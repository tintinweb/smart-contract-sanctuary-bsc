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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IStake {
    struct UserInfo {
        uint256 stakedAmount; // User staked amount
        uint256 lastStakedTimestamp; // User staked timestamp
        uint256 lastUnstakedTimestamp; // User unstaked timestamp
    }

    function getUserInfoByPid(
        uint256 _pid,
        address _userAddress
    ) external view returns (UserInfo memory);
}

interface IDHBR is IERC20 {
    function Reward(address user, uint256 amount) external;
}

interface IDHB is IERC20 {
    function getInviter(address user) external view returns(address);
}

interface LPTOKEN {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Game is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint112;

    struct UserInfo {
        uint256 count;  //参加的次数
        uint256 enterTimestamp;  //参加的时间
        bool isReward; // 是否中奖
        bool waitProcess; //等待开奖 
    }

    mapping(address => UserInfo) private _mapUserInfo;

    mapping(address => bool) public _blackLists;

    IStake public _stakeAddress;
    IDHBR public _DHBRAddress;

    IDHB public _DHBAddress;

    IERC20 immutable _busdAddress;
    LPTOKEN public _lpAddress;

    address public _operator;
    bool public _start = false;

    uint256 private _dayTime = 24 * 60 * 60;

    //开始游戏金额
    uint256 public _startValue = 10;

    event SetStakeAddress(address indexed StakeAddress);
    event SetDHBRAddress(address indexed DHBRAddress);
    event SetDHBAddress(address indexed DHBAddress);
    event WithdrawToken(address token, address owner, uint256 amount);
    event SetOperator(address indexed newOperator);
    event ChangeGameState(bool);
    event SetStartValue(uint256);
    event EnterGame(address indexed user, uint256 indexed value);
    event ProcessGame(address indexed user, uint256 indexed value, bool indexed bReward);

    constructor(address busdt) {
        _busdAddress = IERC20(busdt);
    }

    modifier OnlyOperator() {
        require(msg.sender == _operator, "Only operator");
        _;
    }

    function setStakeAddress(address newStakeAddress) external onlyOwner {
        _stakeAddress = IStake(newStakeAddress);
        emit SetStakeAddress(newStakeAddress);
    }

    function setDHBRAddress(address DHBRAddress) external onlyOwner {
        _DHBRAddress = IDHBR(DHBRAddress);
        emit SetDHBRAddress(DHBRAddress);
    }

    function setDHBAddress(address DHBAddress) external onlyOwner {
        _DHBAddress = IDHB(DHBAddress);
        emit SetDHBAddress(DHBAddress);
    }

    function setGameStatus() external onlyOwner {
        _start = !_start;
        emit ChangeGameState(_start);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
        emit WithdrawToken(token, msg.sender, amount);
    }

    function setStartValue(uint256 value) external onlyOwner {
        _startValue = value;
        emit SetStartValue(value);
    }

    //获取应该收取的费用
    function getValue(uint256 count)  internal view returns(uint256) {
        uint256 resValue = _startValue;
        for (uint256 i = 0; i < count; i++) {
            resValue = resValue * 2;
        }
        return resValue;
    }

    //dhb 价格放大了1000倍 减少误差
    function getDHBPrice() internal view returns(uint256) {
        //TODO test
        (uint112 a, uint112 b,) = _lpAddress.getReserves();
        return uint256(a.mul(1000).div(b));
    }

