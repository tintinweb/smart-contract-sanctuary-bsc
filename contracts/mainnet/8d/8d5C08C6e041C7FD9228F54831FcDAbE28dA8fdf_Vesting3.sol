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

contract Vesting3 is IVesting, Ownable, Destory {
  using SafeMath for uint256;

  address private _tokenAddress;
  address private _beneficiaryAddress;

  uint256 private _released;

  uint64 private _start;
  uint64 private _duration;

  mapping(address => bool) private _operationAuthority;

  constructor(address __tokenAddress, address __beneficiaryAddress, uint64 startAt, uint64 durationSeconds) {
    require(__tokenAddress != address(0), "Vesting4: tokenAddress is zero");
    require(__beneficiaryAddress != address(0), "Vesting4: beneficiaryAddress is zero");
    _tokenAddress = __tokenAddress;
    _beneficiaryAddress = __beneficiaryAddress;

    _start = uint64(block.timestamp < startAt ? startAt : block.timestamp);
    _duration = durationSeconds;

    _operationAuthority[_msgSender()] = true;
  }

  modifier hasPerm() {
    require(_operationAuthority[_msgSender()], "Vesting4: caller is not has authority");
    _;
  }

  function setStartTime(uint64 startAt) public override hasPerm returns (bool) {
    if (_start > block.timestamp) {
      _start = startAt;
      return true;
    }
    return false;
  }

  function addBalance(address beneficiary, uint256 amount) public override hasPerm returns (bool) {
    revert("Vesting4: addBalance not support");
  }

  function getBalance(address beneficiary) public view override returns (uint256) {
    return IERC20(_tokenAddress).balanceOf(address(this));
  }

  function release() public override hasPerm returns (bool) {
    uint256 releasable = vestedAmount(uint64(block.timestamp)) - _released;
    _released += releasable;
    if (releasable > 0) {
        IERC20(_tokenAddress).transfer(_beneficiaryAddress, releasable);
    }
  }

  function release(address beneficiary) public override hasPerm returns (bool) {
    revert("Vesting1: release not support");
  }

  function getRelease(address beneficiary) public view override returns (uint256) {
    return _released;
  }

  function addOperationAuthority(address perm) public override onlyOwner returns (bool) {
    require(perm != address(0), "Vesting4: addOperationAuthority address is zero");
    _operationAuthority[perm] = true;
    return true;
  }

  function vestedAmount(uint64 timestamp) public view returns (uint256) {
    return _vestingSchedule(IERC20(_tokenAddress).balanceOf(address(this)) + _released, timestamp);
  }

  function start() public view returns (uint64) {
    return _start;
  }

  function _vestingSchedule(uint256 totalAllocation, uint256 timestamp) internal view returns (uint256) {
    if (timestamp < _start) {
      return 0;
    } else {
      uint256 index = (timestamp - _start) / _duration;
      uint256 remaing = totalAllocation;
      for (uint8 i = 0; i < index; ++i) {
        remaing = remaing - remaing / 2;
      }
      uint256 _remaing = remaing / 2;
      return totalAllocation - remaing + (_remaing * (timestamp - _start - _duration * index)) / _duration;
    }
  }
}