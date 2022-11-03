/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
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

/*
* @title  ENC ECO System, build in Biance Network
* @dev    A financial system built on smart contract technology. Open to all, transparent to all.
*         The worlds first decentralized, community support fund
*/
contract EncEcosystem is Ownable {
    
    IERC20 public invest1ccToken;
    IERC20 public investEncToken;
    using SafeMath for uint256;

    struct PlayerDeposit {
        uint256 id;
        uint256 amount;
        uint256 total_withdraw;
        uint256 time;
        uint256 period;
        uint256 month;
        uint256 expire;
        uint8 status;
        uint8 is_crowd;
    }
    struct Player {
        address referral;
        uint8 is_supernode;
        uint256 level_id;
        uint256 dividends;
        uint256 referral_bonus;
        uint256 match_bonus;
        uint256 supernode_bonus;
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
        uint256 total_supernode_bonus;
        uint256 total_period1_invested;
        uint256 total_period2_invested;
        uint256 total_period3_invested;
        uint256 total_period4_invested;
        uint256 total_period1_devidends;
        uint256 total_period2_devidends;
        uint256 total_period3_devidends;
        uint256 total_period4_devidends;
    }
    
    /* Deposit smart contract address */
    address public invest_1cc_token_address = 0x5b414ad2C644F6551ed0a9749803c9aF11b53943;
    uint256 public invest_1cc_token_decimal = 4;
    address public invest_enc_token_address = 0x13b80d52aBf247284b0A0cB1F7Cd5f8997de9B21;
    uint256 public invest_enc_token_decimal = 8;
    
    /* Token (1CC) burning address */
    address public burning_address = address(0x0000000000000000000000000000000000000001);

    /* Platform bonus address */
    address public platform_bonus_address = 0x6Fc447828B90d7D7f6C84d5fa688FF3E4ED3763C;
    /* Platform bonus rate percent(%) */
    uint256 constant public platform_bonus_rate = 3;
    
    uint256 public total_investors;
    uint256 public total_invested;
    uint256 public total_withdrawn;
    uint256 public total_redeem;
    uint256 public total_dividends;
    uint256 public total_referral_bonus;
    uint256 public total_match_bonus;
    uint256 public total_supernode_bonus;
    uint256 public total_platform_bonus;
    
    /* Current joined supernode count */
    uint256 public total_supernode_num; 
    
    /* Total supernode join limit number */
    uint256 constant public SUPERNODE_LIMIT_NUM = 100;
    uint256[] public supernode_period_ids =         [1,2,3,4,5,6];     //period ids
    uint256[] public supernode_period_pays =        [1,1,1,2,2,2];     //period pays
    uint256[] public supernode_period_amounts =     [5000,6000,7000,500,600,700];  //period amount
    uint256[] public supernode_period_limits =      [20,30,50,10,20,30];    //period limit
    //supernode total numer in which period
    uint256[] public total_supernode_num_periods =  [20,30,50,0,0,0];
    
    /* Super Node bonus rate */
    uint256 constant public supernode_bonus_rate = 20;
    
    /* Referral bonuses data  define*/
    uint8[] public referral_bonuses = [10,5];
    
    /* Invest period and profit parameter definition */
    uint256 constant public invest_early_redeem_feerate = 15;       //invest early redeem fee rate(%)
    uint256[] public invest_period_ids =         [1,   2,   3,   4];   //period ids
    uint256[] public invest_period_months =      [3,   6,   12,  24];   //period months
    uint256[] public invest_period_rates =       [600, 700, 800, 900];   //Ten thousand of month' rate
    uint256[] public invest_period_totals =      [0,   0,   0,   0];         //period total invested
    uint256[] public invest_period_devidends =   [0,   0,   0,   0];         //period total devidends
    
    /* withdraw fee amount (0.8 1CC)) */
    uint256 constant public withdraw_fee_amount = 8000;
    
    /* yield reduce project section config, item1: total yield, item2: reduce rate */
    uint256[] public yield_reduce_section1 = [30000, 30];
    uint256[] public yield_reduce_section2 = [60000, 30];
    uint256[] public yield_reduce_section3 = [90000, 30];
    uint256[] public yield_reduce_section4 = [290000, 30];
    uint256[] public yield_reduce_section5 = [600000, 30];
    uint256[] public yield_reduce_section6 = [900000, 30];
    uint256[] public yield_reduce_section7 = [1400000, 30];
    uint256[] public yield_reduce_section8 = [2000000, 30];
    
    /* Team level data definition */
    uint256[] public team_level_ids =     [1,2,3,4,5,6];
    uint256[] public team_level_amounts = [1000,3000,5000,10000,20000,50000];
    uint256[] public team_level_bonuses = [2,4,6,8,10,12];
    
    /* Crowd period data definition */
    uint256[] public crowd_period_ids =    [1,2,3,4,5,6,7];
    uint256[] public crowd_period_rates =  [4,5,6,20,30,40,50];
    uint256[] public crowd_period_limits = [50000,30000,20000,10000,20000,30000,40000];
    
    /* Total (period) crowd number*/
    uint256[] public total_crowd_num_periods = [50000,30000,20000,0,0,0,0];

    /* user invest min amount */
    uint256 constant public INVEST_MIN_AMOUNT = 10000000;
    /* user invest max amount */
    uint256 constant public INVEST_MAX_AMOUNT = 100000000000000;
    /* user crowd limit amount */
    uint256 constant public SUPERNODE_LIMIT_AMOUNT = 5000;
    /* user crowd period(month) */
    uint256 constant public crowd_period_month = 24;
    uint256 constant public crowd_period_start = 1634313600;
    
    /* Mapping data list define */
    mapping(address => Player) public players;
    mapping(address => PlayerTotal) public playerTotals;
    mapping(uint256 => address) public addrmap;
    address[] public supernodes;
    
    event Deposit(address indexed addr, uint256 amount, uint256 month);
    event Withdraw(address indexed addr, uint256 amount);
    event Crowd(address indexed addr, uint256 period,uint256 amount);
    event SuperNode(address indexed addr, uint256 _period, uint256 amount);
    event DepositRedeem(uint256 invest_id);
    event ReferralPayout(address indexed addr, uint256 amount, uint8 level);
    event SetReferral(address indexed addr,address refferal);
	
    /* Migration action deadLine status*/
    uint256 public MIGRATION_DEADLINE = 0;

    /* Migrate contract data event defined */
    event MigrateContract(uint256 _total_invested, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_platform_bonus, uint256 _total_supernode_num, uint256 _total_holder_bonus, uint256 _total_match_bonus);
    event MigratePlayer(address _addr, address _referral, uint8 _is_supernode, uint256 _dividends, uint256 _referral_bonus, uint256 _match_bonus, uint256 _supernode_bonus,uint256 _last_payout, uint256 _total_invested, uint256 _total_withdrawn);
    event MigratePlayerTotal(address _addr, uint256 _total_match_invested, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_match_bonus, uint256 _total_supernode_bonus);
    event MigratePlayerTotalPeriod(address _addr,uint256 _total_period1_invested,uint256 _total_period2_invested,uint256 _total_period3_invested,uint256 _total_period4_invested,uint256 _total_period1_devidends,uint256 _total_period2_devidends,uint256 _total_period3_devidends,uint256 _total_period4_devidends);
    event MigrateDeposit(address _addr, uint256 _time, uint256 _amount, uint256 _total_withdraw,uint256 _month,uint8 _is_crowd);
    event MigrateDepositPeriod(uint256 _period_total1, uint256 _period_total2, uint256 _period_total3,uint256 _period_total4,uint256 _period_devidend1, uint256 _period_devidend2, uint256 _period_devidend3,uint256 _period_devidend4);
    event MigrateDeadline();

    constructor() public {
        
        /* Create invest token instace  */
        invest1ccToken = IERC20(invest_1cc_token_address);
        investEncToken = IERC20(invest_enc_token_address);
    }
    
    /* Function to receive Ether. msg.data must be empty */
    receive() external payable {}

    /* Fallback function is called when msg.data is not empty */ 
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
	    /*
    * @dev user do set refferal action
    */
    function setReferral(address _referral)
        payable
        external 
    {
        Player storage player = players[msg.sender];
        require(player.referral == address(0), "Referral has been set");
        
        require(_referral != address(0), "Invalid Referral address");
        
        Player storage ref_player = players[_referral];
        require(ref_player.referral != address(0) || _referral == platform_bonus_address, "Referral address not activated yet");
        
        _setReferral(msg.sender,_referral);
        
        emit SetReferral(msg.sender,_referral);
    }
    
    /*
    * @dev user do join shareholder action, to join SUPERNODE
    */ 
    function superNode(address _referral, uint256 _period, uint256 _amount) 
        payable
        external 
    {
        Player storage player = players[msg.sender];
        require(player.is_supernode == 0, "Already a supernode");
        
        require(_period >= 1 && _period <= 6 , "Invalid Period Id");
        
        if(_period > 1){
            uint256 _lastPeriodLimit = supernode_period_limits[_period-2];
            require(total_supernode_num_periods[_period-2] >= _lastPeriodLimit, "Current round not started yet ");
        }
        
        uint256 _periodAmount = supernode_period_amounts[_period-1];
        require(_amount == _periodAmount, "Not match the current round limit");
        
        //valid period remain
        uint256 _periodRemain = supernode_period_limits[_period-1] - total_supernode_num_periods[_period-1];
        require(_periodRemain > 0, "Out of current period limit");

        uint256 supernode_period_pay = supernode_period_pays[_period-1];

        /* Transfer user address token to 1cc contract address*/
        if(supernode_period_pay==1){
            /* format token amount */
            uint256 token_amount = _getTokenAmount(_amount,invest_1cc_token_decimal);
            require(invest1ccToken.transferFrom(msg.sender, burning_address, token_amount), "transferFrom failed");
        }

        /* Transfer user address token to enc contract address*/
        if(supernode_period_pay==2){
            /* format token amount */
            uint256 token_amount = _getTokenAmount(_amount,invest_enc_token_decimal);
            require(investEncToken.transferFrom(msg.sender, burning_address, token_amount), "transferFrom failed");
        }
        
        _setReferral(msg.sender, _referral);
        
        /* set the player of supernodes roles */
        player.is_supernode = 1;
        total_supernode_num += 1;
        total_supernode_num_periods[_period-1] += 1;
    
        /* push user to shareholder list*/
        supernodes.push(msg.sender);

        emit SuperNode(msg.sender, _period, _amount);
    }
    
    /*
    * @dev user do crowd action, to get enc
    */
    function crowd(address _referral, uint256 _period, uint256 _amount)
        payable
        external 
    {
        require(_period >= 1 && _period <= 7 , "Invalid Period Id");
        
        if(_period > 1){
            uint256 _lastPeriodLimit = crowd_period_limits[_period-2];
            require(total_crowd_num_periods[_period-2] >= _lastPeriodLimit, "Current round not started yet ");
        }
        
        //valid period remain
        uint256 _periodRemain = crowd_period_limits[_period-1] - total_crowd_num_periods[_period-1];
        require(_periodRemain > 0, "Out of current period limit");

        uint256 _periodRate = crowd_period_rates[_period-1];
        
        uint256 token_enc_amount = _getTokenAmount(_amount,invest_enc_token_decimal);
        uint256 token_1cc_amount = _getTokenAmount(_amount.mul(_periodRate),invest_1cc_token_decimal);
        
        /* Transfer user address token to burning address*/
        require(invest1ccToken.transferFrom(msg.sender, burning_address, token_1cc_amount), "transferFrom failed");

        _setReferral(msg.sender, _referral);
        
        /* get the period total time (total seconds) */
        uint256 _period_ = 4;
        uint256 _month = crowd_period_month;
        uint256 period_time = _month.mul(30).mul(86400);
        
        //updater period total number
        total_crowd_num_periods[_period-1] += _amount;
        
        Player storage player = players[msg.sender];
        
        /* update total investor count */
        if(player.deposits.length == 0){
            total_investors += 1;
            addrmap[total_investors] = msg.sender;
        }
        
        uint256 _id = player.deposits.length + 1;
        player.deposits.push(PlayerDeposit({
            id: _id,
            amount: token_enc_amount,
            total_withdraw: 0,
            time: uint256(block.timestamp),
            period: _period_,
            month: _month,
            expire: uint256(block.timestamp).add(period_time),
            status: 0,
            is_crowd: 1
        }));
        
        //update total invested
        player.total_invested += token_enc_amount;
        total_invested += token_enc_amount;
        
        invest_period_totals[_period_-1] += token_enc_amount;
        
        //update player period total invest data
        _updatePlayerPeriodTotalInvestedData(msg.sender, _period_, token_enc_amount, 1);
        
        /* update user referral and match invested amount*/
        _updateReferralMatchInvestedAmount(msg.sender, token_enc_amount, 1);

        emit Crowd(msg.sender, _period, _amount);
    }
    
    
    /*
    * @dev user do deposit action,grant the referrs bonus,grant the shareholder bonus,grant the match bonus
    */
    function deposit(address _referral, uint256 _amount, uint256 _period) 
        external
        payable
    {
        require(_period >= 1 && _period <= 4 , "Invalid Period Id");
        
        uint256 _month = invest_period_months[_period-1];
        
        /* format token amount  */
        uint256 _decimal = invest_enc_token_decimal - invest_1cc_token_decimal;
        uint256 token_enc_amount = _amount;
        uint256 token_1cc_amount = _amount.div(10**_decimal);
        
        require(token_enc_amount >= INVEST_MIN_AMOUNT, "Minimal deposit: 0.1 enc");
        require(token_enc_amount <= INVEST_MAX_AMOUNT, "Maxinum deposit: 1000000 enc");

        Player storage player = players[msg.sender];
        require(player.deposits.length < 2000, "Max 2000 deposits per address");
        
        /* Transfer user address token to contract address*/
        require(investEncToken.transferFrom(msg.sender, address(this), token_enc_amount), "transferFrom failed");
        require(invest1ccToken.transferFrom(msg.sender, burning_address, token_1cc_amount), "transferFrom failed");

        _setReferral(msg.sender, _referral);
        
        /* update total investor count */
        if(player.deposits.length == 0){
            total_investors += 1;
            addrmap[total_investors] = msg.sender;
        }
        
        /* get the period total time (total secones) */
        uint256 period_time = _month.mul(30).mul(86400);
        
        uint256 _id = player.deposits.length + 1;
        player.deposits.push(PlayerDeposit({
            id: _id,
            amount: token_enc_amount,
            total_withdraw: 0,
            time: uint256(block.timestamp),
            period: _period,
            month: _month,
            expire:uint256(block.timestamp).add(period_time),
            status: 0,
            is_crowd: 0
        }));

        player.total_invested += token_enc_amount;
        total_invested += token_enc_amount;
        
        invest_period_totals[_period-1] += token_enc_amount;
        
        //update player period total invest data
        _updatePlayerPeriodTotalInvestedData(msg.sender, _period, token_enc_amount, 1);
        
        /* update user referral and match invested amount*/
        _updateReferralMatchInvestedAmount(msg.sender, token_enc_amount, 1);

        emit Deposit(msg.sender, _amount, _month);
    }
    
    
    /*
    * @dev user do withdraw action, tranfer the total profit to user account, grant rereferral bonus, grant match bonus, grant shareholder bonus
    */
    function withdraw() 
        payable 
        external 
    {
        /* get contract pool balance*/
        uint256 _contract_balance = investEncToken.balanceOf(address(this));
        require(_contract_balance >= total_invested, "Insufficient Pool Balance");
        uint256 _contract_pool_balance = _contract_balance - total_invested;

        /* update user dividend data */
        _payout(msg.sender);
        
        Player storage player = players[msg.sender];

        uint256 _amount = player.dividends + player.referral_bonus + player.match_bonus + player.supernode_bonus;
        /* verify contract pool balance is enough or not*/
        require(_contract_pool_balance >= _amount, "Insufficient Pool Balance");
        require(_amount >= 1000000, "Minimal payout: 0.01 ENC");
        
        /* format deposit token amount  */
        uint256 token_enc_amount = _amount;
    
        /* process token transfer action */
        require(investEncToken.approve(address(this), token_enc_amount), "approve failed");
        require(investEncToken.transferFrom(address(this), msg.sender, token_enc_amount), "transferFrom failed");

        /*transfer service fee to contract*/
        uint256 token_1cc_fee_amount = withdraw_fee_amount;
        require(invest1ccToken.transferFrom(msg.sender, burning_address, token_1cc_fee_amount), "transferFrom failed");
        
        uint256 _dividends = player.dividends;
                
        /* Update user total payout data */
        _updatePlayerTotalPayout(msg.sender, token_enc_amount);

        /* Grant referral bonus */
        _referralPayout(msg.sender, _dividends);
        
        /* Grant super node bonus */
        _superNodesPayout(_dividends);
        
        /* Grant team match bonus*/
        _matchPayout(msg.sender, _dividends);

        emit Withdraw(msg.sender, token_enc_amount);
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
        
        require(player.deposits[_index].status == 0, "Invest is redeemed");
        
        //crowded deposit can't do early redeem action
        //if(player.deposits[_index].is_crowd == 1) {
        require(player.deposits[_index].expire < block.timestamp, "Invest not expired");
        //}
        
        /* formt deposit token amount */
        uint256 token_enc_amount = player.deposits[_index].amount;
        
        //deposit is not expired, deduct the fee (10%)
        if(player.deposits[_index].expire > block.timestamp){
            //token_enc_amount = token_enc_amount * (100 - invest_early_redeem_feerate) / 100;
        }
        
        /* process token transfer action*/
        require(investEncToken.approve(address(this), token_enc_amount), "approve failed");
        require(investEncToken.transferFrom(address(this), msg.sender, token_enc_amount), "transferFrom failed");
        
        /* update deposit status in redeem */
        player.deposits[_index].status = 1;
        
        uint256 _amount = player.deposits[_index].amount;
        
        /* update user token balance*/
        player.total_invested -= _amount;
        
        /* update total invested/redeem amount */
        total_invested -= _amount;
        total_redeem += _amount;
        
        /* update invest period total invested amount*/
        uint256 _period = player.deposits[_index].period;
        invest_period_totals[_period-1] -= _amount;
        
        //update player period total invest data
        _updatePlayerPeriodTotalInvestedData(msg.sender, _period, _amount, -1);
        
        /* update user referral and match invested amount*/
        _updateReferralMatchInvestedAmount(msg.sender, _amount, -1);

        emit DepositRedeem(_invest_id);
    }
     
    /*
    * @dev Update Referral Match invest amount, total investor number, map investor address index
    */
    function _updateReferralMatchInvestedAmount(address _addr,uint256 _amount,int8 _opType) 
        private
    {
        if(_opType > 0) {
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
        playerTotal.total_supernode_bonus += player.supernode_bonus;
        
        /* update platform total data*/
        total_withdrawn += token_amount;
        total_dividends += player.dividends;
        total_referral_bonus += player.referral_bonus;
        total_match_bonus += player.match_bonus;
        total_supernode_bonus += player.supernode_bonus;
        uint256 _platform_bonus = (token_amount * platform_bonus_rate / 100);
        total_platform_bonus += _platform_bonus;
        
        /* update platform address bonus*/
        players[platform_bonus_address].match_bonus += _platform_bonus;
        
        /* reset user bonus data */
        player.dividends = 0;
        player.referral_bonus = 0;
        player.match_bonus = 0;
        player.supernode_bonus = 0;
    }
    
    
    /*
    * @dev get user deposit expire status
    */
    function _getExpireStatus(address _addr)
        view
        private
        returns(uint256 value)
    {
        Player storage player = players[_addr];
        uint256 _status = 1;
        for(uint256 i = 0; i < player.deposits.length; i++) {
            
            PlayerDeposit storage dep = player.deposits[i];

            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > dep.expire ? dep.expire : uint256(block.timestamp);

            if(from < to && dep.status == 0) {
                _status = 0;
                break;
            }
        }
        return _status;
    }
    
    /*
    * @dev update user referral data
    */
    function _setReferral(address _addr, address _referral) 
        private 
    {
        /* if user referral is not set */
        if(players[_addr].referral == address(0) && _referral != _addr && _referral != address(0)) {
            
            Player storage ref_player = players[_referral];
            
            if(ref_player.referral != address(0) || _referral == platform_bonus_address){
                
                players[_addr].referral = _referral;

                /* update user referral address list*/
                players[_referral].referrals.push(_addr);
            }
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
            
             //validate account deposit is all expired or not
            uint256 _is_expire = _getExpireStatus(ref);
            if(_is_expire == 0) {
                uint256 bonus = _token_amount * referral_bonuses[i] / 100;
                players[ref].referral_bonus += bonus;
            }
            ref = players[ref].referral;
        }
    }
    
    /*
    * @dev  Grant shareholder full node bonus in user withdraw
    */
    function _superNodesPayout(uint256 _amount)
        private
    {
        uint256 _supernode_num = supernodes.length;
        if(_supernode_num == 0) return;
        
        uint256 bonus = _amount * supernode_bonus_rate / 100 / _supernode_num;
        for(uint256 i = 0; i < _supernode_num; i++) {
            address _addr = supernodes[i];
            players[_addr].supernode_bonus += bonus;
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
            
            //validate account deposit is all expired or not
            uint256 _is_expire = _getExpireStatus(ref);
            
            /* upgrade player team level id*/
            _upgradePlayerTeamLevel(ref);
            
            if(players[ref].level_id > last_level_id){
                
                uint256 last_level_bonus = 0;
                if(last_level_id > 0){
                    last_level_bonus = team_level_bonuses[last_level_id-1];
                }
                uint256 cur_level_bonus = team_level_bonuses[players[ref].level_id-1];
                uint256 bonus_amount = _amount * (cur_level_bonus - last_level_bonus) / 100;
                
                if(_is_expire==0){
                    players[ref].match_bonus += bonus_amount;
                }
                
                last_level_id = players[ref].level_id;
                
                /* referral is max team level, quit */
                if(last_level_id == team_level_ids[team_level_ids.length-1]) 
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
            
            uint256 _team_level_amount = _getTokenAmount(team_level_amounts[i], invest_enc_token_decimal);
            if(community_total_invested >= _team_level_amount){
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
                uint256 _dep_payout = _day_payout * (to - from) / 86400;
                uint256 _period = player.deposits[i].period;
                player.deposits[i].total_withdraw += _dep_payout;
                invest_period_devidends[_period-1]+= _dep_payout;
                
                //update player period total devidend data
                _updatePlayerPeriodTotalDevidendsData(msg.sender,_period,_dep_payout);
            }
        }
    }
    
    /*
    * @dev update player period total invest data
    */
    function _updatePlayerPeriodTotalInvestedData(address _addr,uint256 _period,uint256 _token_amount,int8 _opType)
        private
    {
        if(_opType==-1){
            if(_period==1){
                playerTotals[_addr].total_period1_invested -= _token_amount;
                return;
            }
            if(_period==2){
                playerTotals[_addr].total_period2_invested -= _token_amount;
                return;
            }
            if(_period==3){
                playerTotals[_addr].total_period3_invested -= _token_amount;
                return;
            }
            if(_period==4){
                playerTotals[_addr].total_period4_invested -= _token_amount;
                return;
            }
        }else{
            if(_period==1){
                playerTotals[_addr].total_period1_invested += _token_amount;
                return;
            }
            if(_period==2){
                playerTotals[_addr].total_period2_invested += _token_amount;
                return;
            }
            if(_period==3){
                playerTotals[_addr].total_period3_invested += _token_amount;
                return;
            }
            if(_period==4){
                playerTotals[_addr].total_period4_invested += _token_amount;
                return;
            }
        }
    }
    
    /*
    * @dev update player period total devidend data
    */
    function _updatePlayerPeriodTotalDevidendsData(address _addr,uint256 _period,uint256 _dep_payout)
        private
    {
        if(_period==1){
            playerTotals[_addr].total_period1_devidends += _dep_payout;
            return;
        }
        if(_period==2){
            playerTotals[_addr].total_period2_devidends += _dep_payout;
            return;
        }
        if(_period==3){
            playerTotals[_addr].total_period3_devidends += _dep_payout;
            return;
        }
        if(_period==4){
            playerTotals[_addr].total_period4_devidends += _dep_payout;
            return;
        }
    }
    
    
    /*
    * @dev get the invest period rate, if total yield reached reduce limit, invest day rate will be reduce
    */
    function _getInvestDayPayoutOf(uint256 _amount, uint256 _period) 
        view 
        private 
        returns(uint256 value)
    {
        /* get invest period base rate*/
        uint256 period_month_rate = invest_period_rates[_period-1];
        
        /* format amount with token decimal */
        uint256 token_amount = _amount;
        value = token_amount * period_month_rate / 30 / 10000;
        
        if(value > 0){
            
            /* total yield reached 30,000,start section1 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section1[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section1[1]) / 100;
            }
            /* total yield reached 60,000,start section2 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section2[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section2[1]) / 100;
            }
            /* total yield reached 90,000,start section3 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section3[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section3[1]) / 100;
            }
            /* total yield reached 290,000,start section4 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section4[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section4[1]) / 100;
            }
            /* total yield reached 600,000,start section5 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section5[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section5[1]) / 100;
            }
            /* total yield reached 900,000,start section6 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section6[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section6[1]) / 100;
            }
            /* total yield reached 1400,000,start section7 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section7[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section7[1]) / 100;
            }
            /* total yield reached 2000,000,start section8 reduce */
            if(total_withdrawn >= _getTokenAmount(yield_reduce_section8[0], invest_enc_token_decimal)){
                value = value * (100 - yield_reduce_section8[1]) / 100;
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
            
            //uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            //uint256 to = block.timestamp > dep.expire ? dep.expire : uint256(block.timestamp);
            
            if(dep.status == 0) {
                uint256 _day_payout = _getInvestDayPayoutOf(dep.amount, dep.period);
                value += _day_payout;
            }
        }
        return value;
    }
    
  
    /*
    * @dev Remove supernodes of the special address
    */
    function _removeSuperNodes(address _addr) private {
        for (uint index = 0; index < supernodes.length; index++) {
            if(supernodes[index] == _addr){
                for (uint i = index; i < supernodes.length-1; i++) {
                    supernodes[i] = supernodes[i+1];
                }
                delete supernodes[supernodes.length-1];
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
        returns(
            uint256 _total_invested, uint256 _total_investors, uint256 _total_withdrawn, 
            uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_platform_bonus, 
            uint256 _total_supernode_num, uint256 _crowd_period_month,
            uint256 _crowd_period_start, uint256 _total_holder_bonus, uint256 _total_match_bonus) 
    {
        return (
            total_invested, 
            total_investors, 
            total_withdrawn, 
            total_dividends, 
            total_referral_bonus, 
            total_platform_bonus, 
            total_supernode_num, 
            crowd_period_month,
            crowd_period_start,
            total_supernode_bonus,
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
        returns
        (
            address _referral, uint256 _referral_num, uint256 _is_supernode, 
            uint256 _dividends, uint256 _referral_bonus, uint256 _match_bonus, 
            uint256 _supernode_bonus,uint256 _last_payout
        )
    {
        Player storage player = players[_addr];
        return (
            player.referral,
            player.referrals.length,
            player.is_supernode,
            player.dividends,
            player.referral_bonus,
            player.match_bonus,
            player.supernode_bonus,
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
        returns(
            uint256 _total_invested, uint256 _total_withdrawn, uint256 _total_community_invested, 
            uint256 _total_match_invested, uint256 _total_dividends, uint256 _total_referral_bonus, 
            uint256 _total_match_bonus, uint256 _total_supernode_bonus
            )
    {
        Player storage player = players[_addr];
        PlayerTotal storage playerTotal = playerTotals[_addr];
        
        /* get community total invested*/
        uint256 total_community_invested = _getCommunityTotalInvested(_addr);
        
        return (
            player.total_invested,
            player.total_withdrawn,
            total_community_invested,
            playerTotal.total_match_invested,
            playerTotal.total_dividends,
            playerTotal.total_referral_bonus,
            playerTotal.total_match_bonus,
            playerTotal.total_supernode_bonus
        );
    }
    
    /*
    * @dev get user investment list
    */
    function getInvestList(address _addr)
        view 
        external 
        returns(
            uint256[] memory ids,uint256[] memory times, uint256[] memory months, 
            uint256[] memory amounts,uint256[] memory withdraws,
            uint256[] memory statuses,uint256[] memory payouts)
    {
        Player storage player = players[_addr];
        
        PlayerDeposit[] memory deposits = _getValidInvestList(_addr);
        
        uint256[] memory _ids = new uint256[](deposits.length);
        uint256[] memory _times = new uint256[](deposits.length);
        uint256[] memory _months = new uint256[](deposits.length);
        uint256[] memory _amounts = new uint256[](deposits.length);
        uint256[] memory _withdraws = new uint256[](deposits.length);
        uint256[] memory _statuses = new uint256[](deposits.length);
        uint256[] memory _payouts = new uint256[](deposits.length);
        
        for(uint256 i = 0; i < deposits.length; i++) {
            PlayerDeposit memory dep = deposits[i];
            _ids[i] = dep.id;
            _amounts[i] = dep.amount;
            _withdraws[i] = dep.total_withdraw;
            _times[i] = dep.time;
            _months[i] = dep.month;
            _statuses[i] = dep.is_crowd;
            
            //get deposit current payout
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > dep.expire ? dep.expire : uint256(block.timestamp);
            if(from < to && dep.status == 0) {
                uint256 _day_payout = _getInvestDayPayoutOf(dep.amount,dep.period);
                uint256 _value = _day_payout * (to - from) / 86400;
                _payouts[i] = _value;
            }
        }
        return (
            _ids,
            _times,
            _months,
            _amounts,
            _withdraws,
            _statuses,
            _payouts
        );
    }
    
    /*
    * @dev get deposit valid count
    */
    function _getValidInvestList(address _addr)
        view
        private
        returns(PlayerDeposit[] memory)
    {
        
        Player storage player = players[_addr];
        uint256 resultCount;
        for (uint i = 0; i < player.deposits.length; i++) {
            if ( player.deposits[i].status == 0) {
                resultCount++;
            }
        }
        PlayerDeposit[] memory deposits = new PlayerDeposit[](resultCount);  
        uint256 j;
        for(uint256 i = 0; i < player.deposits.length; i++){
            if(player.deposits[i].status==0){
                deposits[j] = player.deposits[i];
                j++;
            }
        }
        return deposits;
    }
    
    /*
    * @dev get crowd period list
    */
    function getCrowdPeriodList()
        view 
        external 
        returns(uint256[] memory ids,uint256[] memory rates, uint256[] memory limits, uint256[] memory totals) 
    {
        return (
            crowd_period_ids,
            crowd_period_rates,
            crowd_period_limits,
            total_crowd_num_periods
        );
    }
    
    /*
    * @dev get invest period list
    */
    function getInvestPeriodList(address _addr)
        view 
        external 
        returns(
            uint256[] memory ids,
            uint256[] memory months, 
            uint256[] memory rates,
            uint256[] memory totals,
            uint256[] memory devidends,
            uint256[] memory user_investeds,
            uint256[] memory user_devidends) 
    {
        
        PlayerTotal storage playerTotal = playerTotals[_addr];
        uint256[] memory _user_period_investeds = new uint256[](4);
        uint256[] memory _user_period_devidends = new uint256[](4);
        _user_period_investeds[0] = playerTotal.total_period1_invested;
        _user_period_investeds[1] = playerTotal.total_period2_invested;
        _user_period_investeds[2] = playerTotal.total_period3_invested;
        _user_period_investeds[3] = playerTotal.total_period4_invested;
        _user_period_devidends[0] = playerTotal.total_period1_devidends;
        _user_period_devidends[1] = playerTotal.total_period2_devidends;
        _user_period_devidends[2] = playerTotal.total_period3_devidends;
        _user_period_devidends[3] = playerTotal.total_period4_devidends;
        
        return (
            invest_period_ids,
            invest_period_months,
            invest_period_rates,
            invest_period_totals,
            invest_period_devidends,
            _user_period_investeds,
            _user_period_devidends
        );
    }
    
    /*
    * @dev get supernode period list
    */
    function getSuperNodePeriodList()
        view 
        external 
        returns(uint256[] memory ids,uint256[] memory pays,uint256[] memory amounts, uint256[] memory limits,uint256[] memory totals) 
    {
        return (
            supernode_period_ids,
            supernode_period_pays,
            supernode_period_amounts,
            supernode_period_limits,
            total_supernode_num_periods
        );
    }

    /*
    * @dev Migrate contract data (migration from heco chain to biance smart chain)
    */
    function migrateContract(uint256 _total_invested, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_platform_bonus, uint256 _total_supernode_num, uint256 _total_holder_bonus, uint256 _total_match_bonus) 
        external onlyOwner
        payable  
    {
        total_invested = _total_dividends;
        total_withdrawn = _total_withdrawn;
        total_dividends = _total_dividends;
        total_referral_bonus = _total_referral_bonus;
        total_platform_bonus = _total_platform_bonus; 
        total_supernode_num = _total_supernode_num; 
        total_supernode_bonus = _total_holder_bonus;
        total_match_bonus = _total_match_bonus;
        total_investors = 0;

        emit MigrateContract(_total_invested, _total_investors, _total_withdrawn, _total_dividends, _total_referral_bonus, _total_platform_bonus, _total_supernode_num, _total_holder_bonus, _total_match_bonus);
    }


    /*
    * @dev Migrate player data (migration from heco chain to biance smart chain)
    */
    function migratePlayer(address _addr, address _referral, uint8 _is_supernode, uint256 _dividends, uint256 _referral_bonus, uint256 _match_bonus, uint256 _supernode_bonus,uint256 _last_payout,uint256 _total_invested, uint256 _total_withdrawn) 
        external onlyOwner
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        Player storage player = players[_addr];
        player.is_supernode = _is_supernode;
        player.dividends = _dividends;
        player.referral_bonus = _referral_bonus;
        player.supernode_bonus = _supernode_bonus;
        player.match_bonus = _match_bonus;
        player.last_payout = _last_payout;
        player.total_invested = _total_invested;
        player.total_withdrawn = _total_withdrawn;

        /* update user referral address list*/
        player.referral = _referral;
        players[_referral].referrals.push(_addr);
        
        /* update total investor count */
        total_investors += 1;
        addrmap[total_investors] = _addr;

        /* push user to shareholder list*/
        if (_is_supernode == 1) {
            supernodes.push(_addr);
        }

        emit MigratePlayer(_addr,  _referral, _is_supernode, _dividends, _referral_bonus, _match_bonus, _supernode_bonus, _last_payout,_total_invested, _total_withdrawn);
    }


    /*
    * @dev Migrate player total data (migration from heco chain to biance smart chain)
    */
    function migratePlayerTotal(address _addr,uint256 _total_match_invested, uint256 _total_dividends, uint256 _total_referral_bonus, uint256 _total_match_bonus, uint256 _total_supernode_bonus)
        external onlyOwner 
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        PlayerTotal storage playerTotal = playerTotals[_addr];
        playerTotal.total_match_invested = _total_match_invested;
        playerTotal.total_dividends = _total_dividends;
        playerTotal.total_referral_bonus = _total_referral_bonus;
        playerTotal.total_match_bonus = _total_match_bonus;
        playerTotal.total_supernode_bonus = _total_supernode_bonus;

        emit MigratePlayerTotal(_addr, _total_match_invested, _total_dividends, _total_referral_bonus, _total_match_bonus, _total_supernode_bonus);
    }

/*
    * @dev Migrate player total period data (migration from heco chain to biance smart chain)
    */
    function migratePlayerTotalPeriod(address _addr,uint256 _total_period1_invested,uint256 _total_period2_invested,uint256 _total_period3_invested,uint256 _total_period4_invested,uint256 _total_period1_devidends,uint256 _total_period2_devidends,uint256 _total_period3_devidends,uint256 _total_period4_devidends)
        external onlyOwner 
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        PlayerTotal storage playerTotal = playerTotals[_addr];

        playerTotal.total_period1_invested = _total_period1_invested;
        playerTotal.total_period2_invested = _total_period2_invested;
        playerTotal.total_period3_invested = _total_period3_invested;
        playerTotal.total_period4_invested = _total_period4_invested;
        playerTotal.total_period1_devidends = _total_period1_devidends;
        playerTotal.total_period2_devidends = _total_period2_devidends;
        playerTotal.total_period3_devidends = _total_period3_devidends;
        playerTotal.total_period4_devidends = _total_period4_devidends;

        emit MigratePlayerTotalPeriod(_addr, _total_period1_invested, _total_period2_invested, _total_period3_invested, _total_period4_invested, _total_period1_devidends, _total_period2_devidends, _total_period3_devidends, _total_period4_devidends);
    }

    /*
    * @dev Migrate player deposit data (migration from heco chain to biance smart chain)
    */
    function migrateDeposit(address _addr, uint256 _time, uint256 _amount, uint256 _total_withdraw,uint256 _month, uint8 _is_crowd) 
        external onlyOwner 
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        uint256 period_time = _month.mul(30).mul(86400);
        Player storage player = players[_addr];

        uint256 _id = player.deposits.length + 1;
        uint256 _period = 4;
        if(_month == 3) _period = 1;
        if(_month == 6) _period = 2;
        if(_month == 12) _period = 3;
        if(_month == 24) _period = 4;
        player.deposits.push(PlayerDeposit({
            id: _id,
            amount: _amount,
            total_withdraw: _total_withdraw,
            time: _time,
            month: _month,
            expire: _time.add(period_time),
            period: _period,
            status: 0,
            is_crowd: _is_crowd
        }));

        emit MigrateDeposit(_addr, _time, _amount, _total_withdraw, _month, _is_crowd);
    }

    /*
    * @dev Migrate player deposit period data (migration from heco chain to biance smart chain)
    */
    function migrateDepositPeriod(uint256 _period_total1, uint256 _period_total2, uint256 _period_total3,uint256 _period_total4,uint256 _period_devidend1, uint256 _period_devidend2, uint256 _period_devidend3,uint256 _period_devidend4) 
        external onlyOwner 
        payable 
    {
        /* verify migration deadline is pending */
        require(MIGRATION_DEADLINE==0,"Migration is deadline");

        invest_period_totals[0] = _period_total1;
        invest_period_totals[1] = _period_total2;
        invest_period_totals[2] = _period_total3;
        invest_period_totals[3] = _period_total4;
        invest_period_devidends[0] = _period_devidend1;
        invest_period_devidends[1] = _period_devidend2;
        invest_period_devidends[2] = _period_devidend3;
        invest_period_devidends[3] = _period_devidend4;

        emit MigrateDepositPeriod(_period_total1, _period_total2,  _period_total3, _period_total4, _period_devidend1, _period_devidend2, _period_devidend3, _period_devidend4);
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