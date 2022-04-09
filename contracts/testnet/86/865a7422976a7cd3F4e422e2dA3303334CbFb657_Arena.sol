// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IPancakeRouter01.sol";
// import "./IERC20.sol";
import "./NFT.sol";
import "./Game.sol";
import "./BADHero.sol";
contract Arena is Ownable{
    constructor() {
        initArRewardSet();
        arenaOpneTime = block.timestamp + weekCyle;
        weekOpneTime = block.timestamp + weekCyle;
    }

    nftKind[] public _nftKinds;
    // uint256 arenaPool;
    uint256 public arenaPool = 0; // 总的竞技池
    uint256 public arenaNumb; // 竞技的期数
    uint256 public arenaOpneTime ; // 竞技的结束时间
    uint256 public weekOpneTime ; // 周任务的结束时间
    // uint256 public weekCyle =  7*86400; // 周期时间
    uint256 public weekCyle =  600; // 周期时间
    mapping(uint256=>uint256) _tokenIdType; // tokenId对应的属性
    mapping(uint256=>arenaInfo) _arenaInfo; // 每期竞技场设置参数
    mapping(uint256=>tokenArena[]) public tokenSortArenas;  // 每期前15名
    arenaSet _arenaSet = arenaSet(7,100*10**18,15); // 竞技场设置
    IERC20 public erc20 = IERC20(0x0a2231B33152d059454FF43F616E4434Afb6Cc64);
    Game public _game;
    BADHero public _badhero;
    mapping(uint256=>address[]) _weekFightUsers;
    mapping(uint256=>tokenArena[]) _tokenArenas;
    arRewardSet[] public _arRewardSet;
    weekFighting _weekFighting = weekFighting(0,5,100,10);  //周任务属性设置
    mapping(uint256=>weekLottery) public wkLottory;
    mapping(uint256=>mapping(uint256=>RinKInfo)) public rinkInfo;
  
    uint256 public weekRound=0; //周奖期数

    event JoinArena(uint256 indexed tokenId,uint256 indexed nper,uint256 indexed wins,address sender);
    event DisCompetitiveReward(uint256 indexed arenaNumb,uint256 indexed rink,uint256 tokenId,address sender,uint256 reward);
    event DisArenaReward(uint256 indexed arenaNumb,uint256 indexed rink,uint256 tokenId,address sender,uint256 reward);
    event DoWeekTask(uint256 indexed weekRound,address sender);
    event OpenWeekTask(uint256 indexed weekRound,uint256 startTime);

    // 周战斗任务
    struct weekFighting{
        uint256 round; // 参与轮数
        uint256 successRate; // 用户的成功率加成
        uint256 parame;  // 设置的参数
        uint256 parameRate;  // 参数增长值
    }
     struct nftKind{
        uint32 start;
        uint32 end;
        uint64 atRate;
        string ranking;
        string rankingName;
        string url;
    }

    struct arenaInfo{
        uint256 cycle; // 周期时间 
        uint256 price; // 参与价格
        uint256 createTime; // 开始时间
        uint256 endTime; // 结束时间
    }

    struct tokenArena{
        uint256 tokenId; 
        uint256 wins; // 用户胜利的场数
        address sender; // 参与的用户
    }
    
    struct arenaSet{
        uint256 cycle; // 周期时间 
        uint256 price; // 参与价格
        uint256 scNum; // 获奖人数
    }
    struct arRewardSet{
        uint256 rewards; // 奖励占比
        uint256 start; // 开始索引
        uint256 end; // 结束索引
    }
    // 开奖记录
    struct weekLottery{
        uint256 round; // 参与轮数
        uint256 rate; // 成功几率
        bool success; // 用户是否成功
        uint256 openTime;// 开奖时间
    }
    struct RinKInfo{
        uint256 rink; // 排名
        uint256 tokenId;
        uint256 reward; 
        address  win;
        bool isOk; //是否计算已经结算了
        bool isIssue; // 是否已经发放奖励了
    }
    // 竞技场
    function athletics(uint256 tokenId)  public isUser(tokenId) returns(uint256){
        require(arenaOpneTime>=block.timestamp,"This issue is over, please wait for the next issue");
        // 来3次随机数来求值
        uint256 wins = getSucNum(_badhero.getNftKind(_game.getTokenDetails(tokenId).nftKindId).atRate);
        arenaPool += _arenaSet.price;
        erc20.transferFrom(msg.sender, address(this),_arenaSet.price);
        _tokenArenas[arenaNumb].push(tokenArena(tokenId,wins,msg.sender));
        // sort(tokenId,wins,msg.sender);
        emit JoinArena(tokenId,arenaNumb, wins, msg.sender);
        return wins;
    }

    function rand(uint256 _length) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random%_length+1;
    }
    // 获取胜利场数
    function getSucNum(uint256 baseNum) view internal returns(uint256){
        uint256 roundOne = rand(20);
        uint256 roundTow = rand(20);
        uint256 roundTree = rand(20);
        uint256 stateNum = baseNum-10;
        uint256 avg  = (roundOne + roundTow + roundTree)/3;
        return stateNum+avg;
    }
    modifier isUser(uint256 tokenId){
       require(_game.getUserAddress(tokenId)==msg.sender,"Have no legal power");
        _;
    }
    // 做周任务
    function doWeeklyTasks() public{
        require(isJoinWkTask(weekRound,msg.sender) == false,"Have attended");
        require(weekOpneTime>=block.timestamp,"The assignment for this week is over");
        _weekFightUsers[weekRound].push(msg.sender);
        emit  DoWeekTask(weekRound,msg.sender);
    }

    function isJoinWkTask(uint256 wkRound,address sender) view public returns(bool){
       address[] memory addrs =  _weekFightUsers[wkRound];
       bool isJoin;
       for (uint256 i = 0; i < addrs.length; i++) {
           if(addrs[i] == sender){
               isJoin = true;
               break;
           }
       }
       return isJoin;
    }

    //获取本周期数
    function getWeekRound() public view returns(uint256){
        return weekRound;
    }

     function initArRewardSet() public onlyOwner{
        _arRewardSet.push(arRewardSet(30,0,1));
        _arRewardSet.push(arRewardSet(17,1,2));
        _arRewardSet.push(arRewardSet(10,2,3));
        _arRewardSet.push(arRewardSet(4,3,10));
        _arRewardSet.push(arRewardSet(3,10,15));
    }
    // 结算周任务，并且开启下一轮
    function openWeeklyTasks() public onlyOwner{
        uint256 joins = _weekFightUsers[weekRound].length;
        bool isSuccess = false;
        // weekLottery memory oldWkLottery = wkLottory[weekRound-1];
        require(weekOpneTime<block.timestamp, "open Week lottery Time is not");
        if(_weekFighting.parame<=joins){
            _weekFighting.parame += _weekFighting.parame*_weekFighting.parameRate/100;
            isSuccess = true;
        }else{
            _weekFighting.parame -= _weekFighting.parame*_weekFighting.parameRate/100;
        }
        wkLottory[weekRound] = weekLottery(weekRound,_weekFighting.successRate,isSuccess,block.timestamp);
        weekRound +=1;
        weekOpneTime = block.timestamp+weekCyle;
        emit OpenWeekTask(weekRound,weekOpneTime);
    }
    // 竞技任务排行榜
    function getSortArenas() view public returns(tokenArena[] memory){
        return tokenSortArenas[arenaNumb];
    }
    // 发放竞技奖励
    function disCompetitiveReward(uint256 _arenaNumb,uint256 ranking,address sender,uint256 tokenId,uint256 reward)public onlyOwner{
        require(rinkInfo[_arenaNumb][ranking].isOk ==false,"The rewards have already been handed out");
        rinkInfo[_arenaNumb][ranking].rink = ranking;
        rinkInfo[_arenaNumb][ranking].win = sender;
        rinkInfo[_arenaNumb][ranking].reward = reward;
        rinkInfo[_arenaNumb][ranking].tokenId = tokenId;
        rinkInfo[_arenaNumb][ranking].isOk = true;
        emit DisCompetitiveReward(_arenaNumb,ranking,tokenId,sender,reward);
    }

    function upArenaTime() public onlyOwner{
        require(arenaOpneTime<block.timestamp, "open Week lottery Time is not");
        for(uint256 i=0;i<15;i++){
            if(rinkInfo[arenaNumb][i].isOk && rinkInfo[arenaNumb][i].isIssue==false){
               _game.DisReward(rinkInfo[arenaNumb][i].win,rinkInfo[arenaNumb][i].reward);
               arenaPool = arenaPool - rinkInfo[arenaNumb][i].reward;
                rinkInfo[arenaNumb][i].isIssue = true;
               emit DisArenaReward(arenaNumb,i+1,rinkInfo[arenaNumb][i].tokenId,rinkInfo[arenaNumb][i].win,rinkInfo[arenaNumb][i].reward);
            }
        }
        arenaOpneTime = block.timestamp+weekCyle;
        arenaNumb = arenaNumb+1;
    }

    function getArenaPool() public view returns(uint256) {
        return arenaPool;
    }
    function getRangk(uint256 _arenaNumb,uint256 ranking) public view returns(RinKInfo memory){
        return rinkInfo[_arenaNumb][ranking];
    }
    function setGame(address payable _gameAddress) public onlyOwner{
        _game = Game(_gameAddress);
    }

    function setErc20(address _erc20Address) public onlyOwner{
        erc20 = IERC20(_erc20Address);
    }
    function setBadHero(address _badAddress) public onlyOwner{
        _badhero = BADHero(_badAddress);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPancakeSwapRouter {   
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// import "./UserLib.sol";

contract NFT is ERC721, AccessControl {
    using Counters for Counters.Counter;
    // using UserLib for UserLib.CardDetails;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NFT", "BADH") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
    function setRole(address addr) public onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(MINTER_ROLE,addr);
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) returns(uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./GetFee.sol";
import "./Monster.sol";
contract Game is AccessControl,Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        pushTask();
        }
    
    GetFee public getFeeRate;
    
    IERC20 public erc20;
    Monster public _monster;
    

    mapping(address=>EnumerableSet.UintSet) _userTem;//队伍卡片
    mapping(address=>EnumerableSet.UintSet) _userBackpack;//背包卡片
    gameInfo private _gameInfo = gameInfo(12*3600,5,10*10**18,100,10,25,2000*10**18);
    mapping(uint256=>address) _tokenUser;
    mapping(uint256=>CardDetails) _tokenDetail;
    mapping(uint256=>mapping(uint256=>uint256)) _tokenLevel; // toeknId/等级
    uint256 basicHp = 200*10**8;
    // uint256 _unlockTime = 86400;
    uint256 _unlockTime = 600;

    uint32 public enemyNum = 0;

    mapping(address=>rewardPool[]) public _userRewardPools;  // 用户胜利的奖励未领取

    mapping(address=>rewardPool) public userBnbPool;
    mapping(address=>rewardPool) public userBadPool;
    uint256 public badPool; // bad奖金池
    uint256 public bnbPool; // bnb奖金池


    enemyInfo[] public specialTask;
    receiveInfo _receiveInfo = receiveInfo(2*_unlockTime,3,7);

    event SpeedTraining(uint256 indexed tokenId,address indexed sender,uint256 needFee);
    event MoveCard(uint256 indexed tokenId,address indexed sender,uint256 mvType);
    event UpMonster(uint256 indexed tokenId,uint256 indexed level,uint256 amount,address sender);
    event Fighting(bool isSuccess,uint256 indexed fightType,uint256 indexed sHp,uint256  addXp,uint256 indexed reward,uint256 tokenId,address sender);
    event DrawReward(uint256 indexed rewardType,uint256 indexed reward,uint256 rate,address sender);
    event MoveBack(uint256 indexed tokenId,address indexed sender,uint256 mvType);
    event Withdrawal(uint256 indexed amount,address indexed sender);

    struct tokenEarnings{
            uint256 level; // 当前等级
            uint256 income; // 当前等级对应的收益
        }

    struct CardDetails{
        uint32 genre;
        uint256 tokenId;
        uint256 hp;
        uint256 level;
        uint256 xp;//经验值
        uint256 ce;//战斗力
        uint256 armor;//防御力
        uint256 luk;//幸运值
        uint256 unLockTime;//解锁时间
        uint256 rgTime;
        uint256 nftKindId; // 怪物类型id
        string name; // 怪物名字
    }
    // struct nftKind{
    //     uint32 start;
    //     uint32 end;
    //     uint64 atRate;
    //     string ranking;
    //     string rankingName;
    //     string url;
    // }
    
    // 游戏详情
    struct gameInfo{
        uint32 enlistTime; // 游戏卡片解锁时间
        uint32 temNum;      // 队伍上限数量
        uint256 speedMoney;      // 加速招募金额
        uint256 maxLevel;      // 怪物上限等级
        uint256 addAttr;      // 怪物每升级增加的属性
        uint256 upAttrCost;      // 升级怪物费用
        uint256 upEqCost;      // 升级装备费用
    }
    
    //敌人属性
    struct enemyInfo{
        uint32 id;
        uint256 odds;
        uint256 basicReward;
        uint256 basicXp;
        uint256 basicHp;
        string  name;
        string  pic;
    }

    // // 待领取的奖励池
    // struct rewardPool{
    //     uint32 id; // 1 bnb奖励2 BAD
    //     uint32 rewardType; // 奖励类型 1 战斗，2特殊任务，3竞技场
    //     uint256 tokenId;
    //     uint256 reward;
    //     uint256 addTime;
    //     uint256 unLockTime;
    // }

    // 待领取的奖励池
    struct rewardPool{
        uint256 reward; // 待领取的奖励
        uint256 validTime; // 可以领取时间
        uint256 unLockTime;  // 领取不需要手续费时间
        bool isVaild;  //是否存在
    }

    // 奖励设置参数
    struct receiveInfo{
        uint256 lockTime; // 锁定时间
        uint256 fee;    // 每天费用
        uint256 freeDay; // 多天后领取免费
    }

    struct FightingEndInfo{
        bool suc;
        uint32 fgType;
        uint256 reward;
        uint256 hp;
        uint256 xp;
        uint256 unLkTime;
   }


    function rand(uint256 _length) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random%_length;
    }
 

    // 生成卡片信息
    function createCard(uint256 tokenId,uint256 ce,uint256 armor,uint256 luk,uint256 unLockTime,uint256 nftKindId,string memory name,uint256 maxNum,address _userAddress) public onlyRole(MINTER_ROLE) returns(uint256){
        //初始化卡片信息
        CardDetails memory _carDetails = CardDetails(0,tokenId,basicHp,1,0,ce,armor,luk,block.timestamp+unLockTime,0,nftKindId,name);
        
        if(_userTem[_userAddress].length()<maxNum){
            _userTem[_userAddress].add(tokenId);
        }else{
            _userBackpack[_userAddress].add(tokenId);
        }
        _tokenUser[tokenId] = _userAddress;
        _tokenDetail[tokenId] = _carDetails;

        return tokenId;
    }

    // 加速训练
    function adRecruit(uint256 tokenId)  public{
        require(_tokenUser[tokenId]==msg.sender,"Have no legal power");
        CardDetails storage _carDetail = _tokenDetail[tokenId] ;
        uint256 needFee = 0;
        require(_carDetail.unLockTime > block.timestamp,"No need to accelerate");
        uint256 needTime = _carDetail.unLockTime - block.timestamp ;
        needFee = speedFee(needTime);
        erc20.transferFrom(msg.sender, address(this), needFee);
        _tokenDetail[tokenId].unLockTime = 0;
        emit SpeedTraining(tokenId,msg.sender,needFee);
    }

    // 移动去背包
    function moveToBack(uint256 tokenId) public {
        require(_tokenUser[tokenId]==msg.sender,"Have no legal power");
        require(_userTem[msg.sender].contains(tokenId) == true, "It's already decompressed");
        _userBackpack[msg.sender].add(tokenId);
        _userTem[msg.sender].remove(tokenId);
        
        emit MoveCard(tokenId,msg.sender,1);
    }

    // 移动背包卡片去队伍
    function moveToTem(uint256 tokenId) public {
        require(_tokenUser[tokenId]==msg.sender,"Have no legal power");
        require(_userBackpack[msg.sender].contains(tokenId) == true, "It's already decompressed");
        _userTem[msg.sender].add(tokenId);
        _userBackpack[msg.sender].remove(tokenId);
        emit MoveCard(tokenId,msg.sender,2);
    }
    
    // 上架移除背包
    function moveBack(uint256 tokenId,address sender) public onlyRole(MINTER_ROLE){
        require(_tokenUser[tokenId]==sender,"Have no legal power");
        require(_userBackpack[sender].contains(tokenId) == true, "It's already decompressed");
        _userBackpack[sender].remove(tokenId);
        emit MoveBack(tokenId,sender,1);
    }

    // 下架移动到背包
    function addBack(uint256 tokenId,address sender) public onlyRole(MINTER_ROLE){
        require(_tokenUser[tokenId]==sender,"Have no legal power");
        require(_userBackpack[sender].contains(tokenId) == false, "It's already decompressed");
        _userBackpack[sender].add(tokenId);
        emit MoveBack(tokenId,sender,2);
    }
   
    function setRouterAddress(address _feeAddress) public onlyOwner{
        getFeeRate = GetFee(_feeAddress);
    }

    function setErc20(address addr) public onlyOwner{
        erc20 = IERC20(addr);
    }
    function setMonster(address addr) public onlyOwner{
        _monster = Monster(addr);
    }
    function setRole(address upAddress)public onlyOwner{
        _grantRole(MINTER_ROLE, upAddress);
    }
    
    // 计算待加速所需费用
    function speedFee(uint256 remainTime) view public returns(uint256){
        if (remainTime<=0){
            return 0;
        }
        uint256 amounts = getFeeRate.getUsdtPrice1(_gameInfo.speedMoney);
        uint256 const = remainTime*(amounts/_gameInfo.enlistTime);
        return const;
    }
  
    //累计奖励 
    function addUpReward(address user,uint256 reward,uint256 addType) internal{
        if(addType==1){
            if(userBnbPool[user].isVaild){
                if(userBnbPool[user].reward ==0){
                    userBnbPool[user].validTime =  block.timestamp+_receiveInfo.lockTime;
                    userBnbPool[user].unLockTime = block.timestamp+_receiveInfo.lockTime+_receiveInfo.freeDay*_unlockTime;
                }
            }else{
                userBnbPool[user].validTime =  block.timestamp+_receiveInfo.lockTime;
                userBnbPool[user].unLockTime = block.timestamp+_receiveInfo.lockTime+_receiveInfo.freeDay*_unlockTime;
                userBnbPool[user].isVaild=true;
            }
            userBnbPool[user].reward = userBnbPool[user].reward+reward;
        }else{
            if(userBadPool[user].isVaild){
                if(userBadPool[user].reward ==0){
                    userBadPool[user].validTime =  block.timestamp+_receiveInfo.lockTime;
                    userBadPool[user].unLockTime = block.timestamp+_receiveInfo.lockTime+_receiveInfo.freeDay*_unlockTime;
                }
            }else{
                userBadPool[user].validTime =  block.timestamp+_receiveInfo.lockTime;
                userBadPool[user].unLockTime = block.timestamp+_receiveInfo.lockTime+_receiveInfo.freeDay*_unlockTime;
                userBadPool[user].isVaild=true;
            }
            userBadPool[user].reward = userBadPool[user].reward+reward;
            // badPool = badPool-reward;
        }
    }

    function addBadReward(address user,uint256 reward) public onlyRole(MINTER_ROLE){
       addUpReward(user,reward,2);
    }
  
  
    function fighting(uint256 tokenId,uint256 enemyId) public isUnlock(tokenId) isteam(tokenId,msg.sender) returns(FightingEndInfo memory fig){
        // FightingEndInfo memory fig;
        (fig.suc,fig.reward,fig.hp,fig.xp,fig.unLkTime) = _monster.fighting(tokenId,enemyId,msg.sender);
        // CardDetails storage crdDt = _tokenDetail[tokenId];
        if(fig.suc == true){
            addUpReward(msg.sender,fig.reward,1);
            _tokenLevel[tokenId][_tokenDetail[tokenId].level] +=fig.reward;
            _tokenDetail[tokenId].hp =  fig.hp;
            uint256 totalXp = _tokenDetail[tokenId].xp + fig.xp ;
            uint256 limitXp = _tokenDetail[tokenId].level*100-1;
            if (totalXp>limitXp){
                _tokenDetail[tokenId].xp = limitXp;
            }else{
                _tokenDetail[tokenId].xp += fig.xp;
            }
            
            _tokenDetail[tokenId].rgTime = fig.unLkTime;
        }else{
            _tokenDetail[tokenId].hp = 0;
            _tokenDetail[tokenId].rgTime = block.timestamp + _unlockTime;
        }
        fig.fgType = 1;
        emit Fighting(fig.suc,1,fig.hp,fig.xp,fig.reward,tokenId,msg.sender);

        return fig;
        
    }
    // 做任务
    function DoTask(uint256 tokenId,uint256 enemyId) public isUnlock(tokenId) isteam(tokenId,msg.sender) returns(FightingEndInfo memory fig) {
        enemyInfo memory _task =getTaskById(enemyId);
        (fig.suc,fig.reward,fig.hp, fig.unLkTime) = _monster.DoTask(tokenId,_task.odds,_task.basicReward,msg.sender);
        if(fig.suc == true){
            addUpReward(msg.sender,fig.reward,2);
            _tokenDetail[tokenId].hp = fig.hp;
            _tokenDetail[tokenId].rgTime = fig.unLkTime;
        }else{
            _tokenDetail[tokenId].hp = 0;
            _tokenDetail[tokenId].rgTime = block.timestamp + _unlockTime;
        }
        fig.fgType = 2;
        emit Fighting(fig.suc,2,fig.hp,0,fig.reward,tokenId,msg.sender);
        return fig;
    }

    // 发放竞技奖励
    function DisReward(address rewardAddr,uint256 reward) public onlyRole(MINTER_ROLE) {
            addUpReward(rewardAddr,reward,2);
    }

    //升级怪物等级
    function upLevel(uint256 _tokenId) public{
        require(_tokenUser[_tokenId]==msg.sender,"Have no legal power");
        require(_tokenDetail[_tokenId].level < _gameInfo.maxLevel,"_gameInfo.maxLevel");
        uint256 needXp = _tokenDetail[_tokenId].level *_gameInfo.maxLevel -1;
        require(_tokenDetail[_tokenId].xp >= needXp,"xp is lack");
        uint256 amount ;
        amount = getUpConst(_tokenId);
        erc20.transferFrom(msg.sender, address(this), amount);
        _tokenDetail[_tokenId].xp = 0;
        _tokenDetail[_tokenId].level = _tokenDetail[_tokenId].level+1;
        _tokenDetail[_tokenId].ce += _gameInfo.addAttr;
        _tokenDetail[_tokenId].armor += _gameInfo.addAttr;
        _tokenDetail[_tokenId].luk += _gameInfo.addAttr;
        emit UpMonster(_tokenId,_tokenDetail[_tokenId].level,amount,msg.sender);
    }

    // 领取奖励
    function drawReward(uint256 index) public returns(bool){
        uint256 rateFee ;
        uint256 rallReward;
        bool success;
        //判断领取币种
        if(index==1){
            require(userBnbPool[msg.sender].validTime < block.timestamp,"The unlock time is not reached");
            if(userBnbPool[msg.sender].unLockTime<=block.timestamp){
                rallReward = userBnbPool[msg.sender].reward;
            }else{
                rateFee = getFee(userBnbPool[msg.sender].unLockTime-block.timestamp);
                rallReward = userBnbPool[msg.sender].reward - userBnbPool[msg.sender].reward*rateFee/100;
            }
            require(bnbPool>=rallReward,"Insufficient contract balance");
            userBnbPool[msg.sender].reward = 0;
            // payable(msg.sender).transfer(rallReward);
            (success, ) = msg.sender.call{value: rallReward}(new bytes(0));
            bnbPool = bnbPool-rallReward;
        }else if(index==2){
            require(userBadPool[msg.sender].validTime < block.timestamp,"The unlock time is not reached");
            if(userBadPool[msg.sender].unLockTime<=block.timestamp){
                rallReward = userBadPool[msg.sender].reward;
            }else{
                rateFee = getFee(userBadPool[msg.sender].unLockTime-block.timestamp);
                rallReward = userBadPool[msg.sender].reward - userBadPool[msg.sender].reward*rateFee/100;
            }
            userBadPool[msg.sender].reward =0;
            erc20.transferFrom(address(this), msg.sender, rallReward);
        }
        
        emit DrawReward(index,rallReward,rateFee,msg.sender);
        return success;
    }

    // 计算领取所需手续费
    function getFee(uint256 difTime) view public returns(uint256){
        if(difTime == 0){
            return 0;
        }
        // uint256 diffTime = overTime - block.timestamp;
        uint256 needDay = difTime/_unlockTime;
        if (needDay*_unlockTime<difTime){
            needDay +=1;
        }
        return needDay *_receiveInfo.fee;
    }

    //获取任务信息
    function getTaskById(uint256 enemyId) view  public returns(enemyInfo memory){
        enemyInfo memory task ;
        for (uint256 i = 0; i < specialTask.length; i++) {
            if(specialTask[i].id == enemyId){
                task =  specialTask[i];
            }
        }
        return task;
    }

    //获取任务列表
    function getTasks() view  public returns(enemyInfo[] memory tasks){
        for (uint256 i = 0; i < specialTask.length; i++) {
            tasks[i]=specialTask[i];
        }
        return tasks;
    }

    modifier isteam(uint256 tokenId,address sender){
        require(_userTem[sender].contains(tokenId) == true, "It's not no team");
        _;
    }

    function isBack(uint256 tokenId,address sender) public view returns(bool) {
        require(_userBackpack[sender].contains(tokenId) == true, "It's not to back");
        return true;
    }

    modifier isUnlock(uint256 tokenId){
       CardDetails memory cards = _tokenDetail[tokenId];
        require(cards.unLockTime<block.timestamp,"unLock time");
        _;
    }
 
    //specialTask
    // 特殊任务
    function addTask(uint256 odds,uint256 reward,uint256 xp,uint256 hp,string memory name,string memory pic) public onlyOwner{
        specialTask.push(enemyInfo(enemyNum,odds,reward,xp,hp,name,pic));
        enemyNum +=1;
    }
    function pushTask() internal{
        addTask(18,1*10**17,0,20*10**8,"zcdq","");
        addTask(10,2*10**17,0,20*10**8,"gdrz","");
    }

    function getSpecialTask() public view returns(enemyInfo[] memory){
        return specialTask;
    }
    
    // 获取当前等级升级所需费用
    function getUpConst(uint256 tokenId) public view returns(uint256){
         // 获取当前等级收益的25%进行解锁 
        uint256 reward = _tokenLevel[tokenId][_tokenDetail[tokenId].level];
        if (reward<=0){
            return 0;
        }
        uint256 incomeByToken = getFeeRate.getBNBPrice1(reward);
        uint256 amount ;
        amount = incomeByToken * _gameInfo.upAttrCost /100;
        return amount;
    }

    // 获取当前等级奖励
    function getRewardByLevel(uint256 tokenId) public view returns(uint256){
       return _tokenLevel[tokenId][_tokenDetail[tokenId].level];
    }

    function getTokenDetail(uint256 tokenId) view public returns(uint256 level,uint256 ce,uint256 xp,uint256 armor,uint256 luk,uint256 rgTime){
        return (_tokenDetail[tokenId].level,_tokenDetail[tokenId].ce,_tokenDetail[tokenId].xp,_tokenDetail[tokenId].armor,_tokenDetail[tokenId].luk,_tokenDetail[tokenId].rgTime);
    }
    function getTokenDetails(uint256 tokenId) view public returns(CardDetails memory){
        return _tokenDetail[tokenId];
    }

    // function setTokenDetail(uint256 tokenId,uint32 genre)  public onlyRole(MINTER_ROLE) {
    function setTokenDetailGenre(uint256 tokenId,uint32 genre)  public onlyRole(MINTER_ROLE) {
        _tokenDetail[tokenId].genre = genre;
    }

    function getTokenDetailGenre(uint256 tokenId) view  public returns(uint256) {
        return   _tokenDetail[tokenId].genre;
    }

    function getUserAddress(uint256 tokenId) view public returns(address){
        return _tokenUser[tokenId];
    }

    // 修改卡片信息归属
    function editCardDetails(uint256 tokenId,address addr)  public onlyRole(MINTER_ROLE) {
        _tokenUser[tokenId] = addr;
    }
    
    function getUserTesmCards(address sender) view public returns(uint256[]  memory){
        return _userTem[sender].values();
    }

    function getUserBkCards(address sender) view public returns(uint256[]  memory){
        return _userBackpack[sender].values();
    }
    // function rechargeBad(uint256 amount)  public{
    //     require(erc20.balanceOf(msg.sender)>=amount,"ERCO20: Balance not enough");
    //     badPool += amount;
    //     erc20.transfer(address(this), amount);
    // }

    receive() external payable { 
    	bnbPool += msg.value;
	}

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function rechargeBnb() payable public{
        bnbPool += msg.value;
        payable(msg.sender).transfer(msg.value);
    }

    //提现
     function withdrawal(address addr,uint256 amount) public onlyOwner returns(bool){
        bnbPool = bnbPool - amount;
        (bool success, ) = addr.call{value: amount}(new bytes(0));
        emit Withdrawal(amount,addr);
        return success;
    }

    function withdrawalToken(address addr,uint256 amount) public onlyOwner {
        erc20.transfer(addr, amount);
        emit Withdrawal(amount,addr);
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./IERC20.sol";
import "./NFT.sol";
import "./Game.sol";

contract BADHero is Ownable{
    constructor() {
        initStart();
    }
    
    IERC20 public erc20;
    
    uint256 _upEqCost = 1000*10**18;      // 升级装备费用
    mapping(address=>heroAttribute[]) _userHero; // 英雄装备属性
    mapping(uint64=>monsterInfo[]) _monsters;
    mapping(uint256=> nftKind) _nftKinds;
    mapping(uint32=>eqAttribute[]) _equipment; // 装备和等级
    mapping(uint32=>string) _equipmentInfo; // 装备id=>名称

    Game  public  _game;
    // 英雄装备属性
    struct heroAttribute{
        uint32 eqType;//装备类型
        uint32 level;// 装备等级
        uint256 bonus;// 装备加成
    }
    struct monsterInfo{
        uint256 rarity;//怪物类型
        uint256 ce;//战斗力
        uint256 armor;//防御力
        uint256 luk;//幸运值
        string name; // 怪物名字
    }
    struct nftKind{
        uint32 start;
        uint32 end;
        uint64 atRate;
        string ranking;
        string rankingName;
        string url;
    }
     // 怪物属性
    struct eqAttribute{
        uint32 level;//等级
        uint32 reward;// 奖励
    }

    
    //卡片详情
    // genre 类型 0 初始状态1质押，2上架
    struct cardDetails{
        uint32 genre;
        uint256 tokenId;
        uint256 hp;
        uint256 level;
        uint256 xp;//经验值
        uint256 ce;//战斗力
        uint256 armor;//防御力
        uint256 luk;//幸运值
        uint256 unLockTime;//解锁时间
        uint256 rgTime;
        uint256 nftKindId; // 怪物类型id
        string name; // 怪物名字
    }

    // 监听事件
    event UpHeroEq(uint256 indexed eqType,uint256 indexed level,uint256 amount,address sender);
    event Withdrawal(uint256 indexed amount,address indexed sender);
    
    //升级装备
    function upEquipment(uint32 _eqType) public{
        heroAttribute[] storage heroEqs =  _userHero[msg.sender];
        uint256 level ;
        for (uint256 index = 0; index < heroEqs.length; index++) {
            if(heroEqs[index].eqType == _eqType){
                level = heroEqs[index].level +1;
                require(level<=3,"Level cap");
                heroEqs[index].level = uint32(level);
                heroEqs[index].bonus = getBonus(uint32(index),level);
                erc20.transferFrom(msg.sender, address(this), _upEqCost);
                break;
            }
        }
        emit UpHeroEq(_eqType,level,_upEqCost,msg.sender);
    }
     function getBonus(uint32 index,uint256 level) view public returns(uint256){
        eqAttribute[] memory attr = _equipment[index];
        uint256 reward;
        for (uint256 i = 0; i < attr.length; i++) {
            if(attr[i].level==level){
                reward = attr[i].reward;
                break;
            }
        }
        return reward;
    }
    function initStart()public {
        initEq();
        _setNftKind();
        _setMonsterInfo();
    }
     // 初始化装备
    function initEq() internal{
        uint256[6] memory reward= [uint256(1),3,10,10,10,10]; 
        for(uint32 j=0;j<=5;j++){
            for (uint32 i=0;i<=3;i++){
                uint256 rw = reward[j] * i;
                _equipment[j].push(eqAttribute(i,uint32(rw)));
            }
        }
        _equipmentInfo[0] = "Cornucopia";
        _equipmentInfo[1] = "Life Fountain";
        _equipmentInfo[2] = "Wisdom literature";
        _equipmentInfo[3] = "Demon Sword";
        _equipmentInfo[4] = "Warrior Armor";
        _equipmentInfo[5] = "angel bless";
    }
     // 根据类型随机生成卡片属性
    function randNftByType(uint32 _index) view internal returns(monsterInfo memory,uint64 _length){
        monsterInfo[] memory _monsterInfo = _monsters[_index];
        _length =uint64(rand(_monsterInfo.length));
        monsterInfo memory _monster = _monsterInfo[_length];
        return (_monster,_length);
    }
    function rand(uint256 _length) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return (random%_length);
    }
 // 设置怪物NFT属性
    function _setNftKind() internal  {
        _nftKinds[0] = nftKind(49,100,70,"N","Normal","");
        _nftKinds[1] = nftKind(19,49,75,"R","Rare","");
        _nftKinds[2] = nftKind(5,19,80,"SR","Super Rare","");
        _nftKinds[3] = nftKind(1,5,85,"SSR","Super Super Rare","");
        _nftKinds[4] = nftKind(0,1,90,"UR","Ultra Rare","");
        
    }

    function _setMonsterInfo()  internal{
        //每类卡片的不同种类
        _monsters[0].push(monsterInfo(0,150,150,150,"Geryon"));
        _monsters[0].push(monsterInfo(0,50,200,200,"Agrius"));
        _monsters[0].push(monsterInfo(0,300,50,100,"Grindylow"));
        _monsters[0].push(monsterInfo(0,100,50,300,"Harpy"));
        _monsters[0].push(monsterInfo(0,50,350,50,"Alistar"));

        _monsters[1].push(monsterInfo(1,250,200,200,"Conqueror"));
        _monsters[1].push(monsterInfo(1,200,250,200,"Alterac"));
        _monsters[1].push(monsterInfo(1,200,200,250,"Shyvana"));
        _monsters[1].push(monsterInfo(1,0,0,650,"Okypete"));

        _monsters[2].push(monsterInfo(2,600,100,100,"Charybdis"));
        _monsters[2].push(monsterInfo(2,300,250,250,"Fenris"));
        _monsters[2].push(monsterInfo(2,250,350,200,"Kargath"));

        _monsters[3].push(monsterInfo(3,550,350,150,"Zuluhed"));
        _monsters[3].push(monsterInfo(3,350,200,500,"Kassadin"));
        _monsters[4].push(monsterInfo(4,550,350,400,"Vladimir"));
    }
    
    //初始化英雄属性
    function initHeroEq(address _addr) public{
        if(_userHero[_addr].length == 0){
            _userHero[_addr].push(heroAttribute(0,0,0)) ;
            _userHero[_addr].push(heroAttribute(1,0,0)) ;
            _userHero[_addr].push(heroAttribute(2,0,0)) ;
            _userHero[_addr].push(heroAttribute(3,0,0)) ;
            _userHero[_addr].push(heroAttribute(4,0,0)) ;
            _userHero[_addr].push(heroAttribute(5,0,0)) ;
        }
    }
    

    // 获取
    function getMonsterInfo(uint64 _index) view public returns(monsterInfo[] memory){
        return _monsters[_index];
    }
    
    function getNftKind(uint256 index) view public returns(nftKind memory){
        return _nftKinds[index];
    }

    function getMonsterType() view public returns(uint256 ,uint256,uint256,uint256,uint256,string memory){
        uint256 num = 5;
        uint256 nftKindId;
        uint256 monsterId;
        uint256 random=rand(100);
        monsterInfo memory _monster ;
        for (uint256 i=0;i<num;i++){
            if (_nftKinds[i].start <=random && random < _nftKinds[i].end){
                nftKindId = i;
               (_monster,monsterId )= randNftByType(uint32(i));
                break;
            }
        }
        return (nftKindId,monsterId,_monster.ce,_monster.armor,_monster.luk,_monster.name);
    }
    
    // modifier isUser(uint256 tokenId){
    //    require(_game.getUserAddress(tokenId)!=msg.sender,"Have no legal power");
    //     _;
    // }
   

    // 获取英雄装备信息
    function getHeroEq(address _addr) public view  returns(heroAttribute[] memory){
        // if (_userHero[_addr].length == 0){
        //     initHeroEq(_addr);
        // }
        return _userHero[_addr];
    }
    struct combatOdds{
        uint256 addReward;
        uint256 addHp;
        uint256 addXp;
        uint256 addPower;
        uint256 addDefens;
        uint256 addLuk;
        uint256 injury;
    }
    //计算胜利后返回的参数
    function getCombatOdds(uint256 tokenId,address addr) view public returns(uint256,uint256,uint256,uint256,uint256){
        heroAttribute[] memory _attrs = _userHero[addr];
        combatOdds memory _combatOdds;
        for (uint256 i = 0; i < _attrs.length; i++) {
            // 0 +奖励 1减少HP损伤 2加经验 3+战斗力 4+防御力 5+新运值
            // heroAttribute[] memory  _equipment[uint32(i)];
            if(_attrs[i].eqType==0){
                _combatOdds.addReward = _attrs[i].bonus;
            }
            if(_attrs[i].eqType==1){
                _combatOdds.addHp = (_attrs[i].bonus*200/100)*10**8;
            }
            if(_attrs[i].eqType==2){
                _combatOdds.addXp = _attrs[i].bonus;
            }
            if(_attrs[i].eqType==3){
                _combatOdds.addPower = _attrs[i].bonus;
            }
            if(_attrs[i].eqType==4){
                _combatOdds.addDefens = _attrs[i].bonus;
            }
            if(_attrs[i].eqType==5){
                _combatOdds.addLuk = _attrs[i].bonus;
            }
            
        }
        cardDetails memory _cardDetails;
        (,_cardDetails.ce,_cardDetails.xp,_cardDetails.armor,_cardDetails.luk,) =  _game.getTokenDetail(tokenId);
        _combatOdds.addPower += _cardDetails.ce;
        _combatOdds.addDefens += _cardDetails.armor;
        // _combatOdds.addXp += _cardDetails.xp;
        _combatOdds.addLuk += _cardDetails.luk;
        _combatOdds.injury = (_combatOdds.addDefens/10)*10**8+_combatOdds.addHp;

        // 返回成功率（战斗力），HP injury，luk,xp
        // return _combatOdds;
        return (_combatOdds.addPower,_combatOdds.addDefens,_combatOdds.addXp,_combatOdds.addLuk,_combatOdds.injury);
    }

    function setGame(address payable _gameAddress) public onlyOwner{
        _game = Game(_gameAddress);
    }
   
   function setToken(address _tokenAddress) public onlyOwner{
        erc20 = IERC20(_tokenAddress);
    }

    function withdrawalToken(address addr,uint256 amount) public onlyOwner {
        erc20.transfer(addr, amount);
        emit Withdrawal(amount,addr);
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPancakeRouter01.sol";
contract GetFee is Ownable {
    // 根据不同的地址获取不同的汇率
    constructor() {
    }
    address public usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public tokenAddress = 0xe3Fa57Cc3514E132fD326D33B22bFAcDEC4F7c08;
    address public wbnbAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IPancakeSwapRouter public router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    function getRateByAddress(uint amountIn, address[] memory path) view public returns(uint[] memory amounts){
        amounts = router.getAmountsOut(amountIn, path);
        return amounts;
    }
    
    function getUsdtPrice(uint amountIn) public view  returns(uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = tokenAddress;
        amounts = getRateByAddress(amountIn,path);
        return amounts;
    }
    function getUsdtPrice1(uint amountIn) public view  returns(uint){
        address[] memory pathBNB = new address[](2);
        pathBNB[0] = usdtAddress;
        pathBNB[1] = wbnbAddress;
        uint[] memory amountsBnb = getRateByAddress(amountIn,pathBNB);
        address[] memory path = new address[](2);
        path[0] = wbnbAddress;
        path[1] = tokenAddress;
        uint[] memory amounts = getRateByAddress(amountsBnb[1],path);
        return amounts[1];
    }

    function getBNBPrice1(uint amountIn) public view  returns(uint){
        address[] memory path = new address[](2);
        path[0] = wbnbAddress;
        path[1] = tokenAddress;
        uint[] memory amounts = getRateByAddress(amountIn,path);
        return amounts[1];
    }
    
    function setIpaddress(address _addr) public onlyOwner{
        router = IPancakeSwapRouter(_addr);
    }
    function setTokenddress(address _addr) public onlyOwner{
        tokenAddress = _addr;
    }
    function setUsdtddress(address _addr) public onlyOwner{
        usdtAddress = _addr;
    }

    function setWbnbddress(address _addr) public onlyOwner{
        wbnbAddress = _addr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BADHero.sol";
import "./Game.sol";
contract Monster is Ownable  {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    constructor()  {
        initEney();
    }

    enemyInfo[] public enemys;
    uint32 enemyNum;
    uint256 basicHp = 200*10**8;
    BADHero public _badHero;
    Game public _game;
    // uint256 _unlockTime = 86400;
    uint256 _unlockTime = 600;
   
    event Fighting(bool isSuccess,uint256 indexed fightType,uint256 indexed sHp,uint256  addXp,uint256 indexed reward);
    event Test(bool isSuccess,uint256 indexed number,uint256 indexed suc);
    //敌人属性
    struct enemyInfo{
        uint32 id;
        uint256 odds;
        uint256 basicReward;
        uint256 basicXp;
        uint256 basicHp;
        string  name;
        string  pic;
    }
    struct combatOdds{
            uint256 addReward;
            uint256 addHp;
            uint256 addXp;
            uint256 addPower;
            uint256 addDefens;
            uint256 addLuk;
            uint256 injury;
        } 
    struct figInfo{
        uint256 succesRate;
        uint256 totalSuc;
        uint256 reward;
        uint256 addXp;
        uint256 sHp;
        bool isSuccess;
    }
    struct CardDetails{
        uint32 genre;
        uint256 tokenId;
        uint256 hp;
        uint256 level;
        uint256 xp;//经验值
        uint256 ce;//战斗力
        uint256 armor;//防御力
        uint256 luk;//幸运值
        uint256 unLockTime;//解锁时间
        uint256 rgTime;
        uint256 nftKindId; // 怪物类型id
        string name; // 怪物名字
    }
     // 待领取的奖励池
    struct rewardPool{
        uint32 id; // 1 bnb奖励2 BAD
        uint32 rewardType; // 奖励类型 1 战斗，2特殊任务，3竞技场
        uint256 tokenId;
        uint256 reward;
        uint256 addTime;
        uint256 unLockTime;
    }
    struct addXpInfo{
        uint256 totalXp;
        uint256 validXp;
    } 
    struct tokenEarnings{
            uint256 level; // 当前等级
            uint256 income; // 当前等级对应的收益
        }
    function rand(uint256 _length) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random%_length+1;
    }
    // 战斗
    function fighting(uint256 tkId,uint256 enemyId,address addr) public view  isFullHp(tkId) returns(bool,uint256,uint256,uint256,uint256){
        combatOdds memory _combatOdds;
        
        (_combatOdds.addPower,_combatOdds.addDefens,_combatOdds.addXp,_combatOdds.addLuk,_combatOdds.injury) = _badHero.getCombatOdds(tkId,addr);
        figInfo memory _figInfo ;
        _figInfo.succesRate = _combatOdds.addPower/100;
        enemyInfo memory _enemy =getEnemyById(enemyId);
        _figInfo.totalSuc = _enemy.odds + _figInfo.succesRate;
        CardDetails memory _carDetail;
        (_carDetail.level,_carDetail.ce,,_carDetail.armor,_carDetail.luk,) = _game.getTokenDetail(tkId);
        uint256 randNumber = rand(100);
        // 判断是否胜利
        if (randNumber>_figInfo.totalSuc){
            // 修改血量 basicHp
            _carDetail.hp = 0;
            _carDetail.unLockTime = block.timestamp + _unlockTime;
            _figInfo.sHp= basicHp;
            _figInfo.isSuccess = false;
        }else{
            _figInfo.sHp = basicHp - _combatOdds.injury;
            _carDetail.hp = _combatOdds.addHp;
            _carDetail.unLockTime = block.timestamp + getRgTime(_figInfo.sHp);
            _figInfo.reward = _enemy.basicReward + _combatOdds.addLuk *_enemy.basicReward/1000;
            _figInfo.addXp =_enemy.basicXp + _combatOdds.addXp;
            addXpInfo memory _addXpInfo;
            _addXpInfo.totalXp =  _enemy.basicXp + _combatOdds.addXp;
            _addXpInfo.validXp = _carDetail.level * 100 -1;
            if(_addXpInfo.totalXp>=_addXpInfo.validXp){
                _carDetail.xp = _addXpInfo.validXp;
            }else{
                _carDetail.xp = _addXpInfo.totalXp;
            }
            _figInfo.isSuccess = true;
        }
        return (_figInfo.isSuccess,_figInfo.reward,_figInfo.sHp,_carDetail.xp,_carDetail.unLockTime);
        
    }
    


    // 做任务
    function DoTask(uint256 tokenId,uint256 odds,uint256 basicReward,address addr ) public view isFullHp(tokenId)  returns(bool,uint256,uint256,uint256){
        combatOdds memory _combatOdds;
        (_combatOdds.addPower,_combatOdds.addDefens,_combatOdds.addXp,_combatOdds.addLuk,_combatOdds.injury)  = _badHero.getCombatOdds(tokenId,addr);
        figInfo memory _figInfo ;
        _figInfo.succesRate = _combatOdds.addPower/100;
        _figInfo.totalSuc = odds + _figInfo.succesRate;
        CardDetails memory _carDetail;
        (_carDetail.level,_carDetail.ce,_carDetail.xp,_carDetail.armor,_carDetail.luk,) = _game.getTokenDetail(tokenId);
        
        // 判断是否胜利
        if (rand(100)>=_figInfo.totalSuc){
            // 修改血量 basicHp
            _carDetail.hp = 0;
            _carDetail.unLockTime = block.timestamp + _unlockTime;
            _figInfo.sHp= basicHp;
        }else{
            _figInfo.sHp = basicHp - _combatOdds.injury;
            _carDetail.hp = _combatOdds.addHp;
            _carDetail.unLockTime = block.timestamp + getRgTime(_figInfo.sHp);
            _figInfo.reward = basicReward + _combatOdds.addLuk*basicReward/1000;
            _figInfo.isSuccess = true;
        }
        return (_figInfo.isSuccess,_figInfo.reward,_figInfo.sHp,_carDetail.unLockTime);
    }
    //获取怪兽信息
    function getEnemyById(uint256 enemyId) view  public returns(enemyInfo memory){
        enemyInfo memory enemy ;
        for (uint256 i = 0; i < enemys.length; i++) {
            if(enemys[i].id == enemyId){
                enemy =  enemys[i];
                break;
            }
        }
        return enemy;
    }

    // 上传怪物
    function addEnemy(uint256 odds,uint256 reward,uint256 xp,uint256 hp,string memory name,string memory pic) public onlyOwner{
        enemys.push(enemyInfo(enemyNum,odds,reward,xp,hp,name,pic));
        enemyNum +=1;
    }

    // 生成怪物
    function initEney() internal{
        if(enemys.length ==0 ){
            addEnemy(80,2*10**16,20,200*10**8,"Gabriel","");
            addEnemy(50,3*10**16,20,200*10**8,"Horace","");
            addEnemy(25,4*10**16,25,200*10**8,"Rufio","");
            addEnemy(20,5*10**16,25,200*10**8,"Hadrea","");
            addEnemy(15,6*10**16,30,200*10**8,"Sirius","");
        }
    }

    function getEnemys() view public returns(enemyInfo[] memory){
        return enemys;
    }

    function delEnemy(uint256 id) public onlyOwner{
        for(uint256 i=0;i<enemys.length;i++){
            if(enemys[i].id == id){
               delete(enemys[i]);
               break;
            }
        }
    }
    function editEnemy(uint256 id,uint256 odds,uint256 reward,uint256 xp,uint256 hp,string memory name) public onlyOwner{
        for(uint256 i=0;i<enemys.length;i++){
            if(enemys[i].id == id){
                enemys[i].odds = odds;
                enemys[i].basicReward = reward;
                enemys[i].basicXp = xp;
                enemys[i].basicHp = hp;
                enemys[i].name = name;
                break;
            }
        }
    }


    // 计算血量
    function getHp(uint256 tokenId) view public returns(uint256){
        CardDetails memory _carDetail;
        (_carDetail.level,_carDetail.ce,_carDetail.xp,_carDetail.armor,_carDetail.luk,_carDetail.rgTime) = _game.getTokenDetail(tokenId);
        // CardDetails memory _carDetail = _tokenDetail[tokenId] ;
        if(_carDetail.rgTime ==0){
            return basicHp ;
        }else{
            if (_carDetail.rgTime<=block.timestamp){
                return basicHp;
            }else{
                uint256  useTime = _carDetail.rgTime - block.timestamp;
                return _carDetail.hp + rgHp(useTime) ;
            }
        }
    }

    //计算待回复血量的时间
    function getRgTime(uint256 hp) view internal returns(uint256){
        return hp*_unlockTime/basicHp;
    }
    
    // 判断是否在队伍中
    modifier isFullHp(uint256 tokenId){
        uint256 tokenHp= getHp(tokenId);
        require(tokenHp >= basicHp," Hp Is no full");
        _;
    }
    // 血量回复
    function rgHp(uint256 useTime) view public returns(uint256 hp){
        uint256 rate = basicHp/_unlockTime;
        return basicHp - rate*useTime;
    }
    function setGame(address payable _token) public onlyOwner{
        _game = Game(_token);
    }
    function setBADHero(address _token) public onlyOwner{
        _badHero = BADHero(_token);
    }
}