// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "interfaces/IPlanetPlot.sol";
import "interfaces/IResources.sol";
import "interfaces/IPlotState.sol";
import "interfaces/IMoDApproveProxy.sol";
import "interfaces/IPlanetPassHandler.sol";

contract PlotHandler is AccessControl, Pausable {

    bytes32 public constant GAME_CONTROL = keccak256("GAME_CONTROL");
    bytes32 public constant PLANET_PLOT_CREATOR = keccak256("PLANET_PLOT_CREATOR");

    IPlanetPlot public planetPlot;
    IPlotState public plotState;
    IMoDApproveProxy public MoDApproveProxy;
    IResources public resources;
    IPlanetPassHandler public planetPassHandler;
    
    address private MoDTaxAccount;
    address private serverPubKey;
    
    uint public taxRate;
    uint public staticTax;
    uint public breakRent;
    uint public playerMinRent;
    
    uint public fixedRent;

    uint public maxOpenDigs = 10;

    uint public miningSafetyCap = 1000;

    struct Plot_ru_recipe {
        uint[] resourceInputIds;
        uint[] resourceInputAmounts;

        uint darInputAmount;

        uint max;
        uint add;
    }

    mapping(uint=>Plot_ru_recipe) public plotRURecipes;
    mapping(address => uint) public internalNonce;

    event Rent(address indexed renter, uint plotId, uint nrOfDigs);
    event CloseRentAndMint (address renter, uint digsClosed);
    event ReplenishUpgradeEvent(uint plotId, uint recipeId);
    event PlotRURecipeCreated(uint recipeId);
    event PlotRURecipeDeleted(uint recipeId);

    function addPlotRURecipe(
        uint _recipeId, 
        uint[] memory _RIIds,
        uint[] memory _RIAmounts,
        uint _DIAmount,
        uint _max,
        uint _add
         ) public onlyRole(GAME_CONTROL){
        require(!recipeExists(_recipeId), "recipe id taken");
        require(_add > 0, "_add must be greater than zero");
        require((_RIIds.length > 0 || _DIAmount > 0), "Must have 1 input+");

        Plot_ru_recipe storage recipe = plotRURecipes[_recipeId];

        recipe.resourceInputIds = checkResourceIds(_RIIds);
        recipe.resourceInputAmounts = validAmountArray(_RIAmounts, _RIIds.length);

        recipe.darInputAmount = _DIAmount;

        recipe.max = _max;
        recipe.add = _add;
        
        emit PlotRURecipeCreated(_recipeId);   
    }

    function removePlotRURecipe(uint _recipeId) public onlyRole(GAME_CONTROL){
        require(recipeExists(_recipeId));
        delete plotRURecipes[_recipeId];
        emit PlotRURecipeDeleted(_recipeId);
    }

    function validAmountArray(uint[] memory _arr, uint _l) internal pure returns (uint[] memory){
        require (_arr.length == _l, "Id/pre arr not same length as amount arr");
        for (uint256 index = 0; index < _arr.length; index++) {
            require(_arr[index] > 0, "Cant be zero amount");
        }
        return _arr;
    }

    function checkResourceIds(uint[] memory _rIds) internal view returns (uint[] memory){
        if(_rIds.length > 0){
            uint count = resources.getResourceCount();
            for (uint256 index = 0; index < _rIds.length; index++) {
                require(_rIds[index] < count, "Resource not exist");
                for (uint256 j = 0; j < _rIds.length; j++) {
                    if(index != j){
                        require(_rIds[index] != _rIds[j], "Can not have the same _rId input multiple times");
                    }
                }
            }
        }
        return _rIds;
    }

    function recipeExists(uint _recipeId) public view returns (bool){
        if (plotRURecipes[_recipeId].add == 0) {
            return false;
        } else {
            return true;
        }
    }

    function plotRU(uint _recipeId, uint _plotId) public whenNotPaused(){
        require(msg.sender == planetPlot.ownerOf(_plotId), "Sender not owner of plot");
        require(recipeExists(_recipeId), "Recipe id not exist");

        if(plotRURecipes[_recipeId].resourceInputIds.length > 0){
            MoDApproveProxy.resources_burnBatch(msg.sender, plotRURecipes[_recipeId].resourceInputIds, plotRURecipes[_recipeId].resourceInputAmounts);
        } 
        if (plotRURecipes[_recipeId].darInputAmount > 0){
            MoDApproveProxy.DAR_transferFrom(msg.sender, MoDTaxAccount, plotRURecipes[_recipeId].darInputAmount);
        } 
        if (plotRURecipes[_recipeId].max > 0){
            require(plotState.getMax(_plotId) == plotRURecipes[_recipeId].max, "Plot max, recipe max mismatch");
            plotState.setMax(_plotId, plotRURecipes[_recipeId].max + plotRURecipes[_recipeId].add);
            plotState.setLeft(_plotId, plotState.getMax(_plotId));
        } 
        else {
            uint left = plotState.getLeft(_plotId);
            if(left + plotRURecipes[_recipeId].add > plotState.getMax(_plotId)){
                plotState.setLeft(_plotId, plotState.getMax(_plotId));
            } else {
                plotState.setLeft(_plotId, left + plotRURecipes[_recipeId].add);
            }
        }
        emit ReplenishUpgradeEvent(_plotId, _recipeId);
    }


    function openRentPlot(
        uint _plotId, 
        uint8 _digsToOpen, 
        uint _currentRent,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public whenNotPaused(){
        bytes memory message = abi.encode(msg.sender, _plotId, _digsToOpen, internalNonce[msg.sender]);
        bytes memory prefix = "\x19Ethereum Signed Message:\n128";
        require(ecrecover(keccak256(abi.encodePacked(prefix, message)), _v, _r, _s) == serverPubKey, "Signature invalid");
        internalNonce[msg.sender]++;

        require(plotState.addressIsRenting(msg.sender) + _digsToOpen <= maxOpenDigs, "Address can not open this amount of digs until closing previous digs");

        plotState.subLeft(_plotId, _digsToOpen);
        plotState.addAddressIsRenting(msg.sender, _plotId, _digsToOpen);
        planetPassHandler.passCheck(msg.sender, _plotId, _digsToOpen);

        uint rent = plotState.getRent(_plotId);
        if(rent < playerMinRent) {
            rent = playerMinRent;
        }

        uint rentToPay;
        if (fixedRent != 0) {
            require(fixedRent == _currentRent, "WARNING: Rent mis-match");
            rentToPay = fixedRent * _digsToOpen;
        } else {
            require(rent == _currentRent, "WARNING: Rent mis-match");
            rentToPay =  rent * _digsToOpen;
        }

        uint tax = rent < breakRent ? staticTax * _digsToOpen : (rentToPay * taxRate)/100;

        MoDApproveProxy.DAR_transferFrom(msg.sender, MoDTaxAccount, tax);
        MoDApproveProxy.DAR_transferFrom(msg.sender, planetPlot.ownerOf(_plotId), rentToPay - tax);

        emit Rent(msg.sender, _plotId, _digsToOpen);
    }

    function closeRentAndMint(
        uint[] memory _resources, 
        uint[] memory _amounts,
        uint _digsToClose,
        uint _plotId,
        bytes memory _prefix,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public whenNotPaused(){
        for (uint256 i = 0; i < _amounts.length; i++) {
            require(_amounts[i] <= miningSafetyCap, "Warning: mined resource amount overflow");
        }
        bytes memory message = abi.encode(msg.sender, _resources, _amounts, _digsToClose, _plotId, internalNonce[msg.sender]);
        require(ecrecover(keccak256(abi.encodePacked(_prefix, message)), _v, _r, _s) == serverPubKey, "Signature invalid");
        internalNonce[msg.sender]++;
        
        require(_digsToClose > 0, "Can not close 0 digs");
        plotState.subAddressIsRenting(msg.sender, _plotId, _digsToClose);// will fail without good error message if underflow (gas savings)
        MoDApproveProxy.resources_mintBatch(msg.sender, _resources, _amounts);
        
        emit CloseRentAndMint(msg.sender, _digsToClose);
    }

    function setPlotRent(uint _plotId, uint _rent) public whenNotPaused(){
        require(_rent >= playerMinRent);
        require(msg.sender == planetPlot.ownerOf(_plotId), "Sender not owner of plot");
        plotState.setRent(_plotId, _rent);
    }

    function updateTax(uint _staticTax, uint _taxRate) external onlyRole(GAME_CONTROL) {
        require(_taxRate < 100, "Invalid tax rate");
        if(fixedRent != 0) {
            require(_staticTax <= fixedRent, "Invalid static tax");
        }
        staticTax = _staticTax;
        taxRate = _taxRate;
        breakRent = (_staticTax * 100) / taxRate;
        if(playerMinRent < _staticTax) {
            playerMinRent = _staticTax;
        }
    }

    function updatePlayerMinRent(uint _playerMinRent) public onlyRole(GAME_CONTROL){
        require(_playerMinRent >= staticTax, "Can not be lower than static tax");
        playerMinRent = _playerMinRent;
    }

    function updateMiningSafetyCap(uint _miningSafetyCap) public onlyRole(GAME_CONTROL){
        miningSafetyCap = _miningSafetyCap;
    }

    function updateFixedRent(uint _fixedRent) public onlyRole(GAME_CONTROL){
        require(_fixedRent >= staticTax, "Can not be lower than static tax");
        fixedRent = _fixedRent;
    }

    function updateDigLimit(uint8 _maxOpenDigs) public onlyRole(GAME_CONTROL){
        require(_maxOpenDigs > 0, "Can not be 0");
        maxOpenDigs = _maxOpenDigs;
    }

    function updateServer (address _serverPubKey) public onlyRole(GAME_CONTROL){
        serverPubKey = _serverPubKey;
    }

    function updateTaxAccount(address _MoDTaxAccount) public onlyRole(GAME_CONTROL){
        MoDTaxAccount = _MoDTaxAccount;
    }

    function createPlanet(uint _sideLength, uint _planetId) public onlyRole(PLANET_PLOT_CREATOR){
        IPlanetPlot(planetPlot).createPlanet(_sideLength, _planetId);
    }

    function mintPlotRegion( address _to, uint _planetId, uint _region) public onlyRole(PLANET_PLOT_CREATOR){
        IPlanetPlot(planetPlot).mintPlotRegion(_to, _planetId, _region);
    }

    function pauseHandler() public onlyRole(GAME_CONTROL){
        _pause();
    }
    function unpauseHandler() public onlyRole(GAME_CONTROL){
        _unpause();
    }

    constructor (
        IPlanetPlot _planetPlot,  
        IPlotState _plotState,
        IMoDApproveProxy _ModApproveProxy,
        IPlanetPassHandler _planetPassHandler,
        IResources _resources,
        address _MoDTaxAccount, 
        address _admin_address
    ) {
        planetPlot = _planetPlot;
        resources = _resources;
        MoDTaxAccount = _MoDTaxAccount;
        taxRate = 10;
        plotState = _plotState;
        MoDApproveProxy = _ModApproveProxy;
        planetPassHandler = _planetPassHandler;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin_address);
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

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

library planetPlotLib {
    struct Plot { uint max; uint left; uint rent; bool open; uint latestReplenish; }
}

interface IPlanetPlot is IERC721 {
    function mintPlotRegion(address _to, uint _planetId, uint _region) external;
    function createPlanet (uint _xy, uint _id) external;
    function openRentPlot(address _renter, uint _plotId, uint8 _digsToOpen) external returns (bool);
    function setFreePlanetPass (uint _planetId, bool _freePass) external;
    function setPlayerPlanetPass (address _renter, uint[] memory _planetIds) external;
    function rentInfo(uint _plotId) external view returns (address, uint, uint, bool);
    function setPlotOpen (address _owner, uint _plotId, bool _open) external;
    function setPlotRent (address _owner, uint _plotId, uint _rent) external;
    function replenishPlot (uint _plotId, uint _digs) external returns (bool);
    function upgradePlotMax (uint _plotId, uint _newMax) external returns (bool);
    function plotMax(uint _plotId) external view returns (uint);
    function planetExists(uint _planetId) external view returns (bool);
    function updateAutoReplenish (uint _digsPerTimeUnit, uint _replenishTimeUnit) external;
    function plotState(uint _plotId) external returns( planetPlotLib.Plot calldata );
    function planetPass(address _user, uint _planetId) external returns (bool);
}

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/interfaces/IERC1155.sol";

interface IResources is IERC1155 {
    function mintBatch(address _to, uint[] memory _resources, uint[] memory _amounts) external returns (bool);
    function createResource(string memory _resourceName) external;
    function burnBatch(address _from, uint256[] memory _ids, uint256[] memory _amounts) external returns (bool);
    function getResourceCount() external view returns (uint);
}

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlotState {
    function setMax(uint _plotId, uint _newMax) external;
    function setLeft(uint _plotId, uint _newLeft) external;
    function subLeft(uint _plotId, uint _sub) external;
    function setRent(uint _plotId, uint _newRent) external;
    function setAddressIsRenting(address _renter, uint _plotId, uint _digs) external;
    function addAddressIsRenting(address _renter, uint _plotId, uint _addDigs) external;
    function subAddressIsRenting(address _renter, uint _plotId, uint _subDigs) external;
    function getMax(uint _plotId) external view returns(uint);
    function getLeft(uint _plotId) external view returns(uint);
    function getRent(uint _plotId) external view returns(uint);
    function createPlot(uint[] calldata _plotIds) external;
    function setPlot(uint _plotId, uint _max, uint _left, uint _rent) external;
    function addressIsRenting(address _renter) external returns (uint);
}

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IMoDApproveProxy {
    function DAR_transferFrom(address _sender, address _recipient, uint256 _amount) external;
    function item_safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory _data) external;
    function resources_safeTransferFrom(address _from, address _to, uint _id, uint _amount, bytes memory _data) external;
    function resources_safeBatchTransferFrom(address _from, address _to, uint[] calldata _ids, uint[] calldata _amounts, bytes memory _data) external;
    function planetPlot_safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory _data) external;
    function item_burn(address _from, uint256[] memory _burnItemIds) external returns (bool);
    function item_mint(address _to, uint256[] memory _mintTypes) external returns (bool);
    function item_burnAndMint(address _fromTo, uint256[] memory _mintTypes, uint256[] memory _burnItemIds) external returns (bool);
    function resources_burnBatch(address _from, uint256[] memory _ids, uint256[] memory _amounts) external returns (bool);
    function resources_mintBatch(address _to, uint256[] memory _ids, uint256[] memory _amounts) external returns (bool);
}

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlanetPassHandler {
    function passCheck(address _user, uint256 _plotId, uint256 _digs) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}