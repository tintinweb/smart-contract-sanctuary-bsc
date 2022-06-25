// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./GFTToken.sol";
import "./Ownable.sol";

contract BuyGFT is Ownable {
    address gftAddress;
    uint public tokenPerBnb;
    uint public tokenPerNotBnb;
    GFTToken public gftToken;

    event BuyGftUsingBNB(address _to, uint transferAmount, uint bnbAmount);
    event BuyGftUsingNotBNB(address _to, uint transferAmount, uint notBnbAmount);
    event ChangeInTokenPerBnb(uint newTokenPerBnbPrice);
    event ChangeInTokenPerNotBnb(uint newTokenPerNotBnbPrice);
    event ChangedGftContractAddress(address newGftAddress);

    constructor(uint _tokenPerNotBnb,uint _tokenPerBnb, address _gftAddress) Ownable(){
        tokenPerBnb = _tokenPerBnb;
        tokenPerNotBnb = _tokenPerNotBnb;
        gftToken = GFTToken(_gftAddress);  
    }

    //it creates new gftToken instance
    function setGftTokenContractAddress(address _newGftTokenAddress) external onlyOwner{
        require(_newGftTokenAddress != address(0),"Invalid address.");
        gftAddress = _newGftTokenAddress;
        gftToken = GFTToken(gftAddress);
        emit ChangedGftContractAddress(gftAddress);
    }

    //setting the tokenPerBnb
    function setTokenPerBnb(uint _requiredRate) external onlyOwner{
           require(_requiredRate > 0,"Invalid rate.");
           tokenPerBnb = _requiredRate; 
           emit ChangeInTokenPerBnb(tokenPerBnb);
    }
    //setting the tokenPerNotBnb

    function setTokenPerNotBnb(uint _requiredRate) external onlyOwner{
           require(_requiredRate > 0,"Invalid rate.");
           tokenPerNotBnb = _requiredRate; 
           emit ChangeInTokenPerNotBnb(tokenPerNotBnb);
    }

    //function to swap BNB with GFT token
    function buyGftUsingBNB() external payable returns(uint buyAmount){
        require(msg.value >0,"Invalid amount.");
        uint tokenBuyAmount = msg.value * tokenPerBnb;

        // checking the net balance
        uint netBalance = gftToken.balanceOf(address(this));
        require(netBalance > tokenBuyAmount,"Insufficient token balance.");

        //transferring the required amount to sender
        bool transactionStatus = gftToken.transfer(msg.sender, tokenBuyAmount);

        require(transactionStatus,"Transaction failed.");

        emit BuyGftUsingBNB(msg.sender, tokenBuyAmount, msg.value);
        return tokenBuyAmount;
    }       

    //function to swap token other than BNB with GFT token
    function buyGftUsingNotBNB() external payable returns(uint buyAmount){
        require(msg.value >0,"Invalid amount.");
        uint tokenBuyAmount = msg.value * tokenPerNotBnb;

        // checking the net balance
        uint netBalance = gftToken.balanceOf(address(this));
        require(netBalance > tokenBuyAmount,"Insufficient token balance.");

        //transferring the required amount to sender
        bool transactionStatus = gftToken.transfer(msg.sender, tokenBuyAmount);

        require(transactionStatus ,"Transaction failed.");

        emit BuyGftUsingNotBNB(msg.sender, tokenBuyAmount, msg.value);
        return tokenBuyAmount;
    }    
}