// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

contract nftOracle{
    enum rariryLevel{
        common,
        uncommon,
        rare,
        epic,
        legend
    }

    mapping (uint256 => rariryLevel) private rarityRate;

    constructor(
        uint256[] memory id,
        rariryLevel[] memory setRarity
    ){
        for(uint256 a; a < id.length; a++){
            rarityRate[id[a]] = setRarity[a];
        }
    }

    function getRarity(
        uint256 id
    ) public view returns(rariryLevel){
        return rarityRate[id];
    }
}