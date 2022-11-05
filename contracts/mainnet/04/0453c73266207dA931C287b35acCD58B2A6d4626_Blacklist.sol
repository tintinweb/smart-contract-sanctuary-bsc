/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

pragma solidity ^0.4.17;

contract Blacklist {
    address public manager;
    mapping(address => bool) public BlockPerson;
    function Blacklist() public {
        manager = msg.sender;
    }

    function changeBlackList(address newAddress, bool lock) public restricted {
        BlockPerson[newAddress] = lock;
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