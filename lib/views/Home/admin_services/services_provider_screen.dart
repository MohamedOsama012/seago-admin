import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Model/servicesProvider_model.dart';

import 'package:sa7el/views/Home/Widgets/custom_appBar.dart';

class ServicesProviderUIPage extends StatefulWidget {
  const ServicesProviderUIPage({super.key});

  @override
  State<ServicesProviderUIPage> createState() => _ServicesProviderUIPageState();
}

class _ServicesProviderUIPageState extends State<ServicesProviderUIPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<ServiceProvider> _serviceProviders = [
    ServiceProvider(
      id: '1',
      name: 'Tech Solutions LLC',
      serviceType: 'IT Support',
      phoneNumber: '01123456789',
      isActive: true,
    ),
    ServiceProvider(
      id: '2',
      name: 'Plumbing Pros',
      serviceType: 'Plumbing Services',
      phoneNumber: '02234567890',
      isActive: false,
    ),
    ServiceProvider(
      id: '3',
      name: 'Green Energy',
      serviceType: 'Solar Installation',
      phoneNumber: '03345678901',
      isActive: true,
    ),
  ];

  List<ServiceProvider> _filteredProviders = [];

  @override
  void initState() {
    super.initState();
    _filteredProviders = _serviceProviders;
    _searchController.addListener(_filterProviders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProviders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProviders = _serviceProviders.where((provider) {
        return provider.name.toLowerCase().contains(query) ||
            provider.serviceType.toLowerCase().contains(query) ||
            provider.phoneNumber.contains(query);
      }).toList();
    });
  }

  void _addServiceProvider() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Service Provider feature to be implemented'),
      ),
    );
  }

  void _editServiceProvider(ServiceProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${provider.name} feature to be implemented'),
      ),
    );
  }

  void _deleteServiceProvider(ServiceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Service Provider'),
          content: Text('Are you sure you want to delete ${provider.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _serviceProviders.removeWhere((p) => p.id == provider.id);
                  _filterProviders();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${provider.name} deleted successfully'),
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper method to get responsive values
  double _getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }

  // Helper method to determine if device is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Helper method to determine if device is tablet
  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  // Helper method to get cross axis count for grid
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1; // Mobile: 1 column
    if (width < 900) return 2; // Small tablet: 2 columns
    if (width < 1200) return 3; // Large tablet: 3 columns
    return 4; // Desktop: 4 columns
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: appBar(
        title: "Services Providers",
        context: context,
        onPressedAddIcon: () {},
        onPressedBackIcon: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          // Search Bar and Filter - Responsive
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(
              _getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search providers, services, or phone numbers',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: _getResponsiveValue(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 16,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: _getResponsiveValue(
                          context,
                          mobile: 20,
                          tablet: 24,
                          desktop: 24,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveValue(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        vertical: _getResponsiveValue(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _getResponsiveValue(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: _getResponsiveValue(
                        context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 24,
                      ),
                    ),
                    onPressed: () {
                      // Filter functionality
                    },
                    padding: EdgeInsets.all(
                      _getResponsiveValue(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Service Provider List - Responsive Layout
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(
                _getResponsiveValue(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              child: isMobile ? _buildMobileList() : _buildGridLayout(),
            ),
          ),
        ],
      ),

      // Add Button - Responsive
      floatingActionButton: Container(
        width: isMobile ? double.infinity : null,
        margin: EdgeInsets.symmetric(
          horizontal: _getResponsiveValue(
            context,
            mobile: 16,
            tablet: 24,
            desktop: 32,
          ),
          vertical: 16,
        ),
        child: FloatingActionButton.extended(
          onPressed: _addServiceProvider,
          backgroundColor: Colors.teal,
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: _getResponsiveValue(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 24,
            ),
          ),
          label: Text(
            'Add Service Provider',
            style: TextStyle(
              color: Colors.white,
              fontSize: _getResponsiveValue(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 18,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonLocation: isMobile
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }

  // Mobile list layout
  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _filteredProviders.length,
      itemBuilder: (context, index) {
        final provider = _filteredProviders[index];
        return _buildServiceProviderCard(provider, isMobile: true);
      },
    );
  }

  // Grid layout for tablets and desktops
  Widget _buildGridLayout() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _getResponsiveValue(
          context,
          mobile: 1.2,
          tablet: 1.0,
          desktop: 0.9,
        ),
      ),
      itemCount: _filteredProviders.length,
      itemBuilder: (context, index) {
        final provider = _filteredProviders[index];
        return _buildServiceProviderCard(provider, isMobile: false);
      },
    );
  }

  Widget _buildServiceProviderCard(
    ServiceProvider provider, {
    required bool isMobile,
  }) {
    final cardPadding = _getResponsiveValue(
      context,
      mobile: 16,
      tablet: 18,
      desktop: 20,
    );

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 16 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.isActive ? Colors.blue : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with name and status
          Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: provider.isActive
                  ? Colors.blue.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider.name,
                    style: TextStyle(
                      fontSize: _getResponsiveValue(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 18,
                      ),
                      fontWeight: FontWeight.w600,
                      color: provider.isActive ? Colors.blue : Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveValue(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: provider.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    provider.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _getResponsiveValue(
                        context,
                        mobile: 12,
                        tablet: 13,
                        desktop: 14,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Service details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                children: [
                  // Service Type
                  _buildDetailRow(
                    'Service Type:',
                    provider.serviceType,
                    hasIndicator: true,
                  ),

                  SizedBox(
                    height: _getResponsiveValue(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),

                  // Phone Number
                  _buildDetailRow('Phone Number:', provider.phoneNumber),

                  const Spacer(),

                  // Action Buttons - Responsive
                  _buildActionButtons(provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool hasIndicator = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _getResponsiveValue(
            context,
            mobile: 100,
            tablet: 120,
            desktop: 130,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveValue(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: _getResponsiveValue(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasIndicator) ...[
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ServiceProvider provider) {
    final isMobile = _isMobile(context);

    return isMobile
        ? Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _editServiceProvider(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _deleteServiceProvider(provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _editServiceProvider(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: _getResponsiveValue(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _deleteServiceProvider(provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: _getResponsiveValue(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
