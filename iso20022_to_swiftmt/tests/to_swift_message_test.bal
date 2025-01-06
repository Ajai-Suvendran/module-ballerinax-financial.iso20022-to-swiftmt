// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerinax/financial.swift.mt as swiftmt;

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPain001ToMt101() returns error? {
    string finMessage = string `{1:F010000000000}{2:O101074518250101N}{4:
:20:11FF99RR
:28D:1/1
:30:090327
:21:REF501
:32B:EUR100000.00
:50F:/9020123100
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
:57C://CP9999
:59F:/756-857489-21
1/SOFTEASE PC GRAPHICS
2/34 BRENTWOOD ROAD
3/US/SEAFORD, NEW YORK, 11246
:70:/INV/19S95
:77B:/BENEFRES/US//34 BRENTWOOD ROAD SEA
//FORD, NEW YORK 11246
:71A:SHA
:25A:/9101000123
:36:0,90
:21:REF502
:23E:CHQB
:32B:EUR2000.00
:50F:/9020123100
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
3/FI/HELSINKI
:59F:/TONY BALONEY
1/MYRTLE AVENUE 3159
2/US/BROOKLYN, NEW YORK 11245
:70:09-02 PENSION PAYMENT
:71A:OUR
:25A:/9101000123
:36:0,9
:21:REF503
:23E:CMZB
:23E:INTC
:32B:USD0
:50F:/9102099999
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
3/FI/HELSINKI
:52A:CHXXUS33BBB
:59F:/9020123100
1/FINPETROL INC.
2/ANDRELAE SPINKATU 7
3/FI/HELSINKI
:71A:SHA
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.12"><CstmrCdtTrfInitn><GrpHdr><MsgId>11FF99RR</MsgId><CreDtTm>2025-01-01T07:45:18.651615900Z</CreDtTm><NbOfTxs>3</NbOfTxs><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><FwdgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></FwdgAgt></GrpHdr><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>/9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF501</EndToEndId></PmtId><PmtTpInf/><Amt><InstdAmt Ccy="EUR">100000.00</InstdAmt></Amt><XchgRateInf><XchgRate>0.90</XchgRate></XchgRateInf><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId><Cd>/CP9999</Cd></ClrSysId><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAgtAcct><Cdtr><Nm>SOFTEASE PC GRAPHICS</Nm><PstlAdr><TwnNm>SEAFORD, NEW YORK, 11246</TwnNm><Ctry>US</Ctry><AdrLine>34 BRENTWOOD ROAD</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>756-857489-21</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><RgltryRptg><Dtls><Ctry>US</Ctry><Cd>BENEFRES</Cd><Inf>34 BRENTWOOD ROAD SEAFORD, NEW YORK 11246</Inf></Dtls></RgltryRptg><RmtInf><Ustrd>/INV/19S95</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>/9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF502</EndToEndId></PmtId><PmtTpInf/><Amt><InstdAmt Ccy="EUR">2000.00</InstdAmt></Amt><XchgRateInf><XchgRate>0.9</XchgRate></XchgRateInf><ChrgBr>DEBT</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>MYRTLE AVENUE 3159</Nm><PstlAdr><AdrLine>US/BROOKLYN, NEW YORK 11245</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>TONY BALONEY</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt><Cd>CHQB</Cd></InstrForCdtrAgt><RmtInf><Ustrd>09-02 PENSION PAYMENT</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>/9102099999</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>CHXXUS33BBB</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><ChrgsAcct><Id><Othr><SchmeNm/></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>REF503</EndToEndId></PmtId><PmtTpInf><CtgyPurp><Cd>INTC</Cd></CtgyPurp></PmtTpInf><Amt><InstdAmt Ccy="USD">0</InstdAmt></Amt><XchgRateInf/><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForDbtrAgt><Cd>CMZB</Cd></InstrForDbtrAgt><RmtInf><Ustrd/></RmtInf></CdtTrfTxInf></PmtInf></CstmrCdtTrfInitn></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "101"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs008ToMt102Stp() returns error? {
    string finMessage = string `{1:F01BNKBBEBB0000000000}{2:O102081134250101BNKACHZZN}{3:{121:4ea37e81-98ec-4014-b7a4-1ff4611b3fca}{119:STP}}{4:
:20:5362/MPB
:23:NOTPROVIDED
:50F:AL47212110090000000235698741
1/CONSORTIA PENSION SCHEME
2/FRIEDRICHSTRASSE, 27
2/8022-ZURICH
:71A:OUR
:36:1,6
:21:ABC/123
:32B:EUR1250,00
:59F:/001161685134
1/JOHANN WILLEMS
2/RUE JOSEPH II, 19
2/1040 BRUSSELS
:70:PENSION PAYMENT SEPTEMBER 2009
:33B:CHF2000,00
:71G:EUR5,00
:21:ABC/124
:32B:EUR1875,00
:59F:/510007547061
1/JOAN MILLS
2/AVENUE LOUISE 213
2/1050 BRUSSELS
:70:PENSION PAYMENT SEPTEMBER 2003
:33B:CHF3000,00
:71G:EUR5,00
:32A:090828EUR3135,00
:19:3125,00
:71G:EUR5,00
:53A:BNPAFRPP
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>5362/MPB</MsgId><CreDtTm>2025-01-01T08:11:34.893795900Z</CreDtTm><NbOfTxs>2</NbOfTxs><CtrlSum>3125.00</CtrlSum><TtlIntrBkSttlmAmt Ccy="EUR">3135.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>COVE</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><BICFI>BNPAFRPP</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>BNKACHZZ</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BNKBBEBB</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1250.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="CHF">2000.00</InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt Ccy="EUR">5.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1875.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="CHF">3000.00</InstdAmt><XchgRate>1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt Ccy="EUR">5.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "102STP"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs008ToMt103Remit() returns error? {
    string finMessage = string `{1:F01BKAUATWW0000000000}{2:O103000000091231N}{3:{119:REMIT}}{4:
:20:494931/DEV
:23B:NOTPROVIDED
:32A:090828EUR1958,47
:50F:/942267890
1/FRANZ HOLZAPFEL GMBH
2/GELBSTRASSE, 13
3/AT/VIENNA
:59F:/502664959
1/H.F. JANSSEN
2/LEDEBOERSTRAAT 27
3/NL/AMSTERDAM
:71A:SHA
:77T:/NARR/UNH+123A5+FINPAY:D:98A:UN'DOC+...
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>494931/DEV</MsgId><CreDtTm>2009-12-31T00:00:00</CreDtTm><NbOfTxs>1</NbOfTxs><TtlIntrBkSttlmAmt Ccy="EUR">1958.47</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct><ThrdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></ThrdRmbrsmntAgt></SttlmInf><InstgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>494931/DEV</InstrId><EndToEndId/></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1958.47</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="EUR">1958.47</InstdAmt><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>FRANZ HOLZAPFEL GMBH</Nm><PstlAdr><TwnNm>VIENNA</TwnNm><Ctry>AT</Ctry><AdrLine>GELBSTRASSE, 13</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>/942267890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>H.F. JANSSEN</Nm><PstlAdr><TwnNm>AMSTERDAM</TwnNm><Ctry>NL</Ctry><AdrLine>LEDEBOERSTRAAT 27</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>502664959</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd/></RmtInf><SplmtryData><Envlp><Nrtv>UNH+123A5+FINPAY:D:98A:UN'DOC+...</Nrtv></Envlp></SplmtryData></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "103REMIT"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs008ToMt103Stp() returns error? {
    string finMessage = string `{1:F01OCBCSGSG0000000000}{2:O103090105250101BKAUATWWN}{3:{119:STP}}{4:
:20:494938/DEV
:23B:NOTPROVIDED
:32A:090828USD850,00
:50F:/942267890
1/FRANZ HOLZAPFEL GMBH
2/GELBSTRASSE, 13
3/AT/VIENNA
:52A:BKAUATWWEIS
:57A:OCBCSGSG
:59F:/729615-941
1/C.WON
2/PARK AVENUE 1
3/SG/
:70:/RFB/EXPENSES 7/2009
:71A:SHA
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>494938/DEV</MsgId><CreDtTm>2025-01-01T09:01:05.986385700Z</CreDtTm><NbOfTxs>1</NbOfTxs><TtlIntrBkSttlmAmt Ccy="USD">850.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct><ThrdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></ThrdRmbrsmntAgt></SttlmInf><InstgAgt><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>OCBCSGSG</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>494938/DEV</InstrId><EndToEndId/></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="USD">850.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt Ccy="USD">850.00</InstdAmt><ChrgBr>SHAR</ChrgBr><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>FRANZ HOLZAPFEL GMBH</Nm><PstlAdr><TwnNm>VIENNA</TwnNm><Ctry>AT</Ctry><AdrLine>GELBSTRASSE, 13</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>/942267890</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>BKAUATWWEIS</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><BICFI>OCBCSGSG</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>C.WON</Nm><PstlAdr><Ctry>SG</Ctry><AdrLine>PARK AVENUE 1</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>729615-941</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><Purp><Prtry/></Purp><RmtInf><Ustrd>/RFB/EXPENSES 7/2009</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "103STP"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs008ToMt103() returns error? {
    string finMessage = string `{1:F01OCBCSGSG0000000000}{2:O103090523250101DEUTDEFFXXXN}{3:{121:31df8b48-8845-4fc6-86cd-5586df980e97}}{4:
:20:MSPSDRS/123
:13C:/CLSTIME/0915+0100
:23B:NOTPROVIDED
:23E:TELI/3226553478
:26T:K90
:32A:090828USD840,00
:33B:USD850,00
:36:0,9236
:50F:NE58NE0380100100130305000268
1/JOHN DOE
2/123 MAIN STREET
2/US/NEW YORK
2/APARTMENT 456
:51A:/1234567890123456
DEUTDEFFXXX
:52A:/1234567890123456
DEUTDEFFXXX
:53B:/1234567890
NEW YORK BRANCH
:54D:/1234567890
FINANZBANK AG
EISENSTADT
MARKTPLATZ 5
AT
:55D:FINANZBANK AG
EISENSTADT
MARKTPLATZ 5
AT
:57D:CITIBANK N.A.
399 PARK AVENUE
NEW YORK
US
:59F:/12345678
1/DEPT OF PROMOTION OF SPICY FISH CENTER FOR INTERNATIONALISATION
3/CN/
:70:/TSU/00000089963-0820-01/ABC-15/256
214,
:71A:SHA
:71F:USD10,00
:72:
/INS/ABNANL2A
:77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>MSPSDRS/123</MsgId><CreDtTm>2025-01-01T09:05:23.464992600Z</CreDtTm><NbOfTxs>1</NbOfTxs><TtlIntrBkSttlmAmt Ccy="USD">840.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr><AdrLine>NEW YORK BRANCH</AdrLine></PstlAdr></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><Id>1234567890</Id><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><Nm>FINANZBANK AG</Nm><PstlAdr><AdrLine>EISENSTADT</AdrLine><AdrLine>MARKTPLATZ 5</AdrLine><AdrLine>AT</AdrLine></PstlAdr></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><Id>1234567890</Id><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct><ThrdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><Nm>FINANZBANK AG</Nm><PstlAdr><AdrLine>EISENSTADT</AdrLine><AdrLine>MARKTPLATZ 5</AdrLine><AdrLine>AT</AdrLine></PstlAdr></FinInstnId></ThrdRmbrsmntAgt></SttlmInf><InstgAgt><FinInstnId><BICFI>DEUTDEFFXXX</BICFI><ClrSysMmbId><ClrSysId><Cd>1234567890123456</Cd></ClrSysId><MmbId/></ClrSysMmbId></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>OCBCSGSG</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>MSPSDRS/123</InstrId><EndToEndId/><UETR>31df8b48-8845-4fc6-86cd-5586df980e97</UETR></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="USD">840.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq><CLSTm>09:15:00+01:00</CLSTm></SttlmTmReq><InstdAmt Ccy="USD">850.00</InstdAmt><XchgRate>0.9236</XchgRate><ChrgBr>SHAR</ChrgBr><ChrgsInf><Amt Ccy="USD">10.00</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>CRED</Cd></Tp></ChrgsInf><ChrgsInf><Amt Ccy="EUR">5.50</Amt><Agt><FinInstnId><Nm>NOTPROVIDED</Nm><PstlAdr><AdrLine>NOTPROVIDED</AdrLine></PstlAdr></FinInstnId></Agt><Tp><Cd>DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></PrvsInstgAgt1><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>JOHN DOE</Nm><PstlAdr><AdrLine>123 MAIN STREET</AdrLine><AdrLine>US/NEW YORK</AdrLine><AdrLine>APARTMENT 456</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>NE58NE0380100100130305000268</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>DEUTDEFFXXX</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><Id>1234567890123456</Id><SchmeNm/></Othr></Id></DbtrAgtAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><Nm>CITIBANK N.A.</Nm><PstlAdr><AdrLine>399 PARK AVENUE</AdrLine><AdrLine>NEW YORK</AdrLine><AdrLine>US</AdrLine></PstlAdr></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>DEPT OF PROMOTION OF SPICY FISH CENTER FOR INTERNATIONALISATION</Nm><PstlAdr><Ctry>CN</Ctry></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>12345678</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForNxtAgt><Cd>TELI</Cd><InstrInf>3226553478</InstrInf></InstrForNxtAgt><Purp><Prtry>K90</Prtry></Purp><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd>/TSU/00000089963-0820-01/ABC-15/256
214,</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "103"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs003ToMt104() returns error? {
    string finMessage = string `{1:F01BANKDEFF0000000000}{2:O104091715250101N}{4:
:20:REFERENCE12345
:23E:OTHR
:30:090921
:50K:/12345678
SMITH JOHN
299, PARK AVENUE
US/NEW YORK, NY 10017
:77B:/ORDERRES/BE//MEILAAN 1, 9000 GENT
:71A:OUR
:21:REF12444
:32B:EUR1875.00
:59:/12345678
DEPT OF PROMOTION OF SPICY FISH
299, PARK AVENUE
CN
:21:REF12345
:32B:EUR1875.00
:59:1234567822
DEPT OF PROMOTION OF SPICY FISH
US/NEW YORK, NY 10017
:32B:EUR3750.00
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.11"><FIToFICstmrDrctDbt><GrpHdr><MsgId>REFERENCE12345</MsgId><CreDtTm>2025-01-01T09:17:15.816140800Z</CreDtTm><NbOfTxs>2</NbOfTxs><TtlIntrBkSttlmAmt Ccy="EUR">3750.00</TtlIntrBkSttlmAmt><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf><InstgAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BANKDEFF</BICFI></FinInstnId></InstdAgt></GrpHdr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12444</EndToEndId><TxId>REF12444</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1875.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><InstdAmt Ccy="EUR">1875.00</InstdAmt><ChrgBr>DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><Nm>SMITH JOHN</Nm><PstlAdr><AdrLine>299, PARK AVENUE</AdrLine><AdrLine>US/NEW YORK, NY 10017</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>12345678</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>DEPT OF PROMOTION OF SPICY FISH</Nm><PstlAdr><AdrLine>299, PARK AVENUE</AdrLine><AdrLine>CN</AdrLine></PstlAdr><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><Othr><Id>12345678</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId><TxId>REF12345</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1875.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><InstdAmt Ccy="EUR">1875.00</InstdAmt><ChrgBr>DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><Nm>PETER PARKER</Nm><PstlAdr><AdrLine>299, PARK AVENUE</AdrLine><AdrLine>US/NEW YORK, NY 10017</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>12345678</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><Nm>1234567822</Nm><PstlAdr><AdrLine>DEPT OF PROMOTION OF SPICY FISH</AdrLine><AdrLine>US/NEW YORK, NY 10017</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><RgltryRptg><Dtls><Ctry>BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></FIToFICstmrDrctDbt></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "104"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs009ToMt200() returns error? {
    string finMessage = string `{1:F01CHASUS330000000000}{2:O200092710250101BKAUATWWN}{4:
:20:39857579
:32A:0905251000000,00
:53B:/34554-3049
:56A:CITIUS33
:57A:CITIUS33MIA
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>39857579</MsgId><CreDtTm>2025-01-01T09:27:10.826827400Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BICFI>BKAUATWW</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>CHASUS33</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>39857579</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="USD">1000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-25</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><Id>34554-3049</Id><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>CITIUS33MIA</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "200"))), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs009ToMt201() returns error? {
    string finMessage = string `{1:F01ABNANL2A0000000000}{2:O201094239250101UBSWCHZHN}{4:
:19:61000,00
:30:090528
:20:1234/22
:32B:EUR5000,00
:57A:INGBNL2A
:20:1235/22
:32B:EUR7500,00
:57A:BBSPNL2A
:20:1227/23
:32B:EUR12500,00
:20:1248/32
:32B:EUR6000,00
:57A:CRLYFRPP
:20:1295/22
:32B:EUR30000,00
:56A:INGBNL2A
:57A:DEUTDEFF
:72:/ACC/Pay
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>3dccfff8-eb1a-4c83-85b3-3b28d707866</MsgId><CreDtTm>2025-01-01T09:42:39.134368500Z</CreDtTm><NbOfTxs>5</NbOfTxs><CtrlSum>61000.00</CtrlSum><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>1234/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">5000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1235/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">7500.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>BBSPNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1227/23</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">12500.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr><AdrLine>ROTTERDAM</AdrLine></PstlAdr></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1248/32</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">6000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>CRLYFRPP</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>1295/22</InstrId><EndToEndId/></PmtId><IntrBkSttlmAmt Ccy="EUR">30000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Cdtr><FinInstnId><BICFI>DEUTDEFF</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><InstrForCdtrAgt><Cd>ACC</Cd><InstrInf>Pay</InstrInf></InstrForCdtrAgt></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "201"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs009ToMt202() returns error? {
    string finMessage = string `{1:F01BANKJPJT0000000000}{2:O202094746250101BANKGB2LN}{4:
:20:JPYNOSTRO170105
:21:CLSINSTR170105
:13C:/CLSTIME/0700+0100
:32A:1701055000000,00
:57A:BOJPJPJT
:58A:CLSBUS33
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>JPYNOSTRO170105</MsgId><CreDtTm>2025-01-01T09:47:46.517447700Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>BANKGB2L</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>BANKJPJT</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>JPYNOSTRO170105</InstrId><EndToEndId>CLSINSTR170105</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="JPY">5000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2017-01-05</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq><CLSTm>07:00:00+01:00</CLSTm></SttlmTmReq><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>BOJPJPJT</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>CLSBUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "202"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs009ToMt202Cov() returns error? {
    string finMessage = string `{1:F01CCCCUS330000000000}{2:O202095018250101AAAABEBBN}{3:{119:COV}}{4:
:20:090525/124COV
:21:090525/123COV
:32A:09052710500,00
:56A:ABFDUS33
:57A:DDDDUS33
:58A:BBBBGB22
:50F:/123564982101
1/MR. BIG
2/HIGH STREET 3
3/BE/BRUSSELS
:57A:BBBBGB22
:59F:/987654321
1/MR. SMALL
2/LOW STREET 15
3/GB/LONDON
:70:/INV/1234
:33B:USD10500,00
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>090525/124COV</MsgId><CreDtTm>2025-01-01T09:50:18.865886600Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>AAAABEBB</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>CCCCUS33</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>090525/124COV</InstrId><EndToEndId>090525/123COV</EndToEndId><TxId>090525/123COV</TxId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="USD">10500.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-27</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><IntrmyAgt1><FinInstnId><BICFI>ABFDUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>DDDDUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>BBBBGB22</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><UndrlygCstmrCdtTrf><Dbtr><Nm>MR. BIG</Nm><PstlAdr><TwnNm>BRUSSELS</TwnNm><Ctry>BE</Ctry><AdrLine>HIGH STREET 3</AdrLine></PstlAdr><Id><OrgId><Othr><Id>NOTPROVIDED</Id><SchmeNm><Cd>TxId</Cd></SchmeNm></Othr></OrgId><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>/123564982101</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><DbtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAgtAcct><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><CdtrAgt><FinInstnId><BICFI>BBBBGB22</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><Nm>MR. SMALL</Nm><PstlAdr><TwnNm>LONDON</TwnNm><Ctry>GB</Ctry><AdrLine>LOW STREET 15</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>987654321</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><RmtInf><Ustrd>/INV/1234</Ustrd></RmtInf><InstdAmt Ccy="USD">10500.00</InstdAmt></UndrlygCstmrCdtTrf></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "202COV"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs009ToMt203() returns error? {
    string finMessage = string `{1:F01ABNANL2A0000000000}{2:O203100520250101UBSWCHZHN}{4:
:19:5000000,00
:30:090528
:20:2345
:21:789022
:32B:EUR500000,00
:57A:INGBNL2A
:58A:MGTCUS33
:20:2346
:21:ABX2270
:32B:EUR1500000,00
:57A:BBSPNL2A
:58A:MELNGB2X
:20:2347
:21:CO 2750/26
:32B:EUR1000000,00
:57A:CITINL2X
:58A:CITIUS33
:20:2348
:21:DRESFF2344BKAUWW
:32B:EUR2000000,00
:58A:DRESDEFF
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.009.001.11"><FICdtTrf><GrpHdr><MsgId>207f93ea-9190-4c53-a2f6-9684cbda034</MsgId><CreDtTm>2025-01-01T10:05:20.143212500Z</CreDtTm><NbOfTxs>4</NbOfTxs><CtrlSum>5000000.00</CtrlSum><SttlmInf><SttlmMtd>INDA</SttlmMtd><InstgRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstgRmbrsmntAgt><InstgRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstgRmbrsmntAgtAcct><InstdRmbrsmntAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></InstdRmbrsmntAgt><InstdRmbrsmntAgtAcct><Id><Othr><SchmeNm/></Othr></Id></InstdRmbrsmntAgtAcct></SttlmInf><InstgAgt><FinInstnId><BICFI>UBSWCHZH</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>ABNANL2A</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>2345</InstrId><EndToEndId>789022</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">500000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>INGBNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>MGTCUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2346</InstrId><EndToEndId>ABX2270</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1500000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>BBSPNL2A</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>MELNGB2X</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2347</InstrId><EndToEndId>CO 2750/26</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">1000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><BICFI>CITINL2X</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>2348</InstrId><EndToEndId>DRESFF2344BKAUWW</EndToEndId></PmtId><PmtTpInf><SvcLvl/></PmtTpInf><IntrBkSttlmAmt Ccy="EUR">2000000.00</IntrBkSttlmAmt><IntrBkSttlmDt>2009-05-28</IntrBkSttlmDt><IntrmyAgt1><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt1><IntrmyAgt1Acct><Id><Othr><SchmeNm/></Othr></Id></IntrmyAgt1Acct><Dbtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><CdtrAgt><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><BICFI>DRESDEFF</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct></CdtTrfTxInf></FICdtTrf></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "203"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testPacs010ToMt204() returns error? {
    string finMessage = string `{1:F01CNORUS440000000000}{2:O204100801250101XCMEUS4CN}{4:
:20:XCME REF1
:19:50000,00
:30:090921
:57A:FNBCUS44
:20:XCME REF2
:21:MANDATEREF1
:32B:USD50000,00
:53A:MLNYUS33
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.010.001.06"><FIDrctDbt><GrpHdr><MsgId>XCME REF1</MsgId><CreDtTm>2025-01-01T10:08:01.987249500Z</CreDtTm><NbOfTxs>1</NbOfTxs><CtrlSum>50000.00</CtrlSum><InstgAgt><FinInstnId><BICFI>XCMEUS4C</BICFI></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BICFI>CNORUS44</BICFI></FinInstnId></InstdAgt></GrpHdr><CdtInstr><CdtId>XCME REF1</CdtId><IntrBkSttlmDt>2009-09-21</IntrBkSttlmDt><CdtrAgt><FinInstnId><BICFI>FNBCUS44</BICFI><PstlAdr/></FinInstnId></CdtrAgt><CdtrAgtAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAgtAcct><Cdtr><FinInstnId><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><DrctDbtTxInf><PmtId><InstrId>XCME REF2</InstrId><EndToEndId>MANDATEREF1</EndToEndId></PmtId><IntrBkSttlmAmt Ccy="USD">50000.00</IntrBkSttlmAmt><Dbtr><FinInstnId><BICFI>MLNYUS33</BICFI><PstlAdr/></FinInstnId></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct></DrctDbtTxInf></CdtInstr></FIDrctDbt></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "204"))).toString(), msg = "testToIso20022Xml result incorrect");
}

@test:Config {
    groups: ["toSwiftMtMessage"]
}
isolated function testCamt057ToMt210() returns error? {
    string finMessage = string `{2:O210101211250101N}{4:
:20:318393
:30:100222
:21:BEBEBB0023CRESZZ
:32B:USD230000,00
:52A:CRESCHZZ
:56A:CITIUS33
-}`; 

    xml inputXml = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.057.001.08"><NtfctnToRcv><GrpHdr><MsgId>318393</MsgId><CreDtTm>2025-01-01T10:12:11.802172400Z</CreDtTm></GrpHdr><Ntfctn><Id>318393</Id><Itm><Id>BEBEBB0023CRESZZ</Id><EndToEndId>BEBEBB0023CRESZZ</EndToEndId><Acct><Id><Othr><SchmeNm/></Othr></Id></Acct><Amt Ccy="USD">230000.00</Amt><XpctdValDt>2010-02-22</XpctdValDt><Dbtr><Pty><PstlAdr/><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Pty></Dbtr><DbtrAgt><FinInstnId><BICFI>CRESCHZZ</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></DbtrAgt><IntrmyAgt><FinInstnId><BICFI>CITIUS33</BICFI><ClrSysMmbId><ClrSysId/><MmbId/></ClrSysMmbId><PstlAdr/></FinInstnId></IntrmyAgt></Itm></Ntfctn></NtfctnToRcv></Document></Envelope>`;
    test:assertEquals(finMessage, (check swiftmt:getFinMessage(check toSwiftMtMessage(inputXml, "210"))).toString(), msg = "testToIso20022Xml result incorrect");
}
