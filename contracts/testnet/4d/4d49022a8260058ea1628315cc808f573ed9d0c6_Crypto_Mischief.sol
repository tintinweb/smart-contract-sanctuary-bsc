/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Crypto_Mischief {
    using SafeMath for uint256;

    bool private locked;
    IERC20 public token_BUSD;
	address erctoken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // Testnet BUSD
    // address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // Mainnet BUSD

    uint public startTime = 1660917600; // Testnet - Fri Aug 19 2022 14:00:00 GMT+0000 https://www.unixtimestamp.com/

    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 2592000; // 3%
    uint256 public REFERRAL = 80;                  // 8%
    uint256 public PERCENTS_DIVIDER = 1000;    
    uint256 public FEE = 5;                        // 0.5%
    uint256 public MARKET_EGGS_DIVISOR = 20;

    /** bonus **/
	uint256 public COMPOUND_BONUS = 30; /** 30% **/
	uint256 public COMPOUND_BONUS_MAX_TIMES = 5; /** 5 days. **/
    uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 24 hours. **/

    /** withdrawal tax **/
    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6;

	bool public LOTTERY_ACTIVATED;
    bool public TOP_DEPOSIT_ACTIVATED;
    uint256 public LOTTERY_START_TIME;
    uint256 public TOP_DEPOSIT_START_TIME;
    uint256 public TOP_DEPOSIT_PERCENT = 10;
    uint256 public LOTTERY_PERCENT = 10;
    uint256 public LOTTERY_STEP = 6 * 60 * 60;
    uint256 public TOP_DEPOSIT_STEP = 24 * 60 * 60;
    uint256 public LOTTERY_TICKET_PRICE = 3 ether; /** 3 ether **/
    uint256 public MAX_LOTTERY_TICKET = 50;
    uint256 public MAX_LOTTERY_PARTICIPANTS = 200;
    uint256 public lotteryRound = 1;
    uint256 public currentPot = 0;
    uint256 public participants = 0;
    uint256 public totalTickets = 0;

    /* statistics */
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalLotteryMinerBonus;
    uint256 public totalTopDepositMinerBonus;

    /* miner parameters */
    uint256 public marketEggs = 259200000000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;

    /** whale control features **/
	uint256 public CUTOFF_STEP = 48 * 60 * 60; /** 48 hours  **/
    uint256 public MIN_INVEST = 10 ether; /** 10 BUSD  **/
	uint256 public WITHDRAW_COOLDOWN = 12 * 60 * 60; /** 12 hours  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 50000 ether; /** 50,000 BUSD  **/

    /* biggest deposit per day. */
    uint8[] public pool_bonuses;
    uint256 public pool_cycle = 1;
    uint256 public pool_balance;
    uint256 public max_pool_balance = 2000 ether; /** 2,000 BUSD  **/

    /* addresses */
    address private owner;
    address private dev1;
    address private dev2;    
    address private charity;
    address private treasury;
    address private genesis;
    
    bool public whitelistActive;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 lottery_bonus_as_miners;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 referralMinerRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 pool_bonus_as_miners;
    }

    struct LotteryHistory {
        uint256 round;
        address winnerAddress;
        uint256 pot;
        uint256 miners;
        uint256 totalLotteryParticipants;
        uint256 totalLotteryTickets;
    }

    LotteryHistory[] internal lotteryHistory;

    mapping(address => bool) public whitelisted;
    mapping(uint8 => address) public pool_top; 
    mapping(address => User) public users;
    mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses; /** round => id => address **/
    mapping(uint256 => mapping(address => uint256)) public pool_users_deposits_sum; 
    event LotteryWinner(address indexed investor, uint256 pot, uint256 miner, uint256 indexed round);
    event PoolPayout(address indexed addr, uint256 amount);

    constructor(address _dev1, address _dev2, address _charity, address _treasury, address _genesis) {
		require(!isContract(_dev1) && !isContract(_dev2) && !isContract(_charity) && !isContract(_treasury) && !isContract(_genesis));
        token_BUSD = IERC20(erctoken);
        owner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        charity = _charity;
        treasury = _treasury;
        genesis = _genesis;

        pool_bonuses.push(30);
        pool_bonuses.push(25);
        pool_bonuses.push(20);
        pool_bonuses.push(15);
        pool_bonuses.push(10);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    modifier nonReentrant {
        require(!locked, "No re-entrancy.");
        locked = true;
        _;
        locked = false;
    }
    /** Test Functions: Remove before deploying in Mainnet **/
    //for testing only remove in mainnet
    function claimTestFunds() external {
        require(msg.sender == owner);
        token_BUSD.transfer(msg.sender, token_BUSD.balanceOf(address(this)));
    }

    function updateLotteryTime(uint256 value) external {
        require(msg.sender == owner);
        LOTTERY_STEP = value * 60 * 60; 
    }

    function updateTopDepositTime(uint256 value) external {
        require(msg.sender == owner);
        TOP_DEPOSIT_STEP = value * 60 * 60; 
    }

    function updateMinDeposit(uint256 value) external {
        require(msg.sender == owner);
        MIN_INVEST = value; 
    }

    function updateStartTime(uint256 value) external {
        require(msg.sender == owner);
        startTime = value; 
    }
    /*********************************************************/

    //activate this before the start of the contract.
    function activateEventFeatures() external {
        require(msg.sender == owner);
        LOTTERY_ACTIVATED = true;
        LOTTERY_START_TIME = block.timestamp;
        TOP_DEPOSIT_ACTIVATED = true;
        TOP_DEPOSIT_START_TIME = block.timestamp;
        whitelistActive = true;
    }

    //will need to be triggered every 12 hours if no user action triggered the events.
    function runEvents() external {
        if (LOTTERY_ACTIVATED) {
            if(getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
                chooseWinner();
            }
		}

        if (TOP_DEPOSIT_ACTIVATED) {
            if(getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
                _drawPool();
            }
		}    
    }

    //enable/disable whitelist.
    function setwhitelistActive(bool isActive) public {
        require(msg.sender == owner, "Admin use only.");
        whitelistActive = isActive;
    }

    //single entry.
    function whitelistAddress(address addr, bool value) public {
        require(msg.sender == owner, "Admin use only.");
        whitelisted[addr] = value;
    }  

    //multiple entry.
    function whitelistAddresses(address[] memory addr, bool whitelist) public {
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < addr.length; i++){
            whitelisted[addr[i]] = whitelist;
        }
    }

    //check if whitelisted.
    function isWhitelisted(address Wallet) public view returns(bool whitelist){
        require(msg.sender == owner, "Admin use only.");
        whitelist = whitelisted[Wallet];
    }

    function fundFromGenesis(address ref, uint256 amount) public {
        buyEggs(ref, amount);
    }

    function buyEggs(address ref, uint256 amount) public nonReentrant {
        User storage user = users[msg.sender];
        //if whitelist is active, only whitelisted addresses can invest in the project.
        if (whitelistActive) {
            require(whitelisted[msg.sender], "Address is not Whitelisted.");
        }
        require(block.timestamp > startTime || msg.sender == genesis); //genesis wallet will be funding and will eliminate early advantage.
        require(amount >= MIN_INVEST, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        uint256 eggsBought = calculateEggBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedEggs = user.claimedEggs.add(eggsBought);

        if (LOTTERY_ACTIVATED) {
            if(getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
                chooseWinner();
            }
			_buyTickets(msg.sender, amount);
		}

        if (TOP_DEPOSIT_ACTIVATED) {
            if(getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
                _drawPool();
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
                uint256 eggsReward = calculateEggBuy(refRewards, getBalance().sub(refRewards));
                users[upline].miners = user.miners.add(eggsReward.div(EGGS_TO_HIRE_1MINERS));
                marketEggs = marketEggs.add(eggsReward.div(MARKET_EGGS_DIVISOR));
                users[upline].referralMinerRewards = users[upline].referralMinerRewards.add(eggsReward); //miner amount.
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards); //ether amount.
                totalRefBonus = totalRefBonus.add(refRewards); //ether amount.
            }
        }

        uint256 eggsPayout = payFees(amount);
        totalStaked = totalStaked.add(amount.sub(eggsPayout));
        totalDeposits++;
        hatchEggs(false);
    }

    function hatchEggs(bool isCompound) public {
        User storage user = users[msg.sender];
        require(block.timestamp > startTime || msg.sender == genesis);

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;
        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);

            if(getTimeStamp().sub(user.lastHatch) >= COMPOUND_STEP) {
                if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                    user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
                }
            }

            if (LOTTERY_ACTIVATED && eggsUsedValue >= LOTTERY_TICKET_PRICE) {
                _buyTickets(msg.sender, eggsUsedValue);
            }
        }

        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = getTimeStamp();

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellEggs() public nonReentrant {
        require(block.timestamp > startTime);
        require(msg.sender != genesis, "Genesis wallet is blocked from selling.");
        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
             user.dailyCompoundBonus = 0;   
        }

        user.claimedEggs = 0;
        
        user.lastHatch = getTimeStamp();

        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        token_BUSD.transfer(msg.sender, eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

        if(getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
            chooseWinner();
        }

        if(getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
            _drawPool();
        }
    }

    function _topDeposits(address _addr, uint256 _amount) private {
        if(_addr == address(0) || _addr == owner) return;

	    uint256 pool_amount = _amount.mul(TOP_DEPOSIT_PERCENT).div(100);
		
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

    function _drawPool() private {
        pool_cycle++;
        TOP_DEPOSIT_START_TIME = getTimeStamp();
        uint256 draw_amount = pool_balance;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;
            User storage user = users[pool_top[i]];

            uint256 win = draw_amount.mul(pool_bonuses[i]) / 100;
            uint256 eggsReward = calculateEggBuy(win, getBalance().sub(win));
            uint256 minerRewards = eggsReward.div(EGGS_TO_HIRE_1MINERS);
            user.miners = user.miners.add(minerRewards);
            marketEggs = marketEggs.add(eggsReward.div(MARKET_EGGS_DIVISOR));
            users[pool_top[i]].pool_bonus_as_miners += minerRewards;
            totalTopDepositMinerBonus = totalTopDepositMinerBonus.add(minerRewards);
            pool_balance -= win;
            emit PoolPayout(pool_top[i], win);
        }

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
    }  

    function payFees(uint256 eggValue) internal returns(uint256) {
        (uint256 dev1Fee, uint256 dev2Fee, uint256 charityFee, uint256 treasuryFee) = getFees(eggValue);
        token_BUSD.transfer(dev1, dev1Fee);
		token_BUSD.transfer(dev2, dev2Fee);
        token_BUSD.transfer(charity, charityFee);
        token_BUSD.transfer(treasury, treasuryFee);        
        return treasuryFee.add(dev1Fee).add(dev2Fee).add(charityFee); // 5%
    }

    function getFees(uint256 eggValue) public view returns(uint256 _dev1Fee, uint256 _dev2Fee, uint256 _charityFee, uint256 _treasuryFee) {
        _treasuryFee = (eggValue.mul(FEE).div(PERCENTS_DIVIDER)) * 6; 
        _dev1Fee     = (eggValue.mul(FEE).div(PERCENTS_DIVIDER)) * 2; 
        _dev2Fee     = eggValue.mul(FEE).div(PERCENTS_DIVIDER);       
        _charityFee  = eggValue.mul(FEE).div(PERCENTS_DIVIDER);       
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
        uint256 addToPot = amount.mul(LOTTERY_PERCENT).div(1000);

        if(currentPot.add(addToPot) > max_pool_balance){       
            currentPot += max_pool_balance.sub(currentPot);
        }
        else{
            currentPot += addToPot;
        }

        totalTickets = totalTickets.add(numTickets);
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
                    uint256 eggs = currentPot.sub(burnTax);
                    uint256 eggsReward = calculateEggBuy(eggs, getBalance().sub(eggs));
                    user.miners = user.miners.add(eggsReward.div(EGGS_TO_HIRE_1MINERS));
                    marketEggs = marketEggs.add(eggsReward.div(MARKET_EGGS_DIVISOR));

                    user.lottery_bonus_as_miners = user.lottery_bonus_as_miners.add(eggsReward);
                    totalLotteryMinerBonus = totalLotteryMinerBonus.add(eggsReward);

                    lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, eggs, eggsReward, participants, totalTickets));
                    emit LotteryWinner(winnerAddress, eggs, eggsReward, lotteryRound);

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

    function _getRandom() private view returns(uint256){
        bytes32 _blockhash = blockhash(block.number-1);
        return uint256(keccak256(abi.encode(_blockhash,getTimeStamp(),currentPot,block.difficulty, marketEggs, getBalance())));
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256) {
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(COMPOUND_BONUS); 
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
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

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _referralMinerRewards, uint256 _dailyCompoundBonus) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedEggs = users[_adr].claimedEggs;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _referralMinerRewards = users[_adr].referralMinerRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
	}

    function getUserBonusInfo(address _adr) public view returns(uint256 _lottery_bonus_as_miners, uint256 _pool_bonus_as_miners) {
         _lottery_bonus_as_miners = users[_adr].lottery_bonus_as_miners;        
         _pool_bonus_as_miners = users[_adr].pool_bonus_as_miners;            
    }

    function getBalance() public view returns (uint256) {
        return token_BUSD.balanceOf(address(this));
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

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
        return calculateEggBuy(eth, getBalance());
    }

    function getEggsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getBalance());
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs,uint256 amount) public view returns(uint256){
        return calculateTrade(eggs,marketEggs, getBalance().add(amount));
    }

    function poolTopInfo() view external returns(address[5] memory addrs, uint256[5] memory deps) {
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            addrs[i] = pool_top[i];
            deps[i] = pool_users_deposits_sum[pool_cycle][pool_top[i]];
        }
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalTopDepositMinerBonus, uint256 _totalLotteryMinerBonus, uint256 _pool_balance, uint256 _pool_leader) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalTopDepositMinerBonus, totalLotteryMinerBonus, pool_balance, pool_users_deposits_sum[pool_cycle][pool_top[0]]);
    }

    function getMyMiners() public view returns(uint256) {
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256) {
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsSinceLastHatch = getTimeStamp().sub(users[adr].lastHatch);
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }
    
    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }
    
    function ENABLE_LOTTERY(bool value) public {
        require(msg.sender == owner, "Admin use only.");
        require(block.timestamp > startTime);
        if(value){
            LOTTERY_ACTIVATED = true; 
            LOTTERY_START_TIME = block.timestamp; //enabling the function will start a new start time.           
        }else{
            LOTTERY_ACTIVATED = false;
        }
    }
    
    function ENABLE_TOP_DEPOSIT(bool value) public {
        require(msg.sender == owner, "Admin use only.");
        require(block.timestamp > startTime);
        if(value){
            TOP_DEPOSIT_ACTIVATED = true;   
            TOP_DEPOSIT_START_TIME = block.timestamp; //enabling the function will start a new start time.         
        }else{
            TOP_DEPOSIT_ACTIVATED = false;
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
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