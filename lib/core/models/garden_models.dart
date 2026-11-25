import 'package:flutter/foundation.dart';
import 'package:pomer/database/database.dart';

enum PlantUnlockType {
  starter,
  healthyPlants,
  streakDays,
}

@immutable
class PlantMilestoneRule {
  const PlantMilestoneRule({
    required this.tier,
    required this.emoji,
    required this.name,
    required this.unlockType,
    required this.unlockTarget,
    required this.description,
  });

  final String tier;
  final String emoji;
  final String name;
  final PlantUnlockType unlockType;
  final int unlockTarget;
  final String description;
}

const List<PlantMilestoneRule> kPlantCatalogSpecs = [
  PlantMilestoneRule(
    tier: 'quick',
    emoji: '🌱',
    name: 'Sprout',
    unlockType: PlantUnlockType.starter,
    unlockTarget: 0,
    description: 'Complete a focus session under 20 min',
  ),
  PlantMilestoneRule(
    tier: 'standard',
    emoji: '🌷',
    name: 'Flower',
    unlockType: PlantUnlockType.starter,
    unlockTarget: 0,
    description: 'Complete a 20–49 min focus session',
  ),
  PlantMilestoneRule(
    tier: 'deep',
    emoji: '🌳',
    name: 'Tree',
    unlockType: PlantUnlockType.starter,
    unlockTarget: 0,
    description: 'Complete a 50+ min focus session',
  ),
  PlantMilestoneRule(
    tier: 'failed',
    emoji: '🥀',
    name: 'Withered',
    unlockType: PlantUnlockType.starter,
    unlockTarget: 0,
    description: 'Left behind when a focus session is interrupted',
  ),
  PlantMilestoneRule(
    tier: 'milestone_streak_3',
    emoji: '🌻',
    name: 'Sunflower',
    unlockType: PlantUnlockType.streakDays,
    unlockTarget: 3,
    description: 'Reach a 3-day focus streak',
  ),
  PlantMilestoneRule(
    tier: 'milestone_plants_5',
    emoji: '🌵',
    name: 'Cactus',
    unlockType: PlantUnlockType.healthyPlants,
    unlockTarget: 5,
    description: 'Grow 5 healthy plants',
  ),
  PlantMilestoneRule(
    tier: 'milestone_streak_7',
    emoji: '🎋',
    name: 'Bamboo',
    unlockType: PlantUnlockType.streakDays,
    unlockTarget: 7,
    description: 'Reach a 7-day focus streak',
  ),
  PlantMilestoneRule(
    tier: 'milestone_plants_15',
    emoji: '🌸',
    name: 'Cherry Blossom',
    unlockType: PlantUnlockType.healthyPlants,
    unlockTarget: 15,
    description: 'Grow 15 healthy plants',
  ),
  PlantMilestoneRule(
    tier: 'milestone_plants_30',
    emoji: '🌲',
    name: 'Pine',
    unlockType: PlantUnlockType.healthyPlants,
    unlockTarget: 30,
    description: 'Grow 30 healthy plants',
  ),
];

PlantMilestoneRule? plantRuleForTier(String tier) {
  for (final rule in kPlantCatalogSpecs) {
    if (rule.tier == tier) {
      return rule;
    }
  }
  return null;
}

@immutable
class GardenStats {
  const GardenStats({
    required this.totalHealthyPlants,
    required this.totalWitheredPlants,
    required this.currentStreak,
    required this.bestStreak,
  });

  const GardenStats.empty()
      : totalHealthyPlants = 0,
        totalWitheredPlants = 0,
        currentStreak = 0,
        bestStreak = 0;

  final int totalHealthyPlants;
  final int totalWitheredPlants;
  final int currentStreak;
  final int bestStreak;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GardenStats &&
          runtimeType == other.runtimeType &&
          totalHealthyPlants == other.totalHealthyPlants &&
          totalWitheredPlants == other.totalWitheredPlants &&
          currentStreak == other.currentStreak &&
          bestStreak == other.bestStreak;

  @override
  int get hashCode => Object.hash(
        totalHealthyPlants,
        totalWitheredPlants,
        currentStreak,
        bestStreak,
      );
}

@immutable
class PlantCollectionEntry {
  const PlantCollectionEntry({
    required this.catalogItem,
    required this.rule,
    required this.isUnlocked,
    required this.currentProgress,
    required this.earnedCount,
  });

