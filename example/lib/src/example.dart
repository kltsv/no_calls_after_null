A? topLevel = A();

void main() {
  topLevel = null;

  // expect_lint: avoid_calls_after_null
  topLevel?.foo();

  topLevel?.innerVar = null;

  // expect_lint: avoid_calls_after_null
  topLevel?.innerVar?.foo();

  A? localA;

  // expect_lint: avoid_calls_after_null
  localA?.foo();

  A? localA2 = A();

  // NO LINT
  localA2.foo();

  A? localA3 = null;

  // expect_lint: avoid_calls_after_null
  localA3?.foo();

  final A? localA4 = null;

  // expect_lint: avoid_calls_after_null
  localA4?.foo();
}

class A {
  A? innerVar;

  void foo() {
    innerVar = null;

    // expect_lint: avoid_calls_after_null
    innerVar?.foo();

    innerVar = A();
    // NO LINT
    innerVar?.foo();

    innerVar?.innerVar = null;

    // expect_lint: avoid_calls_after_null
    innerVar?.innerVar?.foo();

    innerVar?.innerVar = A();
    // NO LINT
    innerVar?.innerVar?.foo();
  }
}
