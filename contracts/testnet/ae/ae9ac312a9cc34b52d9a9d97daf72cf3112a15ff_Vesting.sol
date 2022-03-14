/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

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
    function transferFrom(
        address sender,
        address recipient,
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

// File: gist-71572af562f01852a1e328dba89471fe/skippy/SafeMath.sol



pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or la
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

// File: gist-71572af562f01852a1e328dba89471fe/Lockness/vesting-audit.sol




pragma solidity ^0.8.0;

contract Vesting {
    using SafeMath for uint256;

    IERC20 public token;

    address public owner;
    uint public startDate;

    uint day = 1 minutes;

    event TokenWithdraw(address indexed buyer, uint value);

    mapping(address => InvestorDetails) public Investors;

    modifier onlyOwner {
        require(msg.sender == owner, 'Owner only function');
        _;
    }

    uint public seedStartDate;
    uint public privateStartDate;
    uint public StrategyStartDate;


    uint public seedLockEndDate;
    uint public privateLockEndDate;
    uint public StrategyLockEndDate;

    uint public seedVestingEndDate;
    uint public privateVestingEndDate;
    uint public StrategyVestingEndDate;

    uint public seedNextPay;




   
    receive() external payable {
    }
   
    constructor(address _tokenAddress, uint _seedStartDate, uint _privateStartDate, uint _StrategyStartDate) {
        require(_tokenAddress != address(0));
        token = IERC20(_tokenAddress);
        owner = msg.sender;
        seedStartDate = _seedStartDate;
        privateStartDate = _privateStartDate;
        StrategyStartDate = _StrategyStartDate;
     


        seedNextPay = seedStartDate + 2 minutes; 

        seedLockEndDate = seedNextPay +  2 minutes ;
        privateLockEndDate = seedNextPay + 2  minutes;
        StrategyLockEndDate = seedNextPay +  2  minutes;

        seedVestingEndDate = seedLockEndDate + 10 minutes;
        privateVestingEndDate = privateLockEndDate + 10 minutes;
        StrategyVestingEndDate = StrategyLockEndDate + 10 minutes;


       
    }
    
    
    /* Withdraw the contract's BNB balance to owner wallet*/
    function extractBNB() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getInvestorDetails(address _addr) public view returns(InvestorDetails memory){
        return Investors[_addr];
    }

    
    function getContractTokenBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }
    
    
    /* 
        Transfer the remining token to different wallet. 
        Once the ICO is completed and if there is any remining tokens it can be transfered other wallets.
    */
    function transferToken(address _addr, uint value) public onlyOwner {
        require(value <= token.balanceOf(address(this)), 'Insufficient balance to withdraw');
        token.transfer(_addr, value);
    }

    /* Utility function for testing. The token address used in this ICO contract can be changed. */
    function setTokenAddress(address _addr) public onlyOwner {
        token = IERC20(_addr);
    }

    function setStartDate(uint _value) public onlyOwner {
        startDate = _value;
    }

    struct Investor {
        address account;
        uint amount;
        uint8 saleType;
    }

    struct InvestorDetails {
        uint totalBalance;
        uint timeDifference;
        uint lastVestedTime;
        uint reminingUnitsToVest;
        uint tokensPerUnit;
        uint vestingBalance;
        uint investorType;
        uint initialAmount;
        uint nextAmount;
        bool isInitialAmountClaimed;
    }


    function addInvestorDetails(Investor[] memory investorArray) public onlyOwner {
        require(investorArray.length <= 25, "Array length exceeding 25, You might probably run out of gas");
        for(uint16 i = 0; i < investorArray.length; i++) {
            InvestorDetails memory investor;
            uint8 saleType = investorArray[i].saleType;
            investor.totalBalance = investorArray[i].amount.mul(10 ** 18);
            investor.investorType = investorArray[i].saleType;
            investor.vestingBalance = investor.totalBalance;

            if(saleType == 1) {
                investor.reminingUnitsToVest = 10;
                investor.nextAmount = investor.totalBalance.mul(4).div(100);
                investor.initialAmount = investor.totalBalance.mul(4).div(100);
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).sub(investor.nextAmount).div(10);
            }

            if(saleType == 2) {
                investor.reminingUnitsToVest = 10;
                investor.nextAmount = investor.totalBalance.mul(7).div(100);
                investor.initialAmount = investor.totalBalance.mul(7).div(100);
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).sub(investor.nextAmount).div(10);
            }

            if(saleType == 3) {
                investor.reminingUnitsToVest = 10;
                investor.nextAmount = investor.totalBalance.mul(10).div(100);
                investor.initialAmount = investor.totalBalance.mul(10).div(100);
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).sub(investor.nextAmount).div(10);
            }
          

            Investors[investorArray[i].account] = investor; 
        }
    }

    uint public activeLockDate;
    
    function withdrawTokens() public {
       
        //InvestorDetails memory investor = Investors[msg.sender];
        // activeLockDate = seedLockEndDate;
        if(Investors[msg.sender].isInitialAmountClaimed) {
            if(Investors[msg.sender].investorType == 1) {
                require(block.timestamp >= seedLockEndDate, "Wait untill locking period to over!");
                activeLockDate = seedLockEndDate;
            }

            else if(Investors[msg.sender].investorType == 2) {
                require(block.timestamp >= privateLockEndDate, "Wait");
                activeLockDate = privateLockEndDate;
            }

            else if(Investors[msg.sender].investorType == 3) {
                require(block.timestamp >=StrategyLockEndDate, "Wait");
                activeLockDate = StrategyLockEndDate;
            } else {
                revert("Not an investor!");
            }
            
            /* Time difference to calculate the interval between now and last vested time. */
            uint timeDifference;
            if(Investors[msg.sender].lastVestedTime == 0) {
                require(activeLockDate > 0, "Active lockdate was zero");
                timeDifference = block.timestamp.sub(activeLockDate, "Sub error timedifference");
            } else {
                timeDifference = block.timestamp.sub(Investors[msg.sender].lastVestedTime, "sub error lastvested time difference");
            }
            
            /* Number of units that can be vested between the time interval */
            uint numberOfUnitsCanBeVested = timeDifference.div(day, "Div error no.of units can be vested");
            
            /* Remining units to vest should be greater than 0 */
            require(Investors[msg.sender].reminingUnitsToVest > 0, "All units vested!");
            
            /* Number of units can be vested should be more than 0 */
            require(numberOfUnitsCanBeVested > 0, "Please wait till next vesting period!");

            if(numberOfUnitsCanBeVested >= Investors[msg.sender].reminingUnitsToVest) {
                numberOfUnitsCanBeVested = Investors[msg.sender].reminingUnitsToVest;
            }
            
            /*
                1. Calculate number of tokens to transfer
                2. Update the investor details
                3. Transfer the tokens to the wallet
            */
           // Investors[msg.sender].tokensPerUnit =  Investors[msg.sender].vestingBalance.sub(Investors[msg.sender].initialAmount).div(10);
            uint tokenToTransfer = numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            uint reminingUnits = Investors[msg.sender].reminingUnitsToVest;
            uint balance = Investors[msg.sender].vestingBalance;
            Investors[msg.sender].reminingUnitsToVest -= numberOfUnitsCanBeVested;
            Investors[msg.sender].vestingBalance -= numberOfUnitsCanBeVested * Investors[msg.sender].tokensPerUnit;
            Investors[msg.sender].lastVestedTime = block.timestamp;
            if(numberOfUnitsCanBeVested == reminingUnits) { 
                token.transfer(msg.sender, balance);
                emit TokenWithdraw(msg.sender, balance);
            } else {
                token.transfer(msg.sender, tokenToTransfer);
                emit TokenWithdraw(msg.sender, tokenToTransfer);
            }  
        }
        else {
          //  if(Investors[msg.sender].investorType == 1  || Investors[msg.sender].investorType == 2 || Investors[msg.sender].investorType == 3 ||  Investors[msg.sender].investorType == 4){
           if(block.timestamp<seedNextPay){
           require(!Investors[msg.sender].isInitialAmountClaimed, "Amount already withdrawn!");
           require(Investors[msg.sender].initialAmount >0,"wait for next vest time ");
             uint amount = Investors[msg.sender].initialAmount;
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].initialAmount;
           Investors[msg.sender].initialAmount = 0 ; 
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);}
                else if(block.timestamp>= seedNextPay){
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].nextAmount;
            Investors[msg.sender].isInitialAmountClaimed = true;
            uint amount = Investors[msg.sender].nextAmount;
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);
                }
            }
            
        
    }

    function setDay(uint _value) public onlyOwner {
        day = _value;
    }

    function _seedStart(uint _setTime) public onlyOwner{
        seedStartDate = _setTime;
    }
     function _privateStart(uint _setTime) public onlyOwner{
        privateStartDate = _setTime;
    }
    function _strategicStart( uint _setTime) public onlyOwner{
        StrategyStartDate = _setTime;
    }

}