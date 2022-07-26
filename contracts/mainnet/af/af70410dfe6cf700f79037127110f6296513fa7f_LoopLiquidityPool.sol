// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract LoopLiquidityPool is Ownable {
    using SafeMath for uint256;
     
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

    constructor(address _loopContract, address _lpContract){
        loopToken = IERC20(_loopContract);
        lpToken = IERC20(_lpContract);
    }

    function addLockPower(address owner,uint256 amount)public virtual onlyOwner returns(bool){
        _lock_power[owner] += amount;
        _totalPower += amount;
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
       
        uint256 _diff_block = block.number.sub(_last_block[_account]);
        return _unclaimed[msg.sender].add(_my_power.div(_totalPower).mul(_everyDayMintingAmount).div(28800).mul(_diff_block));
    }
    
    function powerOf(address account) public view  returns (uint256) {
        return _power[account].add(_lock_power[account]);
    }
    
    function stake(uint256 amount) public  returns (bool){
        _stake(_msgSender(),amount);
        settlement(_msgSender());
        return true;
    }
    
    function _stake(address sender,uint256 amount) internal virtual{
        require(sender != address(0), "OrePool: transfer from the zero address");
        require(lpToken.transferFrom(msg.sender, address(this), amount), "No approval or insufficient balance");
        
        _power[sender] = _power[sender].add(amount);
        _totalPower = _totalPower.add(amount);
        if(_last_block[sender] == 0){
            _last_block[sender] = block.number;
        }
        
        emit Stake(sender,amount);
    }
    
    function claim() public  returns (bool){
        address sender = msg.sender;
        require(sender != address(0), "OrePool: transfer from the zero address");
        uint256 myUnclaimedAmount = getUnclaimedAmount(sender);
        require(myUnclaimedAmount >0 , "OrePool: balance must be greater than 0 ");

        //mint
        loopToken.transfer(sender, myUnclaimedAmount);
        // miner.mint(sender,myUnclaimedAmount);
        
        _last_block[msg.sender] = block.number;
        _unclaimed[sender] = 0;

        emit Claim(sender,myUnclaimedAmount);
        return true;
    }

    function redeem() public  returns (bool){
         address sender = msg.sender;
        require(sender != address(0), "OrePool: transfer from the zero address");
        _totalPower = _totalPower.sub(_power[sender], "OrePool: transfer amount exceeds balance");
        // transfer
        lpToken.transfer(sender,_power[sender]);
        emit Redeem(sender,_power[sender]);
        _power[sender] = 0;
        settlement(sender);
        return true;
    }

    function settlement(address _user)internal {
        _unclaimed[_user] = getUnclaimedAmount(_user);
        _last_block[msg.sender] = block.number;
    }


}