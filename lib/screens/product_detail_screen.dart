import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/outfit.dart';
import '../widgets/outfit/clothing_item_card.dart';

/// Detailed breakdown of a recommended outfit with shoppable items.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final outfit = Get.arguments as Outfit?;
    final theme = Theme.of(context);
    if (outfit == null) {
      return const Scaffold(
        body: Center(child: Text('No outfit selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(outfit.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (_, index) {
          final item = outfit.items[index];
          return ClothingItemCard(item: item);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemCount: outfit.items.length,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FilledButton(
            onPressed: () {},
            child: Text(
              'Shop this outfit • \$${outfit.items.fold<double>(0, (sum, item) => sum + (item.price ?? 0)).toStringAsFixed(0)}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

