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
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interface/ILiquidityProvider.sol";
import "./interface/ICore.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AncillaryDataLib} from "./Libraries/AncillaryDataLib.sol";
import {ICore, BetData, ConditionData, FundsData} from "./interface/ICore.sol";

/// @title This contract register bets and create conditions
contract Core is OwnableUpgradeable, ICore {
    uint256 public decimals;
    address public oracle;

    address public liquidityProvider;

    mapping(bytes32 => ConditionData) public conditions;
    mapping(uint256 => BetData) public bets; // bet id -> BET
    mapping(bytes32 => FundsData) funds;

    uint256 public lastBetID; //start from 1

    /// @notice Maximum ancillary data length
    uint256 public maxAncillaryData;

    mapping(bytes32 => OutcomeData) outcomes; // conditionid -> outcome

    modifier onlyOracle() {
        require(_msgSender() == oracle, "Core:Only Oracle");
        _;
    }

    modifier OnlyLiquidityProvider() {
        require(_msgSender() == liquidityProvider, "Core:Only LP");
        _;
    }

    /**
     * init
     */
    function initialize(address oracleAddress) public virtual initializer {
        __Ownable_init();
        oracle = oracleAddress;
        decimals = 10 ** 9;
        maxAncillaryData = 8139;
    }

    /**
     * @dev create condition from oracle
     * @param ancillaryData - Data used to resolve a question
     */
    function createCondition(
        bytes calldata ancillaryData,
        bytes32[] calldata outcomeIDs,
        uint256 reinforcement // in token decimals
    ) external override onlyOracle returns (bytes32 conditionID) {
        bytes memory data = AncillaryDataLib._appendAncillaryData(
            _msgSender(),
            ancillaryData
        );
        if (ancillaryData.length == 0 || data.length > maxAncillaryData)
            revert("Core:IAD"); //invalid ancillary data

        conditionID = keccak256(data);

        if (_isInitialized(conditions[conditionID])) revert("Core:CAR"); //condition already initialized

        uint256 timestamp = block.timestamp;

        // Persist the question parameters in storage
        _saveCondition(
            _msgSender(),
            conditionID,
            outcomeIDs,
            data,
            timestamp,
            reinforcement
        );

        emit ConditionCreated(conditionID, timestamp, _msgSender(), data);
    }

    function getConditionId(bytes calldata ancillaryData) external view returns (bytes32 conditionID) {
        bytes memory data = AncillaryDataLib._appendAncillaryData(
            _msgSender(),
            ancillaryData
        );
        if (ancillaryData.length == 0 || data.length > maxAncillaryData)
            revert("Core:IAD"); //invalid ancillary data

        conditionID = keccak256(data);

        return conditionID;
    }

    function setCashoutStatus(
        bytes32 conditionID,
        bool enableCashout
    ) external override onlyOracle {
        ConditionData storage condition = conditions[conditionID];
        require(_isInitialized(condition), "Core:CNE"); //condition not exists

        condition.cashoutEnabled = enableCashout;
    }

    function cancelCondition(bytes32 conditionID) external override onlyOracle {
        ConditionData storage condition = conditions[conditionID];
        require(_isInitialized(condition), "Core:CNE"); //condition not exists

        condition.cancelled = true;
    }

    function cashout(
        uint256 betID,
        uint256 feeOdds
    ) external override OnlyLiquidityProvider returns (uint256 amount) {
        BetData storage currentBet = bets[betID];
        require(currentBet.settled == false, "Core:BAS"); //Bet already settled

        uint256 conditionLength = currentBet.betItems.length;
        uint256[] memory coefficients = new uint256[](conditionLength);
        for (uint256 i = 0; i < conditionLength; ++i) {
            ConditionData storage condition = conditions[
                currentBet.betItems[i].conditionID
            ];
            require(
                condition.cashoutEnabled == true,
                "Core:CCNC" //Condition can not cashout
            );
            coefficients[i] = currentBet.betItems[i].coefficient;
        }

        require(feeOdds < decimals, "Core:ICFO"); //Invalid cashout fee odds

        //calculate max possible win amount
        uint256 possibleWinAmount = _getWinAmount(
            currentBet.amount,
            coefficients
        );

        //use first condition to store funds data
        bytes32 conditionID = currentBet.betItems[0].conditionID;
        bytes32 outcomeID = currentBet.betItems[0].outcomeID;

        _subFunds(conditionID, outcomeID, currentBet.amount, possibleWinAmount);

        currentBet.settled = true;

        amount = (currentBet.amount * (decimals - feeOdds)) / decimals;
    }

    function refundBet(
        uint256 betID
    ) external override OnlyLiquidityProvider returns (uint256 amount) {
        BetData storage currentBet = bets[betID];
        require(currentBet.settled == false, "Core:BAS"); //Bet already settled

        uint256[] memory coefficients = _getCoefficient(currentBet);

        //calculate max possible win amount
        uint256 possibleWinAmount = _getWinAmount(
            currentBet.amount,
            coefficients
        );

        //use first condition to store funds data
        bytes32 conditionID = currentBet.betItems[0].conditionID;
        bytes32 outcomeID = currentBet.betItems[0].outcomeID;

        _subFunds(conditionID, outcomeID, currentBet.amount, possibleWinAmount);

        currentBet.settled = true;

        amount = currentBet.amount;
    }

    /**
     * @dev register the bet in the core
     * @param conditionIDs the current matches or games
     * @param outcomeIDs bet outcomes
     * @param coefficients bet outcome odds
     * @param amount_ bet amount in tokens
     * @return betID with odds of this bet and updated funds
     */
    function placeBet(
        bytes32[] calldata conditionIDs,
        bytes32[] calldata outcomeIDs,
        uint256[] calldata coefficients,
        uint256 amount_
    ) external override OnlyLiquidityProvider returns (uint256) {
        require(amount_ > decimals, "Core:small bet");

        lastBetID += 1;
        BetData storage newBet = bets[lastBetID];

        uint256 conditionLength = conditionIDs.length;
        for (uint256 i = 0; i < conditionLength; ++i) {
            ConditionData storage condition = conditions[conditionIDs[i]];
            require(
                _isInitialized(condition),
                "Core:CMBI" //condition must be initialized
            );
            require(
                condition.resolved == false,
                "Core:SCAR" //Some condition already resolved
            );

            BetItem memory betItem;
            betItem.conditionID = conditionIDs[i];
            betItem.outcomeID = outcomeIDs[i];
            betItem.coefficient = coefficients[i];
            newBet.betItems.push(betItem);
        }

        //calculate max possible win amount
        uint256 possibleWinAmount = _getWinAmount(amount_, coefficients);

        //use first condition to store funds data
        bytes32 conditionID = conditionIDs[0];
        bytes32 outcomeID = outcomeIDs[0];

        _addFunds(conditionID, outcomeID, amount_, possibleWinAmount);

        newBet.amount = amount_;
        newBet.createdAt = block.timestamp;

        return lastBetID;
    }

    /**
     * @dev resolve the payout
     * @param betID it is betID
     * @return success
     * @return amount of better win
     */
    function resolvePayout(
        uint256 betID
    )
        external
        override
        OnlyLiquidityProvider
        returns (bool success, uint256 amount)
    {
        BetData storage currentBet = bets[betID];
        require(currentBet.settled == false, "Core:BAS"); //Bet already settled

        uint256 conditionLength = currentBet.betItems.length;
        for (uint256 i = 0; i < conditionLength; ++i) {
            ConditionData storage condition = conditions[
                currentBet.betItems[i].conditionID
            ];
            require(
                condition.resolved == true,
                "Core:CNRY" //Condition not resolved yet
            );
        }

        ConditionData storage payoutCondition = conditions[
            currentBet.betItems[0].conditionID
        ];

        if (payoutCondition.maxPayout != 0) {
            // decrease global lockedInBets on payout paid value
            ILiquidityProvider(liquidityProvider).releaseLiquidity(
                payoutCondition.maxPayout
            );
            payoutCondition.maxPayout = 0;
        }

        CoefficientsData memory coefficientsData;
        (success, amount, coefficientsData) = _viewPayout(betID);

        uint256 coefficientsLenth = coefficientsData
            .subCoefficientsItems
            .length;
        currentBet.coefficientsData.finalCoefficient = coefficientsData
            .finalCoefficient;

        for (uint256 i = 0; i < coefficientsLenth; ++i) {
            currentBet.coefficientsData.subCoefficientsItems.push(
                coefficientsData.subCoefficientsItems[i]
            );
        }

        if (success) {
            currentBet.settled = true;
        }

        // pool win
        if (amount < currentBet.amount) {
            uint256 profitReserve = currentBet.amount - amount;
            ILiquidityProvider(liquidityProvider).addProfit(profitReserve);
        }

        return (success, amount);
    }

    /**
     * @dev resolve condition from oracle
     * @param conditionID - id of the game
     * @param outcomeData - outcome data
     */
    function resolveCondition(
        bytes32 conditionID,
        bytes calldata outcomeData
    ) external override onlyOracle {
        ConditionData storage condition = conditions[conditionID];
        require(_isInitialized(condition), "Core:CNE"); //condition not exists
        require(
            condition.resolved == false,
            "Core:CAR" // Condition already resolved
        );

        (
            bytes32[] memory outcomeIDs,
            int8[] memory results,
            uint256[] memory voidFactors
        ) = abi.decode(outcomeData, (bytes32[], int8[], uint256[]));
        require(
            outcomeIDs.length == results.length &&
                outcomeIDs.length == voidFactors.length &&
                outcomeIDs.length >= 1,
            "Core:WRCD" // Resolve condition data is not valid.
        );

        OutcomeData storage outcomeData_ = outcomes[conditionID];
        uint256 settlementDataLength = outcomeIDs.length;
        SettlementData[] memory finalSettlements = new SettlementData[](
            settlementDataLength
        );
        for (uint256 i = 0; i < settlementDataLength; ++i) {
            require(
                _exists(conditions[conditionID].outcomeIDs, outcomeIDs[i]),
                "Core:WRC"
            );
            SettlementData storage settlementData = outcomeData_.outcomes[
                outcomeIDs[i]
            ];
            settlementData.result = results[i];
            settlementData.voidFactor = voidFactors[i];
            settlementData.resolved = true;
            finalSettlements[i] = settlementData;
        }

        condition.resolved = true;
        emit ConditionResolved(conditionID, finalSettlements);
    }

    function setLiquidityProvider(
        address lpAddress
    ) external override onlyOwner {
        liquidityProvider = lpAddress;
    }

    function setOracle(address oracleAddress) external onlyOwner {
        oracle = oracleAddress;
    }

    function viewPayout(
        uint256 betID
    ) external view override returns (bool success, uint256 amount) {
        CoefficientsData memory coefficientsData;
        (success, amount, coefficientsData) = _viewPayout(betID);
    }

    function getCondition(
        bytes32 conditionID
    ) external view returns (ConditionData memory) {
        return (conditions[conditionID]);
    }

    /*///////////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS 
    //////////////////////////////////////////////////////////////////*/

    function _saveCondition(
        address creator,
        bytes32 conditionID,
        bytes32[] calldata outcomeIDs,
        bytes memory ancillaryData,
        uint256 requestTimestamp,
        uint256 conditionsReinforcement
    ) internal {
        conditions[conditionID] = ConditionData({
            requestTimestamp: requestTimestamp,
            resolved: false,
            paused: false,
            cancelled: false,
            creator: creator,
            ancillaryData: ancillaryData,
            outcomeIDs: outcomeIDs,
            cashoutEnabled: true,
            reinforcement: conditionsReinforcement,
            maxPayout: 0
        });
    }

    /**
     * internal view, used resolve payout and external views
     * @param betID - bet id
     */

    function _viewPayout(
        uint256 betID
    )
        internal
        view
        returns (bool success, uint256 amount, CoefficientsData memory)
    {
        BetData storage currentBet = bets[betID];

        uint256 finalCoefficient = 0;

        uint256 conditionLength = currentBet.betItems.length;

        uint256 divisor = decimals;
        uint256 voidFactorCount = 0;
        uint256[] memory voidFactorIndex = new uint256[](conditionLength);
        uint256[] memory coefficients = new uint256[](conditionLength);

        CoefficientsData memory coefficientsData;

        for (uint256 i = 0; i < conditionLength; ++i) {
            ConditionData storage condition = conditions[
                currentBet.betItems[i].conditionID
            ];

            require(
                condition.resolved == true,
                "Core:CNRY" //Condition not resolved yet
            );

            uint256 subCoefficient = 0;

            bytes32 currentBetOutcomeID = currentBet.betItems[i].outcomeID;

            OutcomeData storage outcomeData = outcomes[
                currentBet.betItems[i].conditionID
            ];

            SettlementData storage settlementData = outcomeData.outcomes[
                currentBetOutcomeID
            ];

            require(
                settlementData.resolved == true,
                "Core:CONRY" //Condition outcome not resolved yet
            );

            require(
                settlementData.voidFactor >= 0 &&
                    settlementData.voidFactor <= decimals,
                "Core:IVF" // Invalid void factor
            );

            if (settlementData.result == -1) {
                // UNDECIDED_YET
                revert("Core:ISD"); //Invalid settlement data
            } else if (settlementData.result == 0) {
                // LOST
                if (settlementData.voidFactor == decimals) {
                    // refund bet
                    subCoefficient = decimals;
                } else {
                    subCoefficient = 0;
                }
            } else if (settlementData.result == 1) {
                // WIN
                subCoefficient = currentBet.betItems[i].coefficient;
            }

            if (
                settlementData.voidFactor != 0 &&
                settlementData.voidFactor != decimals
            ) // half win/lose,settlementData.voidFactor always 0.5
            {
                voidFactorIndex[voidFactorCount] = i;
                voidFactorCount += 1;
                divisor = (divisor / settlementData.voidFactor) * decimals;
            }

            coefficients[i] = subCoefficient;
        }

        // calculate final coefficient
        if (voidFactorCount == 0) {
            // no half win/lose
            finalCoefficient = _calcCoefficient(coefficients, conditionLength);
            CoefficientsItem memory coefficientItem;
            coefficientsData.subCoefficientsItems = new CoefficientsItem[](1);
            coefficientItem.subCoefficients = coefficients;
            coefficientItem.coefficient = finalCoefficient;

            coefficientsData.subCoefficientsItems[0] = coefficientItem;
            coefficientsData.finalCoefficient = finalCoefficient;
        } else {
            coefficientsData = _genCoefficients(
                coefficients,
                conditionLength,
                voidFactorIndex,
                voidFactorCount
            );

            finalCoefficient = coefficientsData.finalCoefficient;
        }

        uint256 finalDivisor = divisor / decimals;

        require(
            finalDivisor >= 1 && divisor % decimals == 0,
            "Core:IVFD" //Invalid void factor data
        );
        coefficientsData.finalDivisor = finalDivisor;

        uint256 winAmount = ((currentBet.amount *
            finalCoefficient) / decimals) / finalDivisor;
        return (true, winAmount, coefficientsData);
    }

    function _genCoefficients(
        uint256[] memory coefficients,
        uint256 coefficientsCount,
        uint256[] memory voidFactorIndex,
        uint256 voidFactorsCount
    ) internal view returns (CoefficientsData memory) {
        require(
            coefficientsCount >= voidFactorsCount,
            "Core:GCID" //GenCoeff invalid data
        );
        CoefficientsData memory coefficientsData;
        coefficientsData.subCoefficientsItems = new CoefficientsItem[](
            voidFactorsCount * (voidFactorsCount - 1) + 2
        );
        uint256 pos = 0;
        uint256 finalCoefficient = 0;
        for (uint256 i = 0; i <= voidFactorsCount; ++i) {
            for (uint256 j = 0; j < voidFactorsCount; ++j) {
                uint256[] memory tempCoefficients = _copyArray(
                    coefficients,
                    coefficientsCount
                );

                for (uint256 k = 0; k < i; ++k) {
                    tempCoefficients[
                        (voidFactorIndex[(k + j) % voidFactorsCount]) %
                            coefficientsCount
                    ] = decimals;
                }

                CoefficientsItem memory coefficientItem;
                coefficientItem.subCoefficients = tempCoefficients;
                coefficientItem.coefficient = _calcCoefficient(
                    tempCoefficients,
                    coefficientsCount
                );
                coefficientsData.subCoefficientsItems[pos++] = coefficientItem;
                finalCoefficient += coefficientItem.coefficient;

                if (i % voidFactorsCount == 0) {
                    break;
                }
            }
        }

        coefficientsData.finalCoefficient = finalCoefficient;

        return coefficientsData;
    }

    function _copyArray(
        uint256[] memory data,
        uint256 dataCount
    ) internal pure returns (uint256[] memory) {
        uint256[] memory dupData = new uint256[](dataCount);
        for (uint256 i = 0; i < dataCount; ++i) {
            dupData[i] = data[i];
        }
        return dupData;
    }

    function _calcCoefficient(
        uint256[] memory coefficients,
        uint256 coefficientsCount
    ) internal view returns (uint256) {
        uint256 retValue = decimals;
        for (uint256 i = 0; i < coefficientsCount; ++i) {
            retValue = (retValue * coefficients[i]) / decimals;
        }

        return retValue;
    }

    function _isInitialized(
        ConditionData storage conditionData
    ) internal view returns (bool) {
        return conditionData.ancillaryData.length > 0;
    }

    // Get the expected win amount.
    function _getWinAmount(
        uint amount,
        uint256[] memory coefficients
    ) private view returns (uint256 winAmount) {
        uint256 finalCoefficient = decimals;
        //uint256 uLength = coefficients.length;
        for (uint256 i = 0; i < coefficients.length; ++i) {
            finalCoefficient = (finalCoefficient * coefficients[i]) / decimals;
        }

        winAmount = (amount * finalCoefficient) / decimals;
    }

    function _getCoefficient(
        BetData storage currentBet
    ) internal view returns (uint256[] memory) {
        uint256 conditionLength = currentBet.betItems.length;
        uint256[] memory coefficients = new uint256[](conditionLength);
        for (uint256 i = 0; i < conditionLength; ++i) {
            coefficients[i] = currentBet.betItems[i].coefficient;
        }

        return coefficients;
    }

    function _addFunds(
        bytes32 conditionID,
        bytes32 outcomeID,
        uint256 amount,
        uint256 possibleWinAmount
    ) internal {
        //FundsData storage fundsData = funds[conditionID];
        funds[conditionID].fundsBank[outcomeID] += amount;
        funds[conditionID].payouts[outcomeID] += possibleWinAmount;
        _updateMaxPayout(conditionID);
    }

    function _subFunds(
        bytes32 conditionID,
        bytes32 outcomeID,
        uint256 amount,
        uint256 possibleWinAmount
    ) internal {
        //FundsData storage fundsData = funds[conditionID];
        require(
            funds[conditionID].fundsBank[outcomeID] >= amount,
            "Core:WFD" //Wrong fundsBank data
        );
        require(
            funds[conditionID].payouts[outcomeID] >= possibleWinAmount,
            "Core:WPD" //Wrong payouts data
        );

        funds[conditionID].fundsBank[outcomeID] -= amount;
        funds[conditionID].payouts[outcomeID] -= possibleWinAmount;

        _updateMaxPayout(conditionID);
    }

    function _updateMaxPayout(bytes32 conditionID) internal {
        uint256 curMaxPayout = _calculateMaxPayout(conditionID);
        if (
            curMaxPayout > conditions[conditionID].maxPayout
        ) // we need lock more liquidity
        {
            uint256 diffVal = curMaxPayout - conditions[conditionID].maxPayout;
            ILiquidityProvider(liquidityProvider).lockLiquidity(diffVal);
        } else if (
            conditions[conditionID].maxPayout > curMaxPayout
        ) // release some liquidity
        {
            uint256 diffVal = conditions[conditionID].maxPayout - curMaxPayout;
            ILiquidityProvider(liquidityProvider).releaseLiquidity(diffVal);
        }

        conditions[conditionID].maxPayout = curMaxPayout;
    }

    function _calculateMaxPayout(
        bytes32 conditionID
    ) internal view returns (uint256) {
        uint256 maxPayout = 0;
        uint256 totalFunds = _calculateFunds(conditionID);
        for (
            uint256 i = 0;
            i < conditions[conditionID].outcomeIDs.length;
            ++i
        ) {
            uint256 curPayout = 0;
            uint256 curOutcomePayout = funds[conditionID].payouts[
                conditions[conditionID].outcomeIDs[i]
            ];
            uint256 curOutcomeFunds = totalFunds -
                funds[conditionID].fundsBank[
                    conditions[conditionID].outcomeIDs[i]
                ];
            if (curOutcomePayout > curOutcomeFunds) // need payout
            {
                curPayout = curOutcomePayout - curOutcomeFunds;
            }

            if (maxPayout < curPayout) {
                maxPayout = curPayout;
            }
        }

        return maxPayout;
    }

    function _calculateFunds(
        bytes32 conditionID
    ) internal view returns (uint256) {
        uint256 totalFunds = 0;
        for (
            uint256 i = 0;
            i < conditions[conditionID].outcomeIDs.length;
            ++i
        ) {
            totalFunds += funds[conditionID].fundsBank[
                conditions[conditionID].outcomeIDs[i]
            ];
        }

        return totalFunds;
    }

    function _exists(
        bytes32[] storage array,
        bytes32 element
    ) internal view returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }

        return false;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

