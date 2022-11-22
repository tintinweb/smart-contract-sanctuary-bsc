/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
interface poap {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}
contract multiCall{
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Only Owner");
        _;
    }
    function safeBatchTransferFrom(address _nftaddress,address _recipient, uint256[] memory _tokenids) external {
        for (uint256 i = 0; i < _tokenids.length; i++)
            poap(_nftaddress).safeTransferFrom(msg.sender, _recipient, _tokenids[i]);
    }
}