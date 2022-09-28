//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Burnable.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract HashBetShare is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using SafeMath for uint256;
    
    uint256 private _totalSupply;
    mapping(uint256 => uint256) private _referral;

    constructor() ERC721("HashBet Share", "HBS") {}
    
    function shareMint(address to, uint256 tokenId, string memory uri, uint256 parentId)
        public
        onlyOwner
    {
        _referral[tokenId] = parentId;
        _totalSupply = _totalSupply.add(1);
        
        super._safeMint(to, tokenId);
        super._setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        _totalSupply = _totalSupply.sub(1);

        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function parentTokenId(uint256 tokenId) public view returns(uint256) {
        return _referral[tokenId];
    }

    function parentOwner(uint256 tokenId) public view returns(address) {
        uint256 ownerId = _referral[tokenId];

        if (ownerId == 0) {
            return address(0);
        } else {
            return super.ownerOf(ownerId);
        }
    }
}