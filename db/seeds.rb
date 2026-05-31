# Cycle phase content — English
[
  {
    phase: "menstrual", locale: "en",
    season_name: "Winter",
    superpower_text: "Deep intuition and inner clarity",
    mood_text: "Reflective, introverted, need for rest",
    take_care_text: "Rest as much as possible, avoid high intensity exercise",
    sport_text: "Gentle yoga, stretching, slow walks",
    nutrition_text: "Iron-rich foods, dark chocolate, warming soups"
  },
  {
    phase: "follicular", locale: "en",
    season_name: "Spring",
    superpower_text: "High creativity and fresh ideas",
    mood_text: "Optimistic, energetic, sociable",
    take_care_text: "Great time to start new projects and plans",
    sport_text: "Cardio, dance, strength training",
    nutrition_text: "Fresh vegetables, salads, light proteins"
  },
  {
    phase: "ovulation", locale: "en",
    season_name: "Summer",
    superpower_text: "Self-reflection and finding solutions",
    mood_text: "Confident, magnetic, communicative",
    take_care_text: "Channel your high energy wisely",
    sport_text: "High intensity workouts, running, group classes",
    nutrition_text: "Anti-inflammatory foods, omega-3, plenty of water"
  },
  {
    phase: "luteal", locale: "en",
    season_name: "Autumn",
    superpower_text: "High creativity and self-reflection",
    mood_text: "Irritable, self-critical, mood swings",
    take_care_text: "Dizziness, constipation, higher pain sensitivity",
    sport_text: "Light movement, walking, yoga to lift mood",
    nutrition_text: "Nutrient-rich foods, magnesium, reduce caffeine"
  },
  {
    phase: "menstrual", locale: "de",
    season_name: "Winter",
    superpower_text: "Tiefe Intuition und innere Klarheit",
    mood_text: "Reflektiert, introvertiert, Ruhebedürfnis",
    take_care_text: "So viel wie möglich ruhen",
    sport_text: "Sanftes Yoga, Stretching, langsame Spaziergänge",
    nutrition_text: "Eisenreiche Lebensmittel, dunkle Schokolade"
  },
  {
    phase: "follicular", locale: "de",
    season_name: "Frühling",
    superpower_text: "Hohe Kreativität und frische Ideen",
    mood_text: "Optimistisch, energetisch, gesellig",
    take_care_text: "Tolle Zeit um neue Projekte zu starten",
    sport_text: "Cardio, Tanzen, Krafttraining",
    nutrition_text: "Frisches Gemüse, Salate, leichte Proteine"
  },
  {
    phase: "ovulation", locale: "de",
    season_name: "Sommer",
    superpower_text: "Selbstreflexion und Lösungen finden",
    mood_text: "Selbstbewusst, magnetisch, kommunikativ",
    take_care_text: "Hohe Energie weise einsetzen",
    sport_text: "Hochintensive Workouts, Laufen, Gruppenkurse",
    nutrition_text: "Entzündungshemmende Lebensmittel, Omega-3"
  },
  {
    phase: "luteal", locale: "de",
    season_name: "Herbst",
    superpower_text: "Hohe Kreativität und Selbstreflexion",
    mood_text: "Reizbar, selbstkritisch, Stimmungsschwankungen",
    take_care_text: "Schwindel, Verstopfung, höhere Schmerzempfindlichkeit",
    sport_text: "Leichte Bewegung, Spazierengehen, Yoga",
    nutrition_text: "Nährstoffreiche Lebensmittel, Magnesium"
  }
].each do |attrs|
  CyclePhaseContent.find_or_create_by(
    phase: attrs[:phase],
    locale: attrs[:locale],
    dietary_preference: ""
  ) do |c|
    c.assign_attributes(attrs)
  end
end

Rails.logger.debug { "Seeded #{CyclePhaseContent.count} phase content records" }

