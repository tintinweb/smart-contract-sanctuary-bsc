/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// File: RichCatsToken.sol


pragma solidity ^0.8;

abstract contract RichCatsToken {
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    
    function balanceOf(address owner) public virtual view returns (uint);

    function approve(address spender, uint value) public virtual returns (bool);
}
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: rcntsinglepool.sol


pragma solidity ^0.8.13;





contract RCNTsinglePool is Ownable{

    event Deposit(address indexed depositor, uint amount);
    event Withdraw(address indexed withdrawer, uint amount);

    uint256 public CURRENT_POOL_VALUE;
    uint256 public MAX_POOL_VALUE = 2000000000000000000000000;
    uint256 public EMISSIONS_RATE = 17361111111;

    uint256 public MINIMUM_DURATION = 86400;
    uint256 public TAX_RATE  = 20;

    mapping(address => Staker) public stake;
    mapping(uint256 => Staker) public stakehistory;
    
    uint256 public TOTAL_INTEREST_PAID;
    uint256 public TAX_COLLECTED;
    uint256 public txCount;

    address constant RCNT_ADDRESS = 0x2370f1c27da5048038724843C258168f452A7e4a;

    struct Staker {
        uint256 deposit_amount;
        uint256 stake_creation_time;
        address staker_addr;
    }


    function SET_POOL_VALUE(uint256 newPoolValue, uint256 newEmissionRate) public onlyOwner {
        MAX_POOL_VALUE = newPoolValue;
        EMISSIONS_RATE = newEmissionRate;
    }

    function SET_TAX_DURATION(uint256 newDuration, uint256 newTaxRate) public onlyOwner {
        MINIMUM_DURATION = newDuration;
        TAX_RATE = newTaxRate;
    }


    function depositRCNT(uint256 depositvalue) public payable {
        Staker memory item = stake[msg.sender];
        require((CURRENT_POOL_VALUE + depositvalue) <= MAX_POOL_VALUE, "Max pool size reached! lower deposit amount");
        require( CURRENT_POOL_VALUE <= MAX_POOL_VALUE, "Staking Pool has reached max size!");
        require(RichCatsToken(RCNT_ADDRESS).balanceOf(msg.sender) > depositvalue, "Balance of RCNT not sufficient.");

        //transfer pending reward
        if (item.deposit_amount != 0) {
            uint256 pendingrewards = (block.timestamp - item.stake_creation_time)* EMISSIONS_RATE;
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),pendingrewards));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,pendingrewards);
            TOTAL_INTEREST_PAID += pendingrewards;
        }
        
        //update record
        stake[msg.sender] = Staker(item.deposit_amount+depositvalue, block.timestamp, msg.sender);
        stakehistory[txCount] = Staker(depositvalue, block.timestamp, msg.sender);

        
        //transfer depositvalue
        require(RichCatsToken(RCNT_ADDRESS).approve(msg.sender,depositvalue));
        RichCatsToken(RCNT_ADDRESS).transferFrom(msg.sender,address(this),depositvalue);

        CURRENT_POOL_VALUE += depositvalue;
        txCount ++;
        emit Deposit(msg.sender,depositvalue);

    }




    function unstakeRCNT(uint256 withdrawvalue) public payable {
        Staker memory item = stake[msg.sender];
        require(withdrawvalue <= item.deposit_amount, "amount is bigger than deposit balance!");
        
        // transfer pending reward
        uint256 pendingrewards = (block.timestamp - item.stake_creation_time)* EMISSIONS_RATE;
        require(RichCatsToken(RCNT_ADDRESS).approve(address(this),pendingrewards));
        RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,pendingrewards);
        TOTAL_INTEREST_PAID += pendingrewards;

        //update record


        //check if taxeable charged TAX_RATE%
        if ( block.timestamp - item.stake_creation_time < MINIMUM_DURATION) {
            
            stake[msg.sender] = Staker(item.deposit_amount-withdrawvalue, block.timestamp, msg.sender);
            uint tax_amount = withdrawvalue*TAX_RATE/100;
            uint balanceafterTax = withdrawvalue - tax_amount; 
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),balanceafterTax));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,balanceafterTax);
            TAX_COLLECTED += tax_amount;
            
        } else {
            stake[msg.sender] = Staker(item.deposit_amount-withdrawvalue, block.timestamp, msg.sender);
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),withdrawvalue));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,withdrawvalue);
        }

    CURRENT_POOL_VALUE -= withdrawvalue;
    emit Withdraw(msg.sender,withdrawvalue);
    }



    function claimRewards() public {
        Staker memory item = stake[msg.sender];
        require(item.deposit_amount > 0, "no deposit amount!");

        //calculate reward
        uint256 pendingrewards = (block.timestamp - item.stake_creation_time)* EMISSIONS_RATE;

         //update new timestamp
        stake[msg.sender] = Staker(item.deposit_amount, block.timestamp, msg.sender);

        //transfer reward
        require(RichCatsToken(RCNT_ADDRESS).approve(address(this),pendingrewards));
        RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,pendingrewards);
        TOTAL_INTEREST_PAID += pendingrewards;
        
    }




  function GET_POOL_BALANCE() public view returns(uint256) {
    
    return RichCatsToken(RCNT_ADDRESS).balanceOf(address(this));
  }


  function getRewards(address stake_addr) public view returns(uint256) {
    Staker memory item = stake[stake_addr];
    if (item.deposit_amount != 0) {
        return (block.timestamp - item.stake_creation_time) * EMISSIONS_RATE;
    }
    else {
        return (0);
    }
  }

}