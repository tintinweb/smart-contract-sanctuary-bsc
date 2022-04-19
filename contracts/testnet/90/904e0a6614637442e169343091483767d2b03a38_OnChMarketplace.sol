// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./IOnChEternalStorage.sol";
import "./IOnChRoyaltyOrchestrator.sol";
//import "hardhat/console.sol";


library SaleKindInterface {
    enum NFTKind {ERC721, ERC1155}
    enum SaleKind {FixedPrice, EnglishAuction}
    enum SellOrderStatus {Active, Completed, Cancelled}
}

contract OnChMarketplace is ReentrancyGuardUpgradeable, PausableUpgradeable {
    using SafeMath for uint256;

    bool internal _initialized;

    IOnChEternalStorage EternalStorage;
    IOnChRoyaltyOrchestrator RoyaltyOrchestrator;


    function initialize(address eternalStorageAddress, address royaltyOrchestratorAddress) public {
        _initialized = true;
        EternalStorage = IOnChEternalStorage(eternalStorageAddress);
        RoyaltyOrchestrator = IOnChRoyaltyOrchestrator(royaltyOrchestratorAddress);
    }

    //TODO: Investigate struct in struct
    //TODO: HER price discount
    //TODO: Auction starting price

    struct SellOrder {
        address contractAddress;
        uint256 tokenId;
        address seller;
        address buyer;
        address paymentToken;
        uint256 price;
        uint256 nftHighestBid;
        address nftHighestBidder;
        uint listingTime;
        uint expirationTime;
        uint amount;
        SaleKindInterface.SaleKind saleKind;
        SaleKindInterface.NFTKind nftKind;
        SaleKindInterface.SellOrderStatus status;
    }

    // Events
    event SellOrderCreated(
        address nftContractAddress,
        uint256 tokenId,
        address seller,
        address paymentToken,
        uint256 price,
        SaleKindInterface.SaleKind saleKind,
        uint listingTime,
        uint expirationTime,
        uint amount,
        bytes32 orderHash
    );

    event SellOrderCancelled(
        address nftContractAddress,
        uint256 tokenId,
        address seller,
        bytes32 orderHash
    );

    event SellOrderCompleted(
        address nftContractAddress,
        uint256 tokenId,
        address seller,
        address buyer,
        address paymentToken,
        uint256 price,
        uint amount,
        SaleKindInterface.SaleKind saleKind,
        bytes32 orderHash
    );

    event HighestBidderUpdated(
        address nftContractAddress,
        uint256 tokenId,
        address seller,
        address newHighestBidderAddress,
        address previousHighestBidderAddress,
        uint256 currentPrice
    );

    event AuctionPeriodUpdated(
        address nftContractAddress,
        address seller,
        uint256 tokenId,
        uint expirationTime
    );

    /*╔═════════════════════════════╗
      ║          MODIFIERS          ║
      ╚═════════════════════════════╝*/

    modifier notZeroAddress(address _address) {
        require(_address != address(0), "Cannot specify 0 address");
        _;
    }

    modifier notOwnItem(address _address) {
        require(_address != msg.sender, "OnCh: Cannot buy your own item");
        _;
    }

    modifier isMarketplaceApproved(address _nftContractAddress) {
        require(
            IERC1155(_nftContractAddress).isApprovedForAll(msg.sender, address(this)),
            "OnCh: Marketplace not approved to perform operations on your behalf"
        );
        _;
    }

    /*╔══════════════════════════════╗
      ║    AUCTION CHECK FUNCTIONS   ║
      ╚══════════════════════════════╝*/


    function _isOwnerOfNft(address _addressToCheck, address _nftContractAddress, uint256 _tokenId) internal
    view
    returns (bool)  {
        return IERC721(_nftContractAddress).ownerOf(_tokenId) == _addressToCheck;
    }

    function _getNftBalance(address _addressToCheck, address _nftContractAddress, uint256 _tokenId) internal
    view
    returns (uint256) {
        return IERC1155(_nftContractAddress).balanceOf(_addressToCheck, _tokenId);
    }

    function _isAuctionOngoing(uint256 expirationTime)
    internal
    view
    returns (bool)
    {
        return (expirationTime == 0 ||
        block.timestamp < expirationTime);
    }

    /**
    Generic entry point for creating a new order
    Order can be of either ERC721 or ERC1155
    SaleKind can be FixedPrice or DutchAuction
    */
    function createSellOrder(
        address contractAddress,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        address paymentToken,
        uint expirationTime,
        SaleKindInterface.SaleKind saleKind,
        SaleKindInterface.NFTKind nftKind
    ) public payable nonReentrant whenNotPaused isMarketplaceApproved(contractAddress) returns (bool) {
        SellOrder memory existingMarketItem = _retrieveOrder(contractAddress, tokenId, msg.sender);

        require(existingMarketItem.contractAddress == address(0), 'OnCh: Market item already existing');
        require(amount >= 1, "OnCh: Amount cannot be lower than 1");

        if (nftKind == SaleKindInterface.NFTKind.ERC721) {
            // Inside ERC721 logic
            require(amount == 1, "OnCh: Amount must be exactly 1 for ERC721");
            require(_isOwnerOfNft(msg.sender, contractAddress, tokenId), "OnCh: You are not the owner of this NFT");
        } else if (nftKind == SaleKindInterface.NFTKind.ERC1155) {
            // Inside ERC1155 logic
            require(saleKind == SaleKindInterface.SaleKind.FixedPrice, "OnCh: Currently not supporting Auctions for ERC1155");
            require(_getNftBalance(msg.sender, contractAddress, tokenId) >= amount, "OnCh: You don't have enough balance from NFT");
        } else {
            revert('OnCh: Unknown NFT Type');
        }

        if (saleKind == SaleKindInterface.SaleKind.FixedPrice) {
            require(price > 0, "OnCh: Price must be at least 1 wei");
        } else if (saleKind == SaleKindInterface.SaleKind.EnglishAuction) {
            require(_isAuctionOngoing(expirationTime), "OnCh: Expiration time can either be 0 or in the future");
        } else {
            revert('OnCh: Unknown sale type');
        }

        SellOrder memory marketItem = SellOrder(
            contractAddress,
            tokenId,
            msg.sender,
            address(0),
            paymentToken,
            price,
            0,
            address(0),
            block.timestamp,
            expirationTime,
            amount,
            saleKind,
            nftKind,
            SaleKindInterface.SellOrderStatus.Active
        );

        _createSellOrder(marketItem);

        return true;
    }

    function cancelSellOrder(
        address contractAddress,
        uint256 tokenId) notZeroAddress(contractAddress) nonReentrant whenNotPaused payable public returns (bool) {
        SellOrder memory marketItem = _retrieveOrder(contractAddress, tokenId, msg.sender);
        bytes32 orderHash = _computeOrderHashId(contractAddress, tokenId, msg.sender);

        require(marketItem.contractAddress != address(0), 'OnCh: Market item not found');
        require(marketItem.status == SaleKindInterface.SellOrderStatus.Active, 'OnCh: Can only cancel an active order');

        _updateOrderStatus(contractAddress, tokenId, msg.sender, SaleKindInterface.SellOrderStatus.Cancelled, address(0));

        emit SellOrderCancelled(
            contractAddress,
            tokenId,
            msg.sender,
            orderHash
        );
        return true;
    }

    function createBuyOrder(address contractAddress,
        uint256 tokenId,
        address sellerAddress,
        uint256 price,
        uint256 amount,
        address paymentToken) notOwnItem(sellerAddress) notZeroAddress(contractAddress) nonReentrant whenNotPaused payable public returns (bool) {
        SellOrder memory sellOrder = _retrieveOrder(contractAddress, tokenId, sellerAddress);

        require(sellOrder.contractAddress != address(0), 'OnCh: Market item not found');
        require(sellOrder.status == SaleKindInterface.SellOrderStatus.Active, 'OnCh: Order is not active');
        require(paymentToken == sellOrder.paymentToken, 'OnCh: Invalid token');


        if (sellOrder.nftKind == SaleKindInterface.NFTKind.ERC721) {
            require(_isOwnerOfNft(sellOrder.seller, sellOrder.contractAddress, sellOrder.tokenId), "OnCh: Seller doesn't own the NFT anymore");
            require(amount == 1, 'OnCh: Amount must be 1 for ERC721');
        }

        // Inside ERC1155 logic
        if (sellOrder.nftKind == SaleKindInterface.NFTKind.ERC1155) {
            require(_getNftBalance(sellOrder.seller, sellOrder.contractAddress, sellOrder.tokenId) >= amount, "OnCh: Seller don't have enough balance from NFT");
        }

        if (paymentToken != address(0)) {
            require(IERC20(paymentToken).allowance(msg.sender, address(this)) > price, 'OnCh: Marketplace is not authorized to spend the amount on your behalf');
            require(IERC20(paymentToken).balanceOf(msg.sender) > price, 'OnCh: Not enough ERC20 balance to purchase this item');

        } else {
            require(msg.value == price, 'OnCh: Amount sent not equal to parameter value');
        }

        if (sellOrder.saleKind == SaleKindInterface.SaleKind.EnglishAuction) {
            require(paymentToken != address(0), 'OnCh: Auctions can only be settled in ERC20 payments');
            require(price > sellOrder.nftHighestBid, 'OnCh: Price must be higher than the previous bidders offer');
            require(_isAuctionOngoing(sellOrder.expirationTime), 'OnCh: Auction expired');

            _updateOrderHighestBidder(sellOrder.contractAddress, sellOrder.tokenId, sellOrder.seller, msg.sender, price);
        }

        if (sellOrder.saleKind == SaleKindInterface.SaleKind.FixedPrice) {
            require(sellOrder.price == price, 'OnCh: Not the requested price');
            require(msg.value == price, 'OnCh: Did not send the correct amount');

            _completeSellOrder(sellOrder, msg.sender, price, amount);
        }

        return true;
    }


    function acceptHighestBid(address contractAddress, uint256 tokenId) nonReentrant whenNotPaused payable public returns (bool)  {
        SellOrder memory sellOrder = _retrieveOrder(contractAddress, tokenId, msg.sender);

        require(sellOrder.contractAddress != address(0), 'OnCh: Market item not found');
        require(sellOrder.saleKind != SaleKindInterface.SaleKind.FixedPrice, 'OnCh: Can only accept on auctions');
        require(sellOrder.nftHighestBidder != address(0), 'OnCh: No bids were placed');

        require(IERC20(sellOrder.paymentToken).allowance(sellOrder.nftHighestBidder, address(this)) > sellOrder.nftHighestBid, 'OnCh: Marketplace is not authorized to spend the amount the bidders behalf');
        require(IERC20(sellOrder.paymentToken).balanceOf(sellOrder.nftHighestBidder) > sellOrder.nftHighestBid, 'OnCh: Bidder doesnt have enough tokens');

        _completeSellOrder(sellOrder, sellOrder.nftHighestBidder, sellOrder.nftHighestBid, 1);

        return true;
    }

    function updateAuctionPeriod(address contractAddress, uint256 tokenId, uint expirationTime) nonReentrant whenNotPaused public returns (bool)   {
        SellOrder memory sellOrder = _retrieveOrder(contractAddress, tokenId, msg.sender);

        require(sellOrder.contractAddress != address(0), 'OnCh: Market item not found');
        require(sellOrder.saleKind != SaleKindInterface.SaleKind.FixedPrice, 'OnCh: Can only accept on auctions');
        require(sellOrder.status == SaleKindInterface.SellOrderStatus.Active, 'OnCh: Can only cancel an active order');

        _updateAuctionExpirationTime(contractAddress, tokenId, msg.sender, expirationTime);

        emit AuctionPeriodUpdated(contractAddress, msg.sender, tokenId, expirationTime);
        return true;
    }


    function _completeSellOrder(SellOrder memory sellOrder, address buyer, uint256 price, uint256 amount) internal {
        bytes32 orderHash = _computeOrderHashId(sellOrder.contractAddress, sellOrder.tokenId, sellOrder.seller);

        _updateOrderStatus(sellOrder.contractAddress, sellOrder.tokenId, sellOrder.seller, SaleKindInterface.SellOrderStatus.Completed, buyer);

        _paySellerAndTakePlatformFees(sellOrder, buyer, price);
        _transferAssetsToBuyer(sellOrder, buyer, amount);

        emit SellOrderCompleted(
            sellOrder.contractAddress,
            sellOrder.tokenId,
            sellOrder.seller,
            buyer,
            sellOrder.paymentToken,
            sellOrder.price,
            amount,
            sellOrder.saleKind,
            orderHash
        );
    }

    function _paySellerAndTakePlatformFees(SellOrder memory sellOrder, address buyer, uint256 price) internal {
        (address platformFeeAddress, uint platformFeePercent) = _getMarketplaceFeeInformation(sellOrder.seller);
        (address itemRoyaltyAddress, uint itemRoyaltyPercent) = _getItemRoyaltyInformation(sellOrder.contractAddress, sellOrder.tokenId);
        // Logic for calculating platform fees


        uint platformFeeAmount = platformFeeAddress != address(0) ? price.mul(platformFeePercent).div(100) : 0;
        uint creatorRoyaltyAmount = itemRoyaltyAddress != address(0) ? price.mul(itemRoyaltyPercent).div(100) : 0;
        uint sellerAmount = price - platformFeeAmount - creatorRoyaltyAmount;
/*

        console.log("paltform fee", platformFeePercent, platformFeeAddress, platformFeeAmount);
        console.log("creator royalty", itemRoyaltyPercent, itemRoyaltyAddress, creatorRoyaltyAmount);
        console.log("amount goes to seller", sellerAmount, sellOrder.seller);

*/

        if (sellOrder.paymentToken == address(0)) {
            //TODO: SAFETY CHECK
            payable(sellOrder.seller).transfer(sellerAmount);
            payable(platformFeeAddress).transfer(platformFeeAmount);
            payable(itemRoyaltyAddress).transfer(creatorRoyaltyAmount);
        } else {
            IERC20(sellOrder.paymentToken).transferFrom(buyer, sellOrder.seller, sellerAmount);
            IERC20(sellOrder.paymentToken).transferFrom(buyer, itemRoyaltyAddress, creatorRoyaltyAmount);
            IERC20(sellOrder.paymentToken).transferFrom(buyer, platformFeeAddress, platformFeeAmount);
        }
    }

    function _transferAssetsToBuyer(SellOrder memory sellOrder, address buyer, uint256 amount) internal {
        if (sellOrder.nftKind == SaleKindInterface.NFTKind.ERC721) {
            IERC721(sellOrder.contractAddress).safeTransferFrom(sellOrder.seller, buyer, sellOrder.tokenId);
        }
        if (sellOrder.nftKind == SaleKindInterface.NFTKind.ERC1155) {
            IERC1155(sellOrder.contractAddress).safeTransferFrom(sellOrder.seller, buyer, sellOrder.tokenId, amount, "");
        }
    }


    function _getMarketplaceFeeInformation(address sellerAddress) public view returns (address, uint) {
        return RoyaltyOrchestrator.getPlatformFeeInformation(sellerAddress);
    }

    function _getItemRoyaltyInformation(address contractAddress, uint256 tokenId) public view returns (address, uint) {
        return RoyaltyOrchestrator.getItemRoyaltyInformation(contractAddress, tokenId);
    }

    function _createSellOrder(SellOrder memory sellOrder) internal {
        bytes32 orderHash = _storeOrder(sellOrder);

        emit SellOrderCreated(
            sellOrder.contractAddress,
            sellOrder.tokenId,
            sellOrder.seller,
            sellOrder.paymentToken,
            sellOrder.price,
            sellOrder.saleKind,
            sellOrder.listingTime,
            sellOrder.expirationTime,
            sellOrder.amount,
            orderHash
        );
    }

    function _updateOrderHighestBidder(address contractAddress, uint256 tokenId, address seller, address bidderAddress, uint256 price) internal {
        bytes32 orderHash = _computeOrderHashId(contractAddress, tokenId, seller);

        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'nftHighestBid')), price);
        EternalStorage.setAddress(keccak256(abi.encodePacked(orderHash, 'nftHighestBidderAddress')), bidderAddress);

        address previousHighestBidderAddress = EternalStorage.getAddress(keccak256(abi.encodePacked(orderHash, 'nftHighestBidderAddress')));

        emit HighestBidderUpdated(
            contractAddress,
            tokenId,
            seller,
            bidderAddress,
            previousHighestBidderAddress,
            price
        );
    }

    function _updateOrderStatus(address contractAddress, uint256 tokenId, address seller, SaleKindInterface.SellOrderStatus status, address buyer) internal {
        bytes32 orderHash = _computeOrderHashId(contractAddress, tokenId, seller);

        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'status')), uint(status));
        EternalStorage.setAddress(keccak256(abi.encodePacked(orderHash, 'buyer')), buyer);
    }

    function _updateAuctionExpirationTime(address contractAddress, uint256 tokenId, address seller, uint expirationTime) internal {
        bytes32 orderHash = _computeOrderHashId(contractAddress, tokenId, seller);

        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'expirationTime')), expirationTime);
    }

    /*
        Stores current order information in the eternal storage contract
    */
    function _storeOrder(SellOrder memory marketItem) internal returns (bytes32) {
        bytes32 orderHash = _computeOrderHashId(marketItem.contractAddress, marketItem.tokenId, marketItem.seller);

        EternalStorage.setAddress(keccak256(abi.encodePacked(orderHash, 'contractAddress')), marketItem.contractAddress);
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'tokenId')), marketItem.tokenId);
        EternalStorage.setAddress(keccak256(abi.encodePacked(orderHash, 'seller')), marketItem.seller);
        EternalStorage.setAddress(keccak256(abi.encodePacked(orderHash, 'buyer')), marketItem.buyer);
        EternalStorage.setAddress(keccak256(abi.encodePacked(orderHash, 'paymentToken')), marketItem.paymentToken);
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'price')), marketItem.price);
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'nftHighestBid')), marketItem.nftHighestBid);
        EternalStorage.setAddress(keccak256(abi.encodePacked(orderHash, 'nftHighestBidderAddress')), marketItem.nftHighestBidder);
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'listingTime')), marketItem.listingTime);
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'expirationTime')), marketItem.expirationTime);
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'amount')), marketItem.amount);
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'saleKind')), uint(marketItem.saleKind));
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'nftKind')), uint(marketItem.nftKind));
        EternalStorage.setUint(keccak256(abi.encodePacked(orderHash, 'status')), uint(marketItem.status));

        return orderHash;
    }

    /*
        Retrieves order from eternalStorage
    */
    function _retrieveOrder(address contractAddress, uint256 tokenId, address seller) public view returns (SellOrder memory) {
        bytes32 orderHash = _computeOrderHashId(contractAddress, tokenId, seller);
        return SellOrder(
            EternalStorage.getAddress(keccak256(abi.encodePacked(orderHash, 'contractAddress'))),
            EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'tokenId'))),
            EternalStorage.getAddress(keccak256(abi.encodePacked(orderHash, 'seller'))),
            EternalStorage.getAddress(keccak256(abi.encodePacked(orderHash, 'buyer'))),
            EternalStorage.getAddress(keccak256(abi.encodePacked(orderHash, 'paymentToken'))),
            EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'price'))),
            uint256(EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'nftHighestBidderAddress')))),
            EternalStorage.getAddress(keccak256(abi.encodePacked(orderHash, 'paymentToken'))),
            EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'listingTime'))),
            EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'expirationTime'))),
            EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'amount'))),
            SaleKindInterface.SaleKind(EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'saleKind')))),
            SaleKindInterface.NFTKind(EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'nftKind')))),
            SaleKindInterface.SellOrderStatus(EternalStorage.getUint(keccak256(abi.encodePacked(orderHash, 'status'))))
        );
    }

    function _computeOrderHashId(address contractAddress, uint256 tokenId, address seller) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(contractAddress, tokenId, seller));
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

