class Payment < ApplicationRecord
  validates :txn_id, presence: true
  validates :amount_cents, :currency, presence: true

  def to_canonical_hash
    {
      'txn_id' => txn_id,
      'amount' => { 'value' => amount_cents, 'currency' => currency },
      'metadata' => metadata || {}
    }
  end
end
