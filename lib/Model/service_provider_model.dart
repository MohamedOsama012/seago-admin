class ServiceProviderModel {
  final int id;
  final int serviceId;
  final String name;
  final String phone;
  final String? image;
  final String? location;
  final String description;
  final String? from;
  final String? to;
  final int? packageId;
  final int status;
  final String createdAt;
  final String updatedAt;
  final int? villageId;
  final String? openFrom;
  final String? openTo;
  final String? coverImage;
  final int? zoneId;
  final int? mallId;
  final int? adminId;
  final String? locationMap;
  final String? imageLink;
  final String? arName;
  final String? arDescription;
  final double? rate;
  final String? coverImageLink;
  final List<Translation> translations;
  final ServiceType? service;
  final Package? package;
  final Zone? zone;
  final SuperAdmin? superAdmin;
  final List<RateItem> rateItems;

  ServiceProviderModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.phone,
    this.image,
    this.location,
    required this.description,
    this.from,
    this.to,
    this.packageId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.villageId,
    this.openFrom,
    this.openTo,
    this.coverImage,
    this.zoneId,
    this.mallId,
    this.adminId,
    this.locationMap,
    this.imageLink,
    this.arName,
    this.arDescription,
    this.rate,
    this.coverImageLink,
    required this.translations,
    this.service,
    this.package,
    this.zone,
    this.superAdmin,
    required this.rateItems,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      location: json['location'],
      description: json['description'] ?? '',
      from: json['from'],
      to: json['to'],
      packageId: json['package_id'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      villageId: json['village_id'],
      openFrom: json['open_from'],
      openTo: json['open_to'],
      coverImage: json['cover_image'],
      zoneId: json['zone_id'],
      mallId: json['mall_id'],
      adminId: json['admin_id'],
      locationMap: json['location_map'],
      imageLink: json['image_link'],
      arName: json['ar_name'],
      arDescription: json['ar_description'],
      rate: json['rate']?.toDouble(),
      coverImageLink: json['cover_image_link'],
      translations: _parseTranslations(json['translations']),
      service: json['service'] != null
          ? ServiceType.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      package: json['package'] != null
          ? Package.fromJson(json['package'] as Map<String, dynamic>)
          : null,
      zone: json['zone'] != null
          ? Zone.fromJson(json['zone'] as Map<String, dynamic>)
          : null,
      superAdmin: json['super_admin'] != null
          ? SuperAdmin.fromJson(json['super_admin'] as Map<String, dynamic>)
          : null,
      rateItems: _parseRateItems(json['rate_items']),
    );
  }

  static List<Translation> _parseTranslations(dynamic translations) {
    if (translations == null) return [];
    if (translations is List) {
      return translations
          .map((e) => Translation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<RateItem> _parseRateItems(dynamic rateItems) {
    if (rateItems == null) return [];
    if (rateItems is List) {
      return rateItems
          .map((e) => RateItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'name': name,
      'phone': phone,
      'image': image,
      'location': location,
      'description': description,
      'from': from,
      'to': to,
      'package_id': packageId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'village_id': villageId,
      'open_from': openFrom,
      'open_to': openTo,
      'cover_image': coverImage,
      'zone_id': zoneId,
      'mall_id': mallId,
      'admin_id': adminId,
      'location_map': locationMap,
      'image_link': imageLink,
      'ar_name': arName,
      'ar_description': arDescription,
      'rate': rate,
      'cover_image_link': coverImageLink,
      'translations': translations.map((e) => e.toJson()).toList(),
      'service': service?.toJson(),
      'package': package?.toJson(),
      'zone': zone?.toJson(),
      'super_admin': superAdmin?.toJson(),
      'rate_items': rateItems.map((e) => e.toJson()).toList(),
    };
  }

  // Detail getters for ExpandableItem interface
  Map<String, String> get basicDetails => {
        'Phone': phone,
        'Service': service?.name ?? 'N/A',
        'Status': status == 1 ? 'Active' : 'Inactive',
      };

  Map<String, String> get allDetails => {
        'Phone': phone,
        'Service Type': service?.name ?? 'N/A',
        'Description': description,
        'AR Description': arDescription ?? 'N/A',
        'Location': location ?? 'N/A',
        'Location Map': locationMap ?? 'N/A',
        'Village ID': villageId?.toString() ?? 'N/A',
        'Mall ID': mallId?.toString() ?? 'N/A',
        'Zone ID': zoneId?.toString() ?? 'N/A',
        'Open From': openFrom ?? 'N/A',
        'Open To': openTo ?? 'N/A',
        'From Date': from ?? 'N/A',
        'To Date': to ?? 'N/A',
        'Package ID': packageId?.toString() ?? 'N/A',
        'Rate': rate?.toString() ?? 'N/A',
        'Status': status == 1 ? 'Active' : 'Inactive',
        'Created At': createdAt,
        'Updated At': updatedAt,
      };

  // Add an empty constructor for creating placeholder instances
  ServiceProviderModel.empty()
      : id = 0,
        serviceId = 0,
        name = '',
        phone = '',
        image = null,
        location = null,
        description = '',
        from = null,
        to = null,
        packageId = null,
        status = 1, // Default to active
        createdAt = '',
        updatedAt = '',
        villageId = null,
        openFrom = null,
        openTo = null,
        coverImage = null,
        zoneId = null,
        mallId = null,
        adminId = null,
        locationMap = null,
        imageLink = null,
        arName = null,
        arDescription = null,
        rate = null,
        coverImageLink = null,
        translations = [],
        service = null,
        package = null,
        zone = null,
        superAdmin = null,
        rateItems = [];
}

class Translation {
  final int id;
  final String locale;
  final String translatableType;
  final int translatableId;
  final String key;
  final String value;
  final String createdAt;
  final String updatedAt;

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
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locale': locale,
      'translatable_type': translatableType,
      'translatable_id': translatableId,
      'key': key,
      'value': value,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ServiceType {
  final int id;
  final String name;
  final String? image;
  final String createdAt;
  final String updatedAt;
  final int status;
  final String? imageLink;
  final String? arName;
  final List<Translation> translations;

  ServiceType({
    required this.id,
    required this.name,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.imageLink,
    this.arName,
    required this.translations,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      status: json['status'] ?? 0,
      imageLink: json['image_link'],
      arName: json['ar_name'],
      translations: _parseTranslations(json['translations']),
    );
  }

  static List<Translation> _parseTranslations(dynamic translations) {
    if (translations == null) return [];
    if (translations is List) {
      return translations
          .map((e) => Translation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'image_link': imageLink,
      'ar_name': arName,
      'translations': translations.map((e) => e.toJson()).toList(),
    };
  }
}

class Package {
  // Add package properties as needed
  final int? id;
  final String? name;

  Package({
    this.id,
    this.name,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Zone {
  // Add zone properties as needed
  final int? id;
  final String? name;

  Zone({
    this.id,
    this.name,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SuperAdmin {
  // Add super admin properties as needed
  final int? id;
  final String? name;

  SuperAdmin({
    this.id,
    this.name,
  });

  factory SuperAdmin.fromJson(Map<String, dynamic> json) {
    return SuperAdmin(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class RateItem {
  // Add rate item properties as needed
  final int? id;
  final double? rating;

  RateItem({
    this.id,
    this.rating,
  });

  factory RateItem.fromJson(Map<String, dynamic> json) {
    return RateItem(
      id: json['id'],
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
    };
  }
}
