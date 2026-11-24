class ReciterModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String server;
  final int surahTotal;
  final String moshafName;
  final String? imageUrl;

  const ReciterModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.server,
    this.surahTotal = 114,
    this.moshafName = 'حفص عن عاصم - مرتل',
    this.imageUrl,
  });

  String get displayImage {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    final lower = nameEn.toLowerCase();
    if (id == 123 || lower.contains('mishary') || lower.contains('alafasy')) {
      return 'assets/images/mishary_alafasy.jpg';
    }
    if (id == 51 || lower.contains('abdul basit') || lower.contains('abdulsamad') || lower.contains('abdelbasset')) {
      return 'assets/images/abdul_basit.jpg';
    }
    return 'assets/images/quran_artwork.jpg';
  }

  String getSurahAudioUrl(int surahNumber) {
    final numStr = surahNumber.toString().padLeft(3, '0');
    final base = server.endsWith('/') ? server : '$server/';
    return '$base$numStr.mp3';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'server': server,
      'surahTotal': surahTotal,
      'moshafName': moshafName,
      'imageUrl': imageUrl,
    };
  }

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['id'] as int? ?? 0,
      nameAr: json['nameAr'] as String? ?? json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? json['name'] as String? ?? '',
      server: json['server'] as String? ?? '',
      surahTotal: json['surahTotal'] as int? ?? json['surah_total'] as int? ?? 114,
      moshafName: json['moshafName'] as String? ?? json['moshaf_name'] as String? ?? 'حفص عن عاصم',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  // Curated list of popular, reliable reciters with verified 114 full-surah MP3 servers
  static const List<ReciterModel> popularReciters = [
    ReciterModel(
      id: 123,
      nameAr: 'مشاري راشد العفاسي',
      nameEn: 'Mishary Rashid Alafasy',
      server: 'https://cdn.mp3quran.net/audio/mishary-alafasy/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
      imageUrl: 'assets/images/mishary_alafasy.jpg',
    ),
    ReciterModel(
      id: 102,
      nameAr: 'ماهر المعيقلي',
      nameEn: 'Maher Al-Muaiqly',
      server: 'https://cdn.mp3quran.net/audio/maher-muaiqly/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 51,
      nameAr: 'عبدالباسط عبدالصمد',
      nameEn: 'Abdul Basit Abdul Samad',
      server: 'https://cdn.mp3quran.net/audio/abdulbasit-abdulsamad/r3/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
      imageUrl: 'assets/images/abdul_basit.jpg',
    ),
    ReciterModel(
      id: 30,
      nameAr: 'سعد الغامدي',
      nameEn: 'Saad Al-Ghamdi',
      server: 'https://cdn.mp3quran.net/audio/saad-ghamdi/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 54,
      nameAr: 'عبدالرحمن السديس',
      nameEn: 'Abdul Rahman Al-Sudais',
      server: 'https://cdn.mp3quran.net/audio/abdulrahman-sudais/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 31,
      nameAr: 'سعود الشريم',
      nameEn: 'Saud Al-Shuraim',
      server: 'https://cdn.mp3quran.net/audio/saud-shuraim/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 4,
      nameAr: 'أبو بكر الشاطري',
      nameEn: 'Abu Bakr Al-Shatri',
      server: 'https://cdn.mp3quran.net/audio/abubakr-shatri/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 5,
      nameAr: 'أحمد بن علي العجمي',
      nameEn: 'Ahmad Al-Ajmy',
      server: 'https://cdn.mp3quran.net/audio/ahmad-ajmi/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 112,
      nameAr: 'محمد صديق المنشاوي',
      nameEn: 'Mohamed Siddiq Al-Minshawi',
      server: 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 118,
      nameAr: 'محمود خليل الحصري',
      nameEn: 'Mahmoud Khalil Al-Husary',
      server: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 92,
      nameAr: 'ياسر الدوسري',
      nameEn: 'Yasser Al-Dosari',
      server: 'https://cdn.mp3quran.net/audio/yasser-dosari/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 81,
      nameAr: 'فارس عباد',
      nameEn: 'Fares Abbad',
      server: 'https://cdn.mp3quran.net/audio/fares-abbad/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 86,
      nameAr: 'ناصر القطامي',
      nameEn: 'Nasser Al-Qatami',
      server: 'https://cdn.mp3quran.net/audio/nasser-qatami/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 76,
      nameAr: 'علي جابر',
      nameEn: 'Ali Jaber',
      server: 'https://cdn.mp3quran.net/audio/ali-jaber/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
    ReciterModel(
      id: 12,
      nameAr: 'إدريس أبكر',
      nameEn: 'Idrees Abkar',
      server: 'https://cdn.mp3quran.net/audio/idrees-abkar/r1/',
      surahTotal: 114,
      moshafName: 'حفص عن عاصم - مرتل',
    ),
  ];

  static ReciterModel get defaultReciter => popularReciters.first;
}
