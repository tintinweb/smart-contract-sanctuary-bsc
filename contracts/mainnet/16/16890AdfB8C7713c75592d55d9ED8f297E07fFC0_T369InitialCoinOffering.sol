/**
 *Submitted for verification at BscScan.com on 2022-09-15
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

contract T369InitialCoinOffering {
    using SafeMath for uint256;
    
    BEP20 public t369 = BEP20(0xb50fB42ea1332017ca9508E7a0c1B686698D9D8e);  // T369 Coin
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  // BUSD
    
    address liquidator;
    uint256 public price; // the price per busd
    uint256 public tokensSold;
  
    mapping (address => uint256) public balances;

    event Sold(address buyer, uint256 amount);
    event ReleaseInitialCoinOffering(address liquidator, uint256 busd, uint256 token);
   
    modifier onlyLiquidator(){
        require(msg.sender == liquidator,"You are not authorized liquidator.");
        _;
    }

    function getBalanceSheet() view public returns(uint256 contractTokenBalance, uint256 contractTokenSold,uint256 contractBalance){
        return (
            contractTokenBalance = t369.balanceOf(address(this)),
            contractTokenSold = tokensSold,
            contractBalance = busd.balanceOf(address(this))
        );
    }

    constructor() public {
        liquidator = msg.sender;
        price = 100;
    }

    function buy(uint256 _busd) public {
        require(_busd>=1e18,"Please invest at least 1 BUSD.");
        uint256 scaledAmount = _busd.mul(price);
        scaledAmount = scaledAmount.add(scaledAmount.mul(5).div(100));
        emit Sold(msg.sender, scaledAmount);
        tokensSold+=scaledAmount;
        require(t369.transfer(msg.sender, scaledAmount));
    }

    function releaseInitialCoinOffering(address _liquidator, uint256 _busd, uint256 _t369) external onlyLiquidator{
        busd.transfer(_liquidator,_busd);
        t369.transfer(_liquidator,_t369);
        emit ReleaseInitialCoinOffering(_liquidator,_busd,_t369);
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