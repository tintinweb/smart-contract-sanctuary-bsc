// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Strings.sol";
import "./ERC1155.sol";
import "./Ownable.sol";
import "./ERC1155Enumerable.sol";

contract UTOPIA_BLOCKs1155 is Ownable, ERC1155Enumerable {
    using Address for address;
    using Strings for uint256;

    mapping(address => bool) public minters;

    function setMinter(address newMinter_, bool bool_) public onlyOwner {
        minters[newMinter_] = bool_;
    }

    string private _name;
    string private _symbol;
    uint private _totalSupply;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    struct ItemInfo {
        uint tokenId;
        uint currentAmount;
        uint burnedAmount;
    }

    mapping(uint => ItemInfo) public itemInfoes;
    string public myBaseURI;

    constructor(string memory name_, string memory symbol_, string memory myBaseURI_, string memory URI_) ERC1155(URI_) {
        _name = name_;
        _symbol = symbol_;
        myBaseURI = myBaseURI_;
    }

    function setMyBaseURI(string memory uri_) public onlyOwner {
        myBaseURI = uri_;
    }

    function mint(address to_, uint tokenId_, uint amount_) public onlyOwner returns (bool) {
        require(minters[_msgSender()], "S: not minter's calling");
        require(amount_ > 0, "S: missing amount");
        require(tokenId_ != 0, "S: wrong tokenId");
        itemInfoes[tokenId_].tokenId = tokenId_;
        itemInfoes[tokenId_].currentAmount += amount_;
        _totalSupply += amount_;
        _mint(to_, tokenId_, amount_, "");
        return true;
    }

    function tokenURI(uint256 tokenId_) public view returns (string memory) {
        require(itemInfoes[tokenId_].tokenId != 0, "S: URI query for nonexistent token");

        string memory URI = tokenId_.toString();
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, URI , ".json"))
        : URI;
    }

    function _baseURI() internal view returns (string memory) {
        return myBaseURI;
    }

  
}