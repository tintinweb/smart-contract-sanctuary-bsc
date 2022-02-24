// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Address.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./IERC721.sol";
import "./IERC1155.sol";
import "./Ownable.sol";
import "./EnumerableSet.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./OperahouseMarketplaceRoyalty.sol";

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract Marketplace is ReentrancyGuard, Ownable, OperahouseMarketplaceRoyalty {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    address adminAddress;
    address WFTM = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    bool marketplaceStatus;

    uint256 listingFee = 0 ether; // minimum price, change for what you want
    uint256 _serviceFee = 0;  // 0 % with 1000 factor

    struct Bid {
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address bidder;
        uint256 expireTimestamp;
    }

    struct TokenBids {
        EnumerableSet.AddressSet bidders;
        mapping(address => Bid) bids;
    }

    struct ListItem {
        uint8 contractType;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address seller;
        address paymentToken;
        bool listType;
        uint256 expireTimestamp;
        uint256 time;
    }

    struct ListItemInput {
        address nftContract;
        uint8 contractType;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address paymentToken;
        bool listType;
        uint256 expireTimestamp;
    }

    struct TransferItem {
        address nftContract;
        uint8 contractType;
        uint256 tokenId;
        uint256 amount;
        address toAccount;
    }

    struct CollectionMarket {
      EnumerableSet.UintSet tokenIdsListing;
      mapping(uint256 => ListItem) listings;
      EnumerableSet.UintSet tokenIdsWithBid;
      mapping(uint256 => TokenBids) bids;
    }

    mapping(address => CollectionMarket) private _marketplaceSales;

    // declare a event for when a item is created on marketplace
    event TokenListed(
        address indexed nftnftContract,
        uint256 indexed tokenId,
        string indexed contractType,
        ListItem listItem
    );
    event ListItemUpdated(
        address indexed nftnftContract,
        uint256 indexed tokenId,
        ListItem listItem
    );
    event TokenDelisted(
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 amount,
        ListItem listItem
    );
    event TokenBidEntered(
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 amount,
        Bid bid
    );
    event TokenBidWithdrawn(
        address indexed nftContract,
        uint256 indexed tokenId,
        Bid bid
    );
    event TokenBought(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed buyer,
        ListItem listing,
        uint256 serviceFee,
        uint256 royaltyFee
    );
    event TokenBidAccepted(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        Bid bid,
        uint256 serviceFee,
        uint256 royaltyFee
    );

    constructor() {
        adminAddress = 0x499FbD6C82C7C5D42731B3E9C06bEeFdC494C852;
        marketplaceStatus = true;
    }

    modifier onlyMarketplaceOpen() {
        require(marketplaceStatus, "Listing and bid are not enabled");
        _;
    }

    function _isTokenApproved(address nftContract, uint256 tokenId)
        private
        view
        returns (bool)
    {
        IERC721 _erc721 = IERC721(nftContract);
        try _erc721.getApproved(tokenId) returns (address tokenOperator) {
            return tokenOperator == address(this);
        } catch {
            return false;
        }
    }

    function _isAllTokenApproved(address nftContract, address owner)
        private
        view
        returns (bool)
    {
        IERC721 _erc721 = IERC721(nftContract);
        return _erc721.isApprovedForAll(owner, address(this));
    }

    function _isAllTokenApprovedERC1155(address nftContract, address owner)
        private
        view
        returns (bool)
    {
        IERC1155 _erc1155 = IERC1155(nftContract);
        return _erc1155.isApprovedForAll(owner, address(this));
    }

    function _isTokenOwner(
        address nftContract,
        uint256 tokenId,
        address account
    ) private view returns (bool) {
        IERC721 _erc721 = IERC721(nftContract);
        try _erc721.ownerOf(tokenId) returns (address tokenOwner) {
            return tokenOwner == account;
        } catch {
            return false;
        }
    }

    function _isTokenOwnerERC1155(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        address account
    ) private view returns (bool) {
        IERC1155 _erc1155 = IERC1155(nftContract);
        try _erc1155.balanceOf(account, tokenId) returns (uint256 ownedBalance) {
            return ownedBalance >= amount;
        } catch {
            return false;
        }
    }

    function _isListItemValid(address nftContract, ListItem memory listItem)
        private
        view
        returns (bool isValid)
    {
        if (
            listItem.contractType == 1 &&
            listItem.amount == 1 &&
            _isTokenOwner(nftContract, listItem.tokenId, listItem.seller) &&
            (_isTokenApproved(nftContract, listItem.tokenId) ||
                _isAllTokenApproved(nftContract, listItem.seller)) &&
            listItem.price > 0 &&
            listItem.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _isListItemValidERC1155(address nftContract, ListItem memory listItem)
        private
        view
        returns (bool isValid)
    {
        if (
            listItem.contractType == 2 &&
            listItem.amount >= 1 &&
            _isTokenOwnerERC1155(nftContract, listItem.tokenId, listItem.amount, listItem.seller) &&
            (_isAllTokenApprovedERC1155(nftContract, listItem.seller)) &&
            listItem.price > 0 &&
            listItem.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _isBidValid(address nftContract, Bid memory bid)
        private
        view
        returns (bool isValid)
    {
        if (
            !_isTokenOwner(nftContract, bid.tokenId, bid.bidder) &&
            bid.amount == 1 &&
            bid.price > 0 &&
            bid.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _isBidValidERC1155(Bid memory bid)
        private
        view
        returns (bool isValid)
    {
        if (
            bid.price > 0 &&
            bid.amount > 0 &&
            bid.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    // returns the listing price of the contract
    function getListingPrice() public view returns (uint256) {
        return listingFee;
    }

    function setListingPrice(uint256 price) external onlyOwner {
        require(
            price <= 2 ether,
            "Attempt to set percentage higher than 2 FTM"
        );
        listingFee = price;
    }

    function getServiceFee() public view returns (uint256) {
        return _serviceFee;
    }

    function setServiceFee(uint256 fee) external onlyOwner {
        require(
            fee <= 100,
            "Attempt to set percentage higher than 10 %"
        );
        _serviceFee = fee;
    }

    function changeMarketplaceStatus (bool status) external onlyOwner {
        require(status != marketplaceStatus, "Already set.");
        marketplaceStatus = status;
    }

    function _delistToken(address nftContract, uint256 tokenId, uint256 amount) private {
        if (_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId)) {
            if (_marketplaceSales[nftContract].listings[tokenId].amount > amount) {
                _marketplaceSales[nftContract].listings[tokenId].amount -= amount;
            } else {
                delete _marketplaceSales[nftContract].listings[tokenId];
                _marketplaceSales[nftContract].tokenIdsListing.remove(tokenId);
                if (_marketplaceSales[nftContract].tokenIdsWithBid.contains(tokenId)) {
                    delete _marketplaceSales[nftContract].bids[tokenId];
                    _marketplaceSales[nftContract].tokenIdsWithBid.remove(tokenId);
                }
            }
        }
    }

    function _removeBidOfBidder(
        address nftContract,
        uint256 tokenId,
        address bidder
    ) private {
        if (
            _marketplaceSales[nftContract].bids[tokenId].bidders.contains(bidder)
        ) {
            // Step 1: delete the bid and the address
            delete _marketplaceSales[nftContract].bids[tokenId].bids[bidder];
            _marketplaceSales[nftContract].bids[tokenId].bidders.remove(bidder);

            // Step 2: if no bid left
            if (
                _marketplaceSales[nftContract].bids[tokenId].bidders.length() == 0
            ) {
                delete _marketplaceSales[nftContract].bids[tokenId];
                _marketplaceSales[nftContract].tokenIdsWithBid.remove(tokenId);
            }
        }
    }

    // places an item for sale on the marketplace
    function listTokenERC1155(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) public payable nonReentrant onlyMarketplaceOpen {
        require(price > 0, "Price must be at least 1 wei");

        require(!_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Already listed");

        ListItem memory listItem = ListItem(
            2,
            tokenId,
            amount,
            price,
            msg.sender,
            paymentToken,
            listType,
            expireTimestamp,
            block.timestamp
        );

        require(
            _isListItemValidERC1155(nftContract, listItem),
            "Listing is not valid"
        );
        
        _marketplaceSales[nftContract].listings[tokenId] = listItem;
        _marketplaceSales[nftContract].tokenIdsListing.add(tokenId);

        if (listingFee > 0) {
            IERC20(paymentToken).transferFrom(msg.sender, adminAddress, listingFee);
        }
        emit TokenListed(nftContract, tokenId, "erc1155", listItem);
    }

    function listToken(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) public payable nonReentrant onlyMarketplaceOpen {
        require(price > 0, "Price must be at least 1 wei");

        require(!_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Already listed");

        ListItem memory listItem = ListItem(
            1,
            tokenId,
            1,
            price,
            msg.sender,
            paymentToken,
            listType,
            expireTimestamp,
            block.timestamp
        );

        require(
            _isListItemValid(nftContract, listItem),
            "Listing is not valid"
        );

        _marketplaceSales[nftContract].listings[tokenId] = listItem;
        _marketplaceSales[nftContract].tokenIdsListing.add(tokenId);

        if (listingFee > 0) {
            payable(adminAddress).transfer(listingFee);
        }
        emit TokenListed(nftContract, tokenId, "erc721", listItem);
    }

    function updateListedToken(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) public nonReentrant onlyMarketplaceOpen {
        require(price > 0, "Price must be at least 1 wei");

        require(_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Not listed");

        ListItem storage listItem = _marketplaceSales[nftContract].listings[tokenId];

        require(msg.sender == listItem.seller, "Not owner");
        
        listItem.tokenId = tokenId;
        listItem.amount = amount;
        listItem.price = price;
        listItem.listType = listType;
        listItem.paymentToken = paymentToken;
        listItem.expireTimestamp = expireTimestamp;

        if (listItem.contractType == 1) {
            require(
                _isListItemValid(nftContract, listItem),
                "Listing is not valid"
            );
        } else if (listItem.contractType == 2) {
            require(
                _isListItemValidERC1155(nftContract, listItem),
                "Listing is not valid"
            );
        } else {
            revert("Wrong list item");
        }

        emit ListItemUpdated(nftContract, tokenId, listItem);
    }

    function bulkListToken(
        ListItemInput[] memory listItems
    ) public payable nonReentrant onlyMarketplaceOpen {
        for (uint256 i = 0; i < listItems.length; i ++) {
            if (listItems[i].contractType == 1) {
                listToken(listItems[i].nftContract, listItems[i].tokenId, listItems[i].price, listItems[i].paymentToken, listItems[i].listType, listItems[i].expireTimestamp);
            } else if (listItems[i].contractType == 2) {
                listTokenERC1155(listItems[i].nftContract, listItems[i].tokenId, listItems[i].amount, listItems[i].price, listItems[i].paymentToken, listItems[i].listType, listItems[i].expireTimestamp);
            } else {
                revert("Unsupported contract type");
            }
        }
    }

    function delistToken(address nftContract, uint256 tokenId, uint256 amount)
        external
    {
        require(
            _marketplaceSales[nftContract].listings[tokenId].seller == msg.sender,
            "Only token seller can delist token"
        );

        emit TokenDelisted(
            nftContract,
            tokenId,
            amount,
            _marketplaceSales[nftContract].listings[tokenId]
        );

        _delistToken(nftContract, tokenId, amount);
    }


    function buyToken(
        address nftContract,
        uint256 tokenId,
        uint256 amount
    ) external payable nonReentrant onlyMarketplaceOpen {

        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];

        if (listItem.contractType == 1) {
            require(
                _isListItemValid(nftContract, listItem),
                "Not for sale"
            );
            require(
                !_isTokenOwner(nftContract, tokenId, msg.sender),
                "Token owner can't buy their own token"
            );
        } else if (listItem.contractType == 2) {
            require(
                _isListItemValidERC1155(nftContract, listItem),
                "Not for sale"
            );
            require(
                !_isTokenOwnerERC1155(nftContract, tokenId, amount, msg.sender),
                "Token owner can't buy their own token"
            );
        } else {
            revert();
        }

        uint256 totalPrice = listItem.price.mul(listItem.amount);
        uint256 royaltyPrice;
        address recipient;
        uint256 serviceFee = totalPrice.mul(_serviceFee).div(1000);
   
        if (checkRoyalties(nftContract)) {
            (recipient, royaltyPrice) = royaltyFromERC2981(nftContract, tokenId, totalPrice);
        } else {
            CollectionRoyalty memory collectionRoyalty = royalty(nftContract);
            recipient = collectionRoyalty.recipient;
            royaltyPrice = collectionRoyalty.feeFraction.mul(totalPrice).div(1000);
        }

        if (listItem.paymentToken == address(0)) {
            require(
                msg.value >= listItem.price,
                "The value send is below sale price"
            );
            if (recipient != address(0)) Address.sendValue(payable(recipient), royaltyPrice);
            Address.sendValue(payable(adminAddress), serviceFee);
            Address.sendValue(payable(listItem.seller), totalPrice - royaltyPrice - serviceFee);
        } else {
            if (recipient != address(0)) IERC20(listItem.paymentToken).safeTransfer(recipient, royaltyPrice);
            IERC20(listItem.paymentToken).safeTransfer(adminAddress, serviceFee);
            IERC20(listItem.paymentToken).safeTransfer(listItem.seller, serviceFee);
        }

        if (listItem.contractType == 1) {
            IERC721(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId);
        } else if (listItem.contractType == 2) {
            IERC1155(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId, amount, "");
        }

        emit TokenBought(
            nftContract,
            tokenId,
            msg.sender,
            listItem,
            serviceFee,
            royaltyPrice
        );

        _delistToken(nftContract, tokenId, amount);
    }

    function enterBid(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        uint256 expireTimestamp
    )
        public nonReentrant onlyMarketplaceOpen
    {
        Bid memory bid = Bid(tokenId, amount, price, msg.sender, expireTimestamp);

        require(_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Not for bid");

        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        address paymentToken = listItem.paymentToken;
        if ((listItem.contractType == 1 && !_isBidValid(nftContract, bid)) || (listItem.contractType == 2 && !_isBidValidERC1155(bid))) {
            revert("Bid is not valid");
        }
        
        if (paymentToken == address(0)) {
            require(address(msg.sender).balance >= price, "Insurance money");
        } else {
            require((IERC20(paymentToken).balanceOf(msg.sender) >= price &&
                IERC20(paymentToken).allowance(msg.sender, address(this)) >= price),
                "Insurance money or not approved"
            );
        }

        _marketplaceSales[nftContract].tokenIdsWithBid.add(tokenId);
        _marketplaceSales[nftContract].bids[tokenId].bidders.add(msg.sender);
        _marketplaceSales[nftContract].bids[tokenId].bids[msg.sender] = bid;

        emit TokenBidEntered(nftContract, tokenId, amount, bid);
    }

    function accpetBid(
        address nftContract,
        uint8 contractType,
        uint256 tokenId,
        uint256 amount,
        address payable bidder,
        uint256 price
    ) external nonReentrant {
        if (contractType == 1) {
            require(
                _isTokenOwner(nftContract, tokenId, msg.sender),
                "Only token owner can accept bid of token"
            );
            require(
                _isTokenApproved(nftContract, tokenId) ||
                    _isAllTokenApproved(nftContract, msg.sender),
                "The token is not approved to transfer by the contract"
            );
        } else if (contractType == 2) {
            require(
                _isTokenOwnerERC1155(nftContract, tokenId, amount, msg.sender),
                "Only token owner can accept bid of token"
            );
            require(
                _isAllTokenApprovedERC1155(nftContract, msg.sender),
                "The token is not approved to transfer by the contract"
            );
        }

        Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
            bidder
        ];
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        require(_isBidValid(nftContract, bid), "Not valid bidder");
        require(
            bid.tokenId == tokenId &&
                bid.amount == amount &&
                bid.price == price &&
                bid.bidder == bidder,
            "This nft doesn't have a matching bid"
        );
        require(
            listItem.tokenId == tokenId &&
                listItem.amount >= amount,
            "Don't match with listing"
        );

        uint256 royaltyPrice;
        address recipient;
        uint256 totalPrice = price.mul(amount);
        uint256 serviceFee = totalPrice.mul(_serviceFee).div(1000);
        address paymentToken = _marketplaceSales[nftContract].listings[tokenId].paymentToken;
        

        if (checkRoyalties(nftContract)) {
            (recipient, royaltyPrice) = royaltyFromERC2981(nftContract, tokenId, totalPrice);
        } else {
            CollectionRoyalty memory collectionRoyalty = royalty(nftContract);
            recipient = collectionRoyalty.recipient;
            royaltyPrice = collectionRoyalty.feeFraction;
        }

        if (paymentToken == address(0)) {
            paymentToken = WFTM;
        }

        if (recipient != address(0)) {
            IERC20(paymentToken).safeTransferFrom({
                from: bidder,
                to: recipient,
                value: royaltyPrice
            });
        }
        IERC20(paymentToken).safeTransferFrom({
            from: bidder,
            to: adminAddress,
            value: serviceFee
        });
        IERC20(paymentToken).safeTransferFrom({
            from: bidder,
            to: msg.sender,
            value: totalPrice - serviceFee - royaltyPrice
        });

        if (listItem.contractType == 1) {
            IERC721(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId);
        } else if (listItem.contractType == 2) {
            IERC1155(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId, amount, "");
        }

        if (paymentToken == address(0)) {
            IWETH(WFTM).withdraw(price - serviceFee - royaltyPrice);
        }

        emit TokenBidAccepted({
            nftContract: nftContract,
            tokenId: tokenId,
            seller: msg.sender,
            bid: bid,
            serviceFee: serviceFee,
            royaltyFee: royaltyPrice
        });
        _delistToken(nftContract, tokenId, amount);
    }

    function bulkTransfer(TransferItem[] memory items)
        external
    {
        for (uint256 i = 0; i < items.length; i ++) {
            TransferItem memory item = items[i];
            if (item.contractType == 1) {
                IERC721(item.nftContract).safeTransferFrom(msg.sender, item.toAccount, item.tokenId);
            } else {
                IERC1155(item.nftContract).safeTransferFrom(msg.sender, item.toAccount, item.tokenId, item.amount, "");
            }
        }
    }

    function getTokenListing(address nftContract, uint256 tokenId)
        public
        view
        returns (ListItem memory validListing)
    {
        ListItem memory listing = _marketplaceSales[nftContract].listings[tokenId];
        if ((listing.contractType == 1 && _isListItemValid(nftContract, listing)) || (listing.contractType == 2 && _isListItemValidERC1155(nftContract, listing))) {
            validListing = listing;
        }
    }

    function numOfTokenListings(address nftContract)
        public
        view
        returns (uint256)
    {
        return _marketplaceSales[nftContract].tokenIdsListing.length();
    }

    function getTokenListings(
        address nftContract,
        uint256 from,
        uint256 size
    ) public view returns (ListItem[] memory listings) {
        uint256 listingsCount = numOfTokenListings(nftContract);

        if (from < listingsCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > listingsCount) {
                querySize = listingsCount - from;
            }
            listings = new ListItem[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                uint256 tokenId = _marketplaceSales[nftContract]
                    .tokenIdsListing
                    .at(i + from);
                ListItem memory listing = _marketplaceSales[nftContract].listings[
                    tokenId
                ];
                if ((listing.contractType == 1 && _isListItemValid(nftContract, listing)) || (listing.contractType == 2 && _isListItemValidERC1155(nftContract, listing))) {
                    listings[i] = listing;
                }
            }
        }
    }

    function getBidderTokenBid(
        address nftContract,
        uint256 tokenId,
        address bidder
    ) public view returns (Bid memory validBid) {
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
            bidder
        ];
        if ((listItem.contractType == 1 && _isBidValid(nftContract, bid)) || (listItem.contractType == 2 && _isBidValidERC1155(bid))) {
            validBid = bid;
        }
    }

    function getTokenBids(address nftContract, uint256 tokenId)
        external
        view
        returns (Bid[] memory bids)
    {
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];

        uint256 bidderCount = _marketplaceSales[nftContract]
            .bids[tokenId]
            .bidders
            .length();

        bids = new Bid[](bidderCount);
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _marketplaceSales[nftContract]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
                bidder
            ];
            if ((listItem.contractType == 1 && _isBidValid(nftContract, bid)) || (listItem.contractType == 2 && _isBidValidERC1155(bid))) {
                bids[i] = bid;
            }
        }
    }

    function getTokenHighestBid(address nftContract, uint256 tokenId)
        public
        view
        returns (Bid memory highestBid)
    {
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        highestBid = Bid(tokenId, 1, 0, address(0), 0);
        uint256 bidderCount = _marketplaceSales[nftContract]
            .bids[tokenId]
            .bidders
            .length();
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _marketplaceSales[nftContract]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
                bidder
            ];
            if (listItem.contractType == 1) {
                if (
                    _isBidValid(nftContract, bid) && bid.price > highestBid.price
                ) {
                    highestBid = bid;
                }
            } else if (listItem.contractType == 2) {
                if (
                    _isBidValidERC1155(bid) && bid.price > highestBid.price
                ) {
                    highestBid = bid;
                }
            }
        }
    }

    function numTokenWithBids(address nftContract)
        public
        view
        returns (uint256)
    {
        return _marketplaceSales[nftContract].tokenIdsWithBid.length();
    }

    function getTokenHighestBids(
        address nftContract,
        uint256 from,
        uint256 size
    ) public view returns (Bid[] memory highestBids) {
        uint256 tokenCount = numTokenWithBids(nftContract);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            highestBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                highestBids[i] = getTokenHighestBid({
                    nftContract: nftContract,
                    tokenId: _marketplaceSales[nftContract].tokenIdsWithBid.at(
                        i + from
                    )
                });
            }
        }
    }

    function getBidderBids(
        address nftContract,
        address bidder,
        uint256 from,
        uint256 size
    ) external view returns (Bid[] memory bidderBids) {
        uint256 tokenCount = numTokenWithBids(nftContract);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            bidderBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                bidderBids[i] = getBidderTokenBid({
                    nftContract: nftContract,
                    tokenId: _marketplaceSales[nftContract].tokenIdsWithBid.at(
                        i + from
                    ),
                    bidder: bidder
                });
            }
        }
    }
}