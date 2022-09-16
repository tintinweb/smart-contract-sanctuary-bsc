/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

pragma solidity 0.5.10;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function burn(address account, uint amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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


contract MetaGlobalPlanMRS {
    struct User {
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 payouts_mg;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 deposit_amount;
        uint256 deposit_payouts;
        uint256 direct_payouts;
        uint256 match_payouts;
        uint40 deposit_time;
        uint256 total_structure;
        uint256 deposit_amount_mg;
        uint8 is_limit_reached;
        mapping(uint8 => Level) levels;
    }


    struct Level {
        uint256 total_structure;
        uint256 total_deposited; 
        uint256 total_deposited_mg;
        mapping(uint256 => address) users;
    }

    address payable public owner;

    //Live
    //IERC20 public busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    //IERC20 public mg = IERC20(0xD4eE64b161B2453715c727f70d1606F2022Ee2a4); 
    //MetaGlobalPlanTemplate mgp = MetaGlobalPlanTemplate(0xADb4578E8555a0a1A75CC24FD4cD254B82e8e0a3);   

    //Test
    IERC20 public busd = IERC20(0x306B5BD92DFf425CE50a6AEb7DD2769B04f2148f);
    IERC20 public mg = IERC20(0xEd06841DD92135d739B67eb4660Ebb82757A1cef);  
    MetaGlobalPlanTemplate mgp = MetaGlobalPlanTemplate(0x5f96B8B81684D985482CA282ef05Cc785e726e8B);  

    mapping(address => User) public users;

    uint8[] public ref_bonuses; 
    uint8[] public direct_bonuses; 
    uint8[] public direct_bonuses_criteria; 

    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public total_deposited_mg;
    uint256 public total_withdraw;
    uint256 public total_withdraw_mg;
    
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount, uint256 amount_mg);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event WithdrawMG(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);

    constructor(address payable _owner) public {
        owner = _owner;
        
        ref_bonuses.push(15);
        ref_bonuses.push(4);
        ref_bonuses.push(3);
        ref_bonuses.push(2);
        ref_bonuses.push(1);

        direct_bonuses.push(5);
        direct_bonuses.push(2);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(1);

        direct_bonuses_criteria.push(0);
        direct_bonuses_criteria.push(2);
        direct_bonuses_criteria.push(4);
        direct_bonuses_criteria.push(6);
        direct_bonuses_criteria.push(10);                

        
   
    }

    function() payable external {
        _deposit(msg.sender);
    }

    function _setUpline(address _addr, address _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner && (users[_upline].deposit_time > 0 || _upline == owner)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_addr, _upline);

            total_users++;

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;

                users[_upline].total_structure++;
                users[_upline].levels[i].users[users[_upline].levels[i].total_structure] = _addr;
                users[_upline].levels[i].total_structure++;
               
                _upline = users[_upline].upline;
            }
        }
    }

    function _deposit(address _addr) private {
        require(users[_addr].upline != address(0) || _addr == owner, "No upline");

        //Check for existing AMS User
        uint256 ams_deposit = GetDepositAmount(_addr);
        require( ams_deposit > 0, "Not a AMS User");

        uint256 wallet_balance = GetWalletBalance(_addr);
        require( wallet_balance >= 100000000000000000000000, "Low MG Balancer");
        
        users[_addr].payouts = 0;
        users[_addr].deposit_amount_mg = wallet_balance;
        users[_addr].deposit_payouts = 0;
        users[_addr].direct_bonus = 0;
        users[_addr].match_bonus = 0;
        users[_addr].deposit_time = uint40(block.timestamp);
        users[_addr].deposit_amount = ams_deposit;
        users[_addr].is_limit_reached = 0;

        total_deposited_mg += wallet_balance;
        total_deposited += ams_deposit;
        
        emit NewDeposit(_addr, ams_deposit, wallet_balance);

        _directPayout(_addr, ams_deposit, wallet_balance);        
    }

    function _directPayout(address _addr, uint256 _amount, uint256 _amount_mg) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < direct_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(users[up].referrals >= direct_bonuses_criteria[i]) {
                uint256 bonus = _amount * direct_bonuses[i] / 100;
                
                users[up].direct_bonus += bonus;

                users[up].levels[i].total_deposited += _amount;
                users[up].levels[i].total_deposited_mg += _amount_mg;

                emit DirectPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;

            uint256 bonus = _amount * ref_bonuses[i] / 100;                
            users[up].match_bonus += bonus;
            emit MatchPayout(up, _addr, bonus);

            up = users[up].upline;
        }
    }

    function deposit(address _upline) payable external {
        _setUpline(msg.sender, _upline);
        _deposit(msg.sender);
    }

    function withdraw() external {

        uint256 bal = mg.balanceOf(msg.sender);
        require(bal >= users[msg.sender].deposit_amount_mg,"Invalid Wallet Balance");

        uint256 to_payout = 0;
        
        // Direct payout
        if(users[msg.sender].direct_bonus > 0) {
            uint256 direct_bonus = users[msg.sender].direct_bonus;

            users[msg.sender].direct_bonus -= direct_bonus;
            users[msg.sender].payouts += direct_bonus;
            users[msg.sender].direct_payouts += direct_bonus;
            to_payout += direct_bonus;
        }
        
        require(to_payout > 0, "Zero payout");
        
        total_withdraw += to_payout;

        safeTransfer(msg.sender, to_payout);

        emit Withdraw(msg.sender, to_payout);
    }

    function withdrawMG() external {

        uint256 bal = mg.balanceOf(msg.sender);
        require(bal >= users[msg.sender].deposit_amount_mg,"Invalid Wallet Balance");

        (uint256 to_payout,uint256 daysGone) = this.payoutOf(msg.sender);

        // Deposit payout
        if(to_payout > 0) {
            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts_mg += to_payout;

            _refPayout(msg.sender, to_payout);
        }

        if (users[msg.sender].is_limit_reached == 0 && daysGone >= 365) {
            users[msg.sender].is_limit_reached = 1;
            emit LimitReached(msg.sender, users[msg.sender].deposit_payouts);
        }
              
        // Match payout
        if(users[msg.sender].match_bonus > 0) {
            uint256 match_bonus = users[msg.sender].match_bonus;

            users[msg.sender].match_bonus -= match_bonus;
            users[msg.sender].payouts_mg += match_bonus;
            users[msg.sender].match_payouts += match_bonus;
            to_payout += match_bonus;
        }

        require(to_payout > 0, "Zero payout");
    
        total_withdraw_mg += to_payout;

        safeTransferMG(msg.sender, to_payout);

        emit WithdrawMG(msg.sender, to_payout);

    }
    
    function payoutOf(address _addr) view external returns(uint256 payout, uint256 daysGone) {
        daysGone = ((block.timestamp - users[_addr].deposit_time) / 1 seconds);
        if(daysGone > 365) {
            daysGone = 365;
        }

        payout = (users[_addr].deposit_amount_mg * (daysGone) / 10000) * 30 - users[_addr].deposit_payouts;
    }

    function doDeposit( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
            busd.transferFrom(address(msg.sender), address(this), _amount);
        }

    }    

    function getPayout( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
          uint256 bal = busd.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransfer(msg.sender, amtToTransfer);
            }
        }
    }	

    function getPayoutMG( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
          uint256 bal = mg.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransferMG(msg.sender, amtToTransfer);
            }
        }
    }	

    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = busd.balanceOf(address(this));
        require(tokenBal >= _amount,"Insufficient BUSD Balance" );
        busd.transfer(_to, _amount);
    }
	
    function safeTransferMG(address _to, uint256 _amount) internal {
        uint256 tokenBal = mg.balanceOf(address(this));
        require(tokenBal >= _amount,"Insufficient MG Balance" );
        mg.transfer(_to, _amount);
    }    

    function  GetDepositAmount(address addr) view internal returns (uint256) {
        (uint40 a, uint256 b, uint8 c) =  mgp.userDepositInfo(addr);
        return b;
    }    

    function  GetWalletBalance(address addr) view internal returns (uint256) {
        return mg.balanceOf(addr);
    }

    /*
        Only external call
    */
    function userInfo(address _addr) view external returns(address upline, uint40 deposit_time, uint256 deposit_amount, uint256 deposit_amount_mg, uint256 direct_bonus, uint256 match_bonus) {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].deposit_amount_mg, users[_addr].direct_bonus, users[_addr].match_bonus);
    }

    function userIncomeInfo(address _addr) view external returns(uint256 payouts, uint256 payouts_mg, uint256 deposit_payouts, uint256 direct_payouts, uint256 match_payouts) {
        return (users[_addr].payouts, users[_addr].payouts_mg, users[_addr].deposit_payouts, users[_addr].direct_payouts, users[_addr].match_payouts);
    }    

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_structure) {
        return (users[_addr].referrals, users[_addr].total_structure);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_deposited_mg, uint256 _total_withdraw, uint256 _total_withdraw_mg) {
        return (total_users, total_deposited, total_deposited_mg, total_withdraw, total_withdraw_mg);
    }

    function levelInfo(address _addr) view external returns (uint256[] memory _total_structure, 
                                    uint256[] memory _total_deposited, uint256[] memory _total_deposited_mg) {
        uint256[] memory structure = new uint256[](5);
        uint256[] memory deposited  = new uint256[](5);
        uint256[] memory deposited_mg  = new uint256[](5);

        structure[0] = users[_addr].levels[0].total_structure;
        structure[1] = users[_addr].levels[1].total_structure;
        structure[2] = users[_addr].levels[2].total_structure;
        structure[3] = users[_addr].levels[3].total_structure;
        structure[4] = users[_addr].levels[4].total_structure;

        deposited[0] = users[_addr].levels[0].total_deposited;
        deposited[1] = users[_addr].levels[1].total_deposited;
        deposited[2] = users[_addr].levels[2].total_deposited;
        deposited[3] = users[_addr].levels[3].total_deposited;
        deposited[4] = users[_addr].levels[4].total_deposited;

        deposited_mg[0] = users[_addr].levels[0].total_deposited_mg;
        deposited_mg[1] = users[_addr].levels[1].total_deposited_mg;
        deposited_mg[2] = users[_addr].levels[2].total_deposited_mg;
        deposited_mg[3] = users[_addr].levels[3].total_deposited_mg;
        deposited_mg[4] = users[_addr].levels[4].total_deposited_mg; 

        return (structure, deposited, deposited_mg);
    }

}


contract MetaGlobalPlanTemplate {

    function userDepositInfo(address _addr) view external returns(uint40 deposit_time, uint256 deposit_amount, uint8 deposit_block);
           
}