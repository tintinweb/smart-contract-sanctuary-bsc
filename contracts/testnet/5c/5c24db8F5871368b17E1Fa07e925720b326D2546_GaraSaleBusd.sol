/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;



interface IBEP20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// @dev using 0.8.0.
// Note: If changing this, Safe Math has to be implemented!


// File: @openzeppelin/contracts/GSN/Context.sol

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

contract GaraSaleBusd {
    
    bool    public saleActive;
    address public garaswapToken;
    address public feeCollector;
    address public owner;
    uint    public price;
    
    uint256 public tokensSold;
    
    
    // Emitted when tokens are sold
    event Sale(address indexed account, uint indexed price, uint tokensGot);
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    
    // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(_msgSender() == owner,"GARASWAP: YOU ARE NOT THE OWNER.");
        _;
    }

    constructor(address _feeCollector, address _garaswapToken) {
        owner =  _msgSender();
        feeCollector = _feeCollector;
        garaswapToken = _garaswapToken;
        saleActive = true;
    }
    
    // Change the token price
    // Note: Set the price respectively considering the decimals of eth
    // Example: If the intended price is 0.01 per token, call this function with the result of 0.01 * 10**18 (_price = intended price * 10**18; calc this in a calculator).
    function tokenPrice(uint _price) external onlyOwner {
        price = _price;
    }

    function changeFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;
    }

    function changeTokenAddress(address _tokenAddress) external onlyOwner {
        garaswapToken = _tokenAddress;
    }
    
   
    // Buy tokens function
    // Note: This function allows only purchases of "full" tokens, purchases of 0.1 tokens or 1.1 tokens for example are not possible
    function buyTokens(uint256 _tokenAmount) public payable {
        
        uint256 cost = _tokenAmount * price;



        // Check if sale is active and user tries to buy atleast 1 token
        require(saleActive == true, "GARASWAP: SALE HAS ENDED.");
        require(_tokenAmount >= 1, "GARASWAP: BUY ATLEAST 1 TOKEN.");
        require(msg.value > 0 , "GARASWAP: NO BNB SENT");
        require(cost <= msg.value , "GARASWAP: INSUFFICIENT AMOUNT PROVIDED FOR TOKEN PURCHASE");
        // Calculate the purchase cost
        
        
        // Calculate the tokens _msgSender() will get (with decimals)
        uint256 tokensToGet = _tokenAmount * 10**18;
      
        
        // Transfer eth from _msgSender() to the contract
        // If it returns false/didn't work, the
        //  msg.sender may not have allowed the contract to spend eth or
        //  msg.sender or the contract may be frozen or
        //  msg.sender may not have enough eth to cover the transfer.
         payable(feeCollector).transfer(msg.value);
      
        
        // Transfer GARASWAP to msg.sender
        // If it returns false/didn't work, the contract doesn't own enough tokens to cover the transfer
        require(IBEP20(garaswapToken).transfer(_msgSender(), tokensToGet), "GARASWAP: CONTRACT DOES NOT HAVE ENOUGH TOKENS.");
   

        
        tokensSold += tokensToGet;
        emit Sale(_msgSender(), price, tokensToGet);
    }

    // End the sale, don't allow any purchases anymore and send remaining garaswap to the owner
    function disableSale() external onlyOwner{
        
        // End the sale
        saleActive = false;
        
        // Send unsold tokens and remaining usdt to the owner. Only ends the sale when both calls are successful
        IBEP20(garaswapToken).transfer(feeCollector, IBEP20(garaswapToken).balanceOf(address(this)));
    }
    
    // Start the sale again - can be called anytime again
    // To enable the sale, send GARASWAP tokens to this contract
    function enableSale() external onlyOwner{
        
        // Enable the sale
        saleActive = true;
        
        // Check if the contract has any tokens to sell or cancel the enable
        require(IBEP20(garaswapToken).balanceOf(address(this)) >= 1, "GARASWAP: CONTRACT DOES NOT HAVE TOKENS TO SELL.");
    }
    

    
    // Withdraw (accidentally) to the contract sent BNB
    function withdrawBNB() external payable onlyOwner {
        payable(feeCollector).transfer(payable(address(this)).balance);
    }
    
    // Withdraw (accidentally) to the contract sent BEP20 tokens except garaswap
    function withdrawIBEP20(address _token) external onlyOwner {
        uint _tokenBalance = IBEP20(_token).balanceOf(address(this));
        
        // Don't allow garaswap to be withdrawn (use endSale() instead)
        require(_tokenBalance >= 1 && _token != garaswapToken, "GARASWAP: CONTRACT DOES NOT OWN THAT TOKEN OR TOKEN IS GARASWAP.");
        IBEP20(_token).transfer(feeCollector, _tokenBalance);
    }
}