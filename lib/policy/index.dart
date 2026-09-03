import 'package:demo_ui/widgets/tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import 'data.dart';
import 'overview.dart';
import 'team_structure.dart';

class PolicyListScreen extends ConsumerStatefulWidget {
  const PolicyListScreen({super.key});

  @override
  ConsumerState<PolicyListScreen> createState() => _PolicyListScreenState();
}

class _PolicyListScreenState extends ConsumerState<PolicyListScreen>
    with TickerProviderStateMixin {
  final PolicyRepository _repository = PolicyRepository();
  final List<CRMUser> _navigationStack = [];
  TabController? _tabController;

  bool _isLoading = true;
  List<PolicyModel> _allPolicies = [];

  CRMUser get _currentUser => _navigationStack.last;

  bool get _hasTeamMembers {
    if (_currentUser.role == UserRole.fa) return false;
    return _repository.users.any((u) => u.managerId == _currentUser.id);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final rootUser = _repository.users.firstWhere((u) => u.id == 'usr_md');
    final policies = _repository.fetchPolicies;

    if (mounted) {
      _navigationStack.add(rootUser);
      _allPolicies = policies;
      _isLoading = false;
      _updateTabController();
    }
  }

  void _updateTabController() {
    _tabController?.dispose();
    final tabCount = _hasTeamMembers ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  void _pushUser(CRMUser user) {
    setState(() {
      _navigationStack.add(user);
      _updateTabController();
    });
  }

  void _popUser() {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        _updateTabController();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primaryColor),
        ),
      );
    }

    final isRootLevel = _navigationStack.length == 1;
    final showTeamTab = _hasTeamMembers;

    return PopScope(
      canPop: isRootLevel,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _popUser();
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.cream,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: !isRootLevel
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: _popUser,
                )
              : null,
          title: Text(
            'Policy & Serving',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            _buildBreadcrumbs(),
            Expanded(
              child: showTeamTab == false
                  ? OverviewPage(
                      currentUser: _currentUser,
                      data: _allPolicies,
                      repository: _repository,
                    )
                  : CustomTabView(
                      controller: _tabController,
                      tabs: [
                        const TabItemData(label: 'Overview'),
                        const TabItemData(label: 'Team Hierarchy'),
                      ],
                      tabViews: [
                        OverviewPage(
                          currentUser: _currentUser,
                          data: _allPolicies,
                          repository: _repository,
                        ),
                        TeamStructurePage(
                          currentUser: _currentUser,
                          allPolicies: _allPolicies,
                          repository: _repository,
                          onPushUser: _pushUser,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _navigationStack.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final isLast = index == _navigationStack.length - 1;

            return Row(
              children: [
                InkWell(
                  onTap: isLast
                      ? null
                      : () {
                          setState(() {
                            _navigationStack.removeRange(
                              index + 1,
                              _navigationStack.length,
                            );
                            _updateTabController();
                          });
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    child: Text(
                      user.name,
                      style: TextStyle(
                        color: isLast ? context.colors.primaryColor : Colors.grey,
                        fontSize: 11,
                        fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: context.iconBase,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
