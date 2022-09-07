//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MarketEvents.sol";
import "./Verification.sol";
import "./ILazymint.sol";
//import "hardhat/console.sol";

/// @title An Auction Contract for bidding and selling single and batched NFTs
/// @notice This contract can be used for auctioning any NFTs, and accepts any ERC20 token as payment
/// @author Modified from Avo Labs GmbH (https://github.com/avolabs-io/nft-auction/blob/master/contracts/NFTAuction.sol)
contract NFTMarket is MarketEvents, verification {

    struct Localvars {
        string _uri;
        address _nftContractAddress;
        uint256 _tokenId;
        address _erc20Token;
        uint256 _buyNowPrice;
        address[] _feeRecipients;
        uint32[] _feePercentages;
        address _nftSeller;
        uint256 _amount;
        address _nftHighestBidder;
        bool lazymint;
    }

    ///@notice Map each sell with the token ID
    mapping(address => mapping(uint256 => Sells)) public nftContractAuctions;
    ///@notice If transfer fail save to withdraw later
    mapping(address => uint256) public failedTransferCredits;

    ///@notice Each sell is unique to each NFT (contract + id pairing).
    ///@param ERC20Token The seller can specify an ERC20 token that can be used to bid or purchase the NFT.
    struct Sells {
        uint256 buyNowPrice;
        address nftHighestBidder;
        address nftSeller;
        address ERC20Token;
        address[] feeRecipients;
        uint32[] feePercentages;
        bool lazymint;
        string metadata;
    }

    ///@notice Default values market fee
    address payable public addressmarketfee;
    uint256 public feeMarket = 250; //Equal 2.5%

    /*///////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier isAuctionNotStartedByOwner(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        if(
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller ==
                msg.sender){
            revert ("Initiated by the owner");
        }

        if (
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
            address(0)
        ) {
            if(
                msg.sender != IERC721(_nftContractAddress).ownerOf(_tokenId)){
                 revert ("Sender doesn't own NFT");
            }
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
    function _isBuyNowPriceMet(address _nftContractAddress, uint256 _tokenId, uint256 amount)
        internal
        view
        returns (bool)
    {
        uint256 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;
        return
            buyNowPrice > 0 && amount >= buyNowPrice;
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
            address auctionERC20Token = nftContractAuctions[
                _nftContractAddress
            ][_tokenId].ERC20Token;
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
            if(
                IERC721(_nftContractAddress).ownerOf(_tokenId) != address(this)){
                revert ("nft transfer failed");
            }
        } else {
            if(
                IERC721(_nftContractAddress).ownerOf(_tokenId) != address(this)){
                revert ("Seller doesn't own NFT");
           }
        }
    }

    /*///////////////////////////////////////////////////////////////
                                END
                      TRANSFER NFTS TO CONTRACT
    //////////////////////////////////////////////////////////////*/


    /*///////////////////////////////////////////////////////////////
                              SALES
    //////////////////////////////////////////////////////////////*/
/*     function _setupSale(
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
    } */

    ///@notice Allows for a standard sale mechanism.
    ///@dev For sale the min price must be 0
    ///@dev _isABidMade check if buyNowPrice is meet and conclude sale, otherwise reverse the early bid
    function createSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice,
        address _nftSeller,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages,
        bool _lazymint,
        string memory _metadata
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_buyNowPrice)
    {
        Localvars memory vars;
       
        vars._nftContractAddress = _nftContractAddress;
        vars._tokenId = _tokenId;
        vars._erc20Token = _erc20Token;
        vars._buyNowPrice = _buyNowPrice;
        vars._feeRecipients = _feeRecipients;
        vars._feePercentages = _feePercentages;
        vars._nftSeller = _nftSeller;

        nftContractAuctions[vars._nftContractAddress][vars._tokenId].lazymint = _lazymint;
        nftContractAuctions[vars._nftContractAddress][vars._tokenId].metadata = _metadata;
        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .nftSeller = vars._nftSeller;
        if (vars._erc20Token != address(0)) {
            nftContractAuctions[vars._nftContractAddress][vars._tokenId]
                .ERC20Token = vars._erc20Token;
        }
        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .feeRecipients = vars._feeRecipients;
        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .feePercentages = vars._feePercentages;
        nftContractAuctions[vars._nftContractAddress][vars._tokenId]
            .buyNowPrice = vars._buyNowPrice;

        vars._uri;
        if (!_lazymint) {
            vars._uri = metadata(vars._nftContractAddress, vars._tokenId);
        } else {
            vars._uri = _metadata;
        }

        emit SaleCreated(
            vars._nftContractAddress,
            vars._tokenId,
            vars._nftSeller,
            vars._erc20Token,
           vars. _buyNowPrice,
           vars. _feeRecipients,
            vars._feePercentages,
            _lazymint,
            vars._uri
        );
        if (!_lazymint) {
            _transferNftToAuctionContract(vars._nftContractAddress, vars._tokenId);
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
        Localvars memory vars;
        vars._nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        if(msg.sender == vars._nftSeller){
            revert ("Owner cannot bid on own NFT");
        }
        if(
            !_isPaymentAccepted(
                _nftContractAddress,
                _tokenId,
                _erc20Token,
                _tokenAmount
            )){
            revert("Bid to be in specified ERC20/ETH");
        }
        if(_tokenAmount != 0){
            vars._amount = _tokenAmount;
        }else{
            vars._amount = msg.value;
        }
     
       // _updateSell(_nftContractAddress, _tokenId, vars._amount);
       if (_isBuyNowPriceMet(_nftContractAddress, _tokenId,vars._amount)) {
            _transferNftAndPaySeller(_nftContractAddress, _tokenId, msg.sender, vars._amount);
       }else{
            revert("amount less than buy now");
       }
        
        emit BidMade(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            msg.value,
            _erc20Token,
            _tokenAmount
        );
    }

    /*///////////////////////////////////////////////////////////////
                        END BID FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        UPDATE AUCTION
    //////////////////////////////////////////////////////////////*/

 /*    ///@notice Settle an auction or sale if the buyNowPrice is met or set
    ///@dev min price not set, nft not up for auction yet
    function _updateSell(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal {
         if (_isBuyNowPriceMet(_nftContractAddress, _tokenId,_tokenAmount)) {
                _transferNftAndPaySeller(_nftContractAddress, _tokenId);
                return;
            }
    } */

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
    function _resetSell(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        
        nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = address(0);
    }

    ///@notice Reset all bid related parameters for an NFT.
    ///@notice This effectively sets an NFT as having no active bids
   /*  function _resetBids(address _nftContractAddress, uint256 _tokenId)
        internal
    {
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = address(0);
        nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid = 0;
    } */

    /*///////////////////////////////////////////////////////////////
                        END RESET FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                    TRANSFER NFT, PAY SELLER & MARKET
    //////////////////////////////////////////////////////////////*/
    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address buyer,
        uint256 amount
    ) internal {
        Localvars memory vars;
        vars._nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        vars._nftHighestBidder = buyer;
        vars.lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;

        _payFeesAndSeller(
            _nftContractAddress,
            _tokenId,
            vars._nftSeller,
            amount
        );
        if (!vars.lazymint) {
            IERC721(_nftContractAddress).transferFrom(
                address(this),
                vars._nftHighestBidder,
                _tokenId
            );
        } else {
            //This is the lazyminting function
            ILazyNFT(_nftContractAddress).redeem(
                vars._nftHighestBidder,
                _tokenId,
                nftContractAuctions[_nftContractAddress][_tokenId].metadata
            );
        }
        _resetSell(_nftContractAddress, _tokenId);
        emit NFTTransferredAndSellerPaid(
            _nftContractAddress,
            _tokenId,
            vars._nftSeller,
            vars._nftHighestBidder
        );
    }

    function _payFeesAndSeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address _nftSeller,
        uint256 _amount
    ) internal {
        uint256 feesPaid = 0;
        uint256 minusfee = _getPortionOfBid(_amount, feeMarket);

        feesPaid = _payoutroyalties(_nftContractAddress, _tokenId, _amount);

        uint256 subtotal = minusfee + feesPaid;

        uint256 reward = _amount - subtotal;

        _payout(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            reward
        );
        sendpayment(_nftContractAddress, _tokenId, minusfee);
    }

    function sendpayment(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 minusfee
    ) internal {
        uint256 amount = minusfee;
        minusfee = 0;
        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;

        if (auctionERC20Token != address(0)) {
            IERC20(auctionERC20Token).transfer(addressmarketfee, amount);
        } else {
            (bool success, ) = payable(addressmarketfee).call{value: amount}(
                ""
            );
            if (!success) {
                failedTransferCredits[addressmarketfee] =
                    failedTransferCredits[addressmarketfee] +
                    amount;
            }
        }
    }

    function _payoutroyalties(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 subtotal
    ) internal returns (uint256) {
        uint256 feesPaid = 0;
        uint256 length = nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients
            .length;
        for (uint256 i = 0; i < length; i++) {
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
        return feesPaid;
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
                         WITHDRAW
    //////////////////////////////////////////////////////////////*/
    ///@dev Only the owner of the NFT can prematurely close the sale or auction.
    function withdrawSell(address _nftContractAddress, uint256 _tokenId)
        external
    {
        if(nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
                msg.sender){
           revert("cannot cancel an auction");
      }
        bool lazymint = nftContractAuctions[_nftContractAddress][_tokenId]
            .lazymint;
        if (lazymint) {
            _resetSell(_nftContractAddress, _tokenId);
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
            _resetSell(_nftContractAddress, _tokenId);
        }
        emit AuctionWithdrawn(_nftContractAddress, _tokenId, msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                         END  SETTLE & WITHDRAW
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                          UPDATE AUCTION
    //////////////////////////////////////////////////////////////*/
    function updateBuyNowPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _newBuyNowPrice
    ) external priceGreaterThanZero(_newBuyNowPrice) {
        if(
            msg.sender !=
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller){
            revert ("Only nft seller");
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _newBuyNowPrice;
        emit BuyNowPriceUpdated(_nftContractAddress, _tokenId, _newBuyNowPrice);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

abstract contract MarketEvents {
    /*///////////////////////////////////////////////////////////////
                              EVENTS            
    //////////////////////////////////////////////////////////////*/

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


    event NFTTransferredAndSellerPaid(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address nftHighestBidder
    );

    event AuctionWithdrawn(
        address nftContractAddress,
        uint256 tokenId,
        address nftOwner
    );

    event BuyNowPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newBuyNowPrice
    );

    event NFTTransferred(
        address nftContractAddress,
        uint256 tokenId,
        address nftHighestBidder
    );

    /*///////////////////////////////////////////////////////////////
                              END EVENTS            
    //////////////////////////////////////////////////////////////*/
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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
        if(_price <= 0) {
            revert ("Price cannot be 0");
        }
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
        return IERC721Metadata(_nftcontract).tokenURI(_nftid);
     
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