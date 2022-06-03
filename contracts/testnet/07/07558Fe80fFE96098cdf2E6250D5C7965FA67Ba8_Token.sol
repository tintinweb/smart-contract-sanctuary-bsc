/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

//SPDX-License-Identifier: MIT


pragma solidity 0.8.2;

contract Token{
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply =20000000 * 10 ** 18;
    string public name = " Aperture Games Token";
    string public symbol = "TST";
    uint public decimals = 18;
    address byr = 0x5f7A951f4eAf51be91b030EF762D84266e992DdA;
    uint public maxownablepercentage = 10 ;
    uint private maxownableamount;
    uint public maxtxpercentage = 3;
    uint private maxtxamount;
    uint txfeeToHolders = 4;
    uint txfeeTomarketing = 2;
    uint txfeeToBurn = 2;
    uint txfeeToTeam = 2;
    address noTaxWallet;
    address  owner;
    address marketingWallet = 0x023B8F9ee90080d018246E6b885A31d2c8212360;
    bool private existbool = false;
    uint ivalue;


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);

    struct Holder{
        bool isNftHolder;
        address holderAdddress;
    }
    
    Holder[] holders;
    
    function setMaxOwnablePerentage(uint newPercentage) isOwner public returns(bool){
        maxownablepercentage = newPercentage;

        return true;
    }

    function ChangeNoTaxAddress(address newWallet) public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        noTaxWallet = newWallet;

        return true;
    }
    
    function transferNoTax(address to, uint value) private returns(bool){
        balances[to] += value;
        balances[msg.sender] -= value;
        exist(to);
        if(existbool  == false && to != owner){
            Holder memory holder = Holder(false, to);
            holders.push(holder);
            }
        emit Transfer(msg.sender, to, value);
        return true;   
    }

    function setMaxTxPerentage(uint _newPercentage) isOwner public returns(bool){
        maxtxpercentage = _newPercentage;

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
        maxownableamount = totalSupply / 100 * maxownablepercentage;
        maxtxamount = totalSupply / 100 * maxtxpercentage;
        if(msg.sender == owner || to == owner ) {   // if else statement
            require(true == true);
        } else {
            require(balanceOf(to) + value <= maxownableamount);
            require(value <= maxtxamount);
        }
        if (msg.sender == noTaxWallet || msg.sender == owner) {


            transferNoTax(to, value);
         } else {
            uint truetxfeeH = value / 100 * txfeeToHolders;
            uint truetxfeeB = value / 100 * txfeeToBurn;
            uint truetxfeeM = value / 100 * txfeeTomarketing;
            uint truetxfeeT = value / 100 * txfeeToTeam;
            uint truevalue = (value - truetxfeeH - truetxfeeB - truetxfeeM - truetxfeeT);
            balances[to] += truevalue;
            balances[msg.sender] -= value;
            burnprv(truetxfeeB);
            transferPaid(owner, truetxfeeT);
            transferPaid(owner, truetxfeeM);
            distributeRewardsint(truetxfeeH);
            exist(to);
            if(existbool  == false && to != owner){
                Holder memory holder = Holder(false, to);
                holders.push(holder);
            }
            
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
        maxownableamount = totalSupply / 100 * maxownablepercentage;
        maxtxamount = totalSupply / 100 * maxtxpercentage;
        if(from == owner || to == owner ) {   // if else statement
            require(true == true);
        } else {
            require(balanceOf(to) + value <= maxownableamount);
            require(value <= maxtxamount);
        }
        if (from == noTaxWallet || msg.sender == owner) {


            transferNoTax(to, value);
         } else {
            uint truetxfeeH = value / 100 * txfeeToHolders;
            uint truetxfeeB = value / 100 * txfeeToBurn;
            uint truetxfeeM = value / 100 * txfeeTomarketing;
            uint truetxfeeT = value / 100 * txfeeToTeam;
            uint truevalue = (value - truetxfeeH - truetxfeeB - truetxfeeM - truetxfeeT);
            balances[to] += truevalue;
            balances[from] -= value;
            burnprv(truetxfeeB);
            transferPaid(owner, truetxfeeT);
            transferPaid(owner, truetxfeeM);
            distributeRewardsint(truetxfeeH);
            exist(to);
            if(existbool  == false && to != owner){
                Holder memory holder = Holder(false, to);
                holders.push(holder);
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
    function ChangeTxFees(uint newTxFeeBurned, uint newTxFeeToHolders, uint newTxFeeToMarket, uint newTxFeeToTeam)
    public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        txfeeToTeam = newTxFeeToTeam;
        txfeeToHolders = newTxFeeToHolders;
        txfeeTomarketing = newTxFeeToMarket;
        txfeeToBurn = newTxFeeBurned;

        return true;
    }

    function exist(address holder) private {
        existbool = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i].holderAdddress == holder) {
                ivalue = i;
                existbool = true;}
        }    
    }


    function distributeRewards(uint256 _value) public returns(bool success){
        _value = _value * 10 **18;
        uint  availableSupplyH = 0;
        for(uint i = 0; i < holders.length; i++) {
            availableSupplyH = availableSupplyH + balanceOf(holders[i].holderAdddress);
        }
        uint valueH = _value / 3 * 2;
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i].holderAdddress) *valueH / availableSupplyH);
            transferToHolder(holders[i].holderAdddress, percentageToHolder);
        }
        uint availableSupplyN = 0;
        for(uint i = 0; i < holders.length; i++) {
            if (holders[i].isNftHolder == true) {
                availableSupplyH = availableSupplyH + balanceOf(holders[i].holderAdddress);
                }
            
        }
        uint valueN = _value / 3;
        for(uint i = 0; i < holders.length; i++) {
            if (holders[i].isNftHolder == true) {
                percentageToHolder = (balanceOf(holders[i].holderAdddress) *valueN / availableSupplyN);
                transferToHolder(holders[i].holderAdddress, percentageToHolder);
                }
            
        }
        return true;
    }

    function distributeRewardsint(uint256 _value) private returns(bool success){
        
        uint  availableSupplyH = 0;
        for(uint i = 0; i < holders.length; i++) {
            availableSupplyH = availableSupplyH + balanceOf(holders[i].holderAdddress);
        }
        uint valueH = _value / 3 * 2;
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i].holderAdddress) *valueH / availableSupplyH);
            transferPaid(holders[i].holderAdddress, percentageToHolder);
        }
        uint availableSupplyN = 0;
        for(uint i = 0; i < holders.length; i++) {
            if (holders[i].isNftHolder == true) {
                availableSupplyH = availableSupplyH + balanceOf(holders[i].holderAdddress);
                }
            
        }
        uint valueN = _value / 3;
        for(uint i = 0; i < holders.length; i++) {
            if (holders[i].isNftHolder == true) {
                percentageToHolder = (balanceOf(holders[i].holderAdddress) *valueN / availableSupplyN);
                transferPaid(holders[i].holderAdddress, percentageToHolder);
                }
            
        }
        return true;
    }

    function addNFTholder(address walletAddress) public isOwner returns(bool success){
        exist(walletAddress);
        if(existbool  == true){
                holders[ivalue].isNftHolder = true;
            }else{
                Holder memory holder = Holder(true, walletAddress);
                holders.push(holder);
            }
        return true;
                   
        }
    
    function burnprv (uint256 _value) private returns(bool success){
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    function transferToHolder(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }
}