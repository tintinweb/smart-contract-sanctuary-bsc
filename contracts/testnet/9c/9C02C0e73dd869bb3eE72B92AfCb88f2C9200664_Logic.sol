/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity ^0.8.4;

contract Logic {
    bool initialized;
    uint256 magicNumber;

    function initialize() public {
        require(!initialized, "already initialized");

        magicNumber = 0x42;
        initialized = true;
    }

    function setMagicNumber(uint256 newMagicNumber) public {
        magicNumber = newMagicNumber;
    }

    function getMagicNumber() public view returns (uint256) {
        return magicNumber;
    }
}