/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract SITToken{ 
    string public constant name="Self Innovate Token";
    string public constant symbol="SIT";
    uint8 public constant decimals=18;
    uint256 public constant dbase=10**decimals;
    uint256 public totalSupply = 1_000_000_000 * dbase;    //1 billion
 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    address m_Owener;
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
 
    constructor ()  {
        m_Owener = msg.sender;
        balanceOf[m_Owener] = totalSupply;
    }

    modifier IsOwener(){
        require(msg.sender == m_Owener);
        _;
    }
 
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
 
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
 
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) IsOwener public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function mint(uint256 _value) IsOwener public returns (bool success) {
        balanceOf[msg.sender] += _value;
        totalSupply += _value;
        return true;
    }
}