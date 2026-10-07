/// Alumni model representing an alumni member
class Alumni {
  final String id;
  final String name;
  final String phone;
  final String currentAddress;
  final String permanentAddress;
  final String currentlyDoing;
  final String batchYear;
  final String position;
  final String? bloodGroup;  // NEW: Blood group option
  /// Auth user id of the member who added this entry. RLS policies allow a
  /// member to edit or delete only rows they own, so the app uses this to
  /// decide whether to show edit and delete controls.
  final String? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Alumni({
    required this.id,
    required this.name,
    required this.phone,
    this.currentAddress = '',
    this.permanentAddress = '',
    this.currentlyDoing = '',
    required this.batchYear,
    this.position = '',
    this.bloodGroup,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an Alumni from Supabase database row
  factory Alumni.fromSupabase(Map<String, dynamic> data) {
    return Alumni(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      currentAddress: data['current_address'] ?? '',
      permanentAddress: data['permanent_address'] ?? '',
      currentlyDoing: data['currently_doing'] ?? '',
      batchYear: data['batch_year'] ?? '',
      position: data['position'] ?? '',
      bloodGroup: data['blood_group'] as String?,  // NEW
      ownerId: data['owner_id'] as String?,
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
    // owner_id is deliberately omitted: the column defaults to auth.uid(), so
    // the database stamps the signed-in member and a client cannot forge it.
    return {
      'name': name,
      'phone': phone,
      'current_address': currentAddress,
      'permanent_address': permanentAddress,
      'currently_doing': currentlyDoing,
      'batch_year': batchYear,
      'position': position,
      'blood_group': bloodGroup,  // NEW
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert Alumni to Supabase database row (for update)
  Map<String, dynamic> toSupabaseUpdate() {
    // owner_id is omitted here too, so an update can never hand an entry to a
    // different member.
    return {
      'name': name,
      'phone': phone,
      'current_address': currentAddress,
      'permanent_address': permanentAddress,
      'currently_doing': currentlyDoing,
      'batch_year': batchYear,
      'position': position,
      'blood_group': bloodGroup,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy of Alumni with updated fields
  Alumni copyWith({
    String? id,
    String? name,
    String? phone,
    String? currentAddress,
    String? permanentAddress,
    String? currentlyDoing,
    String? batchYear,
    String? position,
    String? bloodGroup,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alumni(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      currentAddress: currentAddress ?? this.currentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      currentlyDoing: currentlyDoing ?? this.currentlyDoing,
      batchYear: batchYear ?? this.batchYear,
      position: position ?? this.position,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      ownerId: ownerId ?? this.ownerId,
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
      'currentAddress': currentAddress,
      'permanentAddress': permanentAddress,
      'currentlyDoing': currentlyDoing,
      'batchYear': batchYear,
      'position': position,
      'bloodGroup': bloodGroup,
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
      currentAddress: json['currentAddress'] ?? '',
      permanentAddress: json['permanentAddress'] ?? '',
      currentlyDoing: json['currentlyDoing'] ?? '',
      batchYear: json['batchYear'] ?? '',
      position: json['position'] ?? '',
      bloodGroup: json['bloodGroup'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
