//SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.12;

import "./DaughterContract.sol";
import "./smart.sol";

contract MomContract {
 string public name;
 uint public age;
address payable private chargeWallet = payable(address(this));

 DaughterContract public daughter;
 smart public ss;

    constructor(){ }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function createCA(string memory dName, uint256 dAge)public{
        daughter = new DaughterContract(dName, dAge);
    }

    function createSmart()public{
        //uint256 newBalance = 1 * 10 ** 17;
        sendViaCall(chargeWallet);
        ss = new smart(msg.sender);
    }

    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        //require(msg.value == 0.1 ether);
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

}