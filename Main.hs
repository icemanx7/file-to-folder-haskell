{-# LANGUAGE OverloadedStrings #-}

module Main where

import System.Directory
import System.FilePath.Posix

-- basePath :: String
basePath = "/tmp/Files"

filePaths :: IO [FilePath]
filePaths = listDirectory basePath

getBase :: [FilePath] -> [String]
getBase files = map takeBaseName files

mkDir :: String -> String
mkDir file = basePath ++ "/" ++ file

getNewPath :: [FilePath] -> [String] -> [FilePath]
getNewPath f b = map (\(x, y) -> replaceDirectory x y) $ zip f b

createNewDir :: [FilePath] -> IO [()]
createNewDir a = mapM createDirectory a

moveFiles :: [FilePath] -> [FilePath] -> IO ()
moveFiles f a = mapM_ (\(x, y) -> renameFile x y) $ zip f a

bearFiles :: IO (IO ())
bearFiles = do
  file <- filePaths
  let base = getBase file
  let newDir = map mkDir base
  let old = map mkDir file
  r <- createNewDir newDir
  let final = getNewPath file newDir
  return (moveFiles old final)

main = do
  final <- bearFiles
  final
