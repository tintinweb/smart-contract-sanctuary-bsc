/**
 *Submitted for verification at BscScan.com on 2022-07-26
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

contract PrivateSell{
  mapping(address=>bool) public isWhiteListed;
  mapping(address=>uint256) public boughtAmount;
  address[] public whiteList;
  uint256 public price;
  uint256 public maxAmount;
  IBEP20 public payToken;
  uint256 public releaseTime;
  uint256 public totalSold;

  address private _owner;
  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
  constructor(uint256 _price, uint256 _maxAmount, IBEP20 _payToken) {
    price = _price;
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

  function updateConfig(uint256 _price, uint256 _maxAmount, IBEP20 _payToken) external onlyOwner{
    price = _price;
    maxAmount = _maxAmount;
    payToken = _payToken;
  }

  function setWhiteList(address[] memory _whiteList) external onlyOwner {
    for(uint i = 0; i < _whiteList.length; i++) {
      isWhiteListed[_whiteList[i]] = true;
      whiteList.push(_whiteList[i]);
    }
  }

  function setReleasTime(uint256 _releaseTime) external onlyOwner{
    require(block.timestamp < _releaseTime, "Invalide release time");
    releaseTime = _releaseTime;
  }

  function buy(uint256 amount) external{
    require(isWhiteListed[msg.sender], "You are not whitelisted");
    require(boughtAmount[msg.sender] + amount < maxAmount, "Max amount reached");
    uint256 payAmount = price*amount/1e18;
    payToken.transferFrom(msg.sender, address(this), payAmount);
    boughtAmount[msg.sender] += amount;
    totalSold += amount;
  }

  function withDraw() external onlyOwner{
    require(block.timestamp > releaseTime, "You can't withdraw now");
    payToken.transfer(_owner, payToken.balanceOf(address(this)));
  }

  function getWhiteList() external view returns(address[] memory) {
    return whiteList;
  }
}