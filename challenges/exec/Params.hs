{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards       #-}

module Params where

import Common (ChallengeID, InstanceID)

import Control.Applicative  hiding ((<|>))
import Control.Monad.Except
import Data.Int
import Prelude              hiding (lex)
import Text.Parsec
import Text.Parsec.Token

-- | Information to generate a challenge.
data ChallengeParams =
    C { challID :: ChallengeID, m :: Int32, q :: Int64, svar :: Double, numSamples :: Int32,
        numInstances :: InstanceID, eps :: Double, annotation :: String }
  | D { challID :: ChallengeID, m :: Int32, q :: Int64, svar :: Double, numSamples :: Int32,
        numInstances :: InstanceID, eps :: Double, annotation :: String }
  | R { challID :: ChallengeID, m :: Int32, q :: Int64, p :: Int64, numSamples :: Int32,
        numInstances :: InstanceID, annotation :: String }
  deriving (Show)

contLineID, discLineID, rlwrLineID :: String
contLineID = "Cont"
discLineID = "Disc"
rlwrLineID = "RLWR"

-- default probability eps to use
epsDef :: Double
epsDef = 2 ** (-25)

lang :: (Stream s m Char) => GenLanguageDef s u m
lang = LanguageDef
  {commentStart = "/*",
   commentEnd = "*/",
   commentLine = "--",
   nestedComments = True,
   identStart = letter,
   identLetter = letter,
   opStart = letter,
   opLetter = letter,
   reservedNames = [],
   reservedOpNames = [],
   caseSensitive = True}

-- applies `p` zero or more times, stopping when it reaches EOF
-- if an error occurs, it stops parsing and reports the error
manyError :: (Stream s m Char) => ParsecT s u m a -> ParsecT s u m [a]
manyError p = try (eof *> return []) <|> liftA2 (:) p (manyError p)

lex :: (Stream s m Char) => ParsecT s u m a -> ParsecT s u m a
lex = lexeme langParser

langParser :: (Stream s m Char) => GenTokenParser s u m
langParser = makeTokenParser lang

parseIntegral :: (Integral i, Stream s m Char) => ParsecT s u m i
parseIntegral = fromIntegral <$> lex (natural langParser)

parseDouble :: (Stream s m Char) => ParsecT s u m Double
parseDouble = lex $ float langParser

parseString :: (Stream s m Char) => ParsecT s u m String
parseString = lex $ stringLiteral langParser

parseWord ::  (Stream s m Char) => String -> ParsecT s u m ()
parseWord = lex . void . try . string

paramsFile :: (MonadError String m, Stream s m Char) => ParsecT s InstanceID m [ChallengeParams]
paramsFile = do
  whiteSpace langParser -- skip leading whitespace
  manyError line

line :: (MonadError String m, Stream s m Char) => ParsecT s InstanceID m ChallengeParams
line = try rlwecParams <|> try rlwedParams <|> try rlwrParams <?> "Expected one of '" ++
  show contLineID ++ "', '" ++
  show discLineID ++ "', or '" ++
  show rlwrLineID ++ "'."

rlwecParams, rlwedParams, rlwrParams ::
  (MonadError String m, Stream s m Char) => ParsecT s InstanceID m ChallengeParams
rlwecParams = do
  challID <- parseIntegral
  parseWord contLineID
  m <- parseIntegral
  q <- parseIntegral
  svar <- parseDouble
  numSamples <- parseIntegral
  annotation <- parseString

  numInstances <- getState
  let eps = epsDef
  return C{..}

rlwedParams = do
  challID <- parseIntegral
  parseWord discLineID
  m <- parseIntegral
  q <- parseIntegral
  svar <- parseDouble
  numSamples <- parseIntegral
  annotation <- parseString

  numInstances <- getState
  let eps = epsDef
  return D{..}

rlwrParams = do
  challID <- parseIntegral
  parseWord rlwrLineID
  m <- parseIntegral
  q <- parseIntegral
  p <- parseIntegral
  numSamples <- parseIntegral
  annotation <- parseString

  numInstances <- getState
  when (p > q) $ throwError $
    "Expected p <= q; parsed q=" ++ show q ++ " and p=" ++ show p
  return R{..}

parseChallParams :: String -> InstanceID -> [ChallengeParams]
parseChallParams input numInsts = do
  let output = runExcept $ runParserT paramsFile numInsts "" input
  case output of
    Left e -> error $ "Invalid parameters: " ++ e
    Right r -> case r of
      Left e -> error $ "Error parsing input:" ++ show e
      Right v -> v
