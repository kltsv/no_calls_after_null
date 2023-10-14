library no_calls_after_null;

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'no_calls_after_null.dart';

export 'src/linter.dart';

// This is the entrypoint of our custom linter
PluginBase createPlugin() => NoCallsAfterNullLinter();
