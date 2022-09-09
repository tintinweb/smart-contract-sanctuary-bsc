// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ICloneFactory } from "../lib/CloneFactory.sol";
import { IDPPOracle } from "../interfaces/IDPPOracle.sol";
import { IDPPController } from "../interfaces/IDPPController.sol";
import { IDPPOracleAdmin } from "../interfaces/IDPPOracleAdmin.sol";
import "../lib/Adminable.sol";

contract DuetDPPFactory is Adminable, Initializable {
    // ============ default ============

    address public CLONE_FACTORY;
    address public WETH;
    address public dodoDefautMtFeeRateModel;
    address public dodoApproveProxy;
    address public dodoDefaultMaintainer;

    // ============ Templates ============

    address public dppTemplate;
    address public dppAdminTemplate;
    address public dppControllerTemplate;

    // ============registry and adminlist ==========

    // base->quote->dppController
    mapping(address => mapping(address => address)) public registry;
    // registry dppController
    mapping(address => address[]) public userRegistry;

    // ============ Events ============

    event NewDPP(address baseToken, address quoteToken, address creator, address dpp, address dppController);

    function initialize(
        address admin_,
        address cloneFactory_,
        address dppTemplate_,
        address dppAdminTemplate_,
        address dppControllerTemplate_,
        address defaultMaintainer_,
        address defaultMtFeeRateModel_,
        address dodoApproveProxy_,
        address weth_
    ) public initializer {
        _setAdmin(admin_);
        WETH = weth_;

        CLONE_FACTORY = cloneFactory_;
        dppTemplate = dppTemplate_;
        dppAdminTemplate = dppAdminTemplate_;
        dppControllerTemplate = dppControllerTemplate_;

        dodoDefaultMaintainer = defaultMaintainer_;
        dodoDefautMtFeeRateModel = defaultMtFeeRateModel_;
        dodoApproveProxy = dodoApproveProxy_;
    }

    // ============ Admin Operation Functions ============

    function updateDefaultMaintainer(address newMaintainer_) external onlyAdmin {
        dodoDefaultMaintainer = newMaintainer_;
    }

    function updateDefaultFeeModel(address newFeeModel_) external onlyAdmin {
        dodoDefautMtFeeRateModel = newFeeModel_;
    }

    function updateDodoApprove(address newDodoApprove_) external onlyAdmin {
        dodoApproveProxy = newDodoApprove_;
    }

    function updateDppTemplate(address newDPPTemplate_) external onlyAdmin {
        dppTemplate = newDPPTemplate_;
    }

    function updateAdminTemplate(address newDPPAdminTemplate_) external onlyAdmin {
        dppAdminTemplate = newDPPAdminTemplate_;
    }

    function updateControllerTemplate(address newController_) external onlyAdmin {
        dppControllerTemplate = newController_;
    }

    function delOnePool(
        address baseToken_,
        address quoteToken_,
        address dppCtrlAddress_,
        address creator_
    ) external onlyAdmin {
        registry[baseToken_][quoteToken_] = address(0);
        uint256 len = userRegistry[creator_].length;
        for (uint256 i = 0; i < len; ++i) {
            if (userRegistry[creator_][i] == dppCtrlAddress_) {
                userRegistry[creator_][i] = userRegistry[creator_][len - 1];
                userRegistry[creator_].pop();

                break;
            }
        }
    }

    // ============ Functions ============

    function _createDODOPrivatePool() internal returns (address newPrivatePool) {
        newPrivatePool = ICloneFactory(CLONE_FACTORY).clone(dppTemplate);
    }

    function _createDPPAdminModel() internal returns (address newDppAdminModel) {
        newDppAdminModel = ICloneFactory(CLONE_FACTORY).clone(dppAdminTemplate);
    }

    function createDPPController(
        address creator_, // dpp controller's admin and dppAdmin's operator
        address baseToken_,
        address quoteToken_,
        uint256 lpFeeRate_, // 单位是10**18，范围是[0,10**18] ，代表的是交易手续费
        uint256 k_, // adjust curve's type, limit in [0，10**18], 单位是 10**18，代表价格曲线波动系数 0是恒定价格卖币，10**18是类UNI的bonding curve
        uint256 i_, // 代表的是base 对 quote的价格比例.decimals 18 - baseTokenDecimals+ quoteTokenDecimals. If use oracle, i set here wouldn't be used.
        address o_, // oracle address
        bool isOpenTwap_, // use twap price or not
        bool isOracleEnabled_ // use oracle or not
    ) external onlyAdmin {
        require(
            registry[baseToken_][quoteToken_] == address(0) && registry[quoteToken_][baseToken_] == address(0),
            "HAVE CREATED"
        );
        address dppAddress;
        address dppController;
        {
            dppAddress = _createDODOPrivatePool();
            address dppAdminModel = _createDPPAdminModel();
            IDPPOracle(dppAddress).init(
                dppAdminModel,
                dodoDefaultMaintainer,
                baseToken_,
                quoteToken_,
                lpFeeRate_,
                dodoDefautMtFeeRateModel,
                k_,
                i_,
                o_,
                isOpenTwap_,
                isOracleEnabled_
            );

            dppController = _createDPPController(creator_, dppAddress, dppAdminModel);

            IDPPOracleAdmin(dppAdminModel).init(
                dppController, // owner
                dppAddress,
                dppController, // del dpp admin's operator
                dodoApproveProxy
            );
        }

        registry[baseToken_][quoteToken_] = dppController;
        userRegistry[creator_].push(dppController);
        emit NewDPP(baseToken_, quoteToken_, creator_, dppAddress, dppController);
    }

    function _createDPPController(
        address admin_,
        address dppAddress_,
        address dppAdminAddress_
    ) internal returns (address dppController) {
        dppController = ICloneFactory(CLONE_FACTORY).clone(dppControllerTemplate);
        IDPPController(dppController).init(admin_, dppAddress_, dppAdminAddress_, WETH);
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

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface ICloneFactory {
    function clone(address prototype) external returns (address proxy);
}

// introduction of proxy mode design: https://docs.openzeppelin.com/upgrades/2.8/
// minimum implementation of transparent proxy: https://eips.ethereum.org/EIPS/eip-1167

contract CloneFactory is ICloneFactory {
    function clone(address prototype) external override returns (address proxy) {
        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }
}

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IDPPOracle {
    function init(
        address owner,
        address maintainer,
        address baseTokenAddress,
        address quoteTokenAddress,
        uint256 lpFeeRate,
        address mtFeeRateModel,
        uint256 k,
        uint256 i,
        address o,
        bool isOpenTWAP,
        bool isOracleEnabled
    ) external;

    function _MT_FEE_RATE_MODEL_() external returns (address);

    function _O_() external returns (address);
}

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IDPPController {
    function init(
        address admin,
        address dppAddress,
        address dppAdminAddress,
        address weth
    ) external;
}

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IDPPOracleAdmin {
    function init(
        address owner,
        address dpp,
        address operator,
        address dodoApproveProxy
    ) external;

    //=========== admin ==========
    function ratioSync() external;

    function retrieve(
        address payable to,
        address token,
        uint256 amount
    ) external;

    function reset(
        address assetTo,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function tuneParameters(
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function tunePrice(
        uint256 newI,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function changeOracle(address newOracle) external;

    function enableOracle() external;

    function disableOracle(uint256 newI) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

abstract contract Adminable {
    event AdminUpdated(address indexed user, address indexed newAdmin);

    address public admin;

    modifier onlyAdmin() virtual {
        require(msg.sender == admin, "UNAUTHORIZED");

        _;
    }

    function setAdmin(address newAdmin) public virtual onlyAdmin {
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) internal {
        require(newAdmin != address(0), "Can not set admin to zero address");
        admin = newAdmin;

        emit AdminUpdated(msg.sender, newAdmin);
    }
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