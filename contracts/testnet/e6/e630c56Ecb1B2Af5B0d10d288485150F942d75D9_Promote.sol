// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";



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

interface IPreacher {
    function update(uint256 amount) external;
    function updateWeight(address _user, uint256 amount, bool isAdd) external;
    function upgradePreacher(address _user) external;
    function checkIsPreacher(address _user) external view returns (bool);
}


interface IMasterChef {
    struct _UserInfo {
        uint256 receivedReward;
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 pendingReward;
        uint256[]  _nftBalances;
        uint256 lvMore1Count;   // 擁有level > 1的nft數量
    }
    function getUser(address _user) external view returns(_UserInfo memory);
    function claimReward(uint256 _pid, address _user) external;
    function updateRewardDebt(address _user) external;
}

contract Promote is Member {
    
    using SafeMath for uint256;
    uint256 public totalDepositedAmount;
    uint256 public round;
    uint256 public totalRewards;

    uint256 public timeLock = 15 hours;

    IERC20 public usdt;
    IERC20 public mp;
    IUniswapV2Pair public pair;

    struct DaliyInfo {
        uint256 daliyDividends;
        uint256 rewardedAmount;
        // 各等級三代加總權重
        uint256[4] totalDown3GenWeight;
        // 各等級，有效用戶數
        uint256[] perNodeNum;
    }

    struct UserInfo {
        // 上線八代
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
        

    struct pendingDeposit{
        uint256 pendingMP;
        uint256 pendingAsUsdt;
    }

    mapping(address=>pendingDeposit) public userPending;
    
    mapping(uint256 => DaliyInfo) public daliyInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => User3GenWeight) public user3GenWeight;
    uint256 public total3GenBonusWeight;    // 全網（包含無效user權重）
    uint256 public invalid3GenBonusWeight;    // 無效user的權重加總
    mapping(address => bool) public isGamer;
    mapping(uint256 => uint256) public roundTime;
    mapping(address => uint256) public lockRequest;
    
    // MD 值（直推）
    uint256[] internal numThresholdSS = [6,8,12,15];
    // MD 值（三代內）
    uint256[] internal numThresholdGS = [30,60,120,180];
    // 質押 MP 等級
    uint256[] internal amountThreshould = [1000*1e18, 2000*1e18, 3000*1e18, 4000*1e18];
    // 獎勵係數
    uint256[] internal rewardPrecent = [40, 30, 20, 10];

    event LevelChange(address _user, uint8 beforeLv, uint8 curLv);
    event NewRound(uint256 _round);
    event NewJoin(address _user, address _f);
    event WithdrawRequest(address _user);
    event Withdraw(address _user, uint256 _amount);
    event GetReward(address _user, uint256 _amount);
    event Deposit(address _user, uint256 _amount);
    event UpdatePool(uint256 amount);
    event Recycle(uint256 amount);

    modifier onlyPool{
        require(msg.sender == address(manager.members("nftMasterChef")), "this function can only called by pool address!");
        _;
    }
    
    modifier validSender{
        require(msg.sender == address(manager.members("updatecard")) || msg.sender == manager.members("nft"));
        _;
    }
    
    constructor(IERC20 _mp, IERC20 _usdt, IUniswapV2Pair _pair, address genesis) {
        mp = _mp;
        usdt = _usdt;
        pair = _pair;
        isGamer[genesis] = true;
        
        uint8 i = 0;
        while( i < 4) {
            daliyInfo[0].perNodeNum.push(0);
            i++;
        }
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
    function getUser3GenWeight(address _user) public view returns(User3GenWeight memory) {
        return user3GenWeight[_user];
    }
    
    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 mp_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, mp_balance , ) = pair.getReserves();   
        }  
        else{
          (mp_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(mp_balance);
        return token_price;
    }

    function bind(address binding) public {
        UserInfo storage user = userInfo[msg.sender];
        require(isGamer[binding] == true, "origin must in game!");
        require(msg.sender != binding, "can not bindself");
        
        require(user.f == address(0) && isGamer[msg.sender] == false, "Already bound before, please do not bind repeatedly");
        user.f = binding;
        isGamer[msg.sender] = true;

        // 第一代
        address upline = binding;
        // 存1~8代上線
        for(uint8 i=0; i < 8; i++) {
            user.upline8Gen[i] = upline;
            // 取下一代
            upline = userInfo[upline].f;
            if (upline == address(0)) {
                break;
            }
        }

        // 更新下線群組
        userInfo[user.f].ss.push(msg.sender);
        emit NewJoin(msg.sender, user.f);
    }

    // NFT 解質押後會呼叫
    function redem(address sender, uint256, uint256 amount) external onlyPool {
        UserInfo storage user = userInfo[sender];
        require(isGamer[sender] == true, "origin must in game!");
        address f = user.f;
        address ff = userInfo[f].f;
        address fff = userInfo[ff].f;
        
        if(!userInfo[sender].isValid){
            // 個人權重
            invalid3GenBonusWeight =  invalid3GenBonusWeight.sub(amount);
        }
        user.weight -= amount;
        IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(sender);

        bool changeToInvalid = false;
        if(user.isValid && user.weight == 0) {
            userDown(sender);

            if(f != address(0)) {
                evoDown(f,1);
            }
            if(ff != address(0)) {
                evoDown(ff,2);
            }
            if(fff != address(0)) {
                evoDown(fff,3);
            }
            changeToInvalid = true;
        }
        // 更新權重
        // 自己
        claimReward(sender);
        user.down8GenWeight = user.down8GenWeight.sub(amount);
        user.down3GenWeight = user.down3GenWeight.sub(amount);
        
        bool isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(sender);
        if(isPreacher){
            bool isAdd = false;
            IPreacher(manager.members("PreacherAddress")).updateWeight(sender, amount, isAdd);
        }

        // 紀錄total3GenBonusWeight的更新值
        uint256 _total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight;
        // 自己
        _total3GenBonusWeight = _total3GenBonusWeight.add(amount);

        uint256[4] memory subTotalUpdateWeight;
        if(user.level > 0){
            subTotalUpdateWeight[user.level-1] = subTotalUpdateWeight[user.level-1].add(amount);
        }
        uint256 tmpAmount = amount;
        for(uint8 i=0; i < 8; i++) {
            address _user = user.upline8Gen[i];
            if(_user == address(0)){
                break;
            }
            // 更新上線6代的有效人數
            if (changeToInvalid) {
                if (i < 6) {
                    userInfo[_user].numDown6Gen = userInfo[_user].numDown6Gen.sub(1);
                    // 檢查是否為佈道者
                    IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);
                }
            }
            
            // 更新上線8代的權重加總
            userInfo[_user].down8GenWeight = userInfo[_user].down8GenWeight.sub(tmpAmount);
            bool _isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(_user);
            if(_isPreacher){
                bool isAdd = false;
                IPreacher(manager.members("PreacherAddress")).updateWeight(_user, tmpAmount, isAdd);
            }

            // 更新上線3代權重加總
            if(i < 3){
                claimReward(_user);

                userInfo[_user].down3GenWeight = userInfo[_user].down3GenWeight.sub(tmpAmount);

                uint256 _level = userInfo[_user].level;
                if(_level > 0){
                    subTotalUpdateWeight[_level-1] = subTotalUpdateWeight[_level-1].add(tmpAmount);
                }
                
                // 用於「masterChef算力額外加成」
                if(i == 0){
                    IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                    user3GenWeight[_user].gen1Weight = user3GenWeight[_user].gen1Weight.sub(tmpAmount);
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen1Bonus.add(100)).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 1){
                    IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                    user3GenWeight[_user].gen2Weight = user3GenWeight[_user].gen2Weight.sub(tmpAmount);
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen2Bonus.add(100)).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 2){
                    IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                    user3GenWeight[_user].gen3Weight = user3GenWeight[_user].gen3Weight.sub(tmpAmount);
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen3Bonus.add(100)).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }
            }
        }

        // 更新個等級權重
        for(uint8 i=0 ;i<4 ;i++){
            daliyInfo[round].totalDown3GenWeight[i] = daliyInfo[round].totalDown3GenWeight[i].sub(subTotalUpdateWeight[i]) ;
        }

        // 更新全網三代bouns權重
        total3GenBonusWeight = total3GenBonusWeight.sub(_total3GenBonusWeight);
        invalid3GenBonusWeight = invalid3GenBonusWeight.sub(_invalid3GenBonusWeight);
    }

    

    function userDown(address sender) internal {
        uint8 level1 = userInfo[sender].level;
        if (userInfo[sender].level > 0) {
            levelChange(sender, level1, 0);
            emit LevelChange(sender, level1, 0);
        }

        if(userInfo[sender].isValid == true){
            updateInvalid3GenBonusWeight(sender, false);
        }
        userInfo[sender].isValid = false;
    }

    // 代數gen 1~3
    function evoDown(address _user, uint8 gen) internal {
        uint8 level = userInfo[_user].level;

        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS--;
            
            // 更新權重加成
            if(userInfo[_user].numSS >= 0 && userInfo[_user].numSS < 3){
                updateUserBouns(_user);
            }
        }
        userInfo[_user].numGS--;
        
        // 如果上線因此降级了，更新用户等级以及全網數據
        if ( level > 0 && (userInfo[_user].numSS < numThresholdSS[level - 1] || userInfo[_user].numGS < numThresholdGS[level - 1])) {
            levelChange(_user, level, level - 1);
            emit LevelChange(_user, level, level - 1);
        }
    }
    
    // NFT 質押後會呼叫
    function newDeposit(address sender,uint256, uint256 amount) external onlyPool {
        require(isGamer[sender] == true, "origin must in game!");
        UserInfo storage user = userInfo[sender];

        address f = user.f;
        address ff = userInfo[f].f;
        address fff = userInfo[ff].f;

        claimReward(sender);
        if(!userInfo[sender].isValid){
            // 個人權重
            invalid3GenBonusWeight =  invalid3GenBonusWeight.add(amount);
        }
        user.weight += amount;
        IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(sender);

        bool changeToValid = false;
        // 質押後，該用戶變為有效用戶
        if(!user.isValid && user.weight > 0) {
            userUp(sender);
            evo(f,1);
            if (ff != address(0)) {
                evo(ff, 2);
            }
            if (fff != address(0)) {
                evo(fff, 3);
            }
            changeToValid = true;
        }  

        // 更新權重
        // 自己
        userInfo[sender].down8GenWeight = userInfo[sender].down8GenWeight.add(amount);
        userInfo[sender].down3GenWeight = userInfo[sender].down3GenWeight.add(amount);

        bool isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(sender);
        if(isPreacher){
            bool isAdd = true;
            IPreacher(manager.members("PreacherAddress")).updateWeight(sender, amount, isAdd);
        }

        // 紀錄total3GenBonusWeight的更新值
        uint256 _total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight;
        // 自己
        _total3GenBonusWeight = _total3GenBonusWeight.add(amount);

        uint256[4] memory addTotalUpdateWeight;
        uint256 userLevel = userInfo[sender].level;
        if(userLevel > 0){
            addTotalUpdateWeight[userLevel-1] = addTotalUpdateWeight[userLevel-1].add(amount);
        }
        uint256 tmpAmount = amount;
        for(uint8 i=0; i < 8; i++) {
            address _user =user.upline8Gen[i];
            if(_user == address(0)){
                break;
            }
            // 更新上線6代的有效人數
            if (changeToValid) {
                if (i < 6) {
                    userInfo[_user].numDown6Gen = userInfo[_user].numDown6Gen.add(1);
                    // 檢查是否為佈道者
                    IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);
                }
            }
            
            // 更新上線8代的權重加總
            userInfo[_user].down8GenWeight = userInfo[_user].down8GenWeight.add(tmpAmount);
            bool _isPreacher = IPreacher(manager.members("PreacherAddress")).checkIsPreacher(_user);
            if(_isPreacher){
                bool isAdd = true;
                IPreacher(manager.members("PreacherAddress")).updateWeight(_user, tmpAmount, isAdd);
            }

            // 更新上線3代權重加總
            if(i < 3){
                claimReward(_user);
                userInfo[_user].down3GenWeight = userInfo[_user].down3GenWeight.add(tmpAmount);

                uint256 _level = userInfo[_user].level;
                if(_level > 0){
                    addTotalUpdateWeight[_level-1] = addTotalUpdateWeight[_level-1].add(tmpAmount);
                }

                // 用於「masterChef算力額外加成」
                if(i == 0){
                    IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                    user3GenWeight[_user].gen1Weight = user3GenWeight[_user].gen1Weight.add(tmpAmount);
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen1Bonus.add(100)).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 1){
                    IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                    user3GenWeight[_user].gen2Weight = user3GenWeight[_user].gen2Weight.add(tmpAmount);
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen2Bonus.add(100)).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }

                if(i == 2){
                    IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
                    user3GenWeight[_user].gen3Weight = user3GenWeight[_user].gen3Weight.add(tmpAmount);
                    IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
                    // 更新全網總權重
                    uint256 _bounsWeight = tmpAmount.mul(user3GenWeight[_user].gen3Bonus.add(100)).div(100);
                    _total3GenBonusWeight = _total3GenBonusWeight.add(_bounsWeight);

                    if(!userInfo[_user].isValid){
                        _invalid3GenBonusWeight =  _invalid3GenBonusWeight.add(_bounsWeight);
                    }
                }
            }
        }
        
        // 更新個等級權重
        for(uint8 i=0 ;i<4 ;i++){
            daliyInfo[round].totalDown3GenWeight[i] = daliyInfo[round].totalDown3GenWeight[i].add(addTotalUpdateWeight[i]);
        }

        // 更新全網三代bouns權重
        total3GenBonusWeight = total3GenBonusWeight.add(_total3GenBonusWeight);
        invalid3GenBonusWeight = invalid3GenBonusWeight.add(_invalid3GenBonusWeight);
    }

    function userUp(address sender) internal {
        uint8 level1 = userInfo[sender].level;
        uint8 level2 = updateLevel(sender);
        if (userInfo[sender].isValid == false && level2 > 0) {
            levelChange(sender, level1, level2);
            emit LevelChange(sender, level1, level2);

        }
        
        if(userInfo[sender].isValid == false){
            updateInvalid3GenBonusWeight(sender, true);
        }
        userInfo[sender].isValid = true;
    }

    // 更上線信息（如果提升了等级将沉淀奖励）
    function evo(address _user, uint8 gen) internal {
        uint8 level = userInfo[_user].level;

        // 更新 MD 值
        if(gen == 1){
            // 直推
            userInfo[_user].numSS++;

            // 更新權重加成
            if(userInfo[_user].numSS >= 0 && userInfo[_user].numSS <= 3){
                updateUserBouns(_user);
            }
        }
        userInfo[_user].numGS++;

        // 如果上線因此升级了，更新用户等级以及全網數據
        if ( 
            userInfo[_user].isValid &&
            level <= 3 && 
            userInfo[_user].numSS >= numThresholdSS[level] && 
            userInfo[_user].numGS >= numThresholdGS[level] && 
            userInfo[_user].depositAsUsdt >= amountThreshould[level]) {
                levelChange(_user, level, level+1);
                emit LevelChange(_user, level, level+1);
        }
    }

    function claimReward(address _user) internal {
        userInfo[_user].pendingReward = userInfo[_user].pendingReward.add(settleRewards(_user));
        userInfo[_user].lastRewardRound = round;
    }
    
    function update(uint256 amount) external validSender {
        if(block.timestamp >= roundTime[round] + 24 minutes) {
            round++;
            roundTime[round] = block.timestamp;
            if (round > 0) {
                daliyInfo[round] = daliyInfo[round -1];
                daliyInfo[round].totalDown3GenWeight = daliyInfo[round -1].totalDown3GenWeight;
                daliyInfo[round].perNodeNum = daliyInfo[round -1].perNodeNum;
            }
            // daliyInfo[round].round = round;
            daliyInfo[round].daliyDividends = 0;
            daliyInfo[round].rewardedAmount = 0;
            if(round > 16) {
                uint256 _p = daliyInfo[round - 16].daliyDividends.sub(daliyInfo[round - 16].rewardedAmount);
                if(_p > 0){
                    IERC20(mp).transfer(address(manager.members("funder")), _p);
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
    
    function deposit(uint256 amount) public {
        require(lockRequest[msg.sender] == 0, "In withdraw");
        require(amount > 0);
        require(isGamer[msg.sender] == true);
        IERC20(mp).transferFrom(msg.sender, address(this), amount);
        userInfo[msg.sender].depositedMP = userInfo[msg.sender].depositedMP.add(amount);
        userInfo[msg.sender].depositAsUsdt = userInfo[msg.sender].depositAsUsdt.add(amount.mul(getPrice()).div(1e18));
        uint8 old = userInfo[msg.sender].level;
        uint8 newlevel = updateLevel(msg.sender);
        if (old != newlevel && userInfo[msg.sender].isValid) {
            levelChange(msg.sender, old, newlevel);
            emit LevelChange(msg.sender, old, newlevel);
        }
        totalDepositedAmount = totalDepositedAmount.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function updateLevel(address user) internal view returns (uint8){
        // 質押 MP 的等級
        uint8 level1;
        // MD 值（直推）
        uint8 level2;
        // MD 值（兩代）
        uint8 level3;
        
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
        IERC20(mp).transfer(msg.sender, payReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward.add(payReward);
        userInfo[msg.sender].pendingReward = 0;
        userInfo[msg.sender].lastRewardRound = round;
        emit GetReward(msg.sender, reward);
    }
    
    function withdraw() public {
        require(lockRequest[msg.sender] !=0 && block.timestamp >= lockRequest[msg.sender].add(timeLock), "locked");
        IERC20(mp).transfer(msg.sender, userPending[msg.sender].pendingMP);
        lockRequest[msg.sender] = 0;
        totalDepositedAmount = totalDepositedAmount.sub(userPending[msg.sender].pendingMP);
        delete userPending[msg.sender];
        emit Withdraw(msg.sender, userPending[msg.sender].pendingMP);
    }

    function withdrawRequest() public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        getReward();
        userPending[msg.sender].pendingMP = userInfo[msg.sender].depositedMP;
        userPending[msg.sender].pendingAsUsdt = userInfo[msg.sender].depositAsUsdt;
        userInfo[msg.sender].depositedMP = 0;
        userInfo[msg.sender].depositAsUsdt = 0;
        lockRequest[msg.sender] = block.timestamp;


        levelChange(msg.sender, userInfo[msg.sender].level, 0);
        emit LevelChange(msg.sender, userInfo[msg.sender].level, 0);
        emit WithdrawRequest(msg.sender);
    }
    
    function pendingRewards(address _user) public view returns (uint256 reward){
        if (userInfo[_user].level == 0) {
            return 0;
        }
        // uint256 num = userInfo[_user].numSS;
        uint8 level = userInfo[_user].level;
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        for(i; i >0; i--) {
            if(daliyInfo[round-i].daliyDividends == 0 || userInfo[_user].down3GenWeight == 0 || daliyInfo[round-i].totalDown3GenWeight[level-1] == 0){
                continue;
            }
            // (daliyDividends * level 加成百分比) * (用戶3代算力 / 當前等級3代全網總算力) = 元域池 * 全網站比
            reward = reward.add(daliyInfo[round-i].daliyDividends.mul(rewardPrecent[userInfo[_user].level-1]).div(100).mul(userInfo[_user].down3GenWeight).div(daliyInfo[round-i].totalDown3GenWeight[level-1]));
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
            if(daliyInfo[round-i].daliyDividends == 0 || userInfo[_user].down3GenWeight == 0 || daliyInfo[round-i].totalDown3GenWeight[level-1] == 0){
                continue;
            }
            // (daliyDividends * level 加成百分比) * (用戶3代算力 / 當前等級3代全網總算力) = 元域池 * 全網站比
            roundReward = daliyInfo[round-i].daliyDividends.mul(rewardPrecent[userInfo[_user].level-1]).div(100).mul(userInfo[_user].down3GenWeight).div(daliyInfo[round-i].totalDown3GenWeight[level-1]);
            reward = reward.add(roundReward);
            daliyInfo[round-i].rewardedAmount+=roundReward;
        }
    }

    // 更新user bouns加成權重%
    function updateUserBouns(address _user) public {
        IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);
        IMasterChef._UserInfo memory masterUserInfo = IMasterChef(manager.members("nftMasterChef")).getUser(_user);

         User3GenWeight storage user3Gen = user3GenWeight[_user];

        uint256[3] memory _oldGenBonusArray = [user3Gen.gen1Bonus, user3Gen.gen2Bonus,user3Gen.gen3Bonus];

        // 質押 Uncommon罕見级NFT(以上) > 0  
        if(masterUserInfo.lvMore1Count > 0){
            // 直推1个有效地址获得1代 6%算力奖励
            if(userInfo[_user].numSS >= 3) {
                user3Gen.gen1Bonus = 6;
                user3Gen.gen2Bonus = 4;
                user3Gen.gen3Bonus = 2;
            }else if(userInfo[_user].numSS == 2) {
                user3Gen.gen1Bonus = 6;
                user3Gen.gen2Bonus = 4;
                user3Gen.gen3Bonus = 0;
            }else if(userInfo[_user].numSS == 1) {
                user3Gen.gen1Bonus = 6;
                user3Gen.gen2Bonus = 0;
                user3Gen.gen3Bonus = 0;
            }else{
                user3Gen.gen1Bonus = 0;
                user3Gen.gen2Bonus = 0;
                user3Gen.gen3Bonus = 0;
            }
        }else{
            user3Gen.gen1Bonus = 0;
            user3Gen.gen2Bonus = 0;
            user3Gen.gen3Bonus = 0;
        }

        uint256[3] memory _newGenBonusArray = [user3Gen.gen1Bonus, user3Gen.gen2Bonus,user3Gen.gen3Bonus];
        uint256[3] memory _newGenWeightArray = [user3Gen.gen1Weight, user3Gen.gen2Weight,user3Gen.gen3Weight];

        uint256 _total3GenBonusWeight = total3GenBonusWeight;
        uint256 _invalid3GenBonusWeight = invalid3GenBonusWeight;
        // 更新全網權重
        for( uint8 i = 0; i < 3; i++) {
            if(_newGenBonusArray[i] != _oldGenBonusArray[i]) {
                uint256 _oldBounsWeight = _newGenWeightArray[i].mul(_oldGenBonusArray[i].add(100)).div(100);
                uint256 _newBounsWeight = _newGenWeightArray[i].mul(_newGenBonusArray[i].add(100)).div(100);
                _total3GenBonusWeight = _total3GenBonusWeight.sub(_oldBounsWeight).add(_newBounsWeight); 
                if(!userInfo[_user].isValid){
                    _invalid3GenBonusWeight = _invalid3GenBonusWeight.sub(_oldBounsWeight).add(_newBounsWeight);
                }
            }
        }
        total3GenBonusWeight = _total3GenBonusWeight;
        invalid3GenBonusWeight = _invalid3GenBonusWeight;
        IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
    }

    // 有效身份變動時需更新
    function updateInvalid3GenBonusWeight(address _user, bool isValid) internal {
        // isValid是新狀態
        IMasterChef(manager.members("nftMasterChef")).claimReward(0, _user);

        User3GenWeight memory _user3Gen = user3GenWeight[_user];
        UserInfo memory _userInfo = userInfo[_user];
        uint256 userTotalWeight;
        userTotalWeight = userTotalWeight.add(_user3Gen.gen3Weight.mul(_user3Gen.gen3Bonus.add(100)).div(100));
        userTotalWeight = userTotalWeight.add(_user3Gen.gen2Weight.mul(_user3Gen.gen2Bonus.add(100)).div(100));
        userTotalWeight = userTotalWeight.add(_user3Gen.gen1Weight.mul(_user3Gen.gen1Bonus.add(100)).div(100));
        userTotalWeight = userTotalWeight.add(_userInfo.weight);

        if(isValid){
            // 變有效用戶
            invalid3GenBonusWeight = invalid3GenBonusWeight.sub(userTotalWeight);
        }else{
            // 變無效用戶
            invalid3GenBonusWeight = invalid3GenBonusWeight.add(userTotalWeight);
        }
        IMasterChef(manager.members("nftMasterChef")).updateRewardDebt(_user);
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

        // 檢查佈道者身份
        IPreacher(manager.members("PreacherAddress")).upgradePreacher(_user);

        // 當有人升級，更新該等級全網權重
        uint256 _down3GenWeight = userInfo[_user].down3GenWeight;
        if(oldLevel > 0){
            daliyInfo[round].totalDown3GenWeight[oldLevel-1] = daliyInfo[round].totalDown3GenWeight[oldLevel-1].sub(_down3GenWeight);
        }
        if(newLevel > 0){
            daliyInfo[round].totalDown3GenWeight[newLevel-1] = daliyInfo[round].totalDown3GenWeight[newLevel-1].add(_down3GenWeight);
        }
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