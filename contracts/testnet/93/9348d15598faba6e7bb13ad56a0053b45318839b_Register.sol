/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// File: Register.sol

pragma solidity 0.5.4;

contract Register {
    string private info;

    function setInfo(string memory _info) public {
        info = _info;
    }

    function getInfo() public view returns (string memory) {
        return info;
    }
}