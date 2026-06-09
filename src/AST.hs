module AST where

data Term = Var String 
    | Abs String Term
    | App Term Term

instance Show Term where
    show (Var name) = name
    show (Abs arg body) = "\\" ++ arg ++ ". " ++ show body
    show (App t1 t2) = "(" ++ show t1 ++ " " ++ show t2 ++ ")"

type Venv = [(String, Term)]

eval :: Venv -> Term -> Term 
-- | Evaluates a term and returns the result.
eval v (Var name) = case lookup name v of
        Just t -> eval v t
        Nothing -> Var name
eval v (Abs arg body) = Abs arg body
eval v (App t1 t2) = case eval v t1 of
        Abs arg body -> eval v $ reduce arg body t2
        term -> App term $ eval v t2
        
isFree :: String -> Term -> Bool
-- | Returns True if a variable is free in a term, otherwise returns False.
isFree x (Var name) = x == name 
isFree x (Abs arg body)
    | x == arg = False
    | otherwise = isFree x body
isFree x (App t1 t2) = isFree x t1 || isFree x t2

reduce :: String -> Term -> Term -> Term
-- | Substitudes a variable everywhere in a term with a different (input) term and returns the result.
reduce arg (Var name) input
    | arg == name = input
    | otherwise = Var name
reduce arg1 (Abs arg2 body) input
    | arg1 == arg2 = Abs arg2 body
    | isFree arg2 input = let arg2' = arg2 ++ "'" in Abs arg2' $ reduce arg1 (reduce arg2 body $ Var arg2') input  
    | otherwise = Abs arg2 $ reduce arg1 body input
reduce arg (App t1 t2) input = App (reduce arg t1 input) (reduce arg t2 input)

eta :: Venv -> Term -> Term
-- | Eta reduces a term after evaluation.
eta v t = case eval v t of
    Var name -> Var name 
    App t1 t2 -> App (eta v t1) (eta v t2)
    Abs arg body -> case eta (filter (\(x, _) -> x /= arg) v) body of
        App f (Var x) | x == arg && not (isFree x f) -> f
        body' -> Abs arg body'
