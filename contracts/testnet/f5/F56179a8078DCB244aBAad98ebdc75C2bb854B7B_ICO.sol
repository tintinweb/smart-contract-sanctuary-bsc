/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract Ownable {
  address public owner;
  constructor ()  {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

interface Token {
  function transfer(address _to, uint256 _value) external  returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address from,address _to, uint256 _value) external  returns (bool);
}

contract ICO is Ownable {
  using SafeMath for uint256;
  Token token;
  uint256 public  RATE = 1000;
  uint256 public  CAP = 1000; // Cap in BNB
  uint256 public  START = block.timestamp; 
  uint256 public  DAYS = 30; // 30 Days 
  // The minimum amount of Wei you must pay to participate in the RBT_ICO
  uint256 public  MinPurchase = 0.04 ether; // 0.04 BNB  
  uint256 public  initialTokens ; // Initial number of tokens available
  bool public initialized = false;
  uint256 public raisedAmount = 0;
  event BoughtTokens(address indexed to, uint256 value);
  modifier whenSaleIsActive() {
    assert(isActive());
    _;
  }
  constructor(address _tokenAddr,uint256 _initialTokens)  {
      require(_tokenAddr != address(0));
      require(_initialTokens >0 ," initial token should always greater than 0 ");
      token = Token(_tokenAddr);
      initialTokens = _initialTokens;
      token.transferFrom(msg.sender,address(this),initialTokens);
  }
  function initialize() public onlyOwner {
      require(initialized == false); // Can only be initialized once
      require(tokensAvailable() == initialTokens); // Must have enough tokens allocated
      initialized = true;
  }
  function isActive() public view returns (bool) {
    return (
        initialized == true &&
        block.timestamp >= START && // Must be after the START date
        block.timestamp <= START.add(DAYS * 1 days) && // Must be before the end date
        goalReached() == false // Goal must not already be reached
    );
  }
  function goalReached() public view returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }
  receive () external payable {
    buyTokens();
  }
  // if user pay 1 wei then he will get 1 token 
  function buyTokens() public payable whenSaleIsActive {
    require(msg.value > 0, "Enter a Non-Zero amount.");
    require(msg.value >= MinPurchase, "Please Enter the amount more than the minimum allowed investment." );
    uint256 weiAmount = msg.value; // Calculate tokens to sell
    uint256 tokens = weiAmount.mul(RATE); // according to this line   
    emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
    raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
    token.transferFrom(address(this),msg.sender, tokens); // Send tokens to buyer
    payable(owner).transfer(msg.value);// Send money to owner
  }
  function SetTokenRate (uint256 _rate) external onlyOwner {
    RATE = _rate;
  }
  function SetCap (uint256 _cap) external onlyOwner {
    CAP = _cap;
  }
  function SetDays (uint256 _days) external onlyOwner {
    DAYS = _days;
  }
  function SetStartTime (uint256 _startTime) external onlyOwner {
    START = _startTime;
  }
  function SetMinPurchase (uint256 _minimumInvestment) external onlyOwner {
    MinPurchase = _minimumInvestment;
  }
  function tokensAvailable() public view returns (uint256) {
    return token.balanceOf(address(this));
  }
  function  tokenbalance(address user)public view returns(uint256)
  {
      return token.balanceOf(user);
  }
  function destroy() onlyOwner public {
    // Transfer tokens back to owner
    uint256 balance = token.balanceOf(address(this));
    assert(balance > 0);
    token.transfer(owner, balance);
    // There should be no bnb in the contract but just in case
    selfdestruct(payable(owner));
  }
}