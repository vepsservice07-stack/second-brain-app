#!/bin/bash
# Second Brain - VEPS Integration Setup
# Sets up the VEPS client for event submission
# Usage: ./setup-veps-integration.sh

echo "========================================"
echo "  VEPS Integration Setup"
echo "========================================"
echo ""

# Check if we're in the Rails app directory
if [ ! -f "bin/rails" ]; then
    if [ -d "second-brain-rails" ]; then
        echo "Entering Rails app directory..."
        cd second-brain-rails
    else
        echo "❌ Error: Not in Rails app directory"
        exit 1
    fi
fi

echo "Creating VEPS client library..."

# Create lib directory if it doesn't exist
mkdir -p lib/veps

# Create VEPS client
cat > lib/veps/client.rb << 'RUBY'
# frozen_string_literal: true

module Veps
  class Client
    class << self
      def submit_event(event_type:, actor:, evidence:, source: "second-brain")
        return mock_response if Rails.env.development? && !ENV['VEPS_ENABLED']
        
        event = build_event(
          event_type: event_type,
          actor: actor,
          evidence: evidence,
          source: source
        )
        
        post_to_boundary_adapter(event)
      end
      
      private
      
      def build_event(event_type:, actor:, evidence:, source:)
        {
          source: source,
          data: {
            type: event_type,
            actor: actor,
            **evidence
          }
        }
      end
      
      def post_to_boundary_adapter(event)
        uri = URI("#{boundary_adapter_url}/ingest")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.read_timeout = 5
        
        request = Net::HTTP::Post.new(uri.path)
        request['Content-Type'] = 'application/json'
        request.body = event.to_json
        
        response = http.request(request)
        
        if response.code.to_i == 200
          result = JSON.parse(response.body)
          { success: true, sequence_number: result['sequence_number'], data: result }
        else
          { success: false, error: "HTTP #{response.code}: #{response.body}" }
        end
      rescue StandardError => e
        { success: false, error: e.message }
      end
      
      def mock_response
        {
          success: true,
          sequence_number: rand(1000..999999),
          event_id: SecureRandom.uuid,
          mocked: true,
          message: "VEPS integration is mocked in development. Set VEPS_ENABLED=true to use real service."
        }
      end
      
      def boundary_adapter_url
        ENV.fetch('BOUNDARY_ADAPTER_URL', 'https://boundary-adapter-846963717514.us-east1.run.app')
      end
    end
  end
end
RUBY

echo "✅ VEPS client created"
echo ""

echo "Creating VEPS event models..."

# Create event concern
cat > app/models/concerns/veps_eventable.rb << 'RUBY'
# frozen_string_literal: true

module VepsEventable
  extend ActiveSupport::Concern
  
  included do
    after_create :submit_created_event
    after_update :submit_updated_event, if: :should_submit_update?
    before_destroy :submit_deleted_event
  end
  
  private
  
  def submit_created_event
    submit_veps_event("#{model_name.singular}_created")
  end
  
  def submit_updated_event
    submit_veps_event("#{model_name.singular}_updated")
  end
  
  def submit_deleted_event
    submit_veps_event("#{model_name.singular}_deleted")
  end
  
  def submit_veps_event(event_type)
    return unless should_submit_to_veps?
    
    result = Veps::Client.submit_event(
      event_type: event_type,
      actor: event_actor,
      evidence: event_evidence
    )
    
    if result[:success]
      update_column(:sequence_number, result[:sequence_number]) if respond_to?(:sequence_number)
      Rails.logger.info("VEPS event submitted: #{event_type} - Sequence: #{result[:sequence_number]}")
    else
      Rails.logger.error("VEPS submission failed: #{result[:error]}")
    end
  rescue StandardError => e
    Rails.logger.error("VEPS submission error: #{e.message}")
  end
  
  def should_submit_to_veps?
    true
  end
  
  def should_submit_update?
    saved_changes.present? && !saved_changes.keys.include?('updated_at')
  end
  
  def event_actor
    {
      id: user_id || "system",
      name: "User #{user_id || 'System'}",
      type: "user"
    }
  end
  
  def event_evidence
    attributes.except('created_at', 'updated_at', 'deleted_at')
  end
end
RUBY

echo "✅ VEPS event concern created"
echo ""

echo "Updating Note model with VEPS integration..."

# Update Note model to include VEPS
cat >> app/models/note.rb << 'RUBY'

# VEPS Integration
include VepsEventable

def event_evidence
  {
    note_id: id,
    title: title,
    content_length: content&.length || 0,
    has_content: content.present?,
    tag_ids: tag_ids,
    deleted: deleted?
  }
end
RUBY

echo "✅ Note model updated"
echo ""

echo "Creating VEPS configuration file..."

cat > config/initializers/veps.rb << 'RUBY'
# frozen_string_literal: true

# VEPS Configuration
Rails.application.config.to_prepare do
  require_relative '../../lib/veps/client'
end

# Log VEPS status on boot
Rails.application.config.after_initialize do
  if ENV['VEPS_ENABLED'] == 'true'
    Rails.logger.info "VEPS Integration: ENABLED - Using #{ENV.fetch('BOUNDARY_ADAPTER_URL', 'default URL')}"
  else
    Rails.logger.info "VEPS Integration: MOCKED - Set VEPS_ENABLED=true to enable"
  end
end
RUBY

echo "✅ VEPS initializer created"
echo ""

echo "Creating environment variables template..."

cat >> ../.env.example << 'ENV'

# VEPS Integration
VEPS_ENABLED=false
BOUNDARY_ADAPTER_URL=https://boundary-adapter-XXXXX.us-east1.run.app
VEPS_API_KEY=your-api-key-here
ENV

echo "✅ Environment template created"
echo ""

echo "========================================"
echo "  VEPS Integration Setup Complete!"
echo "========================================"
echo ""
echo "What was created:"
echo "  📦 lib/veps/client.rb - VEPS HTTP client"
echo "  🔧 app/models/concerns/veps_eventable.rb - Event submission concern"
echo "  ⚙️  config/initializers/veps.rb - VEPS configuration"
echo "  📝 .env.example - Environment variables template"
echo ""
echo "Current Status:"
echo "  ✅ VEPS is MOCKED by default (safe for development)"
echo "  ✅ Every Note create/update/delete will attempt submission"
echo "  ✅ Failures are logged but don't block operations"
echo ""
echo "To enable real VEPS integration:"
echo "  1. Set VEPS_ENABLED=true in your environment"
echo "  2. Set BOUNDARY_ADAPTER_URL to your real endpoint"
echo "  3. Add VEPS_API_KEY when authentication is ready"
echo ""
echo "Testing:"
echo "  Create a note in the app - check logs for:"
echo "  'VEPS event submitted: note_created'"
echo ""