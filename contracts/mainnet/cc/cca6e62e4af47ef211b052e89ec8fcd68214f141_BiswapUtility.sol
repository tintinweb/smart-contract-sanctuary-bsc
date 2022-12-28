//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

interface IMasterChef{
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. BSWs to distribute per block.
        uint256 lastRewardBlock; // Last block number that BSWs distribution occurs.
        uint256 accBSWPerShare; // Accumulated BSWs per share, times 1e12. See below.
    }

    function userInfo(uint256 pid, address user) external view returns(UserInfo memory);

    function poolInfo(uint256 pid) external view returns(PoolInfo memory);

    function poolLength() external view returns(uint256);
    function depositedBsw() external view returns(uint256);
    function owner() external view returns(address);
    function BSW() external view returns(address);
    function BSWPerBlock() external view returns(uint256);
    function pendingBSW(uint256 _pid, address _user) external view returns (uint256);
    function totalAllocPoint() external view returns(uint);
}

interface IAutoBSW{
    function withdrawFee() external view returns(uint256);
    function withdrawFeePeriod() external view returns(uint256);
    function userInfo(address) external view returns(
        uint256 shares,
        uint256 lastDepositedTime,
        uint256 BswAtLastUserAction,
        uint256 lastUserActionTime
    );
    function token() external view returns(address);
    function totalShares() external view returns(uint256);
    function owner() external view returns(address);
    function performanceFee() external view returns(uint256);
    function getPricePerFullShare() external view returns(uint256);
    function calculateTotalPendingBswRewards() external view returns(uint256);
    function balanceOf() external view returns(uint256);
    function masterchef() external view returns(address);
}

interface ISmartChef{
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        address lpToken;          // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. BSWs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that BSWs distribution occurs.
        uint256 accBSWPerShare;   // Accumulated BSWs per share, times 1e12. See below.
    }

    function userInfo(address _user) external view returns(UserInfo calldata _userInfo);
    function poolInfo(uint _index) external view returns(PoolInfo calldata _poolInfo);
    function biswap()         external view returns(address _stakeToken);
    function rewardToken()    external view returns(address _earnToken);
    function rewardPerBlock() external view returns(uint _RPB);
    function bonusEndBlock()  external view returns(uint);
    function limitAmount()  external view returns(uint);
    function remainingLimitAmount() external view returns(uint);
    function minStakeHolderPool() external view returns(uint _limitAmount); //only contracts with HP
    function pendingReward(address _user) external view returns (uint256);

}


interface ISmartChefV2{
    struct RewardToken {
        uint rewardPerBlock;
        uint startBlock;
        uint accTokenPerShare; // Accumulated Tokens per share, times 1e12.
        uint rewardsForWithdrawal;
        bool enabled; // true - enable; false - disable
    }

    struct UserInfo {
        RewardToken[] rewardTokens;
        uint[] pendingReward;
        uint totalStakedSupply;
        address stakeToken;
        uint stakingEndBlock;
        uint holderPoolAmount;
        uint holderPoolMinAmount;
        uint stakedAmount;
        uint maxLimitPerUser;
    }
    function pendingReward(address _user) external view returns (address[] memory, uint[] memory);
    function totalStakedSupply() external view returns (uint);
    function getUserStakedAmount(address _user) external view returns(uint);
    function lastRewardBlock() external view returns(uint);
    function getListRewardTokens() external view returns(address[] memory);
    function stakeToken() external view returns(address);
    function stakingEndBlock() external view returns(uint);
    function getHolderPoolAmount(address _user) external view returns(uint);
    function holderPoolMinAmount() external view returns(uint);
    function maxLimitPerUser() external view returns(uint);
    function getUserInfo(address _user) external view returns(UserInfo memory);
    function listRewardTokens(uint) external view returns(address);
    function getUserlimit(address _user) external view returns (uint256);//only nft collectibles
}

interface ISmartChefV2PF {
    struct RewardToken {
        uint128 rewardPerBlock;
        uint128 accTokenPerShare; // Accumulated Tokens per share, times 1e12.
        uint128 rewardsForWithdrawal;
        uint128 precisionFactor;
        uint32 startBlock;
        bool enabled; // true - enable; false - disable
    }

