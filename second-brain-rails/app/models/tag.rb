class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags
  
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i, allow_blank: true }
  
  before_validation :set_default_color, on: :create
  
  private
  
  def set_default_color
    self.color ||= "##{SecureRandom.hex(3)}"
  end
end
