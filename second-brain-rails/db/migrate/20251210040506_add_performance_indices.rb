class AddPerformanceIndices < ActiveRecord::Migration[8.0]
  def change
    # Only add if they don't exist
    add_index :notes, [:user_id, :created_at] unless index_exists?(:notes, [:user_id, :created_at])
    add_index :notes, [:user_id, :updated_at] unless index_exists?(:notes, [:user_id, :updated_at])
    add_index :notes, :title unless index_exists?(:notes, :title)
    add_index :cognitive_profiles, :user_id unless index_exists?(:cognitive_profiles, :user_id)
  end
end
