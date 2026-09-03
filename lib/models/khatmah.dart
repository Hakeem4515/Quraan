enum KhatmahStatus {
  inProgress,
  completed,
}

class Khatmah {
  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int currentPage;
  final double progress; // 0.0 to 100.0
  final KhatmahStatus status;
  final DateTime lastUpdatedAt;

  Khatmah({
    required this.id,
    required this.startedAt,
    this.completedAt,
    required int currentPage,
    required this.status,
    required this.lastUpdatedAt,
  })  : currentPage = currentPage.clamp(1, 604),
        progress = ((currentPage.clamp(1, 604) / 604.0) * 100.0).clamp(0.0, 100.0);

  bool get isCompleted => status == KhatmahStatus.completed || currentPage >= 604;

  Khatmah copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentPage,
    KhatmahStatus? status,
    DateTime? lastUpdatedAt,
  }) {
    final int newPage = (currentPage ?? this.currentPage).clamp(1, 604);
    final KhatmahStatus newStatus = status ?? (newPage >= 604 ? KhatmahStatus.completed : this.status);
    final DateTime? newCompletedAt = newStatus == KhatmahStatus.completed
        ? (completedAt ?? this.completedAt ?? DateTime.now())
        : null;

    return Khatmah(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: newCompletedAt,
      currentPage: newPage,
      status: newStatus,
      lastUpdatedAt: lastUpdatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentPage': currentPage.clamp(1, 604),
      'progress': progress,
      'status': status == KhatmahStatus.completed ? 'completed' : 'inProgress',
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  factory Khatmah.fromJson(Map<String, dynamic> json) {
    final int page = ((json['currentPage'] as num?)?.toInt() ?? 1).clamp(1, 604);
    final String statusStr = (json['status'] as String?) ?? 'inProgress';
    final KhatmahStatus status = (statusStr == 'completed' || page >= 604)
        ? KhatmahStatus.completed
        : KhatmahStatus.inProgress;

    return Khatmah(
      id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : (status == KhatmahStatus.completed ? DateTime.now() : null),
      currentPage: page,
      status: status,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
