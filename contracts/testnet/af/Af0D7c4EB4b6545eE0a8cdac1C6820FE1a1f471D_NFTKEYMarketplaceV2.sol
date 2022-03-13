// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity =0.8.9;
pragma abicoder v2;

import "./Ownable.sol";
import "./Address.sol";
import "./EnumerableSet.sol";
import "./ReentrancyGuard.sol";
import "./IERC721.sol";
import "./SafeERC20.sol";
import "./INFTKEYMarketplaceV2.sol";
import "./NFTKEYMarketplaceRoyalty.sol";
import "./NFT.sol";

/**
 * @title NFTKEY Marketplace contract V2
 * Note: Payment tokens usually is the chain native coin's wrapped token, e.g. WETH, WBNB
 */
contract NFTKEYMarketplaceV2 is
    INFTKEYMarketplaceV2,
    Ownable,
    NFTKEYMarketplaceRoyalty,
    ReentrancyGuard
{
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    constructor(address _paymentTokenAddress) {
        _paymentToken = IERC20(_paymentTokenAddress);
    }

    IERC20 private immutable _paymentToken;

    bool private _isTradingEnabled = true;
    uint8 private _serviceFeeFraction = 20;
    uint256 private _actionTimeOutRangeMin = 1800; // 30 mins
    uint256 private _actionTimeOutRangeMax = 31536000; // One year - This can extend by owner is contract is working smoothly

    mapping(address => ERC721Market) private _erc721Market;

    address[] collections;

    mapping (address => uint) index;

    function addcollection(address newValue) internal {
        collections.push(newValue);
    }

    function getcollections() public view returns (address[] memory) {
        return collections;
    }
    
    /**
     * @dev only if listing and bid is enabled
     * This is to help contract migration in case of upgrading contract
     */
    modifier onlyTradingOpen() {
        require(_isTradingEnabled, "Listing and bid are not enabled");
        _;
    }

    /**
     * @dev only if the entered timestamp is within the allowed range
     * This helps to not list or bid for too short or too long period of time
     */
    modifier onlyAllowedExpireTimestamp(uint256 expireTimestamp) {
        require(
            expireTimestamp - block.timestamp >= _actionTimeOutRangeMin,
            "Please enter a longer period of time"
        );
        require(
            expireTimestamp - block.timestamp <= _actionTimeOutRangeMax,
            "Please enter a shorter period of time"
        );
        _;
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-listToken}.
     * The timestamp set needs to be in the allowed range
     * Listing must be valid
     */
    function listToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    )
        external
        override
        onlyTradingOpen
        onlyAllowedExpireTimestamp(expireTimestamp)
    {
        Listing memory listing = Listing({
            tokenId: tokenId,
            value: value,
            seller: msg.sender,
            expireTimestamp: expireTimestamp
        });

        require(
            _isListingValid(erc721Address, listing),
            "Listing is not valid"
        );

        _erc721Market[erc721Address].listings[tokenId] = listing;
        _erc721Market[erc721Address].tokenIdWithListing.add(tokenId);

        bool found;

        for (uint i; i < collections.length; i++) {
        if (collections[i] == erc721Address)
            found = true;
        }

        if (found == false) 
        addcollection(erc721Address);

        found = false;
        emit TokenListed(erc721Address, tokenId, listing);
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-delistToken}.
     * msg.sender must be the seller of the listing record
     */
    function delistToken(address erc721Address, uint256 tokenId)
        external
        override
    {
        require(
            _erc721Market[erc721Address].listings[tokenId].seller == msg.sender,
            "Only token seller can delist token"
        );

        emit TokenDelisted(
            erc721Address,
            tokenId,
            _erc721Market[erc721Address].listings[tokenId]
        );

        _delistToken(erc721Address, tokenId);
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-buyToken}.
     * Must have a valid listing
     * msg.sender must not the owner of token
     * msg.value must be at least sell price plus fees
     */
    function buyToken(address erc721Address, uint256 tokenId)
        external
        payable
        override
        nonReentrant
    {
        Listing memory listing = _erc721Market[erc721Address].listings[tokenId];
        require(
            _isListingValid(erc721Address, listing),
            "Token is not for sale"
        );
        require(
            !_isTokenOwner(erc721Address, tokenId, msg.sender),
            "Token owner can't buy their own token"
        );
        require(
            msg.value >= listing.value,
            "The value send is below sale price"
        );

        (uint256 _serviceFee, uint256 _royaltyFee) = _calculateFees(
            erc721Address,
            listing.value
        );

        Address.sendValue(
            payable(listing.seller),
            msg.value - _serviceFee - _royaltyFee
        );
        Address.sendValue(payable(owner()), _serviceFee);

        address _royaltyRecipient = royalty(erc721Address).recipient;
        if (_royaltyRecipient != address(0) && _royaltyFee > 0) {
            Address.sendValue(payable(_royaltyRecipient), _royaltyFee);
        }

        // Send token to buyer
        emit TokenBought({
            erc721Address: erc721Address,
            tokenId: tokenId,
            buyer: msg.sender,
            listing: listing,
            serviceFee: _serviceFee,
            royaltyFee: _royaltyFee
        });

        IERC721(erc721Address).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );

        // Remove token listing
        _delistToken(erc721Address, tokenId);
        _removeBidOfBidder(erc721Address, tokenId, msg.sender);
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-enterBidForToken}.
     * People can only enter bid if bid is valid
     */
    function enterBidForToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    )
        external
        override
        onlyTradingOpen
        onlyAllowedExpireTimestamp(expireTimestamp)
    {
        Bid memory bid = Bid(tokenId, value, msg.sender, expireTimestamp);

        require(_isBidValid(erc721Address, bid), "Bid is not valid");

        _erc721Market[erc721Address].tokenIdWithBid.add(tokenId);
        _erc721Market[erc721Address].bids[tokenId].bidders.add(msg.sender);
        _erc721Market[erc721Address].bids[tokenId].bids[msg.sender] = bid;

        emit TokenBidEntered(erc721Address, tokenId, bid);
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-withdrawBidForToken}.
     * There must be a bid exists
     * remove this bid record
     */
    function withdrawBidForToken(address erc721Address, uint256 tokenId)
        external
        override
    {
        Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
            msg.sender
        ];
        require(
            bid.bidder == msg.sender,
            "This address doesn't have bid on this token"
        );

        emit TokenBidWithdrawn(erc721Address, tokenId, bid);
        _removeBidOfBidder(erc721Address, tokenId, msg.sender);
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-acceptBidForToken}.
     * Must be owner of this token
     * Must have approved this contract to transfer token
     * Must have a valid existing bid that matches
     */
    function acceptBidForToken(
        address erc721Address,
        uint256 tokenId,
        address bidder,
        uint256 value
    ) external override nonReentrant {
        require(
            _isTokenOwner(erc721Address, tokenId, msg.sender),
            "Only token owner can accept bid of token"
        );
        require(
            _isTokenApproved(erc721Address, tokenId) ||
                _isAllTokenApproved(erc721Address, msg.sender),
            "The token is not approved to transfer by the contract"
        );

        Bid memory existingBid = getBidderTokenBid(
            erc721Address,
            tokenId,
            bidder
        );
        require(
            existingBid.tokenId == tokenId &&
                existingBid.value == value &&
                existingBid.bidder == bidder,
            "This token doesn't have a matching bid"
        );

        address _royaltyRecipient = royalty(erc721Address).recipient;
        (uint256 _serviceFee, uint256 _royaltyFee) = _calculateFees(
            erc721Address,
            existingBid.value
        );

        _paymentToken.safeTransferFrom({
            from: existingBid.bidder,
            to: msg.sender,
            value: existingBid.value - _serviceFee - _royaltyFee
        });
        _paymentToken.safeTransferFrom({
            from: existingBid.bidder,
            to: owner(),
            value: _serviceFee
        });
        if (_royaltyRecipient != address(0) && _royaltyFee > 0) {
            _paymentToken.safeTransferFrom({
                from: existingBid.bidder,
                to: _royaltyRecipient,
                value: _royaltyFee
            });
        }

        IERC721(erc721Address).safeTransferFrom({
            from: msg.sender,
            to: existingBid.bidder,
            tokenId: tokenId
        });

        emit TokenBidAccepted({
            erc721Address: erc721Address,
            tokenId: tokenId,
            seller: msg.sender,
            bid: existingBid,
            serviceFee: _serviceFee,
            royaltyFee: _royaltyFee
        });

        // Remove token listing
        _delistToken(erc721Address, tokenId);
        _removeBidOfBidder(erc721Address, tokenId, existingBid.bidder);
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-isTradingEnabled}.
     */
    function isTradingEnabled() external view override returns (bool) {
        return _isTradingEnabled;
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-getTokenListing}.
     */
    function getTokenListing(address erc721Address, uint256 tokenId)
        public
        view
        override
        returns (Listing memory validListing)
    {
        Listing memory listing = _erc721Market[erc721Address].listings[tokenId];
        if (_isListingValid(erc721Address, listing)) {
            validListing = listing;
        }
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-numTokenListings}.
     */
    function numTokenListings(address erc721Address)
        public
        view
        override
        returns (uint256)
    {
        return _erc721Market[erc721Address].tokenIdWithListing.length();
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-getTokenListings}.
     */
    function getTokenListings(address erc721Address) public view override returns (Listing[] memory listings, string[] memory URIs) {
       
        uint256 listingsCount = numTokenListings(erc721Address);

        listings = new Listing[](listingsCount);
        URIs = new string[](listingsCount);

            for (uint256 i = 0; i < listingsCount; i++) {
                uint256 tokenId = _erc721Market[erc721Address]
                    .tokenIdWithListing
                    .at(i);
                Listing memory listing = _erc721Market[erc721Address].listings[
                    tokenId
                ];
                if (_isListingValid(erc721Address, listing)) {
                    listings[i] = listing; 
                    URIs[i] = NFT(erc721Address).tokenURI(tokenId);
                }
            }
            return (listings,URIs);
    }

    function getcollection(address erc721Address) public view override returns (uint256[] memory tokenIds, string[] memory URIs) {
    
        uint256 Collectiontotal = NFT(erc721Address).totalSupply();

        tokenIds = new uint256[](Collectiontotal);
        URIs = new string[](Collectiontotal);

            for (uint256 i = 0; i < Collectiontotal; i++) {
                    tokenIds[i] = i; 
                    URIs[i] = NFT(erc721Address).tokenURI(i);
            }

        return (tokenIds,URIs);
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-getBidderTokenBid}.
     */
    function getBidderTokenBid(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) public view override returns (Bid memory validBid) {
        Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
            bidder
        ];
        if (_isBidValid(erc721Address, bid)) {
            validBid = bid;
        }
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-getTokenBids}.
     */
    function getTokenBids(address erc721Address, uint256 tokenId)
        external
        view
        override
        returns (Bid[] memory bids)
    {
        uint256 bidderCount = _erc721Market[erc721Address]
            .bids[tokenId]
            .bidders
            .length();

        bids = new Bid[](bidderCount);
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _erc721Market[erc721Address]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
                bidder
            ];
            if (_isBidValid(erc721Address, bid)) {
                bids[i] = bid;
            }
        }
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-getTokenHighestBid}.
     */
    function getTokenHighestBid(address erc721Address, uint256 tokenId)
        public
        view
        override
        returns (Bid memory highestBid)
    {
        highestBid = Bid(tokenId, 0, address(0), 0);
        uint256 bidderCount = _erc721Market[erc721Address]
            .bids[tokenId]
            .bidders
            .length();
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _erc721Market[erc721Address]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
                bidder
            ];
            if (
                _isBidValid(erc721Address, bid) && bid.value > highestBid.value
            ) {
                highestBid = bid;
            }
        }
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-numTokenWithBids}.
     */
    function numTokenWithBids(address erc721Address)
        public
        view
        override
        returns (uint256)
    {
        return _erc721Market[erc721Address].tokenIdWithBid.length();
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-getTokenHighestBids}.
     */
    function getTokenHighestBids(
        address erc721Address,
        uint256 from,
        uint256 size
    ) public view override returns (Bid[] memory highestBids) {
        uint256 tokenCount = numTokenWithBids(erc721Address);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            highestBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                highestBids[i] = getTokenHighestBid({
                    erc721Address: erc721Address,
                    tokenId: _erc721Market[erc721Address].tokenIdWithBid.at(
                        i + from
                    )
                });
            }
        }
    }

    function getBidderBids(
        address erc721Address,
        address bidder,
        uint256 from,
        uint256 size
    ) external view override returns (Bid[] memory bidderBids) {
        uint256 tokenCount = numTokenWithBids(erc721Address);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            bidderBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                bidderBids[i] = getBidderTokenBid({
                    erc721Address: erc721Address,
                    tokenId: _erc721Market[erc721Address].tokenIdWithBid.at(
                        i + from
                    ),
                    bidder: bidder
                });
            }
        }
    }

    /**
     * @dev check if the account is the owner of this erc721 token
     */
    function _isTokenOwner(
        address erc721Address,
        uint256 tokenId,
        address account
    ) private view returns (bool) {
        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.ownerOf(tokenId) returns (address tokenOwner) {
            return tokenOwner == account;
        } catch {
            return false;
        }
    }

    /**
     * @dev check if this contract has approved to transfer this erc721 token
     */
    function _isTokenApproved(address erc721Address, uint256 tokenId)
        private
        view
        returns (bool)
    {
        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.getApproved(tokenId) returns (address tokenOperator) {
            return tokenOperator == address(this);
        } catch {
            return false;
        }
    }

    /**
     * @dev check if this contract has approved to all of this owner's erc721 tokens
     */
    function _isAllTokenApproved(address erc721Address, address owner)
        private
        view
        returns (bool)
    {
        IERC721 _erc721 = IERC721(erc721Address);
        return _erc721.isApprovedForAll(owner, address(this));
    }

    /**
     * @dev Check if a listing is valid or not
     * The seller must be the owner
     * The seller must have give this contract allowance
     * The sell price must be more than 0
     * The listing mustn't be expired
     */
    function _isListingValid(address erc721Address, Listing memory listing)
        private
        view
        returns (bool isValid)
    {
        if (
            _isTokenOwner(erc721Address, listing.tokenId, listing.seller) &&
            (_isTokenApproved(erc721Address, listing.tokenId) ||
                _isAllTokenApproved(erc721Address, listing.seller)) &&
            listing.value > 0 &&
            listing.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    /**
     * @dev Check if an bid is valid or not
     * Bidder must not be the owner
     * Bidder must have enough balance same or more than bid price
     * Bidder must give the contract allowance same or more than bid price
     * Bid price must > 0
     * Bid mustn't been expired
     */
    function _isBidValid(address erc721Address, Bid memory bid)
        private
        view
        returns (bool isValid)
    {
        if (
            !_isTokenOwner(erc721Address, bid.tokenId, bid.bidder) &&
            _paymentToken.allowance(bid.bidder, address(this)) >= bid.value &&
            _paymentToken.balanceOf(bid.bidder) >= bid.value &&
            bid.value > 0 &&
            bid.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    /**
     * @dev delist a token - remove token id record and remove listing from mapping
     * @param tokenId erc721 token Id
     */
    function _delistToken(address erc721Address, uint256 tokenId) private {
        if (_erc721Market[erc721Address].tokenIdWithListing.contains(tokenId)) {
            delete _erc721Market[erc721Address].listings[tokenId];
            _erc721Market[erc721Address].tokenIdWithListing.remove(tokenId);
        }
    }

    /**
     * @dev remove a bid of a bidder
     * @param tokenId erc721 token Id
     * @param bidder bidder address
     */
    function _removeBidOfBidder(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) private {
        if (
            _erc721Market[erc721Address].bids[tokenId].bidders.contains(bidder)
        ) {
            // Step 1: delete the bid and the address
            delete _erc721Market[erc721Address].bids[tokenId].bids[bidder];
            _erc721Market[erc721Address].bids[tokenId].bidders.remove(bidder);

            // Step 2: if no bid left
            if (
                _erc721Market[erc721Address].bids[tokenId].bidders.length() == 0
            ) {
                _erc721Market[erc721Address].tokenIdWithBid.remove(tokenId);
            }
        }
    }

    /**
     * @dev Calculate service fee, royalty fee and left value
     * @param value bidder address
     */
    function _calculateFees(address erc721Address, uint256 value)
        private
        view
        returns (uint256 _serviceFee, uint256 _royaltyFee)
    {
        uint256 _royaltyFeeFraction = royalty(erc721Address).feeFraction;
        uint256 _baseFractions = 1000 +
            _serviceFeeFraction +
            _royaltyFeeFraction;

        _serviceFee = (value * _serviceFeeFraction) / _baseFractions;
        _royaltyFee = (value * _royaltyFeeFraction) / _baseFractions;
    }

    /**
     * @dev Enable to disable Bids and Listing
     */
    function changeMarketplaceStatus(bool enabled) external onlyOwner {
        _isTradingEnabled = enabled;
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-actionTimeOutRangeMin}.
     */
    function actionTimeOutRangeMin() external view override returns (uint256) {
        return _actionTimeOutRangeMin;
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-actionTimeOutRangeMax}.
     */
    function actionTimeOutRangeMax() external view override returns (uint256) {
        return _actionTimeOutRangeMax;
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-paymentToken}.
     */
    function paymentToken() external view override returns (address) {
        return address(_paymentToken);
    }

    /**
     * @dev Change minimum listing and bid time range
     */
    function changeMinActionTimeLimit(uint256 timeInSec) external onlyOwner {
        _actionTimeOutRangeMin = timeInSec;
    }

    /**
     * @dev Change maximum listing and bid time range
     */
    function changeMaxActionTimeLimit(uint256 timeInSec) external onlyOwner {
        _actionTimeOutRangeMax = timeInSec;
    }

    /**
     * @dev See {INFTKEYMarketplaceV2-serviceFee}.
     */
    function serviceFee() external view override returns (uint8) {
        return _serviceFeeFraction;
    }

    /**
     * @dev Change withdrawal fee percentage.
     * @param serviceFeeFraction_ Fraction of withdrawal fee based on 1000
     */
    function changeSeriveFee(uint8 serviceFeeFraction_) external onlyOwner {
        require(
            serviceFeeFraction_ <= 25,
            "Attempt to set percentage higher than 2.5%."
        );

        _serviceFeeFraction = serviceFeeFraction_;
    }
}