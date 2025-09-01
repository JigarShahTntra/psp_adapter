class PspManifest < ApplicationRecord
  validates :psp_id, presence: true
  scope :active, -> { where(active: true) }

  def manifest_hash
    manifest.with_indifferent_access
  end
end
