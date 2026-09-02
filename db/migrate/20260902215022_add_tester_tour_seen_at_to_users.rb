class AddTesterTourSeenAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :tester_tour_seen_at, :datetime
  end
end
