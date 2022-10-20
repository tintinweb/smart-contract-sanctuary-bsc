/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vaultv2 {

    string public name;
    uint256 public vaLue;
    
    error Down(string reason);

    function initialize(string memory _name, uint256 _vaLue) public {
        name = _name;
        vaLue = _vaLue;
    }

    function down() public {
        if (vaLue == 0) revert Down("!vaLue");
        vaLue--;
    }

    function up() public {
        vaLue++;
    }

}