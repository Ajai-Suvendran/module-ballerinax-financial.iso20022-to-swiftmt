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

import ballerina/log;
import ballerina/regex;
import ballerina/time;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

isolated function getTransactionInfo(camtIsoRecord:PaymentTransaction155[]? transactionInfo) returns camtIsoRecord:PaymentTransaction155[]|error {
    if transactionInfo is camtIsoRecord:PaymentTransaction155[] {
        return transactionInfo;
    }
    return error("Transaction Information is required to transform this ISO 20022 message to SWIFT message.");
}

isolated function getOrginalPaymentInfo(camtIsoRecord:OriginalPaymentInstruction49[]? orgnlPmtInfo) returns camtIsoRecord:OriginalPaymentInstruction49|error {
    if orgnlPmtInfo is camtIsoRecord:OriginalPaymentInstruction49[] {
        return orgnlPmtInfo[0];
    }
    return error("Transaction Information is required to transform this ISO 20022 message to SWIFT message.");
}

isolated function getCancellationDetails(camtIsoRecord:UnderlyingTransaction32[]? cxlDtls) returns camtIsoRecord:PaymentTransaction152[]?|error {
    if cxlDtls is camtIsoRecord:UnderlyingTransaction32[] {
        if cxlDtls[0].TxInfAndSts is camtIsoRecord:PaymentTransaction152[] {
            return cxlDtls[0].TxInfAndSts;
        }
    }
    return error("Transaction Information is required to transform this ISO 20022 message to SWIFT message.");
}

isolated function getTransactionInfoAndSts(camtIsoRecord:PaymentTransaction152[]? txInfAndSts) returns camtIsoRecord:PaymentTransaction152|error {
    if txInfAndSts is camtIsoRecord:PaymentTransaction152[] {
        return txInfAndSts[0];
    }
    return error("Transaction Information is required to transform this ISO 20022 message to SWIFT message.");
}

isolated function getMandatoryField(string? content) returns string {
    if content is string {
        return content;
    }
    return "";
}

isolated function convertToString(decimal? content) returns string|error {
    if content is () {
        return "";
    }

    return regex:replace(content.toString(), "\\.", ",");
}

isolated function convertToSWIFTStandardDate(string? date) returns string {
    if date is string && date.length() > 9 {
        return date.substring(2, 4) + date.substring(5, 7) + date.substring(8, 10);
    }
    return "";
}

isolated function getAddressLine(pacsIsoRecord:Max70Text[]? address1, int num = 4, boolean isOptionF = false,
        string? townName = (), string? countryCode = ()) returns swiftmt:AdrsLine[] {
    swiftmt:AdrsLine[] address = [];
    int count = num;
    if address1 is pacsIsoRecord:Max70Text[] {
        foreach string adrsLine in address1 {
            address.push({content: adrsLine, number: count.toString()});
            if isOptionF {
                count += 2;
                continue;
            }
            count += 1;
        }
    }
    if isOptionF && (countryCode is string || townName is string) {
        address.push({content: countryCode.toString() + "/" + townName.toString(), number: count.toString()});
    }
    return address;
}

isolated function getOptionalAddressLine(pacsIsoRecord:Max70Text[]? address1, int num = 4, boolean isOptionF = false,
        string? townName = (), string? countryCode = ()) returns swiftmt:AdrsLine[]? {
    swiftmt:AdrsLine[] address = [];
    int count = num;
    if address1 is pacsIsoRecord:Max70Text[] {
        foreach string adrsLine in address1 {
            address.push({content: adrsLine, number: count.toString()});
            if isOptionF {
                count += 2;
                continue;
            }
            count += 1;
        }
        if isOptionF && countryCode is string && townName is string {
            address.push({content: countryCode + "/" + townName, number: count.toString()});
        }
        return address;
    }
    return ();
}

# Maps ServiceLevel, CategoryPurpose, and LocalInstrument fields to MT72.
#
# + serviceLevels - The service level from the ISO message
# + categoryPurpose - The category purpose from the ISO message
# + localInstrument - The local instrument from the ISO message
# + narration - The continuation of the sende rto receiver information from agents.
# + lineCount - The number of lines which the sender to receiver information has.
# + return - Returns a swiftmt:MT72 structure containing mapped Sender to Receiver Information
isolated function getSndRcvrInfoFromMsclns(pacsIsoRecord:ServiceLevel8Choice[]? serviceLevels,
        pacsIsoRecord:CategoryPurpose1Choice? categoryPurpose,
        pacsIsoRecord:LocalInstrument2Choice? localInstrument, string narration, int lineCount) returns string {

    string content = narration;
    int count = lineCount;

    if serviceLevels is pacsIsoRecord:ServiceLevel8Choice[] {
        foreach pacsIsoRecord:ServiceLevel8Choice serviceLevel in serviceLevels {
            if serviceLevel?.Cd is string {
                string code = serviceLevel?.Cd.toString();
                string:RegExp regex = re `^G00[1-9]$`;

                if code != "SDVA" && !code.matches(regex) {
                    content += "/SVCLVL/" + code + " ";
                }
            }
            if serviceLevel?.Prtry is string {
                string proprietary = serviceLevel?.Prtry.toString();
                content += "/SVCLVL/" + proprietary + " ";
            }
        }
    }
    if categoryPurpose?.Cd is string {
        string code = categoryPurpose?.Cd.toString();
        if code != "INTC" && code != "CORT" {
            if count < 6 && (35 - ((narration.length() % 35) + 9)) <= code.length() {
                content += "/CATPURP/" + code;
            } else if count < 5 {
                content += "\n/CATPURP/" + code;
                count += 1;
            }
        }
    }
    if categoryPurpose?.Prtry is string {
        string proprietary = categoryPurpose?.Prtry.toString();

        if proprietary != "INTC CORT" {
            if count < 6 && (35 - ((narration.length() % 35) + 9)) <= proprietary.length() {
                content += "/CATPURP/" + proprietary;
            } else if count < 5 {
                content += "\n/CATPURP/" + proprietary;
                count += 1;
            }
        }
    }
    if localInstrument?.Cd is string {
        string code = localInstrument?.Cd.toString();
        if count < 6 && (35 - ((narration.length() % 35) + 8)) <= code.length() {
            content += "/LOCINS/" + code;
        } else if count < 5 {
            content += "\n/LOCINS/" + code;
            count += 1;
        }
    }
    if localInstrument?.Prtry is string {
        string proprietary = localInstrument?.Prtry.toString();
        if proprietary != "CRED" && proprietary != "CRTS" && proprietary != "SPAY" &&
            proprietary != "SPRI" && proprietary != "SSTD" {
            if count < 6 && (35 - ((narration.length() % 35) + 8)) <= proprietary.length() {
                content += "/LOCINS/" + proprietary;
            } else if count < 5 {
                content += "\n/LOCINS/" + proprietary;
                count += 1;
            }
        }
    }
    return content;
}

isolated function getFieldSndRcvrInfoFromAgts(pacsIsoRecord:InstructionForCreditorAgent3[]? instruction1,
        pacsIsoRecord:InstructionForNextAgent1[]? instruction2, pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?
        instruction3, pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instruction4) returns [string, int] {
    string narration = "";
    int lineCount = 0;
    int count = 0;
    if instruction1 is pacsIsoRecord:InstructionForCreditorAgent3[] {
        foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in instruction1 {
            if instruction.Cd == "ACC" && count == 0 {
                narration += "/ACC/";
                count += 1;
                if instruction.InstrInf is string {
                    string instructionInfo = instruction.InstrInf.toString();
                    foreach int i in 0 ... instructionInfo.length() - 1 {
                        if narration.length() % 35 == 0 {
                            lineCount += 1;
                            if lineCount > 5 {
                                break;
                            }
                            narration += "\n//".concat(instructionInfo.substring(i, i + 1));
                            continue;
                        }
                        narration += instructionInfo.substring(i, i + 1);
                    }
                }
            }
        }
        count = 0;
    }
    if instruction2 is pacsIsoRecord:InstructionForNextAgent1[] {
        foreach pacsIsoRecord:InstructionForNextAgent1 instruction in instruction2 {
            if instruction.Cd == "INT" && count == 0 {
                if narration.length() % 35 < 31 && lineCount < 6 {
                    narration += "/INT/";
                    count += 1;
                } else if lineCount < 5 {
                    narration += "\n/INT/";
                    lineCount += 1;
                    count += 1;
                } else {
                    break;
                }
                if instruction.InstrInf is string {
                    string instructionInfo = instruction.InstrInf.toString();
                    foreach int i in 0 ... instructionInfo.length() - 1 {
                        if narration.length() % 35 == 0 {
                            lineCount += 1;
                            if lineCount > 5 {
                                break;
                            }
                            narration += "\n//".concat(instructionInfo.substring(i, i + 1));
                            continue;
                        }
                        narration += instructionInfo.substring(i, i + 1);
                    }
                }
            }
        }
    }
    if instruction3 is pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 {
        if instruction3.FinInstnId?.BICFI is string {
            if lineCount < 6 && (35 - ((narration.length() % 35) + 4)) <= instruction3.FinInstnId?.BICFI.toString().length() {
                narration += "/INS/".concat(instruction3.FinInstnId?.BICFI.toString());
            } else if lineCount < 5 {
                narration += "\n/INS/".concat(instruction3.FinInstnId?.BICFI.toString());
                lineCount += 1;
            }
        } else if instruction3.FinInstnId?.Nm is string {
            if lineCount < 6 && (35 - ((narration.length() % 35) + 4)) <= instruction3.FinInstnId?.Nm.toString().length() {
                narration += "/INS/".concat(instruction3.FinInstnId?.Nm.toString());
            } else if lineCount < 5 {
                narration += "\n/INS/".concat(instruction3.FinInstnId?.Nm.toString());
            }
        }
    }
    if instruction4 is pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 {
        if instruction4.FinInstnId?.BICFI is string {
            if lineCount < 6 && (35 - ((narration.length() % 35) + 5)) <= instruction4.FinInstnId?.BICFI.toString().length() {
                narration += "/INTA/".concat(instruction4.FinInstnId?.BICFI.toString());
            } else if lineCount < 5 {
                narration += "\n/INTA/".concat(instruction4.FinInstnId?.BICFI.toString());
            }
        } else if instruction4.FinInstnId?.Nm is string {
            if lineCount < 6 && (35 - ((narration.length() % 35) + 5)) <= instruction4.FinInstnId?.Nm.toString().length() {
                narration += "/INTA/".concat(instruction4.FinInstnId?.Nm.toString());
            } else if lineCount < 5 {
                narration += "\n/INTA/".concat(instruction4.FinInstnId?.Nm.toString());
                lineCount += 1;
            }
        }
    }
    return [narration, lineCount];
}

isolated function getField72(pacsIsoRecord:InstructionForCreditorAgent3[]? instruction1,
        pacsIsoRecord:InstructionForNextAgent1[]? instruction2, pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?
        instruction3 = (), pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instruction4 = (),
        pacsIsoRecord:ServiceLevel8Choice[]? serviceLevels = (), pacsIsoRecord:CategoryPurpose1Choice? categoryPurpose = (),
        pacsIsoRecord:LocalInstrument2Choice? localInstrument = ()) returns swiftmt:MT72? {
    [string, int] [narration, lineCount] = getFieldSndRcvrInfoFromAgts(instruction1, instruction2, instruction3, instruction4);
    narration = getSndRcvrInfoFromMsclns(serviceLevels, categoryPurpose, localInstrument, narration, lineCount);
    if narration.equalsIgnoreCaseAscii("") {
        return ();
    }
    return {
        name: MT72_NAME,
        Cd: {content: narration, number: NUMBER1}
    };
}

isolated function getRepeatingField72(pacsIsoRecord:CreditTransferTransaction62[] creditTransactionArray, pacsIsoRecord:CreditTransferTransaction62? transaxion = (), boolean isTransaction = false) returns swiftmt:MT72? {
    swiftmt:MT72? instruction1 = getField72(creditTransactionArray[0].InstrForCdtrAgt, creditTransactionArray[0].InstrForNxtAgt);
    foreach int i in 1 ... creditTransactionArray.length() - 1 {
        swiftmt:MT72? instruction2 = getField72(creditTransactionArray[i].InstrForCdtrAgt, creditTransactionArray[i].InstrForNxtAgt);
        if instruction1?.Cd?.content != instruction2?.Cd?.content {
            return getField72(transaxion?.InstrForCdtrAgt, transaxion?.InstrForNxtAgt);
        }
    }
    if isTransaction {
        return ();
    }
    return instruction1;
}

isolated function getField21(string? endToEndId = (), string? txId = (), string? id = ()) returns string {
    if endToEndId is string && endToEndId.length() > 4 && !(endToEndId.substring(1, 4).equalsIgnoreCaseAscii("ROC")) {
        return endToEndId;
    }
    if txId is string {
        return txId;
    }
    if id is string {
        return id;
    }
    return "";
}

isolated function getPartyIdentifierOrAccount(string? partyIdentifier, string account, string num = NUMBER2, boolean isOptionF = false) returns swiftmt:PrtyIdn? {
    if partyIdentifier is string {
        return {content: partyIdentifier, number: num};
    }
    if !account.equalsIgnoreCaseAscii("") {
        if isOptionF {
            return {content: "/" + account, number: num};
        }
        return {content: account, number: num};
    }
    return ();
}

isolated function getPartyIdentifierForField50a(pacsIsoRecord:GenericPersonIdentification2 otherId, string? countryCode) returns swiftmt:PrtyIdn {
    if otherId.Issr is string {
        return {content:otherId.SchmeNm?.Cd.toString() + "/" + countryCode.toString() + "/" + otherId.Issr.toString() + "/" + otherId.Id.toString(), number: NUMBER1};
    }
    return {content: otherId.SchmeNm?.Cd.toString() + "/" + countryCode.toString() + "/" + otherId.Id.toString(), number: NUMBER1};
} 

