/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
contract Pool{
    address public tokenaddr=address(0x2C4619f878D8e4002B651cE8a80fbe28d7c88E71);
    address public owner;

    constructor() public {
      owner = msg.sender;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
    function setOwner(address a) public {
      require(msg.sender==owner);
      owner = a;
    }
    function tokenTransfer(address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner);
        return token(tokenaddr).transfer(t,am);
    }
    function tokenTransferFrom(address f,address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner);
        return token(tokenaddr).transferFrom(f,t,am);
    }
    
}