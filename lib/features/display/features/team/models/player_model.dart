/// Represents a single player.
class Player {
  Player({required this.name});
  final String name;

  /// Creates a Player from a structured JSON map.
  factory Player.fromJson(Map<String, dynamic> data) {
    final name = data['name'];
    if (name is! String || name.isEmpty) {
      throw FormatException(
        'Invalid JSON: "name" is required and must be a non-empty String in $data',
      );
    }
    return Player(name: name);
  }

  /// Creates a Player from a simple string.
  /// ToDo: This is for compatibility with the current Google Script data source.
  /// It should be removed when switching to a structured data source like Firebase.
  factory Player.fromString(String name) {
    if (name.isEmpty) {
      throw const FormatException('Invalid data: player name cannot be empty.');
    }
    return Player(name: name);
  }
}
