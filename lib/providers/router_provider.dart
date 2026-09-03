import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../authorize_user.dart';
import '../comparison.dart';
import '../commission.dart';
import '../crm/create_lead.dart';
import '../crm/crm.dart';
import '../crm/crm_detail.dart';
import '../crm/model.dart';
import '../eapp/eapp_screen.dart';
import '../eapp/eapp_tracker_screen.dart';
import '../eapp/eapp_status_detail_screen.dart';
import '../guest.dart';
import '../login/forgot.dart';
import '../login/index.dart';
import '../login/register.dart';
import '../nav.dart';
import '../notification/detail.dart';
import '../notification/index.dart';
import '../notification/inapp_webview.dart';
import '../policy/detail.dart';
import '../policy/index.dart';
import '../products/product_detail_screen.dart';
import '../products/product_library_screen.dart';
import '../products/compare_screen.dart';
import '../profile/change_password.dart';
import '../profile/guest_profile.dart';
import '../profile/index.dart';
import '../profile/language.dart';
import '../profile/account_detail_screen.dart';
import '../quote/quote_screen.dart';
import '../quote/saved_quotes_screen.dart';
import '../rolebase_dashboard/index.dart';
import '../splash.dart';
import '../task/create_task.dart';
import '../task/detail.dart';
import '../task/index.dart';
import '../tracker/detail.dart';
import '../tracker/index.dart';
import 'auth_provider.dart';

// --- Navigator Keys ---
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Auth shell keys
final _authHomeKey = GlobalKey<NavigatorState>(debugLabel: 'auth-home');
final _authCrmKey = GlobalKey<NavigatorState>(debugLabel: 'auth-crm');
final _authProductsKey = GlobalKey<NavigatorState>(debugLabel: 'auth-products');
final _authProfileKey = GlobalKey<NavigatorState>(debugLabel: 'auth-profile');

// Guest shell keys
final _guestHomeKey = GlobalKey<NavigatorState>(debugLabel: 'guest-home');
final _guestProductsKey = GlobalKey<NavigatorState>(
  debugLabel: 'guest-products',
);
final _guestProfileKey = GlobalKey<NavigatorState>(debugLabel: 'guest-profile');

// --- Route Paths ---
class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const crm = '/crm';
  static const products = '/products';
  static const profile = '/profile';
  static const productDetail = '/products/:code';
  static const quote = '/quote';
  static const quoteDrafts = '/quote/drafts';
  static const eapp = '/e-app';
  static const eappTracker = '/e-app/tracker';
  static const eappTrackerDetail = '/e-app/tracker/:id';
  static const policyList = '/policies';
  static const policyDetail = '/policies/:policyNo';
  static const policyTimeline = '/policies/timeline';
  static const taskList = '/tasks';
  static const taskCreate = '/tasks/create';
  static const taskDetail = '/tasks/:id';
  static const trackerList = '/tracker';
  static const trackerDetail = '/tracker/:status';
  static const crmDetail = '/crm/detail';
  static const crmCreateLead = '/crm/create-lead';
  static const notificationInbox = '/notifications';
  static const announcementDetail = '/notifications/:id';
  static const webview = '/webview';
  static const performance = '/performance';
  static const changePassword = '/change-password';
  static const language = '/language';
  static const comparison = '/comparison';
  static const calculator = '/calculator';
  static const commission = '/commission';
  static const productsCompare = '/products/compare';
}

// --- Navigation State ---
class NavigationState {
  final int currentTab;
  const NavigationState({this.currentTab = 0});

  NavigationState copyWith({int? currentTab}) {
    return NavigationState(currentTab: currentTab ?? this.currentTab);
  }
}

class NavigationController extends StateNotifier<NavigationState> {
  NavigationController() : super(const NavigationState());

  void setTab(int index) {
    state = state.copyWith(currentTab: index);
  }

  void navigateByLocation(String location) {
    const tabMap = {'/home': 0, '/crm': 1, '/products': 2, '/profile': 3};
    final index = tabMap[location];
    if (index != null) {
      state = state.copyWith(currentTab: index);
    }
  }

  void navigateBackToRoot() {
    state = state.copyWith(currentTab: 0);
  }
}

