# Badminton Manager — iOS

A native SwiftUI iOS app for the **Shuttle and Scales** badminton club. Connects to the same Firebase Firestore backend as the [web app](https://badminton-cost-manager.web.app/), providing real-time court booking management, cost splitting, and payment tracking on mobile.

## Screenshots

- Splash Screen → Member Dashboard → Admin Panel

## Features

### Member View (Read-Only)
- Monthly summary cards (days booked, per-player cost, court total, grand total)
- Court booking calendar (Monday-first grid with booked day indicators)
- Player list (main & standby with color-coded pills)
- Shuttle tracker (tins, used, remaining with progress bar)
- Financial overview (collected vs expenses vs balance)
- Payment status list (per-member with due/paid/outstanding/credit)

### Admin View (After Login)
- Edit court rate, tin cost, tins count, courier charges
- Interactive calendar — tap days to toggle bookings
- Record payments — member dropdown picker, amount, date
- Record expenses — type selector (court/shuttle/misc), amount, shop
- Shuttle usage tracker — tap days to mark shuttle use
- Manage players — view main & standby rosters

### General
- **Splash Screen** — Animated logo reveal with court background
- **Real-time Sync** — Live Firestore listener; changes from web or mobile appear instantly
- **Admin Authentication** — Verifies credentials against Firestore `users` collection
- **Dark Theme** — Glassmorphism UI with subtle badminton court background
- **Smooth Animations** — Scale, fade, and transition effects throughout

## Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| Swift | 5.0 | Programming language |
| SwiftUI | 5.0+ | Declarative UI framework |
| Xcode | 26.6+ | IDE & build system |
| iOS | 17.0+ | Minimum deployment target |
| Firebase iOS SDK | 11.x | Backend services |
| Cloud Firestore | via Firebase | Real-time NoSQL database |
| Swift Package Manager | Built-in | Dependency management |

## Architecture

| Layer | Pattern | Details |
|---|---|---|
| UI | SwiftUI Views | Declarative, composable view hierarchy |
| State Management | `@Observable` + `@Environment` | Modern SwiftUI observation (iOS 17+) |
| Data Flow | Unidirectional | Store → Views (read), Views → Store actions (write) |
| Networking | Firebase Firestore SDK | Real-time `addSnapshotListener` |
| Theme | Centralized `AppTheme` | Color tokens, design system |
| Components | Reusable SwiftUI Views | GlassCard, StatCard, PillView, etc. |

## Project Structure

```
Badminton Manager/
├── Badminton_ManagerApp.swift          # App entry — FirebaseApp.configure()
├── ContentView.swift                   # Root navigator (member ↔ admin)
├── GoogleService-Info.plist            # Firebase config (gitignored)
│
├── Views/
│   ├── SplashScreenView.swift          # Animated splash screen
│   ├── MemberDashboardView.swift       # Read-only member dashboard
│   ├── AdminDashboardView.swift        # Admin panel with editing
│   ├── LoginView.swift                 # Admin login screen
│   └── CourtBackgroundView.swift       # Court layout Canvas background
│
├── State/
│   ├── AppState.swift                  # Login state (@Observable)
│   └── BadmintonDataStore.swift        # ViewModel — live Firestore data & business logic
│
├── Services/
│   └── FirestoreService.swift          # Firestore CRUD, real-time listener, auth
│
├── Components/
│   ├── GlassCard.swift                 # Semi-transparent card container
│   ├── CardHeader.swift                # Icon + title section header
│   ├── StatCard.swift                  # Summary stat card (icon, value, label)
│   ├── PillView.swift                  # Player name capsule
│   ├── StatViews.swift                 # ShuttleStatView, FinanceStatView
│   ├── PaymentItemView.swift           # Payment row (avatar, amount, status badge)
│   └── MiniCalendarView.swift          # Calendar grid with booked day indicators
│
├── Models/
│   └── Models.swift                    # BadmintonDocument, MonthData, PaymentEntry, etc.
│
├── Theme/
│   └── AppTheme.swift                  # Color palette & design tokens
│
├── Utilities/
│   ├── Helpers.swift                   # formatMoney()
│   └── FlowLayout.swift               # Custom SwiftUI Layout for pills/tags
│
└── Assets.xcassets/
    ├── AppIcon.appiconset/             # App icon
    ├── SplashLogo.imageset/            # Club logo for splash screen
    └── AccentColor.colorset/           # System accent color
```

## Prerequisites

- macOS with Xcode 26.6 or later
- iOS 17.0+ device or simulator
- Firebase project with Firestore enabled
- iOS app registered in Firebase Console

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/SajevLucksman/badminton-manager-mobile-ios-swift.git
   cd badminton-manager-mobile-ios-swift
   ```

2. **Register iOS app in Firebase Console**
   - Go to [Firebase Console](https://console.firebase.google.com/) → Project Settings → Add app → iOS
   - Bundle ID: `com.badminton.manager.mobile.Badminton-Manager`
   - Download the generated `GoogleService-Info.plist`

3. **Add the plist to the project**
   ```
   Badminton Manager/Badminton Manager/GoogleService-Info.plist
   ```

4. **Open in Xcode**
   ```bash
   open "Badminton Manager/Badminton Manager.xcodeproj"
   ```
   Xcode will automatically resolve the Firebase iOS SDK via Swift Package Manager.

5. **Build & Run** — `Cmd+R`

## App Flow

```
┌─────────────┐     2 sec      ┌──────────────────┐
│   Splash    │ ──────────────→ │  Member View     │
│   Screen    │                 │  (read-only)     │
└─────────────┘                 └────────┬─────────┘
                                         │ Tap "Admin"
                                         ▼
                                ┌──────────────────┐
                                │   Login Sheet    │
                                │  (username/pass) │
                                └────────┬─────────┘
                                         │ Success
                                         ▼
                                ┌──────────────────┐
                                │   Admin View     │
                                │  (full editing)  │
                                └────────┬─────────┘
                                         │ Logout
                                         ▼
                                ┌──────────────────┐
                                │  Member View     │
                                └──────────────────┘
```

## Key Design Decisions

| Decision | Rationale |
|---|---|
| `@Observable` over `ObservableObject` | Modern iOS 17+ API, less boilerplate, better performance |
| Single Firestore document | Matches existing web app structure; atomic reads/writes |
| Canvas for court background | GPU-accelerated drawing, no image assets needed |
| Glassmorphism cards | Modern iOS aesthetic, separates content from background |
| No navigation stack in admin | Single scrollable screen avoids deep navigation on mobile |
| Picker for member selection | Prevents typos, faster than typing on mobile |

## Dependencies

| Package | Source | Version |
|---|---|---|
| Firebase iOS SDK | `https://github.com/firebase/firebase-ios-sdk` | 11.0.0+ |
| — FirebaseCore | Included | Firebase initialization |
| — FirebaseFirestore | Included | Real-time database |

## Scripts / Build Commands

| Action | Command |
|---|---|
| Open project | `open "Badminton Manager/Badminton Manager.xcodeproj"` |
| Build (CLI) | `xcodebuild -project "Badminton Manager/Badminton Manager.xcodeproj" -scheme "Badminton Manager" -destination 'platform=iOS Simulator,name=iPhone 16' build` |
| Clean build | `xcodebuild clean` |

## Related

- **Web App** — [badminton-cost-manager.web.app](https://badminton-cost-manager.web.app/) (React + Vite + Firebase Hosting)
- **Same Backend** — Both apps read/write the same Firestore document in real-time

## License

MIT — © 2026 Sajev Lucksman
