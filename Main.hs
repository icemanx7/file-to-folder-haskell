{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (join)
import Data.Maybe
import System.Directory
  ( createDirectory,
    listDirectory,
    renameFile,
  )
import System.Environment
import System.FilePath.Posix

rmdups ::
  Eq a =>
  [a] ->
  [a]
rmdups [] = []
rmdups (x : xs)
  | x `elem` xs = rmdups xs
  | otherwise = x : rmdups xs

data ArgResult = Error | Result String

filePaths :: String -> IO [FilePath]
filePaths = listDirectory

getBase :: [FilePath] -> [String]
getBase = map takeBaseName

mkDir :: String -> String -> String
mkDir baseP file = baseP ++ "/" ++ file

getNewPath :: [FilePath] -> [String] -> [FilePath]
getNewPath = zipWith replaceDirectory

createNewDir :: [FilePath] -> IO ()
createNewDir = mapM_ createDirectory

moveFiles :: [FilePath] -> [FilePath] -> IO ()
moveFiles f a = mapM_ (uncurry renameFile) $ zip f a

handleInvalidArguments :: Maybe String -> ArgResult
handleInvalidArguments = maybe Error Result

getSourceDirectory :: IO (Maybe String)
getSourceDirectory = do
  arg <- getArgs
  let s = listToMaybe arg
  pure s

bearFiles :: ArgResult -> IO ()
bearFiles (Result str) = do
  file <- filePaths str
  let mkDirF = mkDir str
  let base = getBase file
  let newDir = map mkDirF base
  let old = map mkDirF file
  let newW = rmdups newDir
  r <- createNewDir newW
  let final = getNewPath file newDir
  join return (moveFiles old final)
bearFiles Error = putStrLn "Broken"

main :: IO ()
main = do
  src <- getSourceDirectory
  let args = handleInvalidArguments src
  bearFiles args
