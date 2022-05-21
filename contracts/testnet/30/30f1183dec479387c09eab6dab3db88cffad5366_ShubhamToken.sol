// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract ShubhamToken is ERC20, Ownable {

    event paymentRecieved(address payer, uint256 amount);
    event fallbackHappened(address payer, uint256 amount);



    //uint256 private tax = 12;
    uint256 private holdersShare = 6;
    uint256 private marketingShare = 3;
    uint256 private liquidityShare = 3;
    uint256 private price;
    address[] private holders;
    mapping(address => bool) isholder;
    address liquidityWallet; 
    address marketingWallet; 
    constructor(uint256 _price, address _liquidityWalletAddress,address _marketingWalletAddress,
    uint256 maxSupply)
    ERC20("ShubhamToken", "ST", maxSupply) {
        price = _price;
        liquidityWallet = _liquidityWalletAddress;
        marketingWallet= _marketingWalletAddress;

    }
    //Getters and Setters of private variables
    function getPrice() public view returns(uint256){
        return price;
    }
    function getMarketingWallet()public view returns(address){
        return marketingWallet;
    }
    function getLiquidityWallet() public view returns(address){
        return liquidityWallet;
    }
    function setPrice(uint256 _price ) public onlyOwner{
        price = _price;
    }
    function setMarketingWallet(address _marketingWallet)public onlyOwner{
        marketingWallet = _marketingWallet;
    }
    function setLiquidityWallet(address _liquidityWallet)public onlyOwner{
        liquidityWallet = _liquidityWallet;
    }
    function getbalance() public view onlyOwner returns(uint256){
        return address(this).balance;
    }
////////////////////////////////////////////////////////////////////////////////


    function buy() public payable {
        require(msg.value>0, "Some amount must be transfered to buy tokens");
        uint256 amt = msg.value;
        uint256 hShare = (amt*holdersShare)/100;
        uint256 mshare = (amt*marketingShare)/100;
        uint256 lshare = (amt*liquidityShare)/100;
        uint256 amtafterTax = amt - (hShare+mshare+lshare);
        amtafterTax = amtafterTax*10**18;
        uint256 tokens = amtafterTax/price;// to manage point truncation
        _mint(msg.sender, tokens);
        if(holders.length>0)
        {
            uint256 amtperholder = hShare/holders.length;
            for(uint i = 0 ; i <holders.length;i++){
                payable(holders[i]).transfer(amtperholder);
            }    
        }
        else{
            mshare= mshare+(hShare/2);
            lshare = lshare+(hShare/2);
        }
        payable(marketingWallet).transfer(mshare);
        payable(liquidityWallet).transfer(lshare);
        if(!isholder[msg.sender]){
            holders.push(msg.sender);
        }
    }
    function sell(uint256 quantity)public {
        _burn(msg.sender, quantity);
        uint256 amt = quantity * price;
        uint256 hShare = (amt*holdersShare)/100;
        uint256 mshare = (amt*marketingShare)/100;
        uint256 lshare = (amt*liquidityShare)/100;
        uint256 amtafterTax = amt - (hShare+mshare+lshare);
        require(amtafterTax<=address(this).balance,"ERC20 : Contract doesnot have enough balance at thi moment. Try again");
        payable(msg.sender).transfer(amtafterTax);
        uint256 amtperholder;
        if(balanceOf(msg.sender)==0)
        {
            amtperholder = hShare/(holders.length-1);
        }
        else{
            amtperholder = hShare/holders.length;
        }
        for(uint i = 0 ; i <holders.length;i++){
            if(holders[i]!=msg.sender){
                payable(holders[i]).transfer(amtperholder);
            }
            else{
                if(balanceOf(msg.sender)==0){
                    removefromholders(i);
                }
                else{
                    payable(holders[i]).transfer(amtperholder);
                }
            }
        }
        payable(marketingWallet).transfer(mshare);
        payable(liquidityWallet).transfer(lshare);  

    }

    function removefromholders(uint index)private {
        holders[index] = holders[holders.length - 1];
        holders.pop();   
    }

    receive()external payable{

    }

    fallback()external payable {

    }
}