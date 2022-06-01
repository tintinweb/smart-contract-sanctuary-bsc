// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/IUniswapV2Pair.sol";

contract Promote is Initializable, Member {
    
    using SafeMath for uint256;
    uint256 public totalDepositedAmount;
    uint256 public round;
    uint256 public totalRewards;

    uint256 public timeLock;

    IERC20 public usdt;
    IERC20 public mca;
    IUniswapV2Pair public pair;

    uint256 gen1Bonus;
    uint256 gen2Bonus;

    struct DaliyInfo {
        uint256 daliyDividends;
        uint256 rewardedAmount;
        // 各等級2代加總權重
        uint256[4] totalDown2GenWeight;
        // 各等級，有效用戶數
        uint256[] perNodeNum;
    }

    struct UserInfo {
        // 以2代内的權重加總(包含自己)
        uint256 down2GenWeight;

        // 已提領獎勵
        uint256 receivedReward;

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
        // 下線群組
        address[] ss;

        // 有效1代
        address[] validGen1;
        // 有效2代
        address[] validGen2;
    }

    struct pendingDeposit{
        uint256 pendingMCA;
        uint256 pendingAsUsdt;
    }

    mapping(address=>pendingDeposit) public userPending;
    
    mapping(uint256 => DaliyInfo) public daliyInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public isGamer;
    mapping(uint256 => uint256) public roundTime;
    mapping(address => uint256) public lockRequest;
    mapping(address => mapping(address => uint256)) public userValidGen1Index;
    mapping(address => mapping(address => uint256)) public userValidGen2Index;
    
    // MD 值（直推）
    uint256[] internal numThresholdSS;
    // MD 值（2代內）
    uint256[] internal numThresholdGS;
    // 質押 MCA 等級
    uint256[] internal amountThreshould;
    // 獎勵係數
    uint256[] internal rewardPrecent;

    event LevelChange(address _user, uint8 beforeLv, uint8 curLv);
    event NewRound(uint256 _round);
    event NewJoin(address _user, address _f);
    event WithdrawRequest(address _user);
    event Withdraw(address _user, uint256 _amount);
    event GetReward(address _user, uint256 _amount);
    event Deposit(address _user, uint256 _amount);
    event UpdatePool(uint256 amount);
    event Recycle(uint256 amount);
    event RecoverTokens(address token, uint256 amount, address to);

    address public genesis;

    modifier onlyPool{
        require(msg.sender == address(manager.members("NFTStakePool")), "this function can only called by pool address!");
        _;
    }
    
    modifier validSender{
        require(msg.sender == address(manager.members("market")) || msg.sender == address(manager.members("auction")) || msg.sender == manager.members("nft"));
        _;
    }

    function initialize(IERC20 _mca, IERC20 _usdt, IUniswapV2Pair _pair, address _genesis) public initializer {
        __initializeMember();
        init();
        mca = _mca;
        usdt = _usdt;
        pair = _pair;
        isGamer[_genesis] = true;
        genesis = _genesis;
        
        uint8 i = 0;
        while( i < 4) {
            daliyInfo[0].perNodeNum.push(0);
            i++;
        }
    }

    function setInitialize(IERC20 _mca, IERC20 _usdt, IUniswapV2Pair _pair ) external {
        require(msg.sender == manager.members("owner"), "owner");
        mca = _mca;
        usdt = _usdt;
        pair = _pair;
    }
    function init() internal initializer {
        timeLock = 0 days;
        numThresholdSS = [3,9,18,40];
        numThresholdGS = [10,27,52,108];
        amountThreshould = [1000*1e18, 2000*1e18, 4000*1e18, 8000*1e18];
        rewardPrecent = [30, 40, 20, 10];
        gen1Bonus = 50;
        gen2Bonus = 25;
    }

    function getSS(address _user) public view returns (address[] memory) {
        return userInfo[_user].ss;
    }
    
    
    function getDaily(uint256 _round)  public view returns(DaliyInfo memory) {
        return daliyInfo[_round];
    }
    function getDaliyPerNode(uint256 _round) public view returns(uint256[] memory) {
        return daliyInfo[_round].perNodeNum;
    }
    function bind(address downline, address binding) external {
        address _downline = msg.sender;
        if (msg.sender == manager.members("owner")){
            _downline = downline;
        } else {
            // 只有在 user bind 時檢查
            require(msg.sender != binding, "can not bindself");
        }
        UserInfo storage user = userInfo[_downline];
        require((isGamer[binding] == true) && (isGamer[_downline] == false), "origin & upline must in game!");
        
        user.f = binding;
        isGamer[_downline] = true;
       
        // 更新下線群組
        userInfo[user.f].ss.push(_downline);
        emit NewJoin(_downline, user.f);
    }

    // NFT 解質押後會呼叫
    function redem(address sender, uint256, uint256 amount) external onlyPool {
        UserInfo storage user = userInfo[sender];
        require(isGamer[sender] == true, "origin must in game!");
        address f = user.f;
        address ff = userInfo[f].f;
        
        user.weight -= amount;

        userDown(sender);
        if(f != address(0)) {
            evoDown(f,1);
        }
        if(ff != address(0)) {
            evoDown(ff,2);
        }
        
        // 更新權重
        // 自己
        user.down2GenWeight = user.down2GenWeight.sub(amount);
        
        // 所有 所影響總權重
        uint256[4] memory subTotalUpdateWeight;

        // 更新上線權重 & 全網總權重
        address _user = sender;
        for(uint8 i=0; i < 2; i++) {
            _user = userInfo[_user].f;
            if(_user == address(0)){
                break;
            }
            
            // 更新上線2代權重加總
            claimReward(_user);

            uint256 addWeight;
            // 計算user
            if(i == 0){
                addWeight = amount * gen1Bonus / 100;
            }

            if(i == 1){
                addWeight = amount * gen2Bonus / 100;
            }

            userInfo[_user].down2GenWeight = userInfo[_user].down2GenWeight.sub(addWeight);

            // 計算全網權重
            uint256 _level = userInfo[_user].level;
            if(_level > 0){
                subTotalUpdateWeight[_level-1] = subTotalUpdateWeight[_level-1].add(addWeight);
            }
        }

        // 更新個等級權重
        for(uint8 i=0 ;i<4 ;i++){
            daliyInfo[round].totalDown2GenWeight[i] = daliyInfo[round].totalDown2GenWeight[i].sub(subTotalUpdateWeight[i]) ;
        }
    }

    

    function userDown(address sender) internal {
        userInfo[sender].isValid = false;
        uint8 level1 = userInfo[sender].level;
        if (userInfo[sender].level > 0) {
            levelChange(sender, level1, 0);
            emit LevelChange(sender, level1, 0);
        }
    }

    // 代數gen 1~2
    function evoDown(address _user, uint8 gen) internal {
        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS--;

            // 取要刪掉user的index
            uint256 _delIndex = userValidGen1Index[_user][msg.sender];

            uint256 lastIndex = userInfo[_user].validGen1.length - 1;
            if (_delIndex == lastIndex){
                userInfo[_user].validGen1.pop(); 
            } else {

                userInfo[_user].validGen1[_delIndex] = userInfo[_user].validGen1[lastIndex];
                userInfo[_user].validGen1.pop(); 
                // 更新最後一個index
                userValidGen1Index[_user][userInfo[_user].validGen1[_delIndex]] = _delIndex;
            }
            delete userValidGen1Index[_user][msg.sender];
        }


        // 刪掉user第二代下線
        if(gen == 2){
            // 取要刪掉user的index
            uint256 _delIndex = userValidGen2Index[_user][msg.sender];

            uint256 lastIndex = userInfo[_user].validGen2.length - 1;
            if (_delIndex == lastIndex){
                userInfo[_user].validGen2.pop(); 
            } else {

                userInfo[_user].validGen2[_delIndex] = userInfo[_user].validGen2[lastIndex];
                userInfo[_user].validGen2.pop(); 
                // 更新最後一個index
                userValidGen2Index[_user][userInfo[_user].validGen2[_delIndex]] = _delIndex;
            }
            delete userValidGen2Index[_user][msg.sender];
        }
        userInfo[_user].numGS--;
        
        // 檢查升等
        uint8 level1 = userInfo[_user].level;
        uint8 level2 = updateLevel(_user);
        if (level1 != level2) {
            levelChange(_user, level1, level2);
            emit LevelChange(_user, level1, level2);
        }
    }
    
    // NFT 質押後會呼叫
    function newDeposit(address sender,uint256, uint256 amount) external onlyPool {
        require(isGamer[sender] == true, "origin must in game!"); // 
        UserInfo storage user = userInfo[sender];

        address f = user.f;
        address ff = userInfo[f].f;

        claimReward(sender);
        user.weight += amount;

        // 質押後，該用戶變為有效用戶
        userUp(sender);
        evo(f,1);
        if (ff != address(0)) {
            evo(ff, 2);
        }

        // 更新權重
        // 自己
        userInfo[sender].down2GenWeight = userInfo[sender].down2GenWeight.add(amount);

        uint256[4] memory addTotalUpdateWeight;
        uint256 userLevel = userInfo[sender].level;
        if(userLevel > 0){
            addTotalUpdateWeight[userLevel-1] = addTotalUpdateWeight[userLevel-1].add(amount);
        }
         // 更新上線權重 & 全網總權重
        address _user = sender;
        for(uint8 i=0; i < 2; i++) {
            _user = userInfo[_user].f;
            if(_user == address(0)){
                break;
            }

            // 更新上線2代權重加總
            claimReward(_user);

            uint256 addWeight;
            // 計算user
            if(i == 0){
                addWeight = amount * gen1Bonus / 100;
            }

            if(i == 1){
                addWeight = amount * gen2Bonus / 100;
            }

            userInfo[_user].down2GenWeight = userInfo[_user].down2GenWeight.add(addWeight);

            uint256 _level = userInfo[_user].level;
            if(_level > 0){
                addTotalUpdateWeight[_level-1] = addTotalUpdateWeight[_level-1].add(addWeight);
            }
        }
        
        // 更新個等級權重
        for(uint8 i=0 ;i<4 ;i++){
            daliyInfo[round].totalDown2GenWeight[i] = daliyInfo[round].totalDown2GenWeight[i].add(addTotalUpdateWeight[i]);
        }
    }

    function userUp(address sender) internal {
        userInfo[sender].isValid = true;

        uint8 level1 = userInfo[sender].level;
        uint8 level2 = updateLevel(sender);
        if (level1 != level2) {
            levelChange(sender, level1, level2);
            emit LevelChange(sender, level1, level2);

        }
    }

    // 更上線信息（如果提升了等级将沉淀奖励）
    function evo(address _user, uint8 gen) internal {
        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS++;

            userInfo[_user].validGen1.push(msg.sender);
            userValidGen1Index[_user][msg.sender] = userInfo[_user].validGen1.length - 1;
        }
        if(gen == 2){
            userInfo[_user].validGen2.push(msg.sender);
            userValidGen2Index[_user][msg.sender] = userInfo[_user].validGen2.length - 1;
        }
        userInfo[_user].numGS++;

        // 檢查升等
        uint8 level1 = userInfo[_user].level;
        uint8 level2 = updateLevel(_user);
        if (level1 != level2) {
            levelChange(_user, level1, level2);
            emit LevelChange(_user, level1, level2);
        }
    }

    function claimReward(address _user) internal {
        userInfo[_user].pendingReward = userInfo[_user].pendingReward.add(settleRewards(_user));
        userInfo[_user].lastRewardRound = round;
    }
    
    function update(uint256 amount) external validSender {
        if(block.timestamp >= roundTime[round] + 24 hours) {
            round++;
            roundTime[round] = block.timestamp;
            if (round > 0) {
                daliyInfo[round] = daliyInfo[round -1];
            }
            daliyInfo[round].daliyDividends = 0;
            daliyInfo[round].rewardedAmount = 0;
            if(round > 16) {
                uint256 _p = daliyInfo[round - 16].daliyDividends.sub(daliyInfo[round - 16].rewardedAmount);
                if(_p > 0 && IERC20(mca).balanceOf(address(this)) >= _p){
                    IERC20(mca).transfer(address(manager.members("NFTStakePool")), _p);
                    emit Recycle(_p);    // 回收
                }
            }
            emit NewRound(round);
        }
        daliyInfo[round].daliyDividends = daliyInfo[round].daliyDividends.add(amount);
        totalRewards = totalRewards.add(amount);
        emit UpdatePool(amount);
    }

    function getUser(address _user) external view returns (UserInfo memory) {
        return userInfo[_user];
    }

    function getNowDaily() external view returns (DaliyInfo memory) {
        return daliyInfo[round];
    }
    
    function deposit(uint256 amount) external {
        require(lockRequest[msg.sender] == 0, "In withdraw");
        require(amount > 0);
        require(isGamer[msg.sender] == true);
        
        uint256 usd_balance;
        uint256 mca_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, mca_balance , ) = pair.getReserves();   
        }  
        else{
          (mca_balance, usd_balance , ) = pair.getReserves();           
        }
    
        IERC20(mca).transferFrom(msg.sender, address(this), amount);
        userInfo[msg.sender].depositedMCA = userInfo[msg.sender].depositedMCA.add(amount);
        userInfo[msg.sender].depositAsUsdt = userInfo[msg.sender].depositAsUsdt.add(amount.mul(usd_balance.mul(1e18).div(mca_balance)).div(1e18));
        uint8 old = userInfo[msg.sender].level;
        uint8 newlevel = updateLevel(msg.sender);
        if (old != newlevel) {
            levelChange(msg.sender, old, newlevel);
            emit LevelChange(msg.sender, old, newlevel);
        }
        totalDepositedAmount = totalDepositedAmount.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function updateLevel(address user) internal view returns (uint8){
        // 質押 MCA 的等級
        uint8 level1;
        // MD 值（直推）
        uint8 level2;
        // MD 值（兩代）
        uint8 level3;

        // 無效用戶，無法升級
        if(!userInfo[user].isValid){
            return 0;
        }
        
        uint256 amount = userInfo[user].depositAsUsdt;
        for(uint8 i = 4; i > 0;i--) {
            level1 = level1==0 && amount >= amountThreshould[i - 1]? i : level1;
            level2 = level2==0 && userInfo[user].numSS >= numThresholdSS[i-1] ? i : level2;
            level3 = level3==0 && userInfo[user].numGS >= numThresholdGS[i-1] ? i : level3;
        }

        uint8 mdLevel = level2 < level3 ? level2:level3;
        return level1 < mdLevel ? level1:mdLevel;
    }
    
    function getReward() public {
        uint256 reward = settleRewards(msg.sender);
        uint256 payReward = reward.add(userInfo[msg.sender].pendingReward);
        require(IERC20(mca).balanceOf(address(this)) >= payReward, "contract balance too low");
        IERC20(mca).transfer(msg.sender, payReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward.add(payReward);
        userInfo[msg.sender].pendingReward = 0;
        userInfo[msg.sender].lastRewardRound = round;
        emit GetReward(msg.sender, reward);
    }
    
    function withdraw() public {
        require(lockRequest[msg.sender] !=0 && block.timestamp >= lockRequest[msg.sender].add(timeLock), "locked");
        IERC20(mca).transfer(msg.sender, userPending[msg.sender].pendingMCA);
        lockRequest[msg.sender] = 0;
        totalDepositedAmount = totalDepositedAmount.sub(userPending[msg.sender].pendingMCA);
        delete userPending[msg.sender];
        emit Withdraw(msg.sender, userPending[msg.sender].pendingMCA);
    }

    function withdrawRequest() external {
        require(lockRequest[msg.sender] == 0, "is in pending");
        getReward();
        userPending[msg.sender].pendingMCA = userInfo[msg.sender].depositedMCA;
        userPending[msg.sender].pendingAsUsdt = userInfo[msg.sender].depositAsUsdt;
        userInfo[msg.sender].depositedMCA = 0;
        userInfo[msg.sender].depositAsUsdt = 0;
        lockRequest[msg.sender] = block.timestamp;


        levelChange(msg.sender, userInfo[msg.sender].level, 0);
        emit LevelChange(msg.sender, userInfo[msg.sender].level, 0);
        emit WithdrawRequest(msg.sender);

        if(timeLock == 0){
            withdraw();
        }
    }
    
    function pendingRewards(address _user) external view returns (uint256 reward){
        if (userInfo[_user].level == 0) {
            return 0;
        }
        // uint256 num = userInfo[_user].numSS;
        uint8 level = userInfo[_user].level;
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        for(i; i >0; i--) {
            if(daliyInfo[round-i].daliyDividends == 0 || userInfo[_user].down2GenWeight == 0 || daliyInfo[round-i].totalDown2GenWeight[level-1] == 0){
                continue;
            }
            // (daliyDividends * level 加成百分比) * (用戶3代算力 / 當前等級3代全網總算力) = 元域池 * 全網站比
            reward = reward.add(daliyInfo[round-i].daliyDividends.mul(rewardPrecent[userInfo[_user].level-1]).div(100).mul(userInfo[_user].down2GenWeight).div(daliyInfo[round-i].totalDown2GenWeight[level-1]));
        }
        reward = reward.add(userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if (userInfo[_user].level == 0) {
            return 0;
        }
        uint8 level = userInfo[_user].level;
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        uint256 roundReward;
        for(i; i >0; i--) {
            if(daliyInfo[round-i].daliyDividends == 0 || userInfo[_user].down2GenWeight == 0 || daliyInfo[round-i].totalDown2GenWeight[level-1] == 0){
                continue;
            }
            // (daliyDividends * level 加成百分比) * (用戶3代算力 / 當前等級3代全網總算力) = 元域池 * 全網站比
            roundReward = daliyInfo[round-i].daliyDividends.mul(rewardPrecent[userInfo[_user].level-1]).div(100).mul(userInfo[_user].down2GenWeight).div(daliyInfo[round-i].totalDown2GenWeight[level-1]);
            reward = reward.add(roundReward);
            daliyInfo[round-i].rewardedAmount+=roundReward;
        }
    }

    function levelChange(address _user , uint8 oldLevel, uint8 newLevel)internal{
        // 領獎
        claimReward(_user);

        // 進行升級
        if (oldLevel > 0) {
            daliyInfo[round].perNodeNum[oldLevel - 1]--;
        }
        if (newLevel > 0) {
            daliyInfo[round].perNodeNum[newLevel - 1]++;
        }
        userInfo[_user].level = newLevel;

        // after new level

        // 當有人升級，更新該等級全網權重
        uint256 _down2GenWeight = userInfo[_user].down2GenWeight;
        if(oldLevel > 0){
            daliyInfo[round].totalDown2GenWeight[oldLevel-1] = daliyInfo[round].totalDown2GenWeight[oldLevel-1].sub(_down2GenWeight);
        }
        if(newLevel > 0){
            daliyInfo[round].totalDown2GenWeight[newLevel-1] = daliyInfo[round].totalDown2GenWeight[newLevel-1].add(_down2GenWeight);
        }
    }

    function changeTimeLock(uint256 _timeLock) external {
        require(msg.sender == manager.members("owner"), "owner");
        timeLock = _timeLock;
    }

    function changeNumThresholdSS(uint256[] memory _data) external {
        require(msg.sender == manager.members("owner"), "owner");
        numThresholdSS = _data;
    }
    
    function changeNumThresholdGS(uint256[] memory _data) external {
        require(msg.sender == manager.members("owner"), "owner");
        numThresholdGS = _data;
    }

    function recoverTokens(address token, uint256 amount, address to) external {
        require(msg.sender == manager.members("owner"), "owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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