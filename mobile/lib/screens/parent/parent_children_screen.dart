import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';

class ParentChildrenScreen extends StatelessWidget {
  const ParentChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final children = context.watch<ChildrenProvider>();
    if (auth.userId != null) {
      context.read<ChildrenProvider>().attach(auth.userId!);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Children')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children:[
              FilledButton(
                onPressed: () async {
                  // Create a new link code the parent can share for additional kids
                  final db = FirebaseFirestore.instance;
                  final code = (auth.userId ?? 'XXXXXX').substring(0,6) + DateTime.now().millisecondsSinceEpoch.toString().substring(8,12);
                  await db.collection('linkCodes').doc(code).set({'parent_id': auth.userId});
                  showDialog(context: context, builder: (_)=>AlertDialog(
                    title: const Text('New Link Code'),
                    content: SelectableText(code),
                    actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Close'))],
                  ));
                },
                child: const Text('Generate Link Code'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/schoolMode');
                },
                child: const Text('School Mode'),
              ),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: children.children.length,
                separatorBuilder: (_, __)=>const Divider(),
                itemBuilder: (context, i) {
                  final c = children.children[i];
                  final id = c['id'];
                  final status = c['status'] ?? 'unlocked';
                  final remaining = c['remaining_minutes'] ?? 0;
                  return ListTile(
                    title: Text('Child: $id'),
                    subtitle: Text('Status: $status • Remaining: $remaining min'),
                    trailing: FilledButton(
                      onPressed: () => children.toggleLock(id, status),
                      child: const Text('Toggle Lock'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
