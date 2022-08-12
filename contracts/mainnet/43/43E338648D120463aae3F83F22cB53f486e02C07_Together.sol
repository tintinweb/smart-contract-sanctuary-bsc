/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "0 owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IETHNFT {
    function claimAllReward(address account) external;

    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenBaseInfo(uint256 tokenId) external view returns (uint256 initId, uint256 lastId, uint256 activeTime);

    function activeSupply() external view returns (uint256);

    function initIdInfo(uint256 initId) external view returns (uint256 lastId, bool isActive, address nftOwner);

    function getActiveTime(uint256 tokenId) external view returns (uint256 activeTime);
}

interface IBTCNFT {
    function claimAllReward(address account) external;

    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract Together is Ownable {
    address public _ethNFTAddress;
    address public _btcNFTAddress;

    function setEthNFTAddress(address adr) external onlyOwner {
        _ethNFTAddress = adr;
    }

    function setBtcNFTAddress(address adr) external onlyOwner {
        _btcNFTAddress = adr;
    }

    function claimNFTReward() external {
        address account = msg.sender;
        IETHNFT(_ethNFTAddress).claimAllReward(account);
        IBTCNFT(_btcNFTAddress).claimAllReward(account);
    }

    function getBTCNFTList(address account, uint256 start, uint256 length) public view returns (
        uint256 returnLen, uint256[] memory tokenIds
    ){
        IBTCNFT nft = IBTCNFT(_btcNFTAddress);
        uint256 nftLength = nft.balanceOf(account);
        if (0 == length) {
            length = nftLength;
        }
        returnLen = length;
        tokenIds = new uint256[](length);
        uint256 index = 0;
        uint256 tokenId;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= nftLength)
                return (index, tokenIds);
            tokenId = nft.tokenOfOwnerByIndex(account, i);
            tokenIds[index] = tokenId;
            ++index;
        }
    }

    function getETHNFTList(address account, uint256 start, uint256 length) public view returns (
        uint256 returnLen, uint256[] memory tokenIds, uint256[] memory lastIds, uint256[] memory activeTimes
    ){
        IETHNFT nft = IETHNFT(_ethNFTAddress);
        uint256 nftLength = nft.balanceOf(account);
        if (0 == length) {
            length = nftLength;
        }
        returnLen = length;
        tokenIds = new uint256[](length);
        lastIds = new uint256[](length);
        activeTimes = new uint256[](length);
        uint256 index = 0;
        uint256 tokenId;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= nftLength)
                return (index, tokenIds, lastIds, activeTimes);
            tokenId = nft.tokenOfOwnerByIndex(account, i);
            tokenIds[index] = tokenId;
            (, lastIds[index], activeTimes[index]) = nft.tokenBaseInfo(tokenId);
            ++index;
        }
    }

    function getETHNFTList(uint256 start, uint256 length) public view returns (
        uint256 returnLen, uint256[] memory lastIds, uint256[] memory activeTimes, address[] memory nftOwners
    ){
        IETHNFT nft = IETHNFT(_ethNFTAddress);
        uint256 nftLength = nft.activeSupply();
        if (0 == length) {
            length = nftLength;
        }
        returnLen = length;
        lastIds = new uint256[](length);
        activeTimes = new uint256[](length);
        nftOwners = new address[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= nftLength)
                return (index, lastIds, activeTimes, nftOwners);
            (lastIds[index],, nftOwners[index]) = nft.initIdInfo(i + 1);
            activeTimes[index] = nft.getActiveTime(lastIds[index]);
            ++index;
        }
    }

    constructor(){
        _ethNFTAddress = address(0xB7dC2FD542Fb373255CB4c493b51808F1b2F18e7);
        _btcNFTAddress = address(0x6477F5D55E8cd3a9a2d85DccF6B3aB09AAc47547);
    }
}