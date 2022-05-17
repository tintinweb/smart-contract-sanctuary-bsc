// SPDX-License-Identifier: MIT

pragma solidity 0.8.8;

import "./ERC721.sol";
import "./Owner.sol";
import "./ReentrancyGuard.sol";
import "./Counters.sol";
import "./Strings.sol";

contract NFT is ERC721, Owner, ReentrancyGuard {
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIds;

    string private baseURI;

    struct TokenMetaData {
        uint256 tokenType;
    }

    mapping(uint256 => TokenMetaData) private _tokenMetaData;

    mapping(address => bool) private allowedList; // allowed list to award or mint tokens

    constructor(string memory _tokenName, string memory _tokenSymbol) ERC721(_tokenName, _tokenSymbol) {
        allowedList[msg.sender] = true;
    }

    function addToAllowedList(address[] memory _allowedList) public isOwner {
        for (uint256 i = 0; i < _allowedList.length; i++) {
            allowedList[_allowedList[i]] = true;
        }
    }

    function getTokenMetaData(uint256 _tokenId) public view returns(uint256){ // return tokenType
        return _tokenMetaData[_tokenId].tokenType;
    }

    function setBaseURI(string memory _newBaseURI) public virtual isOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(_baseURI(), _tokenMetaData[_tokenId].tokenType.toString(), ".json")) : "";
    }

    function awardToken(address _newOwner, uint256 _tokenType) public nonReentrant returns (uint256) {
        require(allowedList[msg.sender] == true, 'msg.sender not authorized to call awardToken');
        require(_tokenType >= 1 && _tokenType <= 5, "_tokenType is not valid");
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(_newOwner, newTokenId);
        _tokenMetaData[newTokenId] = TokenMetaData(_tokenType);

        return newTokenId;
    }
}