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

# This function transforms a camt.031 ISO 20022 message into an MTn96 SWIFT format message.
#
# + envelope - The camt.031 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn96 message type to be transformed.
# + return - Returns an MTn96 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt031ToMtn96(camtIsoRecord:Camt031Envelope envelope, string messageType) returns swiftmt:MTn96Message|error => {
    block1: {
        applicationId:"F",
        serviceId: "01",
        logicalTerminal: getSenderOrReceiver(envelope.Document.RjctInvstgtn.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(envelope.Document.RjctInvstgtn.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI, envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.RjctInvstgtn.Assgnmt.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.RjctInvstgtn.Assgnmt.CreDtTm.substring(0, 10))}
    },
    block4:
        {
        MT20: check getMT20(envelope.Document.RjctInvstgtn.Case?.Id),
        MT21: {
            name: MT21_NAME,
            Ref: {
                content: envelope.Document.RjctInvstgtn.Assgnmt.Id,
                number: NUMBER1
            }
        },
        MT11S: { // TODO - Implement the correct mapping
            name: MT11S_NAME,
            MtNum: {
                content: "031", // TODO - Implement the correct mapping
                number: NUMBER1
            },
            Dt: check convertISODateStringToSwiftMtDate(envelope.Document.RjctInvstgtn.Assgnmt.CreDtTm.toString())
        }
,
        MT76: {
            name: MT76_NAME,
            Nrtv: {
                content: getRejectionReasonNarrative(envelope.Document.RjctInvstgtn.Justfn.RjctnRsn),
                number: NUMBER1
            }
        },
        MT79: envelope.Document.RjctInvstgtn.SplmtryData is camtIsoRecord:SupplementaryData1[] ? {
                name: MT79_NAME,
                Nrtv: getAdditionalNarrativeInfo(envelope.Document.RjctInvstgtn.SplmtryData)
            } : (),
        MessageCopy: () // TODO - Need to add the relavent field mapping for this using the official mappings
    },
    block5: check generateMtBlock5FromSupplementaryData(envelope.Document.RjctInvstgtn.SplmtryData),
    unparsedTexts: ()
};
