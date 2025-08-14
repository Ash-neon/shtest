import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildrenProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  String? parentId;
  List<Map<String, dynamic>> children = []; // [{id, status, remaining_minutes}]

  void attach(String parentUid) {
    parentId = parentUid;
    _db.collection('users').doc(parentUid).snapshots().listen((parentSnap) async {
      final data = parentSnap.data();
      if (data == null) return;
      final List<dynamic> ids = (data['children'] ?? []);
      if (ids.isEmpty) { children = []; notifyListeners(); return; }
      final snaps = await _db.collection('users').where(FieldPath.documentId, whereIn: ids).get();
      children = snaps.docs.map((d)=>{'id': d.id, ...d.data()}).toList();
      notifyListeners();
    });
  }

  Future<void> toggleLock(String childId, String current) async {
    final next = current == 'locked' ? 'unlocked' : 'locked';
    await _db.collection('users').doc(childId).set({'status': next}, SetOptions(merge: true));
  }

  Future<void> addChildByLinkCode(String code) async {
    if (parentId == null) return;
    final doc = await _db.collection('linkCodes').doc(code).get();
    if (!doc.exists) throw Exception('Invalid code');
    final pid = doc.data()!['parent_id'];
    if (pid != parentId) throw Exception('Code belongs to another parent');
    // here, the child must have entered the code in their app first to set parent_id
    // This method is optional; primary linking is from child app.
  }
}
