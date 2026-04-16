# Analysis Classification Exercise

## Instructions
For each code snippet in `code-samples.md`, fill in the table below.

**Objective categories:** Correctness, Security, Performance
**Detection method:** Static, Dynamic, Both

---

| Snippet | Issue Description | Objective | Detection Method | Explanation |
|---------|-------------------|-----------|-----------------|-------------|
| 1 | String concatenation with user input → SQL injection risk | Security | Static | Static analysis can flag unsafe string building patterns, but the actual attack would only happen at runtime. |
| 2 | Unreachable code after return | Correctness | Static | Static tools easily detect unreachable code because the function returns before the console.log. |
| 3 | Possible division by zero if list is empty | Correctness | Dynamic | Only running the code with an empty list triggers the crash; static tools usually won’t know list length. |
| 4 | Missing null terminator → buffer overflow | Security | Static | Static analysis can detect unsafe C string copying without bounds checks. |
| 5 | Loop goes out of bounds (<= instead of <) | Correctness | Dynamic | The bug only appears when the loop hits the invalid index at runtime. |
| 6 | Exponential recursion → extremely slow for large n | Performance | Both | Static tools can warn about expensive recursion; runtime tests show the slowdown clearly. |
| 7 | File handle never closed → resource leak | Performance | Static | Static analysis can detect missing close() calls; dynamic detection requires special tools.
 |
| 8 | Command injection via os.system("rm " + user_in) | Security | Static | Static tools can detect unsafe shell command construction; runtime would be dangerous. |
| 9 | Cache grows forever → memory leak | Performance | Dynamic | Static tools can warn about unbounded data structures; runtime shows memory usage increasing. |
| 10 | Unreachable code after return | Correctness | Static | Static analysis catches unreachable statements; dynamic analysis never reaches them. |
| 11 | Inconsistent state if exception occurs mid‑transfer | Correctness | Dynamic | Only running the code with an exception shows the inconsistent account state. |
| 12 | Inefficient O(n²) search | Performance | Static | Static tools can detect nested loops; runtime slowdown depends on input size. |
| 13 | Writing raw user input to DOM → XSS risk | Security | Static | Static analysis can detect unsafe DOM writes; dynamic detection requires an actual attack. |
| 14 | Possible division by zero | Correctness | Dynamic | Only runtime execution with divisor = 0 triggers the error. |
| 15 | Returning pointer to local stack variable | Correctness | Static | Static analysis can detect invalid pointer lifetime; dynamic behavior is undefined. |

---

## Summary Questions

### How many snippets had Correctness issues? 8 (Snippets 2, 3, 5, 10, 11, 14, 15)

### How many had Security issues? 3 (Snippets 1, 8, 13)

### How many had Performance issues? 4 (Snippets 6, 7, 9, 12)

### Which issues are best caught by static analysis? Why?
Static analysis is best for problems that you can spot just by looking at the code, without needing to run it. Things like unreachable code, unsafe string building, memory leaks, or returning pointers that don’t live long enough are all visible from the structure of the program. Tools can point these out right away because they don’t depend on any specific input or runtime behavior. It’s basically good for catching mistakes that are “baked into” the code itself.

### Which issues require dynamic analysis? Why?
Dynamic analysis is needed when the bug only shows up while the program is actually running. These are things like dividing by zero, going out of bounds in a loop, or hitting an exception that leaves the program in a weird state. You won’t see these just by reading the code — you have to run it with certain inputs to trigger the problem. So dynamic analysis is better for catching issues that depend on real data or real execution paths.
