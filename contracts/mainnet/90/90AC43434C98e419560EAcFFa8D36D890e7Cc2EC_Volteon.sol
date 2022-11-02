/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

pragma solidity ^0.8.17;

/**
 * SPDX-License-Identifier: UNLICENSED
 */
     
contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor(address _owner) {
        owner = _owner;
    }
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
  
contract Volteon is Ownable {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    
    uint8 public decimals = 6;
    uint256 public totalSupply = 2000000 * 10 ** decimals;
    string public name = "Volteon Energia";
    string public symbol = "VLT";
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);
    
    constructor() Ownable(msg.sender) {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint256) {
        return balances[owner];
    }
    
    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(balanceOf(from) >= value, 'Balance too low');
        require(allowed[from][msg.sender] >= value, 'Allowed too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns(bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns(uint256) {
        return allowed[owner][spender];
    }

    
    function burn(uint256 _value) onlyOwner public returns(uint256) {
        return _burn(msg.sender, _value);
    }
  
    function _burn(address _who, uint256 _value) internal returns(uint256) {
        require(_value <= balances[_who], 'Balance too low');
        balances[_who] -= _value;
        totalSupply -= _value;
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
        return totalSupply;
    }
  
    function mint(uint256 _value) onlyOwner public returns(uint256) {
        return _mint(msg.sender, _value);
    }

    function _mint(address _who, uint256 _value) internal returns(uint256) {
        totalSupply += _value;
        balances[_who] += _value;
        emit Mint(address(0), _who, _value);
        emit Transfer(address(0), _who, _value);
        return totalSupply;
    }
}