/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IToken {
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

contract UltimateYield {
    using SafeMath for uint256;
    using SafeMath for uint8;

     struct User {
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 direct_bonus;
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
        uint256 airdrops_withdrawn;
        uint256 income_reinvested;
        uint256 bonus_reinvested;
        uint256 airdrops_reinvested;
        uint256 reinvested_gross;
    }
		    
    mapping(address => UserBonusStats) public userBonusStats;
    mapping(address => User) public users;
    mapping(address => Airdrop) public airdrops;
    mapping(uint256 => Team) public teams;
    mapping(address => uint8) public user_teams_counter; // holds the number of teams of a user
    mapping(address => TeamInfo[]) public user_teams;
    mapping(address => TeamInfo) public user_referral_team;

    address public owner;

    uint256 public REFERRAL;
    uint256 public SUSTAINABILITY;
    uint256 public AIRDROP; // 0% Tax on airdrop
    uint256 public REINVEST_BONUS;
    uint256 public MAX_PAYOUT;
    uint256 public BASE_PERCENT;
    uint256 public TIME_STEP;
    uint8 public MAX_TEAMS_PER_ADDRESS;
    uint256 constant public PERCENTS_DIVIDER = 1000;

    uint8[] public ref_bonuses;
    uint256 constant public ref_depth = 10;

    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    uint256 public total_reinvested;
    uint256 public total_airdrops;
    uint256 public total_teams_created;

    bool public started;
    bool public initialized;
    bool public airdrop_enabled;
    uint256 public MIN_INVEST;
    uint256 public AIRDROP_MIN;
    uint256 public MAX_WALLET_DEPOSIT;

    bool public KEEP_TAXES_IN_CONTRACT;

    uint256 public MAX_REINVEST_MULTIPLIER;
    uint256 public MAX_PAYOUT_CAP;
	
	mapping(address => uint8) public user_reinvest_count;
	uint256 public ACTION_COOLDOWN;
    uint256 public MAX_ACCUMULATION;
    uint8 public MANDATORY_REINVEST_COUNT;
	bool public MANDATORY_REINVEST_ENABLED;

    IToken public tokenERC;

    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint256 amount);
    event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    function initialize(address erctokenAddress) external{
		require(!initialized);
        require(isContract(erctokenAddress));	
        owner = msg.sender; //owner is marketing wallet
        tokenERC = IToken(erctokenAddress);

        MIN_INVEST = 1 * 1e18; // 1 erctoken
        AIRDROP_MIN = 1 * 1e17; //0.1 erctoken
        MAX_WALLET_DEPOSIT = 50000 ether; //50K erctoken
        MAX_REINVEST_MULTIPLIER = 5;
        ACTION_COOLDOWN = 24 * 60 * 60;
        MAX_ACCUMULATION = 48 * 60 * 60;

        total_users = 1;
        REFERRAL = 50;
        SUSTAINABILITY = 100;
        AIRDROP = 10;
        REINVEST_BONUS = 30;
        MAX_PAYOUT = 3650;
        BASE_PERCENT = 12;// 1.2
        TIME_STEP = 1 days;
        MAX_TEAMS_PER_ADDRESS = 6;

        //depth 10
        ref_bonuses.push(8);
        ref_bonuses.push(8);
        ref_bonuses.push(8);
        ref_bonuses.push(8);
        ref_bonuses.push(8);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);

        initialized = true;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    //deposit_amount -- can only be done by the owner address for first deposit.
    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount);
    }

    //deposit with upline
    function deposit(address _upline, uint256 amount) external {
        if (!started) {
			revert("Contract not yet started.");
		}	
		_setUpline(msg.sender, _upline);
        _deposit(msg.sender, amount);
    }

    //invest
    function _deposit(address _addr, uint256 _amount) private {
        if (!started) {
			revert("Contract not yet started.");
		}
        require(users[_addr].upline != address(0) || _addr == owner, "No upline");
        require(_amount >= MIN_INVEST, "Mininum investment not met.");
        require(users[_addr].total_direct_deposits.add(_amount) <= MAX_WALLET_DEPOSIT, "Max deposit limit reached.");

        tokenERC.transferFrom(address(msg.sender), address(this), _amount);

        if(users[_addr].deposit_amount == 0 ){
            total_users++;
        }

        // reinvest before deposit because the checkpoints will reset
        uint256 to_reinvest = this.payoutToReinvest(msg.sender);
        if(to_reinvest > 0 && users[_addr].deposit_amount.add(_amount) < this.maxReinvestOf(users[_addr].total_direct_deposits)){
            userBonusStats[msg.sender].income_reinvested += to_reinvest;
            to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));
            users[msg.sender].deposit_amount += to_reinvest;	
            userBonusStats[msg.sender].reinvested_gross += to_reinvest;        
            total_reinvested += to_reinvest;
            emit ReinvestedDeposit(msg.sender, to_reinvest);
        }

        // deposit
        uint256 amount = _amount.sub(_amount.mul(SUSTAINABILITY).div(PERCENTS_DIVIDER));
        users[_addr].deposit_amount += amount;
        users[_addr].checkpoint = block.timestamp;
        users[_addr].total_direct_deposits += amount;

        total_deposited += amount;

        emit NewDeposit(_addr, amount);
        
        if(users[_addr].upline != address(0)) {
            //direct referral bonus 5%
            uint256 refBonus = amount.mul(REFERRAL).div(PERCENTS_DIVIDER);

			if(users[users[_addr].upline].checkpoint > 0 && users[users[_addr].upline].deposit_amount < this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits)) {

                if(users[users[_addr].upline].deposit_amount.add(refBonus) > this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits)){
                    refBonus = this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits).sub(users[users[_addr].upline].deposit_amount);
                }

                users[users[_addr].upline].direct_bonus += refBonus;
                emit DirectPayout(users[_addr].upline, _addr, refBonus);
			}
        }
        
        _downLineDeposits(_addr, amount);

    }

    function checkUplineValid(address _addr, address _upline) external view returns (bool isValid) {	
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner && (users[_upline].checkpoint > 0 || _upline == owner)) {
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
                if(users[up].checkpoint > block.timestamp.sub(MAX_ACCUMULATION)){  // 48h accumulation stop
                    uint256 bonus = _amount * ref_bonuses[i] / 100;
                    if(users[up].checkpoint!= 0) { // only pay match payout if user is present
                        users[up].match_bonus += bonus;
                        emit MatchPayout(up, _addr, bonus);   
                    }     
                }  
            }

            up = users[up].upline;
        }
    }

    function withdraw() external {
        if (!started) {
			revert("Contract not yet started.");
		}

		if(MANDATORY_REINVEST_ENABLED){
            // check if the the user has not reached max reinvest multiplier of real deposits, if has reached max, no more compound only claim.
            if(users[msg.sender].deposit_amount <= this.maxReinvestOf(users[msg.sender].total_direct_deposits)){
			    require(user_reinvest_count[msg.sender] >= MANDATORY_REINVEST_COUNT, "User is required to reinvest 3 times before being allowed to withdraw." );
            }
		}

        if(users[msg.sender].checkpoint.add(ACTION_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after action cooldown.");
        
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received.");

        if(to_payout > 0) {
            if(users[msg.sender].payouts.add(to_payout) > max_payout) {
                to_payout = max_payout.sub(users[msg.sender].payouts);
            }

            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _refPayout(msg.sender, to_payout);
        }

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

        require(to_payout > 0, "User has zero dividends payout.");
        to_payout = this.withdrawalTaxPercentage(to_payout);
        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;
        users[msg.sender].checkpoint = block.timestamp;
        
        uint256 payout = to_payout.sub(to_payout.mul(SUSTAINABILITY).div(PERCENTS_DIVIDER));
        tokenERC.transfer(msg.sender, payout);
		if(MANDATORY_REINVEST_ENABLED){
			user_reinvest_count[msg.sender] = 0;
		}

        emit Withdraw(msg.sender, payout);

        if(users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    function compound() external {
		if (!started) {
			revert("Not started yet");
		}

		if(MANDATORY_REINVEST_ENABLED){
			if(users[msg.sender].checkpoint.add(ACTION_COOLDOWN) > block.timestamp) revert("Reinvestment can only be done after action cooldown.");
		}

        (, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received.");

        uint256 to_reinvest = this.payoutToReinvest(msg.sender);

        userBonusStats[msg.sender].income_reinvested += to_reinvest;

        uint256 direct_bonus = users[msg.sender].direct_bonus;
        users[msg.sender].direct_bonus -= direct_bonus;
        userBonusStats[msg.sender].bonus_reinvested += direct_bonus;
        to_reinvest += direct_bonus;
        
        uint256 match_bonus = users[msg.sender].match_bonus;
        users[msg.sender].match_bonus -= match_bonus;
        userBonusStats[msg.sender].bonus_reinvested += match_bonus;
        to_reinvest += match_bonus;    

        uint256 airdrop_bonus = airdrops[msg.sender].airdrop_bonus;
        airdrops[msg.sender].airdrop_bonus -= airdrop_bonus;
        userBonusStats[msg.sender].airdrops_reinvested += airdrop_bonus;
        to_reinvest += airdrop_bonus; 

        require(to_reinvest > 0, "User has zero dividends re-invest.");
        to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));
        uint256 finalReinvestAmount = reinvestAmountOf(msg.sender, to_reinvest);

        users[msg.sender].deposit_amount += finalReinvestAmount;
        users[msg.sender].checkpoint = block.timestamp;
        userBonusStats[msg.sender].reinvested_gross += finalReinvestAmount;        
        
        total_reinvested += finalReinvestAmount;
        
		if(MANDATORY_REINVEST_ENABLED){
			
			user_reinvest_count[msg.sender]++;
		}

        emit ReinvestedDeposit(msg.sender, finalReinvestAmount);

	}

    function reinvestAmountOf(address _addr, uint256 _toBeRolledAmount) view public returns(uint256 reinvestAmount) {
        
        uint256 maxReinvestAmount = this.maxReinvestOf(users[_addr].total_direct_deposits); 

        reinvestAmount = _toBeRolledAmount; 

        if(users[_addr].deposit_amount >= maxReinvestAmount) {
            revert("User exceeded x5 of total deposit to be rolled.");
        }

        if(users[_addr].deposit_amount.add(reinvestAmount) >= maxReinvestAmount) {
            reinvestAmount = maxReinvestAmount.sub(users[_addr].deposit_amount);
        }        
    }

    function maxReinvestOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(MAX_REINVEST_MULTIPLIER);
    }

    function airdrop(address _to,uint256 _amount) external {
        require(airdrop_enabled, "Airdrop not Enabled.");

        address _addr = msg.sender;

        require(_amount >= AIRDROP_MIN, "Mininum airdrop amount not met.");

        tokenERC.transferFrom(address(msg.sender), address(this), _amount);

        if(users[_to].deposit_amount.add(_amount) >= this.maxReinvestOf(users[_to].total_direct_deposits) ){
            revert("User exceeded x5 of total deposit.");
        }
     
        uint256 sustainability_tax = _amount.mul(AIRDROP).div(PERCENTS_DIVIDER);
        uint256 payout = _amount.sub(sustainability_tax);

        require(users[_to].upline != address(0), "_to not found");

        airdrops[_to].airdrop_bonus += payout;

        airdrops[_addr].airdrops += payout;
        airdrops[_addr].last_airdrop = block.timestamp;
        airdrops[_addr].airdrops_sent += payout;
        airdrops[_addr].airdrops_sent_count = airdrops[_addr].airdrops_sent_count.add(1);
        airdrops[_to].airdrops_received += payout;
        airdrops[_to].airdrops_received_count = airdrops[_to].airdrops_received_count.add(1);
        airdrops[_to].last_airdrop_received = block.timestamp;

        total_airdrops += payout;

        emit NewAirdrop(_addr, _to, payout, block.timestamp);
    }

    function teamAirdrop(uint256 teamId, bool excludeOwner,uint256 _amount) external {
        require(airdrop_enabled, "Airdrop not Enabled.");
        
        address _addr = msg.sender;
        
        require(_amount >= AIRDROP_MIN, "Mininum airdrop amount not met.");

        tokenERC.transferFrom(address(msg.sender), address(this), _amount);

        uint256 sustainability_tax = _amount.mul(AIRDROP).div(PERCENTS_DIVIDER);
        uint256 payout = _amount.sub(sustainability_tax);
        
        require(teams[teamId].owner != address(0), "team not found");

        uint256 memberDivider = teams[teamId].members.length;
        if(excludeOwner == true){
            memberDivider--;
        }
        uint256 amountDivided = payout.div(memberDivider);

        for(uint8 i = 0; i < teams[teamId].members.length; i++){

            address _to = address(teams[teamId].members[i]);
            if(excludeOwner == true && _to == teams[teamId].owner){
                continue;
            }

            if(users[_to].deposit_amount.add(_amount) >= this.maxReinvestOf(users[_to].total_direct_deposits) ){
                continue;
            }

            airdrops[_to].airdrop_bonus += amountDivided;
            airdrops[_addr].airdrops += amountDivided;
            airdrops[_addr].last_airdrop = block.timestamp;
            airdrops[_addr].airdrops_sent += amountDivided;
            airdrops[_addr].airdrops_sent_count = airdrops[_addr].airdrops_sent_count.add(1);
            airdrops[_to].airdrops_received += amountDivided;
            airdrops[_to].airdrops_received_count = airdrops[_to].airdrops_received_count.add(1);
            airdrops[_to].last_airdrop_received = block.timestamp;

            emit NewAirdrop(_addr, _to, payout, block.timestamp);
        }

        total_airdrops += payout;
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {

        max_payout = this.maxPayoutOf(users[_addr].deposit_amount);

        if(users[_addr].deposit_payouts < max_payout) {

            uint256 timestamp_now = block.timestamp;

            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(timestamp_now.sub(MAX_ACCUMULATION))
                    .div(TIME_STEP);

            if(users[_addr].deposit_payouts.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].deposit_payouts);

            }
        }
    }

    function payoutToReinvest(address _addr) view external returns(uint256 payout) {
        
        uint256 max_payout = this.maxPayoutOf(users[_addr].deposit_amount);

        if(users[_addr].deposit_payouts < max_payout) {
            uint256 timestamp_now = block.timestamp;

            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(timestamp_now.sub(MAX_ACCUMULATION))
                    .div(TIME_STEP);

        }            
    
    }

    function maxPayoutOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(MAX_PAYOUT).div(PERCENTS_DIVIDER);
    }

    function withdrawalTaxPercentage(uint256 to_payout) view external returns(uint256 finalPayout) {
      uint256 contractBalance = tokenERC.balanceOf(address(this));
	  
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

        require(numberOfExistingTeams <= MAX_TEAMS_PER_ADDRESS, "Max number of teams reached.");

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
        Team storage team = teams[teamId];
        team.members.push(member);

        user_teams[member].push(TeamInfo(teamId, true));
        user_teams_counter[member]++;
    }

    function userInfo(address _addr) view external returns(address upline, uint256 checkpoint, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 match_bonus) {
        return (users[_addr].upline, users[_addr].checkpoint, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].direct_bonus, users[_addr].match_bonus);
    }

    function userInfo2(address _addr) view external returns(uint256 last_airdrop, uint8 teams_counter, TeamInfo[] memory member_of_teams, uint256 airdrop_bonus, uint8 reinvest_count) {

        return (airdrops[_addr].last_airdrop, user_teams_counter[_addr], user_teams[_addr], airdrops[_addr].airdrop_bonus, user_reinvest_count[_addr]);
    }

    function userDirectTeamsInfo(address _addr) view external returns(uint256 referral_team, bool referral_team_exists, uint256 upline_team, bool upline_team_exists) {
        User memory user = users[_addr];

        return (user_referral_team[_addr].id, user_referral_team[_addr].exists, user_referral_team[user.upline].id, user_referral_team[user.upline].exists);
    }

    function teamInfo(uint256 teamId) view external returns(Team memory _team) {
        Team memory team = teams[teamId];
        return (team);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure,uint256 total_downline_deposit, uint256 airdrops_total, uint256 airdrops_received) {
        return (users[_addr].referrals, users[_addr].total_direct_deposits, users[_addr].total_payouts, users[_addr].total_structure, users[_addr].total_downline_deposit, airdrops[_addr].airdrops, airdrops[_addr].airdrops_received);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_airdrops, uint256 current_tvl) {
        return (total_users, total_deposited, total_withdraw, total_airdrops, tokenERC.balanceOf(address(this)));
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only");
        owner = payable(value);
    }

    function ENABLE_AIRDROP(bool value) external{
        require(msg.sender == owner, "Admin use only");
        airdrop_enabled = value;
    }  

	function ENABLE_MANDATORY_REINVEST(bool value) external{
        require(msg.sender == owner, "Admin use only");
		MANDATORY_REINVEST_ENABLED = value;																					  
    }

    function SET_STARTED(bool value) external{
        require(msg.sender == owner, "Admin use only");
		started = value;																					  
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