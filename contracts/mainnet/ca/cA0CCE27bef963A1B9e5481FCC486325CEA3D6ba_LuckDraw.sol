/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

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

contract LuckDraw{
    using SafeMath for uint256;
    
    mapping(address => address) private _superiorMap;
    
    mapping(address => uint256) private _userTopIdMap;
    
    mapping(uint256 => address) private _topIdToAddressMap;
    
    mapping(address => uint256) private _topAddressToIdMap;
    
    mapping(address => uint256) private _pushIncomeMap;
    
    mapping(address => uint256) private _nodeIncomeMap;
    
    mapping(address => Access) private _accessMap;
    
    mapping(address => uint256) private _userLowerSumMap;
    
    mapping(uint256 => uint256) private _topLowerSumMap;
    
    uint256 private _topCount = 0;
    
    uint256 private _gameCount = 0;
    
    mapping(uint256 => Game) private _gameMap;
    
    uint256 public _roundId = 0;
    
    mapping(uint256 => Session) private _sessionMap;
    
    mapping(uint256 => uint256) private _awardedMap;
    
    mapping(uint256 => address[]) private _roundUserMap;
    
    uint256 public _nodeFee = 5;
    
    uint256 public _superiorFee = 5;
    
    uint256 public _poolFee = 50;
    
    uint256 public _takePool = 10;  
    uint256 public _no1Fee = 50;
    uint256 public _no2Fee = 30;
    uint256 public _no3Fee = 20;
    IERC20 private _usdtContract;
    address public _owner;
    
    event Register(address account,address superiorAddress,address topAddress);
    
    event Share(address account,uint256 gameId,uint256 roundId,uint256 price,uint256 time);
    
    event StartNewGame(uint256 gameId,uint256 roundId,address account,uint256 time);
    
    event SendRewards(address account,address superior,uint256 superiorReward,address top,uint256 topReward,uint256 time);
    
    event DrawAPrize(uint256 roundId,address no1,uint256 no1Reward,address no2,uint256 no2Reward,address no3,uint256 no3Reward,uint256 time);
    modifier isOwner(){
        require(msg.sender == _owner);
        _;
    }

    
    struct Reward{
        address account;
        uint256 amount;
    }
    struct Access{
        uint256 putIn;
        uint256 income;
    }

    struct Session{
        
        uint256 thisNumber;
        
        uint256 startTime;
        
        uint256 endTime;
        
        uint256 pool;
        
        bool isOver;
    }

    
    struct Game {
        
        uint256 price;
        
        uint256 numberPeople;
        
        uint256 poolCount;
        
        uint256 duration;
        
        uint256 gapTime;
    }

    constructor() public {
        _owner = msg.sender;
        _usdtContract = IERC20(0x55d398326f99059fF775485246999027B3197955);
        addNode(_owner);
        init();
    }
    
    function init() internal {
        uint256 decimals = _usdtContract.decimals();
        
        _gameMap[++_gameCount] = Game(1 * 10 ** decimals,30,0,1800,60);
        _gameMap[++_gameCount] = Game(3 * 10 ** decimals,30,0,1800,60);
        _gameMap[++_gameCount] = Game(5 * 10 ** decimals,30,0,1800,60);
        
        _gameMap[++_gameCount] = Game(5 * 10 ** decimals,100,0,1800,60);
        _gameMap[++_gameCount] = Game(10 * 10 ** decimals,100,0,1800,60);
        _gameMap[++_gameCount] = Game(20 * 10 ** decimals,100,0,1800,60);
    }

    
    function setGame(uint256 gameId,uint256 price,uint256 numberPeople,uint256 poolCount,uint256 duration,uint256 gapTime) public isOwner{
        require(gameId > 0 && gameId <=_gameCount);
        _gameMap[gameId] = Game(price * 10 ** _usdtContract.decimals(),numberPeople,poolCount,duration,gapTime);
    }

    
    function share(uint256 gameId) public{
        uint256 roundId = getAwardedByGameId(gameId);
        (uint256 price,uint256 numberPeople,,,uint256 gapTime) = getGameRuleById(gameId);
        (uint256 thisNumber,,uint256 endTime,,bool isOver) = getRoundInfo(gameId);
        require(!isNewUser(msg.sender),"you is new user");
        
        if(roundId == 0 || isOver){
            
            require(now - endTime >= gapTime,"It's not time");
            startGame(msg.sender,gameId,price);
            
        } else if(thisNumber.add(1) >= numberPeople){
            require(!isShare(gameId,msg.sender),"is share over");
            putIn(msg.sender,price);
            addShareUser(gameId,roundId,msg.sender,price.sub(rewardCount(msg.sender,price)));
            drawPrize(gameId);
        } else {
            require(!isShare(gameId,msg.sender),"is share over");
            putIn(msg.sender,price);
            addShareUser(gameId,roundId,msg.sender,price.sub(rewardCount(msg.sender,price)));
        }
    }
    
    
    function drawPrizeTiming(uint256 gameId) public isOwner returns(bool){
        return drawPrize(gameId);
    }

    
    function drawPrize(uint256 gameId) internal returns(bool) {
        uint256 roundId = getAwardedByGameId(gameId);
        Session storage session = _sessionMap[roundId];
        require(!session.isOver,"The prize has been drawn");
        
        (uint256 poolCount,uint256 stackPoolCount,uint256 poolCountPart) = getGamePoolArgs(gameId,session.pool);
        
        Reward[] memory mediumUser = getMediumUser(roundId,stackPoolCount.add(poolCount));
        
        for(uint i = 0;i < mediumUser.length;i++){
            _usdtContract.transfer(mediumUser[i].account,mediumUser[i].amount);
            Access memory access = _accessMap[mediumUser[i].account];
            access.income = access.income.add(mediumUser[i].amount);
            _accessMap[mediumUser[i].account] = access;
        }
        
        Game storage game = _gameMap[gameId];
        
        game.poolCount = poolCount.sub(poolCountPart).add(session.pool.sub(stackPoolCount));
        session.endTime = now;
        session.pool = 0;
        session.isOver = true;
        _sessionMap[roundId] = session;
        emit DrawAPrize(roundId,mediumUser[0].account,mediumUser[0].amount,mediumUser[1].account,mediumUser[1].amount,mediumUser[2].account,mediumUser[2].amount,now);
    }

    
    function getGamePoolArgs(uint256 gameId,uint256 roundPool) internal view returns(uint256,uint256,uint256) {
        (,,uint256 poolCount,,) = getGameRuleById(gameId);
        uint256 stackPoolCount = calculateReward(roundPool,_poolFee);
        uint256 poolCountPart = calculateReward(poolCount,_takePool);
        return(poolCountPart,stackPoolCount,poolCountPart);
    }

    function getMediumUser(uint256 roundId,uint256 reward) internal view returns(Reward[] memory){
        address[] memory accounts = _roundUserMap[roundId];
        Reward[] memory mediumUser = new Reward[](3); 
        require(accounts.length > 0,"nft data not fount");
        uint256 no1 = getRandom(now,accounts.length);
        uint256 no2 = getRandom(uint256(block.difficulty),accounts.length);
        uint256 no3 = getRandom(uint256(uint160(block.coinbase)),accounts.length);
        uint256 no1Reward = calculateReward(reward,_no1Fee);
        uint256 no2Reward = calculateReward(reward,_no2Fee);
        uint256 no3Reward = reward.sub(no1Reward).sub(no2Reward);
        mediumUser[0] = Reward(accounts[no1],no1Reward);
        mediumUser[1] = Reward(accounts[no2],no2Reward);
        mediumUser[2] = Reward(accounts[no3],no3Reward);
        return mediumUser;
    }
    function getRandom(uint256 random,uint256 length) internal pure returns(uint256){
        return random % length;
    }
   
    
    function startGame(address account,uint256 gameId,uint256 price) internal returns(bool){
        
        putIn(account,price);
        
        _sessionMap[++_roundId] = Session(1,now,0,price.sub(rewardCount(account,price)),false);
        _awardedMap[gameId] = _roundId;
        
        address[] storage accounts = _roundUserMap[_roundId];
        accounts.push(account);
        _roundUserMap[_roundId] = accounts;
        emit Share(account,gameId,_roundId,price,now);
        
        emit StartNewGame(gameId,_roundId,account,now);
    }

    
    function putIn(address account,uint256 price) internal{
        
        Access storage access = _accessMap[account];
        access.putIn = access.putIn.add(price);
        _accessMap[account] = access;
        
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
        _usdtContract.transferFrom(account,address(this),price.sub(rewardAmount));
        emit SendRewards(account,rewards[0].account,rewards[0].amount,rewards[1].account,rewards[1].amount,now);
    }
    
    function getPushIncome(address account) public view returns(uint256){
        return _pushIncomeMap[account];
    }
    
    function getNodeIncome(address account) public view returns(uint256){
        return _nodeIncomeMap[account];
    }

    
    function rewardCount(address account,uint256 price) internal view returns(uint256){
        Reward[] memory rewards = getReward(account,price);
        if(rewards[0].account == address(0) && rewards[0].account == address(0)){
            return 0;
        }       
        return rewards[0].amount.add(rewards[1].amount);
    }

    
    function addShareUser(uint256 gameId,uint256 roundId,address account,uint256 price) internal {
        
        address[] storage accounts = _roundUserMap[roundId];
        accounts.push(account);
        _roundUserMap[roundId] = accounts;
        Session storage session = _sessionMap[roundId];
        session.thisNumber = session.thisNumber.add(1);
        session.pool = session.pool.add(price);
        emit Share(account,gameId,roundId,price,now);
    }

    
    function isShare(uint256 gameId,address account) public view returns(bool){
        uint256 roundId = getAwardedByGameId(gameId);
        address[] memory accounts = _roundUserMap[roundId];
        for(uint i = 0;i < accounts.length;i++){
            if(accounts[i] == account) return true;
        }
        return false;
    }

    
    function getRoundInfo(uint256 gameId) public view returns(uint256,uint256,uint256,uint256,bool){
        uint256 roundId = _awardedMap[gameId];
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
    
    function getPutInAndIncome(address account) public view returns(uint256,uint256){
        Access memory access = _accessMap[account];
        return(access.putIn,access.income);
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

    
    function getReward(address shareAccount,uint256 money) public view returns(Reward[] memory) {
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
    
    
    function getGameRuleById(uint256 gameId) public view returns(uint256,uint256,uint256,uint256,uint256){
        Game memory game = _gameMap[gameId];
        return(game.price,game.numberPeople,game.poolCount,game.duration,game.gapTime);
    }

    function setGameRule(uint256 gameId,uint256 numberPeople,uint256 price,uint256 duration,uint256 gapTime) external isOwner{
        Game storage game = _gameMap[gameId];
        game.numberPeople = numberPeople;
        uint256 decimals =_usdtContract.decimals();
        game.price = price * 10 ** decimals;
        game.duration = duration;
        game.gapTime = gapTime; 
        _gameMap[gameId] = game;
    }
    
    function nextStartCountDown(uint256 gameId) public view returns(uint256){
        uint256 roundId = getAwardedByGameId(gameId);
        Session memory session = _sessionMap[roundId];
        if(!session.isOver){
            return 0;
        }
        (,,,,uint256 gapTime) = getGameRuleById(gameId);
        uint256 second = (session.endTime + gapTime) - now;
        if(second < 0 ){
            return 0; 
        }
        return second;
    }
}