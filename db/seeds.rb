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
    locale: attrs[:locale]
  ) do |c|
    c.assign_attributes(attrs)
  end
end

Rails.logger.info "Seeded #{CyclePhaseContent.count} phase content records"
