/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
contract exchange{
    address public tokenaddr=address(0x9339d523F58A0c41d0f326B0011DA0189AB9641f);
    address public uaddr=address(0x55d398326f99059fF775485246999027B3197955);
    address public fundAddress=address(0x11BeAF84947083c304c3a2b183431BBD6C76541A);
    uint256 public rate;
    address public owner;

    constructor() public {
      owner = msg.sender;
      rate=1000;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
    function setOwner(address a) public {
      require(msg.sender==owner);
      owner = a;
    }
    function setFundAddress(address a) public {
      require(msg.sender==owner);
      fundAddress = a;
    }
    function setRate(uint256 a) public{
      require(msg.sender==owner );
        rate = a;
    }
    function out(address c,address u,uint256 am) public{
        require(msg.sender==owner);
        token(c).transfer(u,am);
    }

    function ex(uint256 am) public  returns (bool success){
        if(token(uaddr).transferFrom(msg.sender,fundAddress,am)){
              token(tokenaddr).transfer(msg.sender,am*1000/rate/(10**10));
              return true;
        }
        return false;
    }
}