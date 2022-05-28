/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

pragma solidity 0.4.21;
interface Simp{
    function sum(uint256 a, uint256 b) returns (uint256);
}
contract Simple {
    
    function self() public{
        selfdestruct(msg.sender);
    }
    function sum(uint256 a, uint256 b) public pure returns (uint256){
        return a+b;
    }
}
contract Simple2 {
   
    function suml(address add, uint256 a, uint256 b) public returns (uint256){
         Simp s = Simp(add);
        return s.sum(a,b);
    }
}