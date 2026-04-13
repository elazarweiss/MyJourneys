import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/app_shell.dart';
import '../../features/journey_overview/journey_overview_screen.dart';
import '../../features/calendar/calendar_mode_screen.dart';
import '../../features/day_view/day_mode_screen.dart';
import '../../features/weekly_reflection/weekly_reflection_screen.dart';
import '../../features/daily_check_in/daily_check_in_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/journey',
  routes: [
    // ── Shell (3 persistent branches) ─────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/journey',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: JourneyOverviewScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CalendarModeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/day',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DayModeScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // ── Modal routes (slide-up, outside shell) ─────────────────────────────────
    GoRoute(
      path: '/week/:weekNumber/entry',
      pageBuilder: (context, state) {
        final weekNumber = int.parse(state.pathParameters['weekNumber']!);
        return CustomTransitionPage(
          child: WeeklyReflectionScreen(weekNumber: weekNumber),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/week/:weekNumber/day/:dayIndex',
      pageBuilder: (context, state) {
        final weekNumber = int.parse(state.pathParameters['weekNumber']!);
        final dayIndex = int.parse(state.pathParameters['dayIndex']!);
        return CustomTransitionPage(
          child: DailyCheckInScreen(
            weekNumber: weekNumber,
            dayIndex: dayIndex,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        );
      },
    ),

    // ── Legacy redirects ───────────────────────────────────────────────────────
    GoRoute(
      path: '/week/:n',
      redirect: (context, state) => '/calendar',
    ),
    GoRoute(
      path: '/trimester/:n',
      redirect: (context, state) => '/journey',
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) => '/journey',
    ),
  ],
);
