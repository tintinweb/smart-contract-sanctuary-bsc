/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);
  function burn(uint256 amount) external;

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  function mintPRESALE(address account_, uint256 amount_) external;

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PublicSell{
  mapping(address=>uint256) public boughtAmount;
  mapping(uint256=>address) public buyerList;
  uint256 public buyerCount;
  uint256 public price;
  uint256 public minAmount;
  uint256 public maxAmount;
  IBEP20 public payToken;
  uint256 public releaseTime;
  uint256 public totalSold;

  address private _owner;
  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
  constructor(uint256 _price, uint256 _minAmount, uint256 _maxAmount, IBEP20 _payToken) {
    price = _price;
    minAmount = _minAmount;
    maxAmount = _maxAmount;
    payToken = _payToken;

    _owner = msg.sender;
  }  

  function owner() external view returns(address) {
    return _owner;
  }

  function transferOwnership(address _newOwner) external onlyOwner{
    require(_newOwner != address(0), "Invalide address");
    _owner = _newOwner;
  }

  function updateConfig(uint256 _price, uint256 _minAmount, uint256 _maxAmount, IBEP20 _payToken) external onlyOwner{
    price = _price;
    minAmount = _minAmount;
    maxAmount = _maxAmount;
    payToken = _payToken;
  }

  function setReleasTime(uint256 _releaseTime) external onlyOwner{
    require(block.timestamp < _releaseTime, "Invalide release time");
    releaseTime = _releaseTime;
  }

  function buy(uint256 amount) external{
    if(boughtAmount[msg.sender] == 0) {
      buyerList[buyerCount] = msg.sender;
      buyerCount++; 
    }
    require(boughtAmount[msg.sender]+amount <= maxAmount, "Max amount reached");
    require(amount >= minAmount, "You have to buy at least minamount");
    uint256 payAmount = price*amount/1e18;
    payToken.transferFrom(msg.sender, address(this), payAmount);
    boughtAmount[msg.sender] += amount;
    totalSold += amount;
  }

  function withDraw() external onlyOwner{
    payToken.transfer(_owner, payToken.balanceOf(address(this)));
  }
}