  final PlantCatalogItem catalogItem;
  final PlantMilestoneRule rule;
  final bool isUnlocked;
  final int currentProgress;
  final int earnedCount;
}

@immutable
class GardenRewardEvent {
  const GardenRewardEvent({
    required this.eventId,
    required this.plant,
    required this.isWithered,
    required this.newlyUnlocked,
  });

  final int eventId;
  final PlantCatalogItem plant;
  final bool isWithered;
  final List<PlantCatalogItem> newlyUnlocked;
}

DateTime _toUtcCalendarDay(DateTime dateTime) {
  final local = dateTime.toLocal();
  return DateTime.utc(local.year, local.month, local.day);
}

GardenStats computeGardenStats({
  required List<UserGardenItem> garden,
  required Map<int, PlantCatalogItem> catalogById,
  DateTime? now,
}) {
  var totalHealthyPlants = 0;
  var totalWitheredPlants = 0;
  final healthyDays = <DateTime>{};

  for (final item in garden) {
    final catalogItem = catalogById[item.plantId];
    if (catalogItem?.tier == 'failed') {
      totalWitheredPlants++;
    } else {
      totalHealthyPlants++;
      healthyDays.add(_toUtcCalendarDay(item.earnedAt));
    }
  }

  if (healthyDays.isEmpty) {
    return GardenStats(
      totalHealthyPlants: totalHealthyPlants,
      totalWitheredPlants: totalWitheredPlants,
      currentStreak: 0,
      bestStreak: 0,
    );
  }

  final sortedDays = healthyDays.toList()..sort();

  var bestStreak = 0;
  var run = 0;
  for (var i = 0; i < sortedDays.length; i++) {
    if (i == 0 || sortedDays[i].difference(sortedDays[i - 1]).inDays == 1) {
      run++;
    } else {
      run = 1;
    }
    if (run > bestStreak) {
      bestStreak = run;
    }
  }

  final today = _toUtcCalendarDay(now ?? DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));
  final latestDay = sortedDays.last;

  var currentStreak = 0;
  if (latestDay == today || latestDay == yesterday) {
    currentStreak = 1;
    for (var i = sortedDays.length - 1; i > 0; i--) {
      if (sortedDays[i].difference(sortedDays[i - 1]).inDays == 1) {
        currentStreak++;
      } else {
        break;
      }
    }
  }

  return GardenStats(
    totalHealthyPlants: totalHealthyPlants,
    totalWitheredPlants: totalWitheredPlants,
    currentStreak: currentStreak,
    bestStreak: bestStreak,
  );
}

bool isPlantRuleUnlocked(PlantMilestoneRule rule, GardenStats stats) {
  switch (rule.unlockType) {
    case PlantUnlockType.starter:
      return true;
    case PlantUnlockType.healthyPlants:
      return stats.totalHealthyPlants >= rule.unlockTarget;
    case PlantUnlockType.streakDays:
      return stats.bestStreak >= rule.unlockTarget;
  }
}

int progressForPlantRule(PlantMilestoneRule rule, GardenStats stats) {
  switch (rule.unlockType) {
    case PlantUnlockType.starter:
      return 1;
    case PlantUnlockType.healthyPlants:
      return stats.totalHealthyPlants.clamp(0, rule.unlockTarget);
    case PlantUnlockType.streakDays:
      return stats.bestStreak.clamp(0, rule.unlockTarget);
  }
}

List<PlantCollectionEntry> buildPlantCollection({
  required List<PlantCatalogItem> catalog,
  required List<UserGardenItem> garden,
  required GardenStats stats,
}) {
  final catalogByTier = <String, PlantCatalogItem>{
    for (final item in catalog) item.tier: item,
  };
  final earnedCounts = <int, int>{};
  for (final item in garden) {
    earnedCounts[item.plantId] = (earnedCounts[item.plantId] ?? 0) + 1;
  }

  final entries = <PlantCollectionEntry>[];
  for (final rule in kPlantCatalogSpecs) {
    if (rule.tier == 'failed') continue;
    final catalogItem = catalogByTier[rule.tier];
    if (catalogItem == null) continue;

    entries.add(
      PlantCollectionEntry(
        catalogItem: catalogItem,
        rule: rule,
        isUnlocked: isPlantRuleUnlocked(rule, stats),
        currentProgress: progressForPlantRule(rule, stats),
        earnedCount: earnedCounts[catalogItem.id] ?? 0,
      ),
    );
  }

  return entries;
}