    struct UserInfo {
        RewardToken[] rewardTokens;
        uint[] pendingReward;
        uint totalStakedSupply;
        IERC20 stakeToken;
        uint stakingEndBlock;
        uint holderPoolAmount;
        uint holderPoolMinAmount;
        uint stakedAmount;
        uint maxLimitPerUser;
    }
    function pendingReward(address _user) external view returns (address[] memory, uint[] memory);
    function totalStakedSupply() external view returns (uint);
    function getUserStakedAmount(address _user) external view returns(uint);
    function lastRewardBlock() external view returns(uint);
    function getListRewardTokens() external view returns(address[] memory);
    function stakeToken() external view returns(address);
    function stakingEndBlock() external view returns(uint);
    function getHolderPoolAmount(address _user) external view returns(uint);
    function holderPoolMinAmount() external view returns(uint);
    function maxLimitPerUser() external view returns(uint);
    function getUserInfo(address _user) external view returns(UserInfo memory);
    function listRewardTokens(uint) external view returns(address);
}

interface IERC20{
    function symbol() external view returns(string memory);
    function name() external view returns(string memory);
    function decimals() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
}

interface IPair is IERC20{
    function token0() external view returns(address);
    function token1() external view returns(address);
    function price0CumulativeLast() external view returns(uint);
    function price1CumulativeLast() external view returns(uint);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract BiswapUtility {

    address private owner;
    address private constant operator = 0x321fB1002DD7fa1e8D2Ad5F697ADCdD6dFA6da13;
    IMasterChef constant masterChef = IMasterChef(0xDbc1A13490deeF9c3C12b44FE77b503c1B061739);


    enum PoolType {AutoBSW, MasterChef, SmartChef, SmartChefHP, SmartChefV2, SmartChefV2PF, SmartChefNFTCollectibles}
//                   1          2           3           3           4               4                 4
    struct Token {
        address tokenAddress;
        uint decimals;
        string symbol;
        string name;
        uint userBalance;
    }

    struct UserData{
        uint token1Allowance;
        uint[] pendingReward;
        uint holderPoolBalance;
        uint userShares;
        uint lastActionTimestamp;
        uint stakedBalance;
    }

    struct PoolInfo {
        PoolType poolType;
        address poolAddress;
        Token token1;
        Token token2; //OPTIONAL
        Token stakedToken;
        uint[] tokensPerBlock;
        uint endBlock;
        uint limitPerUser;
        uint holderPoolRequire;
        uint totalStaked;
        uint performanceFee;
        uint withdrawalFee;
        uint withdrawalFeePeriod;
        bool inProd;
        string projectLink;
        uint8[] tag;
        UserData userData;
        uint sortId;
    }

    struct PoolInstance{
        address poolAddress;
        PoolType poolType; //
        bool    inProd;
        string  projectLink;
        uint8[] tag;
    }

    struct Farm {
        uint pid;
        uint[] tags;
        address lpAddress;
        Token token0;
        Token token1;
        uint112[2] reserves;
        uint price;
        uint mcLpBalance;
        uint userLpBalance;
        uint allowance;
        uint allocPoint;
        uint pendingBSW;
        uint userStakedAmount;
        uint sortId;
    }

    address[] public pools;

    mapping(address => PoolInstance) public poolInstances;
    mapping(uint => uint[]) public farmsTags; // farms tags mapping pid => tags[]
    mapping(address => uint) public sortPools;
    mapping(uint => uint) public sortFarms;
    uint lastSortId;

    modifier onlyOwner() {
        require(owner == msg.sender || operator == msg.sender, 'only Owner or Operator');
        _;
    }

    function poolInstancesLength() public view returns(uint){
        return pools.length;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function poolExist(address _pool) public view returns(bool){
        return poolInstances[_pool].poolAddress == _pool;
    }

    function addPool(PoolInstance[] calldata _pools) public onlyOwner{
        for(uint i; i < _pools.length;i++){
            if(!poolExist(_pools[i].poolAddress)){
                pools.push(_pools[i].poolAddress);
                poolInstances[_pools[i].poolAddress] = _pools[i];
                sortPools[_pools[i].poolAddress] = ++lastSortId;
            }
        }
    }

    function setSortId(uint _sortId) external onlyOwner {
        lastSortId = _sortId;
    }

    struct SortPools {
        address poolAddress;
        uint sortId;
    }

    function addSortPools(SortPools[] calldata sortPoolsIds) external onlyOwner {
        for(uint i; i < sortPoolsIds.length; i++){
            sortPools[sortPoolsIds[i].poolAddress] = sortPoolsIds[i].sortId;
        }
    }

    struct SortFarms {
        uint pid;
        uint[] tags;
        uint sortId;
    }

    function addSortFarms(SortFarms[] calldata sortFarmsIds) external onlyOwner {
        for(uint i; i < sortFarmsIds.length; i++){
            sortFarms[sortFarmsIds[i].pid] = sortFarmsIds[i].sortId;
            farmsTags[sortFarmsIds[i].pid] = sortFarmsIds[i].tags;
        }
    }

    struct FarmsTag{
        uint pid;
        uint[] tags;
    }
    function addFarmsTags(FarmsTag[] calldata _farmTags) external onlyOwner {
        for(uint i; i< _farmTags.length;i++){
            farmsTags[_farmTags[i].pid] = _farmTags[i].tags;
        }
    }

    function updatePool(address poolAddress, PoolInstance calldata _pool) public onlyOwner{
        if(poolExist(poolAddress)){
            poolInstances[poolAddress] = _pool;
        }
    }

    function delPool(address poolAddress) public onlyOwner{
        for(uint i; i< pools.length;i++){
            if(poolAddress == pools[i]){
                delete poolInstances[poolAddress];
                pools[i] = pools[pools.length - 1];
                pools.pop();
            }
        }
    }


    function changeProdMode(address poolAddress, bool state) public onlyOwner {
        poolInstances[poolAddress].inProd = state;
    }

    function changeTagCodes(address poolAddress, uint8[] memory tagCodes) public onlyOwner{
        poolInstances[poolAddress].tag = tagCodes;
    }

    function getTokenInfo(address tokenAddress, address user) public view returns(Token memory token){
        IERC20 tokenContract = IERC20(tokenAddress);
        token.decimals = tokenContract.decimals();
        token.name = tokenContract.name();
        token.symbol = tokenContract.symbol();
        token.tokenAddress = tokenAddress;
        token.userBalance = user == address(0) ? 0 : tokenContract.balanceOf(user);
        return token;
    }

    function getHoldersPoolBalance(address _user) public view returns (uint256 holderPoolBalance) {
        IAutoBSW HP = IAutoBSW(0xa4b20183039b2F9881621C3A03732fBF0bfdff10);
        (uint shares,,,) = HP.userInfo(_user);
        holderPoolBalance = HP.balanceOf() * shares / HP.totalShares();
    }

    function getPool(address user, uint poolId) public view returns(PoolInfo memory poolInfo){
        require(poolId < pools.length, "Wrong length");
        PoolInstance memory currentPool = poolInstances[pools[poolId]];

        if(currentPool.poolType == PoolType.AutoBSW) return getAutoBSWPool(currentPool, user);
        if(currentPool.poolType == PoolType.SmartChef) return getSmartChef(currentPool, user);
        if(currentPool.poolType == PoolType.SmartChefHP) return getSmartChef(currentPool, user);
        if(currentPool.poolType == PoolType.MasterChef) return getMasterChef(currentPool, user);
        if(currentPool.poolType == PoolType.SmartChefV2) return getSmartChefV2(currentPool, user);
        if(currentPool.poolType == PoolType.SmartChefV2PF) return getSmartChefV2PF(currentPool, user);
        if(currentPool.poolType == PoolType.SmartChefNFTCollectibles) return getSmartChefNFTCollectibles(currentPool, user);
    }

    function getActivePoolsIds() public view returns(uint[] memory idsActive, uint[] memory idsInactive){
        uint[] memory tmpIdsActive = new uint[](pools.length);
        uint[] memory tmpIdsInactive = new uint[](pools.length);
        uint blockNumber = block.number;
        uint k = 0;
        uint j = 0;
        for(uint i; i < pools.length; i++){
            PoolInstance memory currentPool = poolInstances[pools[i]];
            uint currentBlockNumber;


            if(currentPool.poolType == PoolType.AutoBSW){
                currentBlockNumber = 1;
            } else if(currentPool.poolType == PoolType.MasterChef){
                currentBlockNumber = 1;
            } else if(currentPool.poolType == PoolType.SmartChef || currentPool.poolType == PoolType.SmartChefHP){
                currentBlockNumber = ISmartChef(currentPool.poolAddress).bonusEndBlock();
            } else if(currentPool.poolType == PoolType.SmartChefV2 || currentPool.poolType == PoolType.SmartChefV2PF || currentPool.poolType == PoolType.SmartChefNFTCollectibles){
                currentBlockNumber = ISmartChefV2(currentPool.poolAddress).stakingEndBlock();
            }

            if(currentBlockNumber == 1 || currentBlockNumber > blockNumber){
                tmpIdsActive[k++] = i;
            } else {
                tmpIdsInactive[j++] = i;
            }
        }

        idsActive = new uint[](k);
        for(uint i; i < k; i++){
            idsActive[i] = tmpIdsActive[i];
        }

        idsInactive = new uint[](j);
        for(uint i; i < j; i++){
            idsInactive[i] = tmpIdsInactive[i];
        }
    }

    function getActivePools(address user) public view returns(PoolInfo[] memory poolInfo){
        (uint[] memory iDs,) = getActivePoolsIds();
        poolInfo = new PoolInfo[](iDs.length);
        for(uint i; i < iDs.length; i++){
            poolInfo[i] = getPool(user, iDs[i]);
        }
    }

    function getInactivePools(address user) public view returns(PoolInfo[] memory poolInfo){
        (, uint[] memory iDs) = getActivePoolsIds();
        poolInfo = new PoolInfo[](iDs.length);
        for(uint i; i < iDs.length; i++){
            poolInfo[i] = getPool(user, iDs[i]);
        }
    }


    function getPools(address user) public view returns(PoolInfo[] memory poolInfo){
        poolInfo = new PoolInfo[](pools.length);
        for(uint i; i < pools.length; i++){
            poolInfo[i] = getPool(user, i);
        }
    }

    function getSmartChefNFTCollectibles(PoolInstance memory poolInstance, address user) public view returns(PoolInfo memory poolInfo){
        ISmartChefV2 pool = ISmartChefV2(poolInstance.poolAddress);


        poolInfo.poolType       = poolInstance.poolType;
        poolInfo.inProd         = poolInstance.inProd;
        poolInfo.poolAddress    = poolInstance.poolAddress;
        poolInfo.projectLink    = poolInstance.projectLink;
        poolInfo.tag            = poolInstance.tag;
        poolInfo.sortId         = sortPools[poolInfo.poolAddress];
        poolInfo.stakedToken    = getTokenInfo(address(pool.stakeToken()), user);
        poolInfo.token1         = getTokenInfo(pool.getListRewardTokens()[0], user);
        poolInfo.token2         = getTokenInfo(pool.getListRewardTokens()[1], user);// TODO change to array

        if (user != address(0)){
            ISmartChefV2.UserInfo memory userInfo = pool.getUserInfo(user);

            uint countOfRewardTokens = userInfo.rewardTokens.length;
            poolInfo.tokensPerBlock = new uint[](countOfRewardTokens);
            for (uint i = 0; i < countOfRewardTokens; i++){
                if (!userInfo.rewardTokens[i].enabled) continue;
                poolInfo.tokensPerBlock[i] = userInfo.rewardTokens[i].rewardPerBlock;
            }

            poolInfo.endBlock                   = userInfo.stakingEndBlock;
            poolInfo.totalStaked                = userInfo.totalStakedSupply;
            poolInfo.limitPerUser               = pool.getUserlimit(user);
            poolInfo.holderPoolRequire          = 0;
            poolInfo.userData.pendingReward     = userInfo.pendingReward;
            poolInfo.userData.token1Allowance   = IERC20(poolInfo.stakedToken.tokenAddress).allowance(user, poolInfo.poolAddress);
            poolInfo.userData.holderPoolBalance = user != address(0) ? getHoldersPoolBalance(user) : 0;
            poolInfo.userData.stakedBalance     = pool.getUserStakedAmount(user);
        }
    }

    function getSmartChefV2(PoolInstance memory poolInstance, address user) public view returns(PoolInfo memory poolInfo){
        ISmartChefV2 pool = ISmartChefV2(poolInstance.poolAddress);
        poolInfo.poolType = poolInstance.poolType;
        poolInfo.inProd = poolInstance.inProd;
        poolInfo.poolAddress = poolInstance.poolAddress;
        poolInfo.sortId = sortPools[poolInfo.poolAddress];
        poolInfo.projectLink = poolInstance.projectLink;
        poolInfo.tag = poolInstance.tag;
        ISmartChefV2.UserInfo memory userInfo = pool.getUserInfo(user);
        poolInfo.stakedToken = getTokenInfo(address(userInfo.stakeToken), user);
        poolInfo.token1 = getTokenInfo(pool.listRewardTokens(0), user);
        poolInfo.token2 = getTokenInfo(pool.listRewardTokens(1), user);
        poolInfo.tokensPerBlock = new uint[](2);
        poolInfo.tokensPerBlock[0] = userInfo.rewardTokens[0].rewardPerBlock;
        poolInfo.tokensPerBlock[1] = userInfo.rewardTokens[1].rewardPerBlock;
        poolInfo.endBlock = userInfo.stakingEndBlock;
        poolInfo.limitPerUser = userInfo.maxLimitPerUser;
        poolInfo.holderPoolRequire = userInfo.holderPoolMinAmount;
        poolInfo.totalStaked = userInfo.totalStakedSupply;
        poolInfo.userData.pendingReward = userInfo.pendingReward;
        poolInfo.userData.token1Allowance = IERC20(poolInfo.stakedToken.tokenAddress).allowance(user, poolInfo.poolAddress);
        poolInfo.userData.holderPoolBalance = user != address(0) ? getHoldersPoolBalance(user) : 0;
        poolInfo.userData.stakedBalance = userInfo.stakedAmount;
        return poolInfo;

    }

    function getSmartChefV2PF(PoolInstance memory poolInstance, address user) public view returns(PoolInfo memory poolInfo){
        ISmartChefV2PF pool = ISmartChefV2PF(poolInstance.poolAddress);
        poolInfo.poolType = poolInstance.poolType;
        poolInfo.inProd = poolInstance.inProd;
        poolInfo.poolAddress = poolInstance.poolAddress;
        poolInfo.sortId = sortPools[poolInfo.poolAddress];
        poolInfo.projectLink = poolInstance.projectLink;
        poolInfo.tag = poolInstance.tag;
        ISmartChefV2PF.UserInfo memory userInfo = pool.getUserInfo(user);
        poolInfo.stakedToken = getTokenInfo(address(userInfo.stakeToken), user);
        poolInfo.token1 = getTokenInfo(pool.listRewardTokens(0), user);
        poolInfo.token2 = getTokenInfo(pool.listRewardTokens(1), user);
        poolInfo.tokensPerBlock = new uint[](2);
        poolInfo.tokensPerBlock[0] = userInfo.rewardTokens[0].rewardPerBlock;
        poolInfo.tokensPerBlock[1] = userInfo.rewardTokens[1].rewardPerBlock;
        poolInfo.endBlock = userInfo.stakingEndBlock;
        poolInfo.limitPerUser = userInfo.maxLimitPerUser;
        poolInfo.holderPoolRequire = userInfo.holderPoolMinAmount;
        poolInfo.totalStaked = userInfo.totalStakedSupply;
        poolInfo.userData.pendingReward = userInfo.pendingReward;
        poolInfo.userData.token1Allowance = IERC20(poolInfo.stakedToken.tokenAddress).allowance(user, poolInfo.poolAddress);
        poolInfo.userData.holderPoolBalance = user != address(0) ? getHoldersPoolBalance(user) : 0;
        poolInfo.userData.stakedBalance = userInfo.stakedAmount;
        return poolInfo;
    }

    function getMasterChef(PoolInstance memory poolInstance, address user) public view returns(PoolInfo memory poolInfo){
        IMasterChef pool = IMasterChef(poolInstance.poolAddress);
        poolInfo.poolType = poolInstance.poolType;
        poolInfo.inProd = poolInstance.inProd;
        poolInfo.poolAddress = poolInstance.poolAddress;
        poolInfo.sortId = sortPools[poolInfo.poolAddress];
        poolInfo.projectLink = poolInstance.projectLink;
        poolInfo.tag = poolInstance.tag;
        poolInfo.stakedToken = getTokenInfo(pool.BSW(), user);
        poolInfo.token1 = poolInfo.stakedToken;
        poolInfo.tokensPerBlock = new uint[](1);
        poolInfo.tokensPerBlock[0] = pool.BSWPerBlock() * pool.poolInfo(0).allocPoint / pool.totalAllocPoint();
        poolInfo.userData.holderPoolBalance = user != address(0) ? getHoldersPoolBalance(user) : 0;
        poolInfo.userData.pendingReward = new uint[](1);
        poolInfo.userData.pendingReward[0] = pool.pendingBSW(0, user);
        IMasterChef.UserInfo memory curInfo = pool.userInfo(0, user);
        poolInfo.userData.stakedBalance = curInfo.amount;
        poolInfo.userData.token1Allowance = IERC20(poolInfo.stakedToken.tokenAddress).allowance(user, poolInfo.poolAddress);
        poolInfo.totalStaked = pool.depositedBsw();
        return poolInfo;
    }

    function getSmartChef(PoolInstance memory poolInstance, address user) public view returns(PoolInfo memory poolInfo){
        ISmartChef pool = ISmartChef(poolInstance.poolAddress);
        poolInfo.poolType = poolInstance.poolType;
        poolInfo.holderPoolRequire = poolInstance.poolType == PoolType.SmartChefHP ? pool.minStakeHolderPool() : 0;
        poolInfo.inProd = poolInstance.inProd;
        poolInfo.poolAddress = poolInstance.poolAddress;
        poolInfo.sortId = sortPools[poolInfo.poolAddress];
        poolInfo.projectLink = poolInstance.projectLink;
        poolInfo.tag = poolInstance.tag;
        poolInfo.endBlock = pool.bonusEndBlock();
        poolInfo.stakedToken = getTokenInfo(pool.poolInfo(0).lpToken, user);
        poolInfo.token1 = getTokenInfo(pool.rewardToken(), user);
        poolInfo.limitPerUser = pool.limitAmount();
        poolInfo.tokensPerBlock = new uint[](1);
        poolInfo.tokensPerBlock[0] = pool.rewardPerBlock();
        poolInfo.totalStaked = IERC20(poolInfo.stakedToken.tokenAddress).balanceOf(poolInstance.poolAddress);
        poolInfo.userData.holderPoolBalance = user != address(0) ? getHoldersPoolBalance(user) : 0;
        poolInfo.userData.pendingReward = new uint[](1);
        poolInfo.userData.pendingReward[0] = pool.pendingReward(user);
        poolInfo.userData.stakedBalance = pool.userInfo(user).amount;
        poolInfo.userData.token1Allowance = IERC20(poolInfo.stakedToken.tokenAddress).allowance(user, poolInfo.poolAddress);

        return poolInfo;
    }

    function getAutoBSWPool(PoolInstance memory poolInstance, address user) public view returns(PoolInfo memory poolInfo){
        IAutoBSW pool = IAutoBSW(poolInstance.poolAddress);
        poolInfo.poolType = poolInstance.poolType;
        poolInfo.inProd = poolInstance.inProd;
        poolInfo.poolAddress = poolInstance.poolAddress;
        poolInfo.sortId = sortPools[poolInfo.poolAddress];
        poolInfo.projectLink = poolInstance.projectLink;
        poolInfo.tag = poolInstance.tag;
        poolInfo.tokensPerBlock = new uint[](1);
        uint pid0_tokenPerBlock = IMasterChef(pool.masterchef()).BSWPerBlock() * IMasterChef(pool.masterchef()).poolInfo(0).allocPoint / IMasterChef(pool.masterchef()).totalAllocPoint();
        poolInfo.tokensPerBlock[0] = pid0_tokenPerBlock * pool.balanceOf() / IMasterChef(pool.masterchef()).depositedBsw();
        poolInfo.endBlock = 0;
        (poolInfo.userData.userShares, poolInfo.userData.lastActionTimestamp, poolInfo.userData.stakedBalance, poolInfo.userData.lastActionTimestamp) = pool.userInfo(user);
        poolInfo.userData.holderPoolBalance = user != address(0) ? getHoldersPoolBalance(user) : 0;
        poolInfo.holderPoolRequire = 0;
        poolInfo.limitPerUser = type(uint).max;
        poolInfo.performanceFee = pool.performanceFee();
        poolInfo.stakedToken = getTokenInfo(pool.token(), user);
        poolInfo.token1 = poolInfo.stakedToken;
        poolInfo.withdrawalFee = pool.withdrawFee();
        poolInfo.withdrawalFeePeriod = pool.withdrawFeePeriod();
        poolInfo.holderPoolRequire = 0;
        poolInfo.totalStaked = pool.balanceOf();
        poolInfo.userData.pendingReward = new uint[](2);
        poolInfo.userData.pendingReward[0] = poolInfo.totalStaked * poolInfo.userData.userShares / pool.totalShares() > poolInfo.userData.stakedBalance ?
            poolInfo.totalStaked * poolInfo.userData.userShares / pool.totalShares() - poolInfo.userData.stakedBalance : 0;
        poolInfo.userData.pendingReward[1] = pool.totalShares();
        poolInfo.userData.token1Allowance = IERC20(poolInfo.stakedToken.tokenAddress).allowance(user, poolInfo.poolAddress);
        return poolInfo;
    }

    function getFarms(address user) external view returns(Farm[] memory farm, uint totalAllocPoint){
        uint FarmsLength =  masterChef.poolLength() - 1;

        totalAllocPoint = masterChef.totalAllocPoint();
        farm = new Farm[](FarmsLength);
        for(uint i = 0; i < FarmsLength; i++){
            farm[i] = getFarm(user, i+1);
        }
    }

    function getFarm(address user, uint pid) public view returns(Farm memory farm){
        require(pid < masterChef.poolLength() && pid > 0, "Wrong pid!");
        IMasterChef.UserInfo memory currentUserInfo = masterChef.userInfo(pid, user);
        IMasterChef.PoolInfo memory currentPoolInfo = masterChef.poolInfo(pid);
        farm.pid = pid;
        farm.tags = farmsTags[pid];
        farm.sortId = sortFarms[pid];
        farm.lpAddress =  currentPoolInfo.lpToken;
        farm.token0 = getTokenInfo(IPair(farm.lpAddress).token0(), user);
        farm.token1 = getTokenInfo(IPair(farm.lpAddress).token1(), user);
        (farm.reserves[0], farm.reserves[1], ) = IPair(farm.lpAddress).getReserves();
        farm.price = uint(farm.reserves[1]) * 1e12 /uint(farm.reserves[0]);
        farm.mcLpBalance = IERC20(farm.lpAddress).balanceOf(address(masterChef));
        farm.userLpBalance = IERC20(farm.lpAddress).balanceOf(user);
        farm.allowance = IERC20(farm.lpAddress).allowance(user, address(masterChef));
        farm.allocPoint = currentPoolInfo.allocPoint;
        farm.pendingBSW = masterChef.pendingBSW(pid, user);
        farm.userStakedAmount = currentUserInfo.amount;
    }
}