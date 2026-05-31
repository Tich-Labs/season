# Cycle Day Content — 35-day forecast for all 6 card types
# Seeded for development. Managed via /admin/cycle_day_contents in production.

Rails.logger.debug "🌱 Seeding cycle day forecast content..."

# ── Superpower ────────────────────────────────────────────────────────────
superpowers = {
  1 => {s: "Letting Go & New Beginnings", l: "Progesterone is at its lowest point, which makes physical and mental 'letting go' easier. Your body sheds the uterine lining – in the same way, you can also mentally release old burdens."},
  2 => {s: "Creativity Through Rest", l: "Estrogen drops sharply, leading to less outward activity but more inner clarity. Your brain processes experiences more slowly, but more deeply – a foundation for creative insights."},
  3 => {s: "Stronger Intuition", l: "Since estrogen is low, your brain switches from rational analysis to emotional perception. The amygdala (emotional center) and hippocampus (memory processing) work more closely together – you sense things more clearly."},
  4 => {s: "Heightened Empathy", l: "Low estrogen means less dopamine → you become calmer, but more sensitive to emotional signals. Your brain focuses more strongly on interpersonal nuances – you sense what others are feeling."},
  5 => {s: "Efficient Prioritization", l: "Your body slows down metabolism to save energy – you focus on the essentials. The prefrontal cortex (for decision-making) is relieved, automatically blocking out unimportant things."},
  6 => {s: "Deeper Self-Reflection", l: "The low estrogen level reduces external distractions, so your focus is more strongly turned inward. Your brain works more slowly, but more deeply – you recognize your own patterns and emotional processes more clearly. This allows you to question old ways of thinking, gain deeper insights, and reflect more consciously on what really does you good."},
  7 => {s: "Sharp Analytical Thinking", l: "Low estrogen means less emotional distraction, so your logical thinking becomes clearer. Your brain is not in 'socializing mode', but processes information at a deeper level."},
  8 => {s: "High Energy Level", l: "Estrogen acts as a natural energizer – it boosts your endurance, concentration, and motivation. Your metabolism speeds up, you're physically more capable, and you have more desire to do things."},
  9 => {s: "Creative Idea Explosion", l: "Since your brain is particularly active now, new ideas come to you faster. The rising estrogen level increases communication between brain regions, amplifying creative inspiration."},
  10 => {s: "Optimal Muscle Growth", l: "In this phase, your body is particularly receptive to muscle building. Rising estrogen improves recovery, while testosterone provides more strength – perfect for more intense workouts."},
  11 => {s: "Social Radiance", l: "Estrogen influences not only your mood, but also your demeanor. You feel more confident, more communicative, and attract others with your energy – a natural effect that is evolutionarily linked to preparing for ovulation."},
  12 => {s: "More Patience & Tolerance", l: "The rising estrogen level stabilizes your mood and provides greater emotional resilience. As a result, you are more patient and can respond to challenges in a more relaxed way."},
  13 => {s: "Better Decision-Making", l: "Since your prefrontal cortex (responsible for logical thinking) is more active, you can make decisions faster and more effectively. You are less uncertain and can recognize opportunities more clearly."},
  14 => {s: "Higher Adaptability", l: "Rising estrogen makes you more open to change. You can adjust more easily to new situations and feel motivated to try new things."},
  15 => {s: "Higher Memory Performance", l: "Rising estrogen strengthens synaptic connections, allowing you to absorb and recall knowledge more easily. Your working memory is particularly active, you can remember details better and learn faster."},
  16 => {s: "Greater Ability to Inspire Others", l: "Due to the rise in testosterone, you feel more confident, while dopamine boosts your enthusiasm. You can carry others away with your energy, appear convincing, and communicate ideas clearly."},
  17 => {s: "Heightened Diplomatic Skills", l: "Estrogen improves emotional perception and language processing, so you communicate sensitively but still clearly. This allows you to skillfully defuse conflicts and put yourself in others' shoes."},
  18 => {s: "Natural Attraction for Like-Minded People", l: "Due to high estrogen levels, you appear more open and charismatic, which is evolutionarily linked to partner selection. This phase is ideal for strengthening relationships – both personal and professional."},
  19 => {s: "Maximum Problem-Solving Skills", l: "Estrogen promotes rapid analytical thinking, while dopamine increases your mental flexibility. This allows you to find creative solutions for complex problems and recognize patterns faster."},
  20 => {s: "Optimal Perception of Non-Verbal Communication", l: "Your brain is now particularly sensitive to facial expressions, gestures, and moods. You intuitively recognize what others are feeling, even if they don't express it."},
  21 => {s: "Maximum Clarity About Own Wishes & Goals", l: "High testosterone levels give you determination, while estrogen brings emotional clarity. This means you can sense exactly what you want and what steps are necessary to achieve it."},
  22 => {s: "High Resilience", l: "Progesterone stabilizes your nervous system and ensures you handle challenges with more composure. Your body is programmed to be more resilient during this phase."},
  23 => {s: "Improved Detail Perception", l: "Progesterone makes your brain switch to 'threat analysis', which means you notice small inconsistencies and details faster. Your analytical thinking is particularly pronounced in this phase."},
  24 => {s: "Increased Productivity", l: "Since your body is preparing for the upcoming menstruation, progesterone sends a biological signal for structuring and completing tasks. You feel less like getting distracted and complete things efficiently."},
  25 => {s: "High Discipline", l: "Falling estrogen makes you less impulsive, while progesterone provides more perseverance. You can stick to plans and routines particularly well in this phase."},
  26 => {s: "Efficient Problem Solving", l: "Less estrogen means less emotional distraction, so you can focus on practical solutions. Your brain processes information more pragmatically and strategically."},
  27 => {s: "Precise Communication", l: "As your body adjusts to rest and structure, you automatically become more direct in your communication. You have less patience for unnecessary discussions and formulate your thoughts more efficiently."},
  28 => {s: "Sharp Judgment of People", l: "Progesterone sharpens your gut feeling, while less estrogen means you are not influenced by wishful thinking. You can more easily judge whom you can trust and who may not be honest."},
  29 => {s: "Effective Crisis Management", l: "This phase is evolutionarily designed to make you more resilient to stress. Your body is ready to act efficiently rather than react emotionally."},
  30 => {s: "Setting Clear Boundaries", l: "Falling estrogen means your need for harmony decreases. You now have less patience for compromises that don't serve you, and set boundaries more clearly."},
  31 => {s: "Increased Assertiveness", l: "Since your testosterone level is slightly elevated, you are particularly assertive in this phase. You defend your opinion and push yourself through with more determination."},
  32 => {s: "Higher Motivation for Self-Care", l: "Progesterone signals your body to prepare for the next phase. As a result, you feel more intensely what does you good – be it healthy nutrition, rest, or movement."},
  33 => {s: "Higher Stress Resistance", l: "Progesterone stabilizes your reaction to stress hormones like cortisol. As a result, you respond more calmly to problems and can view situations more objectively."},
  34 => {s: "Good Time Management", l: "Since progesterone increases your need for order, it's easier for you to set priorities and plan tasks efficiently."},
  35 => {s: "Deeper Self-Acceptance", l: "This phase brings you into a natural reflection about your own needs. You feel more strongly connected to yourself and can question old thought patterns."}
}

