/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

pragma solidity ^0.4.16;
 
contract Ownable {
  address public owner;
 
  function Ownable() {
    owner = msg.sender;
  }
 
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}
 
interface Token {
  function transfer(address _to, uint256 _value) returns (bool);
  function balanceOf(address _owner) constant returns (uint256 balance);
}
 
contract TazAirDrop is Ownable {
 
  Token token;
 
  event TransferredToken(address indexed to, uint256 value);
  event FailedTransfer(address indexed to, uint256 value);
 
  modifier whenDropIsActive() {
    assert(isActive());
 
    _;
  }
 
  function AirDrop () {
      address _tokenAddr =0x1fed8951D852b88930557B681409b334e1089343; //smartcontract address
      token = Token(_tokenAddr);
  }
 
  function isActive() constant returns (bool) {
    return (
        tokensAvailable() > 0 // Tokens must be available to send
    );
  }
 
//
//
//
//
//below function can be used when you want to send every recipient with different number of tokens
function sendTokens(address[] dests, uint256[] values) whenDropIsActive onlyOwner external {
    uint256 i = 0;
    while (i < dests.length) {
        uint256 toSend = values[i]; 	//    "* 10**18" was here on this line, changed it to 10^0 because VRE has 0 decimals??? Idk.
        sendInternally(dests[i] , toSend, values[i]);
        i++;
    }
  }
//
//
//
//
 
 
// this function can be used when you want to send same number of tokens to all the recipients
  function sendTokensSingleValue(address[] dests, uint256 value) whenDropIsActive onlyOwner external {
    uint256 i = 0;
    uint256 toSend = value;
    while (i < dests.length) {
        sendInternally(dests[i] , toSend, value);
        i++;
    }
  }  
 
  function sendInternally(address recipient, uint256 tokensToSend, uint256 valueToPresent) internal {
    if(recipient == address(0)) return;
 
    if(tokensAvailable() >= tokensToSend) {
      token.transfer(recipient, tokensToSend);
      TransferredToken(recipient, valueToPresent);
    } else {
      FailedTransfer(recipient, valueToPresent); 
    }
  }   
 
 
  function tokensAvailable() constant returns (uint256) {
    return token.balanceOf(this);
  }
 
  function destroy() onlyOwner {
    uint256 balance = tokensAvailable();
    require (balance > 0);
    token.transfer(owner, balance);
    selfdestruct(owner);
  }
}