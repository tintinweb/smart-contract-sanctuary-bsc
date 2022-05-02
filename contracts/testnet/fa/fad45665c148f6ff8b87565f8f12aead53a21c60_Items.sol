/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

pragma solidity ^0.8.7;

/*
    SPDX-License-Identifier: Mozilla Public License 2.0
*/

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract Items {
    string private _name;
    string private _symbol;

    bytes4 private _safeCheck;

    string[] private _allTokens;

    mapping (uint256 => uint256) private _tokens;

    mapping (uint256 => address) private _owners;
    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    address public _contractOwner;
    address public _server;
    
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    event ApprovalForAll(address owner, address operator, bool approved);

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _safeCheck = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
        _contractOwner = msg.sender;
        _mint(msg.sender, 0, "Hi!");
    }

    function setServer(address server) public {
        require(msg.sender == _contractOwner);
        _server = server;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0));
        return _owners[tokenId];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenExists(uint256 tokenId) public view returns (bool) {
        return _tokens[tokenId] != 0;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(tokenExists(tokenId));
        return _allTokens[_tokens[tokenId]];
    }
 
    function _baseURI() internal pure returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);    
        require(to != owner);    
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));   

        _tokenApprovals[tokenId] = to;    
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(tokenExists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(msg.sender == ownerOf(tokenId) || msg.sender == getApproved(tokenId) || isApprovedForAll(from, msg.sender));
        require(tokenExists(tokenId), "Token doesn't exist");

        _owners[tokenId] = to;
        _tokenApprovals[tokenId] = address(0);

        _balances[from] -= 1;
        _balances[to] += 1;

        emit Transfer(from, to, tokenId);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transferFrom(from, to, tokenId);

        uint32 size;
        assembly {
            size := extcodesize(to)
        }

        if(size > 0) {
            IERC721Receiver receiver = IERC721Receiver(to);
            require(receiver.onERC721Received(msg.sender, from, tokenId, data) == _safeCheck);
        }

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external {
        _safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        _safeTransferFrom(from, to, tokenId, "");
    }

    function _mint(address owner, uint256 tokenId, string memory uri) internal {
        require(msg.sender == _server || msg.sender == _contractOwner, "You need to be a server or a contract owner");
        require(owner != address(0), "Cannot mint to null address");
        require(!tokenExists(tokenId), "Token with that id exists");

        _owners[tokenId] = owner;
        _tokens[tokenId] = _allTokens.length;    
        _balances[owner] += 1;   
        _allTokens.push(uri);

        emit Transfer(address(0), owner, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        require(msg.sender == _server || msg.sender == _contractOwner);
        require(tokenExists(tokenId) && ownerOf(tokenId) != address(0xdead));

        _balances[ownerOf(tokenId)] -= 1;
        _balances[address(0xdead)] += 1;
        _owners[tokenId] = address(0xdead);
        _tokenApprovals[tokenId] = address(0xdead);
    }

    function mint(address owner, uint256 tokenId, string memory uri) public {
        _mint(owner, tokenId, uri);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}