/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TopGunAI {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool private contractStarted;
    uint256 random_min = 0;
    uint256 random_max = 9;
    IERC20 public BUSD;
    bool private locked;

    uint256 public MIN_INVEST = 50 ether; /** 50 BUSD  **/
	uint256 public ACTION_COOLDOWN = 86400; /** 24 hours  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 10000 ether; /** 10,000 BUSD  **/
    uint256 public REFERRAL = 10;  //
    uint256 public JETS_TO_HIRE_1MINERS = 972000; // 8%
    uint256 public JETS_BUSD = 100; // ammount of jets for 1 busd
    uint256 public jetsValue = JETS_TO_HIRE_1MINERS * JETS_BUSD; //JETS_TO_HIRE_1MINERS * JETS_BUSD
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public FEE = 50;   // 5%
    uint256 public SUSTAIN_FEE = 50;   // 5%
    uint256 public MARKET_JETS_DIVISOR = 20;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 3;

     /* addresses */
    address private owner;
    address private treasury;
    address private sustainability;

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
     bool public TOP_DEPOSIT_ACTIVATED = false;
     uint256 public LOTTERY_START_TIME;
     uint256 public TOP_DEPOSIT_START_TIME;
     uint256 public TOP_DEPOSIT_PERCENT = 500; //50%
     uint256 public LOTTERY_PERCENT = 50;
     uint256 public LOTTERY_STEP = 86400; // 24 hrs
     uint256 public TOP_DEPOSIT_STEP = 86400; // 24 hrs
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
    uint256 public max_pool_balance = 1000 ether; /** 1,000 BUSD  **/


     mapping(address => uint256) private buyCount;
     mapping(address => bool) private blacklisted;
     mapping(uint8 => address) public pool_top;
     mapping(address => User) public users;
     mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
     mapping(uint256 => mapping(uint256 => address)) public participantAdresses; /** round => id => address **/
     mapping(uint256 => mapping(address => uint256)) public pool_users_deposits_sum;
     event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);
     event PoolPayout(address indexed addr, uint256 amount);

     address public topDepositWinner;
     uint256 public topDepositWinnerDeps;

     uint256 public marketJets = 259200000000;
     uint256 PSN = 10000;
     uint256 PSNH = 5000;

     uint256 public CUTOFF_STEP = 345600; /** 96 hours  **/

     struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedJets;
        uint256 lottery_bonus_as_miners;
        uint256 lastCompound;
        address referrer;
        uint256 referralsCount;
        uint256 referralJetsReward;
        uint256 referralMinerRewards;
        uint256 totalWithdrawn;
        uint256 pool_bonus_as_miners;
        uint256 dailyCompoundCount;
        uint256 lottery_rewards;
    }

    address [] public addresses;

    struct LotteryHistory {
        uint256 round;
        address winnerAddress;
        uint256 pot;
        //uint256 miners;
        uint256 totalLotteryParticipants;
        uint256 totalLotteryTickets;
    }

    LotteryHistory[] internal lotteryHistory;

    event NewDepositLottery(address indexed user, uint256 amount);

    constructor(address _treasury, address _sustainability) {
		require(!isContract(_treasury) && !isContract(_sustainability));
       //BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // mainnet
       BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); //testnet

        owner = msg.sender;
        treasury = _treasury;
        sustainability = _sustainability;

        pool_bonuses.push(10);
        pool_bonuses.push(9);
        pool_bonuses.push(8);
        pool_bonuses.push(7);
        pool_bonuses.push(6);
        pool_bonuses.push(5);
        pool_bonuses.push(4);
        pool_bonuses.push(3);
        pool_bonuses.push(2);
        pool_bonuses.push(1);
    }

    function buyJets(address ref, uint256 amount) public nonReentrant {
        
        User storage user = users[msg.sender];
        require(!blacklisted[msg.sender], "Address is blacklisted.");
        require(contractStarted || msg.sender == sustainability); //sustainability wallet will be funding and will eliminate early advantage.
        require(amount >= MIN_INVEST, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");

        BUSD.safeTransferFrom(address(msg.sender), address(this), amount);

        if(user.initialDeposit < 1){ //new user! add count for new deposits only for precise record of data.
            totalDeposits++;
            addresses.push(msg.sender);
            user.dailyCompoundCount = 0;
        }
        else{ //existing user - add the current yield to the total compound before adding new deposits for precise record of data.
            uint256 currJetsValue = calculateJetsSell(getJetsSinceLastCompound(msg.sender));
            user.userDeposit = user.userDeposit.add(currJetsValue);
            totalCompound = totalCompound.add(currJetsValue);
            }

        uint256 jetsBought = calculateJetsBuy(amount);
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedJets = user.claimedJets.add(jetsBought);

        if (LOTTERY_ACTIVATED) {
            if(getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_LOTTERY_POOL_PER_ROUND) {
                chooseWinner();
            }
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
                    uint256 jetsReward = calculateJetsBuy(refRewards);
                    uint256 minerRewards = jetsReward.div(JETS_TO_HIRE_1MINERS);
                    users[upline].miners = users[upline].miners.add(minerRewards);
                    marketJets = marketJets.add(jetsReward.div(MARKET_JETS_DIVISOR));
                    users[upline].referralMinerRewards = users[upline].referralMinerRewards.add(minerRewards); //miner amount.
                    users[upline].referralJetsReward = users[upline].referralJetsReward.add(refRewards); //ether amount.
                    totalRefBonus = totalRefBonus.add(refRewards); //ether amount.
                }
        }

        uint256 jetsPayout = payFees(amount);
        jetsPayout = jetsPayout + paySustainabilityFees(amount);
        totalStaked = totalStaked.add(amount.sub(jetsPayout));
        compoundJets(false);
        
    }

    function compoundJets(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted || msg.sender == sustainability);


        uint256 jetsUsed = getMyJets();
        uint256 jetsForCompound = jetsUsed;
        if(isCompound) {
            if(user.lastCompound.add(ACTION_COOLDOWN) > block.timestamp) revert("Can only compound after action cooldown.");
            require(user.miners > 0, "Did not make a deposit yet");
            uint256 jetsUsedValue = calculateJetsSell(jetsForCompound);
            user.userDeposit = user.userDeposit.add(jetsUsedValue);
            totalCompound = totalCompound.add(jetsUsedValue);

            if(TOP_DEPOSIT_ACTIVATED && getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
                _drawPool();
            }
            user.dailyCompoundCount = user.dailyCompoundCount.add(1); //adds compound
        }

        user.miners = user.miners.add(jetsForCompound.div(JETS_TO_HIRE_1MINERS));
        user.claimedJets = 0;
        user.lastCompound = getTimeStamp();
        marketJets = marketJets.add(jetsUsed.div(MARKET_JETS_DIVISOR));
    }

    function sellJets() public nonReentrant {
        require(contractStarted, "Contract is not Started.");
        require(msg.sender != sustainability, "sustainability wallet is blocked from selling.");
        User storage user = users[msg.sender];
        require(user.dailyCompoundCount >= COMPOUND_FOR_NO_TAX_WITHDRAWAL, "Not enought compounds.");
        uint256 hasJets = getMyJets();
        uint256 jetValue = calculateJetsSell(hasJets);

        if(user.lastCompound.add(ACTION_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");

        user.claimedJets = 0;
        user.dailyCompoundCount = 0; // resets compound limit
        user.lastCompound = getTimeStamp();

        marketJets = marketJets.add(hasJets.div(MARKET_JETS_DIVISOR));

        if(getBalance() < jetValue) {
            jetValue = getBalance();
        }

        uint256 jetsPayout = jetValue;
        BUSD.safeTransfer(msg.sender, jetsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(jetsPayout);
        totalWithdrawn = totalWithdrawn.add(jetsPayout);

        if(LOTTERY_ACTIVATED && getTimeStamp().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS) {
            chooseWinner();
        }

       if(TOP_DEPOSIT_ACTIVATED && getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP) {
            _drawPool();
       }
    }

    function random_number(uint minNumber, uint maxNumber) public view returns (uint amount) {
        amount = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number))) % (maxNumber-minNumber);
        amount = amount + minNumber;
        return amount;
   }

   function _drawPool() private {
    pool_cycle++;
    TOP_DEPOSIT_START_TIME = getTimeStamp();
    uint256 draw_amount = pool_balance;

    for(uint8 i = 0; i < pool_bonuses.length; i++) {
        if(pool_top[i] == address(0)) break;
        User storage user = users[pool_top[i]];

        uint256 win = draw_amount.mul(pool_bonuses[i]) / 100;
        uint256 jetsReward = calculateJetsBuy(win);
        uint256 minerRewards = jetsReward.div(JETS_TO_HIRE_1MINERS);
        user.miners = user.miners.add(minerRewards);
        marketJets = marketJets.add(jetsReward.div(MARKET_JETS_DIVISOR));
        users[pool_top[i]].pool_bonus_as_miners += minerRewards;
        totalTopDepositMinerBonus = totalTopDepositMinerBonus.add(minerRewards);
        pool_balance -= win;
        emit PoolPayout(pool_top[i], minerRewards);
    }

    for(uint8 i = 0; i < pool_bonuses.length; i++) {
        pool_top[i] = address(0);
    }
    pool_balance = 0;
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
   

   //lotery

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
                uint256 rewardAmount = currentPot.sub(payFees(currentPot));
                user.lottery_rewards = user.lottery_rewards.add(rewardAmount);
                address payable receiver = payable(winnerAddress);
                receiver.transfer(rewardAmount);           
                lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, rewardAmount, participants, totalTickets));
                emit LotteryWinner(winnerAddress, rewardAmount, lotteryRound);

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

