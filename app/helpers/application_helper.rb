module ApplicationHelper
  # Pagy::Frontend - only load if pagy gem is available
  begin
    include Pagy::Frontend
  rescue
    # Pagy not fully loaded yet
  end
end
