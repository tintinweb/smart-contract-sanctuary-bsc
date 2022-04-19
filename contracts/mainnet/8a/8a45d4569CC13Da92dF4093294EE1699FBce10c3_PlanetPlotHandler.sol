// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "interfaces/IPlanetPlot.sol";
import "interfaces/IResources.sol";

contract PlanetPlotHandler is AccessControl, ReentrancyGuard, Pausable{

    bytes32 public constant RESOURCES_HANDLER = keccak256("RESOURCES_HANDLER");
    bytes32 public constant GAME_PAUSER = keccak256("GAME_PAUSER");
    bytes32 public constant GAME_CONTROL = keccak256("GAME_CONTROL");
    bytes32 public constant PLANET_PLOT_CREATOR = keccak256("PLANET_PLOT_CREATOR");

    IERC20 public DAR;
    IPlanetPlot public planetPlot;
    IResources public resources; 
    address private MoDTaxAccount;
    address private serverPubKey;
    
    uint private taxRate;
    uint private baseRate;
    uint public fixedRent;

    uint public maxDigsInOneTx = 5;
    uint public maxOpenDigs = 10;

    uint public miningSafetyCap = 1000;

    mapping(address => uint) public addressIsRenting;

    mapping(address => uint) public internalNonce;

    event Rent(address indexed renter, address indexed plotOwner, uint plotId, uint nrOfDigs);
    event CloseRentAndMint (address renter, uint digsClosed);

    constructor (IResources _resources, IERC20 _DAR, IPlanetPlot _planetPlot, address _MoDTaxAccount, uint8 _taxRate) {
        resources = _resources;
        DAR = _DAR;
        planetPlot = _planetPlot;
        MoDTaxAccount = _MoDTaxAccount;
        taxRate = _taxRate;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier isResourcesHandler(){
        require(hasRole(RESOURCES_HANDLER, msg.sender),"Tx not from resourcesHandler");
        _;
    }

    modifier isGameController(){
        require(hasRole(GAME_CONTROL, msg.sender),"GAME_CONTROL required");
        _;
    }

    modifier isPlanetPlotCreator(){
        require(hasRole(PLANET_PLOT_CREATOR, msg.sender),"PLANET_PLOT_CREATOR ROLE required");
        _;
    }

    modifier isGamePauser(){
        require(hasRole(GAME_PAUSER, msg.sender),"GAME_PAUSER required");
        _;
    }

    function createPlanet(uint _sideLength, uint _planetId) public isPlanetPlotCreator(){
        IPlanetPlot(planetPlot).createPlanet(_sideLength, _planetId);
    }

    function mintPlotRegion( address _to, uint _planetId, uint _region) public isPlanetPlotCreator(){
        IPlanetPlot(planetPlot).mintPlotRegion(_to, _planetId, _region);
    }

    function openRentPlot(uint _tokenId, uint8 _digsToOpen) public nonReentrant() whenNotPaused(){
        require(_digsToOpen <= maxDigsInOneTx && _digsToOpen > 0, "An address can not open this many digs in on tx");
        require((addressIsRenting[msg.sender]+_digsToOpen) <= maxOpenDigs, "Address can not open this amount of digs until closing previous digs");
        (address owner, uint left, uint rent, bool open) = IPlanetPlot(planetPlot).rentInfo(_tokenId);
        require(left >= _digsToOpen, "This amount of digs not available on plot");

        if(msg.sender != owner){
            require(open, "Plot owner is not allowing rents at this time");

            uint rentToPay;

            if (fixedRent != 0){
                rentToPay = fixedRent * _digsToOpen;
            }else{
                rentToPay = rent * _digsToOpen;
            }

            uint tax = (rentToPay * taxRate)/100;

            IERC20(DAR).transferFrom(msg.sender, MoDTaxAccount, tax);
            IERC20(DAR).transferFrom(msg.sender, owner, rentToPay - tax);
        } else {
            if(baseRate > 0){
                IERC20(DAR).transferFrom(msg.sender, MoDTaxAccount, baseRate * _digsToOpen);
            }
        }

        require(IPlanetPlot(planetPlot).openRentPlot(msg.sender, _tokenId, _digsToOpen), "Could not rent");
        addressIsRenting[msg.sender] = addressIsRenting[msg.sender] + _digsToOpen;
        emit Rent(msg.sender, owner, _tokenId, _digsToOpen);
    }

    function closeRentAndMint(
        address _renter,
        uint[] memory _resources, 
        uint[] memory _amounts,
        uint _digsToClose,
        bytes memory _prefix,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public whenNotPaused(){
        for (uint256 i = 0; i < _amounts.length; i++) {
            require(_amounts[i] <= miningSafetyCap, "Warning: mined resource amount overflow");
        }
        bytes memory message = abi.encode(_renter, _resources, _amounts, _digsToClose, internalNonce[_renter]);
        bytes32 m = keccak256(abi.encodePacked(_prefix, message));
        require(ecrecover(m, _v, _r, _s) == serverPubKey, "Signature invalid");

        internalNonce[_renter]++;
        closeRentPlot(_renter, _digsToClose);
        IResources(resources).mintBatch(_renter, _resources, _amounts);
        emit CloseRentAndMint(_renter, _digsToClose);
    }

    function closeRentPlot(address _renter, uint _nrToClose) internal whenNotPaused(){
        require(_nrToClose > 0, "Can not close 0 digs");
        require(addressIsRenting[_renter] >= _nrToClose, "Address does not have this many rents open");
        addressIsRenting[_renter] = addressIsRenting[_renter] - _nrToClose;
    }

    function setPlotRent(uint _tokenId, uint _rent) public whenNotPaused(){
        IPlanetPlot(planetPlot).setPlotRent(msg.sender, _tokenId, _rent);
    }

    function setPlotOpen(uint _tokenId, bool _open) public whenNotPaused(){
        IPlanetPlot(planetPlot).setPlotOpen(msg.sender, _tokenId, _open);
    }

    function replenishPlot(uint _tokenId, uint _digs) external isResourcesHandler() whenNotPaused() returns (bool) {
        IPlanetPlot(planetPlot).replenishPlot(_tokenId, _digs);
        return true;
    }

    function upgradePlotMax(uint _tokenId, uint _newMax) external isResourcesHandler() whenNotPaused() returns (bool) {
        IPlanetPlot(planetPlot).upgradePlotMax(_tokenId, _newMax);
        return true;
    }

    function setPlayerPlanetPass(address _renter, uint[] memory _planetIds) external isResourcesHandler() whenNotPaused(){
        IPlanetPlot(planetPlot).setPlayerPlanetPass(_renter, _planetIds);
    }

    function setFreePlanetPass(uint _planetId, bool _isFreePass) public isGameController(){
        IPlanetPlot(planetPlot).setFreePlanetPass(_planetId, _isFreePass);
    }

    function updateTaxAccount(address _MoDTaxAccount) public isGameController(){
        MoDTaxAccount = _MoDTaxAccount;
    }

    function updateTaxRate(uint8 _taxRate) public isGameController(){
        require(_taxRate < 100);
        taxRate = _taxRate;
    }

    function updateBaseRate(uint _baseRate) public isGameController(){
        baseRate = _baseRate;
    }

    function updateMiningSafetyCap(uint _miningSafetyCap) public isGameController(){
        miningSafetyCap = _miningSafetyCap;
    }

    function updateFixedRent(uint _fixedRent) public isGameController(){
        fixedRent = _fixedRent;
    }

    function updateDigLimits(uint8 _maxOpenDigs, uint8 _maxDigsInOneTx) public isGameController(){
        require(_maxOpenDigs > 0 && _maxDigsInOneTx > 0 && _maxDigsInOneTx <= _maxOpenDigs);
        maxOpenDigs = _maxOpenDigs;
        maxDigsInOneTx = _maxDigsInOneTx;
    }

    function updateServer (address _serverPubKey) public isGameController(){
        serverPubKey = _serverPubKey;
    }

    function updateAutoReplenish (uint _digsPerTimeUnit, uint _replenishTimeUnit) public isGameController(){
        IPlanetPlot(planetPlot).updateAutoReplenish(_digsPerTimeUnit, _replenishTimeUnit);
    }
    function pauseHandler() public isGamePauser(){
        _pause();
    }
    function unpauseHandler() public isGamePauser(){
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
// OpenZeppelin Contracts v4.4.0 (access/AccessControl.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlanetPlot {
    function mintPlotRegion(address _to, uint _planetId, uint _region) external;
    function createPlanet (uint _xy, uint _id) external;
    function openRentPlot(address _renter, uint _plotId, uint8 _digsToOpen) external returns (bool);
    function setFreePlanetPass (uint _planetId, bool _freePass) external;
    function setPlayerPlanetPass (address _renter, uint[] memory _planetIds) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function rentInfo(uint _plotId) external view returns (address, uint, uint, bool);
    function setPlotOpen (address _owner, uint _plotId, bool _open) external;
    function setPlotRent (address _owner, uint _plotId, uint _rent) external;
    function replenishPlot (uint _plotId, uint _digs) external returns (bool);
    function upgradePlotMax (uint _plotId, uint _newMax) external returns (bool);
    function plotMax(uint _plotId) external view returns (uint);
    function planetExists(uint _planetId) external view returns (bool);
    function updateAutoReplenish (uint _digsPerTimeUnit, uint _replenishTimeUnit) external;
}

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IResources {
    function mintBatch(address _to, uint[] memory _resources, uint[] memory _amounts) external returns (bool);
    function createResource(string memory _resourceName) external;
    function burnBatch(address _from, uint256[] memory _ids, uint256[] memory _amounts) external returns (bool);
    function getResourceCount() external view returns (uint);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

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