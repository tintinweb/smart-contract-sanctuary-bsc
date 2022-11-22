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

pragma solidity ^0.8.0;

interface IAccess {
    function isMinter(address _manager) external view returns (bool);

    function isOwner(address _manager) external view returns (bool);

    function isSender(address _manager) external view returns (bool);

    function isSigner(address _manager) external view returns (bool);

    function isTradeDesk(address _manager) external view returns (bool);

    function updateTradeDeskUsers(address _user, bool _isTradeDesk) external;

    function preAuthValidations(
        bytes32 message,
        bytes32 token,
        bytes memory signature
    ) external returns (address);
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../lib/TransferHelper.sol";
import "../access/IAccess.sol";

contract Escrow is Initializable {
    // The counter of trades
    uint256 public tradesCounter;
    // Address of AZK token
    address public azx;
    // Address of wallet for receiving fee
    address public auzWallet;
    // Address of access control contract
    address public accessControl;

    // Mapping of trades
    mapping(uint256 => Trade) public trades;
    // Mapping of trade's external ids to internal ids
    mapping(string => uint256) public tradesIdsToTrades;

    // The struct of trade
    struct Trade {
        string tradeId;
        string[] links;
        address seller;
        address buyer;
        uint256 tradeCap;
        uint256 sellersPart;
        uint256 timeToResolve;
        uint256 resolveTS;
        uint256 linksLength;
        bool valid;
        bool paid;
        bool finished;
        bool released;
    }

    // Events
    event TradeRegistered(
        address signer,
        string indexed tradeId,
        address seller,
        address buyer,
        uint256 tradeCap,
        uint256 sellersPart,
        uint256 timeToResolve
    );
    event TradeValidated(string tradeId);
    event TradePaid(string tradeId, uint256 amount);
    event TradeFinished(string tradeId);
    event TradeReleased(
        string tradeId,
        address buyer,
        uint256 cap,
        uint256 sellersPart
    );
    event TradeResolved(
        address signer,
        string tradeId,
        bool result,
        string reason
    );

    modifier onlyOwner() {
        require(
            IAccess(accessControl).isOwner(msg.sender),
            "AUZToken: Only owner is allowed"
        );
        _;
    }

    modifier onlyManager() {
        require(
            IAccess(accessControl).isSender(msg.sender),
            "Escrow: Only managers is allowed"
        );
        _;
    }

    modifier onlyTradeDesk() {
        require(
            IAccess(accessControl).isTradeDesk(msg.sender),
            "Escrow: Only TradeDesk is allowed"
        );
        _;
    }

    receive() external payable {
        revert("Escrow: Contract cannot work with ETH");
    }

    /**
     * @dev Initializes the contract
     * @param _auzToken Address of AZK token
     * @param _auzWallet Address of wallet for receiving fee
     */
    function initialize(
        address _auzToken,
        address _auzWallet,
        address _access
    ) public initializer {
        accessControl = _access;
        azx = _auzToken;
        auzWallet = _auzWallet;
    }

    /**
     * @dev Changes address of wallet for receiving fee (for owner only)
     * @param _wallet Address of wallet for receiving fee
     */
    function changeWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Escrow: Zero address is not allowed");
        auzWallet = _wallet;
    }

    /**
     * @dev ID of the executing chain
     * @return uint value
     */
    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * @dev Get message hash for signing for validateTrade
     */
    function tradeDeskProof(
        bytes32 token,
        address user,
        bool isTradeDesk
    ) public view returns (bytes32 message) {
        message = keccak256(
            abi.encodePacked(getChainID(), token, user, isTradeDesk)
        );
    }

    /**
     * @dev Validate trade
     * @param signature Buyer's signature
     * @param user User address
     * @param isTradeDesk Is user TradeDesk
     */
    function setTradeDesk(
        bytes memory signature,
        bytes32 token,
        address user,
        bool isTradeDesk
    ) external onlyManager {
        bytes32 message = tradeDeskProof(token, user, isTradeDesk);
        address signer = IAccess(accessControl).preAuthValidations(
            message,
            token,
            signature
        );
        require(
            IAccess(accessControl).isSigner(signer),
            "Escrow: Signer is not manager"
        );
        IAccess(accessControl).updateTradeDeskUsers(user, isTradeDesk);
    }