struct BetItem {
    bytes32 conditionID;
    bytes32 outcomeID;
    uint256 coefficient;
}

struct CoefficientsItem {
    uint256[] subCoefficients;
    uint256 coefficient;
}

struct CoefficientsData {
    CoefficientsItem[] subCoefficientsItems;
    uint256 finalCoefficient;
    uint256 finalDivisor;
}

struct BetData {
    BetItem[] betItems;
    CoefficientsData coefficientsData;
    uint256 amount;
    bool settled;
    uint256 createdAt;
}
struct ConditionData {
    /// @notice Request timestamp
    uint256 requestTimestamp;
    /// @notice Flag marking whether a condition is resolved
    bool resolved;
    /// @notice Flag marking whether a condition is paused
    bool paused;
    /// @notice Flag marking whether a condition is cancelled
    bool cancelled;
    /// @notice The address of the condition creator
    address creator;
    /// @notice Data used to resolve a condition
    bytes ancillaryData;
    /// @notice All outcome id
    bytes32[] outcomeIDs;
    /// @notice Cashout status
    bool cashoutEnabled;
    uint256 reinforcement;
    /// @notice maximum sum of payouts to be paid on some result
    uint256 maxPayout;
}

struct FundsData {
    mapping(bytes32 => uint256) fundsBank;
    mapping(bytes32 => uint256) payouts;
}

