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

# This function transforms a camt.055 ISO 20022 message into an MTn92 SWIFT format message.
#
# + envelope - The camt.055 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn92 message type to be transformed.
# + return - Returns an MTn92 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt055ToMtn92(camtIsoRecord:Camt055Envelope envelope, string messageType) returns swiftmt:MTn92Message|error => let
    camtIsoRecord:UnderlyingTransaction33 undrlygTransaction = envelope.Document.CstmrPmtCxlReq.Undrlyg[0] in {
        block1: {
            applicationId:"F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.CstmrPmtCxlReq.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.CstmrPmtCxlReq.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.CstmrPmtCxlReq.Assgnmt.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.CstmrPmtCxlReq.Assgnmt.CreDtTm.substring(0, 10))}
        },
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: getMandatoryField(undrlygTransaction.OrgnlGrpInfAndCxl?.Case?.Id), number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {content: getMandatoryField((check getOrginalPaymentInfo(undrlygTransaction.OrgnlPmtInfAndCxl)).OrgnlPmtInfId), number: NUMBER1}
            },
            MT11S: {
                name: MT11S_NAME,
                Dt: {content: convertToSWIFTStandardDate(undrlygTransaction.OrgnlGrpInfAndCxl?.OrgnlCreDtTm), number: NUMBER2},
                MtNum: {content: getOrignalMessageName(undrlygTransaction.OrgnlGrpInfAndCxl?.OrgnlMsgNmId), number: NUMBER1}
            },
            MT79: getField79((check getOrginalPaymentInfo(undrlygTransaction.OrgnlPmtInfAndCxl)).CxlRsnInf)
        }
    };
