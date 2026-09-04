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
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      await ref.read(profileProvider.notifier).pickAndUploadImage(source);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Update Photo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.colors.accentNavy,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildImageOption(
                      icon: FontAwesomeIcons.images,
                      label: 'Gallery',
                      onTap: () {
                        context.pop();
                        _pickAndUploadImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageOption(
                      icon: FontAwesomeIcons.camera,
                      label: 'Camera',
                      onTap: () {
                        context.pop();
                        _pickAndUploadImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required FaIconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.cream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              size: context.iconXxl,
              color: context.colors.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.accentNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final agentData = profileState.agentData;

    return Material(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Avatar Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    context.colors.primaryColor,
                                    context.colors.primaryColor.withValues(
                                      alpha: 0.6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 43,
                                backgroundColor: context.colors.primaryColor
                                    .withValues(alpha: 0.1),
                                backgroundImage:
                                    profileState.selectedImage != null
                                    ? FileImage(profileState.selectedImage!)
                                          as ImageProvider
                                    : null,
                                child: profileState.selectedImage == null
                                    ? FaIcon(
                                        FontAwesomeIcons.solidUser,
                                        size: 30,
                                        color: context.colors.primaryColor,
                                      )
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: profileState.isUploading
                                    ? null
                                    : _showImagePickerBottomSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.camera,
                                    size: context.iconXs,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          agentData.fullName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.colors.accentNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agentData.designation,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Links Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Links',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.colors.accentNavy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                icon: FontAwesomeIcons.fileSignature,
                                label: 'e-App',
                                color: context.colors.primaryColor,
                                onTap: () => context.push(RoutePaths.eapp),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildActionCard(
                                icon: FontAwesomeIcons.listCheck,
                                label: 'Tasks',
                                color: context.colors.mint,
                                onTap: () => context.push(RoutePaths.taskList),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildActionCard(
                                icon: FontAwesomeIcons.fileContract,
                                label: 'Policy',
                                color: context.colors.warn,
                                onTap: () =>
                                    context.push(RoutePaths.policyList),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.colors.accentNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMenuTile(
                          FontAwesomeIcons.idBadge,
                          'License No.',
                          agentData.agentCode,
                          context.colors.primaryColor,
                          showDivider: false,
                          onTap: () => context.push('/account'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Settings Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.colors.accentNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMenuTile(
                          FontAwesomeIcons.lock,
                          'Change Password',
                          null,
                          context.colors.primaryColor,
                          onTap: () => context.push(RoutePaths.changePassword),
                        ),
                        _buildMenuTile(
                          FontAwesomeIcons.globe,
                          'Language',
                          null,
                          context.colors.mint,
                          onTap: () => context.push(RoutePaths.language),
                        ),
                        _buildMenuTile(
                          FontAwesomeIcons.bell,
                          'Notifications',
                          null,
                          context.colors.warn,
                          trailing: Switch.adaptive(
                            value: true,
                            activeThumbColor: context.colors.primaryColor,
                            onChanged: (v) {},
                          ),
                        ),
                        _buildMenuTile(
                          FontAwesomeIcons.fingerprint,
                          'Biometric',
                          null,
                          context.colors.mint,
                          trailing: Switch.adaptive(
                            value: profileState.biometricEnabled,
                            activeThumbColor: context.colors.primaryColor,
                            onChanged: (v) => ref
                                .read(profileProvider.notifier)
                                .toggleBiometric(v),
                          ),
                        ),
                        _buildMenuTile(
                          FontAwesomeIcons.shieldHalved,
                          'Privacy',
                          null,
                          context.colors.primaryColor,
                          onTap: () {},
                        ),
                        _buildMenuTile(
                          FontAwesomeIcons.circleQuestion,
                          'Help & Support',
                          null,
                          context.colors.deep,
                          onTap: () {},
                        ),
                        _buildMenuTile(
                          FontAwesomeIcons.circleInfo,
                          'About',
                          null,
                          context.colors.muted,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout
                  GestureDetector(
                    onTap: () {
                      if (widget.onLogout != null) {
                        widget.onLogout!();
                      } else {
                        ref.read(authProvider.notifier).logout();
                        context.go('/guest/home');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: context.colors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.rightFromBracket,
                            size: 15,
                            color: context.colors.danger,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.colors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  );

  Widget _buildActionCard({
    required FaIconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(icon, size: context.iconXxxl, color: color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colors.accentNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    FaIconData icon,
    String title,
    String? value,
    Color color, {
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(icon, size: context.iconBase, color: color),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.colors.accentNavy,
                      ),
                    ),
                  ),
                  if (value != null)
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.muted,
                      ),
                    ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing,
                  ] else if (onTap != null) ...[
                    const SizedBox(width: 8),
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: context.iconXs,
                      color: context.colors.border,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: context.colors.border.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
