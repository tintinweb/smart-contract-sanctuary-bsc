/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint (uint256 amount) external returns (bool);
    function maximumMint (uint256 time) external view returns (uint256);
    function currentSupply () external view returns (uint256);
    function transferOwner (address newOwner) external returns (bool);
    function getOwner () external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

struct LockInfo {
    address addr;
    string reason;
}


contract Gemlink is IERC20 {
    string public constant name = "Gemlink";
    string public constant symbol = "GLINK";
    uint8 public constant decimals = 8;


    mapping(address => uint256) _balances;
    mapping(address => mapping (address => uint256)) allowed;
    LockInfo[] _locked;

    uint256 _totalSupply = 16000000000000000 wei; // 160 mil fixed
    uint256 _currentSupply = 0;
    address admin;

    uint256 _startingAmount = 6000000000000000 wei; // 60 mil while actual circulating supply is 63671410
    uint256 _startingTime = 1668736751; // Fri Nov 18 2022 01:59:11 GMT +0, at block 2557319
    uint256 _nextHalving = _startingTime + 102736860; // 1712281 blocks, each block 60 secs
    uint256 _nextNextHalving = _nextHalving + 126144000; // 365 * 4 days, 2102400 blocks, each block 60 secs
    uint256 _epochTime = 86400; // 1 day
    uint256 _baseReward = 3000000000 * 1440; // 1440 blocks per day in mainnet, reward 30
    uint256 _halfBaseReward = 1500000000 * 1440; // 1440 blocks per day in mainnet, reward 30
    uint256 _firstMintAmount = 1000000000000000 wei;

    modifier onlyAdmin {
        require(msg.sender == admin, "Invalid address");
        _;
    }

   constructor() {
        admin = msg.sender;
        _mint(msg.sender, _firstMintAmount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    // mint some amount to specific address
    function _mint(address account, uint256 amount) internal onlyAdmin virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _currentSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    
    function currentSupply () public view returns (uint256)  {
        return _currentSupply;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return _balances[tokenOwner];
    }

    // each epoch is 86400 seconds
    // if time is larger than the 2nd halving, return total supply
    // if the time is smaller than the first halving, reward will be _baseReward per epoch
    // if the time is smaller than the second halving and bigger than the first halving, reward will be _halfBaseReward per epoch
    function maximumMint (uint256 time) public view returns (uint256)  {
        require(time > _startingTime, "Invalid time");

        if(time >= _nextNextHalving) {
            return _totalSupply;
        }
        
        if(time < _nextHalving) {
            uint256 currEpoch = (time - _startingTime) / _epochTime;
            return _startingAmount + currEpoch * _baseReward;
        }

        uint256 max = _startingAmount;
        uint256 epoch1 = (_nextHalving - _startingTime) / _epochTime;
        max += epoch1 * _baseReward;

        uint256 epoch2 = (time - _nextHalving) / _epochTime;
        max += epoch2 * _halfBaseReward;

        return max;
    }

    // lock address with reason
    // if it's existed already, update reason
    function lock (address locked,  string memory reason) public onlyAdmin returns (uint256){
        int256 idx = _findLockIdx(locked);
        if(idx > -1)
        {
            _locked[uint256(idx)].reason = reason;
            return _locked.length;
        }

        LockInfo memory lockInfo;
        lockInfo.addr = locked;
        lockInfo.reason = reason;
        _locked.push(lockInfo);
        return _locked.length;
    }

    function getLockCount () public view returns (uint256){
        return _locked.length;
    }

    function getLockInfo (address addr) public view returns (string memory){
        int256 idx = _findLockIdx(addr);
        require(idx > -1, "Cannot find address");
        return _locked[uint256(idx)].reason;
    }

    function _findLockIdx(address locked) internal view returns(int256){
        int256 idx = -1;
        for(uint256 i = 0; i < _locked.length; i++){
            if(_locked[i].addr == locked){
                idx = int256(i);
            }
        }
        return idx;
    }

    function unlock (address locked) public onlyAdmin returns (uint256){
        int256 idx = _findLockIdx(locked);
        require(idx > -1, "Cannot find address");
        delete _locked[uint256(idx)];
        return _locked.length;
    }
    // end lock

    // mint some amount to the owner
    function mint (uint256 amount) public onlyAdmin returns (bool){
        require(amount +  _currentSupply <= _totalSupply, "Reach total supply");
        uint256 currTime = block.timestamp; // in seconds
        require(amount <= maximumMint(currTime), "Invalid mint amount");

        _mint(msg.sender, amount);
        return true;
    }

    // transfer admin to new owner
    function transferOwner (address newOwner) public onlyAdmin returns (bool){
        admin = newOwner;
        return true;
    }

    // get current owner of the contract
    function getOwner () public view returns (address) {
        return admin;
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= _balances[msg.sender], "Not enough balance");

        // check lock here
        int256 idx = _findLockIdx(msg.sender);
        require(idx == -1, "Address was locked, please contact dev team");
        
        _balances[msg.sender] = _balances[msg.sender]-numTokens;
        _balances[receiver] = _balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= _balances[owner], "Not enough balance");
        require(numTokens <= allowed[owner][msg.sender], "Not enough allowed balance");

        int256 idx = _findLockIdx(msg.sender);
        require(idx == -1, "Address was locked, please contact dev team");

        _balances[owner] = _balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        _balances[buyer] = _balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}