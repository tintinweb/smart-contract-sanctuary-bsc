/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
} 
contract Pool{
    address public tokenaddr=address(0x55d398326f99059fF775485246999027B3197955);
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
}