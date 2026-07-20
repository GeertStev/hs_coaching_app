// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String?,
  picture: json['picture'] as String?,
  role: json['role'] as String? ?? 'user',
  lastLogin: const NullableTimestampConverter().fromJson(json['lastLogin']),
  personalInfo:
      (json['personalInfo'] as List<dynamic>?)
          ?.map((e) => PersonalInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'picture': instance.picture,
  'role': instance.role,
  'lastLogin': const NullableTimestampConverter().toJson(instance.lastLogin),
  'personalInfo': instance.personalInfo,
};

_PersonalInfo _$PersonalInfoFromJson(Map<String, dynamic> json) =>
    _PersonalInfo(
      street: json['street'] as String?,
      number: json['number'] as String?,
      zipCode: json['zipCode'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String,
      birthday: const NullableTimestampConverter().fromJson(json['birthday']),
      gender: json['gender'] as String?,
      emergencyContacts:
          (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PersonalInfoToJson(_PersonalInfo instance) =>
    <String, dynamic>{
      'street': instance.street,
      'number': instance.number,
      'zipCode': instance.zipCode,
      'city': instance.city,
      'country': instance.country,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'birthday': const NullableTimestampConverter().toJson(instance.birthday),
      'gender': instance.gender,
      'emergencyContacts': instance.emergencyContacts,
    };

_EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    _EmergencyContact(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$EmergencyContactToJson(_EmergencyContact instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
    };
