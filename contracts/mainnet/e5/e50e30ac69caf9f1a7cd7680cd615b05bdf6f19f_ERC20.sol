pragma solidity ^0.5.10;

import "./ERC20Interface.sol";  // 
import "./Ownable.sol";  //

contract ERC20 is ERC20Interface,Ownable{
    
    mapping (address => uint256) public balanceOf;  // 
    mapping (address => mapping (address => uint256)) internal allowed;  //  
    
    // 
    constructor() public{
        totalSupply = 150000000000;  
        name = "Metars Ore";  
        symbol = "OREM";  // 
        decimals = 2;  // 
        balanceOf[msg.sender] = totalSupply;  //
        emit Transfer(address(0), msg.sender, totalSupply); 
    }
    
    // 
    function balance(address _owner) public view returns(uint256){
        return balanceOf[_owner];
    }
    
    function transfer(address _to, uint _value) public returns(bool success){
        require(_to != address(0));
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // 
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns(bool success){
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);  // 
        require(balanceOf[_to] + _value >= balanceOf[_to]);  // 
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    // 
    function approve(address _spender, uint256 _value) public returns(bool success){
        allowed[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns(uint256){
        return allowed[_owner][_spender];
    }

}