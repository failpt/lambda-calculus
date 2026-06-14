{- HLINT ignore "Use infix" -}
module Evaluator where
import Data.List (delete, union)

data Term = Var String 
    | Abs String Term
    | App Term Term

instance Show Term where
    show (Var name) = name
    show (Abs arg body) = "\\" ++ arg ++ ". " ++ show body
    show (App l (Var name)) = show l ++ " " ++ name
    show (App l r) = show l ++ " (" ++ show r ++ ")"

type Venv = [(String, Term)]

eval :: Venv -> Term -> Term 
-- | Evaluates a term and returns the result.
eval v (Var name) = case lookup name v of
        Just t -> eval v t
        Nothing -> Var name
eval v (Abs arg body) = Abs arg body
eval v (App l r) = case eval v l of
        Abs arg body -> eval v $ reduce arg body r
        term -> App term $ eval v r

reduce :: String -> Term -> Term -> Term
-- | Substitutes a variable everywhere in a term with a different (input) term and returns the result.
reduce x term input = go term where
    go (Var name)
        | x == name = input
        | otherwise = Var name
    go (Abs arg body)
        | x == arg = Abs arg body
        | elem arg inputFrees = let arg' = rename arg $ union inputFrees $ frees body in 
            Abs arg' $ go (reduce arg body $ Var arg')
        | otherwise = Abs arg $ go body
    go (App l r) = App (go l) (go r)
    
    inputFrees = frees input
    frees :: Term -> [String]
    frees (Var name) = [name]
    frees (Abs arg body) = delete arg $ frees body
    frees (App l r) = union (frees l) (frees r)

    rename :: String -> [String] -> String
    rename x taken
        | elem x' taken = rename (x' ++ "'") taken
        | otherwise = x'
        where x' = x ++ "'"

eta :: Venv -> Term -> Term
-- | Eta reduces a term after evaluation.
eta v t = case eval v t of
    Var name -> Var name 
    App l r -> App (eta v l) (eta v r)
    Abs arg body -> case eta (filter (\(x, _) -> x /= arg) v) body of
        App f (Var x) | x == arg && not (isFree x f) -> f
        body' -> Abs arg body'
    where 
        isFree :: String -> Term -> Bool
        isFree x (Var name) = x == name 
        isFree x (Abs arg body) = x /= arg && isFree x body
        isFree x (App l r) = isFree x l || isFree x r