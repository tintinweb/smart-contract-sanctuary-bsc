/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

pragma solidity ^0.4.17;

contract Lottery {
    string public extenTimes;
    address public manager;

    function Lottery() public {
        manager = msg.sender;
        extenTimes = "0";
    }

    function extensionTime(string time) public restricted {
        extenTimes = time;
    }

    function OwnershipTransferred(address newOwner) public restricted {
        require(newOwner != address(0));
        manager = newOwner;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}