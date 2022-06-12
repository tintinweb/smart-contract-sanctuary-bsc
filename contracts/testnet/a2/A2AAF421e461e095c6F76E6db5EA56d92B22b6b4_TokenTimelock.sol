/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-30
*/

pragma solidity ^0.4.26;
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeERC20 {
  function safeTransfer(ERC20 token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}
contract TokenTimelock {
  using SafeERC20 for ERC20;

  ERC20 public OCLock;
  address public owner;

  uint64 public releaseTime;

  bool public bLocked = false; 

  constructor () public {
    owner = msg.sender;
    OCLock = ERC20(0x3007651Fa19AaEA27db3991AF2CDD407E04C3c72); // ini main oc contract
  }
  
  function lockTokenA(uint64 _releaseTime) public {
    require(msg.sender == owner, "only owner");
    require(_releaseTime > now);
    require(bLocked == false, "already locked");
    uint256 totalBalance = OCLock.balanceOf(msg.sender);
    OCLock.safeTransferFrom(msg.sender, address(this), totalBalance);
    releaseTime = _releaseTime;
    bLocked = true;
  }

  function getTokenBalance(address addrSender) view external returns (uint256) {
    uint256 totalBalance = OCLock.balanceOf(addrSender);
    return totalBalance;
  }

  function lockTokenB(uint64 _releaseTime) public {
      require(msg.sender == owner, "only owner");
      require(_releaseTime > now);
      require(bLocked == false, "already locked");
      releaseTime = _releaseTime;
      bLocked = true;
  }

  function releaseToken() public {
    require(msg.sender == owner, "only owner");
    require(now >= releaseTime);
    uint256 totalBalance = OCLock.balanceOf(this);
    if(totalBalance>0)
        OCLock.safeTransfer(msg.sender, totalBalance);
    bLocked = false;
  }
}