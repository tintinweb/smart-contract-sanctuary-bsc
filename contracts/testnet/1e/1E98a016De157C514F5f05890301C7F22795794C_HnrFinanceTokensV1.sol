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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IHonorTreasureV1 {
    function depositToken(address token,uint256 amount) external;
    function depositWETH(uint256 amount) external;
    function depositHonor(uint256 amount) external;
    function widthdrawToken(address token,uint256 amount,address _to) external;
    function widthdrawWETH(uint256 amount,address _to) external;
    function widthdrawHonor(uint256 amount,address _to) external;
    function getTokenReserve(address token) external view returns(uint256);
    function getWETHReserve() external view returns(uint256);
    function getPairAllReserve(address token0,address token1) external view returns(uint112 ,uint112 );
    function getHonorBUSDValue(uint256 amount) external view returns(uint256); 
    function getBUSDHonorValue(uint256 amount) external view returns(uint256); 
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Helpers/IHonorTreasureV1.sol";
import "./Helpers/IWETH.sol";

contract HnrFinanceTokensV1 is Ownable {

    using SafeMath for uint256;

    IHonorTreasureV1 public _honorTreasure;
    address public _honorToken;
    address public _wethToken;
    
    uint256 public _awardInterest;

    struct TokenFinance 
    {
        uint256 maxAmountPerUser;
        uint256 maxTotalAmount;
        uint256 totalAmount;
        uint256 interest;
    }

    struct UserBalance {
        uint start_time;
        uint duration;
        uint interest_rate;
        uint amount;       
    }

    struct HonorBalance {
        uint start_time;
        uint duration;
        uint interest_rate;
        uint256 amount;
        uint256 busdValue;
    }
    mapping(address=>TokenFinance) public _tokenFinances;
    mapping(address=>mapping(address=>UserBalance)) public _userBalances;
    mapping(address=>HonorBalance) _userHonorBalances;

    constructor(address honorToken,address wethToken,address treasure)
    {
        _honorToken=honorToken;
        _wethToken=wethToken;
        _honorTreasure=IHonorTreasureV1(treasure);

        IERC20(_honorToken).approve(treasure, type(uint256).max);
        IERC20(_wethToken).approve(treasure, type(uint256).max);
    }

    function addToken(address token,uint256 maxAmountUser,uint256 maxTotalAmount,uint256 interest) public onlyOwner {
        TokenFinance storage finance=_tokenFinances[token];
        finance.maxAmountPerUser=maxAmountUser;
        finance.maxTotalAmount=maxTotalAmount;
        finance.interest=interest;
        IERC20(token).approve(address(_honorTreasure), type(uint256).max);
    }
    /*
    uint256 public YEAR_INTEREST=5707762557;
    uint256 public SIXMONTH_INTEREST=4883307965;
    uint256 public THREEMONTH_INTEREST=4223744292;
    uint256 public MONTH_INTEREST=3611745307;
    */

    event Deposit(address indexed _from,address indexed _token,uint256 _amount,uint256 duration);
    event Widthdraw(address indexed _from,address indexed _token,uint256 _amount,uint256 duration);


    function setInterestRates(address token,uint256 _interest) public onlyOwner {
        TokenFinance storage finance=_tokenFinances[token];
        finance.interest=_interest;
    }

    function setAwardInterest(uint256 interest) public onlyOwner {
        _awardInterest=interest;
    }

    function setMaxCaps(address token,uint256 maxPerUser,uint256 maxAmount) public onlyOwner {
        TokenFinance storage finance=_tokenFinances[token];
        finance.maxAmountPerUser=maxPerUser;
        finance.maxTotalAmount=maxAmount;
    }

    function getInterestRate(uint duration,address token,uint256 amount) public view returns(uint256) {
        if(duration<2592000)
            return 0;

        TokenFinance memory finance=_tokenFinances[token];
       

        if(amount>=(finance.maxAmountPerUser/2))
        {
            if(duration>=31536000)
                return finance.interest * 2090 / 1000;
            if(duration>=15552000)
                return finance.interest * 1803 / 1000;
            if(duration>=7776000)
                return finance.interest * 1580 / 1000;
            if(duration>=2592000)
                return finance.interest * 1377 / 1000;
        }
        if(amount>=(finance.maxAmountPerUser/10))
        {
            if(duration>=31536000)
                return finance.interest * 1881 / 1000;
            if(duration>=15552000)
                return finance.interest * 1610 / 1000;
            if(duration>=7776000)
                return finance.interest * 1392 / 1000;
            if(duration>=2592000)
                return finance.interest * 1190 / 1000;
        }
        if(amount>=(finance.maxAmountPerUser/100))
        {
            if(duration>=31536000)
                return finance.interest * 1463 / 1000;
            if(duration>=15552000)
                return finance.interest * 1317 / 1000;
            if(duration>=7776000)
                return finance.interest * 1201 / 1000;
            if(duration>=2592000)
                return finance.interest * 1095 / 1000;
        }
        
        
        if(duration>=31536000)
            return finance.interest * 1358 / 1000;
        if(duration>=15552000)
            return finance.interest * 1218 / 1000;
        if(duration>=7776000)
           return finance.interest * 1105 / 1000;
        if(duration>=2592000)
           return finance.interest ;

        return 0;
    }

    function _depositToken(address user,address token,uint256 amount,uint duration) private {
        TokenFinance storage finance=_tokenFinances[token];
        require(finance.maxAmountPerUser>=amount && finance.maxAmountPerUser>0,"AMOUNT ERROR");

        uint interest=getInterestRate(duration,token,amount);
        require(interest>0,"ERROR DURATION");

        finance.totalAmount += amount;

        require(finance.totalAmount<=finance.maxTotalAmount,"TOTAL AMOUNT ERROR");

        UserBalance storage balance=_userBalances[user][token];

        require(balance.start_time==0,"Current Deposited");

        balance.start_time=block.timestamp;
        balance.interest_rate=interest;
        balance.duration=duration;
        balance.amount=amount;
    }

    function depositHonor(uint256 amount,uint duration) public {
        IERC20(_honorToken).transferFrom(msg.sender,address(this),amount);

        _depositHonor(msg.sender, amount, duration);

        emit Deposit(msg.sender, _honorToken, amount, duration);
    }
    function _depositHonor(address user,uint256 amount,uint duration) private {
        
        TokenFinance storage finance=_tokenFinances[_honorToken];
        require(finance.maxAmountPerUser>=amount && finance.maxAmountPerUser>0,"AMOUNT ERROR");

        uint interest=getInterestRate(duration,_honorToken,amount);
        require(interest>0,"ERROR DURATION");

        finance.totalAmount += amount;

        require(finance.totalAmount<=finance.maxTotalAmount,"TOTAL AMOUNT ERROR");

        HonorBalance storage balance=_userHonorBalances[user];

        require(balance.start_time==0,"Current Deposited");

        balance.start_time=block.timestamp;
        balance.interest_rate=interest;
        balance.duration=duration;
        balance.amount=amount;
        balance.busdValue=_honorTreasure.getHonorBUSDValue(amount);
    }

    
    function depositToken(address token,uint256 amount,uint duration) public {

        IERC20(token).transferFrom(msg.sender,address(this),amount);

        _depositToken(msg.sender,token,amount,duration);

        if(token==_wethToken)
        {
            _honorTreasure.depositWETH(amount);
        }
        else
        {
            _honorTreasure.depositToken(token,amount);
        }
        

        emit Deposit(msg.sender,token,amount,duration);
    }

    function depositWETH(uint256 duration) public payable {
        uint256 amount=msg.value;

        if(amount!=0)
        {
            IWETH(_wethToken).deposit{ value: amount }();
        }

        require(IERC20(_wethToken).balanceOf(address(this))>=amount,"Not Deposit WETH");

        _depositToken(msg.sender,_wethToken,amount,duration);

        _honorTreasure.depositWETH(amount);

        emit Deposit(msg.sender,_wethToken,amount,duration);
    }

    function changeTimeToken(address token,uint256 addAmount,uint duration) public {
        UserBalance storage balance = _userBalances[msg.sender][token];
        require(balance.start_time>0,"NOT START");

        uint elapsedTime=block.timestamp - balance.start_time;

        uint remainTime=balance.duration - elapsedTime;

        require(duration>remainTime,"ERROR TIME");

        balance.start_time=0;

        TokenFinance storage finance=_tokenFinances[token];
        finance.totalAmount -=balance.amount;

        uint256 income=getIncome(balance.amount, elapsedTime, balance.interest_rate);

        uint256 amount=income + balance.amount;
        if(addAmount>0)
        {
            IERC20(token).transferFrom(msg.sender, address(this), addAmount);
            amount=amount.add(addAmount);
            if(token==_wethToken)
            {
                _honorTreasure.depositWETH(addAmount);
            }
            else
            {
                _honorTreasure.depositToken(token,addAmount);
            }
        }
        
        _depositToken(msg.sender, token, amount, duration);

        emit Deposit(msg.sender,token,amount,duration);

    }

    function changeTimeHonor(uint256 addAmount,uint duration) public {
        HonorBalance storage balance = _userHonorBalances[msg.sender];
        require(balance.start_time>0,"NOT START");

        uint elapsedTime=block.timestamp - balance.start_time;

        uint remainTime=balance.duration - elapsedTime;

        require(duration>remainTime,"ERROR TIME");

        balance.start_time=0;

        TokenFinance storage finance=_tokenFinances[_honorToken];
        finance.totalAmount -=balance.amount;

        uint256 income=getIncome(balance.busdValue, elapsedTime, balance.interest_rate);

        uint256 amount=_honorTreasure.getBUSDHonorValue(income + balance.busdValue);
        if(addAmount>0)
        {
            IERC20(_honorToken).transferFrom(msg.sender, address(this), addAmount);
            amount=amount.add(addAmount);

            _honorTreasure.depositHonor(addAmount);
        }
        
        _depositHonor(msg.sender, amount, duration);

        emit Deposit(msg.sender,_honorToken,addAmount,duration);

    }

    function getIncome(uint256 amount,uint256 duration,uint256 rate) public pure returns(uint256) {
        return amount.mul(duration).div(10**18).mul(rate);
    }

    function widthdraw(address token) public {
        UserBalance storage balance=_userBalances[msg.sender][token];
        require(balance.start_time>0,"Not Deposited");
        uint endtime=balance.start_time + balance.duration;
        require(endtime<=block.timestamp,"Not Time");

        uint256 duration=block.timestamp - balance.start_time;

        uint256 income=getIncome(balance.amount,duration,balance.interest_rate);
        uint256 lastBalance=balance.amount.add(income);
        
        if(token==_wethToken)
        {
            if(_honorTreasure.getWETHReserve()>=lastBalance)
            {
                _honorTreasure.widthdrawWETH(lastBalance,msg.sender);
            }
            else
            {
                uint256 count=getAwardHonorCount(_wethToken, lastBalance, income);
                
                _honorTreasure.widthdrawHonor(count,msg.sender);
                //Mint Honor
            }
        }
        else 
        {
            if(_honorTreasure.getTokenReserve(token)>=lastBalance)
            {
                _honorTreasure.widthdrawToken(token,lastBalance,msg.sender);
            }
            else
            {
                uint256 count=getAwardHonorCount(token, lastBalance, income);
                
                _honorTreasure.widthdrawHonor(count,msg.sender);
                //Mint Honor
            }
            
        }
        

        TokenFinance storage finance=_tokenFinances[token];
        finance.totalAmount=finance.totalAmount.sub(balance.amount);
        balance.amount=0;
        balance.duration=0;
        balance.start_time=0;
        balance.interest_rate=0;
        
        emit Widthdraw(msg.sender,token, lastBalance, duration);
        
    }

    function widthdrawHonor() public {
        HonorBalance storage balance=_userHonorBalances[msg.sender];
        require(balance.start_time>0,"NOT DEPOSITED");

        uint endtime=balance.start_time + balance.duration;
        require(endtime<=block.timestamp,"Not Time");

        uint256 duration=block.timestamp - balance.start_time;

        uint256 income=getIncome(balance.busdValue,duration,balance.interest_rate);
        uint256 lastBalance=balance.busdValue.add(income);
        uint256 count=_honorTreasure.getBUSDHonorValue(lastBalance);
        _honorTreasure.widthdrawHonor(count,msg.sender);

        TokenFinance storage finance=_tokenFinances[_honorToken];
        finance.totalAmount=finance.totalAmount.sub(balance.amount);
        balance.amount=0;
        balance.duration=0;
        balance.start_time=0;
        balance.interest_rate=0;
        balance.busdValue=0;
        
        emit Widthdraw(msg.sender,_honorToken, count, duration);
    }

    function getAwardHonorCount(address token,uint256 amount,uint256 income) public view returns(uint256) {
        uint256 incomeLast=income.mul(_awardInterest).div(100);
        uint256 amountLast=amount.sub(income).add(incomeLast);
        (uint256 tokenRes,uint256 honorRes) = _honorTreasure.getPairAllReserve(token, _honorToken);
        return amountLast.div(tokenRes).mul(honorRes);
    }

    function emergencyWidthdrawToken(address token) public {
        UserBalance storage balance=_userBalances[msg.sender][token];
        require(balance.start_time>0,"Not Deposited");
        (uint256 tokenRes,uint256 honorRes) = _honorTreasure.getPairAllReserve(token, _honorToken);
        uint256 amount=balance.amount.div(honorRes).mul(tokenRes);
        amount=amount * 9 / 10;
        _honorTreasure.widthdrawHonor(amount, msg.sender);

        balance.start_time=0;
        balance.amount=0;
        balance.interest_rate=0;
        balance.duration=0;
        emit Widthdraw(msg.sender,token,balance.amount,0);
    }
    function emergencyWidthdrawHonor() public {
        HonorBalance storage balance=_userHonorBalances[msg.sender];
        require(balance.start_time>0,"Not Deposited");

        uint256 amount=balance.busdValue * 9 / 10;

        uint256 honorAmount=_honorTreasure.getBUSDHonorValue(amount);

        _honorTreasure.widthdrawHonor(honorAmount, msg.sender);

        balance.start_time=0;
        balance.amount=0;
        balance.interest_rate=0;
        balance.duration=0;
        balance.busdValue=0;

        emit Widthdraw(msg.sender,_honorToken,honorAmount,0);   
        }
}