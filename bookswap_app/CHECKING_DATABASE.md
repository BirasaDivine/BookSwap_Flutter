# How to Check Swap Offers in Firebase Console

## Your swap offers ARE being saved!

Looking at your screenshot, you have 3 swap offers showing:

1. Nike ↔️ Data Structures (From: Edwin Bayingana)
2. Yesu ni mwiza ↔️ Data Structures (From: Edwin Bayingana)
3. Yesu ni mwiza ↔️ Data Structures (From: Edwin Bayingana)

This proves the swap offers are in the database!

## How to View Them in Firebase Console

### Step 1: Go to Firestore Database

```
https://console.firebase.google.com/project/bookswap-97c8e/firestore/data
```

### Step 2: Look for Collections

You should see these collections on the left:

- ✅ `users`
- ✅ `books`
- ✅ `swap_offers` ← **Click this one!**
- ✅ `chat_rooms`

### Step 3: View Swap Offers

Click on `swap_offers` collection and you'll see documents like:

```
swap_offers/
  ├─ abc123-def456... (document ID)
  │   ├─ id: "abc123-def456..."
  │   ├─ requestedBookId: "xyz789..."
  │   ├─ requestedBookTitle: "Data Structures"
  │   ├─ offeredBookId: "book456..."
  │   ├─ offeredBookTitle: "Nike"
  │   ├─ requesterId: "edwin_user_id"
  │   ├─ requesterName: "Edwin Bayingana"
  │   ├─ ownerId: "your_user_id"
  │   ├─ ownerName: "Your Name"
  │   ├─ status: "Pending"
  │   ├─ createdAt: timestamp
  │   └─ message: null
```

## Troubleshooting: If You Don't See swap_offers Collection

### Possible Reasons:

1. **Wrong Project** - Make sure you're looking at project `bookswap-97c8e`

2. **No Data Tab** - Click "Data" tab (not "Rules" or "Indexes" tab)

3. **Collapsed Collection** - The collection might be collapsed, look for a small arrow (▶) next to "swap_offers"

4. **Filtering Applied** - Remove any filters at the top

5. **Security Rules Blocking Console** - Your security rules are correct, but if you changed them, make sure they allow reads

## What Each Swap Offer Means

From your screenshot:

- **"Received Offer"** = You own the book being requested
- **"Nike"** = Book being offered to you
- **"Data Structures"** = Your book being requested
- **"From: Edwin Bayingana"** = Person who wants to swap

## The swap offers ARE in the database!

The app is reading them from Firestore and displaying them correctly. If you're not seeing them in Firebase Console, it's just a navigation issue, not a data issue.

## To Verify Data Exists:

Run this command in your terminal:

```powershell
cd bookswap_app
flutter run
```

Then check the console output - you should see Firestore queries being executed.

Or check your app - if you see the swap offers in "My Listings" → "Swap Offers" tab, they're definitely in the database! 🎉