struct SettlementData {
    bool resolved;
    int8 result; // -1,0,1
    uint256 voidFactor; // in decimals 10^9
}

struct OutcomeData {
    mapping(bytes32 => SettlementData) outcomes; // outcome id -> SettlementData
}

interface ICore {
    /// @notice Emitted when a condition is created
    event ConditionCreated(
        bytes32 indexed conditionID,
        uint256 indexed requestTimestamp,
        address indexed creator,
        bytes ancillaryData
    );
    event ConditionResolved(bytes32 conditionID, SettlementData[] outcomeWin);

    function createCondition(
        bytes calldata ancillaryData,
        bytes32[] calldata outcomeIDs,
        uint256 reinforcement
    ) external returns (bytes32 conditionID);

    function cancelCondition(bytes32 conditionID) external;

    function resolveCondition(
        bytes32 conditionID,
        bytes calldata outcomeData
    ) external;

    function viewPayout(uint256 betID) external view returns (bool, uint256);

    function resolvePayout(uint256 betID) external returns (bool, uint256);

    function setLiquidityProvider(address lpAddress) external;

    function placeBet(
        bytes32[] calldata conditionIDs,
        bytes32[] calldata outcomeIDs,
        uint256[] calldata coefficients,
        uint256 amount_
    ) external returns (uint256);

