import 'package:flutter/material.dart';
import 'responsable_drawer.dart';
import '../../services/ascenseur_service.dart';
import '../../models/ascenseur_model.dart';
import 'assemblage_tree_screen.dart'; // ✅ AJOUTÉ : Import pour l'arborescence

class AscenseurListScreen extends StatefulWidget {
  const AscenseurListScreen({super.key});

  @override
  State<AscenseurListScreen> createState() => _AscenseurListScreenState();
}

class _AscenseurListScreenState extends State<AscenseurListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _service = AscenseurService();
  String _searchQuery = '';
  List<AscenseurModel> _ascenseurs = [];
  bool _isLoading = true;

  final Color navyColor = Colors.blue[900]!;
  final Color orangeColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _loadAscenseurs();
  }

  Future<void> _loadAscenseurs() async {
    setState(() => _isLoading = true);
    try {
      final ascenseurs = await _service.getAscenseurs();
      setState(() {
        _ascenseurs = ascenseurs;
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

  Future<void> _deleteAscenseur(int id, String nom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'ascenseur "$nom" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteAscenseur(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ascenseur supprimé avec succès'), backgroundColor: Colors.green),
          );
          _loadAscenseurs();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showDetails(AscenseurModel asc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.85,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fiche de l\'ascenseur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(asc.nom, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navyColor)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: asc.actif ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      asc.actif ? 'Actif' : 'Inactif',
                      style: TextStyle(color: asc.actif ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              _buildSectionTitle('Informations générales'),
              const SizedBox(height: 12),
              _buildInfoRow('Marque', asc.marque ?? 'Non renseigné'),
              _buildInfoRow('Fabricant', asc.fabricant ?? 'Non renseigné'),
              if (asc.modele != null) _buildInfoRow('Modèle', asc.modele!),
              if (asc.numeroSerie != null) _buildInfoRow('N° de série', asc.numeroSerie!),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Caractéristiques techniques'),
              const SizedBox(height: 12),
              if (asc.nombreEtages != null) _buildInfoRow('Nombre d\'étages', '${asc.nombreEtages}'),
              if (asc.capacitePersonnes != null) _buildInfoRow('Capacité', '${asc.capacitePersonnes} personnes'),
              if (asc.chargeMaxKg != null) _buildInfoRow('Charge max', '${asc.chargeMaxKg} kg'),
              if (asc.vitesse != null) _buildInfoRow('Vitesse', '${asc.vitesse} m/s'),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Rattachement'),
              const SizedBox(height: 12),
              _buildInfoRow('Client', '${asc.clientPrenom ?? ''} ${asc.clientNom ?? 'Non défini'}'),
              _buildInfoRow('Site', asc.siteAdresse ?? 'Adresse non définie'),
              if (asc.parcNom != null) _buildInfoRow('Parc', asc.parcNom!),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Dates'),
              const SizedBox(height: 12),
              if (asc.dateMiseEnService != null) _buildInfoRow('Mise en service', _formatDate(asc.dateMiseEnService!)),
              if (asc.dateExpirationGarantie != null) _buildInfoRow('Garantie jusqu\'au', _formatDate(asc.dateExpirationGarantie!)),
              
              if (asc.description != null && asc.description!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Description'),
                const SizedBox(height: 8),
                Text(asc.description!, style: const TextStyle(color: Colors.black87)),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssemblageTreeScreen(
                          ascenseurId: asc.id,
                          ascenseurNom: asc.nom,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_tree, color: Colors.white, size: 24),
                  label: const Text(
                    'Voir l\'arborescence des pièces',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: navyColor));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label :', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  List<AscenseurModel> get _filteredAscenseurs {
    if (_searchQuery.isEmpty) return _ascenseurs;
    return _ascenseurs.where((asc) {
      final nom = asc.nom.toLowerCase();
      final site = (asc.siteAdresse ?? '').toLowerCase();
      final marque = (asc.marque ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nom.contains(query) || site.contains(query) || marque.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const ResponsableDrawer(currentRoute: '/responsable-ascenseur-list'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Gestion des Ascenseurs', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, site...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/responsable-nouvel-ascenseur'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nouveau'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : _filteredAscenseurs.isEmpty
                    ? const Center(child: Text('Aucun ascenseur trouvé', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAscenseurs.length,
                        itemBuilder: (context, index) {
                          final asc = _filteredAscenseurs[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: SizedBox(
                              height: 110,
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: navyColor.withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                    ),
                                    child: Icon(Icons.elevator, color: navyColor, size: 32),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(asc.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Text(asc.siteAdresse ?? 'Site non défini', style: const TextStyle(color: Colors.black87, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text('${asc.marque ?? 'Marque ?'} - ${asc.fabricant ?? 'Fabricant ?'}', style: const TextStyle(color: Colors.black54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: asc.actif ? Colors.green[100] : Colors.red[100],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            asc.actif ? 'Actif' : 'Inactif',
                                            style: TextStyle(color: asc.actif ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.visibility, size: 20, color: navyColor),
                                              onPressed: () => _showDetails(asc),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                              onPressed: () => _deleteAscenseur(asc.id, asc.nom),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}