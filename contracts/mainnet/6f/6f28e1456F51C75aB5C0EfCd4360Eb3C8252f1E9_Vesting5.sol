/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: Mozilla
pragma solidity ^0.8.0;

interface IVesting {
  function setStartTime(uint64 startTime) external returns (bool);
  function addBalance(address beneficiary, uint256 amount) external returns (bool);
  function getBalance(address beneficiary) external view returns (uint256);
  function release() external returns (bool);
  function release(address beneficiary) external returns (bool);
  function getRelease(address beneficiary) external view returns (uint256);
  function addOperationAuthority(address perm) external returns (bool);
}

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
    _transferOwnership(address(0));
  }

  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

abstract contract Destory is Context, Ownable {
  function destory() public onlyOwner {
    selfdestruct(payable(owner()));
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require (c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Vesting5 is IVesting, Ownable, Destory {
  using SafeMath for uint256;

  address private _tokenAddress;
  address private _fromWallet;
  address private _inviteFromWallet;

  uint256 private _released;

  uint64 private _start;
  uint64 private _duration;
  uint64 private _firstPercentage;

  mapping(address => bool) private _operationAuthority;

  mapping(address => uint256) private _beneficiaryBalances;
  mapping(address => uint256) private _beneficiaryInviteBalances;
  mapping(address => uint256) private _beneficiaryBalanceReleased;
  mapping(address => uint256) private _beneficiaryInviteBalanceReleased;

  bool private _isStart = false;

  struct Info {
    uint256 lockBalance;
    uint256 unlockBalance;
    uint256 withdrawBalance;
    uint256 lockInviateBalance;
    uint256 unlockInviteBalance;
    uint256 withdrawInviteBalance;
  }

  constructor(address __tokenAddress, address __fromWallet, address __inviteFromWallet, uint64 firstPercentage, uint64 durationSeconds) {
    require(__tokenAddress != address(0), "Vesting5: tokenAddress is zero");
    require(__fromWallet != address(0), "Vesting5: fromWallet is zero");
    require(__inviteFromWallet != address(0), "Vesting5: inviteFromWallet is zero");
    _tokenAddress = __tokenAddress;
    _fromWallet = __fromWallet;
    _inviteFromWallet = __inviteFromWallet;

    _duration = durationSeconds;
    _firstPercentage = firstPercentage;

    _operationAuthority[_msgSender()] = true;
  }

  modifier hasPerm() {
    require(_operationAuthority[_msgSender()], "Vesting5: caller is not has authority");
    _;
  }

  modifier isStart() {
    require(_isStart, "Vesting5: caller is not start");
    _;
  }

  function addBalance(address beneficiary, uint256 amount) public override hasPerm returns (bool) {
    require(beneficiary != address(0), "Vesting5: addBalance beneficiary is zero");
    _beneficiaryBalances[beneficiary] += amount;
  }

  function getBalance(address beneficiary) public view override returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getBalance beneficiary is zero");
    return _beneficiaryBalances[beneficiary];
  }

  function addInvite(address beneficiary, uint256 amount) public hasPerm returns (bool) {
    require(beneficiary != address(0), "Vesting5: addBalance beneficiary is zero");
    _beneficiaryInviteBalances[beneficiary] += amount;
    return true;
  }

  function getInvite(address beneficiary) public view returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getInvite beneficiary is zero");
    return _beneficiaryBalances[beneficiary];
  }

  function getInviteRelease(address beneficiary) public view returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getInviteRelease beneficiary is zero");
    return _beneficiaryInviteBalanceReleased[beneficiary];
  }

  function release() public override hasPerm isStart returns (bool) {
    revert("Vesting5: release not support");
    return true;
  }

  function release(address beneficiary) public override hasPerm isStart returns (bool) {
    require(beneficiary != address(0), "Vesting5: release beneficiary is zero");
    uint256 balanceReleaseable = vestedAmountBalance(beneficiary, uint64(block.timestamp)) - _beneficiaryBalanceReleased[beneficiary];
    uint256 inviteReleaseable = vestedAmountInvite(beneficiary, uint64(block.timestamp)) - _beneficiaryInviteBalanceReleased[beneficiary];
    _beneficiaryBalanceReleased[beneficiary] += balanceReleaseable;
    _beneficiaryInviteBalanceReleased[beneficiary] += inviteReleaseable;
    _beneficiaryBalances[beneficiary] -= balanceReleaseable;
    _beneficiaryInviteBalances[beneficiary] -= inviteReleaseable;
    if (balanceReleaseable > 0) {
        IERC20(_tokenAddress).transferFrom(_fromWallet, beneficiary, balanceReleaseable);
    }
    if (inviteReleaseable > 0) {
        IERC20(_tokenAddress).transferFrom(_inviteFromWallet, beneficiary, inviteReleaseable);
    }
  }

  function getRelease(address beneficiary) public view override returns (uint256) {
    require(beneficiary != address(0), "Vesting5: getRelease beneficiary is zero");
    return _beneficiaryBalanceReleased[beneficiary];
  }

  function addOperationAuthority(address perm) public override onlyOwner returns (bool) {
    require(perm != address(0), "Vesting5: addOperationAuthority address is zero");
    _operationAuthority[perm] = true;
    return true;
  }

  function vestedAmountBalance(address beneficiary, uint64 timestamp) public view returns (uint256) {
    return _vestingSchedule(_beneficiaryBalances[beneficiary] + _beneficiaryBalanceReleased[beneficiary], timestamp);
  }

  function vestedAmountInvite(address beneficiary, uint64 timestamp) public view returns (uint256) {
    return _vestingSchedule(_beneficiaryInviteBalances[beneficiary] + _beneficiaryInviteBalanceReleased[beneficiary], timestamp);
  }

  function start() public view returns (uint64) {
    return _start;
  }

  function setStartTime(uint64 startAt) public override hasPerm returns (bool) {
    require(!_isStart, "Vesting5: setStartTime alreday start");
    _start = startAt;
    return true;
  }

  function setStart() public hasPerm returns (bool) {
    require(!_isStart, "Vesting5: setStart alreday start");
    _isStart = true;
    _start = uint64(block.timestamp);
    return true;
  }

  function info(address account) public view returns (Info memory) {
    require(account != address(0), "Vesting5: info account is zero");
    uint256 balanceReleaseable = vestedAmountBalance(account, uint64(block.timestamp)) - _beneficiaryBalanceReleased[account];
    uint256 inviteReleaseable = vestedAmountInvite(account, uint64(block.timestamp)) - _beneficiaryInviteBalanceReleased[account];
    return Info({
      lockBalance : _beneficiaryBalances[account],
      unlockBalance : _beneficiaryBalanceReleased[account],
      withdrawBalance : balanceReleaseable,
      lockInviateBalance : _beneficiaryInviteBalances[account],
      unlockInviteBalance : _beneficiaryInviteBalanceReleased[account],
      withdrawInviteBalance : inviteReleaseable
    });
  }

  function _vestingSchedule(uint256 totalAllocation, uint256 timestamp) internal view returns (uint256) {
    if (!_isStart) {
      return 0;
    }
    if (timestamp < _start) {
      return 0;
    } else if (timestamp >= _start + _duration) {
      return totalAllocation;
    } else {
      return (totalAllocation * _firstPercentage) / 100 + ((totalAllocation - (totalAllocation * _firstPercentage) / 100) * (timestamp - _start)) / _duration;
    }
  }
}