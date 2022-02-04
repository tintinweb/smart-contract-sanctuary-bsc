//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MarketEvents.sol";
import "./Verification.sol";
import "./ILazymint.sol";

/// @title An Auction Contract for bidding and selling single and batched NFTs
/// @notice This contract can be used for auctioning any NFTs, and accepts any ERC20 token as payment
/// @author Disruptive Studios
/// @author Modified from Avo Labs GmbH (https://github.com/avolabs-io/nft-auction/blob/master/contracts/NFTAuction.sol)
contract NFTMarket is MarketEvents, verification {
    ///@notice Map each auction with the token ID
    mapping(address => mapping(uint256 => Auction)) public nftContractAuctions;
    ///@notice If transfer fail save to withdraw later
    mapping(address => uint256) public failedTransferCredits;

    ///@notice Each Auction is unique to each NFT (contract + id pairing).
    ///@param auctionBidPeriod Increments the length of time the auction is open in which a new bid can be made after each bid.
    ///@param ERC20Token The seller can specify an ERC20 token that can be used to bid or purchase the NFT.
    struct Auction {
        uint32 bidIncreasePercentage;
        uint32 auctionBidPeriod;
        uint64 auctionEnd;
        uint256 minPrice;
        uint256 buyNowPrice;
        uint256 nftHighestBid;
        address nftHighestBidder;
        address nftSeller;
        address ERC20Token;
        address[] feeRecipients;
        uint32[] feePercentages;
        bool lazymint;
        string metadata;
    }

    ///@notice Default values that are used if not specified by the NFT seller.

    address payable public addressmarketfee;
    uint256 feeMarket = 500; //Equal 5%

    /*///////////////////////////////////////////////////////////////
                              MODIFIERS       
    //////////////////////////////////////////////////////////////*/

    modifier isAuctionNotStartedByOwner(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        require(
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
                msg.sender,
            "Initiated by the owner"
        );

        if (
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
            address(0)
        ) {
            require(
                msg.sender == IERC721(_nftContractAddress).ownerOf(_tokenId),
                "Sender doesn't own NFT"
            );
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////
                              END MODIFIERS            
    //////////////////////////////////////////////////////////////*/

    // constructor
    constructor(address payable _addressmarketfee) {
        addressmarketfee = _addressmarketfee;
    }

    /*///////////////////////////////////////////////////////////////
                    AUCTION/SELL CHECK FUNCTIONS             
    //////////////////////////////////////////////////////////////*/
    ///@dev If the buy now price is set by the seller, check that the highest bid meets that price.
    function _isBuyNowPriceMet(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        uint256 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;
        return
            buyNowPrice > 0 &&
            nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid >=
            buyNowPrice;
    }

    ///@dev Check that a bid is applicable for the purchase of the NFT.
    ///@dev In the case of a sale: the bid needs to meet the buyNowPrice. if buyNowPrice is met, ignore increase percentage
    ///@dev In the case of an auction: the bid needs to be a % higher than the previous bid.
    ///@dev if the NFT is up for auction, the bid needs to be a % higher than the previous bid
    function _bidMeetBidRequirements(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal view returns (bool) {
        uint256 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;

        if (
            buyNowPrice > 0 &&
            (msg.value >= buyNowPrice || _tokenAmount >= buyNowPrice)
        ) {
            return true;
        }
        uint32 bidIncreasePercentage = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].bidIncreasePercentage;

        uint256 bidIncreaseAmount = (nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid * (10000 + bidIncreasePercentage)) / 10000;
        return (msg.value >= bidIncreaseAmount ||
            _tokenAmount >= bidIncreaseAmount);
    }

    ///@dev Payment is accepted in the following scenarios:
    ///@dev (1) Auction already created - can accept ETH or Specified Token
    ///@dev  --------> Cannot bid with ETH & an ERC20 Token together in any circumstance<------
    ///@dev (2) Auction not created - only ETH accepted (cannot early bid with an ERC20 Token
    ///@dev (3) Cannot make a zero bid (no ETH or Token amount)
    function _isPaymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        address _bidERC20Token,
        uint256 _tokenAmount
    ) internal view returns (bool) {
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (auctionERC20Token != address(0)) {
            return
                msg.value == 0 &&
                auctionERC20Token == _bidERC20Token &&
                _tokenAmount > 0;
        } else {
            return
                msg.value != 0 &&
                _bidERC20Token == address(0) &&
                _tokenAmount == 0;
        }
    }

    /*///////////////////////////////////////////////////////////////
                                     END              
                            AUCTION CHECK FUNCTIONS        
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                      TRANSFER NFTS TO CONTRACT        
    //////////////////////////////////////////////////////////////*/

    function _transferNftToAuctionContract(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {
        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        if (IERC721(_nftContractAddress).ownerOf(_tokenId) == _nftSeller) {
            IERC721(_nftContractAddress).transferFrom(
                _nftSeller,
                address(this),
                _tokenId
            );
            require(
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this),
                "nft transfer failed"
            );
        } else {
            require(
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this),
                "Seller doesn't own NFT"
            );
        }
    }

    /*///////////////////////////////////////////////////////////////
                                END
                      TRANSFER NFTS TO CONTRACT        
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                          AUCTION CREATION        
    //////////////////////////////////////////////////////////////*/

    ///@dev Setup parameters applicable to all auctions and whitelised sales:
    ///@dev --> ERC20 Token for payment (if specified by the seller) : _erc20Token
    ///@dev --> minimum price : _minPrice
    ///@dev --> buy now price : _buyNowPrice
    ///@dev --> the nft seller: msg.sender
    ///@dev --> The fee recipients & their respective percentages for a sucessful auction/sale
    function _setupAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _minPrice,
        uint256 _buyNowPrice,
        uint32 _bidIncreasePercentage,
        uint32 _auctionBidPeriod,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    ) internal isFeePercentagesLessThanMaximum(_feePercentages) {
        if (_erc20Token != address(0)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients = _feeRecipients;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feePercentages = _feePercentages;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = _minPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = msg
            .sender;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = _bidIncreasePercentage;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .auctionBidPeriod = _auctionBidPeriod;
    }

    function _createNewNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token, //change to BEP20Token
        uint256 _minPrice,
        uint256 _buyNowPrice,
        uint32 _bidIncreasePercentage,
        uint32 _auctionBidPeriod,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages,
        bool _lazymint,
        string memory _metadata
    ) internal {
        string memory _uri;
        if (!_lazymint) {
            _uri = metadata(_nftContractAddress, _tokenId);
        } else {
            _uri = _metadata;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBid = _minPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].lazymint = _lazymint;
        nftContractAuctions[_nftContractAddress][_tokenId].metadata = _metadata;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd = (uint64(
            block.timestamp
        ) + _auctionBidPeriod);
        _setupAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _bidIncreasePercentage,
            _auctionBidPeriod,
            _feeRecipients,
            _feePercentages
        );
        emit NftAuctionCreated(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _auctionBidPeriod,
            _bidIncreasePercentage,
            _feeRecipients,
            _feePercentages,
            _lazymint,
            _uri
        );
    }

    ///@param _bidIncreasePercentage It is the percentage for an offer to be validated.
    ///@param _auctionBidPeriod this is the time that the auction lasts until another bid occurs
    function createNewNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _minPrice,
        uint256 _buyNowPrice,
        uint32 _auctionBidPeriod,
        uint32 _bidIncreasePercentage,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages,
        bool _lazymint,
        string memory _metadata
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_minPrice)
    {
        require(
            _bidIncreasePercentage >= 100, //Equal 1%
            "Bid increase percentage too low"
        );

        _createNewNftAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _bidIncreasePercentage,
            _auctionBidPeriod,
            _feeRecipients,
            _feePercentages,
            _lazymint,
            _metadata
        );
        if (!_lazymint) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
        }
    }

    /*///////////////////////////////////////////////////////////////
                              END
                       AUCTION CREATION          
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                              SALES        
    //////////////////////////////////////////////////////////////*/
    function _setupSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    ) internal isFeePercentagesLessThanMaximum(_feePercentages) {
        if (_erc20Token != address(0)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients = _feeRecipients;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feePercentages = _feePercentages;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = msg
            .sender;
    }

    ///@notice Allows for a standard sale mechanism.
    ///@dev For sale the min price must be 0
    ///@dev _isABidMade check if buyNowPrice is meet and conclude sale, otherwise reverse the early bid
    function createSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages,
        bool _lazymint,
        string memory _metadata
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_buyNowPrice)
    {
        nftContractAuctions[_nftContractAddress][_tokenId].lazymint = _lazymint;
        nftContractAuctions[_nftContractAddress][_tokenId].metadata = _metadata;
        _setupSale(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _buyNowPrice,
            _feeRecipients,
            _feePercentages
        );
        string memory _uri;
        if (!_lazymint) {
            _uri = metadata(_nftContractAddress, _tokenId);
        } else {
            _uri = _metadata;
        }

        emit SaleCreated(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            _erc20Token,
            _buyNowPrice,
            _feeRecipients,
            _feePercentages,
            _lazymint,
            _uri
        );
        if (!_lazymint) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
        }
    }

    /*///////////////////////////////////////////////////////////////
                              END  SALES         
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                              BID FUNCTIONS          
    //////////////////////////////////////////////////////////////*/

    ///@notice Make bids with ETH or an ERC20 Token specified by the NFT seller.
    ///@notice Additionally, a buyer can pay the asking price to conclude a sale of an NFT.
    function makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _tokenAmount
    ) external payable {
        uint64 auctionEndTimestamp = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionEnd;
        if (auctionEndTimestamp != 0) {
            require(
                (block.timestamp < auctionEndTimestamp),
                "Auction has ended"
            );
        }
        require(
            msg.sender !=
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Owner cannot bid on own NFT"
        );
        require(
            _bidMeetBidRequirements(
                _nftContractAddress,
                _tokenId,
                _tokenAmount
            ),
            "Not enough funds to bid on NFT"
        );
        require(
            _isPaymentAccepted(
                _nftContractAddress,
                _tokenId,
                _erc20Token,
                _tokenAmount
            ),
            "Bid to be in specified ERC20/Eth"
        );
        _reversePreviousBidAndUpdateHighestBid(
            _nftContractAddress,
            _tokenId,
            _tokenAmount
        );
        emit BidMade(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            msg.value,
            _erc20Token,
            _tokenAmount
        );
        _updateOngoingAuction(_nftContractAddress, _tokenId);
    }

    /*///////////////////////////////////////////////////////////////
                        END BID FUNCTIONS           
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        UPDATE AUCTION           
    //////////////////////////////////////////////////////////////*/

    ///@notice Settle an auction or sale if the buyNowPrice is met or set
    ///@dev min price not set, nft not up for auction yet
    function _updateOngoingAuction(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {
        if (_isBuyNowPriceMet(_nftContractAddress, _tokenId)) {
            _transferNftAndPaySeller(_nftContractAddress, _tokenId);
            return;
        }
    }

    ///@dev the auction end is always set to now + the bid period
    /*function _updateAuctionEnd(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        uint32 auctionBidPeriod = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionBidPeriod;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd =
            auctionBidPeriod +
            uint64(block.timestamp);
        emit AuctionPeriodUpdated(
            _nftContractAddress,
            _tokenId,
            nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd
        );
    }*/

    /*///////////////////////////////////////////////////////////////
                           END UPDATE AUCTION
   //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                           RESET FUNCTIONS    
   //////////////////////////////////////////////////////////////*/

    ///@notice Reset all auction related parameters for an NFT.
    ///@notice This effectively removes an NFT as an item up for auction
    function _resetAuction(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionBidPeriod = 0;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token = address(
            0
        );
    }

    ///@notice Reset all bid related parameters for an NFT.
    ///@notice This effectively sets an NFT as having no active bids
    function _resetBids(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = address(0);
        nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid = 0;
    }

    /*///////////////////////////////////////////////////////////////
                        END RESET FUNCTIONS         
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        UPDATE BIDS         
    //////////////////////////////////////////////////////////////*/
    function _reversePreviousBidAndUpdateHighestBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal {
        address prevNftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;

        uint256 prevNftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            );
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = _tokenAmount;
        } else {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = msg.value;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = msg.sender;

        if (prevNftHighestBidder != address(0)) {
            _payout(
                _nftContractAddress,
                _tokenId,
                prevNftHighestBidder,
                prevNftHighestBid
            );
        }
    }

    /*///////////////////////////////////////////////////////////////
                          END UPDATE BIDS         
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                    TRANSFER NFT, PAY SELLER & MARKET      
    //////////////////////////////////////////////////////////////*/
    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {
        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        address _nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;
        uint256 _nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;
        _resetBids(_nftContractAddress, _tokenId);

        _payFeesAndSeller(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _nftHighestBid
        );
        if (!lazymint) {
            IERC721(_nftContractAddress).transferFrom(
                address(this),
                _nftHighestBidder,
                _tokenId
            );
        } else {
            //This is the lazyminting function
            ILazyNFT(_nftContractAddress).redeem(
                _nftHighestBidder,
                _tokenId,
                nftContractAuctions[_nftContractAddress][_tokenId].metadata
            );
        }
        _resetAuction(_nftContractAddress, _tokenId);
        emit NFTTransferredAndSellerPaid(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _nftHighestBid,
            _nftHighestBidder
        );
    }

    function _payFeesAndSeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address _nftSeller,
        uint256 _highestBid
    ) internal {
        uint256 minusfee = _getPortionOfBid(_highestBid, feeMarket);
        uint256 subtotal = _highestBid - minusfee;
        uint256 feesPaid;
        for (
            uint256 i = 0;
            i <
            nftContractAuctions[_nftContractAddress][_tokenId]
                .feeRecipients
                .length;
            i++
        ) {
            uint256 fee = _getPortionOfBid(
                subtotal,
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feePercentages[i]
            );
            feesPaid = feesPaid + fee;
            _payout(
                _nftContractAddress,
                _tokenId,
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feeRecipients[i],
                fee
            );
        }
        _payout(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            (subtotal - feesPaid)
        );
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).transfer(addressmarketfee, minusfee);
        } else {
            (bool success, ) = payable(addressmarketfee).call{value: minusfee}(
                ""
            );
            if (!success) {
                failedTransferCredits[addressmarketfee] =
                    failedTransferCredits[addressmarketfee] +
                    minusfee;
            }
        }
    }

    ///@dev if the call failed, update their credit balance so they the seller can pull it later
    function _payout(
        address _nftContractAddress,
        uint256 _tokenId,
        address _recipient,
        uint256 _amount
    ) internal {
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).transfer(_recipient, _amount);
        } else {
            (bool success, ) = payable(_recipient).call{value: _amount}("");
            if (!success) {
                failedTransferCredits[_recipient] =
                    failedTransferCredits[_recipient] +
                    _amount;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                      END TRANSFER NFT, PAY SELLER & MARKET        
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        SETTLE & WITHDRAW          
    //////////////////////////////////////////////////////////////*/
    function settleAuction(address _nftContractAddress, uint256 _tokenId)
        external
    {
        uint64 auctionEndTimestamp = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionEnd;
        require(
            (block.timestamp > auctionEndTimestamp),
            "Auction has not ended"
        );
        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
        emit AuctionSettled(_nftContractAddress, _tokenId, msg.sender);
    }

    ///@dev Only the owner of the NFT can prematurely close the sale or auction.
    function withdrawAuction(address _nftContractAddress, uint256 _tokenId)
        external
    {
        require(
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBidder ==
                address(0) &&
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller ==
                msg.sender,
            "cannot cancel an auction"
        );
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;
        if (lazymint) {
            _resetAuction(_nftContractAddress, _tokenId);
            _resetBids(_nftContractAddress, _tokenId);
        } else {
            if (
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this)
            ) {
                IERC721(_nftContractAddress).transferFrom(
                    address(this),
                    nftContractAuctions[_nftContractAddress][_tokenId]
                        .nftSeller,
                    _tokenId
                );
            }
            _resetAuction(_nftContractAddress, _tokenId);
            _resetBids(_nftContractAddress, _tokenId);
        }
        emit AuctionWithdrawn(_nftContractAddress, _tokenId, msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                         END  SETTLE & WITHDRAW           
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                          UPDATE AUCTION            
    //////////////////////////////////////////////////////////////*/
    function updateMinimumPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _newMinPrice
    ) external priceGreaterThanZero(_newMinPrice) {
        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only nft seller"
        );
        require(
            (nftContractAuctions[_nftContractAddress][_tokenId].minPrice != 0),
            "Not applicable a sale"
        );
        nftContractAuctions[_nftContractAddress][_tokenId]
            .minPrice = _newMinPrice;

        emit MinimumPriceUpdated(_nftContractAddress, _tokenId, _newMinPrice);
    }

    function updateBuyNowPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _newBuyNowPrice
    ) external priceGreaterThanZero(_newBuyNowPrice) {
        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only nft seller"
        );
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _newBuyNowPrice;
        emit BuyNowPriceUpdated(_nftContractAddress, _tokenId, _newBuyNowPrice);
        if (_isBuyNowPriceMet(_nftContractAddress, _tokenId)) {
            bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
                .lazymint;
            if (!lazymint) {
                _transferNftToAuctionContract(_nftContractAddress, _tokenId);
            }
            _transferNftAndPaySeller(_nftContractAddress, _tokenId);
        }
    }

    ///@notice The NFT seller can opt to end an auction by taking the current highest bid.
    function takeHighestBid(address _nftContractAddress, uint256 _tokenId)
        external
    {
        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only nft seller"
        );
        require(
            (nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid >
                0),
            "cannot payout 0 bid"
        );
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;
        if (!lazymint) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
        }
        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
        emit HighestBidTaken(_nftContractAddress, _tokenId);
    }

    ///@notice If the transfer of a bid has failed, allow the recipient to reclaim their amount later.
    function withdrawAllFailedCredits() external {
        uint256 amount = failedTransferCredits[msg.sender];

        require(amount != 0, "no credits to withdraw");

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = msg.sender.call{value: amount}("");
        require(successfulWithdraw, "withdraw failed");
    }

    /*///////////////////////////////////////////////////////////////
                        END UPDATE AUCTION         
    //////////////////////////////////////////////////////////////*/
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

