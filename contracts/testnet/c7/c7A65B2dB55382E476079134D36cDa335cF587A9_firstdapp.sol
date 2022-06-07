/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

pragma solidity ^0.4.26;

contract firstdapp{
    uint256 public round=14400; // 10天的分钟数
    uint256 public marketPoints;
    bool public initialized=false;
    bool public willDividend=false;
    address public owner;
    mapping (address => uint256) public miners; // 存入金额
    mapping (address => uint256) public points; // 积分数值
    mapping (address => address) public referrals; // 推荐人
    mapping (address => uint256) public lastSend; // 最后一次分发积分时间

    constructor() public{
        owner=msg.sender;
    }

    // 提现
    function withdrawal(uint256 amount) public payable{
        require(initialized);
        require(amount <= miners[msg.sender]);
        uint256 fee=devFee(amount);
        uint256 putOut = SafeMath.sub(amount,fee);
        owner.transfer(fee);
        msg.sender.transfer(putOut);
        miners[msg.sender] = SafeMath.sub(miners[msg.sender],amount);
    }

    // 充值
    function recharge(address ref) public payable{
        require(initialized);
        // 增加账户数额
        uint256 fee = devFee(msg.value);
        uint256 putIn = SafeMath.sub(msg.value,fee);
        owner.transfer(fee);
        address(this).transfer(putIn);
        miners[msg.sender] = SafeMath.add(miners[msg.sender],putIn);
        // 增加积分
        uint256 k = getK();
        uint256 getPoint = SafeMath.mul(putIn,k);
        points[msg.sender]=SafeMath.add(points[msg.sender],getPoint);
        marketPoints = SafeMath.add(marketPoints,getPoint);
        // 设置邀请人
        if(ref == msg.sender || ref == address(0) || miners[ref] == 0) {
            ref = owner;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        // 发送积分给推荐人（金额*k*20%）
        uint256 getPoint2 = SafeMath.div(SafeMath.mul(getPoint,20),100);
        points[referrals[msg.sender]]=SafeMath.add(points[referrals[msg.sender]],getPoint2);
        
        marketPoints = SafeMath.add(marketPoints,getPoint2);
        toDividend();
    }

    // 分红
    function toDividend() public{
        require(initialized);
        require(willDividend);

        uint256 myPoints=getMyPoints();
        uint256 myMiners=getMyMiners();

        uint256 subPoints=SafeMath.div(myPoints,round);
        uint256 addMiners=SafeMath.div(myMiners,round);

        points[msg.sender]=SafeMath.sub(points[msg.sender],subPoints);
        miners[msg.sender]=SafeMath.add(miners[msg.sender],addMiners);

        lastSend[msg.sender]=now;
    }

    // 注资100
    function donation() public payable{
        address(this).transfer(100);
    }

    // 计算k值
    function getK() public view returns(uint256){
        uint balance = getBalance();
        return SafeMath.sub(1000000,balance);
    }

    // 计算每笔存取手续费（1%）
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(amount,100);
    }

    // 计算每分钟可分红额度（分红池的0.005%）
    function canDividend() public view returns(uint256) {
        uint256 balance = getBalance();
        return SafeMath.div(balance,20000);
    }

    // 计算积分比例
    function share() public view returns(uint256){
        uint256 all = marketPoints;
        uint256 myPoints = getMyPoints();
        return SafeMath.div(myPoints,all);
    }

    // 初始化分红池
    function init() public payable{
        require(msg.sender == owner, 'invalid call');
        require(marketPoints==0);
        initialized=true;
    }

    // 触发分红
    function openDividend() public payable{
        require(initialized);
        uint256 balance = address(this).balance;
        require(balance >= 200);
        willDividend=true;
    }
    
    // 获取合约余额
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    // 获取当前账户可取额度
    function getMyMiners() public view returns(uint256){
        return SafeMath.add(miners[msg.sender],getMinersSinceLastSend(msg.sender));
    }

    // 获取当前账户积分数值
    function getMyPoints() public view returns(uint256){
        return SafeMath.sub(points[msg.sender],subPointsSinceLastSend(msg.sender));
    }

    // 分红后扣除积分
    function subPointsSinceLastSend(address adr) public view returns(uint256){
        // minutesPassed = min(round,now/lastSend)
        uint256 minutesPassed=min(round,SafeMath.sub(now,lastSend[adr]));
        return SafeMath.mul(minutesPassed,SafeMath.mul(points[adr],20000));
    }

    // 获取最新一次分红
    function getMinersSinceLastSend(address adr) public view returns(uint256){
        // minutesPassed = min(round,now/lastSend)
        uint256 minutesPassed=min(round,SafeMath.sub(now,lastSend[adr]));
        uint256 myShare = share();
        return SafeMath.mul(minutesPassed,SafeMath.mul(myShare,miners[adr]));
    }

    // 获取最小值
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
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