module Main where

import AST
import Parser
import Control.Monad (guard, foldM)
import System.Environment (getArgs)
import GHC.IO.Handle (hFlush, hSetBuffering, BufferMode (LineBuffering))
import GHC.IO.Handle.FD (stdout, stdin)

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
            | isAssignment -> error "Invalid assignment."
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
        _  -> putStrLn "Usage: runlc [file]"
