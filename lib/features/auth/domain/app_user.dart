import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
    String? picture,
    required String role,
    @TimestampConverter() required DateTime lastLogin,
    @Default([]) List<PersonalInfo> personalInfo,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
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
    @TimestampConverter() DateTime? birthday,
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

/// A utility class for converting Firestore Timestamps to DateTime objects and vice-versa.
/// This is necessary for Freezed to correctly handle the conversion.
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
