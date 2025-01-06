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

isolated function transformCamt057ToMt210(camtIsoRecord:Camt057Envelope envelope, string messageType) returns swiftmt:MT210Message|error => let
    camtIsoRecord:NotificationItem9 notificationItem = envelope.Document.NtfctnToRcv.Ntfctn.Itm[0],
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? field50 = getField50Or50COr50L(notificationItem.Dbtr?.Pty),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(notificationItem.DbtrAgt?.FinInstnId),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(notificationItem.IntrmyAgt?.FinInstnId),
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getField50a(notificationItem.Dbtr?.Pty)
    in {
        block1: {
            applicationId:"F",
            serviceId: "01",
            logicalTerminal: envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI,
            senderInputTime: {content: check convertToSwiftTimeFormat(envelope.Document.NtfctnToRcv.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(envelope.Document.NtfctnToRcv.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(envelope.Document.NtfctnToRcv.Ntfctn.Itm[0].UETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: envelope.Document.NtfctnToRcv.Ntfctn.Id, number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {content: getField21(notificationItem.EndToEndId, id = notificationItem.Id), number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: notificationItem.Amt.Ccy, number: NUMBER1},
                Amnt: {content: check convertToString(notificationItem.Amt.content), number: NUMBER2}
            },
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(notificationItem.XpctdValDt), number: NUMBER1}
            },
            MT25: getField25(notificationItem.Acct?.Id?.IBAN, notificationItem.Acct?.Id?.Othr?.Id),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT50: field50 is swiftmt:MT50 ? field50 : (),
            MT50C: field50 is swiftmt:MT50C ? field50 : (),
            MT50F: field50a is swiftmt:MT50F ? field50a : ()
        }
    };
