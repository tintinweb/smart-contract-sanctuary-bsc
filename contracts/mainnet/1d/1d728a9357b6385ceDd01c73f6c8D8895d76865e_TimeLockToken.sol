pragma solidity ^0.8.0;

interface ERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(
    address owner,
    address spender
  ) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TimeLockToken {
  uint256 lockUntil = 1647442800000; // Wednesday, March 16, 2022 15:00:00
  address public owner;

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  /**
   * Below emergency functions will be never used in normal situations.
   * These function is only prepared for emergency case such as smart contract hacking Vulnerability or smart contract abolishment
   * Withdrawn fund by these function cannot belong to any operators or owners.
   * Withdrawn fund should be distributed to individual accounts having original ownership of withdrawn fund.
   */
  function withdrawToken(uint256 _amount, address _token) public onlyOwner {
    require(block.timestamp > lockUntil, "TIME LOCKED");
    require(ERC20(_token).transfer(msg.sender, _amount));
  }
}