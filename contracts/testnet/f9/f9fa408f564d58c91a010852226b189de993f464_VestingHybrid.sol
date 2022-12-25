/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

pragma solidity 0.8.17;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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




// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.17;

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.17;



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


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity 0.8.17;

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

//file: VestingHybrid.sol
pragma solidity 0.8.17;

contract VestingHybrid is Ownable {
    using SafeMath for uint256;

// struct to store information about a vesting tier
struct VestingTier {
    uint256 amount; // total amount of tokens in the tier
    uint256 cliff; // cliff duration in seconds
    uint256 vesting; // vesting duration in seconds
    uint256 start; // start time of the vesting period, in seconds
    uint256 claimed; //total claimed from vesting
}

              //Mappings
mapping(address => VestingTier) public vestingTiers;
mapping(address =>uint256) public TgeAmount;
mapping (address => bool) TgeAmountClaimed;

// event emitted when a beneficiary claims their vested tokens
event Claimed(address indexed beneficiary, uint256 amount);
// event emitted when a beneficiary claims their TGE unlock tokens
event TGEclaimed (address indexed beneficiary, uint256 amount);
// declaring token variable which will vested
IERC20 public token;

// store the timeStamp of the token generation event (TGE)
uint256 public tgeTime;

constructor(uint256 _tgeTime, address _token)  {
    
  tgeTime = _tgeTime;
  token = IERC20 (_token);
}

// set the time of the token generation event
function setTgeTime(uint256 time) external onlyOwner {
    tgeTime = time;
}

// add an address to a vesting tier
function addVesting(uint8 tier, address[] calldata beneficiaries, uint256[] calldata amounts) external onlyOwner {
    require(beneficiaries.length == amounts.length, "beneficiaries and amount must have the same length");
   
    uint256 cliff_;
    uint256 vesting_;
    uint256 initialUnlock_;

    
    //Tier 1 has 0 cliff time, 1% unlock at TGE, 99% linearly vested for 20 months
    if (tier == 1) {
        cliff_ = 0;
        vesting_ = 20 days;
        initialUnlock_ = 10;

    //Tier 2 has 2 months cliff time, 2% unlock at TGE, 98% linearly vested for 17 months
    } else if (tier == 2) {
        cliff_ = 2 hours ;
        vesting_ = 17 days;
        initialUnlock_ = 20;

    //Tier 3 has 1 months cliff time, 4% unlock at TGE, 98% linearly vested for 18 months 
    } else if (tier == 3) {
        cliff_ = 1 hours;
        vesting_ = 18 days;
        initialUnlock_ = 40;

    //Tier 4 has 1 months cliff time, 4% unlock at TGE, 98% linearly vested for 16 months  
    } else if(tier == 4){
        cliff_ = 1 hours;
        vesting_ = 16 days;
        initialUnlock_ = 40;
    } else {
        revert("Invalid vesting tier");
    }
    // iterate through the beneficiaries and add them to the vesting mapping
    for (uint256 i = 0; i < beneficiaries.length; i++) {
        // calculate the start time of the vesting period
        uint256 startTime = tgeTime + (cliff_);
        // create a VestingTier struct and store it in the mapping
        vestingTiers[beneficiaries[i]] = VestingTier({
          
            amount: amounts[i] - amounts[i].mul(initialUnlock_).div(1000),
            cliff: cliff_,
            vesting: vesting_,
            start: startTime,
            claimed: 0
        });
        
        TgeAmount[beneficiaries[i]] = amounts[i].mul(initialUnlock_).div(1000);
        
        
    }
}


function AutoDistribute(address [] calldata beneficiries) public {
    for (uint256 i =0; i<beneficiries.length; i++){
        claim(beneficiries[i]);
    }
}

// claim vested tokens for a beneficiary
function claim(address beneficiary) public  {
    require (block.timestamp >= tgeTime, "TGE time is not reached yet");
    require (beneficiary != address(0), "beneficiary can't be a zero address");
    uint256 tgeUnlock;
    VestingTier memory tier = vestingTiers[beneficiary];
    uint256 claimableAmount = getUnlockedAmount(beneficiary);

    if (tier.claimed + claimableAmount > tier.amount){
        claimableAmount = tier.amount - tier.claimed;
    }

    if (TgeAmountClaimed[beneficiary]){
        tgeUnlock = 0;
    }

    if (!TgeAmountClaimed[beneficiary]){
    tgeUnlock = TgeAmount[beneficiary];
    TgeAmountClaimed[beneficiary] = true;
    emit TGEclaimed(beneficiary, tgeUnlock);
    } 

    tier.claimed += claimableAmount;
    vestingTiers[beneficiary] = tier;
    // transfer the vested tokens to the beneficiary
    token.transfer(beneficiary, claimableAmount.add(tgeUnlock));
    // emit the Vested event
    emit Claimed(beneficiary, claimableAmount);
    // update the claimed Tokens information for the beneficiary
   
   
   }

function claimOtherERC20tokens (address _token) external onlyOwner {
    require (_token != address(token), "No rugPull");
    uint256 balance = IERC20(_token).balanceOf(address(this));
    IERC20 (_token).transfer(owner(),balance);
   }   

function getUnlockedAmount (address user) public view returns (uint256 amount){
    
     VestingTier memory tier = vestingTiers[user];
     uint256 elapsed;
     if (tier.start >= block.timestamp) {
         elapsed = 0;
     }
     if (tier.start < block.timestamp) {
     elapsed = block.timestamp.sub(tier.start);
     }
    uint256 releasePerSecond = tier.amount.div(tier.vesting);
    amount = releasePerSecond.mul(elapsed).sub(tier.claimed);
    
   } 
}