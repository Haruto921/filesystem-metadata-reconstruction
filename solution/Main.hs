{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Data.Aeson as Aeson
import qualified Data.ByteString.Lazy as BL
import qualified Data.Map.Strict as Map
import System.Directory (listDirectory, doesFileExist)
import System.FilePath ((</>))
import Control.Exception (try, IOException)
import Text.Read (readMaybe)

-- Metadata types for filesystem reconstruction
data FileMetadata = FileMetadata
    { fmName     :: FilePath
    , fmSize     :: Integer
    , fmType     :: FileType
    , fmChecksum :: Maybe String
    } deriving (Show, Eq)

data FileType = RegularFile | Directory | Symlink
    deriving (Show, Eq)

instance Aeson.ToJSON FileMetadata where
    toJSON fm = Aeson.object
        [ "name" Aeson..= fmName fm
        , "size" Aeson..= fmSize fm
        , "type" Aeson..= fileTypeToString (fmType fm)
        , "checksum" Aeson..= fmChecksum fm
        ]

fileTypeToString :: FileType -> String
fileTypeToString RegularFile = "file"
fileTypeToString Directory   = "directory"
fileTypeToString Symlink     = "symlink"

-- Parse archive metadata from JSON
parseArchiveMetadata :: BL.ByteString -> Either String [FileMetadata]
parseArchiveMetadata bs = case Aeson.eitherDecode bs of
    Left err  -> Left $ "JSON parse error: " ++ err
    Right arr -> Right arr

-- Reconstruct filesystem structure from metadata
reconstructFilesystem :: [FileMetadata] -> Map.Map FilePath FileMetadata
reconstructFilesystem = Map.fromList . map (\fm -> (fmName fm, fm))

-- Validate metadata consistency
validateMetadata :: [FileMetadata] -> [String]
validateMetadata metas = concatMap validateSingle metas
  where
    validateSingle :: FileMetadata -> [String]
    validateSingle fm
        | null (fmName fm) = ["Empty filename detected"]
        | fmSize fm < 0    = ["Negative size for: " ++ fmName fm]
        | otherwise        = []

-- Main oracle function: reconstruct and validate
main :: IO ()
main = do
    putStrLn "Filesystem Metadata Reconstruction Oracle"
    putStrLn "==========================================="
    
    -- Read metadata files from data/metadata directory
    metadataDir <- listDirectory "data/metadata"
    let metadataFiles = filter (\f -> ".json" `isSuffixOf` f) metadataDir
    
    if null metadataFiles
        then putStrLn "No metadata files found in data/metadata/"
        else do
            putStrLn $ "Found " ++ show (length metadataFiles) ++ " metadata file(s)"
            
            -- Process each metadata file
            mapM_ processMetadataFile metadataFiles
            
            putStrLn "\nReconstruction complete."

processMetadataFile :: FilePath -> IO ()
processMetadataFile filename = do
    let filepath = "data/metadata" </> filename
    putStrLn $ "\nProcessing: " ++ filename
    
    result <- try @IOException (BL.readFile filepath)
    case result of
        Left e -> putStrLn $ "Error reading file: " ++ show e
        Right content -> do
            case parseArchiveMetadata content of
                Left err -> putStrLn $ "Parse error: " ++ err
                Right metas -> do
                    let validationErrors = validateMetadata metas
                    if null validationErrors
                        then do
                            putStrLn $ "  Validated " ++ show (length metas) ++ " entries"
                            let fsMap = reconstructFilesystem metas
                            putStrLn $ "  Reconstructed filesystem with " ++ show (Map.size fsMap) ++ " entries"
                        else do
                            putStrLn "  Validation errors:"
                            mapM_ (putStrLn . ("    " ++)) validationErrors

isSuffixOf :: String -> String -> Bool
isSuffixOf needle haystack = 
    let needleLen = length needle
        hayLen = length haystack
    in needleLen <= hayLen && drop (hayLen - needleLen) haystack == needle
