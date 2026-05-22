import { useState, useEffect } from "react";

const SECTIONS = [
  {
    id: "rails-foundation",
    label: "Rails Foundation",
    icon: "⚙️",
    color: "#C084FC",
    accent: "#7C3AED",
    items: [
      { id: "rf1", label: "Rails 8.1 app initialized and running in production", priority: "critical" },
      { id: "rf2", label: "PostgreSQL database configured and migrated", priority: "critical" },
      { id: "rf3", label: "Devise authentication — signup, login, logout, password reset", priority: "critical" },
      { id: "rf4", label: "Pundit authorization — role/policy layer in place", priority: "high" },
      { id: "rf5", label: "Solid Queue configured for background jobs", priority: "high" },
      { id: "rf6", label: "Hotwire (Turbo + Stimulus) wired up — no full-page reloads", priority: "critical" },
      { id: "rf7", label: "Tailwind CSS configured and design tokens applied", priority: "high" },
      { id: "rf8", label: "Environment variables managed (.env / credentials.yml.enc)", priority: "critical" },
      { id: "rf9", label: "Render deployment live and healthy", priority: "critical" },
      { id: "rf10", label: "Error tracking configured (Sentry / Honeybadger / Rollbar)", priority: "high" },
      { id: "rf11", label: "Logging configured for production", priority: "medium" },
      { id: "rf12", label: "Domain + SSL configured", priority: "critical" },
      { id: "rf13", label: "German user migration — 150+ users pre-seeded with invite tokens", priority: "critical" },
      { id: "rf14", label: "Email delivery configured (transactional — Postmark / Sendgrid / etc.)", priority: "critical" },
    ],
  },
  {
    id: "cycle-data",
    label: "Cycle & User Data",
    icon: "🌙",
    color: "#F472B6",
    accent: "#BE185D",
    items: [
      { id: "cd1", label: "User cycle profile model — cycle length, period length, start dates", priority: "critical" },
      { id: "cd2", label: "Cycle phase calculation logic — menstrual / follicular / ovulatory / luteal", priority: "critical" },
      { id: "cd3", label: "Daily log model — symptoms, mood, energy, flow, notes", priority: "critical" },
      { id: "cd4", label: "Cycle history — ability to view past cycles", priority: "high" },
      { id: "cd5", label: "Predicted vs actual phase tracking", priority: "high" },
      { id: "cd6", label: "Phase-aware date calculations (next period prediction, fertile window, etc.)", priority: "high" },
      { id: "cd7", label: "Irregular cycle handling — algorithm accounts for variation", priority: "medium" },
      { id: "cd8", label: "Data export / portability (GDPR-ready — especially for German users)", priority: "critical" },
      { id: "cd9", label: "User account deletion with full data purge", priority: "critical" },
      { id: "cd10", label: "Onboarding flow — captures first period date and baseline cycle data", priority: "critical" },
    ],
  },
  {
    id: "superpowers",
    label: "Superpower Feature Layer",
    icon: "✨",
    color: "#34D399",
    accent: "#059669",
    items: [
      { id: "sp1", label: "Superpower model — defined per phase (ideation, output, review, rest)", priority: "critical" },
      { id: "sp2", label: "Phase-to-superpower mapping logic in place", priority: "critical" },
      { id: "sp3", label: "Today dashboard — shows current phase + active superpower", priority: "critical" },
      { id: "sp4", label: "Superpower detail view — explanation, tips, recommended tasks per phase", priority: "high" },
      { id: "sp5", label: "Calendar / cycle wheel view — visual phase overview", priority: "high" },
      { id: "sp6", label: "Productivity prompts / tasks tailored to current phase", priority: "high" },
      { id: "sp7", label: "Journaling or reflection feature tied to phase", priority: "medium" },
      { id: "sp8", label: "Notifications — phase transition alerts (especially for native)", priority: "high" },
      { id: "sp9", label: "Personalization — user can customize superpower labels / themes", priority: "low" },
      { id: "sp10", label: "Insights view — patterns across past cycles (energy, mood, output)", priority: "medium" },
    ],
  },
  {
    id: "pwa",
    label: "PWA Readiness",
    icon: "📱",
    color: "#60A5FA",
    accent: "#1D4ED8",
    items: [
      { id: "pwa1", label: "Web App Manifest (manifest.json) — name, icons, theme_color, start_url, display: standalone", priority: "critical" },
      { id: "pwa2", label: "Service Worker registered — caches shell and key assets", priority: "critical" },
      { id: "pwa3", label: "Offline fallback page — graceful UX when offline", priority: "high" },
      { id: "pwa4", label: "App icons — all required sizes (192x192, 512x512, maskable variants)", priority: "critical" },
      { id: "pwa5", label: "Splash screens configured for iOS and Android", priority: "high" },
      { id: "pwa6", label: "viewport meta tag — width=device-width, initial-scale=1", priority: "critical" },
      { id: "pwa7", label: "Apple-specific meta tags — apple-mobile-web-app-capable, status-bar-style", priority: "high" },
      { id: "pwa8", label: "Lighthouse PWA audit passing (installable + PWA criteria)", priority: "critical" },
      { id: "pwa9", label: "HTTPS enforced everywhere (required for SW registration)", priority: "critical" },
      { id: "pwa10", label: "Install prompt handled — beforeinstallprompt event captured", priority: "medium" },
    ],
  },
  {
    id: "turbo-native",
    label: "Turbo Native Readiness",
    icon: "🔗",
    color: "#FBBF24",
    accent: "#B45309",
    items: [
      { id: "tn1", label: "turbo-rails gem installed and Turbo Drive enabled globally", priority: "critical" },
      { id: "tn2", label: "All navigation uses Turbo — no full-page reloads from links or forms", priority: "critical" },
      { id: "tn3", label: "Path configuration file (path-configuration.json) created — maps routes to native behaviors", priority: "critical" },
      { id: "tn4", label: "path-configuration.json served at a stable URL (e.g. /turbo-native/path-configuration.json)", priority: "critical" },
      { id: "tn5", label: "turbo-native CSS class applied to <html> when running in native shell", priority: "high" },
      { id: "tn6", label: "Native-specific UI hidden on web (e.g. bottom nav, back buttons) via turbo-native class", priority: "high" },
      { id: "tn7", label: "Stimulus Bridge — web ↔ native bridge components identified and wired", priority: "high" },
      { id: "tn8", label: "Modal / sheet navigation configured in path config (present-as-modal context)", priority: "high" },
      { id: "tn9", label: "External links open in browser, not Turbo (target: _blank or path config rule)", priority: "high" },
      { id: "tn10", label: "Authentication handled correctly — sessions persist across native app restarts", priority: "critical" },
      { id: "tn11", label: "Push notifications bridge set up (if using — APNs for iOS, FCM for Android)", priority: "medium" },
      { id: "tn12", label: "Error pages (401, 422, 500) handled gracefully in native context", priority: "high" },
      { id: "tn13", label: "Hotwire Native iOS shell project initialized (Swift / Xcode)", priority: "critical" },
      { id: "tn14", label: "Hotwire Native Android shell project initialized (Kotlin / Android Studio)", priority: "critical" },
      { id: "tn15", label: "Native tab bar / bottom navigation configured in shell", priority: "high" },
    ],
  },
  {
    id: "ios-store",
    label: "iOS / App Store",
    icon: "🍎",
    color: "#E879F9",
    accent: "#86198F",
    items: [
      { id: "ios1", label: "Apple Developer account active ($99/yr)", priority: "critical" },
      { id: "ios2", label: "App registered in App Store Connect — bundle ID set", priority: "critical" },
      { id: "ios3", label: "Xcode project configured — signing certificates and provisioning profiles", priority: "critical" },
      { id: "ios4", label: "App icons set — all required sizes via .xcassets", priority: "critical" },
      { id: "ios5", label: "Launch screen / splash screen configured", priority: "critical" },
      { id: "ios6", label: "Privacy manifest (PrivacyInfo.xcprivacy) — required for App Store 2024+", priority: "critical" },
      { id: "ios7", label: "Privacy usage descriptions in Info.plist (if accessing camera, health, etc.)", priority: "critical" },
      { id: "ios8", label: "TestFlight build uploaded and tested on real device", priority: "critical" },
      { id: "ios9", label: "App Store screenshots prepared — all required device sizes", priority: "critical" },
      { id: "ios10", label: "App Store listing copy — description, keywords, category (Health & Fitness)", priority: "high" },
      { id: "ios11", label: "Age rating questionnaire completed", priority: "high" },
      { id: "ios12", label: "In-app purchase / subscription configured in App Store Connect (if applicable)", priority: "medium" },
      { id: "ios13", label: "HealthKit integration considered (if accessing Apple Health cycle data)", priority: "medium" },
      { id: "ios14", label: "App review submission — compliance notes for reviewer re: cycle tracking", priority: "high" },
    ],
  },
  {
    id: "android-store",
    label: "Android / Google Play",
    icon: "🤖",
    color: "#4ADE80",
    accent: "#15803D",
    items: [
      { id: "and1", label: "Google Play developer account active ($25 one-time)", priority: "critical" },
      { id: "and2", label: "App registered in Google Play Console — package name set", priority: "critical" },
      { id: "and3", label: "Android Studio project configured — keystore generated and stored securely", priority: "critical" },
      { id: "and4", label: "Adaptive icons configured (foreground + background layers)", priority: "critical" },
      { id: "and5", label: "Release AAB (Android App Bundle) built and signed", priority: "critical" },
      { id: "and6", label: "Internal testing track — APK tested on real device", priority: "critical" },
      { id: "and7", label: "Play Store listing — screenshots, feature graphic, description", priority: "critical" },
      { id: "and8", label: "Target API level meets Play Store requirements (currently API 34+)", priority: "critical" },
      { id: "and9", label: "Permissions declared in AndroidManifest.xml — no over-permissioning", priority: "high" },
      { id: "and10", label: "Data safety form completed in Play Console (health data disclosure)", priority: "critical" },
      { id: "and11", label: "Privacy policy URL added to Play Console", priority: "critical" },
      { id: "and12", label: "Content rating questionnaire completed", priority: "high" },
      { id: "and13", label: "App signing by Google Play enrolled (recommended)", priority: "medium" },
    ],
  },
  {
    id: "compliance",
    label: "Legal & Compliance",
    icon: "🔒",
    color: "#F87171",
    accent: "#B91C1C",
    items: [
      { id: "lc1", label: "Privacy policy published — covers health/cycle data, storage, third parties", priority: "critical" },
      { id: "lc2", label: "Terms of service published", priority: "critical" },
      { id: "lc3", label: "GDPR compliance — consent management, data portability, right to delete", priority: "critical" },
      { id: "lc4", label: "Cookie consent (if applicable for web)", priority: "high" },
      { id: "lc5", label: "Sensitive health data handling policy — cycle data is sensitive under GDPR", priority: "critical" },
      { id: "lc6", label: "Data stored in EU region or disclosed clearly (for German users)", priority: "critical" },
      { id: "lc7", label: "No health data sent to third-party analytics without explicit consent", priority: "critical" },
      { id: "lc8", label: "German language support — app and store listing in German (de locale)", priority: "high" },
    ],
  },
];

