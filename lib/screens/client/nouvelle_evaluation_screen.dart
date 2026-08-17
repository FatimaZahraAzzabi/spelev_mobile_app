import 'package:flutter/material.dart';
import '../../services/evaluation_service.dart';
import '../../theme/app_theme.dart';
import 'client_drawer.dart';

class NouvelleEvaluationScreen extends StatefulWidget {
  const NouvelleEvaluationScreen({super.key});

  @override
  State<NouvelleEvaluationScreen> createState() => _NouvelleEvaluationScreenState();
}

class _NouvelleEvaluationScreenState extends State<NouvelleEvaluationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = EvaluationService();
  bool _isLoading = false;

  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _typeBatiment = 'IMMEUBLE';
  int _nombreEtages = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: ClientDrawer(currentRoute: '/client-nouvelle-evaluation'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Demande d\'évaluation', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demande d\'évaluation d\'installation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 8),
              const Text(
                'Décrivez votre projet pour recevoir un devis personnalisé.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('TYPE DE BÂTIMENT'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _typeBatiment,
                decoration: const InputDecoration(labelText: 'Type de bâtiment *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'IMMEUBLE', child: Text('Immeuble résidentiel')),
                  DropdownMenuItem(value: 'COMMERCIAL', child: Text('Bâtiment commercial')),
                  DropdownMenuItem(value: 'INDUSTRIEL', child: Text('Bâtiment industriel')),
                  DropdownMenuItem(value: 'AUTRE', child: Text('Autre')),
                ],
                onChanged: (val) => setState(() => _typeBatiment = val!),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('CARACTÉRISTIQUES'),
              const SizedBox(height: 12),
              TextFormField(
                controller: TextEditingController(text: _nombreEtages.toString()),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nombre d\'étages *', border: OutlineInputBorder()),
                onChanged: (val) {
                  final n = int.tryParse(val);
                  if (n != null) setState(() => _nombreEtages = n);
                },
                validator: (val) => (val == null || val.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('ADRESSE'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adresseController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Adresse complète *',
                  hintText: 'Numéro, rue, ville, code postal',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('DESCRIPTION DU PROJET'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Décrivez votre besoin (type d\'ascenseur, capacité souhaitée, contraintes...)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
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
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue, letterSpacing: 0.5),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final dto = {
        'typeBatiment': _typeBatiment,
        'nombreEtages': _nombreEtages,
        'adresse': _adresseController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      await _service.creer(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande envoyée avec succès !'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}