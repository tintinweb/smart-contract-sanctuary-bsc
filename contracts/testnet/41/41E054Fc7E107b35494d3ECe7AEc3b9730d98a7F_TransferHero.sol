// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IHeroNFT {
  function transferFrom(address from, address to, uint256 tokenId) external;
}

contract TransferHero {
  IHeroNFT public heroNFT;
  address public owner;

  constructor (address _heroNFTAddress) {
    heroNFT = IHeroNFT(_heroNFTAddress);
    owner = msg.sender;
  }

  function transferHeroes(uint[] calldata _tokenIds, address _from, address _to) external {
    require(msg.sender == owner, "UpdateHero: Invalid caller.");

    for (uint i = 0; i < _tokenIds.length; i += 1) {
      heroNFT.transferFrom(_from, _to, _tokenIds[i]);
    }
  }
}