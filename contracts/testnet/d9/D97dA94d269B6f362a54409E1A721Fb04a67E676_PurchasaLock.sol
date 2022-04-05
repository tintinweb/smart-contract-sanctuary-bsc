/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    constructor () {
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


interface IBEP20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PurchasaLock is Ownable {
    using SafeMath for uint256;

    IBEP20 public tokenPCA = IBEP20(0x0F20967cFC65EA024c256E01387578646e377D58);

    /* PRIVATE SALE */
    struct Vesting {
        uint256 totalLocked;
        uint256 totalUnlocked;
        uint256 start;
        uint256 end;
        uint256 unlockAmount;
        uint256 unlockPeriod;
        uint256 lockMonth;
        uint256 unlockCheckPoint;
    }
    mapping (address => Vesting) public privateList;
    mapping (address => bool) public lockedList;

    uint256 LOCK_MONTH = 10 * 60;
 

    function lockToken(uint256 amount, uint256 lockingmonth, uint256 unlockamount) public {
        require(lockedList[msg.sender] == false, "You can only lock your token once at a time");
        tokenPCA.transferFrom(msg.sender, address(this), amount);
        lockedList[msg.sender] = true;
        Vesting storage vestPlan = privateList[msg.sender];
        vestPlan.totalLocked = vestPlan.totalLocked.add(amount);
         vestPlan.start = vestPlan.start == 0 ? block.timestamp : vestPlan.start;
        vestPlan.end = vestPlan.end == 0 ? block.timestamp + (lockingmonth * LOCK_MONTH) + ((100 / unlockamount) * LOCK_MONTH) : vestPlan.end;
        vestPlan.unlockAmount = vestPlan.unlockAmount.add(unlockamount);
        vestPlan.lockMonth = vestPlan.lockMonth.add(lockingmonth);
        // vestPlan.unlockPeriod = vestPlan.unlockPeriod.add(unlockingperiod);
    }

    function unlockToken() public {
        require(lockedList[msg.sender], "Please lock token first");
         Vesting storage vestPlan = privateList[msg.sender];
        uint256 unlockableAmount = availableAmountPrivate(msg.sender);
        if(unlockableAmount > 0){
            uint256 currentTime = block.timestamp;
            uint256 LOCK_CLIFF = vestPlan.lockMonth * LOCK_MONTH;

            if(currentTime > vestPlan.end){
                currentTime = vestPlan.end;
            }
            vestPlan.unlockCheckPoint = (currentTime - vestPlan.start.add(LOCK_CLIFF)) / LOCK_MONTH + 1;
            vestPlan.totalUnlocked = vestPlan.totalUnlocked.add(unlockableAmount);
            tokenPCA.transfer(msg.sender,  unlockableAmount);
        }
    }

    function availableAmountPrivate(address account) public view returns (uint256){
        Vesting memory vestPlan = privateList[account];

        //Already unlock all
        if(vestPlan.totalUnlocked >= vestPlan.totalLocked){
            return 0;
        }

        //No infor
        if(vestPlan.start == 0 || vestPlan.totalLocked == 0){
            return 0;
        }
        
        uint256 LOCK_CLIFF = vestPlan.lockMonth * LOCK_MONTH;

        uint256 currentTime = block.timestamp;
        if(currentTime >= vestPlan.end){
            return vestPlan.totalLocked.sub(vestPlan.totalUnlocked);
        }else if(currentTime < vestPlan.start.add(LOCK_CLIFF)){
            return 0;
        }else{
            uint256 currentCheckPoint = (currentTime - vestPlan.start.add(LOCK_CLIFF)) / LOCK_MONTH + 1;
            if(currentCheckPoint > vestPlan.unlockCheckPoint){
                uint256 unlockable =  ((currentCheckPoint - vestPlan.unlockCheckPoint)* vestPlan.unlockAmount * vestPlan.totalLocked) / 100;
                return unlockable;
            }else
                return 0;
        }
    }

    function nextUnlock (address account) public view returns (uint256){
        Vesting memory vestPlan = privateList[account];
        uint256 LOCK_CLIFF = vestPlan.lockMonth * LOCK_MONTH;
        if(vestPlan.totalLocked > 0) { // This account bought private
            uint256 nextUnlockPrivateVesting = vestPlan.unlockCheckPoint * LOCK_MONTH + vestPlan.start.add(LOCK_CLIFF);
            return nextUnlockPrivateVesting;
        }else
            return 0;
    }

    function lockedAmountPrivate(address account) public view returns(uint256){
        Vesting memory vestPlan = privateList[account];
        return  (vestPlan.totalLocked -  vestPlan.totalUnlocked) - availableAmountPrivate(account);        
    }

}