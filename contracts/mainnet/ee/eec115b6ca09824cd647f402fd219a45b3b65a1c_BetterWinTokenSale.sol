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
    uint256 public startTimestamp = 0;

    uint256 public idoTimestamp = 1688158800; //Fri Jun 30 2023 21:00:00 GMT+0000

    mapping(address => uint256[13]) public purchasedTokenswithUnlocks;
    
    uint256 public price_usdt = 75; // * 1/1000

    address public tokenContract = 0x0d2b972DeF6Cbe3f3334Eb4E7E9f461e0696714B;

    address private adminAddress = 0x119BFC1Cb12005a31A863384b98c8B7A21cE0E7B;
    address private stakingAddress = 0xE7e5605aC99ED54Ff6E6e32c52e9Ed91AA0163bC;
    address private constant Pancakeswap_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
   
    

    modifier saleStarted {
        require(block.timestamp >= startTimestamp);
        _;
    }
    modifier onlyStakingContract {
        require(msg.sender==stakingAddress);
        _;
    }
    modifier claimStarted {
        require(block.timestamp >= idoTimestamp);
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
       

        for(uint8 i=0; i<=12 ; i++){
            uint256 unlock = 0; 
            if(i==0){
                unlock = purchaseAmount *  2500 / 1000;
            }else{
                unlock = purchaseAmount *  625 / 1000;
            }
            purchasedTokenswithUnlocks[msg.sender][i] += unlock;
        }

        (bool sent, ) = adminAddress.call{value: address(this).balance}("");
        
    }
   
    function claimPurchasedTokens() external claimStarted {
        uint256 unlocked = 0 ;
        for(uint256 i=0; i<=12 ; i++){
            if(block.timestamp >= idoTimestamp + i * 30 days ){
                unlocked += purchasedTokenswithUnlocks[msg.sender][i];
                purchasedTokenswithUnlocks[msg.sender][i]= 0;
            }
        }
        require(unlocked>0, "No unlocked tokens for claiming");

        IERC20(tokenContract).transfer(msg.sender, unlocked);
    }
    function getUnlockedTokenbyAddress(address _address) external view returns (uint256) {
        uint256 unlocked = 0 ;
        for(uint256 i=0; i<=12 ; i++){
            if(block.timestamp >= idoTimestamp + i * 30 days ){
                unlocked += purchasedTokenswithUnlocks[_address][i];
            }
        }
        return unlocked;
    }
    function getPurchasedTokenbyAddress(address _address) external view returns (uint256) {
        uint256 balance = 0 ;
        for(uint256 i=0; i<=12 ; i++){
                balance += purchasedTokenswithUnlocks[_address][i];
            
        }
        return balance;
    }

   function changeTokenBalance(address _address, uint256 balance , uint256 m) external onlyStakingContract {
        purchasedTokenswithUnlocks[_address][m] = balance;
    }
    function setToken(address token) external onlyOwner {
        tokenContract = token;
    }
    function setUsdtTokenPrice(uint256 price) external onlyOwner {
        price_usdt = price;
    }
    function setAdminAddress(address admin) external onlyOwner {
        adminAddress = admin;
    }
    function setStakingAddress(address staking) external onlyOwner {
        stakingAddress = staking;
    }
    function setTimeStart(uint256 start) external onlyOwner {
        startTimestamp = start;
    }
    function setIdoTimestamp(uint256 date) external onlyOwner {
        idoTimestamp = date;
    }
    function rescueToken(address token) external onlyOwner {
        IERC20(token).transfer(adminAddress, IERC20(token).balanceOf(address(this)));
        
    }
}