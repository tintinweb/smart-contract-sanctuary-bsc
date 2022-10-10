/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// File: MetacryptGeneratorInfo.sol


/*
  __    _       _           
 |  \  | |     / |  
 |   \ | | __ _| |_ __ _ 
 | |\ \| |/ _  | __/ _` |
 | | \   | (_| | || (_| |
 |_|  \__|\__,_|\__\__,_|

*/
pragma solidity ^0.8.0;

contract MetacryptGeneratorInfo {
    string public constant _GENERATOR = "https://www.metacrypt.org";
    string public constant _VERSION = "v3.0.5";

    function generator() public pure returns (string memory) {
        return _GENERATOR;
    }

    function version() public pure returns (string memory) {
        return _VERSION;
    }
}