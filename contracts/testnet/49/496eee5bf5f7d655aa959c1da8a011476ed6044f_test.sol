/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



interface  IERC721{
      function ownerOf(uint256 tokenId) external view returns (address);
      function balanceOf(address owner) external view returns (uint256);
      function approve(address to, uint256 tokenId) external;
      function isApprovedForAll(address owner, address operator) external view returns (bool);
      function getApproved(uint256 tokenId) external view returns (address );
      function transferFrom(address from, address to, uint256 tokenId) external;
      function safeTransferFrom(address from, address to, uint256 tokenId) external;
      function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
      function setApprovalForAll(address operator, bool approved) external;
      
      
      event Transfer(address indexed from ,address  to, uint256 tokenId);
      event approval(address indexed owner, bool approved,uint256 tokenId);
      event approvalforall(address indexed owner, address operator,bool approved);
      

}
contract test is IERC721{
     using SafeMath for uint256;
    string public name;
    string public symbol;
    string public tokenURI;
    address admin;
    mapping(uint256 => address) public _owners;

    mapping(address => uint256) public _balances;

     mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) public _operatorApprovals;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
       admin = msg.sender;
    }
    function settokenURI(string memory _tokenURI) public view returns(string memory){
        _tokenURI = tokenURI;
        return tokenURI;

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
        
         require(to != owner, "approval to current owner");

       require( msg.sender == owner || isApprovedForAll(owner, msg.sender));

        approve(to, tokenId);

    }

    function getApproved(uint256 _tokenId) public view override returns (address ) {
       require(_exists(_tokenId), "approved query for nonexistent token");
        return _tokenApprovals[_tokenId];

        
    }
    function setApprovalForAll(address operator, bool approved) public override {
          require(operator != msg.sender, "approve to caller");

       _operatorApprovals[msg.sender][operator] = approved;
        emit approvalforall(msg.sender, operator, approved);

    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _transfer(address from, address to, uint256 tokenId) public{
        require(ownerOf(tokenId) == from, "transfer from incorrect owner");
        require(to != address(0), "transfer to the zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    function transferFrom(address from, address to, uint256 tokenId) public override {

        require(_isApprovedOrOwner(msg.sender, tokenId),"caller is not owner");

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

 function _exists(uint256 tokenId) public view returns (bool) {
        return _owners[tokenId] != address(0);

    }
 function _isApprovedOrOwner(address spender, uint256 tokenId) public view returns (bool) {
        address owner = ownerOf(tokenId);
        return isApprovedForAll(owner, spender);
 }

 modifier onlyAdmin{
         require (msg.sender == admin, "only admin can run this function");
         _;
         }
     

 function _safeMint(address to, uint256 tokenId) public view onlyAdmin {
       _safeMint(to, tokenId);
    }

 function _mint(address account, uint256 tokenId) public onlyAdmin payable {
        require(account != address(0), "mint to the zero address");
        require(!_exists(tokenId), "token already minted");
        require(msg.value>=100000000000000000,"abc");
      
        _balances[account] += 1;
        _owners[tokenId] =account;

        
    }
 function _burn(uint256 tokenId) internal{
        address owner = ownerOf(tokenId);

        delete _tokenApprovals[tokenId];

        _balances[owner] -= 1;
        delete _owners[tokenId];


    }




}