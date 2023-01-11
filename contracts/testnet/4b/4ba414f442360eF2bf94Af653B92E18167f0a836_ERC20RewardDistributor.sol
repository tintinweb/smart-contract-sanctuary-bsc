// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IERC20RewardDistributor.sol";
import "../../contract-registry/ContractEntity.sol";
import "../../contract-registry/Contracts.sol";
import "../../acl/direct/AccessControlledUpgradeable.sol";
import "./ERC20RewardDistributorStorage.sol";
import "./ERC20RewardDistributionHelper.sol";
import "../../listing/listing-manager/IListingManager.sol";
import "../../renting/renting-manager/IRentingManager.sol";

contract ERC20RewardDistributor is
    IERC20RewardDistributor,
    UUPSUpgradeable,
    ContractEntity,
    AccessControlledUpgradeable,
    ERC20RewardDistributorStorage
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    /**
     * @dev ERC20RewardDistributor initialization params.
     * @param acl ACL contract address.
     * @param metahub Metahub contract address.
     */
    struct ERC20RewardDistributorInitParams {
        IACL acl;
        IMetahub metahub;
    }

    /**
     * @dev Constructor that gets called for the implementation contract.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    function initialize(ERC20RewardDistributorInitParams calldata params) external initializer {
        __UUPSUpgradeable_init();

        _aclContract = IACL(params.acl);
        _metahub = IMetahub(params.metahub);
    }

    /// @inheritdoc IERC20RewardDistributor
    function distributeExternalReward(
        uint256 agreementId,
        address token,
        uint256 rewardAmount
    ) external returns (Accounts.RentalEarnings memory rentalExternalRewardEarnings) {
        Rentings.Agreement memory agreement = IRentingManager(_metahub.getContract(Contracts.RENTING_MANAGER))
            .rentalAgreementInfo(agreementId);
        ERC20RewardDistributionHelper.RentalExternalERC20RewardFees
            memory rentalExternalERC20RewardFees = ERC20RewardDistributionHelper.getRentalExternalERC20RewardFees(
                agreement,
                token,
                rewardAmount
            );

        if (rentalExternalERC20RewardFees.totalReward > 0) {
            IERC20Upgradeable(token).safeIncreaseAllowance(
                address(_metahub),
                rentalExternalERC20RewardFees.totalReward
            );

            Listings.Listing memory listing = IListingManager(_metahub.getContract(Contracts.LISTING_MANAGER))
                .listingInfo(agreement.listingId);

            rentalExternalRewardEarnings = IMetahub(_metahub).handleExternalERC20Reward(
                listing,
                agreement,
                rentalExternalERC20RewardFees
            );
        }
    }

    /**
     * @inheritdoc IContractEntity
     */
    function contractKey() external pure override returns (bytes4) {
        return Contracts.ERC20_REWARD_DISTRIBUTOR;
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view override(ContractEntity, IERC165) returns (bool) {
        return interfaceId == type(IERC20RewardDistributor).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../listing/Listings.sol";
import "../../renting/Rentings.sol";
import "../Accounts.sol";

interface IERC20RewardDistributor is IContractEntity {
    /**
     * @dev Thrown when the Warper has not set enough allowance for ERC20RewardDistributor.
     */
    error InsufficientAllowanceForDistribution(uint256 asked, uint256 provided);

    /**
     * @notice Executes a single distribution of external ERC20 reward.
     * @dev Before calling this function, an ERC20 increase allowance should be given
     *  for the `tokenAmount` of `token`
     *  by caller for Metahub.
     * @param agreementId The ID of related to the distribution Rental Agreement.
     * @param token Represents the ERC20 token that is being distributed.
     * @param rewardAmount Represents the `token` amount to be distributed as a reward.
     * @return rentalExternalRewardEarnings Represents external reward based earnings for all entities.
     */
    function distributeExternalReward(
        uint256 agreementId,
        address token,
        uint256 rewardAmount
    ) external returns (Accounts.RentalEarnings memory rentalExternalRewardEarnings);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IContractEntity.sol";
import "../metahub/core/IMetahub.sol";

abstract contract ContractEntity is IContractEntity, ERC165 {
    /**
     * @dev Metahub contract.
     * Contract (e.g. ACL, AssetClassRegistry etc), the Metahub depends on
     * still can be Contract Entities (with key), but
     * do not have the `_metahub` reference set.
     */
    IMetahub internal _metahub;

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IContractEntity).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title IQ Protocol Contracts and their keys.
 */
library Contracts {
    /**** Accounting ****/
    bytes4 public constant ERC20_REWARD_DISTRIBUTOR = bytes4(keccak256("ERC20RewardDistributor"));
    bytes4 public constant TOKEN_QUOTE = bytes4(keccak256("TokenQuote"));
    /**** ACL ****/
    bytes4 public constant ACL = bytes4(keccak256("ACL"));
    /**** Asset ****/
    bytes4 public constant ASSET_CLASS_REGISTRY = bytes4(keccak256("AssetClassRegistry"));
    /**** Listing & Listing Configurator ****/
    bytes4 public constant LISTING_MANAGER = bytes4(keccak256("ListingManager"));
    bytes4 public constant LISTING_CONFIGURATOR_REGISTRY = bytes4(keccak256("ListingConfiguratorRegistry"));
    bytes4 public constant LISTING_CONFIGURATOR_PRESET_FACTORY = bytes4(keccak256("ListingConfiguratorPresetFactory"));
    bytes4 public constant LISTING_STRATEGY_REGISTRY = bytes4(keccak256("ListingStrategyRegistry"));
    bytes4 public constant LISTING_TERMS_REGISTRY = bytes4(keccak256("ListingTermsRegistry"));
    bytes4 public constant FIXED_RATE_LISTING_CONTROLLER = bytes4(keccak256("FixedRateListingController"));
    bytes4 public constant FIXED_RATE_WITH_REWARD_LISTING_CONTROLLER =
        bytes4(keccak256("FixedRateWithRewardListingController"));
    /**** Renting ****/
    bytes4 public constant RENTING_MANAGER = bytes4(keccak256("RentingManager"));
    /**** Universe & Tax ****/
    bytes4 public constant UNIVERSE_REGISTRY = bytes4(keccak256("UniverseRegistry"));
    bytes4 public constant TAX_STRATEGY_REGISTRY = bytes4(keccak256("TaxStrategyRegistry"));
    bytes4 public constant TAX_TERMS_REGISTRY = bytes4(keccak256("TaxTermsRegistry"));
    bytes4 public constant FIXED_RATE_TAX_CONTROLLER = bytes4(keccak256("FixedRateTaxController"));
    bytes4 public constant FIXED_RATE_WITH_REWARD_TAX_CONTROLLER =
        bytes4(keccak256("FixedRateWithRewardTaxController"));
    /**** Warper ****/
    bytes4 public constant WARPER_MANAGER = bytes4(keccak256("WarperManager"));
    bytes4 public constant WARPER_PRESET_FACTORY = bytes4(keccak256("WarperPresetFactory"));
    /**** Wizards v1 ****/
    bytes4 public constant LISTING_WIZARD_V1 = bytes4(keccak256("ListingWizardV1"));
    bytes4 public constant GENERAL_GUILD_WIZARD_V1 = bytes4(keccak256("GeneralGuildWizardV1"));
    bytes4 public constant UNIVERSE_WIZARD_V1 = bytes4(keccak256("UniverseWizardV1"));
    bytes4 public constant WARPER_WIZARD_V1 = bytes4(keccak256("WarperWizardV1"));
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./IACL.sol";
import "../Roles.sol";

/**
 * @title Modifier provider for contracts that want to interact with the ACL contract.
 */
abstract contract AccessControlledUpgradeable is ContextUpgradeable {
    /**
     * @dev Modifier to make a function callable by the admin account.
     */
    modifier onlyAdmin() {
        _acl().checkRole(Roles.ADMIN, _msgSender());
        _;
    }

    /**
     * @dev Modifier to make a function callable by a supervisor account.
     */
    modifier onlySupervisor() {
        _acl().checkRole(Roles.SUPERVISOR, _msgSender());
        _;
    }

    /**
     * @dev return the IACL address
     */
    function _acl() internal view virtual returns (IACL);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../acl/direct/IACL.sol";

abstract contract ERC20RewardDistributorStorage {
    /**
     * @dev ACL contract.
     */
    IACL internal _aclContract;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../listing/listing-strategies/ListingStrategies.sol";
import "../../tax/tax-strategies/TaxStrategies.sol";
import "../../renting/Rentings.sol";

library ERC20RewardDistributionHelper {
    struct RentalExternalERC20RewardFees {
        address token;
        uint256 totalReward;
        uint256 listerRewardFee;
        uint256 renterRewardFee;
        uint256 universeRewardFee;
        uint256 protocolRewardFee;
    }

    /**
     * A constant that represents one hundred percent for calculation.
     * This defines a calculation precision for percentage values as two decimals.
     * For example: 1 is 0.01%, 100 is 1%, 10_000 is 100%.
     */
    uint16 private constant _HUNDRED_PERCENT = 10_000;

    function getRentalExternalERC20RewardFees(
        Rentings.Agreement memory agreement,
        address token,
        uint256 rewardAmount
    ) internal view returns (RentalExternalERC20RewardFees memory rentalExternalERC20RewardFees) {
        // Listing Terms will have equivalent (in terms of strategy type) Tax Terms.
        IListingTermsRegistry.ListingTerms memory listingTerms = agreement.agreementTerms.listingTerms;

        if (listingTerms.strategyId == ListingStrategies.FIXED_RATE_WITH_REWARD) {
            (
                uint16 listerRewardPercentage,
                uint16 universeRewardTaxPercentage,
                uint16 protocolRewardTaxPercentage
            ) = retrieveRewardPercentages(agreement);

            rentalExternalERC20RewardFees = calculateExternalRewardBasedFees(
                token,
                rewardAmount,
                listerRewardPercentage,
                universeRewardTaxPercentage,
                protocolRewardTaxPercentage
            );
        } else if (listingTerms.strategyId == ListingStrategies.FIXED_RATE) {
            rentalExternalERC20RewardFees = calculateExternalRewardForFixedRate(token, rewardAmount);
        }
    }

    function retrieveRewardPercentages(Rentings.Agreement memory agreement)
        internal
        view
        returns (
            uint16 listerRewardPercentage,
            uint16 universeRewardTaxPercentage,
            uint16 protocolRewardTaxPercentage
        )
    {
        IListingTermsRegistry.ListingTerms memory listingTerms = agreement.agreementTerms.listingTerms;
        ITaxTermsRegistry.TaxTerms memory universeTaxTerms = agreement.agreementTerms.universeTaxTerms;
        ITaxTermsRegistry.TaxTerms memory protocolTaxTerms = agreement.agreementTerms.protocolTaxTerms;

        (, listerRewardPercentage) = ListingStrategies.decodeFixedRateWithRewardListingStrategyParams(listingTerms);
        (, universeRewardTaxPercentage) = TaxStrategies.decodeFixedRateWithRewardTaxStrategyParams(universeTaxTerms);
        (, protocolRewardTaxPercentage) = TaxStrategies.decodeFixedRateWithRewardTaxStrategyParams(protocolTaxTerms);
    }

    function calculateExternalRewardBasedFees(
        address token,
        uint256 rewardAmount,
        uint16 listerRewardPercentage,
        uint16 universeRewardTaxPercentage,
        uint16 protocolRewardTaxPercentage
    ) internal pure returns (RentalExternalERC20RewardFees memory externalRewardFees) {
        externalRewardFees.token = token;
        externalRewardFees.totalReward = rewardAmount;
        uint256 leftoverRewardAmount = rewardAmount;

        externalRewardFees.universeRewardFee = (leftoverRewardAmount * universeRewardTaxPercentage) / _HUNDRED_PERCENT;
        if (leftoverRewardAmount <= externalRewardFees.universeRewardFee) {
            externalRewardFees.universeRewardFee = leftoverRewardAmount;
            return externalRewardFees;
        }
        leftoverRewardAmount -= externalRewardFees.universeRewardFee;

        externalRewardFees.protocolRewardFee = (leftoverRewardAmount * protocolRewardTaxPercentage) / _HUNDRED_PERCENT;
        if (leftoverRewardAmount <= externalRewardFees.protocolRewardFee) {
            externalRewardFees.protocolRewardFee = leftoverRewardAmount;
            return externalRewardFees;
        }
        leftoverRewardAmount -= externalRewardFees.protocolRewardFee;

        externalRewardFees.listerRewardFee = (leftoverRewardAmount * listerRewardPercentage) / _HUNDRED_PERCENT;
        if (leftoverRewardAmount <= externalRewardFees.listerRewardFee) {
            externalRewardFees.listerRewardFee = leftoverRewardAmount;
            return externalRewardFees;
        }
        externalRewardFees.renterRewardFee = leftoverRewardAmount - externalRewardFees.listerRewardFee;
    }

    function calculateExternalRewardForFixedRate(address token, uint256 rewardAmount)
        internal
        pure
        returns (RentalExternalERC20RewardFees memory externalRewardFees)
    {
        externalRewardFees.token = token;
        externalRewardFees.totalReward = rewardAmount;

        externalRewardFees.renterRewardFee = rewardAmount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";
import "../Listings.sol";

interface IListingManager is IContractEntity {
    /**
     * @dev Thrown when the message sender is not renting manager.
     */
    error CallerIsNotRentingManager();

    /**
     * @dev Thrown when the message sender does not own LISTING_WIZARD role and is not lister.
     * @param listingId The Listing ID.
     * @param account The account that was checked.
     */
    error AccountIsNotAuthorizedOperatorForListingManagement(uint256 listingId, address account);

    /**
     * @dev Thrown when the message sender does not own LISTING_WIZARD role
     */
    error AccountIsNotListingWizard(address account);

    /**
     * @dev Thrown when assets array is empty.
     */
    error EmptyAssetsArray();

    /**
     * @dev Thrown when asset collection is mismatched in one of the assets from assets array.
     */
    error AssetCollectionMismatch();

    /**
     * @dev Thrown when the original asset cannot be withdrawn because of active rentals
     * or other activity that requires asset to stay in the vault.
     */
    error AssetIsLocked();

    /**
     * @dev Thrown when the configurator returns a payment beneficiary different from lister.
     */
    error OnlyImmediatePayoutSupported();

    /**
     * @dev Thrown when the Listing with `listingId`
     * is not registered among present or historical Listings,
     * meaning it has never existed.
     * @param listingId The ID of Listing that never existed.
     */
    error ListingNeverExisted(uint256 listingId);

    /**
     * @dev Emitted when a new listing is created.
     * @param listingId Listing ID.
     * @param lister Lister account address.
     * @param assets Listing asset.
     * @param params Listing params.
     * @param maxLockPeriod The maximum amount of time the original asset owner can wait before getting the asset back.
     */
    event ListingCreated(
        uint256 indexed listingId,
        address indexed lister,
        Assets.Asset[] assets,
        Listings.Params params,
        uint32 maxLockPeriod
    );

    /**
     * @dev Emitted when the listing is no longer available for renting.
     * @param listingId Listing ID.
     * @param lister Lister account address.
     * @param unlocksAt The earliest possible time when the asset can be returned to the owner.
     */
    event ListingDisabled(uint256 indexed listingId, address indexed lister, uint32 unlocksAt);

    /**
     * @dev Emitted when the asset is returned to the `lister`.
     * @param listingId Listing ID.
     * @param lister Lister account address.
     * @param assets Returned assets.
     */
    event ListingWithdrawal(uint256 indexed listingId, address indexed lister, Assets.Asset[] assets);

    /**
     * @dev Emitted when the listing is paused.
     * @param listingId Listing ID.
     */
    event ListingPaused(uint256 indexed listingId);

    /**
     * @dev Emitted when the listing pause is lifted.
     * @param listingId Listing ID.
     */
    event ListingUnpaused(uint256 indexed listingId);

    /**
     * @dev Creates new listing.
     * Emits an {ListingCreated} event.
     * @param assets Assets to be listed.
     * @param params Listing params.
     * @param maxLockPeriod The maximum amount of time the original asset owner can wait before getting the asset back.
     * @param immediatePayout Indicates whether the rental fee must be transferred to the lister on every renting.
     * If FALSE, the rental fees get accumulated until withdrawn manually.
     * @return listingId New listing ID.
     */
    function createListing(
        Assets.Asset[] calldata assets,
        Listings.Params calldata params,
        uint32 maxLockPeriod,
        bool immediatePayout
    ) external returns (uint256 listingId);

    /**
     * @dev Updates listing lock time for Listing.
     * @param listingId Listing ID.
     * @param unlockTimestamp Timestamp when asset would be unlocked.
     */
    function addLock(uint256 listingId, uint32 unlockTimestamp) external;

    /**
     * @dev Marks the assets as being delisted. This operation in irreversible.
     * After delisting, the asset can only be withdrawn when it has no active rentals.
     * Emits an {AssetDelisted} event.
     * @param listingId Listing ID.
     */
    function disableListing(uint256 listingId) external;

    /**
     * @dev Returns the asset back to the lister.
     * Emits an {AssetWithdrawn} event.
     * @param listingId Listing ID.
     */
    function withdrawListingAssets(uint256 listingId) external;

    /**
     * @dev Puts the listing on pause.
     * Emits a {ListingPaused} event.
     * @param listingId Listing ID.
     */
    function pauseListing(uint256 listingId) external;

    /**
     * @dev Lifts the listing pause.
     * Emits a {ListingUnpaused} event.
     * @param listingId Listing ID.
     */
    function unpauseListing(uint256 listingId) external;

    /**
     * @dev Returns the Listing details by the `listingId`.
     * Performs a look up among both
     * present (contains listed and delisted, but not yet withdrawn Listings)
     * and historical ones (withdrawn Listings only).
     * @param listingId Listing ID.
     * @return Listing details.
     */
    function listingInfo(uint256 listingId) external view returns (Listings.Listing memory);

    /**
     * @dev Reverts if Listing is
     * neither registered among present ones nor listed.
     * @param listingId Listing ID.
     */
    function checkRegisteredAndListed(uint256 listingId) external view;

    /**
     * @dev Reverts if the provided `account` does not own LISTING_WIZARD role.
     * @param account The account to check ownership for.
     */
    function checkIsListingWizard(address account) external view;

    /**
     * @dev Returns the number of currently registered listings.
     * @return Listing count.
     */
    function listingCount() external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered listings.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Listing IDs.
     * @return Listings.
     */
    function listings(uint256 offset, uint256 limit)
        external
        view
        returns (uint256[] memory, Listings.Listing[] memory);

    /**
     * @dev Returns the number of currently registered listings for the particular lister account.
     * @param lister Lister address.
     * @return Listing count.
     */
    function userListingCount(address lister) external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered listings for the particular lister account.
     * @param lister Lister address.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Listing IDs.
     * @return Listings.
     */
    function userListings(
        address lister,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listings.Listing[] memory);

    /**
     * @dev Returns the number of currently registered listings for the particular original asset address.
     * @param original Original asset address.
     * @return Listing count.
     */
    function assetListingCount(address original) external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered listings for the particular original asset address.
     * @param original Original asset address.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Listing IDs.
     * @return Listings.
     */
    function assetListings(
        address original,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listings.Listing[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";
import "../Rentings.sol";

interface IRentingManager is IContractEntity {
    /**
     * @dev Thrown when the message sender doesn't match the renter address.
     */
    error CallerIsNotRenter();

    /**
     * @dev Thrown when the Rental Agreement with `rentalId`
     * is not registered among present or historical Rental Agreements,
     * meaning it has never existed.
     * @param rentalId The ID of Rental Agreement that never existed.
     */
    error RentalAgreementNeverExisted(uint256 rentalId);

    /**
     * @dev Emitted when the warped asset(s) are rented.
     * @param rentalId Rental agreement ID.
     * @param renter The renter account address.
     * @param listingId The corresponding ID of the original asset(s) listing.
     * @param warpedAssets Rented warped asset(s).
     * @param startTime The rental agreement staring time.
     * @param endTime The rental agreement ending time.
     */
    event AssetRented(
        uint256 indexed rentalId,
        address indexed renter,
        uint256 indexed listingId,
        Assets.Asset[] warpedAssets,
        uint32 startTime,
        uint32 endTime
    );

    /**
     * @dev Returns token amount from specific collection rented by particular account.
     * @param warpedCollectionId Warped collection ID.
     * @param renter The renter account address.
     * @return Rented value.
     */
    function collectionRentedValue(bytes32 warpedCollectionId, address renter) external view returns (uint256);

    /**
     * @dev Returns the rental status of a given warped asset.
     * @param warpedAssetId Warped asset ID.
     * @return The asset rental status.
     */
    function assetRentalStatus(Assets.AssetId calldata warpedAssetId) external view returns (Rentings.RentalStatus);

    /**
     * @dev Evaluates renting params and returns rental fee breakdown.
     * @param rentingParams Renting parameters.
     * @return Rental fee breakdown.
     */
    function estimateRent(Rentings.Params calldata rentingParams) external view returns (Rentings.RentalFees memory);

    /**
     * @dev Performs renting operation.
     * @param rentingParams Renting parameters.
     * @param maxPaymentAmount Maximal payment amount the renter is willing to pay.
     * @return New rental ID.
     */
    function rent(
        Rentings.Params calldata rentingParams,
        bytes memory tokenQuote,
        bytes memory tokenQuoteSignature,
        uint256 maxPaymentAmount
    ) external returns (uint256);

    /**
     * @dev Returns the Rental Agreement details by the `rentalId`.
     * Performs a look up among both
     * present (contains active and inactive, but not yet deleted Rental Agreements)
     * and historical ones (inactive and deleted Rental Agreements only).
     * @param rentalId Rental agreement ID.
     * @return Rental agreement details.
     */
    function rentalAgreementInfo(uint256 rentalId) external view returns (Rentings.Agreement memory);

    /**
     * @dev Returns the number of currently registered rental agreements for particular renter account.
     * @param renter Renter address.
     * @return Rental agreement count.
     */
    function userRentalCount(address renter) external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered rental agreements for particular renter account.
     * @param renter Renter address.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Rental agreement IDs.
     * @return Rental agreements.
     */
    function userRentalAgreements(
        address renter,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Rentings.Agreement[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../asset/Assets.sol";
import "./listing-terms-registry/IListingTermsRegistry.sol";

library Listings {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using Listings for Registry;
    using Listings for Listing;
    using Assets for Assets.Asset;

    /**
     * @dev Thrown when the Listing with `listingId`
     * is neither registered among present ones nor listed (disabled).
     */
    error ListingIsNeitherRegisteredNorListed(uint256 listingId);

    /**
     * @dev Thrown when the Listing with `listingId` is not registered among present ones.
     */
    error ListingIsNotRegistered(uint256 listingId);

    /**
     * @dev Thrown when the operation is not allowed due to the listing being paused.
     */
    error ListingIsPaused();

    /**
     * @dev Thrown when the operation is not allowed due to the listing not being paused.
     */
    error ListingIsNotPaused();

    /**
     * @dev Thrown when attempting to lock listed assets for the period longer than the lister allowed.
     */
    error InvalidLockPeriod(uint32 period);

    /**
     * @dev Listing params.
     * The layout of `config.data` might vary for different listing strategies.
     * For example, in case of FIXED_RATE strategy, the `config.data` might contain only base rate,
     * and for more advanced auction strategies it might include period, min bid step etc.
     * @param lister Listing creator.
     * @param configurator Optional listing configurator address which may customize renting conditions.
     */
    struct Params {
        address lister;
        address configurator;
    }

    /**
     * @dev Listing structure.
     * @param assets Listed assets structure.
     * @param lister Lister account address.
     * @param beneficiary The target to receive payments or other various rewards from rentals.
     * @param maxLockPeriod The maximum amount of time the assets owner can wait before getting the assets back.
     * @param lockedTill The earliest possible time when the assets can be returned to the owner.
     * @param configurator Optional listing configurator address which may customize renting conditions
     * @param immediatePayout Indicates whether the rental fee must be transferred to the lister on every renting.
     * If FALSE, the rental fees get accumulated until withdrawn manually.
     * @param enabled Indicates whether listing is enabled.
     * @param paused Indicates whether the listing is paused.
     */
    struct Listing {
        Assets.Asset[] assets;
        address lister;
        address beneficiary;
        uint32 maxLockPeriod;
        uint32 lockedTill;
        address configurator;
        bool immediatePayout;
        bool enabled;
        bool paused;
    }

    /**
     * @dev Listing related data associated with the specific account.
     * @param listingIndex The set of listing IDs.
     */
    struct ListerInfo {
        EnumerableSetUpgradeable.UintSet listingIndex;
    }

    /**
     * @dev Listing related data associated with the specific account.
     * @param listingIndex The set of listing IDs.
     */
    struct AssetInfo {
        EnumerableSetUpgradeable.UintSet listingIndex;
    }

    /**
     * @dev Listing registry.
     * @param idTracker Listing ID tracker (incremental counter).
     * @param listingIndex The global set of registered listing IDs.
     * @param listings Mapping from listing ID to the listing info.
     * @param listers Mapping from lister address to the lister info.
     * @param assetCollections Mapping from an Asset Collection's address to the asset info.
     */
    struct Registry {
        CountersUpgradeable.Counter listingIdTracker;
        EnumerableSetUpgradeable.UintSet listingIndex;
        mapping(uint256 => Listing) listings;
        mapping(uint256 => Listing) listingsHistory;
        mapping(address => ListerInfo) listers;
        mapping(address => AssetInfo) assetCollections;
    }

    /**
     * @dev Puts the listing on pause.
     */
    function pause(Listing storage self) internal {
        if (self.paused) revert ListingIsPaused();

        self.paused = true;
    }

    /**
     * @dev Lifts the listing pause.
     */
    function unpause(Listing storage self) internal {
        if (!self.paused) revert ListingIsNotPaused();

        self.paused = false;
    }

    /**
     * Determines whether the listing is registered and active.
     */
    function isRegisteredAndListed(Listing storage self) internal view returns (bool) {
        return self.isRegistered() && self.enabled;
    }

    function isRegistered(Listing storage self) internal view returns (bool) {
        return self.lister != address(0);
    }

    /**
     * @dev Reverts if the listing is paused.
     */
    function checkNotPaused(Listing memory self) internal pure {
        if (self.paused) revert ListingIsPaused();
    }

    /*
     * @dev Validates lock period.
     */
    function isValidLockPeriod(Listing memory self, uint32 lockPeriod) internal pure returns (bool) {
        return (lockPeriod > 0 && lockPeriod <= self.maxLockPeriod);
    }

    /**
     * Determines whether the caller address is assets lister.
     */
    function isAssetLister(
        Registry storage self,
        uint256 listingId,
        address caller
    ) internal view returns (bool) {
        return self.listings[listingId].lister == caller;
    }

    /**
     * @dev Reverts if the lock period is not valid.
     */
    function checkValidLockPeriod(Listing memory self, uint32 lockPeriod) internal pure {
        if (!self.isValidLockPeriod(lockPeriod)) revert InvalidLockPeriod(lockPeriod);
    }

    /**
     * @dev Extends listing lock time.
     * Does not modify the state if current lock time is larger.
     */
    function addLock(Listing storage self, uint32 unlockTimestamp) internal {
        // Listing is already locked till later time, no need to extend locking period.
        if (self.lockedTill >= unlockTimestamp) return;
        // Extend listing lock.
        self.lockedTill = unlockTimestamp;
    }

    /**
     * @dev Registers new listing.
     * @return listingId New listing ID.
     */
    function register(Registry storage self, Listing memory listing) external returns (uint256 listingId) {
        // Generate new listing ID.
        self.listingIdTracker.increment();
        listingId = self.listingIdTracker.current();

        // Add new listing ID to the global index.
        self.listingIndex.add(listingId);
        // Add user listing data.
        self.listers[listing.lister].listingIndex.add(listingId);

        // Creating an instance of listing record
        Listing storage listingRecord = self.listings[listingId];

        // Store new listing record.
        listingRecord.lister = listing.lister;
        listingRecord.beneficiary = listing.beneficiary;
        listingRecord.maxLockPeriod = listing.maxLockPeriod;
        listingRecord.lockedTill = listing.lockedTill;
        listingRecord.immediatePayout = listing.immediatePayout;
        listingRecord.enabled = listing.enabled;
        listingRecord.paused = listing.paused;
        listingRecord.configurator = listing.configurator;

        // Extract collection address. All Original Assets are from the same Original Asset Collection.
        address originalCollectionAddress = listing.assets[0].token();
        self.assetCollections[originalCollectionAddress].listingIndex.add(listingId);

        // Add assets to listing record and listing data.
        for (uint256 i = 0; i < listing.assets.length; i++) {
            listingRecord.assets.push(listing.assets[i]);
        }
    }

    /**
     * @dev Removes listing data.
     * @param listingId The ID of the listing to be deleted.
     */
    function remove(Registry storage self, uint256 listingId) external {
        // Creating an instance of listing record
        Listing storage listingRecord = self.listings[listingId];

        // Remove the listing ID from the global index.
        self.listingIndex.remove(listingId);
        // Remove user listing data.
        self.listers[listingRecord.lister].listingIndex.remove(listingId);

        // All Original Assets are from the same Original Assets Collection.
        address originalCollectionAddress = listingRecord.assets[0].token();
        self.assetCollections[originalCollectionAddress].listingIndex.remove(listingId);

        listingRecord.enabled = false;
        self.listingsHistory[listingId] = listingRecord;

        // Delete Listing.
        delete self.listings[listingId];
    }

    /**
     * @dev Returns the paginated list of currently registered listings.
     */
    function allListings(
        Registry storage self,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listing[] memory) {
        return self.paginateIndexedListings(self.listingIndex, offset, limit);
    }

    /**
     * @dev Returns the paginated list of currently registered listings for the particular lister account.
     */
    function userListings(
        Registry storage self,
        address lister,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listing[] memory) {
        return self.paginateIndexedListings(self.listers[lister].listingIndex, offset, limit);
    }

    /**
     * @dev Returns the paginated list of currently registered listings for the original asset.
     */
    function assetListings(
        Registry storage self,
        address original,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listing[] memory) {
        return self.paginateIndexedListings(self.assetCollections[original].listingIndex, offset, limit);
    }

    /**
     * @dev Reverts if Listing is
     * neither registered among present Listings nor enabled.
     * @param listingId Listing ID.
     */
    function checkRegisteredAndListed(Registry storage self, uint256 listingId) internal view {
        if (!self.listings[listingId].isRegisteredAndListed()) revert ListingIsNeitherRegisteredNorListed(listingId);
    }

    function checkRegistered(Registry storage self, uint256 listingId) internal view {
        if (!self.listings[listingId].isRegistered()) revert ListingIsNotRegistered(listingId);
    }

    /**
     * @dev Returns the number of currently registered listings.
     */
    function listingCount(Registry storage self) internal view returns (uint256) {
        return self.listingIndex.length();
    }

    /**
     * @dev Returns the number of currently registered listings for a particular lister account.
     */
    function userListingCount(Registry storage self, address lister) internal view returns (uint256) {
        return self.listers[lister].listingIndex.length();
    }

    /**
     * @dev Returns the number of currently registered listings for a particular original asset.
     */
    function assetListingCount(Registry storage self, address original) internal view returns (uint256) {
        return self.assetCollections[original].listingIndex.length();
    }

    /**
     * @dev Returns the paginated list of currently registered listing using provided index reference.
     */
    function paginateIndexedListings(
        Registry storage self,
        EnumerableSetUpgradeable.UintSet storage listingIndex,
        uint256 offset,
        uint256 limit
    ) internal view returns (uint256[] memory, Listing[] memory) {
        uint256 indexSize = listingIndex.length();
        if (offset >= indexSize) return (new uint256[](0), new Listing[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        Listing[] memory listings = new Listing[](limit);
        uint256[] memory listingIds = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            listingIds[i] = listingIndex.at(offset + i);
            listings[i] = self.listings[listingIds[i]];
        }

        return (listingIds, listings);
    }

    /**
     * @dev Returns the hash of listing terms strategy ID and data.
     * @param listingTerms Listing Terms.
     */
    function hash(IListingTermsRegistry.ListingTerms memory listingTerms) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(listingTerms.strategyId, listingTerms.strategyData));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../asset/Assets.sol";
import "../metahub/Protocol.sol";
import "../listing/Listings.sol";
import "../warper/warper-manager/Warpers.sol";
import "../tax/tax-terms-registry/ITaxTermsRegistry.sol";
import "../accounting/token-quote/ITokenQuote.sol";
import "../listing/listing-manager/IListingManager.sol";
import "../metahub/core/IMetahub.sol";
import "../universe/universe-registry/IUniverseRegistry.sol";
import "../listing/listing-configurator/registry/IListingConfiguratorRegistry.sol";
import "../listing/listing-strategy-registry/IListingStrategyRegistry.sol";
import "../listing/listing-strategies/IListingController.sol";

library Rentings {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using Rentings for RenterInfo;
    using Rentings for Agreement;
    using Rentings for Registry;
    using Assets for Assets.AssetId;
    using Protocol for Protocol.Config;
    using Listings for Listings.Registry;
    using Listings for Listings.Listing;
    using Warpers for Warpers.Registry;
    using Warpers for Warpers.Warper;

    /**
     * @dev Thrown when a rental agreement is being registered for a specific warper ID,
     * while the previous rental agreement for this warper is still effective.
     */
    error RentalAgreementConflict(uint256 conflictingRentalId);

    /**
     * @dev Thrown when attempting to delete effective rental agreement data (before expiration).
     */
    error CannotDeleteEffectiveRentalAgreement(uint256 rentalId);

    /**
     * @dev Thrown when attempting to rent for Zero address.
     */
    error RenterCannotBeZeroAddress();

    /**
     * @dev Warper rental status.
     * NONE - means the warper had never been minted.
     * AVAILABLE - can be rented.
     * RENTED - currently rented.
     */
    enum RentalStatus {
        NONE,
        AVAILABLE,
        RENTED
    }

    /**
     * @dev Defines the maximal allowed number of cycles when looking for expired rental agreements.
     */
    uint256 private constant _GC_CYCLES = 20;

    /**
     * @dev Rental fee breakdown.
     */
    struct RentalFees {
        uint256 total;
        uint256 protocolFee;
        uint256 listerBaseFee;
        uint256 listerPremium;
        uint256 universeBaseFee;
        uint256 universePremium;
        IListingTermsRegistry.ListingTerms listingTerms;
        ITaxTermsRegistry.TaxTerms universeTaxTerms;
        ITaxTermsRegistry.TaxTerms protocolTaxTerms;
    }

    /**
     * @dev Renting parameters structure.
     * It is used to encode all the necessary information to estimate and/or fulfill a particular renting request.
     * @param listingId Listing ID. Also allows to identify the asset(s) being rented.
     * @param warper Warper address.
     * @param renter Renter address.
     * @param rentalPeriod Desired period of asset(s) renting.
     * @param paymentToken The token address which renter offers as a mean of payment.
     * @param listingTermsId Listing terms ID.
     * @param selectedConfiguratorListingTerms
     */
    struct Params {
        uint256 listingId;
        address warper;
        address renter;
        uint32 rentalPeriod;
        address paymentToken;
        uint256 listingTermsId;
        IListingTermsRegistry.ListingTerms selectedConfiguratorListingTerms;
    }

    /**
     * @dev Rental agreement information.
     * @param warpedAssets Rented asset(s).
     * @param universeId The Universe ID.
     * @param collectionId Warped collection ID.
     * @param listingId The corresponding ID of the original asset(s) listing.
     * @param renter The renter account address.
     * @param startTime The rental agreement staring time. This is the timestamp after which the `renter`
     * considered to be an warped asset(s) owner.
     * @param endTime The rental agreement ending time. After this timestamp, the rental agreement is terminated
     * and the `renter` is no longer the owner of the warped asset(s).
     * @param listingTerms Listing terms
     */
    struct Agreement {
        Assets.Asset[] warpedAssets;
        uint256 universeId;
        bytes32 collectionId;
        uint256 listingId;
        address renter;
        uint32 startTime;
        uint32 endTime;
        AgreementTerms agreementTerms;
    }

    struct AgreementTerms {
        IListingTermsRegistry.ListingTerms listingTerms;
        ITaxTermsRegistry.TaxTerms universeTaxTerms;
        ITaxTermsRegistry.TaxTerms protocolTaxTerms;
        ITokenQuote.PaymentTokenData paymentTokenData;
    }

    function isEffective(Agreement storage self) internal view returns (bool) {
        return self.endTime > uint32(block.timestamp);
    }

    function isRegistered(Agreement memory self) internal pure returns (bool) {
        return self.renter != address(0);
    }

    /**
     * @dev Describes user specific renting information.
     * @param rentalIndex Renter's set of rental agreement IDs.
     * @param collectionRentalIndex Mapping from collection ID to the set of rental IDs.
     */
    struct RenterInfo {
        EnumerableSetUpgradeable.UintSet rentalIndex;
        mapping(bytes32 => EnumerableSetUpgradeable.UintSet) collectionRentalIndex;
    }

    /**
     * @dev Describes asset(s) specific renting information.
     * @param latestRentalId Holds the most recent rental agreement ID.
     */
    struct AssetInfo {
        uint256 latestRentalId; // NOTE: This must never be deleted during cleanup.
    }

    /**
     * @dev Renting registry.
     * @param idTracker Rental agreement ID tracker (incremental counter).
     * @param agreements Mapping from rental ID to the rental agreement details.
     * @param renters Mapping from renter address to the user specific renting info.
     * @param assets Mapping from asset ID (byte32) to the asset specific renting info.
     */
    struct Registry {
        CountersUpgradeable.Counter idTracker;
        mapping(uint256 => Agreement) agreements;
        mapping(uint256 => Agreement) agreementsHistory;
        mapping(address => RenterInfo) renters;
        mapping(bytes32 => AssetInfo) assets;
    }

    /**
     * @dev Returns the number of currently registered rental agreements for particular renter account.
     */
    function userRentalCount(Registry storage self, address renter) internal view returns (uint256) {
        return self.renters[renter].rentalIndex.length();
    }

    /**
     * @dev Returns the paginated list of currently registered rental agreements for particular renter account.
     */
    function userRentalAgreements(
        Registry storage self,
        address renter,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Rentings.Agreement[] memory) {
        EnumerableSetUpgradeable.UintSet storage userRentalIndex = self.renters[renter].rentalIndex;
        uint256 indexSize = userRentalIndex.length();
        if (offset >= indexSize) return (new uint256[](0), new Rentings.Agreement[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        Rentings.Agreement[] memory agreements = new Rentings.Agreement[](limit);
        uint256[] memory rentalIds = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            rentalIds[i] = userRentalIndex.at(offset + i);
            agreements[i] = self.agreements[rentalIds[i]];
        }

        return (rentalIds, agreements);
    }

    /**
     * @dev Finds expired user rental agreements associated with `collectionId` and deletes them.
     * Deletes only first N entries defined by `toBeRemoved` param.
     * The total number of cycles is capped by GC_CYCLES constant.
     */
    function deleteExpiredUserRentalAgreements(
        Registry storage self,
        address renter,
        bytes32 collectionId,
        uint256 toBeRemoved
    ) external {
        EnumerableSetUpgradeable.UintSet storage rentalIndex = self.renters[renter].collectionRentalIndex[collectionId];

        uint256 rentalCount = rentalIndex.length();
        if (rentalCount == 0 || toBeRemoved == 0) return;

        uint256 maxCycles = rentalCount < _GC_CYCLES ? rentalCount : _GC_CYCLES;
        uint256 removed = 0;

        for (uint256 i = 0; i < maxCycles; i++) {
            uint256 rentalId = rentalIndex.at(i);

            if (!self.agreements[rentalId].isEffective()) {
                // Warning: we are iterating an array that we are also modifying!
                _removeRentalAgreement(self, rentalId);
                removed += 1;
                maxCycles -= 1; // This is so we account for reduced `rentalCount`.

                // Stop iterating if we have cleaned up enough desired items.
                if (removed == toBeRemoved) break;
            }
        }
    }

    /**
     * @dev Performs new rental agreement registration.
     */
    function register(Registry storage self, Agreement memory agreement) external returns (uint256 rentalId) {
        // Generate new rental ID.
        self.idTracker.increment();
        rentalId = self.idTracker.current();

        // Save new rental agreement.
        Agreement storage agreementRecord = self.agreements[rentalId];
        agreementRecord.listingId = agreement.listingId;
        agreementRecord.renter = agreement.renter;
        agreementRecord.startTime = agreement.startTime;
        agreementRecord.endTime = agreement.endTime;
        agreementRecord.collectionId = agreement.collectionId;
        agreementRecord.agreementTerms.listingTerms = agreement.agreementTerms.listingTerms;
        agreementRecord.agreementTerms.universeTaxTerms = agreement.agreementTerms.universeTaxTerms;
        agreementRecord.agreementTerms.protocolTaxTerms = agreement.agreementTerms.protocolTaxTerms;

        for (uint256 i = 0; i < agreement.warpedAssets.length; i++) {
            bytes32 assetId = agreement.warpedAssets[i].id.hash();
            uint256 latestRentalId = self.assets[assetId].latestRentalId;

            if (latestRentalId != 0 && self.agreements[latestRentalId].isEffective()) {
                revert RentalAgreementConflict(latestRentalId);
            } else {
                // Add warped assets and their collection ids to rental agreement.
                agreementRecord.warpedAssets.push(agreement.warpedAssets[i]);

                // Update warper latest rental ID.
                self.assets[assetId].latestRentalId = rentalId;
            }
        }

        RenterInfo storage renterInfo = self.renters[agreement.renter];
        // Update user rental index.
        renterInfo.rentalIndex.add(rentalId);
        // Update user collection rental index.
        renterInfo.collectionRentalIndex[agreement.collectionId].add(rentalId);
    }

    /**
     * @dev Updates Agreement Record structure in storage and in memory.
     */
    function updateAgreementConfig(
        Registry storage self,
        Rentings.Agreement memory inMemoryRentalAgreement,
        uint256 rentalId,
        Rentings.RentalFees memory rentalFees,
        Warpers.Warper memory warper,
        ITokenQuote.PaymentTokenData memory paymentTokenData
    ) external returns (Rentings.Agreement memory) {
        inMemoryRentalAgreement.universeId = warper.universeId;
        inMemoryRentalAgreement.agreementTerms.listingTerms = rentalFees.listingTerms;
        inMemoryRentalAgreement.agreementTerms.universeTaxTerms = rentalFees.universeTaxTerms;
        inMemoryRentalAgreement.agreementTerms.protocolTaxTerms = rentalFees.protocolTaxTerms;
        inMemoryRentalAgreement.agreementTerms.paymentTokenData = paymentTokenData;

        Agreement storage agreementRecord = self.agreements[rentalId];
        agreementRecord.universeId = inMemoryRentalAgreement.universeId;
        agreementRecord.agreementTerms.listingTerms = inMemoryRentalAgreement.agreementTerms.listingTerms;
        agreementRecord.agreementTerms.universeTaxTerms = inMemoryRentalAgreement.agreementTerms.universeTaxTerms;
        agreementRecord.agreementTerms.protocolTaxTerms = inMemoryRentalAgreement.agreementTerms.protocolTaxTerms;
        agreementRecord.agreementTerms.paymentTokenData = inMemoryRentalAgreement.agreementTerms.paymentTokenData;

        return inMemoryRentalAgreement;
    }

    /**
     * @dev Safely removes expired rental data from the registry.
     */
    function removeExpiredRentalAgreement(Registry storage self, uint256 rentalId) external {
        if (self.agreements[rentalId].isEffective()) revert CannotDeleteEffectiveRentalAgreement(rentalId);
        _removeRentalAgreement(self, rentalId);
    }

    /**
     * @dev Removes rental data from the registry.
     */
    function _removeRentalAgreement(Registry storage self, uint256 rentalId) private {
        Agreement storage rentalAgreement = self.agreements[rentalId];
        address renter = rentalAgreement.renter;

        bytes32 collectionId = self.agreements[rentalId].collectionId;
        self.renters[renter].rentalIndex.remove(rentalId);
        self.renters[renter].collectionRentalIndex[collectionId].remove(rentalId);

        self.agreementsHistory[rentalId] = rentalAgreement;
        // Delete rental agreement.
        delete self.agreements[rentalId];
    }

    /**
     * @dev Finds all effective rental agreements from specific collection.
     * Returns the total value rented by `renter`.
     */
    function collectionRentedValue(
        Registry storage self,
        address renter,
        bytes32 collectionId
    ) external view returns (uint256 value) {
        EnumerableSetUpgradeable.UintSet storage rentalIndex = self.renters[renter].collectionRentalIndex[collectionId];
        uint256 length = rentalIndex.length();
        for (uint256 i = 0; i < length; i++) {
            Agreement storage agreement = self.agreements[rentalIndex.at(i)];

            if (agreement.isEffective()) {
                for (uint256 j = 0; j < agreement.warpedAssets.length; j++) {
                    value += agreement.warpedAssets[j].value;
                }
            }
        }
    }

    /**
     * @dev Returns asset(s) rental status based on latest rental agreement.
     */
    function assetRentalStatus(Registry storage self, Assets.AssetId memory assetId)
        external
        view
        returns (RentalStatus)
    {
        uint256 latestRentalId = self.assets[assetId.hash()].latestRentalId;
        if (latestRentalId == 0) return RentalStatus.NONE;

        return self.agreements[latestRentalId].isEffective() ? RentalStatus.RENTED : RentalStatus.AVAILABLE;
    }

    /**
     * @dev Main renting request validation function.
     */
    function validateRentingParams(Params calldata params, IMetahub metahub) external view {
        // Validate from the renter's perspective.
        if (params.renter == address(0)) {
            revert RenterCannotBeZeroAddress();
        }
        // Validate from the listing perspective.
        IListingManager listingManager = IListingManager(metahub.getContract(Contracts.LISTING_MANAGER));
        listingManager.checkRegisteredAndListed(params.listingId);
        Listings.Listing memory listing = listingManager.listingInfo(params.listingId);
        listing.checkNotPaused();
        listing.checkValidLockPeriod(params.rentalPeriod);
        // Validate from the warper and strategy override config registry perspective.
        IWarperManager warperManager = IWarperManager(metahub.getContract(Contracts.WARPER_MANAGER));
        warperManager.checkRegisteredWarper(params.warper);
        Warpers.Warper memory warper = warperManager.warperInfo(params.warper);
        warper.checkNotPaused();
        warper.controller.validateRentingParams(warper, listing.assets, params);

        // Validate from the universe perspective
        IUniverseRegistry(metahub.getContract(Contracts.UNIVERSE_REGISTRY)).checkUniversePaymentToken(
            warper.universeId,
            params.paymentToken
        );

        IListingTermsRegistry.ListingTerms memory listingTerms;

        if (listing.configurator != address(0)) {
            IListingConfiguratorRegistry(metahub.getContract(Contracts.LISTING_CONFIGURATOR_REGISTRY))
                .getController(listing.configurator)
                .validateRenting(params, listing, warper.universeId);
            listingTerms = params.selectedConfiguratorListingTerms;
        } else {
            // Validate from the listing terms perspective
            IListingTermsRegistry.Params memory listingTermsParams = IListingTermsRegistry.Params({
                listingId: params.listingId,
                universeId: warper.universeId,
                warperAddress: params.warper
            });
            IListingTermsRegistry listingTermsRegistry = IListingTermsRegistry(
                metahub.getContract(Contracts.LISTING_TERMS_REGISTRY)
            );
            listingTermsRegistry.checkRegisteredListingTermsWithParams(params.listingTermsId, listingTermsParams);
            listingTerms = listingTermsRegistry.listingTerms(params.listingTermsId);
        }

        bytes4 taxStrategyId = IListingStrategyRegistry(metahub.getContract(Contracts.LISTING_STRATEGY_REGISTRY))
            .listingTaxId(listingTerms.strategyId);
        // Validate from the tax terms perspective
        ITaxTermsRegistry.Params memory taxTermsParams = ITaxTermsRegistry.Params({
            taxStrategyId: taxStrategyId,
            universeId: warper.universeId,
            warperAddress: params.warper
        });
        ITaxTermsRegistry taxTermsRegistry = ITaxTermsRegistry(metahub.getContract(Contracts.TAX_TERMS_REGISTRY));
        taxTermsRegistry.checkRegisteredUniverseTaxTermsWithParams(taxTermsParams);
        taxTermsRegistry.checkRegisteredProtocolTaxTermsWithParams(taxTermsParams);
    }

    /**
     * @dev Performs rental fee calculation and returns the fee breakdown.
     */
    function calculateRentalFees(
        Params calldata rentingParams,
        Warpers.Warper memory warper,
        IMetahub metahub
    ) external view returns (RentalFees memory fees) {
        // Resolve listing info
        Listings.Listing memory listing = IListingManager(metahub.getContract(Contracts.LISTING_MANAGER)).listingInfo(
            rentingParams.listingId
        );

        // Listing terms
        IListingTermsRegistry.Params memory listingTermsParams;

        if (listing.configurator != address(0)) {
            fees.listingTerms = rentingParams.selectedConfiguratorListingTerms;
        } else {
            // Compose ListingTerms Params for getting listing terms
            listingTermsParams = IListingTermsRegistry.Params({
                listingId: rentingParams.listingId,
                universeId: warper.universeId,
                warperAddress: rentingParams.warper
            });

            // Reading Listing Terms from Listing Terms Registry
            fees.listingTerms = IListingTermsRegistry(metahub.getContract(Contracts.LISTING_TERMS_REGISTRY))
                .listingTerms(rentingParams.listingTermsId);
        }
        // Resolve listing controller to calculate lister fee based on selected listing strategy.
        address listingControllerAddress = IListingStrategyRegistry(
            metahub.getContract(Contracts.LISTING_STRATEGY_REGISTRY)
        ).listingController(fees.listingTerms.strategyId);

        // Resolving all fees using single call to ListingController.calculateRentalFee(...)
        (
            fees.total,
            fees.listerBaseFee,
            fees.universeBaseFee,
            fees.protocolFee,
            fees.universeTaxTerms,
            fees.protocolTaxTerms
        ) = IListingController(listingControllerAddress).calculateRentalFee(
            listingTermsParams,
            fees.listingTerms,
            rentingParams
        );
        // Calculate warper premiums.
        (uint256 universePremium, uint256 listerPremium) = warper.controller.calculatePremiums(
            listing.assets,
            rentingParams,
            fees.universeBaseFee,
            fees.listerBaseFee
        );
        // Setting premiums.
        fees.listerPremium = listerPremium;
        fees.universePremium = universePremium;
        // Adding premiums to fees.total.
        fees.total += fees.listerPremium;
        fees.total += fees.universePremium;
    }
}

// solhint-disable private-vars-leading-underscore
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "../renting/Rentings.sol";
import "../universe/universe-registry/IUniverseRegistry.sol";
import "../listing/Listings.sol";
import "../contract-registry/Contracts.sol";
import "./IPaymentManager.sol";
import "../listing/listing-strategies/ListingStrategies.sol";
import "../listing/listing-strategies/fixed-rate-with-reward/IFixedRateWithRewardListingController.sol";
import "../tax/tax-strategies/fixed-rate-with-reward/IFixedRateWithRewardTaxController.sol";

library Accounts {
    using Accounts for Account;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    /**
     * @dev Thrown when the estimated rental fee calculated upon renting
     * is higher than maximal payment amount the renter is willing to pay.
     */
    error RentalFeeSlippage();

    /**
     * @dev Thrown when the amount requested to be paid out is not valid.
     */
    error InvalidWithdrawalAmount(uint256 amount);

    /**
     * @dev Thrown when the amount requested to be paid out is larger than available balance.
     */
    error InsufficientBalance(uint256 balance);

    /**
     * @dev A structure that describes account balance in ERC20 tokens.
     */
    struct Balance {
        address token;
        uint256 amount;
    }

    /**
     * @dev Describes an account state.
     * @param tokenBalances Mapping from an ERC20 token address to the amount.
     */
    struct Account {
        EnumerableMapUpgradeable.AddressToUintMap tokenBalances;
    }

    /**
     * @dev Transfers funds from the account balance to the specific address after validating balance sufficiency.
     */
    function withdraw(
        Account storage self,
        address token,
        uint256 amount,
        address to
    ) external {
        if (amount == 0) revert InvalidWithdrawalAmount(amount);
        uint256 currentBalance = self.balance(token);
        if (amount > currentBalance) revert InsufficientBalance(currentBalance);
        unchecked {
            self.tokenBalances.set(token, currentBalance - amount);
        }
        IERC20Upgradeable(token).safeTransfer(to, amount);
    }

    struct UserEarning {
        IPaymentManager.EarningType earningType;
        bool isLister;
        address account;
        uint256 value;
        address token;
    }

    struct UniverseEarning {
        IPaymentManager.EarningType earningType;
        uint256 universeId;
        uint256 value;
        address token;
    }

    struct ProtocolEarning {
        IPaymentManager.EarningType earningType;
        uint256 value;
        address token;
    }

    struct RentalEarnings {
        UserEarning[] userEarnings;
        UniverseEarning universeEarning;
        ProtocolEarning protocolEarning;
    }

    /**
     * @dev Redirects handle rental payment from RentingManager to Accounts.Registry
     * @param self Instance of Accounts.Registry.
     * @param rentingParams Renting params.
     * @param fees Rental fees.
     * @param payer Address of the rent payer.
     * @param maxPaymentAmount Maximum payment amount.
     * @return earnings Payment token earnings.
     */
    function handleRentalPayment(
        Accounts.Registry storage self,
        Rentings.Params calldata rentingParams,
        Rentings.RentalFees calldata fees,
        address payer,
        uint256 maxPaymentAmount
    ) external returns (RentalEarnings memory earnings) {
        IMetahub metahub = IMetahub(address(this));
        // Ensure no rental fee payment slippage.
        if (fees.total > maxPaymentAmount) revert RentalFeeSlippage();

        // Handle lister fee component.
        Listings.Listing memory listing = IListingManager(metahub.getContract(Contracts.LISTING_MANAGER)).listingInfo(
            rentingParams.listingId
        );

        // Initialize user earnings array. Here we have only one user, who is lister.
        earnings.userEarnings = new UserEarning[](1);

        earnings.userEarnings[0] = _createListerEarning(
            listing,
            IPaymentManager.EarningType.LISTER_FIXED_FEE,
            fees.listerBaseFee + fees.listerPremium,
            rentingParams.paymentToken
        );

        earnings.universeEarning = _createUniverseEarning(
            IPaymentManager.EarningType.UNIVERSE_FIXED_FEE,
            IWarperManager(metahub.getContract(Contracts.WARPER_MANAGER)).warperInfo(rentingParams.warper).universeId,
            fees.universeBaseFee + fees.universePremium,
            rentingParams.paymentToken
        );

        earnings.protocolEarning = _createProtocolEarning(
            IPaymentManager.EarningType.PROTOCOL_FIXED_FEE,
            fees.protocolFee,
            rentingParams.paymentToken
        );

        performPayouts(self, listing, earnings, payer, rentingParams.paymentToken);
    }

    function handleExternalERC20Reward(
        Accounts.Registry storage self,
        Listings.Listing memory listing,
        Rentings.Agreement memory agreement,
        ERC20RewardDistributionHelper.RentalExternalERC20RewardFees memory rentalExternalERC20RewardFees,
        address rewardSource
    ) external returns (RentalEarnings memory earnings) {
        // Initialize user earnings array. Here we have 2 users: lister and renter.
        earnings.userEarnings = new UserEarning[](2);

        earnings.userEarnings[0] = _createListerEarning(
            listing,
            IPaymentManager.EarningType.LISTER_EXTERNAL_ERC20_REWARD,
            rentalExternalERC20RewardFees.listerRewardFee,
            rentalExternalERC20RewardFees.token
        );

        earnings.userEarnings[1] = _createNonListerEarning(
            agreement.renter,
            IPaymentManager.EarningType.RENTER_EXTERNAL_ERC20_REWARD,
            rentalExternalERC20RewardFees.renterRewardFee,
            rentalExternalERC20RewardFees.token
        );

        earnings.universeEarning = _createUniverseEarning(
            IPaymentManager.EarningType.UNIVERSE_EXTERNAL_ERC20_REWARD,
            agreement.universeId,
            rentalExternalERC20RewardFees.universeRewardFee,
            rentalExternalERC20RewardFees.token
        );

        earnings.protocolEarning = _createProtocolEarning(
            IPaymentManager.EarningType.PROTOCOL_EXTERNAL_ERC20_REWARD,
            rentalExternalERC20RewardFees.protocolRewardFee,
            rentalExternalERC20RewardFees.token
        );

        performPayouts(self, listing, earnings, rewardSource, rentalExternalERC20RewardFees.token);
    }

    function performPayouts(
        Accounts.Registry storage self,
        Listings.Listing memory listing,
        RentalEarnings memory rentalEarnings,
        address payer,
        address payoutToken
    ) internal {
        // The amount of payment tokens to be accumulated on the Metahub for future payouts.
        // This will include all fees which are not being paid out immediately.
        uint256 accumulatedTokens = 0;

        // Increase universe balance.
        self.universes[rentalEarnings.universeEarning.universeId].increaseBalance(
            rentalEarnings.universeEarning.token,
            rentalEarnings.universeEarning.value
        );
        accumulatedTokens += rentalEarnings.universeEarning.value;

        // Increase protocol balance.
        self.protocol.increaseBalance(rentalEarnings.protocolEarning.token, rentalEarnings.protocolEarning.value);
        accumulatedTokens += rentalEarnings.protocolEarning.value;

        UserEarning[] memory userEarnings = rentalEarnings.userEarnings;

        for (uint256 i = 0; i < userEarnings.length; i++) {
            UserEarning memory userEarning = userEarnings[i];

            if (userEarning.value == 0) continue;

            if (userEarning.isLister && !listing.immediatePayout) {
                // If the lister has not requested immediate payout, the earned amount is added to the lister balance.
                // The direct payout case is handled along with other transfers later.
                self.users[userEarning.account].increaseBalance(userEarning.token, userEarning.value);
                accumulatedTokens += userEarning.value;
            } else {
                // Proceed with transfers.
                // If immediate payout requested, transfer the lister earnings directly to the user account.
                IERC20Upgradeable(userEarning.token).safeTransferFrom(payer, userEarning.account, userEarning.value);
            }
        }

        // Transfer the accumulated token amount from payer to the metahub.
        if (accumulatedTokens > 0) {
            IERC20Upgradeable(payoutToken).safeTransferFrom(payer, address(this), accumulatedTokens);
        }
    }

    function _createListerEarning(
        Listings.Listing memory listing,
        IPaymentManager.EarningType earningType,
        uint256 value,
        address token
    ) internal pure returns (UserEarning memory listerEarning) {
        listerEarning = UserEarning({
            earningType: earningType,
            isLister: true,
            account: listing.beneficiary,
            value: value,
            token: token
        });
    }

    function _createNonListerEarning(
        address user,
        IPaymentManager.EarningType earningType,
        uint256 value,
        address token
    ) internal pure returns (UserEarning memory nonListerEarning) {
        nonListerEarning = UserEarning({
            earningType: earningType,
            isLister: false,
            account: user,
            value: value,
            token: token
        });
    }

    function _createUniverseEarning(
        IPaymentManager.EarningType earningType,
        uint256 universeId,
        uint256 value,
        address token
    ) internal pure returns (UniverseEarning memory universeEarning) {
        universeEarning = UniverseEarning({
            earningType: earningType,
            universeId: universeId,
            value: value,
            token: token
        });
    }

    function _createProtocolEarning(
        IPaymentManager.EarningType earningType,
        uint256 value,
        address token
    ) internal pure returns (ProtocolEarning memory protocolEarning) {
        protocolEarning = ProtocolEarning({earningType: earningType, value: value, token: token});
    }

    /**
     * @dev Increments value of the particular account balance.
     */
    function increaseBalance(
        Account storage self,
        address token,
        uint256 amount
    ) internal {
        uint256 currentBalance = self.balance(token);
        self.tokenBalances.set(token, currentBalance + amount);
    }

    /**
     * @dev Returns account current balance.
     * Does not revert if `token` is not in the map.
     */
    function balance(Account storage self, address token) internal view returns (uint256) {
        (, uint256 value) = self.tokenBalances.tryGet(token);
        return value;
    }

    /**
     * @dev Returns the list of account balances in various tokens.
     */
    function balances(Account storage self) internal view returns (Balance[] memory) {
        uint256 length = self.tokenBalances.length();
        Balance[] memory allBalances = new Balance[](length);
        for (uint256 i = 0; i < length; i++) {
            (address token, uint256 amount) = self.tokenBalances.at(i);
            allBalances[i] = Balance({token: token, amount: amount});
        }
        return allBalances;
    }

    /**
     * @dev Account registry.
     * @param protocol The protocol account state.
     * @param universes Mapping from a universe ID to the universe account state.
     * @param users Mapping from a user address to the account state.
     */
    struct Registry {
        Account protocol;
        mapping(uint256 => Account) universes;
        mapping(address => Account) users;
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IAssetController.sol";
import "./IAssetVault.sol";
import "./asset-class-registry/IAssetClassRegistry.sol";

library Assets {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using Address for address;
    using Assets for Registry;
    using Assets for Asset;
    using Assets for AssetId;

    /*
     * @dev This is the list of asset class identifiers to be used across the system.
     */
    bytes4 public constant ERC721 = bytes4(keccak256("ERC721"));
    bytes4 public constant ERC1155 = bytes4(keccak256("ERC1155"));

    bytes32 public constant ASSET_ID_TYPEHASH = keccak256("AssetId(bytes4 class,bytes data)");

    bytes32 public constant ASSET_TYPEHASH =
        keccak256("Asset(AssetId id,uint256 value)AssetId(bytes4 class,bytes data)");

    /**
     * @dev Thrown upon attempting to register an asset twice.
     * @param asset Duplicate asset address.
     */
    error AssetIsAlreadyRegistered(address asset);

    /**
     * @dev Thrown when target for operation asset is not registered
     * @param asset Asset address, which is not registered.
     */
    error AssetIsNotRegistered(address asset);

    /**
     * @dev Communicates asset identification information.
     * The structure designed to be token-standard agnostic,
     * so the layout of `data` might vary for different token standards.
     * For example, in case of ERC721 token, the `data` will contain contract address and tokenId.
     * @param class Asset class ID
     * @param data Asset identification data.
     */
    struct AssetId {
        bytes4 class;
        bytes data;
    }

    /**
     * @dev Calculates Asset ID hash
     */
    function hash(AssetId memory assetId) internal pure returns (bytes32) {
        return keccak256(abi.encode(ASSET_ID_TYPEHASH, assetId.class, keccak256(assetId.data)));
    }

    /**
     * @dev Extracts token contract address from the Asset ID structure.
     * The address is the common attribute for all assets regardless of their asset class.
     */
    function token(AssetId memory self) internal pure returns (address) {
        return abi.decode(self.data, (address));
    }

    function hash(Assets.AssetId[] memory assetIds) internal pure returns (bytes32) {
        return keccak256(abi.encode(assetIds));
    }

    /**
     * @dev Uniformed structure to describe arbitrary asset (token) and its value.
     * @param id Asset ID structure.
     * @param value Asset value (amount).
     */
    struct Asset {
        AssetId id;
        uint256 value;
    }

    /**
     * @dev Calculates Asset hash
     */
    function hash(Asset memory asset) internal pure returns (bytes32) {
        return keccak256(abi.encode(ASSET_TYPEHASH, hash(asset.id), asset.value));
    }

    /**
     * @dev Extracts token contract address from the Asset structure.
     * The address is the common attribute for all assets regardless of their asset class.
     */
    function token(Asset memory self) internal pure returns (address) {
        return abi.decode(self.id.data, (address));
    }

    function toIds(Assets.Asset[] memory assets) internal pure returns (Assets.AssetId[] memory result) {
        result = new Assets.AssetId[](assets.length);
        for (uint256 i = 0; i < assets.length; i++) {
            result[i] = assets[i].id;
        }
    }

    function hashIds(Assets.Asset[] memory assets) internal pure returns (bytes32) {
        return hash(toIds(assets));
    }

    /**
     * @dev Original asset data.
     * @param controller Asset controller.
     * @param assetClass The asset class identifier.
     * @param vault Asset vault.
     */
    struct AssetConfig {
        IAssetController controller;
        bytes4 assetClass;
        IAssetVault vault;
    }

    /**
     * @dev Asset registry.
     * @param classRegistry Asset class registry contract.
     * @param assetIndex Set of registered asset addresses.
     * @param assets Mapping from asset address to the asset configuration.
     */
    struct Registry {
        IAssetClassRegistry classRegistry;
        EnumerableSetUpgradeable.AddressSet assetIndex;
        mapping(address => AssetConfig) assets;
    }

    /**
     * @dev Registers new asset.
     */
    function registerAsset(
        Registry storage self,
        bytes4 assetClass,
        address asset
    ) external {
        if (self.assetIndex.add(asset)) {
            IAssetClassRegistry.ClassConfig memory assetClassConfig = self.classRegistry.assetClassConfig(assetClass);
            self.assets[asset] = AssetConfig({
                controller: IAssetController(assetClassConfig.controller),
                assetClass: assetClass,
                vault: IAssetVault(assetClassConfig.vault)
            });
        }
    }

    /**
     * @dev Returns the paginated list of currently registered asset configs.
     */
    function supportedAssets(
        Registry storage self,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, AssetConfig[] memory) {
        uint256 indexSize = self.assetIndex.length();
        if (offset >= indexSize) return (new address[](0), new AssetConfig[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        AssetConfig[] memory assetConfigs = new AssetConfig[](limit);
        address[] memory assetAddresses = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            assetAddresses[i] = self.assetIndex.at(offset + i);
            assetConfigs[i] = self.assets[assetAddresses[i]];
        }
        return (assetAddresses, assetConfigs);
    }

    /**
     * @dev Transfers an asset to the vault using associated controller.
     */
    function transferAssetToVault(
        Registry storage self,
        Assets.Asset memory asset,
        address from
    ) external {
        // Extract token address from asset struct and check whether the asset is supported.
        address assetToken = asset.token();

        if (!isRegisteredAsset(self, assetToken)) revert AssetIsNotRegistered(assetToken);

        // Transfer asset to the class asset specific vault.
        AssetConfig memory assetConfig = self.assets[assetToken];
        address assetController = address(assetConfig.controller);
        address assetVault = address(assetConfig.vault);

        assetController.functionDelegateCall(
            abi.encodeWithSelector(IAssetController.transferAssetToVault.selector, asset, from, assetVault)
        );
    }

    /**
     * @dev Transfers an asset from the vault using associated controller.
     */
    function returnAssetFromVault(Registry storage self, Assets.Asset calldata asset) external {
        address assetToken = asset.token();

        AssetConfig memory assetConfig = self.assets[assetToken];
        address assetController = address(assetConfig.controller);
        address assetVault = address(assetConfig.vault);

        assetController.functionDelegateCall(
            abi.encodeWithSelector(IAssetController.returnAssetFromVault.selector, asset, assetVault)
        );
    }

    function assetCount(Registry storage self) internal view returns (uint256) {
        return self.assetIndex.length();
    }

    /**
     * @dev Checks asset registration by address.
     */
    function isRegisteredAsset(Registry storage self, address asset) internal view returns (bool) {
        return self.assetIndex.contains(asset);
    }

    /**
     * @dev Returns controller for asset class.
     * @param assetClass Asset class ID.
     */
    function assetClassController(Registry storage self, bytes4 assetClass) internal view returns (address) {
        return self.classRegistry.assetClassConfig(assetClass).controller;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";

interface IListingTermsRegistry is IContractEntity {
    /**
     * @dev Thrown upon attempting to work with unregistered listing terms.
     */
    error UnregisteredListingTerms(uint256 listingTermsId);

    /**
     * @dev Thrown upon attempting to work with listing terms with params that have more specific terms on warper level.
     */
    error MoreSpecificListingTermsExistForWarper(uint256 listingTermsId, uint256 listingId, address warperAddress);

    /**
     * @dev Thrown upon attempting to work with listing terms with
     * params that have more specific terms on universe level.
     */
    error MoreSpecificListingTermsExistForUniverse(uint256 listingTermsId, uint256 listingId, uint256 universeId);

    /**
     * @dev Thrown upon attempting to work with listing without listing terms.
     */
    error WrongListingTermsIdForParams(
        uint256 listingTermsId,
        uint256 listingId,
        uint256 universeId,
        address warperAddress
    );

    /**
     * @dev Thrown upon attempting to work with listing without listing terms on global level.
     */
    error GlobalListingTermsMismatch(uint256 listingId, uint256 listingTermsId);

    /**
     * @dev Thrown upon attempting to work with listing without listing terms on universe level.
     */
    error UniverseListingTermsMismatch(uint256 listingId, uint256 universeId, uint256 listingTermsId);

    /**
     * @dev Thrown upon attempting to work with listing without listing terms on warper level.
     */
    error WarperListingTermsMismatch(uint256 listingId, address warperAddress, uint256 listingTermsId);

    /**
     * @dev Emitted when the new listing terms are registered.
     * @param listingTermsId Listing terms ID.
     * @param strategyId Listing strategy ID.
     * @param strategyData Listing strategy data.
     */
    event ListingTermsRegistered(uint256 indexed listingTermsId, bytes4 indexed strategyId, bytes strategyData);

    /**
     * @dev Emitted when existing global listing terms are registered.
     * @param listingId Listing group ID.
     * @param listingTermsId Listing terms ID.
     */
    event GlobalListingTermsRegistered(uint256 indexed listingId, uint256 indexed listingTermsId);

    /**
     * @dev Emitted when the global listing terms are removed.
     * @param listingId Listing group ID.
     * @param listingTermsId Listing terms ID.
     */
    event GlobalListingTermsRemoved(uint256 indexed listingId, uint256 indexed listingTermsId);

    /**
     * @dev Emitted when universe listing terms are registered.
     * @param listingId Listing group ID.
     * @param universeId Universe ID.
     * @param listingTermsId Listing terms ID.
     */
    event UniverseListingTermsRegistered(
        uint256 indexed listingId,
        uint256 indexed universeId,
        uint256 indexed listingTermsId
    );

    /**
     * @dev Emitted when universe listing terms are removed.
     * @param listingId Listing group ID.
     * @param universeId Universe ID.
     * @param listingTermsId Listing terms ID.
     */
    event UniverseListingTermsRemoved(
        uint256 indexed listingId,
        uint256 indexed universeId,
        uint256 indexed listingTermsId
    );

    /**
     * @dev Emitted when the warper listing terms are registered.
     * @param listingId Listing group ID.
     * @param warperAddress Address of the warper.
     * @param listingTermsId Listing terms ID.
     */
    event WarperListingTermsRegistered(
        uint256 indexed listingId,
        address indexed warperAddress,
        uint256 indexed listingTermsId
    );

    /**
     * @dev Emitted when warper level lister's listing terms are removed.
     * @param listingId Listing group ID.
     * @param warperAddress Address of the warper.
     * @param listingTermsId Listing terms ID.
     */
    event WarperListingTermsRemoved(
        uint256 indexed listingId,
        address indexed warperAddress,
        uint256 indexed listingTermsId
    );

    /**
     * @dev Listing terms information.
     * @param strategyId Listing strategy ID.
     * @param strategyData Listing strategy data.
     */
    struct ListingTerms {
        bytes4 strategyId;
        bytes strategyData;
    }

    /**
     * @dev Listing Terms parameters.
     * @param listingId Listing ID.
     * @param universeId Universe ID.
     * @param warperAddress Address of the warper.
     */
    struct Params {
        uint256 listingId;
        uint256 universeId;
        address warperAddress;
    }

    /**
     * @dev Registers global listing terms.
     * @param listingId Listing ID.
     * @param terms Listing terms data.
     * @return listingTermsId Listing terms ID.
     */
    function registerGlobalListingTerms(uint256 listingId, ListingTerms calldata terms)
        external
        returns (uint256 listingTermsId);

    /**
     * @dev Removes global listing terms.
     * @param listingId Listing ID.
     * @param listingTermsId Listing Terms ID.
     */
    function removeGlobalListingTerms(uint256 listingId, uint256 listingTermsId) external;

    /**
     * @dev Registers universe listing terms.
     * @param listingId Listing ID.
     * @param universeId Universe ID.
     * @param terms Listing terms data.
     * @return listingTermsId Listing terms ID.
     */
    function registerUniverseListingTerms(
        uint256 listingId,
        uint256 universeId,
        ListingTerms calldata terms
    ) external returns (uint256 listingTermsId);

    /**
     * @dev Removes universe listing terms.
     * @param listingId Listing ID.
     * @param universeId Universe ID.
     * @param listingTermsId Listing terms ID.
     */
    function removeUniverseListingTerms(
        uint256 listingId,
        uint256 universeId,
        uint256 listingTermsId
    ) external;

    /**
     * @dev Registers warper listing terms.
     * @param listingId Listing ID.
     * @param warperAddress The address of the warper.
     * @param terms Listing terms.
     * @return listingTermsId Listing terms ID.
     */
    function registerWarperListingTerms(
        uint256 listingId,
        address warperAddress,
        ListingTerms calldata terms
    ) external returns (uint256 listingTermsId);

    /**
     * @dev Removes warper listing terms.
     * @param listingId Listing ID.
     * @param warperAddress The address of the warper.
     * @param listingTermsId Listing terms ID
     */
    function removeWarperListingTerms(
        uint256 listingId,
        address warperAddress,
        uint256 listingTermsId
    ) external;

    /**
     * @dev Returns listing terms by ID.
     * @param listingTermsId Listing terms ID.
     * @return Listing terms.
     */
    function listingTerms(uint256 listingTermsId) external view returns (ListingTerms memory);

    /**
     * @dev Returns all listing terms for params.
     * @param params Listing terms specific params.
     * @param offset List offset value.
     * @param limit List limit value.
     * @return List of listing terms IDs.
     * @return List of listing terms.
     */
    function allListingTerms(
        Params calldata params,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, ListingTerms[] memory);

    /**
     * @dev Checks registration of listing terms.
     * @param listingTermsId Listing Terms ID.
     * @return Boolean that is positive in case of existance
     */
    function areRegisteredListingTerms(uint256 listingTermsId) external view returns (bool);

    /**
     * @dev Checks registration of listing terms.
     * @param listingTermsId Listing Terms ID.
     * @param params Listing terms specific params.
     * @return Boolean that is positive in case of existance
     */
    function areRegisteredListingTermsWithParams(uint256 listingTermsId, Params memory params)
        external
        view
        returns (bool);

    /**
     * @dev Checks registration of listing terms.
     *      Reverts with UnregisteredListingTerms() in case listing terms were not registered.
     * @param listingTermsId Listing Terms ID.
     */
    function checkRegisteredListingTerms(uint256 listingTermsId) external view;

    /**
     * @dev Checks registration of listing terms for lister on global, universe and warper levels.
     *      Reverts in case of absence of listing terms on all levels.
     * @param listingTermsId Listing Terms ID.
     * @param params Listing terms specific params.
     */
    function checkRegisteredListingTermsWithParams(uint256 listingTermsId, Params memory params) external view;
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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "./Assets.sol";

interface IAssetController is IERC165 {
    /**
     * @dev Thrown when the asset has invalid class for specific operation.
     * @param provided Provided class ID.
     * @param required Required class ID.
     */
    error AssetClassMismatch(bytes4 provided, bytes4 required);

    // @dev Thrown when asset token address order is violated
    error AssetCollectionMismatch(address expected, address actual);

    // @dev Thrown when asset token id order is violated
    error AssetOrderMismatch(address token, uint256 left, uint256 right);

    /**
     * @dev Emitted when asset is transferred.
     * @param asset Asset being transferred.
     * @param from Asset sender.
     * @param to Asset recipient.
     * @param data Auxiliary data.
     */
    event AssetTransfer(Assets.Asset asset, address indexed from, address indexed to, bytes data);

    /**
     * @dev Returns controller asset class.
     * @return Asset class ID.
     */
    function assetClass() external pure returns (bytes4);

    /**
     * @dev Transfers asset.
     * Emits a {AssetTransfer} event.
     * @param asset Asset being transferred.
     * @param from Asset sender.
     * @param to Asset recipient.
     * @param data Auxiliary data.
     */
    function transfer(
        Assets.Asset memory asset,
        address from,
        address to,
        bytes memory data
    ) external;

    /**
     * @dev Transfers asset from owner to the vault contract.
     * @param asset Asset being transferred.
     * @param assetOwner Original asset owner address.
     * @param vault Asset vault contract address.
     */
    function transferAssetToVault(
        Assets.Asset memory asset,
        address assetOwner,
        address vault
    ) external;

    /**
     * @dev Transfers asset from the vault contract to the original owner.
     * @param asset Asset being transferred.
     * @param vault Asset vault contract address.
     */
    function returnAssetFromVault(Assets.Asset calldata asset, address vault) external;

    /**
     * @dev Decodes asset ID structure and returns collection identifier.
     * The collection ID is bytes32 value which is calculated based on the asset class.
     * For example, ERC721 collection can be identified by address only,
     * but for ERC1155 it should be calculated based on address and token ID.
     * @return Collection ID.
     */
    function collectionId(Assets.AssetId memory assetId) external pure returns (bytes32);

    /**
     * @dev Ensures asset array is sorted in incremental order.
     *      This is required for batched listings to guarantee
     *      stable hashing
     */
    function ensureSorted(Assets.AssetId[] calldata assets) external pure;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAssetVault is IERC165 {
    /**
     * @dev Thrown when the asset is not is found among vault inventory.
     */
    error AssetNotFound();

    /**
     * @dev Thrown when the function is called on the vault in recovery mode.
     */
    error VaultIsInRecoveryMode();

    /**
     * @dev Thrown when the asset return is not allowed, due to the vault state or the caller permissions.
     */
    error AssetReturnIsNotAllowed();

    /**
     * @dev Thrown when the asset deposit is not allowed, due to the vault state or the caller permissions.
     */
    error AssetDepositIsNotAllowed();

    /**
     * @dev Emitted when the vault is switched to recovery mode by `account`.
     */
    event RecoveryModeActivated(address account);

    /**
     * @dev Activates asset recovery mode.
     * Emits a {RecoveryModeActivated} event.
     */
    function switchToRecoveryMode() external;

    /**
     * @notice Send ERC20 tokens to an address.
     */
    function withdrawERC20Tokens(
        IERC20 token,
        address to,
        uint256 amount
    ) external;

    /**
     * @dev Pauses the vault.
     */
    function pause() external;

    /**
     * @dev Unpauses the vault.
     */
    function unpause() external;

    /**
     * @dev Returns vault asset class.
     * @return Asset class ID.
     */
    function assetClass() external pure returns (bytes4);

    /**
     * @dev Returns the Metahub address.
     */
    function metahub() external view returns (address);

    /**
     * @dev Returns vault recovery mode flag state.
     * @return True when the vault is in recovery mode.
     */
    function isRecovery() external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";

interface IAssetClassRegistry is IContractEntity {
    /**
     * @dev Thrown when the asset class supported by contract does not match the required one.
     * @param provided Provided class ID.
     * @param required Required class ID.
     */
    error AssetClassMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Thrown upon attempting to register an asset class twice.
     * @param assetClass Duplicate asset class ID.
     */
    error AssetClassIsAlreadyRegistered(bytes4 assetClass);

    /**
     * @dev Thrown upon attempting to work with unregistered asset class.
     * @param assetClass Asset class ID.
     */
    error UnregisteredAssetClass(bytes4 assetClass);

    /**
     * @dev Thrown when the asset controller contract does not implement the required interface.
     */
    error InvalidAssetControllerInterface();

    /**
     * @dev Thrown when the vault contract does not implement the required interface.
     */
    error InvalidAssetVaultInterface();

    /**
     * @dev Emitted when the new asset class is registered.
     * @param assetClass Asset class ID.
     * @param controller Controller address.
     * @param vault Vault address.
     */
    event AssetClassRegistered(bytes4 indexed assetClass, address indexed controller, address indexed vault);

    /**
     * @dev Emitted when the asset class controller is changed.
     * @param assetClass Asset class ID.
     * @param newController New controller address.
     */
    event AssetClassControllerChanged(bytes4 indexed assetClass, address indexed newController);

    /**
     * @dev Emitted when the asset class vault is changed.
     * @param assetClass Asset class ID.
     * @param newVault New vault address.
     */
    event AssetClassVaultChanged(bytes4 indexed assetClass, address indexed newVault);

    /**
     * @dev Asset class configuration.
     * @param vault Asset class vault.
     * @param controller Asset class controller.
     */
    struct ClassConfig {
        address vault;
        address controller;
    }

    /**
     * @dev Registers new asset class.
     * @param assetClass Asset class ID.
     * @param config Asset class initial configuration.
     */
    function registerAssetClass(bytes4 assetClass, ClassConfig calldata config) external;

    /**
     * @dev Sets asset class vault.
     * @param assetClass Asset class ID.
     * @param vault Asset class vault address.
     */
    function setAssetClassVault(bytes4 assetClass, address vault) external;

    /**
     * @dev Sets asset class controller.
     * @param assetClass Asset class ID.
     * @param controller Asset class controller address.
     */
    function setAssetClassController(bytes4 assetClass, address controller) external;

    /**
     * @dev Returns asset class configuration.
     * @param assetClass Asset class ID.
     * @return Asset class configuration.
     */
    function assetClassConfig(bytes4 assetClass) external view returns (ClassConfig memory);

    /**
     * @dev Checks asset class registration.
     * @param assetClass Asset class ID.
     */
    function isRegisteredAssetClass(bytes4 assetClass) external view returns (bool);

    /**
     * @dev Reverts if asset class is not registered.
     * @param assetClass Asset class ID.
     */
    function checkRegisteredAssetClass(bytes4 assetClass) external view;
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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IContractEntity is IERC165 {
    /**
     * @dev Thrown when contract entity does not implement the required interface.
     */
    error InvalidContractEntityInterface();

    /**
     * @dev Returns implemented contract key.
     * @return Contract key;
     */
    function contractKey() external pure returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

library Protocol {
    /**
     * @dev Thrown when the provided token does not match with the configured base token.
     */
    error BaseTokenMismatch();

    /**
     * @dev Protocol configuration.
     * @param baseToken ERC20 contract. Used as the price denominator.
     * @param protocolExternalFeesCollector Address that will accumulate fees
     * received from external source directly (e.g. Warper performing manual rewards distribution).
     */
    struct Config {
        IERC20Upgradeable baseToken;
        address protocolExternalFeesCollector;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "../../asset/Assets.sol";
import "../../contract-registry/Contracts.sol";
import "../../metahub/core/IMetahub.sol";
import "../IWarperController.sol";
import "../preset-factory/IWarperPresetFactory.sol";
import "./IWarperManager.sol";
import "../IWarper.sol";

library Warpers {
    using AddressUpgradeable for address;
    using ERC165CheckerUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;
    using Warpers for Registry;
    using Assets for Assets.Asset;
    using Assets for Assets.Registry;

    /**
     * @dev Thrown if creating warper for universe asset in case one already exists.
     */
    error MultipleWarpersNotSupported();

    /**
     * @dev Thrown if provided warper address does not implement warper interface.
     */
    error InvalidWarperInterface();

    /**
     * @dev Thrown when the warper returned metahub address differs from the one it is being registered in.
     * @param provided Metahub address returned by warper.
     * @param required Required metahub address.
     */
    error WarperHasIncorrectMetahubReference(address provided, address required);

    /**
     * @dev Thrown when performing action or accessing data of an unknown warper.
     * @param warper Warper address.
     */
    error WarperIsNotRegistered(address warper);

    /**
     * @dev Thrown upon attempting to register a warper twice.
     * @param warper Duplicate warper address.
     */
    error WarperIsAlreadyRegistered(address warper);

    /**
     * @dev Thrown upon attempting to rent for universe without any warper(s).
     */
    error MissingWarpersForUniverse(uint256 universeId);

    /**
     * @dev Thrown upon attempting to rent for asset in the certain universe without any warper(s).
     */
    error MissingWarpersForAssetInUniverse(uint256 universeId, address asset);

    /**
     * @dev Thrown when the operation is not allowed due to the warper being paused.
     */
    error WarperIsPaused();

    /**
     * @dev Thrown when the operation is not allowed due to the warper not being paused.
     */
    error WarperIsNotPaused();

    /**
     * @dev Thrown when there are no registered warpers for a particular asset.
     * @param asset Asset address.
     */
    error UnsupportedAsset(address asset);

    /**
     * @dev Thrown upon attempting to use the warper which is not registered for the provided asset.
     */
    error IncompatibleAsset(address asset);

    /**
     * @dev Registered warper data.
     * @param assetClass The identifying asset class.
     * @param original Original asset contract address.
     * @param paused Indicates whether the warper is paused.
     * @param controller Warper controller.
     * @param name Warper name.
     * @param universeId Warper universe ID.
     */
    struct Warper {
        bytes4 assetClass;
        address original;
        bool paused;
        IWarperController controller;
        string name;
        uint256 universeId;
    }

    /**
     * @dev Reverts if the warper original does not match the `asset`;
     */
    function checkCompatibleAsset(Warper memory self, Assets.Asset memory asset) internal pure {
        address original = asset.token();
        if (self.original != original) revert IncompatibleAsset(original);
    }

    /**
     * @dev Puts the warper on pause.
     */
    function pause(Warper storage self) internal {
        if (self.paused) revert WarperIsPaused();

        self.paused = true;
    }

    /**
     * @dev Lifts the warper pause.
     */
    function unpause(Warper storage self) internal {
        if (!self.paused) revert WarperIsNotPaused();

        self.paused = false;
    }

    /**
     * @dev Reverts if the warper is paused.
     */
    function checkNotPaused(Warper memory self) internal pure {
        if (self.paused) revert WarperIsPaused();
    }

    /**
     * @dev Warper registry.
     * @param presetFactory Warper preset factory contract.
     * @param warperIndex Set of registered warper addresses.
     * @param universeWarperIndex Mapping from a universe ID to the set of warper addresses registered by the universe.
     * @param universeAssetWarperIndex Mapping from a universe ID to the set of warper addresses registered
     * by the universe.
     * @param assetWarperIndex Mapping from an original asset address to the set of warper addresses,
     * registered for the asset.
     * @param warpers Mapping from a warper address to the warper details.
     */
    struct Registry {
        IWarperPresetFactory presetFactory;
        EnumerableSetUpgradeable.AddressSet warperIndex;
        mapping(uint256 => EnumerableSetUpgradeable.AddressSet) universeWarperIndex;
        mapping(address => EnumerableSetUpgradeable.AddressSet) assetWarperIndex;
        mapping(uint256 => mapping(address => EnumerableSetUpgradeable.AddressSet)) universeAssetWarperIndex;
        mapping(address => Warpers.Warper) warpers;
    }

    /**
     * @dev Performs warper registration.
     * @param warper Warper address.
     * @param params Warper registration params.
     */
    function registerWarper(
        Registry storage self,
        address warper,
        IWarperManager.WarperRegistrationParams memory params
    ) internal returns (bytes4 assetClass, address original) {
        // Check that provided warper address is a valid contract.
        if (!warper.isContract() || !warper.supportsInterface(type(IWarper).interfaceId)) {
            revert InvalidWarperInterface();
        }

        // Creates allowance for only one warper for universe asset.
        // Throws when trying to create warper for universe asset in case one already exists.
        // Should be removed while adding multi-warper support for universe asset.
        if (self.universeAssetWarperIndex[params.universeId][IWarper(warper).__original()].length() >= 1) {
            revert MultipleWarpersNotSupported();
        }

        // Check that warper has correct metahub reference.
        address metahub = IWarper(warper).__metahub();
        if (metahub != IWarperManager(address(this)).metahub())
            revert WarperHasIncorrectMetahubReference(metahub, IWarperManager(address(this)).metahub());

        // Check that warper asset class is supported.
        assetClass = IWarper(warper).__assetClass();

        address warperController = IAssetClassRegistry(IMetahub(metahub).getContract(Contracts.ASSET_CLASS_REGISTRY))
            .assetClassConfig(assetClass)
            .controller;

        // Retrieve warper controller based on assetClass.
        // Controller resolution for unsupported asset class will revert.
        IWarperController controller = IWarperController(warperController);

        // Ensure warper compatibility with the current generation of asset controller.
        controller.checkCompatibleWarper(warper);

        // Retrieve original asset address.
        original = IWarper(warper).__original();

        // Save warper record.
        _register(
            self,
            warper,
            Warpers.Warper({
                original: original,
                controller: controller,
                name: params.name,
                universeId: params.universeId,
                paused: params.paused,
                assetClass: assetClass
            })
        );
    }

    /**
     * @dev Performs warper registration.
     */
    function _register(
        Registry storage self,
        address warperAddress,
        Warper memory warper
    ) private {
        if (!self.warperIndex.add(warperAddress)) revert WarperIsAlreadyRegistered(warperAddress);

        // Create warper main registration record.
        self.warpers[warperAddress] = warper;
        // Associate the warper with the universe.
        self.universeWarperIndex[warper.universeId].add(warperAddress);
        // Associate the warper with the original asset.
        self.assetWarperIndex[warper.original].add(warperAddress);
        // Associate the warper to the original asset in certain universe
        self.universeAssetWarperIndex[warper.universeId][warper.original].add(warperAddress);
    }

    /**
     * @dev Removes warper data from the registry.
     */
    function remove(Registry storage self, address warperAddress) internal {
        Warper storage warper = self.warpers[warperAddress];
        // Clean up universe index.
        self.universeWarperIndex[warper.universeId].remove(warperAddress);
        // Clean up asset index.
        self.assetWarperIndex[warper.original].remove(warperAddress);
        // Clean up main index.
        self.warperIndex.remove(warperAddress);
        // Clean up universe asset index
        self.universeAssetWarperIndex[warper.universeId][warper.original].remove(warperAddress);
        // Delete warper data.
        delete self.warpers[warperAddress];
    }

    /**
     * @dev Returns the paginated list of warpers belonging to the particular universe.
     */
    function universeWarpers(
        Registry storage self,
        uint256 universeId,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory, Warpers.Warper[] memory) {
        return self.paginateIndexedWarpers(self.universeWarperIndex[universeId], offset, limit);
    }

    /**
     * @dev Returns the paginated list of warpers belonging to the particular universe.
     */
    function universeAssetWarpers(
        Registry storage self,
        uint256 universeId,
        address asset,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory, Warpers.Warper[] memory) {
        return self.paginateIndexedWarpers(self.universeAssetWarperIndex[universeId][asset], offset, limit);
    }

    /**
     * @dev Checks warper registration by address.
     */
    function isRegisteredWarper(Registry storage self, address warper) internal view returns (bool) {
        return self.warperIndex.contains(warper);
    }

    /**
     * @dev Reverts if warper is not registered.
     */
    function checkRegisteredWarper(Registry storage self, address warper) internal view {
        if (!self.isRegisteredWarper(warper)) revert WarperIsNotRegistered(warper);
    }

    /**
     * @dev Reverts if no warpers are registered for the universe.
     */
    function checkUniverseHasWarper(Registry storage self, uint256 universeId) internal view {
        if (self.universeWarperIndex[universeId].length() == 0) revert MissingWarpersForUniverse(universeId);
    }

    /**
     * @dev Reverts if no warpers are registered for the universe.
     */
    function checkUniverseHasWarperForAsset(
        Registry storage self,
        uint256 universeId,
        address asset
    ) internal view {
        if (self.universeAssetWarperIndex[universeId][asset].length() == 0)
            revert MissingWarpersForAssetInUniverse(universeId, asset);
    }

    /**
     * @dev Checks asset support by address.
     * The supported asset should have at least one warper.
     * @param asset Asset address.
     */
    function isSupportedAsset(Registry storage self, address asset) internal view returns (bool) {
        return self.assetWarperIndex[asset].length() > 0;
    }

    /**
     * @dev Returns the number of warpers belonging to the particular universe.
     */
    function universeWarperCount(Registry storage self, uint256 universeId) internal view returns (uint256) {
        return self.universeWarperIndex[universeId].length();
    }

    /**
     * @dev Returns the number of warpers registered for certain asset in universe.
     * @param universeId Universe ID.
     * @param asset Asset address.
     */
    function universeAssetWarperCount(
        Registry storage self,
        uint256 universeId,
        address asset
    ) internal view returns (uint256) {
        return self.universeAssetWarperIndex[universeId][asset].length();
    }

    /**
     * @dev Returns the number of warpers associated with the particular original asset.
     */
    function supported(Registry storage self, address original) internal view returns (uint256) {
        return self.assetWarperIndex[original].length();
    }

    /**
     * @dev Returns the paginated list of registered warpers using provided index reference.
     */
    function paginateIndexedWarpers(
        Registry storage self,
        EnumerableSetUpgradeable.AddressSet storage warperIndex,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory, Warper[] memory) {
        uint256 indexSize = warperIndex.length();
        if (offset >= indexSize) return (new address[](0), new Warper[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        Warper[] memory warpers = new Warper[](limit);
        address[] memory warperAddresses = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            warperAddresses[i] = warperIndex.at(offset + i);
            warpers[i] = self.warpers[warperAddresses[i]];
        }

        return (warperAddresses, warpers);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";

interface ITaxTermsRegistry is IContractEntity {
    /**
     * @dev Thrown upon attempting to work with universe without tax terms.
     */
    error MissingUniverseTaxTerms(bytes4 taxStrategyId, uint256 universeId, address warperAddress);

    /**
     * @dev Thrown upon attempting to work with protocol without tax terms.
     */
    error MissingProtocolTaxTerms(bytes4 taxStrategyId, uint256 universeId, address warperAddress);

    /**
     * @dev Thrown upon attempting to work with universe without tax terms on local level.
     */
    error UniverseLocalTaxTermsMismatch(uint256 universeId, bytes4 taxStrategyId);

    /**
     * @dev Thrown upon attempting to work with universe without tax terms on warper level.
     */
    error UniverseWarperTaxTermsMismatch(uint256 universeId, address warperAddress, bytes4 taxStrategyId);

    /**
     * @dev Thrown upon attempting to work with protocol without tax terms on global level.
     */
    error ProtocolGlobalTaxTermsMismatch(bytes4 taxStrategyId);

    /**
     * @dev Thrown upon attempting to work with protocol without tax terms on universe level.
     */
    error ProtocolUniverseTaxTermsMismatch(uint256 universeId, bytes4 taxStrategyId);

    /**
     * @dev Thrown upon attempting to work with protocol without tax terms on warper level.
     */
    error ProtocolWarperTaxTermsMismatch(address warperAddress, bytes4 taxStrategyId);

    /**
     * @dev Emitted when universe local tax terms are registered.
     * @param universeId Universe ID.
     * @param strategyId Tax strategy ID.
     * @param strategyData Tax strategy data.
     */
    event UniverseLocalTaxTermsRegistered(uint256 indexed universeId, bytes4 indexed strategyId, bytes strategyData);

    /**
     * @dev Emitted when universe local tax terms are removed.
     * @param universeId Universe ID.
     * @param strategyId Tax strategy ID.
     */
    event UniverseLocalTaxTermsRemoved(uint256 indexed universeId, bytes4 indexed strategyId);

    /**
     * @dev Emitted when universe warper tax terms are registered.
     * @param universeId Universe ID.
     * @param warperAddress Warper address.
     * @param strategyId Tax strategy ID.
     * @param strategyData Tax strategy data.
     */
    event UniverseWarperTaxTermsRegistered(
        uint256 indexed universeId,
        address indexed warperAddress,
        bytes4 indexed strategyId,
        bytes strategyData
    );

    /**
     * @dev Emitted when universe warper tax terms are removed.
     * @param universeId Universe ID.
     * @param warperAddress Warper address.
     * @param strategyId Tax strategy ID.
     */
    event UniverseWarperTaxTermsRemoved(
        uint256 indexed universeId,
        address indexed warperAddress,
        bytes4 indexed strategyId
    );

    /**
     * @dev Emitted when protocol global tax terms are registered.
     * @param strategyId Tax strategy ID.
     * @param strategyData Tax strategy data.
     */
    event ProtocolGlobalTaxTermsRegistered(bytes4 indexed strategyId, bytes strategyData);

    /**
     * @dev Emitted when protocol global tax terms are removed.
     * @param strategyId Tax strategy ID.
     */
    event ProtocolGlobalTaxTermsRemoved(bytes4 indexed strategyId);

    /**
     * @dev Emitted when protocol global tax terms are registered.
     * @param universeId Universe ID.
     * @param strategyId Tax strategy ID.
     * @param strategyData Tax strategy data.
     */
    event ProtocolUniverseTaxTermsRegistered(uint256 indexed universeId, bytes4 indexed strategyId, bytes strategyData);

    /**
     * @dev Emitted when protocol global tax terms are removed.
     * @param universeId Universe ID.
     * @param strategyId Tax strategy ID.
     */
    event ProtocolUniverseTaxTermsRemoved(uint256 indexed universeId, bytes4 indexed strategyId);

    /**
     * @dev Emitted when protocol warper tax terms are registered.
     * @param warperAddress Warper address.
     * @param strategyId Tax strategy ID.
     * @param strategyData Tax strategy data.
     */
    event ProtocolWarperTaxTermsRegistered(
        address indexed warperAddress,
        bytes4 indexed strategyId,
        bytes strategyData
    );

    /**
     * @dev Emitted when protocol warper tax terms are removed.
     * @param warperAddress Warper address.
     * @param strategyId Tax strategy ID.
     */
    event ProtocolWarperTaxTermsRemoved(address indexed warperAddress, bytes4 indexed strategyId);

    /**
     * @dev Tax terms information.
     * @param strategyId Tax strategy ID.
     * @param strategyData Tax strategy data.
     */
    struct TaxTerms {
        bytes4 strategyId;
        bytes strategyData;
    }

    /**
     * @dev Tax Terms parameters.
     * @param taxStrategyId Tax strategy ID.
     * @param universeId Universe ID.
     * @param warperAddress Address of the warper.
     */
    struct Params {
        bytes4 taxStrategyId;
        uint256 universeId;
        address warperAddress;
    }

    /**
     * @dev Registers universe local tax terms.
     * @param universeId Universe ID.
     * @param terms Tax terms data.
     */
    function registerUniverseLocalTaxTerms(uint256 universeId, TaxTerms calldata terms) external;

    /**
     * @dev Removes universe local tax terms.
     * @param universeId Universe ID.
     * @param taxStrategyId Tax strategy ID.
     */
    function removeUniverseLocalTaxTerms(uint256 universeId, bytes4 taxStrategyId) external;

    /**
     * @dev Registers universe warper tax terms.
     * @param universeId Universe ID.
     * @param warperAddress Warper address.
     * @param terms Tax terms data.
     */
    function registerUniverseWarperTaxTerms(
        uint256 universeId,
        address warperAddress,
        TaxTerms calldata terms
    ) external;

    /**
     * @dev Removes universe warper tax terms.
     * @param universeId Universe ID.
     * @param warperAddress Warper address.
     * @param taxStrategyId Tax strategy ID.
     */
    function removeUniverseWarperTaxTerms(
        uint256 universeId,
        address warperAddress,
        bytes4 taxStrategyId
    ) external;

    /**
     * @dev Registers protocol global tax terms.
     * @param terms Tax terms.
     */
    function registerProtocolGlobalTaxTerms(TaxTerms calldata terms) external;

    /**
     * @dev Removes protocol global tax terms.
     * @param taxStrategyId Tax strategy ID.
     */
    function removeProtocolGlobalTaxTerms(bytes4 taxStrategyId) external;

    /**
     * @dev Registers protocol universe tax terms.
     * @param universeId Universe ID.
     * @param terms Tax terms.
     */
    function registerProtocolUniverseTaxTerms(uint256 universeId, TaxTerms calldata terms) external;

    /**
     * @dev Removes protocol universe tax terms.
     * @param universeId Universe ID
     * @param taxStrategyId Tax strategy ID.
     */
    function removeProtocolUniverseTaxTerms(uint256 universeId, bytes4 taxStrategyId) external;

    /**
     * @dev Registers protocol warper tax terms.
     * @param warperAddress Warper address.
     * @param terms Tax terms.
     */
    function registerProtocolWarperTaxTerms(address warperAddress, TaxTerms calldata terms) external;

    /**
     * @dev Removes protocol warper tax terms.
     * @param warperAddress Warper address.
     * @param taxStrategyId Tax strategy ID.
     */
    function removeProtocolWarperTaxTerms(address warperAddress, bytes4 taxStrategyId) external;

    /**
     * @dev Returns universe's tax terms.
     * @param params The tax terms params.
     * @return Tax terms.
     */
    function universeTaxTerms(Params memory params) external view returns (TaxTerms memory);

    /**
     * @dev Returns protocol's tax terms.
     * @param params The tax terms params.
     * @return Tax terms.
     */
    function protocolTaxTerms(Params memory params) external view returns (TaxTerms memory);

    /**
     * @dev Checks registration of universe tax terms on either local or Warper levels.
     *      Reverts in case of absence of listing terms on all levels.
     * @param params ListingTermsParams specific params.
     */
    function checkRegisteredUniverseTaxTermsWithParams(Params memory params) external view;

    /**
     * @dev Checks registration of universe tax terms on either global, universe or Warper levels.
     *      Reverts in case of absence of listing terms on all levels.
     * @param params ListingTermsParams specific params.
     */
    function checkRegisteredProtocolTaxTermsWithParams(Params memory params) external view;

    /**
     * @dev Checks registration of universe local tax terms.
     * @param universeId Universe ID.
     * @param taxStrategyId Tax Strategy ID.
     * @return Boolean that is positive in case of existance
     */
    function areRegisteredUniverseLocalTaxTerms(uint256 universeId, bytes4 taxStrategyId) external view returns (bool);

    /**
     * @dev Checks registration of universe warper tax terms.
     * @param universeId Universe ID.
     * @param warperAddress Warper address.
     * @param taxStrategyId Tax Strategy ID.
     * @return Boolean that is positive in case of existance
     */
    function areRegisteredUniverseWarperTaxTerms(
        uint256 universeId,
        address warperAddress,
        bytes4 taxStrategyId
    ) external view returns (bool);

    /**
     * @dev Checks registration of protocol global tax terms.
     * @param taxStrategyId Tax Strategy ID.
     * @return Boolean that is positive in case of existance
     */
    function areRegisteredProtocolGlobalTaxTerms(bytes4 taxStrategyId) external view returns (bool);

    /**
     * @dev Checks registration of protocol universe tax terms.
     * @param universeId Universe ID.
     * @param taxStrategyId Tax Strategy ID.
     * @return Boolean that is positive in case of existance
     */
    function areRegisteredProtocolUniverseTaxTerms(uint256 universeId, bytes4 taxStrategyId)
        external
        view
        returns (bool);

    /**
     * @dev Checks registration of global protocol warper tax terms.
     * @param warperAddress Warper address.
     * @param taxStrategyId Tax Strategy ID.
     * @return Boolean that is positive in case of existance
     */
    function areRegisteredProtocolWarperTaxTerms(address warperAddress, bytes4 taxStrategyId)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";
import "../../renting/Rentings.sol";

interface ITokenQuote is IContractEntity {
    /**
     * @dev Thrown when the message sender is not Metahub.
     */
    error CallerIsNotMetahub();

    /**
     * @dev Thrown when trying to work with expired token quote.
     */
    error TokenQuoteExpired();

    /**
     * @dev Thrown when trying to work with token quote signed by entity missing quote signing role.
     */
    error InvalidTokenQuoteSigner();

    /**
     * @dev Thrown when token quote listing id does not equal one provided from renting params.
     */
    error TokenQuoteListingIdMismatch();

    /**
     * @dev Thrown when token quote renter address does not equal one provided from renting params.
     */
    error TokenQuoteRenterMismatch();

    /**
     * @dev Thrown when token quote warper address does not equal one provided from renting params.
     */
    error TokenQuoteWarperMismatch();

    /**
     * @dev Describes the universe-specific token quote data.
     * @param paymentToken Address of payment token.
     * @param paymentTokenQuote Quote of payment token in accordance to base token
     */
    struct PaymentTokenData {
        address paymentToken;
        uint256 paymentTokenQuote;
    }

    /**
     * @dev Describes the universe-specific-to-base token quote.
     * @param listingId Listing ID.
     * @param renter Address of renter.
     * @param warperAddress Address of warper.
     * @param paymentToken Address of payment token.
     * @param paymentTokenQuote Quote of payment token in accordance to base token
     * @param nonce Anti-replication mechanism value.
     * @param deadline The maximum possible time when token quote can be used.
     */
    struct TokenQuote {
        uint256 listingId;
        address renter;
        address warperAddress;
        address paymentToken;
        uint256 paymentTokenQuote;
        uint256 nonce;
        uint32 deadline;
    }

    /**
     * @dev Using and verification of the price quote for universe-specific token in relation to base token.
     * @param rentingParams Renting params.
     * @param baseTokenFees Base fees in equivalent of base token.
     * @param tokenQuote Encoded token quote.
     * @param tokenQuoteSignature Token Quote ECDSA signature ABI encoded (v,r,s)(uint8, bytes32, bytes32).
     * @return paymentTokenFees Payment token fees calculated in accordance with payment token quote.
     * @return paymentTokenData Payment token data.
     */
    function useTokenQuote(
        Rentings.Params calldata rentingParams,
        Rentings.RentalFees memory baseTokenFees,
        bytes calldata tokenQuote,
        bytes calldata tokenQuoteSignature
    ) external returns (Rentings.RentalFees memory paymentTokenFees, PaymentTokenData memory paymentTokenData);

    /**
     * @dev Getting the nonce for token quote.
     *      This 'nonce' should be included in the signature of TokenQuote
     * @param renter Address of the renter.
     */
    function getTokenQuoteNonces(address renter) external view returns (uint256);

    /**
     * @dev Getting the Chain ID
     */
    function getChainId() external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// solhint-disable no-empty-blocks
pragma solidity ^0.8.13;

import "../IProtocolConfigManager.sol";
import "../../accounting/IPaymentManager.sol";
import "../../asset/IAssetManager.sol";
import "../../contract-registry/IContractRegistry.sol";

interface IMetahub is IProtocolConfigManager, IPaymentManager, IAssetManager, IContractRegistry {
    /**
     * @dev Raised when the caller is not the WarperManager contract.
     */
    error CallerIsNotWarperManager();

    /**
     * @dev Raised when the caller is not the ListingManager contract.
     */
    error CallerIsNotListingManager();

    /**
     * @dev Raised when the caller is not the RentingManager contract.
     */
    error CallerIsNotRentingManager();

    /**
     * @dev Raised when the caller is not the ERC20RewardDistributor contract.
     */
    error CallerIsNotERC20RewardDistributor();
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";

interface IUniverseRegistry is IContractEntity {
    /**
     * @dev Thrown when the message sender does not own UNIVERSE_WIZARD role and is not Universe owner.
     * @param universeId The Universe ID.
     * @param account The account that was checked.
     */
    error AccountIsNotAuthorizedOperatorForUniverseManagement(uint256 universeId, address account);

    /**
     * @dev Thrown when the message sender does not own UNIVERSE_WIZARD role.
     */
    error AccountIsNotUniverseWizard(address account);

    /**
     * @dev Thrown when a check is made where the given account must also be the Universe owner.
     */
    error AccountIsNotUniverseOwner(address account);

    /**
     * @dev Thrown when a check is made when given token is not registered for the universe.
     */
    error PaymentTokenIsNotRegistered(address paymentToken);

    /**
     * @dev Thrown when trying to add payment token that is already register for the universe.
     */
    error PaymentTokenAlreadyRegistered(address paymentToken);

    /**
     * @dev Thrown when a the supplied universe name is empty.
     */
    error EmptyUniverseName();

    /**
     * @dev Thrown when trying to register a universe with empty list of payment tokens.
     */
    error EmptyListOfUniversePaymentTokens();

    /**
     * @dev Thrown when trying to read universe data for a universe is not registered.
     */
    error QueryForNonExistentUniverse(uint256 universeId);

    /**
     * @dev Emitted when a universe is created.
     * @param universeId Universe ID.
     * @param name Universe name.
     * @param paymentTokens Universe token.
     */
    event UniverseCreated(uint256 indexed universeId, string name, address[] paymentTokens);

    /**
     * @dev Emitted when a universe name is changed.
     * @param universeId Universe ID.
     * @param name The newly set name.
     */
    event UniverseNameChanged(uint256 indexed universeId, string name);

    /**
     * @dev Emitted when a universe payment token is registered.
     * @param universeId Universe ID.
     * @param paymentToken Universe payment token.
     */
    event PaymentTokenRegistered(uint256 indexed universeId, address paymentToken);

    /**
     * @dev Emitted when a universe payment token is disabled.
     * @param universeId Universe ID.
     * @param paymentToken Universe payment token.
     */
    event PaymentTokenRemoved(uint256 indexed universeId, address paymentToken);

    /**
     * @dev Updates the universe token base URI.
     * @param baseURI New base URI. Must include a trailing slash ("/").
     */
    function setUniverseTokenBaseURI(string calldata baseURI) external;

    /**
     * @dev The universe properties & initial configuration params.
     * @param name The universe name.
     * @param token The universe name.
     */
    struct UniverseParams {
        string name;
        address[] paymentTokens;
    }

    /**
     * @dev Creates new Universe. This includes minting new universe NFT,
     * where the caller of this method becomes the universe owner.
     * @param params The universe properties & initial configuration params.
     * @return Universe ID (universe token ID).
     */
    function createUniverse(UniverseParams calldata params) external returns (uint256);

    /**
     * @dev Update the universe name.
     * @param universeId The unique identifier for the universe.
     * @param universeName The universe name to set.
     */
    function setUniverseName(uint256 universeId, string memory universeName) external;

    /**
     * @dev Registers certain payment token for universe.
     * @param universeId The unique identifier for the universe.
     * @param paymentToken The universe payment token.
     */
    function registerUniversePaymentToken(uint256 universeId, address paymentToken) external;

    /**
     * @dev Removes certain payment token for universe.
     * @param universeId The unique identifier for the universe.
     * @param paymentToken The universe payment token.
     */
    function removeUniversePaymentToken(uint256 universeId, address paymentToken) external;

    /**
     * @dev Returns name.
     * @param universeId Universe ID.
     * @return universe name.
     */
    function universeName(uint256 universeId) external view returns (string memory);

    /**
     * @dev Returns the Universe payment token address.
     */
    function universePaymentTokens(uint256 universeId) external view returns (address[] memory paymentTokens);

    /**
     * @dev Returns the Universe token address.
     */
    function universeToken() external view returns (address);

    /**
     * @dev Returns the Universe token base URI.
     */
    function universeTokenBaseURI() external view returns (string memory);

    /**
     * @dev Aggregate and return Universe data.
     * @param universeId Universe-specific ID.
     * @return name The name of the universe.
     */
    function universe(uint256 universeId) external view returns (string memory name, address[] memory paymentTokens);

    /**
     * @dev Reverts if the universe owner is not the provided account address.
     * @param universeId Universe ID.
     * @param account The address of the expected owner.
     */
    function checkUniverseOwner(uint256 universeId, address account) external view;

    /**
     * @dev Reverts if the universe owner is not the provided account address.
     * @param universeId Universe ID.
     * @param paymentToken The address of the payment token.
     */
    function checkUniversePaymentToken(uint256 universeId, address paymentToken) external view;

    /**
     * @dev Returns `true` if the universe owner is the supplied account address.
     * @param universeId Universe ID.
     * @param account The address of the expected owner.
     */
    function isUniverseOwner(uint256 universeId, address account) external view returns (bool);

    /**
     * @dev Returns `true` if the account is UNIVERSE_WIZARD.
     * @param account The account to check for.
     */
    function isUniverseWizard(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../../acl/delegated/IDelegatedAccessControlEnumerable.sol";
import "../../../contract-registry/IContractEntity.sol";
import "../IListingConfiguratorController.sol";

interface IListingConfiguratorRegistry is IDelegatedAccessControlEnumerable, IContractEntity {
    error InvalidZeroAddress();
    error CannotGrantRoleForUnregisteredController(address delegate);
    error InvalidListingConfiguratorController(address controller);
    /**
     * @dev Thrown when lister specifies listing configurator which is not registered in
     * {IListingConfiguratorRegistry}
     */
    error ListingConfiguratorNotRegistered(address listingConfigurator);

    event ListingConfiguratorControllerChanged(address indexed previousController, address indexed newController);

    /**
     * IListingConfiguratorRegistryConfigurator.
     * The listing configurator must be deployed and configured prior to registration,
     * since it becomes available for renting immediately.
     * @param listingConfigurator Listing configurator address.
     */
    function registerListingConfigurator(address listingConfigurator, address admin) external;

    function setController(address controller) external;

    function getController(address listingConfigurator) external view returns (IListingConfiguratorController);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";

interface IListingStrategyRegistry is IContractEntity {
    /**
     * @dev Thrown when the listing strategy is not registered or deprecated.
     * @param listingStrategyId Unsupported listing strategy ID.
     */
    error UnsupportedListingStrategy(bytes4 listingStrategyId);

    /**
     * @dev Thrown when listing controller does not implement the required interface.
     */
    error InvalidListingControllerInterface();

    /**
     * @dev Thrown when the listing cannot be processed by the specific controller due to the listing strategy ID
     * mismatch.
     * @param provided Provided listing strategy ID.
     * @param required Required listing strategy ID.
     */
    error ListingStrategyMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Thrown upon attempting to register a listing strategy twice.
     * @param listingStrategyId Duplicate listing strategy ID.
     */
    error ListingStrategyIsAlreadyRegistered(bytes4 listingStrategyId);

    /**
     * @dev Thrown upon attempting to work with unregistered listing strategy.
     * @param listingStrategyId Listing strategy ID.
     */
    error UnregisteredListingStrategy(bytes4 listingStrategyId);

    /**
     * @dev Emitted when the new listing strategy is registered.
     * @param listingStrategyId Listing strategy ID.
     * @param listingTaxStrategyId Taxation strategy ID.
     * @param controller Controller address.
     */
    event ListingStrategyRegistered(
        bytes4 indexed listingStrategyId,
        bytes4 indexed listingTaxStrategyId,
        address indexed controller
    );

    /**
     * @dev Emitted when the listing strategy controller is changed.
     * @param listingStrategyId Listing strategy ID.
     * @param newController Controller address.
     */
    event ListingStrategyControllerChanged(bytes4 indexed listingStrategyId, address indexed newController);

    /**
     * @dev Listing strategy information.
     * @param controller Listing controller address.
     */
    struct ListingStrategyConfig {
        address controller;
        bytes4 taxStrategyId;
    }

    /**
     * @dev Registers new listing strategy.
     * @param listingStrategyId Listing strategy ID.
     * @param config Listing strategy configuration.
     */
    function registerListingStrategy(bytes4 listingStrategyId, ListingStrategyConfig calldata config) external;

    /**
     * @dev Sets listing strategy controller.
     * @param listingStrategyId Listing strategy ID.
     * @param controller Listing controller address.
     */
    function setListingController(bytes4 listingStrategyId, address controller) external;

    /**
     * @dev Returns listing strategy controller.
     * @param listingStrategyId Listing strategy ID.
     * @return Listing controller address.
     */
    function listingController(bytes4 listingStrategyId) external view returns (address);

    /**
     * @dev Returns tax strategy ID for listing strategy.
     * @param listingStrategyId Listing strategy ID.
     * @return Tax strategy ID.
     */
    function listingTaxId(bytes4 listingStrategyId) external view returns (bytes4);

    /**
     * @dev Returns listing strategy configuration.
     * @param listingStrategyId Listing strategy ID.
     * @return Listing strategy information.
     */
    function listingStrategy(bytes4 listingStrategyId) external view returns (ListingStrategyConfig memory);

    /**
     * @dev Returns tax strategy controller for listing strategy.
     * @param listingStrategyId Listing strategy ID.
     * @return Tax strategy controller address.
     */
    function listingTaxController(bytes4 listingStrategyId) external view returns (address);

    /**
     * @dev Checks listing strategy registration.
     * @param listingStrategyId Listing strategy ID.
     */
    function isRegisteredListingStrategy(bytes4 listingStrategyId) external view returns (bool);

    /**
     * @dev Reverts if listing strategy is not registered.
     * @param listingStrategyId Listing strategy ID.
     */
    function checkRegisteredListingStrategy(bytes4 listingStrategyId) external view;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "../../contract-registry/IContractEntity.sol";
import "../listing-terms-registry/IListingTermsRegistry.sol";
import "../../tax/tax-terms-registry/ITaxTermsRegistry.sol";
import "../../renting/Rentings.sol";

interface IListingController is IERC165, IContractEntity {
    /**
     * @dev Calculates rental fee based on listing terms, tax terms and renting params.
     * @param listingTermsParams Listing terms params.
     * @param listingTerms Listing terms.
     * @param rentingParams Renting params.
     * @return totalFee Rental fee (base tokens per second including taxes).
     * @return listerBaseFee Lister fee (base tokens per second without taxes).
     * @return universeBaseFee Universe fee.
     * @return protocolBaseFee Protocol fee.
     * @return universeTaxTerms Universe tax terms.
     * @return protocolTaxTerms Protocol tax terms.
     */
    function calculateRentalFee(
        IListingTermsRegistry.Params calldata listingTermsParams,
        IListingTermsRegistry.ListingTerms calldata listingTerms,
        Rentings.Params calldata rentingParams
    )
        external
        view
        returns (
            uint256 totalFee,
            uint256 listerBaseFee,
            uint256 universeBaseFee,
            uint256 protocolBaseFee,
            ITaxTermsRegistry.TaxTerms memory universeTaxTerms,
            ITaxTermsRegistry.TaxTerms memory protocolTaxTerms
        );

    /**
     * @dev Returns implemented strategy ID.
     * @return Listing strategy ID.
     */
    function strategyId() external pure returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

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
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165Upgradeable.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../asset/IAssetController.sol";
import "../accounting/Accounts.sol";
import "../renting/Rentings.sol";
import "../warper/warper-manager/Warpers.sol";

interface IWarperController is IAssetController {
    /**
     * @dev Thrown if warper interface is not compatible with the controller.
     */
    error IncompatibleWarperInterface();

    /**
     * @dev Thrown upon attempting to use the warper with an asset different from the one expected by the warper.
     */
    error InvalidAssetForWarper(address warper, address asset);

    /**
     * @dev Thrown upon attempting to rent a warped asset which is already rented.
     */
    error AlreadyRented();

    /**
     * @dev Takes an existing asset and then mints a warper token representing it.
     *      Used in Renting Manager->Warper communication.
     * @param assets The asset(s) that must be warped.
     * @param warper Warper contract to be used for warping.
     * @param to The account which will receive the warped asset.
     * @return warpedCollectionId The warped collection ID.
     * @return warpedAssets The warped Assets.
     */
    function warp(
        Assets.Asset[] memory assets,
        address warper,
        address to
    ) external returns (bytes32 warpedCollectionId, Assets.Asset[] memory warpedAssets);

    /**
     * @dev Executes warper rental hook.
     * @param rentalId Rental agreement ID.
     * @param rentalAgreement Newly registered rental agreement details.
     * @param rentalEarnings The rental earnings breakdown.
     */
    function executeRentingHooks(
        uint256 rentalId,
        Rentings.Agreement memory rentalAgreement,
        Accounts.RentalEarnings memory rentalEarnings
    ) external;

    /**
     * @dev Validates that the warper interface is supported by the current WarperController.
     * @param warper Warper whose interface we must validate.
     * @return bool - `true` if warper is supported.
     */
    function isCompatibleWarper(address warper) external view returns (bool);

    /**
     * @dev Reverts if provided warper is not compatible with the controller.
     */
    function checkCompatibleWarper(address warper) external view;

    /**
     * @dev Validates renting params taking into account various warper mechanics and warper data.
     * Throws an error if the specified asset cannot be rented with particular renting parameters.
     * @param warper Registered warper data.
     * @param assets The listing asset(s) to validate for.
     * @param rentingParams Renting parameters.
     */
    function validateRentingParams(
        Warpers.Warper memory warper,
        Assets.Asset[] memory assets,
        Rentings.Params calldata rentingParams
    ) external view;

    /**
     * @dev Calculates the universe and/or lister premiums.
     * Those are extra amounts that should be added the the resulting rental fee paid by renter.
     * @param assets Assets being rented.
     * @param rentingParams Renting parameters.
     * @param universeFee The current value of the Universe fee component.
     * @param listerFee The current value of the lister fee component.
     * @return universePremium The universe premium amount.
     * @return listerPremium The lister premium amount.
     */
    function calculatePremiums(
        Assets.Asset[] memory assets,
        Rentings.Params calldata rentingParams,
        uint256 universeFee,
        uint256 listerFee
    ) external view returns (uint256 universePremium, uint256 listerPremium);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";

interface IWarperPresetFactory is IContractEntity {
    /**
     * @dev Thrown when the implementation does not support the IWarperPreset interface
     */
    error InvalidWarperPresetInterface();

    /**
     * @dev Thrown when the warper preset id is already present in the storage.
     */
    error DuplicateWarperPresetId(bytes32 presetId);

    /**
     * @dev Thrown when the warper preset has been disabled, when it was expected for it to be enabled.
     */
    error DisabledWarperPreset(bytes32 presetId);

    /**
     * @dev Thrown when the warper preset has been enabled, when it was expected for it to be disabled.
     */
    error EnabledWarperPreset(bytes32 presetId);

    /**
     * @dev Thrown when it was expected for the warper preset to be registeredr.
     */
    error WarperPresetNotRegistered(bytes32 presetId);

    /**
     * @dev Thrown when the provided preset initialization data is empty.
     */
    error EmptyPresetData();

    struct WarperPreset {
        bytes32 id;
        address implementation;
        bool enabled;
    }

    /**
     * @dev Emitted when new warper preset is added.
     */
    event WarperPresetAdded(bytes32 indexed presetId, address indexed implementation);

    /**
     * @dev Emitted when a warper preset is disabled.
     */
    event WarperPresetDisabled(bytes32 indexed presetId);

    /**
     * @dev Emitted when a warper preset is enabled.
     */
    event WarperPresetEnabled(bytes32 indexed presetId);

    /**
     * @dev Emitted when a warper preset is enabled.
     */
    event WarperPresetRemoved(bytes32 indexed presetId);

    /**
     * @dev Emitted when a warper preset is deployed.
     */
    event WarperPresetDeployed(bytes32 indexed presetId, address indexed warper);

    /**
     * @dev Stores the association between `presetId` and `implementation` address.
     * NOTE: Warper `implementation` must be deployed beforehand.
     * @param presetId Warper preset id.
     * @param implementation Warper implementation address.
     */
    function addPreset(bytes32 presetId, address implementation) external;

    /**
     * @dev Removes the association between `presetId` and its implementation.
     * @param presetId Warper preset id.
     */
    function removePreset(bytes32 presetId) external;

    /**
     * @dev Enables warper preset, which makes it deployable.
     * @param presetId Warper preset id.
     */
    function enablePreset(bytes32 presetId) external;

    /**
     * @dev Disable warper preset, which makes non-deployable.
     * @param presetId Warper preset id.
     */
    function disablePreset(bytes32 presetId) external;

    /**
     * @dev Deploys a new warper from the preset identified by `presetId`.
     * @param presetId Warper preset id.
     * @param initData Warper initialization payload.
     * @return Deployed warper address.
     */
    function deployPreset(bytes32 presetId, bytes calldata initData) external returns (address);

    /**
     * @dev Checks whether warper preset is enabled and available for deployment.
     * @param presetId Warper preset id.
     */
    function presetEnabled(bytes32 presetId) external view returns (bool);

    /**
     * @dev Returns the list of all registered warper presets.
     */
    function presets() external view returns (WarperPreset[] memory);

    /**
     * @dev Returns the warper preset details.
     * @param presetId Warper preset id.
     */
    function preset(bytes32 presetId) external view returns (WarperPreset memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../contract-registry/IContractEntity.sol";
import "./Warpers.sol";

interface IWarperManager is IContractEntity {
    /**
     * @dev Thrown when the `account` is not a Wizard authorized for Warper Management.
     * @param account The account that was checked.
     */
    error AccountIsNotAuthorizedWizardForWarperManagement(address account);

    /**
     * @dev Thrown when the `account` is not an Operator authorized for Warper Management.
     * @param warper The Warper's address.
     * @param account The account that was checked.
     */
    error AccountIsNotAuthorizedOperatorForWarperManagement(address warper, address account);

    /**
     * @dev Thrown when the `account` is not a Warper admin for `warper`.
     * @param warper The Warper.
     * @param account The account that was checked.
     */
    error AccountIsNotWarperAdmin(address warper, address account);

    /**
     * @dev Warper registration params.
     * @param name The warper name.
     * @param universeId The universe ID.
     * @param paused Indicates whether the warper should stay paused after registration.
     */
    struct WarperRegistrationParams {
        string name;
        uint256 universeId;
        bool paused;
    }

    /**
     * @dev Emitted when a new warper is registered.
     * @param universeId Universe ID.
     * @param warper Warper address.
     * @param original Original asset address.
     * @param assetClass Asset class ID (identical for the `original` and `warper`).
     */
    event WarperRegistered(
        uint256 indexed universeId,
        address indexed warper,
        address indexed original,
        bytes4 assetClass
    );

    /**
     * @dev Emitted when the warper is no longer registered.
     * @param warper Warper address.
     */
    event WarperDeregistered(address indexed warper);

    /**
     * @dev Emitted when the warper is paused.
     * @param warper Address.
     */
    event WarperPaused(address indexed warper);

    /**
     * @dev Emitted when the warper pause is lifted.
     * @param warper Address.
     */
    event WarperUnpaused(address indexed warper);

    /**
     * @dev Registers a new warper.
     * The warper must be deployed and configured prior to registration,
     * since it becomes available for renting immediately.
     * @param warper Warper address.
     * @param params Warper registration params.
     */
    function registerWarper(address warper, WarperRegistrationParams memory params) external;

    /**
     * @dev Deletes warper registration information.
     * All current rental agreements with the warper will stay intact, but the new rentals won't be possible.
     * @param warper Warper address.
     */
    function deregisterWarper(address warper) external;

    /**
     * @dev Puts the warper on pause.
     * Emits a {WarperPaused} event.
     * @param warper Address.
     */
    function pauseWarper(address warper) external;

    /**
     * @dev Lifts the warper pause.
     * Emits a {WarperUnpaused} event.
     * @param warper Address.
     */
    function unpauseWarper(address warper) external;

    /**
     * @dev Sets the new controller address for one or multiple registered warpers.
     * @param warpers A list of registered warper addresses which controller will be changed.
     * @param controller Warper controller address.
     */
    function setWarperController(address[] calldata warpers, address controller) external;

    /**
     * @dev Reverts if the warpers universe owner is not the provided account address.
     * @param warper Warpers address.
     * @param account The address that's expected to be the warpers universe owner.
     */
    function checkWarperAdmin(address warper, address account) external view;

    /**
     * @dev Reverts if warper is not registered.
     */
    function checkRegisteredWarper(address warper) external view;

    /**
     * @dev Reverts if no warpers are registered for the universe.
     */
    function checkUniverseHasWarper(uint256 universeId) external view;

    /**
     * @dev Reverts if no warpers are registered for asset in the certain universe.
     */
    function checkUniverseHasWarperForAsset(uint256 universeId, address asset) external view;

    /**
     * @dev Reverts if the provided `account` is not a Wizard authorized for Warper Management.
     * @param account The account to check for.
     */
    function checkIsAuthorizedWizardForWarperManagement(address account) external view;

    /**
     * @dev Returns the number of warpers belonging to the particular universe.
     * @param universeId The universe ID.
     * @return Warper count.
     */
    function universeWarperCount(uint256 universeId) external view returns (uint256);

    /**
     * @dev Returns the list of warpers belonging to the particular universe.
     * @param universeId The universe ID.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return List of warper addresses.
     * @return List of warpers.
     */
    function universeWarpers(
        uint256 universeId,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, Warpers.Warper[] memory);

    /**
     * @dev Returns the list of warpers belonging to the particular asset in universe.
     * @param universeId The universe ID.
     * @param asset Original asset.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return List of warper addresses.
     * @return List of warpers.
     */
    function universeAssetWarpers(
        uint256 universeId,
        address asset,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, Warpers.Warper[] memory);

    /**
     * @dev Returns the number of warpers registered for certain asset in universe.
     * @param universeId Universe ID.
     * @param asset Original asset address.
     * @return Warper count.
     */
    function universeAssetWarperCount(uint256 universeId, address asset) external view returns (uint256);

    /**
     * @dev Returns the Metahub address.
     */
    function metahub() external view returns (address);

    /**
     * @dev Checks whether `account` is the `warper` admin.
     * @param warper Warper address.
     * @param account Account address.
     * @return True if the `account` is the admin of the `warper` and false otherwise.
     */
    function isWarperAdmin(address warper, address account) external view returns (bool);

    /**
     * @dev Returns registered warper details.
     * @param warper Warper address.
     * @return Warper details.
     */
    function warperInfo(address warper) external view returns (Warpers.Warper memory);

    /**
     * @dev Returns warper controller address.
     * @param warper Warper address.
     * @return Current controller.
     */
    function warperController(address warper) external view returns (address);
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IWarper is IERC165 {
    /**
     * @dev Returns the original asset address.
     */
    function __original() external view returns (address);

    /**
     * @dev Returns the Metahub address.
     */
    function __metahub() external view returns (address);

    /**
     * @dev Returns the warper asset class ID.
     */
    function __assetClass() external view returns (bytes4);

    /**
     * @dev Validates if a warper supports multiple interfaces at once.
     * @return an array of `bool` flags in order as the `interfaceIds` were passed.
     */
    function __supportedInterfaces(bytes4[] memory interfaceIds) external view returns (bool[] memory);
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
pragma solidity ^0.8.13;

interface IProtocolConfigManager {
    /**
     * @dev Emitted when address of collector for Protocol's external fees is changed.
     * @param oldCollector Address of old collector.
     * @param newCollector Address of new collector.
     */
    event ProtocolExternalFeesCollectorChanged(address oldCollector, address newCollector);

    /**
     * @dev Changes the address of collector for Protocol's external fees.
     * Also emits `ProtocolExternalFeesCollectorChanged`.
     * @param newProtocolExternalFeesCollector The new collector's address.
     */
    function changeProtocolExternalFeesCollector(address newProtocolExternalFeesCollector) external;

    /**
     * @dev Returns the base token that's used for stable price denomination.
     * @return The base token address.
     */
    function baseToken() external view returns (address);

    /**
     * @dev Returns the base token decimals.
     * @return The base token decimals.
     */
    function baseTokenDecimals() external view returns (uint8);

    /**
     * @dev Returns address of Protocol's external fees collector.
     * @return The address of Protocol's external fees collector.
     */
    function protocolExternalFeesCollector() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Accounts.sol";
import "./token-quote/ITokenQuote.sol";
import "./distributors/ERC20RewardDistributionHelper.sol";
import "../listing/Listings.sol";

interface IPaymentManager {
    /**
     * @notice Describes the earning type.
     */
    enum EarningType {
        LISTER_FIXED_FEE,
        LISTER_EXTERNAL_ERC20_REWARD,
        RENTER_EXTERNAL_ERC20_REWARD,
        UNIVERSE_FIXED_FEE,
        UNIVERSE_EXTERNAL_ERC20_REWARD,
        PROTOCOL_FIXED_FEE,
        PROTOCOL_EXTERNAL_ERC20_REWARD
    }

    /**
     * @dev Emitted when a user has earned some amount tokens.
     * @param user Address of the user that earned some amount.
     * @param earningType Describes the type of the user.
     * @param paymentToken The currency that the user has earned.
     * @param amount The amount of tokens that the user has earned.
     */
    event UserEarned(
        address indexed user,
        EarningType indexed earningType,
        address indexed paymentToken,
        uint256 amount
    );

    /**
     * @dev Emitted when the universe has earned some amount of tokens.
     * @param universeId ID of the universe that earned the tokens.
     * @param earningType Describes the type of the user.
     * @param paymentToken The currency that the user has earned.
     * @param amount The amount of tokens that the user has earned.
     */
    event UniverseEarned(
        uint256 indexed universeId,
        EarningType indexed earningType,
        address indexed paymentToken,
        uint256 amount
    );

    /**
     * @dev Emitted when the protocol has earned some amount of tokens.
     * @param earningType Describes the type of the user.
     * @param paymentToken The currency that the user has earned.
     * @param amount The amount of tokens that the user has earned.
     */
    event ProtocolEarned(EarningType indexed earningType, address indexed paymentToken, uint256 amount);

    /**
     * @dev Redirects handle rental payment from RentingManager to Accounts.Registry
     * @param rentingParams Renting params.
     * @param fees Rental fees.
     * @param payer Address of the rent payer.
     * @param maxPaymentAmount Maximum payment amount.
     * @param tokenQuote Encoded token quote data.
     * @param tokenQuoteSignature Encoded ECDSA signature for checking token quote data for validity.
     * @return rentalEarnings Payment token earnings.
     * @return paymentTokenData Payment token data.
     */
    function handleRentalPayment(
        Rentings.Params calldata rentingParams,
        Rentings.RentalFees calldata fees,
        address payer,
        uint256 maxPaymentAmount,
        bytes calldata tokenQuote,
        bytes calldata tokenQuoteSignature
    )
        external
        returns (Accounts.RentalEarnings memory rentalEarnings, ITokenQuote.PaymentTokenData memory paymentTokenData);

    /**
     * @dev Redirects handle external ERC20 reward payment from ERC20RewardDistributor to Accounts.Registry.
     * Metahub must have enough funds to cover the distribution.
     * ERC20RewardDistributor makes sure of that.
     * @param listing Represents, related to the distribution, listing.
     * @param agreement Represents, related to the distribution, agreement.
     * @param rentalExternalERC20RewardFees Represents calculated fees based on all terms applied to external reward.
     */
    function handleExternalERC20Reward(
        Listings.Listing memory listing,
        Rentings.Agreement memory agreement,
        ERC20RewardDistributionHelper.RentalExternalERC20RewardFees memory rentalExternalERC20RewardFees
    ) external returns (Accounts.RentalEarnings memory rentalExternalRewardEarnings);

    /**
     * @dev Transfers the specific `amount` of `token` from a protocol balance to an arbitrary address.
     * @param token The token address.
     * @param amount The amount to be withdrawn.
     * @param to The payee address.
     */
    function withdrawProtocolFunds(
        address token,
        uint256 amount,
        address to
    ) external;

    /**
     * @dev Transfers the specific `amount` of `token` from a universe balance to an arbitrary address.
     * @param universeId The universe ID.
     * @param token The token address.
     * @param amount The amount to be withdrawn.
     * @param to The payee address.
     */
    function withdrawUniverseFunds(
        uint256 universeId,
        address token,
        uint256 amount,
        address to
    ) external;

    /**
     * @dev Transfers the specific `amount` of `token` from a user balance to an arbitrary address.
     * @param token The token address.
     * @param amount The amount to be withdrawn.
     * @param to The payee address.
     */
    function withdrawFunds(
        address token,
        uint256 amount,
        address to
    ) external;

    /**
     * @dev Returns the amount of `token`, currently accumulated by the protocol.
     * @param token The token address.
     * @return Balance of `token`.
     */
    function protocolBalance(address token) external view returns (uint256);

    /**
     * @dev Returns the list of protocol balances in various tokens.
     * @return List of balances.
     */
    function protocolBalances() external view returns (Accounts.Balance[] memory);

    /**
     * @dev Returns the amount of `token`, currently accumulated by the universe.
     * @param universeId The universe ID.
     * @param token The token address.
     * @return Balance of `token`.
     */
    function universeBalance(uint256 universeId, address token) external view returns (uint256);

    /**
     * @dev Returns the list of universe balances in various tokens.
     * @param universeId The universe ID.
     * @return List of balances.
     */
    function universeBalances(uint256 universeId) external view returns (Accounts.Balance[] memory);

    /**
     * @dev Returns the amount of `token`, currently accumulated by the user.
     * @param account The account to query the balance for.
     * @param token The token address.
     * @return Balance of `token`.
     */
    function balance(address account, address token) external view returns (uint256);

    /**
     * @dev Returns the list of user balances in various tokens.
     * @param account The account to query the balance for.
     * @return List of balances.
     */
    function balances(address account) external view returns (Accounts.Balance[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Assets.sol";

interface IAssetManager {
    /**
     * @dev Register a new asset.
     * @param assetClass Asset class identifier.
     * @param original The original assets address.
     */
    function registerAsset(bytes4 assetClass, address original) external;

    /**
     * @dev Transfers an asset to the vault using associated controller.
     * @param asset Asset and its value.
     * @param from The owner of the asset.
     */
    function depositAsset(Assets.Asset memory asset, address from) external;

    /**
     * @dev Withdraw asset from the vault using associated controller to owner.
     * @param asset Asset and its value.
     */
    function withdrawAsset(Assets.Asset calldata asset) external;

    /**
     * @dev Retrieve the asset class controller for a given assetClass.
     * @param assetClass Asset class identifier.
     * @return The asset class controller.
     */
    function assetClassController(bytes4 assetClass) external view returns (address);

    /**
     * @dev Returns the number of currently supported assets.
     * @return Asset count.
     */
    function supportedAssetCount() external view returns (uint256);

    /**
     * @dev Returns the list of all supported asset addresses.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return List of original asset addresses.
     * @return List of asset config structures.
     */
    function supportedAssets(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory, Assets.AssetConfig[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IContractRegistry {
    /**
     * @dev Thrown when the contract with a provided key does not exist.
     */
    error InvalidContractEntityInterface();

    /**
     * @dev Thrown when the contract with a provided key does not exist.
     */
    error ContractKeyMismatch(bytes4 keyProvided, bytes4 keyRequired);

    /**
     * @dev Thrown when the contract with a provided key does not exist.
     */
    error ContractNotAuthorized(bytes4 keyProvided, address addressProvided);

    /**
     * @dev Thrown when the contract with a provided key does not exist.
     */
    error ContractDoesNotExist(bytes4 keyProvided);

    /**
     * @dev Emitted when the new contract is registered.
     * @param contractKey Key of the contract.
     * @param contractAddress Address of the contract.
     */
    event ContractRegistered(bytes4 contractKey, address contractAddress);

    /**
     * @dev Register new contract with a key.
     * @param contractKey Key of the contract.
     * @param contractAddress Address of the contract.
     */
    function registerContract(bytes4 contractKey, address contractAddress) external;

    /**
     * @dev Get contract address with a key.
     * @param contractKey Key of the contract.
     * @return Contract address.
     */
    function getContract(bytes4 contractKey) external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.0;

import "./EnumerableSetUpgradeable.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an array of EnumerableMap.
 * ====
 */
library EnumerableMapUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSetUpgradeable.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function get(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), errorMessage);
        return value;
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToUintMap storage map,
        uint256 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToUintMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key), errorMessage));
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key), errorMessage))));
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        AddressToUintMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key))), errorMessage));
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToUintMap storage map,
        bytes32 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        Bytes32ToUintMap storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, key, errorMessage));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../listing-terms-registry/IListingTermsRegistry.sol";

library ListingStrategies {
    bytes4 public constant FIXED_RATE = bytes4(keccak256("FIXED_RATE"));
    bytes4 public constant FIXED_RATE_WITH_REWARD = bytes4(keccak256("FIXED_RATE_WITH_REWARD"));

    /**
     * @dev Thrown when the listing strategy ID does not match the required one.
     * @param provided Provided listing strategy ID.
     * @param required Required listing strategy ID.
     */
    error ListingStrategyMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Modifier to check strategy compatibility.
     */
    modifier compatibleStrategy(bytes4 checkedStrategyId, bytes4 expectedStrategyId) {
        if (checkedStrategyId != expectedStrategyId)
            revert ListingStrategyMismatch(checkedStrategyId, expectedStrategyId);
        _;
    }

    function getSupportedListingStrategyIDs() internal pure returns (bytes4[] memory supportedListingStrategyIDs) {
        bytes4[] memory supportedListingStrategies = new bytes4[](2);
        supportedListingStrategies[0] = FIXED_RATE;
        supportedListingStrategies[1] = FIXED_RATE_WITH_REWARD;
        return supportedListingStrategies;
    }

    function isValidListingStrategy(bytes4 listingStrategyId) internal pure returns (bool) {
        return listingStrategyId == FIXED_RATE || listingStrategyId == FIXED_RATE_WITH_REWARD;
    }

    function decodeFixedRateListingStrategyParams(IListingTermsRegistry.ListingTerms memory terms)
        internal
        pure
        compatibleStrategy(terms.strategyId, FIXED_RATE)
        returns (uint256 baseRate)
    {
        return abi.decode(terms.strategyData, (uint256));
    }

    function decodeFixedRateWithRewardListingStrategyParams(IListingTermsRegistry.ListingTerms memory terms)
        internal
        pure
        compatibleStrategy(terms.strategyId, FIXED_RATE_WITH_REWARD)
        returns (uint256 baseRate, uint16 rewardPercentage)
    {
        return abi.decode(terms.strategyData, (uint256, uint16));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../IListingController.sol";

interface IFixedRateWithRewardListingController is IListingController {
    /**
     * @dev Decodes listing terms data.
     * @param terms Encoded listing terms.
     * @return baseRate Asset renting base rate (base tokens per second).
     * @return rewardPercentage Asset renting base reward percentage rate.
     */
    function decodeStrategyParams(IListingTermsRegistry.ListingTerms memory terms)
        external
        pure
        returns (uint256 baseRate, uint16 rewardPercentage);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../ITaxController.sol";

interface IFixedRateWithRewardTaxController is ITaxController {
    /**
     * @dev Decodes tax terms data.
     * @param terms Encoded tax terms.
     * @return baseTaxRate Asset renting base tax (base rate per rental).
     * @return rewardTaxRate Asset renting reward base tax (base rate per reward).
     */
    function decodeStrategyParams(ITaxTermsRegistry.TaxTerms memory terms)
        external
        pure
        returns (uint16 baseTaxRate, uint16 rewardTaxRate);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IDelegatedAccessControl.sol";

// solhint-disable max-line-length
interface IDelegatedAccessControlEnumerable is IDelegatedAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(
        address delegate,
        string calldata role,
        uint256 index
    ) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(address delegate, string calldata role) external view returns (uint256);

    /**
     * @dev Returns list of delegates where account has any role
     */
    function getDelegates(
        address account,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory delegates, uint256 total);

    /**
     * @dev Returns list of roles for `account` at `delegate`
     */
    function getDelegateRoles(
        address account,
        address delegate,
        uint256 offset,
        uint256 limit
    ) external view returns (string[] memory roles, uint256 total);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "../listing-terms-registry/IListingTermsRegistry.sol";
import "../../asset/Assets.sol";
import "../Listings.sol";
import "../../renting/Rentings.sol";

interface IListingConfiguratorController is IERC165 {
    error ListingTermsNotFound(IListingTermsRegistry.ListingTerms listingTerms);

    function validateListing(
        Assets.Asset[] calldata assets,
        Listings.Params calldata params,
        uint32 maxLockPeriod,
        bool immediatePayout
    ) external view;

    function validateRenting(
        Rentings.Params calldata params,
        Listings.Listing calldata listing,
        uint256 universeId
    ) external view;

    function getERC20RewardTarget(Listings.Listing calldata listing) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IDelegatedAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DELEGATED_ADMIN` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        address indexed delegate,
        string indexed role,
        string previousAdminRole,
        string indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {DelegatedAccessControl-_setupRole}.
     */
    event RoleGranted(address indexed delegate, string indexed role, address indexed account, address sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(address indexed delegate, string indexed role, address indexed account, address sender);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(
        address delegate,
        string calldata role,
        address account
    ) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(
        address delegate,
        string calldata role,
        address account
    ) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(
        address delegate,
        string calldata role,
        address account
    ) external;

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        address delegate,
        string calldata role,
        address account
    ) external view returns (bool);

    /**
     * @notice revert if the `account` does not have the specified role.
     * @param delegate delegate to check
     * @param role the role specifier.
     * @param account the address to check the role for.
     */
    function checkRole(
        address delegate,
        string calldata role,
        address account
    ) external view;

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(address delegate, string calldata role) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../tax-terms-registry/ITaxTermsRegistry.sol";

library TaxStrategies {
    bytes4 public constant FIXED_RATE_TAX = bytes4(keccak256("FIXED_RATE_TAX"));
    bytes4 public constant FIXED_RATE_TAX_WITH_REWARD = bytes4(keccak256("FIXED_RATE_TAX_WITH_REWARD"));

    /**
     * @dev Thrown when the listing tax strategy ID does not match the required one.
     * @param provided Provided taxation strategy ID.
     * @param required Required taxation strategy ID.
     */
    error TaxStrategyMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Modifier to check strategy compatibility.
     */
    modifier compatibleStrategy(bytes4 checkedStrategyId, bytes4 expectedStrategyId) {
        if (checkedStrategyId != expectedStrategyId) revert TaxStrategyMismatch(checkedStrategyId, expectedStrategyId);
        _;
    }

    function getSupportedTaxStrategyIDs() internal pure returns (bytes4[] memory supportedTaxStrategyIDs) {
        bytes4[] memory supportedTaxStrategies = new bytes4[](2);
        supportedTaxStrategies[0] = FIXED_RATE_TAX;
        supportedTaxStrategies[1] = FIXED_RATE_TAX_WITH_REWARD;
        return supportedTaxStrategies;
    }

    function isValidTaxStrategy(bytes4 taxStrategyId) internal pure returns (bool) {
        return taxStrategyId == FIXED_RATE_TAX || taxStrategyId == FIXED_RATE_TAX_WITH_REWARD;
    }

    function decodeFixedRateTaxStrategyParams(ITaxTermsRegistry.TaxTerms memory terms)
        internal
        pure
        compatibleStrategy(terms.strategyId, FIXED_RATE_TAX)
        returns (uint16 baseTaxRate)
    {
        return abi.decode(terms.strategyData, (uint16));
    }

    function decodeFixedRateWithRewardTaxStrategyParams(ITaxTermsRegistry.TaxTerms memory terms)
        internal
        pure
        compatibleStrategy(terms.strategyId, FIXED_RATE_TAX_WITH_REWARD)
        returns (uint16 baseTaxRate, uint16 rewardTaxRate)
    {
        return abi.decode(terms.strategyData, (uint16, uint16));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "../../contract-registry/IContractEntity.sol";
import "../tax-terms-registry/ITaxTermsRegistry.sol";
import "../../renting/Rentings.sol";

interface ITaxController is IERC165, IContractEntity {
    /**
     * @dev Calculates rental tax based on renting params and implemented taxation strategy.
     * @param taxTermsParams Listing tax strategy override params.
     * @param rentingParams Renting params.
     * @param taxableAmount Total taxable amount.
     * @return universeBaseTax Universe rental tax (taxableAmount * universeBaseTax / 100%).
     * @return protocolBaseTax Protocol rental tax (taxableAmount * protocolBaseTax / 100%).
     * @return universeTaxTerms Universe tax terms.
     * @return protocolTaxTerms Protocol tax terms.
     */
    function calculateRentalTax(
        ITaxTermsRegistry.Params calldata taxTermsParams,
        Rentings.Params calldata rentingParams,
        uint256 taxableAmount
    )
        external
        view
        returns (
            uint256 universeBaseTax,
            uint256 protocolBaseTax,
            ITaxTermsRegistry.TaxTerms memory universeTaxTerms,
            ITaxTermsRegistry.TaxTerms memory protocolTaxTerms
        );

    /**
     * @dev Returns implemented listing tax strategy ID.
     * @return Taxation strategy ID.
     */
    function strategyId() external pure returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlEnumerableUpgradeable.sol";
import "../../contract-registry/IContractEntity.sol";

/**
 * @title Access Control List contract interface.
 */
interface IACL is IAccessControlEnumerableUpgradeable, IContractEntity {
    /**
     * @dev Thrown when the Admin roles bytes is incorrectly formatted.
     */
    error RolesContractIncorrectlyConfigured();

    /**
     * @dev Thrown when the attempting to remove the very last admin from ACL.
     */
    error CannotRemoveLastAdmin();

    /**
     * @notice revert if the `account` does not have the specified role.
     * @param role the role specifier.
     * @param account the address to check the role for.
     */
    function checkRole(bytes32 role, address account) external view;

    /**
     * @notice Get the admin role describing bytes
     * return role bytes
     */
    function adminRole() external pure returns (bytes32);

    /**
     * @notice Get the supervisor role describing bytes
     * return role bytes
     */
    function supervisorRole() external pure returns (bytes32);

    /**
     * @notice Get the listing wizard role describing bytes
     * return role bytes
     */
    function listingWizardRole() external pure returns (bytes32);

    /**
     * @notice Get the universe wizard role describing bytes
     * return role bytes
     */
    function universeWizardRole() external pure returns (bytes32);

    /**
     * @notice Get the token quote signer role describing bytes
     * return role bytes
     */
    function tokenQuoteSignerRole() external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title Different role definitions used by the ACL contract.
 */
library Roles {
    /**
     * @dev This maps directly to the OpenZeppelins AccessControl DEFAULT_ADMIN
     */
    bytes32 public constant ADMIN = 0x00;
    bytes32 public constant SUPERVISOR = keccak256("SUPERVISOR_ROLE");
    bytes32 public constant LISTING_WIZARD = keccak256("LISTING_WIZARD_ROLE");
    bytes32 public constant UNIVERSE_WIZARD = keccak256("UNIVERSE_WIZARD_ROLE");
    bytes32 public constant WARPER_WIZARD = keccak256("WARPER_WIZARD_ROLE");
    bytes32 public constant TOKEN_QUOTE_SIGNER = keccak256("TOKEN_QUOTE_SIGNER_ROLE");

    string public constant DELEGATED_ADMIN = "DELEGATED_ADMIN";
    string public constant DELEGATED_MANAGER = "DELEGATED_MANAGER";
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}