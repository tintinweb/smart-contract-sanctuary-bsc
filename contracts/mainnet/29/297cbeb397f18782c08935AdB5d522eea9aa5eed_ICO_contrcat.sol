/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

pragma solidity 0.8.7;



contract ICO_contrcat{

  // Track investor contributions
  // uint256 public investorMinCap = 50000000000000000000; // 50 BUSD
  // uint256 public investorHardCap = 1000000000000000000000; // 1000 BUSD
  mapping(address => uint256) public contributions;
 address []  public AllContributer;
 uint  public token_Price = 5400000000000000; //0.0054 BUSD
  // Crowdsale Stages



  constructor(
    
    address _wallet,
    uint256 _releaseTime
  )
    
  { }

  function BuyToken(uint256 amount ) public {
    contributions[msg.sender] = amount;
    AllContributer.push(msg.sender);
  }

function update_Price(uint256 price) public {
  token_Price = price;

}

  

  

}