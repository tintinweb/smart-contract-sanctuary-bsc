/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract firstdapp{
    address payable public owner;
    uint public startTime;
    uint public pointTsp;
    uint public coinPerPoint;
    uint public totalPoints;
    bool public initialized=false;
    bool public startDividend=false;
    mapping (address => uint) public deposit;
    mapping (address => uint) public dividendTsp;
    mapping (address => uint) public points;
    mapping (address => address) public referrals;

    constructor () {
        owner = payable(msg.sender);
    }

// 业务逻辑
    // 提现
    function toWithdrawal(uint amount) public payable{
        require(initialized);
        require(amount <= deposit[msg.sender]);
        // 更新分红
        updateDiv();
        // 提款
        uint fee=getFee(amount);
        uint outPut = amount - fee;
        owner.transfer(fee);
        payable(msg.sender).transfer(outPut);
        deposit[msg.sender] -= amount;
    }

    // 充值
    function toRecharge(address ref) public payable{
        require(initialized);
        // 更新状态属性
        updateCoinPerPoint();
        setReferrals(ref);
        // 充值
        uint fee = getFee(msg.value);
        uint inPut = msg.value - fee;
        owner.transfer(fee);
        payable(address(this)).transfer(inPut);
        deposit[msg.sender] += inPut;
        // 增加积分
        updatePoints(inPut);
        // 更新分红
        updateDiv();
    }

    // 更新积分
    function updatePoints(uint amount) public{
        require(initialized);
        uint newPoints = getNewPoints(amount);
        points[msg.sender] += newPoints;
        // 添加给推荐人（20%）
        uint newPointsToRef = newPoints * 20 / 100;
        points[referrals[msg.sender]] += newPointsToRef;
        totalPoints += newPoints + newPointsToRef;
    }

    // 更新积分价格
    function updateCoinPerPoint() public {
        uint timeGap = getGap(pointTsp);
        coinPerPoint *= 20000**timeGap / 20001**timeGap;
        pointTsp = block.timestamp;
    }

    // 更新当前用户分红
    function updateDiv() public{
        require(initialized);
        openDividend();
        require(startDividend);
        deposit[msg.sender] += getLastDiv();
        dividendTsp[msg.sender] = block.timestamp;
    }

// 初始化
    // 启动项目
    function init() public{
        require(msg.sender == owner, 'invalid call');
        require(totalPoints==0);
        coinPerPoint = 1000000 / getBalance();
        initialized = true;
    }

    // 触发分红
    function openDividend() public{
        require(initialized);
        require(getBalance() >= 200);
        startTime = block.timestamp;
        pointTsp = startTime;
        startDividend=true;
    }

    // 设置推荐人
    function setReferrals(address ref) public{
        if(ref == msg.sender || ref == address(0) || deposit[ref] == 0) {
            ref = owner;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
    }

// 获取属性
    // 获取时间差
    function getGap(uint stp) public view returns(uint){
        return (block.timestamp - stp)/60;
    }

    // 获取所添加积分
    function getNewPoints(uint amount) public view returns(uint){
        return amount * coinPerPoint;
    }

    // 获取每笔存取手续费（1%）
    function getFee(uint amount) public pure returns(uint){
        return amount / 100;
    }

    // 获取每分钟可分红总额（分红池的0.005%）
    function getDivPerMin() public view returns(uint) {
        return getBalance() / 20000;
    }

    // 获取当前用户积分占比
    function getShare() public view returns(uint){
        return points[msg.sender] / totalPoints;
    }
    
    // 获取当前用户最新一波分红
    function getLastDiv() public view returns(uint){
        uint timeGap = getGap(dividendTsp[msg.sender]==0?startTime:dividendTsp[msg.sender]);
        return timeGap * getShare() * getDivPerMin();
    }

    // 获取合约余额
    function getBalance() public view returns(uint){
        uint unit = 1 ether;
        return address(this).balance / unit;
    }
}