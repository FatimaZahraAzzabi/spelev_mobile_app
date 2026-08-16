import 'package:flutter/material.dart';
import '../../services/checklist_maintenance_service.dart';
import '../../services/bon_travail_service.dart';
import '../../models/checklist_model.dart';
import '../../models/bon_travail_model.dart';

class ChecklistInterventionScreen extends StatefulWidget {
  final int bonTravailId;
  final String ascenseurNom;

  const ChecklistInterventionScreen({super.key, required this.bonTravailId, required this.ascenseurNom});

  @override
  State<ChecklistInterventionScreen> createState() => _ChecklistInterventionScreenState();
}

class _ChecklistInterventionScreenState extends State<ChecklistInterventionScreen> {
  final _checklistService = ChecklistMaintenanceService();
  final _btService = BonTravailService();
  
  ChecklistModel? _checklist;
  bool _isLoading = true;
  bool _isClosing = false;
  final _bilanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() => _isLoading = true);
    try {
      final data = await _checklistService.getChecklistParBonTravail(widget.bonTravailId);
      setState(() {
        _checklist = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _updateItem(ItemChecklistModel item, String nouveauStatut, String? gravite, String? remarque) async {
    try {
      final dto = {
        'statut': nouveauStatut,
        if (gravite != null) 'gravite': gravite,
        if (remarque != null) 'remarque': remarque,
      };
      await _checklistService.cocherItem(item.id, dto);
      _loadChecklist();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _cloturerIntervention() async {
    if (_bilanController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le bilan doit faire au moins 10 caractères'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isClosing = true);
    try {
      await _checklistService.cloturerChecklist(_checklist!.id, {
        'bilanIntervention': _bilanController.text.trim(),
        'estMaintenance': true,
        'estDepannage': false,
        'estTravaux': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Intervention clôturée avec succès !'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isClosing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Checklist : ${widget.ascenseurNom}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checklist == null
              ? const Center(child: Text('Aucune checklist trouvée'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _checklist!.items.length,
                        itemBuilder: (context, index) {
                          final item = _checklist!.items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.ordre}. ${item.libelle}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: _buildStatusChip(item, 'CONFORME', Colors.green)),
                                      const SizedBox(width: 8),
                                      Expanded(child: _buildStatusChip(item, 'ANOMALIE_DETECTEE', Colors.red)),
                                    ],
                                  ),
                                  if (item.statut == 'ANOMALIE_DETECTEE') ...[
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: item.gravite,
                                      decoration: const InputDecoration(labelText: 'Gravité *', border: OutlineInputBorder(), isDense: true),
                                      items: const [
                                        DropdownMenuItem(value: 'LEGERE', child: Text('Légère')),
                                        DropdownMenuItem(value: 'MODEREE', child: Text('Modérée')),
                                        DropdownMenuItem(value: 'CRITIQUE', child: Text('Critique')),
                                      ],
                                      onChanged: (val) => _updateItem(item, item.statut, val, item.remarque),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: item.remarque,
                                      decoration: const InputDecoration(labelText: 'Remarque', border: OutlineInputBorder(), isDense: true),
                                      onChanged: (val) => _updateItem(item, item.statut, item.gravite, val),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))]),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _bilanController,
                            maxLines: 2,
                            decoration: const InputDecoration(labelText: 'Bilan global de l\'intervention *', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isClosing ? null : _cloturerIntervention,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: _isClosing 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text('Clôturer l\'intervention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatusChip(ItemChecklistModel item, String targetStatus, Color color) {
    final isSelected = item.statut == targetStatus;
    return InkWell(
      onTap: () => _updateItem(item, targetStatus, isSelected ? item.gravite : null, isSelected ? item.remarque : null),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 6),
            Text(
              targetStatus == 'CONFORME' ? 'Conforme' : 'Anomalie',
              style: TextStyle(color: isSelected ? color : Colors.black54, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bilanController.dispose();
    super.dispose();
  }
}