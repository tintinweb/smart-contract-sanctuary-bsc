// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Waterpacks.sol";
import "./Fertilizers.sol";
import "./HandlerAwareUpgradeable.sol";

struct NodeAddonLog {
    uint256[] creationTime;
    string[] addonKind;
    string[] addonTypeName;
}

contract Addons is Initializable, HandlerAwareUpgradeable, Waterpacks, Fertilizers {
    mapping(uint256 => NodeAddonLog) internal nodeAddonLogs;

    function initialize(IHandler handler) public initializer {
        __HandlerAware_init(handler);
    }

    //====== Getters =========================================================//

    struct NodeAddonLogItemView {
        uint256 creationTime;
        string addonKind;
        string addonTypeName;
    }

    function getItemLogForNode(uint256 nodeId)
        public
        view
        returns (NodeAddonLogItemView[] memory)
    {
        NodeAddonLog memory log = nodeAddonLogs[nodeId];
        uint256 logLength = log.creationTime.length;
        NodeAddonLogItemView[] memory logItems = new NodeAddonLogItemView[](
            logLength
        );

        for (uint256 i = 0; i < logLength; i++) {
            logItems[i].creationTime = log.creationTime[i];
            logItems[i].addonKind = log.addonKind[i];
            logItems[i].addonTypeName = log.addonTypeName[i];
        }

        return logItems;
    }

    //====== Handler-only API ================================================//

    function setWaterpackType(
        string calldata name,
        uint256 ratioOfGRP,
        uint256[] calldata prices
    ) external onlyHandler {
        _setWaterpackType(name, ratioOfGRP, prices);
    }

    function setFertilizerType(
        string calldata name,
        uint256 durationEffect,
        uint256 rewardBoost,
        uint256[] calldata limits,
        uint256[] calldata prices
    ) external onlyHandler {
        _setFertilizerType(
            name,
            durationEffect,
            rewardBoost,
            limits,
            prices
        );
    }

    function removeFertilizerType(string calldata name)
        external
        onlyHandler
        returns (bool)
    {
        return _removeFertilizerType(name);
    }

    function logWaterpacks(
        uint256[] memory nodeTokenIds,
        string memory waterpackType,
        uint256 creationTime,
        uint256[] memory amounts
    ) external onlyHandler {
        require(
            nodeTokenIds.length == amounts.length,
            "Addons: Length mismatch"
        );
        for (uint256 i = 0; i < nodeTokenIds.length; i++) {
            for (uint256 j = 0; j < amounts[i]; j++) {
                _logAddon(
                    nodeTokenIds[i],
                    "Waterpack",
                    waterpackType,
                    creationTime
                );
            }
        }
    }

    function logFertilizers(
        uint256[] memory nodeTokenIds,
        string memory fertilizerType,
        uint256 creationTime,
        uint256[] memory amounts
    ) external onlyHandler {
        require(
            nodeTokenIds.length == amounts.length,
            "Addons: Length mismatch"
        );

        for (uint256 i = 0; i < nodeTokenIds.length; i++) {
            _applyFertilizer(
                fertilizerType,
                nodeTokenIds[i],
                amounts[i]
            );

            for (uint256 j = 0; j < amounts[i]; j++) {
                _logAddon(
                    nodeTokenIds[i],
                    "Fertilizer",
                    fertilizerType,
                    creationTime
                );
            }
        }
    }

    //====== Internal API =====================================================//

    function _logAddon(
        uint256 nodeTokenId,
        string memory addonKind,
        string memory addonTypeName,
        uint256 creationTime
    ) internal {
        nodeAddonLogs[nodeTokenId].creationTime.push(creationTime);
        nodeAddonLogs[nodeTokenId].addonKind.push(addonKind);
        nodeAddonLogs[nodeTokenId].addonTypeName.push(addonTypeName);

        assert(
            nodeAddonLogs[nodeTokenId].creationTime.length ==
                nodeAddonLogs[nodeTokenId].addonKind.length
        );

        assert(
            nodeAddonLogs[nodeTokenId].creationTime.length ==
                nodeAddonLogs[nodeTokenId].addonTypeName.length
        );
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./HandlerAwareUpgradeable.sol";

struct Waterpack {
    /// @dev How much lifetime is added to the node, expressed relative to the
    /// node's GRP time.
    uint256 ratioOfGRP;
}

abstract contract Waterpacks is HandlerAwareUpgradeable {
    struct WaterpackTypes {
        Waterpack[] items;
        string[] names;
        /// @dev Name to index + 1, 0 means the waterpack doesn't exists.
        mapping(string => uint256) indexOfPlusOne;
		mapping(string => mapping(string => uint256)) itemToNodeTypeToPrice;
    }

    WaterpackTypes internal waterpackTypes;

    //====== Getters =========================================================//

    function hasWaterpackType(string calldata name)
        external
        view
        returns (bool)
    {
        return _hasWaterpackType(name);
    }

	function getWaterpackType(string calldata name)
		external
		view
		returns (Waterpack memory)
	{
		return _getWaterpackType(name);
	}

	function getWaterpackPriceByNameAndNodeType(
		string calldata name,
		string calldata nodeType
	)
		external
		view
		returns (uint256)
	{
		require(_hasWaterpackType(name), "Waterpack type does not exist");
		return waterpackTypes.itemToNodeTypeToPrice[name][nodeType];
	}

    struct WaterpackView {
        string name;
        uint256 ratioOfGRP;
        uint256[] prices;
    }

    function getWaterpackTypes() public view returns (WaterpackView[] memory) {
		string[] memory nodeTypes = _handler.getNodeTypesNames();
        WaterpackView[] memory output = new WaterpackView[](
            waterpackTypes.items.length
        );

        for (uint256 i = 0; i < waterpackTypes.items.length; i++) {
			uint256[] memory prices = new uint256[](nodeTypes.length);
			for (uint256 j = 0; j < nodeTypes.length; j++) {
				prices[j] = waterpackTypes.itemToNodeTypeToPrice[
					waterpackTypes.names[i]
				][nodeTypes[j]];
			}
            output[i] = WaterpackView({
                name: waterpackTypes.names[i],
                ratioOfGRP: waterpackTypes.items[i].ratioOfGRP,
                prices: prices
            });
        }

        return output;
    }

    //====== Internal API ====================================================//

    function _setWaterpackType(
        string calldata name,
        uint256 ratioOfGRP,
        uint256[] calldata prices
    ) internal {
		string[] memory nodeTypes = _handler.getNodeTypesNames();
		require(nodeTypes.length == prices.length, "Waterpacks: length mismatch");

        uint256 indexPlusOne = waterpackTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            waterpackTypes.names.push(name);
            waterpackTypes.items.push(
                Waterpack({ratioOfGRP: ratioOfGRP})
            );
            waterpackTypes.indexOfPlusOne[name] = waterpackTypes.names.length;
        } else {
            Waterpack storage waterpack = waterpackTypes.items[
                indexPlusOne - 1
            ];
            waterpack.ratioOfGRP = ratioOfGRP;
        }

		for (uint256 i = 0; i < nodeTypes.length; i++) {
			waterpackTypes.itemToNodeTypeToPrice[name][nodeTypes[i]] = prices[i];
		}
    }

    function _hasWaterpackType(string calldata name)
        internal
        view
        returns (bool ret)
    {
        ret = waterpackTypes.indexOfPlusOne[name] != 0;
    }

    function _getWaterpackType(string calldata name)
        internal
        view
        returns (Waterpack memory)
    {
        uint256 idx = waterpackTypes.indexOfPlusOne[name];
        require(idx != 0, "Waterpacks: nonexistant key");
        return waterpackTypes.items[idx - 1];
    }

    function _removeWaterpackType(string calldata name)
        internal
        returns (bool)
    {
        uint256 indexPlusOne = waterpackTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            return false;
        }

        uint256 toDeleteIndex = indexPlusOne - 1;
        uint256 lastIndex = waterpackTypes.items.length - 1;

        if (lastIndex != toDeleteIndex) {
            Waterpack storage lastValue = waterpackTypes.items[lastIndex];
            string storage lastName = waterpackTypes.names[lastIndex];

            waterpackTypes.items[toDeleteIndex] = lastValue;
            waterpackTypes.names[toDeleteIndex] = lastName;
            waterpackTypes.indexOfPlusOne[lastName] = indexPlusOne;
        }

        waterpackTypes.items.pop();
        waterpackTypes.names.pop();
        waterpackTypes.indexOfPlusOne[name] = 0;

        return true;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./HandlerAwareUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

struct Fertilizer {
    /// @dev Duration of the effect of the fertilizer, expressed in seconds.
    uint256 durationEffect;
    
    /// @dev Percentage of additional boost provided during the effect of the
    /// fertilizer.
    uint256 rewardBoost;

    /// @dev Global limit on the number of fertilizers that can be applied.
    uint256 globalLimit;

    /// @dev User limit on the number of fertilizers that can be applied.
    uint256 userLimit;

    /// @dev Limit on the number of fertilizers that can be applied per node
    /// type, per user.
    uint256 userNodeTypeLimit;

    /// @dev Limit on the number of fertilizers that can be applied on a single
    /// node.
    uint256 nodeLimit;
}

abstract contract Fertilizers is HandlerAwareUpgradeable {
    struct FertilizerTypes {
        Fertilizer[] items;
        string[] names;
        /// @dev Name to index + 1, 0 means the fertilizer doesn't exists.
        mapping(string => uint256) indexOfPlusOne;
        mapping(string => mapping(string => uint256)) itemToNodeTypeToPrice;
    }

    FertilizerTypes internal fertilizerTypes;

    mapping(string => uint256) public totalCreatedPerType;
    mapping(address => uint256) public totalCreatedPerUser;
    mapping(address => mapping(string => uint256)) public totalCreatedPerUserPerType;
    mapping(uint256 => uint256) public totalCreatedPerNodeTokenId;

    //====== Getters =========================================================//

    function hasFertilizerType(string calldata name)
        external
        view
        returns (bool)
    {
        return _hasFertilizerType(name);
    }

    function getFertilizerType(string calldata name)
        external
        view
        returns (Fertilizer memory)
    {
        return _getFertilizerType(name);
    }

	function getFertilizerPriceByNameAndNodeType(
		string calldata name,
		string calldata nodeType
	)
		external
		view
		returns (uint256)
	{
		require(_hasFertilizerType(name), "Fertilizer type does not exist");
		return fertilizerTypes.itemToNodeTypeToPrice[name][nodeType];
	}

    struct FertilizerView {
        string name;
        uint256 durationEffect;
        uint256 rewardBoost;
        uint256[] prices;
    }

    function getFertilizerTypes()
        public
        view
        returns (FertilizerView[] memory)
    {
        string[] memory nodeTypes = _handler.getNodeTypesNames();
        FertilizerView[] memory output = new FertilizerView[](
            fertilizerTypes.items.length
        );

        for (uint256 i = 0; i < fertilizerTypes.items.length; i++) {
            string storage fertilizerName = fertilizerTypes.names[i];
            uint256[] memory prices = new uint256[](nodeTypes.length);
            for (uint256 j = 0; j < nodeTypes.length; j++) {
                prices[j] = fertilizerTypes.itemToNodeTypeToPrice[
                    fertilizerName
                ][nodeTypes[j]];
            }

            output[i] = FertilizerView({
                name: fertilizerName,
                durationEffect: fertilizerTypes.items[i].durationEffect,
                rewardBoost: fertilizerTypes.items[i].rewardBoost,
                prices: prices
            });
        }

        return output;
    }

    //====== Mutators ========================================================//

    function _applyFertilizer(
        string memory name,
        uint256 nodeTokenId,
        uint256 amount
    )
        internal
        onlyHandler
    {
        Fertilizer memory fertilizerType = _getFertilizerType(name);
        string memory nodeType = _handler.getTokenIdNodeTypeName(nodeTokenId);
        address user = IERC721(_handler.nft()).ownerOf(nodeTokenId);

        totalCreatedPerType[name] += amount; 
        require(
            totalCreatedPerType[name] <= fertilizerType.globalLimit,
            "Fertilizers: Global limit exceeded"
        );

        totalCreatedPerUser[user] += amount;
        require(
            totalCreatedPerUser[user] <= fertilizerType.userLimit,
            "Fertilizers: User limit exceeded"
        );

        totalCreatedPerUserPerType[user][nodeType] += amount;
        require(
            totalCreatedPerUserPerType[user][nodeType] <=
            fertilizerType.userNodeTypeLimit,
            "Fertilizers: User node type limit exceeded"
        );

        totalCreatedPerNodeTokenId[nodeTokenId] += amount;
        require(
            totalCreatedPerNodeTokenId[nodeTokenId] <= fertilizerType.nodeLimit,
            "Fertilizers: Node limit exceeded"
        );
    }

    //====== Internal API ====================================================//

    function _setFertilizerType(
        string calldata name,
        uint256 durationEffect,
        uint256 rewardBoost,
        uint256[] calldata limits,
        uint256[] calldata prices
    ) internal {
        require(limits.length == 4, "Fertilizers: invalid arguments");
		string[] memory nodeTypes = _handler.getNodeTypesNames();
		require(prices.length == nodeTypes.length, "Fertilizers: length mismatch");
        uint256 indexPlusOne = fertilizerTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            fertilizerTypes.names.push(name);
            fertilizerTypes.items.push(
                Fertilizer({
                    durationEffect: durationEffect,
                    rewardBoost: rewardBoost,
                    globalLimit: limits[0],
                    userLimit: limits[1],
                    userNodeTypeLimit: limits[2],
                    nodeLimit: limits[3]
                })
            );
            fertilizerTypes.indexOfPlusOne[name] = fertilizerTypes.names.length;
        } else {
            Fertilizer storage fertilizer = fertilizerTypes.items[
                indexPlusOne - 1
            ];
            fertilizer.durationEffect = durationEffect;
            fertilizer.rewardBoost = rewardBoost;
            fertilizer.globalLimit = limits[0];
            fertilizer.userLimit = limits[1];
            fertilizer.userNodeTypeLimit = limits[2];
            fertilizer.nodeLimit = limits[3];
        }

		for (uint256 i = 0; i < nodeTypes.length; i++) {
			fertilizerTypes.itemToNodeTypeToPrice[name][nodeTypes[i]] = prices[i];
		}
    }

    function _hasFertilizerType(string calldata name)
        internal
        view
        returns (bool ret)
    {
        ret = fertilizerTypes.indexOfPlusOne[name] != 0;
    }

    function _getFertilizerType(string memory name)
        internal
        view
        returns (Fertilizer memory)
    {
        uint256 idx = fertilizerTypes.indexOfPlusOne[name];
        require(idx != 0, "Fertilizers: nonexistant key");
        return fertilizerTypes.items[idx - 1];
    }

    function _removeFertilizerType(string calldata name)
        internal
        returns (bool)
    {
        uint256 indexPlusOne = fertilizerTypes.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            return false;
        }

        uint256 toDeleteIndex = indexPlusOne - 1;
        uint256 lastIndex = fertilizerTypes.items.length - 1;

        if (lastIndex != toDeleteIndex) {
            Fertilizer storage lastValue = fertilizerTypes.items[lastIndex];
            string storage lastName = fertilizerTypes.names[lastIndex];

            fertilizerTypes.items[toDeleteIndex] = lastValue;
            fertilizerTypes.names[toDeleteIndex] = lastName;
            fertilizerTypes.indexOfPlusOne[lastName] = indexPlusOne;
        }

        fertilizerTypes.items.pop();
        fertilizerTypes.names.pop();
        fertilizerTypes.indexOfPlusOne[name] = 0;

        return true;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IHandler.sol";

abstract contract HandlerAwareUpgradeable is Initializable {
    IHandler internal _handler;
    modifier onlyHandler() {
        require(msg.sender == address(_handler));
        _;
    }

    function __HandlerAware_init(IHandler handler) internal onlyInitializing {
        __HandlerAware_init_unchained(handler);
    }

    function __HandlerAware_init_unchained(IHandler handler) internal onlyInitializing {
        _handler = handler;
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

interface IHandler {
    function nodeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function plotTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function getAttribute(uint256 tokenId)
        external
        view
        returns (string memory);

    function getNodeTypesNames() external view returns (string[] memory);

    function getTokenIdNodeTypeName(uint256 key)
        external
        view
        returns (string memory);

    function nft() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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