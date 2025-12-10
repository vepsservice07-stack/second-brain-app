class Snapshot < ApplicationRecord
  belongs_to :note
  
  validates :sequence_number, presence: true
  validates :content, presence: true
  
  # This model exists but isn't required for basic functionality
  # It's ready for when event sourcing is fully implemented
end
