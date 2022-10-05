// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./ERC721AQueryable.sol";
import "./Ownable.sol";



contract NextVisionCapital is ERC721AQueryable, Ownable {

    uint256 public constant COLLECTION_SIZE = 10;

    string public uri = "ipfs://QmWFsBsmbbw7f33CqL3auwtzMyE6KGSmHHH6qEuUwHfqXD";
    constructor() ERC721A("NextVisionCapital T20", "NVC T20") {
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }

    function changeBaseURI(string memory newBaseURI) external onlyOwner{
        uri = newBaseURI;
    }

     function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, ""))
                : "";
    }

    function safeMintTo(address toAddress ,uint256 _quantity) external onlyOwner{
        require(_quantity > 0, "Quantity must be greater than 0.");

        require(
            totalSupply() + _quantity <= COLLECTION_SIZE,
            "Cannot mint over supply cap"
        );

        _safeMint(toAddress, _quantity);
    }


    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }
}