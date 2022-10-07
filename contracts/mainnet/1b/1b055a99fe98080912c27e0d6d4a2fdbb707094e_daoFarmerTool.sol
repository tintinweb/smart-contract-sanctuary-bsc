/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface FarmAuto{
    function farmAuto(uint256 propId, uint256 tokenId) external;
    function repairFull(uint256 propId, uint256 tokenId) external;
}

contract daoFarmerTool{
    address constant private farmAutoContract = 0xE2DF32B35fAF127d3c66e75A34bEA1DD56e21cBC;
    
    FarmAuto private farmAutoTool;

    constructor(){
        farmAutoTool = FarmAuto(farmAutoContract);
    }

    function farmAutoTools(uint256[] memory _propIdList, uint256[] memory _tokenIdList) public {
        for(uint i = 0;i < _tokenIdList.length; i++){
            farmAutoTool.farmAuto(_propIdList[i], _tokenIdList[i]);
        }
    }

    function repairFullTools(uint256[] memory _propIdList, uint256[] memory _tokenIdList) public {
        for(uint i = 0;i < _tokenIdList.length; i++){
            farmAutoTool.repairFull(_propIdList[i], _tokenIdList[i]);
        }
    }
}