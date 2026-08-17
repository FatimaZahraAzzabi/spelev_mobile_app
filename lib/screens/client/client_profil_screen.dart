import 'package:flutter/material.dart';
import '../../models/profil_model.dart';
import '../../services/profil_service.dart';
import '../../theme/app_theme.dart';
import 'client_drawer.dart';

class ClientProfilScreen extends StatefulWidget {
  const ClientProfilScreen({super.key});

  @override
  State<ClientProfilScreen> createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends State<ClientProfilScreen> {
  final _service = ProfilService();
  ProfilModel? _profil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    setState(() => _isLoading = true);
    try {
      final profil = await _service.getProfil();
      setState(() {
        _profil = profil;
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
      drawer: ClientDrawer(currentRoute: '/client-profil'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Mon Profil', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _profil == null
              ? const Center(child: Text('Impossible de charger le profil'))
              : _buildBody(_profil!),
    );
  }

  Widget _buildBody(ProfilModel profil) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.navy,
                    child: Text(
                      (profil.prenom ?? '').isNotEmpty
                          ? profil.prenom![0].toUpperCase()
                          : 'C',
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profil.nomComplet,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profil.email ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                  const SizedBox(height: 16),
                  _infoRow(Icons.person, 'Prénom', profil.prenom ?? 'Non renseigné'),
                  _infoRow(Icons.person_outline, 'Nom', profil.nom ?? 'Non renseigné'),
                  _infoRow(Icons.email, 'Email', profil.email ?? 'Non renseigné'),
                  _infoRow(Icons.phone, 'Téléphone', profil.telephone ?? 'Non renseigné'),
                  if (profil.entreprise != null) _infoRow(Icons.business, 'Entreprise', profil.entreprise!),
                  if (profil.adresse != null) _infoRow(Icons.location_on, 'Adresse', profil.adresse!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}