const PRIORITY_META = {
  critical: { label: "Critical", color: "#F87171", bg: "rgba(248,113,113,0.12)" },
  high: { label: "High", color: "#FBBF24", bg: "rgba(251,191,36,0.12)" },
  medium: { label: "Medium", color: "#60A5FA", bg: "rgba(96,165,250,0.12)" },
  low: { label: "Low", color: "#9CA3AF", bg: "rgba(156,163,175,0.12)" },
};

export default function SeasonAuditChecklist() {
  const [checked, setChecked] = useState({});
  const [expanded, setExpanded] = useState({ "rails-foundation": true });
  const [filter, setFilter] = useState("all");

  useEffect(() => {
    try {
      const saved = localStorage.getItem("season-audit-v1");
      if (saved) setChecked(JSON.parse(saved));
    } catch {}
  }, []);

  const toggle = (id) => {
    setChecked((prev) => {
      const next = { ...prev, [id]: !prev[id] };
      try { localStorage.setItem("season-audit-v1", JSON.stringify(next)); } catch {}
      return next;
    });
  };

  const toggleSection = (id) => {
    setExpanded((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  const totalItems = SECTIONS.flatMap((s) => s.items).length;
  const doneItems = Object.values(checked).filter(Boolean).length;
  const pct = Math.round((doneItems / totalItems) * 100);

  const filteredSections = SECTIONS.map((s) => ({
    ...s,
    items: s.items.filter((item) => {
      if (filter === "all") return true;
      if (filter === "done") return checked[item.id];
      if (filter === "todo") return !checked[item.id];
      return item.priority === filter;
    }),
  })).filter((s) => s.items.length > 0);

  return (
    <div style={{
      minHeight: "100vh",
      background: "#0A0A0F",
      color: "#E8E0FF",
      fontFamily: "'DM Sans', system-ui, sans-serif",
      padding: "0 0 80px",
    }}>
      {/* Header */}
      <div style={{
        background: "linear-gradient(135deg, #1A0A2E 0%, #0F0A1E 60%, #0A0F1E 100%)",
        borderBottom: "1px solid rgba(192,132,252,0.15)",
        padding: "32px 24px 24px",
        position: "sticky",
        top: 0,
        zIndex: 100,
        backdropFilter: "blur(12px)",
      }}>
        <div style={{ maxWidth: 680, margin: "0 auto" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 4 }}>
            <span style={{ fontSize: 22 }}>🌸</span>
            <span style={{ fontSize: 11, letterSpacing: "0.2em", color: "#C084FC", fontWeight: 600, textTransform: "uppercase" }}>Season</span>
          </div>
          <h1 style={{ margin: "0 0 4px", fontSize: 26, fontWeight: 700, letterSpacing: "-0.02em", color: "#F3E8FF" }}>
            Release Readiness Audit
          </h1>
          <p style={{ margin: "0 0 20px", fontSize: 13, color: "#9CA3AF" }}>
            Rails PWA → Turbo Native → App Store + Google Play
          </p>

          {/* Progress bar */}
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{
              flex: 1,
              height: 6,
              background: "rgba(255,255,255,0.08)",
              borderRadius: 99,
              overflow: "hidden",
            }}>
              <div style={{
                height: "100%",
                width: `${pct}%`,
                background: "linear-gradient(90deg, #7C3AED, #C084FC, #F472B6)",
                borderRadius: 99,
                transition: "width 0.4s ease",
              }} />
            </div>
            <span style={{ fontSize: 13, fontWeight: 700, color: "#C084FC", whiteSpace: "nowrap" }}>
              {doneItems}/{totalItems} — {pct}%
            </span>
          </div>
        </div>
      </div>

      <div style={{ maxWidth: 680, margin: "0 auto", padding: "20px 16px 0" }}>

        {/* Filter pills */}
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 20 }}>
          {[
            { key: "all", label: "All" },
            { key: "todo", label: "To Do" },
            { key: "done", label: "Done" },
            { key: "critical", label: "🔴 Critical" },
            { key: "high", label: "🟡 High" },
            { key: "medium", label: "🔵 Medium" },
          ].map(({ key, label }) => (
            <button
              key={key}
              onClick={() => setFilter(key)}
              style={{
                padding: "5px 14px",
                borderRadius: 99,
                border: filter === key
                  ? "1px solid #C084FC"
                  : "1px solid rgba(255,255,255,0.1)",
                background: filter === key ? "rgba(192,132,252,0.15)" : "transparent",
                color: filter === key ? "#E9D5FF" : "#9CA3AF",
                fontSize: 12,
                fontWeight: 600,
                cursor: "pointer",
                transition: "all 0.15s",
              }}
            >
              {label}
            </button>
          ))}
        </div>

        {/* Sections */}
        {filteredSections.map((section) => {
          const sectionDone = section.items.filter((i) => checked[i.id]).length;
          const isOpen = expanded[section.id];

          return (
            <div key={section.id} style={{
              marginBottom: 12,
              border: `1px solid rgba(255,255,255,0.07)`,
              borderRadius: 14,
              overflow: "hidden",
              background: "rgba(255,255,255,0.025)",
            }}>
              {/* Section header */}
              <button
                onClick={() => toggleSection(section.id)}
                style={{
                  width: "100%",
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                  padding: "14px 16px",
                  background: "transparent",
                  border: "none",
                  cursor: "pointer",
                  textAlign: "left",
                }}
              >
                <span style={{ fontSize: 18 }}>{section.icon}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 700, color: "#F3E8FF", letterSpacing: "-0.01em" }}>
                    {section.label}
                  </div>
                  <div style={{ fontSize: 11, color: "#6B7280", marginTop: 1 }}>
                    {sectionDone}/{section.items.length} complete
                  </div>
                </div>
                {/* Mini progress */}
                <div style={{
                  width: 40,
                  height: 40,
                  borderRadius: "50%",
                  background: `conic-gradient(${section.color} ${(sectionDone / section.items.length) * 360}deg, rgba(255,255,255,0.06) 0deg)`,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                }}>
                  <div style={{
                    width: 28,
                    height: 28,
                    borderRadius: "50%",
                    background: "#0A0A0F",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 10,
                    fontWeight: 700,
                    color: section.color,
                  }}>
                    {Math.round((sectionDone / section.items.length) * 100)}%
                  </div>
                </div>
                <span style={{ color: "#6B7280", fontSize: 12, marginLeft: 4 }}>
                  {isOpen ? "▲" : "▼"}
                </span>
              </button>

              {/* Items */}
              {isOpen && (
                <div style={{ borderTop: "1px solid rgba(255,255,255,0.05)" }}>
                  {section.items.map((item, idx) => {
                    const isDone = checked[item.id];
                    const pm = PRIORITY_META[item.priority];
                    return (
                      <div
                        key={item.id}
                        onClick={() => toggle(item.id)}
                        style={{
                          display: "flex",
                          alignItems: "flex-start",
                          gap: 12,
                          padding: "12px 16px",
                          borderTop: idx > 0 ? "1px solid rgba(255,255,255,0.04)" : "none",
                          cursor: "pointer",
                          transition: "background 0.1s",
                          background: isDone ? "rgba(192,132,252,0.04)" : "transparent",
                        }}
                      >
                        {/* Checkbox */}
                        <div style={{
                          width: 20,
                          height: 20,
                          borderRadius: 6,
                          border: isDone ? `2px solid ${section.color}` : "2px solid rgba(255,255,255,0.15)",
                          background: isDone ? `${section.color}20` : "transparent",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          flexShrink: 0,
                          marginTop: 1,
                          transition: "all 0.15s",
                        }}>
                          {isDone && (
                            <svg width="11" height="9" viewBox="0 0 11 9" fill="none">
                              <path d="M1 4L4.5 7.5L10 1" stroke={section.color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                            </svg>
                          )}
                        </div>

                        {/* Label */}
                        <span style={{
                          flex: 1,
                          fontSize: 13,
                          color: isDone ? "#6B7280" : "#D1D5DB",
                          textDecoration: isDone ? "line-through" : "none",
                          lineHeight: 1.5,
                          transition: "all 0.15s",
                        }}>
                          {item.label}
                        </span>

                        {/* Priority badge */}
                        <span style={{
                          fontSize: 10,
                          fontWeight: 700,
                          color: pm.color,
                          background: pm.bg,
                          border: `1px solid ${pm.color}30`,
                          padding: "2px 7px",
                          borderRadius: 99,
                          whiteSpace: "nowrap",
                          flexShrink: 0,
                          letterSpacing: "0.05em",
                          textTransform: "uppercase",
                        }}>
                          {pm.label}
                        </span>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}

        {/* Footer note */}
        <div style={{
          marginTop: 24,
          padding: "16px",
          borderRadius: 12,
          background: "rgba(192,132,252,0.06)",
          border: "1px solid rgba(192,132,252,0.15)",
          fontSize: 12,
          color: "#9CA3AF",
          lineHeight: 1.6,
        }}>
          <span style={{ color: "#C084FC", fontWeight: 700 }}>Turbo Native note:</span> The iOS and Android shell apps are thin wrappers — the Rails web app does the heavy lifting. Get the PWA Readiness and Turbo Native Readiness sections to 100% before opening Xcode or Android Studio.
        </div>
      </div>
    </div>
  );
}
