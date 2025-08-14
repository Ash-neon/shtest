import 'dart:convert';
import 'package:http/http.dart' as http;

class LlmService {
  // Backend endpoint or direct LLM provider endpoint.
  // Prefer calling a Cloud Function that proxies your provider key securely.
  static Future<String> weeklySummary(String parentId, String childId, int minutes) async {
    final prompt = 'Summarize weekly usage for child $childId: minutes=$minutes. Provide 2 recommendations.';
    // Example: call your Cloud Function / summary endpoint
    // final resp = await http.post(Uri.parse('https://your-cloud-function/summarize'),
    //   headers: {'Content-Type':'application/json'},
    //   body: jsonEncode({'prompt': prompt, 'parentId': parentId, 'childId': childId}));
    // if (resp.statusCode == 200) return jsonDecode(resp.body)['summary'];
    // Fallback demo response:
    return 'Weekly usage: $minutes min. 1) Set consistent evening cut-off. 2) Encourage earning time via learning games.';
  }
}
