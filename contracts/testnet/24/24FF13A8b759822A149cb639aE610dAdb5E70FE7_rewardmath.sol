/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract rewardmath {

    mapping(uint256 => mapping(uint256 => uint256)) public tokenRarity;
    mapping(uint8 => mapping(uint16 => uint8)) public token8Rarity;

    function setBatchRarity(uint24 _vaultId, uint256[] memory _tokenIds, uint256 _rarity) public {
        for (uint256 i; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            tokenRarity[_vaultId][tokenId] = _rarity;
        }
    }

    function setBatch8Rarity(uint8 _vaultId, uint16[] memory _tokenIds, uint8 _rarity) public {
        uint16 i;
        for (i; i < _tokenIds.length; ++i) {
            unchecked {
            uint16 tokenId = _tokenIds[i];
            token8Rarity[_vaultId][tokenId] = _rarity;
            }
        }
    }

}