/**
 *Submitted for verification at BscScan.com on 2022-12-12
 */

// SPDX-License-Identifier: MIT
library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      uint256 c = a + b;
      if (c < a) return (false, 0);
      return (true, c);
    }
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b > a) return (false, 0);
      return (true, a - b);
    }
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a / b);
    }
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      if (b == 0) return (false, 0);
      return (true, a % b);
    }
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b <= a, errorMessage);
      return a - b;
    }
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a / b;
    }
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a % b;
    }
  }
}

pragma solidity 0.8.17;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);

  function isPresaleClaimed(address account) external view returns (bool);
}

contract MinuBones is Context, Ownable {
  using SafeMath for uint256;

  uint256 private BONES_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
  uint256 private PSN = 10000;
  uint256 private PSNH = 5000;
  uint256 private devFeeVal = 4;
  bool private initialized = false;
  address payable private recAdd = payable(0x1495909E77f57fbe2e977d96f754e9d170C80eb5);
  mapping(address => uint256) private hatcheryMiners;
  mapping(address => uint256) private claimedBones;
  mapping(address => uint256) private lastHatch;
  mapping(address => address) private referrals;
  uint256 private marketBones;
  uint8 public tradingState = 0;
  IERC20 token;

  constructor(address _owner, address _token) {
    setToken(_token);
    transferOwnership(_owner);
  }

  modifier canTrade() {
    if (tradingState == 1)
      require(token.isPresaleClaimed(_msgSender()) || owner() == _msgSender(), 'only presale users');

    if (tradingState == 0) require(owner() == _msgSender(), 'trades are not enabled');

    require(owner() == _msgSender() || token.balanceOf(_msgSender()) != 0, 'should be a MINE holder');

    _;
  }

  function setTradingState(uint8 _tradingState) public onlyOwner {
    require(_tradingState < 3, 'trading state should be 0:only owner, 1:whitelisted, 2:public');
    tradingState = _tradingState;
  }

  function setToken(address _token) public onlyOwner {
    require(_token != address(0), 'invalid token address');
    token = IERC20(_token);
  }

  function hatchBones(address ref) public canTrade {
    require(initialized, 'not initilized');

    if (ref == msg.sender) {
      ref = address(0);
    }

    if (referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
      referrals[msg.sender] = ref;
    }

    uint256 bonesUsed = getMyBones(msg.sender);
    uint256 newMiners = SafeMath.div(bonesUsed, BONES_TO_HATCH_1MINERS);
    hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender], newMiners);
    claimedBones[msg.sender] = 0;
    lastHatch[msg.sender] = block.timestamp;

    //send referral bones
    claimedBones[referrals[msg.sender]] = SafeMath.add(claimedBones[referrals[msg.sender]], SafeMath.div(bonesUsed, 8));

    //boost market to nerf miners hoarding
    marketBones = SafeMath.add(marketBones, SafeMath.div(bonesUsed, 5));
  }

  function sellBones() public canTrade {
    require(initialized, 'not initilized');
    uint256 hasBones = getMyBones(msg.sender);
    uint256 boneValue = calculateBoneSell(hasBones);
    uint256 fee = devFee(boneValue);
    claimedBones[msg.sender] = 0;
    lastHatch[msg.sender] = block.timestamp;
    marketBones = SafeMath.add(marketBones, hasBones);
    recAdd.transfer(fee);
    payable(msg.sender).transfer(SafeMath.sub(boneValue, fee));
  }

  function beanRewards(address adr) public view returns (uint256) {
    uint256 hasBones = getMyBones(adr);
    uint256 boneValue = calculateBoneSell(hasBones);
    return boneValue;
  }

  function buyBones(address ref) public payable canTrade {
    require(initialized, 'not initilized');
    uint256 bonesBought = calculateBoneBuy(msg.value, SafeMath.sub(address(this).balance, msg.value));
    bonesBought = SafeMath.sub(bonesBought, devFee(bonesBought));
    uint256 fee = devFee(msg.value);
    recAdd.transfer(fee);
    claimedBones[msg.sender] = SafeMath.add(claimedBones[msg.sender], bonesBought);
    hatchBones(ref);
  }

  function calculateTrade(
    uint256 rt,
    uint256 rs,
    uint256 bs
  ) private view returns (uint256) {
    return
      SafeMath.div(
        SafeMath.mul(PSN, bs),
        SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt))
      );
  }

  function calculateBoneSell(uint256 bones) public view returns (uint256) {
    return calculateTrade(bones, marketBones, address(this).balance);
  }

  function calculateBoneBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
    return calculateTrade(eth, contractBalance, marketBones);
  }

  function calculateBoneBuySimple(uint256 eth) public view returns (uint256) {
    return calculateBoneBuy(eth, address(this).balance);
  }

  function devFee(uint256 amount) private view returns (uint256) {
    return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100);
  }

  function seedMarket() public payable onlyOwner {
    require(marketBones == 0);
    initialized = true;
    marketBones = 108000000000;
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function getMyMiners(address adr) public view returns (uint256) {
    return hatcheryMiners[adr];
  }

  function getMyBones(address adr) public view returns (uint256) {
    return SafeMath.add(claimedBones[adr], getBonesSinceLastHatch(adr));
  }

  function getBonesSinceLastHatch(address adr) public view returns (uint256) {
    uint256 secondsPassed = min(BONES_TO_HATCH_1MINERS, SafeMath.sub(block.timestamp, lastHatch[adr]));
    return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
  }

  function min(uint256 a, uint256 b) private pure returns (uint256) {
    return a < b ? a : b;
  }
}