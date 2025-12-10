#!/bin/bash
# Phase 2: Cloud Storage & Attachments
# Sets up GCS bucket, Active Storage, upload interface
# Usage: ./phase-2-storage.sh

echo "========================================"
echo "  Phase 2: Cloud Storage Setup"
echo "========================================"
echo ""

# Must be run from parent directory
if [ ! -f "second-brain-setup.sh" ]; then
    echo "❌ Error: Must run from second-brain-app directory"
    echo "Run: cd ~/Code/second-brain-app && ./phase-2-storage.sh"
    exit 1
fi

# Source environment
source ./second-brain-setup.sh

# Verify PROJECT_ID is set
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set"
    echo "Run: source ./second-brain-setup.sh"
    exit 1
fi

cd second-brain-rails

echo "Creating GCS bucket..."

BUCKET_NAME="second-brain-attachments-${PROJECT_ID}"

# Check if bucket exists
if gsutil ls -b gs://${BUCKET_NAME} 2>/dev/null; then
    echo "✅ Bucket already exists: ${BUCKET_NAME}"
else
    # Create bucket
    gsutil mb -p ${PROJECT_ID} -c STANDARD -l ${REGION} gs://${BUCKET_NAME}
    
    # Set lifecycle to delete old versions after 30 days
    cat > /tmp/lifecycle.json << 'JSON'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 30, "isLive": false}
      }
    ]
  }
}
JSON
    
    gsutil lifecycle set /tmp/lifecycle.json gs://${BUCKET_NAME}
    rm /tmp/lifecycle.json
    
    echo "✅ Bucket created: ${BUCKET_NAME}"
fi

echo ""
echo "Installing Active Storage..."

# Install Active Storage
bin/rails active_storage:install
RAILS_ENV=development bin/rails db:migrate

echo "✅ Active Storage installed"
echo ""

echo "Configuring Google Cloud Storage..."

# Add google-cloud-storage gem if not present
if ! grep -q "google-cloud-storage" Gemfile; then
    cat >> Gemfile << 'RUBY'

# Cloud storage
gem 'google-cloud-storage', '~> 1.47', require: false
RUBY
    bundle install
fi

# Configure storage.yml
cat > config/storage.yml << YAML
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

google:
  service: GCS
  project: ${PROJECT_ID}
  credentials: <%= Rails.root.join("config/gcs_keyfile.json") %>
  bucket: ${BUCKET_NAME}

# Use google in production, local in development/test
YAML

# Update environments to use appropriate storage
echo "Configuring environments..."

# Development - use local
if ! grep -q "config.active_storage.service" config/environments/development.rb; then
    sed -i '/Rails.application.configure do/a\  config.active_storage.service = :local' config/environments/development.rb
fi

# Production - use google
if ! grep -q "config.active_storage.service" config/environments/production.rb; then
    sed -i '/Rails.application.configure do/a\  config.active_storage.service = :google' config/environments/production.rb
fi

echo "✅ Storage configured"
echo ""

echo "Setting up service account for GCS access..."

# Create service account if it doesn't exist
SA_NAME="second-brain-storage"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe ${SA_EMAIL} 2>/dev/null; then
    echo "✅ Service account already exists"
else
    gcloud iam service-accounts create ${SA_NAME} \
        --display-name="Second Brain Storage Access" \
        --project=${PROJECT_ID}
    
    echo "✅ Service account created"
fi

# Grant storage permissions
gsutil iam ch serviceAccount:${SA_EMAIL}:objectAdmin gs://${BUCKET_NAME}

# Create key file
KEY_FILE="config/gcs_keyfile.json"
if [ ! -f ${KEY_FILE} ]; then
    gcloud iam service-accounts keys create ${KEY_FILE} \
        --iam-account=${SA_EMAIL} \
        --project=${PROJECT_ID}
    
    echo "✅ Key file created: ${KEY_FILE}"
    echo "⚠️  Add config/gcs_keyfile.json to .gitignore!"
else
    echo "✅ Key file already exists"
fi

# Add to gitignore
if ! grep -q "gcs_keyfile.json" .gitignore; then
    echo "config/gcs_keyfile.json" >> .gitignore
    echo "✅ Added key file to .gitignore"
fi

echo ""
echo "Updating Attachment model for Active Storage..."

cat > app/models/attachment.rb << 'RUBY'
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
RUBY

echo "✅ Attachment model updated"
echo ""

echo "Creating attachments controller..."

