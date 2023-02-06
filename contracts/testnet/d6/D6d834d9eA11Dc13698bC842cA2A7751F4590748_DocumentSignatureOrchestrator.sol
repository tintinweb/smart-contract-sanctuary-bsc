// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;


contract DocumentSignatureOrchestrator {

    mapping(address => int) signaturesNo;

    function getSignaturesNumber(address hash) public view returns (int) {
        return signaturesNo[hash];
    }
}