class AddSupportToFeedbackType < ActiveRecord::Migration[8.1]
  def change
    # feedback_type is a string column — no schema change needed for string enums
    # This migration exists as a record of the support type being added to the model
  end
end
