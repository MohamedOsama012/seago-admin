import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Core/images_url.dart';
import 'package:sa7el/Core/text_styles.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Cubit/authentication/auth_cubit.dart';
import 'package:sa7el/Cubit/authentication/auth_state.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_cubit.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_state.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_states.dart';
import 'package:sa7el/views/Home/screens/entity_list_screen.dart';
import 'package:sa7el/views/Authentication/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationCubit>().getAdminData();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthenticationCubit, AuthenticationStates>(
            listener: (context, state) {
              if (state is AuthenticationLoginStateFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Error loading user data: ${state.errMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is AuthenticationLogoutState) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          BlocListener<MallsCubit, MallsStates>(
            listener: (context, state) {
              if (state is MallsGetDataErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading malls: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<ServiceProviderCubit, ServiceProviderStates>(
            listener: (context, state) {
              if (state is ServiceProviderGetDataErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error loading service providers'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<MaintenanceCubit, MaintenanceStates>(
            listener: (context, state) {
              if (state is MaintenanceErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error loading maintenance providers: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<VillageCubit, VillageStates>(
            listener: (context, state) {
              if (state is VillageErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading villages: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    BlocBuilder<AuthenticationCubit, AuthenticationStates>(
                      builder: (context, authState) {
                        final userModel =
                            context.read<AuthenticationCubit>().userModel;
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: userModel?.image != null &&
                                      userModel!.image!.isNotEmpty
                                  ? NetworkImage(userModel.image!)
                                  : const NetworkImage(WegoImages.fakephoto),
                              child: userModel?.image == null ||
                                      userModel!.image!.isEmpty
                                  ? authState is AuthenticationLoginStateLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.person,
                                          color: Colors.grey)
                                  : null,
                            ),
                            SizedBox(width: width * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello ${userModel?.name ?? 'Admin'}',
                                  style: WegoTextStyles.welcomeTextStyle,
                                ),
                                if (authState
                                    is AuthenticationLoginStateLoading)
                                  const Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: WegoColors.mainColor,
                      ),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),

                // Stats Cards with Loading States
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: BlocBuilder<MallsCubit, MallsStates>(
                        builder: (context, state) {
                          return _buildStatCard(
                            count: _isLoadingState(state)
                                ? null
                                : context
                                    .read<MallsCubit>()
                                    .items
                                    .length
                                    .toString(),
                            label: 'Malls',
                            subtitle: "Malls",
                            color: WegoColors.mainColor,
                            isLoading: _isLoadingState(state),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: BlocBuilder<ServiceProviderCubit,
                          ServiceProviderStates>(
                        builder: (context, state) {
                          return _buildStatCard(
                            count: _isLoadingState(state)
                                ? null
                                : context
                                    .read<ServiceProviderCubit>()
                                    .items
                                    .length
                                    .toString(),
                            label: 'Providers',
                            subtitle: 'Service Providers',
                            color: WegoColors.mainColor,
                            isLoading: _isLoadingState(state),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: BlocBuilder<MaintenanceCubit, MaintenanceStates>(
                        builder: (context, state) {
                          return _buildStatCard(
                            count: _isLoadingState(state)
                                ? null
                                : context
                                    .read<MaintenanceCubit>()
                                    .items
                                    .length
                                    .toString(),
                            label: 'Providers',
                            subtitle: 'Maintenance Providers',
                            color: WegoColors.mainColor,
                            isLoading: _isLoadingState(state),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: BlocBuilder<VillageCubit, VillageStates>(
                        builder: (context, state) {
                          return _buildStatCard(
                            count: _isLoadingState(state)
                                ? null
                                : context
                                    .read<VillageCubit>()
                                    .items
                                    .length
                                    .toString(),
                            label: 'Villages',
                            subtitle: 'Registered Villages',
                            color: WegoColors.mainColor,
                            isLoading: _isLoadingState(state),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),

                // Navigation Grid
                Expanded(
                  child: BlocBuilder<MallsCubit, MallsStates>(
                    builder: (context, mallsState) {
                      return BlocBuilder<ServiceProviderCubit,
                          ServiceProviderStates>(
                        builder: (context, serviceState) {
                          return BlocBuilder<MaintenanceCubit,
                              MaintenanceStates>(
                            builder: (context, maintenanceState) {
                              return BlocBuilder<VillageCubit, VillageStates>(
                                builder: (context, villageState) {
                                  final isAnyLoading =
                                      _isLoadingState(mallsState) ||
                                          _isLoadingState(serviceState) ||
                                          _isLoadingState(maintenanceState) ||
                                          _isLoadingState(villageState);

                                  return GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 20,
                                    children: [
                                      _buildNavCard(
                                        height: height,
                                        icon: Icons.store_mall_directory,
                                        label: 'Mall',
                                        isEnabled: !isAnyLoading,
                                        onTap: () async {
                                          await _navigateTo(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EntityListScreen(
                                                cubit: MallsCubit(),
                                                title: 'Malls',
                                              ),
                                            ),
                                          );
                                          context.read<MallsCubit>().getData();
                                        },
                                      ),
                                      _buildNavCard(
                                        height: height,
                                        icon: Icons.handshake,
                                        label: 'Service Provider',
                                        isEnabled: !isAnyLoading,
                                        onTap: () async {
                                          await _navigateTo(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EntityListScreen(
                                                cubit: ServiceProviderCubit(),
                                                title: 'Service Providers',
                                              ),
                                            ),
                                          );
                                          context
                                              .read<ServiceProviderCubit>()
                                              .getData();
                                        },
                                      ),
                                      _buildNavCard(
                                        height: height,
                                        icon: Icons.build,
                                        label: 'Maintenance Provider',
                                        isEnabled: !isAnyLoading,
                                        onTap: () async {
                                          await _navigateTo(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EntityListScreen(
                                                cubit: MaintenanceCubit(),
                                                title: 'Maintenance Providers',
                                              ),
                                            ),
                                          );
                                          context
                                              .read<MaintenanceCubit>()
                                              .getData();
                                        },
                                      ),
                                      _buildNavCard(
                                        height: height,
                                        icon: Icons.apartment,
                                        label: 'Village',
                                        isEnabled: !isAnyLoading,
                                        onTap: () async {
                                          await _navigateTo(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EntityListScreen(
                                                cubit: VillageCubit(),
                                                title: 'Villages',
                                              ),
                                            ),
                                          );
                                          context
                                              .read<VillageCubit>()
                                              .getData();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to check if any state is loading
  bool _isLoadingState(dynamic state) {
    return state is MallsGetDataLoadingState ||
        state is VillaLoadingState ||
        state is ServiceProviderGetDataLoadingState ||
        state is MaintenanceLoadingState;
  }

  Widget _buildStatCard({
    String? count,
    required String label,
    String? subtitle,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 50,
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              count ?? '0',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double height,
    bool isEnabled = true,
  }) {
    return SizedBox(
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(isEnabled ? 0.1 : 0.05),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WegoColors.mainColor
                        .withOpacity(isEnabled ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isEnabled
                        ? const Color(0xFF2DD4BF)
                        : const Color(0xFF2DD4BF).withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? const Color(0xFF2DD4BF)
                        : const Color(0xFF2DD4BF).withOpacity(0.5),
                  ),
                ),
                if (!isEnabled) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF2DD4BF).withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateTo(
      BuildContext context, MaterialPageRoute destination) async {
    await Navigator.of(context).push(destination);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<AuthenticationCubit, AuthenticationStates>(
          builder: (context, state) {
            final isLoggingOut = state is AuthenticationLoginStateLoading;

            return AlertDialog(
              title: const Text('Logout'),
              content: isLoggingOut
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Logging out...'),
                      ],
                    )
                  : const Text('Are you sure you want to logout?'),
              actions: isLoggingOut
                  ? null
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthenticationCubit>().logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}
