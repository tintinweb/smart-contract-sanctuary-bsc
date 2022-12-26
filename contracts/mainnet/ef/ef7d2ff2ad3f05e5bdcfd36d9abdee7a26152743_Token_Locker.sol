/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

pragma solidity ^0.4.26;

contract _ERC20Basic {
  function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address to, uint256 value) public returns (bool);
}

contract Token_Locker  {
    address owner;

    address tokenAddress =  0x7ab2937d44d6C3077E7DF9e8b6E66AcD08D8Eb15; 
    uint256 unlockUnix = now + 370 days; 

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