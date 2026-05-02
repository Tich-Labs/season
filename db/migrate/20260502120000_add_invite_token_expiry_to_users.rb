class AddInviteTokenExpiryToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :invite_token_expires_at, :datetime, null: true

    # Set expiry to 7 days from now for any existing unused invite tokens
    reversible do |dir|
      dir.up do
        User.where("invite_token IS NOT NULL AND invite_accepted_at IS NULL")
          .update_all(invite_token_expires_at: 7.days.from_now)
      end
    end
  end
end
