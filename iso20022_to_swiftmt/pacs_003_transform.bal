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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given ISO 20022 Pacs.003 envelope.Document to its corresponding SWIFT MT104 format.
#
# + envelope - The Pacs003 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The transformed SWIFT MT104 message or an error if the transformation fails
isolated function transformPacs003DocumentToMT104(pacsIsoRecord:Pacs003Envelope envelope, string messageType) returns swiftmt:MT104Message|error => let
    pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx = envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf,
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(dbtTrfTx),
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(dbtTrfTx),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId, dbtTrfTx[0].IntrmyAgt1Acct?.Id, isOptionBPresent = true),
    swiftmt:MT104Transaction[] transactions = check generateMT104TransactionsFromPacs003(dbtTrfTx)
    in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: check getField19(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.MsgId,
                    number: NUMBER1
                }
            },
            MT23E: getRepeatingField23EForPacs003(dbtTrfTx),
            MT26T: getRepeatingField26TForPacs003(dbtTrfTx),
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(dbtTrfTx[0].IntrBkSttlmDt), number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.Ccy.toString(), number: NUMBER1},
                Amnt: {content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.content.toString(), number: NUMBER2}
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: field50a is swiftmt:MT50A ? field50a : (),
            MT50K: field50a is swiftmt:MT50K ? field50a : (),
            MT51A: getField51A(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52C: field52 is swiftmt:MT52C ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT71A: getRepeatingField71AForPacs003(dbtTrfTx),
            MT71F: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content.toString(), number: NUMBER2}
                },
            MT71G: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content.toString(), number: NUMBER2}
                },
            MT77B: getRepeatingField77BForPacs003(dbtTrfTx),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrDrctDbt.SplmtryData)
    };

# Creates the MT104 transactions from the Pacs003 envelope.Document's direct debit transaction information.
#
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 envelope.Document
# + return - Array of MT104 transactions or an error
isolated function generateMT104TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf
) returns swiftmt:MT104Transaction[]|error {
    swiftmt:MT104Transaction[] transactions = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(tx.DbtrAgt?.FinInstnId, tx.DbtrAgtAcct?.Id, isOptionCPresent = true);
        swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(tx.Dbtr, tx.DbtrAcct?.Id, isOptionFPresent = false);
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: getMandatoryField(tx.PmtId?.EndToEndId),
                number: NUMBER1
            }
        };

        swiftmt:MT23E? MT23E = getRepeatingField23EForPacs003(drctDbtTxInf, tx.PmtTpInf?.CtgyPurp?.Cd, true);

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {content: tx.IntrBkSttlmAmt.Ccy, number: NUMBER1},
            Amnt: {content: tx.IntrBkSttlmAmt?.content.toString(), number: NUMBER2}
        };

        swiftmt:MT21C? MT21C = getField21C(tx.DrctDbtTx?.MndtRltdInf?.MndtId);
        swiftmt:MT26T? MT26T = getRepeatingField26TForPacs003(drctDbtTxInf, tx.Purp, true);
        swiftmt:MT33B? MT33B = check getField33B(tx.InstdAmt, tx.IntrBkSttlmAmt);
        swiftmt:MT36? MT36 = check getField36(tx.XchgRate);

        swiftmt:MT50C? MT50C = instructingParty is swiftmt:MT50C ? instructingParty : ();
        swiftmt:MT50L? MT50L = instructingParty is swiftmt:MT50L ? instructingParty : ();

        swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
        swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

        swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
        swiftmt:MT52C? MT52C = field52 is swiftmt:MT52C ? field52 : ();
        swiftmt:MT52D? MT52D = field52 is swiftmt:MT52D ? field52 : ();

        swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
        swiftmt:MT57C? MT57C = field57 is swiftmt:MT57C ? field57 : ();
        swiftmt:MT57D? MT57D = field57 is swiftmt:MT57D ? field57 : ();

        swiftmt:MT59? MT59 = field59 is swiftmt:MT59 ? field59 : ();
        swiftmt:MT59A? MT59A = field59 is swiftmt:MT59A ? field59 : ();

        swiftmt:MT70? MT70 = getField70(tx.RmtInf?.Ustrd);
        swiftmt:MT71A? MT71A = getRepeatingField71AForPacs003(drctDbtTxInf, tx.ChrgBr, true);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs003(drctDbtTxInf, tx.RgltryRptg, true);

        transactions.push({
            MT21,
            MT21C,
            MT23E,
            MT26T,
            MT32B,
            MT33B,
            MT36,
            MT50C,
            MT50L,
            MT50A,
            MT50K,
            MT52A,
            MT52C,
            MT52D,
            MT57A,
            MT57C,
            MT57D,
            MT59,
            MT59A,
            MT70,
            MT71A,
            MT77B
        });
    }

    return transactions;
}

