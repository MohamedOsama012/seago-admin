import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Model/maintenance_provider_model.dart';

import 'package:sa7el/views/Home/Widgets/custom_appBar.dart';

class MaintenanceProviderPage extends StatefulWidget {
  const MaintenanceProviderPage({super.key});

  @override
  State<MaintenanceProviderPage> createState() =>
      _MaintenanceProviderPageState();
}

class _MaintenanceProviderPageState extends State<MaintenanceProviderPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<MaintenanceProviderModel> _maintenanceProviders = [
    MaintenanceProviderModel(
      id: '1',
      name: 'Maintenance Plus',
      type: 'Plumbing',
      phoneNumber: '01000000000',
      serving: 'Mall Of Arabia, Marassi',
      isActive: true,
    ),
    MaintenanceProviderModel(
      id: '2',
      name: 'Quick Fix Services',
      type: 'Electrical',
      phoneNumber: '01111111111',
      serving: 'New Cairo, Maadi',
      isActive: false,
    ),
    MaintenanceProviderModel(
      id: '3',
      name: 'Home Repair Co.',
      type: 'General',
      phoneNumber: '01222222222',
      serving: 'Zamalek, Dokki',
      isActive: true,
    ),
  ];

  List<MaintenanceProviderModel> _filteredProviders = [];

  @override
  void initState() {
    super.initState();
    _filteredProviders = _maintenanceProviders;
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
      _filteredProviders = _maintenanceProviders.where((provider) {
        return provider.name.toLowerCase().contains(query) ||
            provider.type.toLowerCase().contains(query) ||
            provider.phoneNumber.contains(query) ||
            provider.serving.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addMaintenanceProvider() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Maintenance Provider feature to be implemented'),
      ),
    );
  }

  void _editMaintenanceProvider(MaintenanceProviderModel provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${provider.name} feature to be implemented'),
      ),
    );
  }

  void _deleteMaintenanceProvider(MaintenanceProviderModel provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Maintenance Provider'),
          content: Text('Are you sure you want to delete ${provider.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _maintenanceProviders.removeWhere((p) => p.id == provider.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Maintenance Providers",
          style: TextStyle(
              color: WegoColors.mainColor,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(
            start: MediaQuery.of(context).size.width * 0.01,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: WegoColors.cardColor,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: WegoColors.mainColor,
                size: 20,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: MediaQuery.of(context).size.width * 0.01,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: WegoColors.cardColor,
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add,
                  color: WegoColors.mainColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar and Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: WegoColors.mainColor,
                        size: 20,
                      ),
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: WegoColors.mainColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: WegoColors.mainColor,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: WegoColors.mainColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: WegoColors.mainColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                    onPressed: () {
                      // Filter functionality
                    },
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          // Maintenance Provider List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _filteredProviders.length,
                itemBuilder: (context, index) {
                  final provider = _filteredProviders[index];
                  return _buildMaintenanceProviderCard(provider);
                },
              ),
            ),
          ),
        ],
      ),

      // Add Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMaintenanceProvider,
        backgroundColor: WegoColors.mainColor,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Add',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMaintenanceProviderCard(MaintenanceProviderModel provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: WegoColors.mainColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: provider.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    provider.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: provider.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Service details
            _buildDetailRow('Maintenance Type:', provider.type),
            const SizedBox(height: 8),
            _buildDetailRow('Phone Number:', provider.phoneNumber),
            const SizedBox(height: 8),
            _buildDetailRow('Serving:', provider.serving),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editMaintenanceProvider(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WegoColors.mainColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteMaintenanceProvider(provider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WegoColors.mainColor,
                      side: BorderSide(color: WegoColors.mainColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: WegoColors.mainColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