interface IOnChEternalStorage {
  function addToWhitelist ( address allowedAddress ) external;
  function addToWhitelistBulk ( address[] memory allowedAddresses ) external;
  function deleteAddress ( bytes32 _key ) external;
  function deleteBool ( bytes32 _key ) external;
  function deleteBytes ( bytes32 _key ) external;
  function deleteInt ( bytes32 _key ) external;
  function deleteString ( bytes32 _key ) external;
  function deleteUint ( bytes32 _key ) external;
  function getAddress ( bytes32 _key ) external view returns ( address );
  function getBool ( bytes32 _key ) external view returns ( bool );
  function getBytes ( bytes32 _key ) external view returns ( bytes memory );
  function getInt ( bytes32 _key ) external view returns ( int256 );
  function getString ( bytes32 _key ) external view returns ( string memory );
  function getUint ( bytes32 _key ) external view returns ( uint256 );
  function isWhitelisted ( address addressToCheck ) external view returns ( bool );
  function owner (  ) external view returns ( address );
  function removeFromWhitelist ( address allowedAddress ) external;
  function removeFromWhitelistBulk ( address[] memory allowedAddresses ) external;
  function renounceOwnership (  ) external;
  function setAddress ( bytes32 _key, address _value ) external;
  function setBool ( bytes32 _key, bool _value ) external;
  function setBytes ( bytes32 _key, bytes memory _value ) external;
  function setInt ( bytes32 _key, int256 _value ) external;
  function setString ( bytes32 _key, string memory _value ) external;
  function setUint ( bytes32 _key, uint256 _value ) external;
  function setUnWithdrawableToken ( address token ) external;
  function transferOwnership ( address newOwner ) external;
  function upgradeVersion ( address _newVersion ) external;
  function withdrawResidualErc20 ( address token, address to ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

interface IOnChRoyaltyOrchestrator {
  function addCustomFee ( address creatorAddress, uint256 customFee ) external returns ( bool );
  function addToWhitelist ( address allowedAddress ) external;
  function addToWhitelistBulk ( address[] memory allowedAddresses ) external;
  function changeMaxRoyaltyPercentage ( uint256 royaltyPercentage ) external returns ( bool );
  function changePlatformFeePercentage ( uint256 _platformPercentage ) external returns ( bool );
  function changePlatformFeeAddress ( address _feeAddress ) external returns ( bool );
  function contractRoyaltyPercentage ( address ) external view returns ( address receiverAddress, uint256 percentage );
  function creators ( uint256 ) external view returns ( address );
  function creatorsLength (  ) external view returns ( uint256 );
  function customFees ( address ) external view returns ( uint256 );
  function getItemRoyaltyInformation ( address _contractAddress, uint256 _tokenId ) external view returns ( address, uint256 );
  function getPlatformFeeInformation ( address creatorAddress ) external view returns ( address, uint256 );
  function isWhitelisted ( address addressToCheck ) external view returns ( bool );
  function maxRoyaltyPercentage (  ) external view returns ( uint256 );
  function owner (  ) external view returns ( address );
  function platformFeePercentage (  ) external view returns ( uint256 );
  function removeFromWhitelist ( address allowedAddress ) external;
  function removeFromWhitelistBulk ( address[] memory allowedAddresses ) external;
  function renounceOwnership (  ) external;
  function setItemRoyaltyPercentage ( address _creatorAddress, address _contractAddress, uint256 _tokenId, uint8 royaltyPercentage ) external returns ( bool );
  function setUnWithdrawableToken ( address token ) external;
  function transferOwnership ( address newOwner ) external;
  function withdrawResidualErc20 ( address token, address to ) external;
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}