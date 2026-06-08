# Lazy evaluation $\lambda$-calculus interpreter
The project is fully written in Haskell. Expressions are Eta-reduced at evaluation.
## Usage 
First, [instal Haskell](https://www.haskell.org/ghcup/install/). Then, from the `src/` directory compile an executable with
```
% ghc --make Main.hs -o runlc
```
*(runlc can be replaced with any desired name)*

You may now run the interpreter with `./runlc [file]` on Unix and `.\runlc.exe [file]` on Windows. To **exit** a REPL type `:q`.

## Syntax
- `\` for $\lambda$ followed by the input, `.` and the function body.
- `\x. \y. \z. body` can be written as `\x y z. body`, input arguments must be separated by spaces.
- With the exception of the outer expression, all functions as well as function applications treated as input arguments must be wrapped in parentheses (i.e. `\f. (\x. f (x x)) (\x. f (x x))`, not `\f. (\x. f (x x)) \x. f (x x)`).
- Expressions can be separated by `,` or `\n`.
- (Inline) Comments must start with `%`.
- Expressions are either function calls or assignments, input files must only contain the latter.
- To evaluate a function in a REPL your line must end with its call (precceeded by assignments or nothing).
## Examples
The unspecified functions are defined in `src/*.lc` and [here](https://en.wikipedia.org/wiki/Church_encoding).
1. Church pairs
```
% ./runlc 
lc> pair = \x y. \z. z x y, first = \p. p (\x y. x), second = \p. p (\x y. y)
lc> first (pair a b)
a
lc> second (pair x y)
y
```
2. Church Booleans
```
% ./runlc churchbools.lc 
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
3. Church numerals
```
% ./runlc churchnums.lc 
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
```
4. Scott lists
```
% ./runlc scottlists.lc
lc> list = Cons a (Cons b (Cons c (Cons d NIL)))
lc> Head list
a
lc> isEmpty list
\a. \b. b
lc> list
\n. \c. ((c a) \n. \c. ((c b) \n. \c. ((c c) \n. \c. ((c \n. \c. n) \n. \c. n))))
lc> Cons (Head list) (Tail list)
\n. \c. ((c a) \n. \c. ((c b) \n. \c. ((c c) \n. \c. ((c \n. \c. n) \n. \c. n))))
```
