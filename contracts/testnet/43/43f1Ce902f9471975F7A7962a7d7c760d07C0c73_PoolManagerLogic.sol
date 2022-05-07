// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "./../interfaces/IPoolFactory.sol";
import "./../interfaces/IPoolManagerLogic.sol";
import "./../interfaces/ISupportedAsset.sol";
import "./../interfaces/IERC20Extended.sol";
import "./../interfaces/IFeeManage.sol";
import "./PoolMember.sol";

contract PoolManagerLogic is Initializable, IPoolManagerLogic, ISupportedAsset, IFeeManage, PoolMember {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    event AssetAdded(address indexed pool, address manager, address asset);
    event AssetRemoved(address pool, address manager, address asset);
    event PoolLogicSet(address poolLogic);
    event FeeChanged(address manager, uint256 feeType, uint256 from, uint256 to, address recipient);

    address public factory;
    address public override poolLogic;
    address public manager;

    address[] public supportedAssets;
    mapping(address => uint256) public assetPosition; // 1-based position
    address public denominationAsset;

    uint256 public override performanceFee;
    uint256 public managementFee;
    uint256 public entryFee;
    uint256 public exitSpecificFee;
    uint256 public exitShareInKindFee;
    mapping(uint256 => address) public recipients;

    struct AssetHolding {
        address asset;
        uint256 amount;
        uint256 price;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "only manager");
        _;
    }

    function initialize(
        address _factory,
        address _manager,
        address _denominationAsset,
        address[] calldata _assets,
        Fee[] calldata _fee
    ) external initializer {
        require(_factory != address(0), "invalid factory");
        require(_manager != address(0), "invalid manager");
        require(_denominationAsset != address(0), "invalid denominationAsset");

        manager = _manager;
        factory = _factory;
        denominationAsset = _denominationAsset;
        _setupFee(_fee);
        _changeAssets(_assets, new address[](0));

        require(assetPosition[denominationAsset] != 0, "no deposit asset in support");
    }

    function setPoolLogic(address _poolLogic) external {
        require(_poolLogic != address(0), "invalid poolLogic");
        require(msg.sender != IPoolFactory(factory).getOwner(), "only factory owner");

        poolLogic = _poolLogic;
        emit PoolLogicSet(poolLogic);
    }

    function getSupportedAssets() external view override returns (address[] memory) {
        return supportedAssets;
    }

    function isValidAsset(address _asset) internal view returns (bool) {
        return IPoolFactory(factory).isValidAsset(_asset);
    }

    function totalPoolValue() public view override returns (uint256) {
        uint256 total = 0;
        uint256 assetCount = supportedAssets.length;

        for (uint256 i = 0; i < assetCount; i++) {
            address asset = supportedAssets[i];
            uint256 totalBalance = IERC20Upgradeable(asset).balanceOf(poolLogic);
            total = total.add(getAssetValue(asset, totalBalance));
        }
        return total;
    }

    function isSupportedAsset(address _asset) public view override returns (bool) {
        return assetPosition[_asset] != 0;
    }

    function getAssetValue(address asset, uint256 amount) public view override returns (uint256) {
        uint256 price = IPoolFactory(factory).getAssetPrice(asset);
        uint256 decimals = IERC20Extended(asset).decimals();

        return price.mul(amount).div(10**decimals);
    }

    /// @dev get asset holding
    function getAssetHolding() public view returns (AssetHolding[] memory) {
        uint256 index = 0;
        address[] memory assets = supportedAssets;
        uint256 assetCount = assets.length;
        AssetHolding[] memory assetHolding = new AssetHolding[](assetCount);
        for (uint256 i = 0; i < assetCount; i++) {
            uint256 balance = IERC20Upgradeable(assets[i]).balanceOf(poolLogic);
            if (balance != 0) {
                uint256 assetPrice = getAssetValue(assets[i], 10**18);
                assetHolding[index] = AssetHolding(assets[i], balance, assetPrice);
                index = index.add(1);
            }
        }

        // Reduce length for assetHolding to remove the empty items
        uint256 reduceLength = assetCount.sub(index);
        assembly {
            mstore(assetHolding, sub(mload(assetHolding), reduceLength))
        }
        return assetHolding;
    }

    function setPerformanceFee(uint256 feeRate, address recipient) public onlyManager {
        _changeFee(Fee(uint256(IFeeManage.FeeType.TYPE_FEE_PERFORMANCE), feeRate, recipient));
    }

    function _setupFee(Fee[] calldata _fee) internal {
        for (uint256 i = 0; i < _fee.length; i++) {
            _changeFee(_fee[i]);
        }
    }

    /// @dev change fee in pool - based on 100%(10000)
    function _changeFee(Fee memory _fee) internal {
        uint256 feeType = _fee.feeType;
        require(_fee.feeRate < 10000, "cannot set over 10000(100%)");
        if (_fee.feeRate > 0) {
            require(_fee.recipient != address(0), "invalid recipient address");
        }

        uint256 oldFee;
        if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_PERFORMANCE)) {
            oldFee = performanceFee;
            performanceFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_MANAGEMENT)) {
            oldFee = managementFee;
            managementFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_ENTRY)) {
            oldFee = entryFee;
            entryFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_EXIT_SPECIFIC)) {
            oldFee = exitSpecificFee;
            exitSpecificFee = _fee.feeRate;
        } else if (feeType == uint256(IFeeManage.FeeType.TYPE_FEE_EXIT_SHARE_IN_KIND)) {
            oldFee = exitShareInKindFee;
            exitShareInKindFee = _fee.feeRate;
        } else {
            revert("invalid fee type");
        }

        recipients[feeType] = _fee.recipient;

        emit FeeChanged(manager, feeType, oldFee, _fee.feeRate, _fee.recipient);
    }

    function availablePerformanceFee(uint256 _sharePriceLatest)
        external
        view
        returns (
            uint256 sharePriceLatest,
            uint256 managerFee,
            uint256 systemFee
        )
    {
        uint256 totalShare = IERC20Upgradeable(poolLogic).totalSupply();
        if (performanceFee == 0 || _sharePriceLatest == 0 || totalShare == 0) {
            return (0, 0, 0);
        }
        uint256 totalValueBefore = _sharePriceLatest.mul(totalShare).div(10**18);
        uint256 totalValueAfter = totalPoolValue();

        // calculate profit
        if (totalValueAfter > totalValueBefore) {
            uint256 profit = totalValueAfter.sub(totalValueBefore);

            uint256 managerFeeValue = profit.mul(performanceFee).div(10000);
            uint256 systemFeeValue = managerFeeValue.div(10);

            // calculate latest share price
            sharePriceLatest = totalValueAfter.sub(managerFeeValue).mul(10**18).div(totalShare);

            // calculate and update number unit
            managerFee = (managerFeeValue.sub(systemFeeValue)).mul(10**18).div(sharePriceLatest);
            systemFee = systemFeeValue.mul(10**18).div(sharePriceLatest);
        }
    }

    function getRecipientWithdrawal(uint256 feeType) public view override returns (address) {
        return recipients[feeType];
    }

    function changeAssets(address[] calldata _addAssets, address[] calldata _removeAssets) external onlyManager {
        _changeAssets(_addAssets, _removeAssets);
    }

    function _changeAssets(address[] calldata _addAssets, address[] memory _removeAssets) internal {
        for (uint8 i = 0; i < _removeAssets.length; i++) {
            _removeAsset(_removeAssets[i]);
        }

        for (uint8 i = 0; i < _addAssets.length; i++) {
            _addAsset(_addAssets[i]);
        }
    }

    function _addAsset(address _asset) internal {
        require(_asset != address(0), "invalid asset");
        require(isValidAsset(_asset), "invalid asset");
        require(poolLogic != _asset, "cannot add pool asset");

        if (assetPosition[_asset] == 0) {
            supportedAssets.push(_asset);
            assetPosition[_asset] = supportedAssets.length;
        }

        emit AssetAdded(address(this), manager, _asset);
    }

    function _removeAsset(address _asset) internal {
        require(assetPosition[_asset] != 0, "asset not supported");

        require(IERC20Upgradeable(_asset).balanceOf(poolLogic) == 0, "cannot remove non-empty asset");

        uint256 length = supportedAssets.length;
        address lastAsset = supportedAssets[length.sub(1)];
        uint256 index = assetPosition[_asset].sub(1);

        supportedAssets[index] = lastAsset;
        assetPosition[lastAsset] = index.add(1);
        assetPosition[_asset] = 0;

        supportedAssets.pop();

        emit AssetRemoved(address(this), manager, _asset);
    }
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
library SafeMathUpgradeable {
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
pragma solidity ^0.8.11;

interface IPoolFactory {
    function getOwner() external view returns (address);

    function pancakeswapRouter() external view returns (address);

    function WBNB() external view returns (address);

    function getProtocolFee() external view returns (uint256);

    function getProtocolPerformanceFee() external view returns (uint256);

    function isValidAsset(address asset) external view returns (bool);
    
    function getAssetPrice(address asset) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPoolManagerLogic {

    function poolLogic() external view returns (address);

    function denominationAsset() external view returns (address);

    function setPoolLogic(address _poolLogic) external;

    function totalPoolValue() external view returns (uint256);

    function getRecipientWithdrawal(uint256 feeType) external view returns (address);

    function getAssetValue(address asset, uint256 amount) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface ISupportedAsset {

    function getSupportedAssets() external view returns (address[] memory);

    function isSupportedAsset(address asset) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20Extended {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IFeeManage {
    enum FeeType {
        TYPE_FEE_PERFORMANCE,
        TYPE_FEE_MANAGEMENT,
        TYPE_FEE_ENTRY,
        TYPE_FEE_EXIT_SPECIFIC,
        TYPE_FEE_EXIT_SHARE_IN_KIND
    }

    struct Fee {
        uint256 feeType;
        uint256 feeRate;
        address recipient;
    }

    function performanceFee() external view returns (uint256);

    function availablePerformanceFee(uint256 _sharePriceLatest)
        external
        view
        returns (
            uint256 sharePriceLatest,
            uint256 managerFee,
            uint256 systemFee
        );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./../interfaces/IPoolMember.sol";

contract PoolMember is IPoolMember {
    using SafeMathUpgradeable for uint256;

    event InvestorAdded(address investor);
    event InvestorRemoved(address investor);

    address payable[] private investors;
    mapping(address => uint256) private indexOfInvestor; // map stores 1-based

    function initialize() external {}

    /// @dev list investor in pool
    function listInvestor() public view returns (address payable[] memory) {
        return investors;
    }

    /// @dev get total of Investor
    function getTotalInvestor() public view returns (uint256) {
        return investors.length;
    }

    /// @dev add investor
    function addMember(address _poolLogic,address _investor) public override {
        require(IERC20Upgradeable(_poolLogic).balanceOf(_investor) != 0, "no share");
        if (indexOfInvestor[_investor] == 0) {
            investors.push(payable(_investor));
            indexOfInvestor[_investor] = investors.length;

            emit InvestorAdded(_investor);
        }
    }

    /// @dev Move the last element to the deleted spot.
    /// @dev Remove the last element.
    function removeMember(address _poolLogic,address _investor) public override {
        uint256 length = investors.length;
        uint256 index = indexOfInvestor[_investor].sub(1);

        require(length > 0, "can't remove from empty array");
        require(index < length, "invalid index");
        require(IERC20Upgradeable(_poolLogic).balanceOf(_investor) == 0, "cannot remove investor");

        address lastInvestor = investors[length.sub(1)];

        investors[index] = payable(lastInvestor);
        indexOfInvestor[lastInvestor] = index.add(1);
        indexOfInvestor[_investor] = 0;

        investors.pop();
        emit InvestorRemoved(_investor);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPoolMember {
    function listInvestor() external view returns (address payable[] memory);

    function getTotalInvestor() external view returns (uint256);

    function addMember(address _poolLogic, address _investor) external;

    function removeMember(address _poolLogic, address _investor) external;
}