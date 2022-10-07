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
    address constant private farmAutoContract = 0xcB96576131a303E0E8f18AB4B13eA89F7992212C;
    
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