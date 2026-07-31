import 'badge_type.dart';

class Badge {
  final String id;

  final String nameKey;

  final String descriptionKey;

  final BadgeType type;

  final String icon;

  final int target;

  final bool unlocked;

  const Badge({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.type,
    required this.icon,
    required this.target,
    this.unlocked = false,
  });

  Badge copyWith({bool? unlocked}) {
    return Badge(
      id: id,
      nameKey: nameKey,
      descriptionKey: descriptionKey,
      type: type,
      icon: icon,
      target: target,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
