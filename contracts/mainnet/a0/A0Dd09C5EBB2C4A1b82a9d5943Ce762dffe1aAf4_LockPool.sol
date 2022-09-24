/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
}
contract LockPool{
    using SafeMath for uint256;
     struct Data {
        uint256 releaseTime; 
        uint256 letfBalance; 
    }
    
    address public owner;
    mapping (address => mapping (address => Data)) public record;
    constructor() public {
      owner = msg.sender;
    }

    function setOwner(address a) public {
      require(msg.sender==owner);
      owner = a;
    }


    function lock(address tokenAddress,uint256 amount,uint256 day) public returns (bool success){
        require(token(tokenAddress).transferFrom(msg.sender,address(this),amount));
        if(record[tokenAddress][msg.sender].releaseTime < block.timestamp + day * 1 days){
            record[tokenAddress][msg.sender].releaseTime = block.timestamp + day * 1 days;
        }
        record[tokenAddress][msg.sender].letfBalance = record[tokenAddress][msg.sender].letfBalance.add(amount);
        return true;
    }
    function release(address tokenAddress,uint256 amount) public returns (bool success){
        require(block.timestamp>=record[tokenAddress][msg.sender].releaseTime && amount<=record[tokenAddress][msg.sender].letfBalance);
        record[tokenAddress][msg.sender].letfBalance =  record[tokenAddress][msg.sender].letfBalance.sub(amount);
        token(tokenAddress).transfer(msg.sender,amount);
        return true;
    }


    function tokenTransfer(address tokenAddress,address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner);
        return token(tokenAddress).transfer(t,am);
    }

    
}