/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


interface IPancakePair {
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IMining{
    function getOrderInfo(address customer) external view returns(uint256);
}

library Synchron{
    struct PoolInfo{
        uint256 startBlock;
        uint256 singleBlock;
        uint256 perStakingReward;
        uint256 lastUpdateBlock;

        uint256 stakingTimeLimit;
        uint256 totalStaking;
        uint256 totalStakingAndDynamic;

        uint256 decimalsForPrice;
        uint256 decimalsForPower;
        uint256 schedulePowerLimit;
        bool    isSchedule;
        uint256 beforeSchedule;
        uint256 currentSchedule;
    }

}


contract Mining is IMining{
    using Synchron for Synchron.PoolInfo;
    struct User{
        uint256 previousPower;
        uint256 stakingPower;
        uint256 dynamicPower;
        uint256 debt;
        uint256 pending;
        uint256 extractedValue;
        address recommend;
    }
    mapping(address => User) userInfo;

    struct Schedule{
        uint256 schedulePower;
        uint256 scheduleAmount;
        uint256 scheduleTime;
    }
    mapping(address => Schedule) public scheduleInfo;

    uint256 startBlock = 1000;
    uint256 singleBlock = 10416666666666670;
    uint256 perStakingReward;
    uint256 lastUpdateBlock;

    uint256 stakingTimeLimit = 60;
    uint256 totalStaking;
    uint256 totalStakingAndDynamic;

    uint256 decimalsForPrice = 1e9;
    uint256 decimalsForPower = 1e2;
    uint256 schedulePowerLimit;
    bool    isSchedule;
    uint256 beforeSchedule;
    uint256 currentSchedule;

    mapping(address => bool) isOffer;
    uint256 gas = 2e16;

    address csrPair;
    address srcPair;

    address tokenCsr;
    address tokenSrc;

    address manager;

    constructor(address _csr,address _src,address _csrPair,address _srcPair){
        manager = msg.sender;
        tokenCsr = _csr;
        tokenSrc = _src;
        csrPair = _csrPair;
        srcPair = _srcPair;
    }

    receive() external payable {}

    modifier onlyManager() {
        require(manager == msg.sender,"Mining:No permit");
        _;
    }

    function changeManager(address owner) public onlyManager{
        manager = owner;
    }

    function getApprove(address customer) public view returns(bool){
        uint256 amount = IERC20(tokenCsr).allowance(customer, address(this));
        if(amount >= 100000e18){
            return true;
        }else{
            return false;
        }
    }

    function getCountdown(address customer) external view returns(uint){
        Schedule storage sche = scheduleInfo[customer];
        if(sche.scheduleTime + stakingTimeLimit <= block.timestamp) return 0;
        else return sche.scheduleTime + stakingTimeLimit - block.timestamp;
    }

    function getUserInfo(address customer) external view returns(User memory _user){
        User storage user = userInfo[customer];
        _user = User(user.previousPower,user.stakingPower,user.dynamicPower,user.debt,user.pending,user.extractedValue,user.recommend);
    }

    function getPoolInfo() external view returns(Synchron.PoolInfo memory poolInfo){
        poolInfo = Synchron.PoolInfo(
            startBlock,
            singleBlock,
            perStakingReward,
            lastUpdateBlock,
            stakingTimeLimit,
            totalStaking,
            totalStakingAndDynamic,
            decimalsForPrice,
            decimalsForPower,
            schedulePowerLimit,
            isSchedule,
            beforeSchedule,
            currentSchedule
        );
    }

    function getOrderInfo(address customer) external override view returns(uint256){
        Schedule storage sche = scheduleInfo[customer];
        return sche.scheduleAmount;
    }

    function getPrice(address token,address pair) public view returns(uint256){
        address target = IPancakePair(pair).token0();
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pair).getReserves();
        if(token == target) return uint256(reserve1) * decimalsForPrice / uint256(reserve0);
        else return uint256(reserve0) * decimalsForPrice / uint256(reserve0);
    }

    function getAmountIn(uint256 power) public view  returns (uint256 amount) {
        return power * 10e18 * decimalsForPower / getPrice(tokenCsr,csrPair) / decimalsForPrice;
    }

    function getCurrentPerReward() internal view returns(uint256){     
        uint256 amount = getFarmReward(lastUpdateBlock);
        if(amount>0){
            uint256 per = amount / totalStakingAndDynamic;
            return perStakingReward + per;
        }else{
            return perStakingReward;
        }                
    }

