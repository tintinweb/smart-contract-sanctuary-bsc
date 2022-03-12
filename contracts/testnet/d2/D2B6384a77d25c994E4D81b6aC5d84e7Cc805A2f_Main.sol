pragma solidity=0.7.5;

import './ImplementationInterface.sol';

contract Main{
  address public admin;
  ImplementationInterface public implementation;

  constructor() {
    admin = msg.sender;
  }

  function upgrade(address _implementation) external {
    require(msg.sender == admin, 'Access Denied');
    implementation = ImplementationInterface(_implementation);
  }

  function getString() external view returns(string memory) {
    return implementation.getString();
  }
}