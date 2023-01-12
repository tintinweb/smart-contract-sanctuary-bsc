// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICounter {
  function count() external view returns(uint);
  function increament () external;
}
contract MyContract {
  address public counter;
  constructor (address _counter)  {
    counter = _counter;
  }
  function getcount( ) view public returns (uint) {
    return ICounter(counter).count();
  }
  function increamentCounter( ) public {
    ICounter(counter).increament();
  }
}