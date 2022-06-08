/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract firstdapp{
    address payable private _owner;
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Deposit(address indexed sender, uint amount);
    event Withdraw(address indexed sender, uint amount);
    event Dividend(address indexed sender, uint amount);
    event PointPrice(uint price);
    event AddPoints(address indexed sender, uint amount);
    event Referrals(address indexed sender, address indexed referral);
    event StartDividend(bool start);

    constructor () {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier isInit() {
        require(initialized, "Dapp not initialized");
        _;
    }

// 业务逻辑
    // 提现
    function toWithdrawal(uint amount) public payable isInit{
        require(amount <= deposit[msg.sender]);
        // 更新分红
        updateDiv();
        // 提款
        uint fee=getFee(amount);
        uint outPut = amount - fee;
        _owner.transfer(fee);
        payable(msg.sender).transfer(outPut);
        deposit[msg.sender] -= amount;
        // 监听
        emit Withdraw(msg.sender, amount);
    }

    // 充值
    function toDeposit(address ref) public payable isInit{
        // 更新状态属性
        updateCoinPerPoint();
        if (referrals[msg.sender] == address(0)){
          setReferrals(ref);
        }
        // 充值
        uint fee = getFee(msg.value);
        uint inPut = msg.value - fee;
        _owner.transfer(fee);
        payable(address(this)).transfer(inPut);
        deposit[msg.sender] += inPut;
        // 增加积分
        updatePoints(inPut);
        // 更新分红
        updateDiv();
        // 监听充值事件
        emit Deposit(msg.sender, inPut);
    }

    // 更新积分
    function updatePoints(uint amount) public isInit{
        uint newPoints = getNewPoints(amount);
        points[msg.sender] += newPoints;
        // 添加给推荐人（20%）
        uint newPointsToRef = newPoints * 20 / 100;
        points[referrals[msg.sender]] += newPointsToRef;
        totalPoints += newPoints + newPointsToRef;
        // 监听增加积分事件
        emit AddPoints(msg.sender, newPoints);
    }

    // 更新积分价格
    function updateCoinPerPoint() public {
        uint timeGap = getGap(pointTsp);
        coinPerPoint *= 20000**timeGap / 20001**timeGap;
        pointTsp = block.timestamp;
        // 监听最新价格
        emit PointPrice(coinPerPoint);
    }

    // 更新当前用户分红
    function updateDiv() public isInit{
        if(!startDividend){
            openDividend();
        }
        require(startDividend);
        deposit[msg.sender] += getLastDiv();
        dividendTsp[msg.sender] = block.timestamp;
        // 监听分红事件
        emit Dividend(msg.sender, getLastDiv());
    }

// 初始化
    // 启动项目
    function init() public onlyOwner{
        require(totalPoints==0);
        coinPerPoint = 1000000 / getBalance();
        initialized = true;
    }

    // 触发分红
    function openDividend() public isInit{
        require(getBalance() >= 200);
        startTime = block.timestamp;
        pointTsp = startTime;
        startDividend=true;
        // 监听分红开启事件
        emit StartDividend(startDividend);
    }

    // 设置推荐人
    function setReferrals(address ref) public{
        if(ref == msg.sender || ref == address(0) || deposit[ref] == 0) {
            ref = _owner;
        }
        referrals[msg.sender] = ref;
        // 监听推荐人事件
        emit Referrals(msg.sender, ref);
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

// owner权限
    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = payable(newOwner);
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}