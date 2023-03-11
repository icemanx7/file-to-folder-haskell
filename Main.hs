{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (join)
import Data.Maybe (listToMaybe)
import System.Directory (
  createDirectory,
  listDirectory,
  renameFile,
 )
import System.Environment (getArgs)
import System.FilePath.Posix (replaceDirectory, takeBaseName)
import Types (ArgResult (Error, Result), BasePathToName (BasePathToName))

removeDuplicates ::
  Eq a =>
  [a] ->
  [a]
removeDuplicates [] = []
removeDuplicates (x : xs)
  | x `elem` xs = removeDuplicates xs
  | otherwise = x : removeDuplicates xs

filePaths :: BasePathToName -> IO [FilePath]
filePaths (BasePathToName path) = listDirectory path

getBaseDirectory :: [FilePath] -> [String]
getBaseDirectory = map takeBaseName

makeDirectory :: BasePathToName -> String -> String
makeDirectory (BasePathToName basePath) file = basePath ++ "/" ++ file

getNewPath :: [FilePath] -> [String] -> [FilePath]
getNewPath = zipWith replaceDirectory

createNewDir :: [FilePath] -> IO ()
createNewDir = mapM_ createDirectory

moveFiles :: [FilePath] -> [FilePath] -> IO ()
moveFiles f a = mapM_ (uncurry renameFile) $ zip f a

handleInvalidArguments :: Maybe String -> ArgResult
handleInvalidArguments m = case m of
  Just str -> Result (BasePathToName str)
  Nothing -> Error

getSourceDirectory :: IO (Maybe String)
getSourceDirectory = do
  arg <- getArgs
  let s = listToMaybe arg
  pure s

bearFiles :: ArgResult -> IO ()
bearFiles (Result str) = do
  file <- filePaths str
  let mkDirF = makeDirectory str
  let base = getBaseDirectory file
  let newDir = map mkDirF base
  let old = map mkDirF file
  let newW = removeDuplicates newDir
  r <- createNewDir newW
  let final = getNewPath file newDir
  join return (moveFiles old final)
bearFiles Error = putStrLn "Broken"

main :: IO ()
main = do
  src <- getSourceDirectory
  let args = handleInvalidArguments src
  bearFiles args
