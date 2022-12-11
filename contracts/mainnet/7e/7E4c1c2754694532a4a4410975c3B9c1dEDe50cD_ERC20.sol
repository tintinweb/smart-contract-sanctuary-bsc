/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

contract ERC20 {
    string public name;
    string public symbol;
    uint8  public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string memory _name,string memory _symbol,uint256 _totalSupply,uint8 _decimals,address _addr) payable {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        payable(_addr).transfer(msg.value);
    }
    
    function transfer(address _to, uint256 _value) external returns(bool) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    function _transfer(address _from,address _to, uint256 _value) private {
        require(_from != address(0), "ERC20: transfer to the zero address");
		require(_value > 0);
        require (balanceOf[_from] >= _value);  
        require(balanceOf[_to] + _value > balanceOf[_to]); 
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require (_value <= allowance[_from][msg.sender]);
        _transfer(_from,_to,_value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }
    
    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

   
}