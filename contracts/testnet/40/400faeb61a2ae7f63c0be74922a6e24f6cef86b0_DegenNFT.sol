// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";

import "./ERC721URIStorage.sol";
import "./Counters.sol";
import "./Whitelist.sol";
import "./IEliteNFT.sol";

contract DegenNFT is IEliteNFT, ERC721URIStorage, Whitelist {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter public override totalMinted;
    
    string public uri;

    uint256 internal _mintPriceOfItem;

    uint256 internal _maxMintable;
	
    constructor(
        string memory _name, 
        string memory _symbol, 
        uint256 _max, 
        uint256 _cost, 
        address _token, 
        string memory _uri, 
        address _recipient
    ) ERC721(_name, _symbol, _max, _cost, _token, _recipient) {
        uri = _uri;
        _mintPriceOfItem = _cost;
        _maxMintable = _max;
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Find all item IDs belonging to an address
    function tokensOf(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalItems = totalMinted.current();
            uint256 resultIndex = 0;

            uint256 itemId;

            for (itemId = 1; itemId <= totalItems; itemId++) {
                if (ownerOf(itemId) == _owner) {
                    result[resultIndex] = itemId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    function mintPrice() external view returns (uint256) {
        return _mintPriceOfItem;
    }

    function mintableRemaining() external override view returns (uint256) {
        return (_maxMintable - totalMinted.current());
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Mint an item - only the WoolMinter can directly mint via this function.
    // Users should visit the WoolFactory to mint NFTs.
    function mint(address player) external onlyWhitelisted() returns (uint256) {
        _tokenIds.increment();
        totalMinted.increment();

        uint256 newItemId = _tokenIds.current();

        _mint(player, newItemId);
        _setTokenURI(newItemId, uri);

        return newItemId;
    }
}