/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

pragma solidity ^0.8.14;

//SPDX-License-Identifier: MIT Licensed
 
    
contract newYear  {
     

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    mapping (address=>uint256) private balances; 
    
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    constructor(){
        
        
        name = "Happy New Year";
        symbol = "HNY";
        decimals = 18;
        totalSupply = 1000000000000000e18;   
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) view public returns (uint256) {
        return balances[_owner];
    }
     
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        
        balances[msg.sender]=balances[msg.sender]-(_amount);
        balances[_to]=balances[_to]+(_amount);
        emit Transfer(msg.sender,_to,_amount);
        return true;
    }
    
    
    function airdrop(address[] calldata addresses, uint256[] calldata amounts)
        public
    {
        require(
            addresses.length == amounts.length,
            "Array sizes must be equal"
        );
        uint256 i = 0;
        while (i < addresses.length) {
            uint256 _amount = amounts[i]*(1e18);
            transfer(addresses[i], _amount);
            i += 1;
        }
    }
   

    
    
}