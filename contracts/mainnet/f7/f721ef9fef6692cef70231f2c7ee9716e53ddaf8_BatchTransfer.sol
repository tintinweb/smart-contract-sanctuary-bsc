/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ERC3525 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 units
    ) external returns (uint256 newTokenId);
}

contract BatchTransfer {

    function batchTransfer(
        address token, 
        address from, 
        address[] calldata tos,
        uint256 tokenId,
        uint256 value
    )
        external
    {
        for (uint256 i = 0; i < tos.length; i++) {
            ERC3525(token).transferFrom(from, tos[i], tokenId, value);
        }
    }

}