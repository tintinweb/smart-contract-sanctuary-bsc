pragma solidity =0.8.4;

// SPDX-License-Identifier: Unlicensed

// you have to set main token for deploying.
// and set ownership of the token to this contract.
// and set startPool(this is start time) of skaking.
// and set MIN_LIMIT for skaking.

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function decimals() external view returns (uint8);
    function mint(address to, uint256 amount) external returns (bool);
    function burn(address _from,uint256 _amount) external returns(bool);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract WaterFinanceContract {
    
    using SafeMath for uint256;
    IBEP20 public token;

    // Info of each user.
    struct UserInfo {
        uint256 amount;           // How many tokens the user has provided.
        uint256 firstStakedBlock; // first stake time
        uint256 lastStakedBlock;
        uint256 reward;
    }

    mapping (uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public lockTokenPeriod; // lock period for taking token 
    mapping (uint256 => uint256) public APY;  // anual percentage yield
    uint256 public startPool;    // open pool time
    address public owner;
    uint256 secondInDay = 86400;
    uint256 public rate; 
    uint256[] public typeList;

    uint256 public MIN_LIMIT = 1000000;  // min amount for skaking 

    uint256 public totalStakedToken = 0; // total amount staked
    uint256 public totalRewardToken = 0; // total amount rewarded

    uint256 public _roi_rate = 1; 

    constructor (address _token){
        owner = msg.sender;
        token = IBEP20(_token);
        startPool = 0;
        lockTokenPeriod = 86400;//1 day == 86400s
        rate = 91000;
    }

    //Set main token.
    function setExternalToken(IBEP20 _token) public onlyOwner {
        token = _token;
    }

    //set min amount of skaking.
    function setMinLimitAmount(uint256 _amount) public onlyOwner {
        MIN_LIMIT = _amount;
    }

    // staking.
    function deposit(uint256 _amount, uint256 _type) public {
        uint256 curBlock = block.timestamp;
        UserInfo storage info = userInfo[_type][msg.sender];
        require(startPool > 0, "Staking Pool is not opened yet.");
        require(_amount > MIN_LIMIT, "Amount should be large than min amount.");
        uint256 _reward = 0;

        if(info.amount > 0){
            uint256 _roi = (APY[_type] / 100) ^ (_roi_rate / 17520);
            _reward = info.amount * ((_roi ^ ((info.lastStakedBlock - curBlock) / 86400 * 48)) - 1);

            token.transferFrom(msg.sender, address(this), info.amount);
        }
        info.reward = info.reward + _reward;
        info.amount = _amount;
        info.lastStakedBlock = curBlock + (lockTokenPeriod * _type);
        info.firstStakedBlock = curBlock;
        totalStakedToken = totalStakedToken + _amount;
    }

    // unstaking all
    function unstakeAll(uint256 _type) public {
        UserInfo storage info = userInfo[_type][msg.sender];
        require(info.amount > 0, "Amount should be large than 0");
        uint256 curBlock = block.timestamp;
        require(curBlock > info.lastStakedBlock, "Tokens are still locked...");

        uint256 _roi = (APY[_type] / 100) ^ (_roi_rate / 17520);
        uint256 _reward = info.amount * ((_roi ^ ((info.lastStakedBlock - info.firstStakedBlock) / 86400 * 48)) -1);

        info.reward = info.reward + _reward;
        token.transfer(msg.sender, info.amount + info.reward);

        info.amount = 0;
        info.reward = 0;
        info.lastStakedBlock = curBlock;
        totalStakedToken = totalStakedToken - info.amount;
    }

    // calculate reward amount
    function calcCurrentAmount(address _addr, uint256 _type) public view returns(uint256) {
        UserInfo storage info = userInfo[_type][_addr];
        uint256 curBlock = block.timestamp;
        uint256 _reward = 0;
        uint256 _roi = (APY[_type] / 100) ^ (_roi_rate / 17520);

        if(info.amount > 0 && curBlock < info.lastStakedBlock){
            _reward = info.amount * ((_roi ^ ((curBlock - info.firstStakedBlock) / 86400 * 48)) - 1);
        }else if(info.amount > 0 && curBlock > info.lastStakedBlock){
            _reward = info.amount * ((_roi ^ ((info.lastStakedBlock - info.firstStakedBlock) / 86400 * 48)) - 1);
        }
        uint256 amount = info.amount + info.reward + _reward;
        return amount;
    }

    function calcCurrentTimeStamp(address _addr, uint256 _type) public view returns(uint256) {
        UserInfo storage info = userInfo[_type][_addr];
        uint256 curBlock = block.timestamp;
        uint256 _timeStamp = 0;
        if(curBlock < info.lastStakedBlock){
            _timeStamp =  info.lastStakedBlock - curBlock;
        }
        return _timeStamp;
    }

    // change lock period variable. only owner can call.
    function setLockPeriod(uint256 _lockPeriod) public onlyOwner {
        lockTokenPeriod = _lockPeriod;
    }

    function getStartPool() public view returns(uint256) {
        return startPool;
    }

    // set start time for stking
    function setStartPool(uint256 _startPool) public onlyOwner {
        startPool = _startPool;
        totalStakedToken = 0;
        totalRewardToken = 0;
    }

    function getAPY(uint256 _type) public view returns(uint256) {
        return APY[_type];
    }

    // change Annual Percentage Yield.
    function setAPY(uint256 _APY, uint256 _type) public onlyOwner {
        APY[_type] = _APY;

        for(uint i = 0; i < typeList.length; i++){
            if(typeList[i] == _type){
                return;
            }
        }
        typeList.push(_type);
    }

    function getTypeList() public view returns(uint256[] memory) {
        return typeList;
    }

    function setTokenRewardRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    // change ownership
    function transferOwnership(address _owner) public {
        require(msg.sender==owner);
        owner=_owner;
    }

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }  
}