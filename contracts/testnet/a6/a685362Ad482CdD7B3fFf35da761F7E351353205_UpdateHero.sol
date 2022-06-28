// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IHeroNFT {
  function updateHeroInfo(uint _tokenId, uint8 _level, uint32 _experience, uint[3] calldata _skills) external;
}

contract UpdateHero {
  IHeroNFT public heroNFT;
  address public owner;

  event UpdatedHeroNFT(uint[] _tokenIds, uint8 _level, uint32 _experience, uint[3] _skills);

  constructor (address _heroNFTAddress) {
    heroNFT = IHeroNFT(_heroNFTAddress);
    owner = msg.sender;
  }

  function updateHero (uint[] calldata _tokenIds, uint8 _level, uint[3] calldata _skills, uint32 _experience) external {
    require(msg.sender == owner, "UpdateHero: Invalid caller.");

    for (uint i = 0; i < _tokenIds.length; i += 1) {
      heroNFT.updateHeroInfo(_tokenIds[i], _level, _experience, _skills);
    }

    emit UpdatedHeroNFT(_tokenIds, _level, _experience, _skills);
  }
}