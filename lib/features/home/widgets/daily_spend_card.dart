import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailySpendCard extends ConsumerWidget {
  const DailySpendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dailySpendAsync = ref.watch(dailyAllowableSpendProvider);
    final userSettings = ref.watch(userSettingsProvider);

    return Container(
      // Padding dengeli tutuldu
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.getCardShadow(context),
        border: Border.all(
          color: AppColors.getBorder(context).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: dailySpendAsync.when(
          loading: () => _buildShimmer(context),
          error: (error, stack) => _buildError(context, theme),
          data: (dailySpend) {
            final currency = userSettings.value?.currency ?? 'USD';
            final isPositive = dailySpend >= 0;

            final statusColor = isPositive ? AppColors.success : AppColors.error;
            // İkonu değiştirdik, artık para sağda olduğu için solda generic bir cüzdan ikonu daha şık durur
            final iconData = Icons.account_balance_wallet_outlined;

            return Row(
              children: [
                // SOL TARA: İkon
                _buildCompactIcon(statusColor, iconData),

                const SizedBox(width: 12),

                // ORTA: Başlık (Sola Yaslı)
                Text(
                  'Daily Budget',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.getTextSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // SPACER: Kalan boşluğu iterek sağ tarafı doldurur
                const Spacer(),

                // SAĞ TARAF: Tutar ve Durum (Sağa Yaslı)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Sağa yaslama kilit nokta
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAmountText(theme, dailySpend, currency),
                    const SizedBox(height: 2),
                    Text(
                      isPositive ? 'remaining' : 'over limit',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPositive
                            ? AppColors.getTextSecondary(context).withValues(alpha: 0.8)
                            : AppColors.error,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactIcon(Color color, IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // Hafif tint
        borderRadius: BorderRadius.circular(10),
        // Border kaldırıldı, daha temiz bir görünüm için
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildAmountText(ThemeData theme, double amount, String currency) {
    return Text(
      CurrencyFormatter.format(amount.abs(), currency),
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: theme.textTheme.bodyLarge?.color,
        height: 1.0,
        letterSpacing: -0.5, // Rakamları biraz sıkılaştırır, daha tok durur
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.getSubtle(context),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 14,
          width: 80,
          decoration: BoxDecoration(
            color: AppColors.getSubtle(context),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Spacer(), // Shimmer'da da sağa itiyoruz
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 20,
              width: 90,
              decoration: BoxDecoration(
                color: AppColors.getSubtle(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 10,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.getSubtle(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        )
      ],
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: AppColors.getBorder(context));
  }

  Widget _buildError(BuildContext context, ThemeData theme) {
    return Center(
      child: Text(
        'Unavailable',
        style: theme.textTheme.labelMedium?.copyWith(color: AppColors.error),
      ),
    );
  }
}