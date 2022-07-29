// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "Counters.sol";
import "ERC721URIStorage.sol";
import "ERC721.sol";


/**
 * @title Ownable
 * @dev This contract has an owner address providing basic authorization control
 */
contract Ownable {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event OwnershipTransferred(address previousOwner, address newOwner);
    
    address ownerAddress;
    
    constructor () {
        ownerAddress = msg.sender;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function owner() public view returns (address) {
        return ownerAddress;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner the address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    /**
    * @dev Sets a new owner address
    */
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        ownerAddress = newOwner;
    }
}


contract NFT is ERC721URIStorage,Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public mintprice  = 3500000000000000;


    constructor() ERC721("ULE NFT", "ULE") {
        
    }

    function createToken(string memory tokenURI) public payable  returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        require(msg.value >= mintprice , "please enter value");

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

    function setprice(uint256 _amount) public onlyOwner 
    {
        mintprice = _amount;
    }
}