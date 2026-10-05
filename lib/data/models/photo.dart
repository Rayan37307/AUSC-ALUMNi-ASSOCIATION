/// Photo model representing a gallery photo
class Photo {
  final String id;
  final String url;
  final String? caption;
  final String uploadedBy;
  final DateTime createdAt;

  const Photo({
    required this.id,
    required this.url,
    this.caption,
    required this.uploadedBy,
    required this.createdAt,
  });

  /// Create a Photo from Supabase database row
  factory Photo.fromSupabase(Map<String, dynamic> data) {
    return Photo(
      id: data['id'] ?? '',
      url: data['url'] ?? '',
      caption: data['caption'] as String?,
      uploadedBy: data['uploaded_by'] ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert Photo to Supabase database row (for insert)
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'url': url,
      'caption': caption,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'caption': caption,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      caption: json['caption'] as String?,
      uploadedBy: json['uploadedBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}