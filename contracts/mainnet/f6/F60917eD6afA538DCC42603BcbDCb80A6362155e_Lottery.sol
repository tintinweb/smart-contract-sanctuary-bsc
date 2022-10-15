/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

pragma solidity ^0.4.17;

contract Lottery {
    address public manager;
    mapping(address => bool) public LockIntegralPerson;
    bool public isLockIntegral;
    function Lottery() public {
        manager = msg.sender;
        isLockIntegral = true;
    }

    function closeLockIntegral(bool lock) public restricted {
        isLockIntegral = lock;
    }

    function closePersonLockIntegral(address newAddress, bool lock) public restricted {
        LockIntegralPerson[newAddress] = lock;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}