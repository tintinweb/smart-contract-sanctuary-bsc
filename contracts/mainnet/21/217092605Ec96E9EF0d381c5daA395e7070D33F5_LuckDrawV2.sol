/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

pragma solidity ^0.5.0;
// pragma experimental ABIEncoderV2;
interface IERC20 {
    function totalSupply() external view returns (uint256);    
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function decimals() external view returns(uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}
// File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
contract LuckDrawV2 {
    using SafeMath for uint256;
    mapping(address => address) private _superiorMap;
    mapping(address => uint256) private _userTopIdMap;
    mapping(uint256 => address) private _topIdToAddressMap;
    mapping(address => uint256) private _topAddressToIdMap;
    mapping(address => uint256) private _pushIncomeMap;
    mapping(address => uint256) private _nodeIncomeMap;
    mapping(address => uint256) private _incomeMap;
    mapping(address => uint256) private _userLowerSumMap;
    mapping(uint256 => uint256) private _topLowerSumMap;
    uint256 private _topCount = 0;
    uint256 private _gameCount = 0;
    mapping(uint256 => FastGame) private _fastGameMap;
    mapping(uint256 => NormalGame) private _normalGameMap;
    uint256 public _roundId = 0;
    mapping(uint256 => Session) private _sessionMap;
    mapping(uint256 => uint256) private _awardedMap;
    mapping(uint256 => address[]) public _roundUserMap;
    uint256 public _nodeFee = 5;
    uint256 public _superiorFee = 5;
    uint256 public _poolFee = 10;
    address public _poolAddress = address(0xfEf0A605cfA4021bA1fD22Ae5d059c5bE70CC48D);
    uint256 public _operateFee = 10;
    address public _operateAddress = address(0x26788C50DedcCF2ca6e80Ac0F55ad16803145577);
    uint256 public _fastNo2Number = 10;
    uint256 public _fastNo1Fee = 30;
    uint256 public _fastNo2Fee = 70;
    uint256 public _normalNo1Fee = 30;
    uint256 public _normalNo2Fee = 30;
    uint256 public _normalNo3Fee = 40;
    IERC20 private _usdtContract;
    address public _owner;
    event Register(address account,address superiorAddress,address topAddress);
    event Share(address account,uint256 gameId,uint256 roundId,uint256 price,uint256 time);
    event StartNewGame(uint256 gameId,uint256 roundId,address account,uint256 time);
    event SendRewards(address account,address superior,uint256 superiorReward,address top,uint256 topReward,uint256 time);
    event FastDrawAPrize(uint256 roundId,address no1,uint256 no1Reward,address no2,uint256 no2Reward,address no3,uint256 no3Reward,uint256 time);
    event NormalDrawAPrize(uint256 roundId,address[] no1,uint256 no1Reward,address[] no2,uint256 no2Reward,address[] no3,uint256 no3Reward,uint256 time);
    modifier isOwner(){
        require(msg.sender == _owner);
        _;
    }
    struct Reward{
        address account;
        uint256 amount;
    }
    struct Session{
        uint256 thisNumber;
        uint256 startTime;
        uint256 endTime;
        uint256 pool;
        bool isOver;
    }
    struct FastGame {
        uint256 price;
        uint256 number;
    }
    struct NormalGame {
        uint256 price;
        uint256 poolCount;
    }
    constructor() public {
        _owner = msg.sender;
        _usdtContract = IERC20(0x55d398326f99059fF775485246999027B3197955);
        addNode(_owner);
        init();
    }
    function init() internal {
        uint256 decimals = _usdtContract.decimals();
        _fastGameMap[++_gameCount] = FastGame(1 * 10 ** decimals,20);
        _normalGameMap[++_gameCount] = NormalGame(2 * 10 ** decimals,0);
        _normalGameMap[++_gameCount] = NormalGame(5 * 10 ** decimals,0);
        _normalGameMap[++_gameCount] = NormalGame(10 * 10 ** decimals,0);
    }
    function setFastNo2Number(uint256 number)public isOwner{
        _fastNo2Number = number;
    }
    function setGame(uint256 numberPeople) public isOwner{
        _fastGameMap[1] = FastGame(1 * 10 ** _usdtContract.decimals(),numberPeople);
    }
    function share(uint256 gameId) public{
        require(!isNewUser(msg.sender),"you is new user");
        require(gameId > 0 && gameId <= _gameCount,"gameId not found");
        if(gameId == 1){
            fastGameShare(gameId);
            return;
        }
        normalGameShare(gameId);
        return;
    }
    function fastGameShare(uint256 gameId) internal {
        uint256 roundId = getAwardedByGameId(gameId);
        (uint256 thisNumber,,,,bool isOver) = getRoundInfo(roundId);
        FastGame memory fastGame = _fastGameMap[gameId];
        if(roundId == 0 || isOver){
            startFastGame(gameId,msg.sender,fastGame.price);
            return;
        }
        if(thisNumber.add(1) == fastGame.number){
            fastDrawPrize(gameId,roundId);
            return;
        }
        fastPutIn(gameId,msg.sender,fastGame.price);
        return;
    }
    function fastPutIn(uint256 gameId,address account,uint256 price) internal{
        Reward[] memory rewards = getReward(account,price);
        _usdtContract.transferFrom(account,address(this),price);
        uint256 rewardAmount = 0;
        for(uint i = 0;i < rewards.length;i++){
            address rewardAccount = rewards[i].account;
            if(rewardAccount != address(0)){
                _usdtContract.transfer(rewardAccount,rewards[i].amount);
                rewardAmount += rewards[i].amount;
                if(i==0){
                    _pushIncomeMap[rewardAccount] = _pushIncomeMap[rewardAccount].add(rewards[i].amount);
                }else{
                    _nodeIncomeMap[rewards[i].account] = _nodeIncomeMap[rewards[i].account].add(rewards[i].amount);
                }
            }
        }
        uint256 poolPutIn = price.sub(rewardAmount);
        addShareUser(gameId,account,poolPutIn);
        emit SendRewards(account,rewards[0].account,rewards[0].amount,rewards[1].account,rewards[1].amount,now);
    }
    function normalGameShare(uint256 gameId) internal {
        uint256 roundId = getAwardedByGameId(gameId);
        (,,,,bool isOver) = getRoundInfo(roundId);
        NormalGame memory normalGame = _normalGameMap[gameId];
        if(roundId == 0 || isOver){
            startNormalGame(gameId,msg.sender,normalGame.price);
            return;
        }
        normalPutIn(gameId,msg.sender,normalGame.price);
        return;
    }
    function normalDrawPrize(uint256 roundId,address[] memory no1,address[] memory no2,address[] memory no3) public isOwner {
        require(no1.length > 0 && no2.length > 0 && no3.length > 0,"Please don't empty the winner");
        Session storage session = _sessionMap[roundId];
        require(!session.isOver,"The prize has been drawn");
        uint256 no1Pool = calculateReward(session.pool,_normalNo1Fee);
        uint256 no2Pool = calculateReward(session.pool,_normalNo2Fee);
        uint256 no3Pool = session.pool.sub(no1Pool).sub(no2Pool);
        uint256 noOne1 = no1Pool.div(no1.length);
        for(uint i = 0; i < no1.length;i++){
            _usdtContract.transfer(no1[i],noOne1);
        }
        uint256 noOne2 = no2Pool.div(no2.length);
        for(uint i = 0; i < no2.length;i++){
            _usdtContract.transfer(no2[i],noOne2);
        }
        uint256 noOne3 = no3Pool.div(no3.length);
        for(uint i = 0; i < no3.length;i++){
            _usdtContract.transfer(no3[i],noOne3);
        }
        session.endTime = now;
        session.pool = 0;
        session.isOver = true;
        _sessionMap[roundId] = session;
        emit NormalDrawAPrize(roundId,no1,noOne1,no2,noOne2,no3,noOne3,now);
    }
    function fastDrawPrize(uint256 gameId,uint256 roundId) internal {
        FastGame memory fastGame = _fastGameMap[gameId];
        fastPutIn(gameId,msg.sender,fastGame.price);
        Session storage session = _sessionMap[roundId];
        (Reward memory no1,Reward[] memory mediumUser) = getFastPrizeUsers(roundId,session.pool);
        _usdtContract.transfer(no1.account,no1.amount);
        for(uint i = 0;i < mediumUser.length;i++){
            _usdtContract.transfer(mediumUser[i].account,mediumUser[i].amount);
            _incomeMap[mediumUser[i].account] = _incomeMap[mediumUser[i].account].add(mediumUser[i].amount);
        }
        session.endTime = now;
        session.pool = 0;
        session.isOver = true;
        _sessionMap[roundId] = session;
        emit FastDrawAPrize(roundId,mediumUser[0].account,mediumUser[0].amount,mediumUser[1].account,mediumUser[1].amount,mediumUser[2].account,mediumUser[2].amount,now);
    }
    function getFastPrizeUsers(uint256 roundId,uint256 reward) internal view returns(Reward memory,Reward[] memory){
        uint256 roundCount = _roundUserMap[roundId].length;
        uint256 no1Index = getRandom(now,roundCount);
        uint256 no1Reward = calculateReward(reward,_fastNo1Fee); 
        Reward memory no1 = Reward(_roundUserMap[roundId][no1Index],no1Reward);
        Reward[] memory mediumUser = new Reward[](10);
        uint256 no2NoOne = (reward.sub(no1Reward)).div(_fastNo2Number);
        uint number = 0;
        while(number < _fastNo2Number){
            if(++no1Index >= roundCount){
                no1Index = 0;
            } 
            mediumUser[number] = Reward(_roundUserMap[roundId][no1Index],no2NoOne);
            number++;
        }
        return(no1,mediumUser);
    }
    function getRandom(uint256 random,uint256 length) internal pure returns(uint256){
        return random % length;
    }
    function startFastGame(uint256 gameId,address account,uint256 price) internal {
        _sessionMap[++_roundId] = Session(0,now,0,0,false);
        _awardedMap[gameId] = _roundId;
        fastPutIn(gameId,account,price);
        emit StartNewGame(gameId,_roundId,account,now);
    }
    function startNormalGame(uint256 gameId,address account,uint256 price) internal{
        _sessionMap[++_roundId] = Session(0,now,0,0,false);
        _awardedMap[gameId] = _roundId;
        normalPutIn(gameId,account,price);
        emit StartNewGame(gameId,_roundId,account,now);
    }
    function normalPutIn(uint256 gameId,address account,uint256 price) internal {
        uint256 rewardAmount = 0;
        Reward[] memory rewards = getReward(account,price);
        for(uint i = 0;i < rewards.length;i++){
            address rewardAccount = rewards[i].account;
            if(rewardAccount != address(0)){
                _usdtContract.transferFrom(account,rewardAccount,rewards[i].amount);
                rewardAmount += rewards[i].amount;
                if(i==0){
                    _pushIncomeMap[rewardAccount] = _pushIncomeMap[rewardAccount].add(rewards[i].amount);
                }else{
                    _nodeIncomeMap[rewards[i].account] = _nodeIncomeMap[rewards[i].account].add(rewards[i].amount);
                }
            }
        }
        uint256 operateAmount = calculateReward(price,_operateFee);
        rewardAmount += operateAmount;
        _usdtContract.transferFrom(account,_operateAddress,operateAmount);
        uint256 poolAmount = calculateReward(price,_poolFee);
        rewardAmount += poolAmount;
        _usdtContract.transferFrom(account,_poolAddress,poolAmount);
        uint256 surplus = price.sub(rewardAmount);
        _usdtContract.transferFrom(account,address(this),surplus);
        addShareUser(gameId,account,surplus);
        emit SendRewards(account,rewards[0].account,rewards[0].amount,rewards[1].account,rewards[1].amount,now);
    }
    function getPushIncome(address account) public view returns(uint256){
        return _pushIncomeMap[account];
    }
    function getNodeIncome(address account) public view returns(uint256){
        return _nodeIncomeMap[account];
    }
    function fastRewardCount(address account,uint256 price) internal view returns(uint256){
        Reward[] memory rewards = getReward(account,price);
        if(rewards[0].account == address(0) && rewards[0].account == address(0)){
            return 0;
        }       
        return rewards[0].amount.add(rewards[1].amount);
    }
    function normalRewardCount(address account,uint256 price) internal view returns(uint256){
        Reward[] memory rewards = getReward(account,price);
        uint256 operateAmount = calculateReward(price,_operateFee);
        uint256 poolAmount = calculateReward(price,_poolFee);
        uint256 amount = operateAmount + poolAmount;
        if(rewards[0].account == address(0) && rewards[0].account == address(0)){
            return amount;
        }
        return amount.add(rewards[0].amount.add(rewards[1].amount));
    }
    function addShareUser(uint256 gameId,address account,uint256 price) internal {
        uint256 roundId = getAwardedByGameId(gameId);
        address[] storage accounts = _roundUserMap[roundId];
        accounts.push(account);
        _roundUserMap[roundId] = accounts;
        Session storage session = _sessionMap[roundId];
        session.thisNumber = session.thisNumber.add(1);
        session.pool = session.pool.add(price);
        emit Share(account,gameId,roundId,price,now);
    }
    function getRoundInfo(uint256 roundId) public view returns(uint256,uint256,uint256,uint256,bool){
        Session memory session = _sessionMap[roundId];
        uint256 thisNumber = session.thisNumber;
        uint256 startTime = session.startTime;
        uint256 endTime = session.endTime;
        uint256 pool = session.pool;
        bool isOver = session.isOver;
        return(thisNumber,startTime,endTime,pool,isOver);
    }
    function setToken(address token)public isOwner {
        _usdtContract = IERC20(token);
    }
    function superiorMap(address account) public view returns(address){
        return _superiorMap[account];
    }
    function getNodeAddress(address account) public view returns(address){
        return _topIdToAddressMap[_userTopIdMap[account]];
    }
    function register(address oldUser) public {
        require(isNewUser(msg.sender),"not a new user");
        require(!isNewUser(oldUser),"oldUser is new user");
        _superiorMap[msg.sender] = oldUser;
        address topAddress;
        if(isNodeAddress(oldUser)){
            _userTopIdMap[msg.sender] = _topAddressToIdMap[oldUser];
            topAddress = oldUser;
        }else{
            _userTopIdMap[msg.sender] = _userTopIdMap[oldUser];
            topAddress = getNodeAddress(oldUser);
        }
        _userLowerSumMap[oldUser] = _userLowerSumMap[oldUser] + 1;
        _topLowerSumMap[_topAddressToIdMap[topAddress]] = _topLowerSumMap[_topAddressToIdMap[topAddress]] + 1;
        emit Register(msg.sender,oldUser,topAddress);
    }
    function isNodeAddress(address account) public view returns(bool){
        return _topAddressToIdMap[account] != uint256(0);
    }
    function topLowerSumMap(address account) public view returns(uint256){
        return _topLowerSumMap[_topAddressToIdMap[account]];
    } 
    function userLowerSumMap(address account)public view returns(uint256){
        return _userLowerSumMap[account];
    }
    function getIncome(address account) public view returns(uint256){
        return _incomeMap[account];
    }
    function addNode(address newNode) public isOwner{
        _topIdToAddressMap[++_topCount] = newNode;
        _topAddressToIdMap[newNode] = _topCount;
    } 
    function setNode(address oldNode,address newNode) public isOwner{
        require(isNodeAddress(oldNode),"oldNode is not Node address");
        uint256 topIndex = _topAddressToIdMap[oldNode];
        delete _topAddressToIdMap[oldNode];
        _topIdToAddressMap[topIndex] = newNode;
        _topAddressToIdMap[newNode] = topIndex;
    }
    function isNewUser(address account) public view returns(bool){
        if(isNodeAddress(account)){
            return false;
        }
        return _superiorMap[account] == address(0);
    }
    function getReward(address shareAccount,uint256 money) internal view returns(Reward[] memory) {
        Reward[] memory rewards=new Reward[](2);
        address superior = _superiorMap[shareAccount];
        rewards[0] = Reward(superior,calculateReward(money,_superiorFee));
        address node = getNodeAddress(shareAccount);
        rewards[1] = Reward(node,calculateReward(money,_nodeFee));
        return rewards;
    }
    function calculateReward(uint256 amount,uint256 fee) private pure returns (uint256){
        return amount.mul(fee).div(10 ** 2);
    }
    function getAwardedByGameId(uint256 gameId) public view returns(uint256){
        return _awardedMap[gameId];
    }
}