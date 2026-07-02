import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/display/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_app/features/display/features/sketch/domain/sketch_background.dart';
import 'package:hs_coaching_app/features/display/features/sketch/presentation/widgets/add_sketch_background_dialog.dart';

class SelectSketchBackgroundDialog extends ConsumerWidget {
  const SelectSketchBackgroundDialog({
    super.key,
    required this.initialSelectedUrl,
  });

  final String? initialSelectedUrl;

  void _showAddBackgroundDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddSketchBackgroundDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundsAsync = ref.watch(sketchBackgroundsProvider);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Select Background'),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            tooltip: 'Upload New Background',
            onPressed: () => _showAddBackgroundDialog(context),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: backgroundsAsync.when(
          data: (backgrounds) {
            if (backgrounds.isEmpty) {
              return const Center(
                child: Text('No backgrounds available. Upload one to start.'),
              );
            }
            // Add a "None" option at the beginning
            final allOptions = [
              const SketchBackground(title: 'None', url: ''),
              ...backgrounds,
            ];

            return ListView.builder(
              itemCount: allOptions.length,
              itemBuilder: (context, index) {
                final bg = allOptions[index];
                final isSelected =
                    initialSelectedUrl == bg.url ||
                    (initialSelectedUrl == null && bg.url.isEmpty);

                return Card(
                  clipBehavior: Clip.antiAlias,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(bg.title),
                    leading: bg.url.isEmpty
                        ? const SizedBox(
                            width: 56,
                            child: Icon(Icons.image_not_supported_outlined),
                          )
                        : SizedBox(
                            width: 56,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(bg.url, fit: BoxFit.cover),
                            ),
                          ),
                    onTap: () {
                      // Return null for "None", otherwise the URL
                      Navigator.of(context).pop(bg.url.isEmpty ? null : bg.url);
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
