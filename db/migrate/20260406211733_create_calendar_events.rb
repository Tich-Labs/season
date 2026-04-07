class CreateCalendarEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :category
      t.text :notes

      t.timestamps
    end
  end
end
