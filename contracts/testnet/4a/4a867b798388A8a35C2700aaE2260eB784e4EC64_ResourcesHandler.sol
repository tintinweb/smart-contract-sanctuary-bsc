// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "interfaces/IPlanetPlot.sol";
import "interfaces/IResources.sol";
import "interfaces/IItems.sol";
import "interfaces/IPlanetPlotHandler.sol";
import "interfaces/IResourceTracker.sol";

contract ResourcesHandler is AccessControl, ReentrancyGuard, Pausable {

    bytes32 public constant RECIPE_CREATOR = keccak256("RECIPE_CREATOR");
    bytes32 public constant GAME_CONTROL = keccak256("GAME_CONTROL");
    bytes32 public constant RESOURCE_ITEM_CREATOR = keccak256("RESOURCE_ITEM_CREATOR");
    bytes32 public constant GAME_PAUSER = keccak256("GAME_PAUSER");

    address private MoDTaxAccount;
    address public planetPlotHandler;
    IPlanetPlot public planetPlot;
    IResources public resources; 
    IItems public items;
    IResourceTracker public resourceTracker;
    IERC20 public DAR;

    mapping(uint=>Crafting_recipe) public craftingRecipes;
    mapping(uint=>Plot_ru_recipe) public plotRURecipes;
    mapping(uint=>Planet_pass_recipe) public planetPassRecipes;
    
    struct Crafting_recipe {
        uint[] resourceInputIds;
        uint[] resourceInputAmounts;

        uint[] itemInputPrefixes;

        uint darInputAmount;

        uint[] resourceOutputIds;
        uint[] resourceOutputAmounts;

        uint[] itemOutputPrefixes;
    }

    struct Plot_ru_recipe {
        uint[] resourceInputIds;
        uint[] resourceInputAmounts;

        uint darInputAmount;

        uint max;
        uint add;
    }

    struct Planet_pass_recipe {
        uint darInputAmount; 
        uint[] planetIds;
    }

    event RecipeEvent(uint recipeId, uint8 reciepeType, bool add);
    event CraftEvent(address crafter, uint recipeId);
    event ReplenishUpgradeEvent(uint plotId, uint recipeId);
    event PlanetPassEvent(address player, uint[] planetIds);

    constructor (IResources _resources, IItems _items, IERC20 _DAR, address _MoDTaxAccount, IPlanetPlot _planetPlot, IResourceTracker _resourceTracker) {
        resources = _resources;
        items = _items;
        DAR = _DAR;
        MoDTaxAccount = _MoDTaxAccount;
        planetPlot = _planetPlot;
        resourceTracker = _resourceTracker;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier isRecipeCreator(){
        require(hasRole(RECIPE_CREATOR, msg.sender),"RECIPE_CREATOR required");
        _;
    }

    modifier isGameController(){
        require(hasRole(GAME_CONTROL, msg.sender),"GAME_CONTROL required");
        _;
    }

    modifier isResourceItemCreator(){
        require(hasRole(RESOURCE_ITEM_CREATOR, msg.sender),"RESOURCE_ITEM_CREATOR required");
        _;
    }

    modifier isGamePauser(){
        require(hasRole(GAME_PAUSER, msg.sender),"GAME_PAUSER required");
        _;
    }

    function createResource(string memory _resourceName) public isResourceItemCreator(){
        IResources(resources).createResource(_resourceName);
    }

    function createItem(uint _prefix) public isResourceItemCreator(){
        IItems(items).createItemType(_prefix);
    }

    function addCraftingRecipe(
        uint _recipeId, 
        uint[] memory _RIIds,
        uint[] memory _RIAmounts,
        uint[] memory _IIPrefixes,
        uint _DIAmount,
        uint[] memory _ROIds,
        uint[] memory _ROAmounts,
        uint[] memory _IOPrefixes
         ) public isRecipeCreator(){
        require(!recipeExists(_recipeId, 1), "Recipe id taken");

        require(_RIIds.length > 0 || _IIPrefixes.length > 0 || _DIAmount > 0, "Must have 1 input+");
        require(_ROIds.length > 0 || _IOPrefixes.length > 0,"Must have 1 output+");

        Crafting_recipe storage recipe  = craftingRecipes[_recipeId];

        recipe.resourceInputIds = checkResourceIds(_RIIds);
        recipe.resourceInputAmounts = validAmountArray(_RIAmounts, _RIIds.length);

        recipe.itemInputPrefixes = checkItemPrefixes(_IIPrefixes);

        recipe.darInputAmount = _DIAmount;

        recipe.resourceOutputIds = checkResourceIds(_ROIds);
        recipe.resourceOutputAmounts = validAmountArray(_ROAmounts, _ROIds.length);

        recipe.itemOutputPrefixes = checkItemPrefixes(_IOPrefixes);

        emit RecipeEvent(_recipeId, 1, true);
    }
        
    function removeCraftingRecipe(uint _recipeId) public isRecipeCreator(){
        require(recipeExists(_recipeId, 1));
        delete craftingRecipes[_recipeId];
        emit RecipeEvent(_recipeId, 1, false);
    }

    function addPlotRURecipe(
        uint _recipeId, 
        uint[] memory _RIIds,
        uint[] memory _RIAmounts,
        uint _DIAmount,
        uint _max,
        uint _add
         ) public isRecipeCreator(){
        require(!recipeExists(_recipeId, 2), "recipe id taken");
        require(_add > 0, "_add must be greater than zero");
        require((_RIIds.length > 0 || _DIAmount > 0), "Must have 1 input+");

        Plot_ru_recipe storage recipe = plotRURecipes[_recipeId];

        recipe.resourceInputIds = checkResourceIds(_RIIds);
        recipe.resourceInputAmounts = validAmountArray(_RIAmounts, _RIIds.length);

        recipe.darInputAmount = _DIAmount;

        recipe.max = _max;
        recipe.add = _add;
        
        emit RecipeEvent(_recipeId, 2, true);
    }

    function removePlotRURecipe(uint _recipeId) public isRecipeCreator(){
        require(recipeExists(_recipeId, 2));
        delete plotRURecipes[_recipeId];
        emit RecipeEvent(_recipeId, 2, false);
    }

    function addPlanetPassRecipe(
        uint _recipeId, 
        uint _DIAmount,
        uint[] memory _planetIds
         ) public isRecipeCreator(){
        require(!recipeExists(_recipeId, 3), "recipe id taken");
        require(_DIAmount > 0, "DAR input cant be 0");
        require (_planetIds.length > 0, "Must have 1+ planet output");

        planetPassRecipes[_recipeId].darInputAmount = _DIAmount;
        planetPassRecipes[_recipeId].planetIds = checkPlanetIds(_planetIds);
        
        emit RecipeEvent(_recipeId, 3, true);
    }

    function removePlanetPassRecipe(uint _recipeId) public isRecipeCreator(){
        require(recipeExists(_recipeId, 3));
        delete planetPassRecipes[_recipeId];
        emit RecipeEvent(_recipeId, 3, false);
    }

    function recipeExists(uint _recipeId, uint8 _type) public view returns (bool){
        if(_type == 1){
            if (craftingRecipes[_recipeId].resourceOutputIds.length == 0 && craftingRecipes[_recipeId].itemOutputPrefixes.length == 0) {
                return false;
            } else {
                return true;
            }
        }else if (_type == 2){
            if (plotRURecipes[_recipeId].add == 0) {
                return false;
            } else {
                return true;
            }
        }else{
            if (planetPassRecipes[_recipeId].planetIds.length == 0) {
                return false;
            } else {
                return true;
            }
        }
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
            uint count = IResources(resources).getResourceCount();
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

    function checkItemPrefixes(uint[] memory _iPrefixes) internal view returns (uint[] memory){
        if(_iPrefixes.length > 0){   
            for (uint256 index = 0; index < _iPrefixes.length; index++) {
                require(IItems(items).prefixExists(_iPrefixes[index]), "Item not exist");
            }
        }
        return _iPrefixes;
    }

    function checkPlanetIds(uint[] memory _planetIds) internal view returns (uint[] memory){
        for (uint256 index = 0; index < _planetIds.length; index++) {
            require(IPlanetPlot(planetPlot).planetExists(_planetIds[index]), "Planet not exist");
        }
        return _planetIds;
    }

    function craft(uint _recipeId, uint[] memory _tokenIds) public nonReentrant() whenNotPaused(){
        require(recipeExists(_recipeId, 1), "Recipe id not exist");

        if (craftingRecipes[_recipeId].darInputAmount > 0 ){
            require(IERC20(DAR).transferFrom(msg.sender, MoDTaxAccount, craftingRecipes[_recipeId].darInputAmount));
        } 
        if (craftingRecipes[_recipeId].resourceInputIds.length > 0){
            require(IResources(resources).burnBatch(msg.sender, craftingRecipes[_recipeId].resourceInputIds, craftingRecipes[_recipeId].resourceInputAmounts));
            IResourceTracker(resourceTracker).deductFromBalanceBatch(msg.sender, craftingRecipes[_recipeId].resourceInputIds, craftingRecipes[_recipeId].resourceInputAmounts);
        }

        if (craftingRecipes[_recipeId].itemInputPrefixes.length > 0 && craftingRecipes[_recipeId].itemOutputPrefixes.length > 0){
            itemInputCheck(_recipeId, _tokenIds);
            require(IItems(items).burnAndMint(msg.sender, craftingRecipes[_recipeId].itemOutputPrefixes, _tokenIds));
        }else{
            if (craftingRecipes[_recipeId].itemInputPrefixes.length > 0){
                itemInputCheck(_recipeId, _tokenIds);
                require(IItems(items).burn(msg.sender, _tokenIds));
            }
            if (craftingRecipes[_recipeId].itemOutputPrefixes.length > 0){
                require(IItems(items).mint(msg.sender, craftingRecipes[_recipeId].itemOutputPrefixes));
            }
        }
        if (craftingRecipes[_recipeId].resourceOutputIds.length > 0){
            require(IResources(resources).mintBatch(msg.sender, craftingRecipes[_recipeId].resourceOutputIds, craftingRecipes[_recipeId].resourceOutputAmounts));
            IResourceTracker(resourceTracker).addToBalanceBatch(msg.sender, craftingRecipes[_recipeId].resourceOutputIds, craftingRecipes[_recipeId].resourceOutputAmounts);
        }
        emit CraftEvent(msg.sender, _recipeId);
    }

    function itemInputCheck(uint _recipeId, uint[] memory _tokenIds) internal view {
        require(craftingRecipes[_recipeId].itemInputPrefixes.length == _tokenIds.length, "Recipe - tokenIds arr no match");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(craftingRecipes[_recipeId].itemInputPrefixes[i] == prefixStrip(_tokenIds[i]), "Token, recipe prefix mismatch");
        }
    }

    function prefixStrip(uint _tokenId) internal pure returns (uint) {
        return _tokenId / (10**68);
    }

    function plotRU(uint _recipeId, uint _plotTokenId) public nonReentrant() whenNotPaused(){
        require(recipeExists(_recipeId, 2), "Recipe id not exist");

        if(plotRURecipes[_recipeId].resourceInputIds.length > 0){
            require(IResources(resources).burnBatch(msg.sender, plotRURecipes[_recipeId].resourceInputIds, plotRURecipes[_recipeId].resourceInputAmounts));
            IResourceTracker(resourceTracker).deductFromBalanceBatch(msg.sender, plotRURecipes[_recipeId].resourceInputIds, plotRURecipes[_recipeId].resourceInputAmounts);
        } 
        if (plotRURecipes[_recipeId].darInputAmount > 0){
            require(IERC20(DAR).transferFrom(msg.sender, MoDTaxAccount, plotRURecipes[_recipeId].darInputAmount));
        } 
        if (plotRURecipes[_recipeId].max > 0){
            require(IPlanetPlot(planetPlot).plotMax(_plotTokenId) == plotRURecipes[_recipeId].max, "Plot max, recipe max mismatch");
            require(IPlanetPlotHandler(planetPlotHandler).upgradePlotMax(_plotTokenId, (plotRURecipes[_recipeId].max + plotRURecipes[_recipeId].add)));
        } 
        else {
            require(IPlanetPlotHandler(planetPlotHandler).replenishPlot(_plotTokenId, plotRURecipes[_recipeId].add));
        }
        emit ReplenishUpgradeEvent(_recipeId, _plotTokenId);
    }

    function planetPass(uint _recipeId) public nonReentrant() whenNotPaused(){
        require(recipeExists(_recipeId, 3), "Recipe id not exist");
        require(IERC20(DAR).transferFrom(msg.sender, MoDTaxAccount, planetPassRecipes[_recipeId].darInputAmount));
        IPlanetPlotHandler(planetPlotHandler).setPlayerPlanetPass(msg.sender, planetPassRecipes[_recipeId].planetIds);

        emit PlanetPassEvent(msg.sender, planetPassRecipes[_recipeId].planetIds);
    }
    
    function updatePlanetPlotHandler (address _planetPlotHandler) public isGameController(){
        planetPlotHandler = _planetPlotHandler;
    }
    function updateTaxAccount(address _MoDTaxAccount) public isGameController(){
        MoDTaxAccount = _MoDTaxAccount;
    }

    function updateResourceTracker(IResourceTracker _resourceTracker) public isGameController(){
        resourceTracker = _resourceTracker;
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

import "@openzeppelin/contracts/interfaces/IERC721.sol";

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

import "@openzeppelin/contracts/interfaces/IERC721.sol";

interface IItems is IERC721{
    function createItemType(uint _type) external returns (bool);
    function mint(address _to, uint256[] memory _mintTypes) external  returns (bool);
    function burn(address _from, uint256[] memory _burnItemIds) external  returns (bool);
    function burnAndMint(address _fromTo, uint256[] memory _mintTypes, uint256[] memory _burnItemIds) external returns (bool);
    function prefixExists(uint _prefix) external view returns (bool);
}

// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlanetPlotHandler {
    function closeRentPlot(address _renter, uint _nrToClose) external returns (bool);
    function replenishPlot(uint _tokenId, uint _digs) external returns (bool);
    function upgradePlotMax(uint _tokenId, uint _newMax) external returns (bool);
    function setPlayerPlanetPass(address _renter, uint[] memory _planetIds) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IResourceTracker {
    function addToBalance(address _player, uint256 _resourceId, uint256 _amount) external;
    function addToBalanceBatch(address _player, uint256[] calldata _resourceIds, uint256[] calldata _amounts) external;
    function deductFromBalance(address _player, uint256 _resourceId, uint256 _amount) external;
    function deductFromBalanceBatch(address _player, uint256[] calldata _resourceIds, uint256[] calldata _amounts) external;
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