// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract LoopLiquidityPool is Ownable {
     
    //income balance
    mapping (address => uint256) private _last_block;
    
    //ore pool self power
    mapping (address => uint256) private _power;
    mapping (address => uint256) private _lock_power;
    mapping (address => uint256) private _unclaimed;
    
    //ore pool total power
    uint256 private _totalPower;
    
    //income total balance
    uint256 private _everyDayMintingAmount = 400*1e18;

    uint256 public total_rewards = 400000 * 1e18;
    uint256 public released;
    
    IERC20 public loopToken;
    IERC20 public lpToken;
    address public locker;

    event Stake(address indexed from, uint256 value);
    event Claim(address indexed to, uint256 value);
    event Redeem(address indexed to, uint256 value);

    function addLockPower(address owner,uint256 amount)public virtual onlyOwner returns(bool){
        _lock_power[owner] += amount;
        _totalPower += amount;
        if(_last_block[owner] == 0){
            _last_block[owner] = block.number;
        }
        return true;
    }

    function addTokenContract(address _loopContract, address _lpContract)public virtual onlyOwner returns(bool){
        require(_loopContract != address(0), "OrePool: transfer from the zero address");
        require(_lpContract != address(0), "OrePool: transfer from the zero address");
       loopToken = IERC20(_loopContract);
        lpToken = IERC20(_lpContract);
        return true;
    }

    function totalPower() public view  returns (uint256) {
        return _totalPower;
    }

    function getUnclaimedAmount(address _account)public view returns(uint256){
        uint256 _my_power = powerOf(_account);
        if(_last_block[_account]==0 || _my_power==0){
            return 0;
        }

        if(released >= total_rewards){
            return 0;
        }
       
        uint256 _diff_block = block.number - _last_block[_account];
        return _unclaimed[msg.sender] + ((((_my_power * _everyDayMintingAmount)/ _totalPower) * _diff_block)/28800);
    }
    
    function powerOf(address account) public view  returns (uint256) {
        return _power[account] + _lock_power[account];
    }
    
    function stake(uint256 amount) public  returns (bool){
        _stake(_msgSender(),amount);
        settlement(_msgSender());
        return true;
    }
    
    function _stake(address sender,uint256 amount) internal virtual{
        require(sender != address(0), "OrePool: transfer from the zero address");
        require(lpToken.transferFrom(msg.sender, address(this), amount), "No approval or insufficient balance");
        
        _power[sender] = _power[sender] + amount;
        _totalPower = _totalPower + amount;
        if(_last_block[sender] == 0){
            _last_block[sender] = block.number;
        }
        
        emit Stake(sender,amount);
    }
    
    function claim() public  returns (bool){
        address sender = msg.sender;
        require(sender != address(0), "OrePool: transfer from the zero address");
        settlement(sender);
        uint256 myUnclaimedAmount = _unclaimed[sender];
        require(myUnclaimedAmount >0 , "OrePool: balance must be greater than 0 ");

        //mint
        loopToken.transfer(sender, myUnclaimedAmount);
        // miner.mint(sender,myUnclaimedAmount);
        
        _unclaimed[sender] = 0;
        emit Claim(sender,myUnclaimedAmount);
        return true;
    }

    function redeem() public  returns (bool){
        address sender = msg.sender;
        require(sender != address(0), "OrePool: transfer from the zero address");
        settlement(sender);
        _totalPower = _totalPower - _power[sender];
        // transfer
        lpToken.transfer(sender,_power[sender]);
        emit Redeem(sender,_power[sender]);
        _power[sender] = 0;
        return true;
    }

    function settlement(address _user)internal {
        _unclaimed[_user] = getUnclaimedAmount(_user);
        _last_block[msg.sender] = block.number;
    }


}