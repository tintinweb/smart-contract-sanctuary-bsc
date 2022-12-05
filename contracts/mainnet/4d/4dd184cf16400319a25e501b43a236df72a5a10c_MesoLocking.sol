/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.4;

interface BEP20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract MesoLocking {
    
    address public owner = 0x82C985Db0dc47f5431E5cAFc6c2352910c87C86e;
    BEP20 public token;
    uint public time;
    address public claimAddress;
    address public claimTokenAddress = 0x237EE7E111bb52034e3e3c95a12F7b6645Bf192c; // testnet token
    uint public oneDay = 86400;
    struct Claim{
        uint[] amounts;
        uint[] times;
        bool[] withdrawn;
    }
    
    mapping(address => Claim) claim;
    
    event Claimed(address user,uint amount, uint time);
    event Received(address, uint);
    
    constructor() {
        claimAddress =  owner;
        token = BEP20(claimTokenAddress);
        time  = 1828003039; //Sunday, 5 December 2027 16:07:19 GMT+05:30
       
        uint tokens      = 44100000 * (10**18);
        uint claimAmount = 220500 * (10**18);
        
        Claim storage clm = claim[claimAddress];
        for(uint i=0; i<199; i++){
            clm.amounts.push(claimAmount);
            clm.times.push(time + (90*oneDay)*i); 
            clm.withdrawn.push(false);   
        }
        
    }

  
    // Update claims for addresses with multiple entries
    function updateClaimAddress(address addr) public {
        require(msg.sender == owner , "Permission error");        
        claim[addr] = claim[claimAddress];
        delete claim[claimAddress];
        claimAddress = addr;
    }


    function updateClaimTokenAddress(address _claimTokenAddress) public {
        require(msg.sender == owner , "Permission error");        
        claimTokenAddress = _claimTokenAddress;
    }
    

    
    // Claim function
    function claimFunction(uint index,address addr) public {
        require(msg.sender == owner, "Permission error");
        uint amt = claim[claimAddress].amounts[index];
        uint timeLimit = claim[claimAddress].times[index];
        require(block.timestamp > timeLimit, "Time not reached");
        require(BEP20(claimTokenAddress).balanceOf(address(this)) >= amt, "Insufficient amount on contract");
        require(claim[claimAddress].withdrawn[index]==false, "Not bought or already claimed");
        BEP20(claimTokenAddress).transfer(addr, amt);
        claim[claimAddress].withdrawn[index] = true;
        emit Claimed(addr,amt, block.timestamp);
    }
    
    // Claim function
    function claimAll(address withdrawAddr) public {
        require(msg.sender == owner, "Permission error");
        address addr = msg.sender;
        uint len = claim[addr].amounts.length;
        uint amt = 0;
        for(uint i = 0; i < len; i++){
            if(block.timestamp > claim[addr].times[i] && claim[addr].withdrawn[i]==false) {
                amt += claim[addr].amounts[i];
            }
        }
        require(BEP20(claimTokenAddress).balanceOf(address(this)) >= amt, "Insufficient amount on contract");
        require(amt != 0, "Not bought or already claimed");
        BEP20(claimTokenAddress).transfer(withdrawAddr, amt);
        for(uint i = 0; i < len; i++){
            if(block.timestamp > claim[addr].times[i]) {
               claim[addr].withdrawn[i] = true;
            }
        }
       
        emit Claimed(withdrawAddr,amt, block.timestamp);
    }
    
    // View details
    function userDetails(address addr) public view returns (uint[] memory amounts, uint[] memory times, bool[] memory withdrawn) {
        uint len = claim[addr].amounts.length;
        amounts = new uint[](len);
        times = new uint[](len);
        withdrawn = new bool[](len);
        for(uint i = 0; i < len; i++){
            amounts[i] = claim[addr].amounts[i];
            times[i] = claim[addr].times[i];
            withdrawn[i] = claim[addr].withdrawn[i];
        }
        return (amounts, times, withdrawn);
    }
    

    
    // View details
    function userDetailsAll(address addr) public view returns (uint,uint,uint,uint) {
        uint len = claim[addr].amounts.length;
        uint totalAmount = 0;
        uint available = 0;
        uint withdrawn = 0;
        uint nextWithdrawnDate = 0;
        bool nextWithdrawnFound;
        for(uint i = 0; i < len; i++){
            totalAmount += claim[addr].amounts[i];
            if(claim[addr].withdrawn[i]==false){
                nextWithdrawnDate = (nextWithdrawnFound==false) ?  claim[addr].times[i] : nextWithdrawnDate;
                nextWithdrawnFound = true;
            }
            if(block.timestamp > claim[addr].times[i] && claim[addr].withdrawn[i]==false){
                available += claim[addr].amounts[i];
            }
            if(claim[addr].withdrawn[i]==true){
                withdrawn += claim[addr].amounts[i];
            }
        }
        return (totalAmount,available,withdrawn,nextWithdrawnDate);
    }
    
    // Get owner 
    function getOwner() public view returns (address) {
        return owner;
    }
    
    //Sub owner withdraw token and BNB
    function withdrawToken(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        require(block.timestamp > (time + 270 days), "Time limit Found");
       
        BEP20 token_ = BEP20(tokenAddress);
        token_.transfer(to, amount);
        return true;
    }
    
    // Owner Token Withdraw    
    function withdrawTokenOwner(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");      
        BEP20 token_ = BEP20(tokenAddress);
        token_.transfer(to, amount);
        return true;
    }
    
    // Owner BNB Withdraw
    function withdrawBNB(address payable to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
        return true;
    }
    
    // transfer ownership
    function ownershipTransfer(address to) public {
        require(to != address(0), "Cannot set to zero address");
        require(msg.sender == owner, "Only owner");
        owner = to;
    }
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
}