import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/home/providers/historical_providers.dart';
import 'package:payday/features/savings/screens/savings_screen.dart';
import 'dart:math' as math;

class SectorStyleSummaryCard extends ConsumerWidget {
  const SectorStyleSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(totalExpensesProvider);
    final budgetAsync = ref.watch(userSettingsProvider);
    final dailySpendAsync = ref.watch(dailyAllowableSpendProvider);

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bu Dönem',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Özet Durum',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.savings_outlined, color: Colors.white),
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavingsScreen()),
                      );
                    },
                    tooltip: 'Tasarruf Hedefleri',
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Main Balance / Progress
              expensesAsync.when(
                data: (expenses) => budgetAsync.when(
                  data: (settings) {
                    if (settings == null) return const SizedBox.shrink();
                    final income = settings.incomeAmount;
                    final progress = (expenses / income).clamp(0.0, 1.0);
                    final remaining = income - expenses;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Harcanan',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  NumberFormat.currency(symbol: '₺', decimalDigits: 0).format(expenses),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Kalan Limit',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  NumberFormat.currency(symbol: '₺', decimalDigits: 0).format(remaining),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Custom Progress Bar
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: progress > 0.9 ? Colors.redAccent : Colors.greenAccent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (progress > 0.9 ? Colors.redAccent : Colors.greenAccent).withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Veri yüklenemedi', style: TextStyle(color: Colors.white)),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Stats / Daily Safe Spend
              dailySpendAsync.when(
                data: (daily) => Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 16),
                                SizedBox(width: 4),
                                Text('Günlük Limit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.currency(symbol: '₺', decimalDigits: 0).format(daily),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                           // Expand to show history/charts
                           showModalBottomSheet(
                             context: context,
                             isScrollControlled: true,
                             backgroundColor: Colors.transparent,
                             builder: (_) => const HistoricalStatsSheet()
                           );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bar_chart, color: Colors.white70, size: 16),
                                  SizedBox(width: 4),
                                  Text('Geçmiş', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'İstatistikler',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoricalStatsSheet extends ConsumerWidget {
  const HistoricalStatsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historicalSpendingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Harcama Geçmişi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Son 6 aylık harcama trendi',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: historyAsync.when(
              data: (data) => HistoricalChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Veri yüklenemedi: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoricalChart extends StatelessWidget {
  final Map<DateTime, double> data;

  const HistoricalChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Veri yok'));

    final sortedKeys = data.keys.toList()..sort();
    final maxValue = data.values.isEmpty ? 1.0 : data.values.reduce(math.max);
    // Avoid division by zero
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        // Ensure we fit all bars
        final barWidth = (width / sortedKeys.length) * 0.5;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: sortedKeys.map((date) {
            final value = data[date] ?? 0.0;
            final heightFactor = (value / safeMax).clamp(0.0, 1.0);

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: NumberFormat.currency(symbol: '₺').format(value),
                  child: Container(
                    width: barWidth,
                    height: math.max(4.0, height * heightFactor), // Minimum visible height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.blue.shade300, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM', 'tr').format(date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
