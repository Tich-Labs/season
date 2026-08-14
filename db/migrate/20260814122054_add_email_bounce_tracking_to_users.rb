class AddEmailBounceTrackingToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_bounce_type, :string
    add_column :users, :email_bounced_at, :datetime
  end
end
