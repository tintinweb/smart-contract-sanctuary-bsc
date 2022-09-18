/**
 * @notice Submitted for verification at bscscan.com on 2022-09-18
 */

/*
 _______          ___            ___      ___          ___
|   __   \       |   \          /   |    |   \        |   |
|  |  \   \      |    \        /    |    |    \       |   |
|  |__/    |     |     \      /     |    |     \      |   |
|         /      |      \____/      |    |      \     |   |
|        /       |   |\        /|   |    |   |\  \    |   |
|   __   \       |   | \______/ |   |    |   | \  \   |   |
|  |  \   \      |   |          |   |    |   |  \  \  |   |
|  |__/    |     |   |          |   |    |   |   \  \ |   |
|         /      |   |          |   |    |   |    \  \|   |
|________/       |___|          |___|    |___|     \______|
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./NFTReserveAuction.sol";

/**
 * @title BlockMelonReserveAuction
 * @author BlockMelon
 * @notice It has the following functionalities:
 *          - auction creation with a reserve price for NFTs
 *          - supported token standard: ERC-721
 *          - transfer the market fee to the treasury of BlockMelon and the revenue of the seller, royalty of the
 *              first owner and creator
 *          - the seller can update the price of its own sale.
 *          - the seller has the right to cancel its own sale.
 *          - a BlockMelon admin has the right to cancel any sale with a reason provided
 * @dev Implements a reserved auction for NFTs.
 * based on: 0x005d77e5eeab2f17e62a11f1b213736ca3c05cf6 `NFTMarketReserveAuction.sol`
 */
