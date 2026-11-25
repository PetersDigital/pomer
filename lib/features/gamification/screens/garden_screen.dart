import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pomer/core/models/garden_models.dart';
import 'package:pomer/database/database.dart';
import 'package:pomer/features/gamification/providers/garden_provider.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardenAsync = ref.watch(userGardenProvider);
    final catalogAsync = ref.watch(plantCatalogProvider);
    final stats = ref.watch(gardenStatsProvider);
    final collection = ref.watch(plantCollectionProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Garden'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Garden'),
              Tab(text: 'Collection'),
            ],
          ),
        ),
        body: Column(
          children: [
            _GardenSummaryHeader(stats: stats),
            Expanded(
              child: TabBarView(
                children: [
                  _GardenGridTab(
                    gardenAsync: gardenAsync,
                    catalogAsync: catalogAsync,
                  ),
                  _CollectionTab(
                    gardenAsync: gardenAsync,
                    catalogAsync: catalogAsync,
                    collection: collection,
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

class _GardenSummaryHeader extends StatelessWidget {
  const _GardenSummaryHeader({required this.stats});

  final GardenStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withAlpha(110),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStatItem(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: colorScheme.primary,
                    value: '${stats.currentStreak}d',
                    label: 'Streak',
                  ),
                  _SummaryStatItem(
                    icon: Icons.emoji_events_outlined,
                    iconColor: colorScheme.tertiary,
                    value: '${stats.bestStreak}d',
                    label: 'Best',
                  ),
                  _SummaryStatItem(
                    icon: Icons.local_florist_outlined,
                    iconColor: colorScheme.secondary,
                    value: '${stats.totalHealthyPlants}',
                    label: 'Plants',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  const _SummaryStatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _GardenGridTab extends StatelessWidget {
  const _GardenGridTab({
    required this.gardenAsync,
    required this.catalogAsync,
  });

  final AsyncValue<List<UserGardenItem>> gardenAsync;
  final AsyncValue<List<PlantCatalogItem>> catalogAsync;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return gardenAsync.when(
      data: (garden) {
        if (garden.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 56,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your garden is empty. Start a focus session!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return catalogAsync.when(
          data: (catalog) {
            final catalogById = <int, PlantCatalogItem>{
              for (final item in catalog) item.id: item,
            };

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: garden.length,
                  itemBuilder: (context, index) {
                    final item = garden[index];
                    final catalogItem = catalogById[item.plantId];
                    final emoji = catalogItem?.emoji ?? '🌱';
                    final name = catalogItem?.name ?? 'Plant';
                    final dateStr = _formatDate(item.earnedAt);

                    return Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.durationMinutes}m · $dateStr',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading catalog: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading garden: $e')),
    );
  }
}

class _CollectionTab extends StatelessWidget {
  const _CollectionTab({
    required this.gardenAsync,
    required this.catalogAsync,
    required this.collection,
  });

  final AsyncValue<List<UserGardenItem>> gardenAsync;
  final AsyncValue<List<PlantCatalogItem>> catalogAsync;
  final List<PlantCollectionEntry> collection;

  @override
  Widget build(BuildContext context) {
    if (gardenAsync.isLoading || catalogAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gardenAsync.hasError) {
      return Center(child: Text('Error loading garden: ${gardenAsync.error}'));
    }

    if (catalogAsync.hasError) {
      return Center(
        child: Text('Error loading catalog: ${catalogAsync.error}'),
      );
    }

    if (collection.isEmpty) {
      return const Center(
        child: Text('No plants in catalog yet.'),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: collection.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = collection[index];
            final target = entry.rule.unlockTarget;
            final statusText = entry.isUnlocked
                ? (entry.earnedCount > 0
                    ? 'Grown ${entry.earnedCount}×'
                    : 'Unlocked')
                : 'Locked';

            return Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Opacity(
                      opacity: entry.isUnlocked ? 1.0 : 0.35,
                      child: Text(
                        entry.catalogItem.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.catalogItem.name,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                statusText,
                                style: textTheme.labelSmall?.copyWith(
                                  color: entry.isUnlocked
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.rule.description,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (target > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: entry.currentProgress / target,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.currentProgress} / $target',
                                  style: textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