    /**
     * @dev Get message hash for signing for registerTrade
     */
    function registerProof(
        bytes32 _token,
        string memory _tradeId,
        string[] memory _links,
        address _seller,
        address _buyer,
        uint256 _tradeCap,
        uint256 _sellersPart,
        uint256 _timeToResolve
    ) public view returns (bytes32 message) {
        if (_links.length == 0) _links[0] = "";
        message = keccak256(
            abi.encodePacked(
                getChainID(),
                _token,
                _tradeId,
                _links[0],
                _seller,
                _buyer,
                _tradeCap,
                _sellersPart,
                _timeToResolve
            )
        );
    }

    function testFunction () external pure returns (string memory _string) {
        _string = "test";
    }

    /**
     * @dev Registers new trade (only for admin)
     * @param _tradeId External trade id
     * @param _seller Address of seller
     * @param _buyer Address of buyer
     * @param _tradeCap Price of trade
     * @param _sellersPart Part of tradeCap for seller
     */
    function registerTrade(
        bytes memory signature,
        bytes32 _token,
        string memory _tradeId,
        string[] memory _links,
        address _seller,
        address _buyer,
        uint256 _tradeCap,
        uint256 _sellersPart,
        uint256 _timeToResolve
    ) external onlyManager {
        require(
            tradesIdsToTrades[_tradeId] == 0,
            "Escrow: Trade is already exist"
        );
        bytes32 message = registerProof(
            _token,
            _tradeId,
            _links,
            _seller,
            _buyer,
            _tradeCap,
            _sellersPart,
            _timeToResolve
        );
        address signer = IAccess(accessControl).preAuthValidations(
            message,
            _token,
            signature
        );
        require(
            IAccess(accessControl).isTradeDesk(signer),
            "Escrow: Signer is not TradeDesk"
        );
        tradesCounter++;
        tradesIdsToTrades[_tradeId] = tradesCounter;
        Trade storage trade = trades[tradesCounter];
        trade.tradeId = _tradeId;
        trade.seller = _seller;
        trade.buyer = _buyer;
        trade.tradeCap = _tradeCap;
        trade.sellersPart = _sellersPart;
        trade.timeToResolve = _timeToResolve;

        for (uint256 i = 0; i < _links.length; i++) {
            if (
                keccak256(abi.encodePacked(_links[i])) !=
                keccak256(abi.encodePacked(""))
            ) {
                trade.links.push(_links[i]);
                trade.linksLength++;
            }
        }

        emit TradeRegistered(
            signer,
            _tradeId,
            _seller,
            _buyer,
            _tradeCap,
            _sellersPart,
            _timeToResolve
        );
    }

    /**
     * @dev Get message hash for signing for validateTrade
     */
    function validateProof(
        bytes32 token,
        string memory _tradeId,
        string[] memory _links
    ) public view returns (bytes32 message) {
        if (_links.length == 0) _links[0] = "";
        message = keccak256(
            abi.encodePacked(getChainID(), token, _tradeId, _links[0])
        );
    }

    /**
     * @dev Validate trade
     * @param signature Buyer's signature
     * @param _tradeId External trade id
     */
    function validateTrade(
        bytes memory signature,
        bytes32 token,
        string memory _tradeId,
        string[] memory _links
    ) external onlyManager {
        require(tradesIdsToTrades[_tradeId] != 0, "Escrow: Trade is not exist");
        Trade storage trade = trades[tradesIdsToTrades[_tradeId]];
        require(!trade.valid, "Escrow: Trade is validates");
        require(!trade.finished, "Escrow: Trade is finished");
        bytes32 message = validateProof(token, _tradeId, _links);
        address signer = IAccess(accessControl).preAuthValidations(
            message,
            token,
            signature
        );
        require(
            IAccess(accessControl).isSigner(signer),
            "Escrow: Signer is not manager"
        );
        trade.valid = true;
        for (uint256 i = 0; i < _links.length; i++) {
            if (
                keccak256(abi.encodePacked(_links[i])) !=
                keccak256(abi.encodePacked(""))
            ) {
                trade.links.push(_links[i]);
                trade.linksLength++;
            }
        }
        emit TradeValidated(_tradeId);
    }

