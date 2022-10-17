/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.7;


abstract contract INFT {
    function getApproved(uint256 tokenId) external virtual returns (address);
    function isApprovedForAll(address account, address operator) external virtual returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external virtual;
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external virtual;
}

contract NFTReceiver {

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;
    bytes4 constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 constant ERC1155_BATCH_RECEIVED = 0xbc197c81;

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external pure returns(bytes4) {
        return ERC1155_BATCH_RECEIVED;
    }
    function onERC721Received(address, uint256, bytes calldata) external pure returns(bytes4) {
        return ERC721_RECEIVED;
    }
}

contract AccessControl {

    bool public paused = false;
    address public owner;
    address public newContractOwner;
    mapping(address => bool) public authorizedContracts;

    event Pause();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        owner = msg.sender;
    }

    modifier ifNotPaused {
        require(!paused);
        _;
    }

    modifier onlyContractOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAuthorizedContract {
        require(authorizedContracts[msg.sender]);
        _;
    }

    modifier onlyContractOwnerOrAuthorizedContract {
        require(authorizedContracts[msg.sender] || msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyContractOwner {
        require(_newOwner != address(0));
        newContractOwner = _newOwner;
    }

    function acceptOwnership() public ifNotPaused {
        require(msg.sender == newContractOwner);
        emit OwnershipTransferred(owner, newContractOwner);
        owner = newContractOwner;
        newContractOwner = address(0);
    }

    function setAuthorizedContract(address _buyContract, bool _approve) public onlyContractOwner {
        if (_approve) {
            authorizedContracts[_buyContract] = true;
        } else {
            delete authorizedContracts[_buyContract];
        }
    }

    function setPause(bool _paused) public onlyContractOwner {
        paused = _paused;
        if (paused) {
            emit Pause();
        }
    }

}

contract AssetLocking is AccessControl, NFTReceiver {

    uint256 lockingPeriod = 86400;

    mapping(address => mapping(address => mapping(uint256 => uint256))) private _lockedAssets;
    mapping(address => mapping(address => mapping(uint256 => uint256))) private _lockedUntil;
    mapping(address => bool) private _isErc721;

    constructor(uint256 _lockingPeriod) {
        lockingPeriod = _lockingPeriod;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return bytes4(keccak256("supportsInterface(bytes4)")) == interfaceId;
    }

    function setLockingPeriod(uint256 _lockingPeriod) onlyContractOwner external returns (bool) {
        lockingPeriod = _lockingPeriod;
        return true;
    }

    function lock(address contractAddress, uint256 tokenId) external returns (uint256) {
        INFT nftContract = INFT(contractAddress);
        try nftContract.getApproved(tokenId) {
            if (nftContract.getApproved(tokenId) == address(this)) {
                nftContract.transferFrom(msg.sender, address(this), tokenId);
                _isErc721[contractAddress] = true;
            } else { revert(); }
        } catch {
            if (nftContract.isApprovedForAll(msg.sender, address(this))) {
                nftContract.safeTransferFrom(msg.sender, address(this), tokenId, 1, "");
            } else {
                revert();
            }
        }

        _lockedAssets[msg.sender][contractAddress][tokenId]++;
        _lockedUntil[msg.sender][contractAddress][tokenId] = block.timestamp + lockingPeriod;

        // return new timestamp the asset is locked until
        return _lockedUntil[msg.sender][contractAddress][tokenId];
    }

    function relock(address contractAddress, uint256 tokenId) external returns (uint256) {
        require(_lockedAssets[msg.sender][contractAddress][tokenId] > 0);

        _lockedUntil[msg.sender][contractAddress][tokenId] = block.timestamp + lockingPeriod;

        // return new timestamp the asset is locked until
        return _lockedUntil[msg.sender][contractAddress][tokenId];
    }

    function unlock(address contractAddress, uint256 tokenId) external returns (uint256) {
        require(_lockedAssets[msg.sender][contractAddress][tokenId] > 0);
        require(_lockedUntil[msg.sender][contractAddress][tokenId] < block.timestamp);

        _lockedAssets[msg.sender][contractAddress][tokenId]--;

        if (_isErc721[contractAddress]) {
            INFT(contractAddress).transferFrom(address(this), msg.sender, tokenId);
        } else {
            INFT(contractAddress).safeTransferFrom(address(this), msg.sender, tokenId, 1, "");
        }

        // return remaining locked count
        return _lockedAssets[msg.sender][contractAddress][tokenId];
    }

    function checkCount(address owner, address contractAddress, uint256 tokenId) external view returns (uint256) {
        return _lockedAssets[owner][contractAddress][tokenId];
    }

    function checkUntil(address owner, address contractAddress, uint256 tokenId) external view returns (uint256) {
        return _lockedUntil[owner][contractAddress][tokenId];
    }

}