# ── Watch Out For ─────────────────────────────────────────────────────────
watch_outs = {
  1 => {s: "Listen to your body instead of working against it", l: "Instead of forcing yourself through demanding days, it's more beneficial to adjust your pace and give your body what it needs right now."},
  2 => {s: "Be gentle with emotional fluctuations", l: "Hormonal fluctuations can make you more sensitive; instead of judging yourself for them, it helps to consciously observe these feelings and accept them with more self-compassion."},
  3 => {s: "Set clear boundaries in stressful situations", l: "Your nervous system is more sensitive in this phase, so it's helpful to consciously protect yourself in stressful moments and not let everything get to you."},
  4 => {s: "Practice self-compassion instead of self-criticism", l: "It's easy to criticize yourself or feel less capable during this phase, but your body is doing a lot – so it helps to treat yourself with more leniency and kindness."},
  5 => {s: "Avoid excessive social commitments", l: "In this phase you tend to be more introverted and need more rest, so too much social interaction can drain your energy faster and stress you out."},
  6 => {s: "Reduce mental overload", l: "Complex, stressful tasks or heated discussions can feel more burdensome during this phase, which is why it makes sense to consciously moderate mental exertion."},
  7 => {s: "Use this time for reflection", l: "Your body is in a natural phase of withdrawal and processing, which is why it's a good opportunity to re-evaluate your emotions, goals, and needs."},
  8 => {s: "Use your rising energy level consciously", l: "Your body is producing more estrogen again, which boosts your energy and motivation; make sure to actively use this phase without overextending yourself."},
  9 => {s: "Adapt your training to your rising performance level", l: "Your body recovers faster, which is why this is the perfect time for more intense workouts or new athletic challenges."},
  10 => {s: "Be open to spontaneous experiences", l: "In this phase, it's easier to try new things, as your willingness to take risks and your sense of adventure increase."},
  11 => {s: "Be careful not to overextend yourself", l: "Even if you're full of drive, you might take on too much and pay for it later in the cycle phases."},
  12 => {s: "Use your emotional balance for important conversations", l: "Now is the best time to have clarifying or strategic conversations, as you are more balanced and solution-oriented."},
  13 => {s: "Pay attention to your sleep quality", l: "Since you are more active, you might neglect your sleep, but good sleep helps you use your energy sustainably."},
  14 => {s: "Consciously prepare for the ovulation phase", l: "This phase is the transition to ovulation, where you have your greatest radiance; now is the perfect time to prepare for your next steps."},
  15 => {s: "Don't take on too many commitments at once", l: "Your energy level is high, but you could overextend yourself, as you are often euphoric and full of drive in this phase, without noticing that you are overstraining your capacities."},
  16 => {s: "Don't underestimate stress", l: "Even if you feel capable, too much pressure can have negative consequences, as your nervous system is in a peak phase due to the hormonal rise, but stress can still cause long-term exhaustion."},
  17 => {s: "Eat and drink enough", l: "Your metabolism is working faster, so a balanced diet is particularly important to avoid cravings, energy swings, and nutrient deficiencies."},
  18 => {s: "Listen to body signals", l: "In this phase, you sometimes overlook small complaints because you feel so good, which can lead you to ignore warning signs such as dehydration, muscle tension, or headaches."},
  19 => {s: "Maintain your boundaries", l: "Because you are so open and communicative, others might take advantage by piling on additional tasks or emotionally claiming you."},
  20 => {s: "Don't schedule too many social commitments", l: "You are more sociable, but need recovery time afterwards, as the next cycle phase (luteal phase) is more inward-focused and you will then need more withdrawal."},
  21 => {s: "Prepare for hormone fluctuations after ovulation", l: "Mood can swing dramatically after ovulation, as estrogen levels drop rapidly and progesterone becomes more noticeable, which often leads to irritability or exhaustion."},
  22 => {s: "Emotionally more sensitive and prone to stress", l: "Your progesterone level is rising while estrogen slowly drops, which can make you emotionally more sensitive and more easily irritated, especially in stressful or overwhelming situations."},
  23 => {s: "Watch for sudden irritability", l: "Your progesterone level is rising while estrogen slowly drops, which can make you emotionally more sensitive and more easily irritated, especially in stressful or overwhelming situations."},
  24 => {s: "Don't overdo perfectionism", l: "You now have a strong urge to do everything tidily and flawlessly, which can lead you to get lost in details and put yourself under unnecessary pressure."},
  25 => {s: "Watch for physical tension", l: "Progesterone can promote water retention and tension, which can manifest as a feeling of tightness in the breasts, head, or joints; gentle movement helps relieve these complaints."},
  26 => {s: "Don't judge yourself for emotional fluctuations", l: "The luteal phase often brings mood swings that feel real, but are hormonally caused; it helps to look at yourself with compassion and not take everything too seriously."},
  27 => {s: "Don't let conflicts escalate", l: "Your patience is lower, which is why you might react more irritably to arguments; it's important in this phase to be more conscious with your words to avoid unnecessary tension."},
  28 => {s: "Shape social interactions more consciously", l: "You feel less like small talk and superficial conversations, which is why it's helpful to focus on deeper, meaningful conversations or to consciously take time for yourself."},
  29 => {s: "Don't overdo perfectionism", l: "You now have a strong urge to do everything tidily and flawlessly, which can lead you to get lost in details and put yourself under unnecessary pressure."},
  30 => {s: "Be mindful with caffeine and alcohol", l: "Your body processes stimulants more slowly, which is why too much coffee can amplify restlessness and sleep problems, and alcohol can trigger more intense mood swings."},
  31 => {s: "Go to bed earlier", l: "Your sleep quality can be affected by hormone fluctuations, which is why conscious sleep hygiene helps you sleep more restfully and minimize fatigue the next day."},
  32 => {s: "Plan for sufficient recovery", l: "Your body is working more intensively to prepare for menstruation, which costs more energy; without enough rest, this can lead to faster exhaustion."},
  33 => {s: "Don't start too many new projects", l: "Your focus is now more on completion and reflection rather than new beginnings, which is why it makes more sense to finish existing tasks rather than take on new challenges."},
  34 => {s: "Consciously manage cravings for unhealthy food", l: "Cravings are hormonally caused, but too much sugar or processed foods can amplify your mood swings and cause energy drops."},
  35 => {s: "Watch for negative self-talk", l: "In this phase, one tends to view oneself more critically, which can affect your self-esteem, even though it's only hormonally caused."}
}

