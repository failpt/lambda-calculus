# Lazy evaluation $\lambda$-calculus interpreter
The project is fully written in Haskell. Expressions are Eta-reduced after evaluation.
## Usage 
First, [install Haskell](https://www.haskell.org/ghcup/install/). Then, from the `src/` directory compile an executable with
```
% ghc --make Main.hs -o runlc
```
*(runlc can be replaced with any desired name)*

You may now run the interpreter with `./runlc [file]` on Unix and `.\runlc.exe [file]` on Windows. To **exit** the REPL type `:q`.

## Syntax
- A lambda function is denoted with `\` (for $\lambda$) followed by the input, `.` and the function body.
- Variable names can contain letters and/or numbers.
- `\x. \y. \z. body` can be written as `\x y z. body`, input arguments must be separated with spaces.
- All functions as well as function applications treated as input arguments must be wrapped in parentheses (i.e. `\f. (\x. f (x x)) (\x. f (x x))`, not `\f. (\x. f (x x)) \x. f (x x)`).
- Expressions can contain function calls or assignments, input files must only contain the latter. Expressions can be separated by `,` or `\n`, but a call cannot precede `,`.
- (Inline) Comments must start with `%`.

## Examples
All the unspecified functions are defined in `src/minilib.lc`. Further details are available on [wiki](https://en.wikipedia.org/wiki/Church_encoding).
1. Church pairs
```
% ./runlc 
lc> pair = \x y. \z. z x y, first = \p. p (\x y. x), second = \p. p (\x y. y)
lc> first (pair a b) % fooooo
a
lc> second (pair x y)
y
```
2. Church Booleans
```
% ./runlc minilib.lc
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
% ./runlc minilib.lc 
lc> minus 6 4
\f. \x. (f (f x))
lc> mult 2 1
\f. \x. (f (f x))
lc> 
lc> pred 5
\f. \x. (f (f (f (f x))))
lc> plus 3 1
\f. \x. (f (f (f (f x))))
lc> div 8 2
\f. \x. (f (f (f (f x))))
```
4. Scott lists
```
% ./runlc minilib.lc
lc> La = Cons 2 (Cons 4 (Cons 3 (Cons 5 NIL))), Lb = Map (minus 6) La
lc> Head (Tail Lb)
\f. \x. (f (f x))
lc> 2
\f. \x. (f (f x))
lc> Head (Map2 plus La Lb)
\f. \x. (f (f (f (f (f (f x))))))
lc> 6
\f. \x. (f (f (f (f (f (f x))))))
lc> Lc = (Cons 1 (Cons 3 (Cons 2 NIL))), fold plus 0 Lc
\f. \x. (f (f (f (f (f (f x))))))
lc>
lc> Tail (Append (Cons 1 NIL) (Cons 3 (Cons 2 NIL)))
\n. \c. ((c \f. \x. (f (f x))) \n. \c. ((c \f. f) \n. \c. n))
lc> Cons 2 (Cons 1 NIL)
\n. \c. ((c \f. \x. (f (f x))) \n. \c. ((c \f. f) \n. \c. n))
```
