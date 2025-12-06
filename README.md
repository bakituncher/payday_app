# 💰 Payday - Your Smart Financial Countdown Companion

A viral, mass-market financial tracker for the US and Australian markets that counts down to payday, tracks expenses, and manages savings goals.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-00A8E8?style=for-the-badge)

## 🎯 Features

### Core Functionality
- **⏱️ Live Countdown Timer** - Beautiful, animated countdown showing exact time until money arrives
- **💸 Daily Allowable Spend** - Smart calculation of how much you can spend per day
- **📊 Budget Progress Tracking** - Visual progress bars with health indicators
- **📝 Transaction Management** - Quick expense tracking with emoji categories
- **🎯 Savings Goals** - Visual "pots" with liquid animation progress
- **🔄 Multi-Currency Support** - USD and AUD with proper formatting

### Design Language
- **Theme**: "Chic Fintech Pink" - Sophisticated, trusted pink combined with clean whites
- **Vibe**: Minimalist, airy, modern, and polished
- **Components**: Rounded corners (24px), soft shadows, glassmorphism effects
- **Typography**: Poppins font family for clean, geometric look

## 🏗️ Architecture

### Clean Architecture Structure
```
lib/
├── core/                       # Core utilities and shared code
│   ├── constants/             # App-wide constants
│   ├── models/                # Data models (Freezed)
│   ├── providers/             # Riverpod providers
│   ├── repositories/          # Repository interfaces & implementations
│   │   └── mock/             # Mock implementations for testing
│   ├── theme/                # App theme configuration
│   └── utils/                # Utility functions
├── features/                  # Feature modules
│   ├── home/                 # Home screen feature
│   │   ├── providers/       # Feature-specific providers
│   │   ├── screens/         # Screen widgets
│   │   └── widgets/         # Feature-specific widgets
│   ├── onboarding/          # Onboarding flow
│   └── transactions/        # Transaction management
├── shared/                   # Shared UI components
│   └── widgets/             # Reusable widgets
└── main.dart                # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Dart SDK 3.9.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/payday_flutter.git
cd payday_flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 📦 Tech Stack

### Framework & Language
- **Flutter 3.9+** - Cross-platform UI framework
- **Dart 3.9+** - Programming language

### State Management
- **Riverpod 2.5+** - Reactive state management with clean, testable code
- **Riverpod Annotations** - Code generation for providers

### Backend (Ready for Integration)
- **Firebase Core** - Firebase initialization
- **Firebase Auth** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Analytics** - User behavior tracking

### UI & Design
- **Google Fonts** - Poppins typography
- **Flutter Animate** - Smooth, declarative animations
- **Shimmer** - Loading state animations
- **Material 3** - Modern Material Design
- **Custom Theme System** - Chic Fintech Pink palette

### Data & Models
- **Freezed** - Immutable data classes with code generation
- **JSON Serializable** - JSON serialization
- **Shared Preferences** - Local storage
- **intl** - Internationalization and formatting
- **UUID** - Unique ID generation

## 🎨 Design System

### Color Palette
```dart
Primary Pink:    #FF69B4  // Hot Pink
Soft Pink:       #F8BBD0  // Pastel Pink
Light Pink:      #FCE4EC  // Very Light Pink
Accent Pink:     #FF1493  // Deep Pink

Background:      #FAFAFA  // Off-white
Card White:      #FFFFFF  // Pure white
Dark Charcoal:   #2D2D2D  // Text primary
```

### Typography Scale
- Display Large: 57px, Bold
- Headline Medium: 28px, SemiBold
- Title Large: 22px, SemiBold
- Body Large: 16px, Regular
- Label Medium: 12px, Medium

### Spacing System (8px grid)
- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px
- XXL: 48px

## 🔧 Configuration

### Onboarding Flow
Users are guided through a 4-step setup:
1. Welcome & Features
2. Currency Selection (USD/AUD)
3. Pay Cycle & Next Payday
4. Income Amount

### Pay Cycles Supported
- Weekly (7 days)
- Bi-Weekly / Fortnightly (14 days)
- Monthly (calendar month)

### Transaction Categories
🍔 Food & Dining | 🚗 Transportation | 🛍️ Shopping | 🎬 Entertainment
📱 Bills & Utilities | 💪 Health & Fitness | 🛒 Groceries | ☕ Coffee & Drinks
💄 Personal Care | 📌 Other

## 📱 Screens

### Home Screen
- Animated countdown timer in hero card
- Daily allowable spend calculation
- Budget progress with health indicator
- Recent transactions list
- Floating action button for quick expense entry

### Add Transaction Screen
- Bottom sheet modal design
- Quick category selection with emoji chips
- Real-time input validation
- Auto-calculated budget updates

### Onboarding Screen
- Smooth page transitions
- Progress indicator
- Market-specific settings
- Date picker for payday

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Mock Repositories
The app includes mock implementations of all repositories for UI testing without backend setup:
- `MockUserSettingsRepository`
- `MockTransactionRepository`
- `MockSavingsGoalRepository`

## 🔮 Future Enhancements

### Phase 2 Features
- [ ] Savings Goals with liquid animations
- [ ] Recurring transactions
- [ ] Budget categories customization
- [ ] Data export (CSV, PDF)
- [ ] Notifications for payday reminders

### Phase 3 Features
- [ ] Multi-account support
- [ ] Bill splitting
- [ ] Financial insights & AI recommendations
- [ ] Dark mode
- [ ] Biometric authentication

### Backend Integration
- [ ] Replace mock repositories with Firebase implementations
- [ ] User authentication flow
- [ ] Cloud data sync
- [ ] Analytics tracking
- [ ] Push notifications

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Your Name** - *Initial work*

## 🙏 Acknowledgments

- Design inspiration from modern fintech apps
- Flutter community for amazing packages
- Material Design 3 guidelines

## 📞 Support

For support, email support@paydayapp.com or join our Discord channel.

---

**Made with 💖 and Flutter**