cat > app/controllers/attachments_controller.rb << 'RUBY'
class AttachmentsController < ApplicationController
  before_action :set_note
  before_action :set_attachment, only: [:destroy]
  
  def create
    @attachment = @note.attachments.build(attachment_params)
    
    if params[:attachment][:file].present?
      @attachment.file.attach(params[:attachment][:file])
    end
    
    if @attachment.save
      redirect_to @note, notice: 'File uploaded successfully.'
    else
      redirect_to @note, alert: "Upload failed: #{@attachment.errors.full_messages.join(', ')}"
    end
  end
  
  def destroy
    @attachment.destroy
    redirect_to @note, notice: 'Attachment deleted.'
  end
  
  private
  
  def set_note
    @note = Note.find(params[:note_id])
  end
  
  def set_attachment
    @attachment = @note.attachments.find(params[:id])
  end
  
  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
RUBY

echo "✅ Attachments controller created"
echo ""

echo "Adding attachment routes..."

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  root "home#index"
  
  get "search", to: "search#index"
  
  resources :notes do
    member do
      post :restore
    end
    
    resources :attachments, only: [:create, :destroy]
  end
  
  resources :tags, only: [:index, :create, :destroy]
  
  get "up" => "rails/health#show", as: :rails_health_check
end
RUBY

echo "✅ Routes updated"
echo ""

echo "Creating attachment UI partials..."

mkdir -p app/views/attachments

cat > app/views/attachments/_list.html.erb << 'ERB'
<% if note.attachments.any? %>
  <div class="card" style="padding: 20px; margin-top: 16px;">
    <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 12px;">
      ATTACHMENTS (<%= note.attachments.count %>)
    </div>
    
    <div style="display: flex; flex-direction: column; gap: 8px;">
      <% note.attachments.each do |attachment| %>
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 8px; background: var(--bg-tertiary); border: 1px solid var(--bg-tertiary);">
          <div style="display: flex; align-items: center; gap: 12px; flex: 1;">
            <% if attachment.image? && attachment.file.attached? %>
              <%= image_tag attachment.file.variant(resize_to_limit: [100, 100]), style: "max-width: 60px; max-height: 60px; object-fit: cover;" %>
            <% else %>
              <div style="width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; background: var(--bg-primary); font-size: 10px; text-transform: uppercase;">
                <%= attachment.content_type&.split('/')&.last || 'FILE' %>
              </div>
            <% end %>
            
            <div style="flex: 1;">
              <div style="font-size: 12px; font-weight: 600;"><%= attachment.filename %></div>
              <div class="meta" style="margin-top: 2px;">
                <%= attachment.humanized_size %> · <%= attachment.content_type %>
              </div>
            </div>
          </div>
          
          <div style="display: flex; gap: 8px;">
            <% if attachment.file.attached? %>
              <%= link_to "DOWNLOAD", rails_blob_path(attachment.file, disposition: "attachment"), class: "btn", style: "font-size: 10px;" %>
            <% end %>
            <%= button_to "DELETE", note_attachment_path(note, attachment), method: :delete, data: { confirm: "Delete this file?" }, class: "btn", style: "font-size: 10px; color: var(--margin-color); border-color: var(--margin-color);" %>
          </div>
        </div>
      <% end %>
    </div>
  </div>
<% end %>
ERB

cat > app/views/attachments/_upload_form.html.erb << 'ERB'
<div class="card" style="padding: 20px; margin-top: 16px;">
  <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 12px;">
    UPLOAD ATTACHMENT
  </div>
  
  <%= form_with model: [note, note.attachments.build], local: true do |f| %>
    <div style="display: flex; gap: 8px; align-items: end;">
      <div style="flex: 1;">
        <%= f.file_field :file, 
          style: "width: 100%; padding: 8px; background: var(--bg-tertiary); border: 1px solid var(--bg-tertiary); color: var(--text-primary); cursor: pointer;" %>
      </div>
      <%= f.submit "UPLOAD", class: "btn-primary", style: "font-size: 10px;" %>
    </div>
  <% end %>
</div>
ERB

echo "✅ Attachment UI created"
echo ""

echo "Updating note show view to include attachments..."

# This will be added to the note show view
cat > app/views/notes/_attachments_section.html.erb << 'ERB'
<%= render 'attachments/list', note: @note %>
<%= render 'attachments/upload_form', note: @note %>
ERB

echo "✅ Attachment section partial created"
echo ""

# Update the note show view to include attachments
cat >> app/views/notes/show.html.erb << 'ERB'

<%= render 'attachments_section' %>
ERB

echo "✅ Note show view updated"
echo ""

echo "========================================"
echo "  Phase 2 Complete!"
echo "========================================"
echo ""
echo "What was created:"
echo "  ☁️  GCS Bucket: ${BUCKET_NAME}"
echo "  🔑 Service Account: ${SA_EMAIL}"
echo "  💾 Active Storage configured"
echo "  📎 Attachment upload/download UI"
echo "  🖼️  Image preview support"
echo ""
echo "Storage locations:"
echo "  Development: local storage (./storage)"
echo "  Production: GCS bucket"
echo ""
echo "Next: Restart dev services to see attachment functionality"
echo ""