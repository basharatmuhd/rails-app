class EventsService
  def self.record_stripe_event(stripe_event)
    stripe_event_object = stripe_event.data.object
    event = Event.create(event_type: stripe_event.type, stripe_event: stripe_event.id, data: stripe_event.to_json)
    EventsService.send("#{stripe_event.type.gsub('.', '_')}_event", event, stripe_event) if event.persisted?
  end

  def self.charge_succeeded_event(event, stripe_event)
    stripe_event_object = stripe_event.data.object
    stripe_charge_id = stripe_event_object.id
    metadata = stripe_event_object.metadata
    customer_id = stripe_event_object.customer
    event.update(stripe_customer: customer_id, user: User.find_by(stripe_customer: customer_id))
    charge = Charge.find_by stripe_charge: stripe_charge_id
    if charge && charge.project_id.to_s == metadata['project_id']
      event.update(targetable: charge.project, charge_ids: [charge.id])
      if event.event_type == 'charge.succeeded'
        unless charge.charge_succeeded_at? # not sent email yet
          UserMailer.homeowner_receipt(charge, event.data).deliver_later rescue nil
        end
        charge.update_columns(source_brand: stripe_event_object.source.brand, charge_succeeded_at: Time.at(stripe_event.created))
        if project = charge.project
          project.active!
          ActivityService.create_activity('charge.succeeded', charge, project, project)
          NotificationsService.delay(priority: 3).notify([project.user], 'Project Update: Payment Made', 'Great News! Your project is ready for the next phase. A payment has been made. Log into your account for more details!')
          SystemMessageRelayJob.perform_now(project, 'project.status.changed', 'active', recipient_ids: project.homeowner_ids + [project.user_id]) if project.active?
          begin
            balance_transaction = Stripe::BalanceTransaction.retrieve(stripe_event_object.balance_transaction)
            charge.update(stripe_fee: balance_transaction.fee, net_amount: balance_transaction.net)
            PaymentsService.payout charge if charge.immediate && charge.errors.blank?
          rescue Exception => e
            puts e.message
          end
        end
      end
    end
  end

  def self.charge_failed_event(event, stripe_event)
    charge_succeeded_event(event, stripe_event)
  end

  def self.payout_paid_event(event, stripe_event)
    stripe_event_object = stripe_event.data.object
    metadata = stripe_event_object.metadata
    charge = Charge.find_by stripe_payout: stripe_event_object.id
    if charge && charge.project_id.to_s == metadata['project_id']
      event.update(targetable: charge.project, charge_ids: [charge.id])
      if event.event_type == 'payout.paid'
        charge.update_columns(payout_paid_at: Time.at(stripe_event.created))
        if (project = charge.project).present?
          project.archived! if project.all_completed?
          SystemMessageRelayJob.perform_now(project, 'charge.payout.paid', 'Payout paid', recipient_ids: project.homeowner_ids + [project.user_id])
          SystemMessageRelayJob.perform_now(project, 'project.status.changed', 'archived', recipient_ids: project.homeowner_ids + [project.user_id]) if project.archived?
          ActivityService.create_activity('payout.paid', charge, project, project)
        end
      end
    end
  end

  def self.payout_failed_event(event, stripe_event)
    payout_paid_event(event, stripe_event)
  end
end
