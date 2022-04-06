class UserMailer < ApplicationMailer

  def reset_password_instructions(user)
    @user = user
    mail(:to => user.email, :subject => 'Leveled Pro - Password Reset')
  end

  def invite_homeowner(user, password = nil, change_password = false)
    @user = user
    @password = password
    @change_password = change_password
    mail(:to => user.email, :subject => 'Leveled Pro - Project Invitation Waiting')
  end

  def invite_signup_homeowner(email)
    @email = email
    mail(:to => email, :subject => 'Leveled℠Pro Invitation')
  end

  def homeowner_receipt(charge, stripe_event)
    @charge = charge
    @project = charge.project
    @stripe_charge = JSON.parse(stripe_event)['data']['object']

    mail(:to => @charge.user.email, :subject => 'Leveled Pro - Receipt')
  end

  def contact_us(contact)
    @contact = contact
    mail(:from => contact.user.email, :to => ENV['CONTACT_US_EMAIL'], :subject => contact.subject)
  end
end
