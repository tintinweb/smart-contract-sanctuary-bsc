/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
contract Pool{
    address public tokenaddr=address(0x2a895aFAEB582b5C914dAA3DEECc08C9705C9fBC);
    address public owner=address(0x3E0142Db06C68fEB89d39e67591C44d32ec84f32);

    constructor() public {
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