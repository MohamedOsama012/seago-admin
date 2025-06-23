// MallModel_model.dart
class Translation {
  final int id;
  final String locale;
  final String translatableType;
  final int translatableId;
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  Translation({
    required this.id,
    required this.locale,
    required this.translatableType,
    required this.translatableId,
    required this.key,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'] ?? 0,
      locale: json['locale'] ?? '',
      translatableType: json['translatable_type'] ?? '',
      translatableId: json['translatable_id'] ?? 0,
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'locale': locale,
        'translatable_type': translatableType,
        'translatable_id': translatableId,
        'key': key,
        'value': value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

// zone_model.dart
class Zone {
  final int id;
  final String name;
  final String image;
  final String? description; // description can be null
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageLink;
  final String arName;
  final String arDescription;
  final List<Translation> translations;

  Zone({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.imageLink,
    required this.arName,
    required this.arDescription,
    required this.translations,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      imageLink: json['image_link'] ?? '',
      arName: json['ar_name'] ?? '',
      arDescription: json['ar_description'] ?? '',
      translations:
          MallsAndZonesResponse._parseTranslations(json['translations']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'description': description,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'image_link': imageLink,
        'ar_name': arName,
        'ar_description': arDescription,
        'translations': translations.map((e) => e.toJson()).toList(),
      };
}

class MallModel {
  final int id;
  final String name;
  final String description;
  final String openFrom;
  final String openTo;
  final String? image; // Made nullable
  final String? coverImage; // Made nullable
  final int zoneId;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageLink;
  final String coverImageLink;
  final String arName;
  final String arDescription;
  final List<Translation> translations;
  final Zone zone;

  MallModel({
    required this.id,
    required this.name,
    required this.description,
    required this.openFrom,
    required this.openTo,
    required this.image,
    required this.coverImage,
    required this.zoneId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.imageLink,
    required this.coverImageLink,
    required this.arName,
    required this.arDescription,
    required this.translations,
    required this.zone,
  });

  factory MallModel.fromJson(Map<String, dynamic> json) {
    return MallModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      openFrom: json['open_from'] ?? '00:00:00',
      openTo: json['open_to'] ?? '23:59:59',
      image: json['image'] ?? '',
      coverImage: json['cover_image'] ?? '',
      zoneId: json['zone_id'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      imageLink: json['image_link'] ?? '',
      coverImageLink: json['cover_image_link'] ?? '',
      arName: json['ar_name'] ?? '',
      arDescription: json['ar_description'] ?? '',
      translations:
          MallsAndZonesResponse._parseTranslations(json['translations']),
      zone: json['zone'] != null
          ? Zone.fromJson(json['zone'])
          : Zone(
              id: 0,
              name: 'Unknown Zone',
              image: '',
              description: '',
              status: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              imageLink: '',
              arName: '',
              arDescription: '',
              translations: [],
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'open_from': openFrom,
        'open_to': openTo,
        'image': image,
        'cover_image': coverImage,
        'zone_id': zoneId,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'image_link': imageLink,
        'cover_image_link': coverImageLink,
        'ar_name': arName,
        'ar_description': arDescription,
        'translations': translations.map((e) => e.toJson()).toList(),
        'zone': zone.toJson(),
      };
}

class MallsAndZonesResponse {
  final List<MallModel> malls;
  final List<Zone> zones;

  MallsAndZonesResponse({
    required this.malls,
    required this.zones,
  });

  factory MallsAndZonesResponse.fromJson(Map<String, dynamic> json) {
    return MallsAndZonesResponse(
      malls: _parseMalls(json['malls']),
      zones: _parseZones(json['zones']),
    );
  }

  static List<MallModel> _parseMalls(dynamic malls) {
    if (malls == null) return [];
    if (malls is List) {
      return malls
          .map((m) => MallModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<Zone> _parseZones(dynamic zones) {
    if (zones == null) return [];
    if (zones is List) {
      return zones
          .map((z) => Zone.fromJson(z as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<Translation> _parseTranslations(dynamic translations) {
    if (translations == null) return [];
    if (translations is List) {
      return translations
          .map((t) => Translation.fromJson(t as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
        'malls': malls.map((m) => m.toJson()).toList(),
        'zones': zones.map((z) => z.toJson()).toList(),
      };
}
