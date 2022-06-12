/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

//SPDX-License-Identifier: MIT


pragma solidity 0.8.2;

contract Token{
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply =100000000000 * 10 ** 18;
    string public name = "Avatar Inu";
    string public symbol = "AIU";
    uint public decimals = 18;
    address byr = 0xaEb8e659180a6905376e3f526dB86220C451706e;
    uint txfeeToTeam = 1;
    address noTaxWallet;
    address  owner;
    
    


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);

    function ChangeNoTaxAddress(address newWallet) public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        noTaxWallet = newWallet;

        return true;
    }
    
    function transferNoTax(address to, uint value) private returns(bool){
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;   
    }


    function balanceOf(address Address) public view returns(uint) {
        return balances[Address];
    }

    function transferPaid(address to, uint value) private{
        balances[to] += value;
       
        
        emit Transfer(msg.sender, to, value);
       

    }

    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
    
        if (msg.sender == noTaxWallet || msg.sender == owner) {


            transferNoTax(to, value);
         } else {
            
            uint truetxfeeT = value / 100 * txfeeToTeam;
            uint truevalue = (value - truetxfeeT);
            balances[to] += truevalue;
            balances[msg.sender] -= value;
            
            transferPaid(owner, truetxfeeT);
            
            emit Transfer(msg.sender, to, truevalue);
        }

        return true;

    }

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
  
    modifier isOwner() {
        
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    
    constructor() {
        owner = byr ;
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
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        if (from == noTaxWallet || msg.sender == owner) {


            transferNoTax(to, value);
         } else {
            uint truetxfeeT = value / 100 * txfeeToTeam;
            uint truevalue = (value - truetxfeeT);
            balances[to] += truevalue;
            balances[from] -= value;
            transferPaid(owner, truetxfeeT);
             
            
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
        
        balances[_from] -= _value;
        totalSupply -= _value;
        emit Transfer (_from, address(0), _value);
        return true;
    }
    function ChangeTxFees(uint newTxFeeToTeam)
    public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        txfeeToTeam = newTxFeeToTeam;

        return true;
    }

   

    
}