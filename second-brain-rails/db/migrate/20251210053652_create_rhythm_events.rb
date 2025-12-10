class CreateRhythmEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :rhythm_events do |t|
      t.references :note, null: false, foreign_key: true
      t.bigint :sequence_number
      t.string :event_type  # 'flow_start', 'pause', 'burst', 'flow_end'
      t.integer :bpm
      t.integer :duration_ms
      t.bigint :timestamp_ms
      t.string :proof_hash
      t.json :vector_clock
      
      t.timestamps
    end
    
    add_index :rhythm_events, :sequence_number
    add_index :rhythm_events, [:note_id, :sequence_number]
  end
end
