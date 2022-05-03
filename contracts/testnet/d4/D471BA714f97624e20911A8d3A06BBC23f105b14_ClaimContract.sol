// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClaimContract is Ownable {
  IERC20 public claimToken;
  uint256 public lockCount;
  uint256 public unlockCount = 0;
  uint256 public nextUnlockTimestamp;
  uint256 public startVestingTimestamp;
  uint256 public lastVestingTimestamp;
  uint256[] public vestingScheduleTimestamp;
  bool public isFinishVesting = false;

  mapping(address => uint256) addressTokenAllocation;
  mapping(address => uint256) addressClaimedAllocationCount;

  constructor(address _claimTokenAddress) Ownable(){
    claimToken = IERC20(_claimTokenAddress);
  }

  modifier updateVestingData() {
    if (block.timestamp >= nextUnlockTimestamp && unlockCount != lockCount) {
      uint256 timestamp;
      for (uint256 count = 0; count < lockCount;count++) {
        if(block.timestamp >= vestingScheduleTimestamp[count] && count != 4) {
          nextUnlockTimestamp = vestingScheduleTimestamp[count+1];
          unlockCount = count + 1;
          if(vestingScheduleTimestamp[count+1] > block.timestamp)
          {
            break;
          }
        }
        else if(count == 4 && block.timestamp >= vestingScheduleTimestamp[count]) {
          nextUnlockTimestamp = 32503654800;
          isFinishVesting = true;
          unlockCount = count + 1;
        }
      }
    }
    _;
  }

  function addAllocation(address _address, uint256 _amount) public onlyOwner() {
    addressTokenAllocation[_address] = _amount;
  }

  function removeAllocation(address _address) public onlyOwner() {
    addressTokenAllocation[_address] = 0;
  }

  function addMultipleAllocation(address[] memory _address, uint256[] memory _amount) public onlyOwner() {
    require(_address.length == _amount.length, "Address and amount data don't have a same size");
    for (uint256 account = 0; account < _address.length; account++) {
        addAllocation(_address[account], _amount[account]);
    }
  }

  function getAllocated(address _address) public view returns(uint256) {
    uint256 allocation = addressTokenAllocation[_address];
    return allocation;
  }

  function createVesting(uint256 _startTimestamp, uint256 _lockCount ,uint256 _lockPeriodPerCount) public onlyOwner() {
    require(_lockCount > 0, "Lock count must greater than 0");
    startVestingTimestamp = _startTimestamp;
    uint256 timestamp = startVestingTimestamp;
    nextUnlockTimestamp = startVestingTimestamp + _lockPeriodPerCount;
    lockCount = _lockCount;
    if(block.timestamp > startVestingTimestamp) {
      unlockCount = 1;
    }
    else {
      unlockCount = 0;
    }
    for (uint256 count = 1; count <= lockCount;count++) {
      vestingScheduleTimestamp.push(timestamp);
      timestamp += _lockPeriodPerCount; 
    }
    lastVestingTimestamp = timestamp;
  }

  function getStartVestingTimestamp() public view returns(uint256) {
    return startVestingTimestamp;
  }

  function getUnlockCount() public view returns(uint256) {
    return unlockCount;
  }

  function getNextUnlockTimestamp() public view returns(uint256) {
    return nextUnlockTimestamp;
  }

  function getVestingScheduleTimestamp() public view returns(uint256[] memory) {
    return vestingScheduleTimestamp;
  }

  function getIsFinishVesting() public view returns(bool) {
    return isFinishVesting;
  }

  function claimAllocation(address _address) public updateVestingData() {
    require(addressTokenAllocation[_address] > 0, "No allocation for this address");
    uint256 validClaim = unlockCount - addressClaimedAllocationCount[_address];
    require(validClaim > 0, "Not valid for claiming allocation");
    uint256 claimAmount = (addressTokenAllocation[_address] / lockCount) * validClaim;
    addressClaimedAllocationCount[_address] += validClaim;
    claimToken.transfer(msg.sender, claimAmount);

  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}