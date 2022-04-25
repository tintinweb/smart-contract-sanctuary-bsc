/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
contract FNTPool{
    address public tokenaddr=address(0);
    address public owner;
    address public admin;
    

    constructor() public {
      owner = msg.sender;
      admin = msg.sender;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
   
    function setAdmin(address a) public {
      require(msg.sender==owner);
      admin = a;
    }

    function tokenTransfer(address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner || msg.sender==admin);
        return token(tokenaddr).transfer(t,am);
    }
    function tokenTransferFrom(address f,address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner || msg.sender==admin || msg.sender==f);
        return token(tokenaddr).transferFrom(f,t,am);
    }
    
}