isolated function getField56(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account = (), boolean isOptionCPresent = false) returns swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name, 
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, 
        institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT56A fieldMt56A = {
            name: MT56A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt56A;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT56D fieldMt56D = {
            name: MT56D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt56D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT56C fieldMt56C = {
            name: MT56C_NAME,
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return fieldMt56C;
    }
    if partyIdentifier is string {
        swiftmt:MT56A fieldMt56A = {
            name: MT56A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt56A;
    }
    return ();
}

isolated function getField56Alt(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, string? partyIdentifier, string? iban = (), string? bban = (), boolean isOptionCPresent = false) returns [swiftmt:MT56A?, swiftmt:MT56C?, swiftmt:MT56D?]|error {
    if identifierCode is string {
        swiftmt:MT56A fieldMt56A = {
            name: MT56A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return [fieldMt56A];
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT56D fieldMt56D = {
            name: MT56D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return [(), (), fieldMt56D];
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT56C fieldMt56C = {
            name: MT56C_NAME,
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return [(), fieldMt56C];
    }
    if partyIdentifier is string {
        swiftmt:MT56A fieldMt56A = {
            name: MT56A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return [fieldMt56A];
    }
    return [];
}

isolated function getField57(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false, boolean isOptionCPresent = false) returns swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name, 
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, 
        institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT57A fieldMt57A = {
            name: MT57A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt57A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT57D fieldMt57D = {
            name: MT57D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt57D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT57C fieldMt57C = {
            name: MT57C_NAME,
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return fieldMt57C;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT57B fieldMt57B = {
            name: MT57B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt57B;
    }
    if partyIdentifier is string {
        swiftmt:MT57A fieldMt57A = {
            name: MT57A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt57A;
    }
    return ();
}

isolated function getField57Alt(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, string? partyIdentifier, string? iban = (), string? bban = (), boolean isOptionBPresent = false, boolean isOptionCPresent = false) returns [swiftmt:MT57A?, swiftmt:MT57B?, swiftmt:MT57C?, swiftmt:MT57D?]|error {
    if identifierCode is string {
        swiftmt:MT57A fieldMt57A = {
            name: MT57A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return [fieldMt57A];
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT57D fieldMt57D = {
            name: MT57D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return [(), (), (), fieldMt57D];
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT57C fieldMt57C = {
            name: MT57C_NAME,
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return [(), (), fieldMt57C];
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT57B fieldMt57B = {
            name: MT57B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return [(), fieldMt57B];
    }
    if partyIdentifier is string {
        swiftmt:MT57A fieldMt57A = {
            name: MT57A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return [fieldMt57A];
    }
    return [];
}

isolated function getLocation(swiftmt:AdrsLine[]? address) returns swiftmt:Lctn? {
    if address is swiftmt:AdrsLine[] {
        return {content: address[0].content, number: NUMBER3};
    }
    return ();
}

isolated function getAccountId(string? iban, string? bban) returns string {
    if iban is string {
        return iban;
    }
    if bban is string {
        return bban;
    }
    return "";
}

isolated function getField25(string? iban, string? bban) returns swiftmt:MT25A? {
    if iban is string || bban is string {
        return {name: "25", Acc: {content: getAccountId(iban, bban)}};
    }
    return ();
}

isolated function getField52(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account = (), boolean isOptionBPresent = false, boolean isOptionCPresent = false) returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name, 
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, 
        institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT52A fieldMt52A = {
            name: "52A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt52A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT52D fieldMt52D = {
            name: "52D",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt52D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT52C fieldMt52C = {
            name: "52C",
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return fieldMt52C;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT52B fieldMt52B = {
            name: "52B",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt52B;
    }
    if partyIdentifier is string {
        swiftmt:MT52A fieldMt52A = {
            name: "52A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt52A;
    }
    return ();
}

isolated function getField52Alt(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, string? partyIdentifier, string? iban = (), string? bban = (), boolean isOptionBPresent = false, boolean isOptionCPresent = false) returns [swiftmt:MT52A?, swiftmt:MT52B?, swiftmt:MT52C?, swiftmt:MT52D?]|error {
    if identifierCode is string {
        swiftmt:MT52A fieldMt52A = {
            name: MT52A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return [fieldMt52A];
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT52D fieldMt52D = {
            name: MT52D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return [(), (), (), fieldMt52D];
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT52C fieldMt52C = {
            name: MT52C_NAME,
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return [(), (), fieldMt52C];
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT52B fieldMt52B = {
            name: MT52B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return [(), fieldMt52B];
    }
    if partyIdentifier is string {
        swiftmt:MT52A fieldMt52A = {
            name: MT52A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return [fieldMt52A];
    }
    return [];
}

isolated function getField50a(pacsIsoRecord:PartyIdentification272? debtor, pacsIsoRecord:AccountIdentification4Choice? account = (), boolean isSecondType = false, boolean isOptionFPresent = true) returns swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, pacsIsoRecord:GenericPersonIdentification2[]?, string?, string?] 
        [identifierCode, name, address, iban, bban, otherId, townName, countryCode] = [debtor?.Id?.OrgId?.AnyBIC, debtor?.Nm, 
        debtor?.PstlAdr?.AdrLine, account?.IBAN, account?.Othr?.Id, debtor?.Id?.PrvtId?.Othr, debtor?.PstlAdr?.TwnNm, debtor?.PstlAdr?.Ctry];
    if identifierCode is string && isSecondType {
        swiftmt:MT50G fieldMt50G = {
            name: MT50G_NAME,
            Acc: {content: getAccountId(iban, bban), number: NUMBER1},
            IdnCd: {content: getMandatoryField(identifierCode), number: NUMBER2}
        };
        return fieldMt50G;
    }
    if identifierCode is string {
        swiftmt:MT50A fieldMt50A = {
            name: MT50A_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            IdnCd: {content: getMandatoryField(identifierCode), number: NUMBER2}
        };
        return fieldMt50A;
    }
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] && otherId[0].Id is string && isOptionFPresent{
        swiftmt:MT50F fieldMt50F = {
            name: MT50F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode),
            PrtyIdn: getPartyIdentifierForField50a(otherId[0], countryCode),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode)
        };
        return fieldMt50F;
    }
    if ((!getAccountId(iban, bban).equalsIgnoreCaseAscii("") && address is pacsIsoRecord:Max70Text[]) || (townName is string || countryCode is string)) && isOptionFPresent{
        swiftmt:MT50F fieldMt50F = {
            name: "50F",
            CdTyp: getCodeType(name, address, townName, countryCode),
            PrtyIdn: check getPartyIdentifierOrAccount((), getAccountId(iban, bban), NUMBER1).ensureType(),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode)
        };
        return fieldMt50F;
    }
    if (name is string || address is pacsIsoRecord:Max70Text[] || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isSecondType {
        swiftmt:MT50H fieldMt50H = {
            name: MT50H_NAME,
            Acc: {content: getAccountId(iban, bban), number: NUMBER1},
            Nm: [{content: getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address, 3)
        };
        return fieldMt50H;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] || !getAccountId(iban, bban).equalsIgnoreCaseAscii("") {
        swiftmt:MT50K fieldMt50K = {
            name: MT50K_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt50K;
    }
    return ();
}

isolated function getCodeType(string? name, pacsIsoRecord:Max70Text[]? address, string? townName = (), string? countryCode = ()) returns swiftmt:CdTyp[] {
    swiftmt:CdTyp[] codeType = [];
    int count = 2;
    if name is string {
        codeType.push({content: NUMBER1, number: count.toString()});
        count += 2;
    }
    if address is pacsIsoRecord:Max70Text[] && address.length() < 3 && (townName is string || countryCode is string) {
        foreach int i in 0 ... address.length() - 1 {
            codeType.push({content: NUMBER2, number: count.toString()});
            count += 2;
        }
        codeType.push({content: NUMBER3, number: count.toString()});
        return codeType;
    }

    if address is pacsIsoRecord:Max70Text[] && address.length() < 4 {
        foreach int i in 0 ... address.length() - 1 {
            codeType.push({content: NUMBER2, number: count.toString()});
            count += 2;
        }
        return codeType;
    }
    if (townName is string || countryCode is string) && address !is pacsIsoRecord:Max70Text[] {
        codeType.push({content: NUMBER3, number: count.toString()});
    }
    return codeType;
}

isolated function getField50Or50COr50L(pacsIsoRecord:PartyIdentification272? agent) returns swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, pacsIsoRecord:GenericPersonIdentification2[]?] [identifierCode, name, address, otherId] = [agent?.Id?.OrgId?.AnyBIC, agent?.Nm, agent?.PstlAdr?.AdrLine, agent?.Id?.PrvtId?.Othr];
    if identifierCode is string {
        swiftmt:MT50C fieldMt50C = {name: MT50C_NAME, IdnCd: {content: identifierCode, number: NUMBER1}};
        return fieldMt50C;
    }
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] && otherId[0].Id is string {
        swiftmt:MT50L fieldMt50L = {name: MT50L_NAME, PrtyIdn: {content: getMandatoryField(otherId[0].Id), number: NUMBER1}};
        return fieldMt50L;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT50 fieldMt50 = {
            name: MT50_NAME,
            Nm: [{content: getMandatoryField(name), number: NUMBER1}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt50;
    }
    return ();
}

isolated function getAccount(string account) returns swiftmt:Acc? {
    if !account.equalsIgnoreCaseAscii("") {
        return {content: account, number: NUMBER1};
    }
    return ();
}

isolated function getFieldMt13C(string? closeTime, string? creditTime, string? debitTime) returns swiftmt:MT13C? {
    string isoTime = "";
    string swiftTime = "";
    string sign = "";
    string timeOffSet = "";
    string code = "";
    if closeTime is string {
        isoTime = closeTime;
        swiftTime = isoTime.substring(0, 2) + isoTime.substring(3, 5);
        code = "CLSTIME";
    } else if creditTime is string {
        isoTime = creditTime;
        swiftTime = isoTime.substring(11, 13) + isoTime.substring(14, 15);
        code = "RNCTIME";
    } else if debitTime is string {
        isoTime = debitTime;
        swiftTime = isoTime.substring(11, 13) + isoTime.substring(14, 15);
        code = "SNDTIME";
    } else {
        return ();
    }
    foreach int i in 0 ... isoTime.length() - 1 {
        if isoTime.substring(i, i + 1).equalsIgnoreCaseAscii("+") || isoTime.substring(i, i + 1).equalsIgnoreCaseAscii("-") {
            sign = isoTime.substring(i, i + 1);
            if i + 5 <= isoTime.length() - 1 {
                timeOffSet = isoTime.substring(i + 1, i + 3) + isoTime.substring(i + 4, i + 6);
            }
        }
    }
    return {
        name: MT13C_NAME,
        Cd: {content: code, number: NUMBER1},
        Tm: {content: swiftTime, number: NUMBER2},
        Sgn: {content: sign, number: NUMBER3},
        TmOfst: {content: timeOffSet, number: NUMBER4}
    };
}

isolated function getField58(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account) returns swiftmt:MT58A?|swiftmt:MT58D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name, 
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, 
        institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT58A fieldMt58A = {
            name: "58A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt58A;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT58D fieldMt58D = {
            name: "58D",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt58D;
    }
    if partyIdentifier is string {
        swiftmt:MT58A fieldMt58A = {
            name: "58A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt58A;
    }
    return ();
}

isolated function getField54(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false) returns swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name, 
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, 
        institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT54A fieldMt54A = {
            name: MT54A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt54A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT54D fieldMt54D = {
            name: MT54D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt54D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT54B fieldMt54B = {
            name: MT54B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt54B;
    }
    if partyIdentifier is string {
        swiftmt:MT54A fieldMt54A = {
            name: MT54A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt54A;
    }
    return ();
}

isolated function getField53(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false, boolean isOptionCPresent = false) returns swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name, 
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, 
        institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT53A fieldMt53A = {
            name: MT53A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt53A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT53D fieldMt53D = {
            name: MT53D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt53D;
    }
    if !getAccountId(iban, bban).equalsIgnoreCaseAscii("") && isOptionCPresent {
        swiftmt:MT53C fieldMt53C = {
            name: MT53C_NAME,
            Acc: {content: getAccountId(iban, bban), number: NUMBER1}
        };
        return fieldMt53C;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT53B fieldMt53B = {
            name: MT53B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getOptionalAddressLine(address))
        };
        return fieldMt53B;
    }
    if partyIdentifier is string {
        swiftmt:MT53A fieldMt53A = {
            name: MT53A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt53A;
    }
    return ();
}

isolated function getOrignalMessageName(string? messageName) returns string {
    if messageName !is string {
        return "";
    }
    match messageName {
        "pain.001" => {
            return "101";
        }
        "pacs.008" => {
            return "103";
        }
        "pacs.003" => {
            return "104";
        }
        "pacs.009" => {
            return "202";
        }
        "pacs.010" => {
            return "204";
        }
    }
    if messageName.substring(2).matches(re `[1-2]0[0-9]{1}`) {
        return messageName.substring(2);
    }
    return "";
}

isolated function getField79(camtIsoRecord:PaymentCancellationReason6[]? cancelReason) returns swiftmt:MT79? {
    if cancelReason is camtIsoRecord:PaymentCancellationReason6[] && cancelReason[0].Rsn?.Cd is camtIsoRecord:ExternalCancellationReason1Code {
        swiftmt:Nrtv[] narration = [];
        string reasonInfo = "/" + getMandatoryField(cancelReason[0].Rsn?.Cd);
        camtIsoRecord:Max105Text[]? additionalInfoArray = cancelReason[0].AddtlInf;
        if additionalInfoArray is camtIsoRecord:Max105Text[] {
            reasonInfo += "/";
            int count = 1;
            foreach string additionalInfo in additionalInfoArray {
                foreach int i in 0 ... additionalInfo.length() - 1 {
                    if reasonInfo.length() == 35 {
                        narration.push({content: reasonInfo, number: count.toString()});
                        reasonInfo = "//";
                        count += 1;
                    }
                    reasonInfo += additionalInfo.substring(i, i + 1);
                }
                reasonInfo += " ";
            }
            return {name: MT79_NAME, Nrtv: narration};
        }
        return {name: MT79_NAME, Nrtv: [{content: reasonInfo, number: NUMBER1}]};
    }
    return ();
}

isolated function getField76(camtIsoRecord:CancellationStatusReason5[]? cancelStatusReason, camtIsoRecord:ExternalInvestigationExecutionConfirmation1Code? status) returns [swiftmt:MT76, swiftmt:MT77A?] {
    string narration = "/";
    string narration2 = "";
    if status !is camtIsoRecord:ExternalInvestigationExecutionConfirmation1Code {
        return [{Nrtv: {content: "", number: NUMBER1}, name: MT76_NAME}, ()];
    }
    narration += status;
    int lineCount = 1;
    int lineCount2 = 1;
    if cancelStatusReason is camtIsoRecord:CancellationStatusReason5[] {
        foreach camtIsoRecord:CancellationStatusReason5 reason in cancelStatusReason {
            string reasonCode = getMandatoryField(reason.Rsn?.Cd);
            if reasonCode.equalsIgnoreCaseAscii("") {
                if lineCount > 6 {
                    return [
                        {name: MT76_NAME, Nrtv: {content: narration, number: NUMBER1}},
                        {name: MT77A_NAME, Nrtv: {content: narration2, number: NUMBER1}}
                    ];
                }
                return [{Nrtv: {content: narration, number: NUMBER1}, name: MT76_NAME}, ()];
            }
            if lineCount > 6 && lineCount2 <= 20 {
                narration2 += "/".concat(reasonCode.concat("/"));
            } else if lineCount == 1 {
                narration += "/".concat(reasonCode.concat(" "));
            } else {
                narration += "/".concat(reasonCode.concat("/"));
            }
            camtIsoRecord:Max105Text[]? additionalInfoArray = reason.AddtlInf;
            if additionalInfoArray is camtIsoRecord:Max105Text[] {
                foreach camtIsoRecord:Max105Text additionalInfo in additionalInfoArray {
                    if lineCount > 6 {
                        if lineCount2 < 20 {
                            narration2 += additionalInfo.concat("\n//");
                            lineCount2 += 1;
                            continue;
                        }
                        if lineCount2 > 20 {
                            return [
                                {name: MT76_NAME, Nrtv: {content: narration, number: NUMBER1}},
                                {name: MT77A_NAME, Nrtv: {content: narration2, number: NUMBER1}}
                            ];
                        }
                        narration2 += additionalInfo.concat("\n");
                        lineCount2 += 1;
                        continue;
                    }
                    if lineCount < 6 {
                        narration += additionalInfo.concat("\n//");
                        lineCount += 1;
                        continue;
                    }
                    narration += additionalInfo.concat("\n");
                    lineCount += 1;
                }
            }
        }
        if lineCount > 6 {
            return [
                {name: MT76_NAME, Nrtv: {content: narration, number: NUMBER1}},
                {name: MT77A_NAME, Nrtv: {content: narration2, number: NUMBER1}}
            ];
        }
        return [{name: MT76_NAME, Nrtv: {content: narration, number: NUMBER1}}, ()];
    }
    return [{Nrtv: {content: narration, number: NUMBER1}, name: MT76_NAME}, ()];
}

isolated function getField59a(pacsIsoRecord:PartyIdentification272? creditor, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionFPresent = true) returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?, string?] 
        [identifierCode, name, address, iban, bban, townName, countryCode] = [creditor?.Id?.OrgId?.AnyBIC, creditor?.Nm, 
        creditor?.PstlAdr?.AdrLine, account?.IBAN, account?.Othr?.Id, creditor?.PstlAdr?.TwnNm, creditor?.PstlAdr?.Ctry];
    if identifierCode is string {
        swiftmt:MT59A fieldMt59A = {
            name: MT59A_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER2}
        };
        return fieldMt59A;
    }
    if ((name is string && address is pacsIsoRecord:Max70Text[]) || (townName is string || countryCode is string)) && isOptionFPresent {
        swiftmt:MT59F fieldMt59F = {
            name: MT59F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode),
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode)
        };
        return fieldMt59F;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] || !(getAccountId(iban, bban).equalsIgnoreCaseAscii("")) {
        swiftmt:MT59 fieldMt59 = {
            name: MT59_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt59;
    }
    return ();
}

isolated function getField33BOptional(pacsIsoRecord:ActiveOrHistoricCurrencyAndAmount? instrdAmt) returns swiftmt:MT33B?|error {
    if instrdAmt is pacsIsoRecord:ActiveOrHistoricCurrencyAndAmount {
        return {
            name: "33B",
            Ccy: {content: instrdAmt.Ccy, number: NUMBER1},
            Amnt: {content: check convertToString(instrdAmt.content), number: NUMBER2}
        };
    }
    return ();
}

isolated function getField70(pacsIsoRecord:Max140Text[]? remmitanceInfoArray) returns swiftmt:MT70? {
    string information = "";
    int count = 1;
    if remmitanceInfoArray is pacsIsoRecord:Max140Text[] {
        if remmitanceInfoArray.length() == 0 {
            return ();
        }
        foreach int i in 0 ... remmitanceInfoArray.length() - 1 {
            if i == remmitanceInfoArray.length() - 1 || count == 4 {
                information += remmitanceInfoArray[i];
                break;
            }
            information += remmitanceInfoArray[i] + "\n";
            count += 1;
        }
        return {
            name: "70",
            Nrtv: {content: information, number: NUMBER1}
        };
    }
    return ();
}

isolated function getField77B(pacsIsoRecord:RegulatoryReporting3[]? rgltryRptg) returns swiftmt:MT77B? {
    if rgltryRptg is pacsIsoRecord:RegulatoryReporting3[] {
        pacsIsoRecord:StructuredRegulatoryReporting3[]? details = rgltryRptg[0].Dtls;
        if details is pacsIsoRecord:StructuredRegulatoryReporting3[] {
            pacsIsoRecord:Max10Text? code = details[0].Cd;
            pacsIsoRecord:Max10Text? country = details[0].Ctry;
            pacsIsoRecord:Max35Text[]? infoArray = details[0].Inf;
            if code is pacsIsoRecord:Max10Text && country is pacsIsoRecord:Max10Text {
                string narration = "//";
                int lineCount = 1;
                int charCount = 0;
                if infoArray is pacsIsoRecord:Max35Text[] {
                    foreach pacsIsoRecord:Max35Text information in infoArray {
                        if lineCount > 3 {
                            break;
                        }
                        foreach int i in 0 ... information.length() - 1 {
                            if lineCount > 3 {
                                break;
                            }
                            if (lineCount == 1 && narration.length() == 23) || charCount == 35 {
                                narration += "\n//".concat(information.substring(i, i + 1));
                                lineCount += 1;
                                charCount = 3;
                                continue;
                            }
                            narration += information.substring(i, i + 1);
                            charCount += 1;
                        }
                    }
                    return {name: MT77B_NAME, Nrtv: {content: "/" + code + "/" + country + narration, number: NUMBER1}};
                }
                return {name: MT77B_NAME, Nrtv: {content: "/" + code + "/" + country, number: NUMBER1}};
            }
            return ();
        }
        return ();
    }
    return ();
}

isolated function getField36(pacsIsoRecord:BaseOneRate? exchangeRate) returns swiftmt:MT36?|error {
    if exchangeRate is pacsIsoRecord:BaseOneRate {
        return {
            name: MT36_NAME,
            Rt: {content: check convertToString(exchangeRate), number: NUMBER1}
        };
    }
    return ();
}

isolated function getField51A(pacsIsoRecord:FinancialInstitutionIdentification23? institution) returns swiftmt:MT51A? {
    [string?, string?] [identifierCode, partyIdentifier] = [institution?.BICFI, institution?.ClrSysMmbId?.ClrSysId?.Cd];
    if identifierCode is string {
        swiftmt:MT51A fieldMt51A = {
            name: MT51A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, ""),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt51A;
    }
    return ();
}

isolated function getfield23EForMt101(painIsoRecord:InstructionForCreditorAgent3[]? instruction1, painIsoRecord:InstructionForDebtorAgent1? instruction2, pacsIsoRecord:ServiceLevel8Choice[]? instruction3, painIsoRecord:CategoryPurpose1Choice? instruction4) returns swiftmt:MT23E[]? {
    swiftmt:MT23E[] field23E = [];
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

    if instruction1 !is painIsoRecord:InstructionForCreditorAgent3[] && instruction2 !is painIsoRecord:InstructionForDebtorAgent1
        && instruction3 !is pacsIsoRecord:ServiceLevel8Choice[] && instruction4 !is painIsoRecord:CategoryPurpose1Choice {
        return ();
    }

    if instruction1 is painIsoRecord:InstructionForCreditorAgent3[] {
        foreach painIsoRecord:InstructionForCreditorAgent3 instruction in instruction1 {
            if MT_101_INSTRC_CD.indexOf(instruction.Cd.toString()) == () {
                log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
            }
            swiftmt:AddInfo? addInfo = ();
            if instruction.InstrInf is painIsoRecord:Max140Text {
                if instruction.InstrInf.toString().length() > 30 {
                    addInfo = {content: instruction.InstrInf.toString().substring(0, 30), number: NUMBER2};
                } else {
                    addInfo = {content: instruction.InstrInf.toString(), number: NUMBER2};
                }
            }
            field23E.push({
                name: MT23E_NAME,
                InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1},
                AddInfo: addInfo
            });
        }
    }

    if instruction2 is painIsoRecord:InstructionForDebtorAgent1 {
        swiftmt:AddInfo? addInfo = ();
        if MT_101_INSTRC_CD.indexOf(instruction2.Cd.toString()) == () {
            log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
        }
        if instruction2.InstrInf is painIsoRecord:Max140Text {
            if instruction2.InstrInf.toString().length() > 30 {
                addInfo = {content: instruction2.InstrInf.toString().substring(0, 30), number: NUMBER2};
            } else {
                addInfo = {content: instruction2.InstrInf.toString(), number: NUMBER2};
            }
        }
        field23E.push({
            name: MT23E_NAME,
            InstrnCd: {content: instruction2.Cd.toString(), number: NUMBER1},
            AddInfo: addInfo
        });
    }

    if instruction3 is pacsIsoRecord:ServiceLevel8Choice[] {
        foreach pacsIsoRecord:ServiceLevel8Choice instruction in instruction3 {
            if MT_101_INSTRC_CD.indexOf(instruction.Cd.toString()) == () {
                log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
            }
            field23E.push({
                name: MT23E_NAME,
                InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1}
            });
        }
    }

    if instruction4 is painIsoRecord:CategoryPurpose1Choice {
        if MT_101_INSTRC_CD.indexOf(instruction4.Cd.toString()) == () {
            log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
        }
        field23E.push({
            name: MT23E_NAME,
            InstrnCd: {content: instruction4.Cd.toString(), number: NUMBER1}
        });
    }
    return field23E;
}

# Get the ordering customer from the Pain001 document.
#
# + payments - The array of payment instructions.
# + transaxion - The payment instruction of the mapping transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The ordering customer or an empty record
isolated function getMT101OrderingCustomerFromPain001Document(painIsoRecord:PaymentInstruction44[] payments, painIsoRecord:PaymentInstruction44? transaxion = (), boolean isTransaction = false)
returns swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F?|error {
    string? partyIdentifier = ();
    painIsoRecord:GenericPersonIdentification2[]? otherId = payments[0].Dbtr.Id?.PrvtId?.Othr;
    if otherId is painIsoRecord:GenericPersonIdentification2[] {
        partyIdentifier = otherId[0].Id;
    }
    [string?, string?, string?] [iban, bban, identifierCode] = [payments[0].DbtrAcct?.Id?.IBAN, payments[0].DbtrAcct?.Id?.Othr?.Id, payments[0].Dbtr.Id?.OrgId?.AnyBIC];
    foreach int i in 1 ... payments.length() - 1 {
        string? partyIdentifier2 = ();
        painIsoRecord:GenericPersonIdentification2[]? otherId2 = payments[i].Dbtr.Id?.PrvtId?.Othr;
        if otherId2 is painIsoRecord:GenericPersonIdentification2[] {
            partyIdentifier2 = otherId2[0].Id;
        }
        if iban != payments[i].DbtrAcct?.Id?.IBAN || bban != payments[i].DbtrAcct?.Id?.Othr?.Id || identifierCode != payments[i].Dbtr.Id?.OrgId?.AnyBIC || partyIdentifier != partyIdentifier2 {
            return getField50a(transaxion?.Dbtr, transaxion?.DbtrAcct?.Id, true);
        }
    }
    if isTransaction {
        return ();
    }
    return getField50a(payments[0].Dbtr, payments[0].DbtrAcct?.Id, true);
}

# Get the account servicing institution from the Pain001 document.
#
# + payments - The array of payment instructions.
# + transaxion - The payment instruction of the mapping transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The account servicing institution or an empty record
isolated function getMT101AccountServicingInstitutionFromPain001Document(painIsoRecord:PaymentInstruction44[] payments, painIsoRecord:PaymentInstruction44? transaxion = (), boolean isTransaction = false)
returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {
    [string?, string?, string?, string?] [iban, bban, identifierCode, partyIdentifier] = [payments[0].DbtrAgtAcct?.Id?.IBAN, payments[0].DbtrAgtAcct?.Id?.Othr?.Id, payments[0].DbtrAgt?.FinInstnId?.BICFI, payments[0].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd];
    foreach int i in 1 ... payments.length() - 1 {
        if iban != payments[i].DbtrAgtAcct?.Id?.IBAN || bban != payments[i].DbtrAgtAcct?.Id?.Othr?.Id || identifierCode != payments[i].DbtrAgt?.FinInstnId?.BICFI || partyIdentifier != payments[i].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd {
            return getField52(transaxion?.DbtrAgt?.FinInstnId, transaxion?.DbtrAgtAcct?.Id, isOptionCPresent = true);
        }
    }
    if isTransaction {
        return ();
    }
    return getField52(payments[0].DbtrAgt?.FinInstnId, payments[0].DbtrAgtAcct?.Id, isOptionCPresent = true);
}

isolated function getRepeatingField26TForPacs008(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx, pacsIsoRecord:Purpose2Choice? purp = (), boolean isTransaction = false) returns swiftmt:MT26T? {
    string? purpose = crdtTrfTx[0].Purp?.Cd;
    foreach int i in 1 ... crdtTrfTx.length() - 1 {
        if purpose != crdtTrfTx[i].Purp?.Cd {
            return getField26T(purp?.Cd);
        }
    }
    if isTransaction {
        return ();
    }
    return getField26T(purpose);
}

# Get the ordering customer from the Pacs008 document.
#
# + crdtTrfTx - The array of credit transactions
# + transaxion - The current credit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The ordering customer or null record
isolated function getOrderingCustomerFromPacs008Document(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx, pacsIsoRecord:CreditTransferTransaction64? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F?|error {
    string? partyIdentifier = ();
    pacsIsoRecord:GenericPersonIdentification2[]? otherId = crdtTrfTx[0].Dbtr.Id?.PrvtId?.Othr;
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] {
        partyIdentifier = otherId[0].Id;
    }
    [string?, string?, string?] [iban, bban, identifierCode] = [crdtTrfTx[0].DbtrAcct?.Id?.IBAN, crdtTrfTx[0].DbtrAcct?.Id?.Othr?.Id, crdtTrfTx[0].Dbtr.Id?.OrgId?.AnyBIC];
    foreach int i in 1 ... crdtTrfTx.length() - 1 {
        string? partyIdentifier2 = ();
        pacsIsoRecord:GenericPersonIdentification2[]? otherId2 = crdtTrfTx[i].Dbtr.Id?.PrvtId?.Othr;
        if otherId2 is pacsIsoRecord:GenericPersonIdentification2[] {
            partyIdentifier2 = otherId2[0].Id;
        }
        if iban != crdtTrfTx[i].DbtrAcct?.Id?.IBAN || bban != crdtTrfTx[i].DbtrAcct?.Id?.Othr?.Id || identifierCode != crdtTrfTx[i].Dbtr.Id?.OrgId?.AnyBIC || partyIdentifier != partyIdentifier2 {
            return getField50a(transaxion?.Dbtr, transaxion?.DbtrAcct?.Id);
        }
    }
    if isTransaction {
        return ();
    }
    return getField50a(crdtTrfTx[0].Dbtr, crdtTrfTx[0].DbtrAcct?.Id);
}

isolated function getRepeatingField26TForPacs003(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, pacsIsoRecord:Purpose2Choice? purp = (), boolean isTransaction = false) returns swiftmt:MT26T? {
    string? purpose = dbtTrfTx[0].Purp?.Cd;
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if purpose != dbtTrfTx[i].Purp?.Cd {
            return getField26T(purp?.Cd);
        }
    }
    if isTransaction {
        return ();
    }
    return getField26T(purpose);
}

isolated function getField26T(string? code) returns swiftmt:MT26T? {
    if code is string && code.matches(re `[A-Z0-9]{3}`){
        return {
            name: MT26T_NAME,
            Typ: {content: getMandatoryField(code), number: NUMBER1}
        };
    }
    return ();
}

isolated function getRepeatingField71AForPacs008(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx, pacsIsoRecord:ChargeBearerType1Code? chrgBr = (), boolean isTransaction = false) returns swiftmt:MT71A? {
    pacsIsoRecord:ChargeBearerType1Code? chargeBearer = crdtTrfTx[0].ChrgBr;
    foreach int i in 1 ... crdtTrfTx.length() - 1 {
        if chargeBearer != crdtTrfTx[i].ChrgBr {
            return {
                name: MT71A_NAME,
                Cd: getDetailsOfChargesFromChargeBearerType1Code(chrgBr)
            };
        }
    }
    if isTransaction {
        return ();
    }
    return {
        name: MT71A_NAME,
        Cd: getDetailsOfChargesFromChargeBearerType1Code(chargeBearer)
    };
}

isolated function getRepeatingField71AForPacs003(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, pacsIsoRecord:ChargeBearerType1Code? chrgBr = (), boolean isTransaction = false) returns swiftmt:MT71A? {
    pacsIsoRecord:ChargeBearerType1Code? chargeBearer = dbtTrfTx[0].ChrgBr;
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if chargeBearer != dbtTrfTx[i].ChrgBr {
            return {
                name: "71A",
                Cd: getDetailsOfChargesFromChargeBearerType1Code(chrgBr)
            };
        }
    }
    if isTransaction {
        return ();
    }
    return {
        name: "71A",
        Cd: getDetailsOfChargesFromChargeBearerType1Code(chargeBearer)
    };
}

isolated function getRepeatingField77BForPacs008(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx, pacsIsoRecord:CreditTransferTransaction64? transaxion = (), boolean isTransaction = false) returns swiftmt:MT77B? {
    swiftmt:MT77B? regulatoryReport = getField77B(crdtTrfTx[0].RgltryRptg);
    foreach int i in 1 ... crdtTrfTx.length() - 1 {
        swiftmt:MT77B? regulatoryReport2 = getField77B(crdtTrfTx[i].RgltryRptg);
        if regulatoryReport?.Nrtv?.content != regulatoryReport2?.Nrtv?.content {
            return getField77B(transaxion?.RgltryRptg);
        }
    }
    if isTransaction {
        return ();
    }
    return regulatoryReport;
}

isolated function getRepeatingField23EForPacs003(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, string? ctgryPurp = (), boolean isTransaction = false) returns swiftmt:MT23E? {
    string? purpose = dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd;
    string[] ctgryPurpCode = ["OTHR", "NAUT", "AUTH"];
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if purpose.toString() != dbtTrfTx[i].PmtTpInf?.CtgyPurp?.Cd.toString() 
            && ctgryPurpCode.indexOf(ctgryPurp.toString()) !is () {
                return {
                    name: MT23E_NAME,
                    InstrnCd: {content: ctgryPurp.toString(), number: NUMBER1}
                };
        }
    }
    if isTransaction {
        return ();
    }
    if ctgryPurpCode.indexOf(purpose.toString()) !is () {
        return {
            name: MT23E_NAME,
            InstrnCd: {content: purpose.toString(), number: NUMBER1}
        };
    }
    return ();
}

isolated function getRepeatingField77BForPacs003(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, pacsIsoRecord:RegulatoryReporting3[]? rgltryRptg = (), boolean isTransaction = false) returns swiftmt:MT77B? {
    swiftmt:MT77B? regulatoryReport = getField77B(dbtTrfTx[0].RgltryRptg);
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        swiftmt:MT77B? regulatoryReport2 = getField77B(dbtTrfTx[i].RgltryRptg);
        if regulatoryReport?.Nrtv?.content != regulatoryReport2?.Nrtv?.content {
            return getField77B(rgltryRptg);
        }
    }
    if isTransaction {
        return ();
    }
    return regulatoryReport;
}

isolated function getField25A(painIsoRecord:CashAccount40? chargesAcct) returns swiftmt:MT25A? {
    if chargesAcct?.Id?.IBAN is painIsoRecord:IBAN2007Identifier {
        return {
            name: MT25A_NAME,
            Acc: {content: chargesAcct?.Id?.IBAN.toString(), number: NUMBER1}};
    }
    if chargesAcct?.Id?.Othr?.Id is painIsoRecord:Max34Text {
        return {
            name: MT25A_NAME,
            Acc: {content: chargesAcct?.Id?.Othr?.Id.toString(), number: NUMBER1}};
    }
    return ();
}

isolated function getRepeatingField36(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx, pacsIsoRecord:BaseOneRate? rate = (), boolean isTransaction = false) returns swiftmt:MT36?|error {
    pacsIsoRecord:BaseOneRate? xchgRate = crdtTrfTx[0].XchgRate;
    foreach int i in 1 ... crdtTrfTx.length() - 1 {
        if xchgRate != crdtTrfTx[i].XchgRate {
            return getField36(rate);
        }
    }
    if isTransaction {
        return ();
    }
    return getField36(xchgRate);
}

isolated function getField19(decimal? controlSum) returns swiftmt:MT19?|error {
    if controlSum is () {
        return ();
    }
    return {name: MT19_NAME, Amnt: {content: check convertToString(controlSum), number: NUMBER1}};
}

// # Convert the charges from the MX message to the MT71G message.
// #
// # + charges - The charges from the MX message.
// # + chargeBearer - The charge bearer from the MX message.
// # + return - The MT71G message or an error if the conversion fails.
// isolated function convertCharges16toMT71G(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx) returns swiftmt:MT71G?|error {
//     decimal mxTotalAmount = 0.0;
//     string? mtCurrency = ();
//     string mtAmount = "";

//     foreach pacsIsoRecord:CreditTransferTransaction64 transaxion in crdtTrfTx {
//         if transaxion.ChrgBr == "DEBT" {
//             painIsoRecord:Charges16[]? charges = transaxion.ChrgsInf;
//             if charges is painIsoRecord:Charges16[] {
//                 foreach painIsoRecord:Charges16 charge in charges {
//                     string currentCurrency = charge.Amt.Ccy;
//                     if mtCurrency is () {
//                         mtCurrency = currentCurrency;
//                     }
//                     if mtCurrency != currentCurrency {
//                         return error("All charges must have the same currency (Error Code: T20045).");
//                     }
//                     mxTotalAmount += charge.Amt.content;
//                 }
//             }
//         }
//     }

//     mtAmount = convertDecimalNumberToSwiftDecimal(mxTotalAmount);
//     if mtAmount.length() > 15 {
//         return error("Amount exceeds maximum length of 15 characters.");
//     }

//     if mtAmount == "0" || mtAmount == "0.0" {
//         return error("Amount cannot be zero (Error Code: D57).");
//     }

//     swiftmt:MT71G mt71g = {
//         name: MT71G_NAME,
//         Ccy: {content: mtCurrency ?: "", number: NUMBER1},
//         Amnt: {content: mtAmount, number: NUMBER1}
//     };

//     return mt71g;
// }

isolated function getField33B(pacsIsoRecord:ActiveOrHistoricCurrencyAndAmount? instdAmt, pacsIsoRecord:ActiveCurrencyAndAmount? intrBkSttlmAmt, boolean isUnderlyingTransaction = false) returns swiftmt:MT33B?|error {
    if instdAmt is pacsIsoRecord:ActiveOrHistoricCurrencyAndAmount &&
        intrBkSttlmAmt is pacsIsoRecord:ActiveCurrencyAndAmount {
        if instdAmt.content
                != intrBkSttlmAmt.content {
            return {
                name: MT33B_NAME,
                Ccy: {content: instdAmt.Ccy, number: NUMBER1},
                Amnt: {content: check convertToString(instdAmt.content), number: NUMBER2}
            };
        }
        return ();
    }
    if instdAmt is pacsIsoRecord:ActiveOrHistoricCurrencyAndAmount && isUnderlyingTransaction {
        return {
            name: MT33B_NAME,
            Ccy: {content: instdAmt.Ccy, number: NUMBER1},
            Amnt: {content: check convertToString(instdAmt.content), number: NUMBER2}
        };
    }
    return ();
}

isolated function getField55(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false) returns swiftmt:MT55A?|swiftmt:MT55B?|swiftmt:MT55D? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name, 
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT55A fieldMt55A = {
            name: MT55A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt55A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT55D fieldMt55D = {
            name: MT55D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt55D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT55B fieldMt55B = {
            name: MT55B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt55B;
    }
    if partyIdentifier is string {
        swiftmt:MT55A fieldMt55A = {
            name: MT55A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt55A;
    }
    return ();
}

isolated function getField77T(pacsIsoRecord:SupplementaryData1[]? supplementaryData, string[]? remmitanceInfo) returns swiftmt:MT77T {
    if supplementaryData is pacsIsoRecord:SupplementaryData1[] {
        if supplementaryData[0].Envlp?.Nrtv is string {
            return {
                name: MT77T_NAME,
                EnvCntnt: {content: "/NARR/" + supplementaryData[0].Envlp?.Nrtv.toString(), number: NUMBER1}
            };
        }
        if supplementaryData[0].Envlp?.XmlContent is string {
            return {
                name: MT77T_NAME,
                EnvCntnt: {content: "/IXML/" + supplementaryData[0].Envlp?.XmlContent.toString(), number: NUMBER1}
            };
        }
    }
    if remmitanceInfo is string[] {
        string narration = "";
        foreach int i in 0 ... remmitanceInfo.length() - 1 {
            if i == remmitanceInfo.length() - 1 {
                narration += remmitanceInfo[i];
                break;
            }
            narration += remmitanceInfo[i];
        }
        return {
            name: MT77T_NAME,
            EnvCntnt: {content: "/SWIF/" + narration, number: NUMBER1}
        };
    }
    return {
        name: MT77T_NAME,
        EnvCntnt: {content: "", number: NUMBER1}
    };
}

isolated function getField21C(string? mandateId) returns swiftmt:MT21C? {
    if mandateId is string {
        return {
            name: "21R",
            Ref: {content: mandateId, number: NUMBER1}
        };
    }
    return ();
}

# Get the ordering institution from the Pacs008 document.
#
# + crdtTrfTx - The array of credit transactions
# + transaxion - The current credit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The ordering institution or an empty record
isolated function getMT102OrderingInstitutionFromPacs008Document(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx,
        pacsIsoRecord:CreditTransferTransaction64? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {

    [string?, string?, string?, string?] [iban, bban, identifierCode, partyIdentifier] = [crdtTrfTx[0].DbtrAgtAcct?.Id?.IBAN, crdtTrfTx[0].DbtrAgtAcct?.Id?.Othr?.Id, crdtTrfTx[0].DbtrAgt?.FinInstnId?.BICFI, crdtTrfTx[0].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd];
    foreach int i in 1 ... crdtTrfTx.length() - 1 {
        if iban != crdtTrfTx[i].DbtrAgtAcct?.Id?.IBAN || bban != crdtTrfTx[i].DbtrAgtAcct?.Id?.Othr?.Id || identifierCode != crdtTrfTx[i].DbtrAgt?.FinInstnId?.BICFI || partyIdentifier != crdtTrfTx[i].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd {
            return getField52(transaxion?.DbtrAgt?.FinInstnId, transaxion?.DbtrAgtAcct?.Id, isOptionCPresent = true);
        }
    }
    if isTransaction {
        return ();
    }
    return getField52(crdtTrfTx[0].DbtrAgt?.FinInstnId, crdtTrfTx[0].DbtrAgtAcct?.Id, isOptionCPresent = true);
}

# Get the intermediary institution from the Pacs008 document.
# + clearingChannel - The clearing channel
# + return - The clearing prefix or an empty string
isolated function getClearingPrefix(pacsIsoRecord:ClearingChannel2Code? clearingChannel) returns string {
    if clearingChannel is pacsIsoRecord:ClearingChannel2Code && clearingChannel == "RTGS" {
        return "//RT";
    }
    return "";
}

# Map the category purpose to MT23E.
# + categoryPurpose - The category purpose
# + return - The MT23E records
isolated function mapCategoryPurposeToMT23E(
        pacsIsoRecord:CategoryPurpose1Choice? categoryPurpose
) returns swiftmt:MT23E[] {
    swiftmt:MT23E[] instructionCodes = [];

    if categoryPurpose is () {
        return instructionCodes;
    }

    if categoryPurpose?.Cd is string {
        string code = categoryPurpose.Cd.toString();
        if code == "CHQB" || code == "HOLD" || code == "PHOB" || code == "TELB" {
            instructionCodes.push({
                name: MT23E_NAME,
                InstrnCd: {
                    content: code,
                    number: instructionCodes.length().toString()
                }
            });
        }
    }
    if categoryPurpose?.Prtry is string {
        string proprietary = categoryPurpose.Prtry.toString();
        if proprietary.includes("CHQB") {
            instructionCodes.push({
                name: MT23E_NAME,
                InstrnCd: {
                    content: "CHQB",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("HOLD") {
            instructionCodes.push({
                name: MT23E_NAME,
                InstrnCd: {
                    content: "HOLD",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("PHOB") {
            instructionCodes.push({
                name: MT23E_NAME,
                InstrnCd: {
                    content: "PHOB",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("TELB") {
            instructionCodes.push({
                name: MT23E_NAME,
                InstrnCd: {
                    content: "TELB",
                    number: instructionCodes.length().toString()
                }
            });
        }
    }

    return instructionCodes;
}

# Get the instructing party from the Pain008 document.
#
# + document - The Pain008 document
# + return - The instructing party or an empty record
isolated function getMT104InstructionPartyFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT50C?|swiftmt:MT50L? {
    painIsoRecord:PartyIdentification272? instructingParty = document.CstmrDrctDbtInitn.GrpHdr.InitgPty;

    if instructingParty is () {
        return ();
    }

    painIsoRecord:GenericPersonIdentification2[]? otherIds = instructingParty.Id?.PrvtId?.Othr;
    if instructingParty.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT50C>{
            name: MT50C_NAME,
            IdnCd: {
                content: instructingParty.Id?.OrgId?.AnyBIC.toString(),
                number: NUMBER1
            }
        };
    }
    if !(otherIds is ()) && otherIds.length() > 0 {
        return <swiftmt:MT50L>{
            name: MT50L_NAME,
            PrtyIdn: {
                content: otherIds[0].Id.toString(),
                number: NUMBER1
            }
        };
    }

    return ();
}

# Get the ordering customer from the Pain008 document.
#
# + document - The Pain008 document
# + return - The ordering customer or an empty record
isolated function getMT104CreditorFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT50A?|swiftmt:MT50K? {
    painIsoRecord:PartyIdentification272? creditor = document.CstmrDrctDbtInitn.PmtInf[0].Cdtr;

    if creditor is () {
        return ();
    }

    painIsoRecord:Max70Text[]? AdrLine = creditor.PstlAdr?.AdrLine;
    if creditor.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT50A>{
            name: MT50A_NAME,
            IdnCd: {
                content: creditor.Id?.OrgId?.AnyBIC.toString(),
                number: NUMBER1
            }
        };
    }
    if creditor.Nm != () || (!(AdrLine is ()) && AdrLine.length() > 0) {
        return <swiftmt:MT50K>{
            name: MT50K_NAME,
            Nm: getNamesArrayFromNameString(creditor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the account servicing institution from the Pain008 document.
#
# + document - The Pain008 document
# + return - The account servicing institution or an empty record
isolated function getMT104CreditorsBankFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? creditorsBank = document.CstmrDrctDbtInitn.PmtInf[0].CdtrAgt;

    if creditorsBank is () {
        return ();
    }

    if creditorsBank.FinInstnId?.BICFI != () {
        return <swiftmt:MT52A>{
            name: MT52A_NAME,
            IdnCd: {
                content: creditorsBank.FinInstnId?.BICFI.toString(),
                number: NUMBER1
            }
        };
    }
    if creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT52C>{
            name: MT52C_NAME,
            PrtyIdn: {
                content: creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    }
    if creditorsBank.FinInstnId?.Nm != () || creditorsBank.FinInstnId?.PstlAdr?.AdrLine != () {
        return <swiftmt:MT52D>{
            name: MT52D_NAME,
            Nm: getNamesArrayFromNameString(creditorsBank.FinInstnId?.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditorsBank.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the document debtor's bank from the Pain008 document.
#
# + mxTransaction - The MX document
# + return - The document debtor's bank or an empty record
isolated function getMT104TransactionDebtorsBankFromPain008Document(painIsoRecord:PaymentInstruction45 mxTransaction)
returns swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt = mxTransaction.DrctDbtTxInf[0].DbtrAgt;

    if dbtrAgt is () {
        return ();
    }
    if dbtrAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT57A>{
            name: MT57A_NAME,
            IdnCd: {
                content: dbtrAgt.FinInstnId.BICFI.toString(),
                number: NUMBER1
            }
        };
    }
    if dbtrAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT57C>{
            name: MT57C_NAME,
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    }
    if dbtrAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57D>{
            name: MT57D_NAME,
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.Othr?.Id.toString(),
                number: NUMBER1
            },
            Nm: getNamesArrayFromNameString(dbtrAgt.FinInstnId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>dbtrAgt.FinInstnId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the document debtor from the Pain008 document.
#
# + mxTransaction - The MX document
# + return - The document debtor or an empty record
isolated function getMT104TransactionDebtorFromPain008Document(painIsoRecord:PaymentInstruction45 mxTransaction)
returns swiftmt:MT59?|swiftmt:MT59A? {
    painIsoRecord:PartyIdentification272? debtor = mxTransaction.DrctDbtTxInf[0].Dbtr;

    if debtor is () {
        return ();
    }
    if debtor.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT59A>{
            name: MT56A_NAME,
            IdnCd: {
                content: debtor.Id?.OrgId?.AnyBIC.toString(),
                number: NUMBER1
            }
        };
    }
    if debtor.Nm != () || debtor.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: MT59_NAME,
            Nm: getNamesArrayFromNameString(debtor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the senders correspondent from the Pain008 document.
#
# + document - The Pain008 document
# + return - The senders correspondent or an empty record
isolated function getMT104SendersCorrespondentFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT53A?|swiftmt:MT53B? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? sendersCorrespondent = document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt;

    if sendersCorrespondent is () {
        return ();
    }

    if sendersCorrespondent.FinInstnId?.BICFI != () {
        return <swiftmt:MT53A>{
            name: MT53A_NAME,
            IdnCd: {
                content: sendersCorrespondent.FinInstnId.BICFI.toString(),
                number: NUMBER1
            }
        };
    }
    if sendersCorrespondent.FinInstnId?.PstlAdr?.TwnNm != () {
        return <swiftmt:MT53B>{
            name: MT53B_NAME,
            Lctn: {
                content: sendersCorrespondent.FinInstnId.PstlAdr?.TwnNm.toString(),
                number: NUMBER1
            }
        };
    }

    return ();
}

# Maps the ISO 20022 charge bearer type to the equivalent SWIFT MT104 code for field MT71A.
#
# + chargeBearer - The charge bearer type from ISO 20022.
# + return - Returns the mapped SWIFT MT104 charge code (BEN, OUR, SHA) or an empty string for unmapped values.
function getMT71AChargesCode(string chargeBearer) returns string {
    string mappedCode = "";
    if chargeBearer == "CRED" {
        mappedCode = "BEN";
    }
    if chargeBearer == "DEBT" {
        mappedCode = "OUR";
    }
    if chargeBearer == "SHAR" {
        mappedCode = "SHA";
    }
    return mappedCode;
}

# Creates the MT72 field based on ISO 20022 Remittance Information.
#
# + document - A single document from the Pacs.003 document.
# + return - The transformed MT72 field or an empty record if no narrative is present.
function getMT72Narrative(pacsIsoRecord:DirectDebitTransactionInformation31 document) returns swiftmt:MT72? {
    string[]? unstructuredInfo = document.RmtInf?.Ustrd;

    if unstructuredInfo is () || unstructuredInfo.length() == 0 {
        return ();
    }

    string code = "/RETN/";
    if unstructuredInfo[0].startsWith("/REJT/") {
        code = "/REJT/";
        unstructuredInfo[0] = unstructuredInfo[0].substring(6);
    }
    string narrative = code + joinStringArray(unstructuredInfo, "\n//");

    return {
        name: MT72_NAME,
        Cd: {
            content: narrative,
            number: NUMBER1
        }
    };
}

# Get the instructing party from the Pacs003 document.
#
# + dbtTrfTx - The array of direct debit transactions
# + transaxion - The current direct debit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The instructing party or an empty record
isolated function getMT104Or107InstructionPartyFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx,
        pacsIsoRecord:DirectDebitTransactionInformation31? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? {
    string? partyIdentifier = ();
    pacsIsoRecord:GenericPersonIdentification2[]? otherId = dbtTrfTx[0].InitgPty?.Id?.PrvtId?.Othr;
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] {
        partyIdentifier = otherId[0].Id;
    }
    string? identifierCode = dbtTrfTx[0].InitgPty?.Id?.OrgId?.AnyBIC;
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        string? partyIdentifier2 = ();
        pacsIsoRecord:GenericPersonIdentification2[]? otherId2 = dbtTrfTx[i].InitgPty?.Id?.PrvtId?.Othr;
        if otherId2 is pacsIsoRecord:GenericPersonIdentification2[] {
            partyIdentifier2 = otherId2[0].Id;
        }
        if identifierCode != dbtTrfTx[i].InitgPty?.Id?.OrgId?.AnyBIC || partyIdentifier != partyIdentifier2 {
            return getField50Or50COr50L(transaxion?.InitgPty);
        }
    }
    if isTransaction {
        return ();
    }
    return getField50Or50COr50L(dbtTrfTx[0]?.InitgPty);
}

# Get the ordering customer from the Pacs003 document.
#
# + dbtTrfTx - The array of direct debit transactions
# + transaxion - The current direct debit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The ordering customer or an empty record
isolated function getMT104Or107CreditorFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, pacsIsoRecord:DirectDebitTransactionInformation31? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F?|error {
    [string?, string?, string?] [iban, bban, identifierCode] = [dbtTrfTx[0].CdtrAcct?.Id?.IBAN, dbtTrfTx[0].CdtrAcct?.Id?.Othr?.Id, dbtTrfTx[0].Cdtr.Id?.OrgId?.AnyBIC];
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if iban != dbtTrfTx[i].CdtrAcct?.Id?.IBAN || bban != dbtTrfTx[i].CdtrAcct?.Id?.Othr?.Id || identifierCode != dbtTrfTx[i].Cdtr.Id?.OrgId?.AnyBIC {
            return getField50a(transaxion?.Cdtr, transaxion?.CdtrAcct?.Id, false, false);
        }
    }
    if isTransaction {
        return ();
    }
    return getField50a(dbtTrfTx[0].Cdtr, dbtTrfTx[0].CdtrAcct?.Id, false, false);
}

# Get the account servicing institution from the Pacs003 document.
#
# + dbtTrfTx - The array of direct debit transactions
# + transaxion - The current direct debit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The account servicing institution or an empty record
isolated function getMT104Or107CreditorsBankFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx,
        pacsIsoRecord:DirectDebitTransactionInformation31? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {

    [string?, string?, string?, string?] [iban, bban, identifierCode, partyIdentifier] = [dbtTrfTx[0].DbtrAgtAcct?.Id?.IBAN, dbtTrfTx[0].DbtrAgtAcct?.Id?.Othr?.Id, dbtTrfTx[0].DbtrAgt?.FinInstnId?.BICFI, dbtTrfTx[0].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd];
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if iban != dbtTrfTx[i].CdtrAgtAcct?.Id?.IBAN || bban != dbtTrfTx[i].CdtrAgtAcct?.Id?.Othr?.Id || identifierCode != dbtTrfTx[i].CdtrAgt?.FinInstnId?.BICFI || partyIdentifier != dbtTrfTx[i].CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd {
            return check getField52(transaxion?.CdtrAgt?.FinInstnId, transaxion?.CdtrAgtAcct?.Id, isOptionCPresent = true);
        }
    }
    if isTransaction {
        return ();
    }
    return check getField52(dbtTrfTx[0].CdtrAgt?.FinInstnId, dbtTrfTx[0].CdtrAgtAcct?.Id, isOptionCPresent = true);
}

isolated function getSenderOrReceiver(string? identifierCode, string? identifierCode2 = ()) returns string? {
    if identifierCode is string {
        return identifierCode;
    }
    return identifierCode2;
}

isolated function convertToSwiftTimeFormat(string? content) returns string|error {
    if content is () {
        return "";
    }
    string time = "";
    foreach int i in 0 ... content.length() - 1 {
        if content.substring(i, i + 1).equalsIgnoreCaseAscii(".") {
            break;
        }
        if content.substring(i, i + 1).equalsIgnoreCaseAscii(":") {
            continue;
        }
        time += content.substring(i, i+1);
    }
    return time;
}

// TODO Add the necessary functions to map the MX messages to the MT messages.
// Need to map the required fields from the MX message to the MT message.
# generate the block 3 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to generate the block 3 from the supplementary data,
#
# + uetr - The unique end-to-end transaction reference
# + validationFlag - The validation flag
# + return - The block 3 of the MT message or an error if the block 3 cannot be created
isolated function createMtBlock3(painIsoRecord:UUIDv4Identifier? uetr, string? validationFlag = ()) returns swiftmt:Block3? {
    if uetr !is string && validationFlag !is string {
        return ();
    }
    if uetr is string && validationFlag is string {
        return {
            ValidationFlag: {name: "119", value: validationFlag},
            NdToNdTxRef: {name: "121", value: uetr}
        };
    }
    if validationFlag is string {
        return {
            ValidationFlag: {name: "119", value: validationFlag}
        };
    }
    return {
        NdToNdTxRef: {name: "121", value: uetr}
    };
}

# generate the block 1 of the MT message from the supplementary data of the MX message.
# Currently, this function extracts logical terminal and sequence information from supplementary data.
#
# + supplementaryData - The supplementary data of the MX message
# + return - The block 1 of the MT message or an error if the block 1 cannot be created
isolated function generateMtBlock1FromSupplementaryData(painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block1?|error {
    if supplementaryData is painIsoRecord:SupplementaryData1[] {
        string? logicalTerminal = ();
        string? sessionNumber = ();
        string? sequenceNumber = ();

        foreach painIsoRecord:SupplementaryData1 data in supplementaryData {
            if data.Envlp.Nrtv is string {
                if data.Envlp.Nrtv.toString().startsWith("LT:") {
                    logicalTerminal = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
                if data.Envlp.Nrtv.toString().startsWith("SN:") {
                    sessionNumber = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
                if data.Envlp.Nrtv.toString().startsWith("SEQ:") {
                    sequenceNumber = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
            }
        }
        if logicalTerminal is string || sessionNumber is string || sequenceNumber is string {
            return {
                logicalTerminal: logicalTerminal,
                sessionNumber: sessionNumber,
                sequenceNumber: sequenceNumber
            };
        }
    }
    return ();
}

// TODO Add the necessary functions to map the MX messages to the MT messages.
// Need to map the MIRLogicalTerminal, MIRSessionNumber, and MIRSequenceNumber from the MX message to the MT message.
# generate the block 2 of the MT message from the supplementary data of the MX message
# Currently, this function extracts the message type from the supplementary data if it is not provided directly.
#
# + mtMessageId - The message type of the MT message
# + return - The block 2 of the MT message or an error if the block 2 cannot be created
isolated function generateMtBlock2(string? mtMessageId) returns swiftmt:Block2|error {
    string messageType = mtMessageId.toString();

    if messageType == "" {
        return error("Failed to identify the message type");
    }

    swiftmt:Block2 result = {
        messageType: messageType,
        'type: "output"
    };

    return result;
}

// TODO Add the necessary functions to map the MX messages to the MT messages.
// Need to map the MIRLogicalTerminal, MIRSessionNumber, and MIRSequenceNumber from the MX message to the MT message.
# generate the block 2 of the MT message from the supplementary data of the MX message
# Currently, this function extracts the message type from the supplementary data if it is not provided directly.
#
# + mtMessageId - The message type of the MT message
# + isoDateTime - The ISO date time of the MT message
# + return - The block 2 of the MT message or an error if the block 2 cannot be created
isolated function generateMtBlock2WithDateTime(string? mtMessageId, painIsoRecord:ISODateTime? isoDateTime) returns swiftmt:Block2|error {
    string messageType = mtMessageId.toString();

    if messageType == "" {
        return error("Failed to identify the message type");
    }

    string?[] swiftMtDateTime = convertToSwiftMTDateTime(isoDateTime.toString());

    swiftmt:Block2 result = {
        messageType: messageType,
        'type: "output",
        MIRDate: {content: swiftMtDateTime[0] ?: "", number: NUMBER1},
        senderInputTime: {content: swiftMtDateTime[1] ?: "", number: NUMBER1}
    };

    return result;
}

// TODO Add the necessary functions to map the MX messages to the MT messages.
// Need to map the required fields from the MX message to the MT message.
# generate the block 3 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to generate the block 3 from the supplementary data,
#
# + supplementaryData - The supplementary data of the MX message
# + uetr - The unique end-to-end transaction reference
# + validationFlag - The validation flag
# + return - The block 3 of the MT message or an error if the block 3 cannot be created
isolated function generateMtBlock3(painIsoRecord:SupplementaryData1[]? supplementaryData, painIsoRecord:UUIDv4Identifier? uetr, string validationFlag) returns swiftmt:Block3?|error {

    if uetr == () {
        return ();
    }

    swiftmt:Block3 result = {
        NdToNdTxRef: {value: uetr.toString()},
        ValidationFlag: {
            name: "ValidationFlag",
            value: validationFlag
        }
    };

    return result;
}

// TODO Add the necessary functions to map the MX messages to the MT messages.
// If nessary, add the logic to generate the block 5 from the supplementary data.
# generate the block 5 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to generate the block 5 from the supplementary data,
#
# + supplementaryData - The supplementary data of the MX message
# + return - The block 5 of the MT message or an error if the block 5 cannot be created
isolated function generateMtBlock5FromSupplementaryData(painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block5?|error {
    return ();
}

# Convert the MX payment amount 
# + ccyAndAmount - The payment type information from the MX message
# + return - The MT103 message or an error if the conversion fails
isolated function getActiveOrHistoricCurrencyAndAmountCcy(painIsoRecord:ActiveOrHistoricCurrencyAndAmount? ccyAndAmount) returns string {
    if (ccyAndAmount == ()) {
        return "";
    }

    return ccyAndAmount.Ccy.toString();
}

# Convert the MX payment amount
# + ccyAndAmount - The payment type information from the MX message
# + return - The MT103 message or an error if the conversion fails
isolated function getActiveOrHistoricCurrencyAndAmountValue(painIsoRecord:ActiveOrHistoricCurrencyAndAmount? ccyAndAmount) returns string {
    if ccyAndAmount == () {
        return "";
    }

    return ccyAndAmount.content.toString();
}

# Convert an ISO date string to a Swift MT date record
#
# + date - The ISO date string
# + number - The number of the date record
# + return - The Swift MT date record or an error if the date cannot be converted
isolated function convertISODateStringToSwiftMtDate(string date, string number = NUMBER1) returns swiftmt:Dt|error {

    string isoDate = date;
    if !isoDate.includes("T") {
        isoDate = isoDate + "T00:00:00Z";
    }

    time:Utc isoTime = check time:utcFromString(isoDate);
    time:Civil civilTime = time:utcToCivil(isoTime);
    string year = civilTime.year % 100 < 10 ? "0" + (civilTime.year % 100).toString() : (civilTime.year % 100).toString();
    string month = civilTime.month < 10 ? "0" + civilTime.month.toString() : civilTime.month.toString();
    string day = civilTime.day < 10 ? "0" + civilTime.day.toString() : civilTime.day.toString();
    string swiftMtDate = year + month + day;

    swiftmt:Dt result = {
        content: swiftMtDate,
        number: number
    };

    return result;
}

# Get the empty string if the value is null
#
# + value - The value
# + return - The value or an empty string if the value is null
isolated function getEmptyStrIfNull(anydata? value) returns string {
    if value == () {
        return "";
    }

    return value.toString();
}

# Get details of charges from the charge bearer type
#
# + chargeBearer - The charge bearer type
# + number - The number of the charge record
# + return - The charge record
isolated function getDetailsOfChargesFromChargeBearerType1Code(painIsoRecord:ChargeBearerType1Code? chargeBearer = (), string number = NUMBER1) returns swiftmt:Cd {
    string chargeBearerType = "";

    if chargeBearer != () {
        match chargeBearer {
            painIsoRecord:CRED => {
                chargeBearerType = "BEN";
            }

            painIsoRecord:DEBT => {
                chargeBearerType = "OUR";
            }

            painIsoRecord:SHAR => {
                chargeBearerType = "SHA";
            }
        }
    }

    swiftmt:Cd result = {
        content: chargeBearerType,
        number: number
    };

    return result;
}

# Convert a decimal number to a Swift Mt decimal number string
#
# + number - The decimal number
# + return - The Swift Mt decimal number string
isolated function convertDecimalNumberToSwiftDecimal(decimal? number) returns string {
    if number == () {
        return "";
    }

    return regex:replace(number.toString(), "\\.", ",");
}

# Convert the charges from the MX message to the MT71F or MT71G message
#
# + charges - The charges from the MX message
# + return - The MT71F or MT71G message or an error if the conversion fails
isolated function convertCharges16toMT71a(painIsoRecord:Charges16[]? charges) returns (swiftmt:MT71F|swiftmt:MT71G)[] {
    (swiftmt:MT71F|swiftmt:MT71G)[] result = [];

    if charges == () {
        return result;
    }

    foreach painIsoRecord:Charges16 charge in charges {
        match charge.Tp?.Cd {
            "CRED" => {
                swiftmt:MT71F mt71f = {
                    name: MT71F_NAME,
                    Ccy: {content: charge.Amt.Ccy, number: NUMBER1},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(charge.Amt.content), number: NUMBER2}
                };

                result.push(mt71f);
            }

            "DEBT" => {
                swiftmt:MT71G mt71g = {
                    name: MT71G_NAME,
                    Ccy: {content: charge.Amt.Ccy, number: NUMBER1},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(charge.Amt.content), number: NUMBER2}
                };

                result.push(mt71g);
            }
        }
    }

    return result;
}

# Convert the charges from the MX message to the MT71F message.
#
# + charges - The charges from the MX message.
# + chargeBearer - The charge bearer from the MX message.
# + return - The MT71F message or an error if the conversion fails.
isolated function convertCharges16toMT71F(painIsoRecord:Charges16[]? charges, string? chargeBearer) returns swiftmt:MT71F?|error {
    (swiftmt:MT71F|swiftmt:MT71G)[] mt71a = [];

    if chargeBearer == "CRED" || chargeBearer == "SHAR" {
        mt71a = convertCharges16toMT71a(charges);
    }

    foreach (swiftmt:MT71F|swiftmt:MT71G) e in mt71a {
        return check e.ensureType(swiftmt:MT71F);
    }

    return ();
}

# Convert the charges from the MX message to the MT71G message.
#
# + charges - The charges from the MX message.
# + chargeBearer - The charge bearer from the MX message.
# + return - The MT71G message or an error if the conversion fails.
isolated function convertCharges16toMT71G(painIsoRecord:Charges16[]? charges, string? chargeBearer) returns swiftmt:MT71G?|error {
    if charges == () || charges.length() == 0 {
        return ();
    }

    if chargeBearer != "DEBT" {
        return ();
    }

    decimal mxTotalAmount = 0.0;
    string mtCurrency = "";
    string mtAmount = "";

    foreach painIsoRecord:Charges16 charge in charges {
        string currentCurrency = charge.Amt.Ccy;
        if mtCurrency.equalsIgnoreCaseAscii("") {
            mtCurrency = currentCurrency;
        }
        if mtCurrency != currentCurrency {
            return error("All charges must have the same currency (Error Code: T20045).");
        }

        mxTotalAmount += check charge.Amt.content.ensureType(decimal);
    }

    mtAmount = convertDecimalNumberToSwiftDecimal(mxTotalAmount);
    if mtAmount.length() > 15 {
        return error("Amount exceeds maximum length of 15 characters (Error Codes: T20039, T13005).");
    }

    if mtAmount == "0" {
        return error("Amount cannot be zero (Error Code: T13009).");
    }

    swiftmt:MT71G mt71g = {
        name: MT71G_NAME,
        Ccy: {content: mtCurrency, number: NUMBER1},
        Amnt: {content: mtAmount, number: NUMBER2}
    };

    return mt71g;
}

# generate the MT13C message from the given code and time
# + code - The code
# + time - The time
# + return - The MT13C message or an error if the conversion fails
isolated function createMT13C(string code, painIsoRecord:ISOTime?|painIsoRecord:ISODateTime? time)
    returns swiftmt:MT13C?|error {

    if time is painIsoRecord:ISOTime && time.length() > 13{
        return {
            name: MT13C_NAME,
            Cd: {content: code, number: NUMBER1},
            Tm: {content: time.substring(0,2) + time.substring(3,5), number: NUMBER2},
            Sgn: {content: time.substring(8,9), number: NUMBER3}, 
            TmOfst: {content: time.substring(9,11) + time.substring(12,14), number: NUMBER4} 
        };
    }

    if time is painIsoRecord:ISODateTime && time.length() > 24{
        return {
            name: MT13C_NAME,
            Cd: {content: code, number: NUMBER1},
            Tm: {content: time.substring(11,13) + time.substring(14,16), number: NUMBER2},
            Sgn: {content: time.substring(19,20), number: NUMBER3}, 
            TmOfst: {content: time.substring(20,22) + time.substring(23,24), number: NUMBER4} 
        };
    }

    return ();
}

# Convert settlement time information to a single MT13C field.
#
# + SttlmTmIndctn - The settlement date-time indication  
# + SttlmTmReq - The settlement time request  
# + return - The MT13C message or an error if the conversion fails
isolated function convertTimeToMT13C(
        painIsoRecord:SettlementDateTimeIndication1? SttlmTmIndctn,
        painIsoRecord:SettlementTimeRequest2? SttlmTmReq
) returns swiftmt:MT13C?|error {

    if SttlmTmIndctn?.DbtDtTm is painIsoRecord:ISODateTime {
        return check createMT13C("SNDTIME", SttlmTmIndctn?.DbtDtTm);
    }
    if SttlmTmIndctn?.CdtDtTm is painIsoRecord:ISODateTime {
        return check createMT13C("RNCTIME", SttlmTmIndctn?.CdtDtTm);
    }
    if SttlmTmReq?.CLSTm is painIsoRecord:ISOTime {
        return check createMT13C("CLSTIME", SttlmTmReq?.CLSTm);
    }
    if SttlmTmReq?.TillTm is painIsoRecord:ISOTime {
        return check createMT13C("TILTIME", SttlmTmReq?.TillTm);
    }
    if SttlmTmReq?.FrTm is painIsoRecord:ISOTime {
        return check createMT13C("FROTIME", SttlmTmReq?.FrTm);
    }
    if SttlmTmReq?.RjctTm is painIsoRecord:ISOTime {
        return check createMT13C("REJTIME", SttlmTmReq?.RjctTm);
    }

    return ();
}

# Get the remittance information from the payment identification or remittance information.
#
# If the Proprietary field in Purpose contains the pattern ":26T:[A-Z0-9]{3}", 
# it will be mapped to field 26T. Otherwise, the remaining cases are handled 
# as remittance information (field 70).
#
# + PmtId - The payment identification
# + RmtInf - The remittance information
# + Prps - The purpose of the payment
# + return - The MT70 message
isolated function getRemittanceInformation(painIsoRecord:PaymentIdentification13? PmtId,
        painIsoRecord:RemittanceInformation22? RmtInf,
        painIsoRecord:Purpose2Choice? Prps) returns swiftmt:MT70? {

    string name = MT70_NAME;
    string content = "";
    string number = NUMBER1;

    string:RegExp regExp = re `:26T:[A-Z0-9]{3}`;
    if Prps?.Prtry != () {
        string? proprietary = Prps?.Prtry;
        if proprietary is string && proprietary.matches(regExp) {
            name = MT26T_NAME;
            content = proprietary.substring(5, 8);
            return {name, Nrtv: {content, number}};
        }
    }

    if PmtId?.EndToEndId != () {
        content = getEmptyStrIfNull(PmtId?.EndToEndId);
    }
    if RmtInf?.Ustrd != () {
        return getField70(RmtInf?.Ustrd);
    }

    return {name, Nrtv: {content, number}};
}

# Get the bank operation code from the payment type information
#
# + PmtTpInf - The payment type information
# + return - The bank operation code
isolated function getBankOperationCodeFromPaymentTypeInformation22(painIsoRecord:PaymentTypeInformation28? PmtTpInf) returns string {
    if PmtTpInf == () {
        return "";
    }

    painIsoRecord:ServiceLevel8Choice[]? svcLvl = PmtTpInf.SvcLvl;

    if svcLvl == () {
        return "";
    }

    if svcLvl.length() > 0 {
        painIsoRecord:ServiceLevel8Choice svcLvl0 = svcLvl[0];
        if (svcLvl0.Cd != ()) {
            return svcLvl0.Cd.toString();
        }
    }

    return "";

}

# Get the names array from the name string
#
# + nameString - The name string
# + return - The names array
isolated function getNamesArrayFromNameString(string nameString) returns swiftmt:Nm[] {
    string[] names = regex:split(nameString, " ");
    swiftmt:Nm[] result = [];

    foreach int i in 0 ... names.length() - 1 {
        result.push({
            content: names[i],
            number: (i + 1).toString()
        });
    }

    return result;
}

# Get the address lines from the addresses
#
# + addresses - The addresses
# + return - The address lines
isolated function getMtAddressLinesFromMxAddresses(string[] addresses) returns swiftmt:AdrsLine[] {
    swiftmt:AdrsLine[] result = [];

    foreach int i in 0 ... addresses.length() - 1 {
        result.push({
            content: addresses[i],
            number: (i + 1).toString()
        });
    }

    return result;
}

# Get the country and town from the country and town
#
# + country - The country
# + town - The town
# + return - The country and town
isolated function getMtCountryAndTownFromMxCountryAndTown(string country, string town) returns swiftmt:CntyNTw[] {
    swiftmt:CntyNTw[] result = [];
    string countryAndTown = country + "/" + town;

    if countryAndTown != "" {
        result.push({
            content: countryAndTown,
            number: NUMBER1
        });
    }

    return result;
}

# Retrieves the charge code from the given `ChargeBearerType1Code`.
#
# + chargeCode - The charge code in ISO 20022 format.
# + return - Returns the corresponding charge code as a string or an empty string if not valid.
function getChargeCode(painIsoRecord:ChargeBearerType1Code? chargeCode) returns string {
    if chargeCode is () {
        return "";
    }

    string code = "";
    match chargeCode {
        painIsoRecord:CRED => {
            code = "CRED";
        }
        painIsoRecord:DEBT => {
            code = "DEBT";
        }
        painIsoRecord:SHAR => {
            code = "SHAR";
        }
        painIsoRecord:SLEV => {
            code = "SLEV";
        }
        _ => {
            code = "";
        }
    }

    return code;
}

# Joins an array of strings with a specified separator.
#
# + strings - The array of strings to join.
# + separator - The separator to use between strings.
# + return - The joined string.
isolated function joinStringArray(string[] strings, string separator) returns string {
    string result = "";
    foreach string s in strings {
        result = result + s + separator;
    }
    return result;
}

# Retrieves the first element of an array or returns null if the array is empty.
#
# + array - The array to process.
# + return - The first element of the array or null if the array is empty.
isolated function getFirstElementFromArray(any[]? array) returns any? {
    if array == () {
        return ();
    }
    if array.length() > 0 {
        return array[0];
    }
    return ();
}

# Retrieves the last element of an array or returns null if the array is empty.
#
# + array - The array to process.
# + return - The last element of the array or null if the array is empty.
function getLastElementFromArray(any[]? array) returns any? {
    if array == () {
        return ();
    }
    if array.length() > 0 {
        return array[array.length() - 1];
    }
    return ();
}

# Extracts narrative (Nrtv) information from a Pacs.003 document's payment cancellation data.
#
# + document - The ISO 20022 `CustomerPaymentCancellationRequestV12` document.
# + return - Array of `Nrtv` records or an empty array if no narrative is found.
isolated function extractNarrativeFromCancellationReason(camtIsoRecord:CustomerPaymentCancellationRequestV12 document) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];
    camtIsoRecord:OriginalPaymentInstruction49? originalPaymentInstruction = <camtIsoRecord:OriginalPaymentInstruction49>getFirstElementFromArray(document.Undrlyg[0].OrgnlPmtInfAndCxl);
    if originalPaymentInstruction is () {
        return narratives;
    }
    camtIsoRecord:PaymentCancellationReason6? cancellationReason = <camtIsoRecord:PaymentCancellationReason6>getFirstElementFromArray(originalPaymentInstruction.CxlRsnInf);
    if cancellationReason is () {
        return narratives;
    }
    if !(cancellationReason.AddtlInf is ()) {
        int number = 1;
        foreach string narrative in <string[]>cancellationReason.AddtlInf {
            narratives.push({
                content: narrative,
                number: number.toString()
            });
            number += 1;
        }
    }
    return narratives;
}

# Creates Block 1 of an MT message using the instructing agent and instructed agent fields.
#
# + InstgAgt - The instructing agent details.
# + InstdAgt - The instructed agent details.
# + return - Returns the constructed Block 1 of the MT message or null if it cannot be created.
isolated function generateMtBlock1FromInstgAgtAndInstdAgt(camtIsoRecord:BranchAndFinancialInstitutionIdentification8? InstgAgt, camtIsoRecord:BranchAndFinancialInstitutionIdentification8? InstdAgt) returns swiftmt:Block1? {
    if (InstgAgt == () && InstdAgt == ()) || InstgAgt?.FinInstnId?.BICFI.toString().length() < 8 || InstdAgt?.FinInstnId?.BICFI.toString().length() < 8 {
        return ();
    }
    string? instgAgtLogicalTerminal = InstgAgt?.FinInstnId?.BICFI.toString().substring(0, 8);
    string? instdAgtLogicalTerminal = InstdAgt?.FinInstnId?.BICFI.toString().substring(0, 8);
    string logicalTerminal = instgAgtLogicalTerminal ?: instdAgtLogicalTerminal ?: "DEFAULTLT";
    return {
        logicalTerminal: logicalTerminal
    };
}

# Creates Block 1 of an MT message using the Assgne and Assgnr fields in a Camt055Document.
#
# + Assgnmt - The assignment details containing Assgne and Assgnr fields.
# + return - Returns the constructed Block 1 of the MT message or null if it cannot be created.
isolated function generateMtBlock1FromAssgnmt(camtIsoRecord:CaseAssignment6? Assgnmt) returns swiftmt:Block1?|error {
    if Assgnmt == () {
        return ();
    }
    string? assgneBIC = Assgnmt?.Assgne?.Agt?.FinInstnId?.BICFI;
    string? assgnrBIC = Assgnmt?.Assgnr?.Agt?.FinInstnId?.BICFI;
    string logicalTerminal = assgnrBIC ?: assgneBIC ?: "DEFAULTLT";
    return {
        logicalTerminal: logicalTerminal.substring(0, 8)
    };
}

# Converts an ISO 20022 date-time format to SWIFT MT date and time.
#
# + isoDateTime - The ISO 20022 date-time string in the format YYYY-MM-DDTHH:MM:SS.
# + return - A tuple containing the SWIFT MT date in YYMMDD format and time in HHMM format.
isolated function convertToSwiftMTDateTime(string? isoDateTime) returns [string?, string?] {
    if isoDateTime is string {
        if isoDateTime.length() >= 16 && isoDateTime.includes("T") {
            string[] dateTimeParts = regex:split(isoDateTime, "T");
            string datePart = dateTimeParts[0];
            string timePart = dateTimeParts[1];
            string swiftDate = datePart.substring(2, 4) + datePart.substring(5, 7) + datePart.substring(8, 10);
            string swiftTime = timePart.substring(0, 2) + timePart.substring(3, 5);
            return [swiftDate, swiftTime];
        }
    }
    return [(), ()];
}

# Get narrative information from the RegulatoryReporting3
#
# + rgltryRptg - The credit transfer transaction information
# + return - The narrative information
isolated function getNarrativeFromRegulatoryCreditTransferTransaction61(painIsoRecord:RegulatoryReporting3[]? rgltryRptg) returns swiftmt:Nrtv {
    string narratives = "";

    if rgltryRptg == () {
        return {
            content: getEmptyStrIfNull(narratives),
            number: NUMBER1
        };
    }

    painIsoRecord:StructuredRegulatoryReporting3[]? Dtls = rgltryRptg[0].Dtls;

    if Dtls == () {
        return {
            content: getEmptyStrIfNull(narratives),
            number: NUMBER1
        };
    }

    painIsoRecord:StructuredRegulatoryReporting3? r = Dtls[0];

    if r is () {
        return {
            content: getEmptyStrIfNull(narratives),
            number: NUMBER1
        };
    }

    narratives = "/" + r.Cd.toString() + "/" + r.Ctry.toString() + "//" + joinStringArray(<string[]>(r.Inf), " ");

    return {
        content: getEmptyStrIfNull(narratives),
        number: NUMBER1
    };
}

# Determines the currency code from instructed or interbank settlement amount.
#
# + instructedAmount - The instructed amount (InstdAmt) from the transaction.
# + interbankAmount - The interbank settlement amount (IntrBkSttlmAmt) from the transaction.
# + return - Returns the currency code or an error if unavailable.
isolated function getCurrencyCodeFromInterbankOrInstructedAmount(
        painIsoRecord:ActiveOrHistoricCurrencyAndAmount? instructedAmount,
        painIsoRecord:ActiveCurrencyAndAmount interbankAmount
) returns string|error {
    if instructedAmount?.Ccy is string {
        return instructedAmount?.Ccy.toString();
    } else if interbankAmount.Ccy is string {
        return interbankAmount.Ccy;
    }

}

# Extracts the amount value from instructed or interbank settlement amount.
#
# + instructedAmount - The instructed amount (InstdAmt) from the transaction.
# + interbankAmount - The interbank settlement amount (IntrBkSttlmAmt) from the transaction.
# + return - Returns the amount value or an error if unavailable.
isolated function getAmountValueFromInterbankOrInstructedAmount(
        painIsoRecord:ActiveOrHistoricCurrencyAndAmount? instructedAmount,
        painIsoRecord:ActiveCurrencyAndAmount interbankAmount
) returns string|error {
    if instructedAmount?.content is decimal {
        return instructedAmount?.content.toString();
    }
    return interbankAmount.content.toString();
}

# Converts an ISO date to Swift MT YYMMDD format and returns the substring (3rd to 6th characters).
#
# + mxDate - The MX ISO date string to be converted.
# + return - The converted YYMMDD format string.
isolated function extractSwiftMtDateFromMXDate(string mxDate) returns string|error {
    swiftmt:Dt|error convertedDate = check convertISODateStringToSwiftMtDate(mxDate, NUMBER2);

    if convertedDate is error {
        return "";
    }
    return convertedDate.content.substring(2, 6);
}

isolated function isStructuredAddress(painIsoRecord:PartyIdentification272 creditor) returns boolean {
    if creditor.PstlAdr?.Ctry != () && creditor.PstlAdr?.AdrLine != () {
        return true;
    }
    return false;
}

# Converts ISO date format (YYYY-MM-DD) to SWIFT date format (YYMMDD).
#
# + isoDate - The ISO date string
# + Default - The default value to return if the conversion fails
# + return - The SWIFT date string in YYMMDD format
isolated function convertISODateToYYMMDD(string isoDate, string Default = "") returns string {
    if isoDate.length() == 10 {
        return isoDate.substring(2, 4) + isoDate.substring(5, 7) + isoDate.substring(8, 10);
    }
    return Default;
}

# Derive the MT20 field for block 4.
#
# + caseId - The case identification from the camt.056 message
# + return - Returns the MT20 field or an error if the mapping fails
isolated function getMT20(string? caseId) returns swiftmt:MT20|error {
    string field20 = "NOTPROVIDED";

    if caseId is string {
        if caseId.length() > 16 {
            field20 = caseId.substring(0, 15) + "+";
        } else {
            field20 = caseId;
        }

        if field20.startsWith("/") || field20.endsWith("/") || field20.matches(re `//`) {
            field20 = "NOTPROVIDED";
        }
    }

    return {
        name: MT20_NAME,
        msgId: {
            content: field20,
            number: NUMBER1
        }
    };
}

# Derive the MT11S field for block 4.
#
# + orgnlGrpInfo - Original group information from the camt.056 message
# + orgnlCreationDateTime - Original creation date-time from the camt.056 message
# + return - Returns the MT11S field or an error if the mapping fails
isolated function getMT11S(
        camtIsoRecord:OriginalGroupHeader21? orgnlGrpInfo,
        string? orgnlCreationDateTime
) returns swiftmt:MT11S|error {
    string mtType = "202";
    string date = "991231";

    string:RegExp pacs008 = re `pacs.008`;
    string:RegExp pacs003 = re `pacs.003`;
    string:RegExp pacs009 = re `pacs.009`;
    string:RegExp pacs010 = re `pacs.010`;
    string:RegExp mt10x = re `MT10[0-9]{1}`;
    string:RegExp mt20x = re `MT20[0-9]{1}`;

    if orgnlGrpInfo?.OrgnlMsgNmId is string {
        string orgnlMsgNmId = orgnlGrpInfo?.OrgnlMsgNmId.toString();
        if orgnlMsgNmId.matches(pacs008) {
            mtType = MESSAGETYPE_103;
        }
        if orgnlMsgNmId.matches(pacs003) {
            mtType = MESSAGETYPE_104;
        }
        if orgnlMsgNmId.matches(pacs009) {
            mtType = MESSAGETYPE_202;
        }
        if orgnlMsgNmId.matches(pacs010) {
            mtType = MESSAGETYPE_203;
        }
        if orgnlMsgNmId.matches(mt10x) || orgnlMsgNmId.matches(mt20x) {
            mtType = orgnlMsgNmId.substring(2, 3);
        }
    }

    if orgnlCreationDateTime is string && orgnlCreationDateTime.length() >= 10 {
        string mxDate = orgnlCreationDateTime.substring(0, 10);
        date = convertISODateToYYMMDD(mxDate, "991231");
    }

    return {
        name: MT11S_NAME,
        MtNum: {
            content: mtType,
            number: NUMBER1
        },
        Dt: {
            content: date,
            number: NUMBER1
        }
    };
}

# Get the Original Instruction Identification or UETR from the underlying transactions.
#
# + undrlyg - The underlying transaction details
# + return - Returns a valid reference for MT21 or "NOTPROVIDED" if invalid
isolated function getOriginalInstructionOrUETR(camtIsoRecord:UnderlyingTransaction34[]? undrlyg) returns string {
    string field21 = "NOTPROVIDED";

    if undrlyg is camtIsoRecord:UnderlyingTransaction34[] {
        foreach camtIsoRecord:UnderlyingTransaction34 trans in undrlyg {
            foreach camtIsoRecord:PaymentTransaction155 txInf in trans.TxInf ?: [] {
                if txInf.OrgnlInstrId is string {
                    field21 = txInf.OrgnlInstrId.toString();
                }
                if txInf.OrgnlUETR is string {
                    field21 = txInf.OrgnlUETR.toString();
                }
                if field21.length() > 16 {
                    field21 = field21.substring(0, 15) + "+";
                }
                if field21.startsWith("/") || field21.endsWith("/") || field21.matches(re `//`) {
                    field21 = "NOTPROVIDED";
                }

                return field21;
            }
        }
    }

    return field21;
}

# Get the Original Instruction Identification or UETR from the underlying transactions.
#
# + undrlyg - The underlying transaction details
# + return - Returns a valid reference for MT21 or "NOTPROVIDED" if invalid
isolated function getOriginalInstructionOrUETRFromCamt055(camtIsoRecord:UnderlyingTransaction33[]? undrlyg) returns string {
    string field21 = "NOTPROVIDED";
    if undrlyg is camtIsoRecord:UnderlyingTransaction33[] {
        foreach camtIsoRecord:UnderlyingTransaction33 trans in undrlyg {
            camtIsoRecord:OriginalPaymentInstruction49[]? OrgnlPmtInfAndCxl = trans.OrgnlPmtInfAndCxl;
            if OrgnlPmtInfAndCxl is camtIsoRecord:OriginalPaymentInstruction49[] {
                foreach camtIsoRecord:OriginalPaymentInstruction49 orgnlPmtInf in OrgnlPmtInfAndCxl {
                    foreach camtIsoRecord:PaymentTransaction154 txInf in orgnlPmtInf.TxInf ?: [] {
                        if txInf.OrgnlInstrId is string {
                            field21 = txInf.OrgnlInstrId.toString();
                        }
                        if txInf.OrgnlUETR is string {
                            field21 = txInf.OrgnlUETR.toString();
                        }
                        if field21.length() > 16 {
                            field21 = field21.substring(0, 15) + "+";
                        }
                        if field21.startsWith("/") || field21.endsWith("/") || field21.matches(re `//`) {
                            field21 = "NOTPROVIDED";
                        }

                        return field21;
                    }
                }

            }

        }
    }

    return field21;
}

# Extracts narrative information from cancellation reasons in the camt.056 message.
# + undrlyg - The underlying transaction details from the camt.056 document.
# + return - Returns an array of narrative strings extracted from the cancellation reasons.
isolated function getNarrativeFromCancellationReason(camtIsoRecord:UnderlyingTransaction34[]? undrlyg) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];
    if undrlyg is camtIsoRecord:UnderlyingTransaction34[] {
        foreach camtIsoRecord:UnderlyingTransaction34 trans in undrlyg {
            foreach camtIsoRecord:PaymentTransaction155 txInf in trans.TxInf ?: [] {
                foreach camtIsoRecord:PaymentCancellationReason6 cxlRsn in txInf.CxlRsnInf ?: [] {
                    if cxlRsn.AddtlInf is camtIsoRecord:Max105Text[] {
                        foreach string info in <string[]>cxlRsn.AddtlInf {
                            narratives.push({
                                content: info,
                                number: NUMBER1
                            });
                        }
                    }
                }
            }
        }
    }
    return narratives;
}

# Formats the narrative for Field 77A to comply with the 20*35x format.
#
# + narrative - The original narrative as a string.
# + return - An Nrtv record containing the formatted narrative.
isolated function formatNarrative(string? narrative) returns swiftmt:Nrtv {
    string formattedNarrative = "";
    int lineLength = 35;

    if narrative is () {
        return {
            content: "",
            number: NUMBER1
        };
    }

    foreach int i in 0 ... narrative.length() / lineLength {
        string line = narrative.substring(i * lineLength, int:min((i + 1) * lineLength, narrative.length()));
        formattedNarrative += line + (i == narrative.length() / lineLength ? "" : "\n");
    }

    return {
        content: formattedNarrative,
        number: NUMBER1
    };
}

# Formats the narrative description for Field 79 to comply with the 35*50x format.
#
# + narrative - The original narrative as a string.
# + return - An array of Nrtv records, each containing a part of the narrative.
isolated function formatNarrativeDescription(string narrative) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] formattedNarrative = [];
    int lineCount = 1;
    foreach int i in 0 ... narrative.length() / 50 {
        string line = narrative.substring(i * 50, int:min((i + 1) * 50, narrative.length()));
        formattedNarrative.push({
            content: line,
            number: lineCount.toString()
        });
        lineCount += 1;
    }
    return formattedNarrative;
}

# Constructs a concatenated queries narrative for the MT75 field.
#
# + missingOrIncorrectInfo - The `MissingOrIncorrectData1` structure containing missing and incorrect information.
# + return - Returns a concatenated string of queries or an empty string if no data is available.
isolated function getConcatenatedQueries(camtIsoRecord:MissingOrIncorrectData1? missingOrIncorrectInfo) returns string {
    if missingOrIncorrectInfo is () {
        return "";
    }

    string queriesContent = "";
    int queryNumber = 1;
    camtIsoRecord:UnableToApplyMissing2[]? missingInfo = missingOrIncorrectInfo.MssngInf;

    if !(missingInfo is ()) && missingInfo.length() > 0 {
        foreach camtIsoRecord:UnableToApplyMissing2 missing in missingInfo {
            string queryContent = "/" + queryNumber.toString() + "/";
            if missing.Tp.Cd is string {
                queryContent += missing.Tp.Cd.toString();
            }
            if missing.Tp.Prtry is string {
                queryContent += missing.Tp.Prtry.toString();
            }
            queryContent += "Unknown Type";
            if missing.AddtlMssngInf is string {
                queryContent += " " + missing.AddtlMssngInf.toString();
            }

            queriesContent += queryContent + "\n";
            queryNumber += 1;
        }
    }

    camtIsoRecord:UnableToApplyIncorrect2[]? incorrectInfo = missingOrIncorrectInfo.IncrrctInf;

    if incorrectInfo is camtIsoRecord:UnableToApplyIncorrect2[] && incorrectInfo.length() > 0 {
        foreach camtIsoRecord:UnableToApplyIncorrect2 incorrect in incorrectInfo {
            string queryContent = "/" + queryNumber.toString() + "/";

            if incorrect.Tp.Cd is string {
                queryContent += incorrect.Tp.Cd.toString();
            }
            if incorrect.Tp.Prtry is string {
                queryContent += incorrect.Tp.Prtry.toString();
            }
            queryContent += "Unknown Type";

            if incorrect.AddtlIncrrctInf is string {
                queryContent += " " + incorrect.AddtlIncrrctInf.toString();
            }

            queriesContent += queryContent + "\n";
            queryNumber += 1;
        }
    }

    return queriesContent.substring(0, queriesContent.length() - 1);
}

# Extracts narrative information from supplementary data.
# + supplData - Array of supplementary data from the camt.028 document.
# + return - Returns a narrative string extracted from the supplementary data.
isolated function extractNarrativeFromSupplementaryData(camtIsoRecord:SupplementaryData1[]? supplData) returns string {
    if supplData is camtIsoRecord:SupplementaryData1[] {
        foreach camtIsoRecord:SupplementaryData1 data in supplData {
            if data.Envlp.Nrtv is string {
                return data.Envlp.Nrtv.toString();
            }
        }
    }
    return "";
}

# Extracts additional narrative information from supplementary data.
# + supplData - Array of supplementary data from the camt.028 document.
# + return - Returns an array of narrative lines extracted from the supplementary data. 
isolated function getAdditionalNarrativeInfo(camtIsoRecord:SupplementaryData1[]? supplData) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];
    if supplData is camtIsoRecord:SupplementaryData1[] {
        foreach camtIsoRecord:SupplementaryData1 data in supplData {
            if data.Envlp.Nrtv is string {
                narratives.push({
                    content: data.Envlp.Nrtv.toString(),
                    number: NUMBER1
                });
            }
        }
    }
    return narratives;
}

# Maps an investigation rejection code to a narrative string.
# + rejectionCode - The rejection code from the camt.031 document.
# + return - The corresponding narrative string for the rejection code.
isolated function getRejectionReasonNarrative(camtIsoRecord:InvestigationRejection1Code rejectionCode) returns string {
    if rejectionCode == camtIsoRecord:NFND {
        return "Investigation rejected: Not found.";
    }
    if (rejectionCode == camtIsoRecord:NAUT) {
        return "Investigation rejected: Not authorized.";
    }
    if (rejectionCode == camtIsoRecord:UKNW) {
        return "Investigation rejected: Unknown.";
    }
    if (rejectionCode == camtIsoRecord:PCOR) {
        return "Investigation rejected: Pending correction.";
    }
    if (rejectionCode == camtIsoRecord:WMSG) {
        return "Investigation rejected: Wrong message.";
    }
    if (rejectionCode == camtIsoRecord:RNCR) {
        return "Investigation rejected: Reason not clear.";
    }
    if (rejectionCode == camtIsoRecord:MROI) {
        return "Investigation rejected: Message received out of scope.";
    }
}

isolated function getField23EForMt103(pacsIsoRecord:InstructionForCreditorAgent3[]? cdtrInstrctn, pacsIsoRecord:InstructionForNextAgent1[]? dbtrInstrctn, pacsIsoRecord:ServiceLevel8Choice[]? svcLvl, pacsIsoRecord:CategoryPurpose1Choice? ctgryPurp) returns swiftmt:MT23E[] {
    swiftmt:MT23E[] field23E = [];
    if cdtrInstrctn is pacsIsoRecord:InstructionForCreditorAgent3[] {
        string[] MT_103_INSTRC_CD = ["CHQB", "TELB", "PHOB", "HOLD"];
        foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in cdtrInstrctn {
            if MT_103_INSTRC_CD.indexOf(instruction.Cd.toString()) !is () {
                if instruction.InstrInf is string {
                    field23E.push({name: MT23E_NAME, InstrnCd: {content: 
                        instruction.Cd.toString() + "/" + instruction.InstrInf.toString(), number: NUMBER1}});
                } else {
                    field23E.push({name: MT23E_NAME, InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1}});
                }
            }
        }
    }

    if dbtrInstrctn is pacsIsoRecord:InstructionForNextAgent1[] {
        string[] MT_103_INSTRC_CD = ["PHON", "TELI", "TELE", "PHOI", "REPA"];
        foreach pacsIsoRecord:InstructionForNextAgent1 instruction in dbtrInstrctn {
            if MT_103_INSTRC_CD.indexOf(instruction.Cd.toString()) !is () {
                if instruction.InstrInf is string {
                    field23E.push({name: MT23E_NAME, InstrnCd: {content: 
                        instruction.Cd.toString() + "/" + instruction.InstrInf.toString(), number: NUMBER1}});
                } else {
                    field23E.push({name: MT23E_NAME, InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1}});
                }
            }
        }
    }

    if svcLvl is pacsIsoRecord:ServiceLevel8Choice[] {
        foreach pacsIsoRecord:ServiceLevel8Choice instruction in svcLvl {
            if instruction.Cd.toString().equalsIgnoreCaseAscii("SDVA") {
                field23E.push({name: MT23E_NAME, InstrnCd: {content: "SDVA", number: NUMBER1}});
            }
        }
    }

    if ctgryPurp is pacsIsoRecord:CategoryPurpose1Choice {
        if ctgryPurp.Cd.toString().equalsIgnoreCaseAscii("INTC") || 
            ctgryPurp.Cd.toString().equalsIgnoreCaseAscii("CORT") {
                field23E.push({name: MT23E_NAME, InstrnCd: {content: ctgryPurp.Cd.toString(), number: NUMBER1}});
                return field23E;
        } 
        if ctgryPurp.Prtry.toString().equalsIgnoreCaseAscii("INTC CORT") {
            field23E.push({name: MT23E_NAME, InstrnCd: {content: "INTC", number: NUMBER1}});
            field23E.push({name: MT23E_NAME, InstrnCd: {content: "CORT", number: NUMBER1}});
            return field23E;
        }
    }
    return field23E;
}

isolated function getField23B(string? bankOpCd) returns swiftmt:MT23B {
    string[] operationCodes = ["CRED", "SPAY", "CRTS", "SSTD", "SPRI"];
    if bankOpCd is string {
        if operationCodes.indexOf(bankOpCd) !is () {
            return {
                name: MT23B_NAME,
                Typ: {content: bankOpCd, number: NUMBER1}};
        }
    }
    return {
        name: MT23B_NAME,
        Typ: {content: "NOTPROVIDED", number: NUMBER1}
    };
}

isolated function getField23(string? bankOpCd) returns swiftmt:MT23 {
    string[] operationCodes = ["CREDIT", "SPAY", "CRTST"];
    if bankOpCd is string {
        if operationCodes.indexOf(bankOpCd) !is () {
            return {
                name: MT23_NAME,
                Cd: {content: bankOpCd, number: NUMBER1}};
        }
    }
    return {
        name: MT23_NAME,
        Cd: {content: "NOTPROVIDED", number: NUMBER1}
    };
}
