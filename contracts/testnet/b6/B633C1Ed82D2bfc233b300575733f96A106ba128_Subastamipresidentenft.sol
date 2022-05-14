// SPDX-License-Identifier: MIT
pragma solidity ^0.5.4;

contract Subastamipresidentenft {

  address public owner;
  uint256 public min;

  
  mapping(uint => Nft) private nfts;

  struct Nft {
    address payable _address;
    string _addressSolana;
    uint256 _value;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
    min = 0;
  }

  function register(uint _nft, string memory _addressSolana) public payable {
    require(msg.value >= min);
    require(msg.value > nfts[_nft]._value);
    if(nfts[_nft]._value > 0) {     
      require(nfts[_nft]._value <= address(this).balance); 
      nfts[_nft]._address.transfer(nfts[_nft]._value);
    }
    nfts[_nft]._address = msg.sender;
    nfts[_nft]._addressSolana = _addressSolana;
    nfts[_nft]._value = msg.value;
  }

  function getAddress(uint _nft) public view returns (address) {
    return nfts[_nft]._address;
  }   

  function getAddressSolana(uint _nft) public view returns (string memory) {
    return nfts[_nft]._addressSolana;
  }   

  function getValue(uint _nft) public view returns (uint256) {
    return nfts[_nft]._value;
  } 
      
  function setMin(uint256 _min) public restricted {
    min = _min; 
  }

  function withdraw(address payable _to, uint256 _value) public restricted {
    uint256 balance = address(this).balance;
    require(_value <= balance); 
    _to.transfer(_value);
  }

}