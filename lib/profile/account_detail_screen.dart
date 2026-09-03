import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const.dart';
import '../providers/profile_provider.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final agentData = profileState.agentData;

    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: context.colors.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    backgroundImage: profileState.selectedImage != null
                        ? FileImage(profileState.selectedImage!)
                              as ImageProvider
                        : null,
                    child: profileState.selectedImage == null
                        ? FaIcon(
                            FontAwesomeIcons.solidUser,
                            size: context.icon4xl,
                            color: context.colors.primaryColor,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  agentData.fullName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.colors.accentNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agentData.designation,
                  style: TextStyle(fontSize: 14, color: context.colors.muted),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.colors.accentNavy,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoTile(
                  FontAwesomeIcons.idBadge,
                  'License No.',
                  agentData.agentCode,
                  context.colors.primaryColor,
                ),
                _buildInfoTile(
                  FontAwesomeIcons.mobileScreen,
                  'Phone',
                  agentData.phone,
                  context.colors.mint,
                  onTap: () => launchUrl(Uri.parse('tel:${agentData.phone}')),
                ),
                _buildInfoTile(
                  FontAwesomeIcons.envelope,
                  'Email',
                  agentData.email,
                  context.colors.deep,
                  onTap: () =>
                      launchUrl(Uri.parse('mailto:${agentData.email}')),
                ),
                _buildInfoTile(
                  FontAwesomeIcons.buildingColumns,
                  'Branch',
                  agentData.branchName,
                  context.colors.warn,
                  showDivider: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Organization Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.colors.accentNavy,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoTile(
                  FontAwesomeIcons.userTie,
                  'Supervisor',
                  agentData.supervisorName,
                  context.colors.danger,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  );

  Widget _buildInfoTile(
    FaIconData icon,
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: FaIcon(icon, size: 16, color: color)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: kAppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kAppColors.accentNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 10,
                      color: kAppColors.border,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: kAppColors.border.withValues(alpha: 0.5)),
      ],
    );
  }
}
