import 'package:flutter/material.dart';
import '../../services/demande_maintenance_service.dart';
// Importe ton modèle d'ascenseur ici si tu as une liste à passer en paramètre
// import '../../models/ascenseur_model.dart';

class NouvelleDemandeScreen extends StatefulWidget {
  // Tu peux passer la liste des ascenseurs du client ici
  // final List<AscenseurModel> mesAscenseurs;
  // const NouvelleDemandeScreen({super.key, required this.mesAscenseurs});
  const NouvelleDemandeScreen({super.key});

  @override
  State<NouvelleDemandeScreen> createState() => _NouvelleDemandeScreenState();
}

class _NouvelleDemandeScreenState extends State<NouvelleDemandeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DemandeMaintenanceService();
  bool _isLoading = false;

  final _descriptionController = TextEditingController();
  
  int? _selectedAscenseurId;
  String _typeDemande = 'DEPANNAGE'; // Valeur par défaut
  String _priorite = 'MOYENNE'; // Valeur par défaut

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nouvelle demande', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('ÉQUIPEMENT CONCERNÉ'),
              const SizedBox(height: 12),
              // TODO: Remplace ce Dropdown par un vrai sélecteur avec tes ascenseurs
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Ascenseur *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Ascenseur A - Cage 1')),
                  DropdownMenuItem(value: 2, child: Text('Ascenseur B - Cage 2')),
                ],
                onChanged: (val) => setState(() => _selectedAscenseurId = val),
                validator: (val) => val == null ? 'Requis' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('DÉTAILS DE LA DEMANDE'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _typeDemande,
                decoration: const InputDecoration(labelText: 'Type de demande *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'DEPANNAGE', child: Text('Dépannage')),
                  DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance préventive')),
                ],
                onChanged: (val) => setState(() => _typeDemande = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priorite,
                decoration: const InputDecoration(labelText: 'Priorité *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'BASSE', child: Text('Basse')),
                  DropdownMenuItem(value: 'MOYENNE', child: Text('Moyenne')),
                  DropdownMenuItem(value: 'HAUTE', child: Text('Haute')),
                  DropdownMenuItem(value: 'CRITIQUE', child: Text('Critique')),
                ],
                onChanged: (val) => setState(() => _priorite = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description du problème *',
                  hintText: 'Décrivez le symptôme (bruit, blocage, erreur...)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDemande,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Envoyer la demande', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue, letterSpacing: 0.5));
  }

  Future<void> _submitDemande() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAscenseurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un ascenseur'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dto = {
        'ascenseurId': _selectedAscenseurId,
        'typeDemande': _typeDemande,
        'priorite': _priorite,
        'description': _descriptionController.text.trim(),
      };
      
      await _service.creerDemande(dto);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande envoyée avec succès !'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}