import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AscenseurCard extends StatelessWidget {
  final Ascenseur ascenseur;
  final VoidCallback onTap;

  const AscenseurCard({super.key, required this.ascenseur, required this.onTap});

  Color get _statutColor {
    switch (ascenseur.statut) {
      case StatutAscenseur.actif:
        return AppColors.success;
      case StatutAscenseur.enMaintenance:
        return AppColors.warning;
      case StatutAscenseur.horsService:
        return AppColors.danger;
    }
  }

  String get _statutLabel {
    switch (ascenseur.statut) {
      case StatutAscenseur.actif:
        return 'Actif';
      case StatutAscenseur.enMaintenance:
        return 'En maintenance';
      case StatutAscenseur.horsService:
        return 'Hors service';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.elevator_outlined, color: AppColors.navy, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ascenseur.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('${ascenseur.clientNom} — ${ascenseur.site}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pill('${ascenseur.nombreEtages} étages'),
                      const SizedBox(width: 6),
                      _pill(ascenseur.numeroSerie),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 108),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statutColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: _statutColor, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _statutLabel,
                            style: TextStyle(color: _statutColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    );
  }
}