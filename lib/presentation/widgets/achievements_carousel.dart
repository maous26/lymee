import 'package:flutter/material.dart' hide Badge;
import 'package:lym_nutrition/presentation/models/gamification_models.dart'
    as gamify;

class AchievementsCarousel extends StatelessWidget {
  final List<gamify.Badge> badges;
  const AchievementsCarousel({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _BadgeTile(badge: badges[index]),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: badges.length,
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final gamify.Badge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final color = badge.unlocked ? badge.color : Colors.grey;
    final bg = color.withValues(alpha: 0.12);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(badge.icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  badge.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  badge.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
