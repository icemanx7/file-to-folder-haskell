{-# LANGUAGE OverloadedStrings #-}

module Main where

import System.Directory
import System.FilePath.Posix

-- basePath :: String
basePath = "/tmp/Files"

filePaths = listDirectory basePath

getBase files = map takeBaseName files

mkDir file = basePath ++ "/" ++ file

getNewPath f b = map (\(x, y) -> replaceDirectory x y) $ zip f b

createNewDir a = mapM createDirectory a

moveFiles f a = mapM_ (\(x, y) -> renameFile x y) $ zip f a

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
