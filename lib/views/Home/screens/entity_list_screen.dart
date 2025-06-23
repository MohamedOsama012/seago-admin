import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_states.dart';
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/Model/village_model.dart';
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/views/Home/Widgets/expandable_container_widget.dart';

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
        state is ServiceProviderGetDataLoadingState;
  }

  bool _isSuccessState(S state) {
    return state is MallsGetDataSuccessState ||
        state is VillageSuccessState ||
        state is VillageFilteredState ||
        state is VillageSearchState ||
        state is ServiceProviderGetDataSuccessState;
  }

  bool _isErrorState(S state) {
    return state is MallsGetDataErrorState ||
        state is VillageErrorState ||
        state is ServiceProviderGetDataErrorState;
  }

  String _getErrorMessage(S state) {
    if (state is MallsGetDataErrorState) {
      return state.error;
    } else if (state is VillageErrorState) {
      return state.error;
    } else if (state is ServiceProviderGetDataErrorState) {
      return 'Failed to load service providers';
    }
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
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => context.read<C>().getData(),
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
                              showMallEditDialog(context, item, cubit);
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
                              showEditDialog(
                                  context, villageItem, 'Village', cubit);
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
                              showEditDialog(context, serviceProviderItem,
                                  'Service Provider', cubit);
                            },
                            onDelete: (serviceProviderItem) async {
                              cubit.deleteData(item.id);
                            },
                          ),
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text(item.toString()),
                        subtitle: Text('Unsupported item type'),
                      );
                    }
                  },
                ),
              );
            }

            return Center(child: Text('No data'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.read<C>().getData(),
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }

  // Future<bool?> _showDeleteDialog(BuildContext context, T item) {
  //   return showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Delete Item'),
  //       content: Text('Are you sure you want to delete this item?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(true),
  //           child: Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
