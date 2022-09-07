/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}



contract TokenSale {
    using SafeMath for uint256;

    IERC20 public tokenContract;  // the token being sold
    IERC20 public buyTokenContract;  
    uint256 public price;             // the price, in BUSD, per token
    uint256 public minBuy = 1;
    uint256 public maxBuy = 500;
    bool public whitelistedOnly = false;
    address public owner;
    mapping (address => bool) public _isWhitelisted;
    mapping (address => uint256) public usersBuy;

    uint256 public tokensSold;

    bool public saleStarted = true;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20 _tokenContract,IERC20 _buyTokenContract, uint256 _price) payable{
        owner = msg.sender;
        tokenContract = _tokenContract;
        buyTokenContract = _buyTokenContract;
        price = _price;
    }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }

    function buyTokens(uint256 numberOfTokens) public {
        require(saleStarted,"Sale not Started");
        if(whitelistedOnly){
            require(_isWhitelisted[msg.sender],"Only whitelisted user can buy token");
        }
        uint256 alreadyBuy =  usersBuy[msg.sender];
        uint256 scaledAmount = safeMultiply(numberOfTokens,uint256(10) ** tokenContract.decimals());
        uint256 amountTopay = safeMultiply(safeMultiply(numberOfTokens,price),uint256(10) ** buyTokenContract.decimals());
        
        require(alreadyBuy.add(scaledAmount) <= safeMultiply(maxBuy,uint256(10) ** tokenContract.decimals()),"Your buy amount limited");
        require( scaledAmount >= safeMultiply(minBuy,uint256(10) ** tokenContract.decimals()),"You are under min buy limit");



        require(tokenContract.balanceOf(address(this)) >= scaledAmount,"Tokens sold out");
        require(buyTokenContract.balanceOf(msg.sender) >= scaledAmount,"Not enough balance to buy");

        require(buyTokenContract.transferFrom(msg.sender,address(this), amountTopay));
        
        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;
        require(tokenContract.transfer(msg.sender, scaledAmount));
        usersBuy[msg.sender]+=scaledAmount;
    }
    
    function startSale() public {
        require(msg.sender == owner);
        saleStarted = true;
    }

    function endSale() public {
        require(msg.sender == owner);
        saleStarted = false;
    }
    function enableWhiteListOnly() public {
        require(msg.sender == owner);
        whitelistedOnly = true;
    }
    function disableWhiteListOnly() public {
        require(msg.sender == owner);
        whitelistedOnly = false;
    }

    function setMinBuy(uint256 _min) public {
        require(msg.sender == owner);
        minBuy = _min;
    }
    function setMaxBuy(uint256 _max) public {
        require(msg.sender == owner);
        maxBuy = _max;
    }
    function getPrice() public view returns (uint256){
        return price;
    }
    function getAlreadyBuy(address adres) public view returns (uint256){
        return usersBuy[adres];
    }
    function getMinBuy() public view returns (uint256){
        return minBuy;
    }
    function getMaxBuy() public view returns (uint256){
        return maxBuy;
    }
    function getSaleTokenBalance() public view returns (uint256){
        return tokenContract.balanceOf(address(this));
    }

    function getBuyTokenBalance() public view returns (uint256){
        return buyTokenContract.balanceOf(address(this));
    }
    function isWhiteListed(address addrs) public view returns (bool){
        return _isWhitelisted[addrs];
    }

    function withdraw() public {
        require(msg.sender == owner);
        require(!saleStarted,"Please end sale first");

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        require(buyTokenContract.transfer(owner, buyTokenContract.balanceOf(address(this))));
    }
    function withdrawBUSDToken() public {
        require(msg.sender == owner);
        require(buyTokenContract.transfer(owner, buyTokenContract.balanceOf(address(this))));
    }


    function transferOwnership(address newAddress) public {
        require(msg.sender == owner);
        owner = newAddress;
    }

    function addToWhiteList(address[] memory addresses) public {
        require(msg.sender == owner);
        for(uint i = 0;i<addresses.length;i++){
            _isWhitelisted[addresses[uint(i)]] = true;
        }
        
    }
    function removeFromWhiteList(address[] memory addresses) public {
        require(msg.sender == owner);
        for(uint i = 0;i<addresses.length;i++){
            _isWhitelisted[addresses[uint(i)]] = false;
        }
        
    }
}