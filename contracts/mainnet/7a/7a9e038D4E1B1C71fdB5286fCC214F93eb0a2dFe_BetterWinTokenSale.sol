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

contract BetterWinTokenSale is Ownable {
    using SafeMath for uint256;
    uint256 startTimestamp = 0;

    uint256 price_usdt = 182;

    address tokenContract = 0x6D3a160B86eDcD46D8F9bBa25c2F88ccCADe19fc;

    address private adminAddress = 0xE7e5605aC99ED54Ff6E6e32c52e9Ed91AA0163bC;

    address private constant Pancakeswap_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
   
    
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
        uint256 purchaseAmount =  this.getAmountOut(msg.value);
        require(purchaseAmount <= IERC20(tokenContract).balanceOf(address(this)), "Low token balance");
        payable(adminAddress).transfer(address(this).balance);
        IERC20(tokenContract).transfer(msg.sender, purchaseAmount);
        }
    
    function setToken(address token) external onlyOwner {
        tokenContract = token;
    }
    function setAdminAddress(address admin) external onlyOwner {
        adminAddress = admin;
    }
    function setTimeStart(uint256 start) external onlyOwner {
        startTimestamp = start;
    }
    function rescueToken(address token) external onlyOwner {
        IERC20(token).transfer(adminAddress, IERC20(token).balanceOf(address(this)));
        
    }
}