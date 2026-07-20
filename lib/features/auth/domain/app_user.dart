import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hs_coaching_app/core/data/firestore_converters.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String uid,
    required String firstName,
    required String lastName,
    String? email,
    String? picture,
    @Default('user') String role,
    @NullableTimestampConverter() DateTime? lastLogin,
    @Default([]) List<PersonalInfo> personalInfo,
  }) = _AppUser;

  const AppUser._();

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  /// Volledige naam voor weergave.
  String get fullName => '$firstName $lastName'.trim();

  /// Initiaal voor de avatar (voornaam, anders achternaam, anders '?').
  String get initial {
    if (firstName.isNotEmpty) return firstName[0].toUpperCase();
    if (lastName.isNotEmpty) return lastName[0].toUpperCase();
    return '?';
  }
}

@freezed
abstract class PersonalInfo with _$PersonalInfo {
  const factory PersonalInfo({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String id,
    String? street,
    String? number,
    String? zipCode,
    String? city,
    String? country,
    String? phoneNumber,
    required String email,
    @NullableTimestampConverter() DateTime? birthday,
    String? gender,
    @Default([]) List<EmergencyContact> emergencyContacts,
  }) = _PersonalInfo;

  factory PersonalInfo.fromJson(Map<String, dynamic> json) =>
      _$PersonalInfoFromJson(json);
}

@freezed
abstract class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String id,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}
