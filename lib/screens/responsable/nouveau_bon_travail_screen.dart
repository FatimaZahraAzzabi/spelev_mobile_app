import 'package:flutter/material.dart';
import '../../models/demande_maintenance_model.dart';
import '../../models/bon_travail_model.dart';
import '../../models/bon_travail_create_model.dart';
import '../../services/bon_travail_service.dart';
import '../../services/demande_maintenance_service.dart';
import '../../theme/app_theme.dart';
import 'responsable_drawer.dart';

class NouveauBonTravailScreen extends StatefulWidget {
  final DemandeMaintenanceModel? demande;

  const NouveauBonTravailScreen({super.key, this.demande});

  @override
  State<NouveauBonTravailScreen> createState() => _NouveauBonTravailScreenState();
}

class _NouveauBonTravailScreenState extends State<NouveauBonTravailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = BonTravailService();
  final _demandeService = DemandeMaintenanceService();
  
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  DateTime? _dateIntervention;
  TimeOfDay? _heureIntervention;
  int _dureeMinutes = 120;
  
  int? _technicienResponsableId;
  String? _description; 
  
  List<Map<String, dynamic>> _techniciensDisponibles = [];
  bool _isLoadingTechniciens = false;
  bool _hasSearchedTechniciens = false; 

  @override
  void initState() {
    super.initState();
    if (widget.demande != null) {
      _descriptionController.text = widget.demande!.description ?? '';
      _description = widget.demande!.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _dateIntervention = picked;
        _hasSearchedTechniciens = false; 
        _techniciensDisponibles.clear();
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _heureIntervention = picked;
        _hasSearchedTechniciens = false;
        _techniciensDisponibles.clear();
      });
    }
  }

  Future<void> _chargerTechniciensDisponibles() async {
    if (_dateIntervention == null || _heureIntervention == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord sélectionner la date et l\'heure'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (widget.demande?.ascenseurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : L\'ascenseur n\'est pas défini pour cette demande.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoadingTechniciens = true;
      _hasSearchedTechniciens = true;
    });

    try {
      final debut = DateTime(
        _dateIntervention!.year,
        _dateIntervention!.month,
        _dateIntervention!.day,
        _heureIntervention!.hour,
        _heureIntervention!.minute,
      );

      debugPrint(' Recherche techniciens pour ascenseur ID: ${widget.demande!.ascenseurId} à $debut');

      final data = await _service.getTechniciensDisponibles(
        ascenseurId: widget.demande!.ascenseurId!,
        debut: debut,
        dureeMinutes: _dureeMinutes,
      );

      setState(() {
        _techniciensDisponibles = data;
        _isLoadingTechniciens = false;
      });

      debugPrint('Techniciens trouvés : ${_techniciensDisponibles.length}');

      if (_techniciensDisponibles.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun technicien disponible pour ce créneau ou ce parc.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingTechniciens = false);
      debugPrint(' Erreur chargement techniciens: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _genererDescriptionIa() async {
    if (widget.demande == null) return;

    setState(() => _isLoading = true);

    try {
      final descriptionGeneree = await _demandeService.genererDescriptionIa(widget.demande!.id);

      setState(() {
        _descriptionController.text = descriptionGeneree;
        _description = descriptionGeneree; 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 8),
                Text('Description générée avec succès par IA ✨'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur IA: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _creerBonTravail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateIntervention == null || _heureIntervention == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date et l\'heure'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_technicienResponsableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un technicien responsable'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final debut = DateTime(
        _dateIntervention!.year,
        _dateIntervention!.month,
        _dateIntervention!.day,
        _heureIntervention!.hour,
        _heureIntervention!.minute,
      );

      final dto = BonTravailCreateModel(
        demandeMaintenanceId: widget.demande?.id,
        ascenseurId: widget.demande?.ascenseurId,
        technicienResponsableId: _technicienResponsableId!,
        dateInterventionPrevue: debut,
        dureeEstimeeMinutes: _dureeMinutes,
        description: _descriptionController.text, 
        priorite: widget.demande?.priorite,
        visitePreventive: widget.demande?.typeDemande == 'ENTRETIEN_PREVENTIF',
      );

      await _service.creer(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bon de travail créé avec succès'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const ResponsableDrawer(currentRoute: '/responsable-bons-travail'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Nouveau bon de travail',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.demande != null)
                Card(
                  color: AppColors.navy.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DEMANDE ASSOCIÉE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.orange)),
                        const SizedBox(height: 8),
                        Text('Demande N° ${widget.demande!.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.demande!.clientNomComplet, style: TextStyle(color: Colors.grey[700])),
                        Text('Ascenseur: ${widget.demande!.ascenseurNom ?? "Non défini"}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DATE ET HEURE PRÉVUES *', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: AppColors.orange),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _dateIntervention != null ? _formatDate(_dateIntervention!) : 'Sélectionner une date',
                                        style: TextStyle(color: _dateIntervention != null ? Colors.black87 : Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, color: AppColors.orange),
                                    const SizedBox(width: 8),
                                    Text(_heureIntervention != null ? _heureIntervention!.format(context) : 'Heure',
                                        style: TextStyle(color: _heureIntervention != null ? Colors.black87 : Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Durée (min): ', style: TextStyle(fontWeight: FontWeight.w600)),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _dureeMinutes,
                              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                              items: [60, 90, 120, 180, 240, 300].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _dureeMinutes = v!;
                                  _hasSearchedTechniciens = false;
                                  _techniciensDisponibles.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TECHNICIEN RESPONSABLE *', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_isLoadingTechniciens)
                        const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: CircularProgressIndicator()))
                      else if (!_hasSearchedTechniciens)
                        ElevatedButton.icon(
                          onPressed: _chargerTechniciensDisponibles,
                          icon: const Icon(Icons.search),
                          label: const Text('Voir les techniciens disponibles'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, minimumSize: const Size(double.infinity, 48)),
                        )
                      else if (_techniciensDisponibles.isEmpty)
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _chargerTechniciensDisponibles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer la recherche'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black87, minimumSize: const Size(double.infinity, 48)),
                            ),
                            const SizedBox(height: 8),
                            Text('Aucun technicien disponible pour ce créneau ou cet ascenseur.\nVérifiez la date, la durée, ou qu\'un technicien couvre ce parc.', style: TextStyle(color: Colors.red[700], fontSize: 12), textAlign: TextAlign.center),
                          ],
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: _technicienResponsableId,
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), hintText: 'Sélectionner un technicien', contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: _techniciensDisponibles.map((t) {
                            final id = t['id'] as int?;
                            final nom = t['nom'] as String? ?? 'Technicien inconnu';
                            return DropdownMenuItem<int>(value: id, child: Text(nom));
                          }).toList(),
                          onChanged: (v) => setState(() => _technicienResponsableId = v),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          if (widget.demande != null)
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _genererDescriptionIa,
                              icon: _isLoading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, size: 16),
                              label: Text(_isLoading ? 'Génération...' : 'IA'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100], foregroundColor: Colors.purple[900], padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          hintText: 'Décrivez l\'intervention prévue...',
                          alignLabelWithHint: true,
                        ),
                        onChanged: (v) => _description = v,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'La description est requise' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _creerBonTravail,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Créer le bon de travail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}