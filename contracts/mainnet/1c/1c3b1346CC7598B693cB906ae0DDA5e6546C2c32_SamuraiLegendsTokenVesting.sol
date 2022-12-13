// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Recoverable.sol";
import "./Array.sol";

struct Lock {
  uint32 index;
  uint32 launchedAt;
  uint32 vestingPeriod;
  uint8 initialLock;
  bool launched;
  bool created;
  bool hasClaimedInitialLockAmount;
  uint128 claimedVestedAmount;
  uint256 fullAmount;
}

struct Pagination {
  uint256 totalPages;
  Lock[] documents;
}

/**
 * @title Contract that adds SMG vesting functionalities.
 * @author Leo
 */
contract SamuraiLegendsTokenVesting is Ownable, Recoverable, ReentrancyGuard {
  using Array for address[];

  IERC20 private immutable smg;

  address[] public recipients;
  mapping(address => Lock) public userLock;

  constructor(IERC20 _smg) {
    smg = _smg;
  }

  /**
   * @notice Creates a new lock.
   * @param _recipient User address to create lock for.
   * @param _vestingPeriod Vesting period of the lock.
   * @param _initialLock Initial lock percentage.
   * @param _fullAmount Lock full amount.
   */
  function createLock(
    address _recipient,
    uint32 _vestingPeriod,
    uint8 _initialLock,
    uint128 _fullAmount
  ) external onlyOwner {
    Lock storage _userLock = userLock[_recipient];

    require(_userLock.created == false, "lock already exist");

    userLock[_recipient] = Lock({
      index: uint32(recipients.length),
      launchedAt: 0,
      vestingPeriod: _vestingPeriod,
      initialLock: _initialLock,
      launched: false,
      created: true,
      hasClaimedInitialLockAmount: false,
      claimedVestedAmount: 0,
      fullAmount: _fullAmount
    });

    recipients.push(_recipient);

    emit LockCreated(_recipient);
  }

  /**
   * @notice Launches a user lock.
   * @param _recipients User addresses to launch lock for.
   */
  function launchLock(address[] calldata _recipients) external onlyOwner {
    for (uint256 i = 0; i < _recipients.length; i++) {
      address recipient = _recipients[i];

      Lock storage _userLock = userLock[recipient];

      require(_userLock.created == true, "lock isn't valid");
      require(_userLock.launched == false, "lock already launched");

      _userLock.launched = true;
      _userLock.launchedAt = uint32(block.timestamp);

      emit LockLaunched(recipient);
    }
  }

  /**
   * @notice Deletes a user lock.
   * @param recipient User address to delete lock for.
   */
  function deleteLock(address recipient) public onlyOwner {
    _deleteLock(recipient);
  }

  /**
   * @notice Deletes a user lock.
   * @param recipient User address to delete lock for.
   */
  function _deleteLock(address recipient) internal {
    Lock memory _userLock = userLock[recipient];

    require(_userLock.created == true, "lock isn't valid");

    Lock storage _lastLock = userLock[recipients[recipients.length - 1]];
    _lastLock.index = _userLock.index;
    recipients.remove(_userLock.index);

    delete userLock[recipient];

    emit LockDeleted(recipient, _userLock);
  }

  /**
   * @notice Computes the passed period and claimable amount of a user lock.
   * @param recipient User address to get claimable amount info from.
   * @return passedPeriod Passed vesting period of a lock.
   * @return claimableAmount Claimable amount of a lock.
   */
  function getClaimableAmount(address recipient)
    public
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    Lock storage _userLock = userLock[recipient];
    uint256 passedPeriod = min(
      block.timestamp - _userLock.launchedAt,
      _userLock.vestingPeriod
    );
    uint256 vestedAmount = (_userLock.fullAmount * (100 - _userLock.initialLock)) / 100;
    uint256 claimableAmount = (passedPeriod * vestedAmount) /
      _userLock.vestingPeriod -
      _userLock.claimedVestedAmount;

    uint256 initialLockAmount = 0;

    if (_userLock.hasClaimedInitialLockAmount == false && _userLock.initialLock != 0) {
      initialLockAmount = (_userLock.fullAmount * _userLock.initialLock) / 100;
    }

    return (passedPeriod, claimableAmount, initialLockAmount);
  }

  /**
   * @notice Lets a user claim an amount according to the linear vesting.
   */
  function claimLock() external nonReentrant {
    Lock storage _userLock = userLock[msg.sender];
    require(_userLock.launched == true, "lock didn't launch yet");

    (
      uint256 passedPeriod,
      uint256 claimableAmount,
      uint256 initialLockAmount
    ) = getClaimableAmount(msg.sender);
    require(claimableAmount != 0, "nothing to claim");

    if (_userLock.hasClaimedInitialLockAmount == false && _userLock.initialLock != 0) {
      _userLock.hasClaimedInitialLockAmount = true;

      emit InitialLockClaimed(msg.sender);
    }

    /**
     * @notice Does a full withdraw since vesting period already finished.
     */
    if (passedPeriod == _userLock.vestingPeriod) {
      _deleteLock(msg.sender);

      emit LockFinished(msg.sender);
    }
    /**
     * @notice Does a partial withdraw since vesting period didn't finish yet.
     */
    else {
      _userLock.claimedVestedAmount += uint112(claimableAmount);

      emit LockUpdated(msg.sender);
    }

    smg.transfer(msg.sender, claimableAmount + initialLockAmount);

    emit LockClaimed(msg.sender);
  }

  /**
   * @notice Gets all user locks in pagianted manner.
   * @param page Page number to query.
   * @param limit Number of locks to get.
   */
  function viewLocks(uint256 page, uint256 limit)
    public
    view
    returns (Pagination memory)
  {
    Lock[] memory documents = new Lock[](limit);

    uint256 start = (page - 1) * limit;
    uint256 end = min((page - 1) * limit + limit, recipients.length);

    for (uint256 i = start; i < end; i++) {
      documents[i] = userLock[recipients[i]];
    }

    return
      Pagination({
        totalPages: (recipients.length - 1) / limit + 1,
        documents: documents
      });
  }

  /**
   * @dev Returns the smallest of two unsigned numbers.
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  event LockCreated(address indexed recipient);
  event LockUpdated(address indexed recipient);
  event LockLaunched(address indexed recipient);
  event LockDeleted(address indexed recipient, Lock userLock);
  event LockFinished(address indexed recipient);
  event LockClaimed(address indexed recipient);
  event InitialLockClaimed(address indexed recipient);
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title Recoverable
@author Leo
@notice Recovers stucked BNB or ERC20 tokens
@dev You can inhertit from this contract to support recovering stucked tokens or BNB
*/
contract Recoverable is Ownable {
  /**
   * @notice Recovers stucked BNB in the contract
   */
  function recoverBNB(uint256 amount) external onlyOwner {
    require(address(this).balance >= amount, "invalid input amount");
    (bool success, ) = payable(owner()).call{ value: amount }("");
    require(success, "recover failed");
  }

  /**
    @notice Recovers stucked ERC20 token in the contract
    @param token An ERC20 token address
    */
  function recoverERC20(address token, uint256 amount) external onlyOwner {
    IERC20 erc20 = IERC20(token);
    require(erc20.balanceOf(address(this)) >= amount, "Invalid input amount.");

    erc20.transfer(owner(), amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
@title Array
@author Leo
@notice Adds utility functions to an array
*/
library Array {
  /**
    @notice Removes an array item by index
    @dev This is a O(1) time-complexity algorithm without persiting the order
    @param array A reference value to the array
    @param index An item index to be removed 
    */
  function remove(uint256[] storage array, uint256 index) internal {
    require(index < array.length, "Index out of bound.");
    array[index] = array[array.length - 1];
    array.pop();
  }

  /**
    @notice Removes an array item by index
    @dev This is a O(1) time-complexity algorithm without persiting the order
    @param array A reference value to the array
    @param index An item index to be removed 
    */
  function remove(address[] storage array, uint256 index) internal {
    require(index < array.length, "Index out of bound.");
    array[index] = array[array.length - 1];
    array.pop();
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