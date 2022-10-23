import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _enableLogs = true;

class NoCallsAfterNullLinter extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    _log(() => 'Lib: ${resolvedUnitResult.path}');
    final result = <Lint>[];
    final candidates = <String>{};

    resolvedUnitResult.unit.visitChildren(
      LinterVisitor(
        onVisitMethodDeclaration: (node) {
          _log(() => 'Method: ${node.name2}');
        },
        exitVisitMethodDeclaration: (node) {
          _log(() => 'MethodExit: ${node.name2}');
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
        onVisitMethodCall: (node) {
          final realTarget = node.realTarget.toString();
          _log(() =>
              'Call: $node, target: $realTarget (candidates: $candidates)');
          if (candidates.contains(realTarget)) {
            final lint = Lint(
              code: 'no_calls_after_null',
              message:
                  'This target is null here. It has been assigned to null in this scope earlier.',
              correction: 'Move this call before "$realTarget = null"',
              location: resolvedUnitResult.lintLocationFromOffset(
                node.offset,
                length: node.length,
              ),
            );
            _log(() => 'Lint caught: $node');
            result.add(lint);
          }
        },
      ),
    );

    for (final lint in result) {
      yield lint;
    }
  }
}

class LinterVisitor extends RecursiveAstVisitor {
  void Function(MethodDeclaration node) onVisitMethodDeclaration;
  void Function(MethodDeclaration node) exitVisitMethodDeclaration;
  void Function(AssignmentExpression node) onVisitAssignment;
  void Function(MethodInvocation node) onVisitMethodCall;

  LinterVisitor({
    required this.onVisitMethodDeclaration,
    required this.exitVisitMethodDeclaration,
    required this.onVisitAssignment,
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
