A? topLevel = A();

void main() {
  topLevel = null;

  // LINT
  topLevel?.foo();

  topLevel?.innerVar = null;

  // LINT
  topLevel?.innerVar?.foo();

  A? localA;

  // LINT
  localA?.foo();

  A? localA2 = A();

  // NO LINT
  localA2.foo();

  A? localA3 = null;

  // LINT
  localA3?.foo();

  final A? localA4 = null;

  // LINT
  localA4?.foo();
}

class A {
  A? innerVar;

  void foo() {
    innerVar = null;

    // LINT
    innerVar?.foo();

    innerVar = A();
    // NO LINT
    innerVar?.foo();

    innerVar?.innerVar = null;

    // LINT
    innerVar?.innerVar?.foo();

    innerVar?.innerVar = A();
    // NO LINT
    innerVar?.innerVar?.foo();
  }
}
