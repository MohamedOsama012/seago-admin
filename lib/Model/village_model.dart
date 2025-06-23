class VillageModel {
  VillageModel({
    this.villages,
    this.zones,
  });

  VillageModel.fromJson(dynamic json) {
    if (json['villages'] != null) {
      villages = [];
      json['villages'].forEach((v) {
        villages?.add(Villages.fromJson(v));
      });
    }
    if (json['zones'] != null) {
      zones = [];
      json['zones'].forEach((v) {
        zones?.add(Zones.fromJson(v));
      });
    }
  }
  List<Villages>? villages;
  List<Zones>? zones;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (villages != null) {
      map['villages'] = villages?.map((v) => v.toJson()).toList();
    }
    if (zones != null) {
      map['zones'] = zones?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Zones {
  Zones({
    this.id,
    this.name,
    this.image,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.imageLink,
    this.arName,
    this.arDescription,
    this.translations,
  });

  Zones.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageLink = json['image_link'];
    arName = json['ar_name'];
    arDescription = json['ar_description'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations?.add(Translations.fromJson(v));
      });
    }
  }
  num? id;
  String? name;
  String? image;
  String? description;
  num? status;
  String? createdAt;
  String? updatedAt;
  String? imageLink;
  dynamic arName;
  dynamic arDescription;
  List<Translations>? translations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['description'] = description;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['image_link'] = imageLink;
    map['ar_name'] = arName;
    map['ar_description'] = arDescription;
    if (translations != null) {
      map['translations'] = translations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Translations {
  Translations({
    this.id,
    this.locale,
    this.translatableType,
    this.translatableId,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Translations.fromJson(dynamic json) {
    id = json['id'];
    locale = json['locale'];
    translatableType = json['translatable_type'];
    translatableId = json['translatable_id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? locale;
  String? translatableType;
  num? translatableId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['locale'] = locale;
    map['translatable_type'] = translatableType;
    map['translatable_id'] = translatableId;
    map['key'] = key;
    map['value'] = value;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Villages {
  Villages({
    this.id,
    this.name,
    this.description,
    this.location,
    this.image,
    this.from,
    this.to,
    this.packageId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.zoneId,
    this.coverImage,
    this.populationCount,
    this.unitsCount,
    this.providersCount,
    this.maintenanceProvidersCount,
    this.imageLink,
    this.arName,
    this.arDescription,
    this.coverImageLink,
    this.translations,
    this.zone,
  });

  Villages.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    location = json['location'];
    image = json['image'];
    from = json['from'];
    to = json['to'];
    packageId = json['package_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    zoneId = json['zone_id'];
    coverImage = json['cover_image'];
    populationCount = json['population_count'];
    unitsCount = json['units_count'];
    providersCount = json['providers_count'];
    maintenanceProvidersCount = json['maintenance_providers_count'];
    imageLink = json['image_link'];
    arName = json['ar_name'];
    arDescription = json['ar_description'];
    coverImageLink = json['cover_image_link'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations?.add(Translations.fromJson(v));
      });
    }
    zone = json['zone'] != null ? Zone.fromJson(json['zone']) : null;
  }
  int? id;
  String? name;
  String? description;
  String? location;
  String? image;
  String? from;
  String? to;
  dynamic packageId;
  num? status;
  String? createdAt;
  String? updatedAt;
  num? zoneId;
  String? coverImage;
  num? populationCount;
  num? unitsCount;
  num? providersCount;
  num? maintenanceProvidersCount;
  String? imageLink;
  dynamic arName;
  dynamic arDescription;
  String? coverImageLink;
  List<Translations>? translations;
  Zone? zone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['description'] = description;
    map['location'] = location;
    map['image'] = image;
    map['from'] = from;
    map['to'] = to;
    map['package_id'] = packageId;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['zone_id'] = zoneId;
    map['cover_image'] = coverImage;
    map['population_count'] = populationCount;
    map['units_count'] = unitsCount;
    map['providers_count'] = providersCount;
    map['maintenance_providers_count'] = maintenanceProvidersCount;
    map['image_link'] = imageLink;
    map['ar_name'] = arName;
    map['ar_description'] = arDescription;
    map['cover_image_link'] = coverImageLink;
    if (translations != null) {
      map['translations'] = translations?.map((v) => v.toJson()).toList();
    }
    if (zone != null) {
      map['zone'] = zone?.toJson();
    }
    return map;
  }
}

class Zone {
  Zone({
    this.id,
    this.name,
    this.image,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.imageLink,
    this.arName,
    this.arDescription,
    this.translations,
  });

  Zone.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageLink = json['image_link'];
    arName = json['ar_name'];
    arDescription = json['ar_description'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations?.add(Translations.fromJson(v));
      });
    }
  }
  num? id;
  String? name;
  String? image;
  String? description;
  num? status;
  String? createdAt;
  String? updatedAt;
  String? imageLink;
  dynamic arName;
  dynamic arDescription;
  List<Translations>? translations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['description'] = description;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['image_link'] = imageLink;
    map['ar_name'] = arName;
    map['ar_description'] = arDescription;
    if (translations != null) {
      map['translations'] = translations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
