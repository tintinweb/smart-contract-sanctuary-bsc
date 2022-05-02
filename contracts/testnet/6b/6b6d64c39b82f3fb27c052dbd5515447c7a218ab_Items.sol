/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

pragma solidity ^0.8.7;

/*
    SPDX-License-Identifier: Mozilla Public License 2.0
*/

interface ERC721TokenReceiver {
    function onERC721Received(address operator_, address from_, uint256 tokenId_, bytes calldata data_) external returns(bytes4);
}

interface ERC165 {
    function supportsInterface(bytes4 interfaceID_) external view returns (bool);
}

interface ERC721 is ERC165 {
    event Transfer(address indexed from_, address indexed to_, uint256 indexed tokenId_);
    event Approval(address indexed owner_, address indexed approved_, uint256 indexed tokenId_);
    event ApprovalForAll(address indexed owner_, address indexed operator_, bool approved_);

    function balanceOf(address owner_) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address from_, address to_, uint256 tokenId_, bytes memory data_) external;
    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;
    function transferFrom(address from_, address to_, uint256 tokenId_) external;
    function approve(address approved_, uint256 tokenId_) external;
    function setApprovalForAll(address operator_, bool approved_) external;
    function getApproved(uint256 tokenId_) external view returns (address);
    function isApprovedForAll(address owner_, address operator_) external view returns (bool);
}

interface ERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId_) external view returns (string memory);
}

interface ERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

