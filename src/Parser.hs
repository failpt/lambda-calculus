module Parser where

import Evaluator (Term(..))
import Data.Char (isAlphaNum)
import Data.Bifunctor (first)

data Token = Lam | Dot | LParen | RParen | Eq | Name String

instance Show Token where 
    show Lam = "\\"
    show Dot = "."
    show LParen = "("
    show RParen = ")"
    show Eq = "="
    show (Name n) = n

scan :: String -> Either String [Token]
-- | Scans (lexes) a line and stores the tokens.
scan [] = Right []
scan (c : cs)
    | c == ' '  = scan cs
    | isName c = let (tail, rest) = span isName cs in (Name (c:tail) :) <$> scan rest
    | c == '\\' = (Lam:) <$> scan cs
    | c == '.' = (Dot:) <$> scan cs
    | c == '(' = (LParen:) <$> scan cs
    | c == ')' = (RParen:) <$> scan cs
    | c == '=' = (Eq:) <$> scan cs
    | c == '%' = Right []
    | otherwise = Left $ "Unknown input symbol: " ++ c : "."
    where isName c = isAlphaNum c || c == '-' || c == '_'

parseTerm :: [Token] -> Either String (Term, [Token])
-- | Parses a lambda calculus term.
parseTerm (Lam : rest) = do 
    (args, rest') <- grabArgs rest
    (body, rest'') <- parseTerm rest'
    return (foldr Abs body args, rest'')
    where
        grabArgs :: [Token] -> Either String ([String], [Token])
        grabArgs (Name arg : Dot : rest) = Right ([arg], rest)
        grabArgs (Name arg : rest) = first (arg:) <$> grabArgs rest
        grabArgs (t : _) = Left $ "Unexpected token: " ++ show t ++ "."
        grabArgs _ = Left "Missing arguments."
parseTerm toks = parseNode toks >>= uncurry leftRecurse

parseNode :: [Token] -> Either String (Term, [Token])
-- | Parses a variable or a parenthesised expression.
parseNode (Name var : rest) = Right (Var var, rest)
parseNode (LParen : rest) = case parseTerm rest of 
        Right (term, RParen : rest'') -> Right (term, rest'')
        _ -> Left "Missing closing parenthesis."
parseNode (t : _) = Left ("Unexpected token: " ++ show t ++ ".")
parseNode _ = Left "Missing variables."

leftRecurse :: Term -> [Token] -> Either String (Term, [Token])
-- | Left-associatively parses function applications.
leftRecurse t1 toks = case toks of
    (Name n : _) -> go
    (LParen : _) -> go
    _ -> Right (t1, toks)
    where go = parseNode toks >>= \(t2, rest') -> leftRecurse (App t1 t2) rest'