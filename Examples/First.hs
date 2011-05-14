{-# LANGUAGE TypeSynonymInstances, TemplateHaskell, QuasiQuotes, MultiParamTypeClasses, FlexibleInstances, DeriveDataTypeable, ScopedTypeVariables #-}

module Examples.First where
import Language.Pads.Padsc
import Test.HUnit hiding (test)
import System.IO.Unsafe (unsafePerformIO)

--import qualified Text.Regex.ByteString as BRE


---- PADS EXAMPLES

-- Regression expects to be run from the Examples directory.
test = runTestTT tests


tests = TestList[ TestLabel "MyChar"  myChar_test
                , TestLabel "IntPair" intPair_test 
                , TestLabel "Bar"     bar_test 
                , TestLabel "Bar2"    bar2_test 
                , TestLabel "Bazr"    bazr_test 
                , TestLabel "MyInt"   myInt_test 
                , TestLabel "StrTy"   strTy_test 
                , TestLabel "StrTy1"  strTy1_test 
                , TestLabel "Baz"     baz_test 
--                , TestLabel "Phex32FW"  phex32FW_test 
                ---- Add cases for regular expressions
                , TestLabel "IntRange" test_intRange24
                , TestLabel "IntRange" test_intRange0
                , TestLabel "IntRange" test_intRange256
                , TestLabel "IntRange" test_intRangeLow
                , TestLabel "IntRange" test_intRangeHigh
                , TestLabel "IntRange" test_intRangeBad
                , TestLabel "IntRangeP" test_intRangeP24
                , TestLabel "IntRangeP" test_intRangeP0
                , TestLabel "IntRangeP" test_intRangeP256
                , TestLabel "IntRangeP" test_intRangePLow
                , TestLabel "IntRangeP" test_intRangePHigh
                , TestLabel "IntRangeP" test_intRangePBad
                , TestLabel "Record" test_Record
                , TestLabel "Id" test_IdInt
                , TestLabel "Id" test_IdStr
                , TestLabel "Id" test_IdInt2
                , TestLabel "Id" test_IdStr2
                , TestLabel "Id3" test_IdInt3
                , TestLabel "Id3" test_IdLit3
                , TestLabel "Ab_or_a" test_Ab_or_a
                , TestLabel "AB_test" test_AB_test1
                , TestLabel "AB_test" test_AB_test2
                , TestLabel "Method" test_method_get
                , TestLabel "Method" test_method_put
                , TestLabel "Method" test_method_link
                , TestLabel "Method" test_method_post
                , TestLabel "Version" test_version
                , TestLabel "Request" test_request_G
                , TestLabel "Request" test_request_B
                , TestLabel "Eor" test_eor_test
                , TestLabel "Eof" test_eof_test_G
                , TestLabel "Eof" test_eof_test_B
--                , TestLabel "Opt" test_opt_test_j
--                , TestLabel "Opt" test_opt_test_n
                , TestLabel "List" test_entries_nosep_noterm
                , TestLabel "List" test_entries_nosep_noterm'
                , TestLabel "List" test_entries_nosep_noterm2
                , TestLabel "List" test_evenInt
                , TestLabel "List" test_evenInts
                , TestLabel "List" test_digitListG
                , TestLabel "List" test_digitList2G
                , TestLabel "List" test_digitListB
                , TestLabel "List" test_digitListLenG
                , TestLabel "List" test_digitListLenB
                , TestLabel "List" test_digitListLenSepG
                , TestLabel "List" test_digitListLenSepB
                , TestLabel "List" test_digitListTermG
                , TestLabel "List" test_digitListTermB
                , TestLabel "List" test_digitListTermSepG
                , TestLabel "List" test_digitListTermSepB
                , TestLabel "Try"  test_tryTest
                , TestLabel "Try"  test_tryTestDG
                , TestLabel "Try"  test_tryTestDB
                , TestLabel "Try"  test_ListWithTry
                , TestLabel "Void" test_WithVoid
                , TestLabel "Void" test_voidEntry1
                , TestLabel "Void" test_voidEntry2
                , TestLabel "Void" test_voidEntry3
                , TestLabel "Switch" test_switch0
                , TestLabel "Switch" test_switch1
                , TestLabel "Switch" test_switchOther
                , TestLabel "Stringln" test_stringln
                , TestLabel "Compound" test_myData
                , TestLabel "Compound" test_hp_data
                , TestLabel "Doc"  test_hp_data_file_parse
                , TestLabel "Doc"  myDoc_test
                , TestLabel "Literal"  litRec_test
                , TestLabel "Literal"  whiteSpace_test
                , TestLabel "Literal"  whiteSpace2_test
                , TestLabel "Regular Expression"  rE_ty_test
                ]

getTotalErrors :: PadsMD md => md -> Int
getTotalErrors md = numErrors $ get_md_header md
mdToError ((rep,md), residual) = (rep, getTotalErrors md, residual)
mkTestCase s expected seen = TestCase(assertEqual s expected  (mdToError seen))

mdFileToError (rep,md) = (rep, getTotalErrors md)
mkFileTestCase s expected seen = TestCase(assertEqual s expected (mdFileToError seen))

[pads| type MyChar = Char |]
myChar_result = myChar_parseS "ab"
myChar_expects = ('a', 0,"b")
myChar_test = mkTestCase "myChar" myChar_expects myChar_result

[pads| type IntPair = (Int, '|', Int) |]
intPair_result = intPair_parseS "12|23"
intPair_expects =  ((12,23), 0,"")
intPair_test = mkTestCase "intPair" intPair_expects intPair_result

[pads| type Bar = (Int, ',', IntPair, ';', Int) |]            -- reference to another named type
bar_result  = bar_parseS "256,12|23;456:"
bar_expects =  ((256, (12, 23), 456), 0, ":")
bar_test = mkTestCase "bar" bar_expects bar_result

[pads| type Bar2 = (Int, ',', (Int,':',Int), ';', Int) |]   -- nested tuple type.
bar2_result  = bar2_parseS "56,23:46;29"
bar2_expects = ((56,(23,46),29), 0 ,"")
bar2_test    = mkTestCase "bar2" bar2_expects bar2_result

[pads| type BazR = Line (Int, ',', Int) |]                  -- type that consumes a line boundary.
bazr_result = bazR_parseS "33,33\n"
bazr_expects = ((33,33),0,"")
bazr_test    = mkTestCase "bazr" bazr_expects bazr_result

[pads| type MyInt = Int |]                                     -- Integer base type
myInt_result  = myInt_parseS "23"
myInt_expects = (23,0,"")
myInt_test    = mkTestCase "myInt" myInt_expects myInt_result


{- String base types -}
testStrLen = 2
computeLen x = x - 1
[pads| type StrTy = StringFW <| testStrLen + (computeLen 4) |> |]
inputStrTy = "catdog"
strTy_results = strTy_parseS inputStrTy
strTy_expects = ("catdo", 0,"g")
strTy_test    = mkTestCase "strTy" strTy_expects strTy_results

[pads| type StrTy1 = StringC 'o' |]
strTy1_results = strTy1_parseS inputStrTy
strTy1_expects = ("catd",0,"og")
strTy1_test    = mkTestCase "strTy1" strTy1_expects strTy1_results

[pads| type Baz = (StringFW 3,',',Int) |]
input_baz  = "cat,123"
baz_results = baz_parseS input_baz
baz_expects = (("cat",123),0,"")
baz_test    = mkTestCase "baz" baz_expects baz_results

{- Regular expression types -}
[pads| type StrME = StringME 'a+' |]
input_strME = "aaaab"
strME_results = strME_parseS input_strME

[pads| type  StrSE = StringSE <|RE "b|c"|> |]
input_strSE_1 = "aaaab"
input_strSE_2 = "aaaac"
strSE_results_1 = strSE_parseS input_strSE_1
strSE_results_2 = strSE_parseS input_strSE_2

[pads| type  StrP1 (x::Int) = StringFW <|x - 1|> |]
input_strP1 = "abcd"
strP1_result = strP1_parseS 3 input_strP1

[pads| type  StrHex = StringME '[0-9A-Fa-f]+' |]
input_strHex = "12abcds"
strHex_result = strHex_parseS input_strHex

{- Testing for Phex32FW, which is in Pads.Language.BaseTypes
-- Add back when transforms are implemented.
input_hex32FW = "12bc34"  
phex32FW_results = phex32FW_parseS 4 input_hex32FW   
phex32FW_expects = (Phex32FW (4796), 0, "34")
phex32FW_test    = mkTestCase "phex32FW" phex32FW_expects phex32FW_results

input2_hex32FW = "00bc34"  
strhex32FW_result2 = phex32FW_parseS 4 input2_hex32FW    -- ((Phex32FW (188),Errors: 0),"34")

input3_hex32FW = "gbc34"  
strhex32FW_result3 = phex32FW_parseS 4 input3_hex32FW    -- Prints error message

[pads| type  HexPair = (Phex32FW 2, ',', Phex32FW 3) |]
input_hexpair = "aa,bbb"
hexpair_result = hexPair_parseS input_hexpair

 -}
{- Constrained types -}
[pads| type  IntRange = constrain x :: Int where <| 0 <= x && x <= 256 |> |]
intRange24_input = "24"
intRange0_input  = "0"
intRange256_input = "256"
intRangeLow_input = "-23"
intRangeHigh_input = "512"
intRangeBad_input  = "aaa"

result_intRange24 = intRange_parseS intRange24_input
expect_intRange24 = (24,0,"")
test_intRange24   =  mkTestCase "IntRange24" expect_intRange24 result_intRange24

result_intRange0  = intRange_parseS intRange0_input
expect_intRange0  = (0,0,"")
test_intRange0    = mkTestCase "IntRange0" expect_intRange0 result_intRange0

result_intRange256 = intRange_parseS intRange256_input
expect_intRange256 = (256,0,"")
test_intRange256   = mkTestCase "IntRange256" expect_intRange256 result_intRange256

result_intRangeLow = intRange_parseS intRangeLow_input
expect_intRangeLow = ((-23),1,"")
test_intRangeLow   = mkTestCase "IntRangeLow" expect_intRangeLow result_intRangeLow

result_intRangeHigh = intRange_parseS intRangeHigh_input
expect_intRangeHigh = (512,1,"")
test_intRangeHigh   = mkTestCase "IntRangeHigh" expect_intRangeHigh result_intRangeHigh

result_intRangeBad  = intRange_parseS intRangeBad_input
expect_intRangeBad  = (0,1,"aaa")
test_intRangeBad    = mkTestCase "IntRangeBad" expect_intRangeBad result_intRangeBad

{- Note that the special variable "md" is in scope in the body of the predicate. -}
{- md is the meta-data descriptor for the underyling type. -}

[pads| type  IntRangeP (low::Int, high::Int) = constrain x :: Int where <| low <= x && x <= high && (numErrors md == 0) |> |]

result_intRangeP24 = intRangeP_parseS (0, 256) intRange24_input
expect_intRangeP24 = (24,0,"")
test_intRangeP24 = mkTestCase "IntRangeP24" expect_intRangeP24 result_intRangeP24

result_intRangeP0  = intRangeP_parseS (0, 256) intRange0_input 
expect_intRangeP0 = (0,0,"")
test_intRangeP0 = mkTestCase "IntRangeP0" expect_intRangeP0 result_intRangeP0

result_intRangeP256 = intRangeP_parseS (0, 256) intRange256_input
expect_intRangeP256 = (256,0,"")
test_intRangeP256 = mkTestCase "IntRangeP256" expect_intRangeP256 result_intRangeP256

result_intRangePLow = intRangeP_parseS (0, 256) intRangeLow_input
expect_intRangePLow = ((-23), 1, "")
test_intRangePLow   = mkTestCase "IntRangePLow" expect_intRangePLow result_intRangePLow


result_intRangePHigh = intRangeP_parseS (0, 256) intRangeHigh_input
expect_intRangePHigh = (512, 1,"")
test_intRangePHigh   = mkTestCase "IntRangePHigh" expect_intRangePHigh result_intRangePHigh


result_intRangePBad  = intRangeP_parseS (0, 256) intRangeBad_input
expect_intRangePBad  = (0, 2,"aaa")
test_intRangePBad    = mkTestCase "IntRangePBad" expect_intRangePBad result_intRangePBad




[pads| data  Record (bound::Int) = Record 
                {  i1 :: Int, 
              ',', i2 :: Int where <| i1 + i2 <= bound |>   } |]

input_Record = "24,45"
result_Record = record_parseS 100 input_Record
expect_Record = (Record {i1 = 24, i2 = 45},0,"")
test_Record   = mkTestCase "Record" expect_Record result_Record

[pads| data Id =  Numeric Int
               |  Alpha   (StringC ',')  |] 

input_IdInt = "23"
result_IdInt = id_parseS input_IdInt
expect_IdInt = (Numeric 23,0,"")
test_IdInt = mkTestCase "IdInt" expect_IdInt result_IdInt

input_IdStr = "hello"
result_IdStr = id_parseS input_IdStr
expect_IdStr = (Alpha ("hello"),0,"")
test_IdStr = mkTestCase "IdAlpha" expect_IdStr result_IdStr

[pads| data Id2 (bound::Int) = 
            Numeric2 (constrain n::Int where <| n <= bound |>)
          | Alpha2   (StringC ',') |] 
input_IdInt2 = "23"
result_IdInt2 = id2_parseS 10 input_IdInt2
expect_IdInt2 =  (Alpha2 ("23"),0,"")
test_IdInt2 = mkTestCase "IdInt2" expect_IdInt2 result_IdInt2

input_IdStr2 = "hello"
result_IdStr2 = id2_parseS 10 input_IdStr2
expect_IdStr2 = (Alpha2 ("hello"),0,"")
test_IdStr2 = mkTestCase "IdAlpha2" expect_IdStr2 result_IdStr2



[pads| data Id3  = Numeric3  (IntRangeP <|(1,10)|>)
                 | Numeric3a Int
                 | Lit3     ','               |] 
input_IdInt3 = "24"
result_IdInt3 = id3_parseS input_IdInt3
expect_IdInt3 = (Numeric3a (24),0,"")
test_IdInt3 = mkTestCase "IdInt3" expect_IdInt2 result_IdInt2

input_IdLit3 = ","
result_IdLit3 = id3_parseS input_IdLit3
expect_IdLit3 = (Lit3,0,"")
test_IdLit3 = mkTestCase "IdLit3" expect_IdLit3 result_IdLit3



[pads| data Ab_or_a = AB "ab" | A "a" |]
input_AB = "ab"
result_Ab_or_a = ab_or_a_parseS input_AB
expect_Ab_or_a = (AB,0,"")
test_Ab_or_a = mkTestCase "Ab_or_a" expect_Ab_or_a result_Ab_or_a

[pads| data  AB_test = AB_test { field_AB  :: Ab_or_a , 'b'} |]
input_AB_test1 = "abb"
result_AB_test1 = aB_test_parseS input_AB_test1
expect_AB_test1 =  (AB_test {field_AB = AB},0,"")
test_AB_test1 = mkTestCase "AB_test1" expect_AB_test1 result_AB_test1

input_AB_test2 = "ab"
result_AB_test2 = aB_test_parseS input_AB_test2
--expect_AB_test2 = (AB_test {field_AB = A},0,"") -- if backtracking
expect_AB_test2 = (AB_test {field_AB = AB},1,"")
test_AB_test2 = mkTestCase "AB_test2" expect_AB_test2 result_AB_test2

[pads| data Method  = GET | PUT | LINK | UNLINK | POST  
       data Version = Version 
              {"HTTP/" 
              , major :: Int, '.'
              , minor :: Int} 
|]

checkVersion :: Method -> Version -> Bool
checkVersion method version = 
  case method of
    LINK   -> major version == 1 && minor version == 0
    UNLINK -> major version == 1 && minor version == 0
    _ -> True

[pads| data Request = Request 
             { '"',  method  :: Method       
             , ' ',  url     :: StringC ' '
             , ' ',  version :: Version where <| checkVersion method version |>
             , '"'
             }  |]

input_method_get = "GET"
result_method_get = method_parseS input_method_get
expect_method_get = (GET,0,"")
test_method_get = mkTestCase "Method_get" expect_method_get result_method_get

input_method_put = "PUT"
result_method_put = method_parseS input_method_put
expect_method_put = (PUT,0,"")
test_method_put = mkTestCase "Method_put" expect_method_put result_method_put


input_method_link = "LINK"
result_method_link = method_parseS input_method_link
expect_method_link = (LINK,0,"")
test_method_link = mkTestCase "Method_link" expect_method_link result_method_link


input_method_post = "POST"
result_method_post = method_parseS input_method_post
expect_method_post = (POST,0,"")
test_method_post = mkTestCase "Method_post" expect_method_post result_method_post


input_version = "HTTP/1.2"
result_version = version_parseS input_version
expect_version = (Version {major = 1, minor = 2},0,"")
test_version = mkTestCase "Version" expect_version result_version

input_request_G = "\"PUT /www.google.com HTTP/1.0\""
result_request_G = request_parseS input_request_G
expect_request_G = (Request {method = PUT, url = "/www.google.com", version = Version {major = 1, minor = 0}}, 0, "")
test_request_G = mkTestCase "Request_G" expect_request_G result_request_G

input_request_B = "\"LINK /www.google.com HTTP/1.3\""
result_request_B = request_parseS input_request_B
expect_request_B =  (Request {method = LINK, url = "/www.google.com", version = Version {major = 1, minor = 3}},1, "")
test_request_B = mkTestCase "Request_B" expect_request_B result_request_B

[pads| type Eor_Test = (Int, EOR, Int) |]
input_eor_test = "23\n56"
result_eor_test = eor_Test_parseS input_eor_test
expect_eor_test = ((23,56),0,"")
test_eor_test   = mkTestCase "Eor_Test" expect_eor_test result_eor_test

[pads| type Eof_Test = (Int, EOR, Int, EOF) |]
input_eof_test_G = "23\n56"
result_eof_test_G = eof_Test_parseS input_eof_test_G
expect_eof_test_G = ((23,56),0,"")
test_eof_test_G = mkTestCase "Eof_TestG" expect_eof_test_G result_eof_test_G

input_eof_test_B = "23\n56ab"
result_eof_test_B = eof_Test_parseS input_eof_test_B
expect_eof_test_B = ((23,56), 1,"ab")
test_eof_test_B = mkTestCase "Eof_TestB" expect_eof_test_B result_eof_test_B

{- Restate after Maybe is implemented 
[pads| type Opt_test = (Int, '|', Maybe Int, '|', Int) |]
input_opt_test_j = "34|35|56"
result_opt_test_j = opt_test_parseS input_opt_test_j
expect_opt_test_j = (Opt_test (34,Just (35),56),0,"")
test_opt_test_j = mkTestCase "Opt_test_j" expect_opt_test_j result_opt_test_j

input_opt_test_n = "34||56"
result_opt_test_n = opt_test_parseS input_opt_test_n
expect_opt_test_n = (Opt_test (34,Nothing,56),0,"")
test_opt_test_n = mkTestCase "Opt_test_n" expect_opt_test_n result_opt_test_n
-}       

{- LIST EXAMPLES -}

[pads| type Entries_nosep_noterm = [StringFW 3] |]
input_entries_nosep_noterm = "123456789"
result_entries_nosep_noterm = entries_nosep_noterm_parseS input_entries_nosep_noterm
expect_entries_nosep_noterm = (["123","456","789"],0,"")
test_entries_nosep_noterm = mkTestCase "NoSep_NoTerm" expect_entries_nosep_noterm result_entries_nosep_noterm

input_entries_nosep_noterm' = "1234567890"
result_entries_nosep_noterm' = entries_nosep_noterm_parseS input_entries_nosep_noterm'
expect_entries_nosep_noterm' = (["123","456","789"],0,"0")
test_entries_nosep_noterm' = mkTestCase "NoSep_NoTerm'" expect_entries_nosep_noterm' result_entries_nosep_noterm'

[pads| type Entries_nosep_noterm2 = [Char] |]
input_entries_nosep_noterm2 = ""
result_entries_nosep_noterm2 = entries_nosep_noterm2_parseS input_entries_nosep_noterm2
expect_entries_nosep_noterm2 = ([],0,"")
test_entries_nosep_noterm2 = mkTestCase "NoSep_NoTerm2" expect_entries_nosep_noterm2 result_entries_nosep_noterm2


[pads| type  EvenInt = constrain x :: Digit where <| x `mod` 2 == 0 |> 
       type  EvenInts = [EvenInt] |]
input_evenInts = "2465"
result_evenInt = evenInt_parseS input_evenInts
expect_evenInt = ( 2,0,"465")
test_evenInt = mkTestCase "EvenInt" expect_evenInt result_evenInt

result_evenInts = evenInts_parseS input_evenInts
expect_evenInts = ([2,4,6],0,"5")
test_evenInts = mkTestCase "EvenInts" expect_evenInts result_evenInts


[pads| type DigitList = [Digit | ','] |]
input_digitListG = "1,2,3"
input_digitList2G = "1,2,3|fed"
input_digitListB = "1,b,3"
result_digitListG = digitList_parseS input_digitListG
expect_digitListG = ([1,2,3],0,"")
test_digitListG = mkTestCase "DigitListG" expect_digitListG result_digitListG

result_digitList2G = digitList_parseS input_digitList2G
expect_digitList2G = ([1,2,3],0,"|fed")
test_digitList2G = mkTestCase "DigitList2G" expect_digitList2G result_digitList2G

result_digitListB = digitList_parseS input_digitListB
expect_digitListB = ([1],0,",b,3")
test_digitListB = mkTestCase "DigitListB" expect_digitListB result_digitListB

[pads| type DigitListLen (x::Int) = [Digit] length <|x + 1 |>  |]
input_digitListLenG = "123456"
input_digitListLenB = "12a456"

result_digitListLenG = digitListLen_parseS 4 input_digitListLenG
expect_digitListLenG = ([1,2,3,4,5],0,"6")
test_digitListLenG = mkTestCase "DigitListLenG" expect_digitListLenG result_digitListLenG

result_digitListLenB = digitListLen_parseS 4 input_digitListLenB
expect_digitListLenB = ([1,2,0,4,5],1 ,"6")
test_digitListLenB = mkTestCase "DigitListLenB" expect_digitListLenB result_digitListLenB


[pads| type DigitListLenSep (x::Int) = [Digit | "ab" ] length <|x + 1|>  |]
input_digitListLenSepG = "1ab2ab3ab4ab5ab6ab7ab"
input_digitListLenSepB = "1ab2ab3abDab5ab6ab7ab"
result_digitListLenSepG = digitListLenSep_parseS 4 input_digitListLenSepG
expect_digitListLenSepG = ([1,2,3,4,5],0,"ab6ab7ab")
test_digitListLenSepG = mkTestCase "DigitListLenSepG" expect_digitListLenSepG result_digitListLenSepG

result_digitListLenSepB = digitListLenSep_parseS 4 input_digitListLenSepB
expect_digitListLenSepB = ([1,2,3,0,5],1,"ab6ab7ab")
test_digitListLenSepB = mkTestCase "DigitListLenSepB" expect_digitListLenSepB result_digitListLenSepB


[pads| type DigitListTerm = [Digit] terminator EOR|]
input_digitListTermG = "12345\nhello"
result_digitListTermG = digitListTerm_parseS input_digitListTermG
expect_digitListTermG = ([1,2,3,4,5],0,"hello")
test_digitListTermG = mkTestCase "DigitListTermG" expect_digitListTermG result_digitListTermG

input_digitListTermB = "12345,h"
result_digitListTermB = digitListTerm_parseS input_digitListTermB
expect_digitListTermB = ([1,2,3,4,5,0,0],2,"")
test_digitListTermB   = mkTestCase "DigitListTermB" expect_digitListTermB result_digitListTermB

[pads| type DigitListTermSep = [Digit | '|' ] terminator ';' |]
input_digitListTermSepG = "1|2|3|4|5|6;hello"
result_digitListTermSepG = digitListTermSep_parseS input_digitListTermSepG 
expect_digitListTermSepG = ([1,2,3,4,5,6], 0,"hello")
test_digitListTermSepG = mkTestCase "digitListTermSepG" expect_digitListTermSepG result_digitListTermSepG

input_digitListTermSepB = "1|2|3|4|56;hello"
result_digitListTermSepB = digitListTermSep_parseS input_digitListTermSepB
expect_digitListTermSepB = ([1,2,3,4,5],1,"hello")
test_digitListTermSepB =   mkTestCase "digitListTermSepB" expect_digitListTermSepB result_digitListTermSepB

[pads| type TryTest = (Try Char, StringFW 3) |]
input_tryTest = "abc123"
result_tryTest = tryTest_parseS input_tryTest
expect_tryTest = (('a',"abc"),0,"123")
test_tryTest = mkTestCase "tryTest" expect_tryTest result_tryTest

[pads| type TryTestD = (Try Digit, StringFW 3) |]
input_tryTestDG = "123abc"
result_tryTestDG = tryTestD_parseS input_tryTestDG
expect_tryTestDG = ((1,"123"),0,"abc")
test_tryTestDG = mkTestCase "tryTestDG" expect_tryTestDG result_tryTestDG

input_tryTestDB = "abc123"
result_tryTestDB = tryTestD_parseS input_tryTestDB
expect_tryTestDB = ((0,"abc"),1, "123")
test_tryTestDB = mkTestCase "tryTestDB" expect_tryTestDB result_tryTestDB

{- ((TryTestD (0,"abc"),
    (Errors: 1 Encountered a when expecting Digit. at: Line: 0, Offset: 0,(Errors: 1 Encountered a when expecting Digit. at: Line: 0, Offset: 0,Errors: 0))),"123")

  XXX: we are getting a repeat error message because of change ot how errors are propogated.  Need to work on cleaning up error reporting.
-}


[pads| type ListWithTry = ([Char] terminator (Try Digit), Digit) |]
input_ListWithTry = "cat123"
result_ListWithTry = listWithTry_parseS input_ListWithTry
expect_ListWithTry = ((['c', 'a', 't'],1),0,"23")
test_ListWithTry = mkTestCase "ListWithTry" expect_ListWithTry result_ListWithTry



[pads| type WithVoid = (Char, ',', Void, '|') |]
input_WithVoid = "a,|rest"
result_WithVoid = withVoid_parseS input_WithVoid
expect_WithVoid =  ('a',0,"rest")
test_WithVoid = mkTestCase "WithVoid" expect_WithVoid result_WithVoid

[pads| data VoidOpt   = PDigit Digit | Pcolor "red" | Pnothing Void 
       type VoidEntry = (VoidOpt, StringFW 3)                    |]
input_voidEntry1 = "9abcdef"
result_voidEntry1 = voidEntry_parseS input_voidEntry1
expect_voidEntry1 = ((PDigit 9,"abc"),0,"def")
test_voidEntry1 = mkTestCase "VoidEntry1" expect_voidEntry1 result_voidEntry1

input_voidEntry2 = "redabcdef"
result_voidEntry2 = voidEntry_parseS input_voidEntry2
expect_voidEntry2 = ((Pcolor,"abc"),0,"def")
test_voidEntry2 = mkTestCase "VoidEntry2" expect_voidEntry2 result_voidEntry2

input_voidEntry3 = "abcdef"
result_voidEntry3 = voidEntry_parseS input_voidEntry3
expect_voidEntry3 =  ((Pnothing,"abc"),0,"def")
test_voidEntry3 = mkTestCase "VoidEntry3" expect_voidEntry3 result_voidEntry3

[pads| data Switch (which :: Int) =  
         case <| which |> of
             0 ->         Even Int where <| even `mod` 2 == 0 |>
           | 1 ->         Comma   ','
           | otherwise -> Missing Void |] 
input_switch0 = "2hello"
input_switch1 = ",hello"
input_switchOther = "hello"

result_switch0 = switch_parseS 0 input_switch0
expect_switch0 =  (Even (2),0,"hello")
test_switch0 = mkTestCase "switch0" expect_switch0 result_switch0

result_switch1 = switch_parseS 1 input_switch1
expect_switch1 = (Comma,0,"hello")
test_switch1 = mkTestCase "switch1" expect_switch1 result_switch1

result_switchOther = switch_parseS 2 input_switchOther
expect_switchOther = (Missing,0,"hello")
test_switchOther = mkTestCase "switchOther" expect_switchOther result_switchOther



result_stringln = stringln_parseS "hello\ngoodbye"
expect_stringln = ("hello",0,"goodbye")
test_stringln = mkTestCase "stringln" expect_stringln result_stringln

[pads| data MyBody (which::Int) = 
         case <| which |> of
            0         -> First Int
          | 1         -> Second (StringC ',')
          | otherwise -> Other Void

       data MyEntry = MyEntry 
          { header  :: Int, ','
          , body    :: MyBody header, ','
          , trailer :: Char}  

       type MyData = [Line MyEntry] terminator EOF      |]

input_myData = "0,23,a\n1,hello,b\n2,,c\n"
result_myData = myData_parseS input_myData
expect_myData = ([MyEntry {header = 0, body = First (23), trailer = 'a'},
                  MyEntry {header = 1, body = Second ("hello"), trailer = 'b'},
                  MyEntry {header = 2, body = Other, trailer = 'c'}],0, "")
test_myData = mkTestCase "MyData" expect_myData result_myData



[pads| data HP = HP { student_num  :: Int, ',', 
                      student_name :: StringFW student_num }
       type HP_data = [Line HP] terminator EOF |]   

input_hp_data = "8,Hermione\n3,Ron\n5,Harry\n"
result_hp_data = hP_data_parseS input_hp_data
expect_hp_data = ([HP {student_num = 8, student_name = "Hermione"},
                   HP {student_num = 3, student_name = "Ron"},
                   HP {student_num = 5, student_name = "Harry"}], 0, "")
test_hp_data = mkTestCase "HP Data" expect_hp_data result_hp_data



test_file = "Examples/data/test_file"
result_hp_data_file_parse :: (HP_data, HP_data_md) = unsafePerformIO $ parseFileWith hP_data_parseM test_file

expect_hp_data_file_parse = 
  ( [HP {student_num = 8, student_name = "Hermione"},
     HP {student_num = 3, student_name = "Ron"},
     HP {student_num = 5, student_name = "Harry"}], 0)
test_hp_data_file_parse = mkFileTestCase "HP file" expect_hp_data_file_parse result_hp_data_file_parse



[pads| newtype MyDoc = MyDoc Text |]
myDoc_input_file = "Examples/data/test_file"
myDoc_result :: (MyDoc, MyDoc_md) = unsafePerformIO $ parseFile myDoc_input_file
myDoc_expects = (MyDoc "8,Hermione\n3,Ron\n5,Harry\n",0)
myDoc_test = mkFileTestCase "myDoc" myDoc_expects myDoc_result


acomma = ","
[pads| data LitRec = LitRec { fstField :: Int, acomma, sndField :: Int} |]
litRec_input = "12,34"
litRec_result = litRec_parseS litRec_input
litRec_expects = (LitRec {fstField = 12, sndField = 34},0,"")
litRec_test = mkTestCase "Haskell identifier literal" litRec_expects litRec_result

[pads| type WhiteSpace = (Int, '[ \t]+', Int) |]
whiteSpace_input = "12      34"
whiteSpace_result = whiteSpace_parseS whiteSpace_input
whiteSpace_expects = ((12,34),0,"")
whiteSpace_test = mkTestCase "regular expression literal" whiteSpace_expects whiteSpace_result


ws = RE "[ \t]+"
[pads| type WhiteSpace2 = (Int, ws, Int) |]
whiteSpace2_input = "12      34"
whiteSpace2_result = whiteSpace2_parseS whiteSpace2_input
whiteSpace2_expects = ((12,34),0,"")
whiteSpace2_test = mkTestCase "Haskell expression regular expression literal" whiteSpace2_expects whiteSpace2_result

[pads| type RE_ty = (StringME '[tod]', ws, StringME 'a+') |]
rE_ty_input = "t  aaaa"
rE_ty_result = rE_ty_parseS rE_ty_input
rE_ty_expects = (("t","aaaa"),0,"")
rE_ty_test = mkTestCase "regular expression abbreviation for StringME" rE_ty_expects rE_ty_result

