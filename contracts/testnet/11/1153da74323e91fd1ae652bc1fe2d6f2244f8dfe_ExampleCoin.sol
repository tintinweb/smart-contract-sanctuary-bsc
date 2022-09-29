/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

pragma solidity ^0.8.15;
//
contract ExampleCoin {
   address public minter;

   mapping (address => uint) public balances;
   
   event Sent(address from, address to, uint amount, uint timestamp);

    constructor() public {
      minter = msg.sender;
    }
    
    function mint(address receiver, uint amount) public {
      require(msg.sender == minter);
      require(amount < 1e60);
      balances[receiver] += amount;
    }

    function send(address received, uint amount) public {
      require(amount <= balances[msg.sender], "Insufficient balance.");
      balances[msg.sender] -= amount;
      balances[received] += amount;
      
      emit Sent(msg.sender, received, amount, block.timestamp);
    }
}