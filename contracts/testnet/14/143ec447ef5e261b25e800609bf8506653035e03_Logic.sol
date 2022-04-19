/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

pragma solidity ^0.8.7;

contract Logic{
    uint magicNumber;

    constructor(){
        magicNumber = 0x42;
    }
    function setMagicNumber(uint256 newMagicNumber) public {
        magicNumber = newMagicNumber;
    }
    function getMagicNumber() public view returns(uint){
        return magicNumber;
    }
}