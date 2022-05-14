/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

pragma solidity 0.5.16;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
} 
contract Pool{
    address public tokenaddr=address(0x2C4619f878D8e4002B651cE8a80fbe28d7c88E71);
    address public owner;
    uint256 public getRewardTime;
    uint256 public starttime;
    uint256 public rewardBalance;

    constructor() public {
      owner = msg.sender;
      getRewardTime = block.timestamp;
      starttime = block.timestamp;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
    function setOwner(address a) public {
      require(msg.sender==owner);
      owner = a;
    }
    function release() public{
        uint x = (block.timestamp-starttime)/30 days;
        uint perday = 700+100*x;
        if(perday>1600){
            perday=1600;
        }
        uint256 perSecondRewardAll= perday*10**18/24/60/60;
        rewardBalance+=perSecondRewardAll*(block.timestamp-getRewardTime);
        getRewardTime=block.timestamp;
    }


    function tokenTransfer(address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner && am<=rewardBalance);
        rewardBalance-=am;
        return token(tokenaddr).transfer(t,am);
    }

    
}