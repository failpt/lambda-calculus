module Main where

import Evaluator (Venv, eta)
import Parser (parseTerm, scan, Token(Eq, Name))
import Control.Monad (foldM, unless)
import System.Environment (getArgs)
import GHC.IO.Handle (hFlush, hSetBuffering, BufferMode (LineBuffering))
import GHC.IO.Handle.FD (stdout, stdin)
import Data.Maybe (fromMaybe)

split' :: String -> Char -> [String]
-- | Splits a string by the specified delimiter.
split' "" _ = []
split' str delim = line : split' (drop 1 rest) delim where (line, rest) = span (/= delim) str

prelex :: String -> [String]
-- | Splits a line into strings ready to be lexed (scanned, tokenized)
prelex line = split' (takeWhile (/= '%') line) ','

unsnoc :: [a] -> Maybe ([a], a)
-- | https://github.com/haskell/core-libraries-committee/issues/165
unsnoc = foldr (\x -> Just . maybe ([], x) (\(~(a, b)) -> (x : a, b))) Nothing

loadTerm :: String -> Bool -> Venv -> IO (Either String Venv)
-- | Reads a variable assignment and saves it to the virtual environment if the second 
--  input is True; throws an error if the first input is not an assignment. 
--  If the second input is False, may also read and run a command.
loadTerm str isAssignment venv = either (return . Left) loadToks (scan str)
    where
        loadToks [] = return $ Right venv
        loadToks (Name n : Eq : rest) = either (return . Left) (return . Right . (:venv) . (,) n . fst) (parseTerm rest)
        loadToks toks
            | isAssignment = return $ Left $ "Invalid assignment: " ++ str ++ "."
            | otherwise = either (return . Left) ((>> return (Right venv)) . print . eta venv . fst) (parseTerm toks)

loadList :: [String] -> String -> Venv -> IO (Either String Venv)
-- | Reads a list of assignments followed by a single application and saves it to the virtual environment.
loadList [] f venv = loadTerm f False venv
loadList (eq : eqs) f venv = do
            venv' <- loadTerm eq True venv
            either (return . Left) (loadList eqs f) venv'

loop :: Venv -> Either String Venv -> IO ()
-- | Updates a REPL's environment or gives an error and continues the REPL on the old environment.
loop venv = either (\msg -> putStrLn msg >> repl venv) repl

repl :: Venv -> IO ()
-- | Starts a lambda calculus read-eval-print loop.
repl venv = do
    putStr "lc> " >> hFlush stdout
    line <- getLine
    unless (line == ":q") $ do
        let (heads, last) = fromMaybe ([], "") $ unsnoc (prelex line)
        venv' <- loadList heads last venv
        loop venv venv'

main :: IO ()
main = do
    hSetBuffering stdin LineBuffering
    args <- getArgs
    case args of
        [file] -> do
            code <- readFile file
            venv <- loadList (concatMap prelex $ lines code) "" []
            loop [] venv
        [] -> repl []
        _  -> putStrLn "Usage: ./runlc [file]"
