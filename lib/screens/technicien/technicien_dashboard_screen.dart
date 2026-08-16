import 'package:flutter/material.dart';
import 'technicien_drawer.dart';
import '../../theme/app_theme.dart';
import '../../services/tache_service.dart';
import '../../models/tache_model.dart';

class TechnicienDashboardScreen extends StatefulWidget {
  const TechnicienDashboardScreen({super.key});

  @override
  State<TechnicienDashboardScreen> createState() => _TechnicienDashboardScreenState();
}

class _TechnicienDashboardScreenState extends State<TechnicienDashboardScreen> {
  final _tacheService = TacheService();
  List<TacheModel> _taches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaches();
  }

  Future<void> _loadTaches() async {
    setState(() => _isLoading = true);
    try {
      final taches = await _tacheService.getMesTaches(); // Le backend filtrera automatiquement
      setState(() {
        _taches = taches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  int get _totalTaches => _taches.length;
  int get _enCours => _taches.where((t) => t.statut == 'EN_COURS').length;
  int get _aFaire => _taches.where((t) => t.statut == 'A_FAIRE').length;
  int get _terminees => _taches.where((t) => t.statut == 'TERMINE').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const TechnicienDrawer(currentRoute: '/technicien-dashboard'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Tableau de bord',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.orange),
            onPressed: _loadTaches,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message de bienvenue
                  const Text(
                    'Bonjour, Technicien 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Voici le résumé de vos interventions.',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Statistiques
                  Row(
                    children: [
                      _buildStatCard('Total', '$_totalTaches', Colors.blue, Icons.task),
                      const SizedBox(width: 12),
                      _buildStatCard('En cours', '$_enCours', Colors.orange, Icons.pending_actions),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard('À faire', '$_aFaire', Colors.red, Icons.warning),
                      const SizedBox(width: 12),
                      _buildStatCard('Terminées', '$_terminees', Colors.green, Icons.check_circle),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Interventions récentes
                  const Text(
                    'Interventions en cours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  if (_taches.where((t) => t.statut == 'EN_COURS' || t.statut == 'A_FAIRE').isEmpty)
                    const Center(
                      child: Text('Aucune intervention en cours', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ..._taches.where((t) => t.statut == 'EN_COURS' || t.statut == 'A_FAIRE').take(3).map((tache) {
                      return _buildTacheCard(tache);
                    }).toList(),

                  const SizedBox(height: 24),

                  // Bouton vers toutes les interventions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/technicien-interventions');
                      },
                      icon: const Icon(Icons.build),
                      label: const Text('Voir toutes mes interventions', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTacheCard(TacheModel tache) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tache.statut == 'EN_COURS' ? Colors.blue[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tache.statut == 'EN_COURS' ? 'En cours' : 'À faire',
                    style: TextStyle(
                      color: tache.statut == 'EN_COURS' ? Colors.blue[800] : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPrioriteColor(tache.priorite).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tache.priorite,
                    style: TextStyle(
                      color: _getPrioriteColor(tache.priorite),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tache.titre,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.elevator, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tache.ascenseurNom ?? 'Ascenseur inconnu',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
            if (tache.dateEcheance != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    'Échéance: ${tache.dateEcheance!.day}/${tache.dateEcheance!.month}/${tache.dateEcheance!.year}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPrioriteColor(String priorite) {
    switch (priorite) {
      case 'URGENTE':
        return Colors.red;
      case 'HAUTE':
        return Colors.orange;
      case 'MOYENNE':
        return Colors.blue;
      case 'BASSE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}