module Main where

import Build_doctests (Component (..), components)
import Data.Foldable (for_)
import System.Environment (unsetEnv)
import Test.DocTest (doctest)

main :: IO ()
main = do
  for_ components print
  for_ components $ \(Component _name flags pkgs sources) -> do
    unsetEnv "GHC_ENVIRONMENT"
    doctest $ flags ++ pkgs ++ sources
