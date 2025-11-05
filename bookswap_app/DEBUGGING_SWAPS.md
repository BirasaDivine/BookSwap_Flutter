# Debugging Swap Offers Not Saving

## Problem

Swap offers appear in the app UI but are **NOT being saved to Firebase Firestore**. The `swap_offers` collection doesn't exist in Firebase Console.

## Possible Causes

### 1. Permission Denied (Most Likely)

The Firestore security rules are blocking the write operation.

**Solution:** Update Firebase security rules (see FIXING_PERMISSIONS.md)

### 2. Silent Failure

The error is being caught but not displayed properly to the user.

**Solution:** Check the Flutter console logs when creating a swap offer.

### 3. Network Issue

The app might be offline or Firebase connection is failing.

**Solution:** Check internet connection and Firebase Console status.

## How to Debug

### Step 1: Run the App with Logging

```powershell
cd bookswap_app
flutter run
```

### Step 2: Try Creating a Swap Offer

1. Go to a book detail page
2. Click "Swap This Book"
3. Select a book to offer
4. Watch the console output

### Step 3: Look for These Log Messages

```
=== Creating swap offer ===
Requested book ID: ...
Offered book ID: ...
Requester ID: ...
Requested book: ...
Offered book: ...
Generated swap ID: ...
Swap offer model created, saving to Firestore...
Swap offer data: {...}
```

**If you see:**

- ✅ `✅ Swap offer saved successfully!` - It worked! Check Firebase Console again
- ❌ `❌ Create swap offer error: ...` - There's an error (read the message)
- 🔒 `permission-denied` - Security rules need updating
- 📚 `Book not found` - The book query is failing

### Step 4: Check Specific Errors

#### Error: "permission-denied"

```
❌ Create swap offer error: [cloud_firestore/permission-denied]
Missing or insufficient permissions.
```

**Fix:** Update Firestore security rules in Firebase Console.

Go to: https://console.firebase.google.com/project/bookswap-97c8e/firestore/rules

Make sure you have these rules:

```
match /swap_offers/{swapId} {
  allow read: if isAuthenticated() &&
              (resource.data.requesterId == request.auth.uid ||
               resource.data.ownerId == request.auth.uid);
  allow create: if isAuthenticated() &&
                request.resource.data.requesterId == request.auth.uid;
  allow update: if isAuthenticated() &&
                (resource.data.requesterId == request.auth.uid ||
                 resource.data.ownerId == request.auth.uid);
  allow delete: if isAuthenticated() &&
                resource.data.requesterId == request.auth.uid;
}
```

#### Error: "Book not found"

```
❌ Create swap offer error: Exception: Book not found
Requested book: null
Offered book: null
```

**Fix:** The getBookById method is failing. Check:

1. Are you logged in?
2. Do the books exist in Firestore?
3. Are the security rules allowing book reads?

#### Error: Network issue

```
❌ Create swap offer error: [cloud_firestore/unavailable]
The service is currently unavailable.
```

**Fix:**

1. Check internet connection
2. Check Firebase Console status
3. Restart the app

### Step 5: Verify in Firebase Console

After seeing `✅ Swap offer saved successfully!` in the console:

1. Go to: https://console.firebase.google.com/project/bookswap-97c8e/firestore/data
2. Refresh the page (F5)
3. Look for `swap_offers` collection on the left sidebar
4. Click it to see the documents

**If still not there:**

- Wait 5-10 seconds and refresh again
- Check you're looking at the right project
- Check the Data tab (not Rules or Indexes)

## Quick Test

Run this test to confirm Firebase connection:

1. Create a book (should work if books collection exists)
2. Check if the book appears in Firebase Console → books collection
3. If books work but swap offers don't, it's definitely a security rules issue

## Expected Console Output (Success)

```
I/flutter: === Creating swap offer ===
I/flutter: Requested book ID: 2cdd0766-e515-4345-8997-9c604143a164
I/flutter: Offered book ID: abc123-xyz789
I/flutter: Requester ID: 3ludZVefrGcstcNrAemOiYVGzqC2
I/flutter: Requested book: Data Structures 2
I/flutter: Offered book: Nike
I/flutter: Generated swap ID: f4d2c1b0-a9e8-7f6d-5c4b-3a2b1c0d9e8f
I/flutter: Swap offer model created, saving to Firestore...
I/flutter: Swap offer data: {id: f4d2c1b0..., requestedBookId: 2cdd0766..., ...}
I/flutter: ✅ Swap offer saved successfully!
I/flutter: Marking books as unavailable...
I/flutter: ✅ Books marked as unavailable
```

## Most Common Fix

**90% of the time, this issue is caused by Firestore security rules blocking the write.**

1. Go to Firebase Console → Firestore → Rules
2. Copy the rules from `firestore.rules` file
3. Paste and Publish
4. Try again

The swap offers should start appearing in the database immediately!
