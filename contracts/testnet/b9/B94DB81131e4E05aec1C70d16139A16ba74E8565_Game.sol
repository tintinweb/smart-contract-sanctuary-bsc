// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./IERC20.sol";
import "./IPancakeRouter01.sol";
// import "./NFT.sol";
import "./IMonster.sol";
contract Game is AccessControl,Ownable {
    // using UserLib for UserLib.CardDetails;
    // UserLib.CardDetails private _cardDetails;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    constructor(address _router,address _usdt,address _tokenAddress) {
        router = IPancakeSwapRouter(_router);
        usdtAddress = _usdt;
        tokenAddress = _tokenAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        pushTask();
        }
    
    IPancakeSwapRouter public router;
    address public usdtAddress ;
    address public tokenAddress ;
    IERC20 public erc20;
    address public wbnb;
    IMonster public _monster;
    

    mapping(address=>CardDetails[]) _userTem;//队伍卡片
    mapping(address=>CardDetails[]) _userBackpack;//背包卡片
    gameInfo private _gameInfo = gameInfo(12*3600,5,10*10**18,100,10,25,2000*10**18);
    mapping(uint256=>address) _tokenUser;
    mapping(uint256=>CardDetails) _tokenDetail;
    mapping(uint256=>mapping(uint256=>uint256)) _tokenLevel; // toeknId/等级
   address[] _USDTpath = [usdtAddress,tokenAddress];
   address[] _wbnbpath = [wbnb,tokenAddress];
    
    uint256 basicHp = 200*10**8;

    uint32 public enemyNum = 0;

    mapping(address=>rewardPool[]) public _userRewardPools;  // 用户胜利的奖励未领取
    enemyInfo[] public specialTask;
    receiveInfo _receiveInfo = receiveInfo(48*3600,3,7);

    event SpeedTraining(uint256 indexed tokenId,address indexed sender,uint256 needFee);
    event MoveCard(uint256 indexed tokenId,address indexed sender,uint256 mvType);
    event UpMonster(uint256 indexed tokenId,uint256 indexed level,uint256 amount,address sender);
    event BuyBft(uint256 indexed _tokenId,uint256 indexed money,address nftOwner, address msender);
    event Fighting(bool isSuccess,uint256 indexed fightType,uint256 indexed sHp,uint256  addXp,uint256 indexed reward);
    event DrawReward(uint256 indexed rewardType,uint256 indexed reward,uint256 rate,address sender);
    event JoinArena(uint256 indexed nper,uint256 indexed wins,address sender);

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
    struct nftKind{
        uint32 start;
        uint32 end;
        uint64 atRate;
        string ranking;
        string rankingName;
        string url;
    }
    
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

    // 待领取的奖励池
    struct rewardPool{
        uint32 id; // 1 bnb奖励2 BAD
        uint32 rewardType; // 奖励类型 1 战斗，2特殊任务，3竞技场
        uint256 tokenId;
        uint256 reward;
        uint256 addTime;
        uint256 unLockTime;
    }

    // 奖励设置参数
    struct receiveInfo{
        uint256 lockTime; // 锁定时间
        uint256 fee;    // 每天费用
        uint256 freeDay; // 多天后领取免费
    }



    function rand(uint256 _length) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random%_length;
    }
 

    // 生成卡片信息
    function createCard(uint256 tokenId,uint256 ce,uint256 armor,uint256 luk,uint256 unLockTime,uint256 nftKindId,string memory name,uint256 maxNum) public onlyRole(MINTER_ROLE) returns(uint256){
        //初始化卡片信息
        CardDetails memory _carDetails = CardDetails(0,tokenId,basicHp,1,0,ce,armor,luk,block.timestamp+unLockTime,0,nftKindId,name);
        
        if(_userTem[msg.sender].length<maxNum){
            _userTem[msg.sender].push(_carDetails);
        }else{
            _userBackpack[msg.sender].push(_carDetails);
        }
        _tokenUser[tokenId] = msg.sender;
        _tokenDetail[tokenId] = _carDetails;

        return tokenId;
    }

    // 加速训练
    function adRecruit(uint256 tokenId)  public{
        require(_tokenUser[tokenId]!=msg.sender,"Have no legal power");
        CardDetails memory _carDetail = _tokenDetail[tokenId] ;
        uint256 needFee = 0;
        if(_carDetail.unLockTime > block.timestamp){
            uint256 needTime = block.timestamp - _carDetail.unLockTime;
            needFee = speedFee(needTime);
            erc20.transferFrom(msg.sender, address(this), needFee);
        }
        _carDetail.unLockTime = 0;
        emit SpeedTraining(tokenId,msg.sender,needFee);
    }

    // 移动去背包
    function moveToBack(uint256 tokenId) public {
        require(_tokenUser[tokenId]!=msg.sender,"Have no legal power");
        CardDetails[] memory cards = _userTem[msg.sender];
        for(uint256 i=0;i<cards.length;i++){
            if(cards[i].tokenId == tokenId){
                _userBackpack[msg.sender].push(cards[i]);
                _userTem[msg.sender][i] = _userTem[msg.sender][_userTem[msg.sender].length - 1];
                _userTem[msg.sender].pop();
                break;
            }
        }
        emit MoveCard(tokenId,msg.sender,1);
    }

    // 移动背包卡片去队伍
    function moveToTem(uint256 tokenId) public {
        require(_tokenUser[tokenId]!=msg.sender,"Have no legal power");
        CardDetails[] memory cards = _userBackpack[msg.sender];
        require(_userTem[msg.sender].length>=_gameInfo.temNum,"The team is full ");
        for(uint256 i=0;i<cards.length;i++){
            if(cards[i].tokenId == tokenId){
                _userTem[msg.sender].push(cards[i]);
                // delete cards[i];
                _userBackpack[msg.sender][i] = _userBackpack[msg.sender][_userBackpack[msg.sender].length - 1];
                _userBackpack[msg.sender].pop();
                break;
            }
        }
        emit MoveCard(tokenId,msg.sender,2);
    }
    
    

    // function setIPancakeRouter(address _IPancakeRouter01Address) public onlyOwner{
    //     router = IPancakeSwapRouter(_IPancakeRouter01Address); 
    // }


    function setusdtAddress(address _usdtAddress) public onlyOwner{
        usdtAddress = _usdtAddress;
    }

    // wbnb
    function setWbnb(address addr) public onlyOwner{
        wbnb = addr;
    }

    
    function setErc20(address addr) public onlyOwner{
        erc20 = IERC20(addr);
    }
    function setMonster(address addr) public onlyOwner{
        _monster = IMonster(addr);
    }
    function setRole(address upAddress)public onlyOwner{
            _grantRole(MINTER_ROLE, upAddress);
    }
    
    // 计算待加速所需费用
    function speedFee(uint256 remainTime) view public returns(uint256){
        if (remainTime<=0){
            return 0;
        }
        uint[] memory amounts = getRateByAddress(_gameInfo.speedMoney,_USDTpath);
        // uint256 amount = amounts[1];
        // uint256 _rate = amounts[1]/_gameInfo.enlistTime;
        uint256 const = remainTime*(amounts[1]/_gameInfo.enlistTime);
        return const;
    }
  
    function fighting(uint256 tokenId,uint256 enemyId) public isteam(tokenId,msg.sender) {
        (bool suc,uint256 reward,uint256 level) = _monster.fighting(tokenId,enemyId);
        if(suc == true){
            rewardPool memory _rewardPool;
            _rewardPool.id = 1;
            _rewardPool.rewardType = 1;
            _rewardPool.tokenId = tokenId;
            _rewardPool.reward = reward;
            _rewardPool.addTime = block.timestamp;
            _rewardPool.unLockTime = block.timestamp+_receiveInfo.lockTime;
            _userRewardPools[msg.sender].push(_rewardPool);
            _tokenLevel[tokenId][level] +=reward;
        }
        
    }
    // 做任务
    function DoTask(uint256 tokenId,uint256 enemyId) public  {
        enemyInfo memory _task =getTaskById(enemyId);
        (bool suc,uint256 reward,) = _monster.DoTask(tokenId,_task.odds,_task.basicReward);
        if(suc == true){
            rewardPool memory _rewardPool;
            _rewardPool.id = 1;
            _rewardPool.rewardType = 2;
            _rewardPool.tokenId = tokenId;
            _rewardPool.reward = reward;
            _rewardPool.addTime = block.timestamp;
            _rewardPool.unLockTime = block.timestamp+_receiveInfo.lockTime;
            _userRewardPools[msg.sender].push(_rewardPool);
        }
    }

    // 发放竞技奖励
    function DisReward(address rewardAddr,uint256 tokenId,uint256 reward) public onlyRole(MINTER_ROLE) {
            rewardPool memory _rewardPool;
            _rewardPool.id = 1;
            _rewardPool.rewardType = 3;
            _rewardPool.tokenId = tokenId;
            _rewardPool.reward = reward;
            _rewardPool.addTime = block.timestamp;
            _rewardPool.unLockTime = block.timestamp+_receiveInfo.lockTime;
            _userRewardPools[rewardAddr].push(_rewardPool);
    }

    //升级怪物等级
    function upLevel(uint256 _tokenId) public{
        require(_tokenUser[_tokenId]!=msg.sender,"Have no legal power");
        require(_tokenDetail[_tokenId].level >= _gameInfo.maxLevel,"_gameInfo.maxLevel");
        uint256 needXp = _tokenDetail[_tokenId].level *_gameInfo.maxLevel -1;
        require(_tokenDetail[_tokenId].xp < needXp,"xp is lack");
        // 获取当前等级收益的25%进行解锁 
        // uint256 income =incomByLevel(_tokenId,_tokenDetail[_tokenId].level);
        uint[] memory amounts = getRateByAddress(_tokenLevel[_tokenId][_tokenDetail[_tokenId].level],_wbnbpath);
        uint256 incomeByToken = amounts[1];
        uint256 amount ;
        amount = incomeByToken * _gameInfo.upAttrCost /100;
        erc20.transferFrom(msg.sender, address(this), amount);
        _tokenDetail[_tokenId].xp = 0;
        _tokenDetail[_tokenId].level = _tokenDetail[_tokenId].level+1;
        _tokenDetail[_tokenId].ce += _gameInfo.addAttr;
        _tokenDetail[_tokenId].armor += _gameInfo.addAttr;
        _tokenDetail[_tokenId].luk += _gameInfo.addAttr;
        emit UpMonster(_tokenId,_tokenDetail[_tokenId].level,amount,msg.sender);
    }

    // 领取奖励
    function drawReward(uint256 index) public{
        rewardPool[] memory _rwPools = _userRewardPools[msg.sender];
        rewardPool memory rwPool = _rwPools[index];
        require(rwPool.unLockTime<block.timestamp,"The unlock time is not reached");
        uint256 rateFee = getFee(rwPool.addTime);
        uint256 rallReward =  rwPool.reward - (rwPool.reward*rateFee/100);
        if(rwPool.id == 1){
            payable(msg.sender).transfer(rallReward);
        }else{
            erc20.transferFrom(address(this), msg.sender, rallReward);
        }
        delete _userRewardPools[msg.sender][index] ;
        emit DrawReward(rwPool.id,rallReward,rateFee,msg.sender);
    }

    // 计算领取所需手续费
    function getFee(uint256 addTime) view public returns(uint256){
        uint256 overTime = _receiveInfo.freeDay*86400 + addTime;
        if(block.timestamp >=overTime){
            return 0;
        }
        uint256 diffTime = overTime - block.timestamp;
        uint256 needDay = diffTime/86400;
        if (needDay*86400<diffTime){
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

modifier isteam(uint256 tokenId,address sender){
       CardDetails[] memory cards = _userTem[sender];
        bool _isTeam = false;
        for(uint32 i=0;i<cards.length;i++){
            if(cards[i].tokenId == tokenId){
                _isTeam =true;
                break;
            }
        }
        require(_isTeam ==false,"nft is no team");
        _;
    }
 
    //specialTask
    // 特殊任务
    function addTask(uint256 odds,uint256 reward,uint256 xp,uint256 hp,string memory name,string memory pic) public onlyOwner{
        specialTask.push(enemyInfo(enemyNum,odds,reward,xp,hp,name,pic));
        enemyNum +=1;
    }
    function pushTask() internal{
        addTask(20,1*10**17,0,20*10**8,"zcdq","");
        addTask(10,2*10**17,0,20*10**8,"gdrz","");
    }
    

    function getTokenDetail(uint256 tokenId) view public returns(uint256 ce,uint256 xp,uint256 armor,uint256 luk,uint256 rgTime){
        return (_tokenDetail[tokenId].ce,_tokenDetail[tokenId].xp,_tokenDetail[tokenId].armor,_tokenDetail[tokenId].luk,_tokenDetail[tokenId].rgTime);
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

     function getRateByAddress(uint amountIn, address[] memory path) view public returns(uint[] memory amounts){
        amounts = router.getAmountsOut(amountIn, path);
        return amounts;
    }
    
    function getUsdtPrice(uint amountIn)  public view returns(uint[] memory){
        uint[] memory amounts =getRateByAddress(amountIn,_USDTpath);
        return amounts;
    }
    function getUserCards(address sender,uint256 cardType) view public returns(CardDetails[] memory){
        if(cardType==1){
            return _userTem[sender];
        }else{
            return _userBackpack[sender];
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IMonster {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function fighting(uint256 tokenId,uint256 enemyId) external view returns (bool,uint256,uint256);

    function DoTask(uint256 tokenId,uint256 odds,uint256 basicReward )  external view returns(bool,uint256,uint256);
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