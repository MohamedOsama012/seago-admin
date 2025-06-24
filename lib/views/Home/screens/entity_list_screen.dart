import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
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
    if (state is ServiceProviderGetDataErrorState)
      return 'Failed to load service providers';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
      create: (context) => widget.cubit..getData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: Text(widget.title),
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
        body: BlocConsumer<C, S>(
          listener: (context, state) {
            if (_isErrorState(state)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getErrorMessage(state)),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is MallsAddSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.successMessage),
                backgroundColor: Colors.green,
              ));
            } else if (state is VillageAddSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Village added successfully."),
                backgroundColor: Colors.green,
              ));
            } else if (state is ServiceProviderAddSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ));
            } else if (state is MaintenanceAddSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Maintenance Provider added successfully."),
                backgroundColor: Colors.green,
              ));
            }
            if (_isSuccessState(state)) {
              _expandedCards.clear();
            }
          },
          builder: (context, state) {
            if (_isLoadingState(state)) {
              return Center(
                child: CircularProgressIndicator(
                  color: WegoColors.mainColor,
                ),
              );
            }

            if (_isSuccessState(state)) {
              final cubit = context.read<C>();
              if (cubit.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No items found', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              }

              final items = cubit.items;
              return RefreshIndicator(
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
                            isTablet: MediaQuery.of(context).size.width > 600,
                            isDesktop: MediaQuery.of(context).size.width > 1024,
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
                            isTablet: MediaQuery.of(context).size.width > 600,
                            isDesktop: MediaQuery.of(context).size.width > 1024,
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
                            isTablet: MediaQuery.of(context).size.width > 600,
                            isDesktop: MediaQuery.of(context).size.width > 1024,
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
                            isTablet: MediaQuery.of(context).size.width > 600,
                            isDesktop: MediaQuery.of(context).size.width > 1024,
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
        floatingActionButton: FloatingActionButton.extended(
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot add item: Unhandled entity type.'),
                  backgroundColor: Colors.red,
                ),
              );
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