contract Items is ERC721, ERC721Metadata, ERC721Enumerable {
    string private _name;
    string private _symbol;

    address public contractOwner;
    address public serverOperator;

    uint256[] private _tokenIdentifiers;
    mapping (uint256 => string) private _tokens;
    mapping (uint256 => uint256) private _indentifierToIndex;

    mapping (address => uint256) private _balance;
    mapping (uint256 => address) private _owner;

    mapping (address => uint256[]) private _ownerTokens;
    mapping (uint256 => uint256) private _ownerIndex;

    mapping (uint256 => address) private _approval;
    mapping (address => mapping (address => bool)) private _operator;

    mapping (bytes4 => bool) private _interface;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        contractOwner = msg.sender;
        //ERC-721
        _interface[0x80ac58cd] = true;
        //ERC-165
        _interface[0x150b7a02] = true;
        //ERC-721 Metadata
        _interface[0x5b5e139f] = true;
        //ERC-721 Enumerable
        _interface[0x780e9d63] = true;
    }

    function balanceOf(address owner_) external view override returns (uint256) {
        //require(owner_ != address(0) && owner_ != address(0xdead), "ERC-721: Query for dead address");
        return _balance[owner_];
    }

    function _exists(uint256 tokenId_) internal view returns (bool) {
        return bytes(_tokens[tokenId_]).length != 0;
    }

    function ownerOf(uint256 tokenId_) external view override returns (address) {
        require(_exists(tokenId_), "ERC-721: Token identifier not valid");

        return _owner[tokenId_];
    }

    function approve(address approved_, uint256 tokenId_) external override {
        address owner = _owner[tokenId_];
        require(msg.sender == owner || _operator[owner][msg.sender], "ERC-721: Not an owner/operator");

        _approval[tokenId_] = approved_;

        emit Approval(owner, approved_, tokenId_);
    }

    function setApprovalForAll(address operator_, bool approved_) external override {
        _operator[msg.sender][operator_] = approved_;

        emit ApprovalForAll(msg.sender, operator_, approved_);
    }
    
    function getApproved(uint256 tokenId_) external view override returns (address) {
        require(_exists(tokenId_), "ERC-721: Token identifier is not valid");

        return _approval[tokenId_];
    }

    function isApprovedForAll(address owner_, address operator_) external view override returns (bool) {
        return _operator[owner_][operator_];
    }

    function _transferFrom(address from_, address to_, uint256 tokenId_) internal {
        address owner = _owner[tokenId_];
        require(msg.sender == owner || msg.sender == _approval[tokenId_] || _operator[owner][msg.sender], "ERC-721: Not an owner/operator/approved" );
        require(from_ == owner, "ERC-721: From is not an owner of the token");
        require(to_ != address(0) && to_ != address(0xdead), "ERC-721: To cannot be a dead address");
        require(_exists(tokenId_), "ERC-721: Token identifier is not valid");

        uint256 index = _ownerIndex[tokenId_];
        _removeOwnerTokenAtIndex(owner, index);

        _balance[to_] += 1;
        _owner[tokenId_] = to_;
        _ownerIndex[_indentifierToIndex[tokenId_]] = _balance[to_] - 1;
        _ownerTokens[to_].push(_indentifierToIndex[tokenId_]);

        _approval[tokenId_] = address(0);

        emit Transfer(from_, to_, tokenId_);
    }

    function _safeTransferFrom(address from_, address to_, uint256 tokenId_, bytes memory data_) internal {
        _transferFrom(from_, to_, tokenId_);

        uint32 size;
        assembly {
            size := extcodesize(to_)
        }

        if(size > 0)
        {
            ERC721TokenReceiver receiver = ERC721TokenReceiver(to_);
            require(receiver.onERC721Received(from_, to_, tokenId_, data_) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")), "ERC-721: Recipient contract doesn't implement ERC721TokenReceiver");
        }
    }

    function safeTransferFrom(address from_, address to_, uint256 tokenId_, bytes memory data_) external override {
        _safeTransferFrom(from_, to_, tokenId_, data_);
    }

    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external override {
        _safeTransferFrom(from_, to_, tokenId_, "");
    }

    function transferFrom(address from_, address to_, uint256 tokenId_) external override {
        _transferFrom(from_, to_, tokenId_);
    }

    //ERC-165
    //---------------
    function supportsInterface(bytes4 interfaceID_) external view override returns (bool) {
        return _interface[interfaceID_];
    }
    //---------------

    //METADATA
    //---------------
    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId_) external view override returns (string memory) {
        require(_exists(tokenId_), "ERC-721 Metadata: Token identifier is not valid");
        return _tokens[tokenId_];
    }
    //---------------

    //ENUMERABLE
    //---------------
    function totalSupply() external view override returns (uint256) {
        return _tokenIdentifiers.length;
    }

    function tokenByIndex(uint256 index_) external view override returns (uint256) {
        require(index_ < _tokenIdentifiers.length, "ERC-721 Enumerable: Index out of bounds");
        return _tokenIdentifiers[index_];
    }

    function tokenOfOwnerByIndex(address owner_, uint256 index_) external view override returns (uint256) {
        require(index_ < _balance[owner_], "ERC-721 Enumerable: Index out of bounds");

        return _tokenIdentifiers[_ownerTokens[owner_][index_]];
    }

    function _removeOwnerTokenAtIndex(address owner_, uint256 index_) internal {
        uint256 value = _ownerTokens[owner_][_balance[owner_] - 1];

        _ownerTokens[owner_][index_] = value;
        _ownerTokens[owner_].pop();
        _ownerIndex[_tokenIdentifiers[value]] = index_;

        _balance[owner_] -= 1;
    }
    //---------------

    //MINT AND BURN
    //---------------
    function mint(address owner_, uint256 tokenId_, string memory uri_) external {
        require(!_exists(tokenId_), "Token with that id already exists");
        require(msg.sender == contractOwner || msg.sender == serverOperator, "You are not a contract owner / server");

        _owner[tokenId_] = owner_;
        _ownerIndex[tokenId_] = _ownerTokens[owner_].length;
        _ownerTokens[owner_].push(_tokenIdentifiers.length);
        _indentifierToIndex[tokenId_] = _tokenIdentifiers.length; 
        _tokenIdentifiers.push(tokenId_);
        _tokens[tokenId_] = uri_;
        
        _balance[owner_] += 1;

        emit Transfer(address(0), owner_, tokenId_);
    }

    function burn(uint256 tokenId_) external {
        require(_exists(tokenId_), "Token identifier is not valid");
        require(msg.sender == contractOwner || msg.sender == serverOperator, "You are not a contract owner / server");

        address owner = _owner[tokenId_];

        _removeOwnerTokenAtIndex(owner, _ownerIndex[tokenId_]);

        _balance[address(0xdead)] += 1;
        _owner[tokenId_] = address(0xdead);
        _ownerIndex[_indentifierToIndex[tokenId_]] = _balance[address(0xdead)] - 1;
        _ownerTokens[address(0xdead)].push(_indentifierToIndex[tokenId_]);

        _approval[tokenId_] = address(0);

        emit Transfer(owner, address(0xdead), tokenId_);
    }
    //---------------

    //OTHER
    //---------------
    function setServer(address server_) external {
        require(msg.sender == contractOwner, "You are not a contract owner");
        serverOperator = server_;
    }
    //---------------
}