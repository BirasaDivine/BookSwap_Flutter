# Fixing "Unknown" Owner Names

## Problem

Books created by users show "Unknown" instead of the actual user name.

## Root Cause

The displayName field in Firestore user documents was:

- Empty or missing
- Not synced from Firebase Auth on login
- Using a fallback of 'Unknown' when creating books

## Solutions Implemented

### 1. ✅ Better Fallback Logic in Book Creation

**File:** `lib/screens/book/add_book_screen.dart`

Now when creating a book, the app tries multiple sources for the username:

1. UserModel displayName from Firestore
2. Firebase Auth user displayName
3. Email username (part before @)
4. "Unknown" as last resort

**Result:** NEW books will have proper names

### 2. ✅ Sync DisplayName on Login

**File:** `lib/services/auth_service.dart`

When users log in, the app now:

- Updates emailVerified status
- **Syncs displayName from Firebase Auth to Firestore**

**Result:** User Firestore documents get updated with correct names

### 3. ✅ User Helper Service

**File:** `lib/services/user_helper.dart`

Created a helper to fetch user displayNames from Firestore for existing books.

## How to Fix Existing "Unknown" Books

### Option 1: Users Re-Login (Easiest)

1. Ask users to log out
2. Log back in
3. The displayName will sync automatically
4. **Then delete and re-create their books** (or edit them)

### Option 2: Manual Firebase Console Update

1. Go to: https://console.firebase.google.com/project/bookswap-97c8e/firestore/data
2. Click on `users` collection
3. For each user document:
   - Click on the document
   - Check if `displayName` field exists and has a value
   - If empty, click "Add field" or edit it
   - Set displayName to the user's actual name
4. The books will still show "Unknown" until re-created

### Option 3: Update Existing Books (Advanced)

Run this script in Firebase Console or create a migration function:

```javascript
// Go to Firestore → Rules → Try it in the console
db.collection("books")
  .get()
  .then((snapshot) => {
    snapshot.docs.forEach((bookDoc) => {
      const book = bookDoc.data();
      if (book.ownerName === "Unknown") {
        // Fetch owner's actual name
        db.collection("users")
          .doc(book.ownerId)
          .get()
          .then((userDoc) => {
            if (userDoc.exists) {
              const user = userDoc.data();
              if (user.displayName) {
                // Update book with correct owner name
                bookDoc.ref.update({
                  ownerName: user.displayName,
                });
              }
            }
          });
      }
    });
  });
```

## Testing the Fix

### Test 1: New Books

1. Log in as a user
2. Create a new book
3. Log in as another user
4. Browse books
5. ✅ Should see the correct owner name

### Test 2: Existing Users

1. Log out from the app
2. Log back in
3. Check your profile/settings to see if displayName is shown

### Test 3: Firebase Console Check

1. Go to Firestore → users collection
2. Click on a user document
3. Verify `displayName` field exists and has a value

## Quick Fix for Testing

If you want to test immediately:

1. Create a NEW account with a clear displayName
2. Create a book
3. Log in as another user
4. Browse books
5. The new book should show the correct owner name ✅

## Why "Unknown" Appeared

1. **Signup:** User signs up → Firebase Auth user created → Firestore user document created with displayName
2. **BUT:** If displayName wasn't properly saved to Firestore...
3. **Login:** User logs in → app loads Firestore user document → displayName is empty/null
4. **Create Book:** app uses `authProvider.userModel?.displayName ?? 'Unknown'` → gets "Unknown"
5. **Book saved:** Book document has ownerName: "Unknown"
6. **Other users browse:** They see "Unknown"

## Now Fixed ✅

1. **Signup:** displayName saved to both Firebase Auth AND Firestore
2. **Login:** displayName synced from Firebase Auth to Firestore (if missing)
3. **Create Book:** Better fallback logic (Auth → Email → Unknown)
4. **Result:** Books show actual owner names!

## Existing Data Cleanup

The "Unknown" books are already in the database. To clean them up:

- Users can edit their books (which will use the new logic)
- Or run the migration script above
- Or wait for users to naturally re-create books

**Future books will automatically have correct owner names!** 🎉
