/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

contract Kuma {
    string kuma;
    int kuma_num = 0;

    function setKuma(string memory _kuma) public{

        // kuma = _kuma;
        if (keccak256(abi.encodePacked(_kuma)) == "kuma") {
            kuma_num += 1;
        }
    }
    function getKuma() public view returns (int) {
        return kuma_num;
    }
}