# ── Mood ──────────────────────────────────────────────────────────────────
moods = {
  1 => "Depressed, unwell",
  2 => "Irritable, sad",
  3 => "Unmotivated, self-critical",
  4 => "Calm, contemplative",
  5 => "Normal, shy",
  6 => "Happy, inspired",
  7 => "Energetic, exuberant",
  8 => "Energetic, inspired",
  9 => "Happy, calm",
  10 => "Sexy, confident",
  11 => "Exuberant, libidinous",
  12 => "Normal, socially active",
  13 => "Euphoric, creative",
  14 => "Sexy, optimistic",
  15 => "Libidinous, happy",
  16 => "Sexy, energetic",
  17 => "Happy, exuberant",
  18 => "Inspired, confident",
  19 => "Normal, calm",
  20 => "Worried, suspicious",
  21 => "Irritable, impatient",
  22 => "Mood swings, unmotivated",
  23 => "Irritable, worried",
  24 => "Depressed, sad",
  25 => "Unwell, self-critical",
  26 => "Confused, suspicious",
  27 => "Impatient, annoyed",
  28 => "Sad, unmotivated",
  29 => "Calm, reflective",
  30 => "Happy, normal",
  31 => "Normal, calm",
  32 => "Happy, inspired",
  33 => "Sexy, exuberant",
  34 => "Normal, socially active",
  35 => "Energetic, motivated"
}

