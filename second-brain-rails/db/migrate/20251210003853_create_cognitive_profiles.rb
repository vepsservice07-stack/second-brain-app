class CreateCognitiveProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :cognitive_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.json :patterns, default: {}, null: false
      
      # Computed fields for quick access
      t.float :avg_velocity
      t.float :avg_confidence
      t.integer :total_notes_count, default: 0
      t.integer :total_interactions_count, default: 0
      
      t.timestamps
    end
    
    add_index :cognitive_profiles, :patterns
  end
end
