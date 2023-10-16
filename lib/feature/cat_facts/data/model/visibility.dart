class VisibilityModel {
  final String fact;
  final DateTime appearanceTime;
  final int visibleDuration;

  VisibilityModel({
    required this.fact,
    required this.appearanceTime,
    required this.visibleDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'fact': fact,
      'appearanceTime': appearanceTime.toIso8601String(),
      'visibleDuration': visibleDuration,
    };
  }
}
