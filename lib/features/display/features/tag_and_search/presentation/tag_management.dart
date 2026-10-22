import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/data/tag_maintenance.dart';
import 'package:hs_coaching_app/features/display/features/tag_and_search/domain/tag_ops.dart';

/// Opent het beheermenu (Rename/Delete) voor [tag], bv. na lang drukken op
/// een filter-chip. [allTags] zijn alle tags van dit content-type, om een
/// samenvoeging te herkennen. [onChanged] krijgt `(from, to)` na een
/// geslaagde wijziging; `to` is leeg na verwijderen.
Future<void> showTagActions(
  BuildContext context, {
  required String tag,
  required int usageCount,
  required Iterable<String> allTags,
  required TagMaintenance maintenance,
  void Function(String from, String to)? onChanged,
}) async {
  final action = await showModalBottomSheet<_TagAction>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(tag, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(_itemsLabel(usageCount)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Rename'),
            onTap: () => Navigator.of(context).pop(_TagAction.rename),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete'),
            onTap: () => Navigator.of(context).pop(_TagAction.delete),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  final String to;
  switch (action) {
    case _TagAction.rename:
      final newName = await showDialog<String>(
        context: context,
        builder: (context) => _RenameTagDialog(
          tag: tag,
          otherTags: allTags.where((t) => tagKey(t) != tagKey(tag)).toList(),
        ),
      );
      if (newName == null || newName.isEmpty || newName == tag) return;
      to = newName;
    case _TagAction.delete:
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete tag "$tag"?'),
          content: Text(
            'The tag is removed from ${_itemsLabel(usageCount)}. '
            'The items themselves are kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      to = '';
  }

  try {
    if (to.isEmpty) {
      await maintenance.deleteTag(tag);
    } else {
      await maintenance.renameTag(tag, to);
    }
    onChanged?.call(tag, to);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not update tag: $e')));
  }
}

enum _TagAction { rename, delete }

String _itemsLabel(int count) => count == 1 ? '1 item' : '$count items';

class _RenameTagDialog extends StatefulWidget {
  const _RenameTagDialog({required this.tag, required this.otherTags});

  final String tag;
  final List<String> otherTags;

  @override
  State<_RenameTagDialog> createState() => _RenameTagDialogState();
}

class _RenameTagDialogState extends State<_RenameTagDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tag)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// De naam die echt opgeslagen wordt: bestaat er al een andere tag met
  /// dezelfde naam (hoofdletter-ongevoelig), dan wordt het die spelling en
  /// worden de twee samengevoegd.
  String get _result => canonicalTag(_controller.text, widget.otherTags);

  bool get _isMerge => containsTag(widget.otherTags, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename tag'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'New name',
          helperText: _isMerge ? 'Will be merged with "$_result".' : null,
        ),
        onSubmitted: (_) => Navigator.of(context).pop(_result),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _result.isEmpty
              ? null
              : () => Navigator.of(context).pop(_result),
          child: Text(_isMerge ? 'Merge' : 'Rename'),
        ),
      ],
    );
  }
}