# ── Sport ─────────────────────────────────────────────────────────────────
sports = {
  1 => {s: "Allow yourself enough rest when your body demands it", l: "In the first few days, your energy level can be very low due to the drop in hormones (estrogen & progesterone), so you shouldn't force yourself into physical activity if you feel exhausted."},
  2 => {s: "Avoid high-intensity training or long endurance runs", l: "Your body is in a regeneration phase, and intense training can release additional stress hormones (cortisol) that amplify your exhaustion."},
  3 => {s: "Focus on mobility and flexibility", l: "Stretching exercises or light mobility training can help release tension in the lower back and hips, which often arises from cramps."},
  4 => {s: "Avoid heavy strength training", l: "Your body is still regenerating, and heavy lifting can place additional strain on your joints and muscles, as your muscle coordination may be slightly impaired in this phase."},
  5 => {s: "Gradually increase your activity", l: "Your estrogen level begins to rise again, leading to more energy; this is a good time to gently return to strength training or moderate cardio."},
  6 => {s: "Use moderate strength exercises for activation", l: "Light strength training with moderate resistance can help activate your muscles without overtaxing your body."},
  7 => {s: "Prepare for the next cycle phase", l: "Since the follicular phase comes with a natural performance boost, you can slowly adjust your training intensity to get back into a stronger rhythm."},
  8 => {s: "Incorporate gentle strength training", l: "Light to moderate strength training is ideal now, as your muscles are becoming more capable again and you feel stronger."},
  9 => {s: "Gradually increase your cardio training", l: "Your cardiovascular system becomes more resilient, so you can now slowly integrate longer or more intense cardio sessions like jogging or cycling."},
  10 => {s: "Increase the intensity of your strength training", l: "In this phase, you can use heavier weights or higher resistance, as your body recovers better and your muscles work more efficiently."},
  11 => {s: "Use your increased endurance for longer workouts", l: "Your body is now more capable and can better handle longer cardio or HIIT (High-Intensity Interval Training) sessions."},
  12 => {s: "Test new athletic challenges", l: "Your mental clarity and physical resilience are high, which is why you can try out new workouts or sports without quickly feeling overwhelmed."},
  13 => {s: "Plan your most demanding training days deliberately", l: "If you're aiming for personal bests, these days are optimal, as your body is especially resilient due to the high estrogen level."},
  14 => {s: "Use your peak form for intense workouts", l: "Now is the perfect time for demanding training such as strength training with heavy weights, sprints, or long cardio sessions."},
  15 => {s: "Use your strength maximum for intense workouts", l: "Now is the perfect time for heavy strength training, as your body can better handle high loads and build muscle faster."},
  16 => {s: "Focus on explosive movements", l: "High estrogen and testosterone levels improve your reaction speed, strength, and power. Your body can now better handle intense loads and recovers faster. Use this phase for sprint training, HIIT, or strength exercises with explosive movements to tap your full performance potential."},
  17 => {s: "Watch your injury risk", l: "Due to the hormonally induced loosening of ligaments and tendons, the likelihood of sprains or overstretching increases, so you should warm up particularly well and perform controlled movements."},
  18 => {s: "Use your high mental resilience for discipline training", l: "Since you are particularly focused in this phase, you can work specifically on your technique, posture, or endurance limits."},
  19 => {s: "Plan strength training deliberately", l: "Your body can now lift the most weight and build muscle efficiently, which is why this is the perfect moment for maximum strength training."},
  20 => {s: "Use your social energy for group or team sports", l: "Your body and mind are optimal for collaborative workouts, whether team sports, group classes, or training together with friends."},
  21 => {s: "Mentally prepare for the transition into the luteal phase", l: "After ovulation, the progesterone rise begins, which slowly changes your energy level – adjust your training in time."},
  22 => {s: "Reduce the intensity of your workout", l: "Your body needs more recovery, as progesterone raises your body temperature and slightly reduces your endurance performance."},
  23 => {s: "Focus on moderate strength training instead of maximum strength", l: "Your body now stores more water in the muscles, which can make movements feel unusually 'heavy'. Work with medium weights and focus on technique."},
  24 => {s: "Focus on balance and stability", l: "Your body has less coordination strength in this phase, so stability exercises and targeted activation of the deep muscles are sensible."},
  25 => {s: "Use relaxing workouts for mental balance", l: "Gentle yoga, stretching, or pilates can help reduce stress and prevent menstrual complaints."},
  26 => {s: "Listen to your body signals & flexibly adjust your training", l: "Some days you'll feel capable, others require more rest – pay attention to your individual well-being."},
  27 => {s: "Integrate light stretching & mobility training", l: "Water retention and muscle tension can increase; gentle stretching can ease tension in the lower back or legs."},
  28 => {s: "Avoid long endurance sessions", l: "Your body burns more carbohydrates than fat in this phase, which can reduce your endurance performance – short, moderate sessions are now more effective."},
  29 => {s: "Gentle fascia training or myofascial release", l: "Use a foam roller or gentle massage balls to release tension in the legs, lower back, or shoulders, as water retention can make the tissue tighter."},
  30 => {s: "Be gentle with performance fluctuations", l: "It's normal to feel weaker or more sluggish on some days – this phase is not meant for peak performance, but for adjusted movement."},
  31 => {s: "Avoid sudden, intense exertion", l: "Your tendons and joints are more sensitive, which is why you should minimize the risk of injury through controlled movements."},
  32 => {s: "Use gentle sports for relaxation", l: "Swimming, walking, or light cycling can help boost your well-being without overloading you."},
  33 => {s: "Introduce conscious breathing exercises into your training", l: "Your breathing can become shallower, which can lead to tension – slow, deep breaths support the oxygen supply to your muscles."},
  34 => {s: "Avoid excessive stress & overtraining", l: "Progesterone makes you more sensitive to stress hormones, so make sure not to push yourself too hard or get frustrated when your energy level is low."},
  35 => {s: "Mentally & physically prepare for the next phase", l: "Your menstruation is imminent, so it makes sense to adjust your routines now and consciously use movement to support your regeneration."}
}

