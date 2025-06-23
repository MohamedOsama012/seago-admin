class SupRole {
  final int id;
  final int positionId;
  final String module;
  final String action;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupRole({
    required this.id,
    required this.positionId,
    required this.module,
    required this.action,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupRole.fromJson(Map<String, dynamic> json) {
    return SupRole(
      id: json['id'] ?? 0,
      positionId: json['position_id'] ?? 0,
      module: json['module'] ?? '',
      action: json['action'] ?? '',
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
        'position_id': positionId,
        'module': module,
        'action': action,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class Position {
  final int id;
  final String name;
  final String type;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SupRole> supRoles;

  Position({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.supRoles,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      supRoles: _parseSupRoles(json['sup_roles']),
    );
  }

  static List<SupRole> _parseSupRoles(dynamic supRoles) {
    if (supRoles == null) return [];
    if (supRoles is List) {
      return supRoles
          .map((role) => SupRole.fromJson(role as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sup_roles': supRoles.map((e) => e.toJson()).toList(),
      };
}

class AdminModel {
  final int id;
  final String name;
  final String gender;
  final String? birthDate;
  final String email;
  final String? emailVerifiedAt;
  final String phone;
  final String? userType;
  final String? providerId;
  final int? villageId;
  final int adminPositionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int status;
  final String role;
  final String? image;
  final int? parentUserId;
  final String? rentFrom;
  final String? rentTo;
  final String qrCode;
  final int? maintenanceProviderId;
  final String token;
  final String imageLink;
  final String qrCodeLink;
  final Position? position;

  AdminModel({
    required this.id,
    required this.name,
    required this.gender,
    this.birthDate,
    required this.email,
    this.emailVerifiedAt,
    required this.phone,
    this.userType,
    this.providerId,
    this.villageId,
    required this.adminPositionId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.role,
    this.image,
    this.parentUserId,
    this.rentFrom,
    this.rentTo,
    required this.qrCode,
    this.maintenanceProviderId,
    required this.token,
    required this.imageLink,
    required this.qrCodeLink,
    this.position,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    final admin = json['admin'];
    return AdminModel(
      id: admin['id'],
      name: admin['name'],
      gender: admin['gender'],
      birthDate: admin['birthDate'],
      email: admin['email'],
      emailVerifiedAt: admin['email_verified_at'],
      phone: admin['phone'],
      userType: admin['user_type'],
      providerId: admin['provider_id'],
      villageId: admin['village_id'],
      adminPositionId: admin['admin_position_id'],
      createdAt: DateTime.parse(admin['created_at']),
      updatedAt: DateTime.parse(admin['updated_at']),
      status: admin['status'],
      role: admin['role'],
      image: admin['image'],
      parentUserId: admin['parent_user_id'],
      rentFrom: admin['rent_from'],
      rentTo: admin['rent_to'],
      qrCode: admin['qr_code'],
      maintenanceProviderId: admin['maintenance_provider_id'],
      token: json['token'],
      imageLink: admin['image_link'],
      qrCodeLink: admin['qr_code_link'],
      position: admin['position'] != null
          ? Position.fromJson(admin['position'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': {
        'id': id,
        'name': name,
        'gender': gender,
        'birthDate': birthDate,
        'email': email,
        'email_verified_at': emailVerifiedAt,
        'phone': phone,
        'user_type': userType,
        'provider_id': providerId,
        'village_id': villageId,
        'admin_position_id': adminPositionId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'status': status,
        'role': role,
        'image': image,
        'parent_user_id': parentUserId,
        'rent_from': rentFrom,
        'rent_to': rentTo,
        'qr_code': qrCode,
        'maintenance_provider_id': maintenanceProviderId,
        'image_link': imageLink,
        'qr_code_link': qrCodeLink,
        'position': position?.toJson(),
      },
      'token': token,
    };
  }
}
