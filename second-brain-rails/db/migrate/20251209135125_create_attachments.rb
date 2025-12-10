class CreateAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :attachments do |t|
      t.references :note, null: false, foreign_key: true
      t.string :filename
      t.string :content_type
      t.string :storage_url
      t.bigint :file_size

      t.timestamps
    end
  end
end