final navigationControllerProvider =
    StateNotifierProvider<NavigationController, NavigationState>(
      (ref) => NavigationController(),
    );

// --- GoRouter Refresh Stream ---
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// --- Router Provider ---
final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final location = state.uri.path;

      if (location == RoutePaths.splash) {
        return null;
      }

      final isGuestRoute = location.startsWith('/guest');
      final isAuthOnlyRoute =
          !isGuestRoute &&
          location != RoutePaths.login &&
          location != RoutePaths.register &&
          location != RoutePaths.forgotPassword &&
          !location.startsWith('/products') &&
          location != RoutePaths.calculator &&
          location != RoutePaths.quote &&
          !location.startsWith('/webview');

      // Guest: redirect restricted pages to login
      if (!isLoggedIn && isAuthOnlyRoute) {
        return RoutePaths.login;
      }

      // Logged in: redirect away from guest shell and auth forms
      if (isLoggedIn &&
          (isGuestRoute ||
              location == RoutePaths.login ||
              location == RoutePaths.register ||
              location == RoutePaths.forgotPassword)) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      // --- Splash ---
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, _) => const AnimatedSplashScreen(),
      ),

      // --- Auth Routes ---
      GoRoute(
        path: RoutePaths.login,
        builder: (_, _) => const MobileLoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),

      // --- Main Shell (Bottom Nav) ---
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            NavShell(isGuest: false, navigationShell: navigationShell),
        branches: [
          // Home Tab
          StatefulShellBranch(
            navigatorKey: _authHomeKey,
            routes: [
              GoRoute(
                path: RoutePaths.home,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: AuthorizedAgentScreen()),
              ),
            ],
          ),

          // CRM Tab
          StatefulShellBranch(
            navigatorKey: _authCrmKey,
            routes: [
              GoRoute(
                path: RoutePaths.crm,
                pageBuilder: (_, _) => NoTransitionPage(
                  child: UserDashboardScreen(repository: CRMRepository()),
                ),
              ),
            ],
          ),

          // Products Tab
          StatefulShellBranch(
            navigatorKey: _authProductsKey,
            routes: [
              GoRoute(
                path: RoutePaths.products,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: ProductsLibraryScreen()),
              ),
            ],
          ),

          // Profile Tab
          StatefulShellBranch(
            navigatorKey: _authProfileKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),

      // --- Guest Shell (Bottom Nav) ---
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            NavShell(isGuest: true, navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _guestHomeKey,
            routes: [
              GoRoute(
                path: '/guest/home',
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: _GuestHomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _guestProductsKey,
            routes: [
              GoRoute(
                path: '/guest/products',
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: ProductsLibraryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _guestProfileKey,
            routes: [
              GoRoute(
                path: '/guest/profile',
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: _GuestProfileWrapper()),
              ),
            ],
          ),
        ],
      ),

      // --- Top-Level Detail Routes ---
      GoRoute(
        path: RoutePaths.productsCompare,
        name: RoutePaths.productsCompare,
        builder: (_, state) {
          final left = state.uri.queryParameters['left'] ?? '';
          final right = state.uri.queryParameters['right'] ?? '';
          return CompareScreen(leftCode: left, rightCode: right);
        },
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        builder: (_, state) =>
            ProductDetailScreen(productCode: state.pathParameters['code']!),
      ),
      GoRoute(
        path: RoutePaths.quote,
        builder: (_, state) =>
            QuoteScreen(productCode: state.uri.queryParameters['product']),
      ),
      GoRoute(
        path: RoutePaths.quoteDrafts,
        builder: (_, _) => const SavedQuotesScreen(),
      ),
      GoRoute(
        path: RoutePaths.eapp,
        builder: (_, state) => EAppScreen(
          productCode: state.uri.queryParameters['product'],
          customerId: state.uri.queryParameters['customerId'],
          renewalPolicyNo: state.uri.queryParameters['renewalPolicyNo'],
          initialStep: state.uri.queryParameters['step'] != null
              ? int.tryParse(state.uri.queryParameters['step']!)
              : null,
          correctionNote: state.uri.queryParameters['note'],
          crmName: state.uri.queryParameters['crmName'],
          crmPhone: state.uri.queryParameters['crmPhone'],
          crmEmail: state.uri.queryParameters['crmEmail'],
        ),
      ),
      GoRoute(
        path: RoutePaths.eappTracker,
        builder: (_, _) => const EappTrackerScreen(),
      ),
      GoRoute(
        path: RoutePaths.eappTrackerDetail,
        builder: (_, state) =>
            EappStatusDetailScreen(appId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.policyList,
        builder: (_, _) => const PolicyListScreen(),
      ),
      GoRoute(
        path: RoutePaths.policyDetail,
        builder: (_, state) =>
            PolicyDetailScreen(policyNo: state.pathParameters['policyNo']!),
      ),
      GoRoute(
        path: RoutePaths.policyTimeline,
        builder: (_, _) => const PolicyTimelineScreen(),
      ),
      GoRoute(
        path: RoutePaths.taskList,
        builder: (_, _) => const ModernTaskCalendarScreen(),
      ),
      GoRoute(
        path: RoutePaths.taskCreate,
        builder: (_, _) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: RoutePaths.taskDetail,
        builder: (_, state) =>
            TaskDetailScreen(taskData: {'id': state.pathParameters['id']}),
      ),
      GoRoute(
        path: RoutePaths.trackerList,
        builder: (_, _) => const ApplicationTrackerListScreen(),
      ),
      GoRoute(
        path: RoutePaths.trackerDetail,
        builder: (_, state) => ApplicationTrackerDetailScreen(
          status: ApplicationStatus.values.firstWhere(
            (s) => s.name == state.pathParameters['status'],
            orElse: () => ApplicationStatus.markForCorrection,
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.crmDetail,
        builder: (_, state) =>
            CRMDetailViewScreen(contact: state.extra as CRMContactModel),
      ),
      GoRoute(
        path: RoutePaths.crmCreateLead,
        builder: (_, _) => const CreateLeadScreen(),
      ),
      GoRoute(
        path: RoutePaths.notificationInbox,
        builder: (_, _) => const NotificationInboxScreen(),
      ),
      GoRoute(
        path: RoutePaths.announcementDetail,
        builder: (_, state) =>
            AnnouncementDetailH5Screen(announcement: state.extra as dynamic),
      ),
      GoRoute(
        path: RoutePaths.webview,
        builder: (_, state) =>
            AppWebViewScreen(url: state.uri.queryParameters['url']!),
      ),
      GoRoute(
        path: RoutePaths.performance,
        builder: (_, _) => const PerformanceDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.language,
        builder: (_, _) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (_, _) => const AccountDetailScreen(),
      ),

      GoRoute(
        path: RoutePaths.calculator,
        builder: (_, state) =>
            QuoteScreen(productCode: state.uri.queryParameters['product']),
      ),

      GoRoute(
        path: RoutePaths.comparison,
        builder: (_, state) {
          final params = state.uri.queryParameters;
          return ComparisonScreen(
            age: int.parse(params['age'] ?? '30'),
            monthlyPremium: double.parse(params['monthlyPremium'] ?? '0'),
            policyTermYears: int.parse(params['policyTermYears'] ?? '10'),
            calculatedSumInsured: double.parse(
              params['calculatedSumInsured'] ?? '0',
            ),
            ageMultiplier: int.parse(params['ageMultiplier'] ?? '1'),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.commission,
        builder: (_, _) => CommissionReportScreen(),
      ),
    ],
  );

  return router;
});

// --- Guest Wrappers (for shell route pages) ---
class _GuestHomeScreen extends StatelessWidget {
  const _GuestHomeScreen();

  @override
  Widget build(BuildContext context) {
    return BeforeLoginDashboardScreen(
      onLogin: () => context.push(RoutePaths.login),
      onRegister: () => context.push(RoutePaths.register),
    );
  }
}

class _GuestProfileWrapper extends StatelessWidget {
  const _GuestProfileWrapper();

  @override
  Widget build(BuildContext context) {
    return GuestProfileScreen(
      onLogin: () => context.push(RoutePaths.login),
      onRegister: () => context.push(RoutePaths.register),
    );
  }
}
