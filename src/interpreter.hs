import Control.Monad (guard, foldM)
import Data.Char (isAlpha, isAlphaNum)
import System.Environment (getArgs)
import GHC.IO.Handle (hFlush, hSetBuffering, BufferMode (LineBuffering))
import GHC.IO.Handle.FD (stdout, stdin)

data Term = Var String 
    | Abs String Term
    | App Term Term

instance Show Term where
    show (Var name) = name
    show (Abs arg body) = "\\" ++ arg ++ "." ++ show body
    show (App t1 t2) = "(" ++ show t1 ++ " " ++ show t2 ++ ")"

type Venv = [(String, Term)]

eval :: Venv -> Term -> Term 
-- | Evaluates (reduces) a term and returns the result.
eval v (Var name) = case lookup name v of
        Just t -> eval v t
        Nothing -> Var name
eval v (Abs arg body) = Abs arg body
eval v (App t1 t2) = case eval v t1 of
        Abs arg body -> eval v $ reduce arg body t2
        term -> App term $ eval v t2
    where
        reduce :: String -> Term -> Term -> Term
        -- | Substitudes an argument everywhere in a term with a different (input) term and returns the result.
        reduce arg (Var name) input
            | arg == name = input
            | otherwise = Var name
        reduce arg1 (Abs arg2 body) input
            | arg1 == arg2 = Abs arg2 body
            | otherwise = Abs arg2 $ reduce arg1 body input
        reduce arg (App t1 t2) input = App (reduce arg t1 input) (reduce arg t2 input)

data Token = Lam | Dot | LParen | RParen | Eq | Name String 
    deriving Eq

scan :: String -> [Token]
-- | Scans (lexes) a line and stores the tokens.
scan [] = []
scan (c : cs)
    | c == ' '  = scan cs
    | isAlpha c = let (tail, rest) = span isAlphaNum cs in Name (c : tail) : scan rest
    | c == '\\' = Lam : scan cs
    | c == '.' = Dot : scan cs
    | c == '(' = LParen : scan cs
    | c == ')' = RParen : scan cs
    | c == '=' = Eq : scan cs
    | c == '%' = []
    | otherwise = error ("Unknown input symbol: " ++ c : ".")

parseTerm :: [Token] -> (Term, [Token])
-- | Parses a lambda calculus term.
parseTerm (Lam : rest) = (foldr Abs body args, rest'') where
        (args, rest') = grabArgs rest
        (body, rest'') = parseTerm rest'

        grabArgs :: [Token] -> ([String], [Token])
        -- | Collects the arguments of a multi-argument lambda function.
        grabArgs (Name arg : Dot : rest) = ([arg], rest)
        grabArgs (Name arg : rest) = (arg : args, rest') where (args, rest') = grabArgs rest
        grabArgs _ = error "Unexpected token."
parseTerm tokens = leftRecurse f rest where (f, rest) = parseLeaf tokens

parseLeaf :: [Token] -> (Term, [Token])
-- | Parses a variable or a parenthesised expression.
parseLeaf (Name var : rest) = (Var var, rest)
parseLeaf (LParen : tail) = (term, rest) where (term, RParen : rest) = parseTerm tail
parseLeaf _ = error "Unexpected token."

leftRecurse :: Term -> [Token] -> (Term, [Token])
-- | Left-associatively parses function applications.
leftRecurse t1 (Name n : rest) = leftRecurse (App t1 t2) rest' where 
    (t2, rest') = parseLeaf (Name n : rest)
leftRecurse t1 (LParen : rest) = leftRecurse (App t1 t2) rest' where 
    (t2, rest') = parseLeaf (LParen : rest) 
leftRecurse t1 rest = (t1, rest)

split' :: String -> Char -> [String]
-- | Splits a string by a specified delimiter and newline carachter.
split' "" _ = []
split' str delim = line : split' (drop 1 rest) delim where (line, rest) = span (\c -> c /= delim && c /= '\n') str

unsnoc :: [a] -> Maybe ([a], a)
-- | https://github.com/haskell/core-libraries-committee/issues/165
unsnoc = foldr (\x -> Just . maybe ([], x) (\(~(a, b)) -> (x : a, b))) Nothing

loadLine :: Venv -> String -> Bool -> IO Venv
-- | Reads a variable assignment and saves it to the virtual environment if the third 
--  input is False; throws an error if the second input is not an assignment. 
--  If the third input is True, may also read and run a command.
loadLine venv line isAssignment = case scan line of
        (Name n : Eq : rest) -> return ((n, fst $ parseTerm rest) : venv)
        [] -> return venv
        tokens 
            | isAssignment -> error "syntax error"
            | otherwise -> print (eval venv (fst $ parseTerm tokens)) >> return venv

repl :: Venv -> IO ()
-- | Starts a lambda calculus read-eval-print loop.
repl venv = do
    putStr "lc> " >> hFlush stdout
    line <- getLine
    if line == ":q" then return ()
    else do
        let (heads, last) = case unsnoc (split' line ',') of 
                (Just pair) -> pair 
                Nothing -> ([], [])
        venv' <- foldM (\v l -> loadLine v l True) venv heads
        venv'' <- loadLine venv' last False
        repl venv''

main :: IO ()
main = do
    hSetBuffering stdin LineBuffering
    args <- getArgs
    case args of
        [file] -> do
            code <- readFile file
            venv <- foldM (\v l -> loadLine v l True) [] (split' code ',')
            repl venv
        [] -> repl []
        _  -> putStrLn "usage: runlc [file]"
