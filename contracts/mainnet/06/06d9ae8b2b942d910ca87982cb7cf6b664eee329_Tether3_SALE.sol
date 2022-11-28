/**
 *Submitted for verification at BscScan.com on 2022-11-28
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

contract Tether3_SALE {
    using SafeMath for uint256;

    BEP20 public usdt3 = BEP20(0x7cD4d42b1779ec004080Ef1375784eC3CE6E20d5);  // Tether 3.0 
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  // BUSD 
    
    address aggregator;
    uint256 tether3Sold;
    
    event Sold(address buyer, uint256 busd, uint256 token);
    event SoldWithReferral(address buyer, address referer, uint256 busd, uint256 token);
    
   
    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized aggregator.");
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
            contractTokenBalance = usdt3.balanceOf(address(this)),
            contractTokenSold = tether3Sold,
            contractBusdBalance = busd.balanceOf(address(this))
        );
    }

    constructor() public {
        aggregator = msg.sender;
    }

    function buy(uint256 _busd) public security{
        require(_busd>=1e18,"Investment from $1 is allowed.");
        phaseSale(msg.sender, _busd);
    }

    function phaseSale(address buyer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd;
        require(usdt3.balanceOf(address(this)) >= scaledAmount);
        tether3Sold += scaledAmount.div(1e18);
        usdt3.transfer(buyer,scaledAmount);
        emit Sold(buyer, _busd, scaledAmount);
        
    }
    
    function purchase(address _aggregator, uint _amount) external onlyAggregator{
        busd.transfer(_aggregator,_amount);
    }
   
    function closeSale(address _aggregator,uint _amount) external onlyAggregator{
        usdt3.transfer(_aggregator,_amount);
        tether3Sold += _amount.div(1e18);
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