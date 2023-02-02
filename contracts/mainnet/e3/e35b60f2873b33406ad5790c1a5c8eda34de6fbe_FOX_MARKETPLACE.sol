/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/*
 * FOX MARKETPLACE
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.16;

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721Metadata is IERC721 {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library EnumerableSet {
    struct Set {bytes32[] _values;mapping(bytes32 => uint256) _indexes;}

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {return false;}
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex;
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {return false;}
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {return set._indexes[value] != 0;}
    function _length(Set storage set) private view returns (uint256) {return set._values.length;}
    function _at(Set storage set, uint256 index) private view returns (bytes32) {return set._values[index];}
    function _values(Set storage set) private view returns (bytes32[] memory) {return set._values;}
    struct UintSet {Set _inner;}
    function add(UintSet storage set, uint256 value) internal returns (bool) {return _add(set._inner, bytes32(value));}
    function remove(UintSet storage set, uint256 value) internal returns (bool) {return _remove(set._inner, bytes32(value));}
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {return _contains(set._inner, bytes32(value));}
    function length(UintSet storage set) internal view returns (uint256) {return _length(set._inner);}
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {return uint256(_at(set._inner, index));}
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {result := store}
        return result;
    }
}

contract FOX_MARKETPLACE {
    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet private indexesForSale;

    uint256 fee = 25;
    uint256 feeDenominator = 10000;

    address private constant CEO = 0xc3fC2A765FC09158f365cA381c7A1a0939Ed978a;

    modifier onlyCEO() {
        require(msg.sender == CEO, "Only the CEO can do that");
        _;
    }

    constructor() {}

    struct NFT {
        uint256 id;
        address seller;
        address nftContract;
        uint256 price;
        bool isAuction;
        address highestBidder;
        uint256 startingTimeStamp;
        uint256 endingTimeStamp;
        string metadata;
        address currency;
    }

    NFT[] public nftsForSale;

    event NftOffered(uint256 index, NFT details);
    event NftBought(uint256 index, address buyer, NFT details);
    event BidPlaced(uint256 index, NFT details);
    event AuctionCancelled(uint256 index, NFT details);
    event OfferCancelled(uint256 index, NFT details);

    function buy(uint256 index) external {
        NFT memory thisNft = nftsForSale[index];
        require(indexesForSale.contains(index), "Not for sale anymore");
        require(!thisNft.isAuction, "Can't buy an auction");
        require(IBEP20(thisNft.currency).transferFrom(msg.sender, CEO, thisNft.price * fee / feeDenominator),"Token transfer failed");
        require(IBEP20(thisNft.currency).transferFrom(msg.sender, thisNft.seller, thisNft.price * (feeDenominator - fee) / feeDenominator),"Token transfer failed");
        indexesForSale.remove(index);
        IERC721(thisNft.nftContract).transferFrom(thisNft.seller, msg.sender, thisNft.id);
        emit NftBought(index, msg.sender, thisNft);
    }

    function offerForSale(uint256 id, uint256 price, address contractAddress, address currencyAddress) external {
        require(IERC721(contractAddress).ownerOf(id) == msg.sender, "Can't transfer a token that is not owned by you");
        require(IERC721(contractAddress).isApprovedForAll(msg.sender, address(this)), "Please approve this contract");
        NFT memory thisNft;
        thisNft.id = id;
        thisNft.seller = msg.sender;
        thisNft.nftContract = contractAddress;
        thisNft.price = price;
        thisNft.currency = currencyAddress;
        thisNft.metadata = IERC721Metadata(contractAddress).tokenURI(id);
        indexesForSale.add(nftsForSale.length);
        nftsForSale.push(thisNft);
        emit NftOffered(nftsForSale.length - 1, thisNft);
    }

    function offerForAuction(uint256 id, uint256 startingPrice, address contractAddress, uint256 startingTime, uint256 endingTime, address currencyAddress) external {
        NFT memory thisNft;
        thisNft.id = id;
        thisNft.seller = msg.sender;
        thisNft.nftContract = contractAddress;
        thisNft.price = startingPrice;
        thisNft.metadata = IERC721Metadata(contractAddress).tokenURI(id);
        thisNft.isAuction = true;
        thisNft.startingTimeStamp = startingTime;
        thisNft.endingTimeStamp = endingTime;
        thisNft.currency = currencyAddress;
        indexesForSale.add(nftsForSale.length);
        nftsForSale.push(thisNft);
        IERC721(thisNft.nftContract).transferFrom(msg.sender, address(this), id);
        emit NftOffered(nftsForSale.length - 1, thisNft);
    }

    function placeBid(uint256 index, uint256 bid) external {
        NFT memory thisNft = nftsForSale[index];
        require(indexesForSale.contains(index), "Not for sale anymore");
        require(thisNft.isAuction, "Can't bid on a nonAuction");
        require(thisNft.price < bid, "Bid needs to be higher than last");
        require(thisNft.startingTimeStamp <= block.timestamp, "Auction hasn't started yet");
        require(thisNft.endingTimeStamp >= block.timestamp, "Auction is finished");
        require(IBEP20(thisNft.currency).transferFrom(msg.sender, address(this), bid),"Token transfer failed");
        if(thisNft.highestBidder != address(0)) IBEP20(thisNft.currency).transfer(thisNft.highestBidder, thisNft.price);
        nftsForSale[index].highestBidder = msg.sender;
        nftsForSale[index].price = bid;
        emit BidPlaced(index, nftsForSale[index]);
    }

    function finalizeAuction(uint256 index) external {
        NFT memory thisNft = nftsForSale[index];
        require(indexesForSale.contains(index), "Not for sale anymore");
        require(thisNft.isAuction, "Needs to be an auction");
        require(thisNft.highestBidder != address(0), "Nobody has placed a bid");
        require(thisNft.endingTimeStamp < block.timestamp, "Auction is not finished");
        IERC721(thisNft.nftContract).transferFrom(address(this), thisNft.highestBidder, thisNft.id);
        require(IBEP20(thisNft.currency).transfer(CEO, thisNft.price * fee / feeDenominator),"Token transfer failed");
        require(IBEP20(thisNft.currency).transfer(thisNft.seller, thisNft.price * (feeDenominator - fee) / feeDenominator),"Token transfer failed");
        indexesForSale.remove(index);
        emit NftBought(index, thisNft.highestBidder, thisNft);
    }

    function cancelAuctionWithoutBids(uint256 index) external {
        NFT memory thisNft = nftsForSale[index];
        require(indexesForSale.contains(index), "Not for sale anymore");
        require(thisNft.isAuction, "Needs to be an auction");
        require(thisNft.highestBidder == address(0), "Someone has placed a bid");
        require(thisNft.endingTimeStamp < block.timestamp, "Auction is not finished");
        IERC721(thisNft.nftContract).transferFrom(address(this), thisNft.seller, thisNft.id);
        indexesForSale.remove(index);
        emit AuctionCancelled(index, thisNft);
    }

    function cancelUnsoldOffer(uint256 index) external {
        NFT memory thisNft = nftsForSale[index];
        require(thisNft.seller == msg.sender, "Only the seller can do that");
        require(indexesForSale.contains(index), "Not for sale anymore");
        require(!thisNft.isAuction, "Can't buy an auction");
        indexesForSale.remove(index);
        emit OfferCancelled(index, thisNft);
    }
    
    function getAllIndexesForSale() public view returns(uint256[] memory) {
        return indexesForSale.values();
    }

    function setFees(uint256 fees, uint256 feesDenominator) external onlyCEO {
        fee = fees;
        feeDenominator = feesDenominator;
    }
}