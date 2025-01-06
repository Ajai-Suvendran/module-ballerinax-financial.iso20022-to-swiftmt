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

isolated function transformPacs009ToMt200(pacsIsoRecord:Pacs009Envelope envelope, string messageType) returns swiftmt:MT200Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = envelope.Document.FICdtTrf.CdtTrfTxInf[0],
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(creditTransfer.Dbtr.FinInstnId, creditTransfer.DbtrAcct?.Id, true),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId, creditTransfer.IntrmyAgt1Acct?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.Cdtr?.FinInstnId, creditTransfer.CdtrAcct?.Id, true)
    in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT32A: {
                name: "32A",
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.content),
                    number: NUMBER2
                }
            },
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt)
        }
    };

isolated function transformPacs009ToMt201(pacsIsoRecord:Pacs009Envelope envelope, string messageType) returns swiftmt:MT201Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = envelope.Document.FICdtTrf.CdtTrfTxInf[0],
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(creditTransfer.Dbtr.FinInstnId, creditTransfer.DbtrAcct?.Id, true) in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT30: {name: MT30_NAME, Dt: {content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt), number: NUMBER1}},
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT72: getRepeatingField72(envelope.Document.FICdtTrf.CdtTrfTxInf),
            Transaction: check getMT201Transaction(envelope.Document.FICdtTrf.CdtTrfTxInf),
            MT19: {name: MT19_NAME, Amnt: {content: check convertToString(envelope.Document.FICdtTrf.GrpHdr.CtrlSum), number: NUMBER1}}
        }
    };

isolated function getMT201Transaction(pacsIsoRecord:CreditTransferTransaction62[] creditTransaction) returns swiftmt:MT201Transaction[]|error {
    swiftmt:MT201Transaction[] transactionArray = [];
    foreach pacsIsoRecord:CreditTransferTransaction62 transaxion in creditTransaction {
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(transaxion.IntrmyAgt1?.FinInstnId, transaxion.IntrmyAgt1Acct?.Id);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(transaxion.Cdtr?.FinInstnId, transaxion.CdtrAcct?.Id, true);
        transactionArray.push({
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(transaxion.PmtId.InstrId),
                    number: NUMBER1
                }
            },
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
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT72: getRepeatingField72(creditTransaction, transaxion, true)
        });
    }
    return transactionArray;
}

isolated function transformPacs009ToMt202(pacsIsoRecord:Pacs009Envelope envelope, string messageType) returns swiftmt:MT202Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = envelope.Document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = envelope.Document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId, creditTransfer.DbtrAcct?.Id),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId, settlementInfo.InstgRmbrsmntAgtAcct?.Id, true),
    swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? field54 = getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId, settlementInfo.InstdRmbrsmntAgtAcct?.Id, true),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId, creditTransfer.IntrmyAgt1Acct?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId, creditTransfer.CdtrAgtAcct?.Id, true),
    swiftmt:MT58A?|swiftmt:MT58D? field58 = check getField58(creditTransfer.Cdtr?.FinInstnId, creditTransfer.CdtrAcct?.Id) in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.content),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT53D: field53 is swiftmt:MT53D ? field53 : (),
            MT54A: field54 is swiftmt:MT54A ? field54 : (),
            MT54B: field54 is swiftmt:MT54B ? field54 : (),
            MT54D: field54 is swiftmt:MT54D ? field54 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: field58 is swiftmt:MT58A ? field58 : (),
            MT58D: field58 is swiftmt:MT58D ? field58 : (),
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt)
        }
};

isolated function transformPacs009ToMt202COV(pacsIsoRecord:Pacs009Envelope envelope, string messageType) returns swiftmt:MT202COVMessage|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = envelope.Document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = envelope.Document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId, creditTransfer.DbtrAcct?.Id),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId, settlementInfo.InstgRmbrsmntAgtAcct?.Id, true),
    swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? field54 = getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId, settlementInfo.InstdRmbrsmntAgtAcct?.Id, true),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId, creditTransfer.IntrmyAgt1Acct?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId, creditTransfer.CdtrAgtAcct?.Id, true),
    swiftmt:MT58A?|swiftmt:MT58D? field58 = check getField58(creditTransfer.Cdtr?.FinInstnId, creditTransfer.CdtrAcct?.Id) in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_COV),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.content),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT53D: field53 is swiftmt:MT53D ? field53 : (),
            MT54A: field54 is swiftmt:MT54A ? field54 : (),
            MT54B: field54 is swiftmt:MT54B ? field54 : (),
            MT54D: field54 is swiftmt:MT54D ? field54 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: field58 is swiftmt:MT58A ? field58 : (),
            MT58D: field58 is swiftmt:MT58D ? field58 : (),
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt),
            UndrlygCstmrCdtTrf: check getUnderlyingCustomerTransaction(creditTransfer)
        }
};

