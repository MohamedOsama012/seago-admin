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

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

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

  void _performSearch(String query, C cubit) {
    if (query.isEmpty) {
      _clearSearch(cubit);
      return;
    }

    if (cubit is VillageCubit) {
      (cubit as VillageCubit).searchVillages(query);
    } else if (cubit is MaintenanceCubit) {
      (cubit as MaintenanceCubit).searchProviders(query);
    } else if (cubit is MallsCubit) {
      (cubit as MallsCubit).searchMalls(query);
    } else if (cubit is ServiceProviderCubit) {
      // Implement local search for ServiceProviderCubit
      _localSearchServiceProviders(query, cubit as ServiceProviderCubit);
    }
  }

  void _localSearchServiceProviders(String query, ServiceProviderCubit cubit) {
    // This is a local implementation since ServiceProviderCubit doesn't have search method
    // We don't trigger any state changes, just update display
    setState(() {
      // The search will be handled in the UI by filtering cubit.items
    });
  }

  // Get the appropriate items list based on cubit type and current state
  List<dynamic> _getDisplayItems(C cubit) {
    if (cubit is VillageCubit) {
      final villageCubit = cubit as VillageCubit;
      // Use filteredVillages if available, otherwise use items
      return villageCubit.filteredVillages.isNotEmpty || _isSearchActive
          ? villageCubit.filteredVillages
          : villageCubit.items;
    } else if (cubit is MaintenanceCubit) {
      final maintenanceCubit = cubit as MaintenanceCubit;
      // Use filteredProviders if available, otherwise use items
      return maintenanceCubit.filteredProviders.isNotEmpty || _isSearchActive
          ? maintenanceCubit.filteredProviders
          : maintenanceCubit.items;
    } else if (cubit is MallsCubit) {
      final mallsCubit = cubit as MallsCubit;
      // Use filteredMalls if available, otherwise use items
      return mallsCubit.filteredMalls.isNotEmpty || _isSearchActive
          ? mallsCubit.filteredMalls
          : mallsCubit.items;
    } else if (cubit is ServiceProviderCubit) {
      final serviceProviderCubit = cubit as ServiceProviderCubit;
      // Implement local filtering for ServiceProviderCubit
      if (_isSearchActive && _searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        return serviceProviderCubit.items.where((provider) {
          final name = provider.name?.toLowerCase() ?? '';
          final description = provider.description?.toLowerCase() ?? '';
          final phone = provider.phone?.toLowerCase() ?? '';
          final serviceName = provider.service?.name?.toLowerCase() ?? '';

          return name.contains(query) ||
              description.contains(query) ||
              phone.contains(query) ||
              serviceName.contains(query);
        }).toList();
      }
      return serviceProviderCubit.items;
    }

    // Fallback to items if no specific handling
    return cubit.items;
  }

  void _clearSearch(C cubit) {
    if (cubit is VillageCubit) {
      (cubit as VillageCubit).clearFilter();
    } else if (cubit is MaintenanceCubit) {
      (cubit as MaintenanceCubit).clearFilter();
    } else if (cubit is MallsCubit) {
      (cubit as MallsCubit).resetFilters();
    } else if (cubit is ServiceProviderCubit) {
      // For ServiceProvider, just trigger a setState to refresh UI
      setState(() {
        // This will reset the local filtering
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              title: _isSearchActive
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.title.toLowerCase()}...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      onChanged: (value) {
                        _performSearch(value, context.read<C>());
                      },
                    )
                  : Text(widget.title),
              actions: [
                IconButton(
                  icon: Icon(_isSearchActive ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = !_isSearchActive;
                      if (!_isSearchActive) {
                        _searchController.clear();
                        _clearSearch(context.read<C>());
                      }
                    });
                  },
                ),
              ],
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

                  // Get the appropriate items list (filtered or all items)
                  List<dynamic> items = _getDisplayItems(cubit);

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                              _isSearchActive
                                  ? 'No search results found'
                                  : 'No items found',
                              style: TextStyle(fontSize: 18)),
                          if (_isSearchActive) ...[
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isSearchActive = false;
                                  _searchController.clear();
                                });
                                _clearSearch(cubit);
                              },
                              child: Text('Clear search'),
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
                        final isExpanded = _expandedCards.contains(index);
                        if (item is MallModel) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: GestureDetector(
                              onTap: () => _toggleCardExpansion(index),
                              child: ExpandableCard<MallItem>(
                                item: MallItem(item),
                                index: index,
                                isGrid: false,
                                isTablet:
                                    MediaQuery.of(context).size.width > 600,
                                isDesktop:
                                    MediaQuery.of(context).size.width > 1024,
                                isExpanded: isExpanded,
                                itemTypeName: 'Mall',
                                onEdit: (mallItem) {
                                  showEditDialog(context, item, cubit);
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
                              onTap: () => _toggleCardExpansion(index),
                              child: ExpandableCard<VillageItem>(
                                item: VillageItem(item),
                                index: index,
                                isGrid: false,
                                isTablet:
                                    MediaQuery.of(context).size.width > 600,
                                isDesktop:
                                    MediaQuery.of(context).size.width > 1024,
                                isExpanded: isExpanded,
                                itemTypeName: 'Village',
                                onEdit: (villageItem) {
                                  showEditDialog(context, item, cubit);
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
                              onTap: () => _toggleCardExpansion(index),
                              child: ExpandableCard<ServiceProviderItem>(
                                item: ServiceProviderItem(item),
                                index: index,
                                isGrid: false,
                                isTablet:
                                    MediaQuery.of(context).size.width > 600,
                                isDesktop:
                                    MediaQuery.of(context).size.width > 1024,
                                isExpanded: isExpanded,
                                itemTypeName: 'Service Provider',
                                onEdit: (serviceProviderItem) {
                                  showEditDialog(context, item, cubit);
                                },
                                onDelete: (serviceProviderItem) async {
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
                              onTap: () => _toggleCardExpansion(index),
                              child: ExpandableCard<MaintenanceProviderItem>(
                                item: MaintenanceProviderItem(item),
                                index: index,
                                isGrid: false,
                                isTablet:
                                    MediaQuery.of(context).size.width > 600,
                                isDesktop:
                                    MediaQuery.of(context).size.width > 1024,
                                isExpanded: isExpanded,
                                itemTypeName: 'Maintenance Provider',
                                onEdit: (serviceProviderItem) {
                                  showEditDialog(context, item, cubit);
                                },
                                onDelete: (serviceProviderItem) async {
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
