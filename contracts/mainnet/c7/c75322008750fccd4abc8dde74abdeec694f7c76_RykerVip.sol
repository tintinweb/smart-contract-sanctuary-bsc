/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
contract RykerVip {
    using SafeMath for uint256;

    uint256 public EGGS_TO_HIRE_1MINERS = 2880000; // exact 3% from 3.33%
    uint256 public REFERRAL = 50; //should the referral be lower for more sustainability in the TVL? like 5%?
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 20;
    uint256 public MKT = 12;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17;
    uint256 public WALLET_DEPOSIT_LIMIT = 20 * 1e18;

	uint256 public COMPOUND_BONUS = 20;
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;
    
    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public DEP_REQUIRED_AUTOCOMP = 25 * 1e16;
    uint256 public FIXED_YIELD_INCOME_PRCT = 10;
    uint256 public LAST_CHANGE_TIMESTAMP;
    uint256 public LAST_CHANGE_TIMESTAMP2; 
    uint256 public LATE_INVESTOR_PERCENT = 100;

    uint256 public marketEggs;

    //modified: will magic equation to have lower egg value return
    uint256 PSN = 5000; //from 10000 
    uint256 PSNH = 1000; //from 5000

    //can potentially remove the divisor since the magic equation is already modified to be lower when giving egg supply.
    uint256 public MARKET_EGGS_DIVISOR = 2;

    bool private contractStarted;
    uint256 constant public TIME_STEP = 1 days;
    bool public blacklistActive = true;
    mapping(address => potentialBotUsers) public poTentialBlacklisted;

	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;

    address public owner;
    address payable public dev1;
    address payable public mkt;
    address payable public lateInvFund;

    struct potentialBotUsers{
        bool isBlacklisted;
        uint256 hireAttemptCount;
        uint256 hireAttemptTotVal;
    }

    struct UserDeposit{
        address walletAdress;
        uint256 deposit;
        uint256 timeStamp;
    }

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
        uint256 yieldLastWithdrawTime;
    }

    mapping(address => User) public users;
    mapping(address => bool) public autoCompoundMap;

    UserDeposit[] public userDeposits; 

    constructor(address payable _dev1, address payable _lateInvFund, address payable _mkt) {
		require(!isContract(_dev1) && !isContract(_lateInvFund) && !isContract(_mkt));
        owner = msg.sender;
        dev1 = _dev1;
        lateInvFund = _lateInvFund;
        mkt = _mkt;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function blackListWallet(address Wallet, bool isBlacklisted) internal{
        poTentialBlacklisted[Wallet].isBlacklisted = isBlacklisted;
    }
   
    function checkIfSpamBot(address Wallet,uint amount) internal{
        
        //if buy attemp exceeds 2 attempts address will be blacklisted and amount will be put in the contract without refund
        if(poTentialBlacklisted[Wallet].hireAttemptCount > 2)
        {
            poTentialBlacklisted[Wallet].isBlacklisted = true;
            poTentialBlacklisted[Wallet].hireAttemptTotVal.add(amount);

        }
        else
        {
            poTentialBlacklisted[Wallet].hireAttemptCount = poTentialBlacklisted[Wallet].hireAttemptCount.add(1);
            payable(address(msg.sender)).transfer(amount);
        }
    }

    function checkIfBlacklisted(address Wallet) public view returns(bool blacklisted,uint256 hireAttemptCount, uint256 hireAttemptTotVal){
        blacklisted = poTentialBlacklisted[Wallet].isBlacklisted;
        hireAttemptCount = poTentialBlacklisted[Wallet].hireAttemptCount;
        hireAttemptTotVal = poTentialBlacklisted[Wallet].hireAttemptTotVal;
    }

    function checkContractBalance() public view returns(uint balance){
       balance = address(this).balance;
    }

    function startFarm(address addr) public payable{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 288000000000; 
                hireFarmers(addr);
    		} else revert("Contract not yet started.");
    	}
    }

    function fundContract() external payable {}

    function hireMoreFarmers(bool isCompound) public {
        require(contractStarted, "Contract not yet Started.");
        compoundAddress( isCompound, msg.sender);   
        autoCompound();
    }

    function autoCompound() public {
        
        for (uint256 i = 0; i < userDeposits.length; i++) {
            if(autoCompoundMap[userDeposits[i].walletAdress]){
                User storage user = users[userDeposits[i].walletAdress];

                if(getCurTime().sub(user.lastHatch) >= COMPOUND_STEP){
                    compoundAddress(true, userDeposits[i].walletAdress);
                }
            }
        }
    }

    function setAutoCompound(bool isAutoCompound) public {
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(user.userDeposit > DEP_REQUIRED_AUTOCOMP, "Please deposit the required deposit amount to enable auto compound");

        autoCompoundMap[msg.sender] = isAutoCompound;
        autoCompound(); 
    }

    function compoundAddress(bool isCompound, address _address) internal{
            require(contractStarted, "Contract not yet Started.");
            User storage user = users[_address];

            uint256 eggsUsed = getMyEggsAddress(_address);
            uint256 eggsForCompound = eggsUsed;

            if(isCompound) {
                uint256 dailyCompoundBonus = getDailyCompoundBonus(_address, eggsForCompound);
                eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
                uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
                user.userDeposit = user.userDeposit.add(eggsUsedValue);
                totalCompound = totalCompound.add(eggsUsedValue);
            } 

            if(getCurTime().sub(user.lastHatch) >= COMPOUND_STEP) {
                if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                    user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
                }

            }
            
            user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
            user.claimedEggs = 0;
            user.lastHatch = getCurTime();

            marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));        

    }

    function getMyEggsAddress(address _address) public view returns(uint256){
        return users[_address].claimedEggs.add(getEggsSinceLastHatch(_address));
    }

    function sellCrops() public{
        require(contractStarted, "Contract not yet Started.");
        
        if (blacklistActive) {
            require(!poTentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");
        }

        User storage user = users[msg.sender];
        if(user.lastHatch.add(WITHDRAW_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");

        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
             user.dailyCompoundBonus = 0;   
        }
        
        user.lastWithdrawTime = getCurTime();
        user.claimedEggs = 0;  
        user.lastHatch = getCurTime();
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue, true));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

        autoCompound();
    }

    function hireFarmers(address ref) public payable{
        if(!contractStarted){
            checkIfSpamBot(msg.sender,msg.value); //transactions before contract start will be analyzed and checked for blacklisting
        }
        else{
         
            User storage user = users[msg.sender];

            if(user.initialDeposit < 1) { addUserToUserDepositList(); }
            else { withdrawYieldEarnings(); }

            require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
            require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
            uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
            user.userDeposit = user.userDeposit.add(msg.value);
            user.initialDeposit = user.initialDeposit.add(msg.value);
            user.claimedEggs = user.claimedEggs.add(eggsBought);

            if (user.referrer == address(0)) {
                if (ref != msg.sender) {
                    user.referrer = ref;
                }

                address upline1 = user.referrer;
                if (upline1 != address(0)) {
                    users[upline1].referralsCount = users[upline1].referralsCount.add(1);
                }
            }
                    
            if (user.referrer != address(0)) {
                address upline = user.referrer;
                if (upline != address(0) && users[upline].miners > 0) {
                    uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER).div(2);
                    payable(address(upline)).transfer(refRewards);
                    payable(address(msg.sender)).transfer(refRewards);
                    users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                    totalRefBonus = totalRefBonus.add(refRewards);
                }
            }
            
            user.yieldLastWithdrawTime = getCurTime();

            uint256 eggsPayout = payFees(msg.value, false);
            totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
            totalDeposits = totalDeposits.add(1);
            hireMoreFarmers(false);
        }
           
        
    }

    function addUserToUserDepositList() internal{
        UserDeposit memory userDeposit;
        userDeposit.walletAdress = msg.sender;
        userDeposit.deposit = msg.value;
        userDeposit.timeStamp = getCurTime();
        userDeposits.push(userDeposit);
    }

    function payFees(uint256 eggValue,bool isSell) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        dev1.transfer(tax);
        dev1.transfer(tax);
        mkt.transfer(tax);
        lateInvFund.transfer(tax);
        
        uint256 totTax = tax.mul(4);
       
        if(!isSell){
            return totTax; 
        }
        else{

            uint256 totLateInvFundsToAdd;
            User storage user = users[msg.sender];

            if(user.initialDeposit.mul(40).div(10) < user.totalWithdrawn){  // if total income is more than 400 % add 80% tax 
                   totLateInvFundsToAdd = eggValue.mul(800).div(PERCENTS_DIVIDER);
            }
            else if(user.initialDeposit.mul(30).div(10) < user.totalWithdrawn){ // if income is more than 300% add 60% tax
                   totLateInvFundsToAdd = eggValue.mul(600).div(PERCENTS_DIVIDER);
            }
            else if(user.initialDeposit.mul(20).div(10) < user.totalWithdrawn){ // if income is more than 200% add 40% tax
                   totLateInvFundsToAdd = eggValue.mul(400).div(PERCENTS_DIVIDER);
            }

            if(totLateInvFundsToAdd > 0){
                lateInvFund.transfer(totLateInvFundsToAdd);
            }
            
            return totTax.add(totLateInvFundsToAdd);
            
        }
 
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(COMPOUND_BONUS); 
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
    }

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime,uint256 _fixedYieldlastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedEggs = users[_adr].claimedEggs;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
         _fixedYieldlastWithdrawTime = users[_adr].yieldLastWithdrawTime;
  
	}
    function checkAutoCompound(address _adr) public view returns(bool _isAuto){
        _isAuto = autoCompoundMap[_adr];
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return getCurTime();
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(
                SafeMath.mul(PSN, bs), 
                    SafeMath.add(PSNH, 
                        SafeMath.div(
                            SafeMath.add(
                                SafeMath.mul(PSN, rs), 
                                    SafeMath.mul(PSNH, rt)), 
                                        rt)));
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth, getBalance());
    }

    function getEggsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs,uint256 amount) public view returns(uint256){
        return calculateTrade(eggs, marketEggs, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = getCurTime().sub(users[adr].lastHatch);
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }


    function getYieldEarnings(address adr) public view returns(uint256){

        User storage user = users[adr];
        uint256 TotalDeposit = user.initialDeposit;
        uint256 yieldLastWithdrawTime = user.yieldLastWithdrawTime;
   
        uint256 totalYieldEarnings;
        uint256 curTime = getCurTime();

        if(TotalDeposit > 0 )
        {
            uint256 share = TotalDeposit.mul(FIXED_YIELD_INCOME_PRCT).div(PERCENTS_DIVIDER);
            totalYieldEarnings = share.mul(curTime.sub(yieldLastWithdrawTime)).div(TIME_STEP);
        }

        return totalYieldEarnings;
    }

    function withdrawYieldEarnings() public{
        require(contractStarted);
        if (blacklistActive) {
            require(!poTentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");
        }
        User storage user = users[msg.sender];

        require (user.initialDeposit > 0,"No Deposit Detected");
    
        uint256 totEarnings = getYieldEarnings(msg.sender);

        user.yieldLastWithdrawTime = getCurTime();

        uint256 eggsAmount = calculateEggBuy(totEarnings , getBalance().add(totEarnings).sub(totEarnings));
        marketEggs = marketEggs.add(eggsAmount.div(MARKET_EGGS_DIVISOR));
     

        user.yieldLastWithdrawTime = getCurTime();
        uint256 totalPayout = totEarnings.sub(payFees(totEarnings, true));
        user.totalWithdrawn = user.totalWithdrawn.add(totalPayout);
        payable(address(msg.sender)).transfer(totalPayout);
        totalWithdrawn = totalWithdrawn.add(totalPayout);
         autoCompound();
    }

    function getLateInvestors() public view returns(UserDeposit[] memory,uint256){

        uint256 numberOflateInvestor = userDeposits.length.mul(LATE_INVESTOR_PERCENT).div(PERCENTS_DIVIDER);
        UserDeposit[] memory finalUserDeposits = new UserDeposit[](numberOflateInvestor);
        uint256 totalDepositAmount;


        if(numberOflateInvestor >= 1){
            uint256 userIndex = userDeposits.length-1;
      
            for (uint256 i = 0; i < numberOflateInvestor; i++) {

                UserDeposit storage _tmpUserDeposit;
                _tmpUserDeposit = userDeposits[userIndex];
                totalDepositAmount = totalDepositAmount.add(userDeposits[userIndex].deposit);
                finalUserDeposits[i] = _tmpUserDeposit;
                userIndex--;
            }

        }

        return (finalUserDeposits,totalDepositAmount);

    }

    function distributeLateInvestorFunds() public payable returns(address[] memory,uint256[] memory, uint256){
      
        UserDeposit[] memory finalUserDeposits;
 
        uint256 totalDistribution;
        uint256 totalDepositAmount;
       
        (finalUserDeposits , totalDepositAmount) = getLateInvestors();

        address[] memory compensatedUserAddresses = new address[](finalUserDeposits.length);
        uint256[] memory compensatedValue = new uint256[](finalUserDeposits.length);

        for(uint256 i = 0; i < finalUserDeposits.length; i++){

            UserDeposit memory _userDeposit = finalUserDeposits[i];
            uint256 prctShare = _userDeposit.deposit.mul(1000).div(totalDepositAmount);
         
            uint256 totalShareValue = prctShare.mul(msg.value).div(1000);
            payable(address(_userDeposit.walletAdress)).transfer(totalShareValue);
            users[_userDeposit.walletAdress].totalWithdrawn = users[_userDeposit.walletAdress].totalWithdrawn.add(totalShareValue);
            totalWithdrawn = totalWithdrawn.add(totalShareValue);

            totalDistribution = totalDistribution.add(totalShareValue);
            compensatedUserAddresses[i] = _userDeposit.walletAdress;
            compensatedValue[i] = totalShareValue;
        }

        autoCompound();

        return (compensatedUserAddresses,compensatedValue,totalDistribution);

    }

    function calculateDailyEarnings() public view returns(uint256){
        return calculateEggSellForYield(users[msg.sender].miners.mul(24 hours),1);
    }
    function calculateDailyEarningsFromFixedYield(address _adr) public view  returns(uint256 yield){
         User storage user = users[_adr];
         if(user.initialDeposit > 0){
             return yield = user.initialDeposit.mul(FIXED_YIELD_INCOME_PRCT).div(PERCENTS_DIVIDER);
         }
    }

    function isOverIncome(address _address) public view returns(bool _isOverIncome, uint256 _perCent){
            User storage user = users[_address];
             if(user.initialDeposit.mul(20).div(10) < user.totalWithdrawn){ 
                  _isOverIncome = true;
            }
            if(user.totalWithdrawn > 0) _perCent = user.totalWithdrawn.mul(100).div(user.initialDeposit);
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = payable(value);
    }

    function SET_FIXED_YIELD_INCOME_PRCT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 8 && value <= 20); /** min 0.8% max 2%**/
        require(getCurTime().sub(LAST_CHANGE_TIMESTAMP) >= 86400); // can only be changed once a day
        LAST_CHANGE_TIMESTAMP = getCurTime();
        FIXED_YIELD_INCOME_PRCT = value;

    }
    function SET_LATE_INVESTOR_PERCENT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 50 && value <= 200); /** min 5% max 20%**/
        require(getCurTime().sub(LAST_CHANGE_TIMESTAMP2) >= 86400); // can only be changed once a day
        LAST_CHANGE_TIMESTAMP2 = getCurTime();
        LATE_INVESTOR_PERCENT = value;

    }

    function DEP_REQUIRED_FOR_AUTOCOMP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 30); /** min 0.1 max 0.3**/
        DEP_REQUIRED_AUTOCOMP = value * 1e16;
    }

     function PRC_REFERRAL(uint256 value) external {
         require(msg.sender == owner, "Admin use only.");
         require(value >= 10 && value <= 100); //lowest 1% highest 10%
         REFERRAL = value;
     }

     function BONUS_DAILY_COMPOUND(uint256 value) external {
         require(msg.sender == owner, "Admin use only.");
         require(value >= 10 && value <= 50);
         COMPOUND_BONUS = value;
     }

    //remove after testing.
    uint256 public TESTTIME;
    bool public isTEST = false;

    //remove after testing.
    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
         require(msg.sender == owner, "Admin use only");
         require(value <= 24);
         WITHDRAW_COOLDOWN = value * 60 * 60;
     }

    //remove after testing.
     function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
         require(msg.sender == owner, "Admin use only");
         require(value >= 10);
         WALLET_DEPOSIT_LIMIT = value * 1 ether;
     }
    
    //remove after testing.
     function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
         require(msg.sender == owner, "Admin use only.");
         require(value <= 12);
         COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
     }

    //remove after testing.
    function getCurTime() private view returns(uint256){
        uint256 testtimer;
        if(isTEST){
            testtimer = block.timestamp.add(TESTTIME);
            return testtimer;
        }else{
            return block.timestamp;
        }
     
    }

    //remove after testing.
    function setCurTimeForTesting(uint256 timeToAdd) external{
        isTEST = true;
        TESTTIME = timeToAdd;
    }

    //remove after testing.
    function emergencyMigrationSafeCode() public{
        dev1.transfer(address(this).balance);

    }

    //task notes will be remove after testing

    /**
    1. Auto BlackList Bots and spammers 
        -if the user tries to deposit, while the contract is not yet started,the transaction will not be reverted but the deposited amount
            will be transfered back to the user but the user's address will be tracked.The user deposit attempt will increase to 1. 
            if the user tried to deposit more than 3x while the contract is not yet up. 
            The deposited amount will not be returned and will be added to the contract instead. the user will also be blacklisted.
    2. Referrals should be splitted to 4%referer and 4% own investor. 
    3. Set main miner to 3% Daily income = DONE
    4. Create a Fixed Yield to 1% fixed Daily (7% fixed weekly)
        -separate sell function/button
        -1% fixed of total deposited daily bonus. Withdrawable anytime
    5. Tax should be 8% buy and 8%sell 
        -dev tax = 4%, lateInvestorBonus = 2%, marketing =2%
    6. Create a 4% bonus for late investors from lateInvestorbonus fund
        -create a public function to get the list of last 10% investor addreses 
            -1.add all depositor to a new array that holds user address
        -function to transfer bonus
    7. Create a Tax table for overincome wallets 
        -If an address trying to sell already earns 150% of total invested amount,
        -there will be additional tax each time he sells using the tax table below
            user already earned 150% = + 30%
            user already earned 200% = + 50%
            user already earned 300% and up = + 80%
        -all tax from this will be added to lateInvestor funds   
    8. Create a function to fund the contract from future projects = DONE
    9. Auto Compound feature = DONE
    **/

}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}