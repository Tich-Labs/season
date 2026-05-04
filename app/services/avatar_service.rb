class AvatarService
  PRESETS = [
    { id: "frame-219", name: "Birthday Cat", file: "frame-219.png" },
    { id: "frame-220", name: "Licking Cat", file: "frame-220.png" },
    { id: "frame-225", name: "Playful Cat", file: "frame-225.png" },
    { id: "frame-230", name: "Sleepy Cat", file: "frame-230.png" },
    { id: "frame-231", name: "Purring Cat", file: "frame-231.png" },
    { id: "frame-242", name: "Happy Cat", file: "frame-242.png" },
    { id: "frame-243", name: "Curious Cat", file: "frame-243.png" },
    { id: "frame-244", name: "Calm Cat", file: "frame-244.png" },
    { id: "frame-245", name: "Silly Cat", file: "frame-245.png" },
    { id: "frame-248", name: "Proud Cat", file: "frame-248.png" },
    { id: "frame-249", name: "Tender Cat", file: "frame-249.png" }
  ].freeze

  def self.all
    PRESETS
  end

  def self.find_by_id(id)
    PRESETS.find { |p| p[:id] == id }
  end

  def self.file_path(id)
    preset = find_by_id(id)
    "avatars/#{preset[:file]}" if preset
  end
end
