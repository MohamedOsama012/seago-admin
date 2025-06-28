import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_states.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_cubit.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_state.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';
import 'package:sa7el/Model/village_model.dart' as village_model;
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/Model/maintenance_model.dart' as maintenance_model;

class FilterState {
  final String searchQuery;
  final int? statusFilter; // 0 = inactive, 1 = active, null = all
  final int? zoneFilter;
  final int? villageFilter;
  final int? serviceTypeFilter;
  final int? maintenanceTypeFilter;

  const FilterState({
    this.searchQuery = '',
    this.statusFilter,
    this.zoneFilter,
    this.villageFilter,
    this.serviceTypeFilter,
    this.maintenanceTypeFilter,
  });

  FilterState copyWith({
    String? searchQuery,
    int? statusFilter,
    int? zoneFilter,
    int? villageFilter,
    int? serviceTypeFilter,
    int? maintenanceTypeFilter,
    bool clearStatusFilter = false,
    bool clearZoneFilter = false,
    bool clearVillageFilter = false,
    bool clearServiceTypeFilter = false,
    bool clearMaintenanceTypeFilter = false,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      zoneFilter: clearZoneFilter ? null : (zoneFilter ?? this.zoneFilter),
      villageFilter:
          clearVillageFilter ? null : (villageFilter ?? this.villageFilter),
      serviceTypeFilter: clearServiceTypeFilter
          ? null
          : (serviceTypeFilter ?? this.serviceTypeFilter),
      maintenanceTypeFilter: clearMaintenanceTypeFilter
          ? null
          : (maintenanceTypeFilter ?? this.maintenanceTypeFilter),
    );
  }

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        statusFilter != null ||
        zoneFilter != null ||
        villageFilter != null ||
        serviceTypeFilter != null ||
        maintenanceTypeFilter != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (statusFilter != null) count++;
    if (zoneFilter != null) count++;
    if (villageFilter != null) count++;
    if (serviceTypeFilter != null) count++;
    if (maintenanceTypeFilter != null) count++;
    return count;
  }
}

enum EntityType { village, mall, serviceProvider, maintenanceProvider }

class EntityFilterWidget extends StatefulWidget {
  final EntityType entityType;
  final FilterState initialFilters;
  final Function(FilterState) onFiltersChanged;
  final dynamic cubit;

  const EntityFilterWidget({
    super.key,
    required this.entityType,
    required this.initialFilters,
    required this.onFiltersChanged,
    required this.cubit,
  });

  @override
  State<EntityFilterWidget> createState() => _EntityFilterWidgetState();
}

