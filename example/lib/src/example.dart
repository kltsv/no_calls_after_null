A? topLevel = A();

void main() {
  topLevel = null;

  // LINT
  topLevel?.foo();

  topLevel?.innerVar = null;

  // LINT
  topLevel?.innerVar?.foo();
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
