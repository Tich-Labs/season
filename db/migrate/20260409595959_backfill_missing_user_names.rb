class BackfillMissingUserNames < ActiveRecord::Migration[8.0]
  def up
    # Backfill users with NULL names using their email prefix
    execute <<~SQL.squish
      UPDATE users
      SET name = split_part(email, '@', 1)
      WHERE name IS NULL OR name = ''
    SQL

    # Also fix empty strings
    execute <<~SQL.squish
      UPDATE users
      SET name = 'User'
      WHERE name IS NULL OR name = ''
    SQL
  end

  def down
    # No rollback needed - we preserve the backfilled data
  end
end
