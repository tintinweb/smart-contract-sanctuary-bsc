// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;


import './ERC721PresetMinterPauserAutoId.sol';
import './Ownable.sol';

contract NFT is ERC721PresetMinterPauserAutoId, Ownable {
    constructor () ERC721PresetMinterPauserAutoId("DreamVerse-RunningDog", "DOG", "https://www.dreamverse.pro/NFT/DOG-2000-json/") {}

    function mintTo(uint256 count, address to) public {
        for(uint256 i=0; i<count; i++){
            mint(to);
        }
    }
}