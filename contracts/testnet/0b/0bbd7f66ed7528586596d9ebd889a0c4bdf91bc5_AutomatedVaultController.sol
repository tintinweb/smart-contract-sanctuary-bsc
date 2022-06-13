// SPDX-License-Identifier: BUSL
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ICreditor } from "./interfaces/ICreditor.sol";
import { IDeltaNeutralVault } from "./interfaces/IDeltaNeutralVault.sol";
import { LinkList } from "./utils/LinkList.sol";

/// @title AutomatedVaultController - Controller how much investor can invest in the private automated vault
contract AutomatedVaultController is OwnableUpgradeable {
  using LinkList for LinkList.List;

  // --- Events ---
  event LogAddPrivateVaults(address indexed _caller, IDeltaNeutralVault[] _vaults);
  event LogRemovePrivateVaults(address indexed _caller, address[] _vaults);
  event LogSetCreditors(address indexed _caller, ICreditor[] _creditors);

  // --- Errors ---
  error AutomatedVaultController_Unauthorized();
  error AutomatedVaultController_OutstandingCredit();
  error AutomatedVaultController_InsufficientCredit();

  // --- State Variables ---
  ICreditor[] public creditors;
  LinkList.List public privateVaults;

  mapping(address => LinkList.List) public userVaults;
  mapping(address => mapping(address => uint256)) public userVaultShares;

  /// @notice Initialize Automated Vault Controller
  /// @param _creditors list of credit sources
  /// @param _privateVaults list of private automated vaults
  function initialize(ICreditor[] memory _creditors, IDeltaNeutralVault[] memory _privateVaults) external initializer {
    // sanity check
    uint256 _creditorLength = _creditors.length;
    for (uint8 _i = 0; _i < _creditorLength; _i++) {
      _creditors[_i].getUserCredit(address(0));
    }

    uint256 _privateVaultLength = _privateVaults.length;
    for (uint8 _i = 0; _i < _privateVaultLength; _i++) {
      _privateVaults[_i].shareToValue(1e18);
    }

    // effect
    OwnableUpgradeable.__Ownable_init();
    creditors = _creditors;

    privateVaults.init();
    for (uint8 _i = 0; _i < _privateVaults.length; ) {
      privateVaults.add(address(_privateVaults[_i]));
      unchecked {
        _i++;
      }
    }
  }

  /// @notice Get total credit for this user
  /// @param _user address of user.
  /// @return _total user's credit in USD value
  function totalCredit(address _user) public view returns (uint256) {
    uint256 _total;
    uint256 _creditorLength = creditors.length;
    for (uint8 _i = 0; _i < _creditorLength; ) {
      _total = _total + creditors[_i].getUserCredit(_user);
      // uncheck overflow to save gas
      unchecked {
        _i++;
      }
    }
    return _total;
  }

  /// @notice Get used credit for this user
  /// @param _user address of user.
  /// @return _total user's used credit in USD value from depositing into private automated vaults
  function usedCredit(address _user) public view returns (uint256) {
    uint256 _total;
    LinkList.List storage _userVaults = userVaults[_user];
    uint256 _length = _userVaults.length();

    if (_length == 0) return 0;

    address _curVault = _userVaults.getNextOf(LinkList.start);
    for (uint8 _i = 0; _i < _length; ) {
      uint256 _share = userVaultShares[_user][_curVault];
      if (_share != 0) _total += IDeltaNeutralVault(_curVault).shareToValue(_share);
      _curVault = _userVaults.getNextOf(_curVault);
      // uncheck overflow to save gas
      unchecked {
        _i++;
      }
    }

    return _total;
  }

  /// @notice Get availableCredit credit for this user
  /// @param _user address of user.
  /// @return _total remaining credit of this user
  function availableCredit(address _user) public view returns (uint256) {
    uint256 _total = totalCredit(_user);
    uint256 _used = usedCredit(_user);
    return _total > _used ? _total - _used : 0;
  }

  /// @notice add private automated vaults
  /// @param _newPrivateVaults list of private automated vaults
  function addPrivateVaults(IDeltaNeutralVault[] memory _newPrivateVaults) external onlyOwner {
    // sanity check
    uint256 _newPrivateVaultLength = _newPrivateVaults.length;
    for (uint8 _i = 0; _i < _newPrivateVaultLength; ) {
      _newPrivateVaults[_i].shareToValue(1e18);

      privateVaults.add(address(_newPrivateVaults[_i]));
      // uncheck overflow to save gas
      unchecked {
        _i++;
      }
    }

    emit LogAddPrivateVaults(msg.sender, _newPrivateVaults);
  }

  /// @notice remove private automated vaults
  /// @param _privateVaultAddresses list of private automated vaults
  function removePrivateVaults(address[] memory _privateVaultAddresses) external onlyOwner {
    // sanity check
    uint256 _newPrivateVaultLength = _privateVaultAddresses.length;
    for (uint8 _i = 0; _i < _newPrivateVaultLength; ) {
      privateVaults.remove(_privateVaultAddresses[_i], privateVaults.getPreviousOf(_privateVaultAddresses[_i]));
      // uncheck overflow to save gas
      unchecked {
        _i++;
      }
    }

    emit LogRemovePrivateVaults(msg.sender, _privateVaultAddresses);
  }

  /// @notice set private automated vaults
  /// @param _newCreditors list of credit sources
  function setCreditors(ICreditor[] memory _newCreditors) external onlyOwner {
    // sanity check
    uint256 _newCreditorLength = _newCreditors.length;
    for (uint8 _i = 0; _i < _newCreditorLength; ) {
      _newCreditors[_i].getUserCredit(address(0));
      // uncheck overflow to save gas
      unchecked {
        _i++;
      }
    }

    // effect
    creditors = _newCreditors;

    emit LogSetCreditors(msg.sender, _newCreditors);
  }

  /// @notice record user's automated vault's share from deposit
  /// @param _user share owner
  /// @param _shareAmount amount of automated vault's share
  /// @param _shareValue value of automated vault's share that will be deposited
  function onDeposit(
    address _user,
    uint256 _shareAmount,
    uint256 _shareValue
  ) external {
    // Check
    if (!privateVaults.has(msg.sender)) revert AutomatedVaultController_Unauthorized();

    if (totalCredit(_user) < (usedCredit(_user) + _shareValue)) revert AutomatedVaultController_InsufficientCredit();

    // expected delta vault to be the caller
    userVaultShares[_user][msg.sender] += _shareAmount;

    // set user's state
    _initOrInsertUserVaults(_user, msg.sender);
  }

  /// @notice update user's automated vault's share from withdrawal
  /// @param _user share owner
  /// @param _shareAmount amount of automated vault's share withdrawn
  function onWithdraw(address _user, uint256 _shareAmount) external {
    uint256 _updatedShare = userVaultShares[_user][msg.sender] <= _shareAmount
      ? 0
      : userVaultShares[_user][msg.sender] - _shareAmount;

    userVaultShares[_user][msg.sender] = _updatedShare;

    // automatically remove vault from the list
    if (_updatedShare == 0) {
      LinkList.List storage _userVaults = userVaults[_user];
      if (_userVaults.getNextOf(LinkList.start) != LinkList.empty) {
        if (_userVaults.has(msg.sender)) {
          _userVaults.remove(msg.sender, _userVaults.getPreviousOf(msg.sender));
        }
      }
    }
  }

  /// @notice Return share of user of given vault
  /// @param _user share owner
  /// @param _vault delta vault
  function getUserVaultShares(address _user, address _vault) external view returns (uint256) {
    return userVaultShares[_user][_vault];
  }

  function _initOrInsertUserVaults(address _user, address _vault) internal {
    // set user's state
    LinkList.List storage _userVaults = userVaults[_user];
    if (_userVaults.getNextOf(LinkList.start) == LinkList.empty) {
      _userVaults.init();
    }
    if (!_userVaults.has(_vault)) {
      _userVaults.add(_vault);
    }
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

// SPDX-License-Identifier: BUSL
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

interface ICreditor {
  function getUserCredit(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

interface IDeltaNeutralVault {
  function shareToValue(uint256 _shareAmount) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.12 <0.9.0;

library LinkList {
  address internal constant start = address(1);
  address internal constant end = address(1);
  address internal constant empty = address(0);

  struct List {
    uint256 llSize;
    mapping(address => address) next;
  }

  function init(List storage list) internal returns (List storage) {
    list.next[start] = end;

    return list;
  }

  function has(List storage list, address addr) internal view returns (bool) {
    return list.next[addr] != empty;
  }

  function add(List storage list, address addr) internal returns (List storage) {
    require(!has(list, addr), "existed");
    list.next[addr] = list.next[start];
    list.next[start] = addr;
    list.llSize++;

    return list;
  }

  function remove(
    List storage list,
    address addr,
    address prevAddr
  ) internal returns (List storage) {
    require(has(list, addr), "!exist");
    require(list.next[prevAddr] == addr, "wrong prev");
    list.next[prevAddr] = list.next[addr];
    list.next[addr] = empty;
    list.llSize--;

    return list;
  }

  function getAll(List storage list) internal view returns (address[] memory) {
    address[] memory addrs = new address[](list.llSize);
    address curr = list.next[start];
    for (uint256 i = 0; curr != end; i++) {
      addrs[i] = curr;
      curr = list.next[curr];
    }
    return addrs;
  }

  function getPreviousOf(List storage list, address addr) internal view returns (address) {
    address curr = list.next[start];
    require(curr != empty, "!inited");
    for (uint256 i = 0; curr != end; i++) {
      if (list.next[curr] == addr) return curr;
      curr = list.next[curr];
    }
    return end;
  }

  function getNextOf(List storage list, address curr) internal view returns (address) {
    return list.next[curr];
  }

  function length(List storage list) internal view returns (uint256) {
    return list.llSize;
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