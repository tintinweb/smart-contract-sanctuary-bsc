/**
 *Submitted for verification at BscScan.com on 2022-11-26
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

contract DeltinCoinICO {
    using SafeMath for uint256;

    BEP20 public delt = BEP20(0xa8097d516f9D03545cF10c70C69Ce7727E29D7A2);  // Deltin Coin 
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  // BUSD 
    
    address liquidator;
    uint256 tokenSold;
    uint8 price = 16;
    event Sold(address buyer, uint256 busd, uint256 token);
    event SoldWithReferral(address buyer, address referer, uint256 busd, uint256 token);
    
   
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
            contractTokenBalance = delt.balanceOf(address(this)),
            contractTokenSold = tokenSold,
            contractBusdBalance = busd.balanceOf(address(this))
        );
    }

    constructor() public {
        liquidator = msg.sender;
    }

    function buy(uint256 _busd) public security{
        require(_busd>=1e18,"Investment from $1 is allowed.");
        phaseSale(msg.sender, _busd);
    }

    function buyWithReferral(address referer, uint256 _busd) public security{
        require(_busd>=1e18,"Investment from $1 is allowed.");
        phaseSaleWithReferral(msg.sender, referer, _busd);
    }

    function phaseSale(address buyer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(price);
        require(delt.balanceOf(address(this)) >= scaledAmount);
        tokenSold += scaledAmount.div(1e18);
        delt.transfer(buyer,scaledAmount);
        emit Sold(buyer, _busd, scaledAmount);
        
    }
    
    function phaseSaleWithReferral(address buyer, address referer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(price);
        require(delt.balanceOf(address(this)) >= scaledAmount);
        tokenSold += scaledAmount.div(1e18);
        delt.transfer(buyer,scaledAmount);
        delt.transfer(referer, scaledAmount.mul(10).div(100));
        emit SoldWithReferral(buyer, referer, _busd, scaledAmount);
        
    }

    function releaseLiquidityFund(address _liquidator, uint _amount) external onlyLiquidator{
        busd.transfer(_liquidator,_amount);
    }
   
    function releaseTokenAndCloseICO(address _liquidator,uint _amount) external onlyLiquidator{
        delt.transfer(_liquidator,_amount);
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