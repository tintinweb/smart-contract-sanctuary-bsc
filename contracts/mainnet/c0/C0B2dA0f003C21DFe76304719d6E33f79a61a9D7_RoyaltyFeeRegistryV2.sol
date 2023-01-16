// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Errors.sol";
import {IRoyaltyFeeRegistryV2} from "./interfaces/IRoyaltyFeeRegistryV2.sol";
import {RoyaltyFeeTypes} from "./libraries/RoyaltyFeeTypes.sol";

/**
 * @title RoyaltyFeeRegistryV2
 * @notice It is a royalty fee registry for the Joepeg exchange and auction house.
 */
contract RoyaltyFeeRegistryV2 is
    IRoyaltyFeeRegistryV2,
    Initializable,
    OwnableUpgradeable
{
    using RoyaltyFeeTypes for RoyaltyFeeTypes.FeeInfoPart;

    /// @notice Max royalty fee bp allowed (10,000 = 100%)
    uint256 public royaltyFeeLimit;

    /// @notice Max number of royalty fee recipients allowed
    uint8 public maxNumRecipients;

    /// @notice Stores royalty fee information for collections
    mapping(address => RoyaltyFeeTypes.FeeInfoPart[])
        public royaltyFeeInfoPartsCollection;

    /// @notice Stores setter address for collections whose royalty fee information
    /// are overridden
    mapping(address => address) public royaltyFeeInfoPartsCollectionSetter;

    event RoyaltyFeeLimitSet(
        uint256 oldRoyaltyFeeLimit,
        uint256 newRoyaltyFeeLimit
    );
    event MaxNumRecipientsSet(
        uint256 oldMaxNumRecipients,
        uint256 newMaxNumRecipients
    );
    event RoyaltyFeeInfoSet(
        address indexed collection,
        address indexed setter,
        RoyaltyFeeTypes.FeeInfoPart[] feeInfoParts
    );

    modifier isValidRoyaltyFeeLimit(uint256 _royaltyFeeLimit) {
        if (_royaltyFeeLimit > 9500) {
            revert RoyaltyFeeRegistryV2__RoyaltyFeeLimitTooHigh();
        }
        _;
    }

    modifier isValidMaxNumRecipients(uint256 _maxNumRecipients) {
        if (_maxNumRecipients == 0) {
            revert RoyaltyFeeRegistryV2__InvalidMaxNumRecipients();
        }
        _;
    }

    /**
     * @notice Initializer
     * @param _royaltyFeeLimit new royalty fee limit (500 = 5%, 1,000 = 10%)
     * @param _maxNumRecipients new maximum number of royalty fee recipients allowed
     */
    function initialize(uint256 _royaltyFeeLimit, uint8 _maxNumRecipients)
        public
        initializer
    {
        __Ownable_init();

        _updateRoyaltyFeeLimit(_royaltyFeeLimit);
        _updateMaxNumRecipients(_maxNumRecipients);
    }

    /**
     * @notice Update royalty fee limit
     * @param _royaltyFeeLimit new royalty fee limit (500 = 5%, 1,000 = 10%)
     */
    function updateRoyaltyFeeLimit(uint256 _royaltyFeeLimit)
        external
        override
        onlyOwner
    {
        _updateRoyaltyFeeLimit(_royaltyFeeLimit);
    }

    /**
     * @notice Update royalty fee limit
     * @param _royaltyFeeLimit new royalty fee limit (500 = 5%, 1,000 = 10%)
     */
    function _updateRoyaltyFeeLimit(uint256 _royaltyFeeLimit)
        internal
        isValidRoyaltyFeeLimit(_royaltyFeeLimit)
    {
        uint256 oldRoyaltyFeeLimit = royaltyFeeLimit;
        royaltyFeeLimit = _royaltyFeeLimit;

        emit RoyaltyFeeLimitSet(oldRoyaltyFeeLimit, _royaltyFeeLimit);
    }

    /**
     * @notice Update `maxNumRecipients`
     * @param _maxNumRecipients new max number of recipients allowed
     */
    function updateMaxNumRecipients(uint8 _maxNumRecipients)
        external
        override
        onlyOwner
    {
        _updateMaxNumRecipients(_maxNumRecipients);
    }

    /**
     * @notice Update `maxNumRecipients`
     * @param _maxNumRecipients new max number of recipients allowed
     */
    function _updateMaxNumRecipients(uint8 _maxNumRecipients)
        internal
        isValidMaxNumRecipients(_maxNumRecipients)
        onlyOwner
    {
        uint8 oldMaxNumRecipients = maxNumRecipients;
        maxNumRecipients = _maxNumRecipients;

        emit MaxNumRecipientsSet(oldMaxNumRecipients, _maxNumRecipients);
    }

    /**
     * @notice Update royalty info for collection
     * @param _collection address of the NFT contract
     * @param _setter address that sets the receivers
     * @param _feeInfoParts contains receiver and fee information
     */
    function updateRoyaltyInfoPartsForCollection(
        address _collection,
        address _setter,
        RoyaltyFeeTypes.FeeInfoPart[] memory _feeInfoParts
    ) external override onlyOwner {
        uint256 numFeeInfoParts = _feeInfoParts.length;
        if (numFeeInfoParts > maxNumRecipients) {
            revert RoyaltyFeeRegistryV2__TooManyFeeRecipients();
        }
        if (_setter == address(0)) {
            revert RoyaltyFeeRegistryV2__RoyaltyFeeSetterCannotBeNullAddr();
        }

        delete royaltyFeeInfoPartsCollection[_collection];
        RoyaltyFeeTypes.FeeInfoPart[]
            storage feeInfoPartsForCollection = royaltyFeeInfoPartsCollection[
                _collection
            ];

        uint256 totalFees;

        for (uint256 i; i < numFeeInfoParts; i++) {
            RoyaltyFeeTypes.FeeInfoPart memory feeInfoPart = _feeInfoParts[i];
            if (feeInfoPart.receiver == address(0)) {
                revert RoyaltyFeeRegistryV2__RoyaltyFeeRecipientCannotBeNullAddr();
            }
            if (feeInfoPart.fee == 0) {
                revert RoyaltyFeeRegistryV2__RoyaltyFeeCannotBeZero();
            }
            totalFees += feeInfoPart.fee;
            feeInfoPartsForCollection.push(feeInfoPart);
        }

        if (totalFees > royaltyFeeLimit) {
            revert RoyaltyFeeRegistryV2__RoyaltyFeeTooHigh();
        }

        royaltyFeeInfoPartsCollectionSetter[_collection] = _setter;

        emit RoyaltyFeeInfoSet(_collection, _setter, _feeInfoParts);
    }

    /**
     * @notice Get royalty info for collection
     * @param _collection address of the NFT contract
     * @param _amount contains receiver and fee information
     */
    function royaltyAmountParts(address _collection, uint256 _amount)
        external
        view
        override
        returns (RoyaltyFeeTypes.FeeAmountPart[] memory)
    {
        RoyaltyFeeTypes.FeeInfoPart[]
            memory feeInfoParts = royaltyFeeInfoPartsCollection[_collection];
        uint256 numFeeInfoParts = feeInfoParts.length;
        RoyaltyFeeTypes.FeeAmountPart[]
            memory feeAmountParts = new RoyaltyFeeTypes.FeeAmountPart[](
                numFeeInfoParts
            );
        for (uint256 i; i < numFeeInfoParts; i++) {
            RoyaltyFeeTypes.FeeInfoPart memory feeInfoPart = feeInfoParts[i];
            feeAmountParts[i] = RoyaltyFeeTypes.FeeAmountPart({
                receiver: feeInfoPart.receiver,
                amount: (_amount * feeInfoPart.fee) / 10_000
            });
        }
        return feeAmountParts;
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
pragma solidity ^0.8.0;

// JoepegAuctionHouse
error JoepegAuctionHouse__AuctionAlreadyExists();
error JoepegAuctionHouse__CurrencyMismatch();
error JoepegAuctionHouse__ExpectedNonNullAddress();
error JoepegAuctionHouse__ExpectedNonZeroFinalSellerAmount();
error JoepegAuctionHouse__FeesHigherThanExpected();
error JoepegAuctionHouse__InvalidDropInterval();
error JoepegAuctionHouse__InvalidDuration();
error JoepegAuctionHouse__InvalidMinPercentageToAsk();
error JoepegAuctionHouse__InvalidStartTime();
error JoepegAuctionHouse__NoAuctionExists();
error JoepegAuctionHouse__OnlyAuctionCreatorCanCancel();
error JoepegAuctionHouse__UnsupportedCurrency();

error JoepegAuctionHouse__EnglishAuctionCannotBidOnUnstartedAuction();
error JoepegAuctionHouse__EnglishAuctionCannotBidOnEndedAuction();
error JoepegAuctionHouse__EnglishAuctionCannotCancelWithExistingBid();
error JoepegAuctionHouse__EnglishAuctionCannotSettleUnstartedAuction();
error JoepegAuctionHouse__EnglishAuctionCannotSettleWithoutBid();
error JoepegAuctionHouse__EnglishAuctionCreatorCannotPlaceBid();
error JoepegAuctionHouse__EnglishAuctionInsufficientBidAmount();
error JoepegAuctionHouse__EnglishAuctionInvalidMinBidIncrementPct();
error JoepegAuctionHouse__EnglishAuctionInvalidRefreshTime();
error JoepegAuctionHouse__EnglishAuctionOnlyCreatorCanSettleBeforeEndTime();

error JoepegAuctionHouse__DutchAuctionCannotSettleUnstartedAuction();
error JoepegAuctionHouse__DutchAuctionCreatorCannotSettle();
error JoepegAuctionHouse__DutchAuctionInsufficientAmountToSettle();
error JoepegAuctionHouse__DutchAuctionInvalidStartEndPrice();

// RoyaltyFeeManager
error RoyaltyFeeManager__InvalidRoyaltyFeeRegistryV2();
error RoyaltyFeeManager__RoyaltyFeeRegistryV2AlreadyInitialized();

// RoyaltyFeeRegistryV2
error RoyaltyFeeRegistryV2__InvalidMaxNumRecipients();
error RoyaltyFeeRegistryV2__RoyaltyFeeCannotBeZero();
error RoyaltyFeeRegistryV2__RoyaltyFeeLimitTooHigh();
error RoyaltyFeeRegistryV2__RoyaltyFeeRecipientCannotBeNullAddr();
error RoyaltyFeeRegistryV2__RoyaltyFeeSetterCannotBeNullAddr();
error RoyaltyFeeRegistryV2__RoyaltyFeeTooHigh();
error RoyaltyFeeRegistryV2__TooManyFeeRecipients();

// RoyaltyFeeSetterV2
error RoyaltyFeeSetterV2__CollectionCannotSupportERC2981();
error RoyaltyFeeSetterV2__CollectionIsNotNFT();
error RoyaltyFeeSetterV2__NotCollectionAdmin();
error RoyaltyFeeSetterV2__NotCollectionOwner();
error RoyaltyFeeSetterV2__NotCollectionSetter();
error RoyaltyFeeSetterV2__SetterAlreadySet();

// PendingOwnable
error PendingOwnable__NotOwner();
error PendingOwnable__AddressZero();
error PendingOwnable__NotPendingOwner();
error PendingOwnable__PendingOwnerAlreadySet();
error PendingOwnable__NoPendingOwner();

// PendingOwnableUpgradeable
error PendingOwnableUpgradeable__NotOwner();
error PendingOwnableUpgradeable__AddressZero();
error PendingOwnableUpgradeable__NotPendingOwner();
error PendingOwnableUpgradeable__PendingOwnerAlreadySet();
error PendingOwnableUpgradeable__NoPendingOwner();

// SafeAccessControlEnumerable
error SafeAccessControlEnumerable__SenderMissingRoleAndIsNotOwner(
    bytes32 role,
    address sender
);
error SafeAccessControlEnumerable__RoleIsDefaultAdmin();

// SafeAccessControlEnumerableUpgradeable
error SafeAccessControlEnumerableUpgradeable__SenderMissingRoleAndIsNotOwner(
    bytes32 role,
    address sender
);
error SafeAccessControlEnumerableUpgradeable__RoleIsDefaultAdmin();

// SafePausable
error SafePausable__AlreadyPaused();
error SafePausable__AlreadyUnpaused();

// SafePausableUpgradeable
error SafePausableUpgradeable__AlreadyPaused();
error SafePausableUpgradeable__AlreadyUnpaused();

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RoyaltyFeeTypes} from "../libraries/RoyaltyFeeTypes.sol";

interface IRoyaltyFeeRegistryV2 {
    function updateRoyaltyInfoPartsForCollection(
        address collection,
        address setter,
        RoyaltyFeeTypes.FeeInfoPart[] memory feeInfoParts
    ) external;

    function updateRoyaltyFeeLimit(uint256 _royaltyFeeLimit) external;

    function updateMaxNumRecipients(uint8 _maxNumRecipients) external;

    function royaltyAmountParts(address _collection, uint256 _amount)
        external
        view
        returns (RoyaltyFeeTypes.FeeAmountPart[] memory);

    function royaltyFeeInfoPartsCollectionSetter(address collection)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RoyaltyFeeTypes
 * @notice This library contains types related to royalty fees
 */
library RoyaltyFeeTypes {
    struct FeeInfoPart {
        address receiver;
        uint256 fee;
    }

    struct FeeAmountPart {
        address receiver;
        uint256 amount;
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