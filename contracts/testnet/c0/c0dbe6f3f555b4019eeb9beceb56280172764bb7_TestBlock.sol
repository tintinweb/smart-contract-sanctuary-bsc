/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-10
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

contract Contractable   {
    address public _contract;
    event contractshipTransferred(
        address indexed previouscontract,
        address indexed newcontract
    );
   
    constructor()   {
        _contract = msg.sender;
        emit contractshipTransferred(address(0), _contract);
    }
   
    function contracto() public view returns (address) {
       return _contract;
    }
   
     modifier onlyContract() {
        require(_contract == msg.sender, "contract: caller is not the contract");
        _;
    }
   
}

contract TestBlock is Contractable {
    using SafeMath for uint256; 
    BEP20 public BUSD = BEP20(0xCB0bdCb50dce5D9B296bA6f4FbF167FeE6292Ca9); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 300; 
    uint256 private constant minDeposit = 25e18;
    uint256 private constant minDepositGrowth = 10e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 15 minutes; //7 days; 
    uint256 private constant dayRewardPercents = 100;
    uint256 private constant maxAddFreeze = 40 days;
    uint256 private constant referDepth = 21;
    uint256 private constant directDepth = 1;
    uint256 private constant uct = 90 days;
    uint256[21] private level_1_21_Percents = [500, 200, 300, 100, 100, 200, 100, 100, 200, 100, 50, 50, 50, 50, 50, 50, 100, 100, 100, 100,300];
    uint256 private SingleLegLevelPercents = 50;
	
    uint256[7] private balDown = [10e22, 30e22, 100e22, 500e22, 1000e22,1500e22,2000e22];
    uint256[7] private balDownRate = [1000, 1500, 2000, 5000, 6000,7000,8000]; 
    uint256[7] private balRecover = [15e22, 50e22, 150e22, 500e22, 1000e22,1500e22, 2000e22];
    mapping(uint256=>bool) public balStatus; // bal=>status
    uint256 allIndex=1;
    address[1] public feeReceivers;

    address public ContractAddress;
    address public defaultRefer;
    address public receivers;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public lastfreezetime;

    mapping(uint256=>address[]) public dayUsers;
	
	address[] public teamLeaderUsers; // 
    address[] public managerUsers;
    address[] public globalManagerUsers;
	address[] public globalCoordinatorUsers;
	address[] public globalHighRankCoordinatorUsers;
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

    struct ImportantInfo {
        address referrer;
        uint256 refNo;    
        uint256 maxDeposit;     
        uint256 myRegister;  
        uint256 myActDirect;            
        mapping(uint256 => uint256) levelTeam;                
        mapping(uint256 => uint256) directBuz; 
        mapping(uint256 => uint256) incomeArray;
    }
    mapping(address=>UserInfo) public userInfo;
    mapping(address=>ImportantInfo) public importantInfo;
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 level1;
        uint256 level_2_to_3;
        uint256 level_4_to_10;
        uint256 level_11_to_16;
        uint256 level_17_to_20;
        uint256 level_21;
        uint256 singleLegDepositIncome;
        uint256 singleLegWithdrwaIncome;
        uint256 netWithdrawal;       
        uint256 split;
        uint256 splitDebt;        
    }

    struct SingleLoop{
        uint256 ind;
    }
    struct SingleIndex{
        address ads;
    }
    mapping(uint => SingleIndex) public singleIndex;
    mapping(address => SingleLoop) public singleAds;
    mapping(address=>RewardInfo) public rewardInfo;
    bool public isFreezeReward;
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositByGrowth(address user, uint256 amount);
    event TransferByGrowth(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor()   
    {     
        feeReceivers[0] = address(0xba45c80B8b51527C46ab2755EE8c178927E3DA6B); 
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = msg.sender;
        receivers = msg.sender;
        singleIndex[0].ads = msg.sender;
        singleAds[msg.sender].ind = 0;
    }

    function contractInfo() public view returns(uint256 balance, uint256 init){
       return (BUSD.balanceOf(address(this)),startTime);
    }

    function register(address _referral) external 
    {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;     
        totalUser = totalUser.add(1);
        ImportantInfo storage impInfo = importantInfo[msg.sender];        
        impInfo.referrer = _referral;
        impInfo.refNo = importantInfo[_referral].myRegister;
        importantInfo[_referral].myRegister++;
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {
        BUSD.transferFrom(msg.sender, address(this), _amount);
        _distributeDeposit(_amount);
        //_deposit(msg.sender, _amount);
        //emit Deposit(msg.sender, _amount);
    }

    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user]; 
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");

        if(user.maxDeposit == 0){
        user.maxDeposit = _amount;
        //_updatedirectNum(_user);
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }  
        /*
        if(singleAds[msg.sender].ind==0){
            singleIndex[allIndex].ads=msg.sender;
            singleAds[msg.sender].ind=allIndex;
            allIndex++;
        }

        bool _isReDept = false;
        if(importantInfo[_user].maxDeposit==0){
            importantInfo[importantInfo[_user].referrer].myActDirect++;
        }else{
            _isReDept=true;
        }
        */
        //_setReferral(_user,userInfo[_user].referrer,_amount,_isReDept);
        //_setSingle(_user,_amount);
        _distributeDeposit(_amount);      
        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);
        user.isactive = true;
        //_updateLevel(msg.sender);
        
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

    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        BUSD.transfer(feeReceivers[0], fee.div(3)); 
    }

}