import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../theme/app_theme.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;
  final QuranThemeMode themeMode;
  final ArabicFontFamily fontFamily;
  final ArabicFontWeightOption fontWeight;
  final bool isArabic;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
    required this.themeMode,
    this.fontFamily = ArabicFontFamily.amiri,
    this.fontWeight = ArabicFontWeightOption.bold,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getConfig(themeMode);

    final primaryName = surah.nameEnglish;
    final typeLabel = isArabic
        ? (surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية')
        : surah.revelationType.toUpperCase();
    final versesLabel = isArabic
        ? '${surah.versesCount} آيات'
        : '${surah.versesCount} VERSES';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cfg.paperBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: cfg.isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Surah Number Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cfg.borderAccent.withValues(alpha: 0.12),
                  border: Border.all(color: cfg.borderAccent.withValues(alpha: 0.4), width: 1),
                ),
                child: Center(
                  child: Text(
                    '${surah.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: cfg.borderAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // English Name & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: cfg.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: cfg.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.circle, size: 4, color: cfg.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          versesLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cfg.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arabic Name (rendered in the selected Quran font)
              Text(
                surah.nameArabic,
                style: AppTheme.getArabicTextStyle(
                  fontFamily: fontFamily,
                  fontWeight: fontWeight,
                  fontSize: 22,
                  color: cfg.borderAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}