function _buyTickets() public payable {
    require(contractStarted, "Contract is not Started.");
    require(msg.value != 0, "zero purchase amount");
    uint256 amount = msg.value;
    uint256 userTickets = ticketOwners[lotteryRound][msg.sender];
    uint256 numTickets = amount.div(LOTTERY_TICKET_PRICE);

    if(userTickets == 0) {
        participantAdresses[lotteryRound][participants] = msg.sender;

        if(numTickets > 0){
          participants = participants.add(1);
        }
    }

    if (userTickets.add(numTickets) > MAX_LOTTERY_TICKET) {
        numTickets = MAX_LOTTERY_TICKET.sub(userTickets);
    }

    ticketOwners[lotteryRound][msg.sender] = userTickets.add(numTickets);
    uint256 ticketAmount = amount.sub(payFees(amount));
    emit NewDepositLottery(msg.sender, ticketAmount);

    if(currentPot.add(ticketAmount) > MAX_LOTTERY_POOL_PER_ROUND){
        currentPot += MAX_LOTTERY_POOL_PER_ROUND.sub(currentPot);
    }
    else{
        currentPot += ticketAmount;
    }

    totalTickets = totalTickets.add(numTickets);
}

function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
    uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice,
    uint256 maxLotteryTicket, uint256 round){
      lotteryStartTime = LOTTERY_START_TIME;
      lotteryStep = LOTTERY_STEP;
      lotteryTicketPrice = LOTTERY_TICKET_PRICE;
      maxLotteryParticipants = MAX_LOTTERY_PARTICIPANTS;
      round = lotteryRound;
      lotteryCurrentPot = currentPot;
      lotteryParticipants = participants;
      totalLotteryTickets = totalTickets;
      maxLotteryTicket = MAX_LOTTERY_TICKET;
  }

