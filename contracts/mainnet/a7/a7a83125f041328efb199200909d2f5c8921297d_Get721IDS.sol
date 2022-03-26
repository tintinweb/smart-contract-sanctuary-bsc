/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface utils {
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}

contract Get721IDS {
    
    function get721IDS(address _token, address _target) view public returns (uint[] memory tokenIDS) {
        utils token = utils(_token);
        uint balance = token.balanceOf(_target);
        tokenIDS = new uint[](balance);
        
        for (uint i = 0; i < balance; i++){
            tokenIDS[i] = token.tokenOfOwnerByIndex(_target,i);
        }
    }
}