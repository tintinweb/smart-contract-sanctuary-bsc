// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./Counters.sol";
import "./Ownable.sol";
import "./Address.sol";

contract NFT is ERC721, ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Token price
    mapping( uint256 => uint) private _price;

    // Sale switches
    bool public publicSaleActive;

    // Is token available to sale
    mapping( uint256 => bool) private _tokenSaleActive;

    // Platform fee
    uint256 private sellFee = 5;
    // Base URI
    string private baseURI;

    uint256 public constant maxNftCount = 10000;
    uint256 public nftMinted;

    // For public sale
    uint public publicSaleStartTime;
    uint public publicSaleDuration;
    uint public publicSaleExpiration;

    // Events
    event PublicSaleStart(
        uint256 indexed _saleStartTime,
        uint256 indexed _saleDuration,
        uint256 indexed _saleExpirationTime
        
    );

    event PublicSaleStop(
        uint256 indexed _saleDuration,
        uint256 indexed _saleStartTime
    );

    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }
    

    constructor (string memory uri) ERC721("NFT Contract", "NFT TEST") {
        _transferOwnership(_msgSender());
        baseURI = uri;
    }

    
    // Sending sellFee=5% to the contract as fee
    // Returns extra funds to the sender
    function buyNFT(uint256 tokenId) external payable whenPublicSaleActive {
        require(_exists(tokenId), "Token doesn't exist");
        require(ownerOf(tokenId) != msg.sender, "You are the token owner");
        require(msg.value >= _price[tokenId], "Not enough eth");
        require(_tokenSaleActive[tokenId], "Sale is not active");
        
        Address.sendValue(payable(ownerOf(tokenId)), _price[tokenId] * (100 - sellFee ) / 100);
        safeTransferFrom(ownerOf(tokenId), msg.sender, tokenId, "");
        _tokenSaleActive[tokenId] = false;

        if (msg.value > _price[tokenId]) {
                Address.sendValue(payable(msg.sender), msg.value - _price[tokenId]);
            }

    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        _safeTransfer(from, to, tokenId, data);
    }

    // Mark nft as sellable
    function sellNFT(uint256 tokenId, uint256 tokenPrice) external whenPublicSaleActive {
        require(_exists(tokenId), "Token doesn't exist");
        require(ownerOf(tokenId) == msg.sender, "You aren't the token owner");
        require(!_tokenSaleActive[tokenId], "Already selling");

        _price[tokenId] = tokenPrice;
        _tokenSaleActive[tokenId] = true;

    }

    function startSelling(uint256 tokenId) external whenPublicSaleActive {
        require(ownerOf(tokenId) == msg.sender, "You aren't the token owner");
        require(_tokenSaleActive[tokenId], "Already selling");

        _tokenSaleActive[tokenId] = true;
    }

    function stopSelling(uint256 tokenId) external whenPublicSaleActive {
        require(ownerOf(tokenId) == msg.sender, "You aren't the token owner");
        require(_tokenSaleActive[tokenId], "Not selling");

        _tokenSaleActive[tokenId] = false;
    }

    function tokenSaleActive(uint256 tokenId) external view returns(bool) {
        if (publicSaleActive) {
            return _tokenSaleActive[tokenId];
        }
        else {
            return false;
        }
    }

    // Permission to sell items for a certain time
    function startPublicSale(uint _saleDuration) external onlyOwner {
        require(!publicSaleActive);
        publicSaleStartTime = block.timestamp;
        publicSaleDuration = _saleDuration;
        publicSaleExpiration = publicSaleStartTime + _saleDuration;
        publicSaleActive = true;

        emit PublicSaleStart(publicSaleStartTime, publicSaleDuration, publicSaleExpiration);
        
    }

    function pausePublicSale() external onlyOwner {
        require(publicSaleActive);
        publicSaleActive = false;

        emit PublicSaleStop(publicSaleStartTime, publicSaleDuration);
    }

    function withdraw() external onlyOwner {
            uint256 balance = address(this).balance;
            Address.sendValue(payable(owner()), balance);
        }

    // Set price for tokenId
    // Available when selling is stopped
    function setPrice(uint256 tokenId, uint tokenPrice) external {
        require(ownerOf(tokenId) == msg.sender, "You aren't the token owner");
        require(!_tokenSaleActive[tokenId], "Can't change the price during the sale");
        _price[tokenId] = tokenPrice;
    }

    // Get price of tokenId
    function price(uint256 tokenId) public view returns(uint) {
        require(_exists(tokenId), "Token doesn't exist");
        return _price[tokenId];
    }

    function getExpirationtime() public view returns(uint) {
        return publicSaleExpiration;
    }

    // Mint
    function mint(address to, uint256 amount) external onlyOwner {
        require(nftMinted + amount <= maxNftCount);
        for (uint256 i = 0; i < amount; i++) {
            safeMint(to);
        }
    }

    // Overrided safeMint for
    function safeMint(address to) private onlyOwner {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, baseURI); //CHECK LATER
            nftMinted += 1;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(_exists(tokenId), "Token doesn't exist");
        return super.tokenURI(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    // Actually deletes token URI
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    // Returns contract's balance
    function balanceOfContract() public view returns(uint) {
        return address(this).balance;
    }


    
}