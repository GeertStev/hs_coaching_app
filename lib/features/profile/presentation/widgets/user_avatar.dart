import 'package:flutter/material.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';

/// Avatar van een gebruiker: profielfoto indien beschikbaar, anders de
/// initiaal van de voornaam op een gekleurde achtergrond.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    this.pictureUrl,
    this.radius = 18,
  });

  UserAvatar.fromUser(AppUser user, {Key? key, double radius = 18})
    : this(
        key: key,
        firstName: user.firstName,
        lastName: user.lastName,
        pictureUrl: user.picture,
        radius: radius,
      );

  final String firstName;
  final String lastName;
  final String? pictureUrl;
  final double radius;

  String get _initial {
    if (firstName.isNotEmpty) return firstName[0].toUpperCase();
    if (lastName.isNotEmpty) return lastName[0].toUpperCase();
    return '?';
  }

  /// Stabiele achtergrondkleur op basis van de naam.
  Color _backgroundColor(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.indigo,
      Colors.deepPurple,
      Colors.orange,
      Colors.pink,
      Colors.green,
      Colors.brown,
    ];
    final hash = '$firstName $lastName'.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = pictureUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
        // Bij een laadfout valt de avatar terug op de initiaal.
        onBackgroundImageError: (_, _) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: _backgroundColor(context),
      child: Text(
        _initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
