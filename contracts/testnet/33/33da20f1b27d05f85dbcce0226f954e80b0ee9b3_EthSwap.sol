// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;

import "./Token.sol";

contract EthSwap{
  string public name = "EthSwap Instant Exchange"; //state variable
  Token public token;
  uint public rate = 100;

  event TokenPurchased(
    address account,
    address token,
    uint amount,
    uint rate
  );

  event TokenSold(
    address account,
    address token,
    uint amount,
    uint rate
  );

  constructor(Token _token) public { //_token is state variable here
    token = _token;
  }

  function buyTokens() public payable{
    uint tokenAmount = msg.value * rate;//ammount of eth * redemption rate (numbers of tokens received for 1 eth)

    //require ethswap has enought tokens
    require(token.balanceOf(address(this)) >= tokenAmount);

    //transfer tokens to user
    token.transfer(msg.sender,tokenAmount);

    //emit on event
    emit TokenPurchased(msg.sender, address(token), tokenAmount, rate);
  }

  function sellTokens(uint _amount) public{
     //user cant sell more tokens than they have
     require(token.balanceOf(msg.sender) >= _amount);

     //calculate amount of ether to be sent
     uint etherAmount = _amount / rate;

     //require ethSwap to have enough tokens
     require(address(this).balance >= etherAmount);

     //perform sale
     token.transferFrom(msg.sender, address(this), _amount);
     msg.sender.transfer(etherAmount);

     //emit on event
     emit TokenSold(msg.sender, address(token), _amount, rate);

  }
}