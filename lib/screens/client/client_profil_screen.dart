import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';
import '../../models/profil_model.dart';
import '../../services/profil_service.dart';
import '../../theme/app_theme.dart';
import 'client_drawer.dart';
import 'edit_profil_screen.dart';

class ClientProfilScreen extends StatefulWidget {
  const ClientProfilScreen({super.key});

  @override
  State<ClientProfilScreen> createState() => _ClientProfilScreenState();
}

class _ClientProfilScreenState extends State<ClientProfilScreen> {
  final _service = ProfilService();
  ProfilModel? _profil;
  bool _isLoading = true;
  int _refreshKey = 0; 

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil({bool clearCache = false}) async {
    setState(() => _isLoading = true);
    
    if (clearCache) {
      painting.PaintingBinding.instance.imageCache.clear();
      painting.PaintingBinding.instance.imageCache.clearLiveImages();
      setState(() => _refreshKey++);
      debugPrint('Cache image nettoyé, refreshKey=$_refreshKey');
    }
    
    try {
      final profil = await _service.getProfil();
      if (mounted) setState(() => _profil = profil);
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

  Future<void> _openEdit() async {
    if (_profil == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilScreen(profil: _profil!)),
    );
    if (result == true) _loadProfil(clearCache: true);
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
        title: const Text('Mon Profil',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.orange),
            onPressed: () => _loadProfil(clearCache: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _profil == null
              ? const Center(child: Text('Impossible de charger le profil'))
              : _buildBody(_profil!),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        onPressed: _openEdit,
        icon: const Icon(Icons.edit),
        label: const Text('Modifier'),
      ),
    );
  }

  Widget _buildBody(ProfilModel profil) {
    final aPhoto = profil.photoUrl != null && profil.photoUrl!.isNotEmpty;

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
                  ProfileAvatarProxy(
                    initiale: (profil.prenom ?? '').isNotEmpty
                        ? profil.prenom![0].toUpperCase()
                        : 'C',
                    hasPhoto: aPhoto,
                    refreshKey: _refreshKey,  
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profil.nomComplet,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profil.email ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  if (profil.role != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profil.role!,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange),
                      ),
                    ),
                  ],
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
                  const Text('Informations',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy)),
                  const SizedBox(height: 16),
                  _infoRow(Icons.person, 'Prénom', profil.prenom ?? 'Non renseigné'),
                  _infoRow(Icons.person_outline, 'Nom', profil.nom ?? 'Non renseigné'),
                  _infoRow(Icons.email, 'Email', profil.email ?? 'Non renseigné'),
                  _infoRow(Icons.phone, 'Téléphone', profil.telephone ?? 'Non renseigné'),
                  if (profil.entreprise != null && profil.entreprise!.isNotEmpty)
                    _infoRow(Icons.business, 'Entreprise', profil.entreprise!),
                  if (profil.adresse != null && profil.adresse!.isNotEmpty)
                    _infoRow(Icons.location_on, 'Adresse', profil.adresse!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
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
                Text(value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Avatar avec PROXY BACKEND + CACHE BUSTING
// ═══════════════════════════════════════════════════════════
class ProfileAvatarProxy extends StatefulWidget {
  final String initiale;
  final bool hasPhoto;
  final int refreshKey; 

  const ProfileAvatarProxy({
    super.key,
    required this.initiale,
    required this.hasPhoto,
    required this.refreshKey,
  });

  @override
  State<ProfileAvatarProxy> createState() => _ProfileAvatarProxyState();
}

class _ProfileAvatarProxyState extends State<ProfileAvatarProxy> {
  bool _error = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void didUpdateWidget(ProfileAvatarProxy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      setState(() => _error = false);
    }
  }

  Future<void> _loadToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (mounted) setState(() => _token = token);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasPhoto || _token == null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.navy,
        child: Text(
          widget.initiale,
          style: const TextStyle(
              fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (_error) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.navy,
        child: Text(
          widget.initiale,
          style: const TextStyle(
              fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

  
    final photoProxyUrl = '${ApiConfig.baseUrl}/api/utilisateurs/photo?t=${widget.refreshKey}';

    debugPrint(' Photo profil (refreshKey=${widget.refreshKey}): $photoProxyUrl');

    return CircleAvatar(
      radius: 60,
      key: ValueKey('avatar_${widget.refreshKey}'), 
      backgroundImage: NetworkImage(
        photoProxyUrl,
        headers: {'Authorization': 'Bearer $_token'},
      ),
      onBackgroundImageError: (error, stackTrace) {
        debugPrint('Erreur chargement photo profil: $error');
        if (mounted) setState(() => _error = true);
      },
    );
  }
}