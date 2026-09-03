import 'package:flutter/material.dart';

import '../../const.dart';
import '../models/agent.dart';
import '../models/announcement.dart';
import '../models/notification_item.dart';
import '../models/promo.dart';
import '../models/resource_node.dart';
import '../models/task_item.dart';
import 'mock_products.dart';

/// Mock data standing in for the Core system APIs described in BRD §9
/// (Rationalization/Data Reference). Swap each of these for a real
/// repository call once the Core/Agent Portal endpoints are available —
/// the provider layer already isolates screens from this detail.
class MockData {
  MockData._();

  static const agent = Agent(
    id: 'FA-10234',
    name: 'Myat Moe Pyae',
    role: AgentRole.fa,
    phone: '09-42xxxxxxx',
  );

  static const products = MockProducts.all;

  static final promos = <Promo>[
    Promo(
      id: 'incentive',
      badge: 'Incentive',
      title: 'Earn more with every milestone',
      description: 'Hit your monthly target and unlock bonus rewards.',
      gradient: [kAppColors.primaryColor, kAppColors.secondaryColor],
      icon: Icons.star_rounded,
      body: [
        'Every proposal you close counts toward your monthly milestone tiers.',
        'Bonus rewards scale up as you cross each target — from cash top-ups to recognition badges.',
        'Log in to see your live milestone progress and current tier.',
      ],
    ),
    Promo(
      id: 'campaign',
      badge: 'This month',
      title: 'Special incentives for top closers',
      description: 'Limited-time campaign for Personal Accident sales.',
      gradient: [kAppColors.baltic, kAppColors.deep],
      icon: Icons.shield_rounded,
      body: [
        'This month\'s campaign rewards agents who close the most Personal Accident policies.',
        'Top closers earn extra incentive payouts on top of standard commission.',
        'Log in to check your ranking and campaign eligibility.',
      ],
    ),
    Promo(
      id: 'training',
      badge: 'Training',
      title: 'New product training drop',
      description: 'Short modules + brochures in Resource Library.',
      gradient: [kAppColors.secondaryColor, kAppColors.deep],
      icon: Icons.menu_book_rounded,
      body: [
        'Fresh short-form training modules just landed for the newest product line.',
        'Includes downloadable brochures and talking points for client conversations.',
        'Log in to access the full Resource Library and start a module.',
      ],
    ),
  ];

  static List<TaskItem> tasks(DateTime now) => [
        TaskItem(
          id: 'T-1',
          title: 'Follow up premium due — U Aung Ko',
          dueAt: DateTime(now.year, now.month, now.day, 10, 30),
          status: TaskStatus.pending,
          highPriority: true,
          clientName: 'U Aung Ko',
        ),
        TaskItem(
          id: 'T-2',
          title: 'Renewal review call — Daw Hla Hla',
          dueAt: DateTime(now.year, now.month, now.day, 14),
          status: TaskStatus.inProgress,
          clientName: 'Daw Hla Hla',
        ),
        TaskItem(
          id: 'T-3',
          title: 'Submit e-Application — Ko Zin Min',
          dueAt: DateTime(now.year, now.month, now.day - 1, 17),
          status: TaskStatus.overdue,
          highPriority: true,
          clientName: 'Ko Zin Min',
        ),
        TaskItem(
          id: 'T-5',
          title: 'Client visit report — Daw Nilar',
          dueAt: DateTime(now.year, now.month, now.day - 2, 16),
          status: TaskStatus.completed,
          clientName: 'Daw Nilar',
        ),
        TaskItem(
          id: 'T-4',
          title: 'New agent onboarding check-in',
          dueAt: DateTime(now.year, now.month, now.day + 1, 9),
          status: TaskStatus.pending,
        ),
      ];

