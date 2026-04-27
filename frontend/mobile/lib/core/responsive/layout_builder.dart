import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/shared/widgets/web/side_nav_item.dart';

const kMobileBreakpoint = 600.0;
const kTabletBreakpoint = 900.0;
const kDesktopBreakpoint = 1280.0;

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.child,
    required this.currentLocation,
    required this.roleScope,
  });

  final Widget child;
  final String currentLocation;
  final String roleScope;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isVolunteer = roleScope == 'volunteer';
        final isAdminPortal = roleScope == 'ngo' || roleScope == 'sponsor';

        if (isVolunteer) {
          return _MobileScaffold(currentLocation: currentLocation, child: child);
        }
        if (isAdminPortal && maxWidth < kDesktopBreakpoint) {
          return _CompactPortalScaffold(currentLocation: currentLocation, child: child);
        }
        if (isAdminPortal) {
          return _DesktopScaffold(currentLocation: currentLocation, child: child);
        }

        if (maxWidth < kMobileBreakpoint) {
          return _MobileScaffold(currentLocation: currentLocation, child: child);
        }

        if (maxWidth < kDesktopBreakpoint) {
          return _TabletScaffold(currentLocation: currentLocation, child: child);
        }

        return _DesktopScaffold(currentLocation: currentLocation, child: child);
      },
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold({required this.currentLocation, required this.child});

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _mobileIndex(currentLocation),
        onDestinationSelected: (index) => _onVolunteerTabTap(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _mobileIndex(String location) {
    if (location.startsWith(AppRoutes.volunteerTasks)) return 1;
    if (location.startsWith(AppRoutes.volunteerWallet)) return 2;
    if (location.startsWith(AppRoutes.volunteerProfile)) return 3;
    return 0;
  }

  void _onVolunteerTabTap(BuildContext context, int index) {
    const routes = [
      AppRoutes.volunteerMap,
      AppRoutes.volunteerTasks,
      AppRoutes.volunteerWallet,
      AppRoutes.volunteerProfile,
    ];
    context.go(routes[index]);
  }
}

class _TabletScaffold extends StatelessWidget {
  const _TabletScaffold({required this.currentLocation, required this.child});

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _mobileIndex(currentLocation),
            onDestinationSelected: (index) => _onVolunteerTabTap(context, index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: Text('Map')),
              NavigationRailDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: Text('Tasks')),
              NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('Wallet')),
              NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _mobileIndex(String location) {
    if (location.startsWith(AppRoutes.volunteerTasks)) return 1;
    if (location.startsWith(AppRoutes.volunteerWallet)) return 2;
    if (location.startsWith(AppRoutes.volunteerProfile)) return 3;
    return 0;
  }

  void _onVolunteerTabTap(BuildContext context, int index) {
    const routes = [
      AppRoutes.volunteerMap,
      AppRoutes.volunteerTasks,
      AppRoutes.volunteerWallet,
      AppRoutes.volunteerProfile,
    ];
    context.go(routes[index]);
  }
}

class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({required this.currentLocation, required this.child});

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.space_dashboard_rounded, 'Dashboard', AppRoutes.ngoDashboard),
      (Icons.assignment_turned_in_outlined, 'Tasks', AppRoutes.ngoTasks),
      (Icons.groups_2_outlined, 'Volunteers', AppRoutes.ngoVolunteers),
      (Icons.summarize_outlined, 'Reports', AppRoutes.ngoReports),
    ];

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 240,
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('UnityHub NGO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SideNavItem(
                      icon: item.$1,
                      label: item.$2,
                      route: item.$3,
                      isActive: currentLocation.startsWith(item.$3),
                      onTap: () => context.go(item.$3),
                    ),
                  ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.authNgo),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: const [
                      Icon(Icons.hub_rounded, size: 20, color: AppColors.primary500),
                      SizedBox(width: 8),
                      Text('NGO Portal'),
                    ],
                  ),
                  actions: const [
                    Icon(Icons.notifications_none),
                    SizedBox(width: 16),
                    CircleAvatar(child: Icon(Icons.person)),
                    SizedBox(width: 16),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPortalScaffold extends StatelessWidget {
  const _CompactPortalScaffold({required this.currentLocation, required this.child});

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.space_dashboard_rounded, 'Dashboard', AppRoutes.ngoDashboard),
      (Icons.assignment_turned_in_outlined, 'Tasks', AppRoutes.ngoTasks),
      (Icons.groups_2_outlined, 'Volunteers', AppRoutes.ngoVolunteers),
      (Icons.summarize_outlined, 'Reports', AppRoutes.ngoReports),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Portal'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.hub_rounded, color: AppColors.primary500),
                title: Text('UnityHub NGO'),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in items)
                      ListTile(
                        leading: Icon(item.$1),
                        title: Text(item.$2),
                        selected: currentLocation.startsWith(item.$3),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(item.$3);
                        },
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.authNgo);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}
