class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :notes, dependent: :destroy
  has_one :cognitive_profile, dependent: :destroy
  
  after_create :create_cognitive_profile!
  
  def semantic_signature
    cognitive_profile&.analytics || {}
  end
end
