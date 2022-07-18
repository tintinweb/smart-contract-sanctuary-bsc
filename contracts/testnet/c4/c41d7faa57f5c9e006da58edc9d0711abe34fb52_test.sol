/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC721{
      function ownerOf(uint256 tokenId) external view returns (address);
      function balanceOf(address owner) external view returns (uint256);
      function approve(address to, uint256 tokenId) external;
      function isApprovedForAll(address owner, address operator) external view returns (bool);
      function getApproved(address tokenId) external view returns (address );
      function transferFrom(address from, address to, uint256 tokenId) external;
      function safeTransferFrom(address from, address to, uint256 tokenId) external;
      function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
      function setApprovalForAll(address operator, bool approved) external;
      
      
      event Transfer(address indexed to, uint256 tokenId);
      event approval(address indexed owner, bool approved,uint256 tokenId);
      event approvalforall(address indexed owner, address operator,bool approved);
      

}
contract test is ERC721{

    string public name;
    string public symbol;

    mapping(uint256 => address) public _owners;

    mapping(address => uint256) public _balances;

     mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) public _operatorApprovals;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    function balanceOf(address owner) public view override returns (uint256){
       require(owner != address(0),"not the address of owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        return owner;
    }

    
    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        approve(to, tokenId);

    }

    function getApproved(address tokenId) public view override returns (address ) {
        getApproved(tokenId);

        return tokenId;
    }
    function setApprovalForAll(address operator, bool approved) public override {
        setApprovalForAll(operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _transfer(address from, address to, uint256 tokenId) internal{
        require(ownerOf(tokenId) == from, "transfer from incorrect owner");
        require(to != address(0), "transfer to the zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        //emit Transfer(from, to, tokenId);
    }
    function transferFrom(address from, address to, uint256 tokenId) public override {

        require(msg.sender == from,"the caller is from");
        transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
       require(from != address(0),"address can not of sender");
        require(to != address(0),"address can not be of receiver");
        require(ownerOf(tokenId) == from,"owner of token id is sender");
        safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _safeTransfer(from, to, tokenId, data);
    }

 function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);

    }
 function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) );
 }

 function _safeMint(address to, uint256 tokenId) internal  {
        _safeMint(to, tokenId);
    }

function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "mint to the zero address");
        require(!_exists(tokenId), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        //emit Transfer( to, tokenId);
    }
 function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);

        delete _tokenApprovals[tokenId];

        _balances[owner] -= 1;
        delete _owners[tokenId];


    }




}