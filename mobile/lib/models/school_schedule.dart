class SchoolSchedule {
  final bool enabled;
  final Map<String, List<Map<String, int>>> days; 
  // Example: { 'Mon': [{'startHour':8,'startMin':0,'endHour':15,'endMin':0}] }

  SchoolSchedule({required this.enabled, required this.days});

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'days': days,
  };

  static SchoolSchedule fromJson(Map<String, dynamic> j) => SchoolSchedule(
    enabled: (j['enabled'] ?? false) as bool,
    days: Map<String, List<dynamic>>.from(j['days'] ?? {}).map((k, v) => MapEntry(k, List<Map<String,int>>.from(v.map((e)=>Map<String,int>.from(e))))),
  );
}
