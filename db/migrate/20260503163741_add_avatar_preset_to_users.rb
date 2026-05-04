class AddAvatarPresetToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :avatar_preset, :string
  end
end
