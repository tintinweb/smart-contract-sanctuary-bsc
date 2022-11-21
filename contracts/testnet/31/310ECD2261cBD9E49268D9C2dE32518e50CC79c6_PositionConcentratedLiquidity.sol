// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (governance/utils/IVotes.sol)
pragma solidity ^0.8.0;

/**
 * @dev Common interface for {ERC20Votes}, {ERC721Votes}, and other {Votes}-enabled contracts.
 *
 * _Available since v4.5._
 */
interface IVotesUpgradeable {
    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to a delegate's number of votes.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (governance/utils/Votes.sol)
pragma solidity ^0.8.0;

import "../../utils/ContextUpgradeable.sol";
import "../../utils/CountersUpgradeable.sol";
import "../../utils/CheckpointsUpgradeable.sol";
import "../../utils/cryptography/EIP712Upgradeable.sol";
import "./IVotesUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev This is a base abstract contract that tracks voting units, which are a measure of voting power that can be
 * transferred, and provides a system of vote delegation, where an account can delegate its voting units to a sort of
 * "representative" that will pool delegated voting units from different accounts and can then use it to vote in
 * decisions. In fact, voting units _must_ be delegated in order to count as actual votes, and an account has to
 * delegate those votes to itself if it wishes to participate in decisions and does not have a trusted representative.
 *
 * This contract is often combined with a token contract such that voting units correspond to token units. For an
 * example, see {ERC721Votes}.
 *
 * The full history of delegate votes is tracked on-chain so that governance protocols can consider votes as distributed
 * at a particular block number to protect against flash loans and double voting. The opt-in delegate system makes the
 * cost of this history tracking optional.
 *
 * When using this module the derived contract must implement {_getVotingUnits} (for example, make it return
 * {ERC721-balanceOf}), and can use {_transferVotingUnits} to track a change in the distribution of those units (in the
 * previous example, it would be included in {ERC721-_beforeTokenTransfer}).
 *
 * _Available since v4.5._
 */
abstract contract VotesUpgradeable is Initializable, IVotesUpgradeable, ContextUpgradeable, EIP712Upgradeable {
    function __Votes_init() internal onlyInitializing {
    }

    function __Votes_init_unchained() internal onlyInitializing {
    }
    using CheckpointsUpgradeable for CheckpointsUpgradeable.History;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 private constant _DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => address) private _delegation;
    mapping(address => CheckpointsUpgradeable.History) private _delegateCheckpoints;
    CheckpointsUpgradeable.History private _totalCheckpoints;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) public view virtual override returns (uint256) {
        return _delegateCheckpoints[account].latest();
    }

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastVotes(address account, uint256 blockNumber) public view virtual override returns (uint256) {
        return _delegateCheckpoints[account].getAtProbablyRecentBlock(blockNumber);
    }

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastTotalSupply(uint256 blockNumber) public view virtual override returns (uint256) {
        require(blockNumber < block.number, "Votes: block not yet mined");
        return _totalCheckpoints.getAtProbablyRecentBlock(blockNumber);
    }

    /**
     * @dev Returns the current total supply of votes.
     */
    function _getTotalSupply() internal view virtual returns (uint256) {
        return _totalCheckpoints.latest();
    }

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) public view virtual override returns (address) {
        return _delegation[account];
    }

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) public virtual override {
        address account = _msgSender();
        _delegate(account, delegatee);
    }

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= expiry, "Votes: signature expired");
        address signer = ECDSAUpgradeable.recover(
            _hashTypedDataV4(keccak256(abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry))),
            v,
            r,
            s
        );
        require(nonce == _useNonce(signer), "Votes: invalid nonce");
        _delegate(signer, delegatee);
    }

    /**
     * @dev Delegate all of `account`'s voting units to `delegatee`.
     *
     * Emits events {DelegateChanged} and {DelegateVotesChanged}.
     */
    function _delegate(address account, address delegatee) internal virtual {
        address oldDelegate = delegates(account);
        _delegation[account] = delegatee;

        emit DelegateChanged(account, oldDelegate, delegatee);
        _moveDelegateVotes(oldDelegate, delegatee, _getVotingUnits(account));
    }

    /**
     * @dev Transfers, mints, or burns voting units. To register a mint, `from` should be zero. To register a burn, `to`
     * should be zero. Total supply of voting units will be adjusted with mints and burns.
     */
    function _transferVotingUnits(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (from == address(0)) {
            _totalCheckpoints.push(_add, amount);
        }
        if (to == address(0)) {
            _totalCheckpoints.push(_subtract, amount);
        }
        _moveDelegateVotes(delegates(from), delegates(to), amount);
    }

    /**
     * @dev Moves delegated votes from one delegate to another.
     */
    function _moveDelegateVotes(
        address from,
        address to,
        uint256 amount
    ) private {
        if (from != to && amount > 0) {
            if (from != address(0)) {
                (uint256 oldValue, uint256 newValue) = _delegateCheckpoints[from].push(_subtract, amount);
                emit DelegateVotesChanged(from, oldValue, newValue);
            }
            if (to != address(0)) {
                (uint256 oldValue, uint256 newValue) = _delegateCheckpoints[to].push(_add, amount);
                emit DelegateVotesChanged(to, oldValue, newValue);
            }
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        CountersUpgradeable.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }

    /**
     * @dev Returns an address nonce.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev Returns the contract's {EIP712} domain separator.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev Must return the voting units held by an account.
     */
    function _getVotingUnits(address) internal view virtual returns (uint256);

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

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
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
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
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
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

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721Upgradeable.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
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

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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
     * @dev Hook that is called before any (single) token transfer. This includes minting and burning.
     * See {_beforeConsecutiveTokenTransfer}.
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
     * @dev Hook that is called after any (single) transfer of tokens. This includes minting and burning.
     * See {_afterConsecutiveTokenTransfer}.
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
     * @dev Hook that is called before consecutive token transfers.
     * Calling conditions are similar to {_beforeTokenTransfer}.
     *
     * The default implementation include balances updates that extensions such as {ERC721Consecutive} cannot perform
     * directly.
     */
    function _beforeConsecutiveTokenTransfer(
        address from,
        address to,
        uint256, /*first*/
        uint96 size
    ) internal virtual {
        if (from != address(0)) {
            _balances[from] -= size;
        }
        if (to != address(0)) {
            _balances[to] += size;
        }
    }

    /**
     * @dev Hook that is called after consecutive token transfers.
     * Calling conditions are similar to {_afterTokenTransfer}.
     */
    function _afterConsecutiveTokenTransfer(
        address, /*from*/
        address, /*to*/
        uint256, /*first*/
        uint96 /*size*/
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
     * - `from` and 'to' cannot be the zero address at the same time.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Hook that is called before any batch token transfer. For now this is limited
     * to batch minting by the {ERC721Consecutive} extension.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeConsecutiveTokenTransfer(
        address,
        address,
        uint256,
        uint96 size
    ) internal virtual override {
        // We revert because enumerability is not supported with consecutive batch minting.
        // This conditional is only needed to silence spurious warnings about unreachable code.
        if (size > 0) {
            revert("ERC721Enumerable: consecutive transfers not supported");
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (token/ERC721/IERC721.sol)

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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Checkpoints.sol)
// This file was procedurally generated from scripts/generate/templates/Checkpoints.js.

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";
import "./math/SafeCastUpgradeable.sol";

/**
 * @dev This library defines the `History` struct, for checkpointing values as they change at different points in
 * time, and later looking up past values by block number. See {Votes} as an example.
 *
 * To create a history of checkpoints define a variable type `Checkpoints.History` in your contract, and store a new
 * checkpoint for the current transaction block using the {push} function.
 *
 * _Available since v4.5._
 */
library CheckpointsUpgradeable {
    struct History {
        Checkpoint[] _checkpoints;
    }

    struct Checkpoint {
        uint32 _blockNumber;
        uint224 _value;
    }

    /**
     * @dev Returns the value at a given block number. If a checkpoint is not available at that block, the closest one
     * before it is returned, or zero otherwise.
     */
    function getAtBlock(History storage self, uint256 blockNumber) internal view returns (uint256) {
        require(blockNumber < block.number, "Checkpoints: block not yet mined");
        uint32 key = SafeCastUpgradeable.toUint32(blockNumber);

        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value at a given block number. If a checkpoint is not available at that block, the closest one
     * before it is returned, or zero otherwise. Similar to {upperLookup} but optimized for the case when the searched
     * checkpoint is probably "recent", defined as being among the last sqrt(N) checkpoints where N is the number of
     * checkpoints.
     */
    function getAtProbablyRecentBlock(History storage self, uint256 blockNumber) internal view returns (uint256) {
        require(blockNumber < block.number, "Checkpoints: block not yet mined");
        uint32 key = SafeCastUpgradeable.toUint32(blockNumber);

        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - MathUpgradeable.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Pushes a value onto a History so that it is stored as the checkpoint for the current block.
     *
     * Returns previous value and new value.
     */
    function push(History storage self, uint256 value) internal returns (uint256, uint256) {
        return _insert(self._checkpoints, SafeCastUpgradeable.toUint32(block.number), SafeCastUpgradeable.toUint224(value));
    }

    /**
     * @dev Pushes a value onto a History, by updating the latest value using binary operation `op`. The new value will
     * be set to `op(latest, delta)`.
     *
     * Returns previous value and new value.
     */
    function push(
        History storage self,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) internal returns (uint256, uint256) {
        return push(self, op(latest(self), delta));
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(History storage self) internal view returns (uint224) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(History storage self)
        internal
        view
        returns (
            bool exists,
            uint32 _blockNumber,
            uint224 _value
        )
    {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._blockNumber, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(History storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(
        Checkpoint[] storage self,
        uint32 key,
        uint224 value
    ) private returns (uint224, uint224) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint memory last = _unsafeAccess(self, pos - 1);

            // Checkpoints keys must be increasing.
            require(last._blockNumber <= key, "Checkpoint: invalid key");

            // Update or push new checkpoint
            if (last._blockNumber == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint({_blockNumber: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint({_blockNumber: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the oldest checkpoint whose key is greater than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (_unsafeAccess(self, mid)._blockNumber > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the oldest checkpoint whose key is greater or equal than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (_unsafeAccess(self, mid)._blockNumber < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    function _unsafeAccess(Checkpoint[] storage self, uint256 pos) private pure returns (Checkpoint storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace224 {
        Checkpoint224[] _checkpoints;
    }

    struct Checkpoint224 {
        uint32 _key;
        uint224 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace224 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     */
    function push(
        Trace224 storage self,
        uint32 key,
        uint224 value
    ) internal returns (uint224, uint224) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the oldest checkpoint with key greater or equal than the search key, or zero if there is none.
     */
    function lowerLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint with key lower or equal than the search key.
     */
    function upperLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace224 storage self) internal view returns (uint224) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace224 storage self)
        internal
        view
        returns (
            bool exists,
            uint32 _key,
            uint224 _value
        )
    {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint224 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace224 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(
        Checkpoint224[] storage self,
        uint32 key,
        uint224 value
    ) private returns (uint224, uint224) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint224 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoints keys must be increasing.
            require(last._key <= key, "Checkpoint: invalid key");

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint224({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint224({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the oldest checkpoint whose key is greater than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the oldest checkpoint whose key is greater or equal than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    function _unsafeAccess(Checkpoint224[] storage self, uint256 pos)
        private
        pure
        returns (Checkpoint224 storage result)
    {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace160 {
        Checkpoint160[] _checkpoints;
    }

    struct Checkpoint160 {
        uint96 _key;
        uint160 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace160 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     */
    function push(
        Trace160 storage self,
        uint96 key,
        uint160 value
    ) internal returns (uint160, uint160) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the oldest checkpoint with key greater or equal than the search key, or zero if there is none.
     */
    function lowerLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint with key lower or equal than the search key.
     */
    function upperLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace160 storage self) internal view returns (uint160) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace160 storage self)
        internal
        view
        returns (
            bool exists,
            uint96 _key,
            uint160 _value
        )
    {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint160 memory ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace160 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(
        Checkpoint160[] storage self,
        uint96 key,
        uint160 value
    ) private returns (uint160, uint160) {
        uint256 pos = self.length;

        if (pos > 0) {
            // Copying to memory is important here.
            Checkpoint160 memory last = _unsafeAccess(self, pos - 1);

            // Checkpoints keys must be increasing.
            require(last._key <= key, "Checkpoint: invalid key");

            // Update or push new checkpoint
            if (last._key == key) {
                _unsafeAccess(self, pos - 1)._value = value;
            } else {
                self.push(Checkpoint160({_key: key, _value: value}));
            }
            return (last._value, value);
        } else {
            self.push(Checkpoint160({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the oldest checkpoint whose key is greater than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the oldest checkpoint whose key is greater or equal than the search key, or `high` if there is none.
     * `low` and `high` define a section where to do the search, with inclusive `low` and exclusive `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = MathUpgradeable.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    function _unsafeAccess(Checkpoint160[] storage self, uint256 pos)
        private
        pure
        returns (Checkpoint160 storage result)
    {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/cryptography/ECDSA.sol)

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
        InvalidSignatureV // Deprecated in v4.8
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
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
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
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/cryptography/EIP712.sol)

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
 *
 * @custom:storage-size 52
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/helper/Liquidity.sol";

interface IAutoMarketMakerCore {
    // TODO add guard

    struct AddLiquidity {
        uint128 baseAmount;
        uint128 quoteAmount;
        uint32 indexedPipRange;
    }

    function addLiquidity(AddLiquidity calldata params)
        external
        returns (
            uint128 baseAmountAdded,
            uint128 quoteAmountAdded,
            uint256 liquidity,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote
        );

    struct RemoveLiquidity {
        uint128 liquidity;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
    }

    function removeLiquidity(RemoveLiquidity calldata params)
        external
        returns (uint128 baseAmount, uint128 quoteAmount);

    function estimateRemoveLiquidity(RemoveLiquidity calldata params)
        external
        view
        returns (
            uint128 baseAmount,
            uint128 quoteAmount,
            Liquidity.Info memory _liquidityInfo
        );

    function getPipRange() external view returns (uint128);

    function liquidityInfo(uint256 index)
        external
        view
        returns (
            uint128 sqrtMaxPip,
            uint128 sqrtMinPip,
            uint128 quoteReal,
            uint128 baseReal,
            uint32 indexedPipRange,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote,
            uint128 sqrtK
        );

    function pipRange() external view returns (uint128);

    function tickSpace() external view returns (uint32);

    function currentIndexedPipRange() external view returns (uint256);

    function feeShareAmm() external view returns (uint32);
}

/**
 * @author Musket
 */
pragma solidity ^0.8.9;

interface IFee {
    function decreaseBaseFeeFunding(uint256 baseFee) external;

    function decreaseQuoteFeeFunding(uint256 quoteFee) external;

    function increaseBaseFeeFunding(uint256 baseFee) external;

    function increaseQuoteFeeFunding(uint256 quoteFee) external;

    function resetFee(uint256 baseFee, uint256 quoteFee) external;

    function getFee()
        external
        view
        returns (uint256 baseFeeFunding, uint256 quoteFeeFunding);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAutoMarketMakerCore.sol";
import "./IMatchingEngineCore.sol";
import "./IFee.sol";

interface IMatchingEngineAMM is
    IFee,
    IAutoMarketMakerCore,
    IMatchingEngineCore
{
    struct InitParams {
        IERC20 quoteAsset;
        IERC20 baseAsset;
        uint256 basisPoint;
        uint128 maxFindingWordsIndex;
        uint128 initialPip;
        uint128 pipRange;
        uint32 tickSpace;
        address owner;
        address positionLiquidity;
        address spotHouse;
        uint32 feeShareAmm;
    }
    // TODO add guard

    struct ExchangedData {
        uint256 baseAmount;
        uint256 quoteAmount;
        uint256 feeQuoteAmount;
        uint256 feeBaseAmount;
    }

    event PairManagerInitialized(
        address quoteAsset,
        address baseAsset,
        address counterParty,
        uint256 basisPoint,
        uint256 baseBasisPoint,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        uint64 expireTime,
        address owner
    );

    function initialize(InitParams memory params) external;

    function approveCounterParty(IERC20 asset, address spender) external;

    function accumulateClaimableAmount(
        uint128 _pip,
        uint64 _orderId,
        ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view returns (ExchangedData memory);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IMatchingEngineCore {
    struct LiquidityOfEachPip {
        uint128 pip;
        uint256 liquidity;
    }

    // TODO add guard
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 startPip,
        uint128 remainingLiquidity,
        uint64 filledIndex
    );
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );

    event LimitOrderCancelled(
        bool isBuy,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    event UpdateMaxFindingWordsIndex(
        address spotManager,
        uint128 newMaxFindingWordsIndex
    );

    event MaxWordRangeForLimitOrderUpdated(
        uint128 newMaxWordRangeForLimitOrder
    );
    event MaxWordRangeForMarketOrderUpdated(
        uint128 newMaxWordRangeForMarketOrder
    );
    event UpdateBasisPoint(address spotManager, uint256 newBasicPoint);
    event UpdateBaseBasicPoint(address spotManager, uint256 newBaseBasisPoint);
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);
    event LimitOrderUpdated(
        address spotManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );
    event UpdateExpireTime(address spotManager, uint64 newExpireTime);
    event UpdateCounterParty(address spotManager, address newCounterParty);
    event LiquidityPoolAllowanceUpdate(address liquidityPool, bool value);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    function updatePartialFilledOrder(uint128 _pip, uint64 _orderId) external;

    function cancelLimitOrder(uint128 _pip, uint64 _orderId)
        external
        returns (uint256 remainingSize, uint256 partialFilled);

    function openLimit(
        uint128 pip,
        uint128 baseAmountIn,
        bool isBuy,
        address trader,
        uint256 quoteAmountIn,
        uint16 feePercent
    )
        external
        returns (
            uint64 orderId,
            uint256 baseAmountFilled,
            uint256 quoteAmountFilled,
            uint256 fee
        );

    function openMarket(
        uint256 size,
        bool isBuy,
        address trader,
        uint16 feePercent
    )
        external
        returns (
            uint256 baseOut,
            uint256 quoteOut,
            uint256 fee
        );

    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool _isBuy,
        address _trader,
        uint16 feePercent
    )
        external
        returns (
            uint256 sizeOutQuote,
            uint256 baseAmount,
            uint256 fee
        );

    function hasLiquidity(uint128 _pip) external view returns (bool);

    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    function getLiquidityInCurrentPip() external view returns (uint128);

    function getLiquidityInPipRange(
        uint128 fromPip,
        uint256 dataLength,
        bool toHigher
    ) external view virtual returns (LiquidityOfEachPip[] memory, uint128);

    function getAmountEstimate(
        uint256 size,
        bool isBuy,
        bool isBase
    ) external view returns (uint256 mainSideOut, uint256 flipSideOut);

    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        external
        view
        returns (uint256);

    function basisPoint() external view returns (uint256);

    function getCurrentPip() external view returns (uint128);

    function quoteToBase(uint256 quoteAmount, uint128 pip)
        external
        view
        returns (uint256);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
    uint256 internal constant BUFFER = 10**24;
    uint256 internal constant Q_POW18 = 10**18;
    uint256 internal constant HALF_BUFFER = 10**12;
    uint32 internal constant BASIC_POINT_FEE = 10_000;
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Liquidity {
    struct Info {
        uint128 sqrtMaxPip;
        uint128 sqrtMinPip;
        uint128 quoteReal;
        uint128 baseReal;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
        uint128 sqrtK;
    }

    function initNewPipRange(
        Liquidity.Info storage self,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip,
        uint32 indexedPipRange
    ) internal {
        self.sqrtMaxPip = sqrtMaxPip;
        self.sqrtMinPip = sqrtMinPip;
        self.indexedPipRange = indexedPipRange;
    }

    function updateAddLiquidity(
        Liquidity.Info storage self,
        Liquidity.Info memory updater
    ) internal {
        if (self.sqrtK == 0) {
            self.sqrtMaxPip = updater.sqrtMaxPip;
            self.sqrtMinPip = updater.sqrtMinPip;
            self.indexedPipRange = updater.indexedPipRange;
        }
        self.quoteReal = updater.quoteReal;
        self.baseReal = updater.baseReal;
        self.sqrtK = updater.sqrtK;
    }

    function updateFeeGrowth(
        Liquidity.Info storage self,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote
    ) internal {
        self.feeGrowthBase = feeGrowthBase;
        self.feeGrowthQuote = feeGrowthQuote;
    }

    function updateAMMReserve(
        Liquidity.Info storage self,
        uint128 quoteReserve,
        uint128 baseReserve,
        uint256 feeGrowth,
        bool isBuy
    ) internal {
        self.quoteReal = quoteReserve;
        self.baseReal = baseReserve;

        if (isBuy) {
            self.feeGrowthBase += feeGrowth;
        } else {
            self.feeGrowthQuote += feeGrowth;
        }
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./FixedPoint128.sol";

library LiquidityMath {
    function calculateBaseReal(
        uint128 sqrtMaxPip,
        uint128 xVirtual,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        if (sqrtCurrentPrice == sqrtMaxPip) {
            return 0;
        }
        return
            uint128(
                (uint256(sqrtMaxPip) * uint256(xVirtual)) /
                    (uint256(sqrtMaxPip) - uint256(sqrtCurrentPrice))
            );
    }

    function calculateQuoteReal(
        uint128 sqrtMinPip,
        uint128 yVirtual,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        if (sqrtCurrentPrice == sqrtMinPip) {
            return 0;
        }
        return
            uint128(
                (uint256(sqrtCurrentPrice) * uint256(yVirtual)) /
                    (uint256(sqrtCurrentPrice) - uint256(sqrtMinPip))
            );
    }

    /// these functions below are used to calculate the amount asset when SELL
    function calculateBaseWithPriceWhenSell(
        uint128 sqrtPriceTarget,
        uint128 quoteReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        //        return uint128(((10**18 * uint256(quoteReal)) / uint256(sqrtPriceTarget) ) * (10**18 *((uint256(quoteReal) *
        //        (uint256(sqrtCurrentPrice) -
        //        uint256(sqrtPriceTarget))))/uint256(sqrtCurrentPrice)**2));

        //        uint256 a = (10**18 *
        //            (uint256(quoteReal) *
        //                (uint256(sqrtCurrentPrice) - uint256(sqrtPriceTarget))));
        //        uint256 b = (uint256(sqrtPriceTarget) * uint256(sqrtCurrentPrice)**2);

        return
            uint128(
                (FixedPoint128.BUFFER *
                    (uint256(quoteReal) *
                        (uint256(sqrtCurrentPrice) -
                            uint256(sqrtPriceTarget)))) /
                    (uint256(sqrtPriceTarget) * uint256(sqrtCurrentPrice)**2)
            );
    }

    function calculateQuoteWithPriceWhenSell(
        uint128 sqrtPriceTarget,
        uint128 quoteReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(quoteReal) *
                    (uint256(sqrtCurrentPrice) - uint256(sqrtPriceTarget))) /
                    uint256(sqrtCurrentPrice)
            );
    }

    function calculateBaseWithPriceWhenBuy(
        uint128 sqrtPriceTarget,
        uint128 baseReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    (uint256(sqrtPriceTarget) - uint256(sqrtCurrentPrice))) /
                    uint256(sqrtPriceTarget)
            );
    }

    function calculateQuoteWithPriceWhenBuy(
        uint128 sqrtPriceTarget,
        uint128 baseReal,
        uint128 sqrtCurrentPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    uint256(sqrtCurrentPrice) *
                    (uint256(sqrtPriceTarget) - uint256(sqrtCurrentPrice))) /
                    FixedPoint128.BUFFER
            );
    }

    function calculateIndexPipRange(uint128 pip, uint128 pipRange)
        internal
        pure
        returns (uint256)
    {
        return uint256(pip / pipRange);
        //            pip % pipRange == 0
        //                ? uint256((pip / pipRange) )
        //                : uint256(pip / pipRange);
    }

    function calculatePipRange(uint32 indexedPipRange, uint128 pipRange)
        internal
        pure
        returns (uint128 pipMin, uint128 pipMax)
    {
        pipMin = indexedPipRange == 0 ? 1 : indexedPipRange * pipRange;
        pipMax = pipMin + pipRange - 1;
    }

    function calculateBaseBuyAndQuoteSellWithoutTargetPrice(
        uint128 sqrtK,
        uint128 amountReal,
        uint128 amount
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(amount) * uint256(amountReal)**2) /
                    (uint256(sqrtK)**2 + amount * uint256(amountReal))
            );
    }

    function calculateQuoteBuyAndBaseSellWithoutTargetPrice(
        uint128 sqrtK,
        uint128 amountReal,
        uint128 amount
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(amount) * uint256(sqrtK)**2) /
                    (uint256(amountReal) *
                        (uint256(amountReal) - uint256(amount)))
            );
    }

    function calculateKWithQuote(uint128 quoteReal, uint128 sqrtPriceMax)
        internal
        pure
        returns (uint256)
    {
        return
            (uint256(quoteReal)**2 * FixedPoint128.BUFFER) /
            uint256(sqrtPriceMax)**2;
    }

    function calculateKWithBase(uint128 baseReal, uint128 sqrtPriceMin)
        internal
        pure
        returns (uint256)
    {
        return
            (uint256(baseReal)**2 * uint256(sqrtPriceMin)**2) /
            FixedPoint128.BUFFER;
    }

    function calculateKWithBaseAndQuote(uint128 quoteReal, uint128 baseReal)
        internal
        pure
        returns (uint256)
    {
        return uint256(quoteReal) * uint256(baseReal);
    }

    function calculateLiquidity(
        uint128 amountReal,
        uint128 sqrtPrice,
        bool isBase
    ) internal pure returns (uint256) {
        if (isBase) {
            return uint256(amountReal) * uint256(sqrtPrice);
        } else {
            return uint256(amountReal) / uint256(sqrtPrice);
        }
    }

    function calculateBaseByLiquidity(
        uint128 liquidity,
        uint128 sqrtPriceMax,
        uint128 sqrtPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (FixedPoint128.HALF_BUFFER *
                    uint256(liquidity) *
                    (uint256(sqrtPriceMax) - uint256(sqrtPrice))) /
                    (uint256(sqrtPrice) * uint256(sqrtPriceMax))
            );
    }

    function calculateQuoteByLiquidity(
        uint128 liquidity,
        uint128 sqrtPriceMin,
        uint128 sqrtPrice
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) *
                    (uint256(sqrtPrice) - uint256(sqrtPriceMin))) /
                    FixedPoint128.HALF_BUFFER
            );
    }

    function calculateBaseRealByLiquidity(
        uint128 liquidity,
        uint128 totalLiquidity,
        uint128 totalBaseReal
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) * totalBaseReal) / uint256(totalLiquidity)
            );
    }

    function calculateQuoteRealByLiquidity(
        uint128 liquidity,
        uint128 totalLiquidity,
        uint128 totalQuoteReal
    ) internal pure returns (uint128) {
        return
            uint128(
                (uint256(liquidity) * totalQuoteReal) / uint256(totalLiquidity)
            );
    }

    function calculateQuoteVirtualAmountFromBaseVirtualAmount(
        uint128 baseVirtualAmount,
        uint128 sqrtCurrentPrice,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip
    ) internal pure returns (uint128 quoteVirtualAmount) {
        return
            (baseVirtualAmount *
                sqrtCurrentPrice *
                (sqrtCurrentPrice - sqrtMinPip)) /
            (sqrtMaxPip * sqrtCurrentPrice);
    }

    function calculateBaseVirtualAmountFromQuoteVirtualAmount(
        uint128 quoteVirtualAmount,
        uint128 sqrtCurrentPrice,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip
    ) internal pure returns (uint128 baseVirtualAmount) {
        return
            (quoteVirtualAmount *
                sqrtCurrentPrice *
                (sqrtCurrentPrice - sqrtMinPip)) /
            ((sqrtCurrentPrice - sqrtMinPip) * sqrtCurrentPrice * sqrtMaxPip);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Math {
    // _feeCalculator calculate fee
    function feeCalculator(
        uint256 _amount,
        uint16 _fee,
        uint128 _feeBasis
    ) internal view returns (uint256 feeCalculatedAmount) {
        if (_fee == 0) {
            return 0;
        }
        feeCalculatedAmount = (_fee * _amount) / _feeBasis;
    }

    function feeRefundCalculator(
        uint256 _amount,
        uint16 _fee,
        uint128 _feeBasis
    ) internal view returns (uint256 feeRefund) {
        feeRefund = (_amount * _fee) / (_feeBasis - _fee);
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Calculate the square root of the perfect square of a power of two that is the closest to x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }
}

library VestingFrequencyHelper {
    enum Frequency {
        Daily, // 1 days
        Weekly, // 7 days
        Monthly, // 30 days
        Bimonthly, // 2 months
        Quarterly, // 3 months
        Biannually // 6 months
    }

    function toTimestamp(Frequency _freq) internal view returns (uint256) {
        if (_freq == Frequency.Daily) {
            return block.timestamp + 86400;
        } else if (_freq == Frequency.Weekly) {
            return block.timestamp + 604800;
        } else if (_freq == Frequency.Monthly) {
            return block.timestamp + 2592000;
        } else if (_freq == Frequency.Bimonthly) {
            return block.timestamp + 5184000;
        } else if (_freq == Frequency.Quarterly) {
            return block.timestamp + 7776000;
        } else if (_freq == Frequency.Biannually) {
            return block.timestamp + 182 days;
        }
        return 0;
    }

}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./library/VestingFrequencyHelper.sol";
import "./VestingScheduleLogic.sol";

abstract contract VestingScheduleBase is VestingScheduleLogic {
    mapping (address => mapping(VestingFrequencyHelper.Frequency => VestingData[])) public vestingSchedule;
    mapping (address => bool) internal _isWhiteListVesting;

    function _getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) internal override view returns (VestingData[] memory) {
        return vestingSchedule[user][freq];
    }

    function _removeFirstSchedule(address user, VestingFrequencyHelper.Frequency freq) internal override {
        _popFirstSchedule(vestingSchedule[user][freq]);
    }

    function _lockVestingSchedule(address _to, VestingFrequencyHelper.Frequency _freq, uint256 _amount) internal override {
        vestingSchedule[_to][_freq].push(_newVestingData(_amount, _freq));
    }

    // use for mocking test
    function _setVestingTime(address user, uint8 freq, uint256 index, uint256 timestamp) internal {
        vestingSchedule[user][VestingFrequencyHelper.Frequency(freq)][index].vestingTime = uint64(timestamp);
    }

    function _setWhitelistVesting(address user, bool val) internal {
        _isWhiteListVesting[user] = val;
        emit WhiteListVestingChanged(user, val);
    }

    function _isWhitelistVesting(address user) internal view returns (bool) {
        return _isWhiteListVesting[user];
    }
}

pragma solidity ^0.8.0;

import "./library/VestingFrequencyHelper.sol";

abstract contract VestingScheduleLogic {
    using VestingFrequencyHelper for VestingFrequencyHelper.Frequency;
    struct VestingData {
        uint64 vestingTime;
        uint192 amount;
    }

    event WhiteListVestingChanged(address indexed _address, bool _isWhiteListVesting);

    function getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) public virtual view returns (VestingData[] memory){
        return _getVestingSchedules(user, freq);
    }
    function _getVestingSchedules(address user, VestingFrequencyHelper.Frequency freq) internal virtual view returns (VestingData[] memory);

    function claimVesting(VestingFrequencyHelper.Frequency freq, uint256 index) public virtual {
        bool success = _claimVesting(msg.sender, freq, index);
        require(success, "claimVesting: failed");
    }

    function claimVestingBatch(VestingFrequencyHelper.Frequency[] memory freqs, uint256[] memory index) public virtual {
        for(uint256 i = 0; i < freqs.length; i++) {
            _claimVesting(msg.sender, freqs[i], index[i]);
        }
    }

    function _claimVesting(address user, VestingFrequencyHelper.Frequency freq, uint256 index) internal returns (bool success) {
        VestingData[] memory vestingSchedules = _getVestingSchedules(user, freq);
        require(index < vestingSchedules.length, "claimVesting: index out of range");
        for (uint256 i = 0; i <= index; i++) {
            VestingData memory schedule = vestingSchedules[i];
            if(block.timestamp >= schedule.vestingTime){
                // remove the vesting schedule
                _removeFirstSchedule(user, freq);
                // transfer locked token
                _transferLockedToken(user, schedule.amount);
            }else{
                // don't need to shift to the next schedule
                // because the vesting schedule is sorted by timestamp
                return false;
            }
        }
        return true;
    }

    function _addSchedules(address _to, uint256 _amount) internal virtual {
        // receive 5% after 1 day
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Daily, _amount * 5 / 100);
        // receive 10% after 7 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Weekly, _amount * 10 / 100);
        // receive 10% after 30 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Monthly, _amount * 10 / 100);
        // receive 20% after 60 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Bimonthly, _amount * 20 / 100);
        // receive 20% after 90 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Quarterly, _amount * 20 / 100);
        // receive 30% after 180 days
        _lockVestingSchedule(_to, VestingFrequencyHelper.Frequency.Biannually, _amount * 30 / 100);
    }

    function _popFirstSchedule(VestingData[] storage schedules) internal {
        for (uint256 i = 0; i < schedules.length-1; i++) {
            schedules[i] = schedules[i + 1];
        }
        schedules.pop();
    }

    function _newVestingData(uint256 _amount, VestingFrequencyHelper.Frequency _freq) internal view returns (VestingData memory) {
        return VestingData({
            amount: uint192(_amount),
            vestingTime: uint64(_freq.toTimestamp())
        });
    }

    function _removeFirstSchedule(address user, VestingFrequencyHelper.Frequency freq) internal virtual;
    function _lockVestingSchedule(address _to, VestingFrequencyHelper.Frequency _freq, uint256 _amount) internal virtual;
    function _transferLockedToken(address _to, uint192 _amount) internal virtual;
}

/**
 * @author Musket
 * @author NiKa
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/liquidity/Liquidity.sol";
import "../libraries/types/SpotHouseStorage.sol";
import "../libraries/helper/Errors.sol";
import "../interfaces/IConcentratedLiquidityNFT.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "@positionex/matching-engine/contracts/libraries/helper/FixedPoint128.sol";
import "@positionex/matching-engine/contracts/libraries/helper/Math.sol";
import "../interfaces/IConcentratedLiquidity.sol";
import "../libraries/helper/LiquidityHelper.sol";
import "../staking/PositionStakingDexManager.sol";

abstract contract ConcentratedLiquidity is IConcentratedLiquidity {
    using UserLiquidity for UserLiquidity.Data;

    mapping(uint256 => UserLiquidity.Data)
        public
        override concentratedLiquidity;
    IPositionStakingDexManager stakingManager;

    struct AddLiquidityParams {
        IMatchingEngineAMM pool;
        uint128 amountVirtual;
        uint32 indexedPipRange;
        bool isBase;
    }

    function addLiquidity(AddLiquidityParams calldata params)
        public
        payable
        virtual
    {
        address user = _msgSender();
        uint256 _addedAmountVirtual = depositLiquidity(
            params.pool,
            user,
            params.isBase
                ? SpotHouseStorage.Asset.Base
                : SpotHouseStorage.Asset.Quote,
            params.amountVirtual
        );

        ResultAddLiquidity memory _resultAddLiquidity = _addLiquidity(
            uint128(_addedAmountVirtual),
            params.isBase,
            params.indexedPipRange,
            _getCurrentIndexPipRange(params.pool),
            params.pool
        );

        uint256 amountModifySecondAsset = depositLiquidity(
            params.pool,
            user,
            params.isBase
                ? SpotHouseStorage.Asset.Quote
                : SpotHouseStorage.Asset.Base,
            params.isBase
                ? _resultAddLiquidity.quoteAmountAdded
                : _resultAddLiquidity.baseAmountAdded
        );
        require(
            params.isBase
                ? amountModifySecondAsset >=
                    _resultAddLiquidity.quoteAmountAdded
                : amountModifySecondAsset >=
                    _resultAddLiquidity.baseAmountAdded,
            "not support"
        );

        uint256 nftTokenId = mint(user);

        concentratedLiquidity[nftTokenId] = UserLiquidity.Data({
            liquidity: uint128(_resultAddLiquidity.liquidity),
            indexedPipRange: params.indexedPipRange,
            feeGrowthBase: _resultAddLiquidity.feeGrowthBase,
            feeGrowthQuote: _resultAddLiquidity.feeGrowthQuote,
            pool: params.pool
        });

        emit LiquidityAdded(
            user,
            address(params.pool),
            _resultAddLiquidity.baseAmountAdded,
            _resultAddLiquidity.quoteAmountAdded,
            params.indexedPipRange,
            nftTokenId
        );
    }

    function removeLiquidity(uint256 nftTokenId) public virtual {
        UserLiquidity.Data memory liquidityData = concentratedLiquidity[
            nftTokenId
        ];

        burn(nftTokenId);

        delete concentratedLiquidity[nftTokenId];

        (
            uint128 baseAmountRemoved,
            uint128 quoteAmountRemoved
        ) = _removeLiquidity(liquidityData, liquidityData.liquidity);

        UserLiquidity.CollectFeeData memory _collectFeeData;

        _collectFeeData = _collectFee(
            liquidityData.pool,
            liquidityData.feeGrowthBase,
            liquidityData.feeGrowthQuote,
            liquidityData.liquidity,
            liquidityData.indexedPipRange
        );

        address user = _msgSender();

        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Base,
            baseAmountRemoved + _collectFeeData.feeBaseAmount
        );

        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Quote,
            quoteAmountRemoved + _collectFeeData.feeQuoteAmount
        );

        emit LiquidityRemoved(
            user,
            address(liquidityData.pool),
            baseAmountRemoved,
            quoteAmountRemoved,
            liquidityData.indexedPipRange,
            liquidityData.liquidity
        );
    }

    function increaseLiquidity(
        uint256 nftTokenId,
        uint128 amountModify,
        bool isBase
    ) public payable virtual {
        UserLiquidity.Data memory liquidityData = concentratedLiquidity[
            nftTokenId
        ];
        address user = _msgSender();
        amountModify = uint128(
            depositLiquidity(
                liquidityData.pool,
                user,
                isBase
                    ? SpotHouseStorage.Asset.Base
                    : SpotHouseStorage.Asset.Quote,
                amountModify
            )
        );

        ResultAddLiquidity memory _resultAddLiquidity = _addLiquidity(
            amountModify,
            isBase,
            liquidityData.indexedPipRange,
            _getCurrentIndexPipRange(liquidityData.pool),
            liquidityData.pool
        );

        uint256 amountModifySecondAsset = depositLiquidity(
            liquidityData.pool,
            user,
            isBase ? SpotHouseStorage.Asset.Quote : SpotHouseStorage.Asset.Base,
            isBase
                ? _resultAddLiquidity.quoteAmountAdded
                : _resultAddLiquidity.baseAmountAdded
        );

        require(
            isBase
                ? amountModifySecondAsset >=
                    _resultAddLiquidity.quoteAmountAdded
                : amountModifySecondAsset >=
                    _resultAddLiquidity.baseAmountAdded,
            "not support"
        );

        UserLiquidity.CollectFeeData memory _collectFeeData = _collectFee(
            liquidityData.pool,
            liquidityData.feeGrowthBase,
            liquidityData.feeGrowthQuote,
            liquidityData.liquidity,
            liquidityData.indexedPipRange
        );

        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Base,
            _collectFeeData.feeBaseAmount
        );

        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Quote,
            _collectFeeData.feeQuoteAmount
        );

        concentratedLiquidity[nftTokenId].updateLiquidity(
            liquidityData.liquidity + uint128(_resultAddLiquidity.liquidity),
            liquidityData.indexedPipRange,
            _collectFeeData.newFeeGrowthBase,
            _collectFeeData.newFeeGrowthQuote
        );

        _updateStakingLiquidity(
            user,
            nftTokenId,
            address(liquidityData.pool),
            uint128(_resultAddLiquidity.liquidity),
            ModifyType.INCREASE
        );

        emit LiquidityModified(
            user,
            address(liquidityData.pool),
            _resultAddLiquidity.baseAmountAdded,
            _resultAddLiquidity.quoteAmountAdded,
            ModifyType.INCREASE,
            liquidityData.indexedPipRange,
            uint128(_resultAddLiquidity.liquidity)
        );
    }

    function decreaseLiquidity(uint256 nftTokenId, uint128 liquidity)
        public
        virtual
    {
        UserLiquidity.Data memory liquidityData = concentratedLiquidity[
            nftTokenId
        ];

        //        require(liquidityData.liquidity >= liquidity, "!Liquidity");

        if (liquidity > liquidityData.liquidity) {
            liquidity = liquidityData.liquidity;
        }

        (
            uint128 baseAmountRemoved,
            uint128 quoteAmountRemoved
        ) = _removeLiquidity(liquidityData, liquidity);

        UserLiquidity.CollectFeeData memory _collectFeeData = _collectFee(
            liquidityData.pool,
            liquidityData.feeGrowthBase,
            liquidityData.feeGrowthQuote,
            liquidityData.liquidity,
            liquidityData.indexedPipRange
        );

        concentratedLiquidity[nftTokenId].updateLiquidity(
            liquidityData.liquidity - liquidity,
            liquidityData.indexedPipRange,
            _collectFeeData.newFeeGrowthBase,
            _collectFeeData.feeQuoteAmount
        );

        // current 5
        address user = _msgSender();
        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Base,
            baseAmountRemoved + _collectFeeData.feeBaseAmount
        );

        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Quote,
            quoteAmountRemoved + _collectFeeData.feeQuoteAmount
        );
        _updateStakingLiquidity(
            user,
            nftTokenId,
            address(liquidityData.pool),
            liquidity,
            ModifyType.DECREASE
        );

        emit LiquidityModified(
            user,
            address(liquidityData.pool),
            baseAmountRemoved,
            quoteAmountRemoved,
            ModifyType.DECREASE,
            liquidityData.indexedPipRange,
            liquidity
        );
    }

    struct ShiftRangeState {
        UserLiquidity.Data liquidityData;
        UserLiquidity.CollectFeeData collectFeeData;
        ResultAddLiquidity resultAddLiquidity;
        address user;
        uint256 currentIndexedPipRange;
        uint128 baseReceiveEstimate;
        uint128 quoteReceiveEstimate;
    }

    function shiftRange(
        uint256 nftTokenId,
        uint32 targetIndex,
        uint128 amountNeeded,
        bool isBase
    ) public payable virtual {
        ShiftRangeState memory state;

        state.liquidityData = concentratedLiquidity[nftTokenId];

        state.currentIndexedPipRange = _getCurrentIndexPipRange(
            state.liquidityData.pool
        );

        require(
            targetIndex != state.liquidityData.indexedPipRange,
            Errors.LQ_INDEX_RANGE_NOT_DIFF
        );

        state.collectFeeData = _collectFee(
            state.liquidityData.pool,
            state.liquidityData.feeGrowthBase,
            state.liquidityData.feeGrowthQuote,
            state.liquidityData.liquidity,
            state.liquidityData.indexedPipRange
        );

        (
            uint128 baseAmountRemoved,
            uint128 quoteAmountRemoved
        ) = _removeLiquidity(
                state.liquidityData,
                state.liquidityData.liquidity
            );

        state.baseReceiveEstimate =
            baseAmountRemoved +
            uint128(state.collectFeeData.feeBaseAmount);
        state.quoteReceiveEstimate =
            quoteAmountRemoved +
            uint128(state.collectFeeData.feeQuoteAmount);

        if (isBase) {
            state.baseReceiveEstimate += amountNeeded;
        } else {
            state.quoteReceiveEstimate += amountNeeded;
        }
        if (
            (targetIndex > state.currentIndexedPipRange &&
                state.baseReceiveEstimate == 0) ||
            (targetIndex < state.currentIndexedPipRange &&
                state.quoteReceiveEstimate == 0)
        ) {
            revert("Invalid amount");
        }

        state.resultAddLiquidity = _addLiquidity(
            // calculate based on BaseAmount. Keep the amount of Base if
            // targetIndex > liquidityData.indexedPipRange
            // else Calculate based on QuoteAmount. Keep the amount of Quote
            isBase ? state.baseReceiveEstimate : state.quoteReceiveEstimate,
            isBase,
            targetIndex,
            state.currentIndexedPipRange,
            state.liquidityData.pool
        );

        state.user = _msgSender();
        {
            if (
                quoteAmountRemoved + state.collectFeeData.feeQuoteAmount <
                state.resultAddLiquidity.quoteAmountAdded
            ) {
                depositLiquidity(
                    state.liquidityData.pool,
                    state.user,
                    SpotHouseStorage.Asset.Quote,
                    state.resultAddLiquidity.quoteAmountAdded -
                        quoteAmountRemoved -
                        state.collectFeeData.feeQuoteAmount
                );
            } else {
                withdrawLiquidity(
                    state.liquidityData.pool,
                    state.user,
                    SpotHouseStorage.Asset.Quote,
                    quoteAmountRemoved +
                        state.collectFeeData.feeQuoteAmount -
                        state.resultAddLiquidity.quoteAmountAdded
                );
            }

            if (
                baseAmountRemoved + state.collectFeeData.feeBaseAmount <
                state.resultAddLiquidity.baseAmountAdded
            ) {
                depositLiquidity(
                    state.liquidityData.pool,
                    state.user,
                    SpotHouseStorage.Asset.Base,
                    state.resultAddLiquidity.baseAmountAdded -
                        baseAmountRemoved -
                        state.collectFeeData.feeBaseAmount
                );
            } else {
                withdrawLiquidity(
                    state.liquidityData.pool,
                    state.user,
                    SpotHouseStorage.Asset.Base,
                    baseAmountRemoved +
                        state.collectFeeData.feeBaseAmount -
                        state.resultAddLiquidity.baseAmountAdded
                );
            }
        }

        concentratedLiquidity[nftTokenId].updateLiquidity(
            uint128(state.resultAddLiquidity.liquidity),
            targetIndex,
            state.resultAddLiquidity.feeGrowthBase,
            state.resultAddLiquidity.feeGrowthQuote
        );

        _updateStakingLiquidity(
            state.user,
            nftTokenId,
            address(state.liquidityData.pool),
            uint128(state.resultAddLiquidity.liquidity),
            state.resultAddLiquidity.liquidity > state.liquidityData.liquidity
                ? ModifyType.INCREASE
                : ModifyType.DECREASE
        );

        emit LiquidityShiftRange(
            state.user,
            address(state.liquidityData.pool),
            state.liquidityData.indexedPipRange,
            state.liquidityData.liquidity,
            baseAmountRemoved,
            quoteAmountRemoved,
            targetIndex,
            uint128(state.resultAddLiquidity.liquidity),
            state.resultAddLiquidity.baseAmountAdded,
            state.resultAddLiquidity.quoteAmountAdded
        );
    }

    function collectFee(uint256 nftTokenId) public virtual {
        UserLiquidity.Data memory liquidityData = concentratedLiquidity[
            nftTokenId
        ];
        UserLiquidity.CollectFeeData memory _collectFeeData;
        _collectFeeData = _collectFee(
            liquidityData.pool,
            liquidityData.feeGrowthBase,
            liquidityData.feeGrowthQuote,
            liquidityData.liquidity,
            liquidityData.indexedPipRange
        );

        address user = _msgSender();
        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Base,
            _collectFeeData.feeBaseAmount
        );

        withdrawLiquidity(
            liquidityData.pool,
            user,
            SpotHouseStorage.Asset.Quote,
            _collectFeeData.feeQuoteAmount
        );
        concentratedLiquidity[nftTokenId].feeGrowthBase = _collectFeeData
            .newFeeGrowthBase;
        concentratedLiquidity[nftTokenId].feeGrowthQuote = _collectFeeData
            .newFeeGrowthQuote;
    }

    function liquidity(uint256 nftTokenId)
        public
        view
        virtual
        returns (
            uint128 baseVirtual,
            uint128 quoteVirtual,
            uint128 liquidity,
            uint256 indexedPipRange,
            uint256 feeBasePending,
            uint256 feeQuotePending,
            IMatchingEngineAMM pool
        )
    {
        UserLiquidity.Data memory liquidityData = concentratedLiquidity[
            nftTokenId
        ];
        UserLiquidity.CollectFeeData memory _collectFeeData;
        _collectFeeData = _collectFee(
            liquidityData.pool,
            liquidityData.feeGrowthBase,
            liquidityData.feeGrowthQuote,
            liquidityData.liquidity,
            liquidityData.indexedPipRange
        );

        (
            uint128 baseAmountRemoved,
            uint128 quoteAmountRemoved,

        ) = liquidityData.pool.estimateRemoveLiquidity(
                IAutoMarketMakerCore.RemoveLiquidity({
                    liquidity: liquidityData.liquidity,
                    indexedPipRange: liquidityData.indexedPipRange,
                    feeGrowthBase: liquidityData.feeGrowthBase,
                    feeGrowthQuote: liquidityData.feeGrowthQuote
                })
            );

        return (
            baseAmountRemoved,
            quoteAmountRemoved,
            liquidityData.liquidity,
            liquidityData.indexedPipRange,
            _collectFeeData.feeBaseAmount,
            _collectFeeData.feeQuoteAmount,
            liquidityData.pool
        );
    }

    function getAllDataTokens(uint256[] memory tokens)
        public
        view
        returns (UserLiquidity.Data[] memory)
    {
        UserLiquidity.Data[] memory LiquidityData;
        return LiquidityData;
    }

    //------------------------------------------------------------------------------------------------------------------
    // INTERNAL FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function _msgSender() internal view virtual returns (address) {}

    struct ResultAddLiquidity {
        uint128 baseAmountAdded;
        uint128 quoteAmountAdded;
        uint256 liquidity;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
    }

    struct State {
        uint128 baseAmountModify;
        uint128 quoteAmountModify;
        uint256 currentIndexedPipRange;
        SpotFactoryStorage.Pair pair;
        address WBNBAddress;
        uint128 currentPrice;
        uint128 maxPip;
        uint128 minPip;
        uint128 basicPoint;
    }

    function _addLiquidity(
        uint128 amountModify,
        bool isBase,
        uint32 indexedPipRange,
        uint256 currentIndexedPipRange,
        IMatchingEngineAMM pool
    ) internal returns (ResultAddLiquidity memory result) {
        State memory state;
        state.currentIndexedPipRange = currentIndexedPipRange;
        state.currentPrice = pool.getCurrentPip();

        (state.minPip, state.maxPip) = LiquidityMath.calculatePipRange(
            indexedPipRange,
            _getPipRange(pool)
        );

        ////
        state.pair = _getQuoteAndBase(pool);

        // TODO consider necessary to check it
        //        state.WBNBAddress = _getWBNBAddress();
        //        if (state.pair.QuoteAsset == state.WBNBAddress) {
        //            require(!isBase, "not support");
        //        }
        //
        //        if (state.pair.BaseAsset == state.WBNBAddress) {
        //            require(isBase, "not support");
        //        }

        if (
            (indexedPipRange < state.currentIndexedPipRange) ||
            (indexedPipRange == state.currentIndexedPipRange &&
                state.currentPrice == state.maxPip)
        ) {
            if (isBase) revert("!Base");

            state.quoteAmountModify = amountModify;
        } else if (
            (indexedPipRange > state.currentIndexedPipRange) ||
            (indexedPipRange == state.currentIndexedPipRange &&
                state.currentPrice == state.minPip)
        ) {
            if (!isBase) revert("!Quote");
            state.baseAmountModify = amountModify;
        } else if (indexedPipRange == state.currentIndexedPipRange) {
            state.maxPip = uint128(Math.sqrt(uint256(state.maxPip) * 10**18));
            state.minPip = uint128(Math.sqrt(uint256(state.minPip) * 10**18));
            state.currentPrice = uint128(
                Math.sqrt(uint256(state.currentPrice) * 10**18)
            );

            if (isBase) {
                uint128 baseReal = LiquidityMath.calculateBaseReal(
                    state.maxPip,
                    amountModify,
                    state.currentPrice
                );

                state.baseAmountModify = amountModify;
                state.quoteAmountModify = LiquidityHelper
                    .calculateQuoteVirtualFromBaseReal(
                        LiquidityMath.calculateBaseReal(
                            state.maxPip,
                            amountModify,
                            state.currentPrice
                        ),
                        state.currentPrice,
                        state.minPip,
                        uint128(Math.sqrt(pool.basisPoint()))
                    );
            } else {
                uint128 quoteReal = LiquidityMath.calculateQuoteReal(
                    state.minPip,
                    amountModify,
                    state.currentPrice
                );

                state.quoteAmountModify = amountModify;
                state.baseAmountModify =
                    LiquidityHelper.calculateBaseVirtualFromQuoteReal(
                        LiquidityMath.calculateQuoteReal(
                            state.minPip,
                            amountModify,
                            state.currentPrice
                        ),
                        state.currentPrice,
                        state.maxPip
                    ) *
                    uint128(pool.basisPoint());
            }
        }

        (
            result.baseAmountAdded,
            result.quoteAmountAdded,
            result.liquidity,
            result.feeGrowthBase,
            result.feeGrowthQuote
        ) = pool.addLiquidity(
            IAutoMarketMakerCore.AddLiquidity({
                baseAmount: state.baseAmountModify,
                quoteAmount: state.quoteAmountModify,
                indexedPipRange: indexedPipRange
            })
        );
    }

    function _removeLiquidity(
        UserLiquidity.Data memory liquidityData,
        uint128 liquidity
    ) internal returns (uint128 baseAmount, uint128 quoteAmount) {
        if (liquidity == 0) return (baseAmount, quoteAmount);
        return
            liquidityData.pool.removeLiquidity(
                IAutoMarketMakerCore.RemoveLiquidity({
                    liquidity: liquidity,
                    indexedPipRange: liquidityData.indexedPipRange,
                    feeGrowthBase: liquidityData.feeGrowthBase,
                    feeGrowthQuote: liquidityData.feeGrowthQuote
                })
            );
    }

    function _collectFee(
        IMatchingEngineAMM pool,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote,
        uint128 liquidity,
        uint32 indexedPipRange
    ) internal view returns (UserLiquidity.CollectFeeData memory _feeData) {
        (
            ,
            ,
            ,
            ,
            ,
            _feeData.newFeeGrowthBase,
            _feeData.newFeeGrowthQuote,

        ) = pool.liquidityInfo(indexedPipRange);

        _feeData.feeBaseAmount = Math.mulDiv(
            _feeData.newFeeGrowthBase - feeGrowthBase,
            liquidity,
            FixedPoint128.Q_POW18
        );
        _feeData.feeQuoteAmount = Math.mulDiv(
            _feeData.newFeeGrowthQuote - feeGrowthQuote,
            liquidity,
            FixedPoint128.Q_POW18
        );
    }

    function _getPipRange(IMatchingEngineAMM pool)
        internal
        returns (uint128 pipRange)
    {
        return pool.getPipRange();
    }

    function _getCurrentIndexPipRange(IMatchingEngineAMM pool)
        internal
        returns (uint256)
    {
        return pool.currentIndexedPipRange();
    }

    function _getCurrentPrice(IMatchingEngineAMM pool)
        internal
        returns (uint128)
    {}

    function depositLiquidity(
        IMatchingEngineAMM _pairManager,
        address _payer,
        SpotHouseStorage.Asset _asset,
        uint256 _amount
    ) internal virtual returns (uint256 amount) {}

    function withdrawLiquidity(
        IMatchingEngineAMM _pairManager,
        address _recipient,
        SpotHouseStorage.Asset _asset,
        uint256 _amount
    ) internal virtual {}

    function _getQuoteAndBase(IMatchingEngineAMM _managerAddress)
        internal
        view
        virtual
        returns (SpotFactoryStorage.Pair memory pair)
    {}

    function _getWBNBAddress() internal view virtual returns (address) {}

    function _updateStakingLiquidity(
        address user,
        uint256 tokenId,
        address poolId,
        uint128 deltaLiquidityModify,
        ModifyType modifyType
    ) internal {
        if (address(stakingManager) != address(0)) {
            stakingManager.updateLiquidity(
                user,
                tokenId,
                poolId,
                deltaLiquidityModify,
                modifyType
            );
        }
    }

    function _isOwnerWhenStaking(address user, uint256 nftId)
        internal
        view
        returns (bool)
    {
        if (address(stakingManager) != address(0)) {
            return stakingManager.isOwnerWhenStaking(user, nftId);
        }

        return false;
    }

    function mint(address user) internal virtual returns (uint256 tokenId) {}

    function burn(uint256 tokenId) internal virtual {}
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/VotesUpgradeable.sol";

/// @title Manage the Liquidity NFT
/// @notice This NFT is voteable
abstract contract ConcentratedLiquidityNFT is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable
{
    uint256 public tokenID;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeConsecutiveTokenTransfer(
        address from,
        address to,
        uint256, /*first*/
        uint96 size
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeConsecutiveTokenTransfer(from, to, 0, size);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Adjusts votes when tokens are transferred.
     *
     * Emits a {Votes-DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner.
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function tokensOfOwner(address owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 balance = balanceOf(owner);
        uint256[] memory tokens = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokens;
    }

    function _burnNFT(uint256 tokenId) internal {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burn: caller is not owner nor approved"
        );
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/liquidity/Liquidity.sol";

//import "../spot-exchange/libraries/liquidity/PoolLiquidity.sol";
//import "../spot-exchange/libraries/liquidity/LiquidityInfo.sol";

interface IConcentratedLiquidity {
    enum ModifyType {
        INCREASE,
        DECREASE
    }

    //------------------------------------------------------------------------------------------------------------------
    // FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    // @dev get all data of nft
    function getAllDataTokens(uint256[] memory tokens)
        external
        view
        returns (UserLiquidity.Data[] memory);

    // @dev get data of nft
    function concentratedLiquidity(uint256 tokenId)
        external
        view
        returns (
            uint128 liquidity,
            uint32 indexedPipRange,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote,
            IMatchingEngineAMM pool
        );

    //------------------------------------------------------------------------------------------------------------------
    // EVENTS
    //------------------------------------------------------------------------------------------------------------------

    event LiquidityAdded(
        address user,
        address pool,
        uint256 amountBaseAdded,
        uint256 amountQuoteAdded,
        uint64 indexedPipRange,
        uint256 nftId
    );

    event LiquidityRemoved(
        address user,
        address pool,
        uint256 amountBaseRemoved,
        uint256 amountQuoteRemoved,
        uint64 indexedPipRange,
        uint128 removedLiquidity
    );

    event LiquidityModified(
        address user,
        address pool,
        uint256 amountBaseModified,
        uint256 amountQuoteModified,
        // 0: increase
        // 1: decrease
        ModifyType modifyType,
        uint64 indexedPipRange,
        uint128 modifiedLiquidity
    );

    event LiquidityShiftRange(
        address user,
        address pool,
        uint64 oldIndexedPipRange,
        uint128 liquidityRemoved,
        uint256 amountBaseRemoved,
        uint256 amountQuoteRemoved,
        uint64 newIndexedPipRange,
        uint128 newLiquidity,
        uint256 amountBaseAdded,
        uint256 amountQuoteAded
    );
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "../libraries/liquidity/Liquidity.sol";

interface IConcentratedLiquidityNFT is IERC721Upgradeable {
    function voteFor() external;

    function voteAgainst() external;
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./IConcentratedLiquidity.sol";
import "./IConcentratedLiquidityNFT.sol";

interface IPositionConcentratedLiquidity is
    IConcentratedLiquidity,
    IConcentratedLiquidityNFT
{}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/types/SpotFactoryStorage.sol";

interface ISpotFactory {
    event PairManagerInitialized(
        address quoteAsset,
        address baseAsset,
        uint256 basisPoint,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        address owner,
        address pairManager,
        uint256 pipRange,
        uint256 tickSpace
    );

    function createPairManager(
        address quoteAsset,
        address baseAsset,
        uint256 basisPoint,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        uint128 pipRange,
        uint32 tickSpace
    ) external;

    function getPairManager(address quoteAsset, address baseAsset)
        external
        view
        returns (address pairManager);

    function getQuoteAndBase(address pairManager)
        external
        view
        returns (SpotFactoryStorage.Pair memory);

    function isPairManagerExist(address pairManager)
        external
        view
        returns (bool);

    function getPairManagerSupported(address tokenA, address tokenB)
        external
        view
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        );
}

pragma solidity ^0.8.9;

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function balanceOf(address guy) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library SpotLimitOrder {
    struct Data {
        uint128 pip;
        uint64 orderId;
        bool isBuy;
        uint40 blockNumber;
        uint16 fee;
        uint128 quoteAmount;
        uint128 baseAmount;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Convert {
    function Uint256ToUint128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint64(uint256 x) internal pure returns (uint64) {
        return uint64(x);
    }

    function Uint256ToUint32(uint256 x) internal pure returns (uint32) {
        return uint32(x);
    }

    function toI256(uint256 x) internal pure returns (int256) {
        return int256(x);
    }

    function toI128(uint256 x) internal pure returns (int128) {
        return int128(int256(x));
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }

    function abs256(int128 x) internal pure returns (uint256) {
        return uint256(uint128(x >= 0 ? x : -x));
    }

    function toU128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint40(uint256 x) internal returns (uint40) {
        return uint40(x);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/**
 *  - VL = ValidationLogic
 *  - MATH = Math libraries

 */
library Errors {
    //common errors
    string public constant VL_EMPTY_ADDRESS = "1";
    string public constant VL_ONLY_COUNTERPARTY = "2";
    string public constant VL_LONG_PRICE_THAN_CURRENT_PRICE = "3";
    string public constant VL_SHORT_PRICE_LESS_CURRENT_PRICE = "4";
    string public constant VL_INVALID_SIZE = "6.1";
    string public constant VL_INVALID_PAIR_INFO = "6.2";
    string public constant VL_INVALID_ORDER_ID = "6.3";
    string public constant VL_EXPIRED = "7";
    string public constant VL_NOT_ENOUGH_LIQUIDITY = "8";
    string public constant VL_NOT_ENOUGH_QUOTE_FUNDING = "9";
    string public constant VL_NOT_ENOUGH_BASE_FUNDING = "10";
    string public constant VL_MUST_NOT_FILLED = "11";
    string public constant VL_SPOT_MANGER_NOT_EXITS = "12";
    string public constant VL_SPOT_MANGER_EXITS = "13";
    string public constant VL_NO_AMOUNT_TO_CLAIM = "14";
    string public constant VL_NO_LIMIT_TO_CANCEL = "15";
    string public constant VL_ONLY_OWNER = "16";
    string public constant VL_MUST_IDENTICAL_ADDRESSES = "17";
    string public constant VL_MUST_NOT_INITIALIZABLE = "18";
    string public constant VL_MUST_NOT_TOKEN_USE_RFI = "19";
    string public constant VL_ONLY_LIQUIDITY_POOL = "!LP";
    string public constant VL_NEED_MORE_BNB = "20";
    string public constant VL_MUST_CLOSE_TO_INDEX_PRICE_SHORT = "21.1";
    string public constant VL_MUST_CLOSE_TO_INDEX_PRICE_LONG = "21.2";

    // Liquidity Errors
    string public constant LQ_NO_LIQUIDITY_BASE = "30";
    string public constant LQ_NO_LIQUIDITY_QUOTE = "31";
    string public constant LQ_NO_LIQUIDITY = "32";
    string public constant LQ_POOL_EXIST = "33";
    string public constant LQ_INDEX_RANGE_NOT_DIFF = "34";
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./TradeConvert.sol";
import "./Convert.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "@positionex/matching-engine/contracts/libraries/helper/LiquidityMath.sol";
import "@positionex/matching-engine/contracts/libraries/helper/Math.sol";

library LiquidityHelper {
    function calculateQuoteVirtualFromBaseReal(
        uint128 baseReal,
        uint128 sqrtCurrentPrice,
        uint128 sqrtPriceMin,
        uint256 sqrtBasicPoint
    ) internal view returns (uint128) {
        return
            uint128(
                (uint256(baseReal) *
                    uint256(sqrtCurrentPrice / sqrtBasicPoint) *
                    (uint256(sqrtCurrentPrice / sqrtBasicPoint) -
                        uint256(sqrtPriceMin / sqrtBasicPoint))) / 10**18
            );
    }

    function calculateBaseVirtualFromQuoteReal(
        uint128 quoteReal,
        uint128 sqrtCurrentPrice,
        uint128 sqrtPriceMax
    ) internal returns (uint128) {
        return
            uint128(
                (uint256(quoteReal) *
                    10**18 *
                    (uint256(sqrtPriceMax) - uint256(sqrtCurrentPrice))) /
                    (uint256(sqrtCurrentPrice**2 * sqrtPriceMax))
            );
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library TradeConvert {
    // convert from base amount to quote amount by pip
    function baseToQuote(
        uint256 quantity,
        uint128 pip,
        uint256 basisPoint
    ) internal view returns (uint256) {
        // quantity * pip / baseBasisPoint / basisPoint / baseBasisPoint;
        // shorten => quantity * pip / basisPoint ;
        return (quantity * pip) / basisPoint;
    }

    function quoteToBase(
        uint256 quoteAmount,
        uint128 pip,
        uint256 basisPoint
    ) public view returns (uint256) {
        return (quoteAmount * basisPoint) / pip;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }

    function transferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        token.transferFrom(from, to, value);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library U128Math {
    function add(uint128 a, uint128 b) internal pure returns (uint128) {
        return a + b;
    }

    function baseToQuote(
        uint128 quantity,
        uint128 pip,
        uint128 basisPoint
    ) internal pure returns (uint128) {
        return
            uint128((uint256(quantity) * uint256(pip)) / uint256(basisPoint));
    }

    function quoteToBase(
        uint128 quantity,
        uint128 pip,
        uint128 basisPoint
    ) internal pure returns (uint128) {
        return
            uint128((uint256(quantity) * uint256(basisPoint)) / uint256(pip));
    }

    function toU256(uint128 a) internal pure returns (uint256) {
        return uint256(a);
    }

    function toInt128(uint128 a) internal pure returns (int128) {
        return int128(a);
    }

    function toInt256(uint128 a) internal pure returns (int256) {
        return int256(int128(a));
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        return a - b;
    }

    function mul(uint128 a, uint256 b) internal pure returns (uint256) {
        return uint256(a) * b;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";

library UserLiquidity {
    struct Data {
        uint128 liquidity;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
        IMatchingEngineAMM pool;
    }

    struct CollectFeeData {
        uint256 feeBaseAmount;
        uint256 feeQuoteAmount;
        uint256 newFeeGrowthBase;
        uint256 newFeeGrowthQuote;
    }

    function updateLiquidity(
        Data storage self,
        uint128 liquidity,
        uint32 indexedPipRange,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote
    ) internal {
        self.liquidity = liquidity;
        self.indexedPipRange = indexedPipRange;
        self.feeGrowthBase = feeGrowthBase;
        self.feeGrowthQuote = feeGrowthQuote;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SpotFactoryStorage {
    address public spotHouse;

    address public positionLiquidity;

    struct Pair {
        address BaseAsset;
        address QuoteAsset;
    }

    //  baseAsset address => quoteAsset address => spotManager address
    mapping(address => mapping(address => address)) internal pathPairManagers;

    mapping(address => Pair) internal allPairManager;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;

    mapping(address => bool) public allowedAddressAddPair;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../exchange/SpotOrderData.sol";
import "../../interfaces/ISpotFactory.sol";
import "../../WithdrawBNB.sol";

contract SpotHouseStorage {
    using SpotLimitOrder for mapping(address => mapping(address => SpotLimitOrder.Data[]));

    ISpotFactory public spotFactory;

    address public WBNB;

    mapping(address => mapping(address => SpotLimitOrder.Data[]))
        public limitOrders;
    enum Side {
        BUY,
        SELL
    }

    uint128 feeBasis;

    // fee 0.01 %
    uint16 public fee;

    enum Asset {
        Quote,
        Base,
        Fee
    }

    struct PendingLimitOrder {
        bool isBuy;
        uint256 quantity;
        uint256 partialFilled;
        uint128 pip;
        uint256 blockNumber;
        uint256 orderIdOfTrader;
        uint64 orderId;
        uint16 fee;
    }

    struct OpenLimitResp {
        uint64 orderId;
        uint256 sizeOut;
    }

    address public positionRouter;

    IWithdrawBNB public withdrawBNB;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./implement/ConcentratedLiquidity.sol";
import "./implement/ConcentratedLiquidityNFT.sol";

import "./libraries/helper/TransferHelper.sol";

contract PositionConcentratedLiquidity is
    ConcentratedLiquidity,
    ConcentratedLiquidityNFT,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    modifier nftOwner(uint256 nftId) {
        require(_msgSender() == ownerOf(nftId), "!Owner");
        _;
    }

    modifier nftOwnerOrStaking(uint256 nftId) {
        require(
            (_msgSender() == ownerOf(nftId)) ||
                _isOwnerWhenStaking(_msgSender(), nftId),
            "!Owner"
        );
        _;
    }

    ISpotFactory public spotFactory;
    IWithdrawBNB withdrawBNB;
    address WBNB;

    mapping(address => bool) public counterParties;

    function initialize() external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __ERC721_init("Position Liquidity Pool", "PLP");
        tokenID = 1000000;
    }

    function setFactory(ISpotFactory _sportFactory) public onlyOwner {
        spotFactory = _sportFactory;
    }

    function setStakingManager(IPositionStakingDexManager _stakingManager)
        public
        onlyOwner
    {
        stakingManager = _stakingManager;
    }

    function getStakingManager() public view returns (address) {
        return address(stakingManager);
    }

    function addLiquidity(AddLiquidityParams calldata params)
        public
        payable
        override(ConcentratedLiquidity)
        nonReentrant
    {
        super.addLiquidity(params);
    }

    function removeLiquidity(uint256 nftTokenId)
        public
        override(ConcentratedLiquidity)
        nonReentrant
        nftOwner(nftTokenId)
    {
        super.removeLiquidity(nftTokenId);
    }

    function decreaseLiquidity(uint256 nftTokenId, uint128 liquidity)
        public
        override(ConcentratedLiquidity)
        nonReentrant
        nftOwnerOrStaking(nftTokenId)
    {
        super.decreaseLiquidity(nftTokenId, liquidity);
    }

    function increaseLiquidity(
        uint256 nftTokenId,
        uint128 amountModify,
        bool isBase
    )
        public
        payable
        override(ConcentratedLiquidity)
        nonReentrant
        nftOwnerOrStaking(nftTokenId)
    {
        super.increaseLiquidity(nftTokenId, amountModify, isBase);
    }

    function shiftRange(
        uint256 nftTokenId,
        uint32 targetIndex,
        uint128 amountNeeded,
        bool isBase
    )
        public
        payable
        override(ConcentratedLiquidity)
        nonReentrant
        nftOwnerOrStaking(nftTokenId)
    {
        super.shiftRange(nftTokenId, targetIndex, amountNeeded, isBase);
    }

    function collectFee(uint256 nftTokenId)
        public
        override(ConcentratedLiquidity)
        nonReentrant
        nftOwner(nftTokenId)
    {
        super.collectFee(nftTokenId);
    }

    function mint(address user)
        internal
        override(ConcentratedLiquidity)
        returns (uint256 tokenId)
    {
        tokenId = tokenID + 1;
        _mint(user, tokenId);
        tokenID = tokenId;
    }

    function burn(uint256 tokenId) internal override(ConcentratedLiquidity) {
        _burnNFT(tokenId);
    }

    function getAllToken(address owner)
        external
        view
        returns (UserLiquidity.Data[] memory, uint256[] memory)
    {
        uint256[] memory tokens = tokensOfOwner(owner);
        return (getAllDataTokens(tokens), tokens);
    }

    function setCounterParty(address _newCounterParty) external onlyOwner {
        counterParties[_newCounterParty] = true;
    }

    function revokeCounterParty(address _account) external onlyOwner {
        counterParties[_account] = false;
    }

    function donatePool(
        IMatchingEngineAMM pool,
        uint256 base,
        uint256 quote
    ) external {
        depositLiquidity(
            pool,
            _msgSender(),
            SpotHouseStorage.Asset.Quote,
            quote
        );
        depositLiquidity(pool, _msgSender(), SpotHouseStorage.Asset.Base, base);
    }

    function _getQuoteAndBase(IMatchingEngineAMM _managerAddress)
        internal
        view
        override(ConcentratedLiquidity)
        returns (SpotFactoryStorage.Pair memory pair)
    {
        pair = spotFactory.getQuoteAndBase(address(_managerAddress));
        require(pair.BaseAsset != address(0), "!0x");
    }

    function depositLiquidity(
        IMatchingEngineAMM _pairManager,
        address _payer,
        SpotHouseStorage.Asset _asset,
        uint256 _amount
    ) internal override(ConcentratedLiquidity) returns (uint256 amount) {
        if (_amount == 0) return 0;
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );
        address pairManagerAddress = address(_pairManager);
        if (_asset == SpotHouseStorage.Asset.Quote) {
            if (_pairAddress.QuoteAsset == WBNB) {
                _depositBNB(pairManagerAddress, _amount);
            } else {
                IERC20 quoteAsset = IERC20(_pairAddress.QuoteAsset);
                uint256 _balanceBefore = quoteAsset.balanceOf(
                    pairManagerAddress
                );
                TransferHelper.transferFrom(
                    quoteAsset,
                    _payer,
                    pairManagerAddress,
                    _amount
                );
                uint256 _balanceAfter = quoteAsset.balanceOf(
                    pairManagerAddress
                );
                _amount = _balanceAfter - _balanceBefore;
            }
        } else {
            if (_pairAddress.BaseAsset == WBNB) {
                _depositBNB(pairManagerAddress, _amount);
            } else {
                IERC20 baseAsset = IERC20(_pairAddress.BaseAsset);
                uint256 _balanceBefore = baseAsset.balanceOf(
                    pairManagerAddress
                );
                TransferHelper.transferFrom(
                    baseAsset,
                    _payer,
                    pairManagerAddress,
                    _amount
                );
                uint256 _balanceAfter = baseAsset.balanceOf(pairManagerAddress);
                _amount = _balanceAfter - _balanceBefore;
            }
        }
        return _amount;
    }

    function withdrawLiquidity(
        IMatchingEngineAMM _pairManager,
        address _recipient,
        SpotHouseStorage.Asset _asset,
        uint256 _amount
    ) internal override(ConcentratedLiquidity) {
        address user = _msgSender();
        if (_amount == 0) return;
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );

        address pairManagerAddress = address(_pairManager);
        if (_asset == SpotHouseStorage.Asset.Quote) {
            if (_pairAddress.QuoteAsset == WBNB) {
                _withdrawBNB(_recipient, pairManagerAddress, _amount);
            } else {
                TransferHelper.transferFrom(
                    IERC20(_pairAddress.QuoteAsset),
                    address(_pairManager),
                    _recipient,
                    _amount
                );
            }
        } else {
            if (_pairAddress.BaseAsset == WBNB) {
                _withdrawBNB(_recipient, pairManagerAddress, _amount);
            } else {
                TransferHelper.transferFrom(
                    IERC20(_pairAddress.BaseAsset),
                    address(_pairManager),
                    _recipient,
                    _amount
                );
            }
        }
    }

    function _depositBNB(address _pairManagerAddress, uint256 _amount)
        internal
    {
        require(msg.value >= _amount, Errors.VL_NEED_MORE_BNB);
        IWBNB(WBNB).deposit{value: _amount}();
        assert(IWBNB(WBNB).transfer(_pairManagerAddress, _amount));
    }

    function _withdrawBNB(
        address _trader,
        address _pairManagerAddress,
        uint256 _amount
    ) internal {
        IWBNB(WBNB).transferFrom(
            _pairManagerAddress,
            address(withdrawBNB),
            _amount
        );
        withdrawBNB.withdraw(_trader, _amount);
    }

    function _msgSender()
        internal
        view
        override(ContextUpgradeable, ConcentratedLiquidity)
        returns (address)
    {
        return msg.sender;
    }

    function _getWBNBAddress()
        internal
        view
        override(ConcentratedLiquidity)
        returns (address)
    {
        return WBNB;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@positionex/posi-token/contracts/VestingScheduleBase.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/IPositionConcentratedLiquidity.sol";
import "../libraries/helper/U128Math.sol";

interface IPositionReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission)
        external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

interface IPosiTreasury {
    function mint(address recipient, uint256 amount) external;
}

interface IPositionStakingDexManager {
    function updateLiquidity(
        address user,
        uint256 tokenId,
        address poolId,
        uint128 deltaLiquidityModify,
        IPositionConcentratedLiquidity.ModifyType modifyType
    ) external;

    function isOwnerWhenStaking(address user, uint256 tokenId)
        external
        view
        returns (bool);
}

contract PositionStakingDexManager is
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    VestingScheduleBase
{
    using SafeMath for uint256;
    using U128Math for uint128;

    // Info of each user.
    struct UserInfo {
        uint128 amount; // How many LP tokens the user has provided.
        uint128 rewardDebt; // Reward debt. See explanation below.
        uint128 rewardLockedUp; // Reward locked up.
        uint128 nextHarvestUntil; // When can the user harvest again.
        //
        // We do some fancy math here. Basically, any point in time, the amount of Positions
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPositionPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPositionPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        address poolId;
        uint256 totalStaked;
        uint256 allocPoint; // How many allocation points assigned to this pool. Positions to distribute per block.
        uint256 lastRewardBlock; // Last block number that Positions distribution occurs.
        uint256 accPositionPerShare; // Accumulated Positions per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint128 harvestInterval; // Harvest interval in seconds
    }

    // The Position TOKEN!
    IERC20 public position;
    IPosiTreasury public posiTreasury;

    //    IPosiStakingManager public posiStakingManager;
    IPositionConcentratedLiquidity public concentratedLiquidityNft;
    //    IERC721 public liquidityNFT;
    // Dev address.
    address public devAddress;
    // Position tokens created per block.
    uint256 public positionPerBlock;
    // Deposit Fee address
    address public feeAddress;
    // Bonus muliplier for early position makers.
    uint256 public BONUS_MULTIPLIER;
    // Max harvest interval: 14 days.
    uint256 public MAXIMUM_HARVEST_INTERVAL;

    // Info of each pool.
    mapping(address => PoolInfo) public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(address => mapping(address => UserInfo)) public userInfo;
    address[] public pools;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // The block number when Position mining starts.
    uint256 public startBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;

    uint256 public posiStakingPid;

    // Position referral contract address.
    IPositionReferral public positionReferral;
    // Referral commission rate in basis points.
    uint16 public referralCommissionRate;
    // Max referral commission rate: 10%.
    uint16 public MAXIMUM_REFERRAL_COMMISSION_RATE;

    uint256 public stakingMinted;

    uint16 harvestFeeShareRate;
    uint16 public MAXIMUM_HARVEST_FEE_SHARE;

    // user => poolId => nftId[]
    mapping(address => mapping(address => uint256[])) public userNft;
    // nftid => poolId => its index in userNft
    mapping(uint256 => mapping(address => uint256)) public nftOwnedIndex;

    event Deposit(address indexed user, address indexed pid, uint256 amount);
    event Withdraw(address indexed user, address indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        address indexed pid,
        uint256 amount
    );
    event EmissionRateUpdated(
        address indexed caller,
        uint256 previousAmount,
        uint256 newAmount
    );
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );
    event RewardLockedUp(
        address indexed user,
        address indexed pid,
        uint256 amountLockedUp
    );
    event NFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );

    function initialize(
        IERC20 _position,
        IPositionConcentratedLiquidity _positionConcentratedLiquidity,
        uint256 _startBlock
    ) external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();

        position = _position;
        startBlock = _startBlock;

        concentratedLiquidityNft = _positionConcentratedLiquidity;

        devAddress = _msgSender();
        feeAddress = _msgSender();

        referralCommissionRate = 100;
        MAXIMUM_REFERRAL_COMMISSION_RATE = 1000;

        harvestFeeShareRate = 1;
        MAXIMUM_HARVEST_FEE_SHARE = 10000;

        BONUS_MULTIPLIER = 1;

        MAXIMUM_HARVEST_INTERVAL = 14 days;

        totalAllocPoint = 0;
    }

    function poolLength() external view returns (uint256) {
        return pools.length;
    }

    //    // get position per block form the staking manager share to the contract

    function getPlayerIds(address owner, address pid)
        public
        view
        returns (uint256[] memory)
    {
        return userNft[owner][pid];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        emit NFTReceived(operator, from, tokenId, data);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY_OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function setPositionPerBlock(uint256 _positionPerBlock) public onlyOwner {
        massUpdatePools();
        positionPerBlock = _positionPerBlock;
    }

    function setPositionTreasury(IPosiTreasury _posiTreasury) public onlyOwner {
        posiTreasury = _posiTreasury;
    }

    function setPositionEarningToken(IERC20 _positionEarningToken)
        public
        onlyOwner
    {
        position = _positionEarningToken;
    }

    function updatePositionLiquidityPool(address _newLiquidityPool)
        public
        onlyOwner
    {
        concentratedLiquidityNft = IPositionConcentratedLiquidity(
            _newLiquidityPool
        );
    }

    function updateHarvestFeeShareRate(uint16 newRate) public onlyOwner {
        // max share 10%
        require(newRate <= 1000, "!F");
        harvestFeeShareRate = newRate;
    }

    function setPosiStakingPid(uint256 _posiStakingPid) public onlyOwner {
        posiStakingPid = _posiStakingPid;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        address _poolId,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint128 _harvestInterval,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "add: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "add: invalid harvest interval"
        );
        require(poolInfo[_poolId].poolId == address(0x00), "pool created");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        pools.push(_poolId);
        poolInfo[_poolId] = PoolInfo({
            poolId: _poolId,
            totalStaked: 0,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accPositionPerShare: 0,
            depositFeeBP: _depositFeeBP,
            harvestInterval: _harvestInterval
        });
    }

    // Update the given pool's Position allocation point and deposit fee. Can only be called by the owner.
    function set(
        address _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint128 _harvestInterval,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "set: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "set: invalid harvest interval"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending Positions on frontend.
    function pendingPosition(address _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accPositionPerShare = pool.accPositionPerShare;
        uint256 lpSupply = pool.totalStaked;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 positionReward = multiplier
                .mul(positionPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accPositionPerShare = accPositionPerShare.add(
                positionReward.mul(1e12).div(lpSupply)
            );
        }
        uint256 pending = user.amount.mul(accPositionPerShare).div(1e12).sub(
            user.rewardDebt
        );
        return pending.add(user.rewardLockedUp);
    }

    // View function to see if user can harvest Positions.
    function canHarvest(address _pid, address _user)
        public
        view
        returns (bool)
    {
        UserInfo memory user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = pools.length;
        for (uint256 i = 0; i < length; ++i) {
            updatePool(pools[i]);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(address _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        // SLOAD
        PoolInfo memory _pool = pool;
        if (block.number <= _pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = _pool.totalStaked;
        if (lpSupply == 0 || _pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 positionReward = multiplier
            .mul(positionPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);

        stakingMinted = stakingMinted.add(
            positionReward.add(positionReward.div(10))
        );
        posiTreasury.mint(address(this), positionReward);
        // transfer 10% to the dev wallet
        posiTreasury.mint(devAddress, positionReward.div(10));
        pool.accPositionPerShare = pool.accPositionPerShare.add(
            positionReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to PosiStakingManager for Position allocation.
    function stake(uint256 _nftId) public nonReentrant {
        _stake(_nftId, address(0));
    }

    function stakeWithReferral(uint256 _nftId, address _referrer)
        public
        nonReentrant
    {
        _stake(_nftId, _referrer);
    }

    function _stake(uint256 _nftId, address _referrer) internal {
        UserLiquidity.Data memory nftData = _getConcentratedLiquidity(_nftId);
        address poolAddress = address(nftData.pool);
        require(
            poolInfo[poolAddress].poolId != address(0x00),
            "pool not created"
        );
        require(poolAddress != address(0x0), "invalid liquidity pool");
        uint256[] storage nftIds = userNft[msg.sender][poolAddress];
        if (nftIds.length == 0) {
            nftIds.push(0);
            nftOwnedIndex[0][poolAddress] = 0;
        }
        nftIds.push(_nftId);
        nftOwnedIndex[_nftId][poolAddress] = nftIds.length - 1;

        PoolInfo storage pool = poolInfo[poolAddress];
        UserInfo storage user = userInfo[poolAddress][msg.sender];
        updatePool(poolAddress);
        if (
            nftData.liquidity > 0 &&
            address(positionReferral) != address(0) &&
            _referrer != address(0) &&
            _referrer != msg.sender
        ) {
            positionReferral.recordReferral(msg.sender, _referrer);
        }
        payOrLockupPendingPosition(poolAddress);
        _transferNFTIn(_nftId);
        user.amount = user.amount.add(nftData.liquidity);
        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
        pool.totalStaked += nftData.liquidity;
        emit Deposit(msg.sender, poolAddress, _nftId);
    }

    // Withdraw LP tokens from PosiStakingManager.
    function unstake(uint256 _nftId) public nonReentrant {
        _unstake(_nftId);
    }

    function _unstake(uint256 _nftId) internal {
        UserLiquidity.Data memory nftData = _getConcentratedLiquidity(_nftId);
        address poolAddress = address(nftData.pool);

        PoolInfo storage pool = poolInfo[poolAddress];
        UserInfo storage user = userInfo[poolAddress][msg.sender];

        removeNftFromUser(_nftId, poolAddress);

        require(user.amount >= nftData.liquidity, "withdraw: not good");

        updatePool(poolAddress);

        payOrLockupPendingPosition(poolAddress);

        user.amount = user.amount.sub(nftData.liquidity);
        _transferNFTOut(_nftId);

        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
        pool.totalStaked -= nftData.liquidity;

        emit Withdraw(msg.sender, poolAddress, _nftId);
    }

    function withdraw(address pid) public nonReentrant {
        _withdraw(pid);
    }

    function _withdraw(address pid) internal {
        uint256[] memory nfts = userNft[msg.sender][pid];
        for (uint8 index = 1; index < nfts.length; index++) {
            if (nfts[index] > 0) {
                _unstake(nfts[index]);
            }
        }
    }

    function harvest(address pid) public nonReentrant {
        _harvest(pid);
    }

    function _harvest(address pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount > 0, "No nft staked");
        updatePool(pid);
        payOrLockupPendingPosition(pid);
        user.rewardDebt = uint128(
            user.amount.mul(pool.accPositionPerShare).div(1e12)
        );
    }

    function exit(address pid) external nonReentrant {
        _withdraw(pid);
        //        _harvest(pid);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(address _pid) public nonReentrant {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        uint256[] memory nfts = userNft[msg.sender][_pid];
        for (uint8 index = 1; index < nfts.length; index++) {
            uint256 _nftId = nfts[index];
            if (_nftId > 0) {
                _transferNFTOut(_nftId);
                emit EmergencyWithdraw(msg.sender, _pid, _nftId);
            }
        }
    }

    function isOwnerWhenStaking(address user, uint256 nftId)
        external
        view
        returns (bool)
    {
        UserLiquidity.Data memory nftData = _getConcentratedLiquidity(nftId);
        uint256 indexNftId = nftOwnedIndex[nftId][address(nftData.pool)];
        return userNft[user][address(nftData.pool)][indexNftId] == nftId;
    }

    function updateLiquidity(
        address user,
        uint256 tokenId,
        address poolId,
        uint128 deltaLiquidityModify,
        IPositionConcentratedLiquidity.ModifyType modifyType
    ) external {
        require(
            msg.sender == address(concentratedLiquidityNft),
            "only concentrated liquidity"
        );

        if (concentratedLiquidityNft.ownerOf(tokenId) == address(this)) {
            PoolInfo storage pool = poolInfo[poolId];
            UserInfo storage user = userInfo[poolId][user];

            updatePool(poolId);

            payOrLockupPendingPosition(poolId);

            user.amount = modifyType ==
                IConcentratedLiquidity.ModifyType.INCREASE
                ? user.amount.add(deltaLiquidityModify)
                : user.amount.sub(deltaLiquidityModify);

            user.rewardDebt = uint128(
                user.amount.mul(pool.accPositionPerShare).div(1e12)
            );

            pool.totalStaked = modifyType ==
                IConcentratedLiquidity.ModifyType.INCREASE
                ? pool.totalStaked + deltaLiquidityModify
                : pool.totalStaked - deltaLiquidityModify;
        }
    }

    // Pay or lockup pending Positions.
    function payOrLockupPendingPosition(address _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil =
                uint128(block.timestamp) +
                pool.harvestInterval;
        }

        uint256 pending = user
            .amount
            .mul(pool.accPositionPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(
                    user.rewardLockedUp
                );
                user.rewardLockedUp = 0;
                user.nextHarvestUntil =
                    uint128(block.timestamp) +
                    pool.harvestInterval;

                // send rewards
                safePositionTransfer(msg.sender, totalRewards);
                payReferralCommission(msg.sender, totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = uint128(
                user.rewardLockedUp.add(uint128(pending))
            );
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    function removeNftFromUser(uint256 _nftId, address _pid) internal {
        uint256[] memory _nftIds = userNft[msg.sender][_pid];
        uint256 nftIndex = nftOwnedIndex[_nftId][_pid];
        require(_nftIds[nftIndex] == _nftId, "not gegoId owner");
        uint256 _nftArrLength = _nftIds.length - 1;
        uint256 tailId = _nftIds[_nftArrLength];
        userNft[msg.sender][_pid][nftIndex] = tailId;
        userNft[msg.sender][_pid][_nftArrLength] = 0;
        userNft[msg.sender][_pid].pop();
        nftOwnedIndex[tailId][_pid] = nftIndex;
        nftOwnedIndex[_nftId][_pid] = 0;
    }

    // Safe position transfer function, just in case if rounding error causes pool to not have enough Positions.
    function safePositionTransfer(address _to, uint256 _amount) internal {
        uint256 positionBal = position.balanceOf(address(this));
        if (_amount > positionBal) {
            _amount = positionBal;
        }
        if (_isWhitelistVesting(msg.sender)) {
            position.transfer(_to, _amount);
        } else {
            // receive 5%
            position.transfer(_to, (_amount * 5) / 100);
            _addSchedules(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function setDevAddress(address _devAddress) public {
        require(msg.sender == devAddress, "setDevAddress: FORBIDDEN");
        require(_devAddress != address(0), "setDevAddress: ZERO");
        devAddress = _devAddress;
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        require(_feeAddress != address(0), "setFeeAddress: ZERO");
        feeAddress = _feeAddress;
    }

    // Update the position referral contract address by the owner
    function setPositionReferral(IPositionReferral _positionReferral)
        public
        onlyOwner
    {
        positionReferral = _positionReferral;
    }

    // Update referral commission rate by the owner
    function setReferralCommissionRate(uint16 _referralCommissionRate)
        public
        onlyOwner
    {
        require(
            _referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE,
            "setReferralCommissionRate: invalid referral commission rate basis points"
        );
        referralCommissionRate = _referralCommissionRate;
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _user, uint256 _pending) internal {
        if (
            address(positionReferral) != address(0) &&
            referralCommissionRate > 0
        ) {
            address referrer = positionReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(
                10000
            );

            if (referrer != address(0) && commissionAmount > 0) {
                if (position.balanceOf(address(this)) < commissionAmount) {
                    posiTreasury.mint(address(this), commissionAmount);
                }
                position.transfer(referrer, commissionAmount);
                positionReferral.recordReferralCommission(
                    referrer,
                    commissionAmount
                );
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

    function _transferNFTOut(uint256 id) internal {
        concentratedLiquidityNft.safeTransferFrom(
            address(this),
            msg.sender,
            id
        );
    }

    function _transferNFTIn(uint256 id) internal {
        concentratedLiquidityNft.safeTransferFrom(
            msg.sender,
            address(this),
            id
        );
    }

    function _transferLockedToken(address _to, uint192 _amount)
        internal
        override
    {
        position.transfer(_to, _amount);
    }

    function _getConcentratedLiquidity(uint256 tokenId)
        internal
        view
        returns (UserLiquidity.Data memory data)
    {
        (
            data.liquidity,
            data.indexedPipRange,
            data.feeGrowthBase,
            data.feeGrowthQuote,
            data.pool
        ) = concentratedLiquidityNft.concentratedLiquidity(tokenId);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import {Errors} from "./libraries/helper/Errors.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IWBNB.sol";

interface IWithdrawBNB {
    function withdraw(address recipient, uint256 _amount) external;
}

contract WithdrawBNB is IWithdrawBNB {
    using Address for address payable;
    IWBNB public WBNB;
    address public owner;
    address public spotHouse;

    modifier onlyOwner() {
        require(msg.sender == owner, Errors.VL_ONLY_OWNER);
        _;
    }

    modifier onlyCounterParty() {
        require(msg.sender == spotHouse, Errors.VL_ONLY_COUNTERPARTY);
        _;
    }

    receive() external payable {
        assert(msg.sender == address(WBNB));
        // only accept BNB via fallback from the WBNB contract
    }

    constructor(IWBNB _WBNB) {
        owner = msg.sender;
        WBNB = _WBNB;
    }

    function setWBNB(IWBNB _newWBNB) external onlyOwner {
        WBNB = _newWBNB;
    }

    function transferOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setSpotHouse(address _newSpotHouse) external onlyOwner {
        spotHouse = _newSpotHouse;
    }

    function withdraw(address recipient, uint256 amount)
        external
        override
        onlyCounterParty
    {
        WBNB.withdraw(amount);
        payable(recipient).sendValue(amount);
    }
}