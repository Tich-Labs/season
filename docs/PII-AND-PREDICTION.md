# PII, Privacy & Prediction — Architecture Document

**Last updated:** 2 July 2026  
**Audience:** Engineering, Product, ML  
**Prerequisites:** [`docs/userdata.md`](userdata.md) (data classification), [`docs/GDPR-AUDIT.md`](GDPR-AUDIT.md) (compliance status), [`docs/Oky_Prediction_Engine_How_To_Build.pdf`](Oky_Prediction_Engine_How_To_Build.pdf) (reference prediction design)

---

## The Core Tension

Season's value proposition is prediction — knowing when your next period starts, when you're ovulating, how your symptoms trend across cycles. Prediction requires **data**. Privacy requires **restricting that data**.

These goals pull in opposite directions:

| Goal | Requires | Threatens |
|------|----------|-----------|
| Accurate prediction | Broad historical data, server-side aggregation, many features | Data minimization, local-first storage |
| User privacy | Local storage, encryption, minimal collection, ephemeral processing | Model training data, feature richness, cross-user learning |

The challenge is not to eliminate the tension — it's to make the right tradeoffs for each user and be transparent about them.

---

## Inventory: Every Data Point × Prediction Value

This table maps every health data point Season collects against its utility for a predictive model, and whether removing it would cripple prediction quality.

### Symptom Logs (`symptom_logs`)

| Column | Prediction value | Needed for cycle prediction? | Needed for symptom prediction? | Can be encrypted? | Risk of removing |
|--------|-----------------|------------------------------|-------------------------------|-------------------|------------------|
| `mood` (0-10) | High | Correlated with cycle phase | Core target | Yes | High — mood effects are a top user feature |
| `moods` (JSONB array) | Medium | User labels for cycle context | Feature for mood patterns | Yes | Low-medium — duplicates `mood` scale |
| `mood_text` (text) | Low | NLP feature for cycle sentiment | Feature | Yes | Low — user-authored, sparse |
| `energy` (0-10) | High | Predicts luteal dips | Feature | Yes | Medium — correlated with sleep/mental |
| `sleep` (hours) | High | Cycle-linked sleep disruption | Feature | Yes | Medium — partially proxied by `energy` |
| `pain` (0-10) | High | Period pain prediction | Core target | Yes | High — key menstrual symptom |
| `physical` (overall) | Medium | Aggregated physical score | Feature | Yes | Low — redundant with `physical_symptoms` |
| `mental` (overall) | Medium | Aggregated mental score | Feature | Yes | Low — redundant with `mental_symptoms` |
| `physical_symptoms` (JSONB) | **Very High** | 24 symptom keys + severity (cramps, headaches, bloating, etc.) | Core feature set | Yes | **Critical** — richest signal in the table |
| `mental_symptoms` (JSONB) | **Very High** | 8 symptom keys + severity (anxiety, insomnia, irritability) | Core feature set | Yes | **Critical** — key cycle-linked signals |
| `bleeding` (enum) | **Very High** | Period start/end, flow level | Core feature | Yes | **Critical** — the most fundamental signal |
| `cravings` (string) | Medium | Cycle-linked food cravings | Feature | Yes | Low — sparse, some users never enter it |
| `discharge` (0-3) | **Very High** | Ovulation prediction (egg-white mucus) | Core feature | Yes | **Critical** — one of the best ovulation signals |
| `sexual_intercourse` (bool) | Medium | Fertility window validation | Feature | Yes | Low — sparse, privacy-sensitive |
| `intercourse_tags` (string) | Low | Additional context | Feature | Yes | Low — rarely used |
| `temperature` (decimal) | **Very High** | Ovulation confirmation (BBT rise) | Core feature | Yes | **Critical** — gold standard for ovulation detection |
| `weight` (decimal) | Low-medium | Cycle-linked weight changes | Feature | Yes | Low — sparse, noisy signal |
| `notes` (text) | Low | Potential NLP for symptom detection | Feature | Yes | Low — unstructured, PII risk |

### Superpower Logs (`superpower_logs`)

| Column | Prediction value | Notes |
|--------|-----------------|-------|
| `ratings` (JSONB, 20 sliders) | Medium | Self-assessment trends across cycle. Could predict phase transitions at population level. Not useful for core period prediction. |

### Cycle Entries (`cycle_entries`)

| Column | Prediction value | Notes |
|--------|-----------------|-------|
| `phase` | **Ground truth label** | This *is* what we're predicting |
| `cycle_day` | **Critical feature** | Day-in-cycle is the primary input feature |
| `period_start` / `period_end` | **Ground truth labels** | These are what we're predicting |
| `season_name` | Low | Derived from phase — redundant |

### User Profile (`users`)