    function setCashoutStatus(bytes32 conditionID, bool enableCashout) external;

    function cashout(uint256 betID, uint256 feeOdds) external returns (uint256);

    function refundBet(uint256 betID) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

interface ILiquidityProvider {
    function changeCore(address addr_) external;

    function addLiquidity(uint256 _amount) external;

    function withdrawLiquidity(uint256 _amount) external;

    function viewPayout(uint256 betID) external view returns (bool, uint256);

    function withdrawPayout(uint256 conditionID, uint256 betID) external;

    function addProfit(uint256 profit) external;

    function placeBet(bytes calldata data, bytes calldata signature) external;

    function checkLiquidity(
        uint256 requiredAmount
    ) external view returns (bool);

    function lockLiquidity(uint256 amount) external;

    function releaseLiquidity(uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library AncillaryDataLib {
    string private constant initializerPrefix = ",initializer:";

    /// @notice Appends the initializer address to the ancillaryData
    /// @param initializer      - The initializer address
    /// @param ancillaryData    - The ancillary data
    function _appendAncillaryData(
        address initializer,
        bytes memory ancillaryData
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                ancillaryData,
                initializerPrefix,
                _toUtf8BytesAddress(initializer)
            );
    }

    /// @notice Returns a UTF8-encoded address
    /// Source: UMA Protocol's AncillaryDataLib
    /// https://github.com/UMAprotocol/protocol/blob/9967e70e7db3f262fde0dc9d89ea04d4cd11ed97/packages/core/contracts/common/implementation/AncillaryData.sol
    /// Will return address in all lower case characters and without the leading 0x.
    /// @param addr - The address to encode.
    function _toUtf8BytesAddress(
        address addr
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _toUtf8Bytes32Bottom(bytes32(bytes20(addr)) >> 128),
                bytes8(_toUtf8Bytes32Bottom(bytes20(addr)))
            );
    }