    function JoinGame() external {
        //是否管理员已经设置比赛
        require(_start, "not start");

        UserInfo memory userInfo = _mapUserInfo[msg.sender];

        //是否等待开奖
        require(!userInfo.waitProcess, "wait process");
        
        //判断是不是在24小时内
        if (block.timestamp < (userInfo.enterTimestamp + _dayTime)) {
            //判断今天是否赢了
            require(!userInfo.isReward, "Win in 24h");
            //判断今天是否超过5次
            require(userInfo.count <= 5, "enter 5 times in 24h");
        }
        
        //获取参加金额，判断钱包是否够
        uint256 needValue = getValue(userInfo.count);
        uint256 needDHBValue = needValue.mul(1000).div(getDHBPrice());
        require(needDHBValue < _DHBRAddress.balanceOf(msg.sender), "dhb not enough");
        require(needValue < _busdAddress.balanceOf(msg.sender), "busd not enough");
        
        //判断质押数量 TODO
        uint256 amount = _stakeAddress.getUserInfoByPid(0, msg.sender).stakedAmount;
        require(amount > 0, "No stake");

        _DHBRAddress.transferFrom(msg.sender, address(this), needDHBValue);
        _busdAddress.transferFrom(msg.sender, address(this), needValue);

        //黑名单扣完钱 return
        if (isBlack(msg.sender)) {
            return;
        }
        //是否有上级推荐,没有返回
        if (_DHBAddress.getInviter(msg.sender) == address(0x00)) {
            return;
        }
        
        //正常玩家更改状态 发出通知
        userInfo.count = userInfo.count + 1;
        userInfo.isReward = false;
        if (userInfo.count == 1) {
            userInfo.enterTimestamp = block.timestamp;
        }
        
        userInfo.waitProcess = true;

        _mapUserInfo[msg.sender] = userInfo;
        emit EnterGame(msg.sender, needValue);
    }

    function joinGameDHBR() external {
        //代码整合
        //是否管理员已经设置比赛
        require(_start, "not start");

        UserInfo memory userInfo = _mapUserInfo[msg.sender];

        //是否等待开奖
        require(!userInfo.waitProcess, "wait process");
        
        //判断是不是在24小时内
        if (block.timestamp < (userInfo.enterTimestamp + _dayTime)) {
            //判断今天是否赢了
            require(!userInfo.isReward, "Win in 24h");
            //判断今天是否超过5次
            require(userInfo.count <= 5, "enter 5 times in 24h");
        }
        
        //获取参加金额，判断钱包是否够
        uint256 needValue = getValue(userInfo.count);
        uint256 needDHBValue = needValue.mul(1000).div(getDHBPrice());
        require(needDHBValue < _DHBRAddress.balanceOf(msg.sender), "dhb not enough");
        require(needValue < _DHBRAddress.balanceOf(msg.sender), "busd not enough");
        
        //判断质押数量 TODO
        uint256 amount = _stakeAddress.getUserInfoByPid(0, msg.sender).stakedAmount;
        require(amount > 0, "No stake");

        _DHBRAddress.transferFrom(msg.sender, address(this), needDHBValue);
        _DHBRAddress.transferFrom(msg.sender, address(this), needValue);

        //黑名单扣完钱 return
        if (isBlack(msg.sender)) {
            return;
        }
        //是否有上级推荐,没有返回
        if (_DHBAddress.getInviter(msg.sender) == address(0x00)) {
            return;
        }
        
        //正常玩家更改状态 发出通知
        userInfo.count = userInfo.count + 1;
        userInfo.isReward = false;
        userInfo.enterTimestamp = block.timestamp;
        userInfo.waitProcess = true;

        _mapUserInfo[msg.sender] = userInfo;
        emit EnterGame(msg.sender, needValue);
    }

    function processGame(address userAddress, bool result) external OnlyOperator {
        UserInfo memory userInfo = _mapUserInfo[userAddress];

        //是否等待开奖
        require(userInfo.waitProcess, "not wait process");

        userInfo.waitProcess = false;
        //中奖
        if (result) {
            //非黑名单发钱 发钱逻辑可能要修改 TODO
            if (!_blackLists[userAddress]) {
                _busdAddress.transferFrom(address(this), userAddress, getValue(userInfo.count - 1));
            }
            userInfo.isReward = true;
        }
        _mapUserInfo[userAddress] = userInfo;

        emit ProcessGame(userAddress, getValue(userInfo.count - 1), result);
        //黑名单更改状态结束
        if (_blackLists[userAddress]) {
            return;
        }
        
        if (userInfo.count == 5 && !result) {
            _DHBRAddress.Reward(userAddress, getValue(5));
        }
    }

    function addBlackList(address target, bool value) public OnlyOperator {
        _blackLists[target] = value;
    }

    function isBlack(address target) public view returns(bool) {
        return _blackLists[target];
    }
}