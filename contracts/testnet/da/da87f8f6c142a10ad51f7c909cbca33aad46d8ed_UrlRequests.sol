// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;
import "./provableAPI.sol";

contract UrlRequests is usingProvable {

    event LogConstructorInitiated(string nextStep);
    event LogNewProvableQuery(string description);
    event LogResult(string result);

    constructor()
        public
    {
        emit LogConstructorInitiated("Constructor was initiated. Call 'requestPost()' to send the Provable Query.");
    }

    function __callback(
        string memory _result
    )
        public
    {
        require(msg.sender == provable_cbAddress());
        emit LogResult(_result);
    }

    // function request(
    //     string memory _url,
    //     string memory _jsonData
    // )
    //     public
    //     // payable
    // {
    //     if (provable_getPrice("URL") > address(this).balance) {
    //         emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
    //     } else {
    //         emit LogNewProvableQuery("Provable query was sent, standing by for the answer..");
    //         provable_query("URL", _url, _jsonData); //json(https://www.pipsr.cloud/api/v1/address-security).data.trust_level
    //     }
    // }

    // Just for demo
    function requestForDemo(
        string memory _chainId,
        string memory _address
    )
        public
        payable
        returns
        (
            string memory
        )
    {
        emit LogNewProvableQuery("Evaluating your smart contract...");
        if (keccak256(abi.encodePacked(_address)) == keccak256(abi.encodePacked("0x312bc7eaaf93f1c60dc5afc115fccde161055fb0")))
        {
            return '{"status":"OK","trust_level":"HIGH","trust_score":82}';
        } else 
        {
            return '{"status":"NULL"}';
        }
        // Should call request to get real Avenger risk evaluation results
    }

    function get(
    )
        public
        payable
    {
       emit LogNewProvableQuery("The risk level is high");
    }

    // Test Example
    function requestPost()
        public
        payable
    {
        requestForDemo("56", "0x312bc7eaaf93f1c60dc5afc115fccde161055fb0");
    }
}