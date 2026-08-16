import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../theme/app_theme.dart';

class ResponsableDrawer extends StatelessWidget {
  final String currentRoute;

  const ResponsableDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.navy,
        child: Column(
          children: [
            // Header avec logo
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.navy,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.build, size: 60, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SPELEV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Espace Responsable',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.dashboard, 'Tableau de bord', '/responsable-dashboard', context),
                  
                  _buildMenuItem(Icons.report_problem_outlined, 'Demandes en attente', '/responsable-demandes-attente', context),
                  
                  _buildMenuItem(Icons.elevator, 'Ascenseurs', '/responsable-ascenseur-list', context),
                  _buildMenuItem(Icons.business, 'Sites', '/responsable-site-list', context),
                  _buildMenuItem(Icons.location_city, 'Parcs', '/responsable-parc-list', context),
                  _buildMenuItem(Icons.build, 'Interventions (BT)', '/responsable-interventions', context),
                  _buildMenuItem(Icons.engineering, 'Techniciens', '/responsable-techniciens', context),
                  _buildMenuItem(Icons.task, 'Mes tâches', '/responsable-mes-taches', context),
                ],
              ),
            ),

            // Déconnexion
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () async {
                  final storage = const FlutterSecureStorage();
                  await storage.delete(key: 'jwt_token');
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String route, BuildContext context) {
    final isActive = route == currentRoute;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.orange : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.orange : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? Colors.white.withOpacity(0.1) : null,
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}