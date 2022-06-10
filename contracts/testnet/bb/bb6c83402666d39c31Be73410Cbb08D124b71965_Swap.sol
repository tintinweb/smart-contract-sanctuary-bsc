/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts/access/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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


// File @openzeppelin/contracts/utils/[email protected]



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


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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


// File @openzeppelin/contracts/utils/introspection/[email protected]



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


// File @openzeppelin/contracts/utils/introspection/[email protected]



pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/access/[email protected]



pragma solidity ^0.8.0;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

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
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// File @openzeppelin/contracts/security/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
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


// File @openzeppelin/contracts/token/ERC721/[email protected]



pragma solidity ^0.8.0;

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}


// File contracts/swap/interfaces/IERC20Dec.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of decimals
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function burn(uint256 amount) external;

  function burnFrom(address sender, uint256 amount) external;

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
}


// File contracts/swap/interfaces/IMouseHauntStashing.sol


pragma solidity 0.8.9;

interface IMouseHauntStashing {
  enum Tier {
    NIL,
    F,
    E,
    D,
    C,
    B,
    A,
    S,
    SS
  }

  function tierOf(address _playerAddress) external view returns (Tier);
}


// File contracts/swap/Swap.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;






contract Swap is Pausable, AccessControl {
  using Counters for Counters.Counter;

  bytes32 internal constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  IERC20 public paymentToken;
  address public owner;
  address public treasury;

  uint256 public totalFeePaid;
  uint256 public totalFeeBurned;

  uint256 public burnFeePercentage;
  uint256 public swapFee;

  IERC721 public trustedToken;
  IMouseHauntStashing public stasher;

  Counters.Counter internal _offerIdCounter;

  mapping(uint256 => uint256) public offerIdToOfferIndex;
  mapping(uint256 => uint256) public tokenIdToOfferId;

  mapping(uint256 => Status) public tradeToStatus;
  mapping(IMouseHauntStashing.Tier => uint256) public tierToFee;

  TradeOffer[] public offers;

  enum Status {
    NIL,
    PENDING,
    EXECUTED,
    CANCELLED
  }
  struct Token {
    address addr;
    uint256 value;
  }
  struct TradeOffer {
    uint256 id;
    uint256 friendTokenId;
    uint256 traderTokenId;
    address trader;
    address friend;
    uint256 fee;
  }

  event TradeOfferCreated(
    uint256 indexed id,
    uint256 friendTokenId,
    uint256 traderTokenId,
    address indexed trader,
    address indexed friend
  );
  event TradeOfferCancelled(
    uint256 indexed id,
    uint256 friendTokenId,
    uint256 traderTokenId,
    address indexed trader,
    address indexed friend
  );
  event TradeOfferExecuted(
    uint256 indexed id,
    uint256 friendTokenId,
    uint256 traderTokenId,
    address indexed trader,
    address indexed friend
  );

  struct FeeTier {
    IMouseHauntStashing.Tier tier;
    uint256 fee;
  }
  event FeeBurned(uint256 indexed id, uint256 fee);

  constructor(
    address _owner,
    address _treasury,
    IERC20 _paymentToken,
    IERC721 _trustedToken,
    uint256 _swapFee,
    uint256 _burnFeePercentage,
    IMouseHauntStashing _stasher
  ) {
    require(_owner != address(0), "INV_OWNER");
    require(_treasury != address(0), "INV_TREASURY");
    require(_paymentToken != IERC20(address(0)), "INV_ACCEPTED_TOKEN");
    require(_trustedToken != IERC721(address(0)), "INV_TRUSTED_TOKEN");
    require(_stasher != IMouseHauntStashing(address(0)), "INV_STASHER");

    owner = _owner;
    paymentToken = _paymentToken;
    swapFee = _swapFee;
    trustedToken = _trustedToken;
    burnFeePercentage = _burnFeePercentage;
    treasury = _treasury;
    stasher = _stasher;

    TradeOffer memory tradeOffer = TradeOffer(0, 0, 0, address(0), address(0), 0);
    offers.push(tradeOffer);
    _offerIdCounter.increment();

    _setupRole(DEFAULT_ADMIN_ROLE, _owner);
    _setupRole(OPERATOR_ROLE, _owner);
  }

  function OfferStatusError(Status status) private returns (string memory) {
    if (status == Status.NIL) return "NIL";
    if (status == Status.PENDING) return "PENDING";
    if (status == Status.EXECUTED) return "EXECUTED";
    if (status == Status.CANCELLED) return "CANCELLED";
  }

  function getOffer(uint256 _offerId) external view returns (TradeOffer memory) {
    require(_offerId > 0, "IID");
    require(offerIdToOfferIndex[_offerId] < offers.length, "IID");
    TradeOffer memory tradeOffer = offers[offerIdToOfferIndex[_offerId]];
    return tradeOffer;
  }

  function getOffers() external view returns (TradeOffer[] memory) {
    return offers;
  }

  function getOfferStatus(uint256 _offerId) external view returns (Status) {
    return tradeToStatus[_offerId];
  }

  function getOfferIdCounter() external view returns (uint256) {
    return _offerIdCounter.current();
  }

  function getOfferId(uint256 _offerIndex) external view returns (uint256) {
    require(_offerIndex < offers.length, "IID");
    return offers[_offerIndex].id;
  }

  function feeValueFor(address _player) public view returns (uint256) {
    IMouseHauntStashing.Tier tier = stasher.tierOf(_player);

    if (tier == IMouseHauntStashing.Tier.NIL) return swapFee;
    return tierToFee[tier];
  }

  function setPaymentToken(IERC20 _paymentToken) external onlyRole(OPERATOR_ROLE) {
    require(_paymentToken != IERC20(address(0)), "INV_PAYMENT_TOKEN");
    paymentToken = _paymentToken;
  }

  function setStasher(IMouseHauntStashing _stasher) external onlyRole(OPERATOR_ROLE) {
    require(_stasher != IMouseHauntStashing(address(0)), "INV_STASHER");
    stasher = _stasher;
  }

  function setSwapFee(uint256 _swapFee) external onlyRole(OPERATOR_ROLE) {
    swapFee = _swapFee;
  }

  function setBurnFeePercentage(uint256 _burnFeePercentage) external onlyRole(OPERATOR_ROLE) {
    require(_burnFeePercentage <= swapFee, "INV_BURN_FEE");
    burnFeePercentage = _burnFeePercentage;
  }

  function setTrustedToken(IERC721 _trustedToken) external onlyRole(OPERATOR_ROLE) {
    require(_trustedToken != IERC721(address(0)), "INV_TRUSTED_TOKEN");
    trustedToken = _trustedToken;
  }

  function setTreasury(address _treasury) external onlyRole(OPERATOR_ROLE) {
    require(_treasury != address(0), "INV_TREASURY");
    treasury = _treasury;
  }

  function setFeePerTier(FeeTier[] calldata data) external onlyRole(OPERATOR_ROLE) {
    for (uint256 i = 0; i < data.length; i++) {
      FeeTier memory feeTier = data[i];
      tierToFee[feeTier.tier] = feeTier.fee;
    }
  }

  function _addOffer(TradeOffer memory offer) internal {
    offers.push(offer);
    offerIdToOfferIndex[offer.id] = offers.length - 1;
  }

  function _deleteOffer(uint256 offerId) internal {
    uint256 offerIndex = offerIdToOfferIndex[offerId];
    require(offerIndex < offers.length && offerIndex != 0, "Invalid offer index");

    TradeOffer memory offer = offers[offerIndex];
    require(offer.id == offerId, "Invalid offer ID");

    TradeOffer memory lastOffer = offers[offers.length - 1];

    if (lastOffer.id != offerId) {
      offers[offerIndex] = lastOffer;
      offerIdToOfferIndex[lastOffer.id] = offerIndex;
    }

    offers.pop();
    delete offerIdToOfferIndex[offerId];
    delete tokenIdToOfferId[offer.traderTokenId];
  }

  function _chargeFee(uint256 _fee, uint256 offerId) internal {
    if (_fee == 0) return;

    totalFeePaid += _fee;
    paymentToken.transferFrom(msg.sender, address(this), _fee);
  }

  function _burnFee(uint256 _fee, uint256 offerId) internal {
    if (burnFeePercentage == 0 || _fee == 0) return;

    uint256 burnFeeValue = (_fee * burnFeePercentage) / 100 ether;
    totalFeeBurned += burnFeeValue;

    emit FeeBurned(offerId, burnFeeValue);
    paymentToken.burnFrom(msg.sender, burnFeeValue);
  }

  function createTradeOffer(
    uint256 _traderTokenId,
    uint256 _friendTokenId,
    address _friend
  ) external returns (uint256) {
    require(msg.sender != address(0), "INV_ADDRESS");
    require(_friend != address(0), "INV_ADDRESS");

    require(msg.sender != _friend, "CANNOT_TRADE_WITH_SELF");
    require(_traderTokenId != _friendTokenId, "INV_TOKEN_ID");

    require(msg.sender == trustedToken.ownerOf(_traderTokenId), "NOT_OWNER");
    require(_friend == trustedToken.ownerOf(_friendTokenId), "FRIEND_NOT_OWNER");

    if (tokenIdToOfferId[_traderTokenId] != 0) {
      uint256 offerId = tokenIdToOfferId[_traderTokenId];
      tradeToStatus[offerId] = Status.CANCELLED;

      TradeOffer memory _offer = offers[offerIdToOfferIndex[offerId]];

      _deleteOffer(tokenIdToOfferId[_traderTokenId]);

      emit TradeOfferCancelled(
        _offer.id,
        _offer.friendTokenId,
        _offer.traderTokenId,
        _offer.trader,
        _offer.friend
      );
    }

    uint256 _offerId = _offerIdCounter.current();

    uint256 feeValue = feeValueFor(msg.sender);

    TradeOffer memory offer = TradeOffer({
      id: _offerId,
      friendTokenId: _friendTokenId,
      traderTokenId: _traderTokenId,
      trader: address(msg.sender),
      friend: address(_friend),
      fee: feeValue
    });

    tokenIdToOfferId[_traderTokenId] = _offerId;
    tradeToStatus[_offerId] = Status.PENDING;

    _addOffer(offer);
    _offerIdCounter.increment();

    emit TradeOfferCreated(
      offer.id,
      offer.friendTokenId,
      offer.traderTokenId,
      offer.trader,
      offer.friend
    );
    _chargeFee(feeValue, offer.id);
    return offer.id;
  }

  function executeTradeOffer(uint256 offerId) external {
    if (tradeToStatus[offerId] != Status.PENDING) {
      revert(OfferStatusError(tradeToStatus[offerId]));
    }

    uint256 offerIndex = offerIdToOfferIndex[offerId];
    TradeOffer memory offer = offers[offerIndex];

    require(msg.sender == offer.friend, "ACCESS_DENIED");
    _deleteOffer(offerId);

    if (
      offer.trader != trustedToken.ownerOf(offer.traderTokenId) ||
      offer.friend != trustedToken.ownerOf(offer.friendTokenId)
    ) {
      tradeToStatus[offer.id] = Status.CANCELLED;

      emit TradeOfferCancelled(
        offer.id,
        offer.friendTokenId,
        offer.traderTokenId,
        offer.trader,
        offer.friend
      );

      return;
    }

    tradeToStatus[offer.id] = Status.EXECUTED;

    emit TradeOfferExecuted(
      offer.id,
      offer.friendTokenId,
      offer.traderTokenId,
      offer.trader,
      offer.friend
    );

    uint256 feeValue = feeValueFor(msg.sender);

    _chargeFee(feeValue, offer.id);
    uint256 totalFee = feeValue + offer.fee;
    _burnFee(totalFee, offer.id);

    trustedToken.transferFrom(offer.trader, offer.friend, offer.traderTokenId);
    trustedToken.transferFrom(offer.friend, offer.trader, offer.friendTokenId);
  }

  function cancelTradeOffer(uint256 offerId) external {
    if (tradeToStatus[offerId] != Status.PENDING) {
      revert(OfferStatusError(tradeToStatus[offerId]));
    }

    uint256 offerIndex = offerIdToOfferIndex[offerId];
    TradeOffer memory offer = offers[offerIndex];

    require(msg.sender == offer.trader || msg.sender == offer.friend, "ACCESS_DENIED");

    _deleteOffer(offerId);

    tradeToStatus[offer.id] = Status.CANCELLED;

    emit TradeOfferCancelled(
      offer.id,
      offer.friendTokenId,
      offer.traderTokenId,
      offer.trader,
      offer.friend
    );

    totalFeePaid -= offer.fee;
    paymentToken.transferFrom(address(this), offer.trader, offer.fee);
  }

  function recoverERC20(
    address _tokenAddress,
    uint256 _amount,
    address _recipient
  ) external onlyRole(OPERATOR_ROLE) {
    IERC20(_tokenAddress).transfer(_recipient, _amount);
  }
}