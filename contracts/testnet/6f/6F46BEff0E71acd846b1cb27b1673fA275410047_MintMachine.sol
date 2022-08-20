// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "./IFactory.sol";
import "./NFT721.sol";
import "./NFT1155.sol";
import "./Context.sol";

contract MintMachine is Context {
    IFactory _factory721;
    IFactory _factory1155;

    mapping(address => mapping(address => bool)) _minters;
    mapping(address => address) _owners;

    constructor(address factory721, address factory1155) {
        _factory721 = IFactory(factory721);
        _factory1155 = IFactory(factory1155);
    }

    // ------ EVENTS ----- //
    event Mint(address indexed collection, uint256 indexed tokenId, uint256 quantity, address indexed minter);
    event Burn(address indexed collection, uint256 indexed tokenId, uint256 quantity, address indexed burner);
    event Deploy(address indexed collection, address indexed deployer);

    // ----- MODIFIERS ----- //
    modifier onlyMinter(address collection) {
        require(_minters[collection][_msgSender()], "Minter: caller is not minter");
        _;
    }

    modifier onlyOwner(address collection) {
        require(_owners[collection] == _msgSender(), "Owner: caller is not owner");
        _;
    }

    // ----- MUTATION FUNCTIONS ----- //
    function createCollection(string memory name, string memory symbol, string memory uri, bool flag) external {
        address addr;
        if(flag) {
            addr = _factory721.createCollection(name, symbol, uri);
        } else {
            addr = _factory1155.createCollection(name, symbol, uri);
        }

        _minters[addr][_msgSender()] = true;
        _owners[addr] = _msgSender();

        emit Deploy(addr, _msgSender());
    }

    function mint(address collection) external onlyMinter(collection) {
        uint256 index = NFT721(collection).mint();

        emit Mint(collection, index, 1, _msgSender());
    }

    function mint(address collection, uint256 amount) external onlyMinter(collection) {
        uint256 index = NFT1155(collection).mint(amount);

        emit Mint(collection, index, amount, _msgSender());
    }

    function mint(address collection, uint256 tokenId, uint256 amount) external onlyMinter(collection) {
        NFT1155(collection).mint(tokenId, amount);

        emit Mint(collection, tokenId, amount, _msgSender());
    }

    function burn(address collection, uint256 tokenId) external {
        NFT721(collection).burn(tokenId);

        emit Burn(collection, tokenId, 1, _msgSender());
    }

    function burn(address collection, uint256 tokenId, uint256 amount) external {
        NFT1155(collection).burn(tokenId, amount);

        emit Burn(collection, tokenId, amount, _msgSender());
    }

    // ----- RESTRICTED FUNCTIONS ----- //
    function setMinter(address collection, address minter, bool approval) external onlyOwner(collection) {
        _minters[collection][minter] = approval;
    }

    function transferOwnership(address collection, address owner) external onlyOwner(collection) {
        _owners[collection] = owner;
    }

    // ----- VIEWS ----- //
    function isMinter(address collection, address account) external view returns (bool) {
        return _minters[collection][account];
    }

    function ownerOf(address collection) external view returns (address) {
        return _owners[collection];
    }
}