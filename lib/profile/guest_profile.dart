import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/router_provider.dart';

class GuestProfileScreen extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  const GuestProfileScreen({super.key, this.onLogin, this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceBg,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.border,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: context.colors.primaryColor
                                .withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 45,
                              color: context.colors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Guest Agent',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore our products and services',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primaryColor.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.orange.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Guest Mode',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Links
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Links',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickLinkCard(
                            context,
                            Icons.shopping_bag_outlined,
                            'Products',
                            context.colors.indigoAccent,
                            () => context.go('/guest/products'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickLinkCard(
                            context,
                            Icons.calculate_outlined,
                            'Calculator',
                            context.colors.emeraldAccent,
                            () => context.push(RoutePaths.calculator),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickLinkCard(
                            context,
                            Icons.language_outlined,
                            'Online',
                            context.colors.infoText,
                            () => context.push(
                              '${RoutePaths.webview}?url=${Uri.encodeComponent("https://selfservice.kbzlife.com/")}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Settings
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildIOSSettingsGroup([
                      _buildIOSSettingTile(
                        icon: Icons.language_rounded,
                        iconColor: context.colors.emeraldAccent,
                        iconBg: context.colors.emeraldLight,
                        title: 'Language',
                        context: context,
                      ),
                      _buildIOSSettingTile(
                        icon: Icons.help_outline_rounded,
                        iconColor: context.colors.purpleAccent,
                        iconBg: context.colors.purpleLight,
                        title: 'Help & Support',
                        context: context,
                      ),
                      _buildIOSSettingTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: context.colors.muted,
                        iconBg: context.colors.chipBg,
                        title: 'About',
                        showDivider: false,
                        context: context,
                      ),
                    ]),
                  ],
                ),
              ),

              // Login/Register Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.login_rounded, size: context.iconLg),
                        label: const Text('Sign In'),
                        onPressed:
                            onLogin ?? () => context.push(RoutePaths.login),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          Icons.person_add_outlined,
                          size: context.iconLg,
                        ),
                        label: const Text('Create Account'),
                        onPressed:
                            onRegister ??
                            () => context.push(RoutePaths.register),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.primaryColor,
                          side: BorderSide(color: context.colors.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
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
            Icon(icon, size: context.iconXxxl, color: color),
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
    required BuildContext context,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: context.colors.divider,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 62, color: context.colors.divider),
      ],
    );
  }
}
