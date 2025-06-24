import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Core/images_url.dart';
import 'package:sa7el/Core/text_styles.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_cubit.dart';
import 'package:sa7el/views/Home/admin_services/maintenance_providers/maintenance_provider_screen.dart';
import 'package:sa7el/views/Home/admin_services/services_provider_screen.dart';
import 'package:sa7el/views/Home/admin_services/village/village_page.dart';
import 'package:sa7el/views/Home/screens/entity_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(WegoImages.fakephoto),
                  ),
                  SizedBox(width: width * 0.02),
                  const Text(
                    'Hello Ahmed',
                    style: WegoTextStyles.welcomeTextStyle,
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildStatCard(
                      count: '12',
                      label: 'Malls',
                      subtitle: "Malls",
                      color: WegoColors.mainColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildStatCard(
                      count: '25',
                      label: 'Providers',
                      subtitle: 'Service Providers',
                      color: WegoColors.mainColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildStatCard(
                      count: '18',
                      label: 'Providers',
                      subtitle: 'Maintenance Providers',
                      color: WegoColors.mainColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildStatCard(
                      count: '9',
                      label: 'Villages',
                      subtitle: 'Registered Villages',
                      color: WegoColors.mainColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              // Navigation Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  children: [
                    _buildNavCard(
                      height: height,
                      icon: Icons.store_mall_directory,
                      label: 'Mall',
                      onTap: () => _navigateTo(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntityListScreen(
                            cubit: MallsCubit(),
                            title: 'Malls',
                          ),
                        ),
                      ),
                    ),
                    _buildNavCard(
                      height: height,
                      icon: Icons.handshake,
                      label: 'Service Provider',
                      onTap: () => _navigateTo(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntityListScreen(
                            cubit: ServiceProviderCubit(),
                            title: 'Service Providers',
                          ),
                        ),
                      ),
                    ),
                    _buildNavCard(
                      height: height,
                      icon: Icons.build,
                      label: 'Maintenance Provider',
                      onTap: () => _navigateTo(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntityListScreen(
                            cubit: MaintenanceCubit(),
                            title: 'Maintenance Providers',
                          ),
                        ),
                      ),
                    ),
                    _buildNavCard(
                      height: height,
                      icon: Icons.apartment,
                      label: 'Village',
                      onTap: () => _navigateTo(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntityListScreen(
                            cubit: VillageCubit(),
                            title: 'Villages',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    String? subtitle,
    required Color color,
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
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
  }) {
    return SizedBox(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WegoColors.mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: const Color(0xFF2DD4BF)),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2DD4BF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, MaterialPageRoute destination) {
    Navigator.of(context).push(destination);
  }
}
