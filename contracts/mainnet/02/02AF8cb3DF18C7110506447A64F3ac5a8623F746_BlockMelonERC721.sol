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

import "./BlockMelonERC721Minter.sol";

/**
 * @title BlockMelonERC721
 * @author BlockMelon
 * @dev A 'tradable' implementation of the standard {ERC721} by OpenZeppelin.
 *      See https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol.
 *      Based on the code by Rarible and Foundation.
 *          See https://github.com/rarible/protocol-contracts/blob/master/tokens/contracts/erc-721/ERC721Rarible.sol
 *          See 0x93249388a3d98fd2412429a78bdd43691cc1508b `FNDNFT721.sol`
 */
contract BlockMelonERC721 is BlockMelonERC721Minter {
    /// @notice Emitted when the token contract is created
    event CreateBlockMelonERC721(
        address indexed creator,
        string name,
        string symbol
    );

    function __BlockMelonERC721_init(
        string memory contractName,
        string memory tokenSymbol,
        string memory baseURI_,
        address market,
        address treasury,
        address _adminContract,
        address _approvalContract
    ) external initializer {
        __BlockMelonERC721_init_unchained(
            contractName,
            tokenSymbol,
            baseURI_,
            market,
            treasury
        );
        _updateAdminContract(_adminContract);
        _updateApprovalContract(_approvalContract);
        _setDefaultApprovedMarket(market);
        emit CreateBlockMelonERC721(_msgSender(), contractName, tokenSymbol);
    }

    function __BlockMelonERC721_init_unchained(
        string memory contractName,
        string memory tokenSymbol,
        string memory baseURI_,
        address market,
        address treasury
    ) internal {
        __Context_init_unchained();
        __ERC165_init_unchained();
        _setBaseURI(baseURI_);
        __ERC721_init_unchained(contractName, tokenSymbol);
        __ERC721URIStorage_init_unchained();
        __BlockMelonERC721TokenBase_init_unchained();
        __BlockMelonERC721Creator_init_unchained();
        __BlockMelonERC721LockedContent_init_unchained();
        __BlockMelonERC721FirstOwners_init_unchained();
        __BlockMelonERC721RoyaltyInfo_init_unchained(market, treasury);
        __BlockMelonERC721Minter_init_unchained();
    }

    /**
     * @dev Allows a BlockMelon admin to update the market and treasury contract addresses
     */
    function updateMarketAndTreasury(address market, address treasury)
        external
        onlyBlockMelonAdmin
    {
        _updateMarketAndTreasury(market, treasury);
    }

    /**
     * @notice Allows a BlockMelon admin to change the admin contract address.
     */
    function updateAdminContract(address _adminContract)
        external
        onlyBlockMelonAdmin
    {
        _updateAdminContract(_adminContract);
    }

    /**
     * @notice Allows a BlockMelon admin to change the creator approval contract address.
     */
    function updateApprovalContract(address _approvalContract)
        external
        onlyBlockMelonAdmin
    {
        _updateApprovalContract(_approvalContract);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

/**
 * @dev This layer stores the corresponding URI of each token ID
 * Furthermore, it stores the default approved market address so that it is allowed to transfer each token ID
 */
abstract contract BlockMelonERC721TokenBase is ERC721URIStorageUpgradeable {
    using StringsUpgradeable for uint256;

    /// @notice Emitted when the URI of `tokenId` is set
    event URI(string value, uint256 indexed tokenId);
    /// @notice Emitted when the default approved operator address is changed
    event DefaultApprovedMarket(address indexed operator);

    /// @dev Storing the address of the default approved operator, i.e.: the BlockMelon market contract
    address public defaultApprovedMarket;
    /// @dev Base URI for all of the token IDs
    string private baseURI_;

    modifier onylExisting(uint256 tokenId) {
        require(_exists(tokenId), "query for nonexistent token");
        _;
    }

    function __BlockMelonERC721TokenBase_init_unchained()
        internal
        onlyInitializing
    {}

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     *      token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI();
    }

    /**
     * @dev See {ERC721Upgradeable__baseURI}
     */
    function _baseURI() internal view virtual override returns (string memory) {
        if (bytes(baseURI_).length > 0) {
            return baseURI_;
        }
        return "ipfs://";
    }

    /**
     * @dev Internal function to set the base URI for all token IDs.
     */
    function _setBaseURI(string memory newBaseURI) internal virtual {
        baseURI_ = newBaseURI;
    }

    function _setTokenURI(uint256 tokenId, string memory newUri)
        internal
        virtual
        override
    {
        require(0 != bytes(newUri).length, "empty token uri");
        super._setTokenURI(tokenId, newUri);
        emit URI(newUri, tokenId);
    }

    /**
     * @dev See {ERC721Upgradeable-_isApprovedOrOwner}
     * This version adds default approval for operators, i.e.: the BlockMelon market contract
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        override
        returns (bool)
    {
        return
            spender == defaultApprovedMarket ||
            super._isApprovedOrOwner(spender, tokenId);
    }

    /**
     * @dev See {ERC721Upgradeable-isApprovedForAll}
     * This version adds default approval for operators, i.e.: the BlockMelon market contract
     */
    function isApprovedForAll(address _owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            operator == defaultApprovedMarket ||
            super.isApprovedForAll(_owner, operator);
    }

    function _setDefaultApprovedMarket(address operator) internal {
        defaultApprovedMarket = operator;
        emit DefaultApprovedMarket(operator);
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

import "../../interfaces/IBlockMelonMarketConfig.sol";
import "../../interfaces/IBlockMelonTreasury.sol";
import "../../interfaces/IGetRoyalties.sol";
import "../../interfaces/IHasSecondarySaleFees.sol";
import "./BlockMelonERC721FirstOwners.sol";

/**
 * @notice Holds a reference to the BlockMelon Market and communicates fees to 3rd party marketplaces.
 * @dev Based on: 0x93249388a3d98fd2412429a78bdd43691cc1508b `NFT721Market.sol`
 * This abstraction layer is reponsible for setting the first owner of each token ID during transfer.
 */
abstract contract BlockMelonERC721RoyaltyInfo is
    IHasSecondarySaleFees,
    IGetRoyalties,
    IERC2981Upgradeable,
    BlockMelonERC721FirstOwners
{
    using AddressUpgradeable for address;
    /// @dev Emitted when either the market or the treasury address is updated
    event MarketAndTreasuryUpdated(
        address indexed market,
        address indexed treasury
    );

    /*
     * bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
     * bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
     *
     * => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
     */
    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
    /// @dev bytes4(keccak256('getRoyalties(address)')) == bb3bafd6
    bytes4 private constant _INTERFACE_ID_ROYALTIES = 0xbb3bafd6;
    uint256 private constant BASIS_POINTS = 10000;
    /// @dev The address of the BlockMelon treasury
    IBlockMelonTreasury private _treasury;
    /// @dev The address of the BlockMelon token market
    IBlockMelonMarketConfig private _market;

    /// @dev Initializes the market and treasury addresses
    function __BlockMelonERC721RoyaltyInfo_init_unchained(
        address market,
        address treasury
    ) internal onlyInitializing {
        _updateMarketAndTreasury(market, treasury);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BlockMelonERC721FirstOwners, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == _INTERFACE_ID_ROYALTIES ||
            interfaceId == _INTERFACE_ID_FEES ||
            interfaceId == type(IERC2981Upgradeable).interfaceId ||
            BlockMelonERC721FirstOwners.supportsInterface(interfaceId);
    }

    /**
     * @notice Returns the address of the BlockMelon market contract.
     */
    function getMarket() public view returns (address) {
        return address(_market);
    }

    /**
     * @notice Returns the address of the BlockMelon treasury contract.
     */
    function getTreasury() public view returns (address) {
        return _treasury.getBlockMelonTreasury();
    }

    function _updateMarketAndTreasury(address market, address treasury)
        internal
        isContract(market)
        isContract(treasury)
    {
        _market = IBlockMelonMarketConfig(market);
        _treasury = IBlockMelonTreasury(treasury);
        _setDefaultApprovedMarket(market);
        emit MarketAndTreasuryUpdated(market, treasury);
    }

    /**
     * @notice Returns an array of recipient addresses to which fees should be sent.
     * The expected fee amount is communicated with `getFeeBps`.
     */
    function getFeeRecipients(uint256 tokenId)
        public
        view
        override
        onylExisting(tokenId)
        returns (address payable[] memory)
    {
        address payable[] memory result = new address payable[](3);
        result[0] = _treasury.getBlockMelonTreasury();
        result[1] = tokenCreator(tokenId);
        result[2] = firstOwner(tokenId);
        return result;
    }

    /**
     * @notice Returns an array of fees in basis points.
     * The expected recipients is communicated with `getFeeRecipients`.
     */
    function getFeeBps(
        uint256 /* tokenId */
    ) public view override returns (uint256[] memory) {
        (
            ,
            uint256 secondaryBlockMelonFeeInBps,
            uint256 secondaryCreatorFeeInBps,
            uint256 secondaryFirstOwnerFeeInBps
        ) = _market.getFeeConfig();
        uint256[] memory feesInBasisPoints = new uint256[](3);
        feesInBasisPoints[0] = secondaryBlockMelonFeeInBps;
        feesInBasisPoints[1] = secondaryCreatorFeeInBps;
        feesInBasisPoints[2] = secondaryFirstOwnerFeeInBps;
        return feesInBasisPoints;
    }

    /**
     * @notice Get fee recipients and fees in a single call.
     * The data is the same as when calling getFeeRecipients and getFeeBps separately.
     */
    function getRoyalties(uint256 tokenId)
        public
        view
        override
        onylExisting(tokenId)
        returns (
            address payable[] memory recipients,
            uint256[] memory feesInBasisPoints
        )
    {
        recipients = new address payable[](3);
        recipients[0] = _treasury.getBlockMelonTreasury();
        recipients[1] = tokenCreator(tokenId);
        recipients[2] = firstOwner(tokenId);
        (
            ,
            uint256 secondaryBlockMelonFeeInBps,
            uint256 secondaryCreatorFeeInBps,
            uint256 secondaryFirstOwnerFeeInBps
        ) = _market.getFeeConfig();
        feesInBasisPoints = new uint256[](3);
        feesInBasisPoints[0] = secondaryBlockMelonFeeInBps;
        feesInBasisPoints[1] = secondaryCreatorFeeInBps;
        feesInBasisPoints[2] = secondaryFirstOwnerFeeInBps;
    }

    /**
     * @notice Return the royalty percantage of the creator
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = tokenCreator(tokenId);
        (, , uint256 secondaryCreatorFeeInBps, ) = _market.getFeeConfig();
        royaltyAmount = (salePrice * secondaryCreatorFeeInBps) / BASIS_POINTS;
    }

    /**
     * @dev See {ERC721-_transfer}
     * @dev Sets `to` as the first owner of `tokenId`, if it is not set yet
     * and if `to` is neither the creator nor the `defaultApprovedMarket` contract
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._transfer(from, to, tokenId);

        if (to != defaultApprovedMarket) {
            _setFirstOwner(tokenId, to);
        }
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BlockMelonERC721RoyaltyInfo.sol";

abstract contract BlockMelonERC721Minter is BlockMelonERC721RoyaltyInfo {
    event Minted(
        address indexed creator,
        uint256 indexed tokenId,
        string indexed indexedTokenCID,
        string tokenCID
    );

    /**
     * @notice Indicates the latest token ID, initially 0.
     * @dev Minting starts at tokenId 1. Each mint will use this value + 1.
     */
    uint256 public latestTokenId;

    function __BlockMelonERC721Minter_init_unchained()
        internal
        onlyInitializing
    {}

    /**
     * @notice Sets the base URI for all token ID.
     */
    function setBaseURI(string memory newBaseUri) external onlyBlockMelonAdmin {
        _setBaseURI(newBaseUri);
    }

    /**
     * @dev Creates a new NFT at the address of msg.sender
     * @param tokenUri       Metadata URI of the NFT ID
     * @param lockedContent  Optional locked content of the NFT ID
     * @dev Requirements:
     *       - caller must be an approved creator
     *       - tokenUri must be non-empty
     * @return tokenId The newly minted token ID
     */
    function mint(string memory tokenUri, string memory lockedContent)
        public
        returns (uint256 tokenId)
    {
        require(
            approvalContract.isApprovedCreator(_msgSender()),
            "caller is not approved"
        );

        tokenId = ++latestTokenId;
        _safeMint(_msgSender(), tokenId);
        _setCreator(tokenId, _msgSender());
        _setTokenURI(tokenId, tokenUri);
        _setLockedContent(tokenId, lockedContent);
        emit Minted(_msgSender(), tokenId, tokenUri, tokenUri);
    }

    /**
     * @dev Burns a token ID from account's balance. Allows the creator to burn if currently owns it.
     * @param tokenId  The token ID that shall be burned.
     */
    function burn(uint256 tokenId) public {
        address caller = _msgSender();
        address creator = tokenCreator(tokenId);
        require(
            caller == creator || isApprovedForAll(creator, caller),
            "caller is neither the creator nor approved"
        );
        require(creator == ownerOf(tokenId), "creator is not the token owner");

        _burn(tokenId);
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/ILockedContent.sol";
import "./BlockMelonERC721Creator.sol";

abstract contract BlockMelonERC721LockedContent is
    ILockedContent,
    BlockMelonERC721Creator
{
    /// @notice Emitted when `tokenId` is created. `hasLockedContent` indicates if it has a locked content
    event LockedContent(uint256 tokenId, bool hasLockedContent);

    /// @dev bytes4(keccak256('getLockedContent(uint256)')) == 1c7e78f3
    bytes4 private constant _INTERFACE_ID_LOCKED_CONTENT = 0x1c7e78f3;
    /// @dev Mapping from each NFT ID to its optionally locked content
    mapping(uint256 => string) private _lockedContent;

    function __BlockMelonERC721LockedContent_init_unchained()
        internal
        onlyInitializing
    {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            _INTERFACE_ID_LOCKED_CONTENT == interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @notice See  {ILockedContent-getLockedContent}.
     * @dev Requirements:
     *      - caller must either be the creator or the owner of `tokenId`
     */
    function getLockedContent(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        bool isOwner = _msgSender() == ownerOf(tokenId);
        bool isCreator = _msgSender() == tokenCreator(tokenId);
        require(isOwner || isCreator, "caller is not the owner or the creator");
        return _lockedContent[tokenId];
    }

    function _setLockedContent(uint256 tokenId, string memory lockedContent)
        internal
        virtual
    {
        if (0 != bytes(lockedContent).length) {
            _lockedContent[tokenId] = lockedContent;
            emit LockedContent(tokenId, true);
        }
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete _lockedContent[tokenId];
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../../interfaces/IFirstOwner.sol";
import "./BlockMelonERC721LockedContent.sol";

abstract contract BlockMelonERC721FirstOwners is
    IFirstOwner,
    BlockMelonERC721LockedContent
{
    /// @notice Emitted when `tokenId` is has its first owner
    event FirstOwner(address indexed owner, uint256 tokenId);

    /// @dev bytes4(keccak256('firstOwner(tokenId)')) == 0xf46c892e
    bytes4 private constant _INTERFACE_ID_FIRST_OWNER = 0xf46c892e;
    /// @dev Mapping from each NFT ID to its first owner
    mapping(uint256 => address payable) private _firstOwners;

    function __BlockMelonERC721FirstOwners_init_unchained()
        internal
        onlyInitializing
    {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            _INTERFACE_ID_FIRST_OWNER == interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IFirstOwner-firstOwner}
     */
    function firstOwner(uint256 tokenId)
        public
        view
        override
        returns (address payable)
    {
        return _firstOwners[tokenId];
    }

    function _setFirstOwner(uint256 tokenId, address account) internal virtual {
        if (
            address(0) == _firstOwners[tokenId] &&
            tokenCreator(tokenId) != account
        ) {
            _firstOwners[tokenId] = payable(account);
            emit FirstOwner(account, tokenId);
        }
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../../interfaces/IAdminRole.sol";
import "../../interfaces/ITokenCreator.sol";
import "../../interfaces/ICreatorApproval.sol";
import "./BlockMelonERC721TokenBase.sol";

abstract contract BlockMelonERC721Creator is
    ITokenCreator,
    BlockMelonERC721TokenBase
{
    using AddressUpgradeable for address;

    event AdminContractUpdated(address indexed adminContract);
    event CreatorApprovalContractUpdated(address indexed approvalContract);

    /// @dev bytes4(keccak256('tokenCreator(uint256)')) == 0x40c1a064
    bytes4 private constant _INTERFACE_ID_TOKEN_CREATOR = 0x40c1a064;
    ///@dev The contract address which manages admin accounts
    IAdminRole public adminContract;
    ///@dev The contract address which manages creator approvals
    ICreatorApproval public approvalContract;
    /// @dev Mapping from each NFT ID to its creator
    mapping(uint256 => address payable) private _tokenIdToCreator;

    function __BlockMelonERC721Creator_init_unchained()
        internal
        onlyInitializing
    {}

    modifier onlyBlockMelonAdmin() {
        require(
            adminContract.isAdmin(_msgSender()),
            "caller is not a BlockMelon admin"
        );
        _;
    }

    modifier isContract(address _contract) {
        require(_contract.isContract(), "address is not a contract");
        _;
    }

    function _updateAdminContract(address _adminContract)
        internal
        isContract(_adminContract)
    {
        adminContract = IAdminRole(_adminContract);
        emit AdminContractUpdated(_adminContract);
    }

    function _updateApprovalContract(address _approvalContract)
        internal
        isContract(_approvalContract)
    {
        approvalContract = ICreatorApproval(_approvalContract);
        emit CreatorApprovalContractUpdated(_approvalContract);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            _INTERFACE_ID_TOKEN_CREATOR == interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete _tokenIdToCreator[tokenId];
    }

    /**
     * @dev Internal function to set the creator of a token ID.
     */
    function _setCreator(uint256 tokenId, address account) internal virtual {
        _tokenIdToCreator[tokenId] = payable(account);
    }

    /**
     * @dev See {ITokenCreator-tokenCreator}
     */
    function tokenCreator(uint256 tokenId)
        public
        view
        override
        returns (address payable)
    {
        return _tokenIdToCreator[tokenId];
    }

    uint256[50] private __gap;
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

interface ILockedContent {
    /**
     * @notice Returns the locked content of the given `tokenId`.
     */
    function getLockedContent(uint256 tokenId)
        external
        view
        returns (string memory);
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

/**
 * @notice Interface for managing creator approvals
 */
interface ICreatorApproval {
    function isApprovedCreator(address account) external view returns (bool);
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
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
    }

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {
    }
    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981Upgradeable is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}