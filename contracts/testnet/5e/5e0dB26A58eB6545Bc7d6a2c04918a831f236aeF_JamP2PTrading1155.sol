/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../JamMarketplaceHelpers.sol";

contract JamP2PTrading1155 is JamMarketplaceHelpers {
    struct Offer {
        address offeror;
        address nftAddress;
        uint256 tokenId;
        uint256 quantity;
        address currency;
        uint256 amount;
    }

    // Mapping from an NFT type (NFT address + token ID) to its pending offers
    mapping(address => mapping(uint256 => Offer[])) private _offersFor;

    // Mapping from a user address to the offers he has made so far
    mapping(address => Offer[]) private _offersOf;

    event OfferCreated(
        address offeror,
        address nftAddress,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 amount
    );

    event OfferUpdated(
        address offeror,
        address nftAddress,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 amount
    );

    event OfferAccepted(
        address offeror,
        address accepter,
        address nftAddress,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 amount
    );

    event OfferCancelled(
        address offeror,
        address nftAddress,
        uint256 tokenId,
        uint256 quantity
    );

    constructor(address hubAddress, uint256 ownerCut_)
        JamMarketplaceHelpers(hubAddress, ownerCut_)
    {
        marketplaceId = keccak256("JAM_P2P_TRADING_1155");
    }

    function getAllOffersFor(address nftAddress, uint256 tokenId)
        external
        view
        returns (Offer[] memory)
    {
        return _offersFor[nftAddress][tokenId];
    }

    function getAcceptableOffersFor(
        address nftAddress,
        uint256 tokenId,
        address user
    ) external view returns (Offer[] memory) {
        uint256 offerCount = 0;
        uint256 numAcceptableOffers = 0;
        uint256 balance = IERC1155(nftAddress).balanceOf(user, tokenId);
        Offer[] memory allOffers = _offersFor[nftAddress][tokenId];
        for (uint256 i = 0; i < allOffers.length; i++)
            if (allOffers[i].quantity <= balance) numAcceptableOffers++;
        Offer[] memory acceptableOffers = new Offer[](numAcceptableOffers);
        for (uint256 i = 0; i < allOffers.length; i++)
            if (allOffers[i].quantity <= balance) {
                acceptableOffers[offerCount] = allOffers[i];
                offerCount++;
            }
        return acceptableOffers;
    }

    function getOffersOf(address offeror)
        external
        view
        returns (Offer[] memory)
    {
        return _offersOf[offeror];
    }

    function getSpecificOffer(
        address offeror,
        address nftAddress,
        uint256 tokenId
    ) public view returns (Offer memory) {
        Offer memory offer;
        for (uint256 i = 0; i < _offersFor[nftAddress][tokenId].length; i++) {
            offer = _offersFor[nftAddress][tokenId][i];
            if (offer.offeror == offeror) return offer;
        }
        return offer;
    }

    function makeOffer(
        address nftAddress,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 offerAmount
    ) external payable {
        // Check offering conditions
        require(
            getSpecificOffer(msg.sender, nftAddress, tokenId).offeror ==
                address(0),
            "JamP2PTrading1155: already offered before"
        );
        if (currency == address(0))
            require(
                offerAmount == msg.value,
                "JamP2PTrading1155: offer amount info mismatch"
            );
        else {
            (bool success, ) = payable(msg.sender).call{value: msg.value}("");
            require(success, "JamP2PTrading1155: return money failed");
        }

        // Save the offer's information
        Offer memory offer = Offer(
            msg.sender,
            nftAddress,
            tokenId,
            quantity,
            currency,
            offerAmount
        );
        _offersFor[nftAddress][tokenId].push(offer);
        _offersOf[msg.sender].push(offer);

        // Lock offeror's money
        if (currency != address(0))
            IERC20(currency).transferFrom(
                msg.sender,
                address(this),
                offerAmount
            );

        emit OfferCreated(
            msg.sender,
            nftAddress,
            tokenId,
            quantity,
            currency,
            offerAmount
        );
    }

    function updateOffer(
        address nftAddress,
        uint256 tokenId,
        address currency,
        uint256 offerAmount
    ) external payable nonReentrant {
        Offer memory offer = getSpecificOffer(msg.sender, nftAddress, tokenId);

        // Check updating conditions
        require(
            offer.offeror == msg.sender,
            "JamP2PTrading1155: no offer found"
        );
        if (currency == address(0))
            require(
                offerAmount == msg.value,
                "JamP2PTrading1155: offer amount info mismatch"
            );
        else {
            (bool success, ) = payable(msg.sender).call{value: msg.value}("");
            require(success, "JamP2PTrading1155: return money failed");
        }

        // Save the new information
        for (uint256 i = 0; i < _offersFor[nftAddress][tokenId].length; i++)
            if (_offersFor[nftAddress][tokenId][i].offeror == msg.sender) {
                _offersFor[nftAddress][tokenId][i].currency = currency;
                _offersFor[nftAddress][tokenId][i].amount = offerAmount;
                break;
            }
        for (uint256 i = 0; i < _offersOf[msg.sender].length; i++)
            if (
                _offersOf[msg.sender][i].nftAddress == nftAddress &&
                _offersOf[msg.sender][i].tokenId == tokenId
            ) {
                _offersOf[msg.sender][i].currency = currency;
                _offersOf[msg.sender][i].amount = offerAmount;
                break;
            }

        // Return old locked offer amount
        if (offer.currency == address(0)) {
            (bool success, ) = payable(msg.sender).call{value: offer.amount}(
                ""
            );
            require(success, "JamP2PTrading1155: return money failed");
        } else {
            bool success = IERC20(offer.currency).transfer(
                msg.sender,
                offer.amount
            );
            require(success, "JamP2PTrading1155: return money failed");
        }

        // Lock new offer amount
        if (currency != address(0))
            IERC20(currency).transferFrom(
                msg.sender,
                address(this),
                offerAmount
            );

        emit OfferUpdated(
            msg.sender,
            nftAddress,
            tokenId,
            offer.quantity,
            currency,
            offerAmount
        );
    }

    function cancelOffer(address nftAddress, uint256 tokenId)
        external
        nonReentrant
    {
        Offer memory offer = getSpecificOffer(msg.sender, nftAddress, tokenId);

        // Check cancelling conditions
        require(
            offer.offeror == msg.sender,
            "JamP2PTrading1155: sender is not offeror"
        );

        // Delete offer's information
        for (uint256 i = 0; i < _offersFor[nftAddress][tokenId].length; i++)
            if (_offersFor[nftAddress][tokenId][i].offeror == msg.sender) {
                uint256 length = _offersFor[nftAddress][tokenId].length;
                _offersFor[nftAddress][tokenId][i] = _offersFor[nftAddress][
                    tokenId
                ][length - 1];
                _offersFor[nftAddress][tokenId].pop();
                break;
            }
        for (uint256 i = 0; i < _offersOf[msg.sender].length; i++)
            if (
                _offersOf[msg.sender][i].nftAddress == nftAddress &&
                _offersOf[msg.sender][i].tokenId == tokenId
            ) {
                uint256 length = _offersOf[msg.sender].length;
                _offersOf[msg.sender][i] = _offersOf[msg.sender][length - 1];
                _offersOf[msg.sender].pop();
                break;
            }

        // Return locked offer amount
        if (offer.currency == address(0)) {
            (bool success, ) = payable(msg.sender).call{value: offer.amount}(
                ""
            );
            require(success, "JamP2PTrading1155: return money failed");
        } else {
            bool success = IERC20(offer.currency).transfer(
                msg.sender,
                offer.amount
            );
            require(success, "JamP2PTrading1155: return money failed");
        }

        emit OfferCancelled(msg.sender, nftAddress, tokenId, offer.quantity);
    }

    /**
     * @dev The owner of the NFT accepts the offer even when the NFT is on marketplace.
     * @param offeror The person who offered this NFT so far.
     * @param nftAddress - Address of the NFT.
     * @param tokenId - ID of the offered token.
     * @notice If the NFT is currently not on marketplace, the owner must approve it for this contract
     */
    function acceptOffer(
        address offeror,
        address nftAddress,
        uint256 tokenId
    ) external nonReentrant {
        // Check accepting conditions
        Offer memory offer = getSpecificOffer(offeror, nftAddress, tokenId);
        require(offer.offeror == offeror, "JamP2PTrading1155: no offer found");

        require(
            IERC1155(nftAddress).balanceOf(msg.sender, tokenId) >=
                offer.quantity,
            "JamP2PTrading1155: not enough NFTs to accept"
        );

        // Sell it to the offeror
        IERC1155(nftAddress).safeTransferFrom(
            msg.sender,
            offeror,
            tokenId,
            offer.quantity,
            abi.encodePacked("Accept offer")
        );

        // Compute auctioneer cut and royalty cut then return proceeds to seller
        if (offer.amount > 0)
            _computeFeesAndPaySeller(
                nftAddress,
                msg.sender,
                offer.currency,
                offer.amount
            );

        emit OfferAccepted(
            offeror,
            msg.sender,
            nftAddress,
            tokenId,
            offer.quantity,
            offer.currency,
            offer.amount
        );
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

/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./JamMarketplaceHub.sol";

abstract contract JamMarketplaceHelpers is Ownable, Pausable, ReentrancyGuard {
    /**
     * @dev Royalty fee is cut from the sale price of an NFT
     * @param recipient Who will receive the royalty fee
     * @param percentage The percentage that sale price will be cut into royalty fee
     * @notice The percentage values 0 - 10000 map to 0% - 100%
     * @notice `percentage` + `ownerCut` (defined in marketplace contracts) must be less than 100%
     */
    struct RoyaltyFee {
        address recipient;
        uint256 percentage;
    }

    // The ID of this marketplace in Gamejam's marketplace system
    bytes32 public marketplaceId;

    // Cut owner takes on each auction. Values 0 - 10,000 map to 0% - 100%
    uint256 public ownerCut;

    // The minimum duration between 2 continuous royalty withdrawals
    uint256 private _withdrawDuration = 14 days;

    // The address of marketplace hub
    address internal _marketplaceHub;

    // Mapping from (royalty recipient, erc20 currency) to the amount of royalty cut he receives
    mapping(address => mapping(address => uint256)) private _royaltyCuts;

    // The total amount of royalty cut which cannot be reclaimed by the owner of the contract
    mapping(address => uint256) private _totalRoyaltyCut;

    // Mapping from (royalty recipient, erc20 currency) to the last moment he withdraws the royalty cut
    mapping(address => mapping(address => uint256)) private _lastWithdraws;

    // Mapping from the NFT contract address to the royalty information of that NFT contract
    mapping(address => RoyaltyFee) private _royaltyInfoOf;

    /**
     * @dev Constructor that rejects incoming Ether
     * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
     * leave out payable, then Solidity will allow inheriting contracts to implement a payable
     * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
     * we could use assembly to access msg.value.
     */
    constructor(address hubAddress, uint256 ownerCut_) payable {
        require(
            msg.value == 0,
            "JamMarketplaceHelpers: cannot send native token when deploying"
        );
        require(
            hubAddress != address(0),
            "JamMarketplaceHelpers: invalid hub address"
        );
        require(
            ownerCut_ < 10000,
            "JamMarketplaceHelpers: owner cut must be less than 100%"
        );
        _marketplaceHub = hubAddress;
        ownerCut = ownerCut_;
    }

    /**
     * @dev Returns a person who is allowed to cancel an auction
     * @param nftAddress - address of a deployed contract implementing the non-fungible interface.
     * @param tokenId - ID of token to auction
     * @notice Sellers are allowed to cancel their ERC721 auctions to accept offers.
     * @notice ERC1155 auctions cannot be cancelled for this reason.
     * @notice If an auction cannot be cancelled, returns address(0)
     */
    function auctionCancelPermittee(address nftAddress, uint256 tokenId)
        external
        view
        virtual
        returns (address)
    {
        return address(0);
    }

    function getRoyaltyInfo(address nftAddress)
        external
        view
        returns (address, uint256)
    {
        RoyaltyFee memory info = _royaltyInfoOf[nftAddress];
        return (info.recipient, info.percentage);
    }

    function getReceivedRoyalty(address user, address[] memory currencies)
        external
        view
        returns (
            uint256[] memory receivedAmounts,
            uint256[] memory lastWithdraws
        )
    {
        receivedAmounts = new uint256[](currencies.length);
        lastWithdraws = new uint256[](currencies.length);
        for (uint256 i = 0; i < currencies.length; i++) {
            uint256 balance = _royaltyCuts[user][currencies[i]];
            receivedAmounts[i] = balance;
            uint256 lastWithdraw = _lastWithdraws[user][currencies[i]];
            lastWithdraws[i] = lastWithdraw;
        }
    }

    function setRoyaltyFee(
        address nftAddress,
        address recipient,
        uint256 percentage
    ) external {
        require(
            msg.sender == _marketplaceHub,
            "JamMarketplaceHelpers: caller is not marketplace hub"
        );
        require(
            recipient != address(0),
            "JamMarketplaceHelpers: invalid recipient"
        );
        require(
            percentage + ownerCut < 10000,
            "JamMarketplaceHelpers: percentage is too high"
        );
        _royaltyInfoOf[nftAddress] = RoyaltyFee(recipient, percentage);
    }

    function setOwnerCut(uint256 ownerCut_) public onlyOwner {
        require(
            ownerCut_ < 10000,
            "JamMarketplaceHelpers: owner cut must be less than 100%"
        );
        ownerCut = ownerCut_;
    }

    function registerWithHub() external onlyOwner {
        JamMarketplaceHub(_marketplaceHub).registerMarketplace(marketplaceId);
    }

    function cancelAuction721(address nftAddress, uint256 tokenId)
        external
        virtual
    {}

    function cancelAuction1155(uint256 auctionId) external virtual {}

    function withdrawRoyalty(address currency) public {
        uint256 lastWithdraw = _lastWithdraws[msg.sender][currency];
        require(
            lastWithdraw + _withdrawDuration <= block.timestamp,
            "JamMarketplaceHelpers: only withdraw after 14 days after previous withdraw"
        );
        uint256 royaltyCut = _royaltyCuts[msg.sender][currency];
        require(
            royaltyCut > 0,
            "JamMarketplaceHelpers: no royalty cut to withdraw"
        );
        _royaltyCuts[msg.sender][currency] = 0;
        _totalRoyaltyCut[currency] -= royaltyCut;
        _lastWithdraws[msg.sender][currency] = block.timestamp;
        if (currency == address(0)) {
            (bool success, ) = payable(msg.sender).call{value: royaltyCut}("");
            require(success, "JamMarketplaceHelpers: withdraw failed");
        } else {
            IERC20 erc20Contract = IERC20(currency);
            bool success = erc20Contract.transfer(msg.sender, royaltyCut);
            require(success, "JamMarketplaceHelpers: withdraw failed");
        }
    }

    function reclaim(address currency) external onlyOwner {
        if (currency == address(0)) {
            (bool success, ) = payable(owner()).call{
                value: address(this).balance - _totalRoyaltyCut[address(0)]
            }("");
            require(success, "JamMarketplaceHelpers: reclaim failed");
        } else {
            IERC20 currencyContract = IERC20(currency);
            bool success = IERC20(currency).transfer(
                owner(),
                currencyContract.balanceOf(address(this)) -
                    _totalRoyaltyCut[currency]
            );
            require(success, "JamMarketplaceHelpers: reclaim failed");
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _computeFeesAndPaySeller(
        address nftAddress,
        address seller,
        address currency,
        uint256 salePrice
    ) internal {
        RoyaltyFee memory royaltyInfo = _royaltyInfoOf[nftAddress];
        uint256 auctioneerCut = (salePrice * ownerCut) / 10000;
        uint256 royaltyFee = (salePrice * royaltyInfo.percentage) / 10000;
        require(
            auctioneerCut + royaltyFee < salePrice,
            "JamMarketplaceHelpers: total fees must be less than sale price"
        );
        _totalRoyaltyCut[currency] += royaltyFee;
        _royaltyCuts[royaltyInfo.recipient][currency] += royaltyFee;
        uint256 sellerProceeds = salePrice - auctioneerCut - royaltyFee;
        if (currency == address(0)) {
            (bool success, ) = payable(seller).call{value: sellerProceeds}("");
            require(success, "JamMarketplaceHelpers: transfer proceeds failed");
        } else {
            bool success = IERC20(currency).transfer(seller, sellerProceeds);
            require(success, "JamMarketplaceHelpers: transfer proceeds failed");
        }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
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
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./JamMarketplaceHelpers.sol";
import "./JamNFTOwners.sol";

contract JamMarketplaceHub is Ownable {
    address private _jamNFTOwners;
    mapping(bytes32 => address) private _marketplaceIdToAddress;
    mapping(address => bytes32) private _marketplaceAddressToId;

    constructor(address nftOwnersContract) {
        _jamNFTOwners = nftOwnersContract;
    }

    function isMarketplace(address addr) external view returns (bool) {
        return _marketplaceAddressToId[addr] != 0x0;
    }

    function getMarketplace(bytes32 id) external view returns (address) {
        return _marketplaceIdToAddress[id];
    }

    function registerMarketplace(bytes32 id) external {
        require(
            Ownable(msg.sender).owner() == owner(),
            "JamMarketplaceHub: invalid caller contract"
        );
        require(id != 0x0, "JamMarketplaceHub: invalid marketplace id");
        _marketplaceIdToAddress[id] = msg.sender;
        _marketplaceAddressToId[msg.sender] = id;
    }

    function unregisterMarketplace(bytes32 id) external onlyOwner {
        delete _marketplaceAddressToId[_marketplaceIdToAddress[id]];
        delete _marketplaceIdToAddress[id];
    }

    function unregisterMarketplace(address addr) external onlyOwner {
        delete _marketplaceIdToAddress[_marketplaceAddressToId[addr]];
        delete _marketplaceAddressToId[addr];
    }

    function setRoyaltyFee(
        address nftAddress,
        bytes32[] memory marketplaceIds,
        address[] memory recipients,
        uint256[] memory percentages
    ) external {
        require(
            msg.sender == JamNFTOwners(_jamNFTOwners).getNFTOwner(nftAddress),
            "JamMarketplaceHub: caller is not NFT owner"
        );
        require(
            marketplaceIds.length == recipients.length &&
                marketplaceIds.length == percentages.length,
            "JamMarketplaceHub: lengths mismatch"
        );
        for (uint256 i = 0; i < marketplaceIds.length; i++) {
            address marketplaceAddr = _marketplaceIdToAddress[
                marketplaceIds[i]
            ];
            require(
                _marketplaceAddressToId[marketplaceAddr] != 0x0,
                "JamMarketplaceHub: invalid marketplace id"
            );
            JamMarketplaceHelpers(marketplaceAddr).setRoyaltyFee(
                nftAddress,
                recipients[i],
                percentages[i]
            );
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract JamNFTOwners is Ownable {
    mapping(address => bool) private _operators;
    mapping(address => address) private _ownerOf;

    constructor() Ownable() {}

    modifier onlyOperators() {
        require(_operators[msg.sender], "JamNFTOwners: caller is not operator");
        _;
    }

    function getNFTOwner(address nftAddress) external view returns (address) {
        return _ownerOf[nftAddress];
    }

    function setOperators(address[] memory operators, bool[] memory isOperators)
        external
        onlyOwner
    {
        require(
            operators.length == isOperators.length,
            "JamNFTOwners: lengths mismatch"
        );
        for (uint256 i = 0; i < operators.length; i++)
            _operators[operators[i]] = isOperators[i];
    }

    function setNFTOwners(
        address[] memory nftAddresses,
        address[] memory nftOwners
    ) external onlyOperators {
        require(
            nftAddresses.length == nftOwners.length,
            "JamNFTOwners: lengths mismatch"
        );
        for (uint256 i = 0; i < nftAddresses.length; i++)
            _ownerOf[nftAddresses[i]] = nftOwners[i];
    }
}