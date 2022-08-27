/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract zb{
    function returnCode(
        bytes memory _creationCode,
        string memory _NAME,
        string memory _SYMBOL,
        uint256 _totalSupply,
        uint256 _buyFee,
        uint256 _sellFee
        ) public pure returns(bytes memory){
        return abi.encodePacked(
                        _creationCode,
                        abi.encode(_NAME, _SYMBOL, _totalSupply, _buyFee, _sellFee)
        );
    }
}