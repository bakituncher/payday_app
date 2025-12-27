/// Add Savings Goal Screen - Create new savings goal with auto-transfer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/savings_goal.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/core/services/currency_service.dart';
import 'package:uuid/uuid.dart';

class AddSavingsGoalScreen extends ConsumerStatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  ConsumerState<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends ConsumerState<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _autoTransferAmountController = TextEditingController();

  String _selectedEmoji = '🏠';
  bool _autoTransferEnabled = false;
  DateTime? _targetDate;
  bool _isLoading = false;

  final List<Map<String, String>> _goalTemplates = [
    {'emoji': '🏠', 'name': 'Home'},
    {'emoji': '🚗', 'name': 'Car'},
    {'emoji': '✈️', 'name': 'Vacation'},
    {'emoji': '💍', 'name': 'Wedding'},
    {'emoji': '🎓', 'name': 'Education'},
    {'emoji': '💻', 'name': 'Laptop'},
    {'emoji': '📱', 'name': 'Phone'},
    {'emoji': '🎮', 'name': 'Gaming'},
    {'emoji': '💰', 'name': 'Emergency Fund'},
    {'emoji': '🎁', 'name': 'Gift'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _autoTransferAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkCharcoal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _targetDate = date;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    // Get user ID from provider (works for both authenticated and guest users)
    final userId = ref.read(currentUserIdProvider);

    print('💾 Saving goal - User ID: $userId');

    setState(() {
      _isLoading = true;
    });

    try {
      final goal = SavingsGoal(
        id: const Uuid().v4(),
        userId: userId,
        name: _nameController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: 0.0,
        emoji: _selectedEmoji,
        createdAt: DateTime.now(),
        targetDate: _targetDate,
        autoTransferEnabled: _autoTransferEnabled,
        autoTransferAmount: _autoTransferEnabled
            ? double.parse(_autoTransferAmountController.text)
            : 0.0,
      );

      print('💾 Goal created: ${goal.toJson()}');

      final repository = ref.read(savingsGoalRepositoryProvider);
      print('💾 Repository type: ${repository.runtimeType}');

      await repository.addSavingsGoal(goal);
      print('💾 Goal saved successfully');

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Goal "${goal.name}" created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving goal: $e');
      _showError('Failed to create goal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userSettingsAsync = ref.watch(userSettingsProvider);

    final currency = userSettingsAsync.when(
      data: (settings) => settings?.currency ?? 'USD',
      loading: () => 'USD',
      error: (_, __) => 'USD',
    );

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Savings Goal',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.getTextPrimary(context),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Emoji Selection
            Text(
              'Goal Icon',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _goalTemplates.map((template) {
                  final isSelected = _selectedEmoji == template['emoji'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedEmoji = template['emoji']!;
                        if (_nameController.text.isEmpty) {
                          _nameController.text = template['name']!;
                        }
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPink.withValues(alpha: 0.1)
                            : AppColors.getSubtle(context),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPink
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          template['emoji']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Goal Name
            Text(
              'Goal Name',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. New Home, Car',
                filled: true,
                fillColor: AppColors.getCardBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.getBorder(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.getBorder(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a goal name';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Target Amount
            Text(
              'Target Amount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                prefixText: _getCurrencySymbol(currency),
                filled: true,
                fillColor: AppColors.getCardBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.getBorder(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.getBorder(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a target amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Target Date
            Text(
              'Target Date (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _selectTargetDate,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.getBorder(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primaryPink,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _targetDate != null
                          ? _formatDate(_targetDate!)
                          : 'Select date',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _targetDate != null
                            ? AppColors.getTextPrimary(context)
                            : AppColors.getTextSecondary(context),
                      ),
                    ),
                    const Spacer(),
                    if (_targetDate != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          setState(() {
                            _targetDate = null;
                          });
                        },
                        color: AppColors.getTextSecondary(context),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Auto-transfer section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sync_rounded,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Auto-Transfer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                      Switch(
                        value: _autoTransferEnabled,
                        onChanged: (value) {
                          setState(() {
                            _autoTransferEnabled = value;
                          });
                        },
                        activeColor: AppColors.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Automatically transfer money to this goal on every payday',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                    ),
                  ),

                  if (_autoTransferEnabled) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _autoTransferAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Transfer Amount',
                        hintText: '0',
                        prefixText: _getCurrencySymbol(currency),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.info),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.info.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.info, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (_autoTransferEnabled) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the transfer amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Create Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    final currencyService = CurrencyUtilityService();
    return currencyService.getSymbol(currency);
  }

  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}