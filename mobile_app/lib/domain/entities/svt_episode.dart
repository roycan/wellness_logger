import '../entities/wellness_entry.dart';
import '../../core/constants/app_constants.dart';

/// Represents an SVT (Supraventricular Tachycardia) episode entry.
/// 
/// SVT episodes are characterized by rapid heart rate events that can be
/// tracked with duration and detailed symptoms or triggers.
/// 
/// **AI-Friendly**: Clear validation rules and immutable design
/// **Student-Friendly**: Medical terminology explained with examples
/// **Test-Friendly**: Comprehensive validation and factory methods
class SvtEpisode extends WellnessEntry {
  /// Duration of the SVT episode (e.g., "3 minutes", "30 seconds")
  final String? duration;
  
  /// Creates a new SVT episode entry.
  /// 
  /// [duration] should follow the format validated by AppConstants.durationRegex
  /// Examples: "3 minutes", "30 seconds", "1 hour 15 minutes"
  const SvtEpisode({
    required super.id,
    required super.timestamp,
    super.comments,
    this.duration,
  }) : super(type: AppConstants.entryTypeSVT);
  
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
  SvtEpisode copyWith({
    String? id,
    String? type, // Ignored - SVT episodes always have type 'SVT Episode'
    DateTime? timestamp,
    String? comments,
    String? duration,
  }) {
    return SvtEpisode(
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
  
  /// Creates an SVT episode from JSON data.
  /// 
  /// Supports both the new JSON format and legacy CSV-style data.
  /// Handles missing fields gracefully with null values.
  static SvtEpisode fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    
    return SvtEpisode(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      comments: details['comments'] as String? ?? json['comments'] as String?,
      duration: details['duration'] as String? ?? json['duration'] as String?,
    );
  }
  
  /// Creates an SVT episode from CSV row data.
  /// 
  /// Expected format: Date,Time,Type,Duration,Dosage,Comments
  /// Where Type should be 'SVT Episode' and Dosage should be empty.
  static SvtEpisode fromCsv({
    required String id,
    required DateTime timestamp,
    String? duration,
    String? comments,
  }) {
    return SvtEpisode(
      id: id,
      timestamp: timestamp,
      duration: duration,
      comments: comments,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SvtEpisode &&
           super == other &&
           other.duration == duration;
  }
  
  @override
  int get hashCode {
    return super.hashCode ^ duration.hashCode;
  }
  
  @override
  String toString() {
    return 'SvtEpisode(id: $id, timestamp: $timestamp, duration: $duration, comments: $comments)';
  }
}
