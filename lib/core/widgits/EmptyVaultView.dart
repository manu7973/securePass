import 'package:flutter/material.dart';

class EmptyVaultView extends StatelessWidget {
  final bool isFiltered;

  const EmptyVaultView({super.key, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    final title = isFiltered
        ? 'No favorite passwords'
        : 'Your vault is empty';

    final subtitle = isFiltered
        ? 'Mark passwords as favorite to see them here'
        : 'Add your first password to keep it secure';

    final icon = isFiltered
        ? Icons.favorite_border
        : Icons.lock_outline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}