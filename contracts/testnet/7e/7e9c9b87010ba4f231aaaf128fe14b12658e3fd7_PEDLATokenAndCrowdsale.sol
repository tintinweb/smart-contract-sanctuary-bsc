/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

pragma solidity ^0.4.20;


contract erc20interface{
  
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 
}


contract PEDLATokenAndCrowdsale {

    mapping (address => uint) public balances;
    mapping(address => mapping(address =>uint)) allowed;
    
    address tokenFundsAddress;
    
    address beneficiary;
    
    uint amountRaised;

    uint constant private TOKEN_PRICE_IN_WEI = 1 * 330000000000000000 ;
    uint constant private Total_price_in_wei = 1 * 1 ether;

    event TransferPEDLA(address indexed from, address indexed to, uint value);
    event FundsRaised(address indexed from, uint fundsReceivedInWei, uint tokensIssued);
    event ETHFundsWithdrawn(address indexed recipient, uint fundsWithdrawnInWei);

           
    
    
    constructor(uint initialSupply) public {
        balances[msg.sender] = initialSupply;
        tokenFundsAddress = msg.sender;
        beneficiary = tokenFundsAddress;
    }
    
    

    function sendTokens(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit TransferPEDLA(msg.sender, receiver, amount);
    }
    
    function getBalance(address addr) public view returns (uint) {
        return balances[addr];
    }

    function buyTokensWithEther() public payable {
        uint numTokens = msg.value / TOKEN_PRICE_IN_WEI;
        balances[tokenFundsAddress] -= numTokens;
        balances[msg.sender] += numTokens;
        amountRaised += msg.value / Total_price_in_wei;
        emit FundsRaised(msg.sender, msg.value, numTokens);
    }
    
    /*function withdrawRaisedFunds() public {
        if (msg.sender != beneficiary)
            return;
            beneficiary.transfer(amountRaised);
            emit ETHFundsWithdrawn(beneficiary, amountRaised);
        
    }*/
    function myAddress() public constant returns (address){
        address myAdr = msg.sender;
        return myAdr;
    }
    function myBalance() public constant returns (uint){
        return (balances[msg.sender]);
    }
    function totalFunds() public constant returns (uint){
        return amountRaised;
    }
    function endSale() public {
        require(msg.sender == beneficiary);
        beneficiary.transfer(address(this).balance);

    }
}