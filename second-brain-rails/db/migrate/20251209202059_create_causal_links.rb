class CreateCausalLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :causal_links do |t|
      t.integer :cause_note_id, null: false
      t.integer :effect_note_id, null: false
      t.decimal :strength, precision: 3, scale: 2, default: 1.0
      t.text :context
      
      t.timestamps
    end
    
    add_index :causal_links, :cause_note_id
    add_index :causal_links, :effect_note_id
    add_index :causal_links, [:cause_note_id, :effect_note_id], unique: true
    
    add_foreign_key :causal_links, :notes, column: :cause_note_id
    add_foreign_key :causal_links, :notes, column: :effect_note_id
  end
end
