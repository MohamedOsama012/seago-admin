import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Core/toast_helper.dart';
import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_states.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_state.dart';
import 'package:sa7el/Model/maintenance_model.dart' show Providers;
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/Model/village_model.dart';
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/views/Home/Widgets/add_dialog_widget.dart';
import 'package:sa7el/views/Home/Widgets/expandable_container_widget.dart';
import 'package:sa7el/views/Home/Widgets/entity_filter_widget.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_cubit.dart';

class EntityListScreen<C extends EntityCubit<T, S>, T, S>
    extends StatefulWidget {
  final C cubit;
  final String title;

  const EntityListScreen({
    super.key,
    required this.cubit,
    required this.title,
  });

  @override
  State<EntityListScreen<C, T, S>> createState() =>
      _EntityListScreenState<C, T, S>();
}

class _EntityListScreenState<C extends EntityCubit<T, S>, T, S>
    extends State<EntityListScreen<C, T, S>> {
  // Track which cards are expanded using their index
  final Set<int> _expandedCards = <int>{};

  // Filter functionality
  FilterState _filterState = const FilterState();

  EntityType _getEntityType() {
    if (widget.cubit is VillageCubit) return EntityType.village;
    if (widget.cubit is MallsCubit) return EntityType.mall;
    if (widget.cubit is ServiceProviderCubit) return EntityType.serviceProvider;
    if (widget.cubit is MaintenanceCubit) return EntityType.maintenanceProvider;
    throw Exception('Unknown cubit type: ${widget.cubit.runtimeType}');
  }

  bool _isLoadingState(S state) {
    return state is MallsGetDataLoadingState ||
        state is VillaLoadingState ||
        state is ServiceProviderGetDataLoadingState ||
        state is MaintenanceLoadingState ||
        state is MallsAddLoadingState ||
        state is VillageAddLoadingState ||
        state is ServiceProviderAddLoadingState ||
        state is MaintenanceAddLoadingState;
  }

  bool _isSuccessState(S state) {
    return state is MallsGetDataSuccessState ||
        state is VillageSuccessState ||
        state is VillageFilteredState ||
        state is VillageSearchState ||
        state is ServiceProviderGetDataSuccessState ||
        state is MaintenanceSuccessState ||
        state is MaintenanceFilteredState ||
        state is MaintenanceSearchState ||
        state is MallsAddSuccessState ||
        state is VillageAddSuccessState ||
        state is ServiceProviderAddSuccessState ||
        state is MaintenanceAddSuccessState;
  }

  bool _isErrorState(S state) {
    return state is MallsGetDataErrorState ||
        state is VillageErrorState ||
        state is ServiceProviderGetDataErrorState ||
        state is MaintenanceErrorState ||
        state is MallsAddFailedState ||
        state is VillageAddErrorState ||
        state is ServiceProviderAddFailedState ||
        state is MaintenanceAddErrorState;
  }

  String _getErrorMessage(S state) {
    if (state is MallsGetDataErrorState) return state.error;
    if (state is VillageErrorState) return state.error;
    if (state is ServiceProviderGetDataErrorState) {
      return 'Failed to load service providers';
    }
    if (state is MaintenanceErrorState) return state.error;

    // Add Failed States
    if (state is MallsAddFailedState) return state.errMessage;
    if (state is VillageAddErrorState) return state.error;
    if (state is ServiceProviderAddFailedState) return state.error;
    if (state is MaintenanceAddErrorState) return state.error;

    return 'Unknown error occurred';
  }

  void _toggleCardExpansion(int index) {
    setState(() {
      if (_expandedCards.contains(index)) {
        _expandedCards.remove(index);
      } else {
        _expandedCards.add(index);
      }
    });
  }

  void _onFiltersChanged(FilterState newFilters) {
    setState(() {
      _filterState = newFilters;
    });
  }

  // Get the appropriate items list based on cubit type and applied filters
  List<dynamic> _getFilteredItems(C cubit) {
    List<dynamic> items;

    // Get base items from cubit
    if (cubit is VillageCubit) {
      items = (cubit as VillageCubit).items;
    } else if (cubit is MaintenanceCubit) {
      items = (cubit as MaintenanceCubit).items;
    } else if (cubit is MallsCubit) {
      items = (cubit as MallsCubit).items;
    } else if (cubit is ServiceProviderCubit) {
      items = (cubit as ServiceProviderCubit).items;
    } else {
      items = cubit.items;
    }

    // Apply filters
    return _applyFilters(items);
  }

  List<dynamic> _applyFilters(List<dynamic> items) {
    if (!_filterState.hasActiveFilters) {
      return items;
    }

    return items.where((item) {
      // Apply search filter
      if (_filterState.searchQuery.isNotEmpty) {
        final query = _filterState.searchQuery.toLowerCase();
        final name = (item.name ?? '').toLowerCase();
        final description = (item.description ?? '').toLowerCase();

        bool matchesSearch =
            name.contains(query) || description.contains(query);

        // Add entity-specific search fields
        if (item is ServiceProviderModel) {
          final phone = (item.phone ?? '').toLowerCase();
          final serviceName = (item.service?.name ?? '').toLowerCase();
          matchesSearch = matchesSearch ||
              phone.contains(query) ||
              serviceName.contains(query);
        } else if (item is Providers) {
          final phone = (item.phone ?? '').toLowerCase();
          matchesSearch = matchesSearch || phone.contains(query);
        } else if (item is Villages) {
          final location = (item.location ?? '').toLowerCase();
          matchesSearch = matchesSearch || location.contains(query);
        }

        if (!matchesSearch) return false;
      }

      // Apply status filter
      if (_filterState.statusFilter != null) {
        final itemStatus = item.status;
        if (itemStatus != _filterState.statusFilter) return false;
      }

      // Apply zone filter
      if (_filterState.zoneFilter != null) {
        final itemZoneId = item is Villages
            ? item.zoneId?.toInt()
            : item is MallModel
                ? item.zoneId?.toInt()
                : item is ServiceProviderModel
                    ? item.zoneId?.toInt()
                    : null;
        if (itemZoneId != _filterState.zoneFilter) return false;
      }

      // Apply village filter
      if (_filterState.villageFilter != null) {
        final itemVillageId = item is ServiceProviderModel
            ? item.villageId?.toInt()
            : item is Providers
                ? item.villageId?.toInt()
                : null;
        if (itemVillageId != _filterState.villageFilter) return false;
      }

      // Apply service type filter
      if (_filterState.serviceTypeFilter != null &&
          item is ServiceProviderModel) {
        if (item.service?.id != _filterState.serviceTypeFilter) return false;
      }

      // Apply maintenance type filter
      if (_filterState.maintenanceTypeFilter != null && item is Providers) {
        if (item.maintenanceTypeId?.toInt() !=
            _filterState.maintenanceTypeFilter) return false;
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
      create: (context) => widget.cubit..getData(),
      child: BlocConsumer<C, S>(
        listener: (BuildContext context, S state) {
          if (_isErrorState(state)) {
            showErrorToast(context, _getErrorMessage(state));
          } else if (state is MallsAddSuccessState) {
            showSuccessToast(context, state.successMessage);
          } else if (state is VillageAddSuccessState) {
            showSuccessToast(context, "Village added successfully.");
          } else if (state is ServiceProviderAddSuccessState) {
            showSuccessToast(context, state.message);
          } else if (state is MaintenanceAddSuccessState) {
            showSuccessToast(
                context, "Maintenance Provider added successfully.");
          }
          if (_isSuccessState(state)) {
            _expandedCards.clear();
          }
        },
        builder: (BuildContext context, S state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              title: Text(widget.title),
            ),
            body: Builder(
              builder: (context) {
                if (_isLoadingState(state)) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: WegoColors.mainColor,
                    ),
                  );
                }

                if (_isSuccessState(state)) {
                  final cubit = context.read<C>();

                  return Column(
                    children: [
                      // Filter Widget
                      EntityFilterWidget(
                        entityType: _getEntityType(),
                        initialFilters: _filterState,
                        onFiltersChanged: _onFiltersChanged,
                        cubit: cubit,
                      ),

                      // Content
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            // Get the appropriate items list (filtered or all items)
                            List<dynamic> items = _getFilteredItems(cubit);

                            if (items.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                        _filterState.hasActiveFilters
                                            ? 'No items match your filters'
                                            : 'No items found',
                                        style: TextStyle(fontSize: 18)),
                                    if (_filterState.hasActiveFilters) ...[
                                      SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          _onFiltersChanged(
                                              const FilterState());
                                        },
                                        child: Text('Clear filters'),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }

                            return RefreshIndicator(
                              color: WegoColors.mainColor,
                              onRefresh: () => context.read<C>().getData(),
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final isExpanded =
                                      _expandedCards.contains(index);
                                  if (item is MallModel) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _toggleCardExpansion(index),
                                        child: ExpandableCard<MallItem>(
                                          item: MallItem(item),
                                          index: index,
                                          isGrid: false,
                                          isTablet: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              600,
                                          isDesktop: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              1024,
                                          isExpanded: isExpanded,
                                          itemTypeName: 'Mall',
                                          onEdit: (mallItem) {
                                            showEditDialog(
                                                context, item, cubit);
                                          },
                                          onDelete: (mallItem) async {
                                            cubit.deleteData(item.id);
                                          },
                                        ),
                                      ),
                                    );
                                  } else if (item is Villages) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _toggleCardExpansion(index),
                                        child: ExpandableCard<VillageItem>(
                                          item: VillageItem(item),
                                          index: index,
                                          isGrid: false,
                                          isTablet: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              600,
                                          isDesktop: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              1024,
                                          isExpanded: isExpanded,
                                          itemTypeName: 'Village',
                                          onEdit: (villageItem) {
                                            showEditDialog(
                                                context, item, cubit);
                                          },
                                          onDelete: (villageItem) async {
                                            cubit.deleteData(item.id!);
                                          },
                                        ),
                                      ),
                                    );
                                  } else if (item is ServiceProviderModel) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _toggleCardExpansion(index),
                                        child:
                                            ExpandableCard<ServiceProviderItem>(
                                          item: ServiceProviderItem(item),
                                          index: index,
                                          isGrid: false,
                                          isTablet: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              600,
                                          isDesktop: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              1024,
                                          isExpanded: isExpanded,
                                          itemTypeName: 'Service Provider',
                                          onEdit: (serviceProviderItem) {
                                            showEditDialog(
                                                context, item, cubit);
                                          },
                                          onDelete:
                                              (serviceProviderItem) async {
                                            cubit.deleteData(item.id);
                                          },
                                        ),
                                      ),
                                    );
                                  } else if (item is Providers) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _toggleCardExpansion(index),
                                        child: ExpandableCard<
                                            MaintenanceProviderItem>(
                                          item: MaintenanceProviderItem(item),
                                          index: index,
                                          isGrid: false,
                                          isTablet: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              600,
                                          isDesktop: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              1024,
                                          isExpanded: isExpanded,
                                          itemTypeName: 'Maintenance Provider',
                                          onEdit: (serviceProviderItem) {
                                            showEditDialog(
                                                context, item, cubit);
                                          },
                                          onDelete:
                                              (serviceProviderItem) async {
                                            cubit.deleteData(item.id!);
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return Center(child: Text('No data'));
              },
            ),
            floatingActionButton: _isLoadingState(state)
                ? null
                : FloatingActionButton.extended(
                    onPressed: () {
                      final cubit = context.read<C>();
                      dynamic templateItem;

                      if (cubit is VillageCubit) {
                        templateItem = Villages();
                      } else if (cubit is MallsCubit) {
                        templateItem = MallModel.empty();
                      } else if (cubit is ServiceProviderCubit) {
                        templateItem = ServiceProviderModel.empty();
                      } else if (cubit is MaintenanceCubit) {
                        templateItem = Providers();
                      } else {
                        print(
                            'Error: Could not create a template for unhandled cubit type ${cubit.runtimeType}');
                        // Optionally, show an error to the user
                        showErrorToast(
                            context, 'Cannot add item: Unhandled entity type.');
                        return;
                      }
                      showAddDialog(context, templateItem, cubit);
                    },
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
          );
        },
      ),
    );
  }
}