| Column | Prediction value | Notes |
|--------|-----------------|-------|
| `cycle_length` | **Critical** | Prior for cycle prediction |
| `period_length` | **Critical** | Prior for period prediction |
| `has_regular_cycle` | High | Determines model confidence / uncertainty |
| `uses_hormonal_birth_control` | **Critical** | Changes cycle dynamics entirely — separate model branch needed |
| `contraception_type` | Medium | Different types affect cycles differently |
| `life_stage` | Medium | Perimenopause vs menstruating vs postpartum |
| `birthday` | Low-medium | Age correlates with cycle regularity |
| `food_preference` | None | Nutrition content filtering only |
| `language` | None | i18n only |

### Summary: What the Prediction Model Actually Needs

**Must-have (prediction breaks without these):**
- `cycle_entries.cycle_day`, `.phase`, `.period_start`, `.period_end` — ground truth
- `users.cycle_length`, `.period_length`, `.has_regular_cycle`, `.uses_hormonal_birth_control`
- `symptom_logs.bleeding`, `.discharge`, `.temperature` — ovulation + period signals
- `symptom_logs.physical_symptoms`, `.mental_symptoms` — cycle-correlated features

**Nice-to-have (improves accuracy, not critical):**
- `symptom_logs.mood`, `.energy`, `.sleep`, `.pain`, `.cravings`
- `superpower_logs.ratings`

**Safe to drop (no prediction impact):**
- `symptom_logs.mood_text`, `.intercourse_tags`, `.weight`, `.notes`
- `users.food_preference`, `.language`, `.avatar_preset`

---

## Architecture Options (Ranked by Privacy)

### Option 0: Current — Server-only, plaintext

```
User → HTTPS → Rails → PostgreSQL (plaintext) → Prediction model
```

| Dimension | Rating |
|-----------|--------|
| Privacy | Low — full plaintext on server |
| Prediction | High — all data available for training + inference |
| Complexity | Low — no changes needed |
| Breach impact | **Catastrophic** — emails, health data, notes exposed |

### Option 1: Server + Encrypted Columns (Recommended now)

```
User → HTTPS → Rails → Lockbox → PostgreSQL (AES-256 encrypted) → Rails decrypts → Prediction model
```

| Dimension | Rating |
|-----------|--------|
| Privacy | Medium — health data encrypted at rest, plaintext in memory during request |
| Prediction | High — model sees decrypted data transparently |
| Complexity | Low — `lockbox` gem, add `encrypts` to model columns |
| Breach impact | **Limited** — encrypted columns unreadable without key |
| Implementation | Encrypt: `temperature`, `weight`, `notes`, `intercourse_tags`, `mood_text`, `cravings` |

`lockbox` encrypts/decrypts transparently at the ActiveRecord layer. The prediction model code doesn't change — it reads `symptom_log.temperature` as a float and the gem handles decryption.

### Option 2: Server + Encrypted Columns + Health Profile Segregation

```
users table                    user_health_profiles table (encrypted)
├── email                       ├── birthday
├── name                        ├── cycle_length
├── encrypted_password          ├── period_length
└── public_id (UUID)            ├── contraception_type
                                └── life_stage
```

Same as Option 1 plus splitting health fields out of the `users` table. Prevents `SELECT * FROM users` from exposing both identity and health data together.

| Dimension | Rating |
|-----------|--------|
| Privacy | Medium-high — identity and health require two separate queries |
| Prediction | High — model still sees all data |
| Complexity | Medium — migration + model split |
| Breach impact | Limited to whichever table is breached |

### Option 3: Local-First + On-Device ML

```
User → IndexedDB (local) → On-device CoreML / TensorFlow.js model → Optional encrypted backup to server
                                                        ↓
                                           No cross-user training
```

| Dimension | Rating |
|-----------|--------|
| Privacy | **Highest** — data never leaves device |
| Prediction | Medium — per-user model only, no population priors, hard to update |
| Complexity | **Very High** — rewrite data layer, port model to CoreML/TF.js, building per-user models from scratch |
| Breach impact | **None** — no central health data |

**When to offer this:**
- Users in restrictive jurisdictions (abortion criminalised)
- Privacy-maximalist users
- As a premium tier ("your data never leaves your phone")

**Limitations to be honest about:**
- First 3 cycles will have poor predictions (no prior)
- No rare-event detection (PCOS, PMDD patterns require population data)
- Model updates require app store submission
- No cross-device sync (or sync requires encryption layer)

### Option 4: Local-First + Encrypted Server Sync + Server Inference

```
User → IndexedDB → User's encryption key → Encrypted sync → Server decrypts ephemerally → Run model → Return prediction → Discard plaintext
```

