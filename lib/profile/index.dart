import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/router_provider.dart';
import 'model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.onLogout});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // --- Profile Picture Compression & Upload Handler ---
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      await ref.read(profileProvider.notifier).pickAndUploadImage(source);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppColors.accentNavy,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update picture: $e'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Update Profile Photo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentNavy,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ListTile(
              tileColor: Colors.white,
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.accentNavy,
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontSize: 13),
              ),
              onTap: () {
                context.pop();
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              tileColor: Colors.white,
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.accentNavy,
              ),
              title: const Text('Take Photo', style: TextStyle(fontSize: 13)),
              onTap: () {
                context.pop();
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBodyContent() {
    final profileState = ref.watch(profileProvider);
    final agentData = profileState.agentData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: profileState.selectedImage != null
                          ? FileImage(profileState.selectedImage!)
                                as ImageProvider
                          : null,
                      child: profileState.selectedImage == null
                          ? const Icon(Icons.person, size: 45)
                          : null,
                    ),
                  ),
                  if (profileState.isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: profileState.isUploading
                          ? null
                          : _showImagePickerBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                agentData.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                agentData.designation,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
                    SizedBox(width: 6),
                    Text(
                      'Active Agent',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Stats Row
        Transform.translate(
          offset: const Offset(0, -20),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(Icons.description_outlined, '12', 'Policies'),
                _buildStatDivider(),
                _buildStatItem(Icons.attach_money, '8.5K', 'FYP'),
                _buildStatDivider(),
                _buildStatItem(Icons.trending_up, '75%', 'Persistency'),
              ],
            ),
          ),
        ),

        // Quick Links
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Links',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickLinkCard(
                      Icons.assignment_outlined,
                      'e-App',
                      const Color(0xFF6366F1),
                      () => context.push(RoutePaths.eapp),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickLinkCard(
                      Icons.task_alt_outlined,
                      'Tasks',
                      const Color(0xFF10B981),
                      () => context.push(RoutePaths.taskList),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickLinkCard(
                      Icons.find_in_page_outlined,
                      'Policy',
                      const Color(0xFFF59E0B),
                      () => context.push(RoutePaths.policyList),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Account Info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _buildIOSSettingsGroup([
                _buildInfoTile(
                  Icons.badge_outlined,
                  'Agent Code',
                  agentData.agentCode,
                  iconColor: const Color(0xFF6366F1),
                  iconBg: const Color(0xFFEEF2FF),
                ),
                _buildInfoTile(
                  Icons.phone_android_outlined,
                  'Phone',
                  agentData.phone,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0xFFECFDF5),
                ),
                _buildInfoTile(
                  Icons.email_outlined,
                  'Email',
                  agentData.email,
                  iconColor: const Color(0xFF3B82F6),
                  iconBg: const Color(0xFFEFF6FF),
                ),
                _buildInfoTile(
                  Icons.location_city_outlined,
                  'Branch',
                  agentData.branchName,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0xFFFEF3C7),
                ),
                _buildInfoTile(
                  Icons.supervisor_account_outlined,
                  'Supervisor',
                  agentData.supervisorName,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF5F3FF),
                  showDivider: false,
                ),
              ]),
            ],
          ),
        ),

        // Settings - iOS Style
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              _buildIOSSettingsGroup([
                _buildIOSSettingTile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF6366F1),
                  iconBg: const Color(0xFFEEF2FF),
                  title: 'Change Password',
                  onTap: () => context.push(RoutePaths.changePassword),
                ),
                _buildIOSSettingTile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0xFFECFDF5),
                  title: 'Language',
                  onTap: () => context.push(RoutePaths.language),
                ),
                _buildIOSSettingTile(
                  icon: Icons.notifications_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0xFFFEF3C7),
                  title: 'Notifications',
                  trailing: Switch.adaptive(
                    value: true,
                    activeThumbColor: AppColors.primaryColor,
                    onChanged: (val) {},
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildIOSSettingsGroup([
                _buildIOSSettingTile(
                  icon: Icons.fingerprint_rounded,
                  iconColor: const Color(0xFF22C55E),
                  iconBg: const Color(0xFFF0FDF4),
                  title: 'Biometric Login',
                  trailing: Switch.adaptive(
                    value: profileState.biometricEnabled,
                    activeThumbColor: AppColors.primaryColor,
                    onChanged: (val) =>
                        ref.read(profileProvider.notifier).toggleBiometric(val),
                  ),
                ),
                _buildIOSSettingTile(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  iconBg: const Color(0xFFEFF6FF),
                  title: 'Privacy & Security',
                ),
                _buildIOSSettingTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF5F3FF),
                  title: 'Help & Support',
                ),
                _buildIOSSettingTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF6B7280),
                  iconBg: const Color(0xFFF3F4F6),
                  title: 'About',
                  showDivider: false,
                ),
              ]),
            ],
          ),
        ),

        // Logout
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 16),
              onPressed: () {
                if (widget.onLogout != null) {
                  widget.onLogout!();
                } else {
                  ref.read(authProvider.notifier).logout();
                  context.go('/guest/home');
                }
              },
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIOSSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildIOSSettingTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFFC7C7CC),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 62, color: Color(0xFFE5E5EA)),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: AppColors.border);
  }

  Widget _buildQuickLinkCard(IconData icon, String label, Color color, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    bool showDivider = true,
    Color iconColor = AppColors.muted,
    Color iconBg = const Color(0xFFF3F4F6),
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 62, color: Color(0xFFE5E5EA)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 80),
              sliver: SliverList(
                delegate: SliverChildListDelegate([_buildProfileBodyContent()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
