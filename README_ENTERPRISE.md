# SafeHaven Enterprise Pack

This pack upgrades your Firebase app to include:
- Multi-child parent dashboard
- School Mode (time-based device locks by day)
- Rewards screen + points system
- Ad rewards stub (replace with COPPA-compliant SDK)
- LLM weekly summaries via Cloud Functions with environment-based keys
- Providers for Children and School Mode
- Services for Ads and LLM
- Stubs for Play Integrity/App Check remain (configure in Firebase Console)

## Integrate

1) Merge `/mobile/lib/` into your existing Firebase app's `lib/` folder.
   - Add providers in `main.dart`:
```dart
ChangeNotifierProvider(create: (_) => ChildrenProvider()),
ChangeNotifierProvider(create: (_) => SchoolModeProvider()),
ChangeNotifierProvider(create: (_) => RewardsProvider()), // from Pro pack
```
   - Add routes:
```dart
routes: {
  '/children': (_) => const ParentChildrenScreen(),
  '/schoolMode': (_) => const SchoolModeScreen(),
  '/rewards': (_) => const RewardsScreen(), // from Pro pack
},
```

2) Update **Parent** UI to navigate to `/children` (or set as default parent screen).

3) Firestore structure changes:
- Parent doc: `children: [childId1, childId2, ...]`
- Child doc: `parent_id: <parentUid>`, `status`, `remaining_minutes`, `points`
- School schedules: `schoolSchedules/{parentUid}: { enabled: bool, days: { Mon: [ {startHour, startMin, endHour, endMin} ] } }`

4) Enforce School Mode on child devices:
- On ChildDashboard, subscribe to parent schedule (you can store a copy on the child's doc for faster access) and, when the current time falls in a lock interval **and** school mode enabled, force status to `locked`.
- For strong enforcement, pair with Android pinned mode or DPC, or iOS Guided Access.

5) Cloud Functions (LLM):
```bash
cd cloud_functions
npm install
# Set env:
firebase functions:config:set llm.key="YOUR_KEY" llm.endpoint="YOUR_ENDPOINT"
# Or set environment variables in your hosting (for gen2 functions use console secrets)
firebase deploy --only functions
```
If you use env vars, ensure your runtime can access `process.env.LLM_API_KEY` and `LLM_ENDPOINT`.

6) Reward Ads:
- Replace `AdsService.showRewardAd` with real SDK implementation, then grant points on completion.
- Keep parental controls and consent in place to meet COPPA and Play policy.

7) Localization:
- Add `flutter_localizations`, `intl`, and configure `flutter gen-l10n`.
- Replace strings with localized values from ARB files.

8) Play Integrity + App Check:
- Firebase Console → App Check → enable for Android/iOS.
- Add SHA-256 fingerprints for Android and configure Play Integrity provider.
- Replace the placeholder in your `SecurityService.initAppCheck()` with the correct provider setup.

## Testing
- Use multiple child test accounts and add their UIDs to a parent's `children` array.
- Verify School Mode locking at expected times.
- Trigger the weekly summary function manually from Firebase console to see reports created.
