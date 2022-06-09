// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";



interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}


interface INFT{
    struct starAttributesStruct{
      address origin;   //发布者
      string  IphsHash;//hash
      uint256 power;//nft等级
      uint256 price;   //价格
      uint256 stampFee;  //版税
      uint256 createTime;  //鑄造時間
      string  MetaData; // metadata json
    }
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(starAttributesStruct memory attr);

    function batchTransferFrom(address from, address to,uint256[] calldata tokenIds) external; 
    function burn(uint256 Id) external;
    function changePower(uint256 tokenId,uint256 power)external returns(bool);
}

interface IPromote{
    struct _UserInfo {
        uint256 rewardedAmount;
        bool isValid;
        // md 值(一代)
        uint256 numSS;
        // md 值(三代)
        uint256 numGS;
        // md 值(6代内有效地址數)
        uint256 numDown6Gen;
        uint256 weight;
        // 用戶上線
        address f;
        // 下線群組
        address[] ss;
    }

    struct User3GenWeight {
        // 1、2、3代的權重加總(不含加成)
        uint256 gen3Weight;
        uint256 gen2Weight;
        uint256 gen1Weight;
    }
    // 全網3代加成總權重
    function total3GenBonusWeight() external view returns (uint256);
    function invalid3GenBonusWeight() external view returns (uint256);
    function getUser3GenWeight(address _user) external view returns (User3GenWeight memory);
    function update(uint256 amount) external;
    function getUser(address _user) external view returns (_UserInfo calldata);
    function newDeposit(address sender, uint256 weight, uint256 amount) external;
    function redem(address sender, uint256 weight, uint256 amount) external;
    function updateUserBouns(address _user) external;
    function genBonus() external view returns (uint256[] memory);
    function updateInvalid3GenBonusWeight(address _user, bool isValid) external;
}

interface ITokenStake{
    function update(uint256 amount) external;
}

