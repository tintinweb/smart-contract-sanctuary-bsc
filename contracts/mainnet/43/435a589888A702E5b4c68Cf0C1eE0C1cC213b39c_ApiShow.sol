/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

contract ApiShow {
    function detachGroup(uint256[] memory tokenIds_) external {}
    function detach1155(uint256[] memory ids_, uint256[] memory amounts_) external {}
    function detach721(uint256[] memory tokenIds_) external {}
    function recallGroup(uint256[] memory tokenIds_) external {}
    function recall1155(uint256[] memory ids_, uint256[] memory amounts_) external {}
    function recall721(uint256[] memory tokenIds_) external {}
    function recallAll(uint256[] memory ids_, uint256[] memory amounts_) external {}
    function beginMerge(uint256[] memory tokenIds_) external {}
    function endMerge() external {}
}