class ChangeDischargeToStringOnSymptomLogs < ActiveRecord::Migration[8.1]
  # `discharge` was mistakenly created as an integer column, unlike its sibling
  # `bleeding`/`cravings` (both string) which hold the same kind of thing: a
  # fixed string key like "dry"/"stretchy"/"period". Assigning a string key to
  # an integer column silently casts it via String#to_i -- every discharge
  # type ("dry", "period", "stretchy", ...) collapsed to the same value, 0,
  # since none of them start with a digit. That 0 never matched any real key
  # on reload (`0 == "dry"` is always false), so a selection looked like it
  # took right after tapping (optimistic client-side update) and then silently
  # reverted to "nothing selected" on the next page load -- while the
  # accordion checkmark stayed lit, since `0.present?` is true in Rails. Every
  # existing discharge value is therefore already meaningless noise (0 or
  # nil), so there's no real data to preserve going from integer -> string.
  def up
    change_column :symptom_logs, :discharge, :string
    # Clean up the stray "0" strings the cast above would otherwise leave
    # behind (Postgres casts integer 0 -> string "0", not NULL) -- "0" isn't
    # a valid discharge_grid key either, so this doesn't change behavior, just
    # removes noise from a column that's now correctly typed.
    execute "UPDATE symptom_logs SET discharge = NULL WHERE discharge = '0'"
  end

  def down
    change_column :symptom_logs, :discharge, :integer, using: "NULL"
  end
end
