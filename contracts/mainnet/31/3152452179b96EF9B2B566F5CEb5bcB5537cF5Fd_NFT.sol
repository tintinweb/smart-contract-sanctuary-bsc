// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "./Counters.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Enumerable.sol";

import "./ERC721.sol";

import "./console.sol";

contract NFT is ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    using Strings for uint256;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;


    constructor(address marketplaceAddress) ERC721("Cloud world", "CW") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory _tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }

    // function createToken(address user, string memory _tokenURI) public returns (uint) {
    //     _tokenIds.increment();
    //     uint256 newItemId = _tokenIds.current();

    //     _mint(user, newItemId);
    //     _setTokenURI(newItemId, _tokenURI);
    //     setApprovalForAll(contractAddress, true);
    //     return newItemId;
    // }

    function createTokens(address user, string memory _tokenURI, uint256 count) public {
        for(uint i=0; i < count; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();

            _mint(user, newItemId);
            _setTokenURI(newItemId, _tokenURI);
            setApprovalForAll(contractAddress, true);
        }
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}