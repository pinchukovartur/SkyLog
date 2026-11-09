import 'package:flutter/widgets.dart';

import 'progress.dart';

/// Раздаёт [Progress] дереву виджетов и перестраивает их при изменениях.
class ProgressScope extends InheritedNotifier<Progress> {
  const ProgressScope({
    super.key,
    required Progress progress,
    required super.child,
  }) : super(notifier: progress);

  static Progress of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
}
