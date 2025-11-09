# BookSwap Implementation Guide

## Current Status

### ✅ Completed Components

1. **Models** (100% Complete)

   - ✅ UserModel
   - ✅ BookModel
   - ✅ SwapOfferModel
   - ✅ ChatMessageModel & ChatRoomModel

2. **Services** (100% Complete)

   - ✅ AuthService (Firebase Authentication)
   - ✅ BookService (CRUD operations)
   - ✅ SwapService (Swap offer management)
   - ✅ ChatService (Real-time messaging)

3. **Providers** (100% Complete)

   - ✅ AuthProvider
   - ✅ BookProvider
   - ✅ SwapProvider
   - ✅ ChatProvider

4. **Authentication Screens** (100% Complete)

   - ✅ LoginScreen
   - ✅ SignupScreen
   - ✅ VerificationScreen

5. **Main Navigation** (100% Complete)

   - ✅ MainScreen with BottomNavigationBar
   - ✅ Firebase integration in main.dart

6. **Browse Section** (Partial)
   - ✅ BrowseListingsScreen
   - ✅ AddBookScreen
   - ⚠️ BookDetailScreen (needs creation)

### 🔨 Remaining Screens to Implement

#### 1. Book Detail Screen

**File**: `lib/screens/book/book_detail_screen.dart`

**Features Needed**:

- Display book details (title, author, condition, image, owner)
- Show "Swap" button if not the owner's book
- Show "Edit" and "Delete" buttons if owner's book
- Initiate swap offer dialog
- Delete confirmation dialog

**Key Functionality**:

```dart
- View full book details
- Initiate swap offer (opens dialog to select user's book to offer)
- Edit book (navigate to AddBookScreen with book data)
- Delete book (with confirmation)
- Chat with owner button
```

#### 2. My Listings Screen

**File**: `lib/screens/listings/my_listings_screen.dart`

**Features Needed**:

- Display user's own book listings
- Show edit and delete options
- Display swap offers (sent and received)
- Tabs for "My Books" and "Swap Offers"

**Tabs Structure**:

1. **My Books Tab**: List of user's posted books
2. **Swap Offers Tab**: Pending/Accepted/Rejected offers

#### 3. Chats List Screen

**File**: `lib/screens/chat/chats_list_screen.dart`

**Features Needed**:

- List all chat rooms
- Show last message preview
- Show unread message count
- Click to open chat detail screen

#### 4. Chat Detail Screen

**File**: `lib/screens/chat/chat_detail_screen.dart`

**Features Needed**:

- Display messages in real-time
- Message input field
- Send message functionality
- Mark messages as read when viewing
- Show timestamp for each message

#### 5. Settings Screen

**File**: `lib/screens/settings/settings_screen.dart`

**Features Needed**:

- Display user profile information
- Toggle for notification preferences
- Toggle for email updates
- Sign out button
- About section

## Firebase Setup Required

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project "BookSwap"
3. Add Android/iOS/Web apps

### 2. Enable Services

#### Authentication

- Enable Email/Password authentication
- Configure email templates for verification

#### Firestore Database

Create collections with following structure:

- `users/` - User profiles
- `books/` - Book listings
- `swap_offers/` - Swap offers
- `chat_rooms/` - Chat rooms
  - `messages/` (subcollection)

#### Storage

- Create bucket for book images
- Configure storage rules

### 3. Add Configuration Files

**Android**:

```
- Download google-services.json
- Place in: android/app/google-services.json
```

**iOS**:

```
- Download GoogleService-Info.plist
- Add to iOS project via Xcode
```

**Web**:

```html
<!-- Add to web/index.html -->
<script src="https://www.gstatic.com/firebasejs/..."></script>
<script>
  const firebaseConfig = {
    // Your config here
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

### 4. Update Android Build Files

**android/build.gradle**:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.1'
    }
}
```

**android/app/build.gradle**:

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21  // Required for Firebase
    }
}
```

## Quick Start to Run the App

### 1. Install Dependencies

```bash
cd bookswap_app
flutter pub get
```

### 2. Setup Firebase

- Create Firebase project
- Add configuration files
- Enable Authentication, Firestore, Storage

### 3. Run App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## Testing Checklist

### Authentication

- [ ] Sign up with email/password
- [ ] Email verification sent
- [ ] Cannot login without verification
- [ ] Login with verified email
- [ ] Logout functionality

### Book Listings (CRUD)

- [ ] Create new book listing
- [ ] Upload book image
- [ ] View all books in browse feed
- [ ] Edit own book
- [ ] Delete own book
- [ ] Search books by title/author

### Swap Functionality

- [ ] Initiate swap offer
- [ ] View sent swap offers
- [ ] View received swap offers
- [ ] Accept swap offer
- [ ] Reject swap offer
- [ ] Cancel swap offer
- [ ] Books marked unavailable during swap

### Chat (Bonus)

- [ ] Create chat room
- [ ] Send messages
- [ ] Receive messages in real-time
- [ ] Mark messages as read
- [ ] Unread message count

### Navigation & UI

- [ ] Bottom navigation works
- [ ] All screens accessible
- [ ] Settings toggles work
- [ ] Profile info displayed

## Running Dart Analyzer

Generate analyzer report:

```bash
# Run analyzer
flutter analyze > dart_analyzer_report.txt

