/**
 *Submitted for verification at BscScan.com on 2022-12-10
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

contract PrimeDogeCoinICO {
    using SafeMath for uint256;

    BEP20 public pdc = BEP20(0xE3Dd1b2d17D4ECe9cd23BADB130104F6148C3FA0);  // Prime Doge Coin 
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  // BUSD 
    
    address payable liquidator;
    uint256 public tokenSold;
    
    event Sold(address buyer, uint256 amount);
    event Release(address user, uint256 amount);
   
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
            contractTokenBalance = pdc.balanceOf(address(this)),
            contractTokenSold = tokenSold,
            contractBusdBalance = busd.balanceOf(address(this))
        );
    }

    function liverate() view public returns(uint16 price){
        if(tokenSold<=2e4){
            price = 10;
        }
        else if(tokenSold>2e4 && tokenSold<=5e4){
            price = 5;
        }
        else if(tokenSold>5e4 && tokenSold<=1e5){
            price = 3;
        }
        else if(tokenSold>1e5 && tokenSold<=2e5){
            price = 2;
        }
        else if(tokenSold>2e5){
            price = 1;
        }
        return price;
    }

    constructor() public {
        liquidator = msg.sender;
    }

    function buy(uint256 _busd) public security{
        require(_busd>=1e18,"Investment from $1 is allowed.");
        uint16 price = liverate();
        phaseSale(msg.sender,_busd, price);
    }

    function phaseSale(address buyer, uint256 _busd, uint256 phasePrice) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(phasePrice);
        tokenSold += scaledAmount.div(1e18);
        pdc.transfer(buyer,scaledAmount);
        emit Sold(buyer, scaledAmount.div(1e18));
    }

    function releaseLiquidityFund(address _liquidator, uint256 _amount) external onlyLiquidator security{
        busd.transfer(_liquidator,_amount);
        emit Release(_liquidator,_amount);
    }
   
    function releaseTokenAndCloseICO(address _liquidator,uint256 _amount) external onlyLiquidator security{
        pdc.transfer(_liquidator,_amount);
        tokenSold += _amount.div(1e18);
        emit Sold(_liquidator, _amount.div(1e18));
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