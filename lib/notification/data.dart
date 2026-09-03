import 'model.dart';

class MockAnnouncementRepository {
  static List<AnnouncementModel> getMockAnnouncements() {
    return [
      AnnouncementModel(
        id: 'mock_1',
        title: 'Personalized Sales Commission Performance Dashboard',
        bodyContent:
            'Your monthly commission targets and individual downline earnings breakdown have been updated. Access your personalized agent workspace below.',
        imageUrl: 'https://picsum.photos/id/10/600/300',
        embeddedLink: 'https://kbzlife.com/',
        type: 'Important',
        category: 'Personal Earnings',
        priority: AnnouncementPriority.urgent,
        publishDate: 'Aug 28, 2026',
        isPrivate: true,
        targetRoles: ['Financial Advisor', 'Team Leader'],
        isRead: false,
      ),
      AnnouncementModel(
        id: 'mock_2',
        title: 'Team Leader Approval Portal & Agent Onboarding',
        bodyContent:
            'New agent applications awaiting structural approval from regional managers are ready for review.',
        imageUrl: 'https://picsum.photos/id/20/600/300',
        embeddedLink: 'https://kbzlife.com/',
        type: 'Alert',
        category: 'Management',
        priority: AnnouncementPriority.high,
        publishDate: 'Aug 27, 2026',
        isPrivate: true,
        isRead: false,
        targetRoles: ['Team Leader', 'Branch Manager'],
      ),
      AnnouncementModel(
        id: 'mock_3',
        title: 'Public Nationwide Product Catalogue Released',
        bodyContent:
            'Our updated public product brochures and policy guides are now accessible to all users and unregistered guests.',
        imageUrl: 'https://picsum.photos/id/30/600/300',
        embeddedLink: 'https://kbzlife.com/',
        type: 'General',
        category: 'Public News',
        priority: AnnouncementPriority.medium,
        publishDate: 'Aug 26, 2026',
        isPrivate: false,
        isRead: true,
        targetRoles: [],
      ),
    ];
  }
}
