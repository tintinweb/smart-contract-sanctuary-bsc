// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract We_Earn_upgradable_V1 is Initializable, OwnableUpgradeable {

    using SafeMath for uint256;
    using SafeMath for uint8;

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

    struct Airdrop {
        uint256 airdrops;
        uint256 airdrops_sent;
        uint256 airdrops_sent_count;
        uint256 airdrops_received;
        uint256 airdrops_received_count;
        uint256 last_airdrop;
        uint256 last_airdrop_received;
        uint256 airdrop_bonus;
    }

    struct Team {
        address[] members; // owner is also in member-array!
        address owner; // owner is able to add users
        uint256 id;
        uint256 created_at;
        string name;
        bool is_referral_team; // first team of upline-user is the referral team. all ref users are added automatically
    }

    struct TeamInfo {
        uint256 id;
        bool exists;
    }

    struct UserBonusStats {
        uint256 direct_bonus_withdrawn;
        uint256 match_bonus_withdrawn;
        uint256 pool_bonus_withdrawn;
        uint256 airdrops_withdrawn;
        uint256 income_reinvested;
        uint256 bonus_reinvested;
        uint256 airdrops_reinvested;
        uint256 reinvested_gross;
    }
		
	mapping(address => address) public uplinesOld;
	    
    mapping(address => UserBonusStats) public userBonusStats;
    mapping(address => string) nicknames;
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    mapping(address => Airdrop) public airdrops;
    mapping(uint256 => Team) public teams;
    mapping(address => uint8) public user_teams_counter; // holds the number of teams of a user
    mapping(address => TeamInfo[]) public user_teams;
    mapping(address => TeamInfo) public user_referral_team;

    // address payable public owner;
    address payable public project;
    address payable public community;

    uint256 public REFERRAL;
    uint256 public PROJECT;
	uint256 public COMMUNITY;
    uint256 public AIRDROP; // 0% Tax on airdrop
    uint256 public REINVEST_BONUS;
    uint256 public MAX_PAYOUT;
    uint256 public BASE_PERCENT;
    uint256 public TIME_STEP;
    uint8 public MAX_TEAMS_PER_ADDRESS;
    uint8 public MAX_LENGTH_NICKNAME;
    uint256 constant public PERCENTS_DIVIDER = 1000;

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
    uint256 public total_airdrops;
    uint256 public total_teams_created;

    bool public started;
    bool public airdrop_enabled;
    uint256 public MIN_INVEST; //0.1 BNB
    uint256 public AIRDROP_MIN; //0.1 BNB
    uint256 public MAX_WALLET_DEPOSIT; //25 BNB
    uint256 public MAX_POOL_BALANCE; //25 BNB

    bool public KEEP_TAXES_IN_CONTRACT;

    mapping(address => uint256) public usersRealDepositsBeforeMigration;
    uint256 public MAX_REINVEST_MULTIPLIER;
    uint256 public MAX_PAYOUT_CAP; // no wallet can withdraw more than this

    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event PoolPayout(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint256 amount);
    event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    // function initialize(address payable projectAddress, address payable communityAddress) public initializer  {
    //     require(!isContract(projectAddress) && !isContract(communityAddress));
	// 	project = projectAddress;
	// 	community = communityAddress;

    //     total_users = 1;
    //     REFERRAL = 50;
    //     PROJECT = 10;
    //     COMMUNITY = 90;
    //     AIRDROP = 0; // 0% Tax on airdrop
    //     REINVEST_BONUS = 50;
    //     MAX_PAYOUT = 3650;
    //     BASE_PERCENT = 15;
    //     TIME_STEP = 1 days;
    //     MAX_TEAMS_PER_ADDRESS = 6;
    //     MAX_LENGTH_NICKNAME = 10;
    //     pool_last_draw = block.timestamp;

    //     MIN_INVEST = 1 * 1e17; //0.1 BNB
    //     AIRDROP_MIN = 1 * 1e17; //0.1 BNB
    //     MAX_WALLET_DEPOSIT = 25 ether; //25 BNB
    //     MAX_POOL_BALANCE = 25 ether; //25 BNB
    //     MAX_REINVEST_MULTIPLIER = 500; // default value before upgrade to avoid stopping rewards. ste this to 5 after execution of MigrateUserForSustainabilityUpgrade
    //     MAX_PAYOUT_CAP = 200 ether; // no wallet can get more than 200 bnb

    //     __Ownable_init();

    //     ref_bonuses.push(10);
    //     ref_bonuses.push(10);
    //     ref_bonuses.push(10);
    //     ref_bonuses.push(10);
    //     ref_bonuses.push(10);
    //     ref_bonuses.push(7);
    //     ref_bonuses.push(7);
    //     ref_bonuses.push(7);
    //     ref_bonuses.push(7);
    //     ref_bonuses.push(7);
    //     ref_bonuses.push(5);
    //     ref_bonuses.push(5);
    //     ref_bonuses.push(5);
    //     ref_bonuses.push(5);
    //     ref_bonuses.push(5);

    //     pool_bonuses.push(25);
    //     pool_bonuses.push(20);
    //     pool_bonuses.push(15);
    //     pool_bonuses.push(10);
    // }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
	
	receive() external payable {
        
    }

    //deposit_amount -- can only be done by the project address for first deposit.
    function deposit() payable external {
        _deposit(msg.sender, msg.value);
    }

    //deposit with upline
    function deposit(address _upline) payable external {
        require(started, "CNT not started");
				
		if(uplinesOld[msg.sender] != address(0)) {
            _setUpline(msg.sender, uplinesOld[msg.sender]);
		} else {
			_setUpline(msg.sender, _upline);
		}
        _deposit(msg.sender, msg.value);
    }

    //deposit with upline NICKNAME
    function depositWithNickname(string calldata _nickname) payable external {
        require(started, "CNT not started");
        if(uplinesOld[msg.sender] != address(0)) {
			_setUpline(msg.sender, uplinesOld[msg.sender]);
        } else {
            address _upline = getAddressToNickname(_nickname);
            require(_upline != address(0), "nick not found");        
            _setUpline(msg.sender, _upline);
        }
        _deposit(msg.sender, msg.value);
    }

    //invest
    function _deposit(address _addr, uint256 _amount) private {
        if (!started) {
    		if (msg.sender == project) {
    			started = true;
    		} else revert("CNT not started");
    	}
        
        require(users[_addr].upline != address(0) || _addr == project, "No upline");
        require(_amount >= MIN_INVEST, "Min investment not met");
        require(users[_addr].total_direct_deposits.add(_amount) <= MAX_WALLET_DEPOSIT, "Max limit reached");

        if(users[_addr].deposit_amount == 0 ){ // new user
            id2Address[total_users] = _addr;
            total_users++;
        }

        // reinvest before deposit because the checkpoint gets an reset here
        uint256 to_reinvest = this.payoutToReinvest(msg.sender);
        if(to_reinvest > 0 && users[_addr].deposit_amount.add(_amount) < this.maxReinvestOf(users[_addr].total_direct_deposits)){
            userBonusStats[msg.sender].income_reinvested += to_reinvest;
            to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER)); //add 5% more bonus for reinvest action.
            users[msg.sender].deposit_amount += to_reinvest;	
            userBonusStats[msg.sender].reinvested_gross += to_reinvest;        
            total_reinvested += to_reinvest;
            emit ReinvestedDeposit(msg.sender, to_reinvest);
        }

        // deposit
        users[_addr].deposit_amount += _amount;
        users[_addr].checkpoint = block.timestamp;
        users[_addr].total_direct_deposits += _amount;

        total_deposited += _amount;

        emit NewDeposit(_addr, _amount);
        if(users[_addr].upline != address(0)) {
            //direct referral bonus 5%
            uint256 refBonus = _amount.mul(REFERRAL).div(PERCENTS_DIVIDER);

			if(users[users[_addr].upline].checkpoint > 0 && users[users[_addr].upline].deposit_amount < this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits)) {

                if(users[users[_addr].upline].deposit_amount.add(refBonus) > this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits)){
                    refBonus = this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits).sub(users[users[_addr].upline].deposit_amount);
                }

                users[users[_addr].upline].direct_bonus += refBonus;
                emit DirectPayout(users[_addr].upline, _addr, refBonus);

                _poolDeposits(_addr, _amount);
			}
        }

        
        _downLineDeposits(_addr, _amount);

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
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != project && (users[_upline].checkpoint > 0 || _upline == project)) {
            isValid = true;        
        }
    }

    function _setUpline(address _addr, address _upline) private {
        if(this.checkUplineValid(_addr, _upline)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            if(user_referral_team[_upline].exists == false){
                uint256 teamId = _createTeam(_upline, true); // create first team on upline-user. this contains the direct referrals
                user_referral_team[_upline].id = teamId;
                user_referral_team[_upline].exists = true;
            }

            // check if current user is in ref-team
            bool memberExists = false;
            for(uint256 i = 0; i < teams[user_referral_team[_upline].id].members.length; i++){
                if(teams[user_referral_team[_upline].id].members[i] == _addr){
                    memberExists = true;
                }
            }
            if(memberExists == false){
                _addTeamMember(user_referral_team[_upline].id, _addr); // add referral user to upline users referral-team
            }

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

        if(upline == address(0) || upline == project) return;

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

            if(users[up].referrals >= i.add(1) && users[up].deposit_amount.add(_amount) < this.maxReinvestOf(users[up].total_direct_deposits)) {
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

            //if( users[pool_top[i]].deposit_amount.add(win) < this.maxReinvestOf(users[pool_top[i]].total_direct_deposits) ){
                users[pool_top[i]].pool_bonus += win;
                pool_balance -= win;

                emit PoolPayout(pool_top[i], win);
            //}
        }

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
    }

    function withdraw() external {
        if (!started) {
			revert("CNT not started");
		}
        
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received");
        require(users[msg.sender].payouts < MAX_PAYOUT_CAP, "Max payout cap 200bnb reached");

        // Deposit payout
        if(to_payout > 0) {
            if(users[msg.sender].payouts.add(to_payout) > max_payout) {
                to_payout = max_payout.sub(users[msg.sender].payouts);
            }
            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _refPayout(msg.sender, to_payout);
        }

        // Direct bonnus payout
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

        // Airdrop payout
        if(users[msg.sender].payouts < max_payout && airdrops[msg.sender].airdrop_bonus > 0) {
            uint256 airdrop_bonus = airdrops[msg.sender].airdrop_bonus;

            if(users[msg.sender].payouts.add(airdrop_bonus) > max_payout) {
                airdrop_bonus = max_payout.sub(users[msg.sender].payouts);
            }

            airdrops[msg.sender].airdrop_bonus -= airdrop_bonus;
            users[msg.sender].payouts += airdrop_bonus;
            userBonusStats[msg.sender].airdrops_withdrawn += airdrop_bonus;
            to_payout += airdrop_bonus;  
            
        }

        if(users[msg.sender].total_payouts.add(to_payout) > MAX_PAYOUT_CAP) {
            to_payout = MAX_PAYOUT_CAP.sub(users[msg.sender].payouts); // only allow the amount up to MAX_PAYOUT_CAP
        }

        require(to_payout > 0, "User has zero dividends payout");
        //check for withdrawal tax and get final payout.
        to_payout = this.withdrawalTaxPercentage(to_payout);
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
    function reinvest() external {
		if (!started) {
			revert("Not started");
		}

        (, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received");

        // Deposit payout
        uint256 to_reinvest = this.payoutToReinvest(msg.sender);

        userBonusStats[msg.sender].income_reinvested += to_reinvest;

        // Direct payout
        uint256 direct_bonus = users[msg.sender].direct_bonus;
        users[msg.sender].direct_bonus -= direct_bonus;
        userBonusStats[msg.sender].bonus_reinvested += direct_bonus;
        to_reinvest += direct_bonus;

        // Pool payout
        uint256 pool_bonus = users[msg.sender].pool_bonus;
        users[msg.sender].pool_bonus -= pool_bonus;
        userBonusStats[msg.sender].bonus_reinvested += pool_bonus;
        to_reinvest += pool_bonus;
        
        // Match payout
        uint256 match_bonus = users[msg.sender].match_bonus;
        users[msg.sender].match_bonus -= match_bonus;
        userBonusStats[msg.sender].bonus_reinvested += match_bonus;
        to_reinvest += match_bonus;    

        // Airdrop payout
        uint256 airdrop_bonus = airdrops[msg.sender].airdrop_bonus;
        airdrops[msg.sender].airdrop_bonus -= airdrop_bonus;
        userBonusStats[msg.sender].airdrops_reinvested += airdrop_bonus;
        to_reinvest += airdrop_bonus; 

        require(to_reinvest > 0, "User has zero dividends re-invest");
        //add 5% more bonus for reinvest action.
        to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));

        //check the reinvest amount if already exceeds 5x max re-investment
        uint256 finalReinvestAmount = reinvestAmountOf(msg.sender, to_reinvest);

        users[msg.sender].deposit_amount += finalReinvestAmount;
        users[msg.sender].checkpoint = block.timestamp;
        userBonusStats[msg.sender].reinvested_gross += finalReinvestAmount;        
        /** to_reinvest will not be added to total_deposits, new deposits will only be added here. **/
        //users[msg.sender].total_deposits += to_reinvest;
        total_reinvested += finalReinvestAmount;
        emit ReinvestedDeposit(msg.sender, finalReinvestAmount);
        
        if(pool_last_draw.add(TIME_STEP) < block.timestamp) {
            _drawPool();
        }
	}

    function reinvestAmountOf(address _addr, uint256 _toBeRolledAmount) view public returns(uint256 reinvestAmount) {
        
        //validate the total amount that can be rolled is 5x the users real deposit only.
        uint256 maxReinvestAmount = this.maxReinvestOf(users[_addr].total_direct_deposits); 

        reinvestAmount = _toBeRolledAmount; 

        if(users[_addr].deposit_amount >= maxReinvestAmount) { // user already got max reinvest
            revert("User exceeded x5 of tot deposit to be rolled");
        }

        if(users[_addr].deposit_amount.add(reinvestAmount) >= maxReinvestAmount) { // user will reach max reinvest with current reinvest
            reinvestAmount = maxReinvestAmount.sub(users[_addr].deposit_amount); // only let him reinvest until max reinvest is reached
        }        
    }

    //max reinvestment per user is 5x user deposit.
    function maxReinvestOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(MAX_REINVEST_MULTIPLIER);
    }

    function airdrop(address _to) payable external {
        require(airdrop_enabled, "Airdrop not enabled");

        address _addr = msg.sender;
        uint256 _amount = msg.value;

        require(_amount >= AIRDROP_MIN, "Min airdrop amount not met");

        if( users[_to].deposit_amount.add(_amount) >= this.maxReinvestOf(users[_to].total_direct_deposits) ){
            revert("User exceeded x5 of total deposit");
        }

        // transfer to recipient        
        uint256 project_fee = _amount.mul(AIRDROP).div(PERCENTS_DIVIDER); // tax on airdrop if enabled
        uint256 payout = _amount.sub(project_fee);
        if(project_fee > 0){
            project.transfer(project_fee);
        }

        //Make sure _to exists in the system; we increase
        require(users[_to].upline != address(0), "_to not found");

        //Fund to airdrop bonus (not a transfer - user will be able to claim/reinvest)
        airdrops[_to].airdrop_bonus += payout;

        //User stats
        airdrops[_addr].airdrops += payout; // sender
        airdrops[_addr].last_airdrop = block.timestamp; // sender
        airdrops[_addr].airdrops_sent += payout; // sender
        airdrops[_addr].airdrops_sent_count = airdrops[_addr].airdrops_sent_count.add(1); // sender add count for airdrop sent count
        airdrops[_to].airdrops_received += payout; // recipient
        airdrops[_to].airdrops_received_count = airdrops[_to].airdrops_received_count.add(1); // recipient add count for airdrop received count
        airdrops[_to].last_airdrop_received = block.timestamp; // recipient

        //Keep track of overall stats
        total_airdrops += payout;

        emit NewAirdrop(_addr, _to, payout, block.timestamp);
    }

    function teamAirdrop(uint256 teamId, bool excludeOwner) payable external {
        require(airdrop_enabled, "Airdrop not enabled");
        
        address _addr = msg.sender;
        uint256 _amount = msg.value;
        
        require(_amount >= AIRDROP_MIN, "Min airdrop amount not met");

        // transfer to recipient        
        uint256 project_fee = _amount.mul(AIRDROP).div(PERCENTS_DIVIDER); // tax on airdrop
        uint256 payout = _amount.sub(project_fee);
        if(project_fee > 0){
            project.transfer(project_fee);
        }

        //Make sure _to exists in the system; we increase
        require(teams[teamId].owner != address(0), "team not found");

        uint256 memberDivider = teams[teamId].members.length;
        if(excludeOwner == true){
            memberDivider--;
        }
        uint256 amountDivided = _amount.div(memberDivider);

        for(uint8 i = 0; i < teams[teamId].members.length; i++){

            address _to = address(teams[teamId].members[i]);
            if(excludeOwner == true && _to == teams[teamId].owner){
                continue;
            }
            //Fund to airdrop bonus (not a transfer - user will be able to claim/reinvest)
            airdrops[_to].airdrop_bonus += amountDivided;
    
            //User stats
            airdrops[_addr].airdrops += amountDivided; // sender
            airdrops[_addr].last_airdrop = block.timestamp; // sender
            airdrops[_addr].airdrops_sent += amountDivided; // sender
            airdrops[_addr].airdrops_sent_count = airdrops[_addr].airdrops_sent_count.add(1); // sender add count for airdrop sent count
            airdrops[_to].airdrops_received += amountDivided; // recipient
            airdrops[_to].airdrops_received_count = airdrops[_to].airdrops_received_count.add(1); // recipient add count for airdrop received count
            airdrops[_to].last_airdrop_received = block.timestamp; // recipient

            emit NewAirdrop(_addr, _to, payout, block.timestamp);
        }

        //Keep track of overall stats
        total_airdrops += payout;
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {

        max_payout = this.maxPayoutOf(users[_addr].deposit_amount);

        if(users[_addr].deposit_payouts < max_payout) {

            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(block.timestamp.sub(users[_addr].checkpoint))
                    .div(TIME_STEP);

            if(users[_addr].deposit_payouts.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].deposit_payouts);

            }
        }
    }

    function payoutToReinvest(address _addr) view external returns(uint256 payout) {
        
        uint256 max_payout = this.maxPayoutOf(users[_addr].deposit_amount);

        if(users[_addr].deposit_payouts < max_payout) {

            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(block.timestamp.sub(users[_addr].checkpoint))
                    .div(TIME_STEP);
        }            
    }

    //max payout per user is 300% including initial investment.
    function maxPayoutOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(MAX_PAYOUT).div(PERCENTS_DIVIDER);
    }

    function fees(uint256 amount) internal returns(uint256){
        uint256 proj = amount.mul(PROJECT).div(PERCENTS_DIVIDER);
        uint256 market = amount.mul(COMMUNITY).div(PERCENTS_DIVIDER);

        if(KEEP_TAXES_IN_CONTRACT == false){
            //so no transfer will trigger when tax is set to 0.
            if(proj > 0){
                project.transfer(proj);
            }

            if(market > 0){
                community.transfer(market);
            }
        }

        return proj.add(market);
    }


    function withdrawalTaxPercentage(uint256 to_payout) view external returns(uint256 finalPayout) {
      uint256 contractBalance = address(this).balance;
	  
      if (to_payout < contractBalance.mul(10).div(PERCENTS_DIVIDER)) {           // 0% tax if amount is  <  1% of contract balance
          finalPayout = to_payout; 
      }else if(to_payout >= contractBalance.mul(10).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(50).div(PERCENTS_DIVIDER));  // 5% tax if amount is >=  1% of contract balance
      }else if(to_payout >= contractBalance.mul(20).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(100).div(PERCENTS_DIVIDER)); //10% tax if amount is >=  2% of contract balance
      }else if(to_payout >= contractBalance.mul(30).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(150).div(PERCENTS_DIVIDER)); //15% tax if amount is >=  3% of contract balance
      }else if(to_payout >= contractBalance.mul(40).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(200).div(PERCENTS_DIVIDER)); //20% tax if amount is >=  4% of contract balance
      }else if(to_payout >= contractBalance.mul(50).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(250).div(PERCENTS_DIVIDER)); //25% tax if amount is >=  5% of contract balance
      }else if(to_payout >= contractBalance.mul(60).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(300).div(PERCENTS_DIVIDER)); //30% tax if amount is >=  6% of contract balance
      }else if(to_payout >= contractBalance.mul(70).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(350).div(PERCENTS_DIVIDER)); //35% tax if amount is >=  7% of contract balance
      }else if(to_payout >= contractBalance.mul(80).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(400).div(PERCENTS_DIVIDER)); //40% tax if amount is >=  8% of contract balance
      }else if(to_payout >= contractBalance.mul(90).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(450).div(PERCENTS_DIVIDER)); //45% tax if amount is >=  9% of contract balance
      }else if(to_payout >= contractBalance.mul(100).div(PERCENTS_DIVIDER)){
          finalPayout = to_payout.sub(to_payout.mul(500).div(PERCENTS_DIVIDER)); //50% tax if amount is >= 10% of contract balance
      }
    }

    function _createTeam(address userAddress, bool is_referral_team) private returns(uint256 teamId){
        uint8 numberOfExistingTeams = user_teams_counter[userAddress];
        require(numberOfExistingTeams <= MAX_TEAMS_PER_ADDRESS, "Max num of teams reached");

        teamId = total_teams_created++;
        teams[teamId].id = teamId;
        teams[teamId].created_at = block.timestamp;
        teams[teamId].owner = userAddress;
        teams[teamId].members.push(userAddress);
        teams[teamId].is_referral_team = is_referral_team;

        user_teams[userAddress].push(TeamInfo(teamId, true));

        user_teams_counter[userAddress]++;
    }

    function _addTeamMember(uint256 teamId, address member) private {
        // on private call, there is no limit on memers. if someone has many referras, the referral team can get huge
        // also no check if member is invested since the addTeamMember is used in setUpline before the investment
        Team storage team = teams[teamId];

        team.members.push(member);
        user_teams[member].push(TeamInfo(teamId, true));
        user_teams_counter[member]++;
    }

    function removeUserNickname() external {
        nicknames[msg.sender] = "";
    }
    
    function _checkNickname(string memory name) private view returns (bool){
        name = _toLower(name);
        if(checkAlphaNumericStr(name) == false){
            return false; // illegal characters
        }
        if(bytes(name).length > MAX_LENGTH_NICKNAME){
            return false; // too long str
        }
        for( uint256 i = 0; i < total_users; i++){
            string memory nick = nicknames[id2Address[i]];
            if( strcmp(nick, name)){
                return false;
            }
        }
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

    // string helper function --- START
    //
    function memcmp(bytes memory a, bytes memory b) internal pure returns(bool){
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
    function strcmp(string memory a, string memory b) internal pure returns(bool){
        return memcmp(bytes(a), bytes(b));
    }
    
    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function checkAlphaNumericStr(string memory str) public pure returns (bool){
        bytes memory b = bytes(str);

        for(uint i; i<b.length; i++){
            bytes1 char = b[i];

            if(
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) //a-z
            ){
                return false;
            }
        }

        return true;
    }
    //
    // string helper functions --- END

    /*
        Only external call
    */

    function setUserNickname(string memory name) external {
        name = _toLower(name);
        require(_checkNickname(name), "invalid nickname");
        nicknames[msg.sender] = name;
    }

    function checkNickname(string memory name) external view returns (bool){
        return _checkNickname(name);
    }

    function userInfo(address _addr) view external returns(address upline, uint256 checkpoint, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 pool_bonus, uint256 match_bonus) {
        return (users[_addr].upline, users[_addr].checkpoint, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].direct_bonus, users[_addr].pool_bonus, users[_addr].match_bonus);
    }

    function userInfo2(address _addr) view external returns(uint256 last_airdrop, uint8 teams_counter, TeamInfo[] memory member_of_teams, string memory nickname, uint256 airdrop_bonus) {

        return (airdrops[_addr].last_airdrop, user_teams_counter[_addr], user_teams[_addr], nicknames[_addr], airdrops[_addr].airdrop_bonus);
    }

    function userDirectTeamsInfo(address _addr) view external returns(uint256 referral_team, bool referral_team_exists, uint256 upline_team, bool upline_team_exists) {
        User memory user = users[_addr];

        return (user_referral_team[_addr].id, user_referral_team[_addr].exists, user_referral_team[user.upline].id, user_referral_team[user.upline].exists);
    }

    function teamInfo(uint256 teamId) view external returns(Team memory _team, string[] memory nicks) {
        Team memory team = teams[teamId];
        nicks = new string[](team.members.length);

        for(uint256 i = 0; i < team.members.length; i++){
            nicks[i] = nicknames[team.members[i]];
        }

        return (team, nicks);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure,uint256 total_downline_deposit, uint256 airdrops_total, uint256 airdrops_received) {
        return (users[_addr].referrals, users[_addr].total_direct_deposits, users[_addr].total_payouts, users[_addr].total_structure, users[_addr].total_downline_deposit, airdrops[_addr].airdrops, airdrops[_addr].airdrops_received);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _pool_last_draw, uint256 _pool_balance, uint256 _pool_lider, uint256 _total_airdrops) {
        return (total_users, total_deposited, total_withdraw, pool_last_draw, pool_balance, pool_users_refs_deposits_sum[pool_cycle][pool_top[0]], total_airdrops);
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

    function CHANGE_PROJECT_WALLET(address value) external onlyOwner{
        project = payable(value);
    }

    function CHANGE_COMMUNITY_WALLET(address value) external onlyOwner{
        community = payable(value);
    }

    function CHANGE_KEEP_TAXES_IN_CONTRACT(bool value) external onlyOwner{
        KEEP_TAXES_IN_CONTRACT = value;
    }

    function CHANGE_PROJECT_FEE(uint256 value) external onlyOwner{
        require(value <= 100);
        PROJECT = value;
    }

    function CHANGE_COMMUNITY_FEE(uint256 value) external onlyOwner{
        require(value <= 100);
        COMMUNITY = value;
    }

    function CHANGE_AIRDROP_FEE(uint256 value) external onlyOwner{
        require(value <= 100);
        AIRDROP = value;
    }

    function SET_REFERRAL_PERCENT(uint256 value) external onlyOwner{
        require(value >= 10 &&value <= 100);
        REFERRAL = value;
    }

    function SET_REINVEST_BONUS(uint256 value) external onlyOwner{
        require(value <= 500);
        REINVEST_BONUS = value;
    }

    function SET_MAX_PAYOUT(uint256 value) external onlyOwner{
        require(value >= 3000 && value <= 10000); 
        MAX_PAYOUT = value;
    }

    function SET_INVEST_MIN(uint256 value) external onlyOwner{
        MIN_INVEST = value;
    }

    function SET_AIRDROP_MIN(uint256 value) external onlyOwner{
        AIRDROP_MIN = value;
    }
    
    function SET_MAX_WALLET_DEPOSIT(uint256 value) external onlyOwner{
        MAX_WALLET_DEPOSIT = value * 1 ether;
    }

    function SET_MAX_POOL_BALANCE(uint256 value) external onlyOwner{
        MAX_POOL_BALANCE = value * 1 ether;
    }
    
    function ENABLE_AIRDROP(bool value) external onlyOwner{
        airdrop_enabled = value;
    }

    function SET_MAX_REINVEST_MULTIPLIER(uint256 value) external onlyOwner{
        MAX_REINVEST_MULTIPLIER = value;
    } 

    function SET_STARTED(bool value) external onlyOwner{
		started = value;																					  
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}