// SPDX-License-Identifier: ANCHISA PINYO
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface ITHB {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external returns (uint256);

    function allowance(address owner, address spender)
        external
        returns (uint256);

    function transfer(address recipient, uint256 amount) external;
}

contract Auction is AccessControl {
    struct Order {
        uint256 orderId;
        address owner;
        string zone;
        uint256 vol;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        bool isEvaluated;
    }
    struct Offer {
        uint256 offerId;
        uint256 orderId;
        address owner;
        uint256 vol;
        string zone;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        bool isAccepted;
        bool isEvaluated;
        uint256 reducedDemand;
        uint256 incentive;
    }

    ITHB THB;
    using Counters for Counters.Counter;
    bytes32 public DRO_ROLE = keccak256("DRO_ROLE");
    Counters.Counter private _offerIdCounter;
    Counters.Counter private _orderIdCounter;
    mapping(uint256 => Order) public orders;
    mapping(uint256 => Offer[]) public offers;
    uint256[] public orderId;

    constructor(address _THB) {
        _grantRole(DRO_ROLE, msg.sender);
        THB = ITHB(_THB);
    }

    function createOrder(
        uint256 _capacity,
        uint256 _maxPrice,
        string memory _zone
    ) public onlyRole(DRO_ROLE) {
        require(
            THB.balanceOf(msg.sender) > _capacity * _maxPrice * 1 ether,
            "Balance is not enough"
        );
        require(_capacity > 0, "Capacity > 0");
        uint256 _orderId = _orderIdCounter.current();

        orders[_orderId] = Order({
            orderId: _orderId,
            owner: msg.sender,
            zone: _zone,
            vol: _capacity,
            price: _maxPrice,
            startTime: block.timestamp,
            endTime: block.timestamp + 10 minutes,
            isEvaluated: false
        });

        orderId.push(_orderId);
        _orderIdCounter.increment();

        THB.transferFrom(
            msg.sender,
            address(this),
            _capacity * _maxPrice * 1 ether
        );
    }

    function getOrder() public view returns (Order[] memory) {
        Order[] memory _order = new Order[](orderId.length);

        for (uint256 i = 0; i < orderId.length; i++) {
            _order[i] = orders[orderId[i]];
        }
        return _order;
    }

    function getOrderId() public view returns (uint256[] memory) {
        return orderId;
    }

    function deleteOrder(uint256 _orderId) public onlyRole(DRO_ROLE) {
        delete orders[_orderId];
        for (uint256 i = 0; i < orderId.length; i++) {
            if (_orderId == orderId[i]) {
                orderId[i] = orderId[orderId.length - 1];
                orderId.pop();
            }
        }
    }

    function createOffer(
        uint256 _vol,
        uint256 _price,
        uint256 _orderId,
        string memory _zone
    ) public {
        require(_vol > 0, "Vol > 0");
        require(
            _price >= 0 && _price <= orders[_orderId].price,
            "0 <= Price <= maxPrice"
        );
        require(
            keccak256(abi.encodePacked(_zone)) ==
                keccak256(abi.encodePacked(orders[_orderId].zone)),
            "The zone must be the same as order"
        );
        uint256 _offerId = _offerIdCounter.current();

        offers[_orderId].push(
            Offer({
                offerId: _offerId,
                orderId: _orderId,
                owner: msg.sender,
                vol: _vol,
                zone: _zone,
                price: _price,
                startTime: block.timestamp,
                endTime: orders[_orderId].endTime,
                isAccepted: false,
                isEvaluated: false,
                reducedDemand: 0,
                incentive: 0
            })
        );

        _offerIdCounter.increment();
        sortOffer(_orderId);
    }

    function sortOffer(uint256 _orderId) internal {
        Offer[] memory _offer = new Offer[](1);
        for (uint8 i = 0; i < offers[_orderId].length; i++) {
            for (uint8 j = i + 1; j < offers[_orderId].length; j++) {
                if (offers[_orderId][j].price < offers[_orderId][i].price) {
                    _offer[0] = offers[_orderId][i];
                    offers[_orderId][i] = offers[_orderId][j];
                    offers[_orderId][j] = _offer[0];
                }
            }
        }
    }

    function deleteOffer(uint256 _offerId, uint256 _orderId) public {
        uint256 x;
        for (uint256 i = 0; i < offers[_orderId].length; i++) {
            if (offers[_orderId][i].offerId == _offerId) {
                x = i;
                break;
            }
        }
        require(offers[_orderId][x].owner == msg.sender, "Only owners can delete their own offer");
        offers[_orderId][x] = offers[_orderId][offers[_orderId].length - 1];
        offers[_orderId].pop();
        sortOffer(_orderId);
    }

    function closeAuction(uint256 _orderId) public onlyRole(DRO_ROLE){
        uint256 accVol = 0;
        uint256 x;

        for (uint256 i = 0; i < offers[_orderId].length; i++) {
            if (accVol < orders[_orderId].vol) {
                accVol = accVol + offers[_orderId][i].vol;
                x = i;
            } else if (accVol >= orders[_orderId].vol) {
                break;
            }
        }

        if (accVol == orders[_orderId].vol) {
            for (uint256 i = 0; i <= x; i++) {
                offers[_orderId][i].isAccepted = true;
            }
        } else if (accVol > orders[_orderId].vol) {
            for (uint256 i = 0; i < x; i++) {
                offers[_orderId][i].isAccepted = true;
            }

            uint256 accepted = orders[_orderId].vol -
                (accVol - offers[_orderId][x].vol);

            uint256 rejected = offers[_orderId][x].vol -
                (orders[_orderId].vol - (accVol - offers[_orderId][x].vol));

            offers[_orderId].push(offers[_orderId][x]);
            offers[_orderId][offers[_orderId].length].vol = rejected;

            offers[_orderId][x].vol = accepted;
            offers[_orderId][x].isAccepted = true;
        }
    }

    function getOfferByOwner(address _owner, uint256 _orderId)
        public
        view
        returns (Offer[] memory)
    {
        uint256 x;

        for (uint256 i = 0; i < offers[_orderId].length; i++) {
            if (offers[_orderId][i].owner == _owner) {
                x++;
            }
        }
        Offer[] memory _offers = new Offer[](x);

        for (uint256 i = 0; i < x; i++) {
            if (offers[_orderId][i].owner == _owner) {
                _offers[i] = offers[_orderId][i];
            }
        }
        return _offers;
    }

    function getAcceptedOfferPrice(uint256 _offerId, uint256 _orderId)
        public
        view
        returns (uint256 _price)
    {
        for (uint256 i = 0; i < offers[_orderId].length; i++) {
            if (
                offers[_orderId][i].offerId == _offerId &&
                offers[_orderId][i].isAccepted == true &&
                offers[_orderId][i].isEvaluated == false
            ) {
                _price = offers[_orderId][i].price;
            }
        }
        return _price;
    }

    function getAcceptedOfferVol(uint256 _offerId, uint256 _orderId)
        public
        view
        returns (uint256 _vol)
    {
        for (uint256 i = 0; i < offers[_orderId].length; i++) {
            if (
                offers[_orderId][i].offerId == _offerId &&
                offers[_orderId][i].isAccepted == true &&
                offers[_orderId][i].isEvaluated == false
            ) {
                _vol = offers[_orderId][i].vol;
            }
        }
        return _vol;
    }

    function getOfferByOrderId(uint256 _orderId)
        public
        view
        returns (Offer[] memory)
    {
        Offer[] memory _offers = new Offer[](offers[_orderId].length);

        for (uint256 i = 0; i < offers[_orderId].length; i++) {
            _offers[i] = offers[_orderId][i];
        }
        return _offers;
    }

    function updateOrderStatus(uint256 _orderId) public {
        orders[_orderId].isEvaluated = true;
    }

    function updateOfferStatus(
        uint256 _orderId,
        uint256 _offerId,
        uint256 _reducedDemand,
        uint256 _incentive
    ) public {
        for (uint256 i = 0; i < offers[_orderId].length; i++) {
            if (offers[_orderId][i].offerId == _offerId) {
                offers[_orderId][i].isEvaluated = true;
                offers[_orderId][i].reducedDemand = _reducedDemand;
                offers[_orderId][i].incentive = _incentive;
            }
        }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
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
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
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

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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