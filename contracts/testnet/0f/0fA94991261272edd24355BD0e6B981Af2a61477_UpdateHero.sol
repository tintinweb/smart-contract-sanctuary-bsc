// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IHeroNFT {
  function updateHeroInfo(uint _tokenId, uint8 _level, uint32 _experience, uint8[3] memory _skills) external;
}

contract UpdateHero {
  IHeroNFT public heroNFT;
  address public owner;

  event UpdatedHeroNFT(uint[] _tokenIds, uint8 _level, uint32 _experience, uint8[3] _skills);

  constructor (address _heroNFTAddress) {
    heroNFT = IHeroNFT(_heroNFTAddress);
    owner = msg.sender;
  }

  function updateHero (uint[] calldata _tokenIds) external {
    require(msg.sender == owner, "UpdateHero: Invalid caller.");
    uint8 level = 1;
    uint32 experience = 0;
    uint8[3] memory skills = [1,0,0];

    for (uint i = 0; i < _tokenIds.length; i += 1) {
      heroNFT.updateHeroInfo(_tokenIds[i], level, experience, skills);
    }

    emit UpdatedHeroNFT(_tokenIds, level, experience, skills);
  }
}