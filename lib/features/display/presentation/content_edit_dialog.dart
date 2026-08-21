enum DialogAction { cancel, addToList, copy, display, save }

class ContentEditDialogResult {
  const ContentEditDialogResult({
    required this.action,
    required this.title,
    required this.description,
    required this.tags,
  });

  final DialogAction action;
  final String title;
  final String description;
  final List<String> tags;
}
