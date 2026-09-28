import 'package:flutter/material.dart';

/// Static content for the school and association pages.
///
/// Everything the app shows about the school lives here, so updating the
/// About, History and banner sections only means editing this file. Teachers
/// are loaded live from the school website (see SchoolApi).
class SchoolContent {
  SchoolContent._();

  static const String schoolName = 'Aftab Uddin School & College';
  static const String associationName = 'AUSC Alumni Association';
  static const String shortName = 'AUSC';
  static const int establishedYear = 1986;
  static const String founder = 'Alhaz Jahurul Islam';
  static const String location = 'Bhagalpur, Bajitpur, Kishoreganj';
  static const String tagline = 'Honoring the past, empowering the future';
  static const String mottoBangla = 'প্রভু জ্ঞান বৃদ্ধি কর';
  static const String mottoEnglish = 'O Lord, increase my knowledge';
  static const String logoBanner = 'assets/images/TABIA.png';

  static const String aboutShort =
      'Connecting generations of graduates from Aftab Uddin School and '
      'College, Bhagalpur. Honoring our shared heritage since 1986 while '
      'empowering the leaders of tomorrow.';

  static const String aboutLong =
      'A vibrant community dedicated to lifelong friendship, service, and '
      'excellence. The association brings former students of every batch '
      'together to stay connected, support one another, and give back to '
      'the school that shaped us. Join us in celebrating our past and '
      'building a brighter future together.';

  static const String schoolAbout =
      'Aftab Uddin School & College was founded in 1986 by Alhaz Jahurul '
      'Islam in Bhagalpur, Bajitpur, Kishoreganj. Guided by the motto '
      '"প্রভু জ্ঞান বৃদ্ধি কর", the institution has spent decades nurturing '
      'students in knowledge, discipline and character.';

  static const String mapsQuery =
      'Aftab Uddin School and College, Bhagalpur, Bajitpur, Kishoreganj';

  // Official details from ausc.edu.bd
  static const String eiin = '110260';
  static const String phone = '01309110260';
  static const String email = 'info.ausc@gmail.com';
  static const String website = 'https://ausc.edu.bd';

  /// The principal's message as published on ausc.edu.bd.
  static const String principalName = 'Sheikh Shahjahan';
  static const String principalMessage =
      'পরিকল্পিত পাঠদানের মাধ্যমে প্রতিটি শিক্ষার্থীর ভালো ফলাফল অর্জনে '
      'সহায়তা প্রদান, প্রত্যেক শিক্ষার্থীর জন্য সমান সুযোগ-সুবিধা '
      'নিশ্চিতকরণ, বার্ষিক পরিকল্পনা অনুযায়ী নিজ নিজ অর্পিত দায়িত্ব সততা, '
      'নিষ্ঠা ও আন্তরিকতার সাথে সম্পন্ন করা, সর্বোপরি প্রাতিষ্ঠানিক লক্ষ্য '
      'অর্জনে নির্দিষ্ট সময়ের মধ্যে সার্থকভাবে সকল কার্যক্রম সুসম্পন্ন করায় '
      'আমাদের লক্ষ্য।';

  static int get yearsOfLegacy => DateTime.now().year - establishedYear;

  /// Home page auto-sliding banners (campus photos from ausc.edu.bd).
  ///
  /// To add more, put photos in assets/images/banners/ and add a
  /// BannerSlide here. Slides without an image render as a gradient card.
  static const List<BannerSlide> banners = [
    BannerSlide(
      image: 'assets/images/banners/main-gate.jpg',
      title: 'Main Gate',
      subtitle: 'Welcome to Aftab Uddin School & College',
    ),
    BannerSlide(
      image: 'assets/images/banners/courtyard.jpg',
      title: 'Academic Buildings',
      subtitle: 'Where generations of students learned',
    ),
    BannerSlide(
      image: 'assets/images/banners/shaheed-minar.jpg',
      title: 'Shaheed Minar',
      subtitle: 'Honoring the language martyrs',
    ),
    BannerSlide(
      image: 'assets/images/banners/campus-field.jpg',
      title: 'Campus Grounds',
      subtitle: 'Games, assemblies and lifelong memories',
    ),
    BannerSlide(
      image: logoBanner,
      title: 'Alumni Association',
      subtitle: 'Aftab Uddin School & College',
      showCaption: false,
    ),
  ];

  /// Milestones shown on the School page timeline.
  // TODO: add more milestones (buildings, college section, results, reunions).
  static const List<Milestone> history = [
    Milestone(
      year: '1986',
      title: 'School founded',
      description:
          'Alhaz Jahurul Islam establishes Aftab Uddin School in Bhagalpur, '
          'Bajitpur, Kishoreganj.',
    ),
    Milestone(
      year: 'Today',
      title: 'School & College',
      description:
          'A full school and college with science, humanities and business '
          'studies groups, and more than a hundred teachers.',
    ),
    Milestone(
      year: 'Join us',
      title: 'Alumni Association',
      description:
          'Graduates across generations come together to honor the past and '
          'empower the future.',
    ),
  ];
}

class BannerSlide {
  final String? image;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Set false for images that already contain their own text.
  final bool showCaption;

  const BannerSlide({
    this.image,
    required this.title,
    required this.subtitle,
    this.icon = Icons.school_rounded,
    this.showCaption = true,
  });
}

class Milestone {
  final String year;
  final String title;
  final String description;

  const Milestone({
    required this.year,
    required this.title,
    required this.description,
  });
}
