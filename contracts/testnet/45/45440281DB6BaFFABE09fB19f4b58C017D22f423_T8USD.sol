pragma solidity ^0.4.15;

import "contracts...BEP20Token.sol";
import "contracts...BNBPriceOracleInterface.sol";

contract T8USD is BEP20Token {
  BNBPriceOracleInterface priceOracle;
  string public constant symbol = "T8USD";
  string public constant name = "TriBit USD";
  uint8 public constant decimals = 2;

  function T8USD(address BNBPriceOracleAddress) {
    priceOracle = BNBPriceOracleInterface(BNBPriceOracleAddress);
  }

  function donate() payable {}

  function mint(address _to, uint _amount) payable{}

	function burn(address _from,uint _amount) payable{}

  function issue() payable {
    uint amountInCents = (msg.value * priceOracle.price()) / 1 ether;
    _totalSupply += amountInCents;
    balances[msg.sender] += amountInCents;
  }

  function getPrice() returns (uint) {
    return priceOracle.price();
  }

  function withdraw(uint amountInCents) returns (uint amountInWei){
    assert(amountInCents <= balanceOf(msg.sender));
    amountInWei = (amountInCents * 1 ether) / priceOracle.price();

    // If we don't have enough Ether in the contract to pay out the full amount
    // pay an amount proportinal to what we have left.
    // this way user's net worth will never drop at a rate quicker than
    // the collateral itself.

    // For Example:
    // A user deposits 1 Ether when the price of Ether is $300
    // the price then falls to $150.
    // If we have enough Ether in the contract we cover ther losses
    // and pay them back 2 ether (the same amount in USD).
    // if we don't have enough money to pay them back we pay out
    // proportonailly to what we have left. In this case they'd
    // get back their original deposit of 1 Ether.
    if(this.balance <= amountInWei) {
      amountInWei = (amountInWei * this.balance * priceOracle.price()) / (1 ether * _totalSupply);
    }

    balances[msg.sender] -= amountInCents;
    _totalSupply -= amountInCents;
    msg.sender.transfer(amountInWei);
  }
}