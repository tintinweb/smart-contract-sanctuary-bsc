/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity  ^0.8.0;

contract IDO{

    address [] public whiteList;
    mapping(address=>bool) public whiteListMapping;
    address [] public contributor;
    address public manager ; 
    address public deposit;

    uint public hardcap = 1000 ether;
    uint public raiseAmount =0;

    uint public canBuy =0;

    constructor(address _deposit , address [] memory initWhitelist )
    {
        manager = msg.sender;
        deposit = _deposit;
        whiteList = initWhitelist;

        for(uint i =0;i<whiteList.length ;i++)
        {
            whiteListMapping[whiteList[i]] = true;
        }
    }

    modifier onlyAdmin(){
        require(msg.sender == manager);
        _;
    }

    function isWhitelist(address check) public view returns(uint)
    {
        if(whiteListMapping[check]) return 1;
        return 0;
    }

    function changeStatus() public onlyAdmin returns(bool)
    {
        if(canBuy ==1) canBuy =0;
        else if(canBuy ==0) canBuy =1;
        return true;
    }

    function enter() public payable returns(bool)
    {
        require(canBuy ==1 ,"Can't buy");
        require( whiteListMapping[msg.sender] == true ,"You are not in whitelist");
        require(msg.value == 0.2 ether,"Don't enough 0.2 BNB");
        contributor.push(msg.sender);

         payable(deposit).transfer(msg.value);
         raiseAmount += 0.2 ether;

        return true;
     
         
    }

    function getWhiteList() public onlyAdmin view returns(address[] memory)  {
        return whiteList;
    }

    function getContributor() public onlyAdmin view returns(address[] memory)  {
        return contributor;
    }

}