| Dimension | Rating |
|-----------|--------|
| Privacy | High — server never stores plaintext |
| Prediction | High — server model + population priors |
| Complexity | **Very High** — KMS, ephemeral compute, key management |
| Breach impact | **None** — encrypted blobs only |

**Requires:**
- User-managed or device-derived encryption key
- Secure enclave / KMS for ephemeral decryption
- Strict memory-safety guarantees (no swap-to-disk)
- Data deletion confirmation after prediction completes

This is aspirational architecture for a mature product. Not recommended for MVP.

---

## Decision Flowchart

```
What environment is the user in?
│
├─ Restrictive jurisdiction (abortion criminalised)
│   → Offer Option 3 (local-first + on-device ML)
│     or Option 4 (encrypted sync with ephemeral inference)
│
├─ Privacy-maximalist but not at legal risk
│   → Offer Option 3 as opt-in
│     Default to Option 2
│
└─ Standard user
    → Option 2 (encrypted columns + health profile segregation)
      → Option 1 is the minimum acceptable baseline
```

---

## Implementation Roadmap for Prediction Team

### Phase 0: Now (No ML changes needed)

- [ ] Add `lockbox` to `symptom_logs.temperature`, `.weight`, `.notes`, `.intercourse_tags`, `.mood_text`, `.cravings`
- [ ] Add `lockbox` to `superpower_logs.ratings`
- [ ] Add `lockbox` to `cycle_entries.phase`, `.cycle_day` (derived — encrypt for consistency)
- [ ] Verify prediction pipeline still reads decrypted values correctly

**Prediction model impact:** Zero. `symptom_log.temperature` returns a `Float` before and after.

### Phase 1: Feature Audit

- [ ] Train a baseline model on current data
- [ ] Compute feature importance scores for every `symptom_log` column
- [ ] Remove columns with zero importance (candidates: `mood_text`, `intercourse_tags`, `weight`)
- [ ] Document which features are critical and why (as a table sent back to product)

**Prediction model impact:** Model may become slightly smaller/faster. Accuracy preserved if pruning is feature-importance-guided.

### Phase 2: Local-Only Mode (Pilot)

- [ ] Design on-device model API surface (what features goes in, what prediction comes out)
- [ ] Port inference logic to TensorFlow.js or CoreML
- [ ] Add IndexedDB/HealthKit as primary store for local-only users
- [ ] Limit: no population priors — per-user cold start

**Prediction model impact:** Server model unchanged. Local model is a separate, simpler implementation.

### Phase 3: Ephemeral Inference (Future)

- [ ] Design encrypted sync protocol (user-key derived, asymmetric)
- [ ] Server decrypts → runs model → returns prediction → wipes plaintext
- [ ] Audit: prove no plaintext persists beyond request lifecycle

**Prediction model impact:** Same model, just the data pipeline changes.

---

## Training Data: What the Model Should Never See

Even with encryption and segregation, the training pipeline must enforce access controls:

| Data | Training allowed? | Rationale |
|------|-----------------|-----------|
| `user.public_id` | Yes (as UUID) | For per-user train/test split only |
| `user.email` | **Never** | PII — can't be in training set |
| `user.name` | **Never** | PII — can't be in training set |
| `user.birthday` | Yes (as age integer) | Age is a valid feature; `birthday` is not |
| Health data by `user_id` | Yes | Anonymised in training context |
| `notes` free text | **Never in training** | Contains PII, never vectorize |
| `symptom_logs` (encrypted) | Yes | Model sees decrypted values via Lockbox |

**Rule:** The training set must contain exactly zero identity Tier-1 fields. The `public_id` is the maximum identifier allowed.

---

## Privacy Presets for Users

Rather than a binary "local vs server" choice, offer three tiers:

| Tier | Storage | Prediction | Best for |
|------|---------|-----------|---------|
| **Standard** | Server (encrypted at rest) | Server-side model, full accuracy | Most users |
| **Local** | On-device only | On-device model, per-user only | Privacy-conscious users |
| **Local + Sync** | On-device + encrypted backup | Server-side via ephemeral inference | Users who want both privacy and accuracy |

---

## References

- [`docs/userdata.md`](userdata.md) — Full data classification (Tier 1-4)
- [`docs/GDPR-AUDIT.md`](GDPR-AUDIT.md) — Compliance status and gaps
- [`docs/Oky_Prediction_Engine_How_To_Build.pdf`](Oky_Prediction_Engine_How_To_Build.pdf) — Reference cycle prediction design from Oky
- [Privacy International — Privacy and Sexual & Reproductive Health in the Post-Roe World](https://www.privacyinternational.org/long-read/4937/privacy-and-sexual-and-reproductive-health-post-roe-world)
- [AGENTS.md](../AGENTS.md) — Development conventions and gotchas
