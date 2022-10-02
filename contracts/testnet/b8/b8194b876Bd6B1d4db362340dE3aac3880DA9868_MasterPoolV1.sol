/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function circularSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function faucet(address account,uint256 amount,uint256 price) external;
  function burnt(address account,uint256 amount,uint256 price) external;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
    modifier onlyOwner() { require(isOwner(msg.sender), "!OWNER"); _; }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

contract MasterPoolV1 is Ownable {
  using SafeMath for uint256;

  struct MasterPool {
    address token;
    uint256 apr;
    uint256 endblock;
    uint256 lockblock;
    bool active;
    uint256 minimum;
    uint256 maximum;
    uint256 totalstaked;
    uint256 remainreward;
    mapping(address => User) users;
  }

  struct User {
    uint256 balance;
    uint256 harvest;
    uint256 locked;
  }

  uint256 public totalpool;
  uint256 public ayear = 60*60*24*365;

  mapping(address => bool) public permission;
  mapping(uint256 => MasterPool) public masterpool;
  
  bool reentrantcy;
  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  modifier onlyPermission() { require(permission[msg.sender], "!PERMISSION"); _; }

  constructor() Ownable(msg.sender) {
    permission[msg.sender] = true;
  }

  function isPermission(address _account) public view returns (bool) {
    return permission[_account];
  }

  function viewUsers(uint256 _id,address _account) public view returns (
      uint256 balance_,
      uint256 harvest_
    ) {
    return (
        masterpool[_id].users[_account].balance,
        masterpool[_id].users[_account].harvest
    );
  }

  function pausePool(uint256 _id) public onlyPermission returns (bool) {
    masterpool[_id].active = false;
    return true;
  }

  function resumePool(uint256 _id) public onlyPermission returns (bool) {
    masterpool[_id].active = true;
    return true;
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function createNewPool(address _token,uint256 _apr,uint256 _endtimer,uint256 _lockblock,uint256 _minimum,uint256 _maximum) public onlyPermission returns (bool) {
    uint256 endblock = block.timestamp.add(_endtimer);
    totalpool = totalpool.add(1);
    masterpool[totalpool].token = _token;
    masterpool[totalpool].apr = _apr;
    masterpool[totalpool].endblock = endblock;
    masterpool[totalpool].lockblock = _lockblock;
    masterpool[totalpool].active = false;
    masterpool[totalpool].minimum = _minimum;
    masterpool[totalpool].maximum = _maximum;
    return true;
  }

  function settingPool(uint256 _id,address _token,uint256 _apr,uint256 _endtimer,uint256 _lockblock,uint256 _minimum,uint256 _maximum) public onlyPermission returns (bool) {
    uint256 endblock = block.timestamp.add(_endtimer);
    masterpool[_id].token = _token;
    masterpool[_id].apr = _apr;
    masterpool[_id].endblock = endblock;
    masterpool[_id].lockblock = _lockblock;
    masterpool[_id].minimum = _minimum;
    masterpool[_id].maximum = _maximum;
    return true;
  }

  function filled(uint256 _id,uint256 _amount) public returns (bool) {
    IERC20 token = IERC20(masterpool[_id].token);
    token.transferFrom(msg.sender,address(this),_amount);
    masterpool[_id].remainreward = masterpool[_id].remainreward.add(_amount);
    return true;
  }

  function deposit(uint256 _id,uint256 _amount) public returns (bool) {
    require(availableCouta(_id)<=_amount.add(masterpool[_id].totalstaked),"not enought couta");
    require(_amount>=masterpool[_id].minimum,"revert amount by minimum vaule");
    require(_amount<=masterpool[_id].maximum,"revert amount by minimum vaule");
    IERC20 token = IERC20(masterpool[_id].token);
    token.transferFrom(msg.sender,address(this),_amount);
    harvest(_id,msg.sender);
    uint256 beforebalance = masterpool[_id].users[msg.sender].balance;
    uint256 increaseblock = masterpool[_id].lockblock.mul(_amount).div(beforebalance.add(_amount));
    masterpool[_id].totalstaked = masterpool[_id].totalstaked.add(_amount);
    masterpool[_id].users[msg.sender].balance = masterpool[_id].users[msg.sender].balance.add(_amount);
    if(masterpool[_id].users[msg.sender].locked==0){
        masterpool[_id].users[msg.sender].locked = masterpool[_id].users[msg.sender].locked.add(increaseblock).add(block.timestamp);
    }else{
        masterpool[_id].users[msg.sender].locked = masterpool[_id].users[msg.sender].locked.add(increaseblock);
    }
    return true;
  }

  function withdraw(uint256 _id,uint256 _amount) public returns (bool) {
    require(masterpool[_id].users[msg.sender].locked<=block.timestamp,"token is in locked period");
    require(masterpool[_id].users[msg.sender].balance>=_amount,"not enought balance for withdraw");
    harvest(_id,msg.sender);
    IERC20 token = IERC20(masterpool[_id].token);
    token.transfer(msg.sender,_amount);
    masterpool[_id].totalstaked = masterpool[_id].totalstaked.sub(_amount);
    masterpool[_id].users[msg.sender].balance = masterpool[_id].users[msg.sender].balance.sub(_amount);
    return true;
  }

  function availableCouta(uint256 _id) public view returns (uint256) {
    require(masterpool[_id].endblock>block.timestamp,"pool was ended");
    uint256 endperiod = masterpool[_id].endblock.sub(block.timestamp);
    uint256 remainreward = masterpool[_id].remainreward;
    return remainreward.mul(endperiod.mul(100).div(ayear)).div(masterpool[_id].apr);
  }

  function tryincreaseblock(uint256 _id,uint256 _amount) public view returns (uint256) {
    uint256 beforebalance = masterpool[_id].users[msg.sender].balance;
    uint256 increaseblock = masterpool[_id].lockblock.mul(_amount).div(beforebalance.add(_amount));
    if(masterpool[_id].users[msg.sender].locked==0){
        return masterpool[_id].users[msg.sender].locked.add(increaseblock).add(block.timestamp);
    }else{
        return masterpool[_id].users[msg.sender].locked.add(increaseblock);
    }
  }

  function harvesting(uint256 _id) public returns (bool) {
    harvest(_id,msg.sender);
    return true;
  }

  function tryharvest(uint256 _id,address _account) public view returns (uint256) {
    uint256 lastclaimblock = masterpool[_id].users[_account].harvest;
    if(lastclaimblock>0){
        return (masterpool[_id].users[_account].balance).mul(masterpool[_id].apr).mul(block.timestamp.sub(lastclaimblock)).div(ayear);
    }else{
        return 0;
    }
  }

  function harvest(uint256 _id,address _account) internal {
    uint256 lastclaimblock = masterpool[_id].users[_account].harvest;
    if(lastclaimblock>0){
        uint256 reward = (masterpool[_id].users[_account].balance).mul(masterpool[_id].apr).mul(block.timestamp.sub(lastclaimblock)).div(ayear);
        IERC20 token = IERC20(masterpool[_id].token);
        token.transfer(_account,reward);
        masterpool[_id].users[_account].harvest = block.timestamp;
        masterpool[_id].remainreward = masterpool[_id].remainreward.sub(reward);
    }
  }

}