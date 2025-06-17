/// Represents analytics data derived from wellness entries.
/// 
/// This model contains computed insights and statistics about the user's
/// wellness patterns, SVT episodes, exercise habits, and medication adherence.
/// 
/// **AI-Friendly**: Clear data structure for pattern analysis
/// **Student-Friendly**: Well-documented metrics with practical meaning
/// **Test-Friendly**: Immutable design with comprehensive validation
class AnalyticsData {
  /// Date range for this analytics period
  final DateTime startDate;
  final DateTime endDate;
  
  /// SVT Episode Statistics
  final int totalSvtEpisodes;
  final double averageEpisodeDuration; // in minutes
  final int episodesThisWeek;
  final int episodesThisMonth;
  
  /// Exercise Statistics
  final int totalExerciseSessions;
  final double averageExerciseDuration; // in minutes
  final int exerciseSessionsThisWeek;
  final int exerciseSessionsThisMonth;
  
  /// Medication Statistics
  final int totalMedicationTaken;
  final int medicationTakenThisWeek;
  final int medicationTakenThisMonth;
  final double adherenceRate; // percentage (0.0 to 1.0)
  
  /// Pattern Insights
  final Map<String, int> svtTriggerPatterns; // e.g., {"after_exercise": 3, "during_stress": 5}
  final Map<String, int> exerciseTypeFrequency; // derived from comments
  final List<String> insights; // AI-generated or rule-based insights
  
  /// Data Quality Metrics
  final int totalEntries;
  final double dataCompleteness; // percentage (0.0 to 1.0)
  final DateTime lastUpdated;
  
  /// Creates analytics data for a specific time period.
  const AnalyticsData({
    required this.startDate,
    required this.endDate,
    required this.totalSvtEpisodes,
    required this.averageEpisodeDuration,
    required this.episodesThisWeek,
    required this.episodesThisMonth,
    required this.totalExerciseSessions,
    required this.averageExerciseDuration,
    required this.exerciseSessionsThisWeek,
    required this.exerciseSessionsThisMonth,
    required this.totalMedicationTaken,
    required this.medicationTakenThisWeek,
    required this.medicationTakenThisMonth,
    required this.adherenceRate,
    required this.svtTriggerPatterns,
    required this.exerciseTypeFrequency,
    required this.insights,
    required this.totalEntries,
    required this.dataCompleteness,
    required this.lastUpdated,
  });
  
  /// Creates empty analytics data (useful for initial state)
  factory AnalyticsData.empty() {
    final now = DateTime.now();
    return AnalyticsData(
      startDate: now,
      endDate: now,
      totalSvtEpisodes: 0,
      averageEpisodeDuration: 0.0,
      episodesThisWeek: 0,
      episodesThisMonth: 0,
      totalExerciseSessions: 0,
      averageExerciseDuration: 0.0,
      exerciseSessionsThisWeek: 0,
      exerciseSessionsThisMonth: 0,
      totalMedicationTaken: 0,
      medicationTakenThisWeek: 0,
      medicationTakenThisMonth: 0,
      adherenceRate: 0.0,
      svtTriggerPatterns: {},
      exerciseTypeFrequency: {},
      insights: [],
      totalEntries: 0,
      dataCompleteness: 0.0,
      lastUpdated: now,
    );
  }
  
  /// Validates that this analytics data is reasonable
  bool isValid() {
    return startDate.isBefore(endDate) &&
           totalSvtEpisodes >= 0 &&
           averageEpisodeDuration >= 0 &&
           episodesThisWeek >= 0 &&
           episodesThisMonth >= 0 &&
           totalExerciseSessions >= 0 &&
           averageExerciseDuration >= 0 &&
           exerciseSessionsThisWeek >= 0 &&
           exerciseSessionsThisMonth >= 0 &&
           totalMedicationTaken >= 0 &&
           medicationTakenThisWeek >= 0 &&
           medicationTakenThisMonth >= 0 &&
           adherenceRate >= 0.0 && adherenceRate <= 1.0 &&
           totalEntries >= 0 &&
           dataCompleteness >= 0.0 && dataCompleteness <= 1.0;
  }
  