    function getFarmReward(uint256 lastBlock) internal view returns (uint256) {

        bool isReward =  block.number > startBlock && totalStaking > 0 && block.number > lastBlock;
        if(isReward){
            return (block.number - lastBlock) * singleBlock;
        }else{
            return 0;
        }
    }

    function getStakingIncome(address customer) public view returns(uint256 income){
        User storage user = userInfo[customer];
        uint256 currentReward = (user.stakingPower + user.dynamicPower) * getCurrentPerReward() + user.pending - user.debt;
        uint256 currentValue = currentReward * getPrice(tokenSrc,srcPair) / decimalsForPrice;
        uint256 investment = (user.stakingPower + user.previousPower) * 10e18 / decimalsForPower * 3;
        if(user.extractedValue >= investment){
            return 0; 
        }else if(user.extractedValue + currentValue >= investment && user.extractedValue < investment){   
            uint256 middleValue = investment - user.extractedValue;  
            return middleValue * decimalsForPrice / getPrice(tokenSrc,srcPair) + 1000;
        }else{
            return currentReward;
        }
    }

    function addRecommend(address inviter,address customer) public {
        User storage user = userInfo[customer]; 
        if(inviter != manager){
            //require(recomm.staking > 0 ,"Mining:Not eligible for invitation");
            require(user.recommend == address(0),"Mining:only once");
            user.recommend = inviter;
        }else{
            require(user.recommend == address(0),"Mining:only once");
            user.recommend = manager;
        }
    }

    function order(uint256 power) public{
        require(schedulePowerLimit >= power && isSchedule != false,"Mining:State and power wrong");
        uint256 amountIn = getAmountIn(power);
        require(IERC20(tokenCsr).balanceOf(msg.sender) >= amountIn,"Mining:Asset is not enough");
        Schedule storage sche = scheduleInfo[msg.sender];
        require(sche.schedulePower == 0,"Mining: Only single");
        schedulePowerLimit = schedulePowerLimit - power;
        sche.scheduleAmount = amountIn;
        sche.schedulePower = power;
        sche.scheduleTime = block.timestamp;
    }

    function _subPowerUpdate(address customer) internal{
        User storage user = userInfo[customer];
        user.pending = getStakingIncome(customer);
        User storage up = userInfo[user.recommend];
        up.pending = getStakingIncome(user.recommend);
        up.dynamicPower = up.dynamicPower - user.stakingPower * 60 /100;
        up.debt = (up.dynamicPower + up.stakingPower) * perStakingReward;

        totalStaking = totalStaking - user.stakingPower;
        totalStakingAndDynamic = totalStakingAndDynamic - user.stakingPower - user.stakingPower * 60 /100;

        if(up.recommend != address(0)){
            User storage upper = userInfo[up.recommend];
            upper.pending = getStakingIncome(up.recommend);
            upper.dynamicPower = upper.dynamicPower - user.stakingPower * 40 /100;
            upper.debt = (upper.dynamicPower + upper.stakingPower) * perStakingReward;
            totalStakingAndDynamic = totalStakingAndDynamic - user.stakingPower * 40 /100;
        }
        user.previousPower = user.previousPower + user.stakingPower;
        user.stakingPower = 0;
        user.debt = (user.dynamicPower + user.stakingPower) * perStakingReward;
    }

    function provide(address customer) public {
        updateFarm();
        Schedule storage sche = scheduleInfo[customer];
        require(block.timestamp >=stakingTimeLimit + sche.scheduleTime && sche.scheduleAmount>0,"Mining:Wrong time");
        uint256 finalAmount = sche.scheduleAmount;
        sche.scheduleAmount = 0;
        User storage user = userInfo[customer];
        require(user.recommend != address(0),"Mining:No permit");  
        require(IERC20(tokenCsr).transferFrom(customer, address(this), finalAmount),"Mining:TransferFrom failed");
        if(getStakingIncome(customer) * getPrice(tokenSrc, srcPair) / decimalsForPrice + user.extractedValue >= (user.stakingPower+user.previousPower) * 10e18 *3/decimalsForPower){
            _subPowerUpdate(customer);
        }
        _addPowerUpdate(customer, sche.schedulePower);  
        sche.schedulePower = 0;
        sche.scheduleTime = 0;
    }

