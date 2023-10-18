class VisibilityModel {
  const VisibilityModel({
    required this.fact,
    required this.appearanceTime,
    required this.visibleDuration,
  });
  final String fact;
  final DateTime appearanceTime;
  final int visibleDuration;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fact': fact,
      'appearanceTime': appearanceTime.toIso8601String(),
      'visibleDuration': visibleDuration,
    };
  }
}
