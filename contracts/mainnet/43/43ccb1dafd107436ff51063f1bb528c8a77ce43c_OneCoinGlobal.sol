/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

/*
* @title  1CC Global Financial System, build in BSC Network
* @dev    A financial system built on smart contract technology. Open to all, transparent to all.
*         The worlds first decentralized, community support fund
*/
contract OneCoinGlobal is Ownable {
    
    IERC20 public investToken;
    using SafeMath for uint256;

    struct PlayerDeposit {
        uint256 id;
        uint256 amount;
        uint256 total_withdraw;
        uint256 time;
        uint256 period;
        uint256 expire;
        uint8 status;
        uint8 is_crowd;
    }

    struct Player {
        address referral;
        uint8 is_crowd;
        uint256 level_id;
        uint256 dividends;
        uint256 eth_dividends;
        uint256 referral_bonus;
        uint256 match_bonus;
        uint256 holder_full_bonus;
        uint256 holder_single_bonus;
        uint256 total_invested;
        uint256 total_redeem;
        uint256 total_withdrawn;
        uint256 last_payout;
        PlayerDeposit[] deposits;
        address[] referrals;
    }
    
    struct PlayerTotal {
        uint256 total_match_invested;
        uint256 total_dividends;
        uint256 total_referral_bonus;
        uint256 total_match_bonus;
        uint256 total_holder_full_bonus;
        uint256 total_holder_single_bonus;
        uint256 total_eth_dividends;
    }
    
    /* Deposit smart contract address */
    address public invest_token_address = 0x5b414ad2C644F6551ed0a9749803c9aF11b53943;
    uint256 public invest_token_decimal = 4;
    uint256 public invest_eth_decimal = 8;
    
    uint256 public total_investors;
    uint256 public total_invested;
    uint256 public total_withdrawn;
    uint256 public total_redeem;
    uint256 public total_referral_bonus;
    uint256 public total_match_bonus;
    uint256 public total_dividends;
    uint256 public total_eth_dividends;
    uint256 public total_holder_full_bonus;
    uint256 public total_holder_single_bonus;
    uint256 public total_platform_bonus;
    
    /* Current corwded shareholder number */
    uint256 public total_crowded_num; 
    
    /* Total shareholder join limit number */
    uint256 constant public SHAREHOLDER_LIMIT_NUM = 60;
    
    /* Shareholder bonus rate */
    uint256 constant public shareholder_full_bonus_rate = 5;
    uint256 constant public shareholder_single_bonus_rate = 3;

    /* Referral bonuses data  define*/
    uint8[] public referral_bonuses = [10,5];
    /* Referral same level bonus define */
    uint256 public referral_same_bonus_rate = 5;

    /* Invest period and profit parameter definition */
    uint256[] public invest_period_months =      [1,   2,   3,    6,    12,   18];     //period months
    uint256[] public invest_period_month_rates = [800, 900, 1000, 1100, 1200, 1200];   //Ten thousand of month' rate
    
    /* yield reduce project section config, item1: total yield, item2: reduce rate */
    uint256[] public yield_reduce_section1 =  [2000000, 30];
    uint256[] public yield_reduce_section2 =  [5000000, 30];
    uint256[] public yield_reduce_section3 =  [9000000, 30];
    uint256[] public yield_reduce_section4 =  [14000000, 30];
    uint256[] public yield_reduce_section5 =  [17000000, 30];
    uint256[] public yield_reduce_section6 =  [20000000, 30];
    uint256[] public yield_reduce_section7 =  [23000000, 30];
    uint256[] public yield_reduce_section8 =  [28000000, 30];
    uint256[] public yield_reduce_section9 =  [33000000, 30];
    uint256[] public yield_reduce_section10 = [40000000, 30];
    
    /* Team level data definition */
    uint256[] public team_level_ids =     [1,2,3,4,5,6];
    uint256[] public team_level_amounts = [5000,20000,40000,100000,200000,500000];
    uint256[] public team_level_bonuses = [2,4,6,8,10,12];

    /* invest coin usd price */ 
    uint256 public invest_coin_usd_price = 1;
    
    /* invest reward eth rate ‰ */
    uint256 public invest_reward_eth_month_rate = 25;
    
    /* ETH min withdraw amount: 15 HT */
    uint256 public eth_min_withdraw_num = 15 * (10 ** 18);
    
    /* user invest min amount */
    uint256 constant public INVEST_MIN_AMOUNT = 5;
    /* user invest max amount */
    uint256 constant public INVEST_MAX_AMOUNT = 10000;
    /* user crowd limit amount */
    uint256 constant public CROWD_LIMIT_AMOUNT = 15000;
    /* user crowd period(month) */
    uint256 constant public crowd_period_month = 18;

    /* Platform bonus address */
    address public platform_bonus_address = 0xb42a4bed3C53a7aC9551670dF0AF36956c7b87F1;
    /* Platform bonus rate percent(%) */
    uint256 constant public platform_bonus_rate = 3;
    
    /* Mapping data list define */
    mapping(address => Player) public players;
    mapping(address => PlayerTotal) public playerTotals;
    mapping(uint256 => address) public addrmap;
    address[] public shareholders;
    
    event Deposit(address indexed addr, uint256 amount, uint256 month);
    event Withdraw(address indexed addr, uint256 amount);
    event ReferralPayout(address indexed addr, uint256 amount, uint8 level);
    event Crowd(address indexed addr, uint256 amount);
    event DepositRedeem(uint256 invest_id);

    /* Migration action deadLine status*/
    uint256 public MIGRATION_DEADLINE = 0;
    
    /* Migrate contract data event defined */
    event MigrateContract(uint256 _total_invested, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_platform_bonus, uint256 _total_crowded_num,uint256 _total_holder_bonus,uint256 _total_eth_dividends,uint256 _total_match_bonus);
    event MigratePlayer(address _addr,address _referral, uint256 _is_crowd, uint256 _dividends, uint256 _eth_dividends, uint256 _referral_bonus, uint256 _match_bonus, uint256 _holder_single_bonus, uint256 _holder_full_bonus,uint256 _last_payout);
    event MigratePlayerTotal(address _addr, uint256 _total_invested, uint256 _total_withdrawn, uint256 _total_match_invested, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_match_bonus, uint256 _total_holder_full_bonus, uint256 _total_holder_single_bonus, uint256 _total_eth_dividends);
    event MigrateDeposit(address _addr, uint256 _time, uint256 _amount, uint256 _total_withdraw,uint256 _expire,uint8 _status);
    event MigrateDeadline();
    
    constructor() public {
        /* Create invest token instace  */
        investToken = IERC20(invest_token_address);
    }
    
    /* Function to receive Ether. msg.data must be empty */
    receive() external payable {}

    /* Fallback function is called when msg.data is not empty */ 
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    /*
    * @dev user do deposit action,grant the referrs bonus,grant the shareholder bonus,grant the match bonus
    */
    function deposit(address _referral, uint256 _amount, uint256 _month) 
        external 
        payable 
    {
        require(_amount >= INVEST_MIN_AMOUNT, "Minimal deposit: 5 1CC");
        require(_amount <= INVEST_MAX_AMOUNT, "Maxinum deposit: 10000 1CC");
        //require(_amount % 100 == 0, "Invest amount must be multiple of 100");
        
        Player storage player = players[msg.sender];
        require(player.deposits.length < 2000, "Max 2000 deposits per address");
        
        /* format token amount  */
        uint256 token_decimals = 10 ** invest_token_decimal;
        uint256 token_amount = _amount * token_decimals;
        
        /* Transfer user address token to contract address*/
        require(investToken.transferFrom(msg.sender, address(this), token_amount), "transferFrom failed");

        _setReferral(msg.sender, _referral);
        
        /* update total investor count */
        if(player.deposits.length == 0){
            total_investors += 1;
            addrmap[total_investors] = msg.sender;
        }
        
        /* get the period total time (total secones) */
        uint256 period_time = _month * 30 * 86400;
        
        uint256 _id = player.deposits.length + 1;
        player.deposits.push(PlayerDeposit({
            id: _id,
            amount: _amount,
            total_withdraw: 0,
            time: uint256(block.timestamp),
            period: _month,
            expire:uint256(block.timestamp).add(period_time),
            status: 0,
            is_crowd: 0
        }));

        player.total_invested += _amount;
        total_invested += _amount;

        /* update user referral and match invested amount*/
        _updateReferralMatchInvestedAmount(msg.sender, _amount, 1);

        emit Deposit(msg.sender, _amount, _month);
    }
    
    /*
    * @dev user do crowd action, to join shareholder
    */
    function crowd(address _referral, uint256 _amount) 
        payable
        external 
    {

        require(_amount == CROWD_LIMIT_AMOUNT, "Crowd limit: 15000 1CC");
        require(total_crowded_num < SHAREHOLDER_LIMIT_NUM, "Maximum shareholders: 50");
        
        Player storage player = players[msg.sender];
        require(player.is_crowd == 0, "Already a shareholder");
        
        /* format token amount  */
        uint256 token_amount = _getTokenAmount(_amount,invest_token_decimal);
        
        /* Transfer user address token to contract address*/
        require(investToken.transferFrom(msg.sender, address(this), token_amount), "transferFrom failed");

        _setReferral(msg.sender, _referral);
        
        /* get the period total time (total secones) */
        uint256 _month = crowd_period_month;
        uint256 period_time = _month.mul(30).mul(86400);
        
        /* update total investor count */
        if(player.deposits.length == 0){
            total_investors += 1;
            addrmap[total_investors] = msg.sender;
        }
        
        uint256 _id = player.deposits.length + 1;
        player.deposits.push(PlayerDeposit({
            id: _id,
            amount: _amount,
            total_withdraw: 0,
            time: uint256(block.timestamp),
            period: _month,
            expire: uint256(block.timestamp).add(period_time),
            status: 0,
            is_crowd: 1
        }));

        /* set the player of shareholders roles */
        player.is_crowd = 1;
        total_crowded_num += 1;
        
        /* push user to shareholder list*/
        shareholders.push(msg.sender);

        player.total_invested += _amount;
        total_invested += _amount;

        /* update user referral and match invested amount*/
        _updateReferralMatchInvestedAmount(msg.sender, _amount, 1);

        emit Crowd(msg.sender, _amount);
    }
    
    /*
    * @dev user do withdraw action, tranfer the total profit to user account, grant rereferral bonus, grant match bonus, grant shareholder bonus
    */
    function withdraw() 
        payable 
        external 
    {
        /* get contract pool balance*/
        uint256 _contract_balance = investToken.balanceOf(address(this));
        uint256 _total_invested_amount = _getTokenAmount(total_invested,invest_token_decimal);
        require(_contract_balance >= _total_invested_amount, "Insufficient Pool Balance");
        uint256 _contract_pool_balance = _contract_balance - _total_invested_amount;

        /* update user dividend data */
        _payout(msg.sender);
        
        Player storage player = players[msg.sender];

        /* only devidend amount to grant upper bonus*/
        uint256 _dividend_amount = player.dividends;
        uint256 _amount = player.dividends + player.referral_bonus + player.match_bonus + player.holder_full_bonus + player.holder_single_bonus;

        /* verify contract pool balance is enough or not*/
        require(_contract_pool_balance >= _amount, "Insufficient Pool Balance");
        require(_amount > 0, "Insufficient balance");
        
        /* format deposit token amount  */
        uint256 token_amount = _amount;
        
        /* process token transfer action */
        require(investToken.approve(address(this), token_amount), "approve failed");
        require(investToken.transferFrom(address(this), msg.sender, token_amount), "transferFrom failed");
        
        /* Grant referral bonus */
        _referralPayout(msg.sender, _dividend_amount);
        
        /* Grant shareholder full node bonus */
        _shareHoldersFullNodePayout(_dividend_amount);
        
        /* Grant shareholder single node bonus */
        _shareHoldersSingleNodePayout(msg.sender, _dividend_amount);
        
        /* Grant team match bonus*/
        _matchPayout(msg.sender, _dividend_amount);
        
        /* Grant same level match bonus*/
        _matchSamePayout(msg.sender, token_amount);

        /* Update user total payout data */
        _updatePlayerTotalPayout(msg.sender, token_amount);
        
        emit Withdraw(msg.sender, token_amount);
    }
    
    
    /*
    * @dev user do deposit redeem action,transfer the expire deposit's amount to user account
    */
    function depositRedeem(uint256 _invest_id) 
        payable 
        external 
    {
        Player storage player = players[msg.sender];
        
        require(player.deposits.length >= _invest_id && _invest_id > 0, "Valid deposit id");
        uint256 _index = _invest_id - 1;
        require(player.deposits[_index].expire < block.timestamp, "Invest not expired");
        require(player.deposits[_index].status == 0, "Invest is redeemed");
        
        /* formt deposit token amount */
        uint256 _amount = player.deposits[_index].amount;
        uint256 token_amount = _getTokenAmount(_amount,invest_token_decimal);
        
        /* process token transfer action*/
        //require(investToken.approve(address(this), 0), "approve failed");
        require(investToken.approve(address(this), token_amount), "approve failed");
        require(investToken.transferFrom(address(this), msg.sender, token_amount), "transferFrom failed");
        
        /* update deposit status in redeem */
        player.deposits[_index].status = 1;

        /* user quit crowd, cancel the shareholders role */
        if(player.deposits[_index].is_crowd == 1){
            player.is_crowd = 0;
            total_crowded_num -= 1;
            
            /* remove user to shareholder list*/
            _removeShareholders(msg.sender);
        }

        /* update user token balance*/
        player.total_invested -= _amount;
        
        /* update total invested/redeem amount */
        total_invested -= _amount;
        total_redeem += _amount;
        
        /* update user referral and match invested amount*/
        _updateReferralMatchInvestedAmount(msg.sender, _amount, -1);

        emit DepositRedeem(_invest_id);
    }
     
    /*
    * @dev Update Referral Match invest amount, total investor number, map investor address index
    */
    function _updateReferralMatchInvestedAmount(address _addr,uint256 _amount,int8 op) 
        private
    {
        if(op > 0){
            playerTotals[_addr].total_match_invested += _amount;
            
            address ref = players[_addr].referral;
            while(true){
                if(ref == address(0)) break;
                
                playerTotals[ref].total_match_invested += _amount;
                ref = players[ref].referral;
            }
        }else{
            playerTotals[_addr].total_match_invested -= _amount;
            
            address ref = players[_addr].referral;
            while(true){
                if(ref == address(0)) break;
                
                playerTotals[ref].total_match_invested -= _amount;
                ref = players[ref].referral;
            }
        }
    }
    
    /*
    * @dev Update user total payout data
    */
    function _updatePlayerTotalPayout(address _addr,uint256 token_amount) 
        private
    {
        
        Player storage player = players[_addr];
        PlayerTotal storage playerTotal = playerTotals[_addr];
        
        /* update user Withdraw total amount*/
        player.total_withdrawn += token_amount;
        
        playerTotal.total_dividends += player.dividends;
        playerTotal.total_referral_bonus += player.referral_bonus;
        playerTotal.total_match_bonus += player.match_bonus;
        playerTotal.total_holder_full_bonus += player.holder_full_bonus;
        playerTotal.total_holder_single_bonus += player.holder_single_bonus;
        
        /* update platform total data*/
        total_withdrawn += token_amount;
        total_dividends += player.dividends;
        total_referral_bonus += player.referral_bonus;
        total_match_bonus += player.match_bonus;
        total_holder_full_bonus += player.holder_full_bonus;
        total_holder_single_bonus += player.holder_single_bonus; 
        uint256 _platform_bonus = (token_amount * platform_bonus_rate / 100);
        total_platform_bonus += _platform_bonus;
        
        /* update platform address bonus*/
        players[platform_bonus_address].match_bonus += _platform_bonus;
        
        /* reset user bonus data */
        player.dividends = 0;
        player.referral_bonus = 0;
        player.match_bonus = 0;
        player.holder_full_bonus = 0;
        player.holder_single_bonus = 0;
    }
    
    
    /*
    * @dev update user referral data
    */
    function _setReferral(address _addr, address _referral) 
        private 
    {
        /* if user referral is not set */
        if(players[_addr].referral == address(0) && _referral != _addr) {
            
            players[_addr].referral = _referral;

            /* update user referral address list*/
            players[_referral].referrals.push(_addr);
        }
    }
    
    
    /*
    * @dev Grant user referral bonus in user withdraw
    */
    function _referralPayout(address _addr, uint256 _amount) 
        private
    {
        address ref = players[_addr].referral;
        uint256 _day_payout = _payoutOfDay(_addr);
        if(_day_payout == 0) return;
        
        for(uint8 i = 0; i < referral_bonuses.length; i++) {
        
            if(ref == address(0)) break;

            uint256 _ref_day_payout = _payoutOfDay(ref);
            uint256 _token_amount = _amount;
            
            /* user bonus double burn */
            if(_ref_day_payout * 2 < _day_payout){
                _token_amount = _token_amount * (_ref_day_payout * 2) / _day_payout;
            }
            
            uint256 bonus = _token_amount * referral_bonuses[i] / 100;
            players[ref].referral_bonus += bonus;
        
            ref = players[ref].referral;
        }
    }
    
    /*
    * @dev  Grant shareholder full node bonus in user withdraw
    */
    function _shareHoldersFullNodePayout(uint256 _amount)
        private
    {
        if(total_crowded_num == 0) return;
        
        uint256 bonus = (_amount * shareholder_full_bonus_rate / 100) / total_crowded_num;
        for(uint8 i = 0; i < shareholders.length; i++) {
            address _addr = shareholders[i];
            players[_addr].holder_full_bonus += bonus;
        }
    }
    
    
    /*
    * @dev  Grant shareholder single node bonus in user withdraw
    */
    function _shareHoldersSingleNodePayout(address _addr,uint256 _amount)
        private
    {
        uint256 bonus = _amount * shareholder_single_bonus_rate / 100;
        address ref = players[_addr].referral;
        
        while(true){
            
            if(ref == address(0)) break;
            
            if(players[ref].is_crowd == 1){
                players[ref].holder_single_bonus += bonus;
                break;
            }
            ref = players[ref].referral;
        }
    }

    /*
    * @dev Grant Match bonus in user withdraw
    */
    function _matchPayout(address _addr,uint256 _amount) 
        private
    {
        /* update player team level */
        _upgradePlayerTeamLevel(_addr);
        uint256 last_level_id = players[_addr].level_id;
        
        /* player is max team level, quit */
        if(last_level_id == team_level_ids[team_level_ids.length-1]) return;
        
        address ref = players[_addr].referral;
        
        while(true){
            
            if(ref == address(0)) break;
            
            /* upgrade player team level id*/
            _upgradePlayerTeamLevel(ref);
            
            if(players[ref].level_id > last_level_id){
                
                uint256 last_level_bonus = 0;
                if(last_level_id > 0){
                    last_level_bonus = team_level_bonuses[last_level_id-1];
                }
                uint256 cur_level_bonus = team_level_bonuses[players[ref].level_id-1];
                uint256 bonus_amount = _amount * (cur_level_bonus - last_level_bonus) / 100;
                players[ref].match_bonus += bonus_amount;
                
                last_level_id = players[ref].level_id;
                
                /* referral is max team level, quit */
                if(last_level_id == team_level_ids[team_level_ids.length-1]) 
                    break;
            }
            ref = players[ref].referral;
        }
    }

    /*
    * @dev Grant same level match bonus in user withdraw
    */
    function _matchSamePayout(address _addr, uint256 _amount) 
        private
    {
        Player storage player = players[_addr];
        address ref = player.referral;
        uint256 player_level_id = player.level_id;
        while(true){

            // player must be a star level
            if(player_level_id==0) break;

            // referral address can't be empty
            if(ref == address(0)) break;

            /* update referral match bonus*/
            if(players[ref].level_id == player_level_id){
                uint256 bonus_amount = _amount * referral_same_bonus_rate / 100;
                players[ref].match_bonus += bonus_amount;
                break;
            }
            ref = players[ref].referral;
        }
    }
    
    /*
    * @dev upgrade player team level id
    */    
    function _upgradePlayerTeamLevel(address _addr) 
        private
    {
        /* get community total invested*/
        uint256 community_total_invested = _getCommunityTotalInvested(_addr);
        
        uint256 level_id = 0;
        for(uint8 i=0; i < team_level_ids.length; i++){
            if(community_total_invested >= team_level_amounts[i]){
                level_id = team_level_ids[i];
            }
        }
        players[_addr].level_id = level_id;
    }
    
    /*
    * @dev Get community total invested
    */
    function _getCommunityTotalInvested(address _addr) 
        view
        private
        returns(uint256 value)
    {
        address[] memory referrals = players[_addr].referrals;
        
        uint256 nodes_max_invested = 0;
        uint256 nodes_total_invested = 0;
        for(uint256 i=0;i<referrals.length;i++){
            address ref = referrals[i];
            nodes_total_invested += playerTotals[ref].total_match_invested;
            if(playerTotals[ref].total_match_invested > nodes_max_invested){
                nodes_max_invested = playerTotals[ref].total_match_invested;
            }
        }
        return (nodes_total_invested - nodes_max_invested);
    }

    /*
    * @dev user withdraw, user devidends data update
    */
    function _payout(address _addr) 
        private 
    {
        uint256 payout = this.payoutOf(_addr);
        if(payout > 0) {
            
            _updateTotalPayout(_addr);
            
            players[_addr].last_payout = uint256(block.timestamp);
            players[_addr].dividends += payout;
        }
    }
    
    /*
    * @dev format token amount with token decimal
    */
    function _getTokenAmount(uint256 _amount,uint256 _token_decimal) 
        pure
        private
        returns(uint256 token_amount)
    {
        uint256 token_decimals = 10 ** _token_decimal;
        token_amount = _amount * token_decimals;   
        return token_amount;
    }
    

    /*
    * @dev update user total withdraw data
    */
    function _updateTotalPayout(address _addr)
        private
    {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            
            PlayerDeposit storage dep = player.deposits[i];

            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > dep.expire ? dep.expire : uint256(block.timestamp);

            if(from < to && dep.status == 0) {
                uint256 _day_payout = _getInvestDayPayoutOf(dep.amount,dep.period);
                player.deposits[i].total_withdraw += _day_payout * (to - from) / 86400;
            }
        }
    }
    
    /*
    * @dev get the invest period rate, if total yield reached reduce limit, invest day rate will be reduce
    */
    function _getInvestDayPayoutOf(uint256 _amount, uint256 _month) 
        view 
        private 
        returns(uint256 value)
    {
        /* get invest period base rate*/
        uint256 period_month_rate = invest_period_month_rates[0];
        
        for(uint256 i = 0; i < invest_period_months.length; i++) {
            if(invest_period_months[i] == _month){
                period_month_rate = invest_period_month_rates[i];
                break;
            }
        }
        
        /* format amount with token decimal */
        uint256 token_amount = _getTokenAmount(_amount, invest_token_decimal);
        value = token_amount * period_month_rate / 30 / 10000;
        
        if(value > 0){
            
            /* total yield reached 2,000,000,start section1 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section1[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section1[1]) / 100;
            }
            /* total yield reached 5,000,000,start section2 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section2[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section2[1]) / 100;
            }
            /* total yield reached 9,000,000,start section3 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section3[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section3[1]) / 100;
            }
            /* total yield reached 12,000,000,start section4 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section4[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section4[1]) / 100;
            }
            /* total yield reached 14,000,000,start section5 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section5[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section5[1]) / 100;
            }
            /* total yield reached 17,000,000,start section6 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section6[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section6[1]) / 100;
            }
            /* total yield reached 20,000,000,start section7 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section7[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section7[1]) / 100;
            }
            /* total yield reached 25,000,000,start section8 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section8[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section8[1]) / 100;
            }
            /* total yield reached 30,000,000,start section9 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section9[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section9[1]) / 100;
            }
            /* total yield reached 40,000,000,start section10 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section10[0], invest_token_decimal)){
                value = value * (100 - yield_reduce_section10[1]) / 100;
            }
        }
        return value;
    }
    
    /*
    * @dev get user deposit day total pending profit
    * @return user pending payout amount
    */
    function payoutOf(address _addr) 
        view 
        external 
        returns(uint256 value)
    {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            PlayerDeposit storage dep = player.deposits[i];
            
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > dep.expire ? dep.expire : uint256(block.timestamp);
            
            if(from < to && dep.status == 0) {
                uint256 _day_payout = _getInvestDayPayoutOf(dep.amount,dep.period);
                value += _day_payout * (to - from) / 86400;
            }
        }
        return value;
    }

    /*
    * @dev get user deposit day total pending profit
    * @return user pending payout amount
    */
    function _payoutOfDay(address _addr) 
        view
        private 
        returns(uint256 value)
    {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            PlayerDeposit storage dep = player.deposits[i];
            if(dep.status == 0) {
                uint256 _day_payout = _getInvestDayPayoutOf(dep.amount, dep.period);
                value += _day_payout;
            }
        }
        return value;
    }
    
  
    /*
    * @dev Remove shareholders of the special address
    */
    function _removeShareholders(address _addr) private {
        for (uint index = 0; index < shareholders.length; index++) {
            if(shareholders[index] == _addr){
                for (uint i = index; i < shareholders.length-1; i++) {
                    shareholders[i] = shareholders[i+1];
                }
                delete shareholders[shareholders.length-1];
                break;
            }
        }
    }
    

    /*
    * @dev get contract data info 
    * @return total invested,total investor number,total withdraw,total referral bonus
    */
    function contractInfo() 
        view 
        external 
        returns(uint256 _total_invested, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_platform_bonus, uint256 _total_crowded_num,uint256[] memory _invest_periods,uint256 _crowd_limit_amount,uint256 _crowd_period_month,uint256 _eth_min_withdraw_num,uint256 _total_holder_bonus,uint256 _total_eth_dividends,uint256 _total_match_bonus) 
    {
        return (
            total_invested, 
            total_investors, 
            total_withdrawn, 
            total_dividends, 
            total_referral_bonus, 
            total_platform_bonus, 
            total_crowded_num, 
            invest_period_months, 
            CROWD_LIMIT_AMOUNT, 
            crowd_period_month,
            eth_min_withdraw_num,
            total_holder_full_bonus + total_holder_single_bonus,
            total_eth_dividends,
            total_match_bonus
        );
    }
    
    /*
    * @dev get user info
    * @return pending withdraw amount,referral,rreferral num etc.
    */
    function userInfo(address _addr)
        view 
        external 
        returns(address _referral, uint256 _referral_num, uint256 _is_crowd, uint256 _dividends, uint256 _eth_dividends, uint256 _referral_bonus, uint256 _match_bonus, uint256 _holder_single_bonus, uint256 _holder_full_bonus,uint256 _last_payout) 
    {
        Player storage player = players[_addr];
        return (
            player.referral,
            player.referrals.length,
            player.is_crowd,
            player.dividends,
            player.eth_dividends,
            player.referral_bonus,
            player.match_bonus,
            player.holder_single_bonus,
            player.holder_full_bonus,
            player.last_payout
        );
    }
    
    /*
    * @dev get user info
    * @return pending withdraw amount,referral bonus, total deposited, total withdrawn etc.
    */
    function userInfoTotals(address _addr) 
        view 
        external 
        returns(uint256 _total_invested, uint256 _total_withdrawn, uint256 _total_community_invested, uint256 _total_match_invested, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_match_bonus, uint256 _total_holder_full_bonus, uint256 _total_holder_single_bonus,uint256 _total_eth_dividends) 
    {
        Player storage player = players[_addr];
        PlayerTotal storage playerTotal = playerTotals[_addr];
        
        /* get community total invested*/
        uint256 total_community_invested = _getCommunityTotalInvested(_addr);
        
        return (
            player.total_invested,
            player.total_withdrawn,
            //player.total_redeem,
            total_community_invested,
            playerTotal.total_match_invested,
            playerTotal.total_dividends,
            playerTotal.total_referral_bonus,
            playerTotal.total_match_bonus,
            playerTotal.total_holder_full_bonus,
            playerTotal.total_holder_single_bonus,
            playerTotal.total_eth_dividends
        );
    }
    
    /*
    * @dev get user investment list
    */
    function getInvestList(address _addr) 
        view 
        external 
        returns(uint256[] memory ids,uint256[] memory times, uint256[] memory amounts, uint256[] memory withdraws,uint256[] memory endTimes,uint256[] memory statuses) 
    {
        Player storage player = players[_addr];
        uint256[] memory _ids = new uint256[](player.deposits.length);
        uint256[] memory _times = new uint256[](player.deposits.length);
        uint256[] memory _endTimes = new uint256[](player.deposits.length);
        uint256[] memory _amounts = new uint256[](player.deposits.length);
        uint256[] memory _withdraws = new uint256[](player.deposits.length);
        uint256[] memory _statuses = new uint256[](player.deposits.length);
        for(uint256 i = 0; i < player.deposits.length; i++) {
            PlayerDeposit storage dep = player.deposits[i];
            _ids[i] = dep.id;
            _amounts[i] = dep.amount;
            _withdraws[i] = dep.total_withdraw;
            _times[i] = dep.time;
            _endTimes[i] = dep.expire;
            _statuses[i] = dep.status;
        }
        return (
            _ids,
            _times,
            _amounts,
            _withdraws,
            _endTimes,
            _statuses
        );
    }
    
    /*
    * @dev Migrate contract data (migration from heco chain to biance smart chain)
    */
    function migrateContract(uint256 _total_invested, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_platform_bonus, uint256 _total_crowded_num,uint256 _total_holder_bonus,uint256 _total_eth_dividends,uint256 _total_match_bonus) 
        external onlyOwner
        payable  
    {
        total_invested = _total_invested;
        //total_investors = _total_investors;
        total_withdrawn = _total_withdrawn; 
        total_dividends = _total_dividends;
        total_referral_bonus = _total_referral_bonus;
        total_platform_bonus = _total_platform_bonus; 
        total_crowded_num = _total_crowded_num;
        total_holder_full_bonus = _total_holder_bonus;
        total_eth_dividends = _total_eth_dividends;
        total_match_bonus = _total_match_bonus;

        emit MigrateContract(_total_invested, _total_investors, _total_withdrawn, _total_dividends, _total_referral_bonus, _total_platform_bonus, _total_crowded_num, _total_holder_bonus, _total_eth_dividends, _total_match_bonus);
    }

    /*
    * @dev Migrate player data (migration from heco chain to biance smart chain)
    */
    function migratePlayer(address _addr, address _referral, uint8 _is_crowd, uint256 _dividends, uint256 _eth_dividends, uint256 _referral_bonus, uint256 _match_bonus, uint256 _holder_single_bonus, uint256 _holder_full_bonus, uint256 _last_payout) 
        external onlyOwner
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        Player storage player = players[_addr];
        player.is_crowd = _is_crowd;
        player.dividends = _dividends;
        player.eth_dividends = _eth_dividends;
        player.referral_bonus = _referral_bonus;
        player.match_bonus = _match_bonus;
        player.holder_single_bonus = _holder_single_bonus;
        player.holder_full_bonus = _holder_full_bonus;
        player.last_payout = _last_payout;

        _setReferral(_addr, _referral);
        
        /* update total investor count */
        total_investors += 1;
        addrmap[total_investors] = _addr;

        /* push user to shareholder list*/
        if (_is_crowd == 1) {
            shareholders.push(_addr);
        }

        emit MigratePlayer(_addr, _referral, _is_crowd,_dividends, _eth_dividends, _referral_bonus, _match_bonus, _holder_single_bonus, _holder_full_bonus, _last_payout);
    }

    /*
    * @dev Migrate player total data (migration from heco chain to biance smart chain)
    */
    function migratePlayerTotal(address _addr, uint256 _total_invested, uint256 _total_withdrawn, uint256 _total_match_invested, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_match_bonus, uint256 _total_holder_full_bonus, uint256 _total_holder_single_bonus, uint256 _total_eth_dividends)
        external onlyOwner 
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");
        
        Player storage player = players[_addr];
        PlayerTotal storage playerTotal = playerTotals[_addr];
        player.total_invested = _total_invested;
        player.total_withdrawn = _total_withdrawn;
        playerTotal.total_match_invested = _total_match_invested;
        playerTotal.total_dividends = _total_dividends;
        playerTotal.total_referral_bonus = _total_referral_bonus;
        playerTotal.total_match_bonus = _total_match_bonus;
        playerTotal.total_holder_full_bonus = _total_holder_full_bonus;
        playerTotal.total_holder_single_bonus = _total_holder_single_bonus;
        playerTotal.total_match_invested = _total_match_invested;
        playerTotal.total_eth_dividends = _total_eth_dividends;

        emit MigratePlayerTotal(_addr, _total_invested, _total_withdrawn,_total_match_invested, _total_dividends, _total_referral_bonus,_total_match_bonus, _total_holder_full_bonus, _total_holder_single_bonus, _total_eth_dividends);
    }

    /*
    * @dev Migrate player deposit data (migration from heco chain to biance smart chain)
    */
    function migrateDeposit(address _addr, uint256 _time, uint256 _amount, uint256 _total_withdraw,uint256 _expire,uint8 _status) 
        external onlyOwner 
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        Player storage player = players[_addr];
        uint256 _id = player.deposits.length + 1;
        uint256 _month = (_expire - _time) / 30 / 86400;
        player.deposits.push(PlayerDeposit({
            id: _id,
            amount: _amount,
            total_withdraw: _total_withdraw,
            time: _time,
            period: _month,
            expire: _expire,
            status: _status,
            is_crowd: 0
        }));

        emit MigrateDeposit(_addr, _time, _amount, _total_withdraw, _expire, _status);
    }

    /*
    * @dev Set Contract Migrate deadline status
    */
    function migrateDeadline() 
        external onlyOwner 
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        MIGRATION_DEADLINE = 1;

        emit MigrateDeadline();
    }
    
}