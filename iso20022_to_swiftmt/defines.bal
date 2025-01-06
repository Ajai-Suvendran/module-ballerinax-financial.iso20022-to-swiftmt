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

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;

const PAIN001 = "pain.001";
const PACS008 = "pacs.008";
const PAIN008 = "pain.008";
const PACS003 = "pacs.003";
const CAMT050 = "camt.050";
const PACS009 = "pacs.009";
const PACS010 = "pacs.010";
const CAMT057 = "camt.057";
const CAMT054 = "camt.054";
const CAMT060 = "camt.060";
const CAMT053 = "camt.053";
const CAMT052 = "camt.052";

const MT101 = "MT101";
const MT102 = "MT102";
const MT102_STP = "MT102_STP";
const MT103 = "MT103";
const MT103_STP = "MT103_STP";
const MT103_REMIT = "MT103_REMIT";
const MT104 = "MT104";
const MT107 = "MT107";
const MT192 = "MT192";
const MT195 = "MT195";
const MT196 = "MT196";

const MT200 = "MT200";
const MT201 = "MT201";
const MT202 = "MT202";
const MT202_COV = "MT202_COV";
const MT203 = "MT203";
const MT204 = "MT204";
const MT205 = "MT205";
const MT205_COV = "MT205_COV";
const MT210 = "MT210";
const MT292 = "MT292";
const MT295 = "MT295";

const MESSAGETYPE_101 = "101";
const MESSAGETYPE_102 = "102";
const MESSAGETYPE_103 = "103";
const MESSAGETYPE_103_STP = "103STP";
const MESSAGETYPE_103_REMIT = "103REMIT";
const MESSAGETYPE_104 = "104";
const MESSAGETYPE_102_STP = "102STP";
const MESSAGETYPE_107 = "107";
const MESSAGETYPE_192 = "192";
const MESSAGETYPE_195 = "195";
const MESSAGETYPE_196 = "196";
const MESSAGETYPE_200 = "200";
const MESSAGETYPE_201 = "201";
const MESSAGETYPE_202 = "202";
const MESSAGETYPE_203 = "203";
const MESSAGETYPE_204 = "204";

const NUMBER1 = "1";
const NUMBER2 = "2";
const NUMBER3 = "3";
const NUMBER4 = "4";

const EMPTY_STRING = "";

const MT19_NAME = "19";
const MT20_NAME = "20";
const MT21_NAME = "21";
const MT21R_NAME = "21R";
const MT23E_NAME = "23E";
const MT21E_NAME = "21E";
const MT30_NAME = "30";
const MT51A_NAME = "51A";
const MT26T_NAME = "26T";
const MT77B_NAME = "77B";
const MT71A_NAME = "71A";
const MT72_NAME = "72";
const MT32B_NAME = "32B";
const MT71F_NAME = "71F";
const MT71G_NAME = "71G";
const MT36_NAME = "36";
const MT21D_NAME = "21D";
const MT33B_NAME = "33B";
const MT28D_NAME = "28D";
const MT70_NAME = "70";
const MT25A_NAME = "25A";
const MT23_NAME = "23";
const MT77T_NAME = "77T";
const MT23B_NAME = "23B";
const MT79_NAME = "79";
const MT11S_NAME = "11S";
const MT11R_NAME = "11R";
const MT76_NAME = "76";
const MT75_NAME = "75";
const MT77A_NAME = "77A";
const MT50C_NAME = "50C";
const MT50L_NAME = "50L";
const MT50F_NAME = "50F";
const MT50G_NAME = "50G";
const MT50H_NAME = "50H";
const MT52A_NAME = "50A";
const MT52C_NAME = "50C";
const MT56A_NAME = "56A";
const MT56D_NAME = "56D";
const MT56C_NAME = "56C";
const MT57A_NAME = "57A";
const MT57C_NAME = "57C";
const MT57D_NAME = "57D";
const MT59A_NAME = "59A";
const MT59F_NAME = "59F";
const MT59_NAME = "59";
const MT50_NAME = "50";
const MT52B_NAME = "52B";
const MT56F_NAME = "56F";
const MT53A_NAME = "53A";
const MT53B_NAME = "53B";
const MT53C_NAME = "53C";
const MT53D_NAME = "53D";
const MT50A_NAME = "50A";
const MT50K_NAME = "50K";
const MT52D_NAME = "52D";
const MT54A_NAME = "54A";
const MT54B_NAME = "54B";
const MT54D_NAME = "54D";
const MT55A_NAME = "55A";
const MT55B_NAME = "55B";
const MT55D_NAME = "55D";
const MT57B_NAME = "57B";
const MT13C_NAME = "13C";
const MT32A_NAME = "32A";

