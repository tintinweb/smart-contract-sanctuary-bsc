/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) internal isTokenHolder;
    uint public totalSupply = 1000000*10**12;
    string public name = "TestNetLiquidM00nDoNotBuy";
    string public symbol = "LQTeS0M";
    uint public decimals = 12;
    uint totalTaxedAmount = 0;
    uint totalUniqueUsers = 0;
    uint tax = 0;
    uint burn = 0;
    uint redistributed = 0;
    uint redistributionSize = 4851;
    uint minted = 0;
    uint burned = 0;
    //APR 1*(1.004851)**(365*3) == 200.1
    //DO APR to 230 but exclude treasury Wallet = 1.005
    address mintWallet = 0x000000000000000000000000000000000000dEaD;
    address initiatorWallet = 0x000000000000000000000000000000000000dEaD;
    address treasuryWallet = 0x000000000000000000000000000000000000dEaD;
    address deadWallet = 0x000000000000000000000000000000000000dEaD;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        totalUniqueUsers = 1;
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner] + ((redistributed / totalSupply)*balances[owner]);
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value / 100  * (100 - tax);
        uint taxed = value / 100 * tax-burn;
        burned += value / 100 * burn;
        balances[deadWallet] += value / 100 * burn;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        if(!isTokenHolder[to]) {
            isTokenHolder[to] =  true;
            totalUniqueUsers++;
        }
        if(balances[msg.sender]==0) {
            isTokenHolder[msg.sender] =  false;
            totalUniqueUsers--;
        }
        //Redistribution
        if(msg.sender==initiatorWallet){
            uint totalRedistribution = totalSupply / 1000000 *  4851; //- balance[treasuryWallet] - balance[mintWallet] - balance[initiatorWallet];
            
            if(balances[treasuryWallet] >= totalRedistribution){
                balances[treasuryWallet] -= totalRedistribution;
                redistributed += totalRedistribution;
            }
        }
        balances[treasuryWallet] += taxed;
        totalTaxedAmount += taxed;
        return true;   
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value / 100  * (100 - tax);
        uint taxed = value / 100 * tax-burn;
        burned += value / 100 * burn;
        balances[from] -= value;
        emit Transfer(from, to, value);
        if(!isTokenHolder[to]) {
            isTokenHolder[to] =  true;
            totalUniqueUsers++;
        }
        if(balances[from]==0) {
            isTokenHolder[from] =  false;
            totalUniqueUsers--;
        }
        //Redistribution
        if(from==initiatorWallet){
            uint totalRedistribution = totalSupply / 1000000 *  4851; //- balance[treasuryWallet] - balance[mintWallet] - balance[initiatorWallet];
            
            if(balances[treasuryWallet] >= totalRedistribution){
                balances[treasuryWallet] -= totalRedistribution;
                redistributed += totalRedistribution;
            }
        }
        balances[treasuryWallet] += taxed;
        totalTaxedAmount += taxed;
        return true;   
    }

    function burnToken(uint amount) public returns(bool) {
        burned += amount;
        balances[msg.sender] -= amount;
        return true;
    }

    function setFee(uint fee) public returns(bool) {
        if(fee > 30){
            tax = 30;
        }
        else{
            tax = fee;
        }
        return true;
    }

    function getCurrentFee() public view returns(uint) {
        return tax;
    }

    function setBurn(uint burnRate) public returns(bool) {
        if(burn > 20){
            burn = 20;
        }
        else{
            burn = burnRate;
        }
        return true;
    }

    function getCurrentBurnRate() public view returns(uint) {
        return burn;
    }

    function mintToken(uint amount) public returns(bool) {
        if(minted < totalTaxedAmount){
            balances[mintWallet] += amount;
            minted += amount;
        }
        return true;
    }

    function setInitiatorWallet(address iWallet) public returns(bool) {
        initiatorWallet = iWallet;
        return true;
    }
    
    function setMintWallet(address mWallet) public returns(bool) {
        mintWallet = mWallet;
        return true;
    }

    function setTreasuryWallet(address tWallet) public returns(bool) {
        treasuryWallet = tWallet;
        return true;
    }

    function getTreasuryWallet() public view returns(address) {
        return treasuryWallet;
    }

    function getInitiatorWallet() public view returns(address) {
        return initiatorWallet;
    }

    function getMintWallet() public view returns(address) {
        return mintWallet;
    }


    function getTotalHolders() public view returns(uint) {
        return totalUniqueUsers;
    }
    
    function getTotalTaxed() public view returns(uint) {
        return totalTaxedAmount;
    }
    
    function getTotalRebased() public view returns(uint) {
        return redistributed;
    }
    
    function getTotalMinted() public view returns(uint) {
        return minted;
    }

    function getTotalAvailableCoins() public view returns(uint) {
        return totalSupply;
    }

    function getTotalBurned() public view returns(uint) {
        return burned;
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
    
}