# ── Nutrition ─────────────────────────────────────────────────────────────
nutritions = {
  1 => {s: "Eat iron-rich foods", l: "Blood loss lowers your iron level, which can cause fatigue. Reach for spinach, lentils, beetroot, pumpkin seeds, or meat (beef, liver) and combine them with vitamin C-rich foods (citrus fruits, peppers) to improve iron absorption.", f: [{name: "Beets", desc: "Provides iron, folate, potassium, and antioxidant plant compounds. Iron and folate contribute to the normal formation of red blood cells and to normal cell division (as part of a balanced diet)."}]},
  2 => {s: "Magnesium for muscle relaxation & fewer cramps", l: "Dark chocolate (at least 85% cocoa), almonds, bananas, and avocados are rich in magnesium and help relieve muscle cramps."},
  3 => {s: "Healthy omega-3 fats for anti-inflammatory effects", l: "Salmon, chia seeds, walnuts, and flaxseeds reduce menstrual cramps and help lower inflammation in the body."},
  4 => {s: "Avoid salty ready-made meals", l: "Heavily processed foods and ready meals often contain a lot of sodium, which increases water retention and can promote bloating."},
  5 => {s: "Dark leafy greens for nutrient balance", l: "Spinach, kale, and broccoli contain iron, magnesium, and B vitamins that boost your energy and support hormonal balance."},
  6 => {s: "More vitamin B6 for mood & hormones", l: "Bananas, salmon, potatoes, and sunflower seeds contain vitamin B6, which promotes serotonin production and can reduce mood swings."},
  7 => {s: "Nuts & seeds for hormonal balance", l: "Pumpkin seeds, sesame, and almonds provide healthy fats and zinc, which regulates the hormonal balance and supports the skin during menstruation."},
  8 => {s: "Continue with iron-rich foods", l: "Your body produces new blood cells after menstruation. Good iron sources are beetroot, lentils, spinach, quinoa, and eggs. Combine them with vitamin C (e.g. oranges, peppers) for better absorption."},
  9 => {s: "Antioxidants for cell protection & skin health", l: "Berries, dark chocolate (at least 85% cocoa), and green tea protect cells from oxidative stress and promote radiant skin."},
  10 => {s: "Increase healthy fats for hormone production", l: "Avocados, olive oil, walnuts, and chia seeds support estrogen production and promote stable hormonal balance."},
  11 => {s: "Hydration with fresh herbal teas & lemon water", l: "Parsley or dandelion tea help flush out excess water and support kidney function."},
  12 => {s: "Fermented foods for strong gut flora", l: "Sauerkraut, kefir, and kimchi promote healthy gut flora, which is important for hormone regulation and nutrient absorption."},
  13 => {s: "More omega-3 fatty acids for anti-inflammatory effects & cell protection", l: "Linseed oil, salmon, chia seeds, and walnuts support the nervous system and ensure optimal brain function."},
  14 => {s: "Vitamin E-rich foods for fertility & hormone regulation", l: "Almonds, hazelnuts, wheat germ, and avocados help protect cell membranes and stabilize estrogen."},
  15 => {s: "Light proteins for muscle building & recovery", l: "Eggs, fish, tofu, or yogurt help prevent muscle breakdown and maintain your performance."},
  16 => {s: "Zinc for ovulation & skin health", l: "Pumpkin seeds, chickpeas, oysters, and cashews support egg maturation and help prevent skin blemishes in this phase."},
  17 => {s: "Vitamin B6 for mood & serotonin production", l: "Potatoes, pistachios, bananas, and sunflower seeds help strengthen the nervous system and prevent cravings."},
  18 => {s: "Probiotics for healthy gut flora", l: "Sauerkraut, kimchi, kefir, and yogurt promote stable digestion and support the immune system."},
  19 => {s: "Complex carbohydrates for sustained energy", l: "Quinoa, sweet potatoes, and whole grain rice stabilize your blood sugar and prevent energy drops."},
  20 => {s: "Vitamin E for cell protection & skin regeneration", l: "Avocados, hazelnuts, sunflower seeds, and wheat germ protect your skin from hormonal fluctuations."},
  21 => {s: "Healthy fats for optimal progesterone production", l: "Nuts, olive oil, and fatty fish help stabilize the hormonal balance and minimize PMS symptoms."},
  22 => {s: "Sesame seeds & sunflower seeds for natural progesterone support", l: "They contain lignans, which help balance hormone levels."},
  23 => {s: "Herbs like chasteberry & lady's mantle for cycle regulation", l: "These plants can help stabilize progesterone and ease PMS symptoms. Do not take if you use hormonal contraception, as they can affect the cycle."},
  24 => {s: "Wild rice & millet for natural detoxification", l: "These gluten-free alternatives support the liver in processing excess hormones. Avoid too much millet if you have an underactive thyroid, as it contains goitrogens that can inhibit iodine absorption."},
  25 => {s: "Bone broth & gelatin for joints & gut health", l: "These help reduce inflammation and promote a stable gut flora. Not suitable for vegetarians or vegans – alternatives are algae broth or plant-based collagen boosters like rosehip powder."},
  26 => {s: "Fennel & celery to reduce water retention", l: "These have a natural diuretic effect and help against a bloated feeling. Avoid fennel if you have an estrogen-sensitive condition (e.g. endometriosis), as fennel can have a slight estrogen-like effect."},
  27 => {s: "Dates & figs as natural sweeteners", l: "They offer a healthy alternative to sugar and provide minerals like potassium & magnesium. Avoid them if you are prone to blood sugar fluctuations, as they can quickly raise insulin levels."},
  28 => {s: "Beans & lentils for gentle blood sugar regulation", l: "They help avoid cravings and provide valuable proteins. Not suitable if you have a sensitive digestion, as they can promote bloating – in this case, soak well beforehand or eat sprouted."},
  29 => {s: "Nettle tea to support kidney function", l: "This tea helps excrete excess fluids. Don't drink if you are already taking diuretic medication or have low blood pressure, as nettle has a strong diuretic effect."},
  30 => {s: "Dark grapes & pomegranate for better circulation", l: "They contain polyphenols that reduce menstrual complaints. Avoid large amounts if you are sensitive to fructose, as they can cause digestive discomfort."},
  31 => {s: "Oatmeal & warm grain porridge for a relaxing effect", l: "They help produce serotonin and have a calming effect on the nervous system. Avoid instant oatmeal, as it has a high glycemic index and raises blood sugar quickly."},
  32 => {s: "Pumpkin & zucchini for gentle digestion & magnesium supply", l: "They are easy to digest and help prevent cramps."},
  33 => {s: "Cashew milk & macadamia nuts for a calming evening ritual", l: "They contain tryptophan, which improves sleep quality. Avoid macadamia nuts if you have a sensitive stomach, as they are high in fat and can trigger gastrointestinal complaints in some people."},
  34 => {s: "Lavender & chamomile tea for mental relaxation", l: "These herbs calm the nervous system and help against sleep problems. Do not take in combination with sedatives or sleeping pills, as they can amplify the effect."},
  35 => {s: "Sweet potatoes & cinnamon for blood sugar stabilization", l: "This combination helps avoid cravings and gives you sustainable energy. Avoid too much cinnamon (especially Cassia cinnamon) if you have liver problems, as it contains coumarin in large amounts, which can strain the liver."}
}

