// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/SafeERC20.sol";

interface INFT{
    struct starAttributesStruct{
      address origin; // 发布者
      uint256 power; // 算力
      bool offical;
      uint256 createTime; // 鑄造時間
      uint256 openTime; // 開盒時間
      string IpfsHash; // hash
      uint256 level; // 無限等級
      uint8 ethnicity; // 種族類型
      uint256 price; // 當下等值 mca
      bool isAdvanced; // 是否預售盲盒(預售盲盒power1000~1200)
    }
    function transferFrom(address _from,address _to,uint256 _tokenId)external;
    function ownerOf(uint256 _tokenID) external returns (address _owner);
    function getStarAttributes(uint256 _tokenID) external view returns(starAttributesStruct memory nftAttr);
}

interface IPromote{
    struct _UserInfo {
        // 以2代内的權重加總(包含自己)
        uint256 down2GenWeight;

        // 已提領獎勵
        uint256 receivedReward;
        // 該user各等級，已派發獎勵
        uint256[4] EarnReward;

        uint256 rewardDebt;
        bool isValid;
        uint8 level;
        // md 值(一代)
        uint256 numSS;
        // md 值(2代)
        uint256 numGS;
        uint256 weight;
        uint256 depositAsUsdt;
        uint256 depositedMCA;
        uint256 lastRewardRound;
        uint256 pendingReward;
        // 用戶上線
        address f;
        // 下線直推列表
        address[] ss;

        // 有效1代
        address[] validGen1;
        // 有效2代
        address[] validGen2;
    }


    function getUser(address _user) external view returns (_UserInfo calldata);
    function newDeposit(address sender, uint256 amount) external;
    function redem(address sender, uint256 amount) external;
}

interface IStakeWar{
    function pushEthnicityNFT(uint256 tokenId) external;
    function removeEthnicityNFT(uint256 tokenId) external;
}

interface ILottery{
    function injectFunds(uint256 _amount) external;
    function currentLotteryId() external returns(uint256);
}

