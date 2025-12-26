/// Settings Form Data Model
/// Holds the form state for settings screen
import 'package:flutter/material.dart';

class SettingsFormData {
  final TextEditingController incomeController;
  final TextEditingController currentBalanceController;
  final String selectedCurrency;
  final String selectedPayCycle;
  final DateTime nextPayday;

  SettingsFormData({
    required this.incomeController,
    required this.currentBalanceController,
    required this.selectedCurrency,
    required this.selectedPayCycle,
    required this.nextPayday,
  });

  SettingsFormData copyWith({
    TextEditingController? incomeController,
    TextEditingController? currentBalanceController,
    String? selectedCurrency,
    String? selectedPayCycle,
    DateTime? nextPayday,
  }) {
    return SettingsFormData(
      incomeController: incomeController ?? this.incomeController,
      currentBalanceController: currentBalanceController ?? this.currentBalanceController,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedPayCycle: selectedPayCycle ?? this.selectedPayCycle,
      nextPayday: nextPayday ?? this.nextPayday,
    );
  }

  void dispose() {
    incomeController.dispose();
    currentBalanceController.dispose();
  }
}

