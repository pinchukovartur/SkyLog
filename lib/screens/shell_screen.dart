import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';
import 'home_screen.dart';
import 'tabs.dart';

/// Порядок вкладок на панели; «Главная» — посередине.
enum AppTab { quests, skills, home, enchanting, followers }

extension on AppTab {
  IconData get icon => switch (this) {
    AppTab.home => Icons.home_rounded,
    AppTab.quests => sectionIcon(Section.quests),
    AppTab.skills => sectionIcon(Section.skills),
    AppTab.enchanting => sectionIcon(Section.enchanting),
    AppTab.followers => sectionIcon(Section.followers),
  };

  String title(S s) => switch (this) {
    AppTab.home => s.tabHome,
    AppTab.quests => s.tabQuests,
    AppTab.skills => s.tabSkills,
    AppTab.enchanting => s.tabEnchanting,
    AppTab.followers => s.tabFollowers,
  };
}

/// Главный экран: вкладки листаются свайпом, снизу — панель вкладок.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  // Приложение всегда открывается на «Главной».
  final _controller = PageController(initialPage: AppTab.home.index);
  AppTab _current = AppTab.home;

  /// Идёт прокрутка по нажатию или жестом по панели: промежуточные
  /// страницы при этом не считаются открытыми.
  bool _jumping = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open(AppTab tab) async {
    if (!_controller.hasClients) return;
    setState(() => _current = tab);
    _jumping = true;
    await _controller.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    _jumping = false;
  }

  void _onPageChanged(int index) {
    if (_jumping) return;
    setState(() => _current = AppTab.values[index]);
  }

  void _barDragStart() => _jumping = true;

  void _barDragTo(double position) {
    if (!_controller.hasClients) return;
    _controller.jumpTo(position * _controller.position.viewportDimension);
  }

  Future<void> _barDragEnd(int index) async {
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    _jumping = false;
    setState(() => _current = AppTab.values[index]);
  }

  Widget _page(AppTab tab) {
    final s = S.of(context);
    return switch (tab) {
      AppTab.home => HomeScreen(
        onOpenSection: (section) => _open(_AppTabOf.of(section)),
      ),
      AppTab.quests => const QuestsTab(),
      AppTab.skills => SectionTab(section: Section.skills, title: s.tabSkills),
      AppTab.enchanting => SectionTab(
        section: Section.enchanting,
        title: s.tabEnchanting,
      ),
      AppTab.followers => SectionTab(
        section: Section.followers,
        title: s.tabFollowers,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: _onPageChanged,
        children: [for (final tab in AppTab.values) _page(tab)],
      ),
      bottomNavigationBar: _NavBar(
        controller: _controller,
        current: _current,
        onTap: _open,
        onDragStart: _barDragStart,
        onDragTo: _barDragTo,
        onDragEnd: _barDragEnd,
      ),
    );
  }
}

/// Вкладка, на которой живёт раздел.
abstract final class _AppTabOf {
  static AppTab of(Section section) => switch (section) {
    // Секреты живут на вкладке «Квесты».
    Section.quests || Section.secrets => AppTab.quests,
    Section.skills => AppTab.skills,
    Section.enchanting => AppTab.enchanting,
    Section.followers => AppTab.followers,
  };
}

/// Панель вкладок: выбранная шире остальных и подписана, плашка
/// выбора едет за страницами. По панели можно вести пальцем — страницы
/// листаются следом.
class _NavBar extends StatefulWidget {
  const _NavBar({
    required this.controller,
    required this.current,
    required this.onTap,
    required this.onDragStart,
    required this.onDragTo,
    required this.onDragEnd,
  });

  final PageController controller;
  final AppTab current;
  final ValueChanged<AppTab> onTap;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragTo;
  final ValueChanged<int> onDragEnd;

  /// Во сколько раз выбранная вкладка шире обычной.
  static const double activeScale = 2.2;

  static const double height = 64;

  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> {
  double? _dragFrom;
  double _dragDx = 0;

  /// Положение страниц дробным номером: 2.4 — между третьей и четвёртой.
  double get _position {
    final controller = widget.controller;
    if (controller.hasClients && controller.position.haveDimensions) {
      return controller.page ?? widget.current.index.toDouble();
    }
    return widget.current.index.toDouble();
  }

  double _unit(double width) =>
      width / (AppTab.values.length - 1 + _NavBar.activeScale);

  void _onDragStart(DragStartDetails details) {
    _dragFrom = _position;
    _dragDx = 0;
    widget.onDragStart();
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    final from = _dragFrom;
    if (from == null) return;
    _dragDx += details.delta.dx;
    final last = (AppTab.values.length - 1).toDouble();
    widget.onDragTo((from + _dragDx / _unit(width)).clamp(0, last));
  }

  void _onDragEnd(DragEndDetails details) {
    final from = _dragFrom;
    if (from == null) return;
    _dragFrom = null;
    // Встаём на ближайшую страницу; рывок от исходной — минимум на соседнюю.
    var index = _position.round();
    if (index == from.round()) {
      if (_dragDx > 20) {
        index += 1;
      } else if (_dragDx < -20) {
        index -= 1;
      }
    }
    widget.onDragEnd(index.clamp(0, AppTab.values.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: scheme.primary.withValues(alpha: 0.18)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        8,
        6,
        8,
        6 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        height: _NavBar.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
              onHorizontalDragEnd: _onDragEnd,
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) => _buildTabs(width),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabs(double width) {
    final tabs = AppTab.values;
    final scheme = Theme.of(context).colorScheme;
    final position = _position.clamp(0, tabs.length - 1).toDouble();
    final unit = _unit(width);

    // Насколько каждая вкладка выбрана, её ширина и левый край.
    final weights = [
      for (var i = 0; i < tabs.length; i++) max(0.0, 1 - (position - i).abs()),
    ];
    final widths = [
      for (final w in weights) unit * (1 + (_NavBar.activeScale - 1) * w),
    ];
    final lefts = <double>[0];
    for (var i = 1; i < tabs.length; i++) {
      lefts.add(lefts[i - 1] + widths[i - 1]);
    }

    // Плашка выбранной — между двумя соседними вкладками.
    final i = min(position.floor(), tabs.length - 2);
    final f = position - i;
    final pillLeft = lefts[i] + (lefts[i + 1] - lefts[i]) * f;
    final pillWidth = widths[i] + (widths[i + 1] - widths[i]) * f;

    return Stack(
      children: [
        Positioned(
          left: pillLeft,
          width: pillWidth,
          top: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            for (var k = 0; k < tabs.length; k++)
              SizedBox(
                width: widths[k],
                child: _NavTab(
                  tab: tabs[k],
                  weight: weights[k],
                  onTap: () => widget.onTap(tabs[k]),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.tab, required this.weight, required this.onTap});

  final AppTab tab;

  /// Насколько вкладка выбрана: 0 — нет, 1 — да.
  final double weight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color.lerp(scheme.onSurfaceVariant, scheme.primary, weight);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 1 + 0.12 * weight,
            child: Icon(tab.icon, color: color, size: 26),
          ),
          SizedBox(
            height: 16 * weight,
            child: Opacity(
              opacity: weight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tab.title(S.of(context)),
                  maxLines: 1,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
