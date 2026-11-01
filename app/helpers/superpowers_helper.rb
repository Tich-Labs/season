module SuperpowersHelper
  # Localized display name for a SUPERPOWERS entry. The stored rating key stays
  # the English name; only the label shown to the user is translated.
  def superpower_label(name)
    key = name.to_s.downcase.gsub(/[^a-z]+/, "_").delete_suffix("_")
    t("superpowers.items.#{key}", default: name.to_s)
  end
end
