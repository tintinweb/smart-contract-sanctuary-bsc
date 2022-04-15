//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "./Counters.sol";
import "./ERC721URIStorage.sol";
import "./ERC721.sol";
contract NFTFactory is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}
    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}