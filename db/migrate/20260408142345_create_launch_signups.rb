class CreateLaunchSignups < ActiveRecord::Migration[8.0]
  def change
    create_table :launch_signups do |t|
      t.string :email

      t.timestamps
    end
  end
end