contract NFT_MasterChef is Initializable, OwnableUpgradeable, Member {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 receivedReward;
        uint256 rewardDebt; 
        uint256 pendingReward;
        uint256[]  _nftBalances;
        uint256 lvMore1Count;   // 擁有level > 1的nft數量
    }

    struct PoolInfo {
        address lpToken;           
        uint256 allocPoint;       
        uint256 lastRewardBlock;  
        uint256 accSushiPerShare; 
        uint256 totalStakingNFTAmount;
    }


    IERC20 public mp;
    IPromote public promote;

    uint256 public bonusEndBlock;
    uint256 public sushiPerBlock;
    uint256 public sushiPerBlockOrigin;

    PoolInfo[] public poolInfo;
    uint256[] public nftweight;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;
    uint256 public startBlock;
    uint256 public fifteenDays;
    
    bool public pauseStake;
    bool public pauseWithdraw;
    bool public pauseGetReward;
    
    address public usdt;
    IUniswapV2Pair public pair;

    
    //mapping(address => uint256[]) public _nftBalances;
    mapping(address => mapping(uint256 => bool)) public isInStating;
    mapping(uint256 => uint256) public lockedTime;
    uint256 maxWithAmount;

    uint256 public lastCutBlock;
    uint256 public CUT_PERIOD;
    
    uint256 public level;
    uint256 public MAX_REWARD_WEIGHT;
    uint256 public mintedMEP;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event ChangeFee(uint256 indexed origunfee, uint256 newfee);
    event UpdatePool(uint256 indexed pid, uint256 timestamp);
    event PerShareChanged(uint256 _before, uint256 _current);
    event RecoverTokens(address token, uint256 amount, address to);
    event MintMax(uint256 amount);


    function initialize(
        IERC20 _mp,
        address _usdt,
        IPromote _promote, 
	    IUniswapV2Pair _pair,
        uint256 _sushiPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public initializer {
        __Ownable_init();
        __initializeMember();

        init();
        mp = _mp;
        usdt = _usdt;
        promote = _promote;
	    pair = _pair;
        sushiPerBlockOrigin = _sushiPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        lastCutBlock = _startBlock;
    }

    function init() internal initializer {
        nftweight = [100,210,440,920,2000,4200];
        fifteenDays = 15 days / 3;
        maxWithAmount = 10;
        CUT_PERIOD = 60 days / 3; // 60天(區塊號格式)
        MAX_REWARD_WEIGHT = 3000000;  // 30w
    }
    
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    
    function getUser(address _user) external view returns(UserInfo memory) {
        uint256 _pid = 0;
        return userInfo[_pid][_user];
    }

    function getBalances(uint256 _pid, address _user) external view returns (uint256[] memory) {
        return userInfo[_pid][_user]._nftBalances;
    }
    
    function balanceOfNFT(uint256 _pid,address account) external view returns(uint256){
        return userInfo[_pid][account]._nftBalances.length;
    }
    function balanceOfByIdex(uint256 _pid,address account,uint256 index) external view returns(uint256){
        return userInfo[_pid][account]._nftBalances[index];
    }

    function add(uint256 _allocPoint, address _lpToken, bool _withUpdate) external onlyOwner {
        require(address(_lpToken) != address(0),'address invalid');
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accSushiPerShare: 0,
            totalStakingNFTAmount:0
        }));
    }

    function timeLockChange(uint256 _period) external {
        require(msg.sender == manager.members("owner"), "onlyOwner");
        fifteenDays = _period;
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) internal pure returns (uint256) {
        return _to - _from;
    }

    // View function to see pending SUSHIs on frontend.
    function pendingSushi(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        uint256 lpSupply = IPromote(promote).total3GenBonusWeight() - IPromote(promote).invalid3GenBonusWeight();
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 sushiReward = multiplier * (sushiPerBlock) * (pool.allocPoint) / (totalAllocPoint);

            // 产出总量的95%加权给NFT质押池，3%分配给添加LP質押池，2%分配给MP靜態池
            uint256 rewardAmount = sushiReward * 95 / 100;

            accSushiPerShare = accSushiPerShare + (rewardAmount * (1e12) / (lpSupply));
        }

        uint256 userTotalWeight = getUserTotalWeight(_user);
        uint256 _pendding;
        if(userTotalWeight > 0){
            _pendding = userTotalWeight * (accSushiPerShare) / (1e12) - (user.rewardDebt);
        }

        return user.pendingReward + (_pendding);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number < pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = IPromote(promote).total3GenBonusWeight() - (IPromote(promote).invalid3GenBonusWeight());
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        // 每達到 1,728,000 個區塊高度（大約需要 60 天），ERA 的產出數量將減少 5%。
        if(block.number >= lastCutBlock + (CUT_PERIOD)){
            lastCutBlock = block.number;
            sushiPerBlockOrigin = sushiPerBlockOrigin * (95) / (100);
        }
        // level只會有 0 or 1
        uint256 level2 = lpSupply >= 6000 ? 1: 0;

        // 等級改變
        if(level2 != level) {
            level = level2;
        }

        uint256 newSushiPerBlock;
        if(level != 0){
            if(lpSupply<MAX_REWARD_WEIGHT){
                // 未滿產按照比例
                newSushiPerBlock = sushiPerBlockOrigin * lpSupply / MAX_REWARD_WEIGHT;
            }else{
                // 滿產
                newSushiPerBlock = sushiPerBlockOrigin;
            }
        }else{
            newSushiPerBlock = 0;
        }

        if(sushiPerBlock != newSushiPerBlock){
            emit PerShareChanged(sushiPerBlock, newSushiPerBlock);
            sushiPerBlock = newSushiPerBlock;
        }

        if (level == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        //與上次生產mp的相差塊數
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if (multiplier == 0) {
            return;
        }
        // 這段時間的總派發Mp * 1 / 1
        uint256 sushiReward = multiplier * sushiPerBlock * pool.allocPoint / totalAllocPoint;

        // 产出总量的95%加权给NFT质押池，3%分配给添加LP質押池，2%分配给MP靜態池
        
        uint256 toLpAmount = safeMint(manager.members("LPAddress"), sushiReward * (3) / (100));
        uint256 toMpAmount = safeMint(manager.members("MPAddress"), sushiReward * (2) / (100));
        uint256 rewardAmount = sushiReward * (95) / (100);
        
        if(toLpAmount > 0){
            ITokenStake(manager.members("LPAddress")).update(toLpAmount);
        }
        if(toMpAmount > 0){
            ITokenStake(manager.members("MPAddress")).update(toMpAmount);
        }

        pool.accSushiPerShare = pool.accSushiPerShare + (rewardAmount * (1e12) / (lpSupply));
        pool.lastRewardBlock = block.number;
        emit UpdatePool(_pid, block.timestamp);
    }
    function deposit(uint256 _pid, uint256[] memory tokenIDList) public{
        require(pauseStake == false, "function is suspended");
        require(tokenIDList.length > 0, "Cannot stake null token");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        uint256 _amount = _stake(_pid,tokenIDList);
        deposit_In(_pid,_amount);
        updatePool(_pid);

        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(msg.sender);
        if(userTotalWeight > 0){
            userInfo[_pid][msg.sender].rewardDebt = userTotalWeight * (poolInfo[_pid].accSushiPerShare) / (1e12);
        }
    }
    // 更新user在IPromote的權重
    function deposit_In(uint256 _pid, uint256 _amount) internal {
        IPromote(promote).newDeposit(msg.sender,0, _amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function claimReward(uint256 _pid, address _user) public {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 userTotalWeight = getUserTotalWeight(_user);
        if (userTotalWeight > 0) {
           
            uint256 pending = userTotalWeight * (pool.accSushiPerShare) / (1e12) - (user.rewardDebt);
            if(pending>0){
                user.pendingReward = user.pendingReward + (pending);
            }
            user.rewardDebt = userTotalWeight * (pool.accSushiPerShare) / (1e12);
        } 
    }

    function updateRewardDebt(address _user) external {
        require(msg.sender == address(promote), "promoteOwner");
        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(_user);
        if(userTotalWeight > 0){
            userInfo[0][_user].rewardDebt = userTotalWeight * (poolInfo[0].accSushiPerShare) / (1e12);
        }
    }

    function _stake(uint256 _pid,uint256[] memory amount) internal returns(uint256 totalAmount){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 len = amount.length;
        uint256 tokenID;
        require(len <= maxWithAmount,"can not big then maxWithAmount");
        for(uint256 i=0;i<len;i++){
            tokenID = amount[i];
            require(!isInStating[msg.sender][tokenID],"already exit");
            require(INFT(pool.lpToken).ownerOf(tokenID) == msg.sender,"not ownerOf");
            lockedTime[tokenID] = block.number;
            INFT.starAttributesStruct memory attr = INFT(pool.lpToken).starAttributes(tokenID);
            uint256 Grade = attr.power;

            // 計數lv>1的nft數量
            if(Grade > 1){
                user.lvMore1Count++;
                if(user.lvMore1Count == 1){
                    promote.updateInvalid3GenBonusWeight(msg.sender, true);
                }
            }

            totalAmount += nftweight[Grade - 1];
            
            isInStating[msg.sender][tokenID] = true;
            user._nftBalances.push(tokenID);
            emit DepositNFT(msg.sender,_pid,tokenID);
        }

        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount + (len);           //更新总抵押nft数量
        INFT(pool.lpToken).batchTransferFrom(msg.sender,address(this),amount);
    }

    function withdraw(uint256 _pid,uint256 tokenid) public{
        require(pauseWithdraw == false, "function is suspended");
        require(isInStating[msg.sender][tokenid] == true,"not ownerOf");

        // 閉鎖期：滿15天（第16天週期基數才可取回，不主動取回則繼續質押）
        // 0d 1h % 15 = 0
        // 1d 1h % 15 = 1

        // 15d 1h % 15 = 0
        // 16d 1h % 15 = 1

        // 30d 1h % 15 = 0
        // 31d 1h % 15 = 1

        bool stakeNotOver1Day = block.number - (lockedTime[tokenid]) < (1 days / 3);  // 質押不到一天
        require(!stakeNotOver1Day && (block.number - (lockedTime[tokenid])) % (fifteenDays) < (1 days / 3) ,"NO Enough Time to lock");  

        updatePool(_pid);
        claimReward(_pid, msg.sender);
        uint256 amount = withdrawNFT(_pid,tokenid);
        withdraw_in(_pid,amount);
        updatePool(_pid);
        
        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(msg.sender);
        if(userTotalWeight > 0){
            userInfo[_pid][msg.sender].rewardDebt = userTotalWeight * (poolInfo[_pid].accSushiPerShare) / (1e12);
        }

        // 當最後一張nft被贖回，自動提領獎勵
        
        if(userInfo[_pid][msg.sender]._nftBalances.length == 0){
            getReward(_pid);
        }
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw_in(uint256 _pid, uint256 _amount) internal {
        IPromote(promote).redem(msg.sender , 0, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    function getReward(uint256 _pid) public{
        require(pauseGetReward == false, "function is suspended");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.pendingReward>0){
            uint256 mintMEPAmount = safeMint(msg.sender, user.pendingReward);
            user.receivedReward = user.receivedReward + (mintMEPAmount);
            user.pendingReward = 0; 
        }
    }

    function withdrawNFT(uint256 _pid,uint256 tokenID) internal returns(uint256 totalAmount){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 len = user._nftBalances.length;
        
        if(len == 0){
            return 0;
        }
        uint256 index = 0;
        uint256 indexLast = len - (1);
        uint256 TiD = 0;
        for(uint256 i = 0;i < len; i++){
            TiD = user._nftBalances[i];
            if(TiD == tokenID){
                index = i;
                break;
            } 
        }
        if(index != indexLast){
            uint256 lastTokenId = user._nftBalances[indexLast];
            user._nftBalances[index] = lastTokenId;
        }
        user._nftBalances.pop();

        INFT.starAttributesStruct memory attr = INFT(pool.lpToken).starAttributes(tokenID);
        uint256 Grade = attr.power;

        // 計數lv>1的nft數量
        if(Grade > 1){
            user.lvMore1Count--;
        }

        // 取消算力額外加成
        if(user.lvMore1Count == 0) {
            promote.updateInvalid3GenBonusWeight(msg.sender, false);
        }
        
        totalAmount = nftweight[Grade - 1];
        isInStating[msg.sender][tokenID] = false;

        delete lockedTime[tokenID];
        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount - (1);
        emit WithdrawNFT(msg.sender,_pid,tokenID);
        INFT(pool.lpToken).transferFrom(address(this),msg.sender,tokenID);
    }

    function safeMint(address _to, uint256 _amount) internal returns(uint256) {
        uint256 MaxSupply = 7770000 * 1e18;
        uint256 oldTotalSupply = mp.totalSupply();
        uint256 newTotalSupply = oldTotalSupply + _amount;
        uint256 newSupply = _amount;

        // 達到上限
        if(MaxSupply == oldTotalSupply){
            emit MintMax(0);
            return 0;
        }

        if(newTotalSupply > MaxSupply){
            newSupply = MaxSupply - oldTotalSupply;
            emit MintMax(newSupply);
        }

        mintedMEP = mintedMEP + newSupply;
        mp.mint(_to, newSupply);
        return newSupply;
    }

    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 rea_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, rea_balance , ) = pair.getReserves();   
        }  
        else{
          (rea_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance * (1e18) / (rea_balance);
        return token_price;
    }

    function getUserTotalWeight(address _user) public view returns(uint256 userTotalWeight){
        IPromote._UserInfo memory _userInfo = IPromote(promote).getUser(_user);
        if(_userInfo.weight == 0){
            return 0;
        }

        if(userInfo[0][_user].lvMore1Count == 0){
            return _userInfo.weight;
        }

        IPromote.User3GenWeight memory _user3Gen = IPromote(promote).getUser3GenWeight(_user);

        // 取得%數
        uint256[] memory bonus = promote.genBonus();
        
        userTotalWeight = userTotalWeight + (_user3Gen.gen3Weight * (bonus[2]) / (100));
        userTotalWeight = userTotalWeight + (_user3Gen.gen2Weight * (bonus[1]) / (100));
        userTotalWeight = userTotalWeight + (_user3Gen.gen1Weight * (bonus[0]) / (100));

        userTotalWeight = userTotalWeight + (_userInfo.weight);
        return userTotalWeight;
    }

    function setPauseStake(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
    }

    function setPauseWithdraw(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseWithdraw = _pause;
    }

    function setPauseGetReward(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseGetReward = _pause;
    }

    function setPauseAll(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
        pauseWithdraw = _pause;
        pauseGetReward = _pause;
    }

    function recoverTokens(address token, uint256 amount, address to) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance not enough");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
    }
    function changeConstructor(
        IERC20 _mp,
        address _usdt,
        IPromote _promote, 
	    IUniswapV2Pair _pair,
        uint256 _sushiPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external { 
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        mp = _mp;
        usdt = _usdt;
        promote = _promote;
	    pair = _pair;
        sushiPerBlockOrigin = _sushiPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        lastCutBlock = _startBlock;
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
abstract contract Member is Initializable, ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function __initializeMember() internal initializer {
        contractOwner = msg.sender;
    }
    
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function burn(uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using AddressUpgradeable for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

pragma solidity ^0.8.0;
// SPDX-License-Identifier: SimPL-2.0

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
abstract contract ContractOwner is Initializable {
    address public contractOwner;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Manager is Initializable, ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    

    function initialize() public initializer {
        contractOwner = msg.sender;
    }
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}