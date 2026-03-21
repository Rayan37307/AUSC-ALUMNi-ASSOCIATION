class AppConstants {
  AppConstants._();

  static const String appName = 'AUSC Alumni';
  static const String schoolName = 'AFTAB UDDIN SCHOOL & COLLEGE';
  
  // Cache settings
  static const int cacheExpiryMs = 5 * 60 * 1000; // 5 minutes
  static const String alumniCacheKey = 'alumni_cache';
  
  // Firebase collections
  static const String alumniCollection = 'alumni';
  
  // Primary color
  static const String primaryColorHex = '0a7ea4';
  
  // Batch year range
  static const int minBatchYear = 1970;
  
  // Image assets
  static const String schoolBannerPath = 'assets/images/school_banner.png';
  
  // Debounce duration
  static const int debounceMs = 300;
}
