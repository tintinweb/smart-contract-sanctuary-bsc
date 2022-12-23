/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity 0.8.17;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract SeekPresale{
    
    IBEP20 public token;
    
    address payable public owner;
    
    uint256 public tokensPerBnb;
   
    uint256 public preSaleTime;
    uint256 public soldToken;
    
    mapping(address => uint256) public balances;
    mapping(address => bool) public claimed;
    

    modifier onlyOwner() {
        require(msg.sender == owner,"BEP20: Not an owner");
        _;
    }
    
    event BuyToken(address _user, uint256 _amount);
    
    constructor(address _owner, IBEP20 _token){
        owner = payable(_owner); 
        token = _token;
        tokensPerBnb = 10000;
        preSaleTime = block.timestamp + 180 days;

    }
    
    receive() external payable{}
    
    
    // to buy Seek token during preSale time 
 
    function buy() payable public{
        uint totalNumOfTokens = (msg.value * tokensPerBnb) / 1e18;
        token.transferFrom(owner, msg.sender, totalNumOfTokens * token.decimals());
        soldToken = soldToken + totalNumOfTokens;
        emit BuyToken(msg.sender, totalNumOfTokens);
    }
    
    // to check number of token for given BNB
    function bnbToToken(uint256 _amount) external  view returns(uint256){
        return (_amount* tokensPerBnb)/1e18;
    }
    
    // to change Price of the token
    function changePrice(uint256 _tokensPerBnb) external onlyOwner{
        tokensPerBnb = _tokensPerBnb;
    }
    
    
    function setpreSaleTime(uint256 _time) external onlyOwner{
        preSaleTime = _time;
    }
    
    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner{
        owner = _newOwner;
    }
    
    // to withdraw funds for liquidity
    function withdrawFunds(uint256 _value) external onlyOwner returns(bool){
        payable(owner).transfer(_value);
        return true;
    }
    
    function getCurrentTime() external  view returns(uint256){
        return block.timestamp;
    }
    
    function contractBalanceBnb() external view returns(uint256){
        return address(this).balance;
    }
    
    function getContractTokenBalance() external view returns(uint256){
        return token.allowance(owner, address(this));
    }
    
}