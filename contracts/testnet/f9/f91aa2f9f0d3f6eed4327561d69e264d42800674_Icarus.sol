/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Icarus {
      string public name = "ICR";
      string public symbol = "ICR";
      uint8 public decimals = 18;
      uint256 public totalSup = 5000000000000000000000000000000000000000;
      event Transfer(address indexed from, address indexed to, uint tokens);
      event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
      mapping(address => uint256) balances;
      mapping(address => mapping (address => uint256)) allowed;
      constructor(uint256 total) {
       totalSup = total;
       balances[msg.sender] = totalSup;
  }
  function balanceOf(address tokenOwner) public view returns (uint) {
    return balances[tokenOwner];
}
function transfer(address receiver, uint numTokens) public returns (bool) {
    require(numTokens <= balances[msg.sender]);
    balances[msg.sender] -= numTokens;
    balances[receiver] += numTokens;
    emit Transfer(msg.sender, receiver, numTokens);
    return true;
}
function approve(address delegate, uint numTokens) public returns (bool) {
    allowed[msg.sender][delegate] = numTokens;
    emit Approval(msg.sender, delegate, numTokens);
    return true;
}
function allowance(address owner, address delegate) public view returns (uint) {
    return allowed[owner][delegate];
}
function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
    require(numTokens <= balances[owner]);
    require(numTokens <= allowed[owner][msg.sender]);
    balances[owner] -= numTokens;
    allowed[owner][msg.sender] -= numTokens;
    balances[buyer] += numTokens;
    emit Transfer(owner, buyer, numTokens);
    return true;
}

}