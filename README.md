# Lazy evaluation Lambda calculus interpreter
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