isolated function getUnderlyingCustomerTransaction(pacsIsoRecord:CreditTransferTransaction62 creditTransfer) returns swiftmt:UndrlygCstmrCdtTrf|error {
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getField50a(creditTransfer.UndrlygCstmrCdtTrf?.Dbtr, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAcct?.Id);
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgtAcct?.Id);
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1Acct?.Id);
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id, true);
    swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(creditTransfer.UndrlygCstmrCdtTrf?.Cdtr, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAcct?.Id);
    return {
        MT33B: check getField33B(creditTransfer.UndrlygCstmrCdtTrf?.InstdAmt, (), true),
        MT50F: field50a is swiftmt:MT50F ? field50a : (),
        MT50A: field50a is swiftmt:MT50A ? field50a : (),
        MT50K: field50a is swiftmt:MT50K ? field50a : (),
        MT52A: field52 is swiftmt:MT52A ? field52 : (),
        MT52D: field52 is swiftmt:MT52D ? field52 : (),
        MT56A: field56 is swiftmt:MT56A ? field56 : (),
        MT56D: field56 is swiftmt:MT56D ? field56 : (),
        MT57A: field57 is swiftmt:MT57A ? field57 : (),
        MT57B: field57 is swiftmt:MT57B ? field57 : (),
        MT57D: field57 is swiftmt:MT57D ? field57 : (),
        MT59: field59 is swiftmt:MT59 ? field59 : (),
        MT59A: field59 is swiftmt:MT59A ? field59 : (),
        MT59F: field59 is swiftmt:MT59F ? field59 : (),
        MT70: getField70(creditTransfer.UndrlygCstmrCdtTrf?.RmtInf?.Ustrd),
        MT72: getField72(creditTransfer.UndrlygCstmrCdtTrf?.InstrForCdtrAgt, creditTransfer.UndrlygCstmrCdtTrf?.InstrForNxtAgt)
    };
}

isolated function transformPacs009ToMt203(pacsIsoRecord:Pacs009Envelope envelope, string messageType) returns swiftmt:MT203Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = envelope.Document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = envelope.Document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId, creditTransfer.DbtrAcct?.Id),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId, settlementInfo.InstgRmbrsmntAgtAcct?.Id, true),
    swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? field54 = getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId, settlementInfo.InstdRmbrsmntAgtAcct?.Id, true) in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT19: {name: MT19_NAME, Amnt: {content: check convertToString(envelope.Document.FICdtTrf.GrpHdr.CtrlSum), number: NUMBER1}},
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt), number: NUMBER1}
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT53D: field53 is swiftmt:MT53D ? field53 : (),
            MT54A: field54 is swiftmt:MT54A ? field54 : (),
            MT54B: field54 is swiftmt:MT54B ? field54 : (),
            MT72: getRepeatingField72(envelope.Document.FICdtTrf.CdtTrfTxInf),
            Transaction: check getMT203Transaction(envelope.Document.FICdtTrf.CdtTrfTxInf)
        }
    };

isolated function getMT203Transaction(pacsIsoRecord:CreditTransferTransaction62[] creditTransaction) returns swiftmt:MT203Transaction[]|error {
    swiftmt:MT203Transaction[] transactionArray = [];
    foreach pacsIsoRecord:CreditTransferTransaction62 transaxion in creditTransaction {
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(transaxion.IntrmyAgt1?.FinInstnId, transaxion.IntrmyAgt1Acct?.Id);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(transaxion.CdtrAgt?.FinInstnId, transaxion.CdtrAgtAcct?.Id, true);
        swiftmt:MT58A?|swiftmt:MT58D? field58 = check getField58(transaxion.Cdtr?.FinInstnId, transaxion.CdtrAcct?.Id);
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
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: field58 is swiftmt:MT58A ? field58 : (),
            MT58D: field58 is swiftmt:MT58D ? field58 : (),
            MT72: getRepeatingField72(creditTransaction, transaxion, true)
        });
    }
    return transactionArray;
}

isolated function transformPacs009ToMt205(pacsIsoRecord:Pacs009Envelope envelope, string messageType) returns swiftmt:MT205Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = envelope.Document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = envelope.Document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId, creditTransfer.DbtrAcct?.Id),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId, settlementInfo.InstgRmbrsmntAgtAcct?.Id, true),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId, creditTransfer.IntrmyAgt1Acct?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId, creditTransfer.CdtrAgtAcct?.Id, true),
    swiftmt:MT58A?|swiftmt:MT58D? field58 = check getField58(creditTransfer.Cdtr?.FinInstnId, creditTransfer.CdtrAcct?.Id) in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.content),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT53D: field53 is swiftmt:MT53D ? field53 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: field58 is swiftmt:MT58A ? field58 : (),
            MT58D: field58 is swiftmt:MT58D ? field58 : (),
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt)
        }
};

isolated function transformPacs009ToMt205COV(pacsIsoRecord:Pacs009Envelope envelope, string messageType) returns swiftmt:MT205COVMessage|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = envelope.Document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = envelope.Document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId, creditTransfer.DbtrAcct?.Id),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId, settlementInfo.InstgRmbrsmntAgtAcct?.Id, true),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId, creditTransfer.IntrmyAgt1Acct?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId, creditTransfer.CdtrAgtAcct?.Id, true),
    swiftmt:MT58A?|swiftmt:MT58D? field58 = check getField58(creditTransfer.Cdtr?.FinInstnId, creditTransfer.CdtrAcct?.Id) in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_COV),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.content),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT53D: field53 is swiftmt:MT53D ? field53 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: field58 is swiftmt:MT58A ? field58 : (),
            MT58D: field58 is swiftmt:MT58D ? field58 : (),
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt),
            UndrlygCstmrCdtTrf: check getUnderlyingCustomerTransaction(creditTransfer)
        }
};