    /// @notice Converts the bottom half of a bytes32 input to hex in a highly gas-optimized way.
    /// Source: the brilliant implementation at https://gitter.im/ethereum/solidity?at=5840d23416207f7b0ed08c9b.
    function _toUtf8Bytes32Bottom(
        bytes32 bytesIn
    ) private pure returns (bytes32) {
        unchecked {
            uint256 x = uint256(bytesIn);

            // Nibble interleave
            x =
                x &
                0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
            x =
                (x | (x * 2 ** 64)) &
                0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff;
            x =
                (x | (x * 2 ** 32)) &
                0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff;
            x =
                (x | (x * 2 ** 16)) &
                0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff;
            x =
                (x | (x * 2 ** 8)) &
                0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff;
            x =
                (x | (x * 2 ** 4)) &
                0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;

            // Hex encode
            uint256 h = (x &
                0x0808080808080808080808080808080808080808080808080808080808080808) /
                8;
            uint256 i = (x &
                0x0404040404040404040404040404040404040404040404040404040404040404) /
                4;
            uint256 j = (x &
                0x0202020202020202020202020202020202020202020202020202020202020202) /
                2;
            x =
                x +
                (h & (i | j)) *
                0x27 +
                0x3030303030303030303030303030303030303030303030303030303030303030;

            // Return the result.
            return bytes32(x);
        }
    }
}