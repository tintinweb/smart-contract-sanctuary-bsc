/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract WordlCupMiner {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 constant firstlaunch = 1667149200; //fixed to October 30st, 2022
    uint256 constant voteLimitTime = 1669507199; // fixed to November 26st 23:59:59 gmt
    uint256 constant finalGameTime = 1671386400; // fixed to December 18st 18:00:00 gmt
   
    bool private contractStarted;    
    uint256 random_min = 0;
    uint256 random_max = 9;
    IERC20 public BUSD;
    bool private locked;

    //uint256 public MIN_INVEST = 50 ether; /** 50 BUSD  **/mainnet
    uint256 public MIN_INVEST = 1 ether; /** 1 BUSD  **/ //testnet
	//uint256 public ACTION_COOLDOWN = 86400; /** 24 hours  **/   mainnet
    uint256 public ACTION_COOLDOWN = 300; /** 5 mins  **/  //testnet
    uint256 public WALLET_DEPOSIT_LIMIT = 10000 ether; /** 10,000 BUSD  **/
    uint256 public REFERRAL = 80;  //
    uint256 public GOALS_TO_HIRE_1MINERS = 486000; // 16%
    uint256 public GOALS_BUSD = 100; // ammount of goals for 1 busd
    uint256 public goalsValue = GOALS_TO_HIRE_1MINERS * GOALS_BUSD; //GOALS_TO_HIRE_1MINERS * 100 
    uint256 public PERCENTS_DIVIDER = 1000;    
    uint256 public FEE = 60;                        // 6%
    uint256 public BONUS = 100; //10%  
    uint256 public MARKET_GOALS_DIVISOR = 20;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 7;

     /* addresses */
    address private owner;
    address private treasury;
    address private genesis;

     /* statistics */
     uint256 public totalStaked;
     uint256 public totalDeposits;
     uint256 public totalCompound;
     uint256 public totalRefBonus;
     uint256 public totalWithdrawn;
     uint256 public totalDripAirdropped;
     uint256 public totalLotteryMinerBonus;
     uint256 public totalTopDepositMinerBonus;

     bool public LOTTERY_ACTIVATED;
     bool public TOP_DEPOSIT_ACTIVATED;
     uint256 public LOTTERY_START_TIME;
     uint256 public TOP_DEPOSIT_START_TIME;
     uint256 public TOP_DEPOSIT_PERCENT = 50;
     uint256 public LOTTERY_PERCENT = 50;
     uint256 public LOTTERY_STEP = 86400; // 24 hrs
     //uint256 public TOP_DEPOSIT_STEP = 86400; // 24 hrs mainnnet
     uint256 public TOP_DEPOSIT_STEP = 1800; // 30 min  testnet
     uint256 public LOTTERY_TICKET_PRICE = 5 ether;
     uint256 public MAX_LOTTERY_TICKET = 20;
     uint256 public MAX_LOTTERY_PARTICIPANTS = 1000;
     uint256 public MAX_LOTTERY_POOL_PER_ROUND = 1000 ether;
     uint256 public lotteryRound = 0; //round will be same as index
     uint256 public currentPot = 0;
     uint256 public participants = 0;
     uint256 public totalTickets = 0;

      /* biggest deposit per day. */
    uint8[] public pool_bonuses;
    uint256 public pool_cycle = 1;
    uint256 public pool_balance;
    uint256 public max_pool_balance = 2000 ether; /** 2,000 BUSD  **/

     mapping(address => bool) private whitelisted;
     mapping(address => uint256) private buyCount;
     mapping(address => bool) private blacklisted;
     mapping(uint8 => address) public pool_top; 
     mapping(address => User) public users;
     mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
     mapping(uint256 => mapping(uint256 => address)) public participantAdresses; /** round => id => address **/
     mapping(uint256 => mapping(address => uint256)) public pool_users_deposits_sum; 
     event LotteryWinner(address indexed investor, uint256 pot, uint256 miner, uint256 indexed round);
     event PoolPayout(address indexed addr, uint256 amount);

     address public topDepositWinner;
     uint256 public topDepositWinnerDeps;

     uint256 public marketGoals = 259200000000; //:39 6646153846
     uint256 PSN = 10000;
     uint256 PSNH = 5000;

     uint256 public CUTOFF_STEP = 172800; /** 48 hours  **/

     struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedGoals;
        uint256 lottery_bonus_as_miners;
        uint256 lastCompound;        
        address referrer;
        uint256 referralsCount;
        uint256 referralGoalRewards;
        uint256 referralMinerRewards;
        uint256 totalWithdrawn;
        uint256 pool_bonus_as_miners;
        string selectedWorldCupWinner;
        uint256 dailyCompoundCount;
    }

    address [] public addresses;

    struct LotteryHistory {
        uint256 round;
        address winnerAddress;
        uint256 pot;
        uint256 miners;
        uint256 totalLotteryParticipants;
        uint256 totalLotteryTickets;
    }

    LotteryHistory[] internal lotteryHistory;

    constructor(address _treasury, address _genesis) {
		require(!isContract(_treasury) && !isContract(_genesis));
       // BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); mainnet
       BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); //testnet
        
       owner = msg.sender;
       treasury = _treasury;
       genesis = _genesis;

       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
       pool_bonuses.push(100);
    }

    function buyGOALS(address ref, uint256 amount) public nonReentrant {
        if(!contractStarted && msg.sender != genesis){
            if(buyCount[msg.sender] >= 25) //interacting to buy in the contract more than 2 times before launch will be blacklisted.
            {
                buyCount[msg.sender]++;
                blacklisted[msg.sender] = true;
            }
            else{   
                buyCount[msg.sender]++;
            }
        }
        else{
            User storage user = users[msg.sender]; 
            require(!blacklisted[msg.sender], "Address is blacklisted.");
            require(contractStarted || msg.sender == genesis); //genesis wallet will be funding and will eliminate early advantage.
            require(amount >= MIN_INVEST, "Mininum investment not met.");
            require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
            
            BUSD.safeTransferFrom(address(msg.sender), address(this), amount);
            
            if(user.initialDeposit < 1){ //new user! add count for new deposits only for precise record of data.
                totalDeposits++; 
                addresses.push(msg.sender);
                user.dailyCompoundCount = 0;
            }
            else{ //existing user - add the current yield to the total compound before adding new deposits for precise record of data.
                uint256 currEggsValue = calculateGoalsSell(getGoalsSinceLastCompound(msg.sender));
                user.userDeposit = user.userDeposit.add(currEggsValue);
                totalCompound = totalCompound.add(currEggsValue);
            }
            
            uint256 eggsBought = calculateGoalsBuy(amount);
            user.userDeposit = user.userDeposit.add(amount);
            user.initialDeposit = user.initialDeposit.add(amount);
            user.claimedGoals = user.claimedGoals.add(eggsBought);  
            
            if (LOTTERY_ACTIVATED) {
                if(getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_LOTTERY_POOL_PER_ROUND) {
                    chooseWinner();
                }
                _buyTickets(msg.sender, amount);
            }

            if (TOP_DEPOSIT_ACTIVATED) {
                if(getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
                    _drawDepositWinner();
                }
                _topDeposits(msg.sender, amount);
            }
            
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
                        uint256 refRewards = amount.mul(REFERRAL).div(PERCENTS_DIVIDER);
                        uint256 goalsReward = calculateGoalsBuy(refRewards);
                        uint256 minerRewards = goalsReward.div(GOALS_TO_HIRE_1MINERS);
                        users[upline].miners = users[upline].miners.add(minerRewards);
                        marketGoals = marketGoals.add(goalsReward.div(MARKET_GOALS_DIVISOR)); //fix inflation
                        users[upline].referralMinerRewards = users[upline].referralMinerRewards.add(minerRewards); //miner amount.
                        users[upline].referralGoalRewards = users[upline].referralGoalRewards.add(refRewards); //ether amount.
                        totalRefBonus = totalRefBonus.add(refRewards); //ether amount.
                    }
            }            

            uint256 goalsPayout = payFees(amount);
            totalStaked = totalStaked.add(amount.sub(goalsPayout));
            compoundGoals(false);
        }
    }

    function compoundGoals(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted || msg.sender == genesis);
       

        uint256 goalsUsed = getMyGoals();
        uint256 goalsForCompound = goalsUsed;
        if(isCompound) {
            if(user.lastCompound.add(ACTION_COOLDOWN) > block.timestamp) revert("Can only compound after action cooldown.");
            require(user.miners > 0, "Did not make a deposit yet");
            uint256 goalsUsedValue = calculateGoalsSell(goalsForCompound);
            user.userDeposit = user.userDeposit.add(goalsUsedValue);
            totalCompound = totalCompound.add(goalsUsedValue);          
	        
            if (LOTTERY_ACTIVATED && goalsUsedValue >= LOTTERY_TICKET_PRICE) {
                _buyTickets(msg.sender, goalsUsedValue);
            }

            if(TOP_DEPOSIT_ACTIVATED && getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
                _drawDepositWinner();
            }
            user.dailyCompoundCount = user.dailyCompoundCount.add(1); //adds compound
        }

        user.miners = user.miners.add(goalsForCompound.div(GOALS_TO_HIRE_1MINERS));
        user.claimedGoals = 0;
        user.lastCompound = getTimeStamp();
        marketGoals = marketGoals.add(goalsUsed.div(MARKET_GOALS_DIVISOR));
    }

    function sellGoals() public nonReentrant {
        require(contractStarted, "Contract is not Started.");
        require(msg.sender != genesis, "Genesis wallet is blocked from selling.");        
        User storage user = users[msg.sender];
        require(user.dailyCompoundCount >= COMPOUND_FOR_NO_TAX_WITHDRAWAL, "Not enought compounds.");
        uint256 hasGoals = getMyGoals();
        uint256 goalValue = calculateGoalsSell(hasGoals);

        if(user.lastCompound.add(ACTION_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");

        user.claimedGoals = 0;
        user.dailyCompoundCount = 0; // resets compound limit
        user.lastCompound = getTimeStamp();

        marketGoals = marketGoals.add(hasGoals.div(MARKET_GOALS_DIVISOR));
        
        if(getBalance() < goalValue) {
            goalValue = getBalance();
        }

        uint256 goalsPayout = goalValue.sub(payFees(goalValue));
        BUSD.safeTransfer(msg.sender, goalsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(goalsPayout);
        totalWithdrawn = totalWithdrawn.add(goalsPayout);

        if(LOTTERY_ACTIVATED && getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS) {
            chooseWinner();
        }

       if(TOP_DEPOSIT_ACTIVATED && getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
            _drawDepositWinner();
       }
    }  

    function random_number(uint minNumber, uint maxNumber) public view returns (uint amount) {
        amount = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number))) % (maxNumber-minNumber);
        amount = amount + minNumber;
        return amount;
   } 

    function _drawDepositWinner() private {
        
        TOP_DEPOSIT_START_TIME = getTimeStamp();
        uint256 random = random_number(random_min, random_max);        
        
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;  
            if (i == random){
                User storage user = users[pool_top[i]];                
                uint256 draw_amount = pool_users_deposits_sum[pool_cycle][pool_top[i]];  // get deposit ammout of winner  
                uint256 win = draw_amount.mul(pool_bonuses[i]) / 100;
                topDepositWinner = pool_top[i]; //write latest winner address
                topDepositWinnerDeps = win; //write latest winner amount
                uint256 goalsReward = calculateGoalsBuy(win);
                uint256 minerRewards = goalsReward.div(GOALS_TO_HIRE_1MINERS);
                user.miners = user.miners.add(minerRewards);
                marketGoals = marketGoals.add(goalsReward.div(MARKET_GOALS_DIVISOR));
                users[pool_top[i]].pool_bonus_as_miners += minerRewards; 
                totalTopDepositMinerBonus = totalTopDepositMinerBonus.add(minerRewards);
                pool_balance -= win;
                emit PoolPayout(pool_top[i], minerRewards); 
           }
        }

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
        pool_cycle++;    
    
    }

    function _topDeposits(address _addr, uint256 _amount) private {
        if(_addr == address(0) || _addr == owner) return;

	    uint256 pool_amount = _amount.mul(TOP_DEPOSIT_PERCENT).div(PERCENTS_DIVIDER);
		
        if(pool_balance.add(pool_amount) > max_pool_balance){   
            pool_balance += max_pool_balance.sub(pool_balance);
        }else{
            pool_balance += pool_amount;
        }

        pool_users_deposits_sum[pool_cycle][_addr] += _amount;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == _addr) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = _addr;
                break;
            }

            if(pool_users_deposits_sum[pool_cycle][_addr] > pool_users_deposits_sum[pool_cycle][pool_top[i]]) {
                for(uint8 j = i + 1; j < pool_bonuses.length; j++) {
                    if(pool_top[j] == _addr) {
                        for(uint8 k = j; k <= pool_bonuses.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(pool_bonuses.length.sub(1)); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }
                pool_top[i] = _addr;
                break;
            }
        }
    }

    function chooseWorldCupWinner(string memory winCountry) public nonReentrant {
        User storage user = users[msg.sender];
        bytes memory tempEmptyStringTest = bytes(user.selectedWorldCupWinner);
        require(contractStarted && tempEmptyStringTest.length == 0, "Already voted!");
        require(getTimeStamp() <= voteLimitTime, "To late to vote");
        user.selectedWorldCupWinner = winCountry;           
    }   

    function distributeWinnerRewards(string memory winCountry) public nonReentrant {     
        require(contractStarted && msg.sender == owner, "Admin use only."); 
        require(getTimeStamp() >= finalGameTime, "WorldCup is not over yet");
        for(uint8 i = 0; i < addresses.length; i++) {
            User storage user = users[addresses[i]]; 
            if(compareStrings(user.selectedWorldCupWinner, winCountry)){            
              user.miners = SafeMath.mul(user.miners, 2);
             }
        }
       
    }

    function distributeDailyRewards(string memory winMatchCountry) public nonReentrant {     
        require(contractStarted && msg.sender == owner, "Admin use only."); 
        for(uint8 i = 0; i < addresses.length; i++) {
            User storage user = users[addresses[i]]; 
            if(compareStrings(user.selectedWorldCupWinner, winMatchCountry)){       
              user.miners += ((user.miners * BONUS) / PERCENTS_DIVIDER); // default +10%
             }
        }
       
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
   
    function chooseWinner() private {
        if(participants > 0){
            uint256[] memory init_range = new uint256[](participants);
            uint256[] memory end_range = new uint256[](participants);

            uint256 last_range = 0;

            for(uint256 i = 0; i < participants; i++){
                uint256 range0 = last_range.add(1);
                uint256 range1 = range0.add(ticketOwners[lotteryRound][participantAdresses[lotteryRound][i]].div(1e18));

                init_range[i] = range0;
                end_range[i] = range1;
                last_range = range1;
            }

            uint256 random = _getRandom().mod(last_range).add(1);

            for(uint256 i = 0; i < participants; i++){
                if((random >= init_range[i]) && (random <= end_range[i])){

                    address winnerAddress = participantAdresses[lotteryRound][i];
                    User storage user = users[winnerAddress];

                    uint256 burnTax = currentPot.mul(100).div(PERCENTS_DIVIDER);
                    uint256 goals = currentPot.sub(burnTax);
                    uint256 goalsReward = calculateGoalsBuy(goals);
                    uint256 minerRewards = goalsReward.div(GOALS_TO_HIRE_1MINERS);
                    user.miners = user.miners.add(minerRewards);
                    marketGoals = marketGoals.add(goalsReward.div(MARKET_GOALS_DIVISOR));

                    user.lottery_bonus_as_miners = user.lottery_bonus_as_miners.add(minerRewards); 
                    totalLotteryMinerBonus = totalLotteryMinerBonus.add(minerRewards);

                    lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, goals, minerRewards, participants, totalTickets));
                    emit LotteryWinner(winnerAddress, goals, minerRewards, lotteryRound);

                    currentPot = 0;
                    participants = 0;
                    totalTickets = 0;
                    LOTTERY_START_TIME = getTimeStamp();
                    lotteryRound++;
                    break;
                }
            }
        }else{
            LOTTERY_START_TIME = getTimeStamp();
        }
    }

    function _buyTickets(address userAddress, uint256 amount) private {
        require(amount != 0, "zero purchase amount");
        uint256 userTickets = ticketOwners[lotteryRound][userAddress];
        uint256 numTickets = amount.div(LOTTERY_TICKET_PRICE);

        if(userTickets == 0) {
            participantAdresses[lotteryRound][participants] = userAddress;

            if(numTickets > 0){
              participants = participants.add(1);
            }
        }

        if (userTickets.add(numTickets) > MAX_LOTTERY_TICKET) {
            numTickets = MAX_LOTTERY_TICKET.sub(userTickets);
        }

        ticketOwners[lotteryRound][userAddress] = userTickets.add(numTickets);
        uint256 ticketAmount = amount.sub(payFees(amount)); //FEE
        uint256 addToPot = ticketAmount.mul(LOTTERY_PERCENT).div(PERCENTS_DIVIDER);

        if(currentPot.add(addToPot) > MAX_LOTTERY_POOL_PER_ROUND){       
            currentPot += MAX_LOTTERY_POOL_PER_ROUND.sub(currentPot);
        }
        else{
            currentPot += addToPot;
        }

        totalTickets = totalTickets.add(numTickets);
    }

    function calculateGoalsBuy(uint256 eth) public view returns(uint256) {
       // return calculateTrade(eth, contractBalance, marketGoals);
       return calculateTradeBuy(eth);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculateTradeBuy(uint256 amountBusd) public view returns(uint256) {
        return SafeMath.mul(SafeMath.div(amountBusd, 1000000000000000000), goalsValue);
    }

    function calculateTradeSell(uint256 amountGoals) public view returns(uint256) {
       return SafeMath.div(SafeMath.mul(amountGoals, 1000000000000000000), goalsValue);
    }

    function calculateGoalSellForYield(uint256 goals) public view returns(uint256){
        //return calculateTrade(goals,marketGoals, getBalance().add(amount));
        return calculateTradeSell(goals);
    }
    
    function calculateGoalsSell(uint256 goals) public view returns(uint256) {
       // return calculateTrade(goals, marketGoals, getBalance());
       return calculateTradeSell(goals);
    }

    function calculateGoalBuySimple(uint256 eth) public view returns(uint256) {
        return calculateGoalsBuy(eth);
    }

    function getBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
	}

    function getMyGoals() public view returns(uint256) {
        return users[msg.sender].claimedGoals.add(getGoalsSinceLastCompound(msg.sender));
    }

    function payFees(uint256 goalValue) internal returns(uint256) {
        (uint256 treasuryFee) = getFees(goalValue);
        BUSD.safeTransfer(treasury, treasuryFee);        
        return treasuryFee; // 5%
    }

    function getFees(uint256 goalValue) public view returns(uint256 _treasuryFee) {
        _treasuryFee = (goalValue.mul(FEE).div(PERCENTS_DIVIDER));       
    }

    modifier nonReentrant {
        require(!locked, "No re-entrancy.");
        locked = true;
        _;
        locked = false;
    }

    function getGoalsSinceLastCompound(address adr) public view returns(uint256) {
        uint256 secondsSinceLastCompound = getTimeStamp().sub(users[adr].lastCompound);
        uint256 cutoffTime = min(secondsSinceLastCompound, CUTOFF_STEP);
        uint256 secondsPassed = min(GOALS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }
    
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function activateLaunch() external {
        require(msg.sender == owner);
	    contractStarted = true;
	    TOP_DEPOSIT_ACTIVATED = true;
	    TOP_DEPOSIT_START_TIME = block.timestamp;
	   // whitelistActive = true;        
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function poolTopInfo() view external returns(address[10] memory addrs, uint256[10] memory deps) { // top 10 deposits
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            addrs[i] = pool_top[i];
            deps[i] = pool_users_deposits_sum[pool_cycle][pool_top[i]];
        }
    }

    function topDepositWinnerInfo() view external returns(address[1] memory addrs, uint256[1] memory deps) {
        addrs[0] = topDepositWinner;
        deps[0] = topDepositWinnerDeps;
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalTopDepositMinerBonus, uint256 _totalLotteryMinerBonus, uint256 _pool_balance, uint256 _pool_leader) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalTopDepositMinerBonus, totalLotteryMinerBonus, pool_balance, pool_users_deposits_sum[pool_cycle][pool_top[0]]);
    }

    function getMyMiners() public view returns(uint256) {
        return users[msg.sender].miners;
    }

    function PRC_GOALS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 486000 && value <= 2592000); /** min 3% max 16%**/
        GOALS_TO_HIRE_1MINERS = value;
        goalsValue = GOALS_TO_HIRE_1MINERS * GOALS_BUSD;
    }

    function VAR_GOALS_BUSD(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 1000); /** min 10 max 1000 **/
        GOALS_BUSD = value;
        goalsValue = GOALS_TO_HIRE_1MINERS * GOALS_BUSD;
    }

    function VAR_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 10);
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
    }

    function VAR_RANDOM_MAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value < 10);
        random_max = value;
    }  
    
    function VAR_BONUS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 50 && value <= 500); /** min 5% max 50% **/
        BONUS = value;
    }  
    
    function VAR_TOP_DEPOSIT_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 3600 && value <= 86400);
        TOP_DEPOSIT_STEP = value;
    }    
    
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }

    function ENABLE_TOP_DEPOSIT(bool value) public {
        require(msg.sender == owner, "Admin use only.");
        require(contractStarted);
                
        if (TOP_DEPOSIT_ACTIVATED) {
            if(getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP){
            _drawDepositWinner();
            }
        }
        
        if(value){
            TOP_DEPOSIT_ACTIVATED = true;   
            TOP_DEPOSIT_START_TIME = block.timestamp; //enabling the function will start a new start time.         
        }else{
            TOP_DEPOSIT_ACTIVATED = false;
        }
    }

    function ENABLE_LOTTERY(bool value) public {
        require(msg.sender == owner, "Admin use only.");
        require(contractStarted);
        if (LOTTERY_ACTIVATED) {
            if(getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_LOTTERY_POOL_PER_ROUND){
                chooseWinner();
            }
		}
        if(value){
            LOTTERY_ACTIVATED = true; 
            LOTTERY_START_TIME = block.timestamp; //enabling the function will start a new start time.           
        }else{
            LOTTERY_ACTIVATED = false;
        }
    }

    function runEvents() external {

        if (LOTTERY_ACTIVATED) {
            if(getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_LOTTERY_POOL_PER_ROUND){
                chooseWinner();
            }
		}

        if (TOP_DEPOSIT_ACTIVATED) {
            if(getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
                _drawDepositWinner();
            }
		}    
    }

    function _getRandom() private view returns(uint256){
        bytes32 _blockhash = blockhash(block.number-1);
        return uint256(keccak256(abi.encode(_blockhash,getTimeStamp(),currentPot,block.difficulty, marketGoals, getBalance())));
    }

    function getLotteryHistory(uint256 index) public view returns(uint256 round, address winnerAddress, uint256 pot, uint256 miners,
        uint256 totalLotteryParticipants, uint256 totalLotteryTickets) {
          round = lotteryHistory[index].round;
          winnerAddress = lotteryHistory[index].winnerAddress;
          pot = lotteryHistory[index].pot;
          miners = lotteryHistory[index].miners;
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

      function getGoalsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 goalsAmount = calculateGoalsBuy(amount);
        uint256 miners = goalsAmount.div(GOALS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateGoalSellForYield(eggsPerDay);
        return(miners, earningsPerDay);
    }

   function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedGoals, uint256 _lastCompound, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn, uint256 _referralGoalRewards, uint256 _referralMinerRewards, string memory _selectedWorldCupWinner,
        uint256 _dailyCompoundCount) {
            _initialDeposit = users[_adr].initialDeposit;
            _userDeposit = users[_adr].userDeposit;
            _miners = users[_adr].miners;
            _claimedGoals = users[_adr].claimedGoals;
            _lastCompound = users[_adr].lastCompound;            
            _referrer = users[_adr].referrer;
            _referrals = users[_adr].referralsCount;
            _totalWithdrawn = users[_adr].totalWithdrawn;
            _referralGoalRewards = users[_adr].referralGoalRewards;
            _referralMinerRewards = users[_adr].referralMinerRewards;
            _selectedWorldCupWinner = users[_adr].selectedWorldCupWinner; 
            _dailyCompoundCount = users[_adr].dailyCompoundCount;     

       }

   function getUserBonusInfo(address _adr) public view returns(uint256 _lottery_bonus_as_miners, uint256 _pool_bonus_as_miners) {
        _lottery_bonus_as_miners = users[_adr].lottery_bonus_as_miners;   
       _lottery_bonus_as_miners = users[_adr].pool_bonus_as_miners;      
        _pool_bonus_as_miners = users[_adr].pool_bonus_as_miners;            
   }   
   
   function getAvailableEarnings(address _adr) public view returns(uint256) {
      uint256 userGoals = users[_adr].claimedGoals.add(getGoalsSinceLastCompound(_adr));
      return calculateGoalsSell(userGoals);
   }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract"); //discuss this line
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeERC20 {
    using Address for address;

    //function balanceOf(address account) external view returns (uint256);

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
      }

}