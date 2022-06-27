// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./GFTToken.sol";
import "./Ownable.sol";

contract BuyGFT is Ownable {
    address gftAddress;
    address masterAccountAddess;
    uint public tokenPerBnb;
    uint public tokenPerNotBnb;
    GFTToken public gftToken;

    event BuyGftUsingBNB(address _to, uint transferAmount, uint bnbAmount,uint contractBalance);
    event BuyGftUsingNotBNB(address _to, uint transferAmount, uint notBnbAmount,uint contractBalance);
    event ChangeInTokenPerBnb(uint newTokenPerBnbPrice);
    event ChangeInTokenPerNotBnb(uint newTokenPerNotBnbPrice);
    event ChangedGftContractAddress(address newGftAddress);

    constructor(uint _tokenPerNotBnb,uint _tokenPerBnb, address _gftAddress, address _masterAccountAddess) Ownable(){
        tokenPerBnb = _tokenPerBnb;
        tokenPerNotBnb = _tokenPerNotBnb;
        gftToken = GFTToken(_gftAddress);  
        masterAccountAddess = _masterAccountAddess; 
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
    function buyGftUsingBNB() external payable returns(uint amount,address _ad,uint rbalance){
        return transferBNB(msg.value,msg.sender);
    }       

    //function to swap token other than BNB with GFT token
    function buyGftUsingToken() external payable returns(uint buyAmount){
        return transferToken(msg.value,msg.sender);       
    }    

    function transferBNB(uint _amount, address _sender) internal returns(uint _txAmount,address ad,uint _rbalance){
        require(_amount >0,"Invalid amount.");
        uint tokenBuyAmount = _amount * tokenPerBnb;

        // checking the net balance
        uint netBalance = gftToken.balanceOf(address(this));
        require(netBalance > tokenBuyAmount,"Insufficient token balance.");

        //transferring the required amount to sender
        bool transactionStatus = gftToken.transfer(_sender, tokenBuyAmount);

        require(transactionStatus,"Transaction failed.");

        // //transferring bnb to masterAccountAddess
        require(address(this).balance >= _amount,"Transaction balace has not replicated yet.");        
        payable(masterAccountAddess).transfer(_amount);

        emit BuyGftUsingBNB(_sender, tokenBuyAmount, _amount,address(this).balance);
        return (tokenBuyAmount,_sender,address(this).balance);
    }

    function transferToken(uint _amount, address _sender) internal returns(uint _txAmount){
        // require(_amount >0,"Invalid amount.");
        uint tokenBuyAmount = _amount * tokenPerNotBnb;

        // // checking the net balance
        // uint netBalance = gftToken.balanceOf(address(this));
        // require(netBalance > tokenBuyAmount,"Insufficient token balance.");

        // //transferring the required amount to sender
        // bool transactionStatus = gftToken.transfer(_sender, tokenBuyAmount);

        // require(transactionStatus ,"Transaction failed.");

        emit BuyGftUsingNotBNB(_sender, tokenBuyAmount, _amount,address(this).balance);
        return tokenBuyAmount;
    }

    function withdrawGFT()external payable onlyOwner returns(uint balnce){
        require(gftToken.balanceOf(address(this)) > 0,"Insufficient Balance.");
        uint requiredAmount = gftToken.balanceOf(address(this));
        bool transactionStatus = gftToken.transfer(owner, requiredAmount);
        require(transactionStatus ,"Transaction failed.");
        return requiredAmount;
    }

}