class MaintenanceModel {
  MaintenanceModel({
    this.providers,
    this.maintenanceTypes,
    this.villages,
  });

  MaintenanceModel.fromJson(dynamic json) {
    if (json['providers'] != null) {
      providers = [];
      json['providers'].forEach((v) {
        providers?.add(Providers.fromJson(v));
      });
    }
    if (json['maintenance_types'] != null) {
      maintenanceTypes = [];
      json['maintenance_types'].forEach((v) {
        maintenanceTypes?.add(MaintenanceTypes.fromJson(v));
      });
    }
    if (json['villages'] != null) {
      villages = [];
      json['villages'].forEach((v) {
        villages?.add(Villages.fromJson(v));
      });
    }
  }
  List<Providers>? providers;
  List<MaintenanceTypes>? maintenanceTypes;
  List<Villages>? villages;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (providers != null) {
      map['providers'] = providers?.map((v) => v.toJson()).toList();
    }
    if (maintenanceTypes != null) {
      map['maintenance_types'] =
          maintenanceTypes?.map((v) => v.toJson()).toList();
    }
    if (villages != null) {
      map['villages'] = villages?.map((v) => v.toJson()).toList();
    }
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
    this.imageLink,
    this.arName,
    this.arDescription,
    this.coverImageLink,
    this.translations,
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
  }
  int? id;
  String? name;
  String? description;
  String? location;
  dynamic image;
  String? from;
  String? to;
  dynamic packageId;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? zoneId;
  String? coverImage;
  String? imageLink;
  String? arName;
  String? arDescription;
  String? coverImageLink;
  List<Translations>? translations;

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
    map['image_link'] = imageLink;
    map['ar_name'] = arName;
    map['ar_description'] = arDescription;
    map['cover_image_link'] = coverImageLink;
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
  int? id;
  String? locale;
  String? translatableType;
  int? translatableId;
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

class MaintenanceTypes {
  MaintenanceTypes({
    this.id,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.imageLink,
    this.arName,
    this.translations,
  });

  MaintenanceTypes.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageLink = json['image_link'];
    arName = json['ar_name'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations?.add(Translations.fromJson(v));
      });
    }
  }
  int? id;
  String? name;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? imageLink;
  dynamic arName;
  List<Translations>? translations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['image_link'] = imageLink;
    map['ar_name'] = arName;
    if (translations != null) {
      map['translations'] = translations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Providers {
  Providers({
    this.id,
    this.maintenanceTypeId,
    this.name,
    this.phone,
    this.image,
    this.location,
    this.description,
    this.from,
    this.to,
    this.packageId,
    this.status,
    this.villageId,
    this.openFrom,
    this.openTo,
    this.coverImage,
    this.createdAt,
    this.updatedAt,
    this.imageLink,
    this.arName,
    this.arDescription,
    this.coverImageLink,
    this.translations,
    this.maintenance,
    this.package,
    this.locationMap,
  });

  Providers.fromJson(dynamic json) {
    id = json['id'];
    maintenanceTypeId = json['maintenance_type_id'];
    name = json['name'];
    phone = json['phone'];
    image = json['image'];
    location = json['location'];
    description = json['description'];
    from = json['from'];
    to = json['to'];
    packageId = json['package_id'];
    status = json['status'];
    villageId = json['village_id'];
    openFrom = json['open_from'];
    openTo = json['open_to'];
    coverImage = json['cover_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageLink = json['image_link'];
    arName = json['ar_name'];
    arDescription = json['ar_description'];
    coverImageLink = json['cover_image_link'];
    locationMap = json['location_map'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations?.add(Translations.fromJson(v));
      });
    }
    maintenance = json['maintenance'] != null
        ? Maintenance.fromJson(json['maintenance'])
        : null;
    package =
        json['package'] != null ? Package.fromJson(json['package']) : null;
  }
  int? id;
  int? maintenanceTypeId;
  String? name;
  String? phone;
  String? image;
  String? location;
  String? description;
  String? from;
  String? to;
  int? packageId;
  int? status;
  int? villageId;
  String? openFrom;
  String? openTo;
  dynamic coverImage;
  String? createdAt;
  String? updatedAt;
  String? imageLink;
  dynamic arName;
  dynamic arDescription;
  String? coverImageLink;
  List<Translations>? translations;
  Maintenance? maintenance;
  Package? package;
  String? locationMap;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['maintenance_type_id'] = maintenanceTypeId;
    map['name'] = name;
    map['phone'] = phone;
    map['image'] = image;
    map['location'] = location;
    map['description'] = description;
    map['from'] = from;
    map['to'] = to;
    map['package_id'] = packageId;
    map['status'] = status;
    map['village_id'] = villageId;
    map['open_from'] = openFrom;
    map['open_to'] = openTo;
    map['cover_image'] = coverImage;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['image_link'] = imageLink;
    map['ar_name'] = arName;
    map['ar_description'] = arDescription;
    map['cover_image_link'] = coverImageLink;
    map['location_map'] = locationMap;
    if (translations != null) {
      map['translations'] = translations?.map((v) => v.toJson()).toList();
    }
    if (maintenance != null) {
      map['maintenance'] = maintenance?.toJson();
    }
    if (package != null) {
      map['package'] = package?.toJson();
    }
    return map;
  }
}

class Package {
  Package({
    this.id,
    this.serviceId,
    this.name,
    this.description,
    this.price,
    this.feez,
    this.discount,
    this.beachPoolModule,
    this.maintenanceModule,
    this.securityNum,
    this.adminNum,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.arName,
    this.arDescription,
    this.translations,
  });

  Package.fromJson(dynamic json) {
    id = json['id'];
    serviceId = json['service_id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    feez = json['feez'];
    discount = json['discount'];
    beachPoolModule = json['beach_pool_module'];
    maintenanceModule = json['maintenance_module'];
    securityNum = json['security_num'];
    adminNum = json['admin_num'];
    type = json['type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    arName = json['ar_name'];
    arDescription = json['ar_description'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations?.add(Translations.fromJson(v));
      });
    }
  }
  int? id;
  dynamic serviceId;
  String? name;
  String? description;
  int? price;
  int? feez;
  int? discount;
  int? beachPoolModule;
  int? maintenanceModule;
  int? securityNum;
  int? adminNum;
  String? type;
  int? status;
  String? createdAt;
  String? updatedAt;
  dynamic arName;
  dynamic arDescription;
  List<Translations>? translations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['service_id'] = serviceId;
    map['name'] = name;
    map['description'] = description;
    map['price'] = price;
    map['feez'] = feez;
    map['discount'] = discount;
    map['beach_pool_module'] = beachPoolModule;
    map['maintenance_module'] = maintenanceModule;
    map['security_num'] = securityNum;
    map['admin_num'] = adminNum;
    map['type'] = type;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['ar_name'] = arName;
    map['ar_description'] = arDescription;
    if (translations != null) {
      map['translations'] = translations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Maintenance {
  Maintenance({
    this.id,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.imageLink,
    this.arName,
    this.translations,
  });

  Maintenance.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageLink = json['image_link'];
    arName = json['ar_name'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations?.add(Translations.fromJson(v));
      });
    }
  }
  int? id;
  String? name;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? imageLink;
  dynamic arName;
  List<Translations>? translations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['image_link'] = imageLink;
    map['ar_name'] = arName;
    if (translations != null) {
      map['translations'] = translations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
