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

# Transforms a PACS008 document to an MT102 message
#
# + envelope - The PACS008 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT102 message or an error if the transformation fails
isolated function transformPacs008DocumentToMT102(pacsIsoRecord:Pacs008Envelope envelope, string messageType) returns swiftmt:MT102Message|error => {
    block1: {
        applicationId: "F",
        serviceId: "01",
        logicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
    block4: check generateMT102Block4(envelope, false).ensureType(swiftmt:MT102Block4),
    block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrCdtTrf.SplmtryData)
};

# Transforms a PACS008 document to an MT102STP message
#
# + envelope - The PACS008 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT102STP message or an error if the transformation fails
isolated function transformPacs008DocumentToMT102STP(pacsIsoRecord:Pacs008Envelope envelope, string messageType) returns swiftmt:MT102STPMessage|error => {
    block1: {
        applicationId: "F",
        serviceId: "01",
        logicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_STP),
    block4: check generateMT102Block4(envelope, true).ensureType(swiftmt:MT102STPBlock4),
    block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrCdtTrf.SplmtryData)
};

# Creates the block 4 of an MT102 message from a PACS008 document
#
# + envelope - The PACS008 envelope containing the corresponding document to be transformed.
# + isSTP - A boolean indicating whether the message is an STP message
# + return - The block 4 of the MT102 message or an error if the transformation fails
isolated function generateMT102Block4(pacsIsoRecord:Pacs008Envelope envelope, boolean isSTP) returns swiftmt:MT102Block4|swiftmt:MT102STPBlock4|error {
    pacsIsoRecord:GroupHeader113 grpHdr = envelope.Document.FIToFICstmrCdtTrf.GrpHdr;
    pacsIsoRecord:CreditTransferTransaction64[] transactions = envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf;
    pacsIsoRecord:CreditTransferTransaction64 firstTransaction = transactions[0];
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getOrderingCustomerFromPacs008Document(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf);
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT102OrderingInstitutionFromPacs008Document(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf);
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id, isOptionCPresent = true);
    swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? field54 = getField54(grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id, true);

    swiftmt:MT20 MT20 = {
        name: MT20_NAME,
        msgId: {
            content: grpHdr.MsgId,
            number: NUMBER1
        }
    };

    swiftmt:MT23 MT23 = getField23(firstTransaction.PmtTpInf?.LclInstrm?.Prtry);

    swiftmt:MT51A? MT51A = getField51A(grpHdr.InstgAgt?.FinInstnId);

    swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
    swiftmt:MT50F? MT50F = field50a is swiftmt:MT50F ? field50a : ();
    swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

    swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
    swiftmt:MT52B? MT52B = field52 is swiftmt:MT52B ? field52 : ();
    swiftmt:MT52C? MT52C = field52 is swiftmt:MT52C ? field52 : ();

    swiftmt:MT26T? MT26T = getRepeatingField26TForPacs008(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT71A? MT71A = getRepeatingField71AForPacs008(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT36? MT36 = check getRepeatingField36(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT32A MT32A = {
        name: MT32A_NAME,
        Dt: {content: convertToSWIFTStandardDate(firstTransaction.IntrBkSttlmDt), number: NUMBER1},
        Ccy: {content: getMandatoryField(grpHdr.TtlIntrBkSttlmAmt?.Ccy), number: NUMBER2},
        Amnt: {content: check convertToString(grpHdr.TtlIntrBkSttlmAmt?.content), number: NUMBER3}
    };

    swiftmt:MT19? MT19 = check getField19(grpHdr.CtrlSum);

    swiftmt:MT71G? MT71G = check convertCharges16toMT71G(firstTransaction.ChrgsInf, firstTransaction.ChrgBr);
    swiftmt:MT13C? MT13C = check convertTimeToMT13C(firstTransaction.SttlmTmIndctn, firstTransaction.SttlmTmReq);
    swiftmt:MT53A? MT53A = field53 is swiftmt:MT53A ? field53 : ();
    swiftmt:MT53C? MT53C = field53 is swiftmt:MT53C ? field53 : ();
    swiftmt:MT54A? MT54A = field54 is swiftmt:MT54A ? field54 : ();
    swiftmt:MT72? MT72 = getField72(firstTransaction.InstrForCdtrAgt, firstTransaction.InstrForNxtAgt, firstTransaction.IntrmyAgt1, firstTransaction.IntrmyAgt2, firstTransaction.PmtTpInf?.SvcLvl, firstTransaction.PmtTpInf?.CtgyPurp, firstTransaction.PmtTpInf?.LclInstrm);
    swiftmt:MT77B? MT77B = getRepeatingField77BForPacs008(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT102STPTransaction[]|swiftmt:MT102Transaction[] Transactions = check generateMT102Transactions(
            envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf,
            isSTP
    );

    if isSTP {
        swiftmt:MT102STPBlock4 MT102STPBlock4 = {
            MT20,
            MT23,
            MT36,
            MT50A,
            MT50F,
            MT50K,
            MT52A,
            MT26T,
            MT32A,
            MT19,
            MT71A,
            MT71G,
            MT13C,
            MT53A,
            MT53C,
            MT54A,
            MT72,
            MT77B,
            Transaction: <swiftmt:MT102STPTransaction[]>Transactions
        };
        return MT102STPBlock4;
    }
    swiftmt:MT102Block4 MT102Block4 = {
        MT20,
        MT23,
        MT51A,
        MT50A,
        MT50F,
        MT50K,
        MT52A,
        MT52C,
        MT26T,
        MT71A,
        MT36,
        MT77B,
        Transaction: <swiftmt:MT102Transaction[]>Transactions,
        MT32A,
        MT19,
        MT71G,
        MT13C,
        MT53A,
        MT53C,
        MT54A,
        MT52B,
        MT72
    };

    return MT102Block4;
}

# Creates the transactions of an MT102 message from a PACS008 document
#
# + mxTransactions - The credit transfer transactions
# + isSTP - A boolean indicating whether the message is an STP message
# + return - The transactions of the MT102 message or an error if the transformation fails
isolated function generateMT102Transactions(
        pacsIsoRecord:CreditTransferTransaction64[] mxTransactions,
        boolean isSTP)
returns swiftmt:MT102Transaction[]|swiftmt:MT102STPTransaction[]|error {
    swiftmt:MT102Transaction[] transactions = [];
    swiftmt:MT102STPTransaction[] transactionsSTP = [];
    foreach pacsIsoRecord:CreditTransferTransaction64 transaxion in mxTransactions {
        swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getOrderingCustomerFromPacs008Document(mxTransactions, transaxion, true);
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT102OrderingInstitutionFromPacs008Document(mxTransactions, transaxion, true);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(transaxion.CdtrAgt?.FinInstnId, transaxion.CdtrAgtAcct?.Id, isOptionCPresent = true);
        swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(transaxion.Cdtr, transaxion.CdtrAcct?.Id);
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: transaxion.PmtId.EndToEndId,
                number: NUMBER1
            }
        };

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {
                content: transaxion.IntrBkSttlmAmt.Ccy,
                number: NUMBER1
            },
            Amnt: {
                content: check convertToString(transaxion.IntrBkSttlmAmt?.content),
                number: NUMBER2
            }
        };

        swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
        swiftmt:MT50F? MT50F = field50a is swiftmt:MT50F ? field50a : ();
        swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

        swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
        swiftmt:MT52B? MT52B = field52 is swiftmt:MT52B ? field52 : ();
        swiftmt:MT52C? MT52C = field52 is swiftmt:MT52C ? field52 : ();

        swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
        swiftmt:MT57C? MT57C = field57 is swiftmt:MT57C ? field57 : ();

        swiftmt:MT59? MT59 = field59 is swiftmt:MT59 ? field59 : ();
        swiftmt:MT59A? MT59A = field59 is swiftmt:MT59A ? field59 : ();
        swiftmt:MT59F? MT59F = field59 is swiftmt:MT59F ? field59 : ();

        swiftmt:MT70? MT70 = getRemittanceInformation(transaxion.PmtId, transaxion.RmtInf, transaxion.Purp);

        swiftmt:MT26T? MT26T = getRepeatingField26TForPacs008(mxTransactions, transaxion.Purp, true);

        swiftmt:MT33B? MT33B = check getField33B(transaxion.InstdAmt, transaxion.IntrBkSttlmAmt);

        swiftmt:MT71A? MT71A = getRepeatingField71AForPacs008(mxTransactions, transaxion.ChrgBr, true);

        swiftmt:MT71F? MT71F = check convertCharges16toMT71F(transaxion.ChrgsInf, transaxion.ChrgBr);
        swiftmt:MT71G? MT71G = check convertCharges16toMT71G(transaxion.ChrgsInf, transaxion.ChrgBr);

        swiftmt:MT36? MT36 = check getRepeatingField36(mxTransactions, transaxion.XchgRate, true);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs008(mxTransactions, transaxion, true);

        if isSTP {
            transactionsSTP.push({MT21, MT32B, MT50A, MT50F, MT50K, MT52A, MT57A, MT59, MT59A, MT59F, MT70, MT26T, MT33B, MT77B, MT71A, MT71F, MT71G, MT36});
        } else {
            transactions.push({MT21, MT32B, MT50A, MT50F, MT50K, MT52A, MT52B, MT52C, MT57A, MT57C, MT59, MT59A, MT59F, MT70, MT26T, MT33B, MT77B, MT71A, MT71F, MT71G, MT36});
        }
    }

    if isSTP {
        return transactionsSTP;
    } else {
        return transactions;
    }
}

