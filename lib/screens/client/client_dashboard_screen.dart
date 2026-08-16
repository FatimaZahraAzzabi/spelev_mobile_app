import 'package:flutter/material.dart';

class ClientDashboardScreen extends StatelessWidget {
  // ✅ Le mot 'const' est OBLIGATOIRE ici
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Espace Client (Bientôt)')),
    );
  }
}