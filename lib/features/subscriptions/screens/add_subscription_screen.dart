/// Add Subscription Screen
/// Form for adding new subscriptions with templates
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/features/subscriptions/providers/subscription_providers.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/providers/currency_providers.dart';
import 'package:uuid/uuid.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  SubscriptionCategory _selectedCategory = SubscriptionCategory.streaming;
  RecurrenceFrequency _selectedFrequency = RecurrenceFrequency.monthly;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  String _selectedEmoji = '💳';
  bool _reminderEnabled = true;
  int _reminderDaysBefore = 2;

  bool _isLoading = false;
  bool _showTemplates = true;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectTemplate(Map<String, dynamic> template) {
    HapticFeedback.lightImpact();
    setState(() {
      _nameController.text = template['name'] as String;
      _amountController.text = (template['amount'] as double).toStringAsFixed(2);
      _selectedCategory = template['category'] as SubscriptionCategory;
      _selectedEmoji = template['emoji'] as String;
      _showTemplates = false;
    });
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      final subscription = Subscription(
        id: const Uuid().v4(),
        userId: userId,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        currency: 'USD',
        frequency: _selectedFrequency,
        category: _selectedCategory,
        nextBillingDate: _nextBillingDate,
        description: _descriptionController.text.trim(),
        emoji: _selectedEmoji,
        status: SubscriptionStatus.active,
        reminderEnabled: _reminderEnabled,
        reminderDaysBefore: _reminderDaysBefore,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(subscriptionNotifierProvider.notifier).addSubscription(subscription);

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${subscription.name} added successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      setState(() => _nextBillingDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.darkCharcoal,
        ),
        title: Text(
          'Add Subscription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkCharcoal,
          ),
        ),
        actions: [
          if (!_showTemplates)
            TextButton(
              onPressed: () => setState(() => _showTemplates = true),
              child: Text(
                'Templates',
                style: TextStyle(
                  color: AppColors.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _showTemplates ? _buildTemplatesView() : _buildFormView(),
      ),
    );
  }

  Widget _buildTemplatesView() {
    final theme = Theme.of(context);
    final templates = SubscriptionTemplates.templates;

    // Group templates by category
    final groupedTemplates = <SubscriptionCategory, List<Map<String, dynamic>>>{};
    for (final template in templates) {
      final category = template['category'] as SubscriptionCategory;
      groupedTemplates.putIfAbsent(category, () => []).add(template);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Subscriptions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap to quickly add a subscription or create a custom one',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Custom button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showTemplates = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: AppColors.pinkGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPink.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom Subscription',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Add any subscription manually',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),

        // Template categories
        ...groupedTemplates.entries.map((entry) {
          final category = entry.key;
          final categoryTemplates = entry.value;

          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _getCategoryDisplayName(category),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: categoryTemplates.map((template) {
                      return GestureDetector(
                        onTap: () => _selectTemplate(template),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                template['emoji'] as String,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                template['name'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildFormView() {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const BouncingScrollPhysics(),
        children: [
          // Name Field
          _buildSectionTitle('Subscription Name'),
          TextFormField(
            controller: _nameController,
            decoration: _buildInputDecoration(
              'e.g., Netflix, Spotify',
              prefixIcon: Text(
                _selectedEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

          const SizedBox(height: AppSpacing.lg),

          // Emoji Selector
          _buildSectionTitle('Icon'),
          _buildEmojiSelector().animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: AppSpacing.lg),

          // Amount Field
          _buildSectionTitle('Amount'),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _buildInputDecoration(
              '0.00',
              prefixIcon: Text(
                ref.watch(currencySymbolProvider),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          const SizedBox(height: AppSpacing.lg),

          // Frequency
          _buildSectionTitle('Billing Frequency'),
          _buildFrequencySelector().animate().fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: AppSpacing.lg),

          // Category
          _buildSectionTitle('Category'),
          _buildCategorySelector().animate().fadeIn(duration: 300.ms, delay: 250.ms),

          const SizedBox(height: AppSpacing.lg),

          // Next Billing Date
          _buildSectionTitle('Next Billing Date'),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.lightGray),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: AppColors.primaryPink),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${_nextBillingDate.day}/${_nextBillingDate.month}/${_nextBillingDate.year}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: AppColors.mediumGray),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

          const SizedBox(height: AppSpacing.lg),

          // Reminder Settings
          _buildSectionTitle('Reminders'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill Reminders',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Switch.adaptive(
                      value: _reminderEnabled,
                      onChanged: (value) => setState(() => _reminderEnabled = value),
                      activeColor: AppColors.primaryPink,
                    ),
                  ],
                ),
                if (_reminderEnabled) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remind me',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                      DropdownButton<int>(
                        value: _reminderDaysBefore,
                        underline: const SizedBox(),
                        items: [1, 2, 3, 5, 7].map((days) {
                          return DropdownMenuItem(
                            value: days,
                            child: Text('$days day${days > 1 ? 's' : ''} before'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reminderDaysBefore = value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

          const SizedBox(height: AppSpacing.xl),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add Subscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.mediumGray,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.mediumGray.withOpacity(0.5)),
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: prefixIcon,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: AppColors.cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: AppColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: AppColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: AppColors.primaryPink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    );
  }

  Widget _buildEmojiSelector() {
    final emojis = ['💳', '🎬', '🎵', '☁️', '💪', '🎮', '📦', '📰', '📚', '🍔', '💰', '🔌'];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: emojis.map((emoji) {
        final isSelected = _selectedEmoji == emoji;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedEmoji = emoji);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryPink.withOpacity(0.1) : AppColors.subtleGray,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: isSelected
                  ? Border.all(color: AppColors.primaryPink, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    final frequencies = [
      (RecurrenceFrequency.weekly, 'Weekly'),
      (RecurrenceFrequency.biweekly, 'Bi-weekly'),
      (RecurrenceFrequency.monthly, 'Monthly'),
      (RecurrenceFrequency.quarterly, 'Quarterly'),
      (RecurrenceFrequency.yearly, 'Yearly'),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: frequencies.map((freq) {
        final isSelected = _selectedFrequency == freq.$1;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedFrequency = freq.$1);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.pinkGradient : null,
              color: isSelected ? null : AppColors.subtleGray,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: Text(
              freq.$2,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkCharcoal,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    final categories = SubscriptionCategory.values;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: categories.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = category);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.pinkGradient : null,
              color: isSelected ? null : AppColors.subtleGray,
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
            child: Text(
              _getCategoryDisplayName(category),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkCharcoal,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getCategoryDisplayName(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.streaming:
        return 'Streaming';
      case SubscriptionCategory.productivity:
        return 'Productivity';
      case SubscriptionCategory.cloudStorage:
        return 'Cloud Storage';
      case SubscriptionCategory.fitness:
        return 'Fitness';
      case SubscriptionCategory.gaming:
        return 'Gaming';
      case SubscriptionCategory.newsMedia:
        return 'News & Media';
      case SubscriptionCategory.foodDelivery:
        return 'Food Delivery';
      case SubscriptionCategory.shopping:
        return 'Shopping';
      case SubscriptionCategory.finance:
        return 'Finance';
      case SubscriptionCategory.education:
        return 'Education';
      case SubscriptionCategory.utilities:
        return 'Utilities';
      case SubscriptionCategory.other:
        return 'Other';
    }
  }
}

