/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

//SPDX-License-Identifier: MIT


pragma solidity 0.8.2;

contract Token{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint public totalSupply = 1000000000000 * 10 ** 18;
    string public name = "MetaCeltic";
    string public symbol = "METACELTIC";
    uint public decimals = 18;
    uint public MAXTXFEE = 10;
    uint public maxownablepercentage = 10 ;
    uint private maxownableamount;
    uint public maxtxpercentage = 3;
    uint private maxtxamount;
    uint txfeeToHolders = 0;
    uint txfeeAutoburn = 0;
    address noTaxWallet;
    address  owner;
    bool private existbool = false;
    

    // events

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    //struct

    struct Holder{
        address holderAdddress;
    }
    
    Holder[] holders;

    //modifiers

    modifier isOwner() {
        
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier antiwhalecheck(address from ,address to, uint value){
        maxownableamount = totalSupply / 100 * maxownablepercentage;
        maxtxamount = totalSupply / 100 * maxtxpercentage;
        if(from == owner || to == owner) {  
            _;
        }else {
            require(balanceOf(to) + value <= maxownableamount, "you already own too many token");
            require(value <= maxtxamount, "you cannot make transactions this high");
        }
        _;
    }






    //change variables
    
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function setMaxOwnablePerentage(uint newPercentage) isOwner public returns(bool){
        maxownablepercentage = newPercentage;

        return true;
    }

    function ChangeNoTaxAddress(address newWallet) public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        noTaxWallet = newWallet;

        return true;
    }
    
    function setMaxTxPerentage(uint _newPercentage) isOwner public returns(bool){
        maxtxpercentage = _newPercentage;

        return true;
    }

    function ChangeTxFees( uint newTxFeeToHolders, uint , uint newTxFeeToBurn)
    public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        require(newTxFeeToHolders + newTxFeeToBurn <= MAXTXFEE);
        txfeeAutoburn = newTxFeeToBurn;
        txfeeToHolders = newTxFeeToHolders;
        
        

        return true;
    }

    //constructor

    constructor() {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
        _balances[owner] = totalSupply;
        
    }

    //transfers

    function transferNoTax(address to, uint value) private returns(bool){
        _balances[to] += value;
        _balances[msg.sender] -= value;
        exist(to);
        if(existbool  == false && to != owner){
            Holder memory holder = Holder(to);
            holders.push(holder);
            }
        emit Transfer(msg.sender, to, value);
        return true;   
    }

    

    

    function transferPaid(address to, uint value) private{
        _balances[to] += value;
       
        
        emit Transfer(msg.sender, to, value);
       

    }

    
    function transfer(address to, uint value) public antiwhalecheck(msg.sender, to, value)  returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        
        if (msg.sender == noTaxWallet || msg.sender == owner) {


            transferNoTax(to, value);
         } else {
            uint truetxfeeH = value / 100 * txfeeToHolders;
            
        
            uint truetxFeeAB = value / 100 * txfeeAutoburn;
            uint truevalue = (value - truetxfeeH  -  truetxFeeAB);
            _balances[to] += truevalue;
            _balances[msg.sender] -= value;
            burnint( truetxFeeAB);
            distributeRewardsint(truetxfeeH);
            exist(to);
            if(existbool  == false && to != owner){
                Holder memory holder = Holder( to);
                holders.push(holder);
            }
            
            emit Transfer(msg.sender, to, truevalue);
        }

        return true;

    }

  
    


    
    
    function transferFrom(address from, address to, uint value) antiwhalecheck(from, to, value) 
     public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(_allowances[from][msg.sender] >= value, '_allowances too low');
        maxownableamount = totalSupply / 100 * maxownablepercentage;
        maxtxamount = totalSupply / 100 * maxtxpercentage;
    
        if (from == noTaxWallet || from == owner) {


            transferNoTax(to, value);
         } else {
            uint truetxfeeH = value / 100 * txfeeToHolders;
            
            
            uint truetxFeeAB = value / 100 * txfeeAutoburn;
            uint truevalue = (value - truetxfeeH   - truetxFeeAB);
            _balances[to] += truevalue;
            _balances[from] -= value;
            burnint( truetxFeeAB);
            distributeRewardsint(truetxfeeH);
            exist(to);
            if(existbool  == false && to != owner){
                Holder memory holder = Holder(to);
                holders.push(holder);
            } 
            
            emit Transfer(from, to, truevalue);
        }

        return true;
    }



    function transferToHolder(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        _balances[to] += value;
        _balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }

    //burn

    function burn (uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        
        require(balanceOf(msg.sender) >= _value);
        _balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    function burnint (uint256 _value) private returns(bool success){
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    
 
    function burnFrom(address _from, uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        require(balanceOf(_from) >= _value);
        require(_value <= _allowances[_from][msg.sender]);
        
        _balances[_from] -= _value;
        totalSupply -= _value;
        emit Transfer (_from, address(0), _value);
        return true;
    }
    
    //rewards distribution

    function exist(address holder) private {
        existbool = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i].holderAdddress == holder) {
                existbool = true;}
        }    
    }


    function distributeRewards(uint256 _value) public returns(bool success){
        _value = _value * 10 **18;
        uint  availableSupplyH = 0;
        for(uint i = 0; i < holders.length; i++) {
            availableSupplyH = availableSupplyH + balanceOf(holders[i].holderAdddress);
        }
        uint valueH = _value;
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i].holderAdddress) *valueH / availableSupplyH);
            transferToHolder(holders[i].holderAdddress, percentageToHolder);
        }
        
        return true;
    }

    function distributeRewardsint(uint256 _value) private returns(bool success){
        
        uint  availableSupplyH = 0;
        for(uint i = 0; i < holders.length; i++) {
            availableSupplyH = availableSupplyH + balanceOf(holders[i].holderAdddress);
        }
        
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i].holderAdddress) * _value / availableSupplyH);
            transferPaid(holders[i].holderAdddress, percentageToHolder);
        }
        
        return true;
    }

   //other
    

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address Address) public view returns(uint) {
        return _balances[Address];
    }

    function approve(address spender, uint value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}