contract NFT_MasterChef is Initializable, OwnableUpgradeable, Member {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 pendingReward;
        uint256[]  _nftBalances;
        uint256 receivedReward;
    }

    // Info of each pool.
    struct PoolInfo {
        address lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that SUSHIs distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHIs per share, times 1e18. See below.
        uint256 lpSupply;
        uint256 totalStakingNFTAmount;
        uint256 totalReword;
    }


    IERC20 public mca;

    // SUSHI tokens created per block.
    uint256 public sushiPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // The block number when SUSHI mining starts.
    uint256 public startBlock;
    uint256 public sevenDays;

    // 質押價值計算用
    uint256 public tokenMaxLevel;
    // 各種等級 NFT 數量
    mapping (uint256 => uint256) public tokenLevelCounts;

    //mapping(address => uint256[]) public _nftBalances;
    mapping(address => uint256) public userStakeTokenId;
    // uint256 public resetReward;
    uint256 public lastCutPower;
    bool public CUT_FLAG;
    uint8 public CUT_TIME;
    // 減產十次後停止
    uint8 public CUT_MAX_TIME;
    uint256 public lastCutBlock;
    uint256 public CUT_PERIOD_POWER_;
    // 每階增加算力 - 算力須達 250 萬
    uint256 public ADD_PERIOD_POWER_;
    // 滿產 19 階 - 算力須達 4750 萬
    uint256 public MAX_PERIOD_POWER_;
    // 每階增加 432 枚 的 25% 产量（108 枚）- 固定的 - 108 / (24*60*60/3) = 0.00375
    uint256 public ADD_PERIOD_MINING_;

    uint256 public minimalPower;  // 全網最低派獎啟動算力

    bool public pauseStake;
    bool public pauseWithdraw;
    bool public pauseGetReward;

    // 用戶質押分配的值推的獎勵是否已經領取了
    mapping(uint256 => bool) public UserNFTMintUplineReword;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawNFT(address indexed user, uint256 indexed pid, uint256 _tokenID);
    event UpdatePool(uint256 indexed pid, uint256 timestamp);
    event PerShareChanged(uint256 _before, uint256 _current, uint256 block);
    event StakeWarDistributeWinnerUpline(address f, uint8 gen, uint256 amout);
    event StakeWarDistributeWinner(address winerUser, uint256 amount);
    event StakeWarDistributeLoser(address loserUser, uint256 amount, uint256 loserPending);

    struct stakeWarProfit {
        uint256 winAmount;
        uint256 loseAmount;
    }
    mapping(address => stakeWarProfit) public userStakeWarProfit;

    uint256 public mintedMCA;
    uint256 public burnedMCA;

    mapping(address => uint256) public userStakeRewardPendingTime;

    function initialize(
        IERC20 _mca,
        uint256 _startBlock
    ) public initializer {
        __initializeMember();
        __Ownable_init();
        mca = _mca;
        startBlock = _startBlock;
        minimalPower = 30 * 10000;

        init();
    }

    function init() internal initializer {
        sushiPerBlock = 15000000000000000;
        sevenDays = 7 days / 3;
        CUT_MAX_TIME = 10;

        CUT_PERIOD_POWER_ = 45 days / 3;
        // 每階增加算力 - 算力須達 250 萬
        ADD_PERIOD_POWER_ = 250*10000;
        // 滿產 19 階 - 算力須達 4750 萬
        MAX_PERIOD_POWER_ = 4750*10000;
        // 每階增加 432 枚 的 25% 产量（108 枚）- 固定的 - 108 / (24*60*60/3) = 0.00375
        ADD_PERIOD_MINING_ = 3750000000000000;
    }

    function changeMinimalPower(uint256 power) external {
        require(msg.sender == manager.members("owner"), "onlyOwner");
        minimalPower = power;
    }

    function getUser(address _user) external view returns(UserInfo memory) {
        uint256 _pid = 0;
        return userInfo[_pid][_user];
    }

    function getBalances(uint256 _pid, address _user) external view returns (uint256[] memory) {
        return userInfo[_pid][_user]._nftBalances;
    }
    
    function balanceOfByIdex(uint256 _pid,address account) public view returns(uint256){
        return userInfo[_pid][account]._nftBalances[0];
    }


    function changeReward(
        uint256 _CUT_PERIOD_POWER_,
        uint256 _ADD_PERIOD_POWER_,
        uint256 _MAX_PERIOD_POWER_,
        uint256 _ADD_PERIOD_MINING_
    ) public onlyOwner {
        CUT_PERIOD_POWER_ = _CUT_PERIOD_POWER_;
        ADD_PERIOD_POWER_ = _ADD_PERIOD_POWER_;
        MAX_PERIOD_POWER_ = _MAX_PERIOD_POWER_;
        ADD_PERIOD_MINING_ = _ADD_PERIOD_MINING_;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
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
            lpSupply: 0,
            totalStakingNFTAmount:0,
            totalReword: 0
        }));
    }

    function timeLockChange(uint256 _period) public {
        require(msg.sender == manager.members("owner"), "onlyOwner");
        sevenDays = _period;
    }

    // Update the given pool's SUSHI allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    // TODO: View function to see pending SUSHIs on frontend.
    function pendingSushi(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];

        uint256 lpSupply = pool.lpSupply;
        uint256 accSushiPerShare = pool.accSushiPerShare;
        
        if ((lpSupply < minimalPower && accSushiPerShare == 0) || lpSupply == 0) {
            return 0;
        }
        UserInfo storage user = userInfo[_pid][_user];
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accSushiPerShare = accSushiPerShare.add(sushiReward.mul(1e18).div(lpSupply));
        }
        uint256 pending;
        if(user.amount > 0){
            pending = user.amount.mul(accSushiPerShare).div(1e18).sub(user.rewardDebt);
        }
       
        return user.pendingReward.add(pending);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];

        uint256 lpSupply = pool.lpSupply;
        if ((lpSupply < minimalPower && pool.accSushiPerShare == 0) || lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        // 當滿產後
        if (CUT_FLAG && CUT_TIME < CUT_MAX_TIME) {
            // 減產 20%
            if(block.number >= lastCutBlock.add(CUT_PERIOD_POWER_)){
                uint256 newSushiPerBlock = sushiPerBlock.mul(80).div(100);
                emit PerShareChanged(sushiPerBlock, newSushiPerBlock, block.number);
                sushiPerBlock = newSushiPerBlock;
                CUT_TIME = CUT_TIME + 1;
                lastCutBlock = block.number;
            }
        } else if (!CUT_FLAG) {
            // 每階增加 432 枚 的 25% 产量（108 枚）- 固定的 - 108 / (24*60*60/3) = 0.00375，且算力小於 19 階
            if (lpSupply >= lastCutPower.add(ADD_PERIOD_POWER_)) {
                lastCutPower = lastCutPower.add(ADD_PERIOD_POWER_);

                uint256 newSushiPerBlock = sushiPerBlock.add(ADD_PERIOD_MINING_);
                emit PerShareChanged(sushiPerBlock, newSushiPerBlock, block.number);
                sushiPerBlock = newSushiPerBlock;

                // 滿產觸發後就會停止增產了
                if (lpSupply >= MAX_PERIOD_POWER_) {
                    CUT_FLAG = true;
                    lastCutBlock = block.number;
                }
            }
        }

        
        //與上次生產token的相差塊數
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if (multiplier == 0) {
            return;
        }
        // 這段時間的總派發Token * 1 / 1
        uint256 sushiReward = multiplier.mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        // resetReward = resetReward.add(sushiReward);
        pool.totalReword = pool.totalReword.add(sushiReward);
        pool.accSushiPerShare = pool.accSushiPerShare.add(sushiReward.mul(1e18).div(lpSupply));
        
        pool.lastRewardBlock = block.number;
        emit UpdatePool(_pid, block.timestamp);
    }

    function getCurrentTotalReward(uint256 _pid) external view returns(uint256 result){
        PoolInfo storage pool = poolInfo[_pid];
        
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply < minimalPower || lpSupply == 0) {
            return pool.totalReword;
        }
         uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
         if (multiplier == 0) {
            result = pool.totalReword;
        } else {
            result = pool.totalReword + multiplier * sushiPerBlock * pool.allocPoint / totalAllocPoint;
        }
    }

    function deposit(uint256 _pid, uint256 tokenID) public{
        require(pauseStake == false, "function is suspended");
        require(userStakeTokenId[msg.sender] == 0, "can only stake one nft");
        require(manager.members("stakeWar") != address(0), "stakeWar address need to set");

        uint256 _power = _stake(_pid,tokenID);
        deposit_In(_pid,_power);

        userStakeRewardPendingTime[msg.sender] = block.number.add(sevenDays);

        IStakeWar(manager.members("stakeWar")).pushEthnicityNFT(tokenID);
        userStakeTokenId[msg.sender] = tokenID;
    }
    // Deposit LP tokens to MasterChef for SUSHI allocation.
    function deposit_In(uint256 _pid, uint256 _power) internal {
        IPromote(manager.members("MCAStakePool")).newDeposit(msg.sender, _power);
        emit Deposit(msg.sender, _pid, _power);
    }

    function claimReward(address _user) internal {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_user];

        updatePool(0);
        user.pendingReward = user.pendingReward.add(user.amount.mul(pool.accSushiPerShare).div(1e18).sub(user.rewardDebt));
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e18);
    }

    // 更新權重金額
    function updateUserAmount(address _user, uint256 amount, bool isAdd) internal {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_user];
        // 領獎
        claimReward(_user);
        
        if(isAdd){
            user.amount = user.amount.add(amount);
            pool.lpSupply = pool.lpSupply.add(amount);
        }else{
            user.amount = user.amount.sub(amount);
            pool.lpSupply = pool.lpSupply.sub(amount);
        }
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e18);
        updatePool(0);
    }


    function _stake(uint256 _pid,uint256 tokenID) internal returns(uint256 power){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(INFT(pool.lpToken).ownerOf(tokenID) == msg.sender,"not ownerOf");
        INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenID);

        power = nftAttr.power;
        
        user._nftBalances.push(tokenID);
        emit DepositNFT(msg.sender,_pid,tokenID);

        // 更新個人/全網權重
        updateUserAmount(msg.sender, power, true);

        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount.add(1);           //更新总抵押nft数量
        INFT(pool.lpToken).transferFrom(msg.sender,address(this),tokenID);

        // 檢查最高等級的 NFT
        if (nftAttr.level > tokenMaxLevel) {
            tokenMaxLevel = nftAttr.level;
        }

        // 儲存各個等級的 NFT 數
        tokenLevelCounts[nftAttr.level] += 1;
    }

    function withdraw() external {
        require(pauseWithdraw == false, "function is suspended");
        uint256 tokenid = userStakeTokenId[msg.sender];
        require(tokenid != 0,"not stake");

        getReward(0);
        uint256 _power = withdrawNFT(0,tokenid);
        withdraw_In(0, _power);
        delete userStakeRewardPendingTime[msg.sender];

        IStakeWar(manager.members("stakeWar")).removeEthnicityNFT(tokenid);
        updatePool(0);
        delete userStakeTokenId[msg.sender];
    }

    function withdraw_In(uint256 _pid, uint256 _power) internal {
        IPromote(manager.members("MCAStakePool")).redem(msg.sender , _power);
        emit Withdraw(msg.sender, _pid, _power);
    }
    
    function getReward(uint256 _pid) public {
        require(pauseGetReward == false, "function is suspended");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "need stake nft");
        require(manager.members("lottery") != address(0), "lottery member not found");

        // 領獎
        claimReward(msg.sender);
        uint256 pending = user.pendingReward;
        pending = pending.sub(userStakeWarProfit[msg.sender].loseAmount).add(userStakeWarProfit[msg.sender].winAmount);
        uint256 _mintAmont;
        if(pending>0){
            // • 質押後必須等待 7 天後（区块时间）可以無償提領獎勵
            // • 收穫後需再等待7天（區塊時間）才可再進行無償收穫。
            // • 任何时间都可以提领奖励或赎回本金
            // • 而在 7 天內赎回NFT或提領奖励 ，放弃 50%奖励
            if (block.number < userStakeRewardPendingTime[msg.sender]) {
                uint256 giveUp = pending.div(2);
                pending = pending.sub(giveUp);  //  少50%獎勵

                // 其中80% 給lottery
                uint256 payLottery = giveUp.mul(80).div(100);
                _mintAmont = safeMint(manager.members("lottery"), payLottery);
                ILottery(manager.members("lottery")).injectFunds(_mintAmont);

                // 其中10% 給項目方
                uint256 payFunder = giveUp.mul(10).div(100);
                _mintAmont = safeMint(manager.members("funder"), payFunder);

                // 其中10% 銷毀，即不增發
                uint256 needBurn = giveUp.sub(payLottery).sub(payFunder);
                burnedMCA = burnedMCA.add(needBurn);
            }
            _mintAmont = safeMint(msg.sender, pending);

            user.receivedReward = user.receivedReward.add(_mintAmont);
            user.pendingReward = 0; 
            user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e18);
            userStakeWarProfit[msg.sender].loseAmount = 0;
            userStakeWarProfit[msg.sender].winAmount = 0;

            userStakeRewardPendingTime[msg.sender] = block.number.add(sevenDays);
        }
    }

    function withdrawNFT(uint256 _pid,uint256 tokenID) internal returns(uint256 power){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        user._nftBalances.pop();
        
        INFT.starAttributesStruct memory nftAttr = INFT(manager.members("nft")).getStarAttributes(tokenID);
        power = nftAttr.power;
        pool.totalStakingNFTAmount = pool.totalStakingNFTAmount.sub(1);
        emit WithdrawNFT(msg.sender,_pid,tokenID);
        
        // 更新個人/全網權重
        updateUserAmount(msg.sender, power, false);

        INFT(pool.lpToken).transferFrom(address(this),msg.sender,tokenID);

        // 各個等級的 NFT 數
        tokenLevelCounts[nftAttr.level] -= 1;

        // 檢查最高等級的 NFT
        if ((nftAttr.level == tokenMaxLevel) && (tokenLevelCounts[nftAttr.level] == 0)) {
            tokenMaxLevel = nftAttr.level - 1;
        }
    }

    // Safe sushi transfer function, just in case if rounding error causes pool to not have enough SUSHIs.
    function safeSushiTransfer(address _to, uint256 _amount) internal {
        uint256 sushiBal = mca.balanceOf(address(this));
        if (_amount > sushiBal) {
            mca.transfer(_to, sushiBal);
        } else {
            mca.transfer(_to, _amount);
        }
    }

    function safeMint(address _to, uint256 _amount) internal returns(uint256) {
        uint256 MaxSupply = 5000000 * 1e18;
        uint256 oldTotalSupply = mca.totalSupply();
        uint256 newTotalSupply = oldTotalSupply + _amount;
        uint256 newSupply = _amount;

        // 達到上限
        if(MaxSupply == oldTotalSupply){
            return 0;
        }

        if(newTotalSupply > MaxSupply){
            newSupply = MaxSupply - oldTotalSupply;
        }

        mintedMCA = mintedMCA + newSupply;
        mca.mint(_to, newSupply);
        return newSupply;
    }

    // 質押戰爭
    function StakeWarDistribute(address winerUser, address loserUser, uint256 bonus) external {
        require(manager.members("stakeWar") != address(0), "stakeWar contract need set");
        require(msg.sender == manager.members("stakeWar"), "only contract call");
        require(bonus<= 200000 && bonus>= 50000, "bonus not correct");

        // • 战胜方收益将预留 5%给予推荐人（必须是有效地址）若無則保留給战胜方
        // • 战胜方收益将预留 1%给予二级推荐人（必须是有效地址）若無則保留給战胜方
        // • 战胜方收益获得 94%（必须是有效地址） 

        // uint256 winerPending = pendingSushi(0, winerUser);
        uint256 loserPending = pendingSushi(0, loserUser).add(userStakeWarProfit[loserUser].winAmount).sub(userStakeWarProfit[loserUser].loseAmount);

        address f = IPromote(manager.members("MCAStakePool")).getUser(winerUser).f;
        address ff = IPromote(manager.members("MCAStakePool")).getUser(f).f;
        
        uint256 result = loserPending.mul(bonus).div(1000000);

        uint256 dist1 = 0;
        uint256 dist2 = 0;
        // 如果上線為有效用戶
        if (f != address(0)) {
            if (userInfo[0][f]._nftBalances.length > 0) {
                dist1 = result.mul(5).div(100);
                userStakeWarProfit[f].winAmount += dist1;
                emit StakeWarDistributeWinnerUpline(f, 1, dist1);
            }
        }

        // 如果上線二代為有效用戶
        if (ff != address(0)) {
            if (userInfo[0][ff]._nftBalances.length > 0) {
                dist2 = result.mul(1).div(100);
                userStakeWarProfit[ff].winAmount += dist2;
                emit StakeWarDistributeWinnerUpline(ff, 2, dist2);
            }
        }

        uint256 d3 = result.sub(dist1).sub(dist2);
        userStakeWarProfit[winerUser].winAmount += d3;
        userStakeWarProfit[loserUser].loseAmount += result;

        emit StakeWarDistributeWinner(winerUser, d3);
        emit StakeWarDistributeLoser(loserUser, result, loserPending);
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

import "./ContractOwner.sol";
import "./Manager.sol";

abstract contract Member is ContractOwner {
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

contract Manager is ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
    constructor () {
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