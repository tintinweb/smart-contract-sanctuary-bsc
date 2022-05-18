/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract HealEstateWCVaultP1 {

    mapping (uint8 => address payable) public holders;
    mapping (uint8 => uint) public shares;
    mapping (address => bool) public admins;

    uint8 public TOTAL_HOLDERS = 6;
    
    constructor() {
        //Set Wallet 
        holders[1] = payable(0x234a856765fa85E2002966FaCD922dC58B88040a);
        holders[2] = payable(0xbe72cdF4487ccA797705A5571c6038338C5d1754);
        holders[3] = payable(0x76737b45ed790a48db794C6C2C964F2c1F851203);
        holders[4] = payable(0xBe937aCbe61c7De8d530c5AfD748363cD02d7b8f);
        holders[5] = payable(0xB85e3796410287E1b0e9E0D87cCd94516c80Ac1c);
        holders[6] = payable(0xBeB9D092609DD6C0A2284BE08E758645e7b17a20);

        //Set share
        shares[1] = 860;
        shares[2] = 860;
        shares[3] = 860;
        shares[4] = 860;
        shares[5] = 2200;
        shares[6] = 4360;

        for(uint8 i=1; i<=TOTAL_HOLDERS; i++) {
            admins[holders[i]] = true;
        }
    }
    
    receive() external payable {}

    function distributeFunds() external {
        require(admins[msg.sender], "Not Allowed");
        require(address(this).balance > 0, "Contract balance is low");

        uint256 contractBal = address(this).balance;
        for(uint8 i=1; i<=TOTAL_HOLDERS; i++) {
            holders[i].transfer(contractBal*shares[i]/10000);
        }
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}