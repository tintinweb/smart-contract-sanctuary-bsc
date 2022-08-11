/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract MakeNumbers{

    // Mask: Full product type (with NF header)
    uint256 public constant MASK_TYPE = uint256(type(uint128).max) << 128;
    // Mask: Non-fungible token index
    uint256 public constant MASK_NF_INDEX = type(uint128).max;
    // Mask: NF flag
    uint256 public constant MASK_TYPE_NF = 1 << 255;
    // Mask: Product ID only (no NF header)
    uint256 public constant MASK_PRODUCTID = MASK_TYPE - MASK_TYPE_NF;

    // These make the code clearer
    function isNonFungible(uint256 _id) public pure returns(bool) {
        return _id & MASK_TYPE_NF == MASK_TYPE_NF;
    }
    function isFungible(uint256 _id) public pure returns(bool) {
        return _id & MASK_TYPE_NF == 0;
    }
    function getNonFungibleIndex(uint256 _id) public pure returns(uint128) {
        return uint128(_id & MASK_NF_INDEX);
    }
    function getProductBaseType(uint256 _id) public pure returns(uint128) {
        return uint128((_id & MASK_PRODUCTID) >> 128);
    }
    function isNonFungibleBaseType(uint256 _id) public pure returns(bool) {
        // A base type has the NF bit but does not have an index.
        return (_id & MASK_TYPE_NF == MASK_TYPE_NF) && (_id & MASK_NF_INDEX == 0);
    }
    function isNonFungibleItem(uint256 _id) public pure returns(bool) {
        // A base type has the NF bit but does have an index.
        return (_id & MASK_TYPE_NF == MASK_TYPE_NF) && (_id & MASK_NF_INDEX != 0);
    }

    function make_number(
        uint128 _baseType,
        bool _fungible,
        uint128 _tokenNum
    ) external pure returns (uint256){
        uint256 val = (_baseType << 128) + _tokenNum;
        if (!_fungible){
            val += MASK_TYPE_NF;
        }
        return val;
    }

    function check_number(
        uint256 _tokenId
     ) external pure returns (uint128, bool, uint128){
        return (getProductBaseType(_tokenId), isFungible(_tokenId), getNonFungibleIndex(_tokenId));
    }
}