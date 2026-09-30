class CreateBetaTesterSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :beta_tester_settings do |t|
      t.string :consent_label, null: false
      t.string :consent_link_text, null: false
      t.string :consent_url, null: false

      t.timestamps
    end
  end
end
