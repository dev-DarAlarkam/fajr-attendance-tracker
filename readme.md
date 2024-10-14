بسم الله الرحمن الرحيم
برنامج الفجر



/fajr_attendance_app_web
│
├── /lib                       # Main source directory for Flutter
│   ├── /models                # Data models representing Firestore documents
│   │   ├── user.dart          # User model (ID, name, group ID, grade, etc.)
│   │   ├── group.dart         # Group model (ID, name, description, grade, etc.)
│   │   └── attendance.dart    # Attendance model (user ID, date, status, etc.)
│   │
│   ├── /services              # Firebase services for interacting with Firestore and Authentication
│   │   ├── auth_service.dart  # User authentication methods (signup, login, etc.)
│   │   ├── firestore_service.dart # Handles Firestore CRUD operations for users, groups, attendance
│   │   └── data_filter_service.dart # Contains methods for filtering data by date, group, etc.
│   │
│   ├── /providers             # State management using Provider/Riverpod for data sharing across widgets
│   │   ├── user_provider.dart # Manages user state and interactions
│   │   ├── group_provider.dart# Manages group state and interactions
│   │   └── attendance_provider.dart # Manages attendance state and data access
│   │
│   ├── /screens               # Different app screens for UI/UX
│   │   ├── auth_screen.dart   # Login and signup screen
│   │   ├── user_dashboard.dart # Regular user dashboard (attendance tracking, personal stats)
│   │   ├── admin_dashboard.dart # Admin dashboard (group management, data filtering)
│   │   └── attendance_screen.dart # Attendance form and record submission screen
│   │
│   ├── /widgets               # Reusable widgets used across multiple screens
│   │   ├── custom_button.dart # Customized button widgets for forms, etc.
│   │   ├── attendance_form.dart # Form widget for recording attendance
│   │   └── user_info_card.dart # Widget for displaying user information (e.g., name, group)
│   │
│   ├── /utils                 # Utility classes and helper functions
│   │   ├── date_utils.dart    # Date utilities for formatting and range selection
│   │   └── firestore_helpers.dart # Helper methods for Firestore queries and data processing
│   │
│   ├── main.dart              # Main entry point for the Flutter app, with Firebase initialization
│
├── /assets                    # Static assets like images, fonts, and icons
│   ├── /images                # Image assets for branding, icons, etc.
│   └── /fonts                 # Font files for Arabic typography
│
├── web/                       # Web-specific directory for Flutter
│   ├── index.html             # Main HTML entry point for Flutter Web
│   ├── manifest.json          # Web app manifest for PWA support (optional)
│   └── favicon.png            # Favicon for the web app
│
├── firebase.json              # Firebase configuration for deployment and hosting
├── firestore.rules            # Firestore security rules
├── .firebaserc                # Firebase project configuration
├── pubspec.yaml               # Flutter dependencies
├── .gitignore                 # Files/folders to ignore in Git
└── README.md                  # Project documentation
