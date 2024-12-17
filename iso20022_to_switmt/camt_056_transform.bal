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
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.056 ISO 20022 message into an MT192 SWIFT format message.
#
# + document - The camt.056 message to be transformed, in `camtIsoRecord:Camt056Document` format.
# + messageType - The message type to which the ISO 20022 is being transformed.
# + return - Returns an MTn92 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt056ToMtn92(camtIsoRecord:Camt056Document document, string messageType) returns swiftmt:MTn92Message|error => let camtIsoRecord:PaymentTransaction155[] transactionInfo = check getTransactionInfo(document.FIToFIPmtCxlReq.Undrlyg[0].TxInf) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FIToFIPmtCxlReq.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FIToFIPmtCxlReq.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFIPmtCxlReq.Assgnmt.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FIToFIPmtCxlReq.Assgnmt.CreDtTm.substring(0, 10))}
        },
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: getMandatoryField(transactionInfo[0].Case?.Id), number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {content: getMandatoryField(transactionInfo[0].OrgnlInstrId), number: NUMBER1}
            },
            MT11S: {
                name: MT11S_NAME,
                Dt: {content: convertToSWIFTStandardDate(transactionInfo[0].OrgnlGrpInf?.OrgnlCreDtTm), number: NUMBER2},
                MtNum: {content: getOrignalMessageName(transactionInfo[0].OrgnlGrpInf?.OrgnlMsgNmId), number: NUMBER1}
            },
            MT79: getField79(transactionInfo[0].CxlRsnInf)
        }
    };
