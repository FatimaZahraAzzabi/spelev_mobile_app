import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/responsable/ascenseur_list_screen.dart';
import 'screens/responsable/nouvel_ascenseur_screen.dart';
// Écrans globaux
import 'screens/login_screen.dart';
import 'screens/responsable/site_list_screen.dart';
import 'screens/responsable/nouveau_site_screen.dart';

// Écrans Admin
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_user_list_screen.dart';
import 'screens/admin/admin_user_form_screen.dart';
import 'screens/admin/admin_taches_screen.dart';

// Écrans autres rôles
import 'screens/technicien/technicien_dashboard_screen.dart';
import 'screens/technicien/technicien_taches_screen.dart';
import 'screens/technicien/checklist_intervention_screen.dart';

import 'screens/client/client_dashboard_screen.dart';
import 'screens/responsable/responsable_dashboard_screen.dart'; 

import 'screens/admin/nouvelle_tache_screen.dart';
import 'screens/responsable/mes_taches_screen.dart';

import 'screens/responsable/parc_list_screen.dart';
import 'screens/responsable/nouveau_parc_screen.dart';
import 'screens/responsable/demandes_en_attente_screen.dart';

import 'screens/client/client_dashboard_screen.dart';
import 'screens/client/nouvelle_demande_screen.dart';


void main() => runApp(const SpelevApp());

class SpelevApp extends StatelessWidget {
  const SpelevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPELEV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        
        // Routes Admin
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-users': (context) => const AdminUserListScreen(),
        '/admin-user-form': (context) => const AdminUserFormScreen(),
        
        // Routes Technicien
        '/technicien-dashboard': (context) => const TechnicienDashboardScreen(),
        
        // Routes Client
        '/client-dashboard': (context) => const ClientDashboardScreen(),

        // Routes Responsable
        '/responsable-ascenseur-list': (context) => const AscenseurListScreen(),
        '/responsable-nouvel-ascenseur': (context) => const NouvelAscenseurScreen(),
        '/responsable-dashboard': (context) => const ResponsableDashboardScreen(),
         '/responsable-site-list': (context) => const SiteListScreen(),
        '/responsable-nouveau-site': (context) => const NouveauSiteScreen(),
        '/responsable-mes-taches': (context) => const MesTachesScreen(),
        '/admin-taches': (context) => const AdminTachesScreen(),
        '/technicien-taches': (context) => const TechnicienTachesScreen(),

        '/responsable-parc-list': (context) => const ParcListScreen(),
        '/responsable-nouveau-parc': (context) => const NouveauParcScreen(),


         '/client-dashboard': (context) => const ClientDashboardScreen(),
        '/client-demandes': (context) => const NouvelleDemandeScreen(),


        '/responsable-demandes-attente': (context) => const DemandesEnAttenteScreen(), 

        
        '/technicien-interventions': (context) => const TechnicienInterventionsListScreen(),

      },
    );
  }
}