# This enum represents the different types of MT103 messages
enum MT103Type {
    MT103,
    MT103_STP,
    MT103_REMIT
}

# Transforms a PACS008 envelope.Document to an MT103 message
#
# + envelope - The PACS008 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT103 message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103(pacsIsoRecord:Pacs008Envelope envelope, string messageType) returns swiftmt:MT103Message|error => {
    block1: {
        applicationId: "F",
        serviceId: "01",
        logicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
    block4: check generateMT103Block4(envelope, MT103).ensureType(swiftmt:MT103Block4),
    block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrCdtTrf.SplmtryData)
};

# Transforms a PACS008 document to an MT103STP message
#
# + envelope - The PACS008 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT103STP message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103STP(pacsIsoRecord:Pacs008Envelope envelope, string messageType) returns swiftmt:MT103STPMessage|error => {
    block1: {
        applicationId: "F",
        serviceId: "01",
        logicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_STP),
    block4: check generateMT103Block4(envelope, MT103_STP).ensureType(swiftmt:MT103STPBlock4),
    block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrCdtTrf.SplmtryData)
};

# Transforms a PACS008 document to an MT103REMIT message
#
# + envelope - The PACS008 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT103REMIT message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103REMIT(pacsIsoRecord:Pacs008Envelope envelope, string messageType) returns swiftmt:MT103REMITMessage|error => {
    block1: {
        applicationId: "F",
        serviceId: "01",
        logicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_REMIT),
    block4: check generateMT103Block4(envelope, MT103_REMIT).ensureType(swiftmt:MT103REMITBlock4),
    block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrCdtTrf.SplmtryData)
};

