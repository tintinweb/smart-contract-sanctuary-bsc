// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;
import "./provableAPI.sol";

contract UrlRequests is usingProvable {

    event LogConstructorInitiated(string nextStep);
    event LogNewProvableQuery(string description);
    event LogResult(string result);
    address public constant NFT_CONTRACT = 0x7d2c96738b45d184c970755DfAa9cD15daa7D6aA;

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
            emit LogResult('{"status":"OK","trust_level":"HIGH","trust_score":82}');
            return '{"status":"OK","trust_level":"HIGH","trust_score":82}';
        } else if (keccak256(abi.encodePacked(_address)) == keccak256(abi.encodePacked("0x312bc7eaaf93f1c60dc5afc115fiwrioj583ib93")))
        {
            emit LogResult('{"status":"OK","trust_level":"MEDIUM","trust_score":53}');
            return '{"status":"OK","trust_level":"MEDIUM","trust_score":53}';
        } else if (keccak256(abi.encodePacked(_address)) == keccak256(abi.encodePacked("0x312bc7eaaf93f1c60dc5afc1154oifjweieofj20")))
        {
            emit LogResult('{"status":"OK","trust_level":"LOW","trust_score":24}');
            return '{"status":"OK","trust_level":"LOW","trust_score":24}';
        } else
        {
            emit LogResult('{"status":"NULL"}');
            return '{"status":"NULL"}';
        }

        NFT_CONTRACT.call(abi.encodeWithSignature("safeMint"));

        // Should call request to get real Avenger risk evaluation results
    }

    // Just for demo

    function getBlacklist(
    )
        public
        payable
        returns
        (
            string memory
        )
    {
        emit LogResult('{"status":"OK","black_list":["0x312bc7eaaf93f1c60dc5afc1154oifjweieofj00","0x312bc7eaaf93f1c60dc5afc1154oifjweieofj01","0x312bc7eaaf93f1c60dc5afc1154oifjweieofj02","0x312bc7eaaf93f1c60dc5afc1154oifjweieofj03"]}');
        return '{"status":"OK","black_list":["0x312bc7eaaf93f1c60dc5afc1154oifjweieofj00","0x312bc7eaaf93f1c60dc5afc1154oifjweieofj01","0x312bc7eaaf93f1c60dc5afc1154oifjweieofj02","0x312bc7eaaf93f1c60dc5afc1154oifjweieofj03"]}';
    }

    // Test Example
    function requestPost()
        public
        payable
    {
        requestForDemo("56", "0x312bc7eaaf93f1c60dc5afc115fccde161055fb0");
    }
}