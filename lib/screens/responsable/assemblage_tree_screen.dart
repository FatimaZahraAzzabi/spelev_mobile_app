import 'package:flutter/material.dart';
import '../../services/assemblage_service.dart';
import '../../models/assemblage_model.dart';
import '../../theme/app_theme.dart';

class AssemblageTreeScreen extends StatefulWidget {
  final int ascenseurId;
  final String ascenseurNom;

  const AssemblageTreeScreen({super.key, required this.ascenseurId, required this.ascenseurNom});

  @override
  State<AssemblageTreeScreen> createState() => _AssemblageTreeScreenState();
}

class _AssemblageTreeScreenState extends State<AssemblageTreeScreen> {
  final _service = AssemblageService();
  List<AssemblageModel> _arbre = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerArbre();
  }

  Future<void> _chargerArbre() async {
    setState(() => _isLoading = true);
    try {
      final arbre = await _service.getArbreParAscenseur(widget.ascenseurId);
      setState(() {
        _arbre = arbre;
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

  Widget _buildTreeNode(AssemblageModel node, int depth) {
    return ExpansionTile(
      leading: Icon(
        node.sousAssemblages != null && node.sousAssemblages!.isNotEmpty 
            ? Icons.folder 
            : Icons.build,
        color: AppColors.orange,
      ),
      title: Text(
        node.nom,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Réf: ${node.reference} | Type: ${node.type}'),
      children: [
        if (node.composants != null && node.composants!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('🔩 Composants:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          ...node.composants!.map((comp) => ListTile(
            leading: const Icon(Icons.circle, size: 12, color: Colors.green),
            title: Text(comp.nom, style: const TextStyle(fontSize: 13)),
            subtitle: Text(comp.reference, style: const TextStyle(fontSize: 11)),
            dense: true,
          )),
          const Divider(),
        ],
        if (node.sousAssemblages != null)
          ...node.sousAssemblages!.map((child) => _buildTreeNode(child, depth + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Arborescence : ${widget.ascenseurNom}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _arbre.isEmpty
              ? const Center(child: Text('Aucun assemblage configuré pour cet ascenseur.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _arbre.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: _buildTreeNode(_arbre[index], 0),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité de création à ajouter ici')),
          );
        },
        backgroundColor: AppColors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}