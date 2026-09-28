/// Helpers for Bangladeshi mobile numbers.
///
/// Numbers are stored in canonical form `8801XXXXXXXXX` (13 digits) and
/// accepted in any common format: 01XXXXXXXXX, +8801XXXXXXXXX, 8801…, with
/// or without spaces and dashes.
class Phone {
  Phone._();

  static final RegExp _canonical = RegExp(r'^8801[3-9]\d{8}$');

  /// Returns the canonical form, or null if the number isn't valid.
  static String? normalize(String input) {
    var digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('01')) digits = '88$digits';
    return _canonical.hasMatch(digits) ? digits : null;
  }

  /// Form-field validator.
  static String? validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Enter your mobile number';
    }
    if (normalize(input) == null) {
      return 'Enter a valid mobile number (01XXXXXXXXX)';
    }
    return null;
  }

  /// `8801712345678` → `01712345678`
  static String toLocal(String canonical) =>
      canonical.startsWith('88') ? canonical.substring(2) : canonical;

  /// `8801712345678` → `+880 1712-345678`
  static String pretty(String canonical) {
    if (!_canonical.hasMatch(canonical)) return canonical;
    return '+880 ${canonical.substring(3, 7)}-${canonical.substring(7)}';
  }
}
