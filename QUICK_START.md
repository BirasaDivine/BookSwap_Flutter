# 🚀 Quick Start Guide - BookSwap App

This guide will help you get the BookSwap app running in the shortest time possible.

## ⚡ Fast Track (30 minutes)

### Step 1: Install Dependencies (2 minutes)

```bash
cd bookswap_app
flutter pub get
```

### Step 2: Create Firebase Project (10 minutes)

1. Go to https://console.firebase.google.com/
2. Click "Create a project"
3. Name it "BookSwap" → Continue
4. Disable Google Analytics → Create project
5. Wait for project creation → Continue

### Step 3: Add Android App (5 minutes)

1. Click Android icon (🤖)
2. Package name: `com.example.bookswap_app`
3. Click "Register app"
4. Download `google-services.json`
5. Put it in: `android/app/google-services.json`
6. Click "Next" → "Next" → "Continue to console"

### Step 4: Enable Firebase Services (5 minutes)

**Authentication:**

1. Click "Build" → "Authentication"
2. Click "Get started"
3. Click "Email/Password"
4. Enable it → Save

**Firestore:**

1. Click "Build" → "Firestore Database"
2. Click "Create database"
3. "Start in test mode" → Next
4. Select location (US-central or closest) → Enable

**Storage:**

1. Click "Build" → "Storage"
2. Click "Get started"
3. "Start in test mode" → Next
4. Use default location → Done

### Step 5: Configure Android Build (3 minutes)

**Your project uses Kotlin DSL (`.kts` files) - modern Flutter setup!**

**File: `android/settings.gradle.kts`**

Add this line inside the `plugins` block:

```kotlin
id("com.google.gms.google-services") version "4.4.1" apply false
```

So it looks like:

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.1" apply false  // Add this
}
```

**File: `android/app/build.gradle.kts`**

Add this line inside the `plugins` block at the top:

```kotlin
id("com.google.gms.google-services")
```

So it looks like:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Add this
}
```

Also change `minSdk` to 21:

```kotlin
defaultConfig {
    minSdk = 21  // Change from flutter.minSdkVersion to 21
}
```

**✅ I've already made these changes for you!**

### Step 6: Run the App! (5 minutes)

```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 First Test (5 minutes)

1. **Sign Up**

   - Email: test@test.com
   - Password: test123
   - Name: Test User

2. **Verify Email**

   - Check your email inbox
   - Click verification link
   - Return to app
   - Click "I've Verified"

3. **Post a Book**

   - Click + icon
   - Title: "Test Book"
   - Author: "Test Author"
   - Condition: Good
   - Click "Post Book"

4. **Check Firebase Console**
   - Go to Firestore Database
   - See your book in "books" collection!

## 🔥 Firebase Console Quick Links

After creating your project, bookmark these:

- **Authentication**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication
- **Firestore**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore
- **Storage**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/storage

## 📝 Security Rules (Add After Testing)

### Firestore Rules

1. Go to Firestore → Rules tab
2. Paste this and click "Publish":

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isOwner(userId);
    }

    match /books/{bookId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && isOwner(resource.data.ownerId);
    }

    match /swap_offers/{offerId} {
      allow read: if isSignedIn() &&
                     (isOwner(resource.data.requesterId) || isOwner(resource.data.ownerId));
      allow create: if isSignedIn();
      allow update: if isSignedIn() &&
                       (isOwner(resource.data.requesterId) || isOwner(resource.data.ownerId));
    }

    match /chat_rooms/{chatRoomId} {
      allow read, write: if isSignedIn() &&
                            request.auth.uid in resource.data.participantIds;

      match /messages/{messageId} {
        allow read, write: if isSignedIn();
      }
    }
  }
}
```

### Storage Rules

1. Go to Storage → Rules tab
2. Paste this and click "Publish":

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      request.resource.size < 5 * 1024 * 1024 &&
                      request.resource.contentType.matches('image/.*');
    }
  }
}
```

## ⚠️ Common Quick Fixes

### App won't build?

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### "No Firebase App created" error?

Make sure `google-services.json` is in `android/app/` folder.

### Email not sending?

1. Check spam folder
2. Wait 1-2 minutes
3. Try "Resend" button

### Can't upload images?

Make sure you:

1. Enabled Storage in Firebase Console
2. Added Storage rules
3. Selected an image < 5MB

## 📱 Demo Video Checklist

When you're ready to record (after testing):

- [ ] Clear Firebase data for fresh demo
- [ ] Create 2 test accounts
- [ ] Sign up → verify → login
- [ ] Post book with image → show in Firestore
- [ ] Edit book → show update in Firestore
- [ ] Delete book → show deletion in Firestore
- [ ] Create swap offer → show in Firestore
- [ ] Accept/reject swap → show state change
- [ ] Send chat messages → show in Firestore
- [ ] Navigate all screens
- [ ] Toggle settings
- [ ] Logout

## 🎓 Next Steps

Once the app is running:

1. **Test all features** (1 hour)

   - Authentication
   - CRUD operations
   - Swap system
   - Chat feature

2. **Record demo video** (1 hour)

   - Show Firebase Console alongside app
   - 7-12 minutes total
   - Clear narration

3. **Write documentation** (2 hours)

   - Reflection PDF (Firebase errors & solutions)
   - Design summary PDF (schema, state management, trade-offs)
   - Run dart analyzer → screenshot

4. **Prepare repository** (30 minutes)
   - 10+ meaningful commits
   - Clean README
   - .gitignore configured

## 📚 Need More Help?

- **Full Firebase Setup**: See `FIREBASE_SETUP_GUIDE.md`
- **Implementation Details**: See `IMPLEMENTATION_GUIDE.md`
- **Project Overview**: See `PROJECT_SUMMARY.md`
- **README**: See `bookswap_app/README.md`

## 🆘 Still Stuck?

1. **Check Firebase Console**

   - Is Authentication enabled?
   - Is Firestore created?
   - Is Storage enabled?
   - Are rules configured?

2. **Check Files**

   - Is `google-services.json` in `android/app/`?
   - Did you update `build.gradle` files?
   - Did you run `flutter pub get`?

3. **Common Issues**
   - Package name mismatch → Check `google-services.json`
   - Build errors → Run `flutter clean`
   - Permission denied → Update Firestore rules
   - No email → Check spam, wait, resend

## ✨ You're Ready!

If you followed these steps, your app should be running! Now:

1. Test all features thoroughly
2. Document any errors you encountered
3. Record your demo video
4. Prepare your submission documents

Good luck! 🎉

---

**Time spent so far**: ~30 minutes
**Total project time**: ~6-9 hours
**You're on track!** 💪
