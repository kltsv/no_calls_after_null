import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _enableLogs = false;

class NoCallsAfterNullLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        NoCallsAfterNullRule(),
      ];
}

class NoCallsAfterNullRule extends DartLintRule {
  static const _lintName = 'avoid_calls_after_null';
  static const _code = LintCode(
    name: _lintName,
    problemMessage: '$_lintName\n\nThis target is null here. '
        'It has been assigned to null in this scope earlier.',
    correctionMessage: 'Move this call before "yourValue = null"',
  );

  const NoCallsAfterNullRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter,
      CustomLintContext context) {
    _log(() => 'Lib: ${resolver.path}');
    final candidates = <String>{};

    context.registry.addDeclaration((node) {
      node.visitChildren(
        LinterVisitor(
          onVisitMethodDeclaration: (node) {
            _log(() => 'Method: ${node.name.lexeme}');
          },
          exitVisitMethodDeclaration: (node) {
            _log(() => 'MethodExit: ${node.name.lexeme}');
            candidates.clear();
          },
          onVisitAssignment: (node) {
            _log(() => 'Assignment: $node');
            final variable = node.leftHandSide.toString();
            if (node.rightHandSide.toString() == 'null') {
              candidates.add(variable);
            } else {
              candidates.remove(variable);
            }
          },
          onVisitVariableDeclaration: (VariableDeclaration node) {
            _log(() => 'Variable: $node');
            final element = node.declaredElement;
            if (element == null) {
              return;
            }

            // if nullable final/var without assignment (or assigned 'null')
            if (element.type.nullabilitySuffix == NullabilitySuffix.question &&
                (node.initializer == null ||
                    node.initializer.toString() == 'null')) {
              candidates.add(element.name);
            }
          },
          onVisitMethodCall: (node) {
            final realTarget = node.realTarget.toString();
            _log(() =>
                'Call: $node, target: $realTarget (candidates: $candidates)');
            if (candidates.contains(realTarget)) {
              final lint = LintCode(
                name: _lintName,
                problemMessage: '$_lintName\n\nThis target is null here. '
                    'It has been assigned to null in this scope earlier.',
                correctionMessage: 'Move this call before "$realTarget = null"',
              );
              _log(() => 'Lint caught: $node');
              reporter.reportErrorForNode(lint, node);
            }
          },
        ),
      );
    });
  }
}

class LinterVisitor extends RecursiveAstVisitor {
  void Function(MethodDeclaration node) onVisitMethodDeclaration;
  void Function(MethodDeclaration node) exitVisitMethodDeclaration;
  void Function(AssignmentExpression node) onVisitAssignment;
  void Function(VariableDeclaration node) onVisitVariableDeclaration;
  void Function(MethodInvocation node) onVisitMethodCall;

  LinterVisitor({
    required this.onVisitMethodDeclaration,
    required this.exitVisitMethodDeclaration,
    required this.onVisitAssignment,
    required this.onVisitVariableDeclaration,
    required this.onVisitMethodCall,
  });

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    onVisitMethodDeclaration(node);
    final result = super.visitMethodDeclaration(node);
    exitVisitMethodDeclaration(node);
    return result;
  }

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    onVisitAssignment(node);
    return super.visitAssignmentExpression(node);
  }

  @override
  visitVariableDeclaration(VariableDeclaration node) {
    onVisitVariableDeclaration(node);
    return super.visitVariableDeclaration(node);
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    onVisitMethodCall(node);
    return super.visitMethodInvocation(node);
  }
}

void _log(Object? message) {
  if (_enableLogs) {
    print(message is Function ? message.call() : message);
  }
}
