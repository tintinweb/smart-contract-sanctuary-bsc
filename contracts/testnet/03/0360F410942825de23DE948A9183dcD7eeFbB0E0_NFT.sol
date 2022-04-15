//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./Counters.sol";
contract NFT is ERC721URIStorage {
    //auto-increment field for each token
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;
    // Token name
    string private _name;
    // Token symbol
    string private _symbol;
    constructor(string memory Name, string memory Symbol,address marketplaceAddress) ERC721("", ""){
        _name =  Name;
        _symbol= Symbol;
       contractAddress = marketplaceAddress;
    }
    // create a new token
    // tokenURI : token URI
    function createToken(string memory tokenURI) public returns(uint) {
        //set a new token id for the token to be minted
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId); //mint the token
        _setTokenURI(newItemId, tokenURI); //generate the URI
        setApprovalForAll(contractAddress, true); //grant transaction permission to marketplace
        //return token ID
        return newItemId;

    }
}