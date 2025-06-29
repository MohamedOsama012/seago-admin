class SupRole {
  final String id;
  final String positionId;
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
      id: (json['id'] == null || json['id'] == 0) ? '' : json['id'].toString(),
      positionId: (json['position_id'] == null || json['position_id'] == 0)
          ? ''
          : json['position_id'].toString(),
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
        'id': id.isEmpty ? '' : id,
        'position_id': positionId.isEmpty ? '' : positionId,
        'module': module,
        'action': action,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class Position {
  final String id;
  final String name;
  final String type;
  final String status;
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
      id: (json['id'] == null || json['id'] == 0) ? '' : json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: (json['status'] == null || json['status'] == 0)
          ? ''
          : json['status'].toString(),
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
        'id': id.isEmpty ? '' : id,
        'name': name,
        'type': type,
        'status': status.isEmpty ? '' : status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sup_roles': supRoles.map((e) => e.toJson()).toList(),
      };
}

class AdminModel {
  final String id;
  final String name;
  final String gender;
  final String birthDate;
  final String email;
  final String emailVerifiedAt;
  final String phone;
  final String userType;
  final String providerId;
  final String villageId;
  final String adminPositionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String role;
  final String image;
  final String parentUserId;
  final String rentFrom;
  final String rentTo;
  final String qrCode;
  final String maintenanceProviderId;
  final String token;
  final String imageLink;
  final String qrCodeLink;
  final Position? position;

  AdminModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.email,
    required this.emailVerifiedAt,
    required this.phone,
    required this.userType,
    required this.providerId,
    required this.villageId,
    required this.adminPositionId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.role,
    required this.image,
    required this.parentUserId,
    required this.rentFrom,
    required this.rentTo,
    required this.qrCode,
    required this.maintenanceProviderId,
    required this.token,
    required this.imageLink,
    required this.qrCodeLink,
    this.position,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    final admin = json['admin'];
    return AdminModel(
      id: (admin['id'] == null || admin['id'] == 0)
          ? ''
          : admin['id'].toString(),
      name: admin['name'] ?? '',
      gender: admin['gender'] ?? '',
      birthDate: admin['birthDate'] ?? '',
      email: admin['email'] ?? '',
      emailVerifiedAt: admin['email_verified_at'] ?? '',
      phone: admin['phone'] ?? '',
      userType: admin['user_type'] ?? '',
      providerId: admin['provider_id'] ?? '',
      villageId: (admin['village_id'] == null || admin['village_id'] == 0)
          ? ''
          : admin['village_id'].toString(),
      adminPositionId: (admin['admin_position_id'] == null ||
              admin['admin_position_id'] == 0)
          ? ''
          : admin['admin_position_id'].toString(),
      createdAt: admin['created_at'] != null
          ? DateTime.parse(admin['created_at'])
          : DateTime.now(),
      updatedAt: admin['updated_at'] != null
          ? DateTime.parse(admin['updated_at'])
          : DateTime.now(),
      status: (admin['status'] == null || admin['status'] == 0)
          ? ''
          : admin['status'].toString(),
      role: admin['role'] ?? '',
      image: admin['image'] ?? '',
      parentUserId:
          (admin['parent_user_id'] == null || admin['parent_user_id'] == 0)
              ? ''
              : admin['parent_user_id'].toString(),
      rentFrom: admin['rent_from'] ?? '',
      rentTo: admin['rent_to'] ?? '',
      qrCode: admin['qr_code'] ?? '',
      maintenanceProviderId: (admin['maintenance_provider_id'] == null ||
              admin['maintenance_provider_id'] == 0)
          ? ''
          : admin['maintenance_provider_id'].toString(),
      token: json['token'] ?? '',
      imageLink: admin['image_link'] ?? '',
      qrCodeLink: admin['qr_code_link'] ?? '',
      position: admin['position'] != null
          ? Position.fromJson(admin['position'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': {
        'id': id.isEmpty ? '' : id,
        'name': name,
        'gender': gender,
        'birthDate': birthDate,
        'email': email,
        'email_verified_at': emailVerifiedAt,
        'phone': phone,
        'user_type': userType,
        'provider_id': providerId,
        'village_id': villageId.isEmpty ? '' : villageId,
        'admin_position_id': adminPositionId.isEmpty ? '' : adminPositionId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'status': status.isEmpty ? '' : status,
        'role': role,
        'image': image,
        'parent_user_id': parentUserId.isEmpty ? '' : parentUserId,
        'rent_from': rentFrom,
        'rent_to': rentTo,
        'qr_code': qrCode,
        'maintenance_provider_id':
            maintenanceProviderId.isEmpty ? '' : maintenanceProviderId,
        'image_link': imageLink,
        'qr_code_link': qrCodeLink,
        'position': position?.toJson(),
      },
      'token': token,
    };
  }
}
