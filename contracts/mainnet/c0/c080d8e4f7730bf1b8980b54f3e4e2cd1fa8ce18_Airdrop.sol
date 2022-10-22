/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

pragma solidity ^0.4.18;

contract BEP20 {
  function transfer(address _recipient, uint256 _value) public returns (bool success);
}

contract Airdrop {
  function drop(BEP20 token, address[] recipients, uint256[] values) public {
    for (uint256 i = 0; i < recipients.length; i++) {
      token.transfer(recipients[i], values[i]);
    }
  }
}