# BookSwap - Student Book Exchange Platform

A comprehensive Flutter application that enables students to swap textbooks with each other. Built with Firebase for backend services, featuring real-time chat, swap offers, and complete CRUD operations.

## 🎯 Features

### Core Functionality

- **User Authentication**: Email/password signup with email verification
- **Book Listings**: Post, edit, delete, and browse textbooks
- **Swap System**: Create and manage book swap offers with real-time status updates
- **Real-time Chat**: Message other students after swap offers
- **Search**: Find books by title or author
- **User Profiles**: View and manage user information

### Technical Features

- **State Management**: Provider pattern for reactive UI
- **Real-time Sync**: Firestore streams for instant updates
- **Image Upload**: Firebase Storage for book cover images
- **Clean Architecture**: Separation of models, services, providers, and UI
- **Material Design**: Modern, intuitive user interface

## 📱 Screenshots

[Add your app screenshots here after running the app]

## 🏗️ Architecture

### Project Structure

```
lib/
├── constants/        # App-wide constants (colors, themes)
├── models/          # Data models (User, Book, SwapOffer, Chat)
├── services/        # Firebase services (Auth, CRUD operations)
├── providers/       # State management (Provider pattern)
├── screens/         # UI screens
│   ├── auth/       # Login, Signup, Verification
│   ├── browse/     # Browse listings
│   ├── book/       # Book details, Add/Edit
│   ├── listings/   # My listings & swap offers
│   ├── chat/       # Chat list & conversations
│   └── settings/   # User settings
└── widgets/        # Reusable widgets
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer (Screens)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Auth    │  │  Browse  │  │  Book    │  │  Chat    │   │
│  │  Screens │  │  Screen  │  │  Screens │  │  Screens │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
└───────┼─────────────┼──────────────┼─────────────┼──────────┘
        │             │              │             │
        ▼             ▼              ▼             ▼
┌─────────────────────────────────────────────────────────────┐
│                   State Management (Provider)                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │   Book   │  │   Swap   │  │   Chat   │   │
│  │ Provider │  │ Provider │  │ Provider │  │ Provider │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
└───────┼─────────────┼──────────────┼─────────────┼──────────┘
        │             │              │             │
        ▼             ▼              ▼             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Service Layer                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │   Book   │  │   Swap   │  │   Chat   │   │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
└───────┼─────────────┼──────────────┼─────────────┼──────────┘
        │             │              │             │
        ▼             ▼              ▼             ▼
┌─────────────────────────────────────────────────────────────┐
│                   Firebase Backend                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │Firebase  │  │Firestore │  │ Firebase │                  │
│  │   Auth   │  │ Database │  │ Storage  │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User Interaction** → UI Screen (e.g., Login Screen)
2. **Screen** → Calls Provider method (e.g., AuthProvider.login())
3. **Provider** → Calls Service method (e.g., AuthService.signIn())
4. **Service** → Interacts with Firebase (Authentication/Firestore/Storage)
5. **Firebase** → Returns data/error
6. **Service** → Processes response, returns to Provider
7. **Provider** → Updates state, notifies listeners
8. **UI** → Rebuilds with new data (via Consumer/Provider.of)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Firebase account
- Android Studio / Xcode (for mobile development)
- VS Code / Android Studio (IDE)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/BirasaDivine/BookSwap_Flutter.git
   cd BookSwap_Flutter/bookswap_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (IMPORTANT!)

   **See `FIREBASE_SETUP_GUIDE.md` for detailed instructions**

   Quick steps:

   - Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to Firebase project
   - Download configuration files:
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → iOS project via Xcode
   - Enable Authentication (Email/Password)
   - Create Firestore Database
   - Create Storage bucket
   - Configure security rules (see Firebase guide)

4. **Run the app**

   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome
   ```

## 🔥 Firebase Configuration

### Required Services

- **Authentication**: Email/Password sign-in
- **Firestore Database**: Real-time NoSQL database
- **Storage**: Image storage for book covers

### Database Structure

