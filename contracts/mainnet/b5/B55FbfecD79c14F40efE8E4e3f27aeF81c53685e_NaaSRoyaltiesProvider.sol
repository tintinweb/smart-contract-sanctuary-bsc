// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@passive-income/naas-royalties/contracts/libraries/LibPart.sol";
import "@passive-income/naas-royalties/contracts/interfaces/INaaSRoyaltiesProvider.sol";
import "./libraries/LibTokenIdentifier.sol";

contract NaaSRoyaltiesProvider is
    OwnableUpgradeable,
    ERC165Upgradeable,
    INaaSRoyaltiesProvider
{
    using LibTokenIdentifier for uint256;

    struct RoyaltiesCache {
        bool initialized;
        LibPart.Part[] royalties;
    }

    mapping(bytes32 => RoyaltiesCache) public royaltiesByTokenAndTokenId;
    mapping(bytes32 => RoyaltiesCache) public royaltiesByTokenAndCollectionId;
    mapping(address => RoyaltiesCache) public royaltiesByToken;

    mapping(bytes32 => RoyaltiesCache)
        public extraRoyaltiesByTokenAndCollectionId;
    mapping(address => RoyaltiesCache) public extraRoyaltiesByToken;

    event RoyaltiesSet(
        address indexed token,
        int256 indexed collectionId,
        int256 indexed tokenId,
        LibPart.Part[] royalties
    );
    event ExtraRoyaltiesSet(
        address indexed token,
        int256 indexed collectionId,
        int256 indexed tokenId,
        LibPart.Part[] royalties
    );
    event RoyaltiesAccountUpdated(
        address indexed token,
        int256 indexed collectionId,
        int256 indexed tokenId,
        address oldAccount,
        address newAccount
    );

    modifier onlyTokenAndOwner(address token) {
        if (
            (owner() != _msgSender()) &&
            token != _msgSender() &&
            (OwnableUpgradeable(token).owner() != _msgSender())
        ) {
            revert("NO_TOKEN_OWNER");
        }
        _;
    }

    function initialize() external initializer {
        __Ownable_init();
        __ERC165_init_unchained();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IRoyaltiesProvider).interfaceId ||
            interfaceId == type(INaaSRoyaltiesProvider).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function getRoyalties(address token, uint256 tokenId)
        external
        view
        override
        returns (LibPart.Part[] memory)
    {
        RoyaltiesCache memory royaltiesSet = royaltiesByTokenAndTokenId[
            keccak256(abi.encode(token, tokenId))
        ];
        if (royaltiesSet.initialized) {
            return
                ensureExtraRoyalties(
                    ensureExtraRoyalties(
                        royaltiesSet.royalties,
                        extraRoyaltiesByTokenAndCollectionId[
                            keccak256(
                                abi.encode(token, tokenId.tokenCollection())
                            )
                        ]
                    ),
                    extraRoyaltiesByToken[token]
                );
        }

        royaltiesSet = royaltiesByTokenAndCollectionId[
            keccak256(abi.encode(token, tokenId.tokenCollection()))
        ];
        if (royaltiesSet.initialized) return royaltiesSet.royalties;

        royaltiesSet = royaltiesByToken[token];
        if (royaltiesSet.initialized) return royaltiesSet.royalties;

        return new LibPart.Part[](0);
    }

    function ensureExtraRoyalties(
        LibPart.Part[] memory royalties,
        RoyaltiesCache memory extraRoyaltiesSet
    ) internal pure returns (LibPart.Part[] memory) {
        if (extraRoyaltiesSet.initialized) return royalties;

        LibPart.Part[] memory finalRoyalties = new LibPart.Part[](
            royalties.length + extraRoyaltiesSet.royalties.length
        );

        uint256 i = 0;
        for (; i < royalties.length; i++) {
            finalRoyalties[i] = royalties[i];
        }
        for (; i < royalties.length + extraRoyaltiesSet.royalties.length; i++) {
            finalRoyalties[i] = extraRoyaltiesSet.royalties[
                i - royalties.length
            ];
        }
        return finalRoyalties;
    }

    function setRoyaltiesForToken(
        address token,
        LibPart.Part[] memory royalties
    ) external override onlyTokenAndOwner(token) {
        ensureCorrectRoyalties(royalties);
        
        delete royaltiesByToken[token].royalties;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "NO_RECIPIENT");
            require(royalties[i].value != 0, "VALUE_IS_ZERO");
            royaltiesByToken[token].royalties.push(royalties[i]);
        }
        royaltiesByToken[token].initialized = true;
        emit RoyaltiesSet(token, -1, -1, royalties);
    }

    function setRoyaltiesForTokenId(
        address token,
        uint256 tokenId,
        LibPart.Part[] memory royalties
    ) external override onlyTokenAndOwner(token) {
        ensureCorrectRoyalties(royalties);
        bytes32 key = keccak256(abi.encode(token, tokenId));

        delete royaltiesByTokenAndTokenId[key].royalties;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "NO_RECIPIENT");
            require(royalties[i].value != 0, "VALUE_IS_ZERO");
            royaltiesByTokenAndTokenId[key].royalties.push(royalties[i]);
        }
        royaltiesByTokenAndTokenId[key].initialized = true;
        emit RoyaltiesSet(token, -1, int256(tokenId), royalties);
    }

    function setRoyaltiesForCollectionId(
        address token,
        uint256 collectionId,
        LibPart.Part[] memory royalties
    ) external override onlyTokenAndOwner(token) {
        ensureCorrectRoyalties(royalties);
        bytes32 key = keccak256(abi.encode(token, collectionId));

        delete royaltiesByTokenAndCollectionId[key].royalties;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "NO_RECIPIENT");
            require(royalties[i].value != 0, "VALUE_IS_ZERO");
            royaltiesByTokenAndCollectionId[key].royalties.push(royalties[i]);
        }
        royaltiesByTokenAndCollectionId[key].initialized = true;
        emit RoyaltiesSet(token, int256(collectionId), -1, royalties);
    }

    function setExtraRoyaltiesForToken(
        address token,
        LibPart.Part[] memory royalties
    ) external override onlyTokenAndOwner(token) {
        ensureCorrectRoyalties(royalties);

        delete extraRoyaltiesByToken[token].royalties;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "NO_RECIPIENT");
            require(royalties[i].value != 0, "VALUE_IS_ZERO");
            extraRoyaltiesByToken[token].royalties.push(royalties[i]);
        }
        extraRoyaltiesByToken[token].initialized = true;
        emit ExtraRoyaltiesSet(token, -1, -1, royalties);
    }

    function setExtraRoyaltiesForCollectionId(
        address token,
        uint256 collectionId,
        LibPart.Part[] memory royalties
    ) external override onlyTokenAndOwner(token) {
        ensureCorrectRoyalties(royalties);
        bytes32 key = keccak256(abi.encode(token, collectionId));

        delete extraRoyaltiesByTokenAndCollectionId[key].royalties;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "NO_RECIPIENT");
            require(royalties[i].value != 0, "VALUE_IS_ZERO");
            extraRoyaltiesByTokenAndCollectionId[key].royalties.push(royalties[i]);
        }
        extraRoyaltiesByTokenAndCollectionId[key].initialized = true;
        emit ExtraRoyaltiesSet(token, int256(collectionId), -1, royalties);
    }

    function ensureCorrectRoyalties(LibPart.Part[] memory royalties)
        internal
        pure
    {
        uint256 sumRoyalties = 0;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "NO_RECIPIENT");
            require(royalties[i].value != 0, "VALUE_NOT_POSITIVE");
            sumRoyalties += royalties[i].value;
        }
        require(sumRoyalties < 5000, "TOTAL_ROYALTIES_EXCEEDS_50%");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

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
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
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

