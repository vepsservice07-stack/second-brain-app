require 'net/http'
require 'json'

# Real VEPS Client - Production implementation
class VepsClient
  API_URL = ENV.fetch('VEPS_API_URL', 'https://api-gateway-846963717514.us-east1.run.app')
  API_KEY = ENV.fetch('VEPS_API_KEY')
  TIMEOUT = 5 # seconds
  
  class VepsError < StandardError; end
  
  # Submit a rhythm event (structural, not keystrokes)
  def self.submit_rhythm_event(note_id:, user_id:, event_type:, bpm: nil, duration_ms: nil, metadata: {})
    payload = {
      event_type: event_type,
      user_id: user_id.to_s,
      note_id: note_id,
      timestamp_client: (Time.now.to_f * 1000).to_i,
      metadata: metadata
    }
    
    # Add optional fields
    payload[:bpm] = bpm if bpm
    payload[:duration_ms] = duration_ms if duration_ms
    
    response = post('/api/v1/events', payload)
    
    if response['success']
      data = response['data']
      {
        sequence_number: data['sequence_number'],
        vector_clock: data['vector_clock'],
        proof_hash: data['proof_hash'],
        timestamp_veps: data['timestamp_veps'],
        event_id: data['event_id']
      }
    else
      raise VepsError, "VEPS submission failed: #{response['error']}"
    end
  rescue => e
    Rails.logger.error("VEPS submission error: #{e.message}")
    # Fallback to mock for development
    MockVepsClient.submit_rhythm_event(
      note_id: note_id,
      event_type: event_type,
      bpm: bpm,
      duration_ms: duration_ms
    )
  end
  
  # Check causality between two events
  def self.check_causality(event_a_seq, event_b_seq)
    response = get("/api/v1/causality?event_a=#{event_a_seq}&event_b=#{event_b_seq}")
    
    if response['success']
      data = response['data']
      {
        relationship: data['relationship'], # 'happened-before', 'happened-after', 'concurrent'
        time_delta_ms: data['time_delta_ms'],
        confidence: data['confidence']
      }
    else
      raise VepsError, "Causality check failed: #{response['error']}"
    end
  rescue => e
    Rails.logger.error("VEPS causality error: #{e.message}")
    nil
  end
  
  # Batch retrieve events for rhythm playback
  def self.get_events(note_id:, user_id: nil, start_seq: nil, end_seq: nil, limit: 100)
    params = { note_id: note_id, limit: limit }
    params[:user_id] = user_id if user_id
    params[:start_seq] = start_seq if start_seq
    params[:end_seq] = end_seq if end_seq
    
    query_string = params.map { |k, v| "#{k}=#{v}" }.join('&')
    response = get("/api/v1/events?#{query_string}")
    
    if response['success']
      data = response['data']
      {
        events: data['events'],
        total_count: data['total_count']
      }
    else
      raise VepsError, "Event retrieval failed: #{response['error']}"
    end
  rescue => e
    Rails.logger.error("VEPS retrieval error: #{e.message}")
    { events: [], total_count: 0 }
  end
  
  # Health check
  def self.healthy?
    response = get('/health')
    response['success'] == true
  rescue
    false
  end
  
  private
  
  def self.post(path, payload)
    uri = URI("#{API_URL}#{path}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = TIMEOUT
    http.open_timeout = TIMEOUT
    
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = "Bearer #{API_KEY}"
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    response = http.request(request)
    JSON.parse(response.body)
  end
  
  def self.get(path)
    uri = URI("#{API_URL}#{path}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = TIMEOUT
    http.open_timeout = TIMEOUT
    
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{API_KEY}"
    
    response = http.request(request)
    JSON.parse(response.body)
  end
end
