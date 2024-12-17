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

import ballerina/data.xmldata;

public isolated function toSwiftMtMessage(xml xmlContent, string messageType) returns record {}|error {
    string? isoMessageType = (check (xmlContent/**/<Document>).ensureType(xml:Element)).getAttributes()["{" + xml:XMLNS_NAMESPACE_URI + "}xmlns"];
    if isoMessageType is () {
        return error("Invalid xml: Cannot be converted to SWIFT MT message.");
    }
    typedesc<record {}>? recordType = isoMessageTypes[isoMessageType];
    if recordType is () {
        return error("ISO 20022 message type not supported.");
    }
    isolated function? transformFunction = transformFunctionMap[messageType];
    if transformFunction is () {
        return error("ISO 20022 xml to SWIFT MT fin message is not supported.");
    }
    record {} inputRecord = check xmldata:parseAsType(xmlContent);
    return function:call(transformFunction, [inputRecord, messageType.substring(0, 3)]).ensureType();
}