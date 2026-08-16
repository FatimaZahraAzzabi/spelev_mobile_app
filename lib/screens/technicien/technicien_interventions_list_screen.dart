import 'package:flutter/material.dart';
import '../../services/bon_travail_service.dart';
import '../../models/bon_travail_model.dart';
import 'technicien_drawer.dart';

class TechnicienInterventionsListScreen extends StatefulWidget {
  const TechnicienInterventionsListScreen({super.key});

  @override
  State<TechnicienInterventionsListScreen> createState() => _TechnicienInterventionsListScreenState();
}

class _TechnicienInterventionsListScreenState extends State<TechnicienInterventionsListScreen> {
  final _service = BonTravailService();
  List<BonTravailModel> _interventions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterventions();
  }

  Future<void> _loadInterventions() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getMesInterventions();
      setState(() {
        _interventions = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const TechnicienDrawer(currentRoute: '/technicien-interventions'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mes Interventions', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _interventions.isEmpty
              ? const Center(child: Text('Aucune intervention assignée', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _interventions.length,
                  itemBuilder: (context, index) {
                    final bt = _interventions[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(bt.ascenseurNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: bt.statut == 'EN_COURS' ? Colors.orange[100] : Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    bt.statut.replaceAll('_', ' '),
                                    style: TextStyle(
                                      color: bt.statut == 'EN_COURS' ? Colors.orange[800] : Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Site: ${bt.siteAdresse ?? "Non défini"}', style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigation vers la checklist avec les arguments
                                  Navigator.pushNamed(
                                    context,
                                    '/technicien-checklist',
                                    arguments: {
                                      'bonTravailId': bt.id,
                                      'ascenseurNom': bt.ascenseurNom,
                                    },
                                  ).then((_) => _loadInterventions()); // Recharge la liste au retour
                                },
                                icon: const Icon(Icons.assignment_turned_in, size: 20),
                                label: const Text('Voir la checklist'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}