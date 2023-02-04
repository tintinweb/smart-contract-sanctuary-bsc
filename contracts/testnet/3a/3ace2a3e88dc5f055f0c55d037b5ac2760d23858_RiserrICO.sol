/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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

contract RiserrICO {
    using SafeMath for uint256;

    BEP20 public rrr = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);  // RRR 
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);  // BUSD
    
    address payable liquidator;
    uint8 [3] public referral = [8,5,2];
    uint256 public price = 160;
    uint256 public tokenSold;
    uint256 public maxbuy = 50e18;
    
    struct User{
        address refer;
        bool isActive;
        uint256 _busd;
        uint256 tokens;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) referral;
        
    }

    struct Deposit{
        uint256 busd;
        uint256 token;
        uint256 deptime;
    }

    mapping (address => User) public users;
    mapping (address => Deposit []) public deposits;
    
    event Sold(address buyer, uint256 busd, uint256 token);
    
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
            contractTokenBalance = rrr.balanceOf(address(this)),
            contractTokenSold = tokenSold,
            contractBusdBalance = busd.balanceOf(address(this))
        );
    }

    constructor() public {
        liquidator = msg.sender;
        users[liquidator].isActive = true;
    }

    function buy(address _refer, uint256 _busd) public security{
        require(users[_refer].isActive==true && _refer!=msg.sender,"Invalid Referer!");
        require((maxbuy.sub(users[msg.sender]._busd)) >= _busd);
        _buy(msg.sender, _refer, _busd);
    }

    function _buy(address buyer, address _refer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(price);
        users[msg.sender].isActive = true;
        users[msg.sender]._busd+=_busd;
        tokenSold += scaledAmount.div(1e18);
        if(buyer!=liquidator){
            if(users[buyer].refer==address(0x0)){
                setReferral(buyer,_refer);
            }
            distributeReferral(buyer, _busd);
        }
        deposits[buyer].push(Deposit(
            _busd,
            scaledAmount,
            block.timestamp
        ));
        users[msg.sender].tokens+=scaledAmount.div(1e18);
        rrr.transfer(msg.sender,scaledAmount);
        emit Sold(buyer, _busd, scaledAmount);
        
    }

    function setReferral(address direct, address refer) internal{
        users[direct].refer = refer;
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].levelTeam[i]++;
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function distributeReferral(address direct, uint256 _busd) internal{
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].referral[i]+=_busd.mul(referral[i]).div(100);
            busd.transfer(users[direct].refer,_busd.mul(referral[i]).div(100));
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function userDetails(address buyer) public view returns(uint256 [3] memory team, uint256 [3] memory income){
        for(uint8 i = 0; i < referral.length; i++){
            team[i] = users[buyer].levelTeam[i];
            income[i] = users[buyer].referral[i];
        }
        return(team,income);
    }

    function releaseLiquidityFund(address _liquidator, uint _amount) external onlyLiquidator security{
        busd.transfer(_liquidator,_amount);
    }
   
    function releaseRiserrAndCloseICO(address _liquidator,uint _amount) external onlyLiquidator security{
        rrr.transfer(_liquidator,_amount);
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