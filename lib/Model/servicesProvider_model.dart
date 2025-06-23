class ServiceProvider {
  final String id;
  final String name;
  final String serviceType;
  final String phoneNumber;
  final bool isActive;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.phoneNumber,
    required this.isActive,
  });
  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      serviceType: json['serviceType'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}