# ── Fertility ─────────────────────────────────────────────────────────────
fertilities = {
  1 => {s: "Fertility probability: 0-1% (extremely unlikely, except with very short cycles)",
        l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
  2 => {s: "Fertility probability: 0-1% (extremely unlikely, except with very short cycles)",
        l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
  3 => {s: "Fertility probability: 0-1% (extremely unlikely, except with very short cycles)",
        l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
  4 => {s: "Fertility probability: 1-3% (low, but possible with short cycles)",
        l: "With a very short cycle (21\u201324 days), a pregnancy is still unlikely, but not impossible, as ovulation could occur as early as day 7\u201310."},
  5 => {s: "Fertility probability: 1-3% (low, but possible with short cycles)",
        l: "With a short cycle of 21\u201324 days, early fertilization could be possible, as sperm can survive up to 5 days and ovulation could occur around day 7\u201310."},
  6 => {s: "Fertility probability: 5-10% (only relevant with short cycles, otherwise still very low)",
        l: "With a short cycle of 21\u201324 days, early fertilization could be possible, as sperm can survive up to 5 days and ovulation could occur around day 7\u201310."},
  7 => {s: "Fertility probability: 5-10% (only relevant with short cycles, otherwise still very low)",
        l: "With a short cycle of 21\u201324 days, early fertilization could be possible, as sperm can survive up to 5 days and ovulation could occur around day 7\u201310."},
  8 => {s: "Fertility probability: 10-20% (high with short cycles, moderate with longer cycles)"},
  9 => {s: "Fertility probability: 10-20% (high with short cycles, moderate with longer cycles)"},
  10 => {s: "Fertility probability: 30-50% (high, especially with medium-length cycles of 26\u201328 days)"},
  11 => {s: "Fertility probability: 30-50% (high, especially with medium-length cycles of 26\u201328 days)"},
  12 => {s: "Fertility probability: 50-80% (maximum with cycles of 26\u201330 days, as ovulation is imminent or has occurred)"},
  13 => {s: "Fertility probability: 50-80% (maximum with cycles of 26\u201330 days, as ovulation is imminent or has occurred)"},
  14 => {s: "Fertility probability: 50-80% (maximum with cycles of 26\u201330 days, as ovulation is imminent or has occurred)"},
  15 => {s: "Fertility probability: 70-90% (maximum chance of pregnancy with a regular cycle)"},
  16 => {s: "Fertility probability: 70-90% (maximum chance of pregnancy with a regular cycle)"},
  17 => {s: "Fertility probability: 20-40% (only still possible if ovulation occurred later than expected or sperm were already present)"},
  18 => {s: "Fertility probability: 20-40% (only still possible if ovulation occurred later than expected)"},
  19 => {s: "Fertility probability: 20-40% (only still possible if ovulation occurred later than expected)"},
  20 => {s: "Fertility probability: 5-10% (only relevant with very long cycles or late ovulation)"},
  21 => {s: "Fertility probability: 5-10% (only relevant with very long cycles or late ovulation)"},
  22 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
  23 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
  24 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
  25 => {s: "Fertility probability: 0-1% (no new fertilization possible, only implantation of an already fertilized egg)"},
  26 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
  27 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
  28 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
  29 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
  30 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
  31 => {s: "Fertility probability: 0% (no more possibility for fertilization, except an already fertilized egg implants)"},
  32 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"},
  33 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"},
  34 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"},
  35 => {s: "Fertility probability: 0% (except a fertilized egg successfully implants, which then leads to pregnancy)"}
}

# ── Seed all content (upserts so re-running updates existing records) ──────
(1..35).each do |day|
  sp = superpowers[day]
  rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: "superpower", locale: "en")
  rec.update!(short_text: sp[:s], long_text: sp[:l])

  wo = watch_outs[day]
  rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: "watch_out_for", locale: "en")
  rec.update!(short_text: wo[:s], long_text: wo[:l])

  rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: "mood", locale: "en")
  rec.update!(short_text: moods[day], long_text: moods[day])

  sp_s = sports[day]
  rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: "sport", locale: "en")
  rec.update!(short_text: sp_s[:s], long_text: sp_s[:l])

  nu = nutritions[day]
  rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: "nutrition", locale: "en")
  rec.update!(short_text: nu[:s], long_text: nu[:l], food_items: nu[:f])

  fe = fertilities[day]
  rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: "fertility", locale: "en")
  rec.update!(short_text: fe[:s], long_text: fe[:l] || fe[:s])
end

Rails.logger.debug { "✅ Seeded #{CycleDayContent.count} cycle day content records (35 days × 6 cards)" }
