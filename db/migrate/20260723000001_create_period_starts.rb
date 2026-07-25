class CreatePeriodStarts < ActiveRecord::Migration[8.1]
  def change
    create_table :period_starts do |t|
      t.references :user, null: false, foreign_key: true
      t.date :started_on, null: false
      t.timestamps
    end

    add_index :period_starts, [:user_id, :started_on], unique: true

    reversible do |dir|
      dir.up do
        # Backfill existing last_period_start values into period_starts
        # so no user loses their data.
        execute <<~SQL
          INSERT INTO period_starts (user_id, started_on, created_at, updated_at)
          SELECT id, last_period_start, NOW(), NOW()
          FROM users
          WHERE last_period_start IS NOT NULL
        SQL
      end
    end
  end
end
