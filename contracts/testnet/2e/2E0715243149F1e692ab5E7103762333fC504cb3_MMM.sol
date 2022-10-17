// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//modified from BSG
contract MMM is Ownable{
    using SafeMath for uint256; 
    IERC20 public usdt;
    uint256 private constant baseDivider = 10000;
    uint256 private constant freezeDay = 5 minutes;    //3 days default
    uint256 private constant withdrawDelay = 3 minutes;    //15 minutes default
    uint256 private constant freezeMultiply = 3;
    uint256[5] private packagePrice = [100e18, 500e18, 1000e18, 2000e18, 3000e18]; 
    uint32[5] private packageIncomePecent = [100, 100, 100, 200, 300];
    uint32 private constant feePercents = 300;

    address public feeReceivers;
    uint256 public startTime;
    uint256 public totalUser = 1;
    uint256 public totalDeposit;
    uint256 public totalDepositCount;
    uint256 public totalWithdraw;
    uint256 public totalReferWithdraw;
    
    address public defaultRefer;

    struct OrderInfo {
        uint256 start;  //last
        uint256 count;
    }

    mapping(address => OrderInfo[5]) public orderInfos;

    struct UserInfo {
        address referrer;
        uint256 totalDeposit;
        uint256 maxDepositID;
        uint256 depositCount;
        uint256 withdrawable;
        uint256 recWithdrawable;
        uint256 refReward;
        uint256 recRefReward;
        uint256 lastDeposit;
    }

    mapping(address=>UserInfo) public userInfo;
    
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    event WithdrawRef(address user, uint256 amount);

    constructor(address _usdt, address _feeReceivers, address _defaultRefer) {
        usdt = IERC20(_usdt);   
        feeReceivers = _feeReceivers;
        startTime = block.timestamp; 
        defaultRefer = _defaultRefer;
        UserInfo storage user = userInfo[defaultRefer];
        user.referrer = feeReceivers;
        // user.maxDepositID = 4;
    }

    //Get VIEW 
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(1 minutes);
    }

    function getData() external view returns 
        (uint256 _startTime, uint256 _totalUser, uint256 _totalDeposit, uint256 _totalDepositCount, uint256 _totalWithdraw, uint256 _totalReferWithdraw) 
    {
        return (startTime, totalUser, totalDeposit, totalDepositCount, totalWithdraw, totalReferWithdraw);
    }

    function getUserOrderData() external view returns 
        (uint256 _pack1Start, uint256 _pack2Start, uint256 _pack3Start, uint256 _pack4Start, uint256 _pack5Start) 
    {   
        return (
            orderInfos[msg.sender][0].start,
            orderInfos[msg.sender][1].start,
            orderInfos[msg.sender][2].start,
            orderInfos[msg.sender][3].start,
            orderInfos[msg.sender][4].start
        );
    }

    //Write External
    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer || _referral != msg.sender, "invalid refer");
        require(userInfo[defaultRefer].totalDeposit > 0 , "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        totalUser += 1;
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _packageID) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer != address(0), "register first");
        require(_packageID < 5, "Invalid Package ID");
        require(orderInfos[msg.sender][_packageID].start == 0 || orderInfos[msg.sender][_packageID].start + freezeDay < block.timestamp, "Package Order Freeze");
        
        usdt.transferFrom(msg.sender, address(this), packagePrice[_packageID]);
        usdt.transfer(feeReceivers, packagePrice[_packageID]* uint256(feePercents) / baseDivider);

        OrderInfo storage order = orderInfos[msg.sender][_packageID];

        if(order.start != 0)
            user.withdrawable += packagePrice[_packageID] + ((packagePrice[_packageID] * freezeMultiply * uint256(packageIncomePecent[_packageID])) / baseDivider);
            
        order.start = block.timestamp;
        order.count += 1;

        UserInfo storage user_ref = userInfo[user.referrer];
        user_ref.refReward += (10 / (5 + order.count)) * (packagePrice[_packageID]* uint256(packageIncomePecent[user_ref.maxDepositID]) / baseDivider) ;

        if(user.maxDepositID < _packageID)
            user.maxDepositID = _packageID;
        
        user.totalDeposit += packagePrice[_packageID];
        user.depositCount += 1;
        user.lastDeposit = block.timestamp;
        
        totalDepositCount += 1;
        totalDeposit += packagePrice[_packageID];

        emit Deposit(msg.sender, packagePrice[_packageID]);
    }

    function withdraw() external {
        uint256 cbalance = usdt.balanceOf(address(this));
        UserInfo storage user = userInfo[msg.sender];

        require((user.lastDeposit + withdrawDelay) < block.timestamp, '15 minutes delay');

        uint256 wdAmount = user.withdrawable;
        
        if(cbalance <= user.withdrawable){
            wdAmount = cbalance;
        }

        user.withdrawable -= wdAmount;
        user.recWithdrawable += wdAmount;
        totalWithdraw += wdAmount;
        usdt.transfer(msg.sender, wdAmount);
        emit Withdraw(msg.sender, wdAmount);
        
    }

    function withdrawRef() external {
        uint256 cbalance = usdt.balanceOf(address(this));
        UserInfo storage user = userInfo[msg.sender];

        uint256 wdAmount = user.refReward;
        
        if(cbalance <= user.refReward){
            wdAmount = cbalance;
        }

        user.refReward -= wdAmount;
        user.recRefReward += wdAmount;
        totalReferWithdraw += wdAmount;
        usdt.transfer(msg.sender, wdAmount);
        emit WithdrawRef(msg.sender, wdAmount);
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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