pragma solidity ^0.8.0;

library LibPart {
    bytes32 public constant TYPE_HASH =
        keccak256("Part(address account,uint256 value)");

    struct Part {
        address payable account;
        uint256 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IRoyaltiesProvider.sol";

interface INaaSRoyaltiesProvider is IRoyaltiesProvider {
    function setRoyaltiesForToken(
        address token,
        LibPart.Part[] memory royalties
    ) external;

    function setRoyaltiesForTokenId(
        address token,
        uint256 tokenId,
        LibPart.Part[] memory royalties
    ) external;

    function setRoyaltiesForCollectionId(
        address token,
        uint256 collectionId,
        LibPart.Part[] memory royalties
    ) external;

    function setExtraRoyaltiesForToken(
        address token,
        LibPart.Part[] memory royalties
    ) external;

    function setExtraRoyaltiesForCollectionId(
        address token,
        uint256 collectionId,
        LibPart.Part[] memory royalties
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

library LibTokenIdentifier {
    uint8 constant ADDRESS_BITS = 160;
    uint8 constant INDEX_BITS = 64;
	uint8 constant COLLECTION_BITS = 32;

	function tokenCreator(uint256 _id) internal pure returns (address) {
        return address(uint160(_id >> (INDEX_BITS + COLLECTION_BITS)));
    }
    function tokenCollection(uint256 _id) internal pure returns (uint256) {
        return uint256(uint32(_id >> (INDEX_BITS)));
    }
    function tokenId(uint256 _id) internal pure returns (uint256) {
		return uint256(uint64(_id));
    }

    function tokenFullId(uint160 minter, uint32 collectionId, uint64 index) internal pure returns (uint256 value) {
		value |= uint256(minter) << (INDEX_BITS + COLLECTION_BITS);
		value |= uint256(collectionId) << (INDEX_BITS);
		value |= uint256(index);
		return value;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

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

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../libraries/LibPart.sol";

interface IRoyaltiesProvider {
    function getRoyalties(address token, uint tokenId) external view returns (LibPart.Part[] memory);
}