# Dietary-preference nutrition variants (overrides only nutrition_text)
dietary_nutrition = [
  # English
  {phase: "menstrual", locale: "en", dietary_preference: "Vegetarian", nutrition_text: "Iron-rich plant foods, dark chocolate, warm lentil soups"},
  {phase: "follicular", locale: "en", dietary_preference: "Vegetarian", nutrition_text: "Fresh vegetables, quinoa, plant-based proteins"},
  {phase: "ovulation", locale: "en", dietary_preference: "Vegetarian", nutrition_text: "Anti-inflammatory foods, flaxseeds, plenty of water"},
  {phase: "luteal", locale: "en", dietary_preference: "Vegetarian", nutrition_text: "Magnesium-rich greens, oats, dark leafy vegetables"},
  {phase: "menstrual", locale: "en", dietary_preference: "Vegan", nutrition_text: "Iron-rich plant foods, dark chocolate, warming soups with legumes"},
  {phase: "follicular", locale: "en", dietary_preference: "Vegan", nutrition_text: "Fresh vegetables, quinoa, plant-based proteins like tofu"},
  {phase: "ovulation", locale: "en", dietary_preference: "Vegan", nutrition_text: "Anti-inflammatory foods, chia seeds, omega-3 from algae oil"},
  {phase: "luteal", locale: "en", dietary_preference: "Vegan", nutrition_text: "Magnesium-rich greens, pumpkin seeds, reduce caffeine"},
  {phase: "menstrual", locale: "en", dietary_preference: "Pescetarian", nutrition_text: "Iron-rich foods, salmon for omega-3, warming soups"},
  {phase: "follicular", locale: "en", dietary_preference: "Pescetarian", nutrition_text: "Fresh vegetables, light fish, quinoa salads"},
  {phase: "ovulation", locale: "en", dietary_preference: "Pescetarian", nutrition_text: "Anti-inflammatory foods, sardines, plenty of water"},
  {phase: "luteal", locale: "en", dietary_preference: "Pescetarian", nutrition_text: "Magnesium-rich greens, mackerel, reduce caffeine"},
  {phase: "menstrual", locale: "en", dietary_preference: "Pollotaric", nutrition_text: "Iron-rich foods, lean chicken, dark chocolate"},
  {phase: "follicular", locale: "en", dietary_preference: "Pollotaric", nutrition_text: "Fresh vegetables, grilled chicken, light proteins"},
  {phase: "ovulation", locale: "en", dietary_preference: "Pollotaric", nutrition_text: "Anti-inflammatory foods, turkey, plenty of water"},
  {phase: "luteal", locale: "en", dietary_preference: "Pollotaric", nutrition_text: "Complex carbs, chicken, magnesium-rich greens"},
  # German
  {phase: "menstrual", locale: "de", dietary_preference: "Vegetarian", nutrition_text: "Eisenreiche Pflanzenkost, dunkle Schokolade, warme Linsensuppen"},
  {phase: "follicular", locale: "de", dietary_preference: "Vegetarian", nutrition_text: "Frisches Gemüse, Quinoa, pflanzliche Proteine"},
  {phase: "ovulation", locale: "de", dietary_preference: "Vegetarian", nutrition_text: "Entzündungshemmende Lebensmittel, Leinsamen, viel Wasser"},
  {phase: "luteal", locale: "de", dietary_preference: "Vegetarian", nutrition_text: "Magnesiumreiches Grünzeug, Haferflocken, Blattgemüse"},
  {phase: "menstrual", locale: "de", dietary_preference: "Vegan", nutrition_text: "Eisenreiche Pflanzenkost, dunkle Schokolade, Hülsenfrüchte-Suppen"},
  {phase: "follicular", locale: "de", dietary_preference: "Vegan", nutrition_text: "Frisches Gemüse, Quinoa, Tofu als Proteinquelle"},
  {phase: "ovulation", locale: "de", dietary_preference: "Vegan", nutrition_text: "Entzündungshemmende Lebensmittel, Chiasamen, Omega-3 aus Algenöl"},
  {phase: "luteal", locale: "de", dietary_preference: "Vegan", nutrition_text: "Magnesiumreiches Grünzeug, Kürbiskerne, Koffein reduzieren"},
  {phase: "menstrual", locale: "de", dietary_preference: "Pescetarian", nutrition_text: "Eisenreiche Lebensmittel, Lachs für Omega-3, warme Suppen"},
  {phase: "follicular", locale: "de", dietary_preference: "Pescetarian", nutrition_text: "Frisches Gemüse, leichter Fisch, Quinoa-Salate"},
  {phase: "ovulation", locale: "de", dietary_preference: "Pescetarian", nutrition_text: "Entzündungshemmende Lebensmittel, Sardinen, viel Wasser"},
  {phase: "luteal", locale: "de", dietary_preference: "Pescetarian", nutrition_text: "Magnesiumreiches Grünzeug, Makrele, Koffein reduzieren"},
  {phase: "menstrual", locale: "de", dietary_preference: "Pollotaric", nutrition_text: "Eisenreiche Lebensmittel, Hähnchen, dunkle Schokolade"},
  {phase: "follicular", locale: "de", dietary_preference: "Pollotaric", nutrition_text: "Frisches Gemüse, gegrilltes Hähnchen, leichte Proteine"},
  {phase: "ovulation", locale: "de", dietary_preference: "Pollotaric", nutrition_text: "Entzündungshemmende Lebensmittel, Pute, viel Wasser"},
  {phase: "luteal", locale: "de", dietary_preference: "Pollotaric", nutrition_text: "Komplexe Kohlenhydrate, Hähnchen, magnesiumreiches Grünzeug"}
]

dietary_nutrition.each do |attrs|
  CyclePhaseContent.find_or_create_by(
    phase: attrs[:phase],
    locale: attrs[:locale],
    dietary_preference: attrs[:dietary_preference]
  ) do |c|
    c.assign_attributes(
      season_name: CyclePhaseContent.find_by(phase: attrs[:phase], locale: attrs[:locale], dietary_preference: "")&.season_name || "",
      nutrition_text: attrs[:nutrition_text]
    )
  end
end

Rails.logger.debug { "Seeded #{CyclePhaseContent.count} total phase content records (including dietary variants)" }

# Cycle day forecast content (35 days × 6 cards)
require_relative "seeds/cycle_day_contents"