  /// Creates a copy with optional field updates
  AnalyticsData copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? totalSvtEpisodes,
    double? averageEpisodeDuration,
    int? episodesThisWeek,
    int? episodesThisMonth,
    int? totalExerciseSessions,
    double? averageExerciseDuration,
    int? exerciseSessionsThisWeek,
    int? exerciseSessionsThisMonth,
    int? totalMedicationTaken,
    int? medicationTakenThisWeek,
    int? medicationTakenThisMonth,
    double? adherenceRate,
    Map<String, int>? svtTriggerPatterns,
    Map<String, int>? exerciseTypeFrequency,
    List<String>? insights,
    int? totalEntries,
    double? dataCompleteness,
    DateTime? lastUpdated,
  }) {
    return AnalyticsData(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSvtEpisodes: totalSvtEpisodes ?? this.totalSvtEpisodes,
      averageEpisodeDuration: averageEpisodeDuration ?? this.averageEpisodeDuration,
      episodesThisWeek: episodesThisWeek ?? this.episodesThisWeek,
      episodesThisMonth: episodesThisMonth ?? this.episodesThisMonth,
      totalExerciseSessions: totalExerciseSessions ?? this.totalExerciseSessions,
      averageExerciseDuration: averageExerciseDuration ?? this.averageExerciseDuration,
      exerciseSessionsThisWeek: exerciseSessionsThisWeek ?? this.exerciseSessionsThisWeek,
      exerciseSessionsThisMonth: exerciseSessionsThisMonth ?? this.exerciseSessionsThisMonth,
      totalMedicationTaken: totalMedicationTaken ?? this.totalMedicationTaken,
      medicationTakenThisWeek: medicationTakenThisWeek ?? this.medicationTakenThisWeek,
      medicationTakenThisMonth: medicationTakenThisMonth ?? this.medicationTakenThisMonth,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      svtTriggerPatterns: svtTriggerPatterns ?? this.svtTriggerPatterns,
      exerciseTypeFrequency: exerciseTypeFrequency ?? this.exerciseTypeFrequency,
      insights: insights ?? this.insights,
      totalEntries: totalEntries ?? this.totalEntries,
      dataCompleteness: dataCompleteness ?? this.dataCompleteness,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  /// Converts to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalSvtEpisodes': totalSvtEpisodes,
      'averageEpisodeDuration': averageEpisodeDuration,
      'episodesThisWeek': episodesThisWeek,
      'episodesThisMonth': episodesThisMonth,
      'totalExerciseSessions': totalExerciseSessions,
      'averageExerciseDuration': averageExerciseDuration,
      'exerciseSessionsThisWeek': exerciseSessionsThisWeek,
      'exerciseSessionsThisMonth': exerciseSessionsThisMonth,
      'totalMedicationTaken': totalMedicationTaken,
      'medicationTakenThisWeek': medicationTakenThisWeek,
      'medicationTakenThisMonth': medicationTakenThisMonth,
      'adherenceRate': adherenceRate,
      'svtTriggerPatterns': svtTriggerPatterns,
      'exerciseTypeFrequency': exerciseTypeFrequency,
      'insights': insights,
      'totalEntries': totalEntries,
      'dataCompleteness': dataCompleteness,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  /// Creates analytics data from JSON
  static AnalyticsData fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalSvtEpisodes: json['totalSvtEpisodes'] as int,
      averageEpisodeDuration: (json['averageEpisodeDuration'] as num).toDouble(),
      episodesThisWeek: json['episodesThisWeek'] as int,
      episodesThisMonth: json['episodesThisMonth'] as int,
      totalExerciseSessions: json['totalExerciseSessions'] as int,
      averageExerciseDuration: (json['averageExerciseDuration'] as num).toDouble(),
      exerciseSessionsThisWeek: json['exerciseSessionsThisWeek'] as int,
      exerciseSessionsThisMonth: json['exerciseSessionsThisMonth'] as int,
      totalMedicationTaken: json['totalMedicationTaken'] as int,
      medicationTakenThisWeek: json['medicationTakenThisWeek'] as int,
      medicationTakenThisMonth: json['medicationTakenThisMonth'] as int,
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      svtTriggerPatterns: Map<String, int>.from(json['svtTriggerPatterns'] as Map),
      exerciseTypeFrequency: Map<String, int>.from(json['exerciseTypeFrequency'] as Map),
      insights: List<String>.from(json['insights'] as List),
      totalEntries: json['totalEntries'] as int,
      dataCompleteness: (json['dataCompleteness'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AnalyticsData &&
           other.startDate == startDate &&
           other.endDate == endDate &&
           other.totalSvtEpisodes == totalSvtEpisodes &&
           other.averageEpisodeDuration == averageEpisodeDuration &&
           other.totalEntries == totalEntries &&
           other.lastUpdated == lastUpdated;
  }
  
  @override
  int get hashCode {
    return startDate.hashCode ^
           endDate.hashCode ^
           totalSvtEpisodes.hashCode ^
           averageEpisodeDuration.hashCode ^
           totalEntries.hashCode ^
           lastUpdated.hashCode;
  }
  
  @override
  String toString() {
    return 'AnalyticsData(range: $startDate to $endDate, entries: $totalEntries, svt: $totalSvtEpisodes, exercise: $totalExerciseSessions, medication: $totalMedicationTaken)';
  }
}
