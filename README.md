# Badminton Manager — iOS

A native SwiftUI iOS app for the **Shuttle and Scales** badminton club. Connects to the same Firebase Firestore backend as the [web app](https://badminton-cost-manager.web.app/), providing real-time court booking management, cost splitting, and payment tracking on mobile.

## Features

- **Member View** (default) — Read-only dashboard with monthly summary, calendar, player list, shuttle tracker, finances, and payment status
- **Admin View** (login required) — Full editing: toggle court bookings, record payments, add expenses, update rates, manage shuttle usage
- **Real-time Sync** — Live Firestore listener; changes from web or mobile appear instantly on both
- **Admin Authentication** — Verifies credentials against Firestore `users` collection (same as web)
- **Dark Theme** — Modern glassmorphism UI with court layout background

## Tech Stack

| Technology | Purpose |
|---|---|
| SwiftUI | Declarative UI framework |
| Swift 5.0 | Language |
| Firebase iOS SDK 11.x | Firestore real-time database |
| Xcode 26.6+ | IDE & build tool |
| iOS 17.0+ | Minimum deployment target |

## Project Structure

```
Badminton Manager/
├── Badminton_ManagerApp.swift       # App entry — FirebaseApp.configure()
├── ContentView.swift                # Root navigator (member ↔ admin)
├── GoogleService-Info.plist         # Firebase config (not committed)
├── State/
│   ├── AppState.swift               # Login state (@Observable)
│   └── BadmintonDataStore.swift     # ViewModel — live Firestore data
├── Services/
│   └── FirestoreService.swift       # Firestore subscribe, save, auth
├── Views/
│   ├── MemberDashboardView.swift    # Read-only member dashboard
│   ├── AdminDashboardView.swift     # Admin panel with editing
│   ├── LoginView.swift              # Admin login screen
│   └── CourtBackgroundView.swift    # Court layout background
├── Components/
│   ├── GlassCard.swift              # Glass card container
│   ├── CardHeader.swift             # Section header
│   ├── StatCard.swift               # Summary stat card
│   ├── PillView.swift               # Player name pill
│   ├── StatViews.swift              # ShuttleStatView, FinanceStatView
│   ├── PaymentItemView.swift        # Payment list item
│   └── MiniCalendarView.swift       # Calendar grid
├── Models/
│   └── Models.swift                 # All data models
├── Theme/
│   └── AppTheme.swift               # Color tokens
└── Utilities/
    ├── Helpers.swift                 # formatMoney()
    └── FlowLayout.swift             # Custom flow layout
```

## Prerequisites

- Xcode 26.6 or later
- iOS 17.0+ device or simulator
- Firebase project with Firestore enabled (same project as the web app)

## Setup

1. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd badminton-manager-mobile-ios-swift
   ```

2. **Register iOS app in Firebase Console**
   - Go to [Firebase Console](https://console.firebase.google.com/) → your project → Project Settings → Add app → iOS
   - Bundle ID: `com.badminton.manager.mobile.Badminton-Manager`
   - Download the generated `GoogleService-Info.plist`

3. **Add the plist to the project**
   - Place `GoogleService-Info.plist` in:
     ```
     Badminton Manager/Badminton Manager/GoogleService-Info.plist
     ```

4. **Open in Xcode**
   ```bash
   open "Badminton Manager/Badminton Manager.xcodeproj"
   ```
   Xcode will automatically resolve the Firebase iOS SDK package.

5. **Build & Run**
   - Select an iOS 17+ simulator or device
   - `Cmd+R` to build and run

## Firestore Data Structure

The app reads/writes the same document as the web app:

```
Collection: badminton
  Document: data
    ├── _members: { main: [...], standby: [...], enrolled: {...}, left: {...} }
    ├── credits: { "2026-07": { "Player": 200.0 } }
    └── months: { "2026-07": { selectedDays, tinCount, hourlyRate, tinCost, payments, expenses, shuttleDays, ... } }
```

## App Flow

1. App launches → **Member View** (read-only dashboard)
2. Tap **Admin** button → Login sheet slides up
3. Enter credentials (verified against Firestore `users` collection)
4. On success → **Admin Dashboard** with full editing
5. Tap **Logout** → back to Member View

## Related

- [Web App](https://badminton-cost-manager.web.app/) — React + Vite + Firebase Hosting
- Same Firestore backend — real-time sync between web and mobile

## License

MIT — © 2026 Sajev Lucksman
