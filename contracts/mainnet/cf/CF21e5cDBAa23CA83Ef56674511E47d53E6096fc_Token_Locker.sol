/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

pragma solidity ^0.4.26;

contract _ERC20Basic {
  function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address to, uint256 value) public returns (bool);
}

contract Token_Locker  {
    address owner;

    address tokenAddress =  0x07b4995221e60Cc74Ad69723016640711493a117; 
    uint256 unlockUnix = now + 675 days; 

    _ERC20Basic token = _ERC20Basic(tokenAddress);

    constructor() public {
        owner = msg.sender;
    }

    function unlockTokens() public {
        require(owner == msg.sender, "You are not owner");
        require( now > unlockUnix, "Still locked");
        token.transfer(owner, token.balanceOf(address(this)));
    }

    //Control
    function getLockAmount() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getTokenAddress()  public view returns (address) {
        return tokenAddress;
    }

    function getUnlockTimeLeft() public view returns (uint) {
        return unlockUnix - now;
    }
}