// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTToken {
    address public _owner;

    string public _name;
    uint256 public _tokenId;
    string public _symbol;

    mapping(uint256 => address) public _owners;
    mapping(address => uint256) public _balances;
    mapping(uint256 => address) public _tokenApprovals;
    mapping(uint256 => string) public _tokenURIs;
    mapping(address => mapping(address => bool)) public _allApprovals;

    event Transfer(address indexed from, address indexed to, uint tokenId);
    event Approval(address indexed from, address indexed to, uint tokenId);
    event ApprovalForAll(address indexed owner, address indexed to, bool approved);
    event TransferOwnership(address indexed owner);

    constructor(string memory name, string memory symbol) {
        _owner = msg.sender;
        _name = name;
        _symbol = symbol;
        _tokenId = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "onlyOwner: you are not is owner");
        _;
    }

    function mint(address recipient, string memory tokenURI) public onlyOwner returns (uint256){
        require(recipient != address(0), "mint: recipient must be not zero address");

        _tokenId += 1;
        _balances[recipient] += 1;
        _owners[_tokenId] = recipient;
        _tokenURIs[_tokenId] = tokenURI;

        emit Transfer(address(0), recipient, _tokenId);
        return _tokenId;
    }

    function approve(address to, uint256 tokenId) public returns (bool success)  {
        address owner = _owners[tokenId];
        require(to != owner, "approve: approval to current owner");
        require(msg.sender == owner, "approve: approve caller is not owner nor approved for all");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);

        return true;
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(to != address(0) && from != address(0), "transferFrom: transfer must be not zero address");
        require(owner != address(0), "transferFrom: operator query for nonexistent token");
        bool checkOwner = owner == from || _allApprovals[owner][from] || _tokenApprovals[tokenId] == from;
        require(checkOwner, "transferFrom: transfer from incorrect owner or approval");

        _tokenApprovals[tokenId] = address(0);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) public {
        require(to != address(0), "setApprovalForAll: approve all must be not zero address");
        require(msg.sender != to, "setApprovalForAll: approve all must be not caller");

        _allApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "transferOwnership: new owner must be not zero address");

        _owner = newOwner;
        emit TransferOwnership(newOwner);
    }
}