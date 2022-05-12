// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/SafeERC20.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function approve(address _approved,uint256 _tokenId) external;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external;
    function viewTokenID() view external returns(uint256);
    function setTokenTypeAttributes(uint256 _tokenId,uint8 _typeAttributes,uint256 _tvalue) external;
    function transferList(address _to,uint256[] calldata _tokenIdList) external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function starAttributes(uint256 _tokenID) external view returns(address,string memory,uint256,uint256,uint256,bool,uint256);
    function batchTransferFrom(address from, address to,uint256[] calldata tokenIds) external; 
    function burn(uint256 Id) external;
    function changePower(uint256 tokenId,uint256 power)external returns(bool);
}

interface IPromote{
    struct _UserInfo {// 上線八代
        address[8] upline8Gen;
        // 以8代内的權重加總(包含自己)
        uint256 down8GenWeight;
        // 以3代内的權重加總(包含自己)
        uint256 down3GenWeight;
        //  6 代内有效地址數
        uint256 numDown6Gen;

        // 已提領獎勵
        uint256 receivedReward;

        bool isValid;
        uint8 level;
        // md 值(一代)
        uint256 numSS;
        // md 值(三代)
        uint256 numGS;
        uint256 weight;
        uint256 depositAsUsdt;
        uint256 depositedMP;
        uint256 lastRewardRound;
        uint256 pendingReward;
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
        // 1、2、3代代加成百分比(6 = 6%)
        uint256 gen3Bonus;
        uint256 gen2Bonus;
        uint256 gen1Bonus;
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
}

interface ITokenStake{
    function update(uint256 amount) external;
}

contract NFT_MasterChef is Ownable, Member {
    using SafeMath for uint256;
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
    IPromote internal promote;

    uint256 public bonusEndBlock;
    uint256 public sushiPerBlock;
    uint256 public sushiPerBlockOrigin;

    PoolInfo[] public poolInfo;
    uint256[] public nftweight = [100,210,440,920,2000,4200];
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public fifteenDays = 15 days;
    
    bool public pauseStake = false;
    bool public pauseWithdraw = false;
    bool public pauseGetReward = false;
    
    address public usdt;
    IUniswapV2Pair public pair;

    
    //mapping(address => uint256[]) public _nftBalances;
    mapping(address => mapping(uint256 => bool)) public isInStating;
    mapping(uint256 => uint256) public lockedTime;
    uint256 maxWithAmount = 10;

    uint256 public lastCutBlock;
    uint256 constant public CUT_PERIOD = 20 * 24 * 3600;
    
    uint256 public level;
    uint256 public constant MAX_REWARD_WEIGHT = 5000000;  // 50w
    

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event ChangeFee(uint256 indexed origunfee, uint256 newfee);
    event UpdatePool(uint256 indexed pid, uint256 timestamp);
    event PerShareChanged(uint256 _before, uint256 _current);
    event RecoverTokens(address token, uint256 amount, address to);

    constructor(
        IERC20 _mp,
        address _usdt,
        IPromote _promote, 
	    IUniswapV2Pair _pair,
        uint256 _sushiPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
        
    ) {
        mp = _mp;
        usdt = _usdt;
        promote = _promote;
	    pair = _pair;
        sushiPerBlockOrigin = _sushiPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        lastCutBlock = _startBlock;
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
    
    function balanceOfNFT(uint256 _pid,address account) public view returns(uint256){
        return userInfo[_pid][account]._nftBalances.length;
    }
    function balanceOfByIdex(uint256 _pid,address account,uint256 index) public view returns(uint256){
        return userInfo[_pid][account]._nftBalances[index];
    }

    function add(uint256 _allocPoint, address _lpToken, bool _withUpdate) public onlyOwner {
        require(address(_lpToken) != address(0),'address invalid');
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accSushiPerShare: 0,
            totalStakingNFTAmount:0
        }));
    }

    function timeLockChange(uint256 _period) public {
        require(msg.sender == manager.members("owner"), "onlyOwner");
        fifteenDays = _period;
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    // View function to see pending SUSHIs on frontend.
    function pendingSushi(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        uint256 lpSupply = IPromote(promote).total3GenBonusWeight().sub(IPromote(promote).invalid3GenBonusWeight());
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            // 产出总量的95%加权给NFT质押池，3%分配给添加LP質押池，2%分配给MP靜態池
            uint256 toLpAmount = sushiReward.mul(3).div(100);
            uint256 toMpAmount = sushiReward.mul(2).div(100);
            uint256 rewardAmount = sushiReward.sub(toLpAmount).sub(toMpAmount);

            accSushiPerShare = accSushiPerShare.add(rewardAmount.mul(1e12).div(lpSupply));
        }

        uint256 userTotalWeight = getUserTotalWeight(_user);
        uint256 _pendding;
        if(userTotalWeight > 0){
            _pendding = userTotalWeight.mul(accSushiPerShare).div(1e12).sub(user.rewardDebt);
        }

        return user.pendingReward.add(_pendding);
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

        uint256 lpSupply = IPromote(promote).total3GenBonusWeight().sub(IPromote(promote).invalid3GenBonusWeight());
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        // 每達到 1,728,000 個區塊高度（大約需要 60 天），ERA 的產出數量將減少 5%。
        if(block.number >= lastCutBlock.add(CUT_PERIOD)){
            lastCutBlock = block.number;
            sushiPerBlockOrigin = sushiPerBlockOrigin.mul(95).div(100);
        }

        if(level != 0){
            uint256 newSushiPerBlock;
            if(lpSupply<MAX_REWARD_WEIGHT){
                // 未滿產按照比例
                newSushiPerBlock = sushiPerBlockOrigin.mul(level).mul(lpSupply).div(MAX_REWARD_WEIGHT);
            }else{
                // 滿產
                newSushiPerBlock = sushiPerBlockOrigin;
            }
            emit PerShareChanged(sushiPerBlock, newSushiPerBlock);
            sushiPerBlock = newSushiPerBlock;
        }

        // level只會有 0 or 1
        uint256 level2 = lpSupply >= 6000 ? 1: 0;

        // 等級改變
        if(level2 != level) {
            level = level2;
            uint256 newSushiPerBlock;
            if(level == 0) {
               newSushiPerBlock = 0;
            }else{
                if(lpSupply < MAX_REWARD_WEIGHT){
                    // 未滿產按照比例
                    newSushiPerBlock = sushiPerBlockOrigin.mul(level).mul(lpSupply).div(MAX_REWARD_WEIGHT);
                }else{
                    // 滿產
                    newSushiPerBlock = sushiPerBlockOrigin;
                }
            }
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
        uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        // 产出总量的95%加权给NFT质押池，3%分配给添加LP質押池，2%分配给MP靜態池
        uint256 toLpAmount = sushiReward.mul(3).div(100);
        uint256 toMpAmount = sushiReward.mul(2).div(100);
        uint256 rewardAmount = sushiReward.sub(toLpAmount).sub(toMpAmount);
        
        IERC20(mp).transfer(address(manager.members("LPAddress")),toLpAmount);  
        ITokenStake(manager.members("LPAddress")).update(toLpAmount);
        IERC20(mp).transfer(address(manager.members("MPAddress")),toMpAmount);
        ITokenStake(manager.members("MPAddress")).update(toMpAmount);

        pool.accSushiPerShare = pool.accSushiPerShare.add(rewardAmount.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
        emit UpdatePool(_pid, block.timestamp);
    }
    function deposit(uint256 _pid, uint256[] memory tokenIDList) public{
        require(pauseStake == false, "function is suspended");
        require(tokenIDList.length > 0, "Cannot stake 0");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        uint256 _amount = _stake(_pid,tokenIDList);
        deposit_In(_pid,_amount);
        updatePool(_pid);

        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(msg.sender);
        if(userTotalWeight > 0){
            userInfo[_pid][msg.sender].rewardDebt = userTotalWeight.mul(poolInfo[_pid].accSushiPerShare).div(1e12);
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
           
            uint256 pending = userTotalWeight.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
            if(pending>0){
                user.pendingReward = user.pendingReward.add(pending);
            }
            user.rewardDebt = userTotalWeight.mul(pool.accSushiPerShare).div(1e12);
        } 
    }

    function updateRewardDebt(address _user) external {
        require(msg.sender == address(promote), "promoteOwner");
        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(_user);
        if(userTotalWeight > 0){
            userInfo[0][_user].rewardDebt = userTotalWeight.mul(poolInfo[0].accSushiPerShare).div(1e12);
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
            lockedTime[tokenID] = block.timestamp;
            (,,uint256 Grade,,,,) = INFT(pool.lpToken).starAttributes(tokenID);
            require(Grade != 0, "Only offical nft can be stake");

            // 計數lv>1的nft數量
            if(Grade > 1){
                user.lvMore1Count++;
                if(user.lvMore1Count == 1){
                    IPromote(promote).updateUserBouns(msg.sender);
                }
            }

            totalAmount = totalAmount.add(nftweight[Grade - 1]);
            
            isInStating[msg.sender][tokenID] = true;
            user._nftBalances.push(tokenID);
            emit DepositNFT(msg.sender,_pid,tokenID);
        }

        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount.add(len);           //更新总抵押nft数量
        INFT(pool.lpToken).batchTransferFrom(msg.sender,address(this),amount);
    }

    function withdraw(uint256 _pid,uint256 tokenid) public{
        require(pauseWithdraw == false, "function is suspended");
        require(isInStating[msg.sender][tokenid] == true,"not ownerOf");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        uint256 amount = withdrawNFT(_pid,tokenid);
        withdraw_in(_pid,amount);
        updatePool(_pid);
        
        // 算個人負債
        uint256 userTotalWeight = getUserTotalWeight(msg.sender);
        if(userTotalWeight > 0){
            userInfo[_pid][msg.sender].rewardDebt = userTotalWeight.mul(poolInfo[_pid].accSushiPerShare).div(1e12);
        }
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw_in(uint256 _pid, uint256 _amount) internal {
        IPromote(promote).redem(msg.sender , 0, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    function getReward(uint256 _pid) public payable{
        require(pauseGetReward == false, "function is suspended");
        updatePool(_pid);
        claimReward(_pid, msg.sender);
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.pendingReward>0){
            safeSushiTransfer(msg.sender, user.pendingReward);
            user.receivedReward = user.receivedReward.add(user.pendingReward);
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
        uint256 indexLast = len.sub(1);
        uint256 TiD = 0;
        for(uint256 i = 0;i < len; i++){
            TiD = user._nftBalances[i];
            if(TiD == tokenID){
                index = i;
                break;
            } 
        }
        uint256 lastTokenId = user._nftBalances[indexLast];
        user._nftBalances[index] = lastTokenId;
        user._nftBalances.pop();
        require(block.timestamp.sub(lockedTime[tokenID]) >= fifteenDays,"NO Enough Time to lock");  
        (,,uint256 Grade,,,,)= INFT(pool.lpToken).starAttributes(tokenID); 

        // 計數lv>1的nft數量
        if(Grade > 1){
            user.lvMore1Count--;
        }

        // 取消算力額外加成
        if(user.lvMore1Count == 0) {
            IPromote(promote).updateUserBouns(msg.sender);
        }
        
        totalAmount = nftweight[Grade - 1];
        isInStating[msg.sender][tokenID] = false;
        delete lockedTime[tokenID];
        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount.sub(1);
        emit WithdrawNFT(msg.sender,_pid,tokenID);
        INFT(pool.lpToken).transferFrom(address(this),msg.sender,tokenID);
    }

    function safeSushiTransfer(address _to, uint256 _amount) internal {
        uint256 sushiBal = mp.balanceOf(address(this));
        if (_amount > sushiBal) {
            mp.transfer(_to, sushiBal);
        } else {
            mp.transfer(_to, _amount);
        }
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
        uint256 token_price = usd_balance.mul(1e18).div(rea_balance);
        return token_price;
    }

    function getUserTotalWeight(address _user) public view returns(uint256 userTotalWeight){
        IPromote._UserInfo memory _userInfo = IPromote(promote).getUser(_user);
        if(!_userInfo.isValid){
            return 0;
        }

        IPromote.User3GenWeight memory _user3Gen = IPromote(promote).getUser3GenWeight(_user);

        if(_user3Gen.gen3Weight > 0){
            userTotalWeight = userTotalWeight.add(_user3Gen.gen3Weight.mul(_user3Gen.gen3Bonus).div(100));
        }

        if(_user3Gen.gen2Weight > 0){
            userTotalWeight = userTotalWeight.add(_user3Gen.gen2Weight.mul(_user3Gen.gen2Bonus).div(100));
        }

        if(_user3Gen.gen1Weight > 0){
            userTotalWeight = userTotalWeight.add(_user3Gen.gen1Weight.mul(_user3Gen.gen1Bonus).div(100));
        }
        userTotalWeight = userTotalWeight.add(_userInfo.weight);
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

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";

abstract contract Member is ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

pragma solidity ^0.7.0;

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
    function mintFrom(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;
// SPDX-License-Identifier: SimPL-2.0

abstract contract ContractOwner {
    address public contractOwner = msg.sender;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";

contract Manager is ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
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

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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