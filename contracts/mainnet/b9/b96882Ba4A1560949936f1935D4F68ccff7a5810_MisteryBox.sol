// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./oracles/random/VRFConsumerBaseV2Upgradeable.sol";
import "./controllers/SellControl.sol";
import "./interfaces/IResource.sol";
import "./interfaces/IArmor.sol";
import "./interfaces/IWeapon.sol";
import "./interfaces/IOraclePrices.sol";
import {SharedStructs} from "./libraries/SharedStructs.sol";
import "./libraries/RandomHelper.sol";

contract MisteryBox is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    VRFConsumerBaseV2Upgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IResource;

    struct RequestData {
        address to;
        uint256 tokenId;
        uint8 tier;
    }

    IResource public paymentToken;
    IOraclePrices oracle;
    uint256 public burnBP;
    uint256 public price;
    uint256 public supply;
    uint256 public amountOfResources;
    address public vaultMisteryBox;
    string public baseURI;
    uint16 totalRange;

    mapping(uint8 => SharedStructs.ArmorTierConfig) armorTierConfigMap;
    mapping(uint8 => SharedStructs.WeaponTierConfig) weaponTierConfigMap;
    mapping(uint256 => RequestData) randomRequestMap;

    event ResourceGenerated(
        address indexed to,
        address resource,
        uint256 amountOfResources
    );
    event WeaponGenerated(address indexed to, address weapon);
    event ArmorGenerated(address indexed to, address armor);

    constructor() initializer {}

    function initialize(
        IResource _paymentToken,
        IOraclePrices _oracle,
        address _vaultMisteryBox,
        address _vrfCoordinator,
        uint64 _subscriptionId,
        address _link,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    ) public initializer {
        __Ownable_init();
        __Pausable_init();
        __VRFConsumerBaseV2_init(
            _vrfCoordinator,
            _subscriptionId,
            _link,
            _keyHash,
            _callbackGasLimit,
            _requestConfirmations,
            _numWords
        );
        paymentToken = _paymentToken;
        oracle = _oracle;
        vaultMisteryBox = _vaultMisteryBox;
        burnBP = 2500;
        price = 3 * 1e18;
        amountOfResources = 500 * 1e18;
        totalRange = 20000;
        supply = 100000;
        baseURI = "https://outerringmmo.mypinata.cloud/ipfs/QmdYtywpTuWNBW3b4xC7f9HCHB1Ps1zt9bffkLcYjj3kg6/";
        pause();
    }

    /// @notice Function to set the URI base for the metadata
    /// @param _baseURI String with the URI to metadata
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    /// @notice This function changes the payment token
    /// @param newPaymentToken The new payment token
    function changePaymentToken(IResource newPaymentToken) external onlyOwner {
        paymentToken = newPaymentToken;
    }

    /// @notice This function updates the oracle address
    /// @param newOracle The new oracle address
    function updateOracle(IOraclePrices newOracle) external onlyOwner {
        oracle = newOracle;
    }

    /// @notice This function updates the vault address
    /// @param newVault The new discount value
    function updateVault(address newVault) external onlyOwner {
        vaultMisteryBox = newVault;
    }

    /// @notice This function updates the burn basis points
    /// @param newBurnBP The new burn basis points
    function updateBurnBP(uint256 newBurnBP) external onlyOwner {
        burnBP = newBurnBP;
    }

    function createArmorConfig(
        uint8 _index,
        address _armorAddress,
        uint8 _armorQuantity,
        uint8 _armorTierId,
        uint8 _armorRarityId,
        string memory _armorRarityName,
        uint8 _collectionId,
        string memory _collectionName
    ) external onlyOwner {
        armorTierConfigMap[_index] = SharedStructs.ArmorTierConfig(
            _armorAddress,
            _armorQuantity,
            _armorTierId,
            _armorRarityId,
            _armorRarityName,
            _collectionId,
            _collectionName
        );
    }

    function createWeaponConfig(
        uint8 _index,
        address _weaponAddress,
        uint8 _weaponQuantity,
        uint8 _weaponTierId,
        uint8 _weaponRarityId,
        string memory _weaponRarityName,
        uint8 _collectionId,
        string memory _collectionName
    ) external onlyOwner {
        weaponTierConfigMap[_index] = SharedStructs.WeaponTierConfig(
            _weaponAddress,
            _weaponQuantity,
            _weaponTierId,
            _weaponRarityId,
            _weaponRarityName,
            _collectionId,
            _collectionName
        );
    }

    /// @notice Function to pause the contract
    function pause() public onlyOwner {
        _pause();
    }

    /// @notice Function to unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }

    /// @notice Function used to buy mistery box
    function buyMisteryBox() external whenNotPaused {
        require(msg.sender == tx.origin, "Only EOA");
        require(supply > 0, "Finished supply");
        _paymentWithToken();
        request = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        RequestData storage requestData = randomRequestMap[request];
        requestData.to = msg.sender;
        supply = supply - 1;
    }

    function _generateResource(address _to, uint16 _random) internal {
        address _resourceAddress = RandomHelper.getRangeForResources(_random);
        IResource(_resourceAddress).mint(_to, amountOfResources);
        emit ResourceGenerated(_to, _resourceAddress, amountOfResources);
    }

    function _generateObject(address _to, uint16 _random) internal {
        (uint8 itemType, uint8 _range) = RandomHelper.getRangeForItems(_random);
        require(itemType >= 0 && itemType <= 3, "Error with item types");
        string memory _tokenURI = string(
            abi.encodePacked(
                baseURI,
                StringsUpgradeable.toString(_random),
                ".json"
            )
        );
        if (itemType == 0) {
            SharedStructs.ArmorTierConfig
                memory armorConfig = armorTierConfigMap[_range];
            IArmor(armorConfig.armorAddress).misteryBoxMint(
                _to,
                _tokenURI,
                armorConfig
            );
            emit ArmorGenerated(_to, armorConfig.armorAddress);
        } else if (itemType > 0 && itemType <= 3) {
            SharedStructs.WeaponTierConfig
                memory weaponConfig = weaponTierConfigMap[_range];
            IWeapon(weaponConfig.weaponAddress).misteryBoxMint(
                _to,
                _tokenURI,
                weaponConfig
            );
            emit WeaponGenerated(_to, weaponConfig.weaponAddress);
        }
    }

    /// @notice This function is used for random generation is the callback of Chain Link
    /// @param _requestId Id of the request
    /// @param randomWords An array of random words returned by VRF
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory randomWords
    ) internal override {
        RequestData memory requestData = randomRequestMap[_requestId];
        uint16 _random = uint16(randomWords[0] % totalRange);
        if (_random > 4399) {
            _generateResource(requestData.to, _random);
        } else {
            _generateObject(requestData.to, _random);
        }
    }

    /// @notice This function makes the payment in other token
    function _paymentWithToken() internal {
        uint256 amountInToken = oracle.getAmountsOutByBUSD(
            price,
            address(paymentToken)
        );
        uint256 amountToBurn = (amountInToken * burnBP) / 10000;
        uint256 amountToSend = amountInToken - amountToBurn;
        paymentToken.safeTransferFrom(
            msg.sender,
            vaultMisteryBox,
            amountToSend
        );
        paymentToken.safeTransferFrom(msg.sender, address(this), amountToBurn);
        paymentToken.burn(amountToBurn);
    }
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
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract VRFConsumerBaseV2Upgradeable is Initializable, OwnableUpgradeable {
    error OnlyCoordinatorCanFulfill(address have, address want);

    // Chainlink data
    VRFCoordinatorV2Interface internal COORDINATOR;
    LinkTokenInterface internal LINKTOKEN;
    address internal vrfCoordinator;
    address internal link;
    bytes32 internal keyHash;
    uint16 internal requestConfirmations;
    uint32 internal callbackGasLimit;
    uint32 internal numWords;
    uint64 internal subscriptionId;
    uint256 internal request;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __VRFConsumerBaseV2_init(
        address _vrfCoordinator,
        uint64 _subscriptionId,
        address _link,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    ) internal onlyInitializing {
        __VRFConsumerBaseV2_init_unchained(
            _vrfCoordinator,
            _subscriptionId,
            _link,
            _keyHash,
            _callbackGasLimit,
            _requestConfirmations,
            _numWords
        );
    }

    function __VRFConsumerBaseV2_init_unchained(
        address _vrfCoordinator,
        uint64 _subscriptionId,
        address _link,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    ) internal onlyInitializing {
        __Ownable_init();
        subscriptionId = _subscriptionId;
        link = _link;
        keyHash = _keyHash;
        requestConfirmations = _requestConfirmations;
        callbackGasLimit = _callbackGasLimit;
        numWords = _numWords;
        vrfCoordinator = _vrfCoordinator;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
    }

    /**
     * @notice fulfillRandomness handles the VRF response. Your contract must
     * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
     * @notice principles to keep in mind when implementing your fulfillRandomness
     * @notice method.
     *
     * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
     * @dev signature, and will call it once it has verified the proof
     * @dev associated with the randomness. (It is triggered via a call to
     * @dev rawFulfillRandomness, below.)
     *
     * @param requestId The Id initially returned by requestRandomness
     * @param randomWords the VRF output expanded to the requested number of words
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual
    {}

    // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    // the origin of the call
    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }

    function changeCoordinator(address _vrfCoordinator) external onlyOwner {
        vrfCoordinator = _vrfCoordinator;
    }

    function changeCallbackGasLimit(uint32 _callbackGasLimit)
        external
        onlyOwner
    {
        callbackGasLimit = _callbackGasLimit;
    }

    function changeSubscriptionId(uint64 _subscriptionId) external onlyOwner {
        subscriptionId = _subscriptionId;
    }

    function changeRequestConfirmations(uint16 _requestConfirmations)
        external
        onlyOwner
    {
        requestConfirmations = _requestConfirmations;
    }

    function changeKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash = _keyHash;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @title Module for sell and price control
contract SellControl is Initializable, OwnableUpgradeable {
    struct SellLimitRound {
        uint256 roundDuration;
        uint256 amountMaxPerRound;
        mapping(address => uint256) purchased;
    }

    SellLimitRound[] public sellLimitRoundList;
    uint256 public sellLimitStartTimestamp;

    mapping(uint8 => uint256) public purchasesByTier;
    mapping(uint8 => uint256) public maxSupplyByTier;

    /// @dev Initializes the contract
    function __SellControl_init() internal onlyInitializing {
        __SellControl_init_unchained();
    }

    function __SellControl_init_unchained() internal onlyInitializing {
        __Ownable_init();
        maxSupplyByTier[1] = 50000;
        maxSupplyByTier[2] = 15000;
        maxSupplyByTier[3] = 7500;
        maxSupplyByTier[4] = 5000;
        maxSupplyByTier[5] = 2500;
        maxSupplyByTier[6] = 500;
    }

    /// @notice This function is used to modify max supply for a tier if it is needed
    /// @param supply The new supply limit for the tier
    function modifyMaxTierSupply(uint8 tier, uint256 supply)
        external
        onlyOwner
    {
        maxSupplyByTier[tier] = supply;
    }

    /// @notice This function controls if tier supply is reached and if not, increment counter
    function _checkAndControlSupply(uint8 tier) internal {
        require(
            purchasesByTier[tier] + 1 <= maxSupplyByTier[tier],
            "Purchase limit reached"
        );
        purchasesByTier[tier] = purchasesByTier[tier] + 1;
    }

    /// @notice This function creates a sell control round to limit buys
    /// @param _sellLimitStartTimestamp this value determines the start timestamp
    /// @param roundDurations this value contains an array of durations for the rounds in seconds
    /// @param amountsMax this values contains an array of amounts limit for round
    function createSellControlRound(
        uint256 _sellLimitStartTimestamp,
        uint256[] calldata roundDurations,
        uint256[] calldata amountsMax
    ) external onlyOwner {
        require(_sellLimitStartTimestamp > 0, "Invalid start timestamp");
        require(roundDurations.length == amountsMax.length, "Invalid config");
        if (roundDurations.length > 0) {
            delete sellLimitRoundList;

            sellLimitStartTimestamp = _sellLimitStartTimestamp;

            for (uint256 i = 0; i < roundDurations.length; i++) {
                SellLimitRound storage sellLimitRound = sellLimitRoundList
                    .push();
                sellLimitRound.roundDuration = roundDurations[i];
                sellLimitRound.amountMaxPerRound = amountsMax[i];
            }
        }
    }

    /// @notice This function modify the sell control round by index
    /// @param index this value indicates the round to change
    /// @param roundDuration this value sets the duration for the round in seconds
    /// @param amountMaxPerRound this value sets the amount limit for round
    function modifySellControlRound(
        uint256 index,
        uint256 roundDuration,
        uint256 amountMaxPerRound
    ) external onlyOwner {
        require(index < sellLimitRoundList.length, "Invalid index");
        sellLimitRoundList[index].roundDuration = roundDuration;
        sellLimitRoundList[index].amountMaxPerRound = amountMaxPerRound;
    }

    /// @notice This function returns a view of the sell control round at this moment
    /// @return round number
    /// @return round duration
    /// @return close timestamp
    /// @return max amount per round
    function getSellControlRound()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (sellLimitStartTimestamp > 0) {
            uint256 sellLimitCloseTimestamp = sellLimitStartTimestamp;

            for (uint256 i = 0; i < sellLimitRoundList.length; i++) {
                SellLimitRound storage sellLimitRound = sellLimitRoundList[i];

                sellLimitCloseTimestamp =
                    sellLimitCloseTimestamp +
                    sellLimitRound.roundDuration;
                if (block.timestamp <= sellLimitCloseTimestamp)
                    return (
                        i + 1,
                        sellLimitRound.roundDuration,
                        sellLimitCloseTimestamp,
                        sellLimitRound.amountMaxPerRound
                    );
            }
        }
        return (0, 0, 0, 0);
    }

    /// @notice This function controls purchases to prevent users from buying more than the established limit
    /// @param recipient destiny address
    /// @param amount amount to send
    function _useSellControlRound(address recipient, uint256 amount) internal {
        if (
            sellLimitRoundList.length == 0 ||
            block.timestamp < sellLimitStartTimestamp
        ) return;

        (uint256 roundNumber, , , ) = getSellControlRound();
        if (roundNumber > 0) {
            SellLimitRound storage sellLimitRound = sellLimitRoundList[
                roundNumber - 1
            ];
            uint256 amountRemaining = 0;
            if (
                sellLimitRound.amountMaxPerRound >
                sellLimitRound.purchased[recipient]
            ) {
                unchecked {
                    amountRemaining =
                        sellLimitRound.amountMaxPerRound -
                        sellLimitRound.purchased[recipient];
                }
            }
            require(amount <= amountRemaining, "Amount exceeds maximum");
            sellLimitRound.purchased[recipient] =
                sellLimitRound.purchased[recipient] +
                amount;
        }
    }

    /// @notice This function returns the remaining boxes for a tier
    /// @param tier Tier to check
    function getRemainingSupplyByTier(uint8 tier)
        public
        view
        returns (uint256)
    {
        return maxSupplyByTier[tier] - purchasesByTier[tier];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IResource is IERC20Upgradeable {
    function mint(address to, uint256 amount) external;

    function burn(uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import {SharedStructs} from "../libraries/SharedStructs.sol";

interface IArmor is IERC721Upgradeable {
    function lootBoxMint(
        address to,
        uint8 tier,
        uint8 piece,
        SharedStructs.ArmorTierConfig memory _armorTierConfig
    ) external;

    function misteryBoxMint(
        address _to,
        string memory _uri,
        SharedStructs.ArmorTierConfig memory _armorTierConfig
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import {SharedStructs} from "../libraries/SharedStructs.sol";

interface IWeapon is IERC721Upgradeable {
    function lootBoxMint(
        address to,
        uint8 tier,
        SharedStructs.WeaponTierConfig memory _weaponTierConfig
    ) external;

    function misteryBoxMint(
        address _to,
        string memory _uri,
        SharedStructs.WeaponTierConfig memory _weaponTierConfig
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IOraclePrices {
    function getAmountsOutByBUSD(uint256 amountInBusd, address tokenOut)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SharedStructs {
    struct RequestData {
        uint256 tokenId;
        uint8 tier;
    }

    struct RangesByTier {
        uint16 minRange;
        uint16 maxRange;
    }

    struct ExoTierConfig {
        address exoCreditAddress;
        uint8 exoQuantity;
    }
    struct ArmorTierConfig {
        address armorAddress;
        uint8 armorQuantity;
        uint8 armorTierId;
        uint8 armorRarityId;
        string armorRarityName;
        uint8 collectionId;
        string collectionName;
    }

    struct WeaponTierConfig {
        address weaponAddress;
        uint8 weaponQuantity;
        uint8 weaponTierId;
        uint8 weaponRarityId;
        string weaponRarityName;
        uint8 collectionId;
        string collectionName;
    }

    struct LandVehicleTierConfig {
        address landVehicleAddress;
        uint8 landVehicleTypeId;
        string landVehicleTypeName;
        uint8 landVehicleQuantity;
        uint8 collectionId;
        string collectionName;
    }

    struct SpaceVehicleTierConfig {
        address spaceVehicleAddress;
        uint8 spaceVehicleTypeId;
        string spaceVehicleTypeName;
        uint8 spaceVehicleQuantity;
        uint8 collectionId;
        string collectionName;
    }

    struct ExoInfo {
        uint256 value;
        address firstOwner;
    }

    struct ItemInfo {
        uint8 tier;
        uint8 rarityId;
        string rarityName;
        uint8 collectionId;
        string collectionName;
        address firstOwner;
        uint8 piece;
    }

    struct VechicleInfo {
        uint8 typeId;
        string typeName;
        uint8 collectionId;
        string collectionName;
        address firstOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library RandomHelper {
    function getRangeForResources(uint256 _randomNumber)
        internal
        pure
        returns (address resourceAddress)
    {
        if (_randomNumber >= 4400 && _randomNumber <= 7519) {
            return 0xbD1945Cd85A2BE93a6475381c9F5EDF19407A921;
        }
        if (_randomNumber > 7519 && _randomNumber <= 10639) {
            return 0x892F23E32B82EF0d5394cF33dcD4dFf7f4b274B0;
        }
        if (_randomNumber > 10639 && _randomNumber <= 13759) {
            return 0x1d006868aFBb97196A7F859605845B957c64b164;
        }
        if (_randomNumber > 13759 && _randomNumber <= 16099) {
            return 0x253B7A24003684F7b4Fe87e531A017C7382A3894;
        }
        if (_randomNumber > 16099 && _randomNumber <= 18439) {
            return 0xf9A71CBA51E260E184a72D9EDF888d3f99F3baC1;
        }
        if (_randomNumber > 18439) {
            return 0x07958Be5D12365db62a6535D0a88105944a2E81E;
        }
    }

    function getRangeForItems(uint16 _randomNumber)
        internal
        pure
        returns (uint8 itemType, uint8 range)
    {
        if (_randomNumber <= 1499) {
            return (0, 0);
        }
        if (_randomNumber > 1499 && _randomNumber <= 2999) {
            return (1, 1);
        }
        if (_randomNumber > 2999 && _randomNumber <= 3999) {
            return (1, 2);
        }
        if (_randomNumber > 3999 && _randomNumber <= 4399) {
            return (1, 3);
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
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
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