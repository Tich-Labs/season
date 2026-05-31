class BackfillCycleDayContents < ActiveRecord::Migration[8.1]
  def up
    # Only seed if empty (production guard: don't overwrite admin-managed data)
    return if CycleDayContent.count >= 210

    # Use a lightweight local model to avoid coupling with app code
    local_class = Class.new(ActiveRecord::Base) do
      self.table_name = "cycle_day_contents"
      self.inheritance_column = nil
    end

    superpowers = {
      1 => {s: "Letting Go & New Beginnings", l: "Progesterone is at its lowest point, which makes physical and mental 'letting go' easier. Your body sheds the uterine lining – in the same way, you can also mentally release old burdens."},
      2 => {s: "Creativity Through Rest", l: "Estrogen drops sharply, leading to less outward activity but more inner clarity. Your brain processes experiences more slowly, but more deeply – a foundation for creative insights."},
      3 => {s: "Stronger Intuition", l: "Since estrogen is low, your brain switches from rational analysis to emotional perception. The amygdala (emotional center) and hippocampus (memory processing) work more closely together – you sense things more clearly."},
      4 => {s: "Heightened Empathy", l: "Low estrogen means less dopamine → you become calmer, but more sensitive to emotional signals. Your brain focuses more strongly on interpersonal nuances – you sense what others are feeling."},
      5 => {s: "Efficient Prioritization", l: "Your body slows down metabolism to save energy – you focus on the essentials. The prefrontal cortex (for decision-making) is relieved, automatically blocking out unimportant things."},
      6 => {s: "Deeper Self-Reflection", l: "The low estrogen level reduces external distractions, so your focus is more strongly turned inward. This allows you to question old ways of thinking, gain deeper insights, and reflect more consciously on what really does you good."},
      7 => {s: "Sharp Analytical Thinking", l: "Low estrogen means less emotional distraction, so your logical thinking becomes clearer. Your brain is not in 'socializing mode', but processes information at a deeper level."},
      8 => {s: "High Energy Level", l: "Estrogen acts as a natural energizer – it boosts your endurance, concentration, and motivation. Your metabolism speeds up, you're physically more capable, and you have more desire to do things."},
      9 => {s: "Creative Idea Explosion", l: "Since your brain is particularly active now, new ideas come to you faster. The rising estrogen level increases communication between brain regions, amplifying creative inspiration."},
      10 => {s: "Optimal Muscle Growth", l: "In this phase, your body is particularly receptive to muscle building. Rising estrogen improves recovery, while testosterone provides more strength – perfect for more intense workouts."},
      11 => {s: "Social Radiance", l: "Estrogen influences not only your mood, but also your demeanor. You feel more confident, more communicative, and attract others with your energy."},
      12 => {s: "More Patience & Tolerance", l: "The rising estrogen level stabilizes your mood and provides greater emotional resilience. As a result, you are more patient and can respond to challenges in a more relaxed way."},
      13 => {s: "Better Decision-Making", l: "Since your prefrontal cortex (responsible for logical thinking) is more active, you can make decisions faster and more effectively."},
      14 => {s: "Higher Adaptability", l: "Rising estrogen makes you more open to change. You can adjust more easily to new situations and feel motivated to try new things."},
      15 => {s: "Higher Memory Performance", l: "Rising estrogen strengthens synaptic connections, allowing you to absorb and recall knowledge more easily. Your working memory is particularly active."},
      16 => {s: "Greater Ability to Inspire Others", l: "Due to the rise in testosterone, you feel more confident, while dopamine boosts your enthusiasm. You can carry others away with your energy."},
      17 => {s: "Heightened Diplomatic Skills", l: "Estrogen improves emotional perception and language processing, so you communicate sensitively but still clearly."},
      18 => {s: "Natural Attraction for Like-Minded People", l: "Due to high estrogen levels, you appear more open and charismatic. This phase is ideal for strengthening relationships – both personal and professional."},
      19 => {s: "Maximum Problem-Solving Skills", l: "Estrogen promotes rapid analytical thinking, while dopamine increases your mental flexibility."},
      20 => {s: "Optimal Perception of Non-Verbal Communication", l: "Your brain is now particularly sensitive to facial expressions, gestures, and moods."},
      21 => {s: "Maximum Clarity About Own Wishes & Goals", l: "High testosterone levels give you determination, while estrogen brings emotional clarity."},
      22 => {s: "High Resilience", l: "Progesterone stabilizes your nervous system and ensures you handle challenges with more composure."},
      23 => {s: "Improved Detail Perception", l: "Progesterone makes your brain switch to 'threat analysis', which means you notice small inconsistencies and details faster."},
      24 => {s: "Increased Productivity", l: "Since your body is preparing for the upcoming menstruation, progesterone sends a biological signal for structuring and completing tasks."},
      25 => {s: "High Discipline", l: "Falling estrogen makes you less impulsive, while progesterone provides more perseverance."},
      26 => {s: "Efficient Problem Solving", l: "Less estrogen means less emotional distraction, so you can focus on practical solutions."},
      27 => {s: "Precise Communication", l: "As your body adjusts to rest and structure, you automatically become more direct in your communication."},
      28 => {s: "Sharp Judgment of People", l: "Progesterone sharpens your gut feeling, while less estrogen means you are not influenced by wishful thinking."},
      29 => {s: "Effective Crisis Management", l: "This phase is evolutionarily designed to make you more resilient to stress."},
      30 => {s: "Setting Clear Boundaries", l: "Falling estrogen means your need for harmony decreases. You now have less patience for compromises that don't serve you."},
      31 => {s: "Increased Assertiveness", l: "Since your testosterone level is slightly elevated, you are particularly assertive in this phase."},
      32 => {s: "Higher Motivation for Self-Care", l: "Progesterone signals your body to prepare for the next phase. You feel more intensely what does you good."},
      33 => {s: "Higher Stress Resistance", l: "Progesterone stabilizes your reaction to stress hormones like cortisol."},
      34 => {s: "Good Time Management", l: "Since progesterone increases your need for order, it's easier for you to set priorities and plan tasks efficiently."},
      35 => {s: "Deeper Self-Acceptance", l: "This phase brings you into a natural reflection about your own needs."}
    }

    watch_outs = {
      1 => {s: "Listen to your body instead of working against it", l: "Instead of forcing yourself through demanding days, it's more beneficial to adjust your pace and give your body what it needs right now."},
      2 => {s: "Be gentle with emotional fluctuations", l: "Hormonal fluctuations can make you more sensitive; instead of judging yourself for them, it helps to consciously observe these feelings and accept them with more self-compassion."},
      3 => {s: "Set clear boundaries in stressful situations", l: "Your nervous system is more sensitive in this phase, so it's helpful to consciously protect yourself in stressful moments and not let everything get to you."},
      4 => {s: "Practice self-compassion instead of self-criticism", l: "It's easy to criticize yourself or feel less capable during this phase, but your body is doing a lot – so it helps to treat yourself with more leniency and kindness."},
      5 => {s: "Avoid excessive social commitments", l: "In this phase you tend to be more introverted and need more rest, so too much social interaction can drain your energy faster and stress you out."},
      6 => {s: "Reduce mental overload", l: "Complex, stressful tasks or heated discussions can feel more burdensome during this phase."},
      7 => {s: "Use this time for reflection", l: "Your body is in a natural phase of withdrawal and processing."},
      8 => {s: "Use your rising energy level consciously", l: "Your body is producing more estrogen again, which boosts your energy and motivation."},
      9 => {s: "Adapt your training to your rising performance level", l: "Your body recovers faster, which is why this is the perfect time for more intense workouts."},
      10 => {s: "Be open to spontaneous experiences", l: "In this phase, it's easier to try new things, as your willingness to take risks increases."},
      11 => {s: "Be careful not to overextend yourself", l: "Even if you're full of drive, you might take on too much and pay for it later."},
      12 => {s: "Use your emotional balance for important conversations", l: "Now is the best time to have clarifying or strategic conversations."},
      13 => {s: "Pay attention to your sleep quality", l: "Since you are more active, you might neglect your sleep."},
      14 => {s: "Consciously prepare for the ovulation phase", l: "This phase is the transition to ovulation, where you have your greatest radiance."},
      15 => {s: "Don't take on too many commitments at once", l: "Your energy level is high, but you could overextend yourself."},
      16 => {s: "Don't underestimate stress", l: "Even if you feel capable, too much pressure can have negative consequences."},
      17 => {s: "Eat and drink enough", l: "Your metabolism is working faster, so a balanced diet is particularly important."},
      18 => {s: "Listen to body signals", l: "In this phase, you sometimes overlook small complaints because you feel so good."},
      19 => {s: "Maintain your boundaries", l: "Because you are so open and communicative, others might take advantage."},
      20 => {s: "Don't schedule too many social commitments", l: "You are more sociable, but need recovery time afterwards."},
      21 => {s: "Prepare for hormone fluctuations after ovulation", l: "Mood can swing dramatically after ovulation."},
      22 => {s: "Emotionally more sensitive and prone to stress", l: "Your progesterone level is rising while estrogen slowly drops."},
      23 => {s: "Watch for sudden irritability", l: "Your progesterone level is rising which can make you more easily irritated."},
      24 => {s: "Don't overdo perfectionism", l: "You now have a strong urge to do everything tidily and flawlessly."},
      25 => {s: "Watch for physical tension", l: "Progesterone can promote water retention and tension."},
      26 => {s: "Don't judge yourself for emotional fluctuations", l: "The luteal phase often brings mood swings that feel real, but are hormonally caused."},
      27 => {s: "Don't let conflicts escalate", l: "Your patience is lower, which is why you might react more irritably."},
      28 => {s: "Shape social interactions more consciously", l: "You feel less like small talk and superficial conversations."},
      29 => {s: "Don't overdo perfectionism", l: "You now have a strong urge to do everything tidily."},
      30 => {s: "Be mindful with caffeine and alcohol", l: "Your body processes stimulants more slowly."},
      31 => {s: "Go to bed earlier", l: "Your sleep quality can be affected by hormone fluctuations."},
      32 => {s: "Plan for sufficient recovery", l: "Your body is working more intensively to prepare for menstruation."},
      33 => {s: "Don't start too many new projects", l: "Your focus is now more on completion and reflection."},
      34 => {s: "Consciously manage cravings for unhealthy food", l: "Cravings are hormonally caused."},
      35 => {s: "Watch for negative self-talk", l: "In this phase, one tends to view oneself more critically."}
    }

    moods = {
      1 => "Depressed, unwell", 2 => "Irritable, sad", 3 => "Unmotivated, self-critical",
      4 => "Calm, contemplative", 5 => "Normal, shy", 6 => "Happy, inspired",
      7 => "Energetic, exuberant", 8 => "Energetic, inspired", 9 => "Happy, calm",
      10 => "Sexy, confident", 11 => "Exuberant, libidinous", 12 => "Normal, socially active",
      13 => "Euphoric, creative", 14 => "Sexy, optimistic", 15 => "Libidinous, happy",
      16 => "Sexy, energetic", 17 => "Happy, exuberant", 18 => "Inspired, confident",
      19 => "Normal, calm", 20 => "Worried, suspicious", 21 => "Irritable, impatient",
      22 => "Mood swings, unmotivated", 23 => "Irritable, worried", 24 => "Depressed, sad",
      25 => "Unwell, self-critical", 26 => "Confused, suspicious", 27 => "Impatient, annoyed",
      28 => "Sad, unmotivated", 29 => "Calm, reflective", 30 => "Happy, normal",
      31 => "Normal, calm", 32 => "Happy, inspired", 33 => "Sexy, exuberant",
      34 => "Normal, socially active", 35 => "Energetic, motivated"
    }

    sports = {
      1 => {s: "Allow yourself enough rest when your body demands it", l: "In the first few days, your energy level can be very low due to the drop in hormones."},
      2 => {s: "Avoid high-intensity training or long endurance runs", l: "Your body is in a regeneration phase, and intense training can release additional stress hormones."},
      3 => {s: "Focus on mobility and flexibility", l: "Stretching exercises or light mobility training can help release tension."},
      4 => {s: "Avoid heavy strength training", l: "Your body is still regenerating, and heavy lifting can place additional strain."},
      5 => {s: "Gradually increase your activity", l: "Your estrogen level begins to rise again, leading to more energy."},
      6 => {s: "Use moderate strength exercises for activation", l: "Light strength training with moderate resistance can help activate your muscles."},
      7 => {s: "Prepare for the next cycle phase", l: "Since the follicular phase comes with a natural performance boost."},
      8 => {s: "Incorporate gentle strength training", l: "Light to moderate strength training is ideal now."},
      9 => {s: "Gradually increase your cardio training", l: "Your cardiovascular system becomes more resilient."},
      10 => {s: "Increase the intensity of your strength training", l: "You can use heavier weights as your body recovers better."},
      11 => {s: "Use your increased endurance for longer workouts", l: "Your body is now more capable."},
      12 => {s: "Test new athletic challenges", l: "Your mental clarity and physical resilience are high."},
      13 => {s: "Plan your most demanding training days deliberately", l: "Your body is especially resilient due to the high estrogen level."},
      14 => {s: "Use your peak form for intense workouts", l: "Now is the perfect time for demanding training."},
      15 => {s: "Use your strength maximum for intense workouts", l: "Now is the perfect time for heavy strength training."},
      16 => {s: "Focus on explosive movements", l: "High estrogen and testosterone levels improve your reaction speed and power."},
      17 => {s: "Watch your injury risk", l: "Due to the hormonally induced loosening of ligaments and tendons."},
      18 => {s: "Use your high mental resilience for discipline training", l: "Since you are particularly focused in this phase."},
      19 => {s: "Plan strength training deliberately", l: "Your body can now lift the most weight."},
      20 => {s: "Use your social energy for group or team sports", l: "Your body and mind are optimal for collaborative workouts."},
      21 => {s: "Mentally prepare for the transition into the luteal phase", l: "After ovulation, the progesterone rise begins."},
      22 => {s: "Reduce the intensity of your workout", l: "Your body needs more recovery."},
      23 => {s: "Focus on moderate strength training instead of maximum strength", l: "Your body now stores more water in the muscles."},
      24 => {s: "Focus on balance and stability", l: "Your body has less coordination strength in this phase."},
      25 => {s: "Use relaxing workouts for mental balance", l: "Gentle yoga, stretching, or pilates can help."},
      26 => {s: "Listen to your body signals & flexibly adjust your training", l: "Pay attention to your individual well-being."},
      27 => {s: "Integrate light stretching & mobility training", l: "Water retention and muscle tension can increase."},
      28 => {s: "Avoid long endurance sessions", l: "Short, moderate sessions are now more effective."},
      29 => {s: "Gentle fascia training or myofascial release", l: "Use a foam roller or gentle massage balls."},
      30 => {s: "Be gentle with performance fluctuations", l: "This phase is not meant for peak performance."},
      31 => {s: "Avoid sudden, intense exertion", l: "Your tendons and joints are more sensitive."},
      32 => {s: "Use gentle sports for relaxation", l: "Swimming, walking, or light cycling can help."},
      33 => {s: "Introduce conscious breathing exercises into your training", l: "Slow, deep breaths support the oxygen supply."},
      34 => {s: "Avoid excessive stress & overtraining", l: "Progesterone makes you more sensitive to stress hormones."},
      35 => {s: "Mentally & physically prepare for the next phase", l: "Your menstruation is imminent."}
    }

    nutritions = {
      1 => {s: "Eat iron-rich foods", l: "Blood loss lowers your iron level. Reach for spinach, lentils, beetroot, pumpkin seeds, or meat and combine them with vitamin C-rich foods to improve iron absorption."},
      2 => {s: "Magnesium for muscle relaxation & fewer cramps", l: "Dark chocolate (at least 85% cocoa), almonds, bananas, and avocados help relieve muscle cramps."},
      3 => {s: "Healthy omega-3 fats for anti-inflammatory effects", l: "Salmon, chia seeds, walnuts, and flaxseeds reduce menstrual cramps."},
      4 => {s: "Avoid salty ready-made meals", l: "Heavily processed foods contain a lot of sodium, which increases water retention."},
      5 => {s: "Dark leafy greens for nutrient balance", l: "Spinach, kale, and broccoli contain iron, magnesium, and B vitamins."},
      6 => {s: "More vitamin B6 for mood & hormones", l: "Bananas, salmon, potatoes, and sunflower seeds promote serotonin production."},
      7 => {s: "Nuts & seeds for hormonal balance", l: "Pumpkin seeds, sesame, and almonds provide healthy fats and zinc."},
      8 => {s: "Continue with iron-rich foods", l: "Your body produces new blood cells after menstruation."},
      9 => {s: "Antioxidants for cell protection & skin health", l: "Berries, dark chocolate, and green tea promote radiant skin."},
      10 => {s: "Increase healthy fats for hormone production", l: "Avocados, olive oil, walnuts, and chia seeds support estrogen production."},
      11 => {s: "Hydration with fresh herbal teas & lemon water", l: "Parsley or dandelion tea help flush out excess water."},
      12 => {s: "Fermented foods for strong gut flora", l: "Sauerkraut, kefir, and kimchi promote healthy gut flora."},
      13 => {s: "More omega-3 fatty acids for anti-inflammatory effects", l: "Linseed oil, salmon, chia seeds support the nervous system."},
      14 => {s: "Vitamin E-rich foods for fertility & hormone regulation", l: "Almonds, hazelnuts, wheat germ, and avocados help stabilize estrogen."},
      15 => {s: "Light proteins for muscle building & recovery", l: "Eggs, fish, tofu, or yogurt help maintain your performance."},
      16 => {s: "Zinc for ovulation & skin health", l: "Pumpkin seeds, chickpeas, oysters, and cashews support egg maturation."},
      17 => {s: "Vitamin B6 for mood & serotonin production", l: "Potatoes, pistachios, bananas help prevent cravings."},
      18 => {s: "Probiotics for healthy gut flora", l: "Sauerkraut, kimchi, kefir support stable digestion."},
      19 => {s: "Complex carbohydrates for sustained energy", l: "Quinoa, sweet potatoes, and whole grain rice stabilize blood sugar."},
      20 => {s: "Vitamin E for cell protection & skin regeneration", l: "Avocados, hazelnuts, sunflower seeds protect your skin."},
      21 => {s: "Healthy fats for optimal progesterone production", l: "Nuts, olive oil, and fatty fish minimize PMS symptoms."},
      22 => {s: "Sesame seeds & sunflower seeds for natural progesterone support", l: "They contain lignans, which help balance hormone levels."},
      23 => {s: "Herbs like chasteberry & lady's mantle for cycle regulation", l: "These plants can help stabilize progesterone."},
      24 => {s: "Wild rice & millet for natural detoxification", l: "These gluten-free alternatives support the liver."},
      25 => {s: "Bone broth & gelatin for joints & gut health", l: "These help reduce inflammation and promote gut flora."},
      26 => {s: "Fennel & celery to reduce water retention", l: "These have a natural diuretic effect."},
      27 => {s: "Dates & figs as natural sweeteners", l: "They provide minerals like potassium and magnesium."},
      28 => {s: "Beans & lentils for gentle blood sugar regulation", l: "They help avoid cravings and provide valuable proteins."},
      29 => {s: "Nettle tea to support kidney function", l: "This tea helps excrete excess fluids."},
      30 => {s: "Dark grapes & pomegranate for better circulation", l: "They contain polyphenols that reduce menstrual complaints."},
      31 => {s: "Oatmeal & warm grain porridge for a relaxing effect", l: "They help produce serotonin and have a calming effect."},
      32 => {s: "Pumpkin & zucchini for gentle digestion & magnesium supply", l: "They are easy to digest and help prevent cramps."},
      33 => {s: "Cashew milk & macadamia nuts for a calming evening ritual", l: "They contain tryptophan, which improves sleep quality."},
      34 => {s: "Lavender & chamomile tea for mental relaxation", l: "These herbs calm the nervous system."},
      35 => {s: "Sweet potatoes & cinnamon for blood sugar stabilization", l: "This combination helps avoid cravings."}
    }

    fertilities = {
      1 => {s: "Fertility probability: 0-1%", l: "Extremely unlikely, except with very short cycles."},
      2 => {s: "Fertility probability: 0-1%", l: "Extremely unlikely, except with very short cycles."},
      3 => {s: "Fertility probability: 0-1%", l: "Extremely unlikely, except with very short cycles."},
      4 => {s: "Fertility probability: 1-3%", l: "Low, but possible with short cycles."},
      5 => {s: "Fertility probability: 1-3%", l: "Low, but possible with short cycles."},
      6 => {s: "Fertility probability: 5-10%", l: "Only relevant with short cycles."},
      7 => {s: "Fertility probability: 5-10%", l: "Only relevant with short cycles."},
      8 => {s: "Fertility probability: 10-20%", l: "High with short cycles."},
      9 => {s: "Fertility probability: 10-20%", l: "High with short cycles."},
      10 => {s: "Fertility probability: 30-50%", l: "High, especially with medium-length cycles."},
      11 => {s: "Fertility probability: 30-50%", l: "High, especially with medium-length cycles."},
      12 => {s: "Fertility probability: 50-80%", l: "Maximum with cycles of 26-30 days."},
      13 => {s: "Fertility probability: 50-80%", l: "Maximum with cycles of 26-30 days."},
      14 => {s: "Fertility probability: 50-80%", l: "Maximum with cycles of 26-30 days."},
      15 => {s: "Fertility probability: 70-90%", l: "Maximum chance of pregnancy with a regular cycle."},
      16 => {s: "Fertility probability: 70-90%", l: "Maximum chance of pregnancy with a regular cycle."},
      17 => {s: "Fertility probability: 20-40%", l: "Only possible if ovulation occurred later."},
      18 => {s: "Fertility probability: 20-40%", l: "Only possible if ovulation occurred later."},
      19 => {s: "Fertility probability: 20-40%", l: "Only possible if ovulation occurred later."},
      20 => {s: "Fertility probability: 5-10%", l: "Only relevant with very long cycles."},
      21 => {s: "Fertility probability: 5-10%", l: "Only relevant with very long cycles."},
      22 => {s: "Fertility probability: 0-1%", l: "No new fertilization possible."},
      23 => {s: "Fertility probability: 0-1%", l: "No new fertilization possible."},
      24 => {s: "Fertility probability: 0-1%", l: "No new fertilization possible."},
      25 => {s: "Fertility probability: 0-1%", l: "No new fertilization possible."},
      26 => {s: "Fertility probability: 0%", l: "No more possibility for fertilization."},
      27 => {s: "Fertility probability: 0%", l: "No more possibility for fertilization."},
      28 => {s: "Fertility probability: 0%", l: "No more possibility for fertilization."},
      29 => {s: "Fertility probability: 0%", l: "No more possibility for fertilization."},
      30 => {s: "Fertility probability: 0%", l: "No more possibility for fertilization."},
      31 => {s: "Fertility probability: 0%", l: "No more possibility for fertilization."},
      32 => {s: "Fertility probability: 0%", l: "Except a fertilized egg successfully implants."},
      33 => {s: "Fertility probability: 0%", l: "Except a fertilized egg successfully implants."},
      34 => {s: "Fertility probability: 0%", l: "Except a fertilized egg successfully implants."},
      35 => {s: "Fertility probability: 0%", l: "Except a fertilized egg successfully implants."}
    }

    (1..35).each do |day|
      local_class.find_or_create_by!(cycle_day: day, card_type: "superpower") do |c|
        c.short_text = superpowers[day][:s]
        c.long_text = superpowers[day][:l]
      end
      local_class.find_or_create_by!(cycle_day: day, card_type: "watch_out_for") do |c|
        c.short_text = watch_outs[day][:s]
        c.long_text = watch_outs[day][:l]
      end
      local_class.find_or_create_by!(cycle_day: day, card_type: "mood") do |c|
        c.short_text = moods[day]
        c.long_text = moods[day]
      end
      local_class.find_or_create_by!(cycle_day: day, card_type: "sport") do |c|
        c.short_text = sports[day][:s]
        c.long_text = sports[day][:l]
      end
      local_class.find_or_create_by!(cycle_day: day, card_type: "nutrition") do |c|
        c.short_text = nutritions[day][:s]
        c.long_text = nutritions[day][:l]
      end
      local_class.find_or_create_by!(cycle_day: day, card_type: "fertility") do |c|
        c.short_text = fertilities[day][:s]
        c.long_text = fertilities[day][:l]
      end
    end
  end

  def down
    # Irreversible — data is essential to the app
  end
end
