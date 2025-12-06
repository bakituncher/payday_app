/// Payment Calendar Screen
/// Shows upcoming subscription payments in calendar view
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';
import 'package:payday_flutter/core/models/subscription.dart';
import 'package:payday_flutter/features/subscriptions/providers/subscription_providers.dart';
import 'package:intl/intl.dart';

class PaymentCalendarScreen extends ConsumerStatefulWidget {
  const PaymentCalendarScreen({super.key});

  @override
  ConsumerState<PaymentCalendarScreen> createState() => _PaymentCalendarScreenState();
}

class _PaymentCalendarScreenState extends ConsumerState<PaymentCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.darkCharcoal,
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Payment Calendar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
      ),
      body: subscriptionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryPink),
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (subscriptions) => _buildContent(context, subscriptions),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Subscription> subscriptions) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Get payments for selected date
    final selectedDatePayments = subscriptions.where((sub) {
      return sub.nextBillingDate.year == _selectedDate.year &&
             sub.nextBillingDate.month == _selectedDate.month &&
             sub.nextBillingDate.day == _selectedDate.day;
    }).toList();

    // Get total for selected month
    final monthPayments = subscriptions.where((sub) {
      return sub.nextBillingDate.year == _focusedMonth.year &&
             sub.nextBillingDate.month == _focusedMonth.month;
    }).toList();

    final monthTotal = monthPayments.fold<double>(0, (sum, sub) => sum + sub.amount);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Month Summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(monthTotal),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${monthPayments.length} payments this month',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: AppSpacing.lg),

        // Calendar
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              // Month navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month - 1,
                        );
                      });
                    },
                    color: AppColors.darkCharcoal,
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                        );
                      });
                    },
                    color: AppColors.darkCharcoal,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Weekday headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((day) => SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              day,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mediumGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Calendar grid
              _buildCalendarGrid(context, subscriptions),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

        const SizedBox(height: AppSpacing.lg),

        // Selected date payments
        Text(
          DateFormat('EEEE, MMMM d').format(_selectedDate),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkCharcoal,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (selectedDatePayments.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available_rounded, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'No payments on this date',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms)
        else
          ...selectedDatePayments.asMap().entries.map((entry) {
            final index = entry.key;
            final sub = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Text(sub.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        Text(
                          sub.frequencyText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(sub.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
          }),

        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, List<Subscription> subscriptions) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final today = DateTime.now();

    // Get dates with payments
    final paymentDates = <int, List<Subscription>>{};
    for (final sub in subscriptions) {
      if (sub.nextBillingDate.year == _focusedMonth.year &&
          sub.nextBillingDate.month == _focusedMonth.month) {
        final day = sub.nextBillingDate.day;
        paymentDates.putIfAbsent(day, () => []).add(sub);
      }
    }

    final rows = <Widget>[];
    var cells = <Widget>[];

    // Empty cells for days before month starts
    for (var i = 0; i < startingWeekday; i++) {
      cells.add(const SizedBox(width: 40, height: 44));
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
      final isSelected = date.year == _selectedDate.year &&
                         date.month == _selectedDate.month &&
                         date.day == _selectedDate.day;
      final hasPayment = paymentDates.containsKey(day);
      final paymentCount = paymentDates[day]?.length ?? 0;

      cells.add(
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedDate = date);
          },
          child: Container(
            width: 40,
            height: 44,
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.pinkGradient : null,
              color: isSelected ? null : (isToday ? AppColors.subtleGray : null),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isToday ? AppColors.primaryPink : AppColors.darkCharcoal),
                    fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (hasPayment)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      paymentCount > 3 ? 3 : paymentCount,
                      (i) => Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primaryPink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      if (cells.length == 7) {
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: cells,
          ),
        );
        cells = [];
      }
    }

    // Fill remaining cells
    while (cells.length < 7 && cells.isNotEmpty) {
      cells.add(const SizedBox(width: 40, height: 44));
    }
    if (cells.isNotEmpty) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cells,
        ),
      );
    }

    return Column(
      children: rows.map((row) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      )).toList(),
    );
  }
}

