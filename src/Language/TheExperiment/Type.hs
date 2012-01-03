{-#Language DeriveFunctor
          , DeriveFoldable
          , DeriveTraversable
          #-}
module Language.TheExperiment.Type where

import Data.Foldable
import Data.Traversable

data StdType = Char8 | Char16 | IntType IntType | SBool | F32 | F64
    deriving (Show, Eq, Ord)

data IntType = Int8 | UInt8 | Int16 | UInt16 | Int32 | UInt32 | Int64 | UInt64
    deriving (Show, Eq, Ord, Bounded, Enum)

isValidInt :: IntType -> Integer -> Bool
isValidInt t n | n >= minValue t && n <= maxValue t = True
isValidInt _ _ = False

maxValue :: IntType -> Integer
maxValue Int8 = 2^(7 :: Integer) - 1
maxValue UInt8 = 2^(8 :: Integer) - 1
maxValue Int16 = 2^(15 :: Integer) -1
maxValue UInt16 = 2^(16 :: Integer) - 1
maxValue Int32 = 2^(31 :: Integer) - 1
maxValue UInt32 = 2^(32 :: Integer) - 1
maxValue Int64 = 2^(63 :: Integer) - 1
maxValue UInt64 = 2^(64 :: Integer) - 1

minValue :: IntType -> Integer
minValue Int8 = -2^(7 :: Integer)
minValue UInt8 = 0
minValue Int16 = -2^(15 :: Integer)
minValue UInt16 = 0
minValue Int32 = -2^(31 :: Integer)
minValue UInt32 = 0
minValue Int64 = -2^(63 :: Integer)
minValue UInt64 = 0

data MonoType a = TypeName String
                | Std StdType
                | Array a a -- first parameter should only be a type variable or a NType (type level number), eventually this would be moved to the std libs, and have a constraint on that parameter
                | NType Integer
                {-
                | Pointer a
                | AlgType [(String, a)]
                | Array (Maybe Integer) a
                | TCall a [a]
                | Struct [(String, a)]
                | Union [(String, a)]
                | NType Integer
                | Func [a] a
                -}
    deriving (Show, Eq, Ord, Functor, Foldable, Traversable)


data PolyType a = MonoType (MonoType a)
                | Var (Maybe String) [(String, a)] (Maybe [a]) -- optional name, list of record fields and their types (empty for non-structures), Just overloads
    deriving (Show, Eq, Ord, Functor, Foldable, Traversable)

newtype FlatMonoType = FlatMonoType (MonoType FlatMonoType)
    deriving (Show, Eq, Ord)

--flatType :: (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType FlatMonoType))))))))))) -> FlatMonoType
flatType :: MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType (MonoType FlatMonoType)))))))))))))))) -> FlatMonoType
flatType a = FlatMonoType $ (f $ f $ f $ f $ f $ f $ f $ f $ f $ f $ f $ f $ f $ f $ f $ fmap FlatMonoType) a
    where
        f g = fmap (FlatMonoType . g) 

-- x = fmap (FlatMonoType . (fmap (FlatMonoType . (fmap FlatMonoType))))
