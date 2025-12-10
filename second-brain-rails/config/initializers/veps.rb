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
