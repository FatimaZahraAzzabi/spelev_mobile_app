import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

// Écrans globaux
import 'screens/login_screen.dart';

// Écrans Admin
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_user_list_screen.dart';
import 'screens/admin/admin_user_form_screen.dart';
import 'screens/admin/admin_taches_screen.dart';
import 'screens/admin/nouvelle_tache_screen.dart';

// Écrans Responsable
import 'screens/responsable/responsable_dashboard_screen.dart'; 
import 'screens/responsable/ascenseur_list_screen.dart';
import 'screens/responsable/nouvel_ascenseur_screen.dart';
import 'screens/responsable/site_list_screen.dart';
import 'screens/responsable/nouveau_site_screen.dart';
import 'screens/responsable/mes_taches_screen.dart';
import 'screens/responsable/parc_list_screen.dart';
import 'screens/responsable/nouveau_parc_screen.dart';
import 'screens/responsable/demandes_en_attente_screen.dart';

// Écrans Technicien
import 'screens/technicien/technicien_dashboard_screen.dart';
import 'screens/technicien/technicien_taches_screen.dart';
import 'screens/technicien/checklist_intervention_screen.dart';
import 'screens/technicien/technicien_interventions_list_screen.dart'; 

// Écrans Client
import 'screens/client/client_dashboard_screen.dart';
import 'screens/client/nouvelle_demande_screen.dart';
import 'screens/client/client_ascenseurs_screen.dart';
import 'screens/client/client_demandes_screen.dart';
import 'screens/client/client_profil_screen.dart';
import 'screens/client/demande_detail_screen.dart';
import 'screens/client/nouvelle_evaluation_screen.dart';

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
        '/admin-taches': (context) => const AdminTachesScreen(),
        
        // Routes Technicien
        '/technicien-dashboard': (context) => const TechnicienDashboardScreen(),
        '/technicien-taches': (context) => const TechnicienTachesScreen(),
        '/technicien-interventions': (context) => const TechnicienInterventionsListScreen(), 
        
        // Routes Client
        '/client-dashboard': (context) => const ClientDashboardScreen(),
        '/client-ascenseurs': (context) => const ClientAscenseursScreen(),
        '/client-demandes': (context) => const ClientDemandesScreen(),
        '/client-profil': (context) => const ClientProfilScreen(),
        '/client-nouvelle-demande': (context) => const NouvelleDemandeScreen(),
        '/client-nouvelle-evaluation': (context) => const NouvelleEvaluationScreen(),
        
        // Routes Responsable
        '/responsable-dashboard': (context) => const ResponsableDashboardScreen(),
        '/responsable-ascenseur-list': (context) => const AscenseurListScreen(),
        '/responsable-nouvel-ascenseur': (context) => const NouvelAscenseurScreen(),
        '/responsable-site-list': (context) => const SiteListScreen(),
        '/responsable-nouveau-site': (context) => const NouveauSiteScreen(),
        '/responsable-mes-taches': (context) => const MesTachesScreen(),
        '/responsable-parc-list': (context) => const ParcListScreen(),
        '/responsable-nouveau-parc': (context) => const NouveauParcScreen(),
        '/responsable-demandes-attente': (context) => const DemandesEnAttenteScreen(), 
      },
      onGenerateRoute: (settings) {
        // Gestion de la route avec paramètre pour le détail d'une demande
        if (settings.name == '/client-demande-detail') {
          final demandeId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => DemandeDetailScreen(demandeId: demandeId),
          );
        }
        return null;
      },
    );
  }
}