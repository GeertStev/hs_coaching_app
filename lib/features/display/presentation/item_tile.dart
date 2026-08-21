import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hs_coaching_app/core/theme/app_theme.dart';

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
  });

  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final DateTime? dateModified;

  final VoidCallback? onPrimaryIconPressed;

  final IconData? secondaryIcon;
  final String? secondaryIconTooltip;
  final VoidCallback? onSecondaryIconPressed;

  static const _thumbnailWidth = 120.0;
  static const _thumbnailHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final typography = Theme.of(context).appTypography;
    final colorScheme = Theme.of(context).colorScheme;
    final metrics = Theme.of(context).appMetrics;

    Widget? subtitleWidget;
    if (subtitle != null || dateModified != null) {
      subtitleWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            SizedBox(height: metrics.spacingXs),
            Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (dateModified != null) ...[
            SizedBox(height: metrics.spacingSm),
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
        style: typography.bodyLg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // subtitle blijft ongestyled: erft ListTile's standaard bodyMedium
      // (= AppTypography.bodyMd, via AppTheme's textTheme), gedimd naar
      // onSurfaceVariant — geen reden om dat hier te herhalen.
      subtitle: subtitleWidget,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onPrimaryIconPressed != null)
            IconButton(
              icon: const Icon(Icons.more_horiz_outlined),
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
    );

    if (!hasImage) {
      return tile;
    }

    return Padding(
      padding: EdgeInsets.only(left: metrics.gutter),
      child: Row(
        children: [
          SizedBox(
            width: _thumbnailWidth,
            height: _thumbnailHeight,
            child: Image.network(
              imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(metrics.spacingSm),
                    child: Icon(
                      Icons.broken_image,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
