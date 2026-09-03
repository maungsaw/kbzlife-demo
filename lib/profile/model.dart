enum ImageSource { gallery, camera }

class XFile {
  const XFile(this.path);

  final String path;
}

class ImagePicker {
  const ImagePicker();

  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return null;
  }
}

enum AgentStatus { active, suspended, inactive }

class AgentProfileModel {
  final String agentId;
  final String agentCode;
  final String fullName;
  final String designation;
  final String phone;
  final String email;
  final String branchName;
  final String supervisorName;
  final String? profileImageUrl;
  final AgentStatus status;

  const AgentProfileModel({
    required this.agentId,
    required this.agentCode,
    required this.fullName,
    required this.designation,
    required this.phone,
    required this.email,
    required this.branchName,
    required this.supervisorName,
    this.profileImageUrl,
    required this.status,
  });

  factory AgentProfileModel.fromJson(Map<String, dynamic> json) {
    return AgentProfileModel(
      agentId: json['agent_id'] as String,
      agentCode: json['agent_code'] as String,
      fullName: json['full_name'] as String,
      designation: json['designation'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      branchName: json['branch_name'] as String,
      supervisorName: json['supervisor_name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      status: AgentStatus.values.byName(json['status'] ?? 'active'),
    );
  }
}
