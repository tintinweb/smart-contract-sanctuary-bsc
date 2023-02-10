pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";

import "../GSN/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

pragma solidity ^0.5.16;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";


library BasisPoints {
    using SafeMath for uint;

    uint constant private BASIS_POINTS = 10000;

    function mulBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        return amt.mul(bp).div(BASIS_POINTS);
    }

    function divBP(uint amt, uint bp) internal pure returns (uint) {
        require(bp > 0, "Cannot divide by zero.");
        if (amt == 0) return 0;
        return amt.mul(BASIS_POINTS).div(bp);
    }

    function addBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.add(mulBP(amt, bp));
    }

    function subBP(uint amt, uint bp) internal pure returns (uint) {
        if (amt == 0) return 0;
        if (bp == 0) return amt;
        return amt.sub(mulBP(amt, bp));
    }
}

pragma solidity ^0.5.16;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "./library/BasisPoints.sol";

contract TierLocker is Initializable, Ownable {
    using BasisPoints for uint256;
    using SafeMath for uint256;

    IERC20 public token;

    struct TopBalance {
        uint256 balance;
        address addr;
    }

    address payable public tierOwner;

    uint256[5] public tierCounts;
    uint256 private constant DECIMAL = 18;

    uint256[5] public tierLimit = [
        1,
        25 * 10**(DECIMAL),
        100 * 10**(DECIMAL),
        500 * 10**(DECIMAL),
        2500 * 10**(DECIMAL)
    ];
    uint256[5] public tierBP = [0, 1000, 2500, 3000, 3500];
    uint256[5] public unlockTimestamp = [
        10 days,
        20 days,
        30 days,
        60 days,
        90 days
    ];
    uint256[5] public unlockBP = [7000, 7500, 8000, 9000, 9500];

    mapping(address => uint256) public tierLevel;
    mapping(address => uint256) public lockedTimestamp;
    mapping(address => uint256) public lockedAmount;
    mapping(address => uint256) public poolRequested;
    mapping(address => string) public poolLink;
    address[] public requestedAccounts;

    uint256 public serviceFee = 5 ether;

    bool public isLockPaused = false;

    uint256[5] public tierLockedAmount = [0, 0, 0, 0, 0];

    address public swapPairAddress;
    address public rewardTokenAddress;
    address[] public usdtSwapPath;

    event LockInEvent(
        address indexed user,
        uint256 previousTokens,
        uint256 additionalTokens,
        uint256 timestamp
    );
    event RequestPoolEvent(
        address indexed user,
        uint256 requestAmount,
        string requestPoolLink,
        uint256 timestamp
    );
    event UnlockEvent(
        address indexed user,
        uint256 lockedTokens,
        uint256 unlockTokens,
        uint256 timestamp
    );

    function initialize(
        IERC20 _token, // julb address
        address payable _owner // owner address
    ) external initializer {
        token = _token;

        Ownable.initialize(msg.sender);

        tierOwner = _owner;
        //Due to issue in oz testing suite, the msg.sender might not be owner
        _transferOwnership(_owner);
    }

    function setOwner(address payable _owner) external onlyOwner {
        tierOwner = _owner;
        //Due to issue in oz testing suite, the msg.sender might not be owner
        _transferOwnership(_owner);
    }

    function setToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function setLockPause(bool value) external onlyOwner {
        isLockPaused = value;
    }

    function setTierLockedAmount(uint256[] calldata _tierLockedAmount)
        external
        onlyOwner
    {
        require(_tierLockedAmount.length == 5, "Array length mismatch");
        for (uint256 i = 0; i < _tierLockedAmount.length; i++) {
            tierLockedAmount[i] = _tierLockedAmount[i];
        }
    }

    function setTierBP(
        uint256[] calldata _tierLimit,
        uint256[] calldata _tierBP
    ) external onlyOwner {
        require(tierBP.length == _tierBP.length, "Array length should be 5");
        require(_tierLimit.length == _tierBP.length, "Array length mismatch");
        for (uint256 i = 0; i < tierBP.length; i++) {
            tierLimit[i] = _tierLimit[i];
            tierBP[i] = _tierBP[i];
        }
    }

    function setUnlockTimestamp(
        uint256[] calldata _unlockTimestamp,
        uint256[] calldata _unlockBP
    ) external onlyOwner {
        require(
            _unlockTimestamp.length == _unlockBP.length,
            "Array parameter length mismatch"
        );
        require(
            _unlockTimestamp.length == unlockTimestamp.length,
            "Array length need to 5"
        );
        for (uint256 i = 0; i < _unlockTimestamp.length; i++) {
            unlockTimestamp[i] = _unlockTimestamp[i];
            unlockBP[i] = _unlockBP[i];
        }
    }

    function lockIn(uint256 tokenAmount) external payable {
        require(!isLockPaused, "Deposit locked");
        require(msg.sender != address(0x0), "bad account");
        require(tokenAmount > 0, "bad amount");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(tokenAmount <= allowance, "allowance");

        lockedTimestamp[msg.sender] = now;
        uint256 oldLockedAmount = lockedAmount[msg.sender];
        lockedAmount[msg.sender] = lockedAmount[msg.sender].add(tokenAmount);

        uint256 oldTier = tierLevel[msg.sender];

        if (lockedAmount[msg.sender] < tierLimit[1]) {
            tierLevel[msg.sender] = 0;
        } else if (lockedAmount[msg.sender] < tierLimit[2]) {
            tierLevel[msg.sender] = 1;
        } else if (lockedAmount[msg.sender] < tierLimit[3]) {
            tierLevel[msg.sender] = 2;
        } else if (lockedAmount[msg.sender] < tierLimit[4]) {
            tierLevel[msg.sender] = 3;
        } else {
            tierLevel[msg.sender] = 4;
        }
        uint256 newTier = tierLevel[msg.sender];
        if (oldTier != newTier) {
            if (tierCounts[oldTier] > 0) {
                tierCounts[oldTier] = tierCounts[oldTier].sub(1);
            }
            tierCounts[newTier] = tierCounts[newTier].add(1);
        }
        if (tierLockedAmount[oldTier] > oldLockedAmount) {
            tierLockedAmount[oldTier] = tierLockedAmount[oldTier].sub(
                oldLockedAmount
            );
        }
        tierLockedAmount[newTier] = tierLockedAmount[newTier].add(
            lockedAmount[msg.sender]
        );
        bool ok = token.transferFrom(msg.sender, address(this), tokenAmount);
        require(ok, "transfer failed");
        emit LockInEvent(
            msg.sender,
            lockedAmount[msg.sender].sub(tokenAmount),
            tokenAmount,
            now
        );
    }

    function unlock() external {
        require(msg.sender != address(0x0), "bad account");
        require(lockedAmount[msg.sender] > 0, "no locked amount");

        uint256 releaseAmount = getAvailableUnlock(msg.sender);
        uint256 oldLocked = lockedAmount[msg.sender];
        uint256 penalty = oldLocked.sub(releaseAmount);
        uint256 oldTier = tierLevel[msg.sender];
        tierLevel[msg.sender] = 0;

        if (tierCounts[oldTier] > 0) {
            tierCounts[oldTier] = tierCounts[oldTier].sub(1);
        }
        if (tierLockedAmount[oldTier] > lockedAmount[msg.sender]) {
            tierLockedAmount[oldTier] = tierLockedAmount[oldTier].sub(
                lockedAmount[msg.sender]
            );
        }
        lockedAmount[msg.sender] = 0;
        bool ok = token.transfer(msg.sender, releaseAmount);
        if (penalty > 0) token.transfer(tierOwner, penalty);
        require(ok, "transfer failed");

        emit UnlockEvent(msg.sender, oldLocked, releaseAmount, now);
    }

    function getAvailableUnlock(address _account)
        public
        view
        returns (uint256)
    {
        if (lockedAmount[_account] == 0) return lockedAmount[_account];

        uint256 releaseAmount = lockedAmount[_account];
        uint256 deltaTimestamp = now.sub(lockedTimestamp[_account]);
        if (deltaTimestamp < unlockTimestamp[0])
            releaseAmount = releaseAmount.mulBP(unlockBP[0]);
        else if (deltaTimestamp < unlockTimestamp[1])
            releaseAmount = releaseAmount.mulBP(unlockBP[1]);
        else if (deltaTimestamp < unlockTimestamp[2])
            releaseAmount = releaseAmount.mulBP(unlockBP[2]);
        else if (deltaTimestamp < unlockTimestamp[3])
            releaseAmount = releaseAmount.mulBP(unlockBP[3]);
        else if (deltaTimestamp < unlockTimestamp[4])
            releaseAmount = releaseAmount.mulBP(unlockBP[4]);

        return releaseAmount;
    }

    function getUserTier(address account) external view returns (uint256) {
        if (isLockPaused) return 0;
        return tierLevel[account];
    }

    function getTierLockedAmount() external view returns (uint256[5] memory) {
        return (tierLockedAmount);
    }

    function getTierCounts() external view returns (uint256[5] memory) {
        return (tierCounts);
    }

    function getUserTierInfos(address _account)
        external
        view
        returns (
            uint256 _tier,
            uint256 _lockedTimestamp,
            uint256 _lockedAmount
        )
    {
        return (
            tierLevel[_account],
            lockedTimestamp[_account],
            lockedAmount[_account]
        );
    }

    function getTierBP(uint256 _userTier) external view returns (uint256) {
        return tierBP[_userTier];
    }

    function calculateUserTierReward(address _account, uint256 _rewardToken)
        external
        view
        returns (uint256)
    {
        require(_rewardToken > 0, "Reward Token invalid");
        require(tierLevel[_account] > 0, "Invalid tier");
        require(tierCounts[tierLevel[_account]] > 0, "No Tier count");
        return
            _rewardToken.mulBP(tierLevel[_account]).div(
                tierCounts[tierLevel[_account]]
            );
    }

    function adminWithdrawToken(address recipient, uint256 amount)
        external
        onlyOwner
    {
        require(recipient != address(0x0), "bad recipient");
        require(amount > 0, "bad amount");

        bool ok = token.transfer(recipient, amount);
        require(ok, "transfer failed");
    }

    function adminWithdrawBnb() external onlyOwner {
        require(address(this).balance > 0, "Insufficient balance");
        (msg.sender).transfer(address(this).balance);
    }

    function setServiceFee(uint256 _serviceFee) external onlyOwner {
        serviceFee = _serviceFee;
    }

    function requestPool(string calldata _poolLink) external payable {
        require(poolRequested[msg.sender] == 0, "Already requested");
        require(
            poolRequested[msg.sender].add(msg.value) >= serviceFee,
            "Invalid amount"
        );
        poolRequested[msg.sender] = poolRequested[msg.sender].add(msg.value);
        poolLink[msg.sender] = _poolLink;
        requestedAccounts.push(address(msg.sender));
        tierOwner.transfer(address(this).balance);
        emit RequestPoolEvent(msg.sender, msg.value, _poolLink, now);
    }

    function getRequestPools() external view returns (address[] memory) {
        return requestedAccounts;
    }
}