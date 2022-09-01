/**
 *Submitted for verification at BscScan.com on 2022-09-01
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

contract Mining is IMining{

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
    mapping(address => Schedule) scheduleInfo;

    uint256 startBlock = 1000;
    uint256 singleBlock = 10416666666666670;
    uint256 perReward;
    uint256 lastUpdateBlock;

    uint256 stakingTimeLimit = 60;
    uint256 totalStaking;
    uint256 totalStakingAndDynamic;

    uint256 decimals = 1e9;
    uint256 powerDecimals = 1e2;
    uint256 schedulePowerLimit;
    bool    public  isSchedule;
    uint256 beforeSchedule;
    uint256 currentSchedule;

    mapping(address => bool) isOffer;
    uint256 gas = 2e16;

    address csrPair;
    address srcPair;

    address tokenCsr;
    address tokenSrc;

    address manager;

    constructor(){
        manager = msg.sender;
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

    function getPoolInfo() public view returns(uint256 tSchedule,uint256 bSchedule,uint256 cSchedule,bool isStart,uint256 tStaking,
        uint256 tStakingAndDync,uint256 rblock,uint256 time){
            tSchedule = schedulePowerLimit;
            bSchedule = beforeSchedule;
            cSchedule = currentSchedule;
            isStart   = isSchedule;
            tStaking  = totalStaking;
            rblock    = singleBlock;
            tStakingAndDync = totalStakingAndDynamic;
            time = stakingTimeLimit;
    }

    function getOrderInfo(address customer) external override view returns(uint256){
        Schedule storage sche = scheduleInfo[customer];
        return sche.scheduleAmount;
    }

    function getUserSettlementInfo(address customer) public view returns(uint256 de,uint256 pe,uint256 ex,uint256 his){
        User storage user = userInfo[customer];
        de = user.debt;
        pe = user.pending;
        ex = user.extractedValue;
        his = user.previousPower;
    }

    function getUserInfo(address customer) public view returns(uint256 stake,uint256 dync,address recomm,uint256 sPower,uint256 sAmount,
        uint256 time){
            User storage user = userInfo[customer];
            Schedule storage sche = scheduleInfo[customer];
            stake = user.stakingPower;
            dync  = user.dynamicPower;
            recomm = user.recommend;
            sPower = sche.schedulePower;
            sAmount = sche.scheduleAmount;
            if(block.timestamp >= stakingTimeLimit + sche.scheduleTime){
                time = 0;
            }else{
                time = stakingTimeLimit - (block.timestamp - sche.scheduleTime);
            }   
    }

    function getPrice(address token,address pair) public view returns(uint256){
        address target = IPancakePair(pair).token0();
        (uint112 reserve0, uint112 reserve1,) = IPancakePair(pair).getReserves();
        uint256 amount0 = reserve0;
        uint256 amount1 = reserve1;
        if(token == target){
            return amount1 * decimals / amount0;
        }else{
            return amount0 * decimals / amount1;
        }

    }

    function getAmountIn(uint256 power) public view  returns (uint256 amount) {
        return power * 10e18 * decimals / getPrice(tokenCsr,csrPair) / powerDecimals;
    }

    function getCurrentPerReward() internal view returns(uint256){     
        uint256 amount = getFarmReward(lastUpdateBlock);
        if(amount>0){
            uint256 per = amount / totalStakingAndDynamic;
            return perReward + per;
        }else{
            return perReward;
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

    function getStakingIncome(address customer) public view returns(uint256){
        User storage user = userInfo[customer];
        
        uint256 currentReward = (user.stakingPower + user.dynamicPower) * getCurrentPerReward() + user.pending - user.debt;
        
        uint256 currentValue = currentReward * getPrice(tokenSrc,srcPair) / decimals;
        
        uint256 investment = (user.stakingPower+user.previousPower) * 10e18 / powerDecimals * 3;
        
        if(user.extractedValue >= investment){
            return 0;
            
        }else if(user.extractedValue + currentValue >= investment && user.extractedValue < investment){
            
            uint256 middleValue = investment - user.extractedValue;
           
            return middleValue * decimals / getPrice(tokenSrc,srcPair);
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

        up.debt = (up.dynamicPower + up.stakingPower)*perReward;
        totalStaking = totalStaking - user.stakingPower;
        totalStakingAndDynamic = totalStakingAndDynamic - user.stakingPower - user.stakingPower * 60 /100;

        if(up.recommend != address(0)){
            User storage upper = userInfo[up.recommend];
            upper.pending = getStakingIncome(up.recommend);
            upper.dynamicPower = upper.dynamicPower - user.stakingPower * 40 /100;
            upper.debt = (upper.dynamicPower + upper.stakingPower)*perReward;
            totalStakingAndDynamic = totalStakingAndDynamic - user.stakingPower * 40 /100;
        }
        user.previousPower = user.previousPower + user.stakingPower;
        user.stakingPower = 0;
        user.debt = (user.dynamicPower + user.stakingPower)*perReward;
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
        if(getStakingIncome(customer) * getPrice(tokenSrc, srcPair) / decimals + user.extractedValue >= (user.stakingPower+user.previousPower) * 10e18 *3/powerDecimals){
            _subPowerUpdate(customer);
        }
        recommendPower(customer, sche.schedulePower);  
        sche.schedulePower = 0;
        sche.scheduleTime = 0;
    }

    function recommendPower(address customer,uint256 power) internal{
        User storage user = userInfo[customer];
        if(user.stakingPower > 0){
            user.pending = getStakingIncome(customer);
        }    
        user.stakingPower = user.stakingPower + power;
        user.debt = (user.dynamicPower + user.stakingPower)*perReward;

        User storage up = userInfo[user.recommend];
        up.pending = getStakingIncome(user.recommend);
        up.dynamicPower = up.dynamicPower + power * 60 /100;
        up.debt = (up.dynamicPower + up.stakingPower)*perReward;
        
        totalStakingAndDynamic = totalStakingAndDynamic + power + power * 60 /100;
        if(up.recommend != address(0)){
            User storage upper = userInfo[up.recommend];
            upper.pending = getStakingIncome(up.recommend);
            upper.dynamicPower = upper.dynamicPower + power * 40 /100;
            upper.debt = (upper.dynamicPower + upper.stakingPower)*perReward;
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
        user.extractedValue = user.extractedValue + amount * getPrice(tokenSrc,srcPair) /decimals;
        uint256 investment = user.stakingPower * 10e18 / powerDecimals * 3;

        if(user.extractedValue + getStakingIncome(customer) * getPrice(tokenSrc,srcPair) / decimals >= investment){
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
            perReward = perReward+transition;
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
            uint256 value = amounts[i]*getPrice(tokenSrc,srcPair)/decimals;
            user.extractedValue = user.extractedValue + value;
            isOffer[customers[i]] = false;
        }
    }

    function testAddPerReward(uint256 per) external{
        perReward = perReward + per;
    }


}
//0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4