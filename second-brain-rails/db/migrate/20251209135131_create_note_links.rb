class CreateNoteLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :note_links do |t|
      t.bigint :source_note_id
      t.bigint :target_note_id
      t.string :link_type

      t.timestamps
    end

    add_index :note_links, :source_note_id
    add_index :note_links, :target_note_id
    add_index :note_links, [:source_note_id, :target_note_id], unique: true
  end
end
