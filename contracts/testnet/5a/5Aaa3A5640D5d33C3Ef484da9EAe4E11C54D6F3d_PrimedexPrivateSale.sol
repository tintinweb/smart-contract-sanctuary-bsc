/**
 *Submitted for verification at BscScan.com on 2022-07-24
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

contract PrimedexPrivateSale {
    struct Owner{
        bool status;
        address owner;
    }
    bool    public saleActive;
    address public primedexToken;
    address public feeCollector;
    address public deployer;
    uint    public price;
    uint256 public tokensSold;
    uint public minimumAmount = 20000;
    mapping(address => Owner) public owners;
    
    
    // Emitted when tokens are sold
    event Sale(address indexed account, uint indexed price, uint tokensGot);
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    
    // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(owners[_msgSender()].status,"PRIMEDEX: YOU ARE NOT THE OWNER.");
        _;
    }

    constructor(address _feeCollector, address _primedexToken) {
        owners[_msgSender()] = Owner(true,_msgSender());
        deployer = _msgSender();
        feeCollector = _feeCollector;
        primedexToken = _primedexToken;
        saleActive = true;
    }
    
    // Change the token price
    // Note: Set the price respectively considering the decimals of eth
    // Example: If the intended price is 0.01 per token, call this function with the result of 0.01 * 10**18 (_price = intended price * 10**18; calc this in a calculator).
    function tokenPrice(uint _price) external onlyOwner {
        price = _price;
    }

    function addOwner(address _newOwner) external onlyOwner {
        require(!owners[_newOwner].status, "OWNER ALREADY EXISTS");
        owners[_newOwner] = Owner(true,_newOwner);
    }

    function removeOwner(address _oldOwner) external onlyOwner {
        require(_oldOwner != deployer, "DEPLOYER CAN NOT BE REMOVED");
        require(owners[_oldOwner].status, "OWNER DOES NOT EXISTS");
        owners[_oldOwner].status = false;
    }

    function changeFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;
    }

    function changeTokenAddress(address _tokenAddress) external onlyOwner {
        primedexToken = _tokenAddress;
    }
    
   
    // Buy tokens function
    // Note: This function allows only purchases of "full" tokens, purchases of 0.1 tokens or 1.1 tokens for example are not possible
    function buyTokens(uint256 _tokenAmount) public payable {
        
        require(_tokenAmount >= minimumAmount, "PRIMEDEX: Minimum Amount to purchase required");
        uint256 cost = _tokenAmount * price;

        // Check if sale is active and user tries to buy atleast 1 token
        require(saleActive == true, "PRIMEDEX: SALE HAS ENDED.");
        require(_tokenAmount >= 1, "PRIMEDEX: BUY ATLEAST 1 TOKEN.");
        require(msg.value > 0 , "PRIMEDEX: NO BNB SENT");
        require(cost <= msg.value , "PRIMEDEX: INSUFFICIENT AMOUNT PROVIDED FOR TOKEN PURCHASE");
        // Calculate the purchase cost
        
        
        // Calculate the tokens _msgSender() will get (with decimals)
        uint256 tokensToGet = _tokenAmount * 10**18;
      
        
        // Transfer eth from _msgSender() to the contract
        // If it returns false/didn't work, the
        //  msg.sender may not have allowed the contract to spend eth or
        //  msg.sender or the contract may be frozen or
        //  msg.sender may not have enough eth to cover the transfer.
         payable(feeCollector).transfer(msg.value);
      
        
        // Transfer PRIMEDEX to msg.sender
        // If it returns false/didn't work, the contract doesn't own enough tokens to cover the transfer
        require(IBEP20(primedexToken).transfer(_msgSender(), tokensToGet), "PRIMEDEX: CONTRACT DOES NOT HAVE ENOUGH TOKENS.");
   

        
        tokensSold += tokensToGet;
        emit Sale(_msgSender(), price, tokensToGet);
    }

    // End the sale, don't allow any purchases anymore and send remaining PRIMEDEX to the owner
    function disableSale() external onlyOwner{
        
        // End the sale
        saleActive = false;
        
        // Send unsold tokens and remaining usdt to the owner. Only ends the sale when both calls are successful
        IBEP20(primedexToken).transfer(feeCollector, IBEP20(primedexToken).balanceOf(address(this)));
    }

    function disableSaleWithoutTransfer() external onlyOwner{
        // End the sale
        saleActive = false;
    }

    function setMinimumAmount(uint amount) external onlyOwner{
        // End the sale
        minimumAmount = amount;
    }

    // Start the sale again - can be called anytime again
    // To enable the sale, send PRIMEDEX tokens to this contract
    function enableSale() external onlyOwner{
        
        // Enable the sale
        saleActive = true;
        
        // Check if the contract has any tokens to sell or cancel the enable
        require(IBEP20(primedexToken).balanceOf(address(this)) >= 1, "PRIMEDEX: CONTRACT DOES NOT HAVE TOKENS TO SELL.");
    }
    
        // Start the sale again - can be called anytime again
    // To enable the sale, send PRIMEDEX tokens to this contract
    function enableSaleWithoutTransfer() external onlyOwner{
        // Enable the sale
        saleActive = true;
    }

    // Withdraw (accidentally) to the contract sent BNB
    function withdrawBNB() external payable onlyOwner {
        payable(feeCollector).transfer(payable(address(this)).balance);
    }
    
    // Withdraw (accidentally) to the contract sent BEP20 tokens except PRIMEDEX
    function withdrawIBEP20(address _token) external onlyOwner {
        uint _tokenBalance = IBEP20(_token).balanceOf(address(this));
        
        // Don't allow PRIMEDEX to be withdrawn (use endSale() instead)
        require(_tokenBalance >= 1 && _token != primedexToken, "PRIMEDEX: CONTRACT DOES NOT OWN THAT TOKEN OR TOKEN IS PRIMEDEX.");
        IBEP20(_token).transfer(feeCollector, _tokenBalance);
    }

    receive() external payable {
       // React to receiving ether
       if(msg.value  > 0 && price > 0){
           uint amount = msg.value/price;
           if(amount > 0){
               buyTokens(amount);
           }
       }
    }

    fallback() external payable {
      if(msg.value  > 0 && price > 0){
           uint amount = msg.value/price;
           if(amount > 0){
               buyTokens(amount);
           }
       }
    }
}