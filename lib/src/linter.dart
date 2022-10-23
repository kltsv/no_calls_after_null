import 'package:analyzer/dart/analysis/results.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class DummyLinter extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    yield Lint(
      code: 'dummy_custom_lint',
      message: 'I always cause problems!',
      location: resolvedUnitResult.lintLocationFromOffset(0, length: 10),
    );
  }
}
