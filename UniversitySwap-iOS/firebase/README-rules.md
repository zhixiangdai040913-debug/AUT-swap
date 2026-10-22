# UniversitySwap — proposed Firebase security rules

**Status:** Proposed only. Not deployed. Not claimed secure until tested.

Files:
- `firestore.rules`
- `storage.rules`

## How to test (do not skip)

### A. Firebase Console Rules Playground

1. Firebase Console → project **aut-swap** → **Firestore** → **Rules**
2. Paste `firestore.rules` into the editor (**Do not click Publish** yet)
3. Open **Rules playground**
4. Run cases below (Auth UID = `userA` / `userB`)

| Simulation | Location | Auth | Expect |
|------------|----------|------|--------|
| get | `/users/userA` | `userA` | Allow |
| get | `/users/userA` | `userB` | Deny |
| get | `/users/userA` | unauthenticated | Deny |
| create | `/listings/L1` with `sellerUserId=userA`, valid fields | `userA` | Allow |
| create | `/listings/L1` with `sellerUserId=userA` | `userB` | Deny |
| create | `/listings/L1` missing `title` | `userA` | Deny |
| update | `/listings/L1` change title | owner `userA` | Allow |
| update | `/listings/L1` change `sellerUserId` | owner | Deny |
| delete | `/listings/L1` | non-owner | Deny |

5. **Storage** → **Rules** → paste `storage.rules` → Playground:
   - write `listings/userA/L1/0.jpg` as `userA`, contentType `image/jpeg`, size 100KB → Allow
   - same path as `userB` → Deny
   - `listings/userA/L1/evil.exe` → Deny
   - size `6MB` → Deny

### B. Firebase Emulator Suite (recommended before production)

```bash
# From a folder with firebase.json pointing at these rule files
firebase emulators:start --only firestore,storage,auth
firebase emulators:exec --only firestore,storage "npm test"
```

Use `@firebase/rules-unit-testing` to automate the table above.  
Emulator results are what you should trust before Publish.

## Deploy later (manual only)

```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

Or paste into Console and click **Publish** after playground/emulator passes.

## App alignment notes

1. Client writes `createdAt` / `updatedAt` via `FieldValue.serverTimestamp()`. Rules compare to `request.time` — this is the supported pattern for server timestamps.
2. If create fails with PERMISSION_DENIED after deploy, confirm the iOS payload keys match `validListingCreate()` (especially `listingType`: `free` \| `swap` \| `sale`).
3. Phase 1 (`AppConfig.useSampleData = true`) does not hit Firestore/Storage; rules only matter when sample mode is off.
4. `users` reads are owner-only so emails stay private; seller display uses listing denormalized fields (`sellerName`, etc.).
