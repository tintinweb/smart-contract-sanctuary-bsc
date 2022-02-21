// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IRoyaltiesProvider.sol";
import "./LibRoyalties2981.sol";
import "../libraries/LibPayout.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract RoyaltiesRegistry is IRoyaltiesProvider, OwnableUpgradeable {
    /// @dev emitted when royalties set for token in
    event RoyaltiesSetForContract(address indexed token, LibPayout.Payout[] royalties);

    mapping(address => uint256) public royaltiesProviders;
    /// @dev struct to store royalties in royaltiesByToken
    struct RoyaltiesSet {
        bool initialized;
        LibPayout.Payout[] royalties;
    }

    /// @dev deprecated
    mapping(bytes32 => RoyaltiesSet) public royaltiesByTokenAndTokenId;
    /// @dev stores royalties for token contract, set in setRoyaltiesByToken() method
    mapping(address => RoyaltiesSet) public royaltiesByToken;

    /// @dev total amount or supported royalties types
    // 0 - royalties type is unset
    // 1 - royaltiesByToken
    // 2 - EIP-2981
    // 3 - external provider
    // 4 - unsupported/nonexistent royalties type
    uint256 constant royaltiesTypesAmount = 4;

    function __RoyaltiesRegistry_init() external initializer {
        __Ownable_init_unchained();
    }

    /// @dev sets external provider for token contract, and royalties type = 3
    function setProviderByToken(address token, address provider) external {
        checkOwner(token);
        setRoyaltiesType(token, 3, provider);
    }

    /// @dev sets royalties for token contract in royaltiesByToken mapping and royalties type = 1
    function setRoyaltiesByToken(address token, LibPayout.Payout[] memory royalties) external {
        checkOwner(token);
        //clearing royaltiesProviders value for the token
        delete royaltiesProviders[token];
        // setting royaltiesType = 1 for the token
        setRoyaltiesType(token, 1, address(0));
        uint256 sumRoyalties = 0;
        delete royaltiesByToken[token];
        for (uint256 i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "RoyaltiesByToken recipient should be present");
            require(royalties[i].value != 0, "Royalty value for RoyaltiesByToken should be > 0");
            royaltiesByToken[token].royalties.push(royalties[i]);
            sumRoyalties += royalties[i].value;
        }
        require(sumRoyalties < 10000, "Set by token royalties sum more, than 100%");
        royaltiesByToken[token].initialized = true;
        emit RoyaltiesSetForContract(token, royalties);
    }

    /// @dev sets royalties type for token contract
    function setRoyaltiesType(
        address token,
        uint256 royaltiesType,
        address royaltiesProvider
    ) internal {
        require(royaltiesType > 0 && royaltiesType <= royaltiesTypesAmount, "wrong royaltiesType");
        royaltiesProviders[token] = uint256(uint160(royaltiesProvider)) + 2**(256 - royaltiesType);
    }

    /// @dev returns provider address for token contract from royaltiesProviders mapping
    function getProvider(address token) public view returns (address) {
        return address(uint160(uint256(royaltiesProviders[token])));
    }

    /// @dev returns royalties type for token contract
    function getRoyaltiesType(address token) external view returns (uint256) {
        return _getRoyaltiesType(royaltiesProviders[token]);
    }

    /// @dev returns royalties type from uint
    function _getRoyaltiesType(uint256 data) internal pure returns (uint256) {
        for (uint256 i = 1; i <= royaltiesTypesAmount; i++) {
            if (data / 2**(256 - i) == 1) {
                return i;
            }
        }
        return 0;
    }

    /// @dev clears royalties type for token contract
    function clearRoyaltiesType(address token) external {
        checkOwner(token);
        royaltiesProviders[token] = uint256(uint160(getProvider(token)));
    }

    /// @dev checks if msg.sender is owner of this contract or owner of the token contract
    function checkOwner(address token) internal view {
        if ((owner() != _msgSender()) && (OwnableUpgradeable(token).owner() != _msgSender())) {
            revert("Token owner not detected");
        }
    }

    /// @dev calculates royalties type for token contract
    function calculateRoyaltiesType(address token, address royaltiesProvider) internal view returns (uint256) {
        try IERC2981(token).supportsInterface(LibRoyalties2981._INTERFACE_ID_ROYALTIES) returns (bool result) {
            if (result) {
                return 2;
            }
        } catch {}

        if (royaltiesProvider != address(0)) {
            return 3;
        }

        if (royaltiesByToken[token].initialized) {
            return 1;
        }

        return 4;
    }

    /// @dev returns royalties for token contract and token id
    function getRoyalties(address token, uint256 tokenId) external view override returns (LibPayout.Payout[] memory) {
        (address royaltiesProvider, uint256 royaltiesType) = getRoyaltyTypeAndProvider(token);

        // case when royaltiesType is not set
        if (royaltiesType == 0) {
            // calculating royalties type for token
            royaltiesType = calculateRoyaltiesType(token, royaltiesProvider);
        }

        return getCachedRoyalties(token, tokenId, royaltiesType, royaltiesProvider);
    }

    /// @dev returns royalties for token contract and token id
    function getAndCacheRoyalties(address token, uint256 tokenId) external override returns (LibPayout.Payout[] memory) {
        (address royaltiesProvider, uint256 royaltiesType) = getRoyaltyTypeAndProvider(token);

        // case when royaltiesType is not set
        if (royaltiesType == 0) {
            // calculating royalties type for token
            royaltiesType = calculateRoyaltiesType(token, royaltiesProvider);

            //saving royalties type
            setRoyaltiesType(token, royaltiesType, royaltiesProvider);
        }

        return getCachedRoyalties(token, tokenId, royaltiesType, royaltiesProvider);
    }

    /// @dev returns cached Royalty Type And Provider
    function getRoyaltyTypeAndProvider(address token) internal view returns (address royaltiesProvider, uint256 royaltiesType) {
        uint256 royaltiesProviderData = royaltiesProviders[token];

        royaltiesProvider = address(uint160(royaltiesProviderData));
        royaltiesType = _getRoyaltiesType(royaltiesProviderData);
    }

    /// @dev returns royalties for token contract and token id
    function getCachedRoyalties(
        address token,
        uint256 tokenId,
        uint256 royaltiesType,
        address royaltiesProvider
    ) internal view returns (LibPayout.Payout[] memory) {
        //case royaltiesType = 1, royalties are set in royaltiesByToken
        if (royaltiesType == 1) {
            return royaltiesByToken[token].royalties;
        }

        //case royaltiesType = 2, royalties EIP-2981
        if (royaltiesType == 2) {
            return getRoyaltiesEIP2981(token, tokenId);
        }

        //case royaltiesType = 3, royalties from external provider
        if (royaltiesType == 3) {
            return providerExtractor(token, tokenId, royaltiesProvider);
        }

        // case royaltiesType = 4, unknown/empty royalties
        if (royaltiesType == 4) {
            return new LibPayout.Payout[](0);
        }

        revert("something wrong in getRoyalties");
    }

    /// @dev tries to get royalties EIP-2981 for token and tokenId
    function getRoyaltiesEIP2981(address token, uint256 tokenId) internal view returns (LibPayout.Payout[] memory) {
        try IERC2981(token).royaltyInfo(tokenId, LibRoyalties2981._WEIGHT_VALUE) returns (address receiver, uint256 royaltyAmount) {
            return LibRoyalties2981.calculateRoyalties(receiver, royaltyAmount);
        } catch {
            return new LibPayout.Payout[](0);
        }
    }

    /// @dev tries to get royalties for token and tokenId from external provider set in royaltiesProviders
    function providerExtractor(
        address token,
        uint256 tokenId,
        address providerAddress
    ) internal view returns (LibPayout.Payout[] memory) {
        try IRoyaltiesProvider(providerAddress).getRoyalties(token, tokenId) returns (LibPayout.Payout[] memory result) {
            return result;
        } catch {
            return new LibPayout.Payout[](0);
        }
    }

    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../libraries/LibPayout.sol";

