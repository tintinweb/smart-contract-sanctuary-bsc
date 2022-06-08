/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

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

    string public name = "MetalShiba Staking";
    string public dev = "@FrankFourier";
    // create 2 state variables
    address public MetalShiba = 0x4c93889992dFC5b361DB738174941feaff074DA0;

    uint256 private constant _precision = 1e18;
    uint256 private MAX_INT = 2**256 - 1;

    uint256 public updatesGas = 500000;
    uint256 public lastsync;
    uint256 public max_sync_interval = 10 minutes;

    mapping (address => bool)    public is_farmer;
    mapping (address => uint256) public balance;
    mapping (address => uint256) public locking_time;
    mapping (address => uint256) public locked_amount;
    mapping (address => uint256) public unlocked_amount;
    mapping (address => uint256) public deposit_time;
    mapping (address => uint256) private OGdeposit_time;
    mapping (address => uint256) public pendingRewards;

    uint256 private _totalDistributed;  
    uint256 public total_staked;
    uint256 private total_Rewards;
    uint256 public locked_time = 60 days;
    uint256 private currentIndex;

    address public owner;
    address[] public farmers;

    mapping(address => bool) public is_farmable;
    mapping(address => uint) private last_tx;
    mapping(address => bool) public is_auth;

    uint256 cooldown_time = 5 seconds;
    
    IERC20 token_reward;

    constructor() {
        owner = msg.sender;
        is_farmable[MetalShiba] = false;
        token_reward = IERC20(MetalShiba);
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
        require(owner==msg.sender || is_auth[msg.sender], "Not authorized!");
        _;
    }

    ///@notice Public farming functions

    ///@dev Approve
    function approveTokens() public {
        bool approved = IERC20(MetalShiba).approve(address(this), MAX_INT);
        require(approved, "Can't approve");
    }

    ///@dev Deposit and lock farmable tokens in the contract
    function farmTokens_andlock(uint _amount, address stakeholder, uint start_time) public authorized {
        require(is_farmable[MetalShiba], "Farming not supported");
        require(IERC20(MetalShiba).allowance(msg.sender, address(this)) >= _amount, "Allowance?");
        require(locked_amount[stakeholder] == 0, "Can't update locking data");

        // Transfer farmable tokens to contract for farming
        bool transferred = IERC20(MetalShiba).transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Not transferred");

        if(OGdeposit_time[stakeholder] == 0) {
            farmers.push(stakeholder);
            is_farmer[stakeholder] = true;
            OGdeposit_time[stakeholder] = start_time;
        } 
    
        // Update the farming balance in mappings
        locking_time[stakeholder] = start_time;
        locked_amount[stakeholder] = _amount;
        deposit_time[stakeholder] = start_time;
        balance[stakeholder] += _amount;       
        total_staked += _amount;
    }

    ///@dev Deposit farmable tokens in the contract
    function farmTokens(uint _amount) public cooldown {
        require(is_farmable[MetalShiba], "Farming not supported");
        require(IERC20(MetalShiba).allowance(msg.sender, address(this)) >= _amount, "Allowance?");
        sync_earnings(updatesGas);

        // Transfer farmable tokens to contract for farming
        bool transferred = IERC20(MetalShiba).transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Not transferred");

        if(OGdeposit_time[msg.sender] == 0) {
            farmers.push(msg.sender);
            is_farmer[msg.sender] = true;
            OGdeposit_time[msg.sender] = block.timestamp;
        } 
    
        // Update the farming balance in mappings
        deposit_time[msg.sender] = block.timestamp;
        balance[msg.sender] += _amount;       
        total_staked += _amount;
    }

    // sync earnings and update APY, deposit time != 0 then sync. Dont go out of gas.
    function sync_earnings(uint256 gas) public {
        uint256 shareholderCount = farmers.length;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        for(uint i = 0; i < shareholderCount; i++) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(is_farmer[farmers[currentIndex]]){
                pendingRewards[farmers[currentIndex]] += _calculate_rewards(farmers[currentIndex]);
                total_Rewards -= _calculate_rewards(farmers[currentIndex]);
                deposit_time[farmers[currentIndex]] = block.timestamp;
            }
            
            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            if(gasUsed >= gas)
            break;
        }
        lastsync = block.timestamp;
    }

    ///@dev Unfarm tokens (if not locked)
    function unfarmTokens(uint _amount) public safe cooldown {
        require(is_farmer[msg.sender], "Not open yet!");
        require(block.timestamp - lastsync < max_sync_interval,"Please sync earnings first");

        if(locked_amount[msg.sender] - unlocked_amount[msg.sender] > 0) {
            if(locking_time[msg.sender] + locked_time <= block.timestamp)
            unlocked_amount[msg.sender] = locked_amount[msg.sender];
            else if(locking_time[msg.sender] + (locked_time / 4 * 3) <= block.timestamp)
            unlocked_amount[msg.sender] = locked_amount[msg.sender] / 4 * 3;
            else if(locking_time[msg.sender] + (locked_time / 2) <= block.timestamp)
            unlocked_amount[msg.sender] = locked_amount[msg.sender] / 2;
            else if(locking_time[msg.sender] + locked_time / 4 <= block.timestamp)
            unlocked_amount[msg.sender] = locked_amount[msg.sender] / 4;
        }

        require(_amount + locked_amount[msg.sender] - unlocked_amount[msg.sender] <= balance[msg.sender], "Locked tokens try again later.");  

        if(locked_amount[msg.sender] > 0 && unlocked_amount[msg.sender] == locked_amount[msg.sender])
        locked_amount[msg.sender] = 0;

        // transfer tokens out of this contract to the msg.sender
        bool transferred =  token_reward.transfer(msg.sender, _amount);
        require(transferred, "Not transferred");

        if (balance[msg.sender] - _amount == 0) {
            //issue interests
            bool transferred_interests = token_reward.transfer(msg.sender, _calculate_rewards(msg.sender) + pendingRewards[msg.sender]);
            require(transferred_interests, "Not transferred");
            _totalDistributed += (_calculate_rewards(msg.sender) + pendingRewards[msg.sender]);
            total_Rewards -= _calculate_rewards(msg.sender);

            // reset farming balance map to 0
            balance[msg.sender] = 0;
            is_farmer[msg.sender] = false;
            deposit_time[msg.sender] = 0;
            OGdeposit_time[msg.sender] = 0;
            pendingRewards[msg.sender] = 0;
        } else {
            // update the farming balance in mappings
            balance[msg.sender] -= _amount;       
        } 
        total_staked -= _amount;
    }     

    ///@dev Give rewards and clear the reward status    
    function issueInterestToken() public {
        require(block.timestamp - lastsync < max_sync_interval, "Please sync earnings first");
        require(is_farmer[msg.sender], "Not farming.");
        uint256 _balance = _calculate_rewards(msg.sender);            
        if(total_Rewards <= _balance)
            _balance = total_Rewards;
        uint256 _pending = pendingRewards[msg.sender];
        // transfer tokens out of this contract to the msg.sender
        bool transferred = token_reward.transfer(msg.sender, _balance + _pending);
        require(transferred, "Not transferred");
        _totalDistributed += (_balance + _pending);
        total_Rewards -= _balance;
        pendingRewards[msg.sender] = 0;
        // reset the time counter so it is not double paid
        deposit_time[msg.sender] = block.timestamp;
    }

    function deposit_rewards(uint256 _amount) external authorized {
        // Transfer farmable tokens to contract for rewards
        bool transferred = IERC20(MetalShiba).transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Not transferred");
        total_Rewards += _amount;
    }    

    function setGasSettings(uint256 gas) external authorized {
        require(gas < 750000);
        updatesGas = gas;
    }

    ///@dev return the general state of a pool
    function get_TVL() public view returns (uint) {
        require(is_farmable[MetalShiba], "Not active");
        return(total_staked);
    }

    function get_rewards() public view returns (uint256) {
        require(is_farmable[MetalShiba], "Not active");
        return(total_Rewards);
    }

    function totalDistributed() public view returns (uint256) {
        return _totalDistributed;
    }

    ///@dev return current APY with precision factor
    function get_APY() public view returns (uint256) {
        require(is_farmable[MetalShiba], "Not active");
        uint TVL = get_TVL();
        uint total_rewards = get_rewards();
        uint APY = (total_rewards * 100 * _precision / TVL);
        return APY;
    }

    ///@dev Helper to calculate rewards in a quick and lightweight way
    function _calculate_rewards(address addy) public view returns (uint256) {
        // get the users farming balance
        uint256 delta_time = 0;
        if (deposit_time[addy] != 0 && balance[addy] > 0)
            delta_time = block.timestamp - deposit_time[addy]; // - initial deposit
        /// Rationale: balance*APY/100 gives the APY reward. It is multiplied by time/year passed
        uint256 current_APY = get_APY();
        return balance[addy] * (current_APY) * (delta_time) / 100 / _precision / 365 days;
    }

// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once MetalShiba is sufficiently
// distributed and the community can show to govern itself. It will only be used 
// to withdraw rewards in case a new staking contract is available and the current 
// one is dimissed. Also useful to withdraw tokens sent by mistake.
    function unstuck_tokens(address tkn) public authorized {
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
    }

    function set_authorized(address addy, bool booly) public authorized {
        is_auth[addy] = booly;
    }

    function set_farming_state(bool status) public authorized {
        is_farmable[MetalShiba] = status;
    }

    function update_cooldown(bool status) public authorized {
        if (status == true)
        cooldown_time = 5 seconds;
        else cooldown_time = 0;
    }

    function update_max_sync_interval(uint256 _max_sync_interval) public authorized {
       require(max_sync_interval <= 10 minutes, "Already updated!");
        max_sync_interval = _max_sync_interval;
    }

    function get_is_synced() public view returns (bool) {
        return block.timestamp - lastsync < max_sync_interval;
    }

    function get_farming_state() public view returns (bool) {
        return is_farmable[MetalShiba];
    }

    function set_token(address token) public authorized {
        MetalShiba = token;
        token_reward = IERC20(MetalShiba);
    }  

    function get_time_remaining(address addy) public view returns (uint) {
        if(locking_time[addy] + locked_time <= block.timestamp)
        return 0;
        else return locked_time - (block.timestamp - locking_time[addy]);
    }

    function get_pool_lock_time() public view returns (uint) {
        return(locked_time);
    }
    
    function get_pool_balance(address addy) public view returns (uint) {
        return(balance[addy]);
    }

    function get_pool_details(address addy) external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
    return(balance[addy], _calculate_rewards(addy), pendingRewards[addy], get_time_remaining(addy), locked_amount[addy], unlocked_amount[addy]);   
    }
}