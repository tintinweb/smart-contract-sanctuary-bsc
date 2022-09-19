// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./Bond.sol";

contract BondDeployer is Ownable {
    event AdminTokenRecovery(address indexed tokenRecovered, uint256 amount);
    event NewBondContract(address indexed bondAddress);

    /**
     * @notice Constructor
     */
    constructor() public {
    }

    function deployBond(
        IERC20 _grona,
        IERC20 _crona,
        IGronaTreasury _gronaTreasury,
        uint256 _price,
        uint256 _expiration,
        uint256 _rewardPerBondPerSecond,
        uint256 _userLimit,
        uint256 _batchLimit,
        uint256 _startTime
    ) external onlyOwner {
        require(_startTime > block.timestamp, "Operations: StartTime must be greater than current timestamp");

        bytes memory bytecode = type(Bond).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_price, _expiration, _rewardPerBondPerSecond, _batchLimit, _startTime));
        address bondAddress;

        assembly {
            bondAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        Bond(bondAddress).initialize(
            _grona,
            _crona,
            _gronaTreasury,
            _price,
            _expiration,
            _rewardPerBondPerSecond,
            _userLimit,
            _batchLimit,
            _startTime
        );

        emit NewBondContract(bondAddress);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress) external onlyOwner {
        uint256 balanceToRecover = IERC20(_tokenAddress).balanceOf(address(this));
        require(balanceToRecover > 0, "Operations: Balance must be > 0");
        IERC20(_tokenAddress).transfer(address(msg.sender), balanceToRecover);

        emit AdminTokenRecovery(_tokenAddress, balanceToRecover);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

interface IGronaTreasury {
    function sell(uint256 _amount) external;
}

contract Bond is Ownable {
    using SafeMath for uint256;

    struct LockedBond {
        uint256 amount;
        uint256 expireTime;
        uint256 lastRewardTime;
    }

    // Whether it is initialized
    bool public isInitialized;
    // The block timestamp when staking starts
    uint256 public startTime;
    // token that can buy bond
    IERC20 public grona;
    // reward token for bond
    IERC20 public crona;
    IGronaTreasury public gronaTreasury;
    // grona tokens needed to buy one bond
    uint256 public price;
    // bond expiration,like 70 days
    uint256 public expiration;
    // crona tokens earned per second by one bond, which is calculated by daily earnings
    uint256 public rewardPerBondPerSecond;
    // limit number of bond that user can buy
    uint256 public userLimit;
    // total number of bond to sell
    uint256 public batchLimit;
    // total number of bond sold
    uint256 public batchSold;
    // user info
    mapping(address => LockedBond[]) private userLocks;
    mapping(address => uint256) public userBought;

    modifier onlyStart() {
        require(block.timestamp > startTime, "!start");
        _;
    }

    constructor() public {}

    function initialize(IERC20 _grona, IERC20 _crona, IGronaTreasury _gronaTreasury,
        uint256 _price, uint256 _expiration, uint256 _rewardPerBondPerSecond,
        uint256 _userLimit, uint256 _batchLimit, uint256 _startTime) external onlyOwner {
        require(!isInitialized, "initialized");
        require(address(_grona) != address(_crona), "same token");
        require(_price != 0, "price must be non-zero");
        require(_userLimit != 0, "userLimit must be non-zero");

        isInitialized = true;

        // uint256 cronaNeeded = rewardPerBondPerSecond.mul(expiration).mul(batchLimit);
        // require(crona.balanceOf(address(this)) >= cronaNeeded, "crona is not enough");

        grona = _grona;
        crona = _crona;
        gronaTreasury = _gronaTreasury;
        price = _price;
        expiration = _expiration;
        rewardPerBondPerSecond = _rewardPerBondPerSecond;
        userLimit = _userLimit;
        batchLimit = _batchLimit;
        startTime = _startTime;

        grona.approve(address(_gronaTreasury), uint(~0));
        transferOwnership(tx.origin);
    }

    function buy(uint256 bonds) external onlyStart {
        uint _batchSold = batchSold.add(bonds);
        require(_batchSold <= batchLimit, "exceed batch limit");
        batchSold = _batchSold;

        uint256 _userBought = userBought[msg.sender].add(bonds);
        require(_userBought < userLimit, "exceed user limit");
        userBought[msg.sender] = _userBought;

        uint256 gronaNeeded = bonds.mul(price);
        grona.transferFrom(msg.sender, address(this), gronaNeeded);

        // burn crona
        uint cronaBefore = crona.balanceOf(address(this));
        gronaTreasury.sell(grona.balanceOf(address(this)));
        uint cronaAfter = crona.balanceOf(address(this));
        if (cronaAfter > cronaBefore) {
            crona.transfer(address(this), cronaAfter - cronaBefore);
        }

        uint256 expireTime = block.timestamp.add(expiration);
        uint256 idx = userLocks[msg.sender].length;
        if (idx == 0 || userLocks[msg.sender][idx - 1].expireTime < expireTime) {
            userLocks[msg.sender].push(LockedBond({amount : bonds, expireTime : expireTime, lastRewardTime : block.timestamp}));
        } else {
            userLocks[msg.sender][idx - 1].amount = userLocks[msg.sender][idx - 1].amount.add(bonds);
        }

        emit Buy(msg.sender, bonds, price);
    }

    function harvest() external onlyStart {
        uint totalReward;
        uint zeroBond;
        uint256 idx = userLocks[msg.sender].length;
        for (uint i; i < idx; i++) {
            LockedBond memory _lockedBond = userLocks[msg.sender][i];

            if (_lockedBond.amount == 0) {
                zeroBond++;
                continue;
            }

            if (_lockedBond.lastRewardTime < _lockedBond.expireTime) {
                if (_lockedBond.expireTime > block.timestamp) {
                    totalReward = totalReward.add(block.timestamp.sub(_lockedBond.lastRewardTime).mul(_lockedBond.amount).mul(rewardPerBondPerSecond));
                    userLocks[msg.sender][i].lastRewardTime = block.timestamp;
                } else {
                    totalReward = totalReward.add(_lockedBond.expireTime.sub(_lockedBond.lastRewardTime).mul(_lockedBond.amount).mul(rewardPerBondPerSecond));
                    zeroBond++;
                    delete userLocks[msg.sender][i];
                }
            } else {
                zeroBond++;
                delete userLocks[msg.sender][i];
            }
        }

        if (idx != 0 && zeroBond == idx) {
            delete userLocks[msg.sender];
        }

        if (totalReward > 0) {
            crona.transfer(msg.sender, totalReward);
        }

        emit RewardPaid(msg.sender, totalReward);
    }

    function updatePrice(uint _price) external onlyOwner {
        price = _price;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(grona), "!grona");
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function pending(address user) external view returns (uint256){
        uint totalPending;
        uint256 idx = userLocks[user].length;
        for (uint i; i < idx; i++) {
            LockedBond memory _lockedBond = userLocks[user][i];

            if (_lockedBond.amount == 0) {
                continue;
            }

            if (_lockedBond.lastRewardTime < _lockedBond.expireTime) {
                if (_lockedBond.expireTime > block.timestamp) {
                    totalPending = totalPending.add(block.timestamp.sub(_lockedBond.lastRewardTime).mul(_lockedBond.amount).mul(rewardPerBondPerSecond));
                } else {
                    totalPending = totalPending.add(_lockedBond.expireTime.sub(_lockedBond.lastRewardTime).mul(_lockedBond.amount).mul(rewardPerBondPerSecond));
                }
            }
        }

        return totalPending;
    }

    function available() external view returns (uint256){
        return batchLimit.sub(batchSold);
    }

    function bonds() external view returns (LockedBond[] memory) {
        uint256 idx = userLocks[msg.sender].length;
        uint256 valid;
        for (uint i; i < idx; i++) {
            if (userLocks[msg.sender][i].amount != 0) {
                valid++;
            }
        }

        uint j;
        LockedBond[] memory validLocks = new LockedBond[](valid);
        for (uint i; i < idx; i++) {
            if (userLocks[msg.sender][i].amount != 0) {
                validLocks[j] = userLocks[msg.sender][i];
                j++;
            }
        }

        return validLocks;
    }

    /* ========== EVENTS ========== */
    event Buy(address indexed user, uint256 bonds, uint256 price);
    event RewardPaid(address indexed user, uint256 reward);
    event Recovered(address token, uint256 amount);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}