# Season App Testing Steps — PWA & iOS (Turbo Native)

_Last updated: 2026-05-18_

## Overview
This document provides step-by-step instructions to test all major Season app features for both the PWA (web) and iOS (Turbo Native) implementations, including new Hotwire Native integrations.

---

## 1. PWA (Web) Testing

### 1.1. General
- [ ] Open the app in Chrome, Safari, and Firefox
- [ ] Verify responsive layout (mobile, tablet, desktop)
- [ ] Confirm service worker registration and offline fallback
- [ ] Add to Home Screen (A2HS) prompt appears on iOS/Android
- [ ] Push notifications (web) work as expected

### 1.2. Core Flows
- [ ] Sign up, confirm email, and log in
- [ ] Complete onboarding steps
- [ ] Log period, symptoms, and superpowers
- [ ] Add, edit, and delete calendar events
- [ ] View daily, weekly, and monthly calendar
- [ ] Change settings (profile, notifications, calendar display)
- [ ] Submit feedback, bug, and support forms
- [ ] Log out and log back in

### 1.3. Admin
- [ ] Access /admin as admin user
- [ ] View users, inbox, feedback, bugs, support
- [ ] Export CSVs

---

## 2. iOS (Turbo Native) Testing

### 2.1. App Shell & Navigation
- [ ] App launches and loads web content
- [ ] data-hotwire-native attribute present on <html>
- [ ] native.css classes apply (d-hotwire-native-*)
- [ ] Web navbar/burger menu hidden in native app
- [ ] Tab bar shows 3 tabs: Calendar, Daily, Tracking
- [ ] Tab bar icons are correct (calendar, calendar.circle, chart.pie)
- [ ] Tapping each tab navigates to correct URL
- [ ] Daily tab appends today's date (/daily/2026-05-19)
- [ ] Navigation between all main screens works

### 2.2. Native-Specific Features
- [ ] /configurations/ios_v1.json returns correct path rules
- [ ] Modal and pull-to-refresh behaviors match config
- [ ] Device token registration (POST /native_devices/register) works
- [ ] APNs push (if Apple Dev account available) — test with test device
- [ ] Base URL reads from Info.plist (SEASON_BASE_URL) — not hardcoded
- [ ] project.yml is valid: `xcodegen generate` succeeds
- [ ] AppDelegate is minimal stub (no WKWebView code)

### 2.3. Auth & Data
- [ ] Sign up, confirm email, and log in via native app
- [ ] All user data syncs between web and native
- [ ] Settings changes persist

### 2.4. Error Handling
- [ ] Offline mode shows fallback
- [ ] Invalid routes show 404
- [ ] Auth errors handled gracefully

---

## 3. Regression & Edge Cases
- [ ] Test with expired/invalid tokens
- [ ] Test on iOS 15, 16, 17
- [ ] Test with slow/unstable network
- [ ] Test with device language set to German/Spanish

---

## 4. Admin/Dev Tools
- [ ] Run all audits: ./audit_runner.sh all
- [ ] Review audit_checklist.md for any ❌/⚠️
- [ ] Use agent skills for deep-dive audits

---

## 5. Notes
- For APNs, you must have a valid Apple Developer account and device token.
- For OAuth, ensure credentials are set in Render dashboard.
- Update this checklist as new features are added.
