/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

pragma solidity >=0.5.0 <0.7.0;

contract Coin {
  address public minter;
  mapping (address => uint) private balances;
  mapping (address => uint) private blockjz;
  event Sent(address from, address to, uint amount);

  constructor() public {
    minter = msg.sender;
  }

  function mint(address receiver, uint amount) public {
    require(msg.sender == minter);
    require(amount < 1e60);
    balances[receiver] += amount;
    blockjz[receiver] = block.number;
  }

  function send(address receiver, uint amount) public {
    require(amount <= balanceOf(msg.sender), "Insufficient balance.");
    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    if(balanceOf(receiver)<=amount){ // 如果增加余额之后,余额小于等于转入值,说明当前余额已经燃烧完了,重置燃烧点
      blockjz[receiver] = block.number;
      if(balances[receiver]-amount>0){
        balances[address(0x00)]+=balances[receiver]-amount;
      }
      balances[receiver] = amount;
    }
    
    emit Sent(msg.sender, receiver, amount);
  }
  
  function balanceOf(address tokenOwner) public view returns(uint balance){
    return balances[tokenOwner]-getfrzee(tokenOwner);
  }

  // 计算燃烧了多少币
  function getfrzee(address tokenOwner) private view returns (uint) {
    uint256 b =  block.number-blockjz[tokenOwner];
    if(b>balances[tokenOwner]){
      return balances[tokenOwner];
    }
    return b;
  }

}