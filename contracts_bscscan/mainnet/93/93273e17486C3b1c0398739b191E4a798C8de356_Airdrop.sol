/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

pragma solidity >=0.6.0;

 
interface IERC20 {
 
    function transfer(address recipient, uint256 amount) external returns (bool);
}


contract Airdrop {
    
    
   address public token;
   address public owner;
   address public operator;
   constructor(address _t,address _o)public {
       token = _t;
       operator = _o;
       owner = msg.sender;
   }
   
   function airdrop(address[] calldata _addresses,uint256 _amounts) external {
       require(msg.sender == operator,"not operator");
       for(uint256 i=0;i < _addresses.length;i++){
           require(_addresses[i] != address(0),"zero address");
           IERC20(token).transfer(_addresses[i],_amounts);
       }
   }

   function exit(uint256  _amount) external  {
       require(msg.sender == owner);
       IERC20(token).transfer(msg.sender, _amount);
   }

   function setOperator (address _operator) external {
       require(msg.sender == owner);
       operator = _operator;
   }

}