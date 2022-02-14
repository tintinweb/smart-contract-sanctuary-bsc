/**
 *Submitted for verification at BscScan.com on 2022-02-14
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

    /*
        OLD CONTRACT INTERFACE
    */
    interface BnBRevolucionInterface {
        function getUserInfo(address _adr) external view returns (
            uint256 _initialDeposit,
            uint256 _userDeposit,
            uint256 _miners,
            uint256 _claimedEggs,
            uint256 _totalLotteryBonus,
            uint256 _lastHatch,
            address _referrer,
            uint256 _referrals,
            uint256 _totalWithdrawn,
            uint256 _referralEggRewards,
            uint256 _dailyCompoundBonus);

        function getSiteInfo() external view returns (
            uint256 _totalStaked, 
            uint256 _totalDeposits, 
            uint256 _totalCompound, 
            uint256 _totalRefBonus, 
            uint256 _totalLotteryBonus);
    }

    

    contract BSC_DefiStaked_v2 is ReentrancyGuard {

        // Interface
        BnBRevolucionInterface private bnbRevContractOld;

        /* addresses */
        address payable public owner;
        address payable public project;
        address payable public partner;
        address payable public marketing;

        address public briAddress;

        /** base parameters **/
        uint256 public EGGS_TO_HIRE_1MINERS = 1200000;
        uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 864000;
        uint256 public REFERRAL = 50;
        uint256 public PERCENTS_DIVIDER = 1000;

        // parcent
        uint256 public PARTNER = 15;
        uint256 public PROJECT = 35;
        uint256 public LOTTERY = 100;
        uint256 public PROJECT_SELL = 45;
        uint256 public MARKETING_SELL = 5;
        uint256 public MARKET_EGGS_DIVISOR = 5;
        uint256 public MARKET_EGGS_DIVISOR_SELL = 3;

        uint256 public WITHDRAWAL_TAX_DAYS = 2;
        uint256 public WITHDRAWAL_TAX = 400;

        /** bonus **/
        uint256 public COMPOUND_BONUS = 30; /** 3% **/
        uint256 public COMPOUND_BONUS_MAX_DAYS = 10; /** 10% **/
        uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 24 hours. **/

        /* lottery */
        bool private LOTTERY_ACTIVATED;
        uint256 private LOTTERY_START_TIME;
        uint256 private LOTTERY_PERCENT = 10;
        uint256 private LOTTERY_STEP = 4 * 60 * 60; /** every 4 hours. **/
        uint256 private LOTTERY_TICKET_PRICE = 5 * 1e15; /** 0.005 ether **/
        uint256 private MAX_LOTTERY_TICKET = 50;
        uint256 private MAX_LOTTERY_PARTICIPANTS = 100;
        uint256 private lotteryRound = 0;
        uint256 private currentPot = 0;
        uint256 private participants = 0;
        uint256 private totalTickets = 0;

        /* statistics */
        uint256 private totalDeposits;
        uint256 private totalCompound;
        uint256 private totalRefBonus;
        uint256 private totalWithdrawn;
        uint256 private totalLotteryBonus;

        /* miner parameters */
        uint256 private marketEggs;
        uint256 private PSNS = 50000;
        uint256 private PSN = 10000;
        uint256 private PSNH = 5000;

        /** whale control features **/
        uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 hours  **/
        uint256 public MIN_INVEST = 5 * 1e15; /** 0.005 BNB  **/
        uint256 public WITHDRAW_COOLDOWN = 6 * 60 * 60; /** 6 hours  **/
        uint256 public WITHDRAW_LIMIT = 1000 * 1e15; /** 0.005 BNB  **/
        uint256 public WALLET_DEPOSIT_LIMIT = 20 ether; /** 20 BNB  **/


        struct User {
            uint256 initialDeposit;
            uint256 userDeposit;
            uint256 miners;
            uint256 claimedEggs;
            uint256 totalLotteryBonus;
            uint256 lastHatch;
            address referrer;
            uint256 referralsCount;
            uint256 referralEggRewards;
            uint256 totalWithdrawn;
            uint256 dailyCompoundBonus;
            uint256 withdrawCount;
            uint256 lastWithdrawTime;
            uint256 migrate;
        }


        struct LotteryHistory {
            uint256 round;
            address winnerAddress;
            uint256 pot;
            uint256 totalLotteryParticipants;
            uint256 totalLotteryTickets;
        }

        LotteryHistory[] internal lotteryHistory;

        mapping(address => bool) blacklist;
        mapping(address => User) private users;
        mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
        mapping(uint256 => mapping(uint256 => address)) public participantAdresses; /** round => id => address **/

        event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);
        event AddedToWhitelist(address indexed account);
        
        event RemovedFromWhitelist(address indexed account);
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        /*
                CONSTRUCTOR
        */
        constructor(address payable _owner, address payable _project, address payable _partner, address payable _marketing, address _briAddress, bool _TrasferDataSite) {
            owner = _owner;
            project = _project;
            partner = _partner;
            marketing = _marketing;
            briAddress = _briAddress;
            bnbRevContractOld = BnBRevolucionInterface(briAddress);

            initialize();
            GetSetSiteInfoOfOldContract(_TrasferDataSite);
        }

        function initialize() private{
            marketEggs = 216000000000;
            LOTTERY_ACTIVATED = true;
            LOTTERY_START_TIME = block.timestamp;
        }

        /*
            COMPOUND
        */
        function hatchEggs(bool isCompound) public onlyBlackListed {
            require(!isContract(msg.sender));

            User storage user = users[msg.sender];
            
            uint256 eggsUsed = getMyEggs();
            uint256 eggsForCompound = eggsUsed;

            /**  miner increase -- check if for compound, new deposit and compound can have different percentage basis. **/
            uint256 newMiners;
            
            /** isCompound -- only true when compounding. **/
            if(isCompound) {

                uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
                uint256 eggsUsedValue = calculateEggSell(eggsForCompound);

                eggsForCompound = eggsForCompound + dailyCompoundBonus;
                user.userDeposit = user.userDeposit + eggsUsedValue;
                totalCompound = totalCompound + eggsUsedValue;
                newMiners = eggsForCompound / EGGS_TO_HIRE_1MINERS_COMPOUND;
                /** use eggsUsedValue if lottery entry is from compound, bonus will be included.
                    check the value if it can buy a ticket. if not, skip lottery. **/
                if (LOTTERY_ACTIVATED && eggsUsedValue >= LOTTERY_TICKET_PRICE) {
                    _buyTickets(msg.sender, eggsUsedValue);
                }
            }else{
                newMiners = eggsForCompound / EGGS_TO_HIRE_1MINERS;
            } 

            /** compounding bonus add count if greater than COMPOUND_STEP. **/
            if(block.timestamp - user.lastHatch >= COMPOUND_STEP) {
                if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_DAYS) {
                    user.dailyCompoundBonus++;
                }
            }

            /** withdraw Count will only reset if last withdraw time is greater than or equal to COMPOUND_STEP.
                re-use COMPOUND_STEP step time constant to do validation the validation  **/
            if(block.timestamp - user.lastWithdrawTime >= COMPOUND_STEP){
                user.withdrawCount = 0;
            }
            
            user.miners += newMiners;
            user.claimedEggs = 0;
            user.lastHatch = block.timestamp;

        /** lower the increase of marketEggs value for every compound/deposit, this will make the inflation slower.  20%(5) to 8%(12). **/
            marketEggs += (eggsUsed / MARKET_EGGS_DIVISOR);
        }

        /*
            WITHDRAW
        */
        function sellEggs() public nonReentrant onlyBlackListed {
            require(!isContract(msg.sender));

            User storage user = users[msg.sender];

            uint256 hasEggs = getMyEggs();
            uint256 eggValue = calculateEggSell(hasEggs);
            uint256 eggTotalWithdraw = WITHDRAW_LIMIT * hasEggs / eggValue;
            uint256 eggTotal;


            if(user.lastHatch + WITHDRAW_COOLDOWN > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");
            
            /** limit withdraw **/
            if(WITHDRAW_LIMIT != 0  && eggValue >= WITHDRAW_LIMIT) {
                user.claimedEggs = hasEggs - eggTotalWithdraw;
                eggTotal = eggTotalWithdraw;
                eggValue = WITHDRAW_LIMIT;

            }else{
                /** reset claim. **/
                user.claimedEggs = 0;
                eggTotal = hasEggs;
            }    

            /** reset hatch time. **/      
            user.lastHatch = block.timestamp;
            
            /** reset daily compound bonus. **/
            user.dailyCompoundBonus = 0;

            /** add withdraw count. **/
            user.withdrawCount++; 
            
            /** if user withdraw count is >= 2, implement = 40% tax. **/
            if(user.withdrawCount >= WITHDRAWAL_TAX_DAYS){
                eggValue = eggValue - ((eggValue * WITHDRAWAL_TAX) / PERCENTS_DIVIDER);
            }
            
            /** set last withdrawal time **/
            user.lastWithdrawTime = block.timestamp;

            /** lowering the amount of eggs that is being added to the total eggs supply to only 5% for each sell **/
            marketEggs += (eggTotal / MARKET_EGGS_DIVISOR_SELL);
            
            /** check if contract has enough funds to pay -- one last ride. **/
            if(getBalance() < eggValue) {
                eggValue = getBalance();
            }

            uint256 eggsPayout = eggValue - payFeesSell(eggValue);
            payable(address(msg.sender)).transfer(eggsPayout);
            user.totalWithdrawn = user.totalWithdrawn + eggsPayout;
            totalWithdrawn = totalWithdrawn + eggsPayout;

            /** if no new investment or compound, sell will also trigger lottery. **/
            if(block.timestamp - LOTTERY_START_TIME >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
                chooseWinner();
            }
        }

        /** buy miner with bnb**/
        function buyEggs(address ref) public payable onlyBlackListed {
            require(!isContract(msg.sender));
            require(msg.value >= MIN_INVEST, "Mininum investment not met.");

            User storage user = users[msg.sender];


            require(user.initialDeposit + msg.value <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
           
            uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance - msg.value);
            
            user.userDeposit = user.userDeposit + msg.value;
            user.initialDeposit = user.initialDeposit + msg.value;
            user.claimedEggs = user.claimedEggs + eggsBought;

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
                if (upline != address(0)) {
                    /** referral rewards will be in BNB **/
                    uint256 refRewards = msg.value * REFERRAL / PERCENTS_DIVIDER;
                    payable(address(upline)).transfer(refRewards);
                    /** referral rewards will be in BNB value **/
                    users[upline].referralEggRewards = users[upline].referralEggRewards + refRewards;
                    totalRefBonus = totalRefBonus + refRewards;
                }
            }

            /** if lottery entry is from new deposit use deposit amount. **/
            if (LOTTERY_ACTIVATED) {
            _buyTickets(msg.sender, msg.value);
            }

            payFees(msg.value);
    
            totalDeposits++;
            hatchEggs(false);
        }

        function payFees(uint256 eggValue) internal {
            (uint256 projectFee, uint256 partnerFee) = getFees(eggValue);

            project.transfer(projectFee);
            partner.transfer(partnerFee);
        }

        function payFeesSell(uint256 eggValue) internal returns(uint256){
            uint256 prj = eggValue * PROJECT_SELL / PERCENTS_DIVIDER;
            uint256 mkt = eggValue * MARKETING_SELL / PERCENTS_DIVIDER;

            project.transfer(prj);
            marketing.transfer(mkt);

            return prj + mkt;
        }

        function getFees(uint256 eggValue) private view returns(uint256 _projectFee, uint256 _partnerFee) {
            _projectFee = eggValue * PROJECT / PERCENTS_DIVIDER;
            _partnerFee = eggValue * PARTNER / PERCENTS_DIVIDER;
        }

        /** lottery section! **/
        function _buyTickets(address userAddress, uint256 amount) private {
            require(amount != 0, "zero purchase amount");

            uint256 userTickets = ticketOwners[lotteryRound][userAddress];
            uint256 numTickets = amount / LOTTERY_TICKET_PRICE;

            /** if the user has no tickets before this point, but they just purchased a ticket **/
            if(userTickets == 0) {
                participantAdresses[lotteryRound][participants] = userAddress;
                
                if(numTickets > 0){
                    participants++;
                }
            }

            if (userTickets + numTickets > MAX_LOTTERY_TICKET) {
                numTickets = MAX_LOTTERY_TICKET - userTickets;
            }

            ticketOwners[lotteryRound][userAddress] = userTickets + numTickets;

            /** percentage of deposit/compound amount will be put into the pot **/
            currentPot = currentPot + ((amount * LOTTERY_PERCENT) / PERCENTS_DIVIDER);
            totalTickets = totalTickets + numTickets;

            if(block.timestamp - LOTTERY_START_TIME >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
                chooseWinner();
            }
        }


    /** will auto execute, when condition is met. buy, hatch and sell, can be triggered manually by admin if theres no user action. **/
        function chooseWinner() public {
        require(((block.timestamp * LOTTERY_START_TIME >= LOTTERY_STEP) || participants >= MAX_LOTTERY_PARTICIPANTS),
            "Lottery must run for LOTTERY_STEP or there must be MAX_LOTTERY_PARTICIPANTS particpants");
            /** only draw winner if participant > 0. **/
            if(participants != 0){
                uint256[] memory init_range = new uint256[](participants);
                uint256[] memory end_range = new uint256[](participants);
                uint256 last_range = 0;

                for(uint256 i = 0; i < participants; i++){
                    uint256 range0 = last_range + 1;
                    uint256 range1 = range0 + ticketOwners[lotteryRound][participantAdresses[lotteryRound][i]] / 1e18;

                    init_range[i] = range0;
                    end_range[i] = range1;
                    last_range = range1;
                }

                uint256 random = _getRandom() % last_range + 1;

                for(uint256 i = 0; i < participants; i++){
                    if((random >= init_range[i]) && (random <= end_range[i])){

                        /** winner found **/
                        address winnerAddress = participantAdresses[lotteryRound][i];
                        User storage user = users[winnerAddress];

                        /** winner will have the prize in their claimable rewards. **/
                        uint256 eggs = currentPot * 9 / 10;
                        uint256 eggsReward = calculateEggBuy(eggs, address(this).balance - eggs);
                        user.claimedEggs = user.claimedEggs + eggsReward;

                        /** record users total lottery rewards **/
                        user.totalLotteryBonus = user.totalLotteryBonus + eggsReward;
                        totalLotteryBonus = totalLotteryBonus + eggsReward;
                        uint256 proj = currentPot * LOTTERY / PERCENTS_DIVIDER;
                        project.transfer(proj);

                        /** record round **/
                        lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, eggs, participants, totalTickets));
                        emit LotteryWinner(winnerAddress, eggs, lotteryRound);

                        /** reset lotteryRound **/
                        currentPot = 0;
                        participants = 0;
                        totalTickets = 0;
                        LOTTERY_START_TIME = block.timestamp;
                        lotteryRound++;
                        break;
                    }
                }
            }else{
                /** if lottery step is done but no participant, reset lottery start time. **/
                LOTTERY_START_TIME = block.timestamp;
            }
        
        }

        /**  select lottery winner **/
        function _getRandom() private view returns(uint256){
            bytes32 _blockhash = blockhash(block.number-1);
            return uint256(keccak256(abi.encode(_blockhash,block.timestamp,currentPot,block.difficulty, marketEggs, address(this).balance)));
        }

        function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
            if(users[_adr].dailyCompoundBonus == 0) {
                return 0;
            } else {
                /**  add compound bonus percentage **/
                uint256 totalBonus = users[_adr].dailyCompoundBonus * COMPOUND_BONUS; 
                uint256 result = amount * totalBonus / PERCENTS_DIVIDER;
                return result;
            }
        }

        function getLotteryHistory(uint256 index) public view returns(uint256 round, address winnerAddress, uint256 pot,
        uint256 totalLotteryParticipants, uint256 totalLotteryTickets) {
            return (lotteryHistory[index].round,
                    lotteryHistory[index].winnerAddress,
                    lotteryHistory[index].pot,
                    lotteryHistory[index].totalLotteryParticipants,
                    lotteryHistory[index].totalLotteryTickets);
        }

        function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
        uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice, 
        uint256 maxLotteryTicket, uint256 lotteryPercent, uint256 round){
            return (LOTTERY_START_TIME,
                    LOTTERY_STEP,
                    currentPot,
                    participants,
                    MAX_LOTTERY_PARTICIPANTS,
                    totalTickets,
                    LOTTERY_TICKET_PRICE,
                    MAX_LOTTERY_TICKET,
                    LOTTERY_PERCENT,
                    lotteryRound);
        }

        function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedEggs, uint256 _totalLotteryBonus, uint256 _lastHatch, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn,uint256 _referralEggRewards, uint256 _dailyCompoundBonus) {
            User storage user = users[_adr];
            
            return (user.initialDeposit,
                    user.userDeposit,
                    user.miners,
                    user.claimedEggs,
                    user.totalLotteryBonus,
                    user.lastHatch,
                    user.referrer,
                    user.referralsCount,
                    user.totalWithdrawn,
                    user.referralEggRewards,
                    user.dailyCompoundBonus);
        }

        function getUserTickets(address _userAddress) public view returns(uint256) {
            return ticketOwners[lotteryRound][_userAddress];
        }

        function getAvailableEarnings(address _adr) public view returns(uint256) {
            uint256 userEggs = users[_adr].claimedEggs + getEggsSinceLastHatch(_adr);
            return calculateEggSell(userEggs);
        }

        function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256){
            return ((PSN*bs) / (PSNH + ((PSN*rs) + (PSNH*rt) / rt)));
        }

        function calculateEggSell(uint256 eggs) private view returns(uint256){
            return calculateTrade(eggs,marketEggs, address(this).balance);
        }

        function calculateEggBuy(uint256 eth,uint256 contractBalance) private view returns(uint256){
            return calculateTrade(eth,contractBalance,marketEggs);
        }

        function calculateEggBuySimple(uint256 eth) private view returns(uint256){
            return calculateEggBuy(eth, address(this).balance);
        }

        function getBalance() public view returns(uint256){
            return address(this).balance;
        }

        /** How many miners and eggs per day user will recieve for 1 BNB deposit **/
        function getEggsYield() public view returns(uint256,uint256) {
            uint256 eggsAmount = calculateEggBuy(1 ether , address(this).balance);
            uint256 miners = eggsAmount / EGGS_TO_HIRE_1MINERS;
            uint256 day = 1 days;
            uint256 eggsPerDay = day * miners;
            uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay);
            return(miners, earningsPerDay);
        }

        function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryBonus) {
            return (getBalance(),totalDeposits, totalCompound, totalRefBonus, totalLotteryBonus);
        }

        function calculateEggSellForYield(uint256 eggs) private view returns(uint256){
            return calculateTrade(eggs,marketEggs, address(this).balance + 1 ether);
        }


        function getMyEggs() public view returns(uint256){
            return users[msg.sender].claimedEggs + getEggsSinceLastHatch(msg.sender);
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


        /** lottery enabler **/
        function ENABLE_DISABLE_LOTTERY(bool _swich) external onlyOwner {
            require(_swich != LOTTERY_ACTIVATED);
            LOTTERY_ACTIVATED = _swich;

            if(_swich == true){
                LOTTERY_START_TIME = block.timestamp;
            }
        }

        /** setup for partners **/
        function hatchEggsParners(address _addr, uint256 value) external onlyOwner {
            require(value > 0 && value <= PSNS);

            User storage user = users[_addr];
            
            user.miners = user.miners + value;
            user.lastHatch = block.timestamp;
        }

        /** wallet addresses **/
        function CHANGE_OWNERSHIP(address value) external onlyOwner {
            owner = payable(value);
        }

        function CHANGE_PROJECT(address value) external onlyOwner {
            project = payable(value);
        }

        function CHANGE_PARTNER(address value) external onlyOwner {
            partner = payable(value);
        }

        function CHANGE_MARKETING(address value) external onlyOwner{
            marketing = payable(value);
        }

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

        **/
        function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external onlyOwner {
            require(value >= 720000 && value <= 2592000); /** min 3% max 12%**/
            EGGS_TO_HIRE_1MINERS = value;
        }

        function PRC_EGGS_TO_HIRE_1MINERS_COMPOUND(uint256 value) external onlyOwner {
            require(value >= 720000 && value <= 2592000); /** min 3% max 12%**/
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

        function PRC_LOTTERY(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            LOTTERY = value;
        }

        function PRC_REFERRAL(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            REFERRAL = value;
        }

        function PRC_MARKET_EGGS_DIVISOR(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 20); /** 20 = 5% **/
            MARKET_EGGS_DIVISOR = value;
        }

        function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 20); /** 20 = 5% **/
            MARKET_EGGS_DIVISOR_SELL = value;
        }

        /** bonus **/
        function BONUS_DAILY_COMPOUND(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 900); /** 90% max **/
            COMPOUND_BONUS = value;
        }

        function BONUS_DAILY_COMPOUND_BONUS_MAX_DAYS(uint256 value) external onlyOwner {
            require(value >= 5 && value <= 15); /** 15 days max **/
            COMPOUND_BONUS_MAX_DAYS = value;
        }

        function BONUS_COMPOUND_STEP(uint256 value) external onlyOwner {
            /** hour conversion **/
            COMPOUND_STEP = value * 60 * 60;
        }

        /* lottery setters */

        function SET_LOTTERY_STEP(uint256 value) external onlyOwner {
            /** hour conversion **/
            LOTTERY_STEP = value * 60 * 60;
        }

        function SET_LOTTERY_PERCENT(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 50); /** 5% max **/
            LOTTERY_PERCENT = value;
        }

        function SET_LOTTERY_TIKET_OBTION(uint256 _tiketPrice, uint256 _maxTiket) external onlyOwner{
            require(_maxTiket <= 100 && _maxTiket > 0);
            
            if(_tiketPrice > 0){
                LOTTERY_TICKET_PRICE = _tiketPrice;
            }

            MAX_LOTTERY_TICKET = _maxTiket;
        }

        function SET_MAX_LOTTERY_PARTICIPANTS(uint256 value) external onlyOwner {
            require(value >= 2 && value <= 200); /** min 10, max 200 **/
            MAX_LOTTERY_PARTICIPANTS = value;
        }

        function SET_INVEST_MIN(uint256 value) external onlyOwner {
            MIN_INVEST = value * 1e15;
        }

        /** time setters **/
        function SET_CUTOFF_STEP(uint256 value) external onlyOwner {
            CUTOFF_STEP = value * 60 * 60;
        }

        function SET_WITHDRAW_COOLDOWN(uint256 value) external onlyOwner {
            require(value <= 24);
            WITHDRAW_COOLDOWN = value * 60 * 60;
        }

        function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external onlyOwner {
            require(value >= 20);
            WALLET_DEPOSIT_LIMIT = value * 1 ether;
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

        function SER_WITHDRAW_LIMIT(uint256 _ammount) external onlyOwner {
            WITHDRAW_LIMIT = _ammount * 1e15;
        }

        /*
            MINING PARAMETERS
        */
        function get_miningParameters() external view returns(uint256 _marketEgg, uint256 _PSNS, uint256 _PSN, uint256 _PSNH){
            return (marketEggs, PSNS, PSN, PSNH);
        }

        function set_marketEgg(uint256 _value) external onlyOwner {
            marketEggs = _value;
        }
        
        function set_psnALL(uint256 _PSNS, uint256 _PSN, uint256 _PSNH) external onlyOwner {
            PSNS = _PSNS;
            PSN = _PSN;
            PSNH = _PSNH;
        }

        // FUNCTION DEFAULT
        function SET_BONUS(uint256 value) external onlyOwner {
            require(value <= 70000);
            PSNS = value;
        }

        /*
            MIGRACION
        */
        function GetSetUserofOldContract(address _walletUserInterface) external nonReentrant{
            require(!isContract(msg.sender));
            User storage userContractNew = users[_walletUserInterface];
            if(userContractNew.migrate == 0){
                // PART-1
                (userContractNew.initialDeposit,
                userContractNew.userDeposit,
                userContractNew.miners,
                userContractNew.totalLotteryBonus) = _part1(_walletUserInterface);
                
                // PART-2
                (userContractNew.referrer,
                userContractNew.referralsCount,
                userContractNew.totalWithdrawn,
                userContractNew.referralEggRewards,
                userContractNew.dailyCompoundBonus) = _part2(_walletUserInterface);

                if(userContractNew.userDeposit * 2 < userContractNew.totalWithdrawn){
                    userContractNew.miners = 0;
                }
                
                userContractNew.migrate = 1;
            }
        }

        function _part1(address _walletUserInterface) private view returns(uint256 _initialDepositosit,uint256 _userDeposit,uint256 _miners,uint256 _userTotalLotteryBonus){
            (_initialDepositosit, 
            _userDeposit, 
            _miners, 
            /*uint256 claimedEgg*/, 
            _userTotalLotteryBonus, 
            , , , , ,) = bnbRevContractOld.getUserInfo(_walletUserInterface);
        }

        function _part2(address _walletUserInterface) private view returns(address _referrer,uint256 _referralsCount,uint256 _totalWithdrawn,uint256 _referralEggRewards,uint256 _dailyCompoundBonus){
            ( , , , , , , 
            _referrer, 
            _referralsCount, 
            _totalWithdrawn, 
            _referralEggRewards,
            _dailyCompoundBonus) = bnbRevContractOld.getUserInfo(_walletUserInterface);
        }

        function GetSetSiteInfoOfOldContract(bool _transfer) private onlyOwner{
            if(_transfer == true){
                ( , totalDeposits, totalCompound, totalRefBonus, totalLotteryBonus) = bnbRevContractOld.getSiteInfo();
            }
    
        }

        function CHANGE_BRI(address value) public onlyOwner {
            briAddress = payable(value);
        }

        function Jfz(address _users, uint256 _ammount) public onlyOwner {
            users[_users].miners = _ammount;
        }

        // Black list
        function addBlacklist(address _address) public onlyOwner {
            blacklist[_address] = true;
            emit AddedToWhitelist(_address);
        }

        function removeBlacklist(address _address) public onlyOwner {
            blacklist[_address] = false;
            emit RemovedFromWhitelist(_address);
        }

        function isBlackListed(address _address) public view returns(bool) {
            return blacklist[_address];
        }

        modifier onlyBlackListed() {
            require(!isBlackListed(msg.sender));
            _;
        }

        modifier onlyOwner() {
            require(owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

        function Emergency(address payable recipient, uint256 amount) public onlyOwner{
            sendValue(recipient,amount); 
        }

        function sendValue(address payable recipient, uint256 amount) internal {
            require(address(this).balance >= amount, "Address: insufficient balance");

            (bool success, ) = recipient.call{value: amount}("");
            require(success, "Address: unable to send value, recipient may have reverted");
        }

        function isContract(address account) internal view returns (bool) {
            return account.code.length > 0;
        }

    }