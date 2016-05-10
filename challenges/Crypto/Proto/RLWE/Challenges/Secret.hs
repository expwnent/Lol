{-# LANGUAGE BangPatterns, DeriveDataTypeable, DeriveGeneric, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC  -fno-warn-unused-imports #-}
module Crypto.Proto.RLWE.Challenges.Secret (Secret(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified GHC.Generics as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Crypto.Proto.RLWE.Rq as RLWE (Rq)

data Secret = Secret{challengeID :: !(P'.Int32), instanceID :: !(P'.Int32), m :: !(P'.Int32), qs :: !(P'.Seq P'.Int64),
                     s :: !(RLWE.Rq)}
            deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data, Prelude'.Generic)

instance P'.Mergeable Secret where
  mergeAppend (Secret x'1 x'2 x'3 x'4 x'5) (Secret y'1 y'2 y'3 y'4 y'5)
   = Secret (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3) (P'.mergeAppend x'4 y'4)
      (P'.mergeAppend x'5 y'5)

instance P'.Default Secret where
  defaultValue = Secret P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue

instance P'.Wire Secret where
  wireSize ft' self'@(Secret x'1 x'2 x'3 x'4 x'5)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size
         = (P'.wireSizeReq 1 5 x'1 + P'.wireSizeReq 1 5 x'2 + P'.wireSizeReq 1 5 x'3 + P'.wireSizeRep 1 3 x'4 +
             P'.wireSizeReq 1 11 x'5)
  wirePut ft' self'@(Secret x'1 x'2 x'3 x'4 x'5)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutReq 8 5 x'1
             P'.wirePutReq 16 5 x'2
             P'.wirePutReq 24 5 x'3
             P'.wirePutRep 32 3 x'4
             P'.wirePutReq 42 11 x'5
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             8 -> Prelude'.fmap (\ !new'Field -> old'Self{challengeID = new'Field}) (P'.wireGet 5)
             16 -> Prelude'.fmap (\ !new'Field -> old'Self{instanceID = new'Field}) (P'.wireGet 5)
             24 -> Prelude'.fmap (\ !new'Field -> old'Self{m = new'Field}) (P'.wireGet 5)
             32 -> Prelude'.fmap (\ !new'Field -> old'Self{qs = P'.append (qs old'Self) new'Field}) (P'.wireGet 3)
             34 -> Prelude'.fmap (\ !new'Field -> old'Self{qs = P'.mergeAppend (qs old'Self) new'Field}) (P'.wireGetPacked 3)
             42 -> Prelude'.fmap (\ !new'Field -> old'Self{s = P'.mergeAppend (s old'Self) (new'Field)}) (P'.wireGet 11)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self

instance P'.MessageAPI msg' (msg' -> Secret) Secret where
  getVal m' f' = f' m'

instance P'.GPB Secret

instance P'.ReflectDescriptor Secret where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [8, 16, 24, 42]) (P'.fromDistinctAscList [8, 16, 24, 32, 34, 42])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Challenges.Secret\", haskellPrefix = [MName \"Crypto\",MName \"Proto\",MName \"RLWE\"], parentModule = [MName \"Challenges\"], baseName = MName \"Secret\"}, descFilePath = [\"Crypto\",\"Proto\",\"RLWE\",\"Challenges\",\"Secret.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Challenges.Secret.challengeID\", haskellPrefix' = [MName \"Crypto\",MName \"Proto\",MName \"RLWE\"], parentModule' = [MName \"Challenges\",MName \"Secret\"], baseName' = FName \"challengeID\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 8}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 5}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Challenges.Secret.instanceID\", haskellPrefix' = [MName \"Crypto\",MName \"Proto\",MName \"RLWE\"], parentModule' = [MName \"Challenges\",MName \"Secret\"], baseName' = FName \"instanceID\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 16}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 5}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Challenges.Secret.m\", haskellPrefix' = [MName \"Crypto\",MName \"Proto\",MName \"RLWE\"], parentModule' = [MName \"Challenges\",MName \"Secret\"], baseName' = FName \"m\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 24}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 5}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Challenges.Secret.qs\", haskellPrefix' = [MName \"Crypto\",MName \"Proto\",MName \"RLWE\"], parentModule' = [MName \"Challenges\",MName \"Secret\"], baseName' = FName \"qs\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 32}, packedTag = Just (WireTag {getWireTag = 32},WireTag {getWireTag = 34}), wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = True, typeCode = FieldType {getFieldType = 3}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Challenges.Secret.s\", haskellPrefix' = [MName \"Crypto\",MName \"Proto\",MName \"RLWE\"], parentModule' = [MName \"Challenges\",MName \"Secret\"], baseName' = FName \"s\", baseNamePrefix' = \"\"}, fieldNumber = FieldId {getFieldId = 5}, wireTag = WireTag {getWireTag = 42}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".RLWE.Rq\", haskellPrefix = [MName \"Crypto\",MName \"Proto\"], parentModule = [MName \"RLWE\"], baseName = MName \"Rq\"}), hsRawDefault = Nothing, hsDefault = Nothing}], descOneofs = fromList [], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False, makeLenses = False}"

instance P'.TextType Secret where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage

instance P'.TextMsg Secret where
  textPut msg
   = do
       P'.tellT "challengeID" (challengeID msg)
       P'.tellT "instanceID" (instanceID msg)
       P'.tellT "m" (m msg)
       P'.tellT "qs" (qs msg)
       P'.tellT "s" (s msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'challengeID, parse'instanceID, parse'm, parse'qs, parse's]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'challengeID
         = P'.try
            (do
               v <- P'.getT "challengeID"
               Prelude'.return (\ o -> o{challengeID = v}))
        parse'instanceID
         = P'.try
            (do
               v <- P'.getT "instanceID"
               Prelude'.return (\ o -> o{instanceID = v}))
        parse'm
         = P'.try
            (do
               v <- P'.getT "m"
               Prelude'.return (\ o -> o{m = v}))
        parse'qs
         = P'.try
            (do
               v <- P'.getT "qs"
               Prelude'.return (\ o -> o{qs = P'.append (qs o) v}))
        parse's
         = P'.try
            (do
               v <- P'.getT "s"
               Prelude'.return (\ o -> o{s = v}))