module Veps
  class MockClient
    class << self
      def initialize_ledger
        @sequence_counter = 0
        @ledger = []
        @device_id = SecureRandom.uuid
      end
      
      # Submit event at keystroke level
      def submit_event(event_type:, actor:, evidence:)
        initialize_ledger unless @sequence_counter
        
        @sequence_counter += 1
        sequence = @sequence_counter
        
        # Generate vector clock
        vector_clock = generate_vector_clock
        
        # Generate previous hash (blockchain-style)
        previous_hash = @ledger.last&.dig(:hash) || '0' * 64
        
        # Create ledger entry
        entry = {
          sequence_number: sequence,
          event_type: event_type,
          actor: actor,
          evidence: evidence,
          vector_clock: vector_clock,
          previous_hash: previous_hash,
          timestamp: Time.current.utc,
          device_id: @device_id
        }
        
        # Hash this entry
        entry[:hash] = Digest::SHA256.hexdigest(entry.except(:hash).to_json)
        
        # Store in ledger
        @ledger << entry
        
        # Log for debugging
        Rails.logger.debug("VEPS Mock: seq #{sequence}, type: #{event_type}")
        
        {
          success: true,
          sequence_number: sequence,
          vector_clock: vector_clock,
          device_id: @device_id,
          timestamp: entry[:timestamp],
          hash: entry[:hash],
          metadata: {
            ledger_size: @ledger.size,
            previous_hash: previous_hash
          }
        }
      rescue => e
        Rails.logger.error("VEPS submission failed: #{e.message}")
        {
          success: false,
          error: e.message,
          sequence_number: nil
        }
      end
      
      # Query ledger (for time travel)
      def query_ledger(note_id:, up_to_sequence:)
        entries = @ledger.select do |entry|
          entry[:evidence][:note_id] == note_id &&
          entry[:sequence_number] <= up_to_sequence
        end
        
        {
          success: true,
          entries: entries,
          count: entries.size
        }
      end
      
      # Get ledger state
      def ledger_info
        {
          total_events: @ledger.size,
          current_sequence: @sequence_counter,
          device_id: @device_id,
          ledger_head_hash: @ledger.last&.dig(:hash)
        }
      end
      
      private
      
      def generate_vector_clock
        # Simple vector clock: {device_id: sequence}
        { @device_id => @sequence_counter }
      end
    end
  end
end