```
users/
  └── {userId}
      ├── uid: string
      ├── email: string
      ├── displayName: string
      ├── emailVerified: boolean
      └── createdAt: timestamp

books/
  └── {bookId}
      ├── id: string
      ├── title: string
      ├── author: string
      ├── condition: string
      ├── imageUrl: string
      ├── ownerId: string
      ├── ownerName: string
      ├── isAvailable: boolean
      └── createdAt: timestamp

swap_offers/
  └── {offerId}
      ├── requestedBookId: string
      ├── offeredBookId: string
      ├── requesterId: string
      ├── ownerId: string
      ├── status: string
      └── createdAt: timestamp

chat_rooms/
  └── {chatRoomId}
      ├── participantIds: array
      ├── participantNames: map
      ├── lastMessage: string
      ├── lastMessageTime: timestamp
      └── messages/ (subcollection)
          └── {messageId}
              ├── senderId: string
              ├── message: string
              └── timestamp: timestamp
```

## 🎨 State Management

This app uses **Provider** for state management:

- **AuthProvider**: Manages authentication state
- **BookProvider**: Handles book listings and CRUD operations
- **SwapProvider**: Manages swap offers and their states
- **ChatProvider**: Handles chat rooms and messages

### Why Provider?

- Official Flutter recommendation
- Simple and easy to learn
- Sufficient for medium-sized apps
- Less boilerplate than BLoC
- Excellent documentation

## 📋 Features Breakdown

### 1. Authentication

- Email/password registration
- Email verification required
- Secure login/logout
- User profile management
- Firebase Auth integration

### 2. Book Listings (CRUD)

- **Create**: Post books with cover images
- **Read**: Browse all available books
- **Update**: Edit book details
- **Delete**: Remove listings
- Search functionality
- Real-time updates

### 3. Swap Functionality

- Initiate swap offers
- View sent and received offers
- Accept/Reject offers
- Real-time status updates
- Automatic book availability management
- States: Pending, Accepted, Rejected, Completed, Cancelled

### 4. Chat System

- Real-time messaging
- Chat room creation
- Unread message counter
- Message timestamps
- Auto-scroll to latest message

### 5. Settings

- View profile information
- Toggle notification preferences
- Toggle email updates
- About section
- Sign out functionality

## 🧪 Testing

Run tests:

```bash
flutter test
```

Run analyzer:

```bash
flutter analyze
```

For detailed report:

```bash
dart analyze --fatal-infos > dart_analyzer_report.txt
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.1
  firebase_storage: ^12.3.6
  provider: ^6.1.2
  image_picker: ^1.1.2
  intl: ^0.19.0
  uuid: ^4.5.1
  cupertino_icons: ^1.0.8
```

## 🔒 Security

### Firestore Rules

See `FIREBASE_SETUP_GUIDE.md` for complete security rules.

Key principles:

- Users can only modify their own data
- Books can only be modified by owners
- Swap offers restricted to participants
- Chat rooms restricted to participants

### Storage Rules

- Authenticated users can read images
- Only authenticated users can upload
- Max file size: 5MB
- Only image files allowed

## 🐛 Common Issues & Solutions

### "No Firebase App '[DEFAULT]' has been created"

**Solution**: Ensure `Firebase.initializeApp()` is called in `main.dart`

### "PERMISSION_DENIED"

**Solution**: Update Firestore/Storage security rules

### "Package name mismatch"

**Solution**: Verify package name in `google-services.json` matches `build.gradle`

### "Email verification not working"

**Solution**: Check spam folder, verify Firebase email templates

See `FIREBASE_SETUP_GUIDE.md` for more solutions.

## 📚 Documentation

- **`PROJECT_SUMMARY.md`**: Complete project overview
- **`FIREBASE_SETUP_GUIDE.md`**: Detailed Firebase configuration steps
- **`IMPLEMENTATION_GUIDE.md`**: Development guide and best practices

## 🎥 Demo Video

[Link to demo video showing:]

- User authentication flow
- Book CRUD operations
- Swap functionality
- Chat feature
- Firebase Console integration

## 🤝 Contributing

This is an academic project. For suggestions or issues:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Divine Birasa**

- GitHub: [@BirasaDivine](https://github.com/BirasaDivine)

## 🙏 Acknowledgments

- Flutter team for excellent documentation
- Firebase for backend services
- Provider package maintainers
- Course instructors and TAs

## 📞 Support

For questions or support:

- Create an issue in the repository
- Contact: [your-email@example.com]

---

**Built with Flutter 💙 and Firebase 🔥**
