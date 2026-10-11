class DropLaunchSignups < ActiveRecord::Migration[8.1]
  def change
    drop_table :launch_signups do |t|
      t.string :email
      t.timestamps
    end
  end
end
