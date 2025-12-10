class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :color
      t.bigint :user_id

      t.timestamps
    end
    add_index :tags, :name, unique: true
  end
end
