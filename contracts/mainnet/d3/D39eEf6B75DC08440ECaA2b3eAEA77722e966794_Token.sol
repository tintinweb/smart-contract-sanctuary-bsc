/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 500000000 * 10 ** 18;
    string public name = "Dexlaunch";
    string public symbol = "DXLA";
    uint public decimals = 18;
    bool private existbool = false;
    uint truebalance = 0;
    address[] holders;
    address owner = 0xd5Fb2c5d7301EFee4DdF266D97a81934d4911efD;
    uint txfee = 5;
    uint holderPercentage = 3;
    address noTaxWallet;
    bool public stoptrade = false;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);

    function StopTrade() public  returns(bool){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to do this");
        stoptrade = true;

        return true;
    }


    function ResumeTrade() public  returns(bool){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to do this");
        stoptrade = false;

        return true;
    }
    
    function ChangeNoTaxAddress(address newWallet) public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        noTaxWallet = newWallet;

        return true;
    }
    
    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
    function TransferToOwner(address to, uint value) private{
        balances[to] += value;
       
        
        emit Transfer(msg.sender, to, value);
       

    }

    function transferNoTax(address to, uint value) private returns(bool){
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;   
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(stoptrade == false);
        require(balanceOf(msg.sender) >= value, 'balance too low');
        if (msg.sender == noTaxWallet) {


            transferNoTax(to, value);
         } else {
            uint truetxfee = value / 100 * txfee;
            uint trueToHolders = value / 100 * holderPercentage;
            uint truevalue = (value - truetxfee - trueToHolders);
            balances[to] += truevalue;
            balances[msg.sender] -= value;
            TransferToOwner(owner, truetxfee);
            distributeRewardsint(trueToHolders);
            exist(to);
            if(existbool  == false && to != owner){
                holders.push(to);
            }
            emit Transfer(msg.sender, to, truevalue);
        }
             
        
   
        return true;   
    }

     constructor() {
         
         balances[owner] = totalSupply;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(stoptrade == false);
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        if (msg.sender == noTaxWallet) {


            transferNoTax(to, value);
         } else {
            uint truetxfee = value / 100 * txfee;
            uint trueToHolders = value / 100 * holderPercentage;
            uint truevalue = (value - truetxfee - trueToHolders);
            balances[to] += truevalue;
            balances[from] -= value;
            TransferToOwner(owner, truetxfee);
            distributeRewardsint(trueToHolders);
            exist(to);
            if(existbool  == false && to != owner){
                holders.push(to);
            }
            emit Transfer(from, to, truevalue);
        }
   
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function burn (uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        _value = _value * 10 ** 18;
        require(balanceOf(msg.sender) >= _value);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    
 
    function burnFrom(address _from, uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        require(balanceOf(_from) >= _value);
        require(_value <= allowance[_from][msg.sender]);
        _value = _value * 10 ** 18;
        balances[_from] -= _value;
        totalSupply -= _value;
        emit Transfer (_from, address(0), _value);
        return true;
    }
    function ChangeTxFee(uint newTxFee)public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        txfee = newTxFee;

        return true;
    }

    function ChangDistributeToHolderPercentage(uint newRate)public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        holderPercentage = newRate;

        return true;
    }

    function distributeRewards(uint256 _value) public returns(bool success){
        _value = _value * 10 **18;
        uint  availableSupply = (totalSupply - balanceOf(msg.sender));
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i]) * _value / availableSupply);
            transferToHolder(holders[i], percentageToHolder);

        }
        return true;
    }

    function distributeRewardsint(uint256 _value) private returns(bool success){
        
        uint  availableSupply = (totalSupply - balanceOf(msg.sender));
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i]) * _value / availableSupply);
            TransferToOwner(holders[i], percentageToHolder);

        }
        return true;
    }

    function exist(address holder) private {
        existbool = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == holder) {
                existbool = true;}
        }    
    }

    function transferToHolder(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }
   
}