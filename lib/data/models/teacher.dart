/// A teacher from the school website's public directory.
///
/// The source API also returns private details (national ID, birth date,
/// phone, address…). Only the fields below are read; everything else is
/// discarded on parse and never stored or displayed.
class Teacher {
  static const String _photoBase =
      'https://team-x.sg-sin-1.linodeobjects.com/team-x.ap-south-1.linodeobjects.com/';

  final int id;
  final String name;
  final String designation;
  final String? photoUrl;

  const Teacher({
    required this.id,
    required this.name,
    required this.designation,
    this.photoUrl,
  });

  /// Parses a row from `ausc.edu.bd/get-teachers`.
  factory Teacher.fromApi(Map<String, dynamic> row) {
    final photo = row['photo'] as String?;
    return Teacher(
      id: row['id'] as int,
      name: _cleanName(row['name'] as String? ?? ''),
      designation: (row['designation_title'] as String? ?? '').trim(),
      photoUrl: photo == null || photo.isEmpty ? null : '$_photoBase$photo',
    );
  }

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id: json['id'] as int,
    name: json['name'] as String,
    designation: json['designation'] as String,
    photoUrl: json['photoUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'designation': designation,
    'photoUrl': photoUrl,
  };

  String get profileUrl => 'https://ausc.edu.bd/teacher/data/$id';

  /// Lower ranks sort first: leadership, then college, then school faculty.
  int get rank {
    const order = [
      'Principal',
      'Asst. Head Teacher',
      'Asst. Professor',
      'Sr. Lecturer',
      'Lecturer',
      'Demonstrator',
      'Sr. Teacher',
      'Asst. Teacher',
    ];
    final exact = order.indexOf(designation);
    if (exact != -1) return exact;
    final partial = order.indexWhere((d) => designation.startsWith(d));
    return partial == -1 ? order.length : partial;
  }

  /// "86. Sheikh Shahjahan" → "Sheikh Shahjahan",
  /// "INDRAJIT KUMAR SARKAR" → "Indrajit Kumar Sarkar".
  static String _cleanName(String raw) {
    var name = raw.trim().replaceFirst(RegExp(r'^\d+\s*\.?\s*'), '');
    name = name.replaceAll(RegExp(r'\s+'), ' ');
    final letters = name.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isNotEmpty && letters == letters.toUpperCase()) {
      name = name
          .toLowerCase()
          .split(' ')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ')
          // "Md.mahbubur" → "Md.Mahbubur"
          .replaceAllMapped(
            RegExp(r'\.([a-z])'),
            (m) => '.${m[1]!.toUpperCase()}',
          );
    }
    return name;
  }
}
