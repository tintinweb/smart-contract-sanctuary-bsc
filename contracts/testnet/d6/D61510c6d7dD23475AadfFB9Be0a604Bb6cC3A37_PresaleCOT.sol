/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File: @openzeppelin/contracts/token/BEP20/IBEP20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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


// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.6.0;

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
contract Ownable is Context {
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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


/// @title PresaleBEP20 Contract

pragma solidity ^0.6.0;

interface ICOT {
    function mint(
        address user,
        uint256 amount
    ) external;
}

contract PresaleCOT is Ownable {
    using SafeMath for uint256;

    ICOT public token;
    address payable public treasury;
    uint8 public immutable whitelistDiscountRate;
    uint256 public immutable presaleStartTimestamp;
    uint256 public immutable presaleEndTimestamp;
    uint256 public immutable dynamicBonusThreshold;
    uint256 public constant hardCapEthAmount = 350 ether;
    uint256 public constant minimumDepositEthAmount = 0 ether;
    uint256 public constant maximumDepositEthAmount = 3.5 ether;
    uint256 private constant precision = 100;
    uint256 public totalDepositedEthBalance;
    uint256 public totalInvestors;

    struct LevelData {
        uint256 tokenPrice;
        uint256 minContribution; 
    }
    
    mapping(uint8 => LevelData) public levels; 
    mapping(address => uint256) public deposits;
    mapping(address => bool) public isWhitelisted; 

    constructor(
        ICOT token_,
        address treasury_,
        uint8 discount_,
        uint256 startTime_,
        uint256 endTime_,
        uint256 dynamicBonusThreshold_,
        uint256[] memory levelPrice_,
        uint256[] memory levelBound_
    ) public {
        require(discount_ > 0 && discount_ <= 100, "Invalid discount");
        require(levelPrice_.length == levelBound_.length, "Invalid inputs");

        token = token_;
        treasury = payable(treasury_);
        whitelistDiscountRate = discount_;
        presaleStartTimestamp = startTime_;
        presaleEndTimestamp = endTime_;
        dynamicBonusThreshold = dynamicBonusThreshold_;

        for(uint8 i; i < levelPrice_.length; i++) {
            levels[i] = LevelData(levelPrice_[i], levelBound_[i]);
        }
    }

    receive() payable external {
        deposit();
    }

    function deposit() public payable {
        require(
            now >= presaleStartTimestamp && now <= presaleEndTimestamp,
            "Presale is not active"
        );
        require(
            totalDepositedEthBalance.add(msg.value) <= hardCapEthAmount,
            "Deposit limits reached"
        );

        uint256 balance = deposits[msg.sender]; 
        
        require(
            balance.add(msg.value) >= minimumDepositEthAmount && balance.add(msg.value) <= maximumDepositEthAmount,
            "incorrect amount"
        );

        totalDepositedEthBalance = totalDepositedEthBalance.add(msg.value);
        
        if (deposits[msg.sender] == 0) { 
            totalInvestors++;
        }
        
        deposits[msg.sender] = balance.add(msg.value);
        
        emit Deposited(msg.sender, msg.value);
    }
    
    function claim(uint8 level_) external {
        require(
            now > presaleEndTimestamp || totalDepositedEthBalance == hardCapEthAmount,
            "Presale is active"
        );
        
        uint256 depositedAmount = deposits[msg.sender];
        
        require(depositedAmount >= levels[level_].minContribution, "Invalid level");
        
        uint256 tokenAmount = depositedAmount.mul(1e18).div(levels[level_].tokenPrice);
        
        if(isWhitelisted[msg.sender]) {
            tokenAmount = tokenAmount.mul(100).div(100 - whitelistDiscountRate);
        }

        uint256 dynamicAmount = calculateDynamicAmount(depositedAmount);

        token.mint(msg.sender, tokenAmount.add(dynamicAmount));
        
        delete deposits[msg.sender];

        emit Claimed(msg.sender, depositedAmount);
    }

    function calculateBasicAmount(uint256 amount_, uint8 level_) public view returns(uint256) {
        return amount_.mul(1e18).div(levels[level_].tokenPrice);
    }

    function calculateBasicAmountWhitelist(uint256 amount_, uint8 level_) public view returns(uint256) {
        uint256 amount = amount_.mul(1e18).div(levels[level_].tokenPrice);
        return amount.mul(100).div(100 - whitelistDiscountRate);
    }
    
    function calculateDynamicAmount(uint256 amount_) public view returns(uint256) {
        
        uint256 avg = totalDepositedEthBalance.div(totalInvestors);
        
        uint256 diff = (avg > amount_) ? avg.sub(amount_) : amount_.sub(avg);

        uint256 adjustedPercentage = precision.sub(precision.mul(diff).div(totalDepositedEthBalance));

        adjustedPercentage = (adjustedPercentage > 75) ? adjustedPercentage.sub(75) : 0;

        uint256 expValue = (((11 ** adjustedPercentage).mul(precision)).div(10 ** adjustedPercentage)).sub(precision);

        return dynamicBonusThreshold.mul(expValue).div(983);
    }

    function addToWhitelist(address[] memory account_) external onlyOwner {
        for(uint i; i < account_.length; i++) {
            isWhitelisted[account_[i]] = true;
        }
    }

    function removeFromWhitelist(address[] memory account_) external onlyOwner {
        for(uint i; i < account_.length; i++) {
            isWhitelisted[account_[i]] = false;
        }
    }

    function releaseFunds() external onlyOwner {
        require(
            now >= presaleEndTimestamp || totalDepositedEthBalance == hardCapEthAmount,
            "Presale is active"
        );
        treasury.transfer(address(this).balance);
    }


    function recoverBEP20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IBEP20(tokenAddress).transfer(this.owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function getDepositAmount() public view returns (uint256) {
        return totalDepositedEthBalance;
    }
    
    function getLeftTimeAmount() public view returns (uint256) {
        if(now > presaleEndTimestamp) {
            return 0;
        } else {
            return (presaleEndTimestamp - now);
        }
    }

    event Deposited(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
}