interface IRoyaltiesProvider {
    function getRoyalties(address token, uint256 tokenId) external view returns (LibPayout.Payout[] memory);

    function getAndCacheRoyalties(address token, uint256 tokenId) external returns (LibPayout.Payout[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../libraries/LibPayout.sol";

library LibRoyalties2981 {
    /*
     * https://eips.ethereum.org/EIPS/eip-2981: bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
     */
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0x2a55205a;
    uint96 constant _WEIGHT_VALUE = 1000000;

    /*Method for converting amount to percent and forming LibPayout.Payout*/
    function calculateRoyalties(address to, uint256 amount) internal pure returns (LibPayout.Payout[] memory) {
        LibPayout.Payout[] memory result;
        if (amount == 0) {
            return result;
        }
        uint256 percent = ((amount * 100) / _WEIGHT_VALUE) * 100;
        require(percent < 10000, "Royalties 2981, than 100%");
        result = new LibPayout.Payout[](1);
        result[0].account = payable(to);
        result[0].value = uint96(percent);
        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library LibPayout {
    bytes32 public constant TYPE_HASH = keccak256("Payout(address account,uint256 value)");

    struct Payout {
        address account;
        uint256 value;
    }

    function hash(Payout memory payout) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, payout.account, payout.value));
    }
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Called with the sale price to determine how much royalty is owed and to whom.
     * @param tokenId - the NFT asset queried for royalty information
     * @param salePrice - the sale price of the NFT asset specified by `tokenId`
     * @return receiver - address of who should be sent the royalty payment
     * @return royaltyAmount - the royalty payment amount for `salePrice`
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

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