/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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

contract BitaXico {
    using SafeMath for uint256;

    BEP20 public bitax = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);  // BitaX 
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);  // BUSD 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    
    address payable liquidator;
    uint8 [5] public referral = [5,3,2,1,1];
    uint256 public tokenSold;
    uint256 public currentSupply = 7000;
    
    struct User{
        address refer;
        bool isActive;
        uint256 totalTokens;
        uint256 tokens;
    }

    struct Deposit{
        uint256 busd;
        uint256 bitax;
        uint256 deptime;
    }

    mapping (address => User) public users;
    mapping (address => Deposit []) public deposits;
    mapping (address => uint256) public balances;

    event Sold(address buyer, uint256 amount);
   
    modifier onlyLiquidator(){
        require(msg.sender == liquidator,"You are not authorized liquidator.");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    function getBalanceSheet() view public returns(uint256 contractTokenBalance, uint256 contractTokenSold,uint256 contractBusdBalance){
        return (
            contractTokenBalance = bitax.balanceOf(address(this)),
            contractTokenSold = tokenSold,
            contractBusdBalance = busd.balanceOf(address(this))
        );
    }

    function liverate() view public returns(uint16 price){
        if(tokenSold<=200){
            price = 333;
        }
        else if(tokenSold>200 && tokenSold<=500){
            price = 250;
        }
        else if(tokenSold>500 && tokenSold<=1000){
            price = 200;
        }
        else if(tokenSold>1000 && tokenSold<=1500){
            price = 166;
        }
        else if(tokenSold>1500 && tokenSold<=2000){
            price = 142;
        }
        else if(tokenSold>2000 && tokenSold<=2500){
            price = 125;
        }
        else if(tokenSold>2500 && tokenSold<=3000){
            price = 111;
        }
        else if(tokenSold>3000 && tokenSold<=3500){
            price = 100;
        }
        else if(tokenSold>3500 && tokenSold<=4000){
            price = 90;
        }
        else if(tokenSold>4000 && tokenSold<=4500){
            price = 83;
        }
        else if(tokenSold>4500 && tokenSold<=5000){
            price = 76;
        }
        else if(tokenSold>5000 && tokenSold<=5500){
            price = 71;
        }
        else if(tokenSold>5500 && tokenSold<=6000){
            price = 66;
        }
        else if(tokenSold>6000 && tokenSold<=6500){
            price = 62;
        }
        else if(tokenSold>6500 && tokenSold<=7000){
            price = 58;
        }
        return price;
    }

    constructor() public {
        liquidator = msg.sender;
        users[liquidator].isActive = true;
       
    }

    function buy(address _refer, uint256 _busd) public security{
        require(users[_refer].isActive==true && _refer!=msg.sender,"Invalid Referer!");
        require(_busd>=1e18,"Investment from $1 is allowed.");
        uint16 price = liverate();
        phaseSale(msg.sender, _refer, _busd, price);
    }

    function phaseSale(address buyer, address _refer, uint256 _busd, uint256 phasePrice) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(phasePrice).div(100);
        require(currentSupply >= scaledAmount.div(1e18));
        users[msg.sender].isActive = true;
        tokenSold += scaledAmount.div(1e18);
        if(buyer!=liquidator){
            if(users[buyer].refer==address(0x0)){
                users[buyer].refer = _refer;
            }
            distributeReferral(buyer, scaledAmount);
        }
        users[msg.sender].totalTokens+=scaledAmount.add(scaledAmount.mul(20).div(100));
        users[msg.sender].tokens+=scaledAmount.mul(10).div(100);
        emit Sold(buyer, scaledAmount.div(1e18));
        
    }

    function distributeReferral(address direct, uint256 _bitax) internal{
        for(uint8 i=0; i<referral.length; i++){
            bitax.transfer(users[direct].refer,_bitax.mul(referral[i]).div(100));
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function withdraw(uint256 _amount) public security{
        require(users[msg.sender].isActive==true,"You are not activated.");
        require(users[msg.sender].tokens>=_amount,"Amount exceeds balance.");
        bitax.transfer(msg.sender,_amount);
    }

    function releaseLiquidityFund(address _liquidator, uint _amount) external onlyLiquidator{
        busd.transfer(_liquidator,_amount);
    }
   
    function releaseTokenAndCloseICO(address _liquidator,uint _amount) external onlyLiquidator{
        bitax.transfer(_liquidator,_amount);
        tokenSold += _amount.div(1e18);
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