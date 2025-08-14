// Stub for COPPA-compliant ad integration.
// Replace with SuperAwesome or other SDK and call onReward() when ad completes.
typedef RewardCallback = void Function(int points);

class AdsService {
  static Future<void> showRewardAd(RewardCallback onReward) async {
    // TODO: integrate real SDK and get parental approval if required by policy.
    await Future.delayed(const Duration(seconds: 1));
    onReward(5); // grant +5 points as demo
  }
}
