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
    Simp s = Simp(0xd9145CCE52D386f254917e481eB44e9943F39138);
   
    function suml(uint256 a, uint256 b) public returns (uint256){
        return s.sum(a,b);
    }
}