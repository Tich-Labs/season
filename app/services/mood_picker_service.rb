class MoodPickerService
  # Colors: sage green for positive, dusty rose for negative, teal for neutral
  # SVG files from app/assets/images/icons/emojis/
  MOODS = [
    {name: "Balanced", color: "#7B9D8F", svg: "group-393.svg"},
    {name: "Worried", color: "#D9A4A0", svg: "group-394.svg"},
    {name: "Depressed", color: "#D9A4A0", svg: "group-395.svg"},
    {name: "Energetic", color: "#7B9D8F", svg: "group-396.svg"},
    {name: "Calm", color: "#7B9D8F", svg: "group-398.svg"},
    {name: "Irritated", color: "#D9A4A0", svg: "group-400.svg"},
    {name: "Happy", color: "#7B9D8F", svg: "group-402.svg"},
    {name: "Sick", color: "#D9A4A0", svg: "group-403.svg"},
    {name: "Flirty", color: "#A0C8C0", svg: "group-404.svg"},
    {name: "Normal", color: "#7B9D8F", svg: "group-405.svg"},
    {name: "Suspicious", color: "#D9A4A0", svg: "group-408.svg"},
    {name: "Inspired", color: "#7B9D8F", svg: "group-409.svg"},
    {name: "Shy", color: "#D9A4A0", svg: "group-410.svg"},
    {name: "Unmotivated", color: "#D9A4A0", svg: "group-411.svg"},
    {name: "Confused", color: "#D9A4A0", svg: "group-412.svg"},
    {name: "Impatient", color: "#D9A4A0", svg: "group-413.svg"},
    {name: "Sad", color: "#D9A4A0", svg: "group-414.svg"},
    {name: "Mood swings", color: "#A0C8C0", svg: "group-415.svg"},
    {name: "Sexy", color: "#7B9D8F", svg: "group-416.svg"},
    {name: "Self-critical", color: "#D9A4A0", svg: "group-418.svg"},
    {name: "Guilty", color: "#D9A4A0", svg: "group-419.svg"}
  ].freeze

  def self.all
    MOODS
  end

  def self.find_by_name(name)
    MOODS.find { |m| m[:name] == name }
  end
end
