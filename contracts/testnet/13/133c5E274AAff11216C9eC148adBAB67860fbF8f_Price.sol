/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Line {
    function getBuyInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier,
        uint256 royaltyFeeMultiplier
    )
        external
        pure
        returns (
            uint error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 inputValue,
            uint256 protocolFee,
            uint256 royaltyFee
        );
    function getSellInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier,
        uint256 royaltyFeeMultiplier
    )
        external
        pure
        returns (
            uint error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 protocolFee,
            uint256 royaltyFee
        );
}

contract Price{
    function getBuyPrice(
        address lineAddress,
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier,
        uint256 royaltyFeeMultiplier
    ) public pure 
    returns(
            uint error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 protocolFee,
            uint256 royaltyFee
    ){
        (error,newSpotPrice,newDelta,outputValue,protocolFee,royaltyFee) = Line(lineAddress).getBuyInfo(spotPrice,delta,numItems,feeMultiplier,protocolFeeMultiplier,royaltyFeeMultiplier);
    }

    function getSellPrice(
        address lineAddress,
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier,
        uint256 royaltyFeeMultiplier
    ) public pure 
    returns(
            uint error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 protocolFee,
            uint256 royaltyFee
    ){
        (error,newSpotPrice,newDelta,outputValue,protocolFee,royaltyFee) = Line(lineAddress).getSellInfo(spotPrice,delta,numItems,feeMultiplier,protocolFeeMultiplier,royaltyFeeMultiplier);
    }
}