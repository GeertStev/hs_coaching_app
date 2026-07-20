import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.dateModified,
    this.onPrimaryIconPressed,
    this.secondaryIcon,
    this.secondaryIconTooltip,
    this.onSecondaryIconPressed,
    this.onLongPress,
  });

  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final DateTime? dateModified;

  final VoidCallback? onPrimaryIconPressed;

  final IconData? secondaryIcon;
  final String? secondaryIconTooltip;
  final VoidCallback? onSecondaryIconPressed;

  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget? subtitleWidget;
    if (subtitle != null || dateModified != null) {
      subtitleWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (dateModified != null) ...[
            const SizedBox(height: 8),
            Text(
              'Modified on ${DateFormat('dd MMM yyyy, HH:mm').format(dateModified!.toLocal())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      );
    }

    final tile = ListTile(
      title: Text(
        title ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitleWidget,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onPrimaryIconPressed != null)
            IconButton(
              icon: Icon(Icons.more_horiz_outlined),
              tooltip: 'Edit Details',
              onPressed: onPrimaryIconPressed,
            ),
          if (secondaryIcon != null)
            IconButton(
              icon: Icon(secondaryIcon),
              tooltip: secondaryIconTooltip,
              onPressed: onSecondaryIconPressed,
            ),
        ],
      ),
      onLongPress: onLongPress,
    );

    if (!hasImage) {
      return tile;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 100,
            child: Image.network(
              imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Expanded(child: tile),
        ],
      ),
    );
  }
}
