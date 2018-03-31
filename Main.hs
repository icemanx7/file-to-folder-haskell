{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Maybe
import System.Directory
import System.FilePath.Posix

rmdups
  :: Eq a
  => [a] -> [a]
rmdups [] = []
rmdups (x:xs)
  | x `elem` xs = rmdups xs
  | otherwise = x : rmdups xs

basePath :: String
basePath = "/run/media/icemanx7/Media/MoviesUnfiltered/"

filePaths :: IO [FilePath]
filePaths = listDirectory basePath

getBase :: [FilePath] -> [String]
getBase files = map takeBaseName files

mkDir :: String -> String
mkDir file = basePath ++ "/" ++ file

getNewPath :: [FilePath] -> [String] -> [FilePath]
getNewPath f b = zipWith replaceDirectory f b

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
  let newW = (rmdups newDir)
  r <- createNewDir newW
  let final = getNewPath file newDir
  return (moveFiles old final)

main = do
  final <- bearFiles
  final
