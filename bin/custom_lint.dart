import 'dart:isolate';

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:no_calls_after_null/no_calls_after_null.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, NoCallsAfterNullLinter());
}
