// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./Counters.sol";
import "./IBEP20.sol";

/// @custom:security-contact [email protected]
contract CenturyNFTToken is ERC721, Pausable, Ownable {
    using Counters for Counters.Counter;
    IBEP20 public immutable currencyContract;
    Counters.Counter private _tokenIdCounter;

    uint256 modulus = 10**18;

    mapping(string => uint256) public token_base_price;
    mapping(uint256 => uint256) public token_new_price;
    mapping(uint256 => string) public token_id_to_type;

    event SetBasePrice(string nft_type, uint256 price, uint256 timestamp);
    event SetNewPrice(uint256 tokenId, uint256 price, uint256 timestamp);
    event Buy(
        address indexed user,
        uint256 tokenId,
        uint256 price,
        uint256 timestamp
    );
    event BuyFromSeller(
        address indexed seller,
        address indexed user,
        uint256 tokenId,
        uint256 price,
        uint256 timestamp
    );

    constructor(address token) ERC721("Century NFT Token", "CNT") {
        currencyContract = IBEP20(token);

        setBasePrice("chicken", 1 * modulus);
        setBasePrice("pig", 2 * modulus);
        setBasePrice("cow", 3 * modulus);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://admin.century.luxe/api/nfts/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * Set Base Price
     * @dev Allow owner set base price for nft type
     */
    function setBasePrice(string memory nft_type, uint256 price)
        public
        onlyOwner
        whenNotPaused
    {
        require(price > 0, "Base price must be greater than zero");

        token_base_price[nft_type] = price;

        emit SetBasePrice(nft_type, price, block.timestamp);
    }

    /**
     * Set New Price
     * @dev Allow owner of nft set new price
     */
    function setNewPrice(uint256 tokenId, uint256 price)
        external
        whenNotPaused
    {
        require(ownerOf(tokenId) == _msgSender(), "Not have permission");
        require(
            price > token_base_price[token_id_to_type[tokenId]],
            "New price must be greater than base price"
        );

        token_new_price[tokenId] = price;

        emit SetNewPrice(tokenId, price, block.timestamp);
    }

    /**
     * Buy
     * @dev Allow anyone buy nft from store
     */
    function buy(string memory nft_type) external whenNotPaused {
        require(token_base_price[nft_type] > 0);

        currencyContract.transferFrom(
            _msgSender(),
            owner(),
            token_base_price[nft_type]
        );

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        token_id_to_type[tokenId] = nft_type;
        token_new_price[tokenId] = 0;

        // Mint
        _safeMint(_msgSender(), tokenId);

        emit Buy(
            _msgSender(),
            tokenId,
            token_base_price[nft_type],
            block.timestamp
        );
    }

    /**
     * Buy From Seller
     * @dev Allow anyone buy nft from owner of nft
     */
    function buyFromSeller(uint256 tokenId) external whenNotPaused {
        require(
            token_new_price[tokenId] >
                token_base_price[token_id_to_type[tokenId]]
        );

        currencyContract.transferFrom(
            _msgSender(),
            ownerOf(tokenId),
            token_new_price[tokenId]
        );
        token_new_price[tokenId] = 0;

        // Transfer
        _transfer(ownerOf(tokenId), _msgSender(), tokenId);

        emit BuyFromSeller(
            ownerOf(tokenId),
            _msgSender(),
            tokenId,
            token_new_price[tokenId],
            block.timestamp
        );
    }
}