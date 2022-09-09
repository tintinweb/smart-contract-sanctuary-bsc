/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ISnailhouseNFT {
    function tokenFreeze(uint256 tokenId) external;
    function tokenUnfreeze(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}
contract StakeNFTDAO {
    ISnailhouseNFT public wineryNFT;
    bool paused = false;
    bool enableUnstake = false;
    address owner;
    constructor(ISnailhouseNFT _wineryNFT) {
        wineryNFT = _wineryNFT;
        owner = msg.sender;
    }
    function pause() public onlyOwner {
        paused = true;
    }
    function unpause() public onlyOwner {
        paused = false;
    }
    function setEnableUnstake(bool _status) public onlyOwner {
        enableUnstake = _status;
    }
    function stake(uint256 nftId) public whenNotPaused {
        require(wineryNFT.ownerOf(nftId) == msg.sender, "Not owner");
        wineryNFT.tokenFreeze(nftId);
    }
    function unstake(uint256 nftId) public whenNotPaused {
        require(enableUnstake, "Not active");
        require(wineryNFT.ownerOf(nftId) == msg.sender, "Not owner");
        wineryNFT.tokenUnfreeze(nftId);
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused() {
        require(paused);
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner contract");
        _;
    }
}