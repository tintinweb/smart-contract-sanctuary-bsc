/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT
interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// @dev using 0.8.0.
// Note: If changing this, Safe Math has to be implemented!
pragma solidity 0.8.13;

contract SalesContract {
    
    bool    public saleActive;

    address public immutable tokenA;
    address public immutable tokenB;
    address public immutable rgp;
    address public immutable owner;

    uint256 public tokenAPrice;
    uint256 public tokenBPrice;
    
    uint256 public amountTokenASold;
    uint256 public amountTokenBSold;
    
    
    // Emitted when tokens are sold
    event Sale(address indexed account, address indexed token, uint indexed price, uint tokensGot);
      
    // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(msg.sender == owner,"RGP TOKEN: YOU ARE NOT THE OWNER.");
        _;
    }

    constructor( 
        address _tokenA, 
        address _tokenB, 
        address _rgp,
        uint256 _tokenAprice,
        uint256 _tokenBprice
    ) {
        owner =  msg.sender;
        tokenA = _tokenA;
        tokenB = _tokenB;
        rgp = _rgp;
        tokenAPrice = _tokenAprice;
        tokenBPrice = _tokenBprice;
        saleActive = true;
    }
    
    // Change the token price
    // Note: Set the price respectively considering the decimals of busd
    // Example: If the intended price is 0.01 per token, call this function with the result of 0.01 * 10**18 (_price = intended price * 10**18; calc this in a calculator).
    function tokenPrice(uint256 _tokenAPrice, uint256 _tokenBPrice) external onlyOwner {
        tokenAPrice = _tokenAPrice;
        tokenBPrice = _tokenBPrice;    }
    
   
    // Buy tokens function
    // Note: This function allows only purchases of "full" tokens, purchases of 0.1 tokens or 1.1 tokens for example are not possible
    error Ended();
    error Zero();
    error InvalidToken();
    error Failed();
    function buyTokens(address _tokenAddress, uint256 _tokenAmount) public {
        
        // Check if sale is active and user tries to buy atleast 1 token
        if (saleActive != true) revert Ended();
        if (_tokenAmount == 0) revert Zero();
        address user = msg.sender;
        // Calculate the purchase cost
        uint256 outputAmount = outPut(_tokenAddress, _tokenAmount);
                
        // Transfer busd from _msgSender() to the contract
        // If it returns false/didn't work, the
        //  msg.sender may not have allowed the contract to spend busd or
        //  msg.sender or the contract may be frozen or
        //  msg.sender may not have enough busd to cover the transfer.
        address token = _tokenAddress == tokenA ? tokenA : tokenB;
        if (!IERC20(token).transferFrom(user, address(this), _tokenAmount)) revert Failed();
        // update token sales
        _update(_tokenAddress, _tokenAmount);
        // Transfer RGP to msg.sender
        // If it returns false/didn't work, the contract doesn't own enough tokens to cover the transfer
        if (!IERC20(rgp).transfer(user, outputAmount)) revert Failed();
        uint256 price = _tokenAddress == tokenA ? tokenAPrice : tokenBPrice;
        emit Sale(user, _tokenAddress, price, outputAmount);
    }

    function outPut(address _tokenAddress, uint256 _tokenAmount) public view returns(uint256 amountOut) {
        uint256 theDecimal = IERC20(_tokenAddress).decimals();
        uint256 div = 100* (10**theDecimal);
        amountOut = _tokenAddress == tokenA ? (_tokenAmount * tokenAPrice) / div: (_tokenAmount * tokenBPrice) / div;
    }

    function req(address _tokenAddress) internal view {
        if(_tokenAddress != tokenA || _tokenAddress != tokenB) revert InvalidToken();
    }

    function _update(address _tokenAddress, uint256 _tokenAmount) internal {
        _tokenAddress == tokenA ? amountTokenASold += _tokenAmount : amountTokenASold += _tokenAmount;
    }

    // End the sale, don't allow any purchases anymore and send remaining rgp to the owner
    function salesStatus(bool status) external onlyOwner{        
        saleActive = status;
    }
    
    // Withdraw (accidentally) to the contract sent eth
    function withdrawETH() external payable onlyOwner {
        payable(owner).transfer(payable(address(this)).balance);
    }
    
    // Withdraw (accidentally) to the contract sent ERC20 tokens except rgp
    function withdrawIERC20(address _token) external onlyOwner {
        uint _tokenBalance = IERC20(_token).balanceOf(address(this));        
        IERC20(_token).transfer(owner, _tokenBalance);
    }
}