  static List<NotificationItem> notifications(DateTime now) => [
        NotificationItem(
          id: 'N-1',
          title: 'Premium due in 7 days',
          body: 'U Aung Ko — Personal Accident policy PA-88213',
          kind: NotificationKind.premiumDue,
          receivedAt: now.subtract(const Duration(hours: 2)),
        ),
        NotificationItem(
          id: 'N-2',
          title: 'Policy renewal window opens',
          body: 'Daw Hla Hla — 60 days before renewal',
          kind: NotificationKind.renewal,
          receivedAt: now.subtract(const Duration(hours: 6)),
        ),
        NotificationItem(
          id: 'N-3',
          title: 'Company announcement',
          body: 'Q3 MDRT incentive campaign now live',
          kind: NotificationKind.announcement,
          receivedAt: now.subtract(const Duration(days: 1)),
          unread: false,
        ),
      ];

  static List<Announcement> announcements(DateTime now) => [
        Announcement(
          id: 'A-1',
          title: 'Q3 MDRT incentive campaign now live',
          body: 'Extra weighted FYP bonus for all agents reaching 65% of MDRT threshold by end of quarter. Full terms in the Resource Center.',
          postedAt: now.subtract(const Duration(hours: 20)),
          linkLabel: 'View campaign terms',
          linkUrl: 'https://kbzlife.com',
          type: AnnouncementType.important,
          category: 'Incentive',
          status: AnnouncementStatus.published,
          publishDate: now.subtract(const Duration(hours: 20)),
          expiryDate: now.add(const Duration(days: 30)),
          targetAudience: 'All agents',
          priority: AnnouncementPriority.high,
        ),
        Announcement(
          id: 'A-2',
          title: 'System maintenance — 02:00–04:00, 28-Aug-2026',
          body: 'Core system will be briefly unavailable for scheduled maintenance. e-Application submissions will queue and sync afterward.',
          postedAt: now.subtract(const Duration(days: 2)),
          type: AnnouncementType.alert,
          category: 'System',
          status: AnnouncementStatus.published,
          publishDate: now.subtract(const Duration(days: 2)),
          expiryDate: now.add(const Duration(days: 1)),
          targetAudience: 'All agents',
          priority: AnnouncementPriority.urgent,
          attachment: 'maintenance-notice.pdf',
        ),
      ];

  static List<ResourceNode> resourceLibrary() => const [
        ResourceNode(
          id: 'R-1',
          name: 'Product Brochures',
          type: ResourceNodeType.mainFolder,
          children: [
            ResourceNode(
              id: 'R-1-1',
              name: 'Life Insurance Plans',
              type: ResourceNodeType.subFolder,
              children: [
                ResourceNode(id: 'R-1-1-1', name: 'Endowment_Plan_2026.pdf', type: ResourceNodeType.file, fileKind: ResourceFileKind.pdf, sizeLabel: '2.4 MB'),
                ResourceNode(id: 'R-1-1-2', name: 'Universal_Life_Brochure.pdf', type: ResourceNodeType.file, fileKind: ResourceFileKind.pdf, sizeLabel: '3.1 MB'),
              ],
            ),
            ResourceNode(
              id: 'R-1-2',
              name: 'Health Insurance Plans',
              type: ResourceNodeType.subFolder,
              children: [
                ResourceNode(id: 'R-1-2-1', name: 'Family_Health_Rates.xlsx', type: ResourceNodeType.file, fileKind: ResourceFileKind.xls, sizeLabel: '640 KB'),
              ],
            ),
          ],
        ),
        ResourceNode(
          id: 'R-2',
          name: 'Training Guides',
          type: ResourceNodeType.mainFolder,
          children: [
            ResourceNode(
              id: 'R-2-1',
              name: 'Onboarding',
              type: ResourceNodeType.subFolder,
              children: [
                ResourceNode(id: 'R-2-1-1', name: 'New_Agent_Induction.mp4', type: ResourceNodeType.file, fileKind: ResourceFileKind.video, sizeLabel: '48 MB'),
              ],
            ),
          ],
        ),
        ResourceNode(
          id: 'R-3',
          name: 'Company Forms',
          type: ResourceNodeType.mainFolder,
          children: [
            ResourceNode(id: 'R-3-1', name: 'Claims', type: ResourceNodeType.subFolder, children: [
              ResourceNode(id: 'R-3-1-1', name: 'Claim_Intimation_Form.docx', type: ResourceNodeType.file, fileKind: ResourceFileKind.doc, sizeLabel: '210 KB'),
            ]),
          ],
        ),
      ];
}
