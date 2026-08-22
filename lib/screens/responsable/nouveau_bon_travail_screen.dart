import 'package:flutter/material.dart';

import '../../services/demande_maintenance_service.dart';
import '../../models/demande_maintenance_model.dart';
import '../../models/site_model.dart';
import '../../theme/app_theme.dart';
import '../../services/bon_travail_service.dart';
import '../../services/site_service.dart';
import '../../models/bon_travail_create_model.dart';
import 'responsable_drawer.dart';

class NouveauBonTravailScreen extends StatefulWidget {
  final DemandeMaintenanceModel? demande;

  /// false = bon de travail de maintenance classique
  /// true  = bon de travail d'évaluation
  final bool isEvaluation;

  const NouveauBonTravailScreen({
    super.key,
    this.demande,
    this.isEvaluation = false,
  });

  @override
  State<NouveauBonTravailScreen> createState() =>
      _NouveauBonTravailScreenState();
}

class _NouveauBonTravailScreenState
    extends State<NouveauBonTravailScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bonTravailService = BonTravailService();
  final _demandeService = DemandeMaintenanceService();
  final _siteService = SiteService();

  final TextEditingController _descriptionController =
      TextEditingController();

  bool _isLoading = false;

  DateTime? _dateIntervention;
  TimeOfDay? _heureIntervention;

  int _dureeMinutes = 120;

  int? _technicienResponsableId;

  List<Map<String, dynamic>> _techniciensDisponibles = [];

  bool _isLoadingTechniciens = false;
  bool _hasSearchedTechniciens = false;

  // ============================================================
  // ÉVALUATION
  // ============================================================

  List<SiteModel> _sites = [];
  int? _selectedSiteId;
  bool _isLoadingSites = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEvaluation) {
      _initialiserEvaluation();
    } else {
      _initialiserDemandeMaintenance();
    }
  }

  // ============================================================
  // INITIALISATION DEMANDE CLASSIQUE
  // ============================================================

  void _initialiserDemandeMaintenance() {
    if (widget.demande != null) {
      _descriptionController.text =
          widget.demande!.description ?? '';
    }
  }

  // ============================================================
  // INITIALISATION ÉVALUATION
  // ============================================================

  void _initialiserEvaluation() {
    _loadSites();

    if (widget.demande != null) {
      final demande = widget.demande!;

      _descriptionController.text =
          'ÉVALUATION NOUVELLE INSTALLATION\n'
          'Client : ${demande.clientNomComplet}\n'
          'Adresse : ${demande.adresseSaisie ?? 'À définir'}\n'
          'Ville : ${demande.villeSaisie ?? 'À définir'}\n'
          '--------------------------------\n'
          '${demande.description ?? ''}';
    }
  }

  // ============================================================
  // CHARGER LES SITES DU CLIENT
  // ============================================================

  Future<void> _loadSites() async {
    if (widget.demande == null ||
        widget.demande!.clientId == null) {
      return;
    }

    setState(() {
      _isLoadingSites = true;
    });

    try {
      final sites = await _siteService.getSitesByClient(
        widget.demande!.clientId!,
      );

      if (!mounted) return;

      setState(() {
        _sites = sites;
        _isLoadingSites = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingSites = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur chargement des sites : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (picked == null) return;

    setState(() {
      _dateIntervention = picked;
      _technicienResponsableId = null;
      _hasSearchedTechniciens = false;
      _techniciensDisponibles.clear();
    });
  }

  // ============================================================
  // HEURE
  // ============================================================

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    setState(() {
      _heureIntervention = picked;
      _technicienResponsableId = null;
      _hasSearchedTechniciens = false;
      _techniciensDisponibles.clear();
    });
  }

  // ============================================================
  // RECHERCHE DES TECHNICIENS DISPONIBLES
  // ============================================================

  Future<void> _chargerTechniciensDisponibles() async {
    if (_dateIntervention == null ||
        _heureIntervention == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez d\'abord sélectionner la date et l\'heure.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ==========================================================
    // ÉVALUATION → SITE OBLIGATOIRE
    // ==========================================================

    if (widget.isEvaluation && _selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez d\'abord sélectionner un site.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ==========================================================
    // MAINTENANCE → ASCENSEUR OBLIGATOIRE
    // ==========================================================

    final ascenseurId = widget.demande?.ascenseurId;

    if (!widget.isEvaluation && ascenseurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erreur : l\'ascenseur n\'est pas défini pour cette demande.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingTechniciens = true;
      _hasSearchedTechniciens = true;
      _technicienResponsableId = null;
    });

    try {
      final debut = DateTime(
        _dateIntervention!.year,
        _dateIntervention!.month,
        _dateIntervention!.day,
        _heureIntervention!.hour,
        _heureIntervention!.minute,
      );

      List<Map<String, dynamic>> data;

      // ========================================================
      // ÉVALUATION
      // Recherche par SITE
      // ========================================================

      if (widget.isEvaluation) {
        data = await _bonTravailService
            .getTechniciensDisponiblesParSite(
          siteId: _selectedSiteId!,
          debut: debut,
          dureeMinutes: _dureeMinutes,
        );
      }

      // ========================================================
      // MAINTENANCE CLASSIQUE
      // Recherche par ASCENSEUR
      // ========================================================

      else {
        data = await _bonTravailService
            .getTechniciensDisponibles(
          ascenseurId: ascenseurId!,
          debut: debut,
          dureeMinutes: _dureeMinutes,
        );
      }

      if (!mounted) return;

      setState(() {
        _techniciensDisponibles = data;
        _isLoadingTechniciens = false;
      });

      debugPrint(
        'Techniciens trouvés : ${_techniciensDisponibles.length}',
      );

      if (_techniciensDisponibles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aucun technicien disponible pour ce créneau.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingTechniciens = false;
      });

      debugPrint(
        'Erreur chargement techniciens : $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // GÉNÉRATION DESCRIPTION IA
  // ============================================================

  Future<void> _genererDescriptionIa() async {
    if (widget.demande == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final descriptionGeneree =
          await _demandeService.genererDescriptionIa(
        widget.demande!.id,
      );

      if (!mounted) return;

      setState(() {
        _descriptionController.text = descriptionGeneree;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Description générée avec succès par IA ✨',
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur IA : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // CRÉATION DU BON DE TRAVAIL
  // ============================================================

  Future<void> _creerBonTravail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateIntervention == null ||
        _heureIntervention == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner la date et l\'heure.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_technicienResponsableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un technicien responsable.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ==========================================================
    // ÉVALUATION → SITE OBLIGATOIRE
    // ==========================================================

    if (widget.isEvaluation && _selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un site pour l\'évaluation.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ==========================================================
    // MAINTENANCE → ASCENSEUR OBLIGATOIRE
    // ==========================================================

    if (!widget.isEvaluation &&
        widget.demande?.ascenseurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de créer le bon : aucun ascenseur associé à la demande.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final debut = DateTime(
        _dateIntervention!.year,
        _dateIntervention!.month,
        _dateIntervention!.day,
        _heureIntervention!.hour,
        _heureIntervention!.minute,
      );

      // ========================================================
      // DTO
      //
      // MAINTENANCE :
      //   demandeMaintenanceId = demande
      //   ascenseurId         = demande.ascenseurId
      //   siteId              = null
      //   isEvaluation        = false
      //
      // ÉVALUATION :
      //   demandeMaintenanceId = demande
      //   ascenseurId          = null
      //   siteId               = site sélectionné
      //   isEvaluation         = true
      // ========================================================

      final dto = BonTravailCreateModel(
        demandeMaintenanceId: widget.demande?.id,

        // IMPORTANT :
        // Pour une maintenance, on garde exactement
        // l'ascenseur de la demande.
        //
        // Pour une évaluation, pas d'ascenseur encore.
        ascenseurId: widget.isEvaluation
            ? null
            : widget.demande?.ascenseurId,

        // Site uniquement pour l'évaluation.
        siteId: widget.isEvaluation
            ? _selectedSiteId
            : null,

        technicienResponsableId:
            _technicienResponsableId!,

        dateInterventionPrevue: debut,

        dureeEstimeeMinutes: _dureeMinutes,

        description:
            _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : widget.isEvaluation
                    ? 'Évaluation nouvelle installation pour ${widget.demande?.clientNomComplet ?? "client"}'
                    : 'Intervention sur ${widget.demande?.clientNomComplet ?? "client"}',

        priorite:
            widget.demande?.priorite ?? 'NORMALE',

        visitePreventive:
            widget.demande?.typeDemande ==
                'ENTRETIEN_PREVENTIF',

        // IMPORTANT
        isEvaluation: widget.isEvaluation,
      );

      debugPrint(
        '===== CRÉATION BON DE TRAVAIL =====',
      );
      debugPrint(
        'demandeMaintenanceId: ${dto.demandeMaintenanceId}',
      );
      debugPrint(
        'ascenseurId: ${dto.ascenseurId}',
      );
      debugPrint(
        'siteId: ${dto.siteId}',
      );
      debugPrint(
        'technicienResponsableId: ${dto.technicienResponsableId}',
      );
      debugPrint(
        'isEvaluation: ${dto.isEvaluation}',
      );

      await _bonTravailService.creer(dto);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEvaluation
                ? 'Bon de travail d\'évaluation créé avec succès.'
                : 'Bon de travail créé avec succès.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // On revient à l'écran précédent.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      drawer: const ResponsableDrawer(
        currentRoute: '/responsable-bons-travail',
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          widget.isEvaluation
              ? 'Créer BT Évaluation'
              : 'Nouveau bon de travail',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // DEMANDE ASSOCIÉE
              // ==================================================

              if (widget.demande != null)
                Card(
                  color: AppColors.navy.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEMANDE ASSOCIÉE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Demande N° ${widget.demande!.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          widget.demande!.clientNomComplet,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),

                        // Pour une maintenance :
                        // afficher l'ascenseur de la demande.
                        if (!widget.isEvaluation)
                          Text(
                            'Ascenseur : '
                            '${widget.demande!.ascenseurNom ?? "Non défini"}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),

                        const SizedBox(height: 8),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isEvaluation
                                ? Colors.purple
                                    .withOpacity(0.1)
                                : Colors.blue
                                    .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.isEvaluation
                                ? 'Évaluation'
                                : 'Maintenance',
                            style: TextStyle(
                              color: widget.isEvaluation
                                  ? Colors.purple
                                  : Colors.blue,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ==================================================
              // SITE POUR ÉVALUATION
              // ==================================================

              if (widget.isEvaluation) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SITE DE L\'ÉVALUATION *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_isLoadingSites)
                          const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        else if (_sites.isEmpty)
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange
                                  .withOpacity(0.08),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Aucun site disponible pour ce client.',
                              style: TextStyle(
                                color: Colors.orange,
                              ),
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            value: _selectedSiteId,

                            decoration:
                                const InputDecoration(
                              labelText: 'Site',
                              border:
                                  OutlineInputBorder(),
                              hintText:
                                  'Sélectionner un site',
                            ),

                            items: _sites.map((site) {
                              return DropdownMenuItem<int>(
                                value: site.id,
                                child: Text(
                                  site.adresse,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: (value) {
                              setState(() {
                                _selectedSiteId = value;

                                // Le changement de site
                                // invalide l'ancienne recherche.
                                _technicienResponsableId =
                                    null;

                                _hasSearchedTechniciens =
                                    false;

                                _techniciensDisponibles
                                    .clear();
                              });
                            },

                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner un site';
                              }

                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // ==================================================
              // DATE / HEURE / DURÉE
              // ==================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DATE ET HEURE PRÉVUES *',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(12),
                                decoration:
                                    BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Colors.grey[300]!,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color:
                                          AppColors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _dateIntervention !=
                                                null
                                            ? _formatDate(
                                                _dateIntervention!,
                                              )
                                            : 'Sélectionner une date',
                                        style: TextStyle(
                                          color:
                                              _dateIntervention !=
                                                      null
                                                  ? Colors
                                                      .black87
                                                  : Colors
                                                      .grey,
                                        ),
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
                                padding:
                                    const EdgeInsets.all(12),
                                decoration:
                                    BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Colors.grey[300]!,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color:
                                          AppColors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _heureIntervention !=
                                                null
                                            ? _heureIntervention!
                                                .format(
                                                context,
                                              )
                                            : 'Heure',
                                        style: TextStyle(
                                          color:
                                              _heureIntervention !=
                                                      null
                                                  ? Colors
                                                      .black87
                                                  : Colors
                                                      .grey,
                                        ),
                                      ),
                                    ),
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
                          const Text(
                            'Durée (min) : ',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          Expanded(
                            child:
                                DropdownButtonFormField<int>(
                              value: _dureeMinutes,

                              decoration:
                                  InputDecoration(
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),

                              items: [
                                60,
                                90,
                                120,
                                180,
                                240,
                                300,
                              ].map(
                                (minutes) {
                                  return DropdownMenuItem<
                                      int>(
                                    value: minutes,
                                    child: Text(
                                      '$minutes min',
                                    ),
                                  );
                                },
                              ).toList(),

                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  _dureeMinutes = value;

                                  _technicienResponsableId =
                                      null;

                                  _hasSearchedTechniciens =
                                      false;

                                  _techniciensDisponibles
                                      .clear();
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

              // ==================================================
              // TECHNICIEN
              // ==================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TECHNICIEN RESPONSABLE *',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_isLoadingTechniciens)
                        const Center(
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            child:
                                CircularProgressIndicator(),
                          ),
                        )
                      else if (!_hasSearchedTechniciens)
                        ElevatedButton.icon(
                          onPressed:
                              _chargerTechniciensDisponibles,
                          icon: const Icon(Icons.search),
                          label: const Text(
                            'Voir les techniciens disponibles',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.orange,
                            minimumSize:
                                const Size(
                              double.infinity,
                              48,
                            ),
                          ),
                        )
                      else if (_techniciensDisponibles
                          .isEmpty)
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  _chargerTechniciensDisponibles,
                              icon: const Icon(
                                Icons.refresh,
                              ),
                              label: const Text(
                                'Réessayer la recherche',
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.grey[300],
                                foregroundColor:
                                    Colors.black87,
                                minimumSize:
                                    const Size(
                                  double.infinity,
                                  48,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              widget.isEvaluation
                                  ? 'Aucun technicien disponible '
                                      'pour ce site et ce créneau.'
                                  : 'Aucun technicien disponible '
                                      'pour cet ascenseur et ce créneau.',
                              style: TextStyle(
                                color:
                                    Colors.red[700],
                                fontSize: 12,
                              ),
                              textAlign:
                                  TextAlign.center,
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<int>(
                          value:
                              _technicienResponsableId,

                          decoration:
                              InputDecoration(
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                            hintText:
                                'Sélectionner un technicien',
                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),

                          items: _techniciensDisponibles
                              .map((technicien) {
                            final dynamic rawId =
                                technicien['id'];

                            final int? id =
                                rawId is int
                                    ? rawId
                                    : int.tryParse(
                                        rawId?.toString() ??
                                            '',
                                      );

                            final String nom =
                                technicien['nom']
                                        ?.toString() ??
                                    technicien[
                                            'nomComplet']
                                        ?.toString() ??
                                    'Technicien inconnu';

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(nom),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setState(() {
                              _technicienResponsableId =
                                  value;
                            });
                          },

                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un technicien';
                            }

                            return null;
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'DESCRIPTION',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          if (widget.demande != null)
                            ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _genererDescriptionIa,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                    ),
                              label: Text(
                                _isLoading
                                    ? 'Génération...'
                                    : 'IA',
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.purple[100],
                                foregroundColor:
                                    Colors.purple[900],
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle:
                                    const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller:
                            _descriptionController,

                        maxLines: 6,

                        decoration:
                            InputDecoration(
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                          ),

                          hintText: widget.isEvaluation
                              ? 'Décrivez l\'évaluation prévue pour la nouvelle installation...'
                              : 'Décrivez l\'intervention prévue...',

                          alignLabelWithHint: true,
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'La description est requise';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // BOUTON CRÉATION
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _creerBonTravail,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.orange,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                  ),

                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.isEvaluation
                              ? 'Créer BT Évaluation'
                              : 'Créer le bon de travail',
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}