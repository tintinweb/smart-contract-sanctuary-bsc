// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./lib/Pausable.sol";
import "./lib/AccessControl.sol";
import "./lib/Counters.sol";
import "./lib/SafeMath.sol";
import "./lib/IERC20.sol";
import "./IPLAYERZ.sol";
import "./ITICKETZ.sol";

contract Milez is Pausable, AccessControl {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant GAME_ROLE = keccak256("GAME_ROLE");
    bytes32 public constant GAME_ADMIN = keccak256("GAME_ADMIN");

    Counters.Counter private _milezPkgIDCounter;
    Counters.Counter private _flierTierIDCounter;

    IERC20 private _busd;
    IPLAYERZ private _playerz;
    ITICKETZ private _ticketz;

    address private _receivingWallet;

    struct MilezPkg {
        bool isPkg;
        bool isActive;
        uint256 milezCount;
        uint256 pkgPrice;
        uint256 standbyzBonus;
    }
    mapping (uint256 => MilezPkg) private _milezPkgs;

    mapping (bytes32 => uint256) private _playerBalances;

    uint256 private _totalMilezBalance;

    struct FlyerTier {
        bool isTier;
        bool isActive;
        string tierName;
        uint256 pkgPrice;
    }
    mapping (uint256 => FlyerTier) private _flyerTierz;

    constructor(IERC20 BUSD, address receivingWallet) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GAME_ROLE, msg.sender);
        _grantRole(GAME_ADMIN, msg.sender);
        _busd = IERC20(BUSD);
        _totalMilezBalance = 0;
        _receivingWallet = receivingWallet;
    }

    function pause() external onlyRole(GAME_ADMIN) {_pause();}
    function unpause() external onlyRole(GAME_ADMIN) {_unpause();}

    function setPLAYERZ(IPLAYERZ PLAYERZ) external onlyRole(GAME_ADMIN) {
        _playerz = IPLAYERZ(PLAYERZ);
    }

    function setTICKETZ(ITICKETZ TICKETZ) external onlyRole(GAME_ADMIN) {
        _ticketz = ITICKETZ(TICKETZ);
    }

    /**
     * @dev ADMIN - 
     */
    function createMilezPkg
    (
        uint256 _milezCount,
        uint256 _pkgPrice,
        uint256 _standbyzBonus
    )
    external onlyRole(GAME_ADMIN)
    {
        uint256 pkgId = _milezPkgIDCounter.current();
        _milezPkgIDCounter.increment();
        _milezPkgs[pkgId] = MilezPkg({
            isPkg: true,
            isActive: true,
            milezCount: _milezCount,
            pkgPrice: _pkgPrice,
            standbyzBonus: _standbyzBonus
        });
    }

    /**
     * @dev ADMIN - 
     */
    function updateMilesPkg
    (
        uint256 pkgId,
        bool _isActive,
        uint256 _milezCount,
        uint256 _pkgPrice,
        uint256 _standbyzBonus
    )
    external onlyRole(GAME_ADMIN)
    {
        require(_milezPkgs[pkgId].isPkg, "Package not found");
        MilezPkg storage pkg = _milezPkgs[pkgId];
        pkg.isActive = _isActive;
        pkg.milezCount = _milezCount;
        pkg.pkgPrice = _pkgPrice;
        pkg.standbyzBonus = _standbyzBonus;
    }

    /**
     * @dev ADMIN - 
     */
    function getMilezPkg
    (
        uint256 pkgId
    )
    external view
    returns (
        bool isActive,
        uint256 milezCount,
        uint256 pkgPrice,
        uint256 standbyzBonus
    ) {
        require(_milezPkgs[pkgId].isPkg, "Package not found");
        MilezPkg memory pkg = _milezPkgs[pkgId];
        isActive = pkg.isActive;
        milezCount = pkg.milezCount;
        pkgPrice = pkg.pkgPrice;
        standbyzBonus = pkg.standbyzBonus;
    }

    /**
     * @dev ADMIN - 
     */
    function purchaseMilezPkg
    (
        bytes32 playerId,
        uint256 pkgId
    )
    external
    {
        require(_milezPkgs[pkgId].isPkg, "Package not found");
        MilezPkg memory pkg = _milezPkgs[pkgId];
        _busd.transferFrom(tx.origin, _receivingWallet, pkg.pkgPrice);
        addPlayerMilez(playerId, pkg.milezCount);
        if (pkg.standbyzBonus > 0) {
            _ticketz.addPlayerStandbyz(playerId, pkg.standbyzBonus);
        }
    }

    /**
     * @dev Adds Milez to player account
     */
    function addPlayerMilez
    (
        bytes32 playerId,
        uint256 milezCount
    )
    public onlyRole(GAME_ROLE)
    {
        _playerBalances[playerId] = _playerBalances[playerId].add(milezCount);
        _totalMilezBalance = _totalMilezBalance.add(milezCount);
    }

    /**
     * @dev Spends Milez from player account
     */
    function spendPlayerMilez
    (
        bytes32 playerId,
        uint256 milezCount
    )
    public onlyRole(GAME_ROLE)
    {
        require(_playerBalances[playerId] >= milezCount, "Not enough Milez available.");
        _playerBalances[playerId] = _playerBalances[playerId].sub(milezCount);
        _totalMilezBalance = _totalMilezBalance.sub(milezCount);
    }

    /**
     * @dev Admin function to adjust milez balance for a user
     */
    function setPlayerMilez
    (
        bytes32 playerId,
        uint256 milezCount
    )
    external onlyRole(GAME_ROLE)
    {
        uint256 beforeAmount = _playerBalances[playerId];
        _totalMilezBalance = _totalMilezBalance.sub(beforeAmount);
        _playerBalances[playerId] = milezCount;
        _totalMilezBalance = _totalMilezBalance.add(milezCount);
    }

    /**
     * @dev Get the milez balance for a player
     */
    function getPlayerMilez
    (
        bytes32 playerId
    )
    external view onlyRole(GAME_ROLE)
    returns (uint256 milezBalance)
    {
        milezBalance = _playerBalances[playerId];
    }

    /**
     * @dev Get the milez balance for the entire system
     */
    function getAllMilez()
    external view onlyRole(GAME_ADMIN)
    returns (uint256 milezBalance)
    {
        milezBalance = _totalMilezBalance;
    }

    /**
     * @dev ADMIN - Set receiving address for BUSD payments
     */
    function setReceivingWallet
    (
        address newAddress
    )
    external onlyRole(GAME_ADMIN)
    {
        _receivingWallet = newAddress;
    }

    /**
     * @dev ADMIN - Get receiving address for BUSD payments
     */
    function getReceivingWallet()
    external view onlyRole(GAME_ADMIN)
    returns (address receivingWallet)
    {
        receivingWallet = _receivingWallet;
    }

    /**
     * @dev ADMIN - 
     */
    function createFlyerTier
    (
        string memory _tierName,
        uint256 _pkgPrice
    )
    external onlyRole(GAME_ADMIN)
    {
        uint256 pkgId = _flierTierIDCounter.current();
        _flierTierIDCounter.increment();
        _flyerTierz[pkgId] = FlyerTier({
            isTier: true,
            isActive: true,
            tierName: _tierName,
            pkgPrice: _pkgPrice
        });
    }

    /**
     * @dev ADMIN - 
     */
    function updateFlyerTier
    (
        uint256 pkgId,
        bool _isActive,
        string memory _tierName,
        uint256 _pkgPrice
    )
    external onlyRole(GAME_ADMIN)
    {
        require(_flyerTierz[pkgId].isTier, "Tier not found");
        FlyerTier storage tier = _flyerTierz[pkgId];
        tier.isActive = _isActive;
        tier.tierName = _tierName;
        tier.pkgPrice = _pkgPrice;
    }

    /**
     * @dev ADMIN - 
     */
    function getFlyerTier
    (
        uint256 tierId
    )
    external view
    returns (
        bool isActive,
        string memory tierName,
        uint256 pkgPrice
    ) {
        require(_flyerTierz[tierId].isTier, "Tier not found");
        FlyerTier memory tier = _flyerTierz[tierId];
        isActive = tier.isActive;
        tierName = tier.tierName;
        pkgPrice = tier.pkgPrice;
    }

    /**
     * @dev ADMIN - 
     */
    function purchaseFlyerTier
    (
        bytes32 playerId,
        uint256 pkgId
    )
    external
    {
        FlyerTier memory tier = _flyerTierz[pkgId];
        require(tier.isTier, "Tier not found");
        require(_playerz.getPlayerFlyerTier(playerId) < pkgId, "Current tier is higher.");
        spendPlayerMilez(playerId, tier.pkgPrice);
        _playerz.setPlayerFlyerTier(playerId, pkgId);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "./Context.sol";
import "./Strings.sol";
import "./ERC165.sol";

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
        _checkRole(role);
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
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
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
library SafeMath {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the Playerz contract
 */
interface IPLAYERZ {

    enum PlayerRanks{ CADET, ENS, LTJG, LT, LCDR, CDR, CAPT, RDML, RADM, VADM, ADM, FADM }
    function registerPlayer(address nftContract, uint256 tokenId) external;
    function registerPlayer(address nftContract, uint256 tokenId, string memory screenName,
                            PlayerRanks playerRank, string memory avatarURL, uint256 flyerTier, uint256 guild, uint256 experiencePTS) external;
    function getPlayer(bytes32 _playerId) external view returns(bytes32 playerId, uint256 registrationBlock, uint256 registrationTimestamp, 
                                                                string memory screenName, PlayerRanks playerRank, string memory avatarURL,
                                                                uint256 flyerTier, uint256 guild, uint256 experiencePTS);
    function isPlayer(bytes32 _playerId) external view returns(bool isValid);
    function getPlayerId(address nftContract, uint256 tokenId) external view returns(bytes32 playerId);
    function setPlayerFlyerTier(bytes32 _playerId, uint256 _flyerTier) external;
    function getPlayerFlyerTier(bytes32 _playerId) external view returns (uint256 flyerTier);
    function pause() external;
    function unpause() external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the Playerz contract
 */
interface ITICKETZ {

    function addPlayerTicketz(bytes32 playerId, uint256 seatCount, uint256 ticketCount) external;
    function spendPlayerTicketz(bytes32 playerId, uint256 seatCount, uint256 ticketCount) external;
    function setPlayerTicketz(bytes32 playerId, uint256 seatCount, uint256 ticketCount) external;
    function listPlayerTicketz(bytes32 playerId) external view returns (uint256[7] memory seats, uint256[7] memory count);
    function listAllTicketz() external view returns (uint256[7] memory seats, uint256[7] memory count);
    function addPlayerStandbyz(bytes32 playerId, uint256 ticketCount) external;
    function spendPlayerStandbyz(bytes32 playerId) external;
    function listPlayerStandbyz(bytes32 playerId) external view returns (uint256 count);
    function setPlayerStandbyz(bytes32 playerId, uint256 ticketCount) external;
    function createTicketPkg(uint256 _ticketCount, uint256 _seatsPerTicket, uint256 _ticketClass, uint256 _pkgPrice, uint256 _milezBonus, uint256 _standbyzBonus) external;
    function updateTicketPkg(uint256 pkgId, bool _isActive, uint256 _ticketCount, uint256 _seatsPerTicket, uint256 _ticketClass, uint256 _pkgPrice, uint256 _milezBonus, uint256 _standbyzBonus) external;
    function getTicketPkg(uint256 pkgId) external view returns(bool isActive, uint256 ticketCount, uint256 seatsPerTicket, uint256 ticketClass, uint256 pkgPrice, uint256 milezBonus, uint256 standbyzBonus);
    function purchaseTicketPkg(bytes32 playerId, uint256 pkgId) external;
    function setReceivingWallet(address newAddress) external;
    function getReceivingWallet() external view returns (address receivingWallet);
    function pause() external;
    function unpause() external;

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