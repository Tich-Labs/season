class AddUserToBetaTesters < ActiveRecord::Migration[8.1]
  def change
    add_reference :beta_testers, :user, null: true, foreign_key: true, index: true
  end
end
