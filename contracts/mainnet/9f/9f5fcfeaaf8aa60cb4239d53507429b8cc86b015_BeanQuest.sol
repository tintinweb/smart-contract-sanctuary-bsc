/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BeanQuest {
    using SafeMath for uint256;
    using SafeMath for uint8;

    address public nftAddress;
    address public bossAddress;
    address public kvrfAddress;
    address public vrfAddress;
    address public gachaAddress;
    bool public kvrfActivated;

    BossContract boss = BossContract(bossAddress); 
    BossNFTs nft = BossNFTs(nftAddress);
    BeanQuestGacha gacha = BeanQuestGacha(gachaAddress);

    function setContracts(address _boss, address _nft, address _gacha, address _vrf, bool activateKVRF, address _beanvrf) public {
        require(msg.sender == owner);
        boss = BossContract(_boss);
        nft = BossNFTs(_nft);
        gacha = BeanQuestGacha(_gacha);
        kvrfAddress = _vrf;
        nftAddress = _nft;
        bossAddress = _boss;
        gachaAddress = _gacha;
        kvrfActivated = activateKVRF;
        vrfAddress = _beanvrf;
    }


     struct User {
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 direct_bonus;
        uint256 pool_bonus;
        uint256 match_bonus;
        uint256 deposit_amount;
        uint256 deposit_payouts;
        uint256 total_direct_deposits;
        uint256 total_payouts;
        uint256 total_structure;
        uint256 total_downline_deposit;
        uint256 checkpoint;
    }

    // struct Team {
    //     address[] members; // owner is also in member-array!
    //     address owner; // owner is able to add users
    //     uint256 id;
    //     uint256 created_at;
    //     string name;
    //     bool is_referral_team; // first team of upline-user is the referral team. all ref users are added automatically
    // }

    // struct TeamInfo {
    //     uint256 id;
    //     bool exists;
    // }

    struct UserBonusStats {
        uint256 direct_bonus_withdrawn;
        uint256 match_bonus_withdrawn;
        uint256 pool_bonus_withdrawn;
        uint256 income_reinvested;
        uint256 bonus_reinvested;
        uint256 reinvested_gross;
        uint256 streak;
        uint256 beanCheckpoint;
        uint256 beanStreak;
    }
		
	mapping(address => address) public uplinesOld;
		
    
    mapping(address => UserBonusStats) public userBonusStats;
    mapping(address => string) nicknames;
    mapping(string => bool) isInUse;
    mapping(address => User) public users;
    //mapping(address => Stat) public stats;
    mapping(uint256 => address) public id2Address;
    // mapping(uint256 => Team) public teams;
    // mapping(address => uint8) public user_teams_counter; // holds the number of teams of a user
    // mapping(address => TeamInfo[]) public user_teams;
    // mapping(address => TeamInfo) public user_referral_team;
    //BOSS VARIABLES
    mapping(uint => mapping(address => bool)) public defeatedThisRound;
    uint public currentBoss;
    uint public round;
    mapping(uint => uint) public timesBossDefeated;

    address payable public owner;
    address payable public director;
    // address payable public marketing;
	uint256 public OWNER;
    uint256 public REFERRAL;
    uint256 public DIRECTOR;
	// uint256 public MARKETING;
    uint256 public REINVEST_BONUS;
    uint256 public MAX_PAYOUT;
    uint256 public BASE_PERCENT;
    uint256 public TIME_STEP;
    // uint8 public MAX_TEAMS_PER_ADDRESS;
    uint8 public MAX_LENGTH_NICKNAME;
    uint256 public STREAK_PENALTY = 400;
    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint public bossRecoveryTime = 43200;
    uint public streakPenaltyTime = 432000;
    uint public finalBossStats = 25000000000000000000;
    uint public beanChance = 10;
    uint public beanTimer = 86400;

    uint8[] public ref_bonuses;
    uint8[] public pool_bonuses;
    uint256 public pool_last_draw;
    uint256 public pool_cycle;
    uint256 public pool_balance;
    uint256 constant public ref_depth = 15;

    mapping(uint256 => mapping(address => uint256)) public pool_users_refs_deposits_sum;
    mapping(uint8 => address) public pool_top;

    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    uint256 public total_reinvested;
    // uint256 public total_teams_created;

    bool public started;
    uint256 public MIN_INVEST; //0.01 BNB
    uint256 public MAX_WALLET_DEPOSIT; //100k BNB
    uint256 public MAX_POOL_BALANCE; //100k BNB


    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event PoolPayout(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint256 amount);
    event MagicBeanFound(address user, string name, uint rand);
    event BossFight(address user, string name, string boss, uint chance, bool defeated, uint nft, bool firstTime);
    event LuckyGuy(address user);

    function initialize(address payable ownerAddress, address payable directorAddress/*, address payable marketingAddress*/) external{
		require(total_users == 0);	
        require(!isContract(ownerAddress) && !isContract(directorAddress)/* && !isContract(marketingAddress)*/);
        owner = ownerAddress;
		director = directorAddress;
		// marketing = marketingAddress;
        total_users = 1;
        REFERRAL = 100;
        DIRECTOR = 30;
        // MARKETING = 30;
        OWNER = 30;
        REINVEST_BONUS = 50;
        MAX_PAYOUT = 3650;
        BASE_PERCENT = 30;
        TIME_STEP = 1 days;
        // MAX_TEAMS_PER_ADDRESS = 6;
        MAX_LENGTH_NICKNAME = 10;
        pool_last_draw = block.timestamp;

        MIN_INVEST = 0.01 ether; //0.01 BNB
        MAX_WALLET_DEPOSIT = 100000 ether; //100K BNB
        MAX_POOL_BALANCE = 100000 ether; //25k BNB


        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);

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
	
	receive() external payable {
        
    }

    //deposit_amount -- can only be done by the owner address for first deposit.
    function deposit(uint8 _attribute) payable external {
        _deposit(msg.value, _attribute);
    }

    //deposit with upline
    function deposit(address _upline, uint8 _attribute) payable external {
        require(started, "Contract not yet started.");
				
		if(uplinesOld[msg.sender] != address(0)) {
            _setUpline(msg.sender, uplinesOld[msg.sender]);
		} else {
			_setUpline(msg.sender, _upline);
		}
        _deposit(msg.value, _attribute);
    }

    // //deposit with upline NICKNAME
    // function depositWithNickname(string calldata _nickname, uint8 _attribute) payable external {
    //     require(started, "Contract not yet started.");
    //     if(uplinesOld[msg.sender] != address(0)) {
	// 		_setUpline(msg.sender, uplinesOld[msg.sender]);
    //     } else {
    //         address _upline = getAddressToNickname(_nickname);
    //         require(_upline != address(0), "nickname not found");        
    //         _setUpline(msg.sender, _upline);
    //     }
    //     _deposit(msg.value, _attribute);
    // }

    //invest
    function _deposit(uint256 _amount, uint8 _attribute) private {
        if (!started) {
    		if (msg.sender == owner) {
    			started = true;
    		} else revert("Contract not yet started.");
    	}
        
        require(users[msg.sender].upline != address(0) || msg.sender == owner, "No upline");
        require(_amount >= MIN_INVEST, "Mininum investment not met.");
        require(users[msg.sender].total_direct_deposits.add(_amount) <= MAX_WALLET_DEPOSIT, "Max deposit limit reached.");
        require(_attribute < 3 || nft.getEffectStatus(16, msg.sender) && _attribute < 4, "No valid attribute selected");

        if(users[msg.sender].deposit_amount == 0 ){ // new user
            id2Address[total_users] = msg.sender;
            total_users++;
        }

        // reinvest before deposit because the checkpoint gets a reset here
        uint256 to_reinvest = this.payoutToReinvest(msg.sender);
        if(to_reinvest > 0){
            userBonusStats[msg.sender].income_reinvested += to_reinvest;
            to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER)); //add 5% more bonus for reinvest action.
            users[msg.sender].deposit_amount += to_reinvest;	
            userBonusStats[msg.sender].reinvested_gross += to_reinvest;        
            total_reinvested += to_reinvest;
            emit ReinvestedDeposit(msg.sender, to_reinvest);
        }

        // deposit
        nft.updateStats(_amount + to_reinvest, msg.sender, _attribute);
        users[msg.sender].deposit_amount += _amount;
        uint _streak = userBonusStats[msg.sender].streak;
        userBonusStats[msg.sender].streak = _streak == 0 ? 1 : _streak + block.timestamp - users[msg.sender].checkpoint;
        users[msg.sender].checkpoint = block.timestamp;

        users[msg.sender].total_direct_deposits += _amount;

        total_deposited += _amount;

        emit NewDeposit(msg.sender, _amount);
        if(users[msg.sender].upline != address(0)) {
            //direct referral bonus 5%
			if(users[users[msg.sender].upline].checkpoint > 0) {
                users[users[msg.sender].upline].direct_bonus += _amount.mul(REFERRAL).div(PERCENTS_DIVIDER);
                emit DirectPayout(users[msg.sender].upline, msg.sender, _amount.mul(REFERRAL).div(PERCENTS_DIVIDER));
			}
        }

        _poolDeposits(msg.sender, _amount);
        _downLineDeposits(msg.sender, _amount);

        if(pool_last_draw.add(TIME_STEP) < block.timestamp) {
            _drawPool();
        }

        //pay fees
        fees(_amount);
    }

    function checkUplineValid(address _addr, address _upline) external view returns (bool isValid) {
        if (uplinesOld[_addr] == _upline && users[_addr].checkpoint == 0) {
            isValid = true;
        }		
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner && (users[_upline].checkpoint > 0 || _upline == owner)) {
            isValid = true;        
        }
    }

    function _setUpline(address _addr, address _upline) private {
        if(this.checkUplineValid(_addr, _upline)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            // if(user_referral_team[_upline].exists == false){
            //     uint256 teamId = _createTeam(_upline, true); // create first team on upline-user. this contains the direct referrals
            //     user_referral_team[_upline].id = teamId;
            //     user_referral_team[_upline].exists = true;
            // }

            // check if current user is in ref-team
            // bool memberExists = false;
            // for(uint256 i = 0; i < teams[user_referral_team[_upline].id].members.length; i++){
            //     if(teams[user_referral_team[_upline].id].members[i] == _addr){
            //         memberExists = true;
            //     }
            // }
            // if(memberExists == false){
            //     _addTeamMember(user_referral_team[_upline].id, _addr); // add referral user to upline users referral-team
            // }

            emit Upline(_addr, _upline);

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }

    function _poolDeposits(address _addr, uint256 _amount) private {
        
	    uint256 pool_amount = _amount.mul(3).div(100); // use 3% of the deposit
		
        if(pool_balance.add(pool_amount) > MAX_POOL_BALANCE){ // check if old balance + additional pool deposit is in range            
            pool_balance += MAX_POOL_BALANCE.sub(pool_balance);
        }else{
            pool_balance += pool_amount;
        }

        address upline = users[_addr].upline;

        if(upline == address(0) || upline == owner) return;

        pool_users_refs_deposits_sum[pool_cycle][upline] += _amount;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == upline) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = upline;
                break;
            }

            if(pool_users_refs_deposits_sum[pool_cycle][upline] > pool_users_refs_deposits_sum[pool_cycle][pool_top[i]]) {
                for(uint8 j = i + 1; j < pool_bonuses.length; j++) {
                    if(pool_top[j] == upline) {
                        for(uint8 k = j; k <= pool_bonuses.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(pool_bonuses.length.sub(1)); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }

                pool_top[i] = upline;

                break;
            }
        }
    }

    function _downLineDeposits(address _addr, uint256 _amount) private {
      address _upline = users[_addr].upline;
      for(uint8 i = 0; i < ref_bonuses.length; i++) {
          if(_upline == address(0)) break;
					if(users[_upline].checkpoint > 0) {
          users[_upline].total_downline_deposit = users[_upline].total_downline_deposit.add(_amount);
					}
          _upline = users[_upline].upline;
      }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < ref_depth; i++) {
            if(up == address(0)) break;

            if(users[up].referrals >= i.add(1)) {
                uint256 bonus = _amount * ref_bonuses[i] / 100;
                if(users[up].checkpoint!= 0) { // only pay match payout if user is present
                    users[up].match_bonus += bonus;
                    emit MatchPayout(up, _addr, bonus);   
                }       
            }

            up = users[up].upline;
        }
    }

    function _drawPool() private {
        pool_last_draw = block.timestamp;
        pool_cycle++;

        uint256 draw_amount = pool_balance.div(10);

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            uint256 win = draw_amount.mul(pool_bonuses[i]) / 100;

            users[pool_top[i]].pool_bonus += win;
            pool_balance -= win;

            emit PoolPayout(pool_top[i], win);
        }

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
    }

    function withdraw() external {
        if (!started) {
			revert("Contract not yet started.");
		}
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received.");

        // Deposit payout   
        if(to_payout > 0) {
            if(users[msg.sender].payouts.add(to_payout) > max_payout) {
                to_payout = max_payout.sub(users[msg.sender].payouts);
            }

            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _refPayout(msg.sender, to_payout);
        }

        // Direct bonus payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].direct_bonus > 0) {
            uint256 direct_bonus = users[msg.sender].direct_bonus;

            if(users[msg.sender].payouts.add(direct_bonus) > max_payout) {
                direct_bonus = max_payout.sub(users[msg.sender].payouts);
            }

            users[msg.sender].direct_bonus -= direct_bonus;
            users[msg.sender].payouts += direct_bonus;
            userBonusStats[msg.sender].direct_bonus_withdrawn += direct_bonus;
            to_payout += direct_bonus;
        }

        // Pool payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].pool_bonus > 0) {
            uint256 pool_bonus = users[msg.sender].pool_bonus;

            if(users[msg.sender].payouts.add(pool_bonus) > max_payout) {
                pool_bonus = max_payout.sub(users[msg.sender].payouts);
            }

            users[msg.sender].pool_bonus -= pool_bonus;
            users[msg.sender].payouts += pool_bonus;
            userBonusStats[msg.sender].pool_bonus_withdrawn += pool_bonus;
            to_payout += pool_bonus;
        }

        // Match payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].match_bonus > 0) {
            uint256 match_bonus = users[msg.sender].match_bonus;

            if(users[msg.sender].payouts.add(match_bonus) > max_payout) {
                match_bonus = max_payout.sub(users[msg.sender].payouts);
            }

            users[msg.sender].match_bonus -= match_bonus;
            users[msg.sender].payouts += match_bonus;
            userBonusStats[msg.sender].match_bonus_withdrawn += match_bonus;
            to_payout += match_bonus;  
        }

        require(to_payout > 0, "User has zero dividends to payout.");
        
        //check for withdrawal tax and get final payout.
        uint _timeLimit = streakPenaltyTime;
        if(nft.getEffectStatus(9, msg.sender)) {
            _timeLimit -= nft.getBonusMultiplier(nft.getRelicActiveForBonus(msg.sender, 9));
            nft._burnHaste(msg.sender);
        }
        // uint _timeLimit = nft.getEffectStatus(9, msg.sender) ? 432000 - nft.getBonusMultiplier(nft.getRelicActiveForBonus(msg.sender, 9)) : 432000;
        if(userBonusStats[msg.sender].streak + (block.timestamp - users[msg.sender].checkpoint) < _timeLimit) {
            to_payout = to_payout * STREAK_PENALTY / PERCENTS_DIVIDER;
        }
        userBonusStats[msg.sender].streak = 1;
        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;
        users[msg.sender].checkpoint = block.timestamp;
        
        //pay investor
        uint256 payout = to_payout.sub(fees(to_payout));
        payable(address(msg.sender)).transfer(payout);
        emit Withdraw(msg.sender, payout);
        //max payout of 
        if(users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    //re-invest direct deposit payouts and direct referrals.
    function reinvest(uint8 _attribute, bool _fightBoss, address _addr, uint _rand) external {
		if (!started) {
			revert("Not started yet");
		}
        if(kvrfActivated && _fightBoss) {
            require(msg.sender == kvrfAddress);
        }
        else {
            require(msg.sender == _addr);
        }
        if(!nft.getEffectStatus(16, msg.sender)) {
            require(_attribute < 3, "No valid attribute selected");
        }
        else {
            require(_attribute < 4, "No valid attribute selected");
        }
        uint _streak = userBonusStats[_addr].streak;
        userBonusStats[_addr].streak = _streak == 0 ? 1 : _streak + block.timestamp - users[_addr].checkpoint;
        uint _chance;
        (, uint256 max_payout) = this.payoutOf(_addr);
        require(users[_addr].payouts < max_payout, "Max payout already received.");
        bool _bossDefeated;
        if(_fightBoss) {
            require(!defeatedThisRound[currentBoss][_addr], "You have already defeated this boss.");
            uint _timeLimit = nft.getEffectStatus(18, _addr) ? bossRecoveryTime - nft.getBonusMultiplier(nft.getRelicActiveForBonus(_addr, 18)) : bossRecoveryTime;
            require(block.timestamp - users[_addr].checkpoint > _timeLimit, "You must wait 12 hours before attempting to fight the boss");
            uint[6] memory _bossStats = boss.getBossStats(currentBoss);
            uint[4] memory _userStats = nft.userStats(_addr);
            _chance = _userStats[3] >= _bossStats[3] ? 70 + (_userStats[3] / 10 ** 17) - (_bossStats[3] / 10 ** 17) : (_userStats[3] / 10 ** 17) * 100 / (_bossStats[3] / 10 ** 17) / 3;
            _chance = nft.getEffectStatus(7, _addr) ? SafeMath.add(_chance, nft.getBonusMultiplier(nft.getRelicActiveForBonus(_addr, 7))) : _chance;
            _chance = _bossStats[_bossStats[5]] < _userStats[_bossStats[5]] ? _chance + 10 : _chance;
            _chance = _chance > 95 ? 95 : _chance;
            _chance = _bossStats[3] > finalBossStats && _chance > 80 ? 80 : _chance;
            if(_rand % 100 < _chance) {
                defeatedThisRound[currentBoss][_addr] = true;
                nft.mint(boss.getBossNFT(currentBoss), _addr, boss.getBossItemAmount(currentBoss));
                _bossDefeated = true;
                emit BossFight(_addr, nicknames[_addr], boss.getBossName(currentBoss), _chance, true, boss.getBossNFT(currentBoss), timesBossDefeated[currentBoss] == 0 ? true : false);
                timesBossDefeated[currentBoss]++;
            }
        }
            // Deposit payout
        uint256 to_reinvest = this.payoutToReinvest(_addr);
        userBonusStats[_addr].income_reinvested += to_reinvest;

        // Direct payout    
        uint256 direct_bonus = users[_addr].direct_bonus;
        users[_addr].direct_bonus -= direct_bonus;
        userBonusStats[_addr].bonus_reinvested += direct_bonus;
        to_reinvest += direct_bonus;

        // Pool payout
        uint256 pool_bonus = users[_addr].pool_bonus;
        users[_addr].pool_bonus -= pool_bonus;
        userBonusStats[_addr].bonus_reinvested += pool_bonus;
        to_reinvest += pool_bonus;
        
        // Match payout
        uint256 match_bonus = users[_addr].match_bonus;
        users[_addr].match_bonus -= match_bonus;
        userBonusStats[_addr].bonus_reinvested += match_bonus;
        to_reinvest += match_bonus;   

        require(to_reinvest > 0, "User has zero dividends to re-invest.");
        //add 5% more bonus for reinvest action.
        to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));
        if (_bossDefeated && _fightBoss) {
            to_reinvest = to_reinvest.mul(boss.getBossReward(currentBoss)).div(100);
        }
        if (_fightBoss && !_bossDefeated) {
            to_reinvest = nft.getEffectStatus(8, _addr) ? to_reinvest * nft.getBonusMultiplier(nft.getRelicActiveForBonus(_addr, 8)) / 100 : 0;
            emit BossFight(_addr, nicknames[_addr],  boss.getBossName(currentBoss), _chance, false, boss.getBossNFT(currentBoss), false);
        }
        to_reinvest = nft.updateStats(to_reinvest, _addr, _attribute);
        users[_addr].deposit_amount += to_reinvest;
        users[_addr].checkpoint = block.timestamp;
        userBonusStats[_addr].reinvested_gross += to_reinvest;
        
        /** to_reinvest will not be added to total_deposits, new deposits will only be added here. **/
        //users[msg.sender].total_deposits += to_reinvest;
        total_reinvested += to_reinvest;
        emit ReinvestedDeposit(_addr, to_reinvest);
        
        //_poolDeposits(msg.sender, to_reinvest);

        //_downLineDeposits(msg.sender, to_reinvest);

        if(pool_last_draw.add(TIME_STEP) < block.timestamp) {
            _drawPool();
        }
	}

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {

        max_payout = this.maxPayoutOf(users[_addr].deposit_amount);

        if(users[_addr].deposit_payouts < max_payout) {

            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(block.timestamp.sub(users[_addr].checkpoint) > 172800 ? 172800 : block.timestamp.sub(users[_addr].checkpoint))
                    .div(TIME_STEP);

            if(users[_addr].deposit_payouts.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].deposit_payouts);
            }
        }
    }

    function payoutToReinvest(address _addr) view external returns(uint256 payout) {
        if(users[_addr].deposit_payouts < this.maxPayoutOf(users[_addr].deposit_amount)) {
            
            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(block.timestamp.sub(users[_addr].checkpoint) > 172800 ? 172800 : block.timestamp.sub(users[_addr].checkpoint))
                    .div(TIME_STEP);
        }            
    
    }

    //max payout per user is 300% including initial investment.
    function maxPayoutOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(MAX_PAYOUT).div(PERCENTS_DIVIDER);
    }

    function fees(uint256 amount) internal returns(uint256){
        uint256 proj = amount.mul(DIRECTOR).div(PERCENTS_DIVIDER);
        // uint256 market = amount.mul(MARKETING).div(PERCENTS_DIVIDER);
        uint256 own = amount.mul(OWNER).div(PERCENTS_DIVIDER);

        //so no transfer will trigger when tax is set to 0.
        if(proj > 0){
            director.transfer(proj);
        }

        if(own > 0){
            owner.transfer(own);
        }


        // if(market > 0){
        //     marketing.transfer(market);
        // }

        return proj/*.add(market)*/.add(own);
    }

    function checkIfEligibleForMagicBean(address _addr) public view returns(bool) {
        if(block.timestamp - userBonusStats[_addr].beanCheckpoint > beanTimer - nft.getBonusMultiplier(nft.getRelicActiveForBonus(_addr, 20)) && users[_addr].total_direct_deposits >= 1 ether) {
            return true;
        }
        else {
            return false;
        }
    }

    function lookForMagicBean(address _addr, uint _rand) external {
        require(msg.sender == vrfAddress);
        if (_rand <= beanChance + nft.getBonusMultiplier(nft.getRelicActiveForBonus(_addr, 19))) { //WITH VRF
            gacha.sendGachaTokens(1, _addr);
            emit MagicBeanFound(_addr, nicknames[_addr], _rand);
            userBonusStats[_addr].beanStreak++;
            if(userBonusStats[_addr].beanStreak > 2) {
                emit LuckyGuy(_addr);
            }
        }
        else {
            userBonusStats[_addr].beanStreak = 0;
        }
        nft._burnBeanConsumables(_addr);
        userBonusStats[_addr].beanCheckpoint = block.timestamp;
    }

    // function withdrawalTaxPercentage(uint256 to_payout) view external returns(uint256 finalPayout) {
    //   uint256 contractBalance = address(this).balance;
	  
    //   if (to_payout < contractBalance.mul(10).div(PERCENTS_DIVIDER)) {           // 0% tax if amount is  <  1% of contract balance
    //       finalPayout = to_payout; 
    //   }else if(to_payout >= contractBalance.mul(10).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(50).div(PERCENTS_DIVIDER));  // 5% tax if amount is >=  1% of contract balance
    //   }else if(to_payout >= contractBalance.mul(20).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(100).div(PERCENTS_DIVIDER)); //10% tax if amount is >=  2% of contract balance
    //   }else if(to_payout >= contractBalance.mul(30).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(150).div(PERCENTS_DIVIDER)); //15% tax if amount is >=  3% of contract balance
    //   }else if(to_payout >= contractBalance.mul(40).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(200).div(PERCENTS_DIVIDER)); //20% tax if amount is >=  4% of contract balance
    //   }else if(to_payout >= contractBalance.mul(50).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(250).div(PERCENTS_DIVIDER)); //25% tax if amount is >=  5% of contract balance
    //   }else if(to_payout >= contractBalance.mul(60).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(300).div(PERCENTS_DIVIDER)); //30% tax if amount is >=  6% of contract balance
    //   }else if(to_payout >= contractBalance.mul(70).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(350).div(PERCENTS_DIVIDER)); //35% tax if amount is >=  7% of contract balance
    //   }else if(to_payout >= contractBalance.mul(80).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(400).div(PERCENTS_DIVIDER)); //40% tax if amount is >=  8% of contract balance
    //   }else if(to_payout >= contractBalance.mul(90).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(450).div(PERCENTS_DIVIDER)); //45% tax if amount is >=  9% of contract balance
    //   }else if(to_payout >= contractBalance.mul(100).div(PERCENTS_DIVIDER)){
    //       finalPayout = to_payout.sub(to_payout.mul(500).div(PERCENTS_DIVIDER)); //50% tax if amount is >= 10% of contract balance
    //   }
    // }

    // function _createTeam(address userAddress, bool is_referral_team) private returns(uint256 teamId){
    //     uint8 numberOfExistingTeams = user_teams_counter[userAddress];

    //     require(numberOfExistingTeams <= MAX_TEAMS_PER_ADDRESS, "Max number of teams reached.");

    //     teamId = total_teams_created++;
    //     teams[teamId].id = teamId;
    //     teams[teamId].created_at = block.timestamp;
    //     teams[teamId].owner = userAddress;
    //     teams[teamId].members.push(userAddress);
    //     teams[teamId].is_referral_team = is_referral_team;

    //     user_teams[userAddress].push(TeamInfo(teamId, true));

    //     user_teams_counter[userAddress]++;
    // }

    // function _addTeamMember(uint256 teamId, address member) private {
    //     Team storage team = teams[teamId];

    //     team.members.push(member);
    //     user_teams[member].push(TeamInfo(teamId, true));
    //     user_teams_counter[member]++;
    // }

    // function removeUserNickname() external {
    //     nicknames[msg.sender] = "";
    // }
    
    function _checkNickname(string memory name) private view returns (bool){
        // name = _toLower(name);
        // if(checkAlphaNumericStr(name) == false){
        //     return false; 
        // }
        if(bytes(name).length > MAX_LENGTH_NICKNAME){
            return false; 
        }
        if(isInUse[name]) {
            return false;
        }
        // for( uint256 i = 0; i < total_users; i++){
        //     string memory nick = nicknames[id2Address[i]];
        //     if( strcmp(nick, name)){
        //         return false;
        //     }
        // }
        return true;
    }

    function getAddressToNickname(string memory name) public view returns (address){
        for( uint256 i = 0; i < total_users; i++){
            string memory nick = nicknames[id2Address[i]];
            if( strcmp(nick, name)){
                return id2Address[i];
            }
        }

        return address(0);
    }

    function getNicknameToAddress(address _addr) public view returns (string memory nick){
        return nicknames[_addr];
    }

    function memcmp(bytes memory a, bytes memory b) internal pure returns(bool){
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
    function strcmp(string memory a, string memory b) internal pure returns(bool){
        return memcmp(bytes(a), bytes(b));
    }
    
    // function _toLower(string memory str) internal pure returns (string memory) {
    //     bytes memory bStr = bytes(str);
    //     bytes memory bLower = new bytes(bStr.length);
    //     for (uint i = 0; i < bStr.length; i++) {
    //         // Uppercase character...
    //         if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
    //             // So we add 32 to make it lowercase
    //             bLower[i] = bytes1(uint8(bStr[i]) + 32);
    //         } else {
    //             bLower[i] = bStr[i];
    //         }
    //     }
    //     return string(bLower);
    // }

    // function checkAlphaNumericStr(string memory str) public pure returns (bool){
    //     bytes memory b = bytes(str);

    //     for(uint i; i<b.length; i++){
    //         bytes1 char = b[i];

    //         if(
    //             !(char >= 0x30 && char <= 0x39) && //9-0
    //             !(char >= 0x41 && char <= 0x5A) && //A-Z
    //             !(char >= 0x61 && char <= 0x7A) //a-z
    //         ){
    //             return false;
    //         }
    //     }

    //     return true;
    // }

    function setUserNickname(string memory name, address _addr) external {
        // name = _toLower(name);
        require(msg.sender == _addr || msg.sender == owner, "Unauthorized call");
        isInUse[nicknames[msg.sender]] = false;
        require(_checkNickname(name), "nickname not valid");
        isInUse[name] = true;
        nicknames[msg.sender] = name;
    }

    function checkNickname(string memory name) external view returns (bool){
        return _checkNickname(name);
    }

    /*function userStats(address _addr) view external returns(uint[4] memory) {
            uint256[4] memory _stats;
            _stats[0] = stats[_addr].STR;
            _stats[1] = stats[_addr].DEX;
            _stats[2] = stats[_addr].INT;
            _stats[3] = stats[_addr].STR + stats[_addr].DEX + stats[_addr].INT;
            return _stats;
    }
    */
    
    function userInfo(address _addr) view external returns(address upline, uint256 checkpoint, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 pool_bonus, uint256 match_bonus) {
        return (users[_addr].upline, users[_addr].checkpoint, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].direct_bonus, users[_addr].pool_bonus, users[_addr].match_bonus);
    }

    // function userInfo2(address _addr) view external returns(uint8 teams_counter, TeamInfo[] memory member_of_teams, string memory nickname) {

    //     return (user_teams_counter[_addr], user_teams[_addr], nicknames[_addr]);
    // }

    // function userDirectTeamsInfo(address _addr) view external returns(uint256 referral_team, bool referral_team_exists, uint256 upline_team, bool upline_team_exists) {
    //     User memory user = users[_addr];

    //     return (user_referral_team[_addr].id, user_referral_team[_addr].exists, user_referral_team[user.upline].id, user_referral_team[user.upline].exists);
    // }

    // function teamInfo(uint256 teamId) view external returns(Team memory _team, string[] memory nicks) {
    //     Team memory team = teams[teamId];
    //     nicks = new string[](team.members.length);

    //     for(uint256 i = 0; i < team.members.length; i++){
    //         nicks[i] = nicknames[team.members[i]];
    //     }

    //     return (team, nicks);
    // }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure,uint256 total_downline_deposit) {
        return (users[_addr].referrals, users[_addr].total_direct_deposits, users[_addr].total_payouts, users[_addr].total_structure, users[_addr].total_downline_deposit);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _pool_last_draw, uint256 _pool_balance, uint256 _pool_lider) {
        return (total_users, total_deposited, total_withdraw, pool_last_draw, pool_balance, pool_users_refs_deposits_sum[pool_cycle][pool_top[0]]);
    }

    function poolTopInfo() view external returns(address[4] memory addrs, uint256[4] memory deps) {
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            addrs[i] = pool_top[i];
            deps[i] = pool_users_refs_deposits_sum[pool_cycle][pool_top[i]];
        }
    }

    function getBlockTimeStamp() public view returns (uint256) {
	    return block.timestamp;
	}	
		
    /** SETTERS **/
    function SET_BOSS(uint _boss) external {
        require(msg.sender == owner, "Admin use only");
        currentBoss = _boss;
        round++;
    }

    function SET_BOSS_STATS(uint _set, uint _time) external {
        require(msg.sender == owner, "Admin use only");
        finalBossStats = _set;
        bossRecoveryTime = _time;
    }

    function SET_BEAN_CHANCE(uint _chance, uint _time) external {
        require(msg.sender == owner, "Admin use only");
        beanChance = _chance;
        beanTimer = _time;
    }

    function SET_STREAK_PENALTY(uint _time, uint _penalty) external {
        require(msg.sender == owner, "Admin use only");
        STREAK_PENALTY = _penalty;
        streakPenaltyTime = _time;        
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only");
        owner = payable(value);
    }

    function CHANGE_DIRECTOR_WALLET(address value) external {
        require(msg.sender == director, "Admin use only");
        director = payable(value);
    }

    // function CHANGE_MARKETING_WALLET(address value) external {
    //     require(msg.sender == marketing , "Admin use only");
    //     marketing = payable(value);
    // }

    function CHANGE_OWNER_DIRECTOR_FEE(uint256 dValue, uint oValue) external {
        require(msg.sender == director || msg.sender == owner, "Admin use only");
        require(dValue <= 30 && oValue <= 30);
        DIRECTOR = dValue;
        OWNER = oValue;
    }

    // function CHANGE_MARKETING_FEE(uint256 value) external {
    //     require(msg.sender == marketing , "Admin use only");
    //     require(value <= 30);
    //     MARKETING = value;
    // }

    function SET_REFERRAL_PERCENT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10 &&value <= 100);
        REFERRAL = value;
    }

    function SET_REINVEST_BONUS(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 500);
        REINVEST_BONUS = value;
    }

    function SET_MAX_PAYOUT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 3000 && value <= 10000); 
        MAX_PAYOUT = value;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST = value;
    }

    function SET_MAX_WALLET_DEPOSIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MAX_WALLET_DEPOSIT = value * 1 ether;
    }

    // function SET_MAX_TEAMS_PER_ADDRESS(uint8 value) external{
    //     require(msg.sender == owner, "Admin use only");
    //     require(value >= 1);
    //     MAX_TEAMS_PER_ADDRESS = value;
    // }

    // function SET_MAX_LENGTH_NICKNAME(uint8 value) external{
    //     require(msg.sender == owner, "Admin use only");
    //     require(value >= 1);
    //     MAX_LENGTH_NICKNAME = value;
    // }

    function SET_MAX_POOL_BALANCE(uint256 value) external{
        require(msg.sender == owner, "Admin use only");
        MAX_POOL_BALANCE = value * 1 ether;
    }

    function SET_BASE_PERCENT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 200);
        BASE_PERCENT = value;
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
}

contract BossNFTs {
    function userStats(address _addr) view external returns(uint[4] memory) {}
    function getEffectStatus(uint8 _bonus, address _add) public view returns(bool) {}
    function getRelicActiveForBonus(address _add, uint8 _bonus) public view returns(uint) {}
    function getBonusMultiplier(uint _id) public view returns (uint) {}
    function mint(uint _id, address _add, uint amount) public {}
    function _burnHaste(address _addr) external {}
    function _burnBeanConsumables(address _addr) external {}
    function updateStats(uint payout, address _addr, uint8 _attribute) external returns(uint) {}
    
}

contract BeanQuestGacha {
    function sendGachaTokens(uint _amount, address receiver) public {}
    function checkFightBoss(address _addr) external view returns(bool) {}
}

contract BossContract {
    function getBossStats(uint _id) external view returns(uint[6] memory) {}
    function getBossReward(uint _id) external view returns (uint) {} 
    function getBossNFT(uint _id) external view returns (uint) {}
    function getBossItemAmount(uint _id) external view returns(uint) {}
    function getBossName(uint _id) external view returns (string memory) {} 

}