# Analysis Report: Calculator Bugs

## Student Name: Roman Dattilo
## Date: 3/12/26

---

## Part 1: Static Analysis Findings (ESLint)

Run `npx eslint calculator.js` and record all findings below.

| # | Line | Rule    | Description        | Severity |
|---|------|------   |-------------       |----------|
| 1 | add() | no-undef |reslt is not define |  error  |
| 2 | subtract() | no-unreachable | Code after return is unreachable |  error   |
| 3 | calculate() | no-fallthrough | Missing break after "add" case |  warn |
| 4 | power() | no-unused-vars | Variable  declared but never used | warn |
| 5 | absolute() |no-constant-condition | Condition if (true) always true | warn |

**Total static analysis issues found:** _5_

---

## Part 2: Dynamic Analysis Findings (Test Suite)

Run `node test-calculator.js` and record all test failures below.

| # | Test Name | Error Message | Root Cause |
|---|-----------|---------------|------------|
| 1 | add(2, 3) | expected 5, got NaN | Used reslt instead of b |
| 2 | calculate("add", 10, 5) | expected 15, got subtract result | Switch fallthrough from "add" to "subtract" |
| 3 | divide(10, 0) | division by zero not handled | No check for b === 0 |
| 4 | factorial(-1) | infinite recursion | Missing negative input base case |
| 5 | multiply("3", 4) | expected 12, got 0 | Used == which caused type coercion |

**Total dynamic analysis issues found:** _5_

---

## Part 3: Comparison

### Which bugs did ONLY static analysis catch?
<!-- List bugs found by ESLint but NOT by running tests -->

1. Unused variable (temp in power)
2. Constant condition (if (true) in absolute)


### Which bugs did ONLY dynamic analysis catch?
<!-- List bugs found by tests but NOT by ESLint -->

1. Division by zero in divide
2. Infinite recursion in factorial
3. Type coercion in multiply


### Which bugs were found by BOTH approaches?
<!-- List bugs caught by both ESLint and test failures -->

1. Undefined variable in add
2. Switch fallthrough in calculate

---

## Part 4: Reflection

### Why can't static analysis catch all bugs?
Static analysis only looks at the code without actually running it, so it can’t see what happens when the program is executed. Because of that, things like infinite loops, bad inputs, or weird behavior with certain values won’t show up. It’s good for spotting obvious mistakes, but not deeper logic problems.

### Why can't dynamic analysis catch all bugs?
Dynamic analysis depends on the tests you run, so it only finds bugs if the test actually triggers them. If a test never hits a certain part of the code, then that bug stays hidden. It also doesn’t warn you about things like unused variables or unreachable code.

### When would you prioritize one approach over the other?
Static analysis is helpful early on because it quickly points out simple mistakes before you even run the program. Dynamic analysis is more useful when you want to make sure your code actually works the way you expect with real inputs. In most cases, using both together gives you the best coverage.