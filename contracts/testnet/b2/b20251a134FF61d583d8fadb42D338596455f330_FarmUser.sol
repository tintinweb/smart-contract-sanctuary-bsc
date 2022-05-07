// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFarmUser.sol";
import "./interfaces/IAppConf.sol";

import "../libs/IERC20Ex.sol";
import "../libs/Initializable.sol";

import "./Model.sol";

// user
contract FarmUser is IFarmUser, Initializable, Ownable {
    // relationship, useraddr -> inviterAddr
    mapping(address => address) inviteMap;
    // invite list
    mapping(address => address[]) invitationMap;

    // useraddr -> old level -> new level -> deltaprice -> hashrate
    event UpgradeLevel(address, uint8, uint8, uint256, uint256);

    mapping(address => Model.User) public userMap;
    Model.User[] allUsers;
    uint256 public userCount;

    mapping(address => uint256) public levelHashrateMap;

    IAppConf appConf;

    modifier onlyFarm {
        require(appConf.validFarm(_msgSender()), "call forbidden, invalid farm");
        _;
    }

    function init(IAppConf _appConf) public onlyOwner {
        appConf = _appConf;

        inviteMap[appConf.getRootInviter()] = appConf.getRootInviter();
        userMap[appConf.getRootInviter()] = Model.User({
            addr: appConf.getRootInviter(),
            inviterAddr: appConf.getRootInviter(),
            levelNo: 0,
            out: 0,
            outTimes: 0,
            outAmount: 0,
            totalInvestAmount: 0,
            totalYieldAmount: 0,
            totalInviteAmount: 0
        });
        allUsers.push(userMap[appConf.getRootInviter()]);
        userCount = SafeMath.add(userCount, 1);

        initialized = true;
    }

    function getInviterUser(address userAddr) public view override returns (Model.User memory)
    {
        Model.User memory user = userMap[inviteMap[userAddr]];
        return user;
    }

    function bindInviter(address inviterAddr) public override needInit {
        require(_msgSender() != inviterAddr, "Can not invite self");
        require(inviteMap[_msgSender()] == address(0), "Can only bind once.");
        require(inviteMap[inviterAddr] != address(0), "Inviter not exists.");

        inviteMap[_msgSender()] = inviterAddr;
        userMap[_msgSender()] = Model.User({
            addr: _msgSender(),
            inviterAddr: inviterAddr,
            levelNo: 0,
            out: 0,
            outTimes: 0,
            outAmount: 0,
            totalInvestAmount: 0,
            totalYieldAmount: 0,
            totalInviteAmount: 0
        });
        allUsers.push(userMap[_msgSender()]);

        invitationMap[inviterAddr].push(_msgSender());
        userCount = SafeMath.add(userCount, 1);
    }

    function getUserByAddr(address userAddr) public view override returns (Model.User memory)
    {
        Model.User memory user = userMap[userAddr];
        return user;
    }

    function existUser(address userAddr) public view override returns (bool) {
        return userMap[userAddr].addr == userAddr && userAddr != address(0);
    }

    function invitation(address inviterAddr) public view returns (address[] memory)
    {
        return invitationMap[inviterAddr];
    }

    function incrementInvestAmount(address userAddr, uint256 usdtAmount) external override onlyFarm returns (Model.User memory) {
        userMap[userAddr].totalInvestAmount = userMap[userAddr].totalInvestAmount + usdtAmount;
        userMap[userAddr].outAmount = getOutAmount(userMap[userAddr].totalInvestAmount);

        if (userMap[userAddr].out == 1 && userMap[userAddr].totalYieldAmount < userMap[userAddr].outAmount) {
            userMap[userAddr].out = 0;
        }

        Model.Level[] memory levels = appConf.getAllLevels();
        for (uint256 index = levels.length - 1; index <= 0; index--) {
            if (userMap[userAddr].totalInvestAmount >= levels[index].price) {
                userMap[userAddr].levelNo = levels[index].levelNo;
                break;
            }
        }

        return userMap[userAddr];
    }

    function decrementInvestAmount(address userAddr, uint256 usdtAmount) external override onlyFarm returns (Model.User memory) {
        userMap[userAddr].totalInvestAmount = SafeMath.sub(userMap[userAddr].totalInvestAmount, usdtAmount);
        userMap[userAddr].outAmount = getOutAmount(userMap[userAddr].totalInvestAmount);

        if (userMap[userAddr].totalYieldAmount > userMap[userAddr].outAmount) {
            out(userAddr);
        }

        return userMap[userAddr];
    }

    function incrementYieldAmount(address userAddr, uint256 usdtAmount) external override onlyFarm returns (bool)
    {
        userMap[userAddr].totalYieldAmount = SafeMath.add(userMap[userAddr].totalYieldAmount, usdtAmount);

        if (userMap[userAddr].totalYieldAmount >= userMap[userAddr].outAmount) {
            out(userAddr);
            return true;
        }

        return false;
    }

    function incrementInviteAmount(address userAddr, uint256 usdtAmount) external override onlyFarm {
        userMap[userAddr].totalInviteAmount = SafeMath.add(userMap[userAddr].totalInviteAmount, usdtAmount);
    }

    function out(address userAddr) public override onlyFarm {
        Model.User storage user = userMap[userAddr];
        user.out = 1;
        user.outTimes++;
        user.outAmount = 0;
        user.totalInvestAmount = 0;
        user.totalYieldAmount = 0;
        user.totalInviteAmount = 0;
        user.levelNo = 0;
    }

    function getOutAmount(uint256 investAmount) private view returns (uint256)
    {
        uint256 outAmount = SafeMath.div(SafeMath.mul(investAmount, appConf.getOutMultiple()), Model.RATE_BASE);
        return outAmount;
    }

    function getAllUsers() external view override returns(Model.User[] memory) {
        return allUsers;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Model.sol";

interface IFarmUser {
    function getInviterUser(address userAddr) external view returns (Model.User memory);
    function bindInviter(address inviterAddr) external;
    function getUserByAddr(address userAddr) external view returns (Model.User memory);
    function existUser(address userAddr) external view returns (bool);
    function incrementInvestAmount(address userAddr, uint256 usdtAmount) external returns (Model.User memory);
    function decrementInvestAmount(address userAddr, uint256 usdtAmount) external returns (Model.User memory);
    function incrementYieldAmount(address userAddr, uint256 usdtAmount) external returns (bool);
    function incrementInviteAmount(address userAddr, uint256 usdtAmount) external;
    function out(address userAddr) external;
    function getAllUsers() external view returns(Model.User[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Model.sol";

interface IAppConf {
    function validFarm(address farmAddr) external returns (bool);
    function validPair(address token0, address token1) external view returns (bool);
    function getAllPairs() external view returns (Model.Pair[] memory);

    function getLevelCommissionRate(uint8 levelNo, uint8 gen) external view returns (uint256);
    function getCoolAddr() external view returns (address);
    function getRootInviter() external view returns (address);
    function getHashrateConf(uint8 category) external view returns (Model.HashrateConf memory);

    function getBurnAddr() external view returns (address);
    function getMaxGen() external view returns (uint256);
    function getOutMultiple() external view returns (uint256);

    function getPairQuoteBurnRate() external view returns (uint256);
    function getPairUsdtRate() external view returns (uint256);
    function getPairUsdtSwapRate() external view returns (uint256);
    function getPairSwapBurnRate() external view returns (uint256);
    function getPairSwapCoolAddr() external view returns (address);

    function getSwapToken() external view returns (address);
    function getLPCoolAddr() external view returns (address);
    function getRankCoolAddr() external view returns (address);
    function getFundCoolAddr() external view returns (address);

    function getClaimProfitRate() external view returns(Model.ClaimProfitRate memory);

    function getRewardPerSecond() external view returns (uint256);

    function getSwapPath(address tokenIn, address tokenOut) external view returns(address[] memory);

    function getLevel(uint8 levelNo) external view returns(Model.Level memory);
    function getAllLevels() external view returns(Model.Level[] memory);

    function getRankTop() external returns(uint256);
    function getQuoteBasePrice() external returns(uint256);
    function getFarmDeltaRate() external returns(uint256);

    function getFarmAddr() external view returns(Model.FarmAddr memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Ex is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Initializable {
 
    bool public initialized = false;

    modifier needInit() {
        require(initialized, "Contract not init.");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Model {
    uint8 constant CATEGORY_LEVEL = 1;
    uint8 constant CATEGORY_LP = 2;
    uint8 constant CATEGORY_PAIR = 3;
    uint8 constant CATEGORY_TOKEN = 4;

    uint256 constant RATE_BASE = 1000;

    struct User {
        address addr;
        address inviterAddr;
        uint8 levelNo;
        uint8 out; // is out
        uint8 outTimes; // out times
        uint256 outAmount; // base USDT
        uint256 totalInvestAmount;
        uint256 totalYieldAmount;
        uint256 totalInviteAmount;
    }

    struct Pair {
        address token0;
        string token0Symbol;
        uint8 token0Decimals;
        address token1;
        string token1Symbol;
        uint8 token1Decimals;
        uint8 status;
    }

    struct Level {
        string name;
        uint8 levelNo;
        uint8 commissionGen;
        uint256 price;
        uint8 needOut;
    }

    struct HashrateConf {
        uint256 multiple; // multple fro usdt
        uint256 baseHashrate; // hashrate base amount
        uint256 minTotalHashrate; // network min hashrate
        uint256 maxTotalHashrate; // network max hashrate
        uint256 maxReward; // network max reward
        uint8 rebate; // hashrate rebate
        uint8 tokenRebate; // token rebate
        uint8 invited; // if 1 for invited user
    }

    struct HashrateRecord {
        uint8 category; // 0=all, 1=level, 2=lp, 3=pair
        uint256 blockNumber;
        uint256 timestamp;
        uint256 totalHashrate;
    }

    struct CommissionRecord {
        address from;
        address to;
        uint256 commission;
    }

    struct ClaimProfitRate {
        uint256 burnRate;
        uint256 rankRate;
        uint256 lpRate;
        uint256 fundRate;
    }

    struct FarmAddr {
        address pancake;
        address farmUser;
        address farmPair;
        address farmReward;
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