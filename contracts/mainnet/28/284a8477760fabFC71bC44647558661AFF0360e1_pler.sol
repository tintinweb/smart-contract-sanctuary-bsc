/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;


library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


contract pler {
    using SafeMath for uint;
     
    mapping(address => bool) whitelist;
     
    address private _owner;
    bool private allowbuy;
    bool private multinode;
    uint256 private taxBuyThreshold;
    uint256 private taxSellThreshold;
    uint256 private checkTaxAmount;
    
    address private constant UNISWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant FACTORY_ADDRESS = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    
    
    constructor () {
        _owner=msg.sender;
        whitelist[msg.sender]=true;
        allowbuy=false;
        multinode=false;
        checkTaxAmount=1000000000000000;
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'Tokenswap: EXPIRED');
        _;
    }
    
    modifier onlyOwner(){
        require(_owner==msg.sender, 'only owner can perform this action!');
        _;
    }
    
    modifier inWhiteList(){
        require(whitelist[msg.sender], "not authorized to make transaction!");
        _;
    }
    
   
 
    function Sasquatch(address[] memory path , uint256 amountIn, uint transCount, address to, bool checkBuyTax, bool checkSellTax) external inWhiteList{

    }
     

}