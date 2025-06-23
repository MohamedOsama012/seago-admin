// Model
class MaintenanceProviderModel {
  final String id;
  final String name;
  final String type;
  final String phoneNumber;
  final String serving;
  final bool isActive;

  MaintenanceProviderModel({
    required this.id,
    required this.name,
    required this.type,
    required this.phoneNumber,
    required this.serving,
    required this.isActive,
  });
  factory MaintenanceProviderModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      phoneNumber: json['phoneNumber'] as String,
      serving: json['serving'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}
