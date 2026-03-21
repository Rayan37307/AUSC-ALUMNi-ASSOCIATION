/// Alumni model representing an alumni member
class Alumni {
  final String id;
  final String name;
  final String phone;
  final String village;
  final String postOffice;
  final String upazila;
  final String district;
  final String currentlyDoing;
  final String achievements;
  final String batchYear;
  final String position;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Alumni({
    required this.id,
    required this.name,
    required this.phone,
    this.village = '',
    this.postOffice = '',
    this.upazila = '',
    this.district = '',
    this.currentlyDoing = '',
    this.achievements = '',
    required this.batchYear,
    this.position = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an Alumni from Supabase database row
  factory Alumni.fromSupabase(Map<String, dynamic> data) {
    return Alumni(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      village: data['village'] ?? '',
      postOffice: data['post_office'] ?? '',
      upazila: data['upazila'] ?? '',
      district: data['district'] ?? '',
      currentlyDoing: data['currently_doing'] ?? '',
      achievements: data['achievements'] ?? '',
      batchYear: data['batch_year'] ?? '',
      position: data['position'] ?? '',
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : DateTime.now(),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : DateTime.now(),
    );
  }

  /// Convert Alumni to Supabase database row (for insert)
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'name': name,
      'phone': phone,
      'village': village,
      'post_office': postOffice,
      'upazila': upazila,
      'district': district,
      'currently_doing': currentlyDoing,
      'achievements': achievements,
      'batch_year': batchYear,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert Alumni to Supabase database row (for update)
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'name': name,
      'phone': phone,
      'village': village,
      'post_office': postOffice,
      'upazila': upazila,
      'district': district,
      'currently_doing': currentlyDoing,
      'achievements': achievements,
      'batch_year': batchYear,
      'position': position,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy of Alumni with updated fields
  Alumni copyWith({
    String? id,
    String? name,
    String? phone,
    String? village,
    String? postOffice,
    String? upazila,
    String? district,
    String? currentlyDoing,
    String? achievements,
    String? batchYear,
    String? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alumni(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      village: village ?? this.village,
      postOffice: postOffice ?? this.postOffice,
      upazila: upazila ?? this.upazila,
      district: district ?? this.district,
      currentlyDoing: currentlyDoing ?? this.currentlyDoing,
      achievements: achievements ?? this.achievements,
      batchYear: batchYear ?? this.batchYear,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'village': village,
      'postOffice': postOffice,
      'upazila': upazila,
      'district': district,
      'currentlyDoing': currentlyDoing,
      'achievements': achievements,
      'batchYear': batchYear,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Alumni.fromJson(Map<String, dynamic> json) {
    return Alumni(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      village: json['village'] ?? '',
      postOffice: json['postOffice'] ?? '',
      upazila: json['upazila'] ?? '',
      district: json['district'] ?? '',
      currentlyDoing: json['currentlyDoing'] ?? '',
      achievements: json['achievements'] ?? '',
      batchYear: json['batchYear'] ?? '',
      position: json['position'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
