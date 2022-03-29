/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

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

abstract contract Ownable {
    address internal owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract KyklosVesting is Ownable, ReentrancyGuard {

    string  public name = "KYKVesting";
    address public Kyklos = 0xA4576d9cA80D891f9D28aC177360d6cADb35866f;

    uint internal constant _precision = 1e6;
    uint256 MAX_INT = 2**256 - 1;



    struct vest_slot {
        bool active;
        uint balance;
        uint initialBalance;
        uint deposit_time;
        uint period;
        uint n_periods;
        uint index;
        uint current_period;
        address account;
    }

    address[] internal vaults;

    mapping(uint => vest_slot) public vestedWallets;
    mapping(address => bool) public is_vested;
    mapping(address => bool) public is_auth;

    uint starting_time;
    uint[] Vesting_pools;
    uint vest_id;
    
    constructor () Ownable(msg.sender) {        
        is_vested[Kyklos] = false;
    }

    bool locked;

    modifier safe() {
        require (!locked, "Guard");
        locked = true;
        _;
        locked = false;
    }

    modifier authorized() {
        require(owner==msg.sender || is_auth[msg.sender], "403");
        _;
    }
    
    function is_unlocked (uint id) public view returns(bool) {
        require(starting_time != 0, "Vesting not yet started");
        if (vestedWallets[id].deposit_time == 0)
        return(block.timestamp > starting_time + vestedWallets[id].period);
        else return(block.timestamp > vestedWallets[id].deposit_time + vestedWallets[id].period);
    }

    ///@notice Public vesting functions

    ///@dev Approve
    function approveTokens() public {
        bool approved = IERC20(Kyklos).approve(address(this), MAX_INT);
        require(approved, "Can't approve");
    }

    ///@dev Deposit vested tokens in the contract
    function vestTokens(uint _amount, uint _period, uint _n_periods, address vestedWallet) public onlyOwner nonReentrant {
        require(is_vested[Kyklos], "Vesting not supported");
        require(IERC20(Kyklos).allowance(msg.sender, address(this)) >= _amount, "Allowance?");

        // Transfer vested tokens to contract for vesting
        bool transferred = IERC20(Kyklos).transferFrom(msg.sender, address(this), _amount);
        require(transferred, "Not transferred");

        // Update the vested balance in mappings
        vest_id++;
        uint id = vest_id;
        vestedWallets[id].period = _period;
        vestedWallets[id].n_periods = _n_periods;
        vestedWallets[id].current_period = 1;
        vestedWallets[id].initialBalance = _amount;
        vestedWallets[id].balance = _amount;
        vestedWallets[id].active = true;        
        vestedWallets[id].account = vestedWallet;

        // Update vesting status to track
        Vesting_pools.push(id);
        vestedWallets[id].index = (Vesting_pools.length)-1;
    }

    ///@dev Unvest tokens (if not locked).
    function unvestTokens(uint id) public safe nonReentrant {
        require(vestedWallets[id].active == true);
        require(vestedWallets[id].account == msg.sender);
        require(is_unlocked(id), "Locking time not finished");
        uint amount = vestedWallets[id].initialBalance / vestedWallets[id].n_periods;
  
        // transfer Kyklos tokens out of this contract to the msg.sender
        IERC20(Kyklos).transfer(msg.sender, amount);

        // reset vesting balance map
        vestedWallets[id].balance = vestedWallets[id].balance - amount;
        vestedWallets[id].deposit_time = block.timestamp;  
        vestedWallets[id].current_period++;     
        
        if (vestedWallets[id].balance == 0) {
        vestedWallets[id].active = false;
        vestedWallets[id].current_period = vestedWallets[id].n_periods;
        delete Vesting_pools[vestedWallets[id].index];
        }
    }

    ///@dev return APY increased by a factor 0 to 1 if locking time is greater than 0 with precision factor
    function get_CurrentPeriod(uint id) public view returns (uint) {
        return vestedWallets[id].current_period;
    }

    ///@dev Helper to calculate rewards in a quick and lightweight way
    function get_NextVestTime(uint id) public view returns (uint) {
        require(starting_time != 0, "Vesting not yet started");
        if (vestedWallets[id].deposit_time == 0)
        return starting_time + vestedWallets[id].period;
        else return vestedWallets[id].deposit_time + vestedWallets[id].period;
    }

    ///@notice Control functions
    function get_Vesting_pools() public view returns(uint[] memory) {
        return(Vesting_pools);
    }

    // Note that it's ownable and the owner wields tremendous power. The ownership
    // will be transferred to a governance smart contract once KYK is sufficiently
    // distributed and the community can show to govern itself. It will only be used 
    // to withdraw tokens in case a new KYK contract will be deployed and the current 
    // one is dimissed. Also useful to withdraw tokens sent by mistake.
    function unstuck_tokens(address tkn) public onlyOwner {
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

    function set_vesting_state(bool status) public authorized {
        is_vested[Kyklos] = status;
    }

    function startVesting() public authorized {
        require (starting_time == 0, "Already started");
        starting_time = block.timestamp;
    }

    function get_vesting_state() public view returns (bool) {
        return is_vested[Kyklos];
    }

    function set_token(address token) public authorized {
        Kyklos = token;
    }  

    ///@notice time helper
    function get_x_days(uint x) public pure returns(uint) {
        return((1 days*x));
    }

    function get_time_remaining(uint id) public view returns (uint) {
        if(vestedWallets[id].active == false)
        return(0);
        if(vestedWallets[id].deposit_time == 0)
        return(starting_time + vestedWallets[id].period);
        else {
        uint _NextVestTime = get_NextVestTime(id);
        return(_NextVestTime - block.timestamp);
        }
    }
    
    function get_vest_balance(uint id) public view returns (uint) {
        return(vestedWallets[id].balance);
    }

    function get_vest_initialBalance(uint id) public view returns (uint) {
        return(vestedWallets[id].initialBalance);
    }

    function get_NextAmountReleased(uint id) public view returns (uint) {
        require(vestedWallets[id].active == true);
        return(vestedWallets[id].initialBalance / vestedWallets[id].n_periods);
    }

    function get_pool_details(uint id) public view returns (uint, uint, uint, uint) {
      return(get_vest_balance(id), get_time_remaining(id), get_NextVestTime(id), get_NextAmountReleased(id));   
    }

    receive() external payable {}
    fallback() external payable {}
}