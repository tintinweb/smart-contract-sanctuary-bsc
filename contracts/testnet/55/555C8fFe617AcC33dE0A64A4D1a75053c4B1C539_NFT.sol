// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../ERC721URIStorage.sol";
import "../Counters.sol";

contract NFT is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address contractAddress;

    address public owner1;
    modifier onlyOwner(){

        require(msg.sender==owner1,"you are not owner");
        _;
    }

    constructor(address marketplaceAddress) ERC721('KryptoBirdz', 'KBIRDZ'){
        contractAddress = marketplaceAddress;
        owner1=msg.sender;
    }

     function mintToken(string memory tokenURI) public onlyOwner returns(uint){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);

        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
         return newItemId;
    }


}

// marketplaceAddress=0x54B6f34A9f8999c207F815cDBFEE769930645926