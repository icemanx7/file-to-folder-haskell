module Types (BasePathToName (..), ArgResult (..)) where

data ArgResult = Error | Result BasePathToName

newtype BasePathToName = BasePathToName String