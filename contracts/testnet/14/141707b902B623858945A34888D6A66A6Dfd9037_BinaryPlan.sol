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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./internal/Base.sol";

import "./interfaces/IBinaryPlan.sol";

contract BinaryPlan is Base, IBinaryPlan, Initializable {
    uint256 public constant PERCENTAGE_FRACTION = 10_000;
    uint256 public constant MAXIMUM_BONUS_PERCENTAGE = 3_000_000;

    IAuthority public immutable cachedAuthority;

    Bonus public bonusRate;
    mapping(address => uint256) public indices;
    mapping(address => Account) public accounts;
    mapping(uint256 => address) public binaryHeap;

    constructor(IAuthority authority_) payable Base(authority_, 0) {
        cachedAuthority = authority_;
    }

    function kill() external onlyRole(Roles.OPERATOR_ROLE) {
        selfdestruct(payable(msg.sender));
    }

    function init(address root_) external initializer {
        binaryHeap[1] = root_;
        indices[root_] = 1;

        __updateAuthority(cachedAuthority);
        _checkRole(Roles.FACTORY_ROLE, msg.sender);

        Bonus memory bonus = bonusRate;
        bonus.branchRate = 300;
        bonus.directRate = 600;
        bonusRate = bonus;
    }

    function root() public view returns (address) {
        return binaryHeap[1];
    }

    function getTree(address root_)
        external
        view
        returns (address[] memory tree)
    {
        Account memory account = accounts[root_];
        uint256 level = account.leftHeight >= account.rightHeight
            ? account.leftHeight
            : account.rightHeight;
        uint256 length = 1 << (level + 1);
        tree = new address[](length);
        __traversePreorder(root_, 1, tree);
    }

    function __traversePreorder(
        address root_,
        uint256 idx,
        address[] memory addrs
    ) private view {
        if (root_ == address(0)) return;

        addrs[idx] = root_;

        __traversePreorder(
            binaryHeap[__leftChildIndexOf(root_)],
            idx << 1,
            addrs
        );
        __traversePreorder(
            binaryHeap[__rightChildIndexOf(root_)],
            (idx << 1) + 1,
            addrs
        );
    }

    function addReferrer(
        address referrer,
        address referree,
        bool isLeft
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        require(
            referree != referrer &&
                referree != address(0) &&
                referrer != address(0),
            "BINARY_PLAN: INVALID_ARGUMENT"
        );
        require(indices[referrer] != 0, "BINARY_PLAN: NON_EXISTED_REF");
        require(indices[referree] == 0, "BINARY_PLAN: EXISTED_IN_TREE");

        uint256 position = isLeft
            ? __emptyLeftChildIndexOf(referrer)
            : __emptyRightChildIndexOf(referrer);

        binaryHeap[position] = referree;

        indices[referree] = position;
        accounts[referree].directReferrer = referrer;

        address leaf = referree;
        address root_ = __parentOf(leaf);
        uint256 leafLevel = __levelOf(position);

        uint256 heightDiff;
        Account memory rootAccount;
        while (root_ != address(0)) {
            rootAccount = accounts[root_];
            heightDiff = leafLevel - __levelOf(indices[root_]);
            if (__isLeftBranch(leaf, root_)) {
                if (rootAccount.leftHeight < heightDiff)
                    rootAccount.leftHeight = uint8(heightDiff);
            } else {
                if (rootAccount.rightHeight < heightDiff)
                    rootAccount.rightHeight = uint8(heightDiff);
            }

            accounts[root_] = rootAccount;

            leaf = root_;
            root_ = __parentOf(leaf);
        }
    }

    function isPerfect(
        uint256 rootIdx_,
        uint256 depth_,
        uint256 level_
    ) public view returns (bool) {
        unchecked {
            if (depth_ == level_) return true;

            if (binaryHeap[rootIdx_] == address(0)) return true;

            uint256 left = rootIdx_ << 1;
            uint256 right = (rootIdx_ << 1) + 1;
            address leftAddr = binaryHeap[left];
            address rightAddr = binaryHeap[right];

            if (leftAddr == address(0) && rightAddr == address(0))
                return depth_ == level_;

            if (leftAddr == address(0) || rightAddr == address(0)) return false;

            if (leftAddr != address(0) && rightAddr != address(0))
                return
                    isPerfect(left, depth_, level_ + 1) &&
                    isPerfect(right, depth_, level_ + 1);

            return false;
        }
    }

    function updateVolume(address account, uint96 volume)
        external
        onlyRole(Roles.OPERATOR_ROLE)
    {
        Account memory _account = accounts[account];

        accounts[_account.directReferrer].directBonus += uint96(
            (volume * bonusRate.directRate) / PERCENTAGE_FRACTION
        );

        if (_account.maxVolume < volume) _account.maxVolume = volume;

        accounts[account] = _account;

        address leaf = account;
        address root_ = __parentOf(leaf);

        while (root_ != address(0)) {
            if (__isLeftBranch(leaf, root_))
                accounts[root_].leftVolume += volume;
            else accounts[root_].rightVolume += volume;

            leaf = root_;
            root_ = __parentOf(leaf);
        }
    }

    function withdrawableAmt(address account_)
        public
        view
        returns (uint256 claimable)
    {
        Account memory account = accounts[account_];

        uint256 branchRate = bonusRate.branchRate;

        uint256 percentageFraction = PERCENTAGE_FRACTION;
        uint256 maxReceived = (account.maxVolume * MAXIMUM_BONUS_PERCENTAGE) /
            percentageFraction;
        uint256 minHeight = account.leftHeight < account.rightHeight
            ? account.leftHeight
            : account.rightHeight;
        uint256 bonusPercentage;
        uint256 idx = indices[account_];
        for (uint256 i = 1; i <= minHeight; ) {
            unchecked {
                if (isPerfect(idx, i, 0)) bonusPercentage += branchRate;
                else break;
                ++i;
            }
        }
        uint256 bonus = account.leftVolume < account.rightVolume
            ? account.leftVolume
            : account.rightVolume;
        uint256 received = account.directBonus +
            ((bonus * bonusPercentage) / percentageFraction);

        claimable = maxReceived > received ? received : maxReceived;

        if (claimable > account.claimed) claimable -= account.claimed;
        else return 0;
    }

    function updateClaimableAmt(address account_, uint256 claimed_) external onlyRole(Roles.OPERATOR_ROLE) {
        accounts[account_].claimed += uint96(claimed_);
    }

    function numBalancedLevel(address account_)
        external
        view
        returns (uint256 numBalanced)
    {
        Account memory account = accounts[account_];
        uint256 minHeight = account.leftHeight < account.rightHeight
            ? account.leftHeight
            : account.rightHeight;
        uint256 idx = indices[account_];
        for (uint256 i = 1; i <= minHeight; ) {
            unchecked {
                if (isPerfect(idx, i, 0)) ++numBalanced;
                else break;
                ++i;
            }
        }
    }

    function isIndexLeftBranch(uint256 leafIdx, uint256 rootIdx)
        public
        pure
        returns (bool)
    {
        return rootIdx >> 1 == leafIdx;
    }

    function isLeftBranch(address leaf_, address root_)
        public
        view
        returns (bool)
    {
        uint256 leafIndex = indices[leaf_];
        uint256 rootIndex = indices[root_];
        return rootIndex >> 1 == leafIndex;
    }

    function __isLeftBranch(address leaf, address root_)
        private
        view
        returns (bool)
    {
        uint256 leafIndex = indices[leaf];
        uint256 numPath = __levelOf(leafIndex) - __levelOf(indices[root_]) - 1; // x levels requires x - 1 steps
        return (leafIndex >> numPath) & 0x1 == 0;
    }

    function __parentOf(address account_) private view returns (address) {
        return binaryHeap[indices[account_] >> 1];
    }

    function __emptyLeftChildIndexOf(address account_)
        private
        view
        returns (uint256 idx)
    {
        if (account_ == address(0)) return 1;
        while (account_ != address(0)) {
            idx = __leftChildIndexOf(account_);
            account_ = binaryHeap[idx];
        }
        return idx;
    }

    function __emptyRightChildIndexOf(address account_)
        private
        view
        returns (uint256 idx)
    {
        if (account_ == address(0)) return 1;
        while (account_ != address(0)) {
            idx = __rightChildIndexOf(account_);
            account_ = binaryHeap[idx];
        }
        return idx;
    }

    function __leftChildIndexOf(address account_)
        private
        view
        returns (uint256)
    {
        return (indices[account_] << 1);
    }

    function __rightChildIndexOf(address account_)
        private
        view
        returns (uint256)
    {
        unchecked {
            return (indices[account_] << 1) + 1;
        }
    }

    function __addLeft(address referrer, address referree) private {
        uint256 referreeIndex = __leftChildIndexOf(referrer);
        binaryHeap[referreeIndex] = referree;
        indices[referree] = referreeIndex;
    }

    function __addRight(address referrer, address referree) private {
        uint256 referreeIndex = __rightChildIndexOf(referrer);
        binaryHeap[referreeIndex] = referree;
        indices[referree] = referreeIndex;
    }

    function __levelOf(uint256 x) private pure returns (uint8 r) {
        if (x == 0) return 0;

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlEnumerableUpgradeable.sol";

import "../internal-upgradeable/interfaces/IBlacklistableUpgradeable.sol";

interface IAuthority is
    IBlacklistableUpgradeable,
    IAccessControlEnumerableUpgradeable
{
    event ProxyAccessGranted(address indexed proxy);

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;

    function pause() external;

    function unpause() external;

    function paused() external view returns (bool isPaused);

    function requestAccess(bytes32 role) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBinaryPlan {
    struct Account {
        address directReferrer;
        uint96 leftVolume;
        uint8 leftHeight;
        uint96 directBonus;
        uint8 rightHeight;
        uint96 rightVolume;
        uint96 maxVolume;
        uint96 claimed;
    }

    struct Bonus {
        uint16 directRate;
        uint16 branchRate;
    }

    function init(address root_) external;

    function getTree(
        address root
    ) external view returns (address[] memory tree);

    function addReferrer(
        address referrer,
        address referree,
        bool isLeft
    ) external;

    function updateVolume(address account, uint96 volume) external;

    function withdrawableAmt(address account_) external view returns (uint256);

    function updateClaimableAmt(address account_, uint256 claimed_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBlacklistableUpgradeable {
    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);

    function setUserStatus(address account_, bool status) external;

    function isBlacklisted(address account_) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";

import "../interfaces/IAuthority.sol";

import "../libraries/Roles.sol";

abstract contract Base {
    bytes32 private _authority;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    modifier onlyWhitelisted() {
        _checkBlacklist(msg.sender);
        _;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    event AuthorityUpdated(IAuthority indexed from, IAuthority indexed to);

    constructor(IAuthority authority_, bytes32 role_) payable {
        authority_.requestAccess(role_);
        __updateAuthority(authority_);
    }

    function updateAuthority(
        IAuthority authority_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        IAuthority old = authority();
        require(old != authority_, "BASE: ALREADY_SET");
        __updateAuthority(authority_);
        emit AuthorityUpdated(old, authority_);
    }

    function authority() public view returns (IAuthority authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(_authority.slot)
        }
    }

    function _checkBlacklist(address account_) internal view {
        require(!authority().isBlacklisted(account_), "BASE: BLACKLISTED");
    }

    function _checkRole(bytes32 role_, address account_) internal view {
        require(authority().hasRole(role_, account_), "BASE: UNAUTHORIZED");
    }

    function __updateAuthority(IAuthority authority_) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_authority.slot, authority_)
        }
    }

    function _requirePaused() internal view {
        require(authority().paused(), "BASE: NOT_PAUSED");
    }

    function _requireNotPaused() internal view {
        require(!authority().paused(), "BASE: PAUSED");
    }

    function _hasRole(
        bytes32 role_,
        address account_
    ) internal view returns (bool) {
        return authority().hasRole(role_, account_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Roles {
    bytes32 internal constant FACTORY_ROLE =
        0xdfbefbf47cfe66b701d8cfdbce1de81c821590819cb07e71cb01b6602fb0ee27;
    bytes32 internal constant CROUPIER_ROLE =
        0xca4ff35aa85b5fefc8312f1391bd040d4b445859a4a611b13d905ef8daa4b19f;
    bytes32 internal constant PROXY_ROLE =
        0x77d72916e966418e6dc58a19999ae9934bef3f749f1547cde0a86e809f19c89b;
    bytes32 internal constant SIGNER_ROLE =
        0xe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70;
    bytes32 internal constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    bytes32 internal constant OPERATOR_ROLE =
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;
    bytes32 internal constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;
    bytes32 internal constant TREASURER_ROLE =
        0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07;
}