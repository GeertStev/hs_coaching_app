import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/data/auth_providers.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';
import 'package:hs_coaching_app/features/profile/data/user_profile_repository.dart';
import 'package:image_picker/image_picker.dart';

/// Controller voor alle profiel- en accountacties vanuit het profielscherm.
class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  String get _uid {
    final uid = ref.read(currentUidProvider);
    if (uid == null) throw StateError('Niet ingelogd.');
    return uid;
  }

  Future<bool> _guard(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }

  Future<bool> updateNames({
    required String firstName,
    required String lastName,
  }) {
    return _guard(
      () => ref
          .read(userProfileRepositoryProvider)
          .updateNames(uid: _uid, firstName: firstName, lastName: lastName),
    );
  }

  /// Kiest een foto (galerij of camera) en uploadt die als profielfoto.
  /// Geeft `false` terug als er niets gekozen is of de upload faalde.
  Future<bool> pickAndUploadPicture(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return false;
    return _guard(
      () => ref
          .read(userProfileRepositoryProvider)
          .uploadPicture(uid: _uid, file: File(picked.path)),
    );
  }

  Future<bool> removePicture() {
    return _guard(
      () => ref.read(userProfileRepositoryProvider).removePicture(_uid),
    );
  }

  Future<bool> setPersonalInfo(List<PersonalInfo> info) {
    return _guard(
      () => ref.read(userProfileRepositoryProvider).setPersonalInfo(_uid, info),
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _guard(
      () => ref.read(authRepositoryProvider).changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  Future<bool> sendEmailVerification() {
    return _guard(
      () => ref.read(authRepositoryProvider).sendEmailVerification(),
    );
  }

  Future<bool> deleteAccount({required String currentPassword}) {
    return _guard(
      () => ref
          .read(authRepositoryProvider)
          .deleteAccount(currentPassword: currentPassword),
    );
  }
}

final profileControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfileController, void>(
      ProfileController.new,
    );
