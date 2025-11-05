# Fixing Swap and Chat Permissions

## Problem

The app is showing "Failed to create swap offer" and chat functionality is not working because of **Firestore Security Rules** - Firebase is blocking the operations due to missing permissions.

## Error in Logs

```
Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
```

## Solution: Update Firestore Security Rules

### Step 1: Go to Firebase Console

1. Open your browser and go to: https://console.firebase.google.com
2. Select your project: **bookswap-97c8e**
3. Click on **Firestore Database** in the left sidebar
4. Click on the **Rules** tab at the top

### Step 2: Replace the Security Rules

Copy the entire content from `firestore.rules` file in your project root and paste it into the Firebase Console rules editor.

**The new rules allow:**

- ✅ Authenticated users to read all books
- ✅ Users to create/update/delete their own books
- ✅ Users to create swap offers (as requester)
- ✅ Users to read swap offers where they are involved
- ✅ Users to update swap offers (accept/reject)
- ✅ Users to create and participate in chats
- ✅ Users to send messages in their chat rooms

### Step 3: Publish the Rules

1. After pasting the rules, click the **Publish** button
2. Wait a few seconds for the rules to deploy

### Step 4: Test the App

1. Restart your app (hot restart won't work for this)
2. Try creating a swap offer again
3. Try chatting with a user

## What Changed

### Before:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;  // ❌ Everything blocked!
    }
  }
}
```

### After:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Proper rules for each collection
    match /users/{userId} { ... }
    match /books/{bookId} { ... }
    match /swap_offers/{swapId} { ... }
    match /chat_rooms/{chatRoomId} { ... }
  }
}
```

## Improved Error Messages

I've also updated the swap provider to show more specific error messages:

- "Permission denied. Please check Firebase security rules."
- "Book not found. Please try again."
- Detailed error for debugging

## Security Notes

The rules ensure:

- 🔒 Users can only modify their own data
- 🔒 Users can only read swap offers and chats they're involved in
- 🔒 Chat messages are immutable (can't be edited or deleted)
- 🔒 All operations require authentication

## If Still Not Working

1. Make sure you published the rules in Firebase Console
2. Check the Flutter console for any error messages
3. Try logging out and logging back in
4. Make sure your indexes are created (check Firestore Console > Indexes tab)
