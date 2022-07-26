// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./GFTToken.sol";
import "./Ownable.sol";

interface BUSDImplementation {
    function balanceOf(address _addr) external view returns (uint256);
    function transferFrom(address _from,address _to,uint256 _value) external returns (bool);
}

contract BuyGFT is Ownable {
    address masterAccountAddess;
    uint256  tokenPerBNB;
    uint256  tokenPerBUSDT;
    uint256 _totalSold;
    GFTToken public gftToken;
    BUSDImplementation public busdtToken;

    event BuyGftUsingBNB(address _to, uint256 transferAmount, uint256 bnbAmount);
    event BuyGftUsingBUSDT(address _to, uint256 transferAmount, uint256 notBnbAmount);
    event ChangeInTokenPerBNB(uint256 newTokenPerBnbPrice);
    event ChangeInTokenPerBUSDT(uint256 newTokenPerNotBnbPrice);
    event ChangedGftContractAddress(address newGftAddress);
    event ChangedBusdtContractAddress(address newBusdtAddress);
    event DoneWithdraw(uint256 withdrawAmount);

    constructor(uint256 _tokenPerBNB,uint256 _tokenPerBUSDT, address _gftAddress,address _busdtAddress, address _masterAccountAddess) Ownable(){
        require(_masterAccountAddess != address(0),"Invalid masterAccountAddess.");
        require(_gftAddress != address(0),"Invalid gftAddress.");
        require(_busdtAddress != address(0),"Invalid busdtAddress.");
        require((_tokenPerBNB !=0) &&  (_tokenPerBUSDT != 0),"Invalid rates.");

        tokenPerBNB = _tokenPerBNB;
        tokenPerBUSDT = _tokenPerBUSDT;
        masterAccountAddess = _masterAccountAddess; 
        gftToken = GFTToken(_gftAddress);  
        busdtToken = BUSDImplementation(_busdtAddress);
    }

    //this function returns amount of GFT tokens sold using this contract.
    // i/p param type: NA
    // o/p param type: uint256
    function totalSold() view external returns(uint256 totalSell){
          return _totalSold;                         
    }

    // description: function returns tokenPerBNB rate. 
    // i/p param type: NA
    // o/p param type: uint256 
    function getTokenPerBNB() view external returns(uint256 _tokenPerBNB){
        return tokenPerBNB;
    }

    // description: function returns tokenPerBUSDT rate. 
    // i/p param type: NA
    // o/p param type: uint256 
    function getTokenPerBUSDT() view external returns(uint256 _tokenPerBUSDT){
        return tokenPerBUSDT;
    }

    // description: It creates new gftToken instance.
    // i/p param type: address
    // o/p param type: NA 
    function setGftTokenContractAddress(address _newGftTokenAddress) external onlyOwner{
        require(_newGftTokenAddress != address(0),"Invalid address.");
        gftToken = GFTToken(_newGftTokenAddress);
        emit ChangedGftContractAddress(_newGftTokenAddress);
    }

    // description: It creates new busdtToken instance.
    // i/p param type: address
    // o/p param type: NA
    function setBusdtTokenContractAddress(address _newBusdtTokenAddress) external onlyOwner{
        require(_newBusdtTokenAddress != address(0),"Invalid address.");
        busdtToken = BUSDImplementation(_newBusdtTokenAddress);
        emit ChangedBusdtContractAddress(_newBusdtTokenAddress);
    }

    // description: setting the tokenPerBNB reate
    // i/p param type: uint256
    // o/p param type: NA 
    function setTokenPerBNB(uint256 _requiredRate) external onlyOwner{
           require(_requiredRate > 0,"Invalid rate.");
           tokenPerBNB = _requiredRate; 
           emit ChangeInTokenPerBNB(tokenPerBNB);
    }
 
    //setting the tokenPerNotBnb
    // i/p param type: uint256
    // o/p param type: NA 
    function setTokenPerBUSDT(uint256 _requiredRate) external onlyOwner{
           require(_requiredRate > 0,"Invalid rate.");
           tokenPerBUSDT = _requiredRate; 
           emit ChangeInTokenPerBUSDT(tokenPerBUSDT);
    }

    // description: function to swap BNB with GFT token
    // i/p param type: NA
    // o/p param type: uint256
    function buyGftUsingBNB() external payable returns(uint256 amount){
        return transferBNB(msg.value,msg.sender);
    }       

    // description:function to swap token other than BNB with GFT token
    // i/p param type: NA
    // o/p param type: uint256
    function buyGftUsingBUSDT(uint256 _amount) external returns(uint256 buyAmount){
        return transferBUSDT(_amount,msg.sender);               
    }    

    // description : It is a internal function facilitates swapping between BNB-GFT.
    // i/p param type: uint256,address
    // o/p param type: uint256
    function transferBNB(uint256 _amount, address _sender) internal returns(uint256 _txAmount){
        require(_amount >0,"Invalid amount.");
        uint tokenBuyAmount = _amount / tokenPerBNB;

        // checking the net balance
        uint netBalance = gftToken.balanceOf(address(this));
        require(netBalance > tokenBuyAmount,"Insufficient token balance.");

        _totalSold += tokenBuyAmount;
        //transferring the required amount to sender
        bool transactionStatus = gftToken.transfer(_sender, tokenBuyAmount);

        require(transactionStatus,"Transaction failed.");

        // //transferring bnb to masterAccountAddess
        require(address(this).balance >= _amount,"Transaction balace has not replicated yet.");        
        payable(masterAccountAddess).transfer(_amount);

        emit BuyGftUsingBNB(_sender, tokenBuyAmount, _amount);
        return tokenBuyAmount;
    }

    // description : It is a internal function facilitates swapping between BUSDT-GFT.
    // i/p param type: uint256,address
    // o/p param type: uint256 
    function transferBUSDT(uint256 _amount, address _sender) internal returns(uint256 _txAmount){
        require(_amount >0,"Invalid amount.");                    
        uint tokenBuyAmount = _amount / tokenPerBUSDT;

        // checking the net balance
        uint netBalance = gftToken.balanceOf(address(this));
        require(netBalance > tokenBuyAmount,"Insufficient token balance.");
        
        _totalSold += tokenBuyAmount;
        //transferring the required amount to sender
        bool transactionStatus = gftToken.transfer(_sender, tokenBuyAmount);
        require(transactionStatus,"Transaction failed.");   

        bool txStatus= busdtToken.transferFrom(msg.sender,masterAccountAddess,_amount);        
        require(txStatus ,"Transaction failed.");

        emit BuyGftUsingBUSDT(_sender, tokenBuyAmount, _amount);
        return tokenBuyAmount;
    }

    // description : function facilitates withdrawl of GFT tokens stored in the contract.
    // i/p param type: NA
    // o/p param type: uint256
    function withdrawGFT()external onlyOwner returns(uint256 balance){
        require(gftToken.balanceOf(address(this)) > 0,"Insufficient Balance.");
        uint requiredAmount = gftToken.balanceOf(address(this));
        bool transactionStatus = gftToken.transfer(payable(owner), requiredAmount);
        require(transactionStatus ,"Transaction failed.");
        emit DoneWithdraw(requiredAmount);
        return requiredAmount;
    }

}