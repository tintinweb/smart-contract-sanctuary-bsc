// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ERC20.sol";
import "./Ownable.sol";


interface IPancakeswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
}

contract BitFightTokenSale is Ownable {
    using SafeMath for uint256;
    uint256 public startTimestamp = 0;

    uint256 public price_usdt = 50;

    uint256 public round_n = 1; // Round 1/10
    uint256 public round_goal = 100 * 1e18; //50 BNB
    uint256 public round_sold = 0;
    uint256 public total_sold = 0;
    address public tokenContract = 0xd2b0E9eDB5fb99374F72C9Ca60EbF05Fc6165C5A;

    address private adminAddress = 0x4BCC21F0CC18C7612b0E908A456674ac8B036223;
    address private constant Pancakeswap_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
   
    mapping(address => uint256) public purchasedTokens;

    modifier saleStarted {
        require(block.timestamp >= startTimestamp);
        _;
    }
  
    

    function getAmountOut( uint256 _amountIn) external view returns (uint256) {
       
        address[] memory path;
        path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0x55d398326f99059fF775485246999027B3197955;
        
        uint256[] memory amountOutMins = IPancakeswapV2Router(Pancakeswap_V2_ROUTER).getAmountsOut(_amountIn, path);
        uint256 usdtAmount = amountOutMins[path.length -1] * 1000;
        uint256 tokenAmount = usdtAmount / price_usdt;
        return tokenAmount;
    
    }
    
    function purchaseTokens() saleStarted payable public {
        require(round_sold<round_goal , "sold out");
        
        total_sold+=msg.value;
        round_sold+=msg.value;
        uint256 purchaseAmount =  this.getAmountOut(msg.value);
        require(purchaseAmount <= IERC20(tokenContract).balanceOf(address(this)), "Low token balance");
        
        IERC20(tokenContract).transfer(msg.sender, purchaseAmount);
        (bool sent, ) = adminAddress.call{value: address(this).balance}("");
        
    }

    function externalPurchase(address _buyer, uint256 _token_amount, uint256 _bnb_amount) saleStarted onlyOwner public {
        IERC20(tokenContract).transfer(_buyer, _token_amount);
        total_sold += _bnb_amount;
    }

    function setTokenContract(address token) external onlyOwner {
        tokenContract = token;
    }
    function setUsdtTokenPrice(uint256 price) external onlyOwner {
        price_usdt = price;
    }
    function setAdminAddress(address admin) external onlyOwner {
        adminAddress = admin;
    }
    function setRoundGoal(uint256 _goal) external onlyOwner {
        round_goal = _goal;
    }
    function setRoundNumber(uint256 _n) external onlyOwner {
        round_n = _n;
    }
    function setRoundSold(uint256 _sold) external onlyOwner {
        round_sold = _sold;
    }
    function setTimeStart(uint256 start) external onlyOwner {
        startTimestamp = start;
    }
    
    function rescueToken(address token) external onlyOwner {
        IERC20(token).transfer(adminAddress, IERC20(token).balanceOf(address(this)));
        
    }
}