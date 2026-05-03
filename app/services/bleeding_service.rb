class BleedingService
  # Bleeding flow options for menstrual phase tracking
  # SVG files from app/assets/images/m3/bleeding/
  # fill_pct: visual intensity fill level
  BLEEDINGS = [
    {name: "Light", color: "#D9A4A0", svg: "drop.svg", fill_pct: 25},
    {name: "Medium", color: "#C08080", svg: "drop-1.svg", fill_pct: 50},
    {name: "Heavy", color: "#A86060", svg: "drop-2.svg", fill_pct: 75},
    {name: "Disaster", color: "#884040", svg: "drop-3.svg", fill_pct: 100}
  ].freeze

  def self.all
    BLEEDINGS
  end

  def self.find_by_name(name)
    BLEEDINGS.find { |b| b[:name] == name }
  end
end
