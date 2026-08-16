import 'package:flutter/material.dart';
import 'admin_drawer.dart';
import '../../theme/app_theme.dart';
import '../../services/utilisateur_service.dart';
import '../../models/utilisateur_model.dart';

class AdminUserFormScreen extends StatefulWidget {
  final UtilisateurModel? utilisateur;

  const AdminUserFormScreen({super.key, this.utilisateur});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = UtilisateurService();
  bool _isLoading = false;

  bool get _isEditMode => widget.utilisateur != null;

  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _emailController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _entrepriseController;
  late final TextEditingController _specialiteController;
  late final TextEditingController _adresseController;

  String? _selectedType;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final u = widget.utilisateur;
    _nomController = TextEditingController(text: u?.nom ?? '');
    _prenomController = TextEditingController(text: u?.prenom ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _telephoneController = TextEditingController(text: u?.telephone ?? '');
    _passwordController = TextEditingController(text: '');
    _entrepriseController = TextEditingController(text: u?.nomEntreprise ?? '');
    _specialiteController = TextEditingController(text: u?.specialite ?? '');
    _adresseController = TextEditingController(text: u?.adresse ?? '');
    _selectedType = u?.type;
    _isActive = u?.actif ?? true;
  }

  @override
  void dispose() {
    _nomController.dispose(); _prenomController.dispose(); _emailController.dispose();
    _telephoneController.dispose(); _passwordController.dispose();
    _entrepriseController.dispose(); _specialiteController.dispose(); _adresseController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        final dto = UtilisateurUpdateDTO(
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          email: _emailController.text.trim(),
          telephone: _telephoneController.text.trim(),
          type: _selectedType!,
          actif: _isActive,
          nomEntreprise: _entrepriseController.text.trim().isEmpty ? null : _entrepriseController.text.trim(),
          specialite: _specialiteController.text.trim().isEmpty ? null : _specialiteController.text.trim(),
          adresse: _adresseController.text.trim().isEmpty ? null : _adresseController.text.trim(),
        );
        await _service.updateUtilisateur(widget.utilisateur!.id, dto);
      } else {
        final dto = UtilisateurCreateDTO(
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          email: _emailController.text.trim(),
          telephone: _telephoneController.text.trim(),
          motDePasse: _passwordController.text.trim(),
          type: _selectedType!,
          nomEntreprise: _entrepriseController.text.trim().isEmpty ? null : _entrepriseController.text.trim(),
          specialite: _specialiteController.text.trim().isEmpty ? null : _specialiteController.text.trim(),
          adresse: _adresseController.text.trim().isEmpty ? null : _adresseController.text.trim(),
        );
        await _service.createUtilisateur(dto);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Utilisateur modifié avec succès !' : 'Utilisateur créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const AdminDrawer(currentRoute: '/admin-users'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          _isEditMode ? 'Modifier l\'utilisateur' : 'Créer un utilisateur',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      // ✅ SOLUTION : Layout responsive sans overflow
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12), // ✅ Padding réduit
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16), // ✅ Padding réduit
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isEditMode ? 'Modifier les informations' : 'Créer un utilisateur',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // ✅ Texte plus petit
                      ),
                      const SizedBox(height: 16),
                      
                      // Nom et Prénom - Sur petits écrans, empiler verticalement
                      if (constraints.maxWidth < 600) ...[
                        // ✅ Mode vertical pour mobiles
                        TextFormField(
                          controller: _nomController,
                          decoration: const InputDecoration(labelText: 'Nom *', border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _prenomController,
                          decoration: const InputDecoration(labelText: 'Prénom *', border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                      ] else ...[
                        // ✅ Mode horizontal pour tablettes/desktop
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nomController,
                                decoration: const InputDecoration(labelText: 'Nom *', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _prenomController,
                                decoration: const InputDecoration(labelText: 'Prénom *', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requis';
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Téléphone et Type - Responsive
                      if (constraints.maxWidth < 600) ...[
                        TextFormField(
                          controller: _telephoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Téléphone *', border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(labelText: 'Type *', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'ADMINISTRATEUR', child: Text('Admin')),
                            DropdownMenuItem(value: 'TECHNICIEN', child: Text('Technicien')),
                            DropdownMenuItem(value: 'RESPONSABLE_MAINTENANCE', child: Text('Resp. Maint.')),
                            DropdownMenuItem(value: 'CLIENT', child: Text('Client')),
                          ],
                          onChanged: !_isEditMode ? (value) => setState(() => _selectedType = value) : null,
                          validator: (value) => value == null ? 'Requis' : null,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _telephoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(labelText: 'Téléphone *', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: const InputDecoration(labelText: 'Type *', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'ADMINISTRATEUR', child: Text('Admin')),
                                  DropdownMenuItem(value: 'TECHNICIEN', child: Text('Technicien')),
                                  DropdownMenuItem(value: 'RESPONSABLE_MAINTENANCE', child: Text('Resp. Maint.')),
                                  DropdownMenuItem(value: 'CLIENT', child: Text('Client')),
                                ],
                                onChanged: !_isEditMode ? (value) => setState(() => _selectedType = value) : null,
                                validator: (value) => value == null ? 'Requis' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Statut Actif/Inactif (uniquement en mode modification)
                      if (_isEditMode) ...[
                        Card(
                          color: _isActive ? Colors.green[50] : Colors.red[50],
                          child: SwitchListTile(
                            title: const Text('Compte actif', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(_isActive ? 'L\'utilisateur peut se connecter' : 'L\'utilisateur ne peut pas se connecter', style: TextStyle(fontSize: 12)),
                            value: _isActive,
                            onChanged: (value) => setState(() => _isActive = value),
                            activeColor: Colors.green,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Mot de passe (uniquement en création)
                      if (!_isEditMode) ...[
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Mot de passe *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requis';
                            if (v.length < 6) return 'Minimum 6 caractères';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Entreprise et Spécialité - Responsive
                      if (constraints.maxWidth < 600) ...[
                        TextFormField(
                          controller: _entrepriseController,
                          decoration: const InputDecoration(labelText: 'Entreprise', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _specialiteController,
                          decoration: const InputDecoration(labelText: 'Spécialité', border: OutlineInputBorder()),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _entrepriseController,
                                decoration: const InputDecoration(labelText: 'Entreprise', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _specialiteController,
                                decoration: const InputDecoration(labelText: 'Spécialité', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      
                      // Adresse
                      TextFormField(
                        controller: _adresseController,
                        decoration: const InputDecoration(labelText: 'Adresse', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      
                      // Boutons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Annuler', style: TextStyle(color: Colors.black87, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(
                                      _isEditMode ? 'Enregistrer' : 'Créer',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}