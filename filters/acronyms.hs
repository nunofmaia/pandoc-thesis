#!/usr/bin/env runhaskell

import Text.Pandoc.JSON
import Data.IORef

main :: IO ()
main = do
  usedRef <- newIORef False
  toJSONFilter $ acronym usedRef

acronym :: IORef Bool -> Inline -> IO Inline
acronym usedRef (Link [Str abbrev] ("acro:", expansion)) = do
  used <- readIORef usedRef
  if used
     then return $ Str abbrev
     else do
       writeIORef usedRef True
       return $ Str $ abbrev ++ " (" ++ expansion ++ ")"
acronym _ x = return x