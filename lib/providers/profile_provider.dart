import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';

import '../profile/model.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileState());

  final ImagePicker _picker = const ImagePicker();

  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      state = state.copyWith(
        selectedImage: File(pickedFile.path),
        isUploading: true,
      );

      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false);
    }
  }

  void toggleBiometric(bool value) {
    state = state.copyWith(biometricEnabled: value);
  }
}

class ProfileState {
  final File? selectedImage;
  final bool isUploading;
  final bool biometricEnabled;
  final AgentProfileModel agentData;

  const ProfileState({
    this.selectedImage,
    this.isUploading = false,
    this.biometricEnabled = true,
    this.agentData = const AgentProfileModel(
      agentId: 'AGT-00821',
      agentCode: 'AGT-998214',
      fullName: 'Alex',
      designation: 'Senior Life Insurance Agent',
      phone: '+95 9 790 123 456',
      email: 'alex.kbz@kbzlife.com',
      branchName: 'Yangon Main Branch',
      supervisorName: 'U Kyaw Myo',
      status: AgentStatus.active,
    ),
  });

  ProfileState copyWith({
    File? selectedImage,
    bool? isUploading,
    bool? biometricEnabled,
    AgentProfileModel? agentData,
  }) {
    return ProfileState(
      selectedImage: selectedImage ?? this.selectedImage,
      isUploading: isUploading ?? this.isUploading,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      agentData: agentData ?? this.agentData,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileController, ProfileState>(
  (ref) => ProfileController(),
);