abstract contract MarketEvents {
    /*///////////////////////////////////////////////////////////////
                              EVENTS            
    //////////////////////////////////////////////////////////////*/

    event NftAuctionCreated(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address erc20Token,
        uint256 minPrice,
        uint256 buyNowPrice,
        uint32 auctionBidPeriod,
        uint32 bidIncreasePercentage,
        address[] feeRecipients,
        uint32[] feePercentages,
        bool lazymint,
        string metadatauri
    );

    event SaleCreated(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address erc20Token,
        uint256 buyNowPrice,
        address[] feeRecipients,
        uint32[] feePercentages,
        bool lazymint,
        string metadatauri
    );

    event BidMade(
        address nftContractAddress,
        uint256 tokenId,
        address bidder,
        uint256 ethAmount,
        address erc20Token,
        uint256 tokenAmount
    );

    event AuctionPeriodUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint64 auctionEndPeriod
    );

    event NFTTransferredAndSellerPaid(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        uint256 nftHighestBid,
        address nftHighestBidder
    );

    event AuctionWithdrawn(
        address nftContractAddress,
        uint256 tokenId,
        address nftOwner
    );

    event MinimumPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newMinPrice
    );

    event BuyNowPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newBuyNowPrice
    );
    event HighestBidTaken(address nftContractAddress, uint256 tokenId);

    event AuctionSettled(
        address nftContractAddress,
        uint256 tokenId,
        address auctionSettler
    );

    /*///////////////////////////////////////////////////////////////
                              END EVENTS            
    //////////////////////////////////////////////////////////////*/
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

abstract contract verification {
    ///@dev Returns the percentage of the total bid (used to calculate fee payments)
    function _getPortionOfBid(uint256 _totalBid, uint256 _percentage)
        internal
        pure
        returns (uint256)
    {
        return (_totalBid * (_percentage)) / 10000;
    }

    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }

    modifier isFeePercentagesLessThanMaximum(uint32[] memory _feePercentages) {
        uint32 totalPercent;
        for (uint256 i = 0; i < _feePercentages.length; i++) {
            totalPercent = totalPercent + _feePercentages[i];
        }
        require(totalPercent <= 10000, "Fee percentages exceed maximum");
        _;
    }

    function metadata(address _nftcontract, uint256 _nftid)
        internal
        view
        returns (
            //bool _mint
            string memory
        )
    {
        //if (!_mint) {
        return IERC721Metadata(_nftcontract).tokenURI(_nftid);
        /*} else {
            return "";
        }*/
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILazyNFT {
    function redeem(
        address _redeem,
        uint256 _tokenid,
        string memory _uri
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}