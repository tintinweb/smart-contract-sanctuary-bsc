/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

pragma solidity ^0.8.13;

interface IERC20 {
  function transferFrom(address from, address to, uint256 amount) external;
  function transfer(address to, uint256 amount) external;
}

contract RainBotDeposit {
  address public owner;

  event Deposit(uint256 user, uint256 amount);
  event Withdraw(uint256 user, address receiver, uint256 amount);

  IERC20 public CAKE;

  constructor(address newOwner){
    CAKE = IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    owner = newOwner;
  }

  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _new) external onlyOwner {
    owner = _new;
  }

  function deposit(uint256 user, uint256 amount) external {
    CAKE.transferFrom(msg.sender, address(this), amount);
    emit Deposit(user, amount);
  }

  function withdraw(uint256 user, address receiver, uint256 amount) external onlyOwner {
    CAKE.transfer(receiver, amount);
    emit Withdraw(user, receiver, amount);
  }

  function recover(address token, address to, uint256 amount) external onlyOwner {
    IERC20(token).transfer(to, amount);
  }
}