# Tranform the given ISO 20022 Pacs.003 envelope.Document to its corresponding SWIFT MT107 format.
# + envelope - The Pacs003 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The transformed SWIFT MT107 message or an error if the transformation fails
isolated function transformPacs003DocumentToMT107(pacsIsoRecord:Pacs003Envelope envelope, string messageType) returns swiftmt:MT107Message|error => let
    pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx = envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf,
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(dbtTrfTx),
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(dbtTrfTx),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId, dbtTrfTx[0].IntrmyAgt1Acct?.Id, isOptionBPresent = true),
    swiftmt:MT104Transaction[] transactions = check generateMT107TransactionsFromPacs003(dbtTrfTx)
    in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: check getField19(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.MsgId,
                    number: NUMBER1
                }
            },
            MT23E: dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd is () ? () : {
                    name: MT23E_NAME,
                    InstrnCd: {content: dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd.toString(), number: NUMBER1}
                },
            MT26T: getRepeatingField26TForPacs003(dbtTrfTx),
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(dbtTrfTx[0].IntrBkSttlmDt), number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.Ccy.toString(), number: NUMBER1},
                Amnt: {content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.content.toString(), number: NUMBER2}
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: field50a is swiftmt:MT50A ? field50a : (),
            MT50K: field50a is swiftmt:MT50K ? field50a : (),
            MT51A: getField51A(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52C: field52 is swiftmt:MT52C ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT71A: getRepeatingField71AForPacs003(dbtTrfTx),
            MT71F: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content.toString(), number: NUMBER2}
                },
            MT71G: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content.toString(), number: NUMBER2}
                },
            MT77B: getRepeatingField77BForPacs003(dbtTrfTx),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrDrctDbt.SplmtryData)
    };

# generate the MT107 transactions from the Pacs003 envelope.Document's direct debit transaction information.
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 envelope.Document
# + return - Array of MT107 transactions or an error
isolated function generateMT107TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf
) returns swiftmt:MT107Transaction[]|error {
    swiftmt:MT107Transaction[] transactions = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(tx.DbtrAgt?.FinInstnId, tx.DbtrAgtAcct?.Id, isOptionCPresent = true);
        swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(tx.Dbtr, tx.DbtrAcct?.Id, isOptionFPresent = false);
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: getMandatoryField(tx.PmtId?.EndToEndId),
                number: NUMBER1
            }
        };

        swiftmt:MT23E MT23E = {
            name: MT23E_NAME,
            InstrnCd: {content: getEmptyStrIfNull(tx.PmtTpInf?.CtgyPurp?.Cd), number: NUMBER1}
        };

        swiftmt:MT32B MT32B = {
            name: MT23B_NAME,
            Ccy: {content: tx.IntrBkSttlmAmt.Ccy, number: NUMBER1},
            Amnt: {content: tx.IntrBkSttlmAmt?.content.toString(), number: NUMBER1}
        };

        swiftmt:MT21C? MT21C = getField21C(tx.DrctDbtTx?.MndtRltdInf?.MndtId);
        swiftmt:MT26T? MT26T = getRepeatingField26TForPacs003(drctDbtTxInf, tx.Purp, true);
        swiftmt:MT33B? MT33B = check getField33B(tx.InstdAmt, tx.IntrBkSttlmAmt);
        swiftmt:MT36? MT36 = check getField36(tx.XchgRate);

        swiftmt:MT50C? MT50C = instructingParty is swiftmt:MT50C ? instructingParty : ();
        swiftmt:MT50L? MT50L = instructingParty is swiftmt:MT50L ? instructingParty : ();

        swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
        swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

        swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
        swiftmt:MT52C? MT52C = field52 is swiftmt:MT52C ? field52 : ();
        swiftmt:MT52D? MT52D = field52 is swiftmt:MT52D ? field52 : ();

        swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
        swiftmt:MT57C? MT57C = field57 is swiftmt:MT57C ? field57 : ();
        swiftmt:MT57D? MT57D = field57 is swiftmt:MT57D ? field57 : ();

        swiftmt:MT59? MT59 = field59 is swiftmt:MT59 ? field59 : ();
        swiftmt:MT59A? MT59A = field59 is swiftmt:MT59A ? field59 : ();

        swiftmt:MT70? MT70 = getField70(tx.RmtInf?.Ustrd);
        swiftmt:MT71A? MT71A = getRepeatingField71AForPacs003(drctDbtTxInf, tx.ChrgBr, true);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs003(drctDbtTxInf, tx.RgltryRptg, true);

        transactions.push({
            MT21,
            MT21C,
            MT23E,
            MT26T,
            MT32B,
            MT33B,
            MT36,
            MT50C,
            MT50L,
            MT50A,
            MT50K,
            MT52A,
            MT52C,
            MT52D,
            MT57A,
            MT57C,
            MT57D,
            MT59,
            MT59A,
            MT70,
            MT71A,
            MT77B
        });
    }

    return transactions;
}
