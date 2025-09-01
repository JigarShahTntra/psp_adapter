class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.string :txn_id
      t.integer :amount_cents
      t.string :currency
      t.string :status
      t.string :idempotency_key
      t.string :psp_id
      t.string :psp_txn_id
      t.jsonb :metadata

      t.timestamps
    end
  end
end
