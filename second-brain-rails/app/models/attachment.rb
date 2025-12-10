class Attachment < ApplicationRecord
  belongs_to :note
  
  # Active Storage
  has_one_attached :file
  
  # Validations
  validates :filename, presence: true
  validates :file, presence: true
  
  # Callbacks
  before_validation :extract_file_metadata, if: -> { file.attached? && filename.blank? }
  
  # Scopes
  scope :images, -> { where("content_type LIKE ?", "image/%") }
  scope :documents, -> { where("content_type LIKE ?", "application/%") }
  
  # Instance methods
  def image?
    content_type&.start_with?('image/')
  end
  
  def document?
    content_type&.start_with?('application/')
  end
  
  def humanized_size
    return 'Unknown' unless file_size
    
    units = ['B', 'KB', 'MB', 'GB']
    size = file_size.to_f
    unit_index = 0
    
    while size >= 1024 && unit_index < units.length - 1
      size /= 1024.0
      unit_index += 1
    end
    
    "#{size.round(2)} #{units[unit_index]}"
  end
  
  def url
    return storage_url if storage_url.present?
    file.attached? ? Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true) : nil
  end
  
  private
  
  def extract_file_metadata
    return unless file.attached?
    
    self.filename = file.filename.to_s
    self.content_type = file.content_type
    self.file_size = file.byte_size
  end
end
