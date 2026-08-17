import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../theme/app_theme.dart';

class ClientDrawer extends StatelessWidget {
  final String currentRoute;
  const ClientDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.navy,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.dashboard, 'Tableau de bord', '/client-dashboard', context),
                  _buildMenuItem(Icons.elevator, 'Mes Ascenseurs', '/client-ascenseurs', context),
                  _buildMenuItem(Icons.report_problem, 'Mes Demandes', '/client-demandes', context),
                 _buildMenuItem(Icons.request_quote, 'Demande d\'évaluation', '/client-nouvelle-evaluation', context),
                  _buildMenuItem(Icons.person, 'Mon Profil', '/client-profil', context),
                ],
              ),
            ),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.navy,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Image.asset(
              'assets/images/logo.png',
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.build, size: 60, color: AppColors.navy),
            ),
          ),
          const SizedBox(height: 12),
          const Text('SPELEV', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Espace Client', style: TextStyle(color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
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

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
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
        label: const Text('Déconnexion', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(alignment: Alignment.centerLeft),
      ),
    );
  }
}