enum SummaryPeriod {
  weekly,
  biWeekly,
  monthly;

  String get label {
    switch (this) {
      case SummaryPeriod.weekly:
        return 'Weekly';
      case SummaryPeriod.biWeekly:
        return 'Bi-Weekly';
      case SummaryPeriod.monthly:
        return 'Monthly';
    }
  }
}
