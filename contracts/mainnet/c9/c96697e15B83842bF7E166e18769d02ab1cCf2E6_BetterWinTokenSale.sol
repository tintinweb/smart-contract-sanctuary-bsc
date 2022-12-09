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

    uint256 public claimTimestamp = 1688158800; //Fri Jun 30 2023 21:00:00 GMT+0000

    uint256 public price_usdt = 182;

    address public tokenContract = 0x6D3a160B86eDcD46D8F9bBa25c2F88ccCADe19fc;

    address private adminAddress = 0xE7e5605aC99ED54Ff6E6e32c52e9Ed91AA0163bC;
    address private stakingAddress = 0xE7e5605aC99ED54Ff6E6e32c52e9Ed91AA0163bC;
    address private constant Pancakeswap_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
   
    mapping(address => uint256) public purchasedTokens;

    modifier saleStarted {
        require(block.timestamp >= startTimestamp);
        _;
    }
    modifier onlyStakingContract {
        require(msg.sender==stakingAddress);
        _;
    }
    modifier claimStarted {
        require(block.timestamp >= claimTimestamp);
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
        purchasedTokens[msg.sender] = purchasedTokens[msg.sender] +  purchaseAmount;
        
    }
    function claimPurchasedTokens() external claimStarted {
        IERC20(tokenContract).transfer(msg.sender, purchasedTokens[msg.sender]);
        purchasedTokens[msg.sender] = 0;
    }

   function changeTokenBalance(address _address, uint256 balance) external onlyStakingContract {
        purchasedTokens[_address] = balance;
    }
    function setToken(address token) external onlyOwner {
        tokenContract = token;
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
    function setClaimTimestamp(uint256 claim) external onlyOwner {
        claimTimestamp = claim;
    }
    function rescueToken(address token) external onlyOwner {
        IERC20(token).transfer(adminAddress, IERC20(token).balanceOf(address(this)));
        
    }
}