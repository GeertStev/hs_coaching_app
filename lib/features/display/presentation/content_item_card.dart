import 'package:flutter/material.dart';

class ContentItemCard extends StatelessWidget {
  const ContentItemCard({
    super.key,
    required this.id,
    required this.title,
    required this.isCurrent,
    required this.onDismissed,
    required this.onUndo,
    required this.onTap,
    required this.child,
  });

  final String id;
  final String title;
  final bool isCurrent;
  final VoidCallback onDismissed;
  final VoidCallback onUndo;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismissed();
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('"$title" archived.'),
              action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
            ),
          );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: isCurrent
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}