# Or for detailed output
dart analyze --fatal-infos > dart_analyzer_report.txt
```

## Demo Video Guide

### Required Scenes (7-12 minutes)

1. **Introduction** (30s)

   - Show app name and purpose
   - Brief overview of features

2. **Firebase Console Setup** (1-2 mins)

   - Show Firebase project structure
   - Point out Authentication, Firestore, Storage

3. **Authentication Flow** (2 mins)

   - Sign up new user
   - Show verification email in inbox
   - Verify email
   - Login

4. **Book Listings CRUD** (3 mins)

   - Create book (with image upload)
   - Show in Firebase Console
   - Edit book
   - Show update in Firestore
   - Delete book
   - Confirm deletion in console

5. **Browse & Search** (1 min)

   - Browse all listings
   - Search functionality
   - Filter results

6. **Swap Functionality** (2-3 mins)

   - Initiate swap offer
   - Show Firestore swap_offers collection
   - View pending offer
   - Accept/Reject offer
   - Show state changes in real-time

7. **Chat Feature** (2 mins - if implemented)

   - Start chat with user
   - Send messages
   - Show real-time updates in Firestore
   - Unread message count

8. **Settings & Logout** (30s)
   - Navigate to settings
   - Toggle preferences
   - Logout

## Common Firebase Errors & Solutions

### Error 1: "No Firebase App '[DEFAULT]' has been created"

**Solution**: Ensure Firebase.initializeApp() is called in main.dart before runApp()

### Error 2: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solution**: Update Firestore security rules (see README for rules)

### Error 3: "Email already in use"

**Solution**: This is expected - inform user or try different email

### Error 4: "Invalid email"

**Solution**: Validate email format before sending to Firebase

### Error 5: "Storage upload failed"

**Solution**:

- Check Storage rules
- Verify image size < 5MB
- Ensure correct file path

## State Management Explanation

### Provider Pattern Used

**Why Provider?**

- Official Flutter recommendation
- Simple to learn and implement
- Sufficient for medium-sized apps
- Less boilerplate than BLoC
- Good community support

**How it Works in BookSwap:**

1. **Providers are created** in main.dart:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => BookProvider()),
    // ...
  ],
)
```

2. **Screens consume providers**:

```dart
final authProvider = Provider.of<AuthProvider>(context);
// or
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    // Use authProvider here
  },
)
```

3. **Providers notify listeners** when state changes:

```dart
class AuthProvider extends ChangeNotifier {
  void signIn() async {
    // ... do work
    notifyListeners(); // Rebuilds all listening widgets
  }
}
```

**Benefits**:

- Automatic UI updates
- Centralized business logic
- Easy testing
- Separation of concerns

## Design Trade-offs

### 1. Single vs Multiple Images

**Decision**: Single image per book
**Reason**: Simpler implementation, faster uploads
**Trade-off**: Less detailed book presentation

### 2. Real-time vs Polling

**Decision**: Firestore streams for real-time updates
**Reason**: Better UX, instant updates
**Trade-off**: Higher read operations cost

### 3. Chat Implementation

**Decision**: Simple text chat only
**Reason**: Core feature for MVP
**Future**: Add images, file sharing, reactions

### 4. Book Availability

**Decision**: Auto-toggle availability during swaps
**Reason**: Prevents double-swapping
**Consideration**: Clear communication to users

## Next Steps for Completion

1. **Create remaining screens** (see list above)
2. **Add Firebase configuration** to project
3. **Test all CRUD operations**
4. **Record demo video**
5. **Document Firebase errors encountered**
6. **Run Dart analyzer** and fix issues
7. **Prepare submission documents**

## Submission Checklist

- [ ] GitHub repository with clean commit history (10+ commits)
- [ ] README with setup instructions
- [ ] All source code files
- [ ] Reflection PDF with Firebase error screenshots
- [ ] Dart Analyzer screenshot
- [ ] Demo video (7-12 mins)
- [ ] Design summary PDF (database schema, state management, trade-offs)

## Support Resources

- Flutter Documentation: https://docs.flutter.dev/
- Firebase Documentation: https://firebase.google.com/docs
- Provider Package: https://pub.dev/packages/provider
- FlutterFire: https://firebase.flutter.dev/

---

**Remember**: Take screenshots of Firebase errors as you encounter them for your reflection document!
