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

import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# generate the MT104 message from the Pain008 document
#
# + envelope - The Pain008 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT104 message or an error if the transformation fails
function transformPain008DocumentToMT104(painIsoRecord:Pain008Envelope envelope, string messageType) returns swiftmt:MT104Message|error => let
    swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104InstructionPartyFromPain008Document(envelope.Document),
    swiftmt:MT50A?|swiftmt:MT50K? creditor = getMT104CreditorFromPain008Document(envelope.Document),
    swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank = getMT104CreditorsBankFromPain008Document(envelope.Document),
    swiftmt:MT53A?|swiftmt:MT53B? sendersCorrespondent = getMT104SendersCorrespondentFromPain008Document(envelope.Document),
    swiftmt:MT104Transaction[] transactions = check generateMT104Transactions(envelope.Document.CstmrDrctDbtInitn.PmtInf, instructingParty, creditor, creditorsBank)
    in {
        block1: {
            applicationId: "F",
            serviceId: "01",
            logicalTerminal: envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI,
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.CstmrDrctDbtInitn.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.CstmrDrctDbtInitn.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: {
                name: MT19_NAME,
                Amnt: {
                    content: envelope.Document.CstmrDrctDbtInitn.GrpHdr.CtrlSum.toString(),
                    number: NUMBER1
                }
            },
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21R: {
                name: MT21R_NAME,
                Ref: {
                    content: EMPTY_STRING,
                    number: NUMBER1
                }
            },
            MT23E: {
                name: MT23E_NAME,
                InstrnCd: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].PmtTpInf?.CtgyPurp?.Cd),
                    number: NUMBER1
                }
            },
            MT21E: {
                name: MT21E_NAME,
                Ref: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.GrpHdr.MsgId),
                    number: NUMBER1
                }
            },
            MT30: {
                name: MT30_NAME,
                Dt: check convertISODateStringToSwiftMtDate(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].ReqdColltnDt, NUMBER1)
            },
            MT51A: {
                name: MT51A_NAME,
                IdnCd: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.BICFI),
                    number: NUMBER1
                },
                PrtyIdn: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.LEI),
                    number: NUMBER2
                }
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: creditor is swiftmt:MT50A ? creditor : (),
            MT50K: creditor is swiftmt:MT50K ? creditor : (),
            MT52A: creditorsBank is swiftmt:MT52A ? creditorsBank : (),
            MT52C: creditorsBank is swiftmt:MT52C ? creditorsBank : (),
            MT52D: creditorsBank is swiftmt:MT52D ? creditorsBank : (),
            MT26T: {
                name: MT26T_NAME,
                Typ: {content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].Purp?.Cd), number: NUMBER1}
            },
            MT77B: {
                name: MT77B_NAME,
                Nrtv: {content: EMPTY_STRING, number: EMPTY_STRING}
            },
            MT71A: {
                name: MT71A_NAME,
                Cd: getDetailsOfChargesFromChargeBearerType1Code(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].ChrgBr)
            },
            MT72: {
                name: MT72_NAME,
                Cd: {content: EMPTY_STRING, number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: getActiveOrHistoricCurrencyAndAmountCcy(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].InstdAmt), number: NUMBER1},
                Amnt: {content: getActiveOrHistoricCurrencyAndAmountValue(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].InstdAmt), number: NUMBER2}
            },
            MT71F: {
                name: MT71F_NAME,
                Ccy: {content: EMPTY_STRING, number: NUMBER1},
                Amnt: {content: EMPTY_STRING, number: NUMBER2}
            },
            MT71G: {
                name: MT71G_NAME,
                Ccy: {content: EMPTY_STRING, number: NUMBER1},
                Amnt: {content: EMPTY_STRING, number: NUMBER2}
            },
            MT53A: sendersCorrespondent is swiftmt:MT53A ? sendersCorrespondent : (),
            MT53B: sendersCorrespondent is swiftmt:MT53B ? sendersCorrespondent : (),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.CstmrDrctDbtInitn.SplmtryData)
    };

