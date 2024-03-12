class Record {
  final int id;
  final String content;
  final DateTime createdAt;
  final int copyTimes;

  Record({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.copyTimes,
  });

  factory Record.fromMap(Map<String, dynamic> json) {
    return Record(
      id: json['id']?.toInt() ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      copyTimes: json['copy_times']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'copy_times': copyTimes,
    };
  }
}
