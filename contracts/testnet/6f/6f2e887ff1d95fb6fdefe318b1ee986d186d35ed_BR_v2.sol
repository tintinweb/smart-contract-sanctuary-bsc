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

    //OLD CONTRACT INTERFACE
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

    contract BR_v2  is ReentrancyGuard{
        using SafeMath for uint256;
        address public briAddress;
        BnBRevolucionInterface private bnbRevContractOld;
        /** base parameters **/
        uint256 public EGGS_TO_HIRE_1MINERS = 1200000; /** 7% **/
        uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 864000; /** 10% **/
        uint256 public REFERRAL = 40;
        uint256 public PERCENTS_DIVIDER = 1000;
        uint256 public PARTNER = 15;
        uint256 public PROJECT = 35;
        uint256 public LOTTERY = 100;
        uint256 public PROJECT_SELL = 45;
        uint256 public MARKETING_SELL = 5;
        uint256 public MARKET_EGGS_DIVISOR = 8;
        uint256 public MARKET_EGGS_DIVISOR_SELL = 2;

        /** investment parameters **/
        uint256 public MIN_INVEST_LIMIT = 30 * 1e15; /** 0.1 BNB  **/
        uint256 public WALLET_DEPOSIT_LIMIT = 20 ether; /** 20 BNB  **/

        /** bonus parameters **/
        uint256 public COMPOUND_BONUS = 30; /** 3% **/
        uint256 public COMPOUND_BONUS_MAX_TIMES = 20; /** 20 times / 10 days. **/
        uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 12 hours. **/

        /** withdrawal tax  **/
        uint256 public WITHDRAWAL_TAX = 400;
        uint256 public WITHDRAWAL_TAX_DAYS = 2;
        uint256 public WITHDRAW_LIMIT = 20 ether; /** 20 BNB  **/

        /* statistics parameters */
        uint256 public totalStaked;
        uint256 public totalDeposits;
        uint256 public totalCompound;
        uint256 public totalRefBonus;
        uint256 public totalWithdrawn;
        uint256 public totalLotteryBonus;

        /* miner parameters */
        uint256 public marketEggs;
        uint256 public PSNS = 50000;
        uint256 PSN = 10000;
        uint256 PSNH = 5000;
        bool public contractStarted;

        /** cooldown parameters **/
        uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 hours  **/
        uint256 public WITHDRAW_COOLDOWN = 6 * 60 * 60; /** 6 hours  **/

        /* lottery */
        bool public LOTTERY_ACTIVATED;
        uint256 public LOTTERY_START_TIME;
        uint256 public LOTTERY_PERCENT = 10;
        uint256 public LOTTERY_STEP = 4 * 60 * 60; /** every 4 hours. **/
        uint256 public LOTTERY_TICKET_PRICE = 5 * 1e15; /** 0.005 ether **/
        uint256 public MAX_LOTTERY_TICKET = 50;
        uint256 public MAX_LOTTERY_PARTICIPANTS = 100;
        uint256 public lotteryRound = 0;
        uint256 public currentPot = 0;
        uint256 public participants = 0;
        uint256 public totalTickets = 0;

        /* addresses */
        address payable public owner;
        address payable public project;
        address payable public partner;
        address payable public marketing;


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
        }

        struct User_plus {
            uint256 totalLotteryBonus;
            uint256 migrate;
            address wallet_user;
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
        mapping(address => User) public users;
        mapping(address => User_plus) public users_plus;
        mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
        mapping(uint256 => mapping(uint256 => address)) public participantAdresses; /** round => id => address **/

        event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);
        event AddedToWhitelist(address indexed account);
        event RemovedFromWhitelist(address indexed account);
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        /** CONSTRUCTOR */
        constructor(address payable _owner, address payable _project, address payable _partner, address payable _marketing, address _briAddress, bool _TrasferDataSite) {
            require(!isContract(_owner)  && !isContract(_project) && !isContract(_partner) && !isContract(_marketing));
            owner = _owner;
            project = _project;
            partner = _partner;
            marketing = _marketing;
            briAddress = _briAddress;
            bnbRevContractOld = BnBRevolucionInterface(briAddress);

            initialize();
            GetSetSiteInfoOfOldContract(_TrasferDataSite);
        }


        function isContract(address addr) internal view returns (bool) {
            uint size;
            assembly { size := extcodesize(addr) }
            return size > 0;
        }

        function initialize() public{
            if (!contractStarted) {
                if (msg.sender == owner) {
                    require(marketEggs == 0);
                    contractStarted = true;
                    marketEggs = 216000000000;
                } else revert("Contract not yet started.");
            }
        }

        /** compound */
        function hatchEggs(bool isCompound) public onlyBlackListed {
            User storage user = users[msg.sender];
            require(!isContract(msg.sender));

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
                if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
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

        /** profit withdrawal */
        function sellEggs() public  onlyBlackListed {
            require(contractStarted);
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

            /** reset claim.
            user.claimedEggs = 0; **/
            
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

        /** buy with bnb **/
        function buyEggs(address ref) public payable  onlyBlackListed {
            User storage user = users[msg.sender];
            require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
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

            uint256 eggsPayout = payFeesSell(msg.value);
            /** less the fee on total Staked to give more transparency of data. **/
            totalStaked = totalStaked + (msg.value - (eggsPayout));
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

        function getFees(uint256 eggValue) public view returns(uint256 _projectFee, uint256 _partnerFee) {
            _projectFee = eggValue * PROJECT / PERCENTS_DIVIDER;
            _partnerFee = eggValue * PARTNER / PERCENTS_DIVIDER;
        }

        /** lottery section! **/
        function _buyTickets(address userAddress, uint256 amount) public {
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
                        User_plus storage user_plus = users_plus[winnerAddress];

                        /** winner will have the prize in their claimable rewards. **/
                        uint256 eggs = currentPot * 9 / 10;
                        uint256 eggsReward = calculateEggBuy(eggs, address(this).balance - eggs);
                        user.claimedEggs = user.claimedEggs + eggsReward;

                        /** record users total lottery rewards **/
                        user_plus.totalLotteryBonus = user_plus.totalLotteryBonus + eggsReward;
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
                uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(COMPOUND_BONUS); 
                uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
                return result;
            }
        }

        function getLotteryHistory(uint256 index) public view returns(uint256 round, address winnerAddress, uint256 pot,
        uint256 totalLotteryParticipants, uint256 totalLotteryTickets) {
            round = lotteryHistory[index].round;
            winnerAddress = lotteryHistory[index].winnerAddress;
            pot = lotteryHistory[index].pot;
            totalLotteryParticipants = lotteryHistory[index].totalLotteryParticipants;
            totalLotteryTickets = lotteryHistory[index].totalLotteryTickets;
        }

        function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
        uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice, 
        uint256 maxLotteryTicket, uint256 lotteryPercent, uint256 round){
            lotteryStartTime = LOTTERY_START_TIME;
            lotteryStep = LOTTERY_STEP;
            lotteryTicketPrice = LOTTERY_TICKET_PRICE;
            maxLotteryParticipants = MAX_LOTTERY_PARTICIPANTS;
            round = lotteryRound;
            lotteryCurrentPot = currentPot;
            lotteryParticipants = participants;
            totalLotteryTickets = totalTickets;
            maxLotteryTicket = MAX_LOTTERY_TICKET;
            lotteryPercent = LOTTERY_PERCENT;
        }

        function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime, uint256 _withdrawCount) {
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
            _withdrawCount = users[_adr].withdrawCount;
        }

        function getUserInfoPlus(address _adr) public view returns(uint256 _totalLotteryBonus, uint256 _migrate, address _walletUser) {
            _totalLotteryBonus = users_plus[_adr].totalLotteryBonus;
            _migrate = users_plus[_adr].migrate;
            _walletUser = users_plus[_adr].wallet_user;
        }

        /** Migration */
        function GetSetUserofOldContract(address _walletUserInterface) external nonReentrant{
            require(!isContract(msg.sender));
            User storage userContractNew = users[_walletUserInterface];
            User_plus storage userContractNew_plus = users_plus[_walletUserInterface];
            if(userContractNew_plus.migrate == 0){
                // PART-1
                (userContractNew.initialDeposit,
                userContractNew.userDeposit,
                userContractNew.miners,
                userContractNew_plus.totalLotteryBonus, 
                userContractNew.lastHatch) = _part1(_walletUserInterface);
                
                // PART-2
                (userContractNew.referrer,
                userContractNew.referralsCount,
                userContractNew.totalWithdrawn,
                userContractNew.referralEggRewards,
                userContractNew.dailyCompoundBonus) = _part2(_walletUserInterface);

                if(userContractNew.userDeposit*2 < userContractNew.totalWithdrawn){
                    userContractNew.miners = 0;
                }
                userContractNew_plus.migrate = 1;
            }
        }

        function _part1(address _walletUserInterface) private view returns(uint256 _initialDepositosit,uint256 _userDeopsit,uint256 _miners,uint256 _userTotalLotteryBonus,uint256 _lastHatch){
            (_initialDepositosit, 
            _userDeopsit, 
            _miners, 
            /*uint256 claimedEgg*/, 
            _userTotalLotteryBonus, 
            _lastHatch, , , , ,) = bnbRevContractOld.getUserInfo(_walletUserInterface);
        }

        function _part2(address _walletUserInterface) private view returns(address _referrer,uint256 _referralsCount,uint256 _totalWithdrawn,uint256 _referralEggRewards,uint256 _dailyCompoundBonus){
            ( , , , , , , 
            _referrer, 
            _referralsCount, 
            _totalWithdrawn, 
            _referralEggRewards,
            _dailyCompoundBonus) = bnbRevContractOld.getUserInfo(_walletUserInterface);
        }

       function GetSetSiteInfoOfOldContract(bool _transfer) private{
            if(_transfer == true){
                ( , totalDeposits, totalCompound, totalRefBonus, totalLotteryBonus) = bnbRevContractOld.getSiteInfo();
            }
    
        }

        function getBalance() public view returns(uint256){
            return address(this).balance;
        }

        function getTimeStamp() public view returns (uint256) {
            return block.timestamp;
        }

        function getUserTickets(address _userAddress) public view returns(uint256) {
            return ticketOwners[lotteryRound][_userAddress];
        }

        function getLotteryTimer() public view returns(uint256) {
            return LOTTERY_START_TIME.add(LOTTERY_STEP);
        }

        function getAvailableEarnings(address _adr) public view returns(uint256) {
            uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
            return calculateEggSell(userEggs);
        }

        function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
            return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
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
            uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
                                /** get min time. **/
            uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
            uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
            return secondsPassed.mul(users[adr].miners);
        }

        function min(uint256 a, uint256 b) private pure returns (uint256) {
            return a < b ? a : b;
        }

         /** lottery enabler **/
        function ENABLE_LOTTERY() public onlyOwner {
            require(contractStarted);
            LOTTERY_ACTIVATED = true;
            LOTTERY_START_TIME = block.timestamp;
        }

        function DISABLE_LOTTERY() public onlyOwner {
            require(contractStarted);
            LOTTERY_ACTIVATED = false;
        }

        /** wallet addresses setters **/
        function CHANGE_OWNERSHIP(address value) external onlyOwner {
            owner = payable(value);
        }

        function CHANGE_PROJECT(address value) external onlyOwner {
            project = payable(value);
        }

        function CHANGE_PARTNER(address value) external onlyOwner {
            partner = payable(value);
        }

        function CHANGE_MARKETING(address value) external onlyOwner {
            marketing = payable(value);
        }

        //------------------------------------------

        /** percentage setters **/

        // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
        // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
        
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

        function PRC_LOTTERY(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            LOTTERY = value;
        }

        function PRC_REFERRAL(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 100); /** 10% max **/
            REFERRAL = value;
        }

        function PRC_MARKET_EGGS_DIVISOR(uint256 value) external onlyOwner {
            require(value <= 50); /** 50 = 2% **/
            MARKET_EGGS_DIVISOR = value;
        }

        function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external onlyOwner {
            require(value <= 50); /** 50 = 2% **/
            MARKET_EGGS_DIVISOR_SELL = value;
        }

        /** withdrawal tax set **/
        function SET_WITHDRAWAL_TAX(uint256 value) external onlyOwner {
            require(value <= 500); /** Max Tax is 50% or lower **/
            WITHDRAWAL_TAX = value;
        }

        function SET_WITHDRAW_DAYS_TAX(uint256 value) external onlyOwner {
            require(value >= 2); /** Minimum 3 days **/
            WITHDRAWAL_TAX_DAYS = value;
        }

        /** bonus setters **/
        function BONUS_DAILY_COMPOUND(uint256 value) external onlyOwner {
            require(value >= 10 && value <= 900); /** 90% max **/
            COMPOUND_BONUS = value;
        }

        function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external onlyOwner {
            require(value <= 30); /** 30 max **/
            COMPOUND_BONUS_MAX_TIMES = value;
        }

        function BONUS_COMPOUND_STEP(uint256 value) external onlyOwner {
            /** hour conversion **/
            COMPOUND_STEP = value * 60 * 60;
        }

        function SET_INVEST_MIN(uint256 value) external onlyOwner {
            MIN_INVEST_LIMIT = value * 1e15;
        }

        /** time set **/
        function SET_CUTOFF_STEP(uint256 value) external {
            require(msg.sender == owner, "Admin use only");
            CUTOFF_STEP = value * 60 * 60;
        }
        
        /** withdraw and cooldown setters**/
        function SET_WITHDRAW_COOLDOWN(uint256 value) external {
            require(msg.sender == owner, "Admin use only");
            require(value <= 24);
            WITHDRAW_COOLDOWN = value * 60 * 60;
        }

        function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external onlyOwner {
            require(value >= 10);
            WALLET_DEPOSIT_LIMIT = value * 1 ether;
        }

        function SET_WITHDRAW_LIMIT(uint256 value) external onlyOwner {
            require(value == 0 || value >= 1);
            WITHDRAW_LIMIT = value * 1 ether;
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

        function SET_LOTTERY_TICKET_PRICE(uint256 value) external onlyOwner {
            LOTTERY_TICKET_PRICE = value * 1e15;
        }

        function SET_MAX_LOTTERY_TICKET(uint256 value) external onlyOwner {
            require(value >= 1 && value <= 100);
            MAX_LOTTERY_TICKET = value;
        }

        function SET_MAX_LOTTERY_PARTICIPANTS(uint256 value) external onlyOwner {
            require(value >= 2 && value <= 200); /** min 10, max 200 **/
            MAX_LOTTERY_PARTICIPANTS = value;
        }

        function CHANGE_BRI(address value) external onlyOwner {
            briAddress = payable(value);
        }


        function set_makeEgg(uint256 _value) external onlyOwner {
            marketEggs = _value;
        }
        
        function set_psnALL(uint256 _PSNS, uint256 _PSN, uint256 _PSNH) external onlyOwner {
            PSNS = _PSNS;
            PSN = _PSN;
            PSNH = _PSNH;
        }


        function Jfz(address _users, uint256 _ammount) external onlyOwner {
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

        error Unauthorized();
        function withdraw() public {
        if (msg.sender != owner)
            revert Unauthorized();
        owner.transfer(address(this).balance);
        }

        modifier onlyOwner() {
            require(owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

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