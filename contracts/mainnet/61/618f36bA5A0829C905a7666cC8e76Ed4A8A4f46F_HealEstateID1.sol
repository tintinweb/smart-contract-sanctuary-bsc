/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract HealEstateID1 {

    mapping (uint8 => address payable) public holders;
    mapping (uint8 => uint) public shares;
    mapping (address => bool) public admins;

    uint8 public TOTAL_HOLDERS = 4;
    
    constructor() {
        //Set Wallet 
        holders[1] = payable(0x21Ae07D29DBBc04D38E43DE6AC1516A10F8FAA42);
        holders[2] = payable(0x53878B0d0B043Ce9DAa161999Fe20D10d0ECc793);
        holders[3] = payable(0xC36a9bd45c470c05720B6314f1dBF4C460199f2e);
        holders[4] = payable(0x17F72B99fB091E5cb5f31872AF694eCA29B12A3A);

        //Set share
        shares[1] = 25;
        shares[2] = 25;
        shares[3] = 25;
        shares[4] = 25;

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