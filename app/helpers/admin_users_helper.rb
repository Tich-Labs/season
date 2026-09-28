# Admin screens identify people by their public User ID only — never name or
# email — so health data is never shown next to who it belongs to.
module AdminUsersHelper
  def admin_user_id_link(user)
    link_to user.public_id.to_s, admin_user_path(user), class: "font-mono text-xs text-brand-primary hover:underline"
  end
end