class _EntityFilterWidgetState extends State<EntityFilterWidget> {
  late FilterState _currentFilters;
  late TextEditingController _searchController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _searchController =
        TextEditingController(text: _currentFilters.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters(FilterState newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  void _clearAllFilters() {
    _searchController.clear();
    _updateFilters(const FilterState());
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search ${widget.entityType.name}s...',
          prefixIcon: const Icon(Icons.search, color: WegoColors.mainColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _updateFilters(_currentFilters.copyWith(searchQuery: ''));
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          _updateFilters(_currentFilters.copyWith(searchQuery: value));
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<int?>(
        value: _currentFilters.statusFilter,
        decoration: const InputDecoration(
          labelText: 'Status',
          prefixIcon: Icon(Icons.toggle_on, color: WegoColors.mainColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: const [
          DropdownMenuItem<int?>(value: null, child: Text('All Status')),
          DropdownMenuItem<int?>(value: 1, child: Text('Active')),
          DropdownMenuItem<int?>(value: 0, child: Text('Inactive')),
        ],
        onChanged: (value) {
          _updateFilters(_currentFilters.copyWith(
            statusFilter: value,
            clearStatusFilter: value == null,
          ));
        },
      ),
    );
  }

  Widget _buildZoneFilter() {
    if (widget.entityType == EntityType.maintenanceProvider) {
      return const SizedBox.shrink(); // Maintenance providers don't have zones
    }

    return BlocBuilder<VillageCubit, VillageStates>(
      builder: (context, state) {
        final villageCubit = VillageCubit.get(context);
        final zones = villageCubit.zones;

        if (zones.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<int?>(
            value: _currentFilters.zoneFilter,
            decoration: const InputDecoration(
              labelText: 'Zone',
              prefixIcon: Icon(Icons.map, color: WegoColors.mainColor),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<int?>(
                  value: null, child: Text('All Zones')),
              ...zones.map((zone) => DropdownMenuItem<int?>(
                    value: zone.id?.toInt(),
                    child: Text(zone.name ?? 'Unnamed Zone'),
                  )),
            ],
            onChanged: (value) {
              _updateFilters(_currentFilters.copyWith(
                zoneFilter: value,
                clearZoneFilter: value == null,
              ));
            },
          ),
        );
      },
    );
  }

  Widget _buildVillageFilter() {
    if (widget.entityType == EntityType.village ||
        widget.entityType == EntityType.mall) {
      return const SizedBox
          .shrink(); // Villages and malls don't filter by village
    }

    return BlocBuilder<VillageCubit, VillageStates>(
      builder: (context, state) {
        final villageCubit = VillageCubit.get(context);
        final villages = villageCubit.items;

        if (villages.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<int?>(
            value: _currentFilters.villageFilter,
            decoration: const InputDecoration(
              labelText: 'Village',
              prefixIcon:
                  Icon(Icons.location_city, color: WegoColors.mainColor),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<int?>(
                  value: null, child: Text('All Villages')),
              ...villages.map((village) => DropdownMenuItem<int?>(
                    value: village.id?.toInt(),
                    child: Text(village.name ?? 'Unnamed Village'),
                  )),
            ],
            onChanged: (value) {
              _updateFilters(_currentFilters.copyWith(
                villageFilter: value,
                clearVillageFilter: value == null,
              ));
            },
          ),
        );
      },
    );
  }

  Widget _buildServiceTypeFilter() {
    if (widget.entityType != EntityType.serviceProvider) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ServiceProviderCubit, ServiceProviderStates>(
      builder: (context, state) {
        final serviceProviderCubit = context.read<ServiceProviderCubit>();

        // Extract unique service types
        final uniqueServices = <int, ServiceType>{};
        for (var provider in serviceProviderCubit.items) {
          if (provider.service != null) {
            uniqueServices[provider.service!.id] = provider.service!;
          }
        }

        if (uniqueServices.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<int?>(
            value: _currentFilters.serviceTypeFilter,
            decoration: const InputDecoration(
              labelText: 'Service Type',
              prefixIcon: Icon(Icons.business, color: WegoColors.mainColor),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<int?>(
                  value: null, child: Text('All Services')),
              ...uniqueServices.values.map((service) => DropdownMenuItem<int?>(
                    value: service.id,
                    child: Text(service.name),
                  )),
            ],
            onChanged: (value) {
              _updateFilters(_currentFilters.copyWith(
                serviceTypeFilter: value,
                clearServiceTypeFilter: value == null,
              ));
            },
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceTypeFilter() {
    if (widget.entityType != EntityType.maintenanceProvider) {
      return const SizedBox.shrink();
    }

    final maintenanceCubit = widget.cubit as MaintenanceCubit;
    final maintenanceTypes = maintenanceCubit.maintenanceTypes;

    if (maintenanceTypes.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<int?>(
        value: _currentFilters.maintenanceTypeFilter,
        decoration: const InputDecoration(
          labelText: 'Maintenance Type',
          prefixIcon: Icon(Icons.build, color: WegoColors.mainColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All Types')),
          ...maintenanceTypes.map((type) => DropdownMenuItem<int?>(
                value: type.id?.toInt(),
                child: Text(type.name ?? 'Unnamed Type'),
              )),
        ],
        onChanged: (value) {
          _updateFilters(_currentFilters.copyWith(
            maintenanceTypeFilter: value,
            clearMaintenanceTypeFilter: value == null,
          ));
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<Widget> chips = [];

    if (_currentFilters.statusFilter != null) {
      chips.add(_buildFilterChip(
        label: _currentFilters.statusFilter == 1 ? 'Active' : 'Inactive',
        onDeleted: () =>
            _updateFilters(_currentFilters.copyWith(clearStatusFilter: true)),
      ));
    }

    if (_currentFilters.zoneFilter != null) {
      final villageCubit = VillageCubit.get(context);
      final zone = villageCubit.zones.firstWhere(
        (z) => z.id == _currentFilters.zoneFilter,
        orElse: () => village_model.Zones(name: 'Unknown Zone'),
      );
      chips.add(_buildFilterChip(
        label: 'Zone: ${zone.name}',
        onDeleted: () =>
            _updateFilters(_currentFilters.copyWith(clearZoneFilter: true)),
      ));
    }

    if (_currentFilters.villageFilter != null) {
      final villageCubit = VillageCubit.get(context);
      final village = villageCubit.items.firstWhere(
        (v) => v.id == _currentFilters.villageFilter,
        orElse: () => village_model.Villages(name: 'Unknown Village'),
      );
      chips.add(_buildFilterChip(
        label: 'Village: ${village.name}',
        onDeleted: () =>
            _updateFilters(_currentFilters.copyWith(clearVillageFilter: true)),
      ));
    }

    if (_currentFilters.serviceTypeFilter != null) {
      final serviceProviderCubit = context.read<ServiceProviderCubit>();
      final serviceProvider = serviceProviderCubit.items.firstWhere(
        (p) => p.service?.id == _currentFilters.serviceTypeFilter,
        orElse: () => ServiceProviderModel.empty(),
      );
      chips.add(_buildFilterChip(
        label: 'Service: ${serviceProvider.service?.name ?? 'Unknown Service'}',
        onDeleted: () => _updateFilters(
            _currentFilters.copyWith(clearServiceTypeFilter: true)),
      ));
    }

    if (_currentFilters.maintenanceTypeFilter != null) {
      final maintenanceCubit = widget.cubit as MaintenanceCubit;
      final maintenanceType = maintenanceCubit.maintenanceTypes.firstWhere(
        (t) => t.id == _currentFilters.maintenanceTypeFilter,
        orElse: () => maintenance_model.MaintenanceTypes(name: 'Unknown Type'),
      );
      chips.add(_buildFilterChip(
        label: 'Type: ${maintenanceType.name}',
        onDeleted: () => _updateFilters(
            _currentFilters.copyWith(clearMaintenanceTypeFilter: true)),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ...chips,
          if (chips.length > 1) _buildClearAllChip(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: WegoColors.mainColor.withOpacity(0.1),
      side: BorderSide(color: WegoColors.mainColor.withOpacity(0.3)),
    );
  }

  Widget _buildClearAllChip() {
    return ActionChip(
      label: const Text(
        'Clear All',
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
      onPressed: _clearAllFilters,
      backgroundColor: WegoColors.mainColor,
      side: const BorderSide(color: WegoColors.mainColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1024;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search and filter toggle
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSearchField()),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _currentFilters.hasActiveFilters
                            ? WegoColors.mainColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentFilters.hasActiveFilters
                              ? WegoColors.mainColor
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        icon: Stack(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: _currentFilters.hasActiveFilters
                                  ? Colors.white
                                  : WegoColors.mainColor,
                            ),
                            if (_currentFilters.hasActiveFilters)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${_currentFilters.activeFilterCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Filter chips
                _buildFilterChips(),
              ],
            ),
          ),

          // Expandable filter options
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  if (isDesktop)
                    // Desktop layout - 3 columns
                    Row(
                      children: [
                        Expanded(child: _buildStatusFilter()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildZoneFilter()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildVillageFilter()),
                      ],
                    )
                  else if (isTablet)
                    // Tablet layout - 2 columns
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildStatusFilter()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildZoneFilter()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildVillageFilter()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildServiceTypeFilter()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildMaintenanceTypeFilter(),
                      ],
                    )
                  else
                    // Mobile layout - 1 column
                    Column(
                      children: [
                        _buildStatusFilter(),
                        const SizedBox(height: 12),
                        _buildZoneFilter(),
                        const SizedBox(height: 12),
                        _buildVillageFilter(),
                        const SizedBox(height: 12),
                        _buildServiceTypeFilter(),
                        const SizedBox(height: 12),
                        _buildMaintenanceTypeFilter(),
                      ]
                          .where((widget) => widget != const SizedBox.shrink())
                          .toList(),
                    ),
                  if (_currentFilters.hasActiveFilters) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearAllFilters,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All Filters'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: WegoColors.mainColor,
                          side: const BorderSide(color: WegoColors.mainColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
