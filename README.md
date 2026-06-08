# Lazy evaluation $\lambda$-calculus interpreter
Fully implemented in Haskell.
## Usage 

## Syntax
- `\` for $\lambda$ followed by the input, `.` and the function body.
- `\x. \y. \z. body` can be written as `\x y z. body`, input arguments must be separated by spaces.
- With the exception of the outer expression, all functions as well as function applications treated as input arguments must be wrapped in parentheses (i.e. `\f. (\x. f (x x)) (\x. f (x x))`, not `\f. (\x. f (x x)) \x. f (x x)`).
- Expressions can be separated by `,` or `\n`.
- Expressions are either function calls or declarations, input files must only contain the latter.
- To evaluate a function in a REPL your line must end with its call (precceeded by definitions or nothing).
## Examples
```
./runlc churchbools.lc 
lc> and true false
\a. \b. b
lc> false
\a. \b. b
lc> or false true
\a. \b. a
lc> true
\a. \b. a
lc> not true
\a. \b. b
lc> xor true true
\a. \b. b
lc> nand false false
\a. \b. a
```

```
./runlc churchnums.lc 
lc> 6
\f. \x. (f (f (f (f (f (f x))))))
lc> minus 6 3 f x
(f (f (f x)))
lc> f (2 f x)
(f (f (f x)))
lc> pred 6
\f. \x. (f (f (f (f (f x)))))
lc> 5
\f. \x. (f (f (f (f (f x)))))
lc> plus 2 3
\f. \x. (f (f (f (f (f x)))))
lc> mult 2 3
\f. \x. (f (f (f (f (f (f x))))))
lc> 6
\f. \x. (f (f (f (f (f (f x))))))
lc> :q
```

```
lc> pair = \x y. \z. z x y, first = \p. p (\x y. x), second = \p. p (\x y. y)
lc> first (pair a b)
a
lc> second (pair a b)
b
```
