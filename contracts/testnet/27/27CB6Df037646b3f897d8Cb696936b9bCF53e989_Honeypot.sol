/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

contract Honeypot {
    address immutable owner = msg.sender;
    bytes32 public answerHash;

    receive() external payable {}

    constructor(bytes32 _answerHash) payable {
        setAnswer(_answerHash);
    }

    function setAnswer(bytes32 _answerHash) public {
        require(msg.sender == owner, "not owner");
        answerHash = _answerHash;
    }

    function submitAnswer(
        bytes memory _answerString
    ) external returns (uint amount) {
        require(keccak256(_answerString) == answerHash, "incorrect answer");
        amount = address(this).balance;
        (bool success, bytes memory data) = msg.sender.call{value: amount}(hex"");
        require(success, string(data));
    }
}