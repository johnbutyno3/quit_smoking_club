class BadgeProgress {
  final String badgeId;

  final int currentValue;

  final bool unlocked;

  const BadgeProgress({
    required this.badgeId,
    required this.currentValue,
    this.unlocked = false,
  });

  double get progress {
    if (currentValue <= 0) {
      return 0;
    }

    return currentValue / 100;
  }

  BadgeProgress copyWith({int? currentValue, bool? unlocked}) {
    return BadgeProgress(
      badgeId: badgeId,
      currentValue: currentValue ?? this.currentValue,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