contract BlockMelonReserveAuction is NFTReserveAuction {
    function __BlockMelonReserveAuction_init(
        uint256 primaryBlockMelonFeeInBps,
        uint256 secondaryBlockMelonFeeInBps,
        uint256 secondaryCreatorFeeInBps,
        uint256 secondaryFirstOwnerFeeInBps,
        address payable blockMelonTreasury,
        address _adminContract
    ) external initializer {
        __Context_init_unchained();
        __BlockMelonPullPayment_init();
        __BlockMelonTreasury_init_unchained(blockMelonTreasury);
        __BlockMelonMarketConfig_init_unchained(
            primaryBlockMelonFeeInBps,
            secondaryBlockMelonFeeInBps,
            secondaryCreatorFeeInBps,
            secondaryFirstOwnerFeeInBps
        );
        __BlockMelonNFTPaymentManager_init_unchained();
        __NFTReserveAuction_init_unchained();

        _updateAdminContract(_adminContract);
    }

    /**
     * @notice Allows a market admin to update the market fees and auction configuration
     */
    function updateAuctionConfig(
        uint256 primaryBlockMelonFeeInBps,
        uint256 secondaryBlockMelonFeeInBps,
        uint256 secondaryCreatorFeeInBps,
        uint256 secondaryFirstOwnerFeeInBps,
        uint256 minPercentIncrementInBasisPoints,
        uint256 duration
    ) external onlyBlockMelonAdmin {
        _updateReserveAuctionConfig(minPercentIncrementInBasisPoints, duration);
        _updateFeesConfig(
            primaryBlockMelonFeeInBps,
            secondaryBlockMelonFeeInBps,
            secondaryCreatorFeeInBps,
            secondaryFirstOwnerFeeInBps
        );
    }

    /**
     * @notice Allows a market admin to update the treasury address
     */
    function setBlockMelonTreasury(address payable newTreasury)
        external
        onlyBlockMelonAdmin
    {
        _setBlockMelonTreasury(newTreasury);
    }

    /**
     * @notice Allows BlockMelon to change the admin contract address.
     */
    function updateAdminContract(address _adminContract)
        external
        onlyBlockMelonAdmin
    {
        _updateAdminContract(_adminContract);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";

/**
 * @dev ERC-721 token receiver contract for handling safe transfers
 */
abstract contract ERC721TokenReceiver is IERC721ReceiverUpgradeable {
    /**
     * @dev See {IERC721ReceiverUpgradeable-onERC721Received}
     */
    function onERC721Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*tokenId*/
        bytes calldata /* data*/
    ) public pure override returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return interfaceId == type(IERC721ReceiverUpgradeable).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

import "../interfaces/ITokenCreatorPaymentAddress.sol";
import "../interfaces/ITokenCreator.sol";
import "../interfaces/IGetRoyalties.sol";
import "../interfaces/IHasSecondarySaleFees.sol";
import "../interfaces/IFirstOwner.sol";
import "../interfaces/IOwnable.sol";

/// @dev based on: 0x005d77e5eeab2f17e62a11f1b213736ca3c05cf6 `NFTMarketCreators.sol`
abstract contract PaymentInfo {
    using ERC165CheckerUpgradeable for address;
    // from 0x005d77e5eeab2f17e62a11f1b213736ca3c05cf6  `Constants.sol`
    uint256 private constant READ_ONLY_GAS_LIMIT = 40000;

    /**
     * @dev Returns the destination address for any payments to the creator,
     * or address(0) if the destination is unknown.
     * It also checks if the current seller is the creator for isPrimary checks.
     */
    function _getCreatorPaymentInfo(
        address nftContract,
        uint256 tokenId,
        address payable seller
    ) internal view returns (address payable creatorAddress_, bool isCreator) {
        // ITokenCreatorPaymentAddress with IERC165
        if (
            nftContract.supportsInterface(
                type(ITokenCreatorPaymentAddress).interfaceId
            )
        ) {
            try
                ITokenCreatorPaymentAddress(nftContract)
                    .getTokenCreatorPaymentAddress{gas: READ_ONLY_GAS_LIMIT}(
                    tokenId
                )
            returns (address payable creatorAddress) {
                if (creatorAddress != address(0)) {
                    if (creatorAddress == seller) {
                        return (creatorAddress, true);
                    }
                    // else keep looking for the creator address
                }
            } catch {
                // Fall through
            }
        }

        // ITokenCreator with IERC165
        if (nftContract.supportsInterface(type(ITokenCreator).interfaceId)) {
            try
                ITokenCreator(nftContract).tokenCreator{
                    gas: READ_ONLY_GAS_LIMIT
                }(tokenId)
            returns (address payable creatorAddress) {
                if (creatorAddress != address(0)) {
                    return (creatorAddress, creatorAddress == seller);
                }
                // else keep looking for the creator address
            } catch {
                // Fall through
            }
        }

        // IGetRoyalties with IERC165
        if (nftContract.supportsInterface(type(IGetRoyalties).interfaceId)) {
            try
                IGetRoyalties(nftContract).getRoyalties{
                    gas: READ_ONLY_GAS_LIMIT
                }(tokenId)
            returns (address payable[] memory recipients, uint256[] memory) {
                if (recipients.length > 0) {
                    for (uint256 i = 0; i < recipients.length; i++) {
                        if (
                            recipients[i] != address(0) &&
                            recipients[i] == seller
                        ) {
                            return (recipients[i], true);
                        }
                    }
                }
                // else keep looking for the creator address
            } catch {
                // Fall through
            }
        }

        // IHasSecondarySaleFees with IERC165
        if (
            nftContract.supportsInterface(
                type(IHasSecondarySaleFees).interfaceId
            )
        ) {
            try
                IHasSecondarySaleFees(nftContract).getFeeRecipients{
                    gas: READ_ONLY_GAS_LIMIT
                }(tokenId)
            returns (address payable[] memory recipients) {
                if (recipients.length > 0) {
                    for (uint256 i = 0; i < recipients.length; i++) {
                        if (
                            recipients[i] != address(0) &&
                            recipients[i] == seller
                        ) {
                            return (recipients[i], true);
                        }
                    }
                }
            } catch {
                // Fall through
            }
        }

        // ITokenCreator without IERC165
        try
            ITokenCreator(nftContract).tokenCreator{gas: READ_ONLY_GAS_LIMIT}(
                tokenId
            )
        returns (address payable creatorAddress) {
            if (creatorAddress != address(0)) {
                return (creatorAddress, creatorAddress == seller);
            }
            // else keep looking for the creator address
        } catch {
            // Fall through
        }

        // Only pay the owner if there wasn't a tokenCreatorPaymentAddress defined, without IERC165
        try IOwnable(nftContract).owner{gas: READ_ONLY_GAS_LIMIT}() returns (
            address owner_
        ) {
            if (owner_ != address(0)) {
                return (payable(owner_), owner_ == seller);
            }
        } catch {
            // Fall through
        }

        // If no valid payment address or creator is found, return address(0) and false
    }

    /**
     * @dev Returns the destination address for any payments to the first owner
     * or address(0) if the destination is unknown.
     */
    function _getFirstOwnerPaymentInfo(address nftContract, uint256 tokenId)
        internal
        view
        returns (address payable firstOwnerAddress_)
    {
        // with IERC165
        if (nftContract.supportsInterface(type(IFirstOwner).interfaceId)) {
            try
                IFirstOwner(nftContract).firstOwner{gas: READ_ONLY_GAS_LIMIT}(
                    tokenId
                )
            returns (address payable firstOwnerAddress) {
                return firstOwnerAddress;
            } catch {
                // Fall through
            }
        }

        // without IERC165
        try
            IFirstOwner(nftContract).firstOwner{gas: READ_ONLY_GAS_LIMIT}(
                tokenId
            )
        returns (address payable firstOwnerAddress) {
            return firstOwnerAddress;
        } catch {
            // Fall through
        }

        // If no valid payment address or creator is found, return address(0)
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PullPaymentUpgradeable.sol";

abstract contract BlockMelonPullPayment is
    PullPaymentUpgradeable,
    ReentrancyGuardUpgradeable
{
    function __BlockMelonPullPayment_init() internal onlyInitializing {
        __PullPayment_init();
        __ReentrancyGuard_init();
    }

    /**
     * @dev See {PullPaymentUpgradeable-withdrawPayments}
     * @dev This version of `withdrawPayments` adds protection against reentrancy attacks
     */
    function withdrawPayments(address payable payee)
        public
        override
        nonReentrant
    {
        super.withdrawPayments(payee);
    }

    /**
     * @dev Sends `amount` to the address of `recipient`, if `amount` > 0
     * If transfer was unsuccessful then save `amount` as a deposit which can be withdrawn by `withdrawPayments`
     */
    function _sendValueToRecipient(address payable recipient, uint256 amount)
        internal
    {
        if (0 == amount) {
            return;
        }
        require(address(this).balance >= amount, "insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            _asyncTransfer(recipient, amount);
        }
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "../market/BlockMelonMarketConfig.sol";
import "../market/BlockMelonTreasury.sol";
import "./BlockMelonPullPayment.sol";
import "./PaymentInfo.sol";

abstract contract BlockMelonNFTPaymentManager is
    BlockMelonMarketConfig,
    BlockMelonTreasury,
    BlockMelonPullPayment,
    PaymentInfo
{
    uint256 private constant BASIS_POINTS = 10000;
    /// @dev Indicates whether the given NFT has been sold in this market previously
    mapping(address => mapping(uint256 => bool))
        private _isPrimaryAuctionFinished;

    struct Revenues {
        uint256 marketRevenue;
        uint256 creatorRevenue;
        uint256 sellerRevenue;
        uint256 firstOwnerRevenue;
    }

    function __BlockMelonNFTPaymentManager_init_unchained()
        internal
        onlyInitializing
    {}

    /**
     * @notice Returns true if the given token has not been sold in this market previously and is being sold by the creator.
     */
    function isPrimaryAuction(
        address tokenContract,
        uint256 tokenId,
        address payable seller
    ) public view returns (bool) {
        (, bool isCreator) = _getCreatorPaymentInfo(
            tokenContract,
            tokenId,
            seller
        );
        return isCreator && !_isPrimaryAuctionFinished[tokenContract][tokenId];
    }

    function _payRecipients(
        address tokenContract,
        address payable seller,
        address payable firstOwnerAddress,
        uint256 tokenId,
        uint256 price
    ) internal returns (Revenues memory revs) {
        (
            address payable creatorAddress,
            bool isCreator
        ) = _getCreatorPaymentInfo(tokenContract, tokenId, seller);

        bool isNotFirstOwner = address(0) != firstOwnerAddress &&
            seller != firstOwnerAddress;
        revs = _getRevenues(
            price,
            isCreator,
            _isPrimaryAuctionFinished[tokenContract][tokenId],
            isNotFirstOwner
        );

        // Setting the sale count must come after _getRevenues, as it is used in that function
        _isPrimaryAuctionFinished[tokenContract][tokenId] = true;

        _sendValueToRecipient(getBlockMelonTreasury(), revs.marketRevenue);
        // creatorRevenue is zero if it is a primary sale and/or if the creator is the seller
        // In both cases the sellerRevenue is sent to the creatoraddress
        _sendValueToRecipient(creatorAddress, revs.creatorRevenue);
        // firstOwnerRevenue is zero if the first owner is invalid or it is the seller
        // In the latter case the sellerRevenue is sent to the firstOwnerAddress
        _sendValueToRecipient(firstOwnerAddress, revs.firstOwnerRevenue);
        _sendValueToRecipient(seller, revs.sellerRevenue);
    }

    function _getRevenues(
        uint256 price,
        bool isCreator,
        bool isPrimaryAuctionFinished,
        bool isNotFirstOwner
    ) internal view returns (Revenues memory revs) {
        (
            uint256 primaryBlockMelonFeeInBps,
            uint256 secondaryBlockMelonFeeInBps,
            uint256 secondaryCreatorFeeInBps,
            uint256 secondaryFirstOwnerFeeInBps
        ) = getFeeConfig();

        uint256 blockMelonFeeFeeInBps;
        if (isCreator && !isPrimaryAuctionFinished) {
            blockMelonFeeFeeInBps = primaryBlockMelonFeeInBps;
        } else {
            blockMelonFeeFeeInBps = secondaryBlockMelonFeeInBps;
            if (!isCreator) {
                revs.creatorRevenue =
                    (price * secondaryCreatorFeeInBps) /
                    BASIS_POINTS;
            }
        }
        // Always calculate the revenue of the first owner, if it is a valid address and not the seller
        if (isNotFirstOwner) {
            revs.firstOwnerRevenue =
                (price * secondaryFirstOwnerFeeInBps) /
                BASIS_POINTS;
        }

        revs.marketRevenue = (price * blockMelonFeeFeeInBps) / BASIS_POINTS;
        revs.sellerRevenue =
            price -
            revs.marketRevenue -
            revs.creatorRevenue -
            revs.firstOwnerRevenue;
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../interfaces/IBlockMelonTreasury.sol";

abstract contract BlockMelonTreasury is IBlockMelonTreasury, Initializable {
    using AddressUpgradeable for address payable;

    /// @notice Emitted when the treasury address is updated
    event TreasuryUpdated(address indexed treasury);

    /// @notice The payment address of BlockMelon treasury
    address payable private _treasury;

    function __BlockMelonTreasury_init_unchained(
        address payable blockMelonTreasury
    ) internal onlyInitializing {
        _setBlockMelonTreasury(blockMelonTreasury);
    }

    function _setBlockMelonTreasury(address payable newTreasury) internal {
        require(newTreasury.isContract(), "address is not a contract");
        _treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    /**
     * @dev See {IBlockMelonTreasury-getBlockMelonTreasury}
     */
    function getBlockMelonTreasury()
        public
        view
        override
        returns (address payable)
    {
        return _treasury;
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../interfaces/IBlockMelonMarketConfig.sol";

abstract contract BlockMelonMarketConfig is
    IBlockMelonMarketConfig,
    Initializable
{
    /// @notice Emitted when the market fees are updated
    event MarketFeesUpdated(
        uint256 primaryBlockMelonFeeInBps,
        uint256 secondaryBlockMelonFeeInBps,
        uint256 secondaryCreatorFeeInBps,
        uint256 secondaryFirstOwnerFeeInBps
    );

    /// @dev Fees that BlockMelon recieves after the primary sale
    uint256 private _primaryBlockMelonFeeInBps;
    /// @dev Fees that BlockMelon recieves after secondary a secondary sale
    uint256 private _secondaryBlockMelonFeeInBps;
    /// @dev Fees that the token creator recieves after a secondary sale
    uint256 private _secondaryCreatorFeeInBps;
    /// @dev Fees that the very first owner of a token recieves after a secondary sale
    uint256 private _secondaryFirstOwnerFeeInBps;
    uint256 private constant BASIS_POINTS = 10000;

    function __BlockMelonMarketConfig_init_unchained(
        uint256 primaryBlockMelonFeeInBps,
        uint256 secondaryBlockMelonFeeInBps,
        uint256 secondaryCreatorFeeInBps,
        uint256 secondaryFirstOwnerFeeInBps
    ) internal onlyInitializing {
        _updateFeesConfig(
            primaryBlockMelonFeeInBps,
            secondaryBlockMelonFeeInBps,
            secondaryCreatorFeeInBps,
            secondaryFirstOwnerFeeInBps
        );
    }

    /**
     * @dev See {IBlockMelonMarketConfig-getFeeConfig}
     */
    function getFeeConfig()
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _primaryBlockMelonFeeInBps,
            _secondaryBlockMelonFeeInBps,
            _secondaryCreatorFeeInBps,
            _secondaryFirstOwnerFeeInBps
        );
    }

    function _updateFeesConfig(
        uint256 primaryBlockMelonFeeInBps,
        uint256 secondaryBlockMelonFeeInBps,
        uint256 secondaryCreatorFeeInBps,
        uint256 secondaryFirstOwnerFeeInBps
    ) internal {
        require(
            primaryBlockMelonFeeInBps < BASIS_POINTS,
            "primary fee >= 100%"
        );
        require(
            secondaryBlockMelonFeeInBps +
                secondaryCreatorFeeInBps +
                secondaryFirstOwnerFeeInBps <
                BASIS_POINTS,
            "secondary fees >= 100%"
        );
        _primaryBlockMelonFeeInBps = primaryBlockMelonFeeInBps;
        _secondaryBlockMelonFeeInBps = secondaryBlockMelonFeeInBps;
        _secondaryCreatorFeeInBps = secondaryCreatorFeeInBps;
        _secondaryFirstOwnerFeeInBps = secondaryFirstOwnerFeeInBps;

        emit MarketFeesUpdated(
            primaryBlockMelonFeeInBps,
            secondaryBlockMelonFeeInBps,
            secondaryCreatorFeeInBps,
            secondaryFirstOwnerFeeInBps
        );
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// originally implemented at 0x005d77e5eeab2f17e62a11f1b213736ca3c05cf6
interface ITokenCreatorPaymentAddress {
    function getTokenCreatorPaymentAddress(uint256 tokenId)
        external
        view
        returns (address payable tokenCreatorPaymentAddress);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// originally implemented at 0x005d77e5eeab2f17e62a11f1b213736ca3c05cf6
interface ITokenCreator {
    /**
     * @notice Returns the address of the creator for the given `tokenId`.
     */
    function tokenCreator(uint256 tokenId)
        external
        view
        returns (address payable);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev An interface representing ownable assests
 */
interface IOwnable {
    /**
     * @notice Returns the address of the current owner.
     */
    function owner() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @notice An interface for communicating fees to 3rd party marketplaces.
 * @dev Originally implemented in mainnet contract 0x44d6e8933f8271abcf253c72f9ed7e0e4c0323b3
 */
interface IHasSecondarySaleFees {
    /**
     * @notice Returns the recipients that are eligible for royalty
     */
    function getFeeRecipients(uint256 id)
        external
        view
        returns (address payable[] memory);

    /**
     * @notice Returns the fees for a given token id in basis points
     */
    function getFeeBps(uint256 id) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// From 0xc9fe4ffc4be41d93a1a7189975cd360504ee361a
interface IGetRoyalties {
    function getRoyalties(uint256 tokenId)
        external
        view
        returns (
            address payable[] memory recipients,
            uint256[] memory feesInBasisPoints
        );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFirstOwner {
    /**
     * @notice Returns the address of the first owner of the given `tokenId`.
     */
    function firstOwner(uint256 tokenId)
        external
        view
        returns (address payable);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBlockMelonTreasury {
    /**
     * @notice Returns the address of the treasury
     */
    function getBlockMelonTreasury() external view returns (address payable);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBlockMelonMarketConfig {
    /**
     * @notice Returns the market fee configarion values in basis points
     */
    function getFeeConfig()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @notice Interface for admin role handling
 */
interface IAdminRole {
    function isAdmin(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../interfaces/IAdminRole.sol";
import "../utils/ERC721TokenReceiver.sol";
import "../payment/BlockMelonNFTPaymentManager.sol";

/**
 * @notice An abstraction layer for a token market.
 */
abstract contract NFTReserveAuction is
    ContextUpgradeable,
    BlockMelonNFTPaymentManager,
    ERC721TokenReceiver
{
    using AddressUpgradeable for address;

    struct Auction {
        address tokenContract;
        uint256 tokenId;
        address payable seller;
        uint256 duration;
        uint256 extensionDuration;
        uint256 endTime;
        address payable bidder;
        uint256 price;
    }

    event ReserveAuctionConfigUpdated(
        uint256 minPercentIncrementInBasisPoints,
        uint256 duration
    );
    event AuctionCreated(
        address indexed seller,
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 duration,
        uint256 extensionDuration,
        uint256 reservePrice,
        uint256 auctionId
    );
    event AuctionUpdated(
        uint256 indexed auctionId,
        uint256 indexed newReservePrice
    );
    event ReserveAuctionBidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 price,
        uint256 endTime
    );
    event AuctionFinalized(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed bidder,
        uint256 blockMelonRevenue,
        uint256 creatorRevenue,
        uint256 sellerRevenue,
        uint256 firstOwnerRevenue
    );
    event AuctionCanceled(uint256 indexed auctionId);
    event AuctionCanceledByAdmin(uint256 indexed auctionId, string reason);
    event AdminContractUpdated(address indexed adminContract);

    /// @dev Indicates the maximum duration of an acution
    uint256 private constant MAX_DURATION = 365 days;
    /// @dev Indicates the extension duration of an acution
    uint256 private constant EXTENSION_DURATION = 15 minutes;
    uint256 private constant BASIS_POINTS = 10000;
    ///@dev The contract address which manages admin accounts
    IAdminRole public adminContract;
    /// @dev Keeps track of each NFT auction per token contract
    mapping(address => mapping(uint256 => uint256))
        private _nftContractToTokenIdToAuctionId;
    /// @dev Mapping from each auction id to its auction data
    mapping(uint256 => Auction) private _auctionIdToAuction;
    /// @dev Indicates the minimum required amount for a bid increment [bps]
    uint256 private _minPercentIncrementInBasisPoints;
    /// @dev Indicates the duration of an acution
    uint256 private _duration;
    /// @dev The id of the current auction
    uint256 private _auctionId;

    modifier onlyValidAuctionConfig(uint256 price) {
        require(price > 0, "Price must be > 0");
        _;
    }

    modifier onlyBlockMelonAdmin() {
        require(
            adminContract.isAdmin(_msgSender()),
            "caller is not a BlockMelon admin"
        );
        _;
    }

    function __NFTReserveAuction_init_unchained() internal onlyInitializing {
        _auctionId = 1;
        _duration = 24 hours;
        _minPercentIncrementInBasisPoints = 1000; // 10% by default
    }

    function _updateAdminContract(address _adminContract) internal {
        require(_adminContract.isContract(), "adminContract is not a contract");
        adminContract = IAdminRole(_adminContract);

        emit AdminContractUpdated(_adminContract);
    }

    /**
     * @notice Returns auction details for a given auctionId.
     */
    function getAuction(uint256 auctionId)
        public
        view
        returns (Auction memory)
    {
        return _auctionIdToAuction[auctionId];
    }

    /**
     * @notice Returns the auctionId for a given NFT, or 0 if no auction is found.
     * @dev If an auction is canceled, it will not be returned. However the auction may be over and pending finalization.
     */
    function getAuctionIdFor(address tokenContract, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return _nftContractToTokenIdToAuctionId[tokenContract][tokenId];
    }

    /**
     * @notice Returns the current configuration for reserve auctions.
     */
    function getReserveAuctionConfig()
        public
        view
        returns (uint256 minPercentIncrementInBasisPoints, uint256 duration)
    {
        minPercentIncrementInBasisPoints = _minPercentIncrementInBasisPoints;
        duration = _duration;
    }

    function _getNextAndIncrementAuctionId() internal returns (uint256) {
        return _auctionId++;
    }

    function _updateReserveAuctionConfig(
        uint256 minPercentIncrementInBasisPoints,
        uint256 duration
    ) internal {
        require(
            minPercentIncrementInBasisPoints <= BASIS_POINTS,
            "Min increment must be <= 100%"
        );
        require(duration <= MAX_DURATION, "Duration must be <= 365 days");
        require(
            duration >= EXTENSION_DURATION,
            "Duration must be >= EXTENSION_DURATION"
        );
        _minPercentIncrementInBasisPoints = minPercentIncrementInBasisPoints;
        _duration = duration;

        emit ReserveAuctionConfigUpdated(
            minPercentIncrementInBasisPoints,
            duration
        );
    }

    /**
     * @notice Creates an auction for the given NFT.
     *         The NFT is held in escrow until the auction is finalized or canceled.
     */
    function createReserveAuction(
        address tokenContract,
        uint256 tokenId,
        uint256 price
    ) public onlyValidAuctionConfig(price) nonReentrant {
        // If an auction is already in progress then the NFT would be in escrow and the modifier would have failed
        uint256 auctionId = _getNextAndIncrementAuctionId();
        _nftContractToTokenIdToAuctionId[tokenContract][tokenId] = auctionId;

        _auctionIdToAuction[auctionId] = Auction(
            tokenContract,
            tokenId,
            payable(_msgSender()),
            _duration,
            EXTENSION_DURATION,
            0, // endTime is only known once the reserve price is met
            payable(address(0)), // bidder is only known once a bid has been placed
            price
        );

        IERC721Upgradeable(tokenContract).safeTransferFrom(
            _msgSender(),
            address(this),
            tokenId
        );

        emit AuctionCreated(
            _msgSender(),
            tokenContract,
            tokenId,
            _duration,
            EXTENSION_DURATION,
            price,
            auctionId
        );
    }

    /**
     * @notice If an auction has been created but has not yet received bids, the configuration
     *          such as the reserve price may be changed by the seller.
     */
    function updateAuction(uint256 auctionId, uint256 newReservePrice)
        public
        onlyValidAuctionConfig(newReservePrice)
    {
        Auction storage auction = _auctionIdToAuction[auctionId];
        require(auction.seller == payable(_msgSender()), "Not your auction");
        require(auction.endTime == 0, "Auction in progress");

        auction.price = newReservePrice;

        emit AuctionUpdated(auctionId, newReservePrice);
    }

    /**
     * @notice If an auction has been created but has not yet received bids, it may be canceled by the seller.
     * The NFT is returned to the seller from escrow.
     */
    function cancelAuction(uint256 auctionId) public nonReentrant {
        Auction memory auction = _auctionIdToAuction[auctionId];
        require(auction.seller == payable(_msgSender()), "Not your auction");
        require(auction.endTime == 0, "Auction in progress");

        delete _nftContractToTokenIdToAuctionId[auction.tokenContract][
            auction.tokenId
        ];
        delete _auctionIdToAuction[auctionId];

        IERC721Upgradeable(auction.tokenContract).safeTransferFrom(
            address(this),
            auction.seller,
            auction.tokenId
        );

        emit AuctionCanceled(auctionId);
    }

    /**
     * @notice A bidder may place a bid which is at least the value defined by `getMinBidAmount`.
     * If this is the first bid on the auction, the countdown will begin.
     * If there is already an outstanding bid, the previous bidder will be refunded at this time
     * and if the bid is placed in the final moments of the auction, the countdown may be extended.
     */
    function placeBid(uint256 auctionId) public payable nonReentrant {
        Auction storage auction = _auctionIdToAuction[auctionId];
        require(auction.price != 0, "Auction not found");

        if (auction.endTime == 0) {
            // If this is the first bid, ensure it's >= the reserve price
            require(
                auction.price <= msg.value,
                "Bid must be at least the reserve price"
            );
        } else {
            // If this bid outbids another, confirm that the bid is at least x% greater than the last
            require(auction.endTime >= block.timestamp, "Auction is over");
            require(
                auction.bidder != payable(_msgSender()),
                "You already have an outstanding bid"
            );
            uint256 minAmount = _getMinBidAmountForReserveAuction(
                auction.price
            );
            require(msg.value >= minAmount, "Bid amount too low");
        }

        if (auction.endTime == 0) {
            auction.price = msg.value;
            auction.bidder = payable(_msgSender());
            // On the first bid, the endTime is now + duration
            auction.endTime = block.timestamp + auction.duration;
        } else {
            // Cache and update bidder state before a possible reentrancy (via the value transfer)
            uint256 originalAmount = auction.price;
            address payable originalBidder = auction.bidder;
            auction.price = msg.value;
            auction.bidder = payable(_msgSender());

            // When a bid outbids another, check to see if a time extension should apply.
            if (auction.endTime - block.timestamp < auction.extensionDuration) {
                auction.endTime = block.timestamp + auction.extensionDuration;
            }

            // Refund the previous bidder
            _sendValueToRecipient(originalBidder, originalAmount);
        }

        emit ReserveAuctionBidPlaced(
            auctionId,
            _msgSender(),
            msg.value,
            auction.endTime
        );
    }

    /**
     * @notice Once the countdown has expired for an auction, anyone can settle the auction.
     * This will send the NFT to the highest bidder and distribute funds.
     */
    function finalizeReserveAuction(uint256 auctionId) public nonReentrant {
        Auction memory auction = _auctionIdToAuction[auctionId];
        require(auction.endTime > 0, "Auction was already settled");
        require(auction.endTime < block.timestamp, "Auction still in progress");

        delete _nftContractToTokenIdToAuctionId[auction.tokenContract][
            auction.tokenId
        ];
        delete _auctionIdToAuction[auctionId];

        // cache the first owner address before transfer, as _transfer may set it
        address payable firstOwnerAddress = _getFirstOwnerPaymentInfo(
            auction.tokenContract,
            auction.tokenId
        );

        IERC721Upgradeable(auction.tokenContract).safeTransferFrom(
            address(this),
            auction.bidder,
            auction.tokenId
        );

        Revenues memory revs = _payRecipients(
            auction.tokenContract,
            auction.seller,
            firstOwnerAddress,
            auction.tokenId,
            auction.price
        );

        emit AuctionFinalized(
            auctionId,
            auction.seller,
            auction.bidder,
            revs.marketRevenue,
            revs.creatorRevenue,
            revs.sellerRevenue,
            revs.firstOwnerRevenue
        );
    }

    /**
     * @notice Returns the minimum amount a bidder must spend to participate in an auction.
     */
    function getMinBidAmount(uint256 auctionId) public view returns (uint256) {
        Auction storage auction = _auctionIdToAuction[auctionId];
        if (auction.endTime == 0) {
            return auction.price;
        }
        return _getMinBidAmountForReserveAuction(auction.price);
    }

    /**
     * @dev Determines the minimum bid amount when outbidding another user.
     */
    function _getMinBidAmountForReserveAuction(uint256 currentBidAmount)
        private
        view
        returns (uint256)
    {
        uint256 minIncrement = (currentBidAmount *
            _minPercentIncrementInBasisPoints) / BASIS_POINTS;
        if (minIncrement == 0) {
            // The next bid must be at least 1 wei greater than the current.
            return currentBidAmount++;
        }
        return minIncrement + currentBidAmount;
    }

    /**
     * @notice Allows BlockMelon to cancel an auction, refunding the bidder and returning the NFT to the seller.
     * This should only be used for extreme cases such as DMCA takedown requests. The reason should always be provided.
     */
    function adminCancelAuction(uint256 auctionId, string memory reason)
        public
        onlyBlockMelonAdmin
    {
        require(
            bytes(reason).length > 0,
            "Include a reason for this cancellation"
        );
        Auction memory auction = _auctionIdToAuction[auctionId];
        require(auction.price > 0, "Auction not found");

        delete _nftContractToTokenIdToAuctionId[auction.tokenContract][
            auction.tokenId
        ];
        delete _auctionIdToAuction[auctionId];

        IERC721Upgradeable(auction.tokenContract).safeTransferFrom(
            address(this),
            auction.seller,
            auction.tokenId
        );

        if (auction.bidder != address(0)) {
            _sendValueToRecipient(auction.bidder, auction.price);
        }

        emit AuctionCanceledByAdmin(auctionId, reason);
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
// OpenZeppelin Contracts v4.4.1 (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "../../access/OwnableUpgradeable.sol";
import "../AddressUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds designated for a payee until they
 * withdraw them.
 *
 * Intended usage: This contract (and derived escrow contracts) should be a
 * standalone contract, that only interacts with the contract that instantiated
 * it. That way, it is guaranteed that all Ether will be handled according to
 * the `Escrow` rules, and there is no need to check for payable functions or
 * transfers in the inheritance tree. The contract that uses the escrow as its
 * payment method should be its owner, and provide public methods redirecting
 * to the escrow's deposit and withdraw.
 */
contract EscrowUpgradeable is Initializable, OwnableUpgradeable {
    function __Escrow_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Escrow_init_unchained() internal onlyInitializing {
    }
    function initialize() public virtual initializer {
        __Escrow_init();
    }
    using AddressUpgradeable for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param payee The destination address of the funds.
     */
    function deposit(address payee) public payable virtual onlyOwner {
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param payee The address whose funds will be withdrawn and transferred to.
     */
    function withdraw(address payable payee) public virtual onlyOwner {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
interface IERC721ReceiverUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (security/PullPayment.sol)

pragma solidity ^0.8.0;

import "../utils/escrow/EscrowUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Simple implementation of a
 * https://consensys.github.io/smart-contract-best-practices/recommendations/#favor-pull-over-push-for-external-calls[pull-payment]
 * strategy, where the paying contract doesn't interact directly with the
 * receiver account, which must withdraw its payments itself.
 *
 * Pull-payments are often considered the best practice when it comes to sending
 * Ether, security-wise. It prevents recipients from blocking execution, and
 * eliminates reentrancy concerns.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * To use, derive from the `PullPayment` contract, and use {_asyncTransfer}
 * instead of Solidity's `transfer` function. Payees can query their due
 * payments with {payments}, and retrieve them with {withdrawPayments}.
 *
 * @custom:storage-size 51
 */
abstract contract PullPaymentUpgradeable is Initializable {
    EscrowUpgradeable private _escrow;

    function __PullPayment_init() internal onlyInitializing {
        __PullPayment_init_unchained();
    }

    function __PullPayment_init_unchained() internal onlyInitializing {
        _escrow = new EscrowUpgradeable();
        _escrow.initialize();
    }

    /**
     * @dev Withdraw accumulated payments, forwarding all gas to the recipient.
     *
     * Note that _any_ account can call this function, not just the `payee`.
     * This means that contracts unaware of the `PullPayment` protocol can still
     * receive funds this way, by having a separate account call
     * {withdrawPayments}.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param payee Whose payments will be withdrawn.
     */
    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    /**
     * @dev Returns the payments owed to an address.
     * @param dest The creditor's address.
     */
    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    /**
     * @dev Called by the payer to store the sent amount as credit to be pulled.
     * Funds sent in this way are stored in an intermediate {Escrow} contract, so
     * there is no danger of them being spent before withdrawal.
     *
     * @param dest The destination address of the funds.
     * @param amount The amount to transfer.
     */
    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{value: amount}(dest);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}