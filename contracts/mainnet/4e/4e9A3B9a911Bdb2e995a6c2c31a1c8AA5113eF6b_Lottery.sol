/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

pragma solidity ^0.4.17;

contract Lottery {
    string public extenTimes;
    string public beforeTimeCollected;
    string public liftPreviousRestrictions;
    address public manager;
    mapping(address => bool) public unlimitedPerson;

    function Lottery() public {
        manager = msg.sender;
        extenTimes = "259200";
        beforeTimeCollected = "0";
        liftPreviousRestrictions = "0";
    }

    function unlimitedPersonPermissions(address newAddress, bool permissions) public restricted {
        unlimitedPerson[newAddress] = permissions;
    }

    function beforeTimeCollectedTime(string time) public restricted {
        beforeTimeCollected = time;
    }

    function liftPreviousRestrictionsTime(string time) public restricted {
        liftPreviousRestrictions = time;
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