const VALIDATION_FLAG_STP = "STP";
const VALIDATION_FLAG_COV = "COV";
const VALIDATION_FLAG_REMIT = "REMIT";

string[] MT_101_INSTRC_CD = [
    "CHQB",
    "CMSW",
    "CMTO",
    "CMZB",
    "CORT",
    "EQUI",
    "INTC",
    "NETS",
    "OTHR",
    "PHON",
    "REPA",
    "RTGS",
    "URGP"
];

isolated string[] MT_103_INSTRC_CD = [
    "CHQB",
    "CORT",
    "INTC",
    "SDVA",
    "TELB",
    "PHOB",
    "HOLD"
];

# This record is used to store any type of MT message record and the type name
#
# + mtTypeName - The MT record type name
# + mtData - The MT record
type MtMessage record {|
    // The MT record type name
    string mtTypeName;
    // The MT record
    record {} mtData;
|};

# This record is used to store any type of MX message record and the type name
#
# + mxTypeName - The MX record type name
# + mxData - The MX record
type MxMessage record {|
    // The MX record type name
    string mxTypeName;
    // The MX record
    record {} mxData;
|};

final readonly & map<isolated function> transformFunctionMap =
    {
    "101": transformPain001DocumentToMT101,
    "102": transformPacs008DocumentToMT102,
    "102STP": transformPacs008DocumentToMT102STP,
    "103": transformPacs008DocumentToMT103,
    "103STP": transformPacs008DocumentToMT103STP,
    "103REMIT": transformPacs008DocumentToMT103REMIT,
    "104": transformPacs003DocumentToMT104,
    "107": transformPacs003DocumentToMT107,   
    "192": transformCamt056ToMtn92,
    "195": transformCamt026ToMtn95,
    "196": transformCamt029ToMtn96,
    "200": transformPacs009ToMt200,
    "201": transformPacs009ToMt201,
    "202": transformPacs009ToMt202,
    "202COV": transformPacs009ToMt202COV,
    "203": transformPacs009ToMt203,
    "204": transformPacs010ToMt204,
    "205": transformPacs009ToMt205,
    "205COV": transformPacs009ToMt205COV,
    "210": transformCamt057ToMt210,
    "292": transformCamt056ToMtn92,
    "295": transformCamt026ToMtn95,
    "296": transformCamt029ToMtn96
};

final readonly & map<typedesc<record {}>> isoMessageTypes = {
    "pacs.002": pacsIsoRecord:Pacs002Envelope,
    "pacs.003": pacsIsoRecord:Pacs003Envelope,
    "pacs.008": pacsIsoRecord:Pacs008Envelope,
    "pacs.009": pacsIsoRecord:Pacs009Envelope,
    "pacs.010": pacsIsoRecord:Pacs010Envelope,
    "pain.001": painIsoRecord:Pain001Envelope,
    "pain.008": painIsoRecord:Pain008Envelope,
    "camt.026": camtIsoRecord:Camt026Envelope,
    "camt.027": camtIsoRecord:Camt027Envelope,
    "camt.028": camtIsoRecord:Camt028Envelope,
    "camt.029": camtIsoRecord:Camt029Envelope,
    "camt.031": camtIsoRecord:Camt031Envelope,
    "camt.033": camtIsoRecord:Camt033Envelope,
    "camt.034": camtIsoRecord:Camt034Envelope,
    "camt.050": camtIsoRecord:Camt050Envelope,
    "camt.052": camtIsoRecord:Camt052Envelope,
    "camt.053": camtIsoRecord:Camt053Envelope,
    "camt.054": camtIsoRecord:Camt054Envelope,
    "camt.055": camtIsoRecord:Camt055Envelope,
    "camt.056": camtIsoRecord:Camt056Envelope,
    "camt.057": camtIsoRecord:Camt057Envelope,
    "camt.060": camtIsoRecord:Camt060Envelope
};
