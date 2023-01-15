/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

/**
 *Submitted for verification at bscscan.com on 2023-01-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


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

interface BEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context { 

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract HandDotsSmartContract is Ownable {
    using SafeMath for uint256; 
    BEP20 public BUSD = BEP20(0x580b02C3e1FE7c2F22D2725D639d70c5cEfd9fF1); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 150;
    uint256 private constant minDeposit = 1e18;
    uint256 private constant minDepositGrowth = 10e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 30 minutes; //7 days; 
    uint256 private constant dayRewardPercents = 100;
    uint256 private constant maxAddFreeze = 40 days;
    uint256 private constant referDepth = 21;
    uint256 private constant directDepth = 1;
    uint256 private constant uct = 90 days;

    address[1] public feeReceivers;
    address public defaultRefer;
    uint256 public startTime;
    uint256 public totalUser; 
    uint256 public lastfreezetime;
    uint256 public _buyPrice;
   
    mapping(uint256=>address[]) public dayUsers;

     struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    address[] public depositors;

    struct UserInfo {
        address referrer;
        uint256 start;
        uint256 level; // 0, 1, 2, 3, 4, 5
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 teamNum;
        uint256 directnum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
        bool isactive;
    }

    mapping(address=>UserInfo) public userInfo;
   
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 directs;
    }
    mapping(address=>RewardInfo) public rewardInfo;
    bool public isFreezeReward;
    event Deposit(address user, uint256 amount);
    event DepositNew(address user, uint256 amount);
    event DepositWithToken(address user, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor()  
    {               
        feeReceivers[0] = address(0x7400F2899134CAF2f044e0e152704f35eCCe25C8);
        startTime = block.timestamp;
        defaultRefer = address(0x7400F2899134CAF2f044e0e152704f35eCCe25C8);
        _buyPrice = 1 ;        
    }    
	
    function deposit(uint256 _amount) external 
    {        
        BUSD.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function _deposit(address _user, uint256 _amount) private 
    {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        ///require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        //require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");

        if(user.maxDeposit == 0){
        user.referrer = defaultRefer;
		user.start = block.timestamp;     
		totalUser = totalUser.add(1);
		user.maxDeposit = _amount;
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }  

        _distributeDeposit(_amount);      
        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);
        user.isactive = true;
        
        uint256 addFreeze = (orderInfos[_user].length.div(1)).mul(timeStep);
        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false
        ));
        
    }

    function _distributeDeposit(uint256 _amount) private 
    {
        //uint256 fee = _amount.mul(feePercents).div(baseDivider);
        BUSD.transfer(feeReceivers[0], _amount);
    }             

    function setPrice(uint256 _newPrice) external onlyOwner{
        _buyPrice = _newPrice ;
    }
    
    function _getPrice(uint256 _amount) public view returns(uint256)
    {
        uint256 tokenAmount = _amount.div(_buyPrice);
        return tokenAmount;
    }
    
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getCurDaytime() public view returns(uint256) {
        return (block.timestamp);
    }

    function getDayLength(uint256 _day) external view returns(uint256) {
        return dayUsers[_day].length;
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    } 
	
    function rescueAnyBEP20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        BEP20(_tokenAddr).transfer(_to, _amount);
    }
	
    function multiTransfer(address payable[]  memory  _address, uint256[] memory _amount) external payable onlyOwner{
        uint256 total = BUSD.balanceOf(address(this));
        uint256 i = 0;
        for (i; i < _address.length; i++) 
        {
            require(total >= _amount[i] );
            total = total.sub(_amount[i]);
            _address[i].transfer(_amount[i]);
            BUSD.transfer(_address[i], _amount[i]);
        }		
    }

    function singleTransfer(address payable  _address, uint256 _amount) external payable onlyOwner{
        uint256 total = BUSD.balanceOf(address(this));
        require(total >= _amount );
        BUSD.transfer(_address, _amount);		
    }
}