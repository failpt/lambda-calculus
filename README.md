# Lazy evaluation $\lambda$-calculus interpreter
The project is fully written in Haskell. Expressions are Eta-reduced after evaluation.
## Usage 
First, [install Haskell](https://www.haskell.org/ghcup/install/). Then, from the `src/` directory compile an executable with
```
$ ghc --make Main.hs -o runlc
```
*(runlc can be replaced with any desired name)*.

You may now run the interpreter with `./runlc [file]` on Unix and `.\runlc.exe [file]` on Windows. To **exit** the REPL type `:q`.

## Syntax
- A lambda function is denoted with `\` (for $\lambda$) followed by the input, `.` and the function body.
- Variable names can contain `-`, `_`, letters and/or numbers.
- `\x. \y. \z. body` can be written as `\x y z. body`, input arguments must be separated with spaces.
- All functions as well as function applications treated as input arguments must be wrapped in parentheses (i.e. `\f. (\x. f (x x)) (\x. f (x x))`, not `\f. (\x. f (x x)) \x. f (x x)`).
- Expressions can contain function calls or assignments, input files must only contain the latter. Expressions can be separated by `,` or `\n`, but a call cannot precede `,`.
- (Inline) Comments must start with `%`.

E.g.:
```
lc> pair = \x y. \z. z x y, first = \p. p (\x y. x), second = \p. p (\x y. y) % these are called Church pairs
lc> first (pair a b)
a
lc> second (pair x y)
y
```

## minilib.lc
Defines pairs, Booleans, numbers 0-9, two list representations, and operations on them using [Church encoding](https://en.wikipedia.org/wiki/Church_encoding) *(thank the Turing-completeness of lambda calculus)*. The code below contains extensive usage examples.

### Booleans
```
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
### Church numerals
```
lc> IsZero 2
\a. \b. b
lc> LEQ 3 4
\a. \b. a
lc> EQ 3 4
\a. \b. b
lc>
lc> 2
\f. \x. f (f x)
lc> minus 6 4
\f. \x. f (f x)
lc> mult 2 1
\f. \x. f (f x)
lc> 
lc> pred 5
\f. \x. f (f (f (f x)))
lc> plus 3 1
\f. \x. f (f (f (f x)))
lc> div 8 2
\f. \x. f (f (f (f x)))
```
### Scott lists
```
lc> La = Cons 2 (Cons 4 (Cons 3 (Cons 5 NIL))), Lb = Map (minus 6) La
lc> Head (Tail Lb)
\f. \x. f (f x)
lc> Head (Map2 plus La Lb)
\f. \x. f (f (f (f (f (f x)))))
lc> 6
\f. \x. f (f (f (f (f (f x)))))
lc> Lc = (Cons 1 (Cons 3 (Cons 2 NIL))), fold plus 0 Lc
\f. \x. f (f (f (f (f (f x)))))
lc> 
lc> Tail (Append (Cons 1 NIL) (Cons 3 (Cons 2 NIL)))
\n. \c. c (\f. \x. f (f x)) (\n. \c. c (\f. f) (\n. \c. n))
lc> Cons 2 (Cons 1 NIL)
\n. \c. c (\f. \x. f (f x)) (\n. \c. c (\f. f) (\n. \c. n))
```
### One-pair lists
*(cons = pair)*
```
lc> head (cons 2 (cons 3 (cons 4 nil)))
\f. \x. f (f x)
lc> tail (cons 2 (cons 0 (cons 0 nil)))
\z. z (\f. \x. x) (\z. z (\f. \x. x) (\a. \b. b))
lc> cons 0 (cons 0 nil)
\z. z (\f. \x. x) (\z. z (\f. \x. x) (\a. \b. b))
lc>
lc> L123 = cons 1 (cons 2 (cons 3 nil)), L456 = cons 4 (cons 5 (cons 6 nil))
lc> EQ (length L123) (length L456)
\a. \b. a
lc> isnil L123
\a. \b. b
lc> 
lc> filter (LEQ 3) (concat L456 L123)
\z. z (\f. \x. f (f (f (f x)))) (\z. z (\f. \x. f (f (f (f (f x))))) (\z. z (\f. \x. f (f (f (f (f (f x)))))) (\z. z (\f. \x. f (f (f x))) (\a. \b. b))))
lc> conj L456 3
\z. z (\f. \x. f (f (f (f x)))) (\z. z (\f. \x. f (f (f (f (f x))))) (\z. z (\f. \x. f (f (f (f (f (f x)))))) (\z. z (\f. \x. f (f (f x))) (\a. \b. b))))
lc> 
lc> drop 2 L123
\z. z (\f. \x. f (f (f x))) (\a. \b. b)
lc> cons 3 nil
\z. z (\f. \x. f (f (f x))) (\a. \b. b)
lc>
lc> drop-while (LEQ 5) (reverse L456)
\z. z (\f. \x. f (f (f (f x)))) (\a. \b. b)
lc> cons 4 nil
\z. z (\f. \x. f (f (f (f x)))) (\a. \b. b)
lc> 
lc> drop-last 4 (concat L123 L456)
\z. z (\f. f) (\z. z (\f. \x. f (f x)) (\a. \b. b))
lc> cons 1 (cons 2 nil)
\z. z (\f. f) (\z. z (\f. \x. f (f x)) (\a. \b. b))
lc> take 2 L123
\z. z (\f. f) (\z. z (\f. \x. f (f x)) (\a. \b. b))
lc> 
lc> take-while (LEQ 2) (reverse L123)
\z. z (\f. \x. f (f (f x))) (\z. z (\f. \x. f (f x)) (\a. \b. b))
lc> cons 3 (cons 2 nil)
\z. z (\f. \x. f (f (f x))) (\z. z (\f. \x. f (f x)) (\a. \b. b))
lc> take-last 2 (map (minus 5) L123)
\z. z (\f. \x. f (f (f x))) (\z. z (\f. \x. f (f x)) (\a. \b. b))
lc> 
lc> all (LEQ 4) L456 
\a. \b. a
lc> any (LEQ 4) L123
\a. \b. b
lc> 
lc> index-of (EQ 3) L123 % indexes elements from 1, returns 0 if not found
\f. \x. f (f (f x))
lc> element-at 1 (remove-at 1 L123)
\f. \x. f (f (f x))
lc> last-index-of (EQ 4) (repeat 4 3)
\f. \x. f (f (f x))
lc> 
lc> element-at 1 (zip L123 (range succ 2 3))
\z. z (\f. \x. f (f x)) (\f. \x. f (f (f x)))
lc> pair 2 3
\z. z (\f. \x. f (f x)) (\f. \x. f (f (f x)))
lc> 
lc> replace-at 1 0 (remove-at 2 L123)
\z. z (\f. f) (\z. z (\f. \x. x) (\a. \b. b))
lc> cons 1 (cons 0 nil)
\z. z (\f. f) (\z. z (\f. \x. x) (\a. \b. b))
lc> 
lc> L210 = map (minus 3) L123
lc> lfold plus 0 L210
\f. \x. f (f (f x))
lc> rfold plus 0 L210
\f. \x. f (f (f x))
```
