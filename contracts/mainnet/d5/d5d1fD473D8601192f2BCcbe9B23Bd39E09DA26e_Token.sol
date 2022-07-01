/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

//SPDX-License-Identifier: MIT


pragma solidity 0.8.2;

contract Token{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint public totalSupply = 10000000000 * 10 ** 18;
    string public name = "SmoulderTKN";
    string public symbol = "SVTK";
    uint public decimals = 18;
    uint public MAXTXFEE = 10;
    uint public maxownablepercentage = 20 ;
    uint private maxownableamount;
    uint public maxtxpercentage = 3;
    uint private maxtxamount;
    uint txfeetoowner = 0;
    address noTaxWallet;
    address  owner;
    bool private existbool = false;
    uint private truevalue;
    bool public antiwhalenabled = false;
    

    // events

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event Burn(address indexed burner, uint256 amount);
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

    function antiwhalecheck(address to, uint amount)private returns(bool success){
        if(antiwhalenabled) {
            maxownableamount = totalSupply  * maxownablepercentage / 100;
            maxtxamount = totalSupply  * maxtxpercentage / 100;
            require(balanceOf(to) + amount <= maxownableamount, "you already own too many token");
            require(amount <= maxtxamount, "you cannot make transactions this high");
        }
        return true;
        
    }






    //change variables
    
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
 
    function activateAntiwhale( bool enable) public isOwner{
        antiwhalenabled = enable;
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

    function ChangeTxFees( uint newtxfee)
    public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        require(newtxfee <= MAXTXFEE);
        
        txfeetoowner = newtxfee;
        
        

        return true;
    }

    //constructor 

    constructor() { 
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
        _balances[owner] = totalSupply;
        
    }

    //transfers

    function transferNoTax(address to, uint amount) private returns(bool){
        _balances[to] += amount;
        _balances[msg.sender] -= amount;
        exist(to);
        if(existbool  == false && to != owner){
            Holder memory holder = Holder(to);
            holders.push(holder);
            }
        emit Transfer(msg.sender, to, amount);
        return true;   
    }

    

    

    function transferPaid(address to, uint amount) private{
        _balances[to] += amount;
       
        
        emit Transfer(msg.sender, to, amount);
       

    }

    
    

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal  {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        antiwhalecheck(to, amount);
        if (from == noTaxWallet || from == owner) {
 

            unchecked {
            _balances[from] = fromBalance - amount;
        }
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }else {
            uint  truetxfeeH  = amount / 100 * txfeetoowner;
            truevalue = (amount - truetxfeeH );
            _balances[to] += truevalue;
            _balances[from] -= amount;
            transferPaid(owner, truetxfeeH);
            emit Transfer(from, to, truevalue);

        }
        exist(to);
        if(existbool  == false && to != owner){
            Holder memory holder = Holder( to);
            holders.push(holder);
        }
        

        

        
    }

    function transfer(address to, uint256 amount) public  returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public  returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function _spendAllowance(
        address ownr,
        address spender,
        uint256 amount
    ) internal  {
        uint256 currentAllowance = allowance(ownr, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(ownr, spender, currentAllowance - amount);
            }
        }
    }

    function allowance(address ownr, address spender) public view  returns (uint256) {
        return _allowances[ownr][spender];
    }

    function _approve(
        address ownr,
        address spender,
        uint256 amount
    ) internal virtual {
        require(ownr != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ownr][spender] = amount;
        emit Approval(ownr, spender, amount);
    }
  
    


    
    
    



    function transferToHolder(address to, uint amount) private{
        require(balanceOf(msg.sender) >= amount, 'balance too low');
        _balances[to] += amount;
        _balances[msg.sender] -= amount;
        
        emit Transfer(msg.sender, to, amount);
       

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

    function approve(address spender, uint amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;   
    }
}