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

isolated function transformPacs010ToMt204(pacsIsoRecord:Pacs010Envelope envelope, string messageType) returns swiftmt:MT204Message|error => let
    pacsIsoRecord:CreditTransferTransaction66 debitTransfer = envelope.Document.FIDrctDbt.CdtInstr[0],
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(debitTransfer.CdtrAgt?.FinInstnId, debitTransfer.CdtrAgtAcct?.Id, true),
    swiftmt:MT58A?|swiftmt:MT58D? field58 = check getField58(debitTransfer.Cdtr?.FinInstnId, debitTransfer.CdtrAcct?.Id) in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FIDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FIDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FIDrctDbt.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FIDrctDbt.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FIDrctDbt.CdtInstr[0].DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: {
                name: MT19_NAME,
                Amnt: {content: check convertToString(envelope.Document.FIDrctDbt.GrpHdr.CtrlSum), number: NUMBER1}
            },
            MT20: {
                name: MT20_NAME,
                msgId: {content: debitTransfer.CdtId, number: NUMBER1}
            },
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(debitTransfer.IntrBkSttlmDt), number: NUMBER1}
            },
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: field58 is swiftmt:MT58A ? field58 : (),
            MT58D: field58 is swiftmt:MT58D ? field58 : (),
            Transaction: check getMT204Transaction(debitTransfer.DrctDbtTxInf)
        }
    };

isolated function getMT204Transaction(pacsIsoRecord:DirectDebitTransactionInformation33[] debitTransaction) returns swiftmt:MT204Transaction[]|error {
    swiftmt:MT204Transaction[] transactionArray = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation33 transaxion in debitTransaction {
        swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(transaxion.Dbtr?.FinInstnId, transaxion.DbtrAcct?.Id, isOptionBPresent = true);
        transactionArray.push({
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(transaxion.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {name: MT21_NAME, Ref: {content: transaxion.PmtId.EndToEndId, number: NUMBER1}},
            MT32B: {
                name: MT32B_NAME,
                Ccy: {
                    content: transaxion.IntrBkSttlmAmt?.Ccy,
                    number: NUMBER1
                },
                Amnt: {
                    content: check convertToString(transaxion.IntrBkSttlmAmt?.content),
                    number: NUMBER2
                }
            },
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT53D: field53 is swiftmt:MT53D ? field53 : ()
        });
    }
    return transactionArray;
}
