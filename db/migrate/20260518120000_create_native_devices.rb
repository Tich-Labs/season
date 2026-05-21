class CreateNativeDevices < ActiveRecord::Migration[7.0]
  def change
    create_table :native_devices do |t|
      t.references :user, foreign_key: true, null: true
      t.string :device_token, null: false
      t.string :platform, null: false, default: "ios"
      t.string :app_version
      t.timestamps
    end
    add_index :native_devices, :device_token, unique: true
  end
end
