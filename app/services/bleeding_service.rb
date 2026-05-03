class BleedingService
  # Bleeding flow options for menstrual phase tracking
  # SVG files from app/assets/images/m3/bleeding/
  BLEEDINGS = [
    {name: "Light", color: "#D9A4A0", svg: "drop.svg"},
    {name: "Medium", color: "#C08080", svg: "drop-1.svg"},
    {name: "Heavy", color: "#A86060", svg: "drop-2.svg"},
    {name: "Disaster", color: "#884040", svg: "drop-3.svg"}
  ].freeze

  def self.all
    BLEEDINGS
  end

  def self.find_by_name(name)
    BLEEDINGS.find { |b| b[:name] == name }
  end
end
