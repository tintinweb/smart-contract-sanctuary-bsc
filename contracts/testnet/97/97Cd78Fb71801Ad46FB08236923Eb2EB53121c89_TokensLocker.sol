//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokensLocker is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _lockIds;

    struct Locker {
        address token;
        address owner;
        uint256 amount;
        uint256 lockedDate;
        uint256 expireDate;
        uint256 claimedAt;
        bool isClaimed;
    }

    struct VestingLocker {
        address token;
        address owner;
        uint256 amount;
        uint256 lockedDate;
        uint256 initialPercentage;
        uint256 releaseCycle;
        uint256 releasePercentage;
        uint256 lastClaim;
        uint256 nextClaim;
        uint256 remainingTokens;
        bool isTotallyClaimed;
        bool isInitialClaimed;
    }

    mapping(uint256 => Locker) public lockerDetails;
    mapping(uint256 => VestingLocker) public vestingLockerDetails;

    mapping(address => uint256[]) public lockedTokensId;

    uint256 public fee = 1 * 10**17;

    event NewTokenLocked(
        uint256 id,
        address token,
        address owner,
        uint256 amount,
        uint256 expireDate
    );
    event LockerOwnershipChanged(
        uint256 lockerId,
        address newOwner,
        address previousOwner
    );

    event LockerUnlocked(
        uint256 lockerId,
        address unlockedBy,
        uint256 unlockedAmount
    );

    constructor() {}

    receive() external payable {}

    function lockTokens(
        address _tokenAddress,
        uint256 amount,
        uint256 lockTime,
        bool isLp
    ) public payable nonReentrant {
        require(_tokenAddress != address(0), "Please submit a valid address");

        require(
            msg.value >= fee,
            "Please submit asking price in order to complete the transaction"
        );

        require(
            IERC20(_tokenAddress).balanceOf(msg.sender) >= amount,
            "You don't have enough tokens to lock"
        );

        require(lockTime > block.timestamp, "Lock time should greater than 0");

        payable(address(this)).transfer(fee);

        uint256 oldTokenBalance = IERC20(_tokenAddress).balanceOf(
            address(this)
        );

        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);

        uint256 currentBalance = IERC20(_tokenAddress).balanceOf(address(this));

        require(
            currentBalance.sub(oldTokenBalance) >= amount,
            "We did not get require token amount"
        );

        if (isLp) {
            address factoryAddress = _parseFactoryAddress(_tokenAddress);
            require(
                _isValidLpToken(_tokenAddress, factoryAddress),
                "This token is not a LP token"
            );
        }

        _lockIds.increment();
        uint256 lockerId = _lockIds.current();

        lockedTokensId[msg.sender].push(lockerId);

        lockerDetails[lockerId].token = _tokenAddress;
        lockerDetails[lockerId].owner = msg.sender;
        lockerDetails[lockerId].amount = amount;
        lockerDetails[lockerId].lockedDate = block.timestamp;
        lockerDetails[lockerId].expireDate = lockTime;

        emit NewTokenLocked(
            lockerId,
            _tokenAddress,
            msg.sender,
            amount,
            lockerDetails[lockerId].expireDate
        );
    }

    function _isValidLpToken(address token, address factory)
        private
        view
        returns (bool)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(token);
        address factoryPair = IUniswapV2Factory(factory).getPair(
            pair.token0(),
            pair.token1()
        );
        return factoryPair == token;
    }

    function _parseFactoryAddress(address token)
        internal
        view
        returns (address)
    {
        address possibleFactoryAddress;
        try IUniswapV2Pair(token).factory() returns (address factory) {
            possibleFactoryAddress = factory;
        } catch {
            revert("This token is not a LP token");
        }
        require(
            possibleFactoryAddress != address(0) &&
                _isValidLpToken(token, possibleFactoryAddress),
            "This token is not a LP token."
        );
        return possibleFactoryAddress;
    }

    // transfer locker ownership
    function transferLockerOwnerShip(uint256 lockerId, address _newOwner)
        public
    {
        require(
            lockerDetails[lockerId].owner == msg.sender,
            "You are not the owner of this locker"
        );

        lockerDetails[lockerId].owner = _newOwner;

        emit LockerOwnershipChanged(lockerId, _newOwner, msg.sender);
    }

    // change locker expire time
    function extendLockerExpireTime(uint256 lockerId, uint256 extendedTime)
        public
    {
        require(
            lockerDetails[lockerId].owner == msg.sender,
            "You are not the owner of this locker"
        );

        lockerDetails[lockerId].expireDate = extendedTime.add(
            lockerDetails[lockerId].expireDate
        );
    }

    // unlock tokens
    function unlockTokens(uint256 lockerId) public {
        require(
            lockerDetails[lockerId].owner == msg.sender,
            "You are not the owner of this locker"
        );
        require(
            !lockerDetails[lockerId].isClaimed,
            "You already claimed this locker"
        );

        require(
            lockerDetails[lockerId].expireDate <= block.timestamp,
            "This locker not unlocked yet"
        );

        lockerDetails[lockerId].isClaimed = true;

        lockerDetails[lockerId].claimedAt = block.timestamp;

        IERC20(lockerDetails[lockerId].token).transferFrom(
            address(this),
            msg.sender,
            lockerDetails[lockerId].amount
        );

        emit LockerUnlocked(
            lockerId,
            msg.sender,
            lockerDetails[lockerId].amount
        );
    }

    function getMyLockers() public view returns (uint256[] memory) {
        return lockedTokensId[msg.sender];
    }

    function isVesting(uint256 lockerId) public view returns (bool) {
        bool status;
        require(
            lockerDetails[lockerId].amount > 0 ||
                vestingLockerDetails[lockerId].amount > 0,
            "Invalid locker id"
        );

        if (vestingLockerDetails[lockerId].amount > 0) {
            status = true;
        }
        return status;
    }

    // lock vesting
    function lockAndVesting(
        address _tokenAddress,
        uint256 _amount,
        uint256 _initialReleaseTime,
        uint256 _initialPercentage,
        uint256 _releaseCycle,
        uint256 _releasePercentage
    ) public payable nonReentrant {
        require(_tokenAddress != address(0), "Please submit a valid address");

        require(
            msg.value >= fee,
            "Please submit asking price in order to complete the transaction"
        );

        require(
            IERC20(_tokenAddress).balanceOf(msg.sender) >= _amount,
            "You don't have enough tokens to lock"
        );

        require(_initialReleaseTime > 0, "Lock time should greater than 0");
        require(
            _initialReleaseTime > block.timestamp,
            "Release time must be a future date"
        );

        payable(address(this)).transfer(fee);

        uint256 oldTokenBalance = IERC20(_tokenAddress).balanceOf(
            address(this)
        );

        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);

        uint256 currentBalance = IERC20(_tokenAddress).balanceOf(address(this));

        require(
            currentBalance.sub(oldTokenBalance) >= _amount,
            "We did not get require token amount"
        );

        _lockIds.increment();
        uint256 lockerId = _lockIds.current();

        lockedTokensId[msg.sender].push(lockerId);

        vestingLockerDetails[lockerId].token = _tokenAddress;
        vestingLockerDetails[lockerId].owner = msg.sender;
        vestingLockerDetails[lockerId].amount = _amount;
        vestingLockerDetails[lockerId].lockedDate = block.timestamp;
        vestingLockerDetails[lockerId].initialPercentage = _initialPercentage;
        vestingLockerDetails[lockerId].releaseCycle = _releaseCycle;
        vestingLockerDetails[lockerId].releasePercentage = _releasePercentage;
        vestingLockerDetails[lockerId].nextClaim = _initialReleaseTime;
        vestingLockerDetails[lockerId].remainingTokens = _amount;
    }

    // unlock vesting
    function unlockVesting(uint256 lockId) public nonReentrant {
        require(
            vestingLockerDetails[lockId].owner == msg.sender,
            "You are not the owner of this locker"
        );

        require(
            vestingLockerDetails[lockId].nextClaim <= block.timestamp,
            "You can not claim tokens at this time"
        );

        require(
            !vestingLockerDetails[lockId].isTotallyClaimed,
            "This locker claimed totally"
        );

        uint256 tokensToRelease;

        if (!vestingLockerDetails[lockId].isInitialClaimed) {
            tokensToRelease = vestingLockerDetails[lockId]
                .amount
                .mul(vestingLockerDetails[lockId].initialPercentage)
                .div(100);
            vestingLockerDetails[lockId].isInitialClaimed = true;
        } else {
            tokensToRelease = vestingLockerDetails[lockId]
                .amount
                .mul(vestingLockerDetails[lockId].releasePercentage)
                .div(100);
        }

        if (tokensToRelease > vestingLockerDetails[lockId].remainingTokens) {
            tokensToRelease = vestingLockerDetails[lockId].remainingTokens;
        }

        vestingLockerDetails[lockId].nextClaim = vestingLockerDetails[lockId]
            .nextClaim
            .add(vestingLockerDetails[lockId].releaseCycle);

        vestingLockerDetails[lockId].remainingTokens = vestingLockerDetails[
            lockId
        ].remainingTokens.sub(tokensToRelease);

        if (vestingLockerDetails[lockId].remainingTokens == 0) {
            vestingLockerDetails[lockId].isTotallyClaimed = true;
        }
    }

    // withdraw bnb
    function withdrawBnb() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // withdraw all bep20 tokens
    function withdrawBep20Tokens(address _token, uint256 percentage)
        public
        onlyOwner
    {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        require(tokenBalance > 0, "No enough tokens in the pool");

        uint256 tokensToTransfer = tokenBalance.mul(percentage).div(100);

        IERC20(_token).transfer(msg.sender, tokensToTransfer);
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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