# generate the MT104 transactions from the Pain008 envelope.Document
#
# + mxTransactions - The Pain008 transactions
# + instrutingParty - The instructing party
# + creditor - The creditor
# + creditorsBank - The creditor's bank
# + return - The MT104 transactions
isolated function generateMT104Transactions(
        painIsoRecord:PaymentInstruction45[] mxTransactions,
        swiftmt:MT50C?|swiftmt:MT50L? instrutingParty,
        swiftmt:MT50A?|swiftmt:MT50K? creditor,
        swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank
) returns swiftmt:MT104Transaction[]|error {
    swiftmt:MT104Transaction[] transactions = [];
    foreach painIsoRecord:PaymentInstruction45 mxTransaction in mxTransactions {
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: getEmptyStrIfNull(mxTransaction.PmtInfId),
                number: NUMBER1
            }
        };

        swiftmt:MT23E MT23E = {
            name: MT23E_NAME,
            InstrnCd: {content: getEmptyStrIfNull(mxTransaction.PmtTpInf?.CtgyPurp?.Cd), number: NUMBER1}
        };

        swiftmt:MT21C MT21C = {
            name: MT21_NAME,
            Ref: {
                content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].DrctDbtTx?.MndtRltdInf?.MndtId),
                number: NUMBER1
            }
        };

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {content: getActiveOrHistoricCurrencyAndAmountCcy(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: NUMBER1},
            Amnt: {content: getActiveOrHistoricCurrencyAndAmountValue(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: NUMBER2}
        };

        swiftmt:MT50C? MT50C = instrutingParty is swiftmt:MT50C ? instrutingParty : ();
        swiftmt:MT50L? MT50L = instrutingParty is swiftmt:MT50L ? instrutingParty : ();

        swiftmt:MT50A? MT50A = creditor is swiftmt:MT50A ? creditor : ();
        swiftmt:MT50K? MT50K = creditor is swiftmt:MT50K ? creditor : ();

        swiftmt:MT52A? MT52A = creditorsBank is swiftmt:MT52A ? creditorsBank : ();
        swiftmt:MT52C? MT52C = creditorsBank is swiftmt:MT52C ? creditorsBank : ();
        swiftmt:MT52D? MT52D = creditorsBank is swiftmt:MT52D ? creditorsBank : ();

        swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? debtorsBank = getMT104TransactionDebtorsBankFromPain008Document(mxTransaction);
        swiftmt:MT57A? MT57A = debtorsBank is swiftmt:MT57A ? debtorsBank : ();
        swiftmt:MT57C? MT57C = debtorsBank is swiftmt:MT57C ? debtorsBank : ();
        swiftmt:MT57D? MT57D = debtorsBank is swiftmt:MT57D ? debtorsBank : ();

        swiftmt:MT59?|swiftmt:MT59A? debtor = getMT104TransactionDebtorFromPain008Document(mxTransaction);
        swiftmt:MT59? MT59 = debtor is swiftmt:MT59 ? debtor : ();
        swiftmt:MT59A? MT59A = debtor is swiftmt:MT59A ? debtor : ();

        swiftmt:MT26T MT26T = {
            name: MT26T_NAME,
            Typ: {content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].Purp?.Cd), number: NUMBER1}
        };

        swiftmt:MT33B MT33B = {
            name: MT33B_NAME,
            Ccy: {content: getActiveOrHistoricCurrencyAndAmountCcy(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: NUMBER1},
            Amnt: {content: getActiveOrHistoricCurrencyAndAmountValue(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: NUMBER2}
        };

        swiftmt:MT71A MT71A = {
            name: MT71A_NAME,
            Cd: getDetailsOfChargesFromChargeBearerType1Code(mxTransaction.ChrgBr)
        };

        transactions.push({
            MT21,
            MT23E,
            MT21C,
            MT32B,
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
            MT26T,
            MT33B,
            MT71A
        });

    }
    return transactions;
}
