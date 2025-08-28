import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/models/gamification_models.dart';

class DailyQuestsCard extends StatelessWidget {
  final List<Quest> quests;
  final void Function(Quest)? onQuestTap;

  const DailyQuestsCard({super.key, required this.quests, this.onQuestTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Quêtes du jour',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...quests.map((q) => _QuestTile(quest: q, onTap: onQuestTap)),
          ],
        ),
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  final Quest quest;
  final void Function(Quest)? onTap;

  const _QuestTile({required this.quest, this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = quest.completionPercent;
    final color = quest.isCompleted ? Colors.green : Colors.teal;
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(quest),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(quest.icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          quest.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('+${quest.rewardXP} XP',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w700)),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
