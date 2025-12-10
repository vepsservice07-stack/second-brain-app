# frozen_string_literal: true

module Veps
  class Client
    class << self
      def submit_event(event_type:, actor:, evidence:, source: "second-brain")
        return mock_response if Rails.env.development? && ENV['VEPS_ENABLED'] != 'true'
        
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
          mocked: true
        }
      end
      
      def boundary_adapter_url
        ENV.fetch('BOUNDARY_ADAPTER_URL', 'https://boundary-adapter-846963717514.us-east1.run.app')
      end
    end
  end
end
