// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC20.sol"; 
import "./IERC721.sol";
import "./Ownable.sol";
import "./Counters.sol";
import "./ISimpleMarketplaceNativeERC721.sol";
import "./IPancakePair.sol";
import "./SafeERC20.sol";
import "./IBunzz.sol";

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
// range: [0, 2**112 - 1]
// resolution: 1 / 2**112
library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

contract MLIVMarketplace is Ownable, ISimpleMarketplaceNativeERC721, IBunzz{
    using UQ112x112 for uint224;
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    Counters.Counter private lastListingId;

    address public nft;
    address public erc20Token;
    address public router;
    IPancakeRouter internal dexRouter;
    IPancakePair internal dexPair;

    struct Listing {
        address seller;
        address currency;
        uint256 tokenId;
        uint256 price;
        bool isSold;
        bool exist;
    }

    mapping(uint256=>Listing) public listings;
    mapping(uint256=>uint256) public tokensListing;

    constructor(
        address _erc20,
        address _router
    ) {
        erc20Token = _erc20;
        router = _router;
        dexRouter = IPancakeRouter(router);
        IPancakeFactory dexFactory = IPancakeFactory(dexRouter.factory());
        dexPair = IPancakePair(
            dexFactory.getPair(
                erc20Token,
                dexRouter.WETH()
            )
        );
    }

    modifier onlyItemOwner(uint256 tokenId) {
        isItemOwner(tokenId);
        _;
    }

    modifier onlyTransferApproval(uint256 tokenId) {
        isTransferApproval(tokenId);
        _;
    }

    function isItemOwner(uint256 tokenId) internal view {
        IERC721 token = IERC721(nft);
        require(token.ownerOf(tokenId) == _msgSender(), "Marketplace: Not the item owner");
    }

    function isTransferApproval(uint256 tokenId) internal view {
        IERC721 token = IERC721(nft);
        require(token.getApproved(tokenId) == address(this), "Marketplace: Marketplace is not approved to use this tokenId");
    }

    function connectToOtherContracts(address[] calldata contracts) external override onlyOwner{
        setNFTContract(contracts[0]);
    }


    function setNFTContract(address _nft) internal {
        require(nft != _nft,"Marketplace: New NFT contract address have same value as the old one");
        nft = _nft;
        emit NftSet(_nft, msg.sender);
    }


    function list(uint256 tokenId, uint256 price) external override onlyItemOwner(tokenId) onlyTransferApproval(tokenId) {
        lastListingId.increment();
        uint256 listingId = lastListingId.current();

        require( tokensListing[tokenId] == 0, "Marketplace: the token is already listed");

        
        tokensListing[tokenId] = listingId;

        Listing memory _list = listings[tokensListing[tokenId]];
        require(_list.exist == false, "Marketplace: List already exist");
        require(_list.isSold == false, "Marketplace: Can not list an already sold item");

        Listing memory newListing = Listing(
            msg.sender,
            address(0),
            tokenId,
            price,
            false,
            true
        );

        listings[listingId] = newListing;

        emit NewListing(listingId, tokenId, msg.sender, price, address(0), block.timestamp);

    }

    function buy(uint256 tokenId) external payable override{
        Listing storage _list = listings[tokensListing[tokenId]];
        // 
        require(_list.price == msg.value, "Marketplace: The sent value doesn't equal the price");
        require(_list.isSold == false,"Marketplace: item is already sold");
        require(_list.exist == true, "Marketplace: item does not exist");
        require(_list.currency == address(0), "Marketplace: item currency is not the native one");
        require(_list.seller != msg.sender, "Marketplace: seller has the same address as buyer");
        IERC721 token = getToken();
        token.safeTransferFrom(_list.seller, msg.sender, tokenId, "");
        
        // transfer coin
        payable(_list.seller).transfer(msg.value);

        _list.isSold = true;

        emit Sold(tokenId, _list.seller, msg.sender, msg.value, address(0), block.timestamp);
        clearStorage(tokenId);
    }

    function getMarketPrice() internal view returns(uint256 priceBNB) {
        address token0 = dexPair.token0();
        // address token1 = dexPair.token1();
        (uint112 reserve0, uint112 reserve1, ) = dexPair.getReserves();
        uint256 ratio = token0 == dexRouter.WETH()
            ? uint256(reserve1) / uint256(reserve0)
            : uint256(reserve1) / uint256(reserve0);
        return (ratio);
    }

    function itemPriceAsERC20(uint256 tokenId) public view returns(uint256 amount) {
        uint256 priceBNB = listings[tokensListing[tokenId]].price;
        return (priceBNB / getMarketPrice());
    }

    function buyUsingERC20(uint256 tokenId) external payable {
        Listing storage _list = listings[tokensListing[tokenId]];
        // Get market price 
        // require(_list.price == msg.value, "Marketplace: The sent value doesn't equal the price");
        require(_list.isSold == false,"Marketplace: item is already sold");
        require(_list.exist == true, "Marketplace: item does not exist");
        require(_list.currency == address(0), "Marketplace: item currency is not the native one");
        require(_list.seller != msg.sender, "Marketplace: seller has the same address as buyer");
        IERC721 token = getToken();
        // transfer NFT
        token.safeTransferFrom(_list.seller, msg.sender, tokenId, "");
        
        // transfer token
        IERC20(erc20Token).transfer(
            _list.seller, 
            itemPriceAsERC20(tokenId)
        );

        _list.isSold = true;

        emit Sold(tokenId, _list.seller, msg.sender, msg.value, address(0), block.timestamp);
        clearStorage(tokenId);
    }

    function getToken() internal view returns(IERC721) {
        IERC721 token = IERC721(nft);
        return token;
    }

    function clearStorage(uint256 tokenId) internal {
        delete listings[tokensListing[tokenId]];
        delete tokensListing[tokenId];
    } 
}