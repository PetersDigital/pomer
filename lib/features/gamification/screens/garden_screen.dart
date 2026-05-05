import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/gamification/providers/garden_provider.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardenAsync = ref.watch(userGardenProvider);
    final catalogAsync = ref.watch(plantCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garden'),
        centerTitle: true,
      ),
      body: gardenAsync.when(
        data: (garden) {
          if (garden.isEmpty) {
            return const Center(
              child: Text(
                'Your garden is empty. Start a focus session!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return catalogAsync.when(
            data: (catalog) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: garden.length,
                itemBuilder: (context, index) {
                  final item = garden[index];
                  final catalogItem = catalog.firstWhere(
                    (c) => c.id == item.plantId,
                    orElse: () => catalog.first,
                  );

                  // Format date roughly as YYYY-MM-DD
                  final dateStr = item.earnedAt.toString().split(' ').first;

                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            catalogItem.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            catalogItem.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading catalog: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading garden: $e')),
      ),
    );
  }
}
