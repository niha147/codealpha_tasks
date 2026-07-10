class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final int progress;
  final int target;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    required this.progress,
    required this.target,
  });
}
