import '../entities/wellness_entry.dart';
import '../../core/constants/app_constants.dart';

/// Represents a medication intake entry.
/// 
/// Medication entries track when medications are taken, including dosage
/// information and any relevant notes about the medication event.
/// 
/// **AI-Friendly**: Clear validation rules and immutable design
/// **Student-Friendly**: Medical context with practical examples
/// **Test-Friendly**: Comprehensive validation and factory methods
class Medication extends WellnessEntry {
  /// Dosage of medication taken (e.g., "1/2 tablet", "100mg", "2 pills")
  final String? dosage;
  
  /// Creates a new medication entry.
  /// 
  /// [dosage] should be any non-empty text describing the amount taken.
  /// The validation is flexible to accommodate various dosage formats.
  /// Examples: "1/2 tablet", "100mg", "2 pills", "5ml"
  const Medication({
    required super.id,
    required super.timestamp,
    super.comments,
    this.dosage,
  }) : super(type: AppConstants.entryTypeMedication);
  
  @override
  bool isValid() {
    if (!super.isValid()) return false;
    
    // Dosage is optional, but if provided must not be empty
    if (dosage != null && dosage!.isNotEmpty) {
      return AppRegex.dosage.hasMatch(dosage!);
    }
    
    return true;
  }
  
  @override
  Medication copyWith({
    String? id,
    String? type, // Ignored - Medication entries always have type 'Medication'
    DateTime? timestamp,
    String? comments,
    String? dosage,
  }) {
    return Medication(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      comments: comments ?? this.comments,
      dosage: dosage ?? this.dosage,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'details': {
        if (dosage != null && dosage!.isNotEmpty) 'dosage': dosage,
        if (comments != null && comments!.isNotEmpty) 'comments': comments,
      },
    };
  }
  
  /// Creates a medication entry from JSON data.
  /// 
  /// Supports both the new JSON format and legacy CSV-style data.
  /// Handles missing fields gracefully with null values.
  static Medication fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    
    return Medication(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      comments: details['comments'] as String? ?? json['comments'] as String?,
      dosage: details['dosage'] as String? ?? json['dosage'] as String?,
    );
  }
  
  /// Creates a medication entry from CSV row data.
  /// 
  /// Expected format: Date,Time,Type,Duration,Dosage,Comments
  /// Where Type should be 'Medication' and Duration should be empty.
  static Medication fromCsv({
    required String id,
    required DateTime timestamp,
    String? dosage,
    String? comments,
  }) {
    return Medication(
      id: id,
      timestamp: timestamp,
      dosage: dosage,
      comments: comments,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Medication &&
           super == other &&
           other.dosage == dosage;
  }
  
  @override
  int get hashCode {
    return super.hashCode ^ dosage.hashCode;
  }
  
  @override
  String toString() {
    return 'Medication(id: $id, timestamp: $timestamp, dosage: $dosage, comments: $comments)';
  }
}
