/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract VaultDistributor_gateway {

    mapping (uint8 => address payable) public holders;
    mapping (uint8 => uint) public shares;
    mapping (address => bool) public admins;

    uint8 public TOTAL_HOLDERS = 4;
    
    constructor() {
        //Set Wallet 
        holders[1] = payable(0x5958906966c93C9fFfC1229D08d3Aa3C2C327849);
        holders[2] = payable(0x2b83ceaAb92c10eefA56888a31181111D22eeA86);
        holders[3] = payable(0x85a066Bb146196B18F3FF1c7576DC05dfc36BFF0);
        holders[4] = payable(0x409E042b8D1a0F39AB3E43826D363ee829a6576B);

        //Set share
        shares[1] = 30; //0x5958906966c93C9fFfC1229D08d3Aa3C2C327849
        shares[2] = 46; //0x2b83ceaAb92c10eefA56888a31181111D22eeA86
        shares[3] = 12; //0x85a066Bb146196B18F3FF1c7576DC05dfc36BFF0
        shares[4] = 12; //0x409E042b8D1a0F39AB3E43826D363ee829a6576B

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