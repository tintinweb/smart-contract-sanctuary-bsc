// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC721.sol";
import "./Ownable.sol";
import "./Counters.sol";
import "./ISimpleMarketplaceNativeERC721.sol";
import "./IBunzz.sol";

contract SimpleMarketplaceNativeERC721 is Ownable, ISimpleMarketplaceNativeERC721, IBunzz{

    using Counters for Counters.Counter;
    Counters.Counter private lastListingId;

    address public nft;

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

    modifier onlyItemOwner(uint256 tokenId) {
        isItemOwner(tokenId);
        _;
    }

    modifier onlyTransferApproval(uint256 tokenId) {
        isTransferApproval(tokenId);
        _;
    }

    function isItemOwner(uint256 tokenId) internal {
        IERC721 token = IERC721(nft);
        require(token.ownerOf(tokenId) == _msgSender(), "Marketplace: Not the item owner");
    }

    function isTransferApproval(uint256 tokenId) internal {
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
        require(_list.price == msg.value, "Marketplace: The sent value doesn't equal the price");
        require(_list.isSold == false,"Marketplace: item is already sold");
        require(_list.exist == true, "Marketplace: item does not exist");
        require(_list.currency == address(0), "Marketplace: item currency is not the native one");
        require(_list.seller != msg.sender, "Marketplace: seller has the same address as buyer");
        IERC721 token = getToken();
        token.safeTransferFrom(_list.seller, msg.sender, tokenId, "");
        payable(_list.seller).transfer(msg.value);

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