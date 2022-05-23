// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/IERC1155Mintable.sol";
import "../interfaces/IERC721Mintable.sol";
import "../interfaces/IRoleManager.sol";
import "../interfaces/IRoyalties.sol";
import "../interfaces/IMintingControl.sol";
import "../interfaces/IUltiMarketplaceV2.sol";
import "../libs/LibAsset.sol";
import "../libs/LibPermit.sol";
import "../libs/LibRole.sol";
import "../libs/LibTransfer.sol";

contract UltiMarketplaceV2 is
    EIP712Upgradeable,
    ERC1155HolderUpgradeable,
    ERC721HolderUpgradeable,
    ReentrancyGuardUpgradeable,
    IUltiMarketplaceV2
{
    using AddressUpgradeable for address;
    using ERC165CheckerUpgradeable for address;
    using LibTransfer for address payable;

    mapping(uint256 => Bid) public bids;
    mapping(uint256 => uint256) public tokensSoldFromOffer;

    mapping(address => bytes4) private _availableCurrencies;
    LibShare.Share private _marketplaceFee;
    IRoleManager private _roleManager;

    event CurrencyAdded(address indexed currencyAddress, bytes4 indexed currencyType);
    event CurrencyRemoved(address indexed currencyAddress);
    event MarketplaceFeeSet(address indexed account, uint32 value);

    modifier onlyRole(bytes32 role) {
        require(_roleManager.accountHasRole(msg.sender, role), "Invalid role");
        _;
    }

    modifier onlyAllowedMinters(address collection) {
        if (collection.supportsInterface(type(IMintingControl).interfaceId)) {
            require(
                IMintingControl(collection).isPublic() || IMintingControl(collection).isMinter(msg.sender),
                "Collection is private"
            );
        }
        _;
    }

    function initialize(
        LibShare.Share calldata fee,
        IRoleManager roleManager,
        address ultiCoin
    ) external initializer {
        __EIP712_init_unchained("Ulti Marketplace", "2.0.0");
        __ERC721Holder_init();
        __ERC1155Holder_init();
        __ReentrancyGuard_init();
        __UltiMarketplace_init_unchained(fee, roleManager, ultiCoin);
    }

    function __UltiMarketplace_init_unchained(
        LibShare.Share calldata fee,
        IRoleManager roleManager,
        address ultiCoin
    ) internal onlyInitializing {
        _marketplaceFee = fee;
        _roleManager = roleManager;
        _addCurrency(address(0), LibAsset.ASSET_TYPE_NATIVE);
        _addCurrency(ultiCoin, LibAsset.ASSET_TYPE_ERC20);
    }

    function getMarketplaceFeeShare() external view returns (uint32) {
        return _marketplaceFee.value;
    }

    function setMarketplaceFee(LibShare.Share calldata fee) external onlyRole(LibRole.ADMIN_ROLE) {
        _marketplaceFee = fee;
        emit MarketplaceFeeSet(fee.account, fee.value);
    }

    function setRoleManager(IRoleManager roleManager) external onlyRole(LibRole.DEFAULT_ADMIN_ROLE) {
        _roleManager = roleManager;
    }

    function addCurrency(address currencyAddress, bytes4 currencyType) external onlyRole(LibRole.ADMIN_ROLE) {
        require(_availableCurrencies[currencyAddress] == 0, "Currency already exists");
        _addCurrency(currencyAddress, currencyType);
        emit CurrencyAdded(currencyAddress, currencyType);
    }

    function removeCurrency(address currencyAddress) external onlyRole(LibRole.ADMIN_ROLE) {
        require(_availableCurrencies[currencyAddress] != 0, "Currency does not exist");
        _removeCurrency(currencyAddress);
        emit CurrencyRemoved(currencyAddress);
    }

    function mint(
        address collection,
        bytes4 tokenType,
        MintDataBatch memory data,
        address recipient
    ) external onlyAllowedMinters(collection) {
        if (data.tokenIds.length == 1) {
            _mintSingle(collection, tokenType, _MintDataSingle(data), data.supplies[0], recipient);
        } else if (data.tokenIds.length > 1) {
            _mintBatch(collection, tokenType, data, data.supplies, recipient);
        } else {
            revert("Invalid parameters length");
        }
    }

    function buyFromOffer(
        LibOfferPermit.MintPermit calldata permit,
        bytes calldata signature,
        uint256 tokenQuantity
    ) external payable nonReentrant {
        LibOffer.Offer memory offer = permit.offer;

        uint256 tokensSold = tokensSoldFromOffer[offer.id];

        require(tokensSold < offer.quantity, "Offer already closed or cancelled");
        _validateBuyFromOffer(offer, tokenQuantity, msg.sender);
        _validateSignature(_hashTypedDataV4(LibOfferPermit.hash(permit)), signature);

        tokensSoldFromOffer[offer.id] = tokensSold + tokenQuantity;
        _buyFromOffer(permit, tokenQuantity, msg.sender);

        emit OfferSold(offer.id, tokenQuantity, offer.price, msg.sender);
    }

    function cancelOffer(LibOffer.Offer calldata offer, bytes calldata signature) external nonReentrant {
        uint256 tokensSold = tokensSoldFromOffer[offer.id];

        require(!offer.lazy, "Offer is lazy");
        require(tokensSold < offer.quantity, "Offer already closed or cancelled");
        require(msg.sender == offer.seller, "Offer cancellation query by unauthorized entity");
        _validateSignature(_hashTypedDataV4(LibOffer.hash(offer)), signature);

        uint256 cashback = offer.quantity - tokensSold;
        tokensSoldFromOffer[offer.id] = offer.quantity;
        _transferFrom(address(this), offer.seller, offer.collection, offer.tokenType, offer.tokenId, cashback);

        emit OfferCancelled(offer.id, msg.sender);
    }

    function bidAuction(
        LibAuctionPermit.MintPermit calldata permit,
        bytes calldata signature,
        uint256 amount
    ) external payable nonReentrant {
        LibAuction.Auction memory auction = permit.auction;

        _validateBid(auction, amount, msg.sender);
        _validateSignature(_hashTypedDataV4(LibAuctionPermit.hash(permit)), signature);

        if (auction.buyNowPrice > 0 && amount == auction.buyNowPrice) {
            _buyFromAuction(permit, msg.sender);
            emit AuctionSold(auction.id, amount, msg.sender);
        } else {
            _placeBid(auction.id, amount, auction.currency, msg.sender);
            emit AuctionBidPlaced(auction.id, amount, msg.sender);
        }
    }

    function buyFromAuction(LibAuctionPermit.MintPermit calldata permit, bytes calldata signature)
        external
        payable
        nonReentrant
    {
        _validateBuyFromAuction(permit.auction, msg.sender);
        _validateSignature(_hashTypedDataV4(LibAuctionPermit.hash(permit)), signature);

        _buyFromAuction(permit, msg.sender);

        emit AuctionSold(permit.auction.id, permit.auction.buyNowPrice, msg.sender);
    }

    function settleAuction(LibAuctionPermit.MintPermit calldata permit, bytes calldata signature) external {
        LibAuction.Auction memory auction = permit.auction;

        require(tokensSoldFromOffer[auction.id] == 0, "Offer already closed or cancelled");
        require(block.timestamp >= auction.endTime, "Auction settlement query before it is ended");
        _validateSignature(_hashTypedDataV4(LibAuctionPermit.hash(permit)), signature);

        tokensSoldFromOffer[auction.id] = 1;

        Bid storage bid = bids[auction.id];
        address payable tokenRecipient;
        uint256 bidValue = bid.highestBid;

        if (bid.highestBidder != address(0)) {
            tokenRecipient = bid.highestBidder;
            _transferWithFees(auction.seller, bidValue, auction.currency, auction.collection, auction.tokenId);
        } else {
            tokenRecipient = auction.seller;
        }

        if (auction.lazy) {
            LibLazyMint.MintData memory token = permit.token;
            _mintSingle(
                auction.collection,
                auction.tokenType,
                MintDataSingle(auction.tokenId, token.supply, token.tokenURI, token.creators, token.royalties),
                1,
                msg.sender
            );
        } else {
            _transferFrom(address(this), tokenRecipient, auction.collection, auction.tokenType, auction.tokenId, 1);
        }

        emit AuctionSettled(auction.id, bidValue, msg.sender, tokenRecipient);
    }

    function cancelAuction(LibAuction.Auction calldata auction, bytes calldata signature) external {
        require(!auction.lazy, "Auction is lazy");
        require(tokensSoldFromOffer[auction.id] == 0, "Offer already closed or cancelled");
        require(msg.sender == auction.seller, "Auction cancellation query by unauthorized entity");
        require(
            block.timestamp >= auction.endTime || bids[auction.id].highestBidder == address(0),
            "Auction cancellation query after bid placed"
        );
        _validateSignature(_hashTypedDataV4(LibAuction.hash(auction)), signature);

        tokensSoldFromOffer[auction.id] = 1;
        _transferFrom(address(this), auction.seller, auction.collection, auction.tokenType, auction.tokenId, 1);

        emit AuctionCancelled(auction.id, msg.sender);
    }

    function _mintSingle(
        address collection,
        bytes4 tokenType,
        MintDataSingle memory data,
        uint256 quantity,
        address recipient
    ) private {
        if (tokenType == LibAsset.ASSET_TYPE_ERC721) {
            IERC721Mintable(collection).mint(
                LibERC721Mint.MintData(data.tokenId, data.tokenURI, data.creators, data.royalties),
                recipient
            );
        } else if (tokenType == LibAsset.ASSET_TYPE_ERC1155) {
            IERC1155Mintable(collection).mint(
                LibERC1155Mint.MintData(data.tokenId, data.supply, data.tokenURI, data.creators, data.royalties),
                recipient,
                quantity
            );
        } else {
            revert("Unknown token type");
        }
    }

    function _mintBatch(
        address collection,
        bytes4 tokenType,
        MintDataBatch memory data,
        uint256[] memory quantities,
        address recipient
    ) private {
        if (tokenType == LibAsset.ASSET_TYPE_ERC1155) {
            IERC1155Mintable(collection).mintBatch(
                LibERC1155Mint.MintDataBatch(
                    data.tokenIds,
                    data.supplies,
                    data.tokenURIs,
                    data.creators,
                    data.royalties
                ),
                recipient,
                quantities
            );
        } else {
            revert("Token type does not support batch minting");
        }
    }

    function _MintDataSingle(MintDataBatch memory data) private pure returns (MintDataSingle memory) {
        return
            MintDataSingle(data.tokenIds[0], data.supplies[0], data.tokenURIs[0], data.creators[0], data.royalties[0]);
    }

    function _placeBid(
        uint256 auctionId,
        uint256 amount,
        address currency,
        address bidder
    ) private {
        Bid storage bid = bids[auctionId];
        _receiveFromSender(amount, currency, bidder);
        _payOffLastBidder(bid.highestBidder, bid.highestBid, currency);
        bid.highestBid = amount;
        bid.highestBidder = payable(bidder);
    }

    function _buyFromAuction(LibAuctionPermit.MintPermit calldata permit, address sender) private {
        LibAuction.Auction memory auction = permit.auction;

        tokensSoldFromOffer[permit.auction.id] = 1;

        Bid storage bid = bids[auction.id];
        _payOffLastBidder(bid.highestBidder, bid.highestBid, auction.currency);
        _transferFromWithFees(
            sender,
            auction.seller,
            auction.buyNowPrice,
            auction.currency,
            auction.collection,
            auction.tokenId
        );

        if (auction.lazy) {
            LibLazyMint.MintData memory token = permit.token;
            _mintSingle(
                auction.collection,
                auction.tokenType,
                MintDataSingle(auction.tokenId, token.supply, token.tokenURI, token.creators, token.royalties),
                1,
                sender
            );
        } else {
            _transferFrom(address(this), payable(sender), auction.collection, auction.tokenType, auction.tokenId, 1);
        }
    }

    function _buyFromOffer(
        LibOfferPermit.MintPermit calldata permit,
        uint256 tokenQuantity,
        address sender
    ) private {
        LibOffer.Offer memory offer = permit.offer;

        uint256 totalPrice = tokenQuantity * offer.price;

        bytes4 currencyType = _availableCurrencies[permit.offer.currency];
        if (currencyType == LibAsset.ASSET_TYPE_NATIVE) {
            _transferWithFees(offer.seller, totalPrice, offer.currency, offer.collection, offer.tokenId);
        } else if (currencyType == LibAsset.ASSET_TYPE_ERC20) {
            _transferFromWithFees(sender, offer.seller, totalPrice, offer.currency, offer.collection, offer.tokenId);
        }

        if (offer.lazy) {
            LibLazyMint.MintData memory token = permit.token;
            _mintSingle(
                offer.collection,
                offer.tokenType,
                MintDataSingle(offer.tokenId, token.supply, token.tokenURI, token.creators, token.royalties),
                tokenQuantity,
                sender
            );
        } else {
            _transferFrom(
                address(this),
                payable(msg.sender),
                offer.collection,
                offer.tokenType,
                offer.tokenId,
                tokenQuantity
            );
        }
    }

    function _validateSignature(bytes32 hash, bytes calldata signature) private view {
        address signer = ECDSAUpgradeable.recover(hash, signature);
        require(_roleManager.accountHasRole(signer, LibRole.MARKETPLACE_REQUEST_SIGNER_ROLE), "Invalid signature");
    }

    function _validateBid(
        LibAuction.Auction memory auction,
        uint256 amount,
        address sender
    ) private view {
        require(tokensSoldFromOffer[auction.id] == 0, "Offer already closed or cancelled");
        require(sender != auction.seller, "Bid caller is a token owner");
        require(block.timestamp >= auction.startTime, "Bid query before auction started");
        require(block.timestamp < auction.endTime, "Bid query after auction ended");
        if (_availableCurrencies[auction.currency] == LibAsset.ASSET_TYPE_NATIVE) {
            require(amount == msg.value, "Bid query with incorrect native funds sent");
        }
        require(amount > auction.startPrice && amount > bids[auction.id].highestBid, "Bid is too low");
        if (auction.buyNowPrice > 0) {
            require(amount <= auction.buyNowPrice, "Bid amount is greater than buy now price");
        }
    }

    function _validateBuyFromAuction(LibAuction.Auction memory auction, address sender) private view {
        require(tokensSoldFromOffer[auction.id] == 0, "Offer already closed or cancelled");
        require(sender != auction.seller, "Buy now caller is a token owner");
        require(auction.buyNowPrice != 0, "Buy now not available for auction");
        if (_availableCurrencies[auction.currency] == LibAsset.ASSET_TYPE_NATIVE) {
            require(auction.buyNowPrice == msg.value, "Buy query with incorrect native funds sent");
        }
        require(block.timestamp >= auction.startTime, "Buy now query before auction started");
        require(block.timestamp < auction.endTime, "Buy now query after auction expired");
    }

    function _validateBuyFromOffer(
        LibOffer.Offer memory offer,
        uint256 tokenQuantity,
        address purchaser
    ) private view {
        require(purchaser != offer.seller, "Buy caller is a token owner");
        require(
            tokenQuantity > 0 && tokensSoldFromOffer[offer.id] + tokenQuantity <= offer.quantity,
            "Insufficient number of tokens available in offer"
        );
        if (_availableCurrencies[offer.currency] == LibAsset.ASSET_TYPE_NATIVE) {
            require(tokenQuantity * offer.price == msg.value, "Buy query with incorrect native funds sent");
        }
        require(block.timestamp >= offer.startTime, "Buy query before offer started");
        if (offer.endTime > 0) {
            require(block.timestamp < offer.endTime, "Buy query after offer expired");
        }
    }

    function _addCurrency(address currencyAddress, bytes4 currencyType) private {
        _availableCurrencies[currencyAddress] = currencyType;
    }

    function _removeCurrency(address currencyAddress) private {
        _availableCurrencies[currencyAddress] = 0;
    }

    function _transfer(
        address payable recipient,
        uint256 value,
        address currency
    ) private {
        bytes4 currencyType = _availableCurrencies[currency];
        if (currencyType == LibAsset.ASSET_TYPE_NATIVE) {
            recipient.transferNative(value);
        } else if (currencyType == LibAsset.ASSET_TYPE_ERC20) {
            recipient.transferERC20(value, IERC20Upgradeable(currency));
        } else {
            revert("Currency type transfer not supported");
        }
    }

    function _transferFrom(
        address from,
        address payable to,
        address tokenAddress,
        bytes4 tokenType,
        uint256 tokenId,
        uint256 quantity
    ) private {
        if (tokenType == LibAsset.ASSET_TYPE_ERC20) {
            to.transferFromERC20(from, quantity, IERC20Upgradeable(tokenAddress));
        } else if (tokenType == LibAsset.ASSET_TYPE_ERC721) {
            to.transferFromERC721(from, tokenId, IERC721Upgradeable(tokenAddress));
        } else if (tokenType == LibAsset.ASSET_TYPE_ERC1155) {
            to.transferFromERC1155(from, tokenId, quantity, IERC1155Upgradeable(tokenAddress));
        } else {
            revert("Token type transfer not supported");
        }
    }

    function _receiveFromSender(
        uint256 amount,
        address currency,
        address sender
    ) private {
        if (_availableCurrencies[currency] == LibAsset.ASSET_TYPE_ERC20) {
            IERC20Upgradeable(currency).transferFrom(sender, address(this), amount);
        }
    }

    function _payOffLastBidder(
        address payable highestBidder,
        uint256 highestBid,
        address currency
    ) private {
        if (highestBid > 0 && highestBidder != address(0)) {
            _transfer(highestBidder, highestBid, currency);
        }
    }

    function _transferMarketplaceFee(uint256 totalAmount, address currency) private returns (uint256) {
        uint256 fee = (totalAmount * _marketplaceFee.value) / LibShare.SHARE_DIVISOR;
        _transfer(payable(_marketplaceFee.account), fee, currency);
        return fee;
    }

    function _transferRoyalties(
        address collection,
        uint256 tokenId,
        uint256 totalAmount,
        address currency
    ) private returns (uint256) {
        uint256 transferred = 0;

        if (collection.supportsInterface(type(IRoyalties).interfaceId)) {
            LibShare.Share[] memory royalties = IRoyalties(collection).getRoyalties(tokenId);
            for (uint256 i = 0; i < royalties.length; i++) {
                uint256 value = (totalAmount * royalties[i].value) / LibShare.SHARE_DIVISOR;
                _transfer(payable(royalties[i].account), value, currency);
                transferred += value;
            }
        }
        return transferred;
    }

    function _transferWithFees(
        address payable recipient,
        uint256 totalAmount,
        address currency,
        address collection,
        uint256 tokenId
    ) private {
        uint256 transferred = _transferMarketplaceFee(totalAmount, currency);
        transferred += _transferRoyalties(collection, tokenId, totalAmount, currency);
        _transfer(recipient, totalAmount - transferred, currency);
    }

    function _transferFromWithFees(
        address from,
        address payable to,
        uint256 totalAmount,
        address currency,
        address collection,
        uint256 tokenId
    ) private {
        bytes4 currencyType = _availableCurrencies[currency];

        uint256 fee = (totalAmount * _marketplaceFee.value) / LibShare.SHARE_DIVISOR;
        _transferFrom(from, payable(_marketplaceFee.account), currency, currencyType, 0, fee);

        uint256 transferred = fee;
        if (collection.supportsInterface(type(IRoyalties).interfaceId)) {
            LibShare.Share[] memory royalties = IRoyalties(collection).getRoyalties(tokenId);
            for (uint256 i = 0; i < royalties.length; i++) {
                uint256 value = (totalAmount * royalties[i].value) / LibShare.SHARE_DIVISOR;
                _transferFrom(from, payable(royalties[i].account), currency, currencyType, 0, value);
                transferred += value;
            }
        }

        _transferFrom(from, to, currency, currencyType, 0, totalAmount - transferred);
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165CheckerUpgradeable {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165Upgradeable).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165Upgradeable.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/LibERC1155Mint.sol";

interface IERC1155Mintable {
    function mint(
        LibERC1155Mint.MintData calldata data,
        address to,
        uint256 amount
    ) external;

    function mintBatch(
        LibERC1155Mint.MintDataBatch calldata data,
        address to,
        uint256[] calldata amounts
    ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/LibERC721Mint.sol";

interface IERC721Mintable {
    function mint(LibERC721Mint.MintData calldata data, address to) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IRoleManager {
    function accountHasRole(address account, bytes32 role) external view returns (bool);

    function isAdmin(address account) external view returns (bool);

    function isMinterAdmin(address account) external view returns (bool);

    function isMinter(address account) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/LibShare.sol";

interface IRoyalties {
    function getRoyalties(uint256 tokenId) external view returns (LibShare.Share[] memory);

    function transferRoyaltyShare(
        uint256 tokenId,
        address from,
        address to
    ) external;

    function royaltiesInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address[] memory, uint256[] memory);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IMintingControl {
    function isPublic() external returns (bool);

    function isMinter(address account) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/LibPermit.sol";

interface IUltiMarketplaceV2 {
    struct Bid {
        uint256 highestBid;
        address payable highestBidder;
    }

    struct MintDataSingle {
        uint256 tokenId;
        uint256 supply;
        string tokenURI;
        LibShare.Share[] creators;
        LibShare.Share[] royalties;
    }

    struct MintDataBatch {
        uint256[] tokenIds;
        uint256[] supplies;
        string[] tokenURIs;
        LibShare.Share[][] creators;
        LibShare.Share[][] royalties;
    }

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed collection,
        uint256 indexed tokenId,
        uint256 quantity
    );
    event AuctionBidPlaced(uint256 indexed auctionId, uint256 bidAmount, address indexed bidder);
    event AuctionCancelled(uint256 indexed auctionId, address caller);
    event AuctionSettled(uint256 indexed auctionId, uint256 price, address caller, address indexed recipient);
    event AuctionSold(uint256 indexed auctionId, uint256 price, address indexed purchaser);

    event OfferCancelled(uint256 indexed offerId, address indexed caller);
    event OfferSold(uint256 indexed offerId, uint256 indexed quantity, uint256 price, address indexed purchaser);

    function mint(
        address collection,
        bytes4 tokenType,
        MintDataBatch calldata data,
        address recipient
    ) external;

    function buyFromOffer(
        LibOfferPermit.MintPermit calldata permit,
        bytes calldata signature,
        uint256 tokenQuantity
    ) external payable;

    function cancelOffer(LibOffer.Offer calldata offer, bytes calldata signature) external;

    function bidAuction(
        LibAuctionPermit.MintPermit calldata permit,
        bytes calldata signature,
        uint256 amount
    ) external payable;

    function buyFromAuction(LibAuctionPermit.MintPermit calldata permit, bytes calldata signature) external payable;

    function settleAuction(LibAuctionPermit.MintPermit calldata permit, bytes calldata signature) external;

    function cancelAuction(LibAuction.Auction calldata auction, bytes calldata signature) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LibAsset {
    bytes4 public constant ASSET_TYPE_NATIVE = bytes4(keccak256("ASSET_TYPE_NATIVE")); // 0x43be5ee6
    bytes4 public constant ASSET_TYPE_ERC20 = bytes4(keccak256("ASSET_TYPE_ERC20")); // 0x2f001e83
    bytes4 public constant ASSET_TYPE_ERC721 = bytes4(keccak256("ASSET_TYPE_ERC721")); // 0x4dd331f6
    bytes4 public constant ASSET_TYPE_ERC1155 = bytes4(keccak256("ASSET_TYPE_ERC1155")); // 0xf7453a31
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./LibAuction.sol";
import "./LibLazyMint.sol";
import "./LibOffer.sol";

library LibOfferPermit {
    struct MintPermit {
        LibOffer.Offer offer;
        LibLazyMint.MintData token;
    }

    bytes32 public constant MINT_PERMIT_TYPE_HASH =
        keccak256(
            "MintPermit(Offer offer,MintData token)MintData(string tokenURI,uint256 supply,Share[] creators,Share[] royalties)Offer(uint256 id,bool lazy,address seller,address collection,bytes4 tokenType,uint256 tokenId,uint256 quantity,uint256 price,address currency,uint48 startTime,uint48 endTime)Share(address account,uint32 value)"
        );

    function hash(MintPermit calldata permit) internal pure returns (bytes32) {
        return
            keccak256(abi.encode(MINT_PERMIT_TYPE_HASH, LibOffer.hash(permit.offer), LibLazyMint.hash(permit.token)));
    }
}

library LibAuctionPermit {
    struct MintPermit {
        LibAuction.Auction auction;
        LibLazyMint.MintData token;
    }

    bytes32 public constant MINT_PERMIT_TYPE_HASH =
        keccak256(
            "MintPermit(Auction auction,MintData token)Auction(uint256 id,bool lazy,address seller,address collection,bytes4 tokenType,uint256 tokenId,uint256 startPrice,uint256 buyNowPrice,address currency,uint48 startTime,uint48 endTime)MintData(string tokenURI,uint256 supply,Share[] creators,Share[] royalties)Share(address account,uint32 value)"
        );

    function hash(MintPermit calldata permit) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(MINT_PERMIT_TYPE_HASH, LibAuction.hash(permit.auction), LibLazyMint.hash(permit.token))
            );
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LibRole {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); // 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775

    bytes32 public constant MINTER_ADMIN_ROLE = keccak256("MINTER_ADMIN_ROLE"); // 0x70480ee89cb38eff00b7d23da25713d52ce19c6ed428691d22c58b2f615e3d67
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6

    bytes32 public constant MARKETPLACE_REQUEST_SIGNER_ROLE = keccak256("MARKETPLACE_REQUEST_SIGNER_ROLE"); // 0x125b900e37891c186e6ad4e5ecd29690b91102d9b84806aa5ee2ef7dd1f03367
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

library LibTransfer {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function transferNative(address payable recipient, uint256 amount) internal {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "BNB transfer failed");
    }

    function transferERC20(
        address payable recipient,
        uint256 amount,
        IERC20Upgradeable erc20Token
    ) internal {
        erc20Token.safeTransfer(recipient, amount);
    }

    function transferFromERC20(
        address payable recipient,
        address from,
        uint256 amount,
        IERC20Upgradeable erc20Token
    ) internal {
        erc20Token.safeTransferFrom(from, recipient, amount);
    }

    function transferFromERC721(
        address payable recipient,
        address from,
        uint256 tokenId,
        IERC721Upgradeable erc721Token
    ) internal {
        erc721Token.safeTransferFrom(from, recipient, tokenId);
    }

    function transferFromERC1155(
        address payable recipient,
        address from,
        uint256 tokenId,
        uint256 amount,
        IERC1155Upgradeable erc1155Token
    ) internal {
        erc1155Token.safeTransferFrom(from, recipient, tokenId, amount, "");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./LibShare.sol";

library LibERC1155Mint {
    struct MintData {
        uint256 tokenId;
        uint256 supply;
        string tokenURI;
        LibShare.Share[] creators;
        LibShare.Share[] royalties;
    }

    struct MintDataBatch {
        uint256[] tokenIds;
        uint256[] supplies;
        string[] tokenURIs;
        LibShare.Share[][] creators;
        LibShare.Share[][] royalties;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LibShare {
    uint32 public constant SHARE_DIVISOR = 10000;

    struct Share {
        address account;
        uint32 value;
    }

    bytes32 public constant SHARE_TYPE_HASH = keccak256("Share(address account,uint32 value)");

    function hash(Share calldata share) internal pure returns (bytes32) {
        return keccak256(abi.encode(SHARE_TYPE_HASH, share.account, share.value));
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./LibShare.sol";

library LibERC721Mint {
    struct MintData {
        uint256 tokenId;
        string tokenURI;
        LibShare.Share[] creators;
        LibShare.Share[] royalties;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LibAuction {
    struct Auction {
        uint256 id;
        bool lazy;
        address payable seller;
        address collection;
        bytes4 tokenType;
        uint256 tokenId;
        uint256 startPrice;
        uint256 buyNowPrice;
        address currency;
        uint48 startTime;
        uint48 endTime;
    }

    bytes32 public constant AUCTION_TYPE_HASH =
        keccak256(
            "Auction(uint256 id,bool lazy,address seller,address collection,bytes4 tokenType,uint256 tokenId,uint256 startPrice,uint256 buyNowPrice,address currency,uint48 startTime,uint48 endTime)"
        );

    function hash(Auction calldata data) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    AUCTION_TYPE_HASH,
                    data.id,
                    data.lazy,
                    data.seller,
                    data.collection,
                    data.tokenType,
                    data.tokenId,
                    data.startPrice,
                    data.buyNowPrice,
                    data.currency,
                    data.startTime,
                    data.endTime
                )
            );
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./LibShare.sol";

library LibLazyMint {
    struct MintData {
        string tokenURI;
        uint256 supply;
        LibShare.Share[] creators;
        LibShare.Share[] royalties;
    }

    bytes32 public constant LAZY_MINT_DATA_TYPE_HASH =
        keccak256(
            "MintData(string tokenURI,uint256 supply,Share[] creators,Share[] royalties)Share(address account,uint32 value)"
        );

    function hash(MintData calldata data) internal pure returns (bytes32) {
        bytes32[] memory creatorsHashes = new bytes32[](data.creators.length);
        for (uint256 i = 0; i < data.creators.length; i++) {
            creatorsHashes[i] = LibShare.hash(data.creators[i]);
        }
        bytes32[] memory royaltiesHashes = new bytes32[](data.royalties.length);
        for (uint256 i = 0; i < data.royalties.length; i++) {
            royaltiesHashes[i] = LibShare.hash(data.royalties[i]);
        }
        return
            keccak256(
                abi.encode(
                    LAZY_MINT_DATA_TYPE_HASH,
                    keccak256(bytes(data.tokenURI)),
                    data.supply,
                    keccak256(abi.encodePacked(creatorsHashes)),
                    keccak256(abi.encodePacked(royaltiesHashes))
                )
            );
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LibOffer {
    struct Offer {
        uint256 id;
        bool lazy;
        address payable seller;
        address collection;
        bytes4 tokenType;
        uint256 tokenId;
        uint256 quantity;
        uint256 price;
        address currency;
        uint48 startTime;
        uint48 endTime;
    }

    bytes32 public constant OFFER_TYPE_HASH =
        keccak256(
            "Offer(uint256 id,bool lazy,address seller,address collection,bytes4 tokenType,uint256 tokenId,uint256 quantity,uint256 price,address currency,uint48 startTime,uint48 endTime)"
        );

    function hash(Offer calldata data) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    OFFER_TYPE_HASH,
                    data.id,
                    data.lazy,
                    data.seller,
                    data.collection,
                    data.tokenType,
                    data.tokenId,
                    data.quantity,
                    data.price,
                    data.currency,
                    data.startTime,
                    data.endTime
                )
            );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}