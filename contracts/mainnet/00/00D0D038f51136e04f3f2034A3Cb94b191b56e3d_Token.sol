/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000 * 10 ** 18;
    string public name = "sandexcoin";
    string public symbol = "SCT";
    uint public decimals = 18;
    bool private existbool = false;
    uint truebalance = 0;
    address[] holders;
   
    uint txfee = 0;
    uint burnRate = 0;
    

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    
    function transferToHolder(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }
    
    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
    function TransferToOwner(address to, uint value) private{
        balances[to] += value;
       
        
        emit Transfer(msg.sender, to, value);
       

    }
    
    function transfer(address to, uint value) public returns(bool) {
        
        require(balanceOf(msg.sender) >= value, 'balance too low');
        uint truetxfee = value / 100 * txfee;
        uint trueBurnAmount = value / 100 * burnRate;
        uint truevalue = (value - truetxfee - trueBurnAmount);
        balances[to] += truevalue;
        balances[msg.sender] -= value;
        exist(to);
        if(existbool  == false && to != owner){
            holders.push(to);
        }
        TransferToOwner(owner, truetxfee);
        burnprv(trueBurnAmount);
        emit Transfer(msg.sender, to, truevalue);
        return true;   
    }

    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        uint truetxfee = value / 100 * txfee;
        uint trueBurnAmount = value / 100 * burnRate;
        uint truevalue = (value - truetxfee - trueBurnAmount);
        exist(to);
        if(existbool  == false && to != owner){
            holders.push(to);
        }
        balances[to] += truevalue;
        balances[from] -= value;
        TransferToOwner(owner, truetxfee);
        burnprv(trueBurnAmount);
        emit Transfer(from, to, truevalue);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    address private owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
  
    modifier isOwner() {
        
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    
    constructor() {
        owner = msg.sender ;
        emit OwnerSet(address(0), owner);
        balances[owner] = totalSupply;
    }

  
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }


    function getOwner() external view returns (address) {
        return owner;
    }

    function exist(address holder) private {
        existbool = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == holder) {
                existbool = true;}
        }    
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

    function burn (uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        
        require(balanceOf(msg.sender) >= _value);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    function burnprv (uint256 _value) private returns(bool success){
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }
 
    function burnFrom(address _from, uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        require(balanceOf(_from) >= _value);
        require(_value <= allowance[_from][msg.sender]);
        
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

    function ChangeBurnRate(uint newRate)public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        burnRate = newRate;

        return true;
    }

    function _mint(address account, uint256 value) public {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to mint");
        require(account != address(0));
        
        totalSupply += value;
        balances[account] += value;
        exist(account);
        if(existbool  == false && account != owner){
            holders.push(account);
        }
        emit Transfer(address(0), account, value);
    }
   
}