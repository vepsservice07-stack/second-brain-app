class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :content
      t.json :vector_clock
      t.bigint :sequence_number
      t.bigint :user_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :notes, :user_id
    add_index :notes, :sequence_number, unique: true
    add_index :notes, :deleted_at
    add_index :notes, :created_at
  end
end
