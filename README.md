# ClassMyte 🎓✈️

ClassMyte is an all-in-one classroom management and bulk communication platform designed for teachers, tutors, and academies. It allows educators to effortlessly organize student data, manage class groups, and seamlessly send customized, reliable bulk SMS messages. 

Unique smart-delay algorithms prevent SPAM-blocking by telecom networks, ensuring your messages always reach their destination.

## 🌟 Key Features

### 📡 Smart Bulk Messaging
*   **Custom Dispatch Delays:** Dynamically select between 5, 10, or 30-second delays between SMS blasts to bypass PTA/Carrier SPAM filters.
*   **Dynamic Personalization:** Inject real-time variables like `[name]` or `[prefix]` right into your message templates for a highly personalized touch.
*   **Status Filtering:** Instantly filter out and exclude "Inactive" students from your bulk dispatches to save message credits.
*   **Background Sending:** Robust, foreground-service-powered message dispatch ensures your texts send even if you switch apps.

### 👥 Student & Template Management 
*   **Class Organization:** Group students by classes, track their active/inactive status, and maintain detailed profiles.
*   **Custom Templates:** Save and organize frequently used notification text (e.g., "Class Cancelled," or "Fee Reminder") into easy-to-load templates.
*   **Excel Imports:** Save time by bulk importing your entire classroom from a simple `.xlsx` or `.csv` file.

### 💰 Scalable Monetization Structure
*   **Free Forever Tier:** Ad-supported access utilizing Google AdMob. Free users experience an intuitive progressive flow utilizing bottom-banners and explicit *Rewarded Video Ads* to bypass feature locks or wait limits.
*   **ClassMyte Pro:** Multi-tiered subscription blocks (Monthly at Rs.299, Yearly at Rs.2,999, Lifetime at Rs.7,999). Pro users enjoy a completely ad-free, maximized-screen experience with instant access to all premium filtering tools. 

## 🏗️ Project Architecture & Tech Stack

ClassMyte is built purely in Flutter and scales beautifully across both iOS and Android platforms via a highly modular, decoupled architecture following clean-code principles.

*   **UI/UX:** Flutter (Dark & Light Mode aware)
*   **State Management:** Riverpod (`flutter_riverpod`)
*   **Navigation:** GoRouter (`go_router`)
*   **Backend / DB:** Firebase Auth & Cloud Firestore
*   **Monetization:** Google Mobile Ads (AdMob) & `in_app_purchase`
*   **Background Tasks:** `flutter_local_notifications`

### Directory Structure

```text
lib/
├── core/
│   ├── ads/           # AdMob loading and configuration providers
│   ├── constants/     # Global app constants
│   ├── exceptions/    # Custom application-wide exceptions
│   ├── providers/     # Dependency injection and global providers
│   ├── theme/         # Royal Blue & Amber design system, Light/Dark Modes
│   └── widgets/       # Highly reusable UI components (Buttons, Inputs, Dialogs)
├── features/
│   ├── auth/          # Login, Sign up, Forgot Password
│   ├── classes/       # Class management & List View screens
│   ├── dashboard/     # Primary landing interface and statistics
│   ├── onboarding/    # Intro screens and T&C agreements
│   ├── premium/       # Subscription pricing tiers & payment handling
│   ├── profile/       # User profile details and settings editing
│   ├── settings/      # Theming preferences, app versioning, logouts
│   ├── sms/           # Core bulk messaging engine, templates, background tasks
│   └── students/      # Individual student tracking, adding, excel imports
└── main.dart          # Application initialization and provider scope
```

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.3.4`)
*   Firebase CLI setup for your specific Google Services config.

### Running Locally
1. Clone the repository.
2. Ensure you have the corresponding `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in place from your Firebase Console.
3. Install the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the project:
   ```bash
   flutter run
   ```

## 🔒 Security & Privacy

ClassMyte values user privacy. All authentication logic is strictly verified against Firebase infrastructure before accessing any internal datasets. Critical paths, such as managing active subscription tiers, enforce explicit re-authentication (Password Prompts) to prevent unauthorized tampering. 

---

*Designed and Developed dynamically for ClassMyte.*
