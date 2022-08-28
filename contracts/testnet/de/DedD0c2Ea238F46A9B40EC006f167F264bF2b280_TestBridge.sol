/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
//test
pragma solidity ^0.8.0;

interface IToken {
  function mint(address to, uint amount) external;
  function burn(uint256 amount) external;
}

contract TestBridge {
  address public owner;
  address public token;
  uint public nonce;
  bool public status;
  mapping(uint => bool) public processedNonces;

  enum Step { Burn, Mint }
  event Transfer(
    address from,
    uint256 amount,
    uint date,
    uint nonce,
    Step indexed step
  );

  modifier onlyOwner() {
    require(msg.sender == owner, 'Only owner');
    _;
  }

  modifier notPaused() {
    require(status == true, 'Sorry, bridge is not working now');
    _;
  }

  constructor(address _token) {
    owner = msg.sender;
    token = _token;
    status = true;
  }

  function burn(uint256 amount) external notPaused {
    IToken tokenContract = IToken(token);
    tokenContract.burn(amount);
    emit Transfer(
      msg.sender,
      amount,
      block.timestamp,
      nonce,
      Step.Burn
    );
    nonce++;
  }

  function mint(address to, uint amount, uint otherChainNonce) external onlyOwner notPaused {
    require(processedNonces[otherChainNonce] == false, 'This transfer already processed');
    processedNonces[otherChainNonce] = true;
    IToken tokenContract = IToken(token);
    tokenContract.mint(to, amount);
    emit Transfer(
      msg.sender,
      amount,
      block.timestamp,
      otherChainNonce,
      Step.Mint
    );
  }

  function pause(bool _status) external onlyOwner {
    status = _status;
  }
}