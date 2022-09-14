/*
    2% fixed yield
    4x max income based on true deposits.
    2% referrer bonus, 2% referee cashback 

    Auto-Farming - 
        user can set what % to comp and what % to Withdraw min 20% compound
        user can set 2 config, 1 default, 1 secondary
        secondary compound will be triggered instead of default when number of trigger reached
        auto farming will be triggered every 24 hrs

    Manual Compounding - 100% compound
        - Compound Anytime

    Manual Withdrawal (80% withdraw -20% auto-compound)
        - Withdraw anytime.
        
    last deposit - 5% of every deposit, 
        - total pot will be splitted to 2, half is for the next round so that every round has a significant amount of rewards

    biggest buy - 5% of every deposit, 
        - total pot will be splitted to 2, half is for the next round so that every round has a significant amount of rewards
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Project63 is Context, Ownable {
    bool private projectInitialized;

    ERC20 public token = ERC20(0xc46CCBE42Afdf64cc4DA7e56DCd60eE9bF1B743B); //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

    /** contract percentage **/
    uint256 public referralPrc = 40;
    uint256 public fixedYieldIncomePrc = 20;

    /** taxes **/
    uint256 private marketingTax = 10;
    uint256 private developmentTax = 40;
    uint256 private incubatorFunds = 50;
    uint256 private overIncomeTax400Prc = 800;
    uint256 private compoundSustainabilityTax = 50;

    /** limits **/
    uint256 private minDeposit = 50 ether;
    uint256 private maxIncentiveBalance = 1000 ether;
    uint256 private maxWalletDepositLimit = 50000 ether;

    /** time steps **/
    uint256 private cutOffTimeStep = 48 hours;
    uint256 private lastDepositTimeStep = 2 hours;
    uint256 private biggestDepositTimeStep = 24 hours;   

    /** event start time **/
    uint256 public LAST_DEPOSIT_START_TIME;
    uint256 public BIGGEST_DEPOSIT_START_TIME;
      
    /** event enablers **/
    bool private LAST_DEPOSIT_ACTIVATED;
    bool private BIGGEST_DEPOSIT_ACTIVATED ;
    bool private AUTO_COMPOUND_ACTIVATED;
 
    uint256 public  lastDepositTotalPot = 0;
    uint256 public  currentLastDepositPot = 0;

    uint256 public  biggestDepositTotalPot = 0;
    uint256 public  currentBiggestDepositPot = 0;   

    uint256 private totalStaked;
    uint256 private totalUserDeposited;
    uint256 private totalCompound;
    uint256 private totalRefBonus;
    uint256 private totalWithdrawn;
    uint256 private totalLastDepositJackpot;

    uint256 public  currentBiggestBuyRound = 1; 
    uint256 public  currentLastBuyRound = 1; 
    uint256 public  currentBiggestDepositAmount;
    
    address public  potentialLastDepositWinner;
    address public  potentialBiggestDepositWinner;

    address private development;
    address private marketing;
    address private incubator;
    address private executor;

    using SafeMath for uint256;
    using SafeMath for uint8;

    struct userCompounded {
        address walletAdress;
        uint256 deposit;
        uint256 timeStamp;
    }

    struct User {
        uint256 initialDeposit;
        uint256 userCompounded;
        address referrer;
        uint256 referralsCount;
        uint256 referralBonus;
        uint256 totalReceived;
        uint256 userDefaultAutoTriggerCount;
        uint256 lastWithdrawTime;
        uint256 lastActionTime;
        uint256 firstInvestmentTime;
    }

    struct FarmingHistory{
        uint256 amount;
        uint256 compoundAmount;
        uint256 withdrawAmount;
        uint256 date;
    }

    mapping(address => User) public users;
    mapping(address => FarmingHistory[]) public farmingHistoryMap;
    mapping(uint256 => address) public poolTop;
    mapping(uint256 => mapping(address => uint256)) public totalDepositPool;
    
    //compound events
    event AutoCompoundEvent(address indexed _addr, uint256 drawTime,uint256 compoundPrc,uint256 withdrawPrc);

    //entry events
    event LastBuyEntryEvent(uint256 indexed round, address indexed userAddress, uint256 amountEntered, uint256 drawTime); 
    event BiggestBuyEntryEvent(uint256 indexed round, address indexed userAddress, uint256 amountEntered, uint256 drawTime); 

    //contest events
    event LastBuyEvent(uint256 indexed round, address indexed winner, uint256 amountRewards, uint256 drawTime); 
    event BiggestBuyEvent(uint256 indexed round, address indexed winner, uint256 amountRewards, uint256 drawTime); 
    
    constructor(address devt, address mkt, address inc) {
		require(!Address.isContract(devt)  && !Address.isContract(mkt)  && !Address.isContract(inc), "Not a valid user address.");
        development = devt;
        marketing   = mkt;
        incubator   = inc;
    }

    modifier isInitialized {
        require(projectInitialized, "Contract not yet Started.");
        _;
    }
    
    function getUserInitialDeposit(address addr) external view returns(uint256 _initialDeposit, uint256 _lastActionTime, uint256 _userDefaultAutoTriggerCount) {
        _initialDeposit = users[addr].initialDeposit;
        _lastActionTime = users[addr].lastActionTime;
        _userDefaultAutoTriggerCount = users[addr].userDefaultAutoTriggerCount;
    }

    function executeAutoCompound(address _addr, uint256 _compoundPrc,uint256 _withdrawPrc ) external isInitialized {
        require(msg.sender == executor, "Function can only be triggered by the executor.");
        require(AUTO_COMPOUND_ACTIVATED, "Auto Compound not Activated.");

        compoundWithdrawAddress( _addr , _compoundPrc , _withdrawPrc);
        emit AutoCompoundEvent(_addr, getCurrentTime(),_compoundPrc,_withdrawPrc);
    }

    function initializeGoLiveSettings(address addr, uint256 amount) public onlyOwner {
        require(!projectInitialized, "Contract already started.");
        projectInitialized = true; 
        LAST_DEPOSIT_ACTIVATED = true;
        BIGGEST_DEPOSIT_ACTIVATED = true;
        AUTO_COMPOUND_ACTIVATED = true;
        BIGGEST_DEPOSIT_START_TIME = getCurrentTime();
        LAST_DEPOSIT_START_TIME = getCurrentTime();
        invest(addr, amount);
    }

    function manualCompound() public isInitialized {
        require(projectInitialized, "Contract not yet Started.");
        require(users[msg.sender].initialDeposit > 0, "Not a depositor");
        compoundWithdrawAddress(msg.sender, 100, 0); 
    }

    function compoundWithdrawAddress( address _address, uint256 _compoundPrc, uint256 _withdrawPrc) internal {
        uint256 validPrcChk = _compoundPrc +  _withdrawPrc;
        require(validPrcChk == 100, "invalid percentages");

        User storage user = users[_address];
        uint256 finalCompoundPrc = _compoundPrc;
        uint256 finalWithdrawPrc = _withdrawPrc;
        uint256 totEarnings = getYieldEarnings(_address);
        user.lastActionTime = getCurrentTime();

        uint256 totCompoundEarnings;
        uint256 totWithdrawnEarnings;
        if (finalCompoundPrc > 0){
            totCompoundEarnings = totEarnings.mul(finalCompoundPrc).div(100);
            totCompoundEarnings = totCompoundEarnings.sub(totCompoundEarnings.mul(compoundSustainabilityTax).div(1000)); 
                 
            uint256 overincomeTax = getOverIncomeTax(_address,totCompoundEarnings);
            totCompoundEarnings =  totCompoundEarnings.sub(overincomeTax);

            user.userCompounded = user.userCompounded.add(totCompoundEarnings);
            // user.userDefaultAutoTriggerCount = user.userDefaultAutoTriggerCount.add(1);
            totalCompound = totalCompound.add(totCompoundEarnings);
        }

        if (finalWithdrawPrc > 0){
            uint256 withdrawAmount = totEarnings.mul(finalWithdrawPrc).div(100);
            totWithdrawnEarnings = withdrawEarnings(_address,  withdrawAmount);
        }

        farmingHistoryMap[_address].push(FarmingHistory(totEarnings,totCompoundEarnings,totWithdrawnEarnings,getCurrentTime()));

    }

    function withdrawEarningsManual() public {
        User storage user = users[msg.sender];
        require(projectInitialized, "Contract not yet Started.");
        require (user.initialDeposit > 0,"No Deposit Detected.");
        compoundWithdrawAddress(msg.sender, 20, 80); 
    }

    
    function withdrawEarnings(address _address, uint256 amount) internal returns(uint256) {
       
        uint256 totalPayout = amount.sub(payFees(_address,amount,true));
        users[_address].totalReceived =  users[_address].totalReceived.add(totalPayout);

        if(getContractBalance() < totalPayout) {
            totalPayout = getContractBalance();
        }

        totalWithdrawn = totalWithdrawn.add(totalPayout); 
        token.transfer(_address, totalPayout); 
        return totalPayout;
    }

    function invest(address ref, uint256 amount) public {
        require(!Address.isContract(msg.sender), "Not a user address.");
        require(projectInitialized, "Contract not yet Started.");

        token.transferFrom(address(msg.sender), address(this), amount);

        User storage user = users[msg.sender];
        
            bool isRedeposit;
            if(user.initialDeposit > 0) {
                isRedeposit = true;  
            }
         
            require(amount >= minDeposit, "Mininum investment not met.");
            require(user.initialDeposit.add(amount) <= maxWalletDepositLimit, "Max deposit limit reached.");
         
            if(isRedeposit){
                uint256 totEarnings = getYieldEarnings(msg.sender);
                uint256 totalPayout = totEarnings.sub(payFees(msg.sender,totEarnings, true));
                amount += totalPayout;
                totalCompound += totalPayout;
            }
            else{
                totalUserDeposited++; 
                user.firstInvestmentTime = block.timestamp;
            }

            user.userCompounded += amount;
            user.initialDeposit += amount;

            user.lastActionTime = getCurrentTime();

            uint256 netPayout = payFees(msg.sender, amount, false);
            totalStaked = totalStaked.add(amount.sub(netPayout));

            drawLastDepositWinner();
            lastDepositEntry(msg.sender, amount);
            
            drawBiggestDepositWinner();
            biggestDepositEntry(msg.sender, amount);
                
            if (user.referrer == address(0)) {
                if (ref != msg.sender) {
                    user.referrer = ref;
                }

                address upline1 = user.referrer;
                if (upline1 != address(0)) {
                    users[upline1].referralsCount++;
                }
            }
                    
            if (user.referrer != address(0)) {
                address upline = user.referrer;
                if (upline != address(0) && users[upline].initialDeposit > 0) {
                    uint256 referralRewards = amount.mul(referralPrc).div(1000).div(2);
             
                    token.transfer(upline, referralRewards);
                    token.transfer(msg.sender, referralRewards);

                    users[upline].referralBonus += referralRewards;
                    user.referralBonus += referralRewards;

                    users[upline].totalReceived += referralRewards;
                    user.totalReceived += referralRewards;

                    totalRefBonus += referralRewards;
                }
            }
    }

    function chooseWinners() external {
        require(msg.sender == executor || msg.sender == owner(), "Not Executor Address.");

        drawLastDepositWinner();
        drawBiggestDepositWinner();
    }   
  
    function checkWinnersTime() external view returns (bool) {
        bool isTimeForWinners;
    
        if(LAST_DEPOSIT_ACTIVATED && getCurrentTime().sub(LAST_DEPOSIT_START_TIME) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
            isTimeForWinners = true;
        }

        if(BIGGEST_DEPOSIT_ACTIVATED && getCurrentTime().sub(BIGGEST_DEPOSIT_START_TIME) >= biggestDepositTimeStep && currentBiggestDepositPot > 0 && potentialBiggestDepositWinner != address(0)) {
          isTimeForWinners = true;
        }

        return isTimeForWinners;
    }

    function lastDepositEntry(address userAddress, uint256 amount) private {
        if(!LAST_DEPOSIT_ACTIVATED || userAddress == owner()) return;

        uint256 share = amount.mul(50).div(1000);

        if(lastDepositTotalPot.add(share) > maxIncentiveBalance){       
            lastDepositTotalPot += maxIncentiveBalance.sub(lastDepositTotalPot);
        }
        else{
            lastDepositTotalPot += share;
        }
      
        currentLastDepositPot = lastDepositTotalPot.div(2);
        LAST_DEPOSIT_START_TIME = getCurrentTime();

        potentialLastDepositWinner = userAddress;
        emit LastBuyEntryEvent(currentLastBuyRound, potentialLastDepositWinner,  amount,  LAST_DEPOSIT_START_TIME); 
    }

    function drawLastDepositWinner() private {
        
        if(LAST_DEPOSIT_ACTIVATED &&
         getCurrentTime().sub(LAST_DEPOSIT_START_TIME) >= lastDepositTimeStep && 
         currentLastDepositPot > 0 && 
         potentialLastDepositWinner != address(0)) {


            uint256 reward = currentLastDepositPot;
            withdrawEarnings(potentialLastDepositWinner,reward);
            emit LastBuyEvent(currentLastBuyRound, potentialLastDepositWinner, reward, getCurrentTime());

            totalLastDepositJackpot += currentLastDepositPot;
            lastDepositTotalPot -= currentLastDepositPot;
            currentLastDepositPot = lastDepositTotalPot.div(2);
            potentialLastDepositWinner = address(0);
            currentLastBuyRound++; 
            LAST_DEPOSIT_START_TIME = getCurrentTime(); 
        }
        
    }

    function biggestDepositEntry(address userAddress, uint256 amount) private {

        uint256 share = amount.mul(50).div(1000);

        if(biggestDepositTotalPot.add(share) > maxIncentiveBalance){       
            biggestDepositTotalPot += maxIncentiveBalance.sub(biggestDepositTotalPot);
        }
        else{
            biggestDepositTotalPot += share;
        }

        currentBiggestDepositPot = biggestDepositTotalPot.div(2);

        if(BIGGEST_DEPOSIT_ACTIVATED && userAddress != owner()){
            if(amount>currentBiggestDepositAmount){
                currentBiggestDepositAmount = amount;
                potentialBiggestDepositWinner = userAddress;
                emit BiggestBuyEntryEvent(currentBiggestBuyRound, potentialBiggestDepositWinner, amount, getCurrentTime()); 
            }
        }
    }

    function drawBiggestDepositWinner() private {
        if(BIGGEST_DEPOSIT_ACTIVATED && 
        getCurrentTime().sub(BIGGEST_DEPOSIT_START_TIME) >= biggestDepositTimeStep &&
         currentBiggestDepositPot > 0 &&
          potentialBiggestDepositWinner != address(0)) {

            uint256 reward = currentBiggestDepositPot;
            withdrawEarnings(potentialBiggestDepositWinner, reward);

            emit BiggestBuyEvent(currentBiggestBuyRound, potentialBiggestDepositWinner, reward, getCurrentTime());

            biggestDepositTotalPot -= currentBiggestDepositPot;
            currentBiggestDepositPot = biggestDepositTotalPot.div(2);
            potentialBiggestDepositWinner = address(0);
            currentBiggestDepositAmount = 0;
            currentBiggestBuyRound++;
            BIGGEST_DEPOSIT_START_TIME = getCurrentTime(); 
        }
    }

    function payFees(address _address, uint256 amount, bool isSell) internal returns(uint256) {
        uint256 devtTax = amount.mul(developmentTax).div(1000);
        uint256 marketTax = amount.mul(marketingTax).div(1000);
        uint256 incFunds = amount.mul(incubatorFunds).div(1000);

        token.transfer(development, devtTax);
        token.transfer(marketing, marketTax);
        token.transfer(incubator, incFunds);
        
        uint256 totalTax =  devtTax.add(marketTax).add(incFunds);
       
        if(!isSell){
            return totalTax; 

        }else{
            uint256 amountAfterDevTax = amount.sub(totalTax);
 
            uint256 overIncomeTax = getOverIncomeTax(_address, amountAfterDevTax);
            return totalTax.add(overIncomeTax);
        }
    }
    
    function getOverIncomeTax(address userAddress, uint256 amount) private view returns (uint256 overIncomeTax) {
        User storage user = users[userAddress];
        
        uint256 overIncomeThresHold = user.initialDeposit.mul(40).div(10); // max income before over-income tax is x4 of real deposit.
        uint256 amtToBeTaxed;
        uint256 totalReceivedAndforWithdraw = user.totalReceived.add(amount);

        if( totalReceivedAndforWithdraw > overIncomeThresHold ){ 
            if(overIncomeThresHold > user.totalReceived){
                amtToBeTaxed = totalReceivedAndforWithdraw.sub(overIncomeThresHold);
                overIncomeTax = amtToBeTaxed.mul(overIncomeTax400Prc).div(1000);
            }else{
                overIncomeTax = amount.mul(overIncomeTax400Prc).div(1000);
            }
        }else{
            return 0;
        }
    }

    function getYieldEarnings(address adr) public view returns(uint256) {
        User storage user = users[adr];
        uint256 totalDeposit = user.userCompounded;
        uint256 lastActionTime = user.lastActionTime;
        uint256 curTime = getCurrentTime();
        uint256 dailyIncome = totalDeposit.mul(fixedYieldIncomePrc).div(1000);
        uint256 timeElapsed = curTime.sub(lastActionTime) > cutOffTimeStep ? cutOffTimeStep : curTime.sub(lastActionTime);
        uint256 totalYieldEarnings = totalDeposit > 0 ? dailyIncome.mul(timeElapsed).div(24 hours) : 0;
        return totalYieldEarnings;
    }

    function getUserFarmHistory(address _address ) view external returns(uint256[10] memory totalEarnings,  uint256[10] memory totCompoundAmount,  uint256[10] memory totWithdrawAmount,
	   uint256[10] memory date) {
   
        uint256 startingIndex = farmingHistoryMap[_address].length-1;    
        for(uint8 i = 0; i < 10; i++) {
            totalEarnings[i] = farmingHistoryMap[_address][startingIndex].amount;
		    totCompoundAmount[i] = farmingHistoryMap[_address][startingIndex].compoundAmount;
		    totWithdrawAmount[i] = farmingHistoryMap[_address][startingIndex].withdrawAmount;
		    date[i] = farmingHistoryMap[_address][startingIndex].date;
            if(startingIndex == 0) break;
            startingIndex--;
        }
	}

    function getUserInfo(address _adr) external view returns(uint256 _initialDeposit, uint256 _userCompounded, address _referrer, 
        uint256 _referrals, uint256 _totalReceived, uint256 _referralBonus, uint256 _userDefaultAutoTriggerCount, 
        uint256 _lastWithdrawTime,uint256 _fixedlastActionTime) {
        _initialDeposit = users[_adr].initialDeposit;
        _userCompounded = users[_adr].userCompounded;
        _referrer = users[_adr].referrer;
        _referrals = users[_adr].referralsCount;
        _totalReceived = users[_adr].totalReceived;
        _referralBonus = users[_adr].referralBonus;
        _userDefaultAutoTriggerCount = users[_adr].userDefaultAutoTriggerCount;
        _lastWithdrawTime = users[_adr].lastWithdrawTime;
        _fixedlastActionTime = users[_adr].lastActionTime;
	}
    
    function getContractBalance() public view returns(uint256) {
       return address(this).balance;
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLastDepositJackpot) {
        return (totalStaked, totalUserDeposited, totalCompound, totalRefBonus, totalLastDepositJackpot);
    }

    function calculateDailyEarningsFromFixedYield(address _adr) public view  returns(uint256 yield) {
        User storage user = users[_adr];
        if(user.userCompounded > 0){
            return yield = user.userCompounded.mul(fixedYieldIncomePrc).div(1000);
        }
    }

    /** biggest deposit rewards enabler **/
    function enableBiggestDeposit(bool value) external onlyOwner {
        require(projectInitialized, "Contract not yet Started.");

        drawBiggestDepositWinner();
        
        if(value){
            BIGGEST_DEPOSIT_ACTIVATED = true;
            BIGGEST_DEPOSIT_START_TIME = getCurrentTime();
        }
        else{
            drawBiggestDepositWinner();
            BIGGEST_DEPOSIT_ACTIVATED = false;                 
        }
    }

    /** last deposit rewards enabler **/
    function enableLastDeposit(bool value) external onlyOwner {
        require(projectInitialized, "Contract not yet Started.");

        drawLastDepositWinner();
        
        if(value){
            LAST_DEPOSIT_ACTIVATED = true;
            LAST_DEPOSIT_START_TIME = getCurrentTime();
        }
        else{
            LAST_DEPOSIT_ACTIVATED = false;                 
        }
    }
    
    /** auto compound enabler **/
    function enableAutoCompound(bool value) external onlyOwner {
        require(projectInitialized, "Contract not yet Started.");
        AUTO_COMPOUND_ACTIVATED = value;
    }

	function setExecutorAddress(address value) external onlyOwner {
        require(Address.isContract(value));
        executor = value;
    }

    function getCurrentTime() public view returns(uint256) {
            return block.timestamp;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

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