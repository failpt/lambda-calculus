module Evaluator where

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
        
isFree :: String -> Term -> Bool
-- | Returns True if a variable is free in a term, otherwise returns False.
isFree x (Var name) = x == name 
isFree x (Abs arg body) = x /= arg && isFree x body
isFree x (App l r) = isFree x l || isFree x r

reduce :: String -> Term -> Term -> Term
-- | Substitudes a variable everywhere in a term with a different (input) term and returns the result.
reduce x (Var name) t
    | x == name = t
    | otherwise = Var name
reduce x (Abs arg body) t
    | x == arg = Abs arg body
    | isFree arg t = let arg' = arg ++ "'" in Abs arg' $ reduce arg (reduce arg body $ Var arg') t  
    | otherwise = Abs arg $ reduce x body t
reduce x (App l r) t = App (reduce x l t) (reduce x r t)

eta :: Venv -> Term -> Term
-- | Eta reduces a term after evaluation.
eta v t = case eval v t of
    Var name -> Var name 
    App l r -> App (eta v l) (eta v r)
    Abs arg body -> case eta (filter (\(x, _) -> x /= arg) v) body of
        App f (Var x) | x == arg && not (isFree x f) -> f
        body' -> Abs arg body'