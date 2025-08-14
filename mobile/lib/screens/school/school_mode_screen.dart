import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_mode_provider.dart';
import '../../providers/auth_provider.dart';

class SchoolModeScreen extends StatefulWidget {
  const SchoolModeScreen({super.key});

  @override
  State<SchoolModeScreen> createState() => _SchoolModeScreenState();
}

class _SchoolModeScreenState extends State<SchoolModeScreen> {
  final Map<String, List<Map<String, int>>> days = {
    'Mon': [], 'Tue': [], 'Wed': [], 'Thu': [], 'Fri': [], 'Sat': [], 'Sun': []
  };
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sm = context.watch<SchoolModeProvider>();
    if (auth.userId != null) {
      context.read<SchoolModeProvider>().attach(auth.userId!);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('School Mode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: sm.schedule['enabled'] ?? false,
              onChanged: (v) => setState(()=> enabled = v),
              title: const Text('Enable School Mode (lock during class)'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: days.keys.map((d) => _dayEditor(d)).toList(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final payload = {
                  'enabled': enabled,
                  'days': days,
                };
                await context.read<SchoolModeProvider>().save(payload);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  Widget _dayEditor(String day) {
    final list = days[day]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...list.map((r) => Row(
              children: [
                Text('From ${r['startHour']}:${r['startMin']?.toString().padLeft(2,'0')} '
                     'to ${r['endHour']}:${r['endMin']?.toString().padLeft(2,'0')}'),
              ],
            )),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final now = TimeOfDay.now();
                final start = await showTimePicker(context: context, initialTime: now);
                if (start == null) return;
                final end = await showTimePicker(context: context, initialTime: now.replacing(hour: (now.hour+1)%24));
                if (end == null) return;
                setState(() {
                  list.add({
                    'startHour': start.hour, 'startMin': start.minute,
                    'endHour': end.hour, 'endMin': end.minute,
                  });
                });
              },
              child: const Text('Add Lock Interval'),
            )
          ],
        ),
      ),
    );
  }
}
