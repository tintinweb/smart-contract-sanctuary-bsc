/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

//SPDX-License-Identifier: UNLICENSED

 pragma solidity ^0.8.7;


abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint);

  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);

  function transfer(address to, uint value) external returns (bool);

  function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IToken is IERC20 {
  function name() external override view returns (string memory);

  function symbol() external  override view returns (string memory);

  function decimals() external  override view returns (uint256);

  function totalSupply() external  override view returns (uint256);

  function balanceOf(address account) external  override view returns (uint256);

  function allowance(address owner, address spender) external  override view returns (uint256);

  function transfer(address recipient, uint256 amount) external  override returns (bool);

  function approve(address spender, uint256 amount) external override  returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external  override returns (bool);

  function burn(uint256 amount) external returns(bool);

  function setStaking(address staking_) external;

  function mintForStake(address to, uint256 amount) external;

  function withdrawNative(address payable account, uint256 amount) external;

  function withdrawTokens(address account, uint256 amount) external;

  function setNativeRate(uint256 rate) external;

  function setERC20Rate(address token, uint256 rate) external;

  function buyNative() external payable;

  function buyERC20(address token, uint256 amount) external;
}

library SafeMath {
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

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
      require(b <= a, errorMessage);
      uint256 c = a - b;
      return c;
    }
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a / b;
    }
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
      require(b > 0, errorMessage);
      return a % b;
    }
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
}

contract ZephyrStaking is Ownable {
  using SafeMath for uint256;

  IToken public token;

  uint256 public minStake;

  struct Stake {
    uint8 id;
    uint256 body;
    uint256 createdAt;
    uint256 lastClaim;
  }

  struct StakeMeta {
    uint256 ttl;
    uint256 rewardPerHour;
  }

  mapping(address => Stake) public accountStake;
  mapping(uint8 => StakeMeta) public stakes;

  event Deposit(address indexed stakeOwner, uint256 amount);
  event Claim(address indexed stakeOwner, uint256 amount);

  constructor() {
    stakes[0] = StakeMeta({ttl: 8 hours, rewardPerHour: 500}); //0.005% = 50% APR
    stakes[1] = StakeMeta({ttl: 1 days, rewardPerHour: 800}); //0.008% = 80% APR
    stakes[2] = StakeMeta({ttl: 30 days, rewardPerHour: 1500}); // 0.015% = 150% APR
    stakes[3] = StakeMeta({ttl: 120 days, rewardPerHour: 3000}); // 0.03% = 300% APR
    stakes[4] = StakeMeta({ttl: 365 days, rewardPerHour: 4500}); // 0.045% = 450% APR
  }

  function setToken(address token_) external onlyOwner {
    require(address(token) == address(0), "Token already installed");
    token = IToken(token_);
    token.approve(token_, 2 ** 256 - 1);
    minStake = 100 * 10 ** token.decimals();
  }

  function setMinStake(uint256 amount) external onlyOwner {
    minStake = amount * 10 ** token.decimals();
  }

  function deposit(uint8 stakeTypeId, uint256 amount) external {
    require(amount >= minStake, "Stake amount is lower than minimum deposit amount");
    require(IERC20(token).balanceOf(_msgSender()) >= amount, "Bad balance");
    require(stakes[stakeTypeId].ttl > 0, "Bad stake type id");
    require(accountStake[_msgSender()].createdAt == 0, "You already have active stake");

    uint256 timestamp = block.timestamp;

    Stake memory stake = Stake({id: stakeTypeId, body: amount, createdAt: timestamp, lastClaim: timestamp});

    accountStake[_msgSender()] = stake;

    token.transferFrom(_msgSender(), address(this), amount);

    emit Deposit(_msgSender(), amount);
  }

  function getAccountRewards(address account) public view returns (uint256 rewards) {
    Stake memory stake = accountStake[account];
    StakeMeta memory stakeMeta = stakes[stake.id];
    uint256 stakeExpiration = stake.createdAt.add(stakeMeta.ttl);
    uint256 upperTimeBound = block.timestamp > stakeExpiration
      ? stakeExpiration
      : block.timestamp;
    rewards = (((upperTimeBound.sub(accountStake[account].lastClaim)).mul(accountStake[account].body)) *
      stakes[accountStake[account].id].rewardPerHour).div(3600).div(10000000);
    if (upperTimeBound == stakeExpiration) {
      rewards = rewards.add(stake.body);
    }
  }

  function claim() external {
    Stake memory stake = accountStake[_msgSender()];
    require(accountStake[_msgSender()].createdAt > 0, "You doesn't have active stake");
    uint256 rewards = getAccountRewards(_msgSender());
    require(rewards > 0, "No rewards");

    token.mintForStake(_msgSender(), rewards);

    StakeMeta memory stakeMeta = stakes[stake.id];
    uint256 stakeExpiration = stake.createdAt.add(stakeMeta.ttl);

    if (block.timestamp >= stakeExpiration) {
      delete accountStake[_msgSender()];
    } else {
      stake.lastClaim = block.timestamp;
    }

    emit Claim(_msgSender(), rewards);
  }
}