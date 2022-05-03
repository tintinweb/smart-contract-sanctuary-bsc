/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract HealEstateVault {

    mapping (uint8 => address payable) public holders;
    mapping (uint8 => uint) public shares;
    mapping (address => bool) public admins;

    uint8 public TOTAL_HOLDERS = 6;
    
    constructor() {
        //Set Wallet 
        holders[1] = payable(0xA696390d527ec835E7b5Dcbd92cb60C11a9E97C4);
        holders[2] = payable(0xd835FFE66774F1bF554Ab0835F7aFD291550c8b1);
        holders[3] = payable(0x090eac56dE7D06C56E48Dfaf30C0Fc520C19095A);
        holders[4] = payable(0x292d59129658F4fa0f38FA09939e48b5538905E9);
        holders[5] = payable(0x234a856765fa85E2002966FaCD922dC58B88040a);
        holders[6] = payable(0x6Bc54A9D721B99ecEC7ce4715CE5Fa9cCe6415E4);

        //Set share
        shares[1] = 30;
        shares[2] = 10;
        shares[3] = 15;
        shares[4] = 15;
        shares[5] = 15;
        shares[6] = 15;

        for(uint8 i=1; i<=TOTAL_HOLDERS; i++) {
            admins[holders[i]] = true;
        }
    }
    
    receive() external payable {}

    function distributeFunds() external {
        require(admins[msg.sender], 'Not Allowed');
        require(address(this).balance > 0, 'Contract balance is low');

        uint256 contractBal = address(this).balance;
        for(uint8 i=1; i<=TOTAL_HOLDERS; i++) {
            holders[i].transfer(contractBal*shares[i]/100);
        }
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}