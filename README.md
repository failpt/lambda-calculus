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
