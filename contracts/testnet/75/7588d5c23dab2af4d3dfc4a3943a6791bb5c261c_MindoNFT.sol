// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol"; 


interface IMindoNFT721 {
    function mint(address account, uint256 id) external;
    function burn(uint256 id) external;
}

contract MindoNFT721 is ERC721, IMindoNFT721  {

    address contractCreator;
    address controller;
    
    string uri;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
         contractCreator = msg.sender;
    }

    function setController(address _controller) public {
        require(contractCreator == msg.sender, "Only creator");
        controller = _controller;
    }
    
    function getController() public view returns (address) {
        return controller;
    }
    
    function getContractCreator() public view returns (address) {
        return contractCreator;
    }
    
    function mint(address account, uint256 id) external override {
        require(controller == msg.sender || contractCreator == msg.sender, "Mint permission");
        _mint(account, id);
    }
    
    function burn(uint256 tokenId) external override {
        require(controller == msg.sender || contractCreator == msg.sender, "Burn permission");
        _burn(tokenId);
    }
    
    function _baseURI() internal view override returns (string memory) {
        return uri;
    }
    
    function setURI(string memory _uri) public {
        require(controller == msg.sender || contractCreator == msg.sender, "URI permission");
        uri = _uri;
    }
}


contract UpgradableStorage {
    
    mapping(address => bool) adminList;

    address mindoNFT721;
    
}


contract MindoNFT is UpgradableStorage {
    
    event NFT721Mint(
        address indexed owner,
        address indexed contractAddress,
        uint256 tokenID,
        uint256 backendTxID
    );
    
    
    function setAdmin(address _address, bool _value) public {
        adminList[_address] = _value;
    }
    
    function isAdmin(address _address) public view returns (bool) {
        return adminList[_address];
    }
    
    function setMindoNFT721(address _mindoNFT721) public {
        require(adminList[msg.sender], "Need admin role");
        mindoNFT721 = _mindoNFT721;
    }
    
    function getMindoNFT721() public view returns (address) {
        return mindoNFT721;
    }
    
    function mint(address owner, uint256 tokenID, uint256 backendTxID) public {
        require(mindoNFT721 != address(0), " NFT721 imp null");
        require(adminList[msg.sender], "Need admin role");
        IMindoNFT721(mindoNFT721).mint(owner, tokenID);
        emit NFT721Mint(owner, mindoNFT721, tokenID, backendTxID);
    }
}


contract MindoNFTProxy {

    bytes32 private constant implementationPosition = keccak256("implementation.contract:2021");
    bytes32 private constant proxyOwnerPosition = keccak256("owner.contract:2021");
    
    event Upgraded(address indexed implementation);
    event ProxyOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        setUpgradeabilityOwner(msg.sender);
    }
    
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {
        bytes32 position = proxyOwnerPosition;
        assembly {
            owner := sload(position)
        }
    }

    function implementation() public view returns (address impl) {
        bytes32 position = implementationPosition;
        assembly {
            impl := sload(position)
        }
    }

    function setImplementation(address newImplementation) internal {
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, newImplementation)
        }
    }

    function _upgradeTo(address newImplementation) internal {
        address currentImplementation = implementation();
        require(currentImplementation != newImplementation);
        setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
    
    function setUpgradeabilityOwner(address newProxyOwner) internal {
        bytes32 position = proxyOwnerPosition;
        assembly {
            sstore(position, newProxyOwner)
        }
    }

    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0));
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    function upgradeTo(address _implementation) public onlyProxyOwner {
        _upgradeTo(_implementation);
    }
    
    function setAdminList(address /*_address*/, bool /*value*/) public onlyProxyOwner {
        address _impl = implementation();
        require(_impl != address(0), "Impl address is 0");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    } 
    
    fallback() external {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}