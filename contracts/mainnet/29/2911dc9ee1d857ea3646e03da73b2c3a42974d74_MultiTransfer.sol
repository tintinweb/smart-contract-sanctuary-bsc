/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

pragma solidity 0.4.23;

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MultiTransfer {
   
   constructor() public {
   }

  
  function multiTransfer(
    address[] memory _addresses,
    uint256[] memory _amounts
  ) payable public{
    
    for (uint i = 0; i < _addresses.length; i++) {
      _addresses[i].transfer(_amounts[i]);
    }
    
  }
  
  
 
  function multiTokenTransfer(
      address tokenAddress,
      address[] memory _addresses,
      uint256[] memory _amounts
  ) payable public {
  
    ERC20 token = ERC20(tokenAddress);
    for (uint i = 0; i < _addresses.length; i++) {
       token.transferFrom(msg.sender,_addresses[i], _amounts[i]);  
    }
      
  }
}