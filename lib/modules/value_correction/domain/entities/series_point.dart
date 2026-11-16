class SeriesPoint {
  final DateTime date;
  final double value;
  final DateTime? periodEnd;

  const SeriesPoint({required this.date, required this.value, this.periodEnd});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SeriesPoint &&
            other.date.year == date.year &&
            other.date.month == date.month &&
            other.date.day == date.day &&
            other.value == value &&
            other.periodEnd == periodEnd;
  }

  @override
  int get hashCode =>
      Object.hash(date.year, date.month, date.day, value, periodEnd);
}
