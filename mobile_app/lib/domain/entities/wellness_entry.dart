// Import specific entry types for the factory method
import 'svt_episode.dart';
import 'exercise.dart';
import 'medication.dart';

/// Base entity for all wellness entries in the system.
/// 
/// This abstract class defines the common structure and behavior for all types
/// of wellness entries (SVT episodes, exercise sessions, medication intake).
/// Implements proper serialization and validation according to domain rules.
/// 
/// **AI-Friendly**: Clear inheritance hierarchy with explicit contracts
/// **Student-Friendly**: Well-documented with examples and clear purpose
/// **Test-Friendly**: Immutable design with factory constructors and validation
abstract class WellnessEntry {
  /// Unique identifier for this entry
  final String id;
  
  /// Type of wellness entry (SVT, Exercise, Medication)
  final String type;
  
  /// When this entry was created/occurred
  final DateTime timestamp;
  
  /// Optional user comments about this entry
  final String? comments;
  
  /// Creates a new wellness entry.
  /// 
  /// [id] must be unique across all entries
  /// [type] must be one of the valid entry types from AppConstants
  /// [timestamp] represents when the entry occurred (not when it was created)
  /// [comments] are optional user notes
  const WellnessEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    this.comments,
  });
  
  /// Validates that this entry meets basic requirements
  /// 
  /// Returns true if valid, false otherwise.
  /// Subclasses should override to add specific validation.
  bool isValid() {
    return id.isNotEmpty && 
           type.isNotEmpty && 
           timestamp.isBefore(DateTime.now().add(const Duration(hours: 1)));
  }
  
  /// Creates a copy of this entry with optional field updates
  WellnessEntry copyWith({
    String? id,
    String? type,
    DateTime? timestamp,
    String? comments,
  });
  
  /// Converts this entry to a JSON map for serialization
  Map<String, dynamic> toJson();
  
  /// Creates a WellnessEntry from JSON data
  /// 
  /// This factory method delegates to specific entry type factories
  /// based on the 'type' field in the JSON data.
  static WellnessEntry fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    
    switch (type) {
      case 'SVT Episode':
        return SvtEpisode.fromJson(json);
      case 'Exercise':
        return Exercise.fromJson(json);
      case 'Medication':
        return Medication.fromJson(json);
      default:
        throw ArgumentError('Unknown wellness entry type: $type');
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WellnessEntry &&
           other.id == id &&
           other.type == type &&
           other.timestamp == timestamp &&
           other.comments == comments;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
           type.hashCode ^
           timestamp.hashCode ^
           comments.hashCode;
  }
  
  @override
  String toString() {
    return 'WellnessEntry(id: $id, type: $type, timestamp: $timestamp, comments: $comments)';
  }
}
