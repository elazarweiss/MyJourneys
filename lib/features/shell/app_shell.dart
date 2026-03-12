import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shell_navigation_state.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  /// Access the shell navigation state from any descendant widget.
  static ShellNavigationState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ShellScope>()!
        .notifier!;
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final ShellNavigationState _navState = ShellNavigationState();

  @override
  void initState() {
    super.initState();
    _navState.addListener(_syncBranch);
  }

  @override
  void dispose() {
    _navState.removeListener(_syncBranch);
    _navState.dispose();
    super.dispose();
  }

  /// Synchronise GoRouter's branch index with our state when switchMode() is
  /// called from non-ModeSwitcher code (e.g. clothesline tap).
  void _syncBranch() {
    final target = _navState.currentMode;
    if (widget.navigationShell.currentIndex != target) {
      widget.navigationShell.goBranch(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ShellScope(
      notifier: _navState,
      child: widget.navigationShell,
    );
  }
}

class _ShellScope extends InheritedNotifier<ShellNavigationState> {
  const _ShellScope({required super.notifier, required super.child});
}
