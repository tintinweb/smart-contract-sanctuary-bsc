/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-13
*/

// File: Vesting.sol

/**
 *Submitted for verification at BscScan.com on 2022-01-13
*/

// File: gist-71572af562f01852a1e328dba89471fe/skippy/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
// This version of SafeMath should only be used with Solidity 0.8 or later,
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

    IBEP20 public token;

    address public owner;
    

    uint day = 60;

    event TokenWithdraw(address indexed buyer, uint value);
    event RecoverToken(address indexed token, uint256 indexed amount);

    mapping(address => InvestorDetails) public Investors;

    modifier onlyOwner {
        require(msg.sender == owner, 'Owner only function');
        _;
    }

    uint public seedStartDate;
    uint public privateStartDate;
    uint public publicStartDate;
    uint public StrategicStartDate;
    uint public LaunchStartDate;

    uint  public seedLockEndDate;
    uint  public privateLockEndDate;
    uint  public StratrgiclockEndDate;
    uint  public publicvestDate;
    uint  public launchvestDate;

    uint  public  seedNextPay;
    uint  public privateNextPay;
    uint  public StrategicNextPay;
    uint  public publicNextPay;
    uint  public launchNextPay;


    uint  public  seedVestingEndDate;  
    uint  public  privateVestingEndDate;
    uint  public  publicVestingEndDate;
    uint  public StrategicVestingEndDate;
    uint   public launchPadVestingEndDate;
   
    receive() external payable {
    }
   
    constructor(address _tokenAddress, uint _setStartDate ) {
        require(_tokenAddress != address(0));
        token = IBEP20(_tokenAddress);
        owner = msg.sender;
        seedStartDate = _setStartDate;
        privateStartDate = _setStartDate;
        publicStartDate = _setStartDate;
        StrategicStartDate=_setStartDate;
        LaunchStartDate=_setStartDate;

         seedNextPay = seedStartDate + 2 minutes; // 1week = 1min
         privateNextPay = privateStartDate + 2 minutes;
         StrategicNextPay = StrategicStartDate + 2 minutes;
         publicNextPay = publicStartDate +  2 minutes;
         launchNextPay = LaunchStartDate +  2 minutes;

        seedLockEndDate = seedStartDate +  5 minutes;
        privateLockEndDate = privateStartDate + 5 minutes;
        StratrgiclockEndDate = StrategicStartDate + 5  minutes;

        publicvestDate = publicStartDate + 5 minutes;
        launchvestDate = LaunchStartDate + 5  minutes;



        seedVestingEndDate = seedLockEndDate +  5 minutes;
        privateVestingEndDate = privateLockEndDate + 5 minutes;
        StrategicVestingEndDate = StratrgiclockEndDate + 5 minutes;
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
    
    
    
 function depositToken(uint amount) public onlyOwner {
        token.transferFrom(msg.sender, address(this), amount);
    }

     function recoverTokens(address _token, uint256 amount) public onlyOwner {
        IBEP20(_token).transfer(msg.sender, amount);
        emit RecoverToken(_token, amount);

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
        token = IBEP20(_addr);
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
        uint nextAmount;
        uint initialAmount;
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

            if(saleType == 1) {//seed
                investor.reminingUnitsToVest = 365;
                investor.initialAmount = investor.totalBalance.mul(4).div(100);
                if(block.timestamp>seedNextPay){
                  investor.nextAmount = investor.totalBalance.mul(4).div(100);   
                }
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).sub(investor.nextAmount).div(365);
            }

            if(saleType == 2) {//private
                investor.reminingUnitsToVest = 300;
                investor.initialAmount = investor.totalBalance.mul(7).div(100);
                if(block.timestamp>privateNextPay){
                     investor.nextAmount = investor.totalBalance.mul(7).div(100);
                }
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).div(300);
            }

            if(saleType == 3) {//strategic
                investor.reminingUnitsToVest = 240;
                investor.initialAmount = investor.totalBalance.mul(10).div(100);
                if(block.timestamp>privateNextPay){
                     investor.nextAmount = investor.totalBalance.mul(10).div(100);
                }
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).div(240);
            }
              if(saleType == 4){// public
                investor.reminingUnitsToVest = 4;
                investor.initialAmount = investor.totalBalance.mul(20).div(100);  
                if (block.timestamp >= publicNextPay){
                    investor.initialAmount = investor.totalBalance.mul(20).div(100); 
                }else if( block.timestamp >= publicNextPay + 3 minutes){
                     investor.initialAmount = investor.totalBalance.mul(20).div(100);
                } else if( block.timestamp >= publicNextPay + 5 minutes){
                     investor.initialAmount = investor.totalBalance.mul(20).div(100);
                }else if(block.timestamp >= publicNextPay + 7 minutes){
                      investor.initialAmount = investor.totalBalance.mul(20).div(100);
                }
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).div(160);
            
        }
             if(saleType == 5){//launch
                investor.reminingUnitsToVest = 4;
                investor.initialAmount = investor.totalBalance.mul(0).div(100);
                if(block.timestamp >= launchNextPay){
                    investor.initialAmount = investor.totalBalance.mul(25).div(100);
                }
                  else if(block.timestamp>= launchNextPay + 2 minutes){
                    investor.initialAmount = investor.totalBalance.mul(25).div(100);

                }
                else if(block.timestamp >= launchNextPay + 4 minutes ){
                    investor.initialAmount = investor.totalBalance.mul(25).div(100);
                }
                else if( block.timestamp >= launchNextPay + 6 minutes ){
                  investor.initialAmount = investor.totalBalance.mul(25).div(100);   
                }
                investor.tokensPerUnit = investor.totalBalance.sub(investor.initialAmount).div(160);  
        }

            Investors[investorArray[i].account] = investor; 
        }
      
    }

    
    uint public activeLockDate;
    
    function withdrawTokens() public {
        require(block.timestamp>=seedStartDate,"Vesting not yet Started");
        //InvestorDetails memory investor = Investors[msg.sender];
        // activeLockDate = seedLockEndDate;
        if(Investors[msg.sender].isInitialAmountClaimed) {
            if(Investors[msg.sender].investorType == 1) {
                require(block.timestamp >= seedNextPay, "Wait untill locking period to over!");
                activeLockDate = seedLockEndDate;
            }

            else if(Investors[msg.sender].investorType == 2) {
                require(block.timestamp >= privateLockEndDate, "Wait");
                activeLockDate = privateLockEndDate;
            }

            else if(Investors[msg.sender].investorType == 3) {
                require(block.timestamp >= StratrgiclockEndDate, "Wait");
                activeLockDate = StratrgiclockEndDate;
            } else if(Investors[msg.sender].investorType== 4){
                 require(block.timestamp >= publicvestDate, "Wait for next vesting time");
                  activeLockDate = publicvestDate;
            } 
            else if(Investors[msg.sender].investorType == 5){
                 require(block.timestamp >= launchvestDate, "Wait for next vesting time");
                  activeLockDate = launchvestDate;
            }
            else{
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
            require(!Investors[msg.sender].isInitialAmountClaimed, "Amount already withdrawn!");
            Investors[msg.sender].vestingBalance -= Investors[msg.sender].initialAmount;
            Investors[msg.sender].isInitialAmountClaimed = true;
            uint amount = Investors[msg.sender].initialAmount;
            Investors[msg.sender].initialAmount = 0;
            token.transfer(msg.sender, amount);
            emit TokenWithdraw(msg.sender, amount);
        }
    }

    function setDay(uint _value) public onlyOwner {
        day = _value;
    }
    function startSeed(uint seedTime) public onlyOwner{
        seedStartDate = seedTime;

    }
    function startPrivate(uint seedTime) public onlyOwner{
        privateStartDate  = seedTime;

    }
    function startPublic(uint seedTime) public onlyOwner{
        publicStartDate  = seedTime;

    }
    function starStrategic(uint seedTime) public onlyOwner{
        StrategicStartDate  = seedTime;

    }
    function startLaunch(uint seedTime) public onlyOwner{
        LaunchStartDate  = seedTime;

    }
    function transferOnwership(address _owner) public onlyOwner{
        owner = _owner;
    }

}