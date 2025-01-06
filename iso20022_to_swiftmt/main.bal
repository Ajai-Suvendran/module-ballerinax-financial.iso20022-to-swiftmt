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

# Converts an ISO 20022 XML message to its corresponding SWIFT MT message format.
#
# The function uses a map of transformation functions for different ISO 20022 message types
# and applies the appropriate transformation based on the provided XML content and target SWIFT MT message type.
#
# + xmlContent - The ISO 20022 XML content that needs to be converted.
# + messageType - The target SWIFT MT message type (e.g., "103", "102STP","202", "202COV").
# + return - Returns the transformed SWIFT MT message as a record value or an error if the conversion fails.
public isolated function toSwiftMtMessage(xml xmlContent, string messageType) returns record {}|error {
    xml:Element document = xml `<Empty/>`;
    foreach xml:Element element in xmlContent.elementChildren() {
        if element.getName().includes("Document") {
            document = element;
        }
    }
    string? isoMessageType = (document).getAttributes()["{" + xml:XMLNS_NAMESPACE_URI + "}xmlns"];
    if isoMessageType is () {
        return error("Invalid xml: Cannot be converted to SWIFT MT message.");
    }
    typedesc<record {}>? recordType = isoMessageTypes[isoMessageType.substring(31, 39)];
    if recordType is () {
        return error("ISO 20022 message type not supported.");
    }
    isolated function? transformFunction = transformFunctionMap[messageType];
    if transformFunction is () {
        return error("ISO 20022 xml to SWIFT MT message is not supported.");
    }
    return function:call(transformFunction, check xmldata:parseAsType(xmlContent, {textFieldName: "content"}, recordType), messageType.substring(0, 3)).ensureType();
}
