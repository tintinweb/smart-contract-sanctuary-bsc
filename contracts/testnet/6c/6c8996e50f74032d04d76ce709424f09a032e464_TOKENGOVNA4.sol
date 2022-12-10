/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

pragma solidity 0.8.4;

 
   contract TOKENGOVNA4 {
   string public name = "TOKENGOVNA4";
   string public symbol = "TKNGVN4";
   uint256 public totalSupply = 100000000000000000000000000;
   // 1 миллион
   uint8 public decimals = 3;
   
   
   event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
   event Approval(
       address indexed _owner,
       address indexed _spender,
       uint256 _value
   );
   mapping(address => uint256) public balanceOf;
   mapping(address => mapping(address => uint256)) public allowance;
    
   
   constructor() {
       balanceOf[0xa1e0643185D3D800CD20Eb6753328D6139e8599b] = totalSupply;
   }
    
 
   function transfer(address _to, uint256 _value)
       public
       returns (bool success)
   {
       require(balanceOf[0xa1e0643185D3D800CD20Eb6753328D6139e8599b] >= _value);
       balanceOf[0xa1e0643185D3D800CD20Eb6753328D6139e8599b] -= _value;
       balanceOf[_to] += _value;
       emit Transfer(0xa1e0643185D3D800CD20Eb6753328D6139e8599b, _to, _value);
       return true;
   }
   
     
   function approve(address _spender, uint256 _value)
       public
       returns (bool success)
   {
       allowance[0xa1e0643185D3D800CD20Eb6753328D6139e8599b][_spender] = _value;
       emit Approval(0xa1e0643185D3D800CD20Eb6753328D6139e8599b, _spender, _value);
       return true;
   }
   }