function getLotteryHistory(uint256 index) public view returns(uint256 round, address winnerAddress, uint256 pot,
    uint256 totalLotteryParticipants, uint256 totalLotteryTickets) {
      round = lotteryHistory[index].round;
      winnerAddress = lotteryHistory[index].winnerAddress;
      pot = lotteryHistory[index].pot;
      totalLotteryParticipants = lotteryHistory[index].totalLotteryParticipants;
      totalLotteryTickets = lotteryHistory[index].totalLotteryTickets;
  }

// Lottery

    function calculateJetsBuy(uint256 eth) public view returns(uint256) {
        return calculateTradeBuy(eth);
    }

    function calculateTradeBuy(uint256 amountBusd) public view returns(uint256) {
        return SafeMath.mul(SafeMath.div(amountBusd, 1000000000000000000), jetsValue);
    }

    function calculateTradeSell(uint256 amountJets) public view returns(uint256) {
       return SafeMath.div(SafeMath.mul(amountJets, 1000000000000000000), jetsValue);
    }

    function calculateJetSellForYield(uint256 jets) public view returns(uint256){
        return calculateTradeSell(jets);
    }

    function calculateJetsSell(uint256 jets) public view returns(uint256) {
       return calculateTradeSell(jets);
    }

    function calculateJetsBuySimple(uint256 eth) public view returns(uint256) {
        return calculateJetsBuy(eth);
    }

    function getBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
	}

    function getMyJets() public view returns(uint256) {
        return users[msg.sender].claimedJets.add(getJetsSinceLastCompound(msg.sender));
    }

    function payFees(uint256 jetValue) internal returns(uint256) {
        (uint256 treasuryFee) = getFees(jetValue);
        BUSD.safeTransfer(treasury, treasuryFee);
        return treasuryFee; // 5%
    }

    function paySustainabilityFees(uint256 jetValue) internal returns(uint256) {
        (uint256 sustainabilityFee) = getFees2(jetValue);
        BUSD.safeTransfer(sustainability, sustainabilityFee);
        return sustainabilityFee; // 5%
    }

    function getFees(uint256 jetValue) public view returns(uint256 _treasuryFee) {
        _treasuryFee = (jetValue.mul(FEE).div(PERCENTS_DIVIDER));
    }

    function getFees2(uint256 jetValue) public view returns(uint256 _sustainabilityFee) {
        _sustainabilityFee = (jetValue.mul(SUSTAIN_FEE).div(PERCENTS_DIVIDER));
    }

    modifier nonReentrant {
        require(!locked, "No re-entrancy.");
        locked = true;
        _;
        locked = false;
    }

    function getJetsSinceLastCompound(address adr) public view returns(uint256) {
        uint256 secondsSinceLastCompound = getTimeStamp().sub(users[adr].lastCompound);
        uint256 cutoffTime = min(secondsSinceLastCompound, CUTOFF_STEP);
        uint256 secondsPassed = min(JETS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

   	function activateLaunch() external {
        require(msg.sender == owner, "Admin use only");
	    if(contractStarted == false)
         {
          contractStarted = true;
	      TOP_DEPOSIT_ACTIVATED = true;
          LOTTERY_ACTIVATED = true;
	      TOP_DEPOSIT_START_TIME = block.timestamp;	
         }    
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

    function getUserLotteryRewars(address userAddress) public view returns (uint256) {
		return users[userAddress].lottery_rewards;
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalTopDepositMinerBonus, uint256 _totalLotteryMinerBonus, uint256 _pool_balance, uint256 _pool_leader) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalTopDepositMinerBonus, totalLotteryMinerBonus, pool_balance, pool_users_deposits_sum[pool_cycle][pool_top[0]]);
    }

    function getMyMiners() public view returns(uint256) {
        return users[msg.sender].miners;
    }

    function VAR_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 10);
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only");  
        require(!isContract(value));     
        owner = value;
    } 

    function DISABLE_TOP_DEPOSIT() public {
        require(msg.sender == owner, "Admin use only.");
        require(contractStarted);      
        
        if (TOP_DEPOSIT_ACTIVATED) {
            if(getTimeStamp().sub(TOP_DEPOSIT_START_TIME) >=  TOP_DEPOSIT_STEP){
            _drawPool();
            }
        }
        
        if(TOP_DEPOSIT_ACTIVATED){
            TOP_DEPOSIT_ACTIVATED = false;                  
        }
        else {
            TOP_DEPOSIT_ACTIVATED = true;
            TOP_DEPOSIT_START_TIME = block.timestamp;	 
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

    function _getRandom() private view returns(uint256){
        bytes32 _blockhash = blockhash(block.number-1);
        return uint256(keccak256(abi.encode(_blockhash,getTimeStamp(),currentPot,block.difficulty, marketJets, getBalance())));
    }

    function getJetsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 jetsAmount = calculateJetsBuy(amount);
        uint256 miners = jetsAmount.div(JETS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 jetsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateJetSellForYield(jetsPerDay);
        return(miners, earningsPerDay);
    }

   function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
        uint256 _claimedJets, uint256 _lastCompound, address _referrer, uint256 _referrals,
        uint256 _totalWithdrawn, uint256 _referralJetsRewards, uint256 _referralMinerRewards,
        uint256 _dailyCompoundCount, uint256 _lottery_rewards) {
            _initialDeposit = users[_adr].initialDeposit;
            _userDeposit = users[_adr].userDeposit;
            _miners = users[_adr].miners;
            _claimedJets = users[_adr].claimedJets;
            _lastCompound = users[_adr].lastCompound;
            _referrer = users[_adr].referrer;
            _referrals = users[_adr].referralsCount;
            _totalWithdrawn = users[_adr].totalWithdrawn;
            _referralJetsRewards = users[_adr].referralJetsReward;
            _referralMinerRewards = users[_adr].referralMinerRewards;
            _dailyCompoundCount = users[_adr].dailyCompoundCount;
            _lottery_rewards = users[_adr].lottery_rewards;

       }

   function getUserBonusInfo(address _adr) public view returns(uint256 _lottery_bonus_as_miners, uint256 _pool_bonus_as_miners) {
        _lottery_bonus_as_miners = users[_adr].lottery_bonus_as_miners;
       _lottery_bonus_as_miners = users[_adr].pool_bonus_as_miners;
        _pool_bonus_as_miners = users[_adr].pool_bonus_as_miners;
   }

   function getAvailableEarnings(address _adr) public view returns(uint256) {
      uint256 userJets = users[_adr].claimedJets.add(getJetsSinceLastCompound(_adr));
      return calculateJetsSell(userJets);
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