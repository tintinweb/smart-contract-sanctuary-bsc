pragma solidity ^0.8.0;
//SPDX-License-Identifier: Unlicense
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

interface IBEP20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

interface IRewardPool{
  function topup(uint256 _amount) external payable;
  function claim() external payable;
 function recorduserreward(address _user, uint256 _amount) external;
}

interface IRewardManager{
  function getRewardID(uint256 rewardKey) external view returns(bytes32);
}



interface IOracle{
  function price(address lp, address usdt)external view returns (uint256);
}

interface IReferralManager{
  function getReferrer(address user) external view returns(address upline);
  function getDepositAmount(address user) external view returns(uint256 deposit);
  function getRewardAmount(address user) external view returns(uint256 claim);
  function getReferralCount(address user) external view returns(uint256 count);
  function getUserTypeCount(bytes32 userType)external view returns(uint256 count);
  function claimReferral() external payable;
  function setReferrer(address user, address upline, bytes32 userType,uint256 depositamount,address token) external payable;
}

interface IbankContribution{
  function depositBank(address token,address payable referrer,uint256 _amount,uint _pid)external payable;
  function  DepositDao(uint256 _pid, address payable referrer, uint256 _amount , address token)external payable;
  function migrateDao(address token,address payable referrer,uint _pid) external payable;
  function migrateBonus(address token,address payable referrer,uint256 _pid) external payable;
 
}
interface daoZap{
  function swapBUSDToLP(address token1,address token2) external returns(uint256);
  function swapLPToToken(address token1,address token2,address _out) external;
}
interface IReferralPool {
    /**
     * @dev Record referral.
     */
    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer,address _token, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
}

