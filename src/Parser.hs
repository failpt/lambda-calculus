module Parser where

import Evaluator
import Data.Char (isAlphaNum)

data Token = Lam | Dot | LParen | RParen | Eq | Name String

instance Show Token where 
    show Lam = "\\"
    show Dot = "."
    show LParen = "("
    show RParen = ")"
    show Eq = "="
    show (Name n) = n

scan :: String -> [Token]
-- | Scans (lexes) a line and stores the tokens.
scan [] = []
scan (c : cs)
    | c == ' '  = scan cs
    | isName c = let (tail, rest) = span isName cs in Name (c : tail) : scan rest
    | c == '\\' = Lam : scan cs
    | c == '.' = Dot : scan cs
    | c == '(' = LParen : scan cs
    | c == ')' = RParen : scan cs
    | c == '=' = Eq : scan cs
    | c == '%' = []
    | otherwise = error ("Unknown input symbol: " ++ c : ".")
    where isName c = isAlphaNum c || c == '-' || c == '_'

parseTerm :: [Token] -> (Term, [Token])
-- | Parses a lambda calculus term.
parseTerm (Lam : rest) = (foldr Abs body args, rest'') where
        (args, rest') = grabArgs rest
        (body, rest'') = parseTerm rest'

        grabArgs :: [Token] -> ([String], [Token])
        grabArgs (Name arg : Dot : rest) = ([arg], rest)
        grabArgs (Name arg : rest) = (arg : args, rest') where (args, rest') = grabArgs rest
        grabArgs (t : _) = error ("Unexpected token: " ++ show t ++ ".")
        grabArgs _ = error "Missing arguments."
parseTerm tokens = leftRecurse f rest where (f, rest) = parseNode tokens

parseNode :: [Token] -> (Term, [Token])
-- | Parses a variable or a parenthesised expression.
parseNode (Name var : rest) = (Var var, rest)
parseNode (LParen : rest) = case rest' of 
        (RParen : rest'') -> (term, rest'')
        _ -> error "Missing closing parenthesis."
        where (term, rest') = parseTerm rest
parseNode (t : _) = error ("Unexpected token: " ++ show t ++ ".")
parseNode _ = error "Missing variables."

leftRecurse :: Term -> [Token] -> (Term, [Token])
-- | Left-associatively parses function applications.
leftRecurse t1 (Name n : rest) = leftRecurse (App t1 t2) rest' where 
    (t2, rest') = parseNode (Name n : rest)
leftRecurse t1 (LParen : rest) = leftRecurse (App t1 t2) rest' where 
    (t2, rest') = parseNode (LParen : rest) 
leftRecurse t1 rest = (t1, rest)
