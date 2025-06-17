import '../entities/wellness_entry.dart';
import '../../core/constants/app_constants.dart';

/// Represents an exercise/physical activity entry.
/// 
/// Exercise entries track physical activities that may be relevant to
/// SVT management, including duration and activity descriptions.
/// 
/// **AI-Friendly**: Clear validation rules and immutable design
/// **Student-Friendly**: Simple structure with practical examples
/// **Test-Friendly**: Comprehensive validation and factory methods
class Exercise extends WellnessEntry {
  /// Duration of the exercise session (e.g., "30 minutes", "1 hour")
  final String? duration;
  
  /// Creates a new exercise entry.
  /// 
  /// [duration] should follow the format validated by AppConstants.durationRegex
  /// Examples: "30 minutes", "1 hour", "45 minutes"
  const Exercise({
    required super.id,
    required super.timestamp,
    super.comments,
    this.duration,
  }) : super(type: AppConstants.entryTypeExercise);
  
  @override
  bool isValid() {
    if (!super.isValid()) return false;
    
    // Duration is optional, but if provided must be valid format
    if (duration != null && duration!.isNotEmpty) {
      return AppRegex.duration.hasMatch(duration!);
    }
    
    return true;
  }
  
  @override
  Exercise copyWith({
    String? id,
    String? type, // Ignored - Exercise entries always have type 'Exercise'
    DateTime? timestamp,
    String? comments,
    String? duration,
  }) {
    return Exercise(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      comments: comments ?? this.comments,
      duration: duration ?? this.duration,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'details': {
        if (duration != null && duration!.isNotEmpty) 'duration': duration,
        if (comments != null && comments!.isNotEmpty) 'comments': comments,
      },
    };
  }
  
  /// Creates an exercise entry from JSON data.
  /// 
  /// Supports both the new JSON format and legacy CSV-style data.
  /// Handles missing fields gracefully with null values.
  static Exercise fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    
    return Exercise(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      comments: details['comments'] as String? ?? json['comments'] as String?,
      duration: details['duration'] as String? ?? json['duration'] as String?,
    );
  }
  
  /// Creates an exercise entry from CSV row data.
  /// 
  /// Expected format: Date,Time,Type,Duration,Dosage,Comments
  /// Where Type should be 'Exercise' and Dosage should be empty.
  static Exercise fromCsv({
    required String id,
    required DateTime timestamp,
    String? duration,
    String? comments,
  }) {
    return Exercise(
      id: id,
      timestamp: timestamp,
      duration: duration,
      comments: comments,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Exercise &&
           super == other &&
           other.duration == duration;
  }
  
  @override
  int get hashCode {
    return super.hashCode ^ duration.hashCode;
  }
  
  @override
  String toString() {
    return 'Exercise(id: $id, timestamp: $timestamp, duration: $duration, comments: $comments)';
  }
}