interface IVaultReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;
    function referralReset(address user, address referrer) external;
    /**
     * @dev Record referral commission.
     */
    function getReferrer(address user) external view returns (address);
}
interface IBankMigration {
    /**
     * @dev Record referral.
     */
    function userInfo(address user) external view returns(uint256,uint256,uint256,uint256);
    function pendingReward(address user)  external view returns (uint256);
    function currentRepo() external;
    function newRepo() external;
    function depositFeeBP() external;
    /**
     * @dev Record referral commission.
     */
    function getReferrer(address user) external view returns (address);
}
interface IDaoMigration {
    /**
     * @dev Record referral.
     */
    function userInfo(uint256 pid,address user) external view returns(uint256,uint256,uint256,uint256,uint256,string memory);
    function pendingReward(address user)  external view returns (uint256);
    function currentRepo() external;
    function newRepo() external;
    function depositFeeBP() external;
    /**
     * @dev Record referral commission.
     */
    function getReferrer(address user) external view returns (address);
}

 contract metabankContribution is ReentrancyGuard,IbankContribution,Pausable{
  using SafeBEP20 for IBEP20;
  using Counters for Counters.Counter;
  using SafeMath for uint256;
  using Strings for uint256;

  IBankMigration public bankMigration;
  IDaoMigration public daoMigration;
  IReferralPool public referralrewardpool;


  Counters.Counter private packCount;

  address public feeAddr;
  uint256 private fees;
  address public defaultReferrer;
  uint256 public id;
  mapping(uint256 => address) public idlist;
  uint256 public uid=0;
  uint public totalBurnt; 
  uint public accBnbPerShare;
  address payable management;
  address payable buyback;
  IVaultReferral public referralvault;
  mapping(address => Account) public accounts;
  mapping (uint256 => Package) public packages;
  mapping(uint256 => address) public holderlist;
  mapping(address => bool) public memberdetect;
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;
  mapping(address => Deposit[]) public depositsOf;
  PoolInfo[] public poolInfo;
  RewardInfo[] public rewardInfo;
  ReferralInfo[] public referralInfo;
  struct UserInfo {
    uint256 amount;     
    uint256 point;    
    uint256 rewardDebt;
    uint256 lastwithdraw;
    uint256 lastDeposit;
    uint256 referralpoint;
    uint256 bankmigration;
    uint256 daomigration;
  }
  struct Account {
    string userID;
    address payable referrer;
    uint256 reward;
    uint256 referredCount;
    uint256 depositAmount;
  }

  struct Deposit {
    uint256 amount;
    uint64 start;
    uint64 end;
  }
  
  struct Package{
    uint256 amount;
    address token;
  }
  struct PoolInfo {
    address acceptedToken;
    IBEP20 lpToken; // Address of LP token contract.
    IBEP20 withdrawal; // Address of secondary token for withdrawal.
    uint256 allocPoint; // How many allocation points assigned to this pool. token to distribute per block, bnbpertime.
    uint256 lastRewardTime;
    uint256 currentRepo;
    uint256 newRepo;
    uint256 lockTime;
    uint256 pointPerShare; // Last block number that token distribution occurs.
    uint256 totalReferralPoint; // Accumulated token per share, times 1e12. See below.
    uint256 totalJoin;
  }
  struct RewardInfo{
    uint256 joinCount;
    uint256 reward;
    uint256 rewardperperson;
    uint256 rewarddivider;
    uint256 maxreward;

  }
  struct ReferralInfo{
    uint256 referralrate;
    uint256 technicalrate;
    uint256 bonusrate;
  }
  IBEP20 public DCVCToken;
  IBEP20 public BUSDToken;
  uint public lastRewardTime;
  uint public depositFeeBP=400;
  uint public Maxmul=30;//max 30%
  uint public maxRewardTime=3600*24*7; 
  uint public bnbPerTime;//*1e18
  uint public totalPoint;
  uint public newRepo;
  address public treasuryRecords;
  uint256 private MAX_FEE;
  uint public pricedcvc;
  uint public decimals;

  uint public currentRepo;
  uint public period;
  daoZap public zapContract;
  address public technical;
  uint public maxDuration;
  uint public endtime;
  uint public totalpayout;
  uint public busdtotalpayout;
  address public burnAddress=0x000000000000000000000000000000000000dEaD;
  uint256[] public levelRate;
  uint256[] public referralRate;
  uint256 public sdecimals2;
  uint8 constant MAX_REFER_DEPTH = 19;
  uint8 constant MAX_REFEREE_BONUS_LEVEL = 3;
  event AgentRecorded(address indexed user, uint256 amount, uint256 timestamp);
  event AgentRewarded(address indexed user, uint256 amount, uint256 timestamp);
  event AgentClaimed(address indexed user, uint256 amount, uint256 timestamp);
  event RegisteredReferer(address referee, address referrer);
  event UpdateReferer(address referee, address referrer);
  event RegisteredRefererFailed(address referee, address referrer, string reason);
  event PaidReferral(address from, address to, uint256 amount, uint256 level);
  event UpdatedUserLastActiveTime(address user, uint256 timestamp);
  mapping(address => bool) public operators;
  mapping(address => uint256) public depositamount;
  IRewardPool public RewardPool;

  constructor(
    uint256 _sdecimals2,
    uint256[] memory _levelRate,
    uint256[] memory _referralRate
    )  {
    sdecimals2 = _sdecimals2;
    levelRate = _levelRate;
    referralRate = _referralRate;
    operators[msg.sender] = true;
    defaultReferrer = msg.sender;
    feeAddr = msg.sender;
    _pause();

  }
  modifier onlyOperator() {
    require(operators[msg.sender], "operator: caller is not the operator");
    _;
  }

  function setFeeAddr(address _newFeeAddr)public onlyOperator{
    feeAddr = _newFeeAddr;
  }

  function setdefaultReferrer(address _newFeeAddr)public onlyOperator{
    defaultReferrer = _newFeeAddr;
  }

  function setFees(uint256 _newFee)public onlyOperator{
    require(_newFee > 0,'Value cannot be zero!');
    fees = _newFee;
  }


  function setBankMigration(address _bankMigration)public onlyOperator{
      bankMigration = IBankMigration(_bankMigration);
  }

  function setDaoMigration(address _daoMigration)public onlyOperator{
      daoMigration = IDaoMigration(_daoMigration);
  }

  function setRewardPool(address _token)public onlyOperator{
      RewardPool = IRewardPool(_token);
  }
   
  function setBUSD(address _token) public onlyOperator {
        BUSDToken=IBEP20(_token);
  }
  function setToken(address _token) public onlyOperator {
        DCVCToken=IBEP20(_token);
  }
  
  function unPause() public  onlyOperator {
    _unpause();
  }
  function Pause() public  onlyOperator {
    _pause();
  }

  function getCount(uint256 index)public view returns(uint256 count){
    if(index == 1){
      count = packCount.current();
    }
  }
  receive()external payable{}
  fallback()external payable{}

  function addPackage(uint144 amount,address token) public onlyOperator{
    Package storage packageSet = packages[getCount(1)];
    packageSet.amount = amount;
    packageSet.token = token;
    packCount.increment();
  }

  function editPackage(uint256 index,uint256 amount,address token) public onlyOperator{
    Package storage packageSet = packages[index];
    packageSet.amount = amount;
    packageSet.token = token;
  }
  function setzapContract(address _address) public onlyOperator {
    require(address(_address) != address(0), "new referal vault is the zero address");
    zapContract = daoZap(_address);
  }

  function checkPackage(uint256 amount,address token)public view returns(bool stat){
      stat = false;
    for(uint256 i;i<getCount(1);i++){
      if(packages[i].amount == amount && packages[i].token == token){
        stat = true;
        break;
      }
    }
  }
  function updatePool(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    if (block.timestamp <= pool.lastRewardTime) {
      return;
    }
    if (pool.allocPoint == 0) {
      pool.lastRewardTime = block.timestamp;
      return;
    }
    uint256 multiplier = block.timestamp.sub(pool.lastRewardTime);
    uint256 bnbReward = multiplier.mul(pool.allocPoint);
    pool.pointPerShare = pool.pointPerShare.add(bnbReward.mul(1e12).div(pool.allocPoint));
    pool.lastRewardTime = block.timestamp;
  }
  function updatePoolBUSD() public {
   if (block.timestamp <= lastRewardTime) {
            return;
        }
        if (totalPoint == 0) {
            lastRewardTime = block.timestamp;
            return;
        }
        uint256 multiplier = block.timestamp.sub(lastRewardTime);
        uint256 bnbReward = multiplier.mul(bnbPerTime);
        accBnbPerShare = accBnbPerShare.add(bnbReward.mul(1e12).div(totalPoint));
        lastRewardTime = block.timestamp;
  }
  function checkend(uint256 _pid) internal {//already updated pool above.
    PoolInfo storage pool = poolInfo[_pid];
    pool.currentRepo = pool.newRepo;//in case of error by over-paying
    pool.newRepo= getRewardInfo(pool.totalJoin,_pid);
    pool.pointPerShare=pool.currentRepo.mul(1e18).div(pool.lockTime);
  }
  function setPeriod(uint _period) public onlyOperator{
      period=_period;
    }
  function start(uint _period) public onlyOperator{
      require(_period>0,"Invalid period");
      unPause();
      period=_period;
      endtime=block.timestamp.add(period);
      currentRepo=newRepo;
      bnbPerTime=currentRepo.mul(1e18).div(period);
      newRepo=0;
    }
  function checkendBUSD() internal {//already updated pool above.
     if(endtime<=block.timestamp){
        endtime=block.timestamp.add(period);
        if(newRepo>10**19){//BUSDToken decimal 18 in bsc. should change on other chains.
          newRepo=newRepo.sub(10**19);
        }
        currentRepo=newRepo.mul(99).div(100);//in case of error by over-paying
        newRepo=0;
        bnbPerTime=currentRepo.mul(1e18).div(period);
      }
  }

  function safeDCVCTransfer(address _to, uint256 _amount) internal {
    uint256 balance = DCVCToken.balanceOf(address(this));
    if (_amount > balance) {
      DCVCToken.safeTransfer(_to, balance);
      totalpayout=totalpayout.add(balance);
    } else {
      DCVCToken.safeTransfer(_to, _amount);
      totalpayout=totalpayout.add(_amount);
    }
  }
  function pendingReward(address _user,uint256 _pid) external view returns (uint256) {
      UserInfo storage user = userInfo[_pid][_user];
      uint256 _accBnbPerShare = accBnbPerShare;
      if (block.timestamp > lastRewardTime && totalPoint != 0) {
          uint256 multiplier = block.timestamp.sub(lastRewardTime);
          uint256 BnbReward = multiplier.mul(bnbPerTime);
          _accBnbPerShare = _accBnbPerShare.add(BnbReward.mul(1e12).div(totalPoint));
      }
      return user.point.mul(_accBnbPerShare).div(1e12).sub(user.rewardDebt);
  }
  function setMaxbonustime(uint _max) public onlyOperator{
    maxRewardTime=_max;
  }
  function setDaoDuration(uint _max) public onlyOperator{
    maxDuration=_max;
  }
  function poolLength() external view returns (uint256) {
      return poolInfo.length;
  }
  function rewardLength() external view returns (uint256) {
      return rewardInfo.length;
  }

  function add(
    address _acceptedToken,
    IBEP20 _lpToken,
    IBEP20 _withdrawal
  ) public onlyOperator {
  
    poolInfo.push(
      PoolInfo({
    acceptedToken:_acceptedToken,
      lpToken:_lpToken, // Address of LP token contract.
      withdrawal:_withdrawal, // Address of secondary token for withdrawal.
      allocPoint:0, // How many allocation points assigned to this pool. token to distribute per block, bnbpertime.
    lastRewardTime: 0,
      currentRepo:0,
      newRepo:0,
      lockTime:0,
      pointPerShare:0, // Last block number that token distribution occurs.
      totalReferralPoint:0,
      totalJoin:0
      })
    );
  }

  function set(
    uint256 _pid, 
    address _acceptedToken,
    IBEP20 _lpToken,
    IBEP20 _withdrawal,
    uint256 _allocPoint,
      uint256 _lastRewardTime,
    uint256 _currentRepo,
    uint256 _newRepo,
    uint256 _lockTime,
    uint256 _pointPerShare,
    uint256 _totalReferralPoint
  ) public onlyOperator {
    
    poolInfo[_pid].acceptedToken = _acceptedToken;
    poolInfo[_pid].lpToken = _lpToken;
    poolInfo[_pid].withdrawal = _withdrawal;
    poolInfo[_pid].allocPoint = _allocPoint;
    poolInfo[_pid].lastRewardTime = _lastRewardTime;
    poolInfo[_pid].currentRepo=_currentRepo;
    poolInfo[_pid].newRepo=_newRepo;
    poolInfo[_pid].lockTime=_lockTime;
    poolInfo[_pid].pointPerShare=_pointPerShare;
    poolInfo[_pid].totalReferralPoint=_totalReferralPoint;
  }

  function addreferralinfo(
    uint256 _referralrate,
    uint256 _technicalrate,
    uint256 _bonusrate
  ) public onlyOperator {
    referralInfo.push(
      ReferralInfo({
        referralrate: _referralrate,
        technicalrate:_technicalrate,
        bonusrate: _bonusrate
      })
    );
  }
  /*
   *Write Function purpose here
   */
  function migrateBonus(address token,address payable referrer,uint256 _pid)public override payable {
    require(msg.value>=fees,'Fees is zero!');
    require(userInfo[_pid][msg.sender].bankmigration==0,'already migrate');
    bool status=addReferrer(referrer);
    require(status==true,'invalid referer');
    payable(feeAddr).transfer(msg.value);
    userInfo[_pid][msg.sender].bankmigration=1;
    (uint256 amount,uint point,uint rewardDebt,uint lastwithdraw)=bankMigration.userInfo(msg.sender);
    (uint256 reward)=bankMigration.pendingReward(msg.sender);
    if(reward>0){
    safeBUSDTransfer(msg.sender,reward);
    }
    require(amount>0,'not exists');
    UserInfo storage user = userInfo[_pid][msg.sender];
    user.amount = user.amount.add(amount);
    if(user.lastwithdraw==0){
        user.lastwithdraw=block.timestamp;//withdraw=>make 0
    }
    user.point=user.point.add(point);
    totalPoint=totalPoint.add(point);
    user.rewardDebt=user.rewardDebt.add(rewardDebt);  
    user.rewardDebt = user.point.mul(accBnbPerShare).div(1e12);
  }

  function DepositDao(uint256 _pid, address payable referrer, uint256 _amount , address token)public override payable{
    require(msg.value>=fees,'Fees is zero!');
    (bool stat)=checkPackage(_amount,token);
    require(stat,'Token is not accepted!');
    payable(feeAddr).transfer(msg.value);
    uint256 userAllowance = BUSDToken.allowance(msg.sender,address(this));
    require(userAllowance > 0,"Allowance is required!");
    bool status=addReferrer(referrer);
    require(status==true,'invalid referer');
    UserInfo storage user = userInfo[_pid][msg.sender];
    PoolInfo storage pool = poolInfo[_pid];
    IBEP20(pool.acceptedToken).safeTransfer(address(zapContract),_amount.mul(30).div(100));
    uint commision=_amount.mul(5).div(100);
    referralrewardpool.recordReferralCommission(referrer,address(BUSDToken),commision);
    IBEP20(BUSDToken).safeTransfer(address(referralrewardpool),commision);
    IBEP20(pool.acceptedToken).safeTransfer(address(treasuryRecords),_amount.mul(65).div(100));
    payreferralDAO(_pid,_amount);
    if(user.amount>0){
     uint pendingReward=userInfo[_pid][msg.sender].point*getmultipliertime(_pid,msg.sender);
     pendingReward=pendingReward.mul(510).div(86400).div(365).div(300).div(pricedcvc).mul(1e18).div(decimals);
      if(pendingReward>0){
        safeDCVCTransfer(msg.sender,pendingReward);
      }
    }
    uint _amountliquidity=zapContract.swapBUSDToLP(address(BUSDToken),address(DCVCToken));
    user.amount = user.amount.add(_amountliquidity);
    user.point=user.point.add(_amount);
    depositsOf[msg.sender].push(Deposit({
      amount: _amount,
      start: uint64(block.timestamp),
      end: uint64(block.timestamp) + uint64(maxDuration)
    }));
  }

  function withdrawDao(uint256 _amount,uint256 _pid,bool needLP) public payable  {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user= userInfo[_pid][msg.sender];
    require(msg.value>=fees,'Fees is zero!');
    payable(feeAddr).transfer(msg.value);
    require(user.amount >= _amount, "withdraw: not good");
    if(user.amount > 0 && _amount != 0){
    require(user.lastDeposit.add(pool.lockTime) < block.timestamp,"Withdraw: Locked!");
     uint pendingReward=userInfo[_pid][msg.sender].point*getmultipliertime(_pid,msg.sender);
     pendingReward=pendingReward.mul(510).div(86400).div(365).div(300).div(pricedcvc).mul(1e18).div(decimals);
      if(pendingReward>0){
        safeDCVCTransfer(msg.sender,pendingReward);
      }
    }
    if(_amount > 0) {
        user.amount = user.amount.sub(_amount);
        if(needLP){
          IBEP20(pool.lpToken).safeTransfer(msg.sender, _amount);
        }else{
          IBEP20(pool.lpToken).safeTransfer(address(zapContract), _amount);
          zapContract.swapLPToToken(address(BUSDToken), address(DCVCToken),msg.sender);
        }
      //   BUSDToken.safeTransfer(address(zapContract), _amount);
    }
    user.lastwithdraw = 0;
    pool.allocPoint=pool.allocPoint.sub(user.point).add(user.amount);
    user.point=user.amount;
    if(user.amount==0){
      pool.totalJoin = pool.totalJoin.sub(1);
      user.lastDeposit=0;
    }
    checkend(_pid);
    }

   function depositBank(address token,address payable referrer,uint256 _amount,uint _pid) public override payable {
    require(msg.value>=fees,'Fees is zero!');
     address refer= referralvault.getReferrer(referrer);
    require(refer!=address(0), 'invalid referrer');
    payable(feeAddr).transfer(msg.value);
    bool status=addReferrer(referrer);
    require(status==true,'invalid referer');
    UserInfo storage user = userInfo[_pid][msg.sender];
    if (user.point > 0) {
      uint256 pending = user.point.add(user.referralpoint).mul(accBnbPerShare).div(1e12).sub(user.rewardDebt);
      if(pending > 0) {
        safeBUSDTransfer(msg.sender, pending.div(1e18));
      }
    }
    if(_amount > 0) {
      DCVCToken.safeTransferFrom(address(msg.sender), address(this), _amount);
      if(depositFeeBP > 0){
        uint256 depositFee = _amount.mul(depositFeeBP).div(10000);
        DCVCToken.safeTransfer(burnAddress , depositFee);
        totalBurnt+=depositFee;//safeMath already checked above
        user.amount = user.amount.add(_amount).sub(depositFee);
      }else{
        user.amount = user.amount.add(_amount);
      }
      if(user.lastwithdraw==0){
        user.lastwithdraw=block.timestamp;//withdraw=>make 0
      }
      uint multiple=getMultiple(msg.sender,_pid);
      totalPoint=totalPoint.sub(user.point);
      user.point=user.amount.mul(multiple).div(1e12);
      totalPoint=totalPoint.add(user.point);
      
    }
    user.rewardDebt = user.point.mul(accBnbPerShare).div(1e12);
    payreferralbank(_pid,_amount);
    updatePoolBUSD();
    checkendBUSD();
  }

  function withdrawBank(uint256 _amount,uint _pid) public payable  {
    require(msg.value>=fees,'Fees is zero!');
    payable(feeAddr).transfer(msg.value);
    UserInfo storage user= userInfo[_pid][msg.sender];
    require(user.amount >= _amount, "withdraw: not good");
    if (user.point > 0) {
      uint256 pending = user.point.add(user.referralpoint).mul(accBnbPerShare).div(1e12).sub(user.rewardDebt);
      if(pending > 0) {
        safeBUSDTransfer(msg.sender, pending.div(1e18));
      }
    }
 updatePoolBUSD();
    if(_amount > 0) {
      user.amount = user.amount.sub(_amount);
      DCVCToken.safeTransfer(address(msg.sender), _amount);
    }
    user.lastwithdraw=0;
    totalPoint=totalPoint.sub(user.point).sub(user.referralpoint).add(user.amount);
    user.point=user.amount;
    user.rewardDebt = user.point.mul(accBnbPerShare).div(1e12);
    checkendBUSD();
  }

    function payreferralbank(uint _pid,uint value) internal returns(uint){
    address user=msg.sender;
    uint256 totalReferal;
     uint256 c ;
    for (uint256 i; i < levelRate.length; i++) {
      
      address  parent =referralvault.getReferrer(user);
      if (parent == address(0)) {
        break;
      }
     
      c = value.mul(levelRate[i]).div(sdecimals2);
      totalPoint=totalPoint.add(c);
      userInfo[_pid][parent].referralpoint=userInfo[_pid][parent].referralpoint.add(c);
     
      emit PaidReferral(msg.sender, parent, c, i + 1);
      user = parent;
    }
    
    return totalReferal;
  }
    
  

  function getMultiple(address _user,uint _pid) public view returns(uint256 multiple){//returns in X 1e12
    multiple=block.timestamp.sub(userInfo[_pid][_user].lastwithdraw).mul(1e10).div(maxRewardTime).mul(Maxmul).add(1e12);//1e12 / 100%
    if(multiple>Maxmul.mul(1e10).add(1e12)){
      multiple=Maxmul.mul(1e10).add(1e12);
    }
  }

  function payreferralDAO(uint256 _pid,uint value) internal returns(uint){
    // Account memory userAccount = accounts[msg.sender];
    address user=msg.sender;
    uint256 totalReferal;
     uint256 c ;
    for (uint256 i; i < referralRate.length; i++) {
      address  parent =referralvault.getReferrer(user);
      if (parent == address(0)) {
        break;
      }
      c = value.mul(referralRate[i]).div(sdecimals2);
      totalReferal = totalReferal.add(c);
      userInfo[_pid][parent].referralpoint=userInfo[_pid][parent].referralpoint.add(c);
      emit PaidReferral(msg.sender, parent, c, i + 1);
      user = parent;
    }
    // updateActiveTimestamp(msg.sender);
    return totalReferal;
  }

  function migrateDao(address token,address payable referrer,uint _pid)public override payable {
    require(msg.value>=fees,'Fees is zero!');
    require(userInfo[_pid][msg.sender].daomigration==0,'already migrate');
    payable(feeAddr).transfer(msg.value);
    (uint256 amount,uint point,uint rewardDebt,uint lastwithdraw,,)=daoMigration.userInfo(_pid,msg.sender);
    require(amount>0,'not exists');
     bool status=addReferrer(referrer);
    require(status==true,'invalid referer');
    UserInfo storage user = userInfo[_pid][msg.sender];
    user.amount = user.amount.add(amount);
    userInfo[_pid][msg.sender].daomigration=1;
    (uint256 reward)=daoMigration.pendingReward(msg.sender);
    if(reward>0){
    safeDCVCTransfer(msg.sender,reward.div(1e18));
    }
    user.lastwithdraw=block.timestamp;
    //temporary set to 100, may find solution for the 500 packages
    user.point=user.point.add(100);
    user.rewardDebt=user.rewardDebt.add(rewardDebt);  
  }

  function safeBUSDTransfer(address _to, uint256 _amount) internal {
    uint256 balance = BUSDToken.balanceOf(address(this));
    if (_amount > balance) {
        BUSDToken.safeTransfer(_to, balance);
        busdtotalpayout=busdtotalpayout.add(balance);
    } else {
        BUSDToken.safeTransfer(_to, _amount);
        busdtotalpayout=busdtotalpayout.add(_amount);
    }
  }

  function massUpdatePools() public {
    uint256 length = poolInfo.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pid);
      checkend(pid);
    }
  }

  function setpriceDCVC(uint _price) public onlyOperator
  {
    pricedcvc=_price;
  }

  function setTreasurry(address _address) public onlyOperator
  {
    treasuryRecords=_address;
  }

  function setdecimals(uint _decimals) public onlyOperator
  {
    decimals=_decimals;
  }

  function getmultipliertime(uint _pid,address _address) public view returns(uint remaining){
    uint lastwithdraw=userInfo[_pid][_address].lastwithdraw;
    if(block.timestamp>lastwithdraw)
    {
      remaining= block.timestamp-lastwithdraw;
    }else{
      remaining=0;
    }
  } 

  function pendingRewardDaorate(uint _pid, address _address) public view returns (uint256){
    uint totalpoint=userInfo[_pid][_address].point.add(userInfo[_pid][_address].referralpoint);
    uint point=totalpoint*getmultipliertime(_pid,_address);
    return point.mul(510).div(86400).div(365).div(300).div(pricedcvc).mul(1e18).div(decimals);
  }

  function getRewardInfo(uint256 _totalJoin,uint256 _pid) public view returns (uint256 _reward){
    RewardInfo storage rewardDetails = rewardInfo[_pid];
    uint256 multipleperreward=_totalJoin.div(rewardDetails.rewardperperson).mul(rewardDetails.rewarddivider);
    _reward=rewardDetails.reward.add(multipleperreward);
    if(_reward>rewardDetails.maxreward){
        _reward=rewardDetails.maxreward;
    }
  }

  function setreferralreward(address _address) public onlyOperator {
    require(address(_address) != address(0), "new referal reward pool is the zero address");
    referralrewardpool = IReferralPool(_address);
  }

  function inCaseTokensGetStuck(address _token) external onlyOperator {
    uint256 amount = IBEP20(_token).balanceOf(address(this));
    IBEP20(_token).safeTransfer(msg.sender, amount);
  }
 
  function inCaseNativeStuck() public onlyOperator {
    payable(msg.sender).transfer(address(this).balance);
  }

  function sum(uint256[] memory data) public pure returns (uint) {
    uint256 S;
    for(uint256 i;i < data.length;i++) {
      S += data[i];
    }
    return S;
  }

  /**
   * @dev Utils function for check whether an address has the referrer
   */
  function hasReferrer(address addr) public view returns(bool){
    return accounts[addr].referrer != address(0);
  }

  /**
   * @dev Get block timestamp with function for testing mock
   */
  function getTime() public view returns(uint256) {
    return block.timestamp; // solium-disable-line security/no-block-members
  }

  function isCircularReference(address referrer, address referee) internal view returns(bool){
    address parent = referrer;

    for (uint256 i; i < levelRate.length; i++) {
      if (parent == address(0)) {
        break;
      }

      if (parent == referee) {
        return true;
      }

      parent = accounts[parent].referrer;
    }

    return false;
  }

  /**
   * @dev Add an address as referrer
   * @param referrer The address would set as referrer of msg.sender
   * @return whether success to add upline
   */
  function addReferrer(address payable referrer) internal returns(bool){
      require (referrer !=address(0),"address must be referrer");
    if (referrer == address(0)) {
      emit RegisteredRefererFailed(msg.sender, referrer, "Referrer cannot be 0x0 address");
      return false;
    } 
      address secondrefer=referralvault.getReferrer(referrer);
      if(secondrefer==address(0)){
      emit RegisteredRefererFailed(msg.sender, referrer, "Referrer not registered");
      return false;
      }
    address refer= referralvault.getReferrer(msg.sender);
    if(refer==address(0)){
      referralvault.recordReferral(msg.sender,referrer);
    }
    return true;
  }

  /**
   * @dev This will calc and pay referral to uplines instantly
   * @param value The number tokens will be calculated in referral process
   * @return the total referral bonus paid
   */
  



  /**
   * @dev This will read all address related to the caller referral account up to input level
   * @param level The level to be involved to check above the parent referrer address
   * @return the list of address involved in input level
   */
  function getReferralByLevel(address user,uint256 level) public view returns(address[] memory){
    Account memory userAccount = accounts[user];
    address[] memory uline =   new address[](level);

    for (uint256 i; i < level; i++) {
      address payable parent = userAccount.referrer;
      Account storage parentAccount = accounts[userAccount.referrer];

      if (parent == address(0)) {
        break;
      }

      uline[i] = parent;
      
      userAccount = parentAccount;
    }

    return uline;
  }

  function getReferrer(address user) public view returns(address parent){
    Account memory userAccount = accounts[user];
    parent = userAccount.referrer;
    if (parent == address(0)) {
       parent=referralvault.getReferrer(user);
    }
  }
 
  function changeReferrer(address  _user,address  referrer)public onlyOperator{
    referralvault.referralReset(_user,referrer);
  }

  function setDecimals(uint256 _sdecimals2) public onlyOperator{
    sdecimals2 = _sdecimals2;
  }

  function setmanagement(address payable _management) public onlyOperator{
    management = _management;
  }

  function setbuyback(address payable _buyback) public onlyOperator{
    buyback = _buyback;
  }

  function setreferralvault(address referral) public onlyOperator{
    referralvault=IVaultReferral(referral);
  }

  function changeuserInfo(address payable user,address payable _referrer, uint256 _reward, uint256 _referredCount, uint256 depositAmount) public onlyOperator{
    accounts[user].referrer=_referrer;
    accounts[user].reward=_reward;
    accounts[user].referredCount=_referredCount;
    accounts[user].depositAmount=depositAmount;
  }

  function setLevelRate(uint256[] memory _levelRate) public onlyOperator{
    require(_levelRate.length > 0, "Referral level should be at least one");
    require(_levelRate.length <= MAX_REFER_DEPTH, "Exceeded max referral level depth");
    levelRate = _levelRate;
  }

  function setReferralRate(uint256[] memory _referralRate) public onlyOperator{
    require(_referralRate.length > 0, "Referral level should be at least one");
    referralRate = _referralRate;
  }


  function updateOperator(address _operators, bool _status) external onlyOperator {
    operators[_operators] = _status;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.0;

import "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}