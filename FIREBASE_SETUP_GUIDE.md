# Firebase Setup Guide for BookSwap App

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add Project"** or **"Create a project"**
3. Enter project name: `BookSwap` or `bookswap-app`
4. Click **Continue**
5. Disable Google Analytics (optional) or configure it
6. Click **Create project**
7. Wait for the project to be created
8. Click **Continue** when ready

## Step 2: Register Your App with Firebase

### For Android

1. In Firebase Console, click the **Android icon** (robot)
2. Enter Android package name: `com.example.bookswap_app`
   - Find this in `android/app/build.gradle` under `applicationId`
3. Click **Register app**
4. Download `google-services.json`
5. Place the file in: `android/app/google-services.json`
6. Click **Next** and follow the SDK setup instructions below

### For iOS

1. In Firebase Console, click the **iOS icon** (apple)
2. Enter iOS bundle ID: `com.example.bookswapApp`
   - Find this in Xcode project settings
3. Click **Register app**
4. Download `GoogleService-Info.plist`
5. Open your iOS project in Xcode
6. Drag the file into the Runner folder in Xcode
7. Make sure "Copy items if needed" is checked
8. Click **Next**

### For Web (Optional)

1. In Firebase Console, click the **Web icon** (</>)
2. Enter app nickname: `BookSwap Web`
3. Click **Register app**
4. Copy the Firebase configuration
5. Add it to `web/index.html` before `</body>`:

```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js";

  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID",
  };

  initializeApp(firebaseConfig);
</script>
```

## Step 3: Configure Android Build Files

### android/build.gradle

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // Add this line
        classpath 'com.google.gms:google-services:4.4.1'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### android/app/build.gradle

At the top, add after other plugins:

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// Add this line
apply plugin: 'com.google.gms.google-services'
```

In `android` block, update `defaultConfig`:

```gradle
android {
    namespace "com.example.bookswap_app"
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.bookswap_app"
        minSdkVersion 21  // Changed from 19 to 21 for Firebase
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
        multiDexEnabled true  // Add this for Firebase
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

## Step 4: Enable Firebase Services

### Enable Authentication

1. In Firebase Console, go to **Build** → **Authentication**
2. Click **Get Started**
3. Click on **Sign-in method** tab
4. Enable **Email/Password**
5. Click **Save**

### Create Firestore Database

1. Go to **Build** → **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (we'll add security rules later)
4. Choose a Cloud Firestore location (select closest to your users)
5. Click **Enable**

### Create Storage Bucket

1. Go to **Build** → **Storage**
2. Click **Get Started**
3. Start in **test mode** (we'll add security rules later)
4. Click **Next**
5. Choose storage location
6. Click **Done**

## Step 5: Set Up Security Rules

### Firestore Security Rules

Go to **Firestore Database** → **Rules** tab and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isOwner(userId);
    }

    // Books collection
    match /books/{bookId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() &&
                                 isOwner(resource.data.ownerId);
    }

    // Swap offers collection
    match /swap_offers/{offerId} {
      allow read: if isSignedIn() &&
                     (isOwner(resource.data.requesterId) ||
                      isOwner(resource.data.ownerId));
      allow create: if isSignedIn();
      allow update: if isSignedIn() &&
                       (isOwner(resource.data.requesterId) ||
                        isOwner(resource.data.ownerId));
      allow delete: if isSignedIn() &&
                       (isOwner(resource.data.requesterId) ||
                        isOwner(resource.data.ownerId));
    }

    // Chat rooms collection
    match /chat_rooms/{chatRoomId} {
      allow read, write: if isSignedIn() &&
                            request.auth.uid in resource.data.participantIds;

      // Messages subcollection
      match /messages/{messageId} {
        allow read, write: if isSignedIn();
      }
    }
  }
}
```

Click **Publish** to save the rules.

### Storage Security Rules

Go to **Storage** → **Rules** tab and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Book images
    match /book_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      request.resource.size < 5 * 1024 * 1024 &&
                      request.resource.contentType.matches('image/.*');
    }
  }
}
```

Click **Publish** to save the rules.

## Step 6: Test Firebase Connection

Run this command to test:

```bash
cd bookswap_app
flutter run
```

If you see authentication screens, Firebase is connected!

## Common Errors and Solutions

### Error 1: "Execution failed for task ':app:processDebugGoogleServices'"

**Solution**: Make sure `google-services.json` is in the correct location:

- Path: `android/app/google-services.json`
- Check package name matches in JSON file and `build.gradle`

### Error 2: "No Firebase App '[DEFAULT]' has been created"

**Solution**: Ensure `Firebase.initializeApp()` is called in `main.dart` before `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // This line must be here
  runApp(const MyApp());
}
```

### Error 3: "Platform Exception: PlatformException(error, ... FirebaseError ...)"

**Solution**:

1. Check Firebase configuration files are properly added
2. Verify package name matches across all files
3. Run `flutter clean` and then `flutter pub get`
4. Rebuild the app

### Error 4: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solution**: Update Firestore security rules as shown in Step 5

### Error 5: "A network error ... occurred"

**Solution**:

1. Check internet connection
2. Verify Firebase project is active
3. Check if Firestore/Storage is enabled in Firebase Console

## Step 7: Email Configuration (Optional)

### Customize Email Templates

1. Go to **Authentication** → **Templates** tab
2. Customize **Email address verification** template:
   - Click the pencil icon
   - Edit the subject and body
   - Add your app name and styling
   - Click **Save**

### Email Sender Configuration

1. Go to **Project Settings** → **General** tab
2. Scroll to **Public-facing name**
3. Set to "BookSwap"
4. Set **Support email**

## Step 8: Verify Setup

### Checklist:

- [ ] Firebase project created
- [ ] `google-services.json` added to `android/app/`
- [ ] Android build files updated
- [ ] Firebase Authentication enabled
- [ ] Firestore Database created
- [ ] Storage bucket created
- [ ] Security rules configured
- [ ] App builds successfully
- [ ] Can sign up and login
- [ ] Data appears in Firestore Console

## Testing the Setup

1. **Run the app**:

   ```bash
   flutter run
   ```

2. **Sign up** with a test email:

   - Email: test@example.com
   - Password: test123

3. **Check Firebase Console**:

   - Go to **Authentication** → **Users** tab
   - You should see the new user

4. **Check Firestore**:

   - Go to **Firestore Database**
   - You should see the `users` collection with the new user document

5. **Post a book**:

   - Add a book in the app
   - Check **Firestore Database** for the `books` collection

6. **Check Storage**:
   - Upload a book image
   - Go to **Storage** → **Files**
   - You should see the image in `book_images/` folder

## Next Steps

After Firebase is set up:

1. Test all CRUD operations
2. Test swap functionality
3. Test chat feature
4. Record demo video showing Firebase Console alongside app
5. Document any errors encountered for reflection PDF

## Useful Firebase Console URLs

- Project Overview: `https://console.firebase.google.com/project/YOUR_PROJECT_ID`
- Authentication: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication/users`
- Firestore: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore`
- Storage: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/storage`

## Resources

- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire: https://firebase.flutter.dev/
- Firebase Console: https://console.firebase.google.com/
- Firebase Support: https://firebase.google.com/support

---

**Important**: Take screenshots at each step for your reflection document, especially any error messages you encounter!