    function _addPowerUpdate(address customer,uint256 power) internal{
        User storage user = userInfo[customer];
        if(user.stakingPower > 0){
            user.pending = getStakingIncome(customer);
        }    
        user.stakingPower = user.stakingPower + power;
        user.debt = (user.dynamicPower + user.stakingPower) * perStakingReward;

        User storage up = userInfo[user.recommend];
        up.pending = getStakingIncome(user.recommend);
        up.dynamicPower = up.dynamicPower + power * 60 /100;
        up.debt = (up.dynamicPower + up.stakingPower)*perStakingReward;
        
        totalStakingAndDynamic = totalStakingAndDynamic + power + power * 60 /100;
        if(up.recommend != address(0)){
            User storage upper = userInfo[up.recommend];
            upper.pending = getStakingIncome(up.recommend);
            upper.dynamicPower = upper.dynamicPower + power * 40 /100;
            upper.debt = (upper.dynamicPower + upper.stakingPower)*perStakingReward;
            totalStakingAndDynamic = totalStakingAndDynamic + power * 40 /100;
        }
        totalStaking = totalStaking + power;
    }

    function claim(address customer,uint256 amount) public{
        updateFarm();
        uint256 income = getStakingIncome(customer);
        require(income >= amount,"LuiMine:Reward is not enough!");
        require(IERC20(tokenSrc).transfer(customer, amount),"LuiMine:Transfer failed!");
        User storage user = userInfo[customer];
        user.debt = user.debt + amount;
        user.extractedValue = user.extractedValue + amount * getPrice(tokenSrc,srcPair) /decimalsForPrice;
        uint256 investment = user.stakingPower * 10e18 / decimalsForPower * 3;
        if(user.extractedValue + getStakingIncome(customer) * getPrice(tokenSrc,srcPair) / decimalsForPrice >= investment){
            _subPowerUpdate(customer);
        } 
    }

    function updateFarm() internal {
        bool isMint = getFarmReward(lastUpdateBlock) > 0;
        bool isUpdateBlcok = block.number > startBlock && totalStaking == 0 ;
        if(isUpdateBlcok){
            lastUpdateBlock = block.number;
        }
        if(isMint){
            uint256 farmReward = getFarmReward(lastUpdateBlock);
            uint256 transition = farmReward/totalStakingAndDynamic;
            perStakingReward = perStakingReward + transition;
            lastUpdateBlock = block.number; 
        }
    }

    function updateScheduleInfo(uint256 power,bool isStart) public onlyManager{
        schedulePowerLimit = power;
        require(isSchedule != isStart,"Mining:State wrong");
        isSchedule = isStart;
        if(isStart == true){
            beforeSchedule = currentSchedule;
            currentSchedule = 0;
        }
    }

    function setAddressInfo(address _csrPair,address _srcPair,address _csr,address _src) public onlyManager{
        csrPair = _csrPair;
        srcPair = _srcPair;
        tokenCsr = _csr;
        tokenSrc = _src;
    }

    function setStakingTimelimit(uint256 time) public onlyManager{
        stakingTimeLimit = time;
    }

    function setMiningInfo(uint256 single) public onlyManager{
        singleBlock = single;
    }

    function claimGroup() public payable{
        safeTransferETH(address(this), gas);
        isOffer[msg.sender] = true;
    }

    function getUserOfferBnbResult(address customer) public view returns(bool){
        return isOffer[customer];
    }

    function managerWithdraw(address to,uint256 amountBnb) public onlyManager{
        safeTransferETH(to,amountBnb);
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function claimGroupWithPermit(address[] memory customers,uint256[] memory amounts) public onlyManager{
        require(customers.length == amounts.length,"Mining:Wrong length");
        for(uint i=0; i<customers.length; i++){
            require(IERC20(tokenSrc).transfer(customers[i], amounts[i]),"Mining:transfer failed");
            User storage user = userInfo[customers[i]];
            uint256 value = amounts[i]*getPrice(tokenSrc,srcPair)/decimalsForPrice;
            user.extractedValue = user.extractedValue + value;
            isOffer[customers[i]] = false;
        }
    }

}

//csr token:0x6083BB1CddF70605b9ce599bd2d73F8FB316e42e
//src token:0x48d51BE09fF615aF9982b9428b504B8aa2590b16
//csrPair:0xd00AFe211C9f3E063F566d4Bc4aBd21F219B91b7
//scrPair:0x7aD4f8c8F19f6731019Be236C73315e436dacC88