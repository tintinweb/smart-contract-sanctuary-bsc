// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./ERC721A.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract DASDUK is ERC721A, Ownable, Pausable {
    uint256 public mint1price = 0.005 ether;
    uint256 public mint6price = 0.025 ether;
    uint256 public mint12price = 0.045 ether;
    uint256 public constant maxDucks = 10000;

    string public constant baseURI = "ipfs://QmWYA1zgmWXt6cmd9EMMC1LaxU2Y3GgnneZjGLc1XwNFLf/";

    constructor() ERC721A("Dastardly Ducks", "DASDUK", 100) {
        _pause();
    }

    function mintDuck() public payable whenNotPaused {
        require(mint1price <= msg.value, 'LOW_ETHER');
        unchecked { require(totalSupply() + 1 <= maxDucks, 'MAX_REACHED'); }
        _safeMint(msg.sender, 1);
    }

    function mint6Ducks() public payable whenNotPaused {
        require(mint6price <= msg.value, 'LOW_ETHER');
        unchecked { require(totalSupply() + 6 <= maxDucks, 'MAX_REACHED'); }
        _safeMint(msg.sender, 6);
    }

    function mint12Ducks() public payable whenNotPaused {
        require(mint12price <= msg.value, 'LOW_ETHER');
        unchecked { require(totalSupply() + 12 <= maxDucks, 'MAX_REACHED'); }
        _safeMint(msg.sender, 12);
    }

    // Mints for promotional purposes and early investors in the project
    function promoMint() public onlyOwner {
        unchecked { require(totalSupply() == 0, 'PROMO_RUN'); }
        _unpause();

        _safeMint(0x8aa986eB2F0D3b5001C9C2093698A4e13d646D5b, 32);
        _safeMint(0xb7940060B6AbD40d2EC723e95A3EA03bF569cDCf, 20);
        _safeMint(0x2351bbfAD2a6Cfd217b8c9ae6C390F495d298097, 24);
        _safeMint(0x9f3Ef50Ea64ADAD5B33F1F8222760CFBF42007F7, 24);
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        mint1price = newPrice;
    }

    function set6Price(uint256 newPrice) public onlyOwner {
        mint6price = newPrice;
    }

    function set12Price(uint256 newPrice) public onlyOwner {
        mint12price = newPrice;
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _baseURI() internal pure override returns (string memory) {
        return baseURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}