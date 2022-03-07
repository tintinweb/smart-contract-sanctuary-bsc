/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
} 

contract Staking {

    string public name = "Staking";
    string public dev = "@FrankFourier";
    // create 2 state variables
    address public Test = 0xDE003d406Ba5a8B2B8574336df0a1C8AA2A5Bf24;

    uint internal constant _precision = 1e6;
    uint256 MAX_INT = 2**256 - 1;

    uint256 private _totalDistributed;  

    struct farm_slot {
        bool active;
        uint balance;
        uint OGdeposit_time;
        uint deposit_time;
        uint locked_time;
        uint index;
        address token;
    }

    struct farm_pool {
        mapping(address => uint) is_farming;
        mapping(address => bool) has_farmed;
        uint total_balance;
    }

    address public owner;

    address[] internal farms;

    mapping(address => mapping(uint => farm_slot)) public farming_unit;
    mapping(address => uint[]) farmer_pools;
    mapping(address => farm_pool) public token_pool;
    mapping(address => uint) farm_id;
    mapping(address => bool) public is_farmable;
    mapping(address => uint) public last_tx;
    mapping(address => bool) public is_auth;

    uint256 cooldown_time = 5 seconds;
    
    IERC20 token_reward;

    constructor() {
        owner = msg.sender;
        is_farmable[Test] = false;
        token_reward = IERC20(Test);
    }

    bool locked;

    modifier safe() {
        require (!locked, "Guard");
        locked = true;
        _;
        locked = false;
    }

    modifier cooldown() {
        require(block.timestamp > last_tx[msg.sender] + cooldown_time, "Calm down");
        _;
        last_tx[msg.sender] = block.timestamp;
    }

    modifier authorized() {
        require(owner==msg.sender || is_auth[msg.sender], "403");
        _;
    }
    
    function is_unlocked (uint id, address addy) public view returns(bool) {
        return(block.timestamp > farming_unit[addy][id].OGdeposit_time + farming_unit[addy][id].locked_time);
    }

    ///@notice Public farming functions

    ///@dev Approve
    function approveTokens() public {
        bool approved = IERC20(Test).approve(address(this), MAX_INT);
        require(approved, "Can't approve");
    }

    ///@dev Deposit farmable tokens in the contract
    function farmTokens(uint _amount, uint locking) public cooldown {
        require(is_farmable[Test], "Farming not supported");
        require(locking >= 86400 || locking == 0, "Farming time too low");
        require(locking < 31536000, "Farming time too high");
        require(IERC20(Test).allowance(msg.sender, address(this)) >= _amount, "Allowance?");

        // Transfer farmable tokens to contract for farming
        bool transferred = IERC20(Test).transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Not transferred");

        // Update the farming balance in mappings
        farm_id[msg.sender]++;
        uint id = farm_id[msg.sender];
        farming_unit[msg.sender][id].locked_time = locking;
        farming_unit[msg.sender][id].balance = farming_unit[msg.sender][id].balance + _amount;
        farming_unit[msg.sender][id].active = true;        
        farming_unit[msg.sender][id].deposit_time = block.timestamp;
        farming_unit[msg.sender][id].OGdeposit_time = block.timestamp;
        farming_unit[msg.sender][id].token = Test;
        token_pool[Test].total_balance += _amount;

        // Add user to farms array if they haven't farmd already
        if(token_pool[Test].has_farmed[msg.sender]) {
            token_pool[Test].has_farmed[msg.sender] = true;
        }

        // Update farming status to track
        token_pool[Test].is_farming[msg.sender]++;
        farmer_pools[msg.sender].push(id);
        farming_unit[msg.sender][id].index = (farmer_pools[msg.sender].length)-1;
    }

     ///@dev Unfarm tokens (if not locked)
    function unfarmTokens(uint id) public safe cooldown {
        if (!is_auth[msg.sender]) {
            require(is_unlocked(id, msg.sender), "Locking time not finished");
        }

        uint balance = _calculate_rewards(id, msg.sender);

        // require the amount farms needs to be greater then 0
        require(balance > 0, "farming balance can not be 0");
    
        // transfer Test tokens out of this contract to the msg.sender
        token_reward.transfer(msg.sender, farming_unit[msg.sender][id].balance);
        token_reward.transfer(msg.sender, balance);
        _totalDistributed = _totalDistributed + balance; 
    
        // reset farming balance map to 0
        farming_unit[msg.sender][id].balance = 0;
        farming_unit[msg.sender][id].active = false;
        farming_unit[msg.sender][id].deposit_time = block.timestamp;
        farming_unit[msg.sender][id].OGdeposit_time = block.timestamp;
        address token = farming_unit[msg.sender][id].token;

        // update the farming status
        token_pool[token].is_farming[msg.sender]--;
        token_pool[Test].total_balance -= farming_unit[msg.sender][id].balance;

        // delete farming pool id
        delete farmer_pools[msg.sender][farming_unit[msg.sender][id].index];
    }

    ///@dev Give rewards and clear the reward status    
    function issueInterestToken(uint id) public safe cooldown {
        uint balance = _calculate_rewards(id, msg.sender);            
        token_reward.transfer(msg.sender, balance);
        _totalDistributed = _totalDistributed + balance; 
        // reset the time counter so it is not double paid
        farming_unit[msg.sender][id].deposit_time = block.timestamp;    
        }

    ///@dev return the general state of a pool
    function get_TVL() public view returns (uint) {
        require(is_farmable[Test], "Not active");
        return(token_pool[Test].total_balance);
    }

    function get_reserve() public view returns (uint) {
        require(is_farmable[Test], "Not active");
        uint amount = IERC20(Test).balanceOf(address(this));
        return amount;
    }

    function totalDistributed() public view returns (uint256) {
        return _totalDistributed;
    }

    ///@dev return current APY with precision factor
    function get_APY() public view returns (uint) {
        uint TVL = get_TVL();
        uint total_rewards = token_reward.balanceOf(address(this));
        uint APY = (total_rewards * 100 * _precision / TVL);
        return APY;
    }

    ///@dev return APY increased by a factor 0 to 1 if locking time is greater than 0 with precision factor
    function get_TimedAPY(uint id, address addy) public view returns (uint) {
        uint current_APY = get_APY();
        uint locking_time = farming_unit[addy][id].locked_time;
        if (locking_time > 0) {
        uint APY_factor = ((locking_time * _precision) / 365 days);
        uint TimedAPY = current_APY * (1 * _precision + APY_factor);
        return TimedAPY;
        }
        else return current_APY;
    }

    ///@dev Helper to calculate rewards in a quick and lightweight way
    function _calculate_rewards(uint id, address addy) public view returns (uint) {
    	// get the users farming balance in Test
        uint delta_time = block.timestamp - farming_unit[addy][id].deposit_time; // - initial deposit
        /// Rationale: balance*APY/100 gives the APY reward. It is multiplied by time/year passed
        uint current_APY = get_APY();
        uint locking_time = farming_unit[addy][id].locked_time;
        if (locking_time > 0) {
        uint TimedAPY = get_TimedAPY(id, addy);
        uint balance = (((farming_unit[addy][id].balance * TimedAPY) / (100 * _precision ** 2)) * ((delta_time * _precision) / 365 days))/_precision;
        return balance;
        }
        else {
        uint balance = (((farming_unit[addy][id].balance * current_APY) / (100 * _precision)) * ((delta_time * _precision) / 365 days))/_precision;
        return balance;
        }
    }

    ///@notice Control functions

    function get_farmer_pools(address farmer) public view returns(uint[] memory) {
        return(farmer_pools[farmer]);
    }

// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once TEST is sufficiently
// distributed and the community can show to govern itself. It will only be used 
// to withdraw rewards in case a new staking contract is available and the current 
// one is dimissed. Also useful to withdraw tokens sent by mistake.
    function unstuck_tokens(address tkn) public authorized {
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
    }

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    function set_authorized(address addy, bool booly) public authorized {
        is_auth[addy] = booly;
    }

    function set_farming_state(bool status) public authorized {
        is_farmable[Test] = status;
    }

    function get_farming_state() public view returns (bool) {
        return is_farmable[Test];
    }

    function get_APY_timed(uint time) public view returns (uint) {
        uint current_APY = get_APY();
        uint APY_factor = ((time * _precision) / 365 days);
        uint TimedAPY = current_APY * (1 * _precision + APY_factor);
        return TimedAPY;
    }

    function set_token(address token) public authorized {
        Test = token;
        token_reward = IERC20(Test);
    }  

    ///@notice time helpers

    function get_1_day() public pure returns(uint) {
        return(1 days);
    }

    function get_365_day() public pure returns(uint) {
        return(365 days);
    }

    function get_x_days(uint x) public pure returns(uint) {
        return((1 days*x));
    }
    
    function get_single_pool(uint id, address addy) public view returns (farm_slot memory) {
        return(farming_unit[addy][id]);
    }

    function get_time_remaining(uint id, address addy) public view returns (uint) {
        if(farming_unit[addy][id].locked_time == 0)
        return(0); else 
        return(farming_unit[addy][id].OGdeposit_time + farming_unit[addy][id].locked_time);
    }

    function get_pool_lock_time(uint id, address addy) public view returns (uint) {
        return(farming_unit[addy][id].locked_time);
    }
    
    function get_pool_balance(uint id, address addy) public view returns (uint) {
        return(farming_unit[addy][id].balance);
    }

    function get_pool_details(uint id, address addy) public view returns (uint, uint, uint, uint, uint) {
      return(get_pool_balance(id, addy), farming_unit[addy][id].OGdeposit_time, farming_unit[addy][id].locked_time, get_time_remaining(id, addy), _calculate_rewards(id, addy));   
    }

    receive() external payable {}
    fallback() external payable {}
}