// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";

contract NFT is Ownable,ERC721 {
    uint256 public tokenCounter;
    string private baseURI;

    address public onlyAddress;

    modifier onlyNft() {
        require(onlyAddress == _msgSender(), "NFT: caller is not error");
        _;
    }
    constructor() ERC721("HP-NFT-TOKEN", "HP-NTF") {
        tokenCounter=10000;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
    function changeBaseURI(string memory newBaseURI) external onlyOwner {
        require(bytes(newBaseURI).length > 0, "wrong base uri");
        baseURI = newBaseURI;
    }

    
    function   safeMint(address to) onlyNft external  returns(uint256)  {
        uint256 newTokenId=tokenCounter;
        _safeMint(to, newTokenId);
        tokenCounter=tokenCounter+1;
        return newTokenId;
    }

    function safeMint( address to,bytes memory _data) onlyNft external   returns(uint256){
        uint256 newTokenId=tokenCounter;
        _safeMint(to, newTokenId,_data);
        tokenCounter=tokenCounter+1;
        return newTokenId;
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function setOnlyAddress(address _address) public onlyOwner {
        onlyAddress = _address;
    }

}