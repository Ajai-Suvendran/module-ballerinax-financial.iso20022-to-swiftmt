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

# This function transforms a camt.029 ISO 20022 message into an MTn96 SWIFT format message.
#
# + envelope - The camt.029 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn96 message type to be transformed.
# + return - Returns an MTn96 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt029ToMtn96(camtIsoRecord:Camt029Envelope envelope, string messageType) returns swiftmt:MTn96Message|error => let
    camtIsoRecord:PaymentTransaction152 cancellationDtls = check getTransactionInfoAndSts(check getCancellationDetails(envelope.Document.RsltnOfInvstgtn.CxlDtls)),
    var [field76, field77A] = getField76(cancellationDtls.CxlStsRsnInf, envelope.Document.RsltnOfInvstgtn.Sts.Conf) in {
        block1: {
            applicationId:"F",
            serviceId: "01",
            logicalTerminal: getSenderOrReceiver(envelope.Document.RsltnOfInvstgtn.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.RsltnOfInvstgtn.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.RsltnOfInvstgtn.Assgnmt.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.RsltnOfInvstgtn.Assgnmt.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(cancellationDtls.OrgnlUETR),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMandatoryField(cancellationDtls.CxlStsId), number: NUMBER1}},
            MT21: {name: MT21_NAME, Ref: {content: getMandatoryField(cancellationDtls.RslvdCase?.Id), number: NUMBER1}},
            MT11R: {
                name: MT11R_NAME,
                Dt: {content: convertToSWIFTStandardDate(cancellationDtls.OrgnlGrpInf?.OrgnlCreDtTm), number: NUMBER2},
                MtNum: {content: getMandatoryField(cancellationDtls.OrgnlGrpInf?.OrgnlMsgNmId), number: NUMBER1}
            },
            MT76: field76,
            MT77A: field77A
        }
    };