# Creates the block 4 of an MT103 message from a PACS008 document
#
# + envelope - The PACS008 envelope containing the corresponding document to be transformed.
# + messageType - The type of the MT103 message
# + return - The block 4 of the MT103 message or an error if the transformation fails
isolated function generateMT103Block4(pacsIsoRecord:Pacs008Envelope envelope, MT103Type messageType) returns swiftmt:MT103Block4|swiftmt:MT103STPBlock4|swiftmt:MT103REMITBlock4|error {
    pacsIsoRecord:GroupHeader113 grpHdr = envelope.Document.FIToFICstmrCdtTrf.GrpHdr;
    pacsIsoRecord:CreditTransferTransaction64[] transactions = envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf;
    pacsIsoRecord:CreditTransferTransaction64 firstTransaction = transactions[0];
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getField50a(firstTransaction.Dbtr, firstTransaction.DbtrAcct?.Id);
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(firstTransaction.DbtrAgt?.FinInstnId, firstTransaction.DbtrAgtAcct?.Id);
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id, true);
    swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? field54 = getField54(grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id, true);
    swiftmt:MT55A?|swiftmt:MT55B?|swiftmt:MT55D? field55 = getField55(grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId, grpHdr.SttlmInf.ThrdRmbrsmntAgtAcct?.Id, true);
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(firstTransaction.IntrmyAgt1?.FinInstnId, firstTransaction.IntrmyAgt1Acct?.Id, isOptionCPresent = true);
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(firstTransaction.CdtrAgt?.FinInstnId, firstTransaction.CdtrAgtAcct?.Id, true, true);
    swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(firstTransaction.Cdtr, firstTransaction.CdtrAcct?.Id);

    swiftmt:MT13C? MT13C = check convertTimeToMT13C(firstTransaction.SttlmTmIndctn, firstTransaction.SttlmTmReq);

    swiftmt:MT20 MT20 = {
        name: MT20_NAME,
        msgId: {
            content: envelope.Document.FIToFICstmrCdtTrf.GrpHdr.MsgId,
            number: NUMBER1
        }
    };

    swiftmt:MT23B MT23B = getField23B(firstTransaction.PmtTpInf?.LclInstrm?.Prtry);

    swiftmt:MT23E[]? MT23E = ();
    swiftmt:MT23E[] field23E = getField23EForMt103(firstTransaction.InstrForCdtrAgt, firstTransaction.InstrForNxtAgt,firstTransaction.PmtTpInf?.SvcLvl, firstTransaction.PmtTpInf?.CtgyPurp);
    if field23E.length() > 0 {
        MT23E = field23E;
    }

    swiftmt:MT26T? MT26T = getField26T(firstTransaction.Purp?.Prtry);

    swiftmt:MT32A MT32A = {
        name: MT32A_NAME,
        Dt: {content: convertToSWIFTStandardDate(firstTransaction.IntrBkSttlmDt), number: NUMBER1},
        Ccy: {content: getMandatoryField(firstTransaction.IntrBkSttlmAmt?.Ccy), number: NUMBER2},
        Amnt: {content: check convertToString(firstTransaction.IntrBkSttlmAmt?.content), number: NUMBER3}
    };

    swiftmt:MT33B? MT33B = check getField33B(firstTransaction.InstdAmt, firstTransaction.IntrBkSttlmAmt);

    swiftmt:MT36? MT36 = check getField36(firstTransaction.XchgRate);

    swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
    swiftmt:MT50F? MT50F = field50a is swiftmt:MT50F ? field50a : ();
    swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

    swiftmt:MT51A? MT51A = getField51A(grpHdr.InstgAgt?.FinInstnId);

    swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
    swiftmt:MT52D? MT52D = field52 is swiftmt:MT52D ? field52 : ();

    swiftmt:MT53A? MT53A = field53 is swiftmt:MT53A ? field53 : ();
    swiftmt:MT53B? MT53B = field53 is swiftmt:MT53B ? field53 : ();

    swiftmt:MT54A? MT54A = field54 is swiftmt:MT54A ? field54 : ();
    swiftmt:MT54B? MT54B = field54 is swiftmt:MT54B ? field54 : ();
    swiftmt:MT54D? MT54D = field54 is swiftmt:MT54D ? field54 : ();

    swiftmt:MT55A? MT55A = field55 is swiftmt:MT55A ? field55 : ();
    swiftmt:MT55B? MT55B = field55 is swiftmt:MT55B ? field55 : ();
    swiftmt:MT55D? MT55D = field55 is swiftmt:MT55D ? field55 : ();

    swiftmt:MT56A? MT56A = field56 is swiftmt:MT56A ? field56 : ();
    swiftmt:MT56C? MT56C = field56 is swiftmt:MT56C ? field56 : ();
    swiftmt:MT56D? MT56D = field56 is swiftmt:MT56D ? field56 : ();

    swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
    swiftmt:MT57B? MT57B = field57 is swiftmt:MT57B ? field57 : ();
    swiftmt:MT57C? MT57C = field57 is swiftmt:MT57C ? field57 : ();
    swiftmt:MT57D? MT57D = field57 is swiftmt:MT57D ? field57 : ();

    swiftmt:MT59? MT59 = field59 is swiftmt:MT59 ? field59 : ();
    swiftmt:MT59A? MT59A = field59 is swiftmt:MT59A ? field59 : ();
    swiftmt:MT59F? MT59F = field59 is swiftmt:MT59F ? field59 : ();

    swiftmt:MT70? MT70 = getRemittanceInformation(firstTransaction.PmtId, firstTransaction.RmtInf, firstTransaction.Purp);

    swiftmt:MT71A MT71A = {
        name: MT71A_NAME,
        Cd: getDetailsOfChargesFromChargeBearerType1Code(firstTransaction.ChrgBr)
    };
    swiftmt:MT71F? MT71F = check convertCharges16toMT71F(firstTransaction.ChrgsInf, firstTransaction.ChrgBr);
    swiftmt:MT71G? MT71G = check convertCharges16toMT71G(firstTransaction.ChrgsInf, firstTransaction.ChrgBr);

    swiftmt:MT72? MT72 = getField72(firstTransaction.InstrForCdtrAgt, firstTransaction.InstrForNxtAgt, firstTransaction.PrvsInstgAgt1, firstTransaction.IntrmyAgt2, firstTransaction.PmtTpInf?.SvcLvl, firstTransaction.PmtTpInf?.CtgyPurp, firstTransaction.PmtTpInf?.LclInstrm);
    swiftmt:MT77B? MT77B = getField77B(firstTransaction.RgltryRptg);
    swiftmt:MT77T MT77T = getField77T(firstTransaction.SplmtryData, firstTransaction.RmtInf?.Ustrd);

    match messageType {
        MT103 => {
            swiftmt:MT103Block4 MT103Block4 = {
                MT20,
                MT13C,
                MT23B,
                MT23E,
                MT26T,
                MT32A,
                MT33B,
                MT36,
                MT50A,
                MT50F,
                MT50K,
                MT51A,
                MT52A,
                MT52D,
                MT53A,
                MT53B,
                MT54A,
                MT54B,
                MT54D,
                MT55A,
                MT55B,
                MT55D,
                MT56A,
                MT56C,
                MT56D,
                MT57A,
                MT57B,
                MT57C,
                MT57D,
                MT59,
                MT59A,
                MT59F,
                MT70,
                MT71A,
                MT71F,
                MT71G,
                MT72,
                MT77B
            };

            return MT103Block4;
        }

        MT103_STP => {
            swiftmt:MT103STPBlock4 MT103STPBlock4 = {
                MT20,
                MT13C,
                MT23B,
                MT23E,
                MT26T,
                MT32A,
                MT33B,
                MT36,
                MT50A,
                MT50F,
                MT50K,
                MT52A,
                MT53A,
                MT53B,
                MT54A,
                MT55A,
                MT56A,
                MT57A,
                MT59,
                MT59A,
                MT59F,
                MT70,
                MT71A,
                MT71F,
                MT71G,
                MT72,
                MT77B
            };

            return MT103STPBlock4;
        }

        MT103_REMIT => {
            swiftmt:MT103REMITBlock4 MT103REMITBlock4 = {
                MT20,
                MT13C,
                MT23B,
                MT23E,
                MT26T,
                MT32A,
                MT33B,
                MT36,
                MT50A,
                MT50F,
                MT50K,
                MT51A,
                MT52A,
                MT52D,
                MT53A,
                MT53B,
                MT54A,
                MT54B,
                MT54D,
                MT55A,
                MT55B,
                MT55D,
                MT56A,
                MT56C,
                MT56D,
                MT57A,
                MT57B,
                MT57C,
                MT57D,
                MT59,
                MT59A,
                MT59F,
                MT71A,
                MT71F,
                MT71G,
                MT72,
                MT77B,
                MT77T
            };

            return MT103REMITBlock4;
        }
    }

    return error("Error occurred while creating MT103 block4");

}
