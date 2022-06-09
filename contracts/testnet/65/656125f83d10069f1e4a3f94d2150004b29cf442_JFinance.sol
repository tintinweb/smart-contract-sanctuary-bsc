/**
 *Submitted for verification at BscScan.com on 2022-06-09
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

contract JFinance {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);
    address payable owner;
    uint8 ownerShare = 2;
    uint256 lockPeriod = 1 hours;
    uint256 public investments;
    uint256 public sales;
 
    struct User{
        uint256 deposits;
        uint256 sold;
        uint256 locker;
    }

    struct Deposit{
        uint256 amount;
        uint256 depositTime;
    }

    struct Sell{
        uint256 amount;
        uint256 soldTime;
    }

    mapping(address => User) public users;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Sell[]) public sells;

    event Deposits(address seller, uint256 amount);
    event Sales(address seller, address buyer, uint256 amount);
   
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not authorized owner.");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBalance, uint256 totalInvestments, uint256 totalSales, uint256 locking, uint8 txnFees){
        return (
            contractBalance = busd.balanceOf(address(this)),
            totalInvestments = investments,
            totalSales = sales,
            locking = lockPeriod,
            txnFees = ownerShare
        );
    }

    constructor() public {
        owner = msg.sender;
    }

    function deposit(uint256 amount) public {
        require(amount>=1e18,"Investment must be at least 1 BUSD!");
        User storage user = users[msg.sender];
        user.deposits+=amount;
        investments+=amount;
        deposits[msg.sender].push(Deposit(
            amount,
            block.timestamp
        ));
        busd.transferFrom(msg.sender,address(this),amount);
        emit Deposits(msg.sender, amount);
    }

    function sell(address buyer, uint256 amount) public {
        require(amount>=1e18,"Sales must be at least 1 BUSD!");
        User storage user = users[msg.sender];
        uint256 balance = user.deposits-user.sold;
        require(balance>=amount,"Insufficient Balance");
        user.sold+=amount;
        sales+=amount;
        uint256 userget = amount.mul(ownerShare).div(100);
        busd.transfer(buyer,userget);
        busd.transfer(owner,userget.mul(2));
        sells[msg.sender].push(Sell(
            amount,
            block.timestamp
        ));
        emit Sales(msg.sender, buyer, amount);
    }

    function setOwnerShare(uint8 share) public onlyOwner returns(uint8){
        ownerShare = share;
        return ownerShare;
    }

    function setlockPeriod(uint256 lock) public onlyOwner returns(uint256){
        lockPeriod = lock;
        return lockPeriod;
    }

    function lockSeller() external returns(uint256){
        User storage user = users[msg.sender];
        if(user.locker<=block.timestamp){
            user.locker = block.timestamp+lockPeriod;
        }
        return user.locker;
    }

    function airdrop(address _address, uint _amount) external onlyOwner{
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