    /**
     * @dev Get message hash for signing for payTrade
     */
    function payProof(
        bytes32 token,
        string memory _tradeId,
        string[] memory _links,
        address _buyer
    ) public view returns (bytes32 message) {
        if (_links.length == 0) _links[0] = "";
        message = keccak256(
            abi.encodePacked(getChainID(), token, _tradeId, _links[0], _buyer)
        );
    }

    /**
     * @dev Pays for trade
     * @param signature Buyer's signature
     * @param _tradeId External trade id
     */
    function payTrade(
        bytes memory signature,
        bytes32 token,
        string memory _tradeId,
        string[] memory _links,
        address _buyer
    ) external onlyManager {
        require(tradesIdsToTrades[_tradeId] != 0, "Escrow: Trade is not exist");
        Trade storage trade = trades[tradesIdsToTrades[_tradeId]];
        require(trade.valid, "Escrow: Trade is not valid");
        require(!trade.paid, "Escrow: Trade is paid");
        require(trade.buyer != address(0), "Escrow: Buyer is not confirmed");
        bytes32 message = payProof(token, _tradeId, _links, _buyer);
        address signer = IAccess(accessControl).preAuthValidations(
            message,
            token,
            signature
        );
        require(
            trade.buyer == signer && trade.buyer == _buyer,
            "Escrow: Signer is not a buyer"
        );
        TransferHelper.safeTransferFrom(
            azx,
            _buyer,
            address(this),
            trade.tradeCap
        );
        trade.paid = true;
        for (uint256 i = 0; i < _links.length; i++) {
            if (
                keccak256(abi.encodePacked(_links[i])) !=
                keccak256(abi.encodePacked(""))
            ) {
                trade.links.push(_links[i]);
                trade.linksLength++;
            }
        }

        emit TradePaid(_tradeId, trade.tradeCap);
    }

    /**
     * @dev Get message hash for signing for approveTrade
     */
    function finishProof(
        bytes32 token,
        string memory _tradeId,
        string[] memory _links
    ) public view returns (bytes32 message) {
        if (_links.length == 0) _links[0] = "";
        message = keccak256(
            abi.encodePacked(token, _links[0], _tradeId, getChainID())
        );
    }

    /**
     * @dev Approves trade
     * @param signature Buyer's signature
     * @param _tradeId External trade id
     */
    function finishTrade(
        bytes memory signature,
        bytes32 token,
        string memory _tradeId,
        string[] memory _links
    ) external onlyManager {
        require(tradesIdsToTrades[_tradeId] != 0, "Escrow: Trade is not exist");
        Trade storage trade = trades[tradesIdsToTrades[_tradeId]];
        require(!trade.finished, "Escrow: Trade is finished");
        require(trade.paid, "Escrow: Trade is not paid");
        bytes32 message = finishProof(token, _tradeId, _links);
        address signer = IAccess(accessControl).preAuthValidations(
            message,
            token,
            signature
        );
        require(
            IAccess(accessControl).isTradeDesk(signer),
            "Escrow: Signer is not TradeDesk"
        );
        trade.finished = true;
        trade.resolveTS = block.timestamp + trade.timeToResolve;
        for (uint256 i = 0; i < _links.length; i++) {
            if (
                keccak256(abi.encodePacked(_links[i])) !=
                keccak256(abi.encodePacked(""))
            ) {
                trade.links.push(_links[i]);
                trade.linksLength++;
            }
        }

        emit TradeFinished(_tradeId);
    }

    /**
     * @dev Get message hash for signing for finishTrade
     */
    function releaseProof(
        bytes32 token,
        string memory _tradeId,
        string[] memory _links,
        address _buyer
    ) public view returns (bytes32 message) {
        if (_links.length == 0) _links[0] = "";
        message = keccak256(
            abi.encodePacked(_buyer, getChainID(), _links[0], token, _tradeId)
        );
    }

    /**
     * @dev Finishes trade (only for admin)
     * @param _tradeId External trade id
     */
    function releaseTrade(
        bytes memory signature,
        bytes32 token,
        string memory _tradeId,
        string[] memory _links,
        address _buyer
    ) external onlyManager {
        require(tradesIdsToTrades[_tradeId] != 0, "Escrow: Trade is not exist");
        Trade storage trade = trades[tradesIdsToTrades[_tradeId]];
        require(trade.buyer != address(0), "Escrow: Buyer is not confirmed");
        bytes32 message = releaseProof(token, _tradeId, _links, _buyer);
        address signer = IAccess(accessControl).preAuthValidations(
            message,
            token,
            signature
        );
        require(
            trade.buyer == signer && trade.buyer == _buyer,
            "Escrow: Signer is not a buyer"
        );
        require(!trade.released, "Escrow: Trade is released");
        require(trade.finished, "Escrow: Trade is not finished");
        TransferHelper.safeTransfer(azx, trade.seller, trade.sellersPart);
        TransferHelper.safeTransfer(
            azx,
            auzWallet,
            trade.tradeCap - trade.sellersPart
        );
        trade.released = true;
        for (uint256 i = 0; i < _links.length; i++) {
            if (
                keccak256(abi.encodePacked(_links[i])) !=
                keccak256(abi.encodePacked(""))
            ) {
                trade.links.push(_links[i]);
                trade.linksLength++;
            }
        }

        emit TradeReleased(_tradeId, _buyer, trade.tradeCap, trade.sellersPart);
    }

    /**
     * @dev Get message hash for signing for resolveTrade
     */
    function resolveProof(
        bytes32 token,
        string memory _tradeId,
        string[] memory _links,
        bool _result,
        string memory _reason
    ) public view returns (bytes32 message) {
        if (_links.length == 0) _links[0] = "";
        message = keccak256(
            abi.encodePacked(
                getChainID(),
                token,
                _links[0],
                _tradeId,
                _result,
                _reason
            )
        );
    }

    /**
     * @dev Resolves trade (only for admin). Uses for resolving disputes.
     * @param _tradeId External trade id
     * @param _result Result of trade
     * @param _reason Reason of trade
     */
    function resolveTrade(
        bytes memory signature,
        bytes32 token,
        string memory _tradeId,
        string[] memory _links,
        bool _result,
        string memory _reason
    ) external {
        require(tradesIdsToTrades[_tradeId] != 0, "Escrow: Trade is not exist");
        Trade storage trade = trades[tradesIdsToTrades[_tradeId]];
        require(!trade.released, "Escrow: Trade is released");
        require(
            block.timestamp >= trade.resolveTS,
            "Escrow: To early to resolve"
        );

        bytes32 message = resolveProof(
            token,
            _tradeId,
            _links,
            _result,
            _reason
        );
        address signer = IAccess(accessControl).preAuthValidations(
            message,
            token,
            signature
        );
        require(
            IAccess(accessControl).isSigner(signer),
            "Escrow: Signer is not manager"
        );

        if (trade.paid) {
            if (_result) {
                TransferHelper.safeTransfer(
                    azx,
                    trade.seller,
                    trade.sellersPart
                );
                TransferHelper.safeTransfer(
                    azx,
                    auzWallet,
                    trade.tradeCap - trade.sellersPart
                );
            } else {
                TransferHelper.safeTransfer(azx, trade.buyer, trade.tradeCap);
            }
        }

        trade.released = true;
        for (uint256 i = 0; i < _links.length; i++) {
            if (
                keccak256(abi.encodePacked(_links[i])) !=
                keccak256(abi.encodePacked(""))
            ) {
                trade.links.push(_links[i]);
                trade.linksLength++;
            }
        }

        emit TradeResolved(signer, _tradeId, _result, _reason);
    }

    /**
     * @dev Gets trade by external trade id
     * @param _tradeId External trade id
     */
    function getTrade(string memory _tradeId)
        external
        view
        returns (
            string[] memory links,
            address seller,
            address buyer,
            uint256 linksLenght,
            uint256 tradeCap,
            uint256 sellersPart,
            bool valid,
            bool paid,
            bool finished,
            bool released
        )
    {
        Trade storage trade = trades[tradesIdsToTrades[_tradeId]];
        links = trade.links;
        linksLenght = trade.linksLength;
        seller = trade.seller;
        buyer = trade.buyer;
        tradeCap = trade.tradeCap;
        sellersPart = trade.sellersPart;
        valid = trade.valid;
        paid = trade.paid;
        finished = trade.finished;
        released = trade.released;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

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
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}