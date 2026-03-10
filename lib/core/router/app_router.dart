import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/journey_overview/journey_overview_screen.dart';
import '../../features/trimester/trimester_screen.dart';
import '../../features/week_detail/week_detail_screen.dart';
import '../../features/daily_entry/daily_entry_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: JourneyOverviewScreen(),
      ),
    ),
    GoRoute(
      path: '/trimester/:n',
      pageBuilder: (context, state) {
        final n = int.parse(state.pathParameters['n']!);
        return CustomTransitionPage(
          child: TrimesterScreen(trimesterNumber: n),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/week/:weekNumber',
      pageBuilder: (context, state) {
        final weekNumber = int.parse(state.pathParameters['weekNumber']!);
        return CustomTransitionPage(
          child: WeekDetailScreen(weekNumber: weekNumber),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/week/:weekNumber/entry',
      pageBuilder: (context, state) {
        final weekNumber = int.parse(state.pathParameters['weekNumber']!);
        return CustomTransitionPage(
          child: DailyEntryScreen(weekNumber: weekNumber),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
