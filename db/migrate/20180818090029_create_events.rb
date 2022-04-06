class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :user, foreign_key: true
      t.string :stripe_customer
      t.string :event_type
      t.references :targetable, polymorphic: true
      t.string :stripe_event
      t.text :data
      t.json :charge_ids, default: []

      t.timestamps
    end
  end
end
