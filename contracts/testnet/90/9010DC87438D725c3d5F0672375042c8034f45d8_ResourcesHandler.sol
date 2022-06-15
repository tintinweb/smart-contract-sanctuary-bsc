// krippilippa
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "interfaces/IResources.sol";
import "interfaces/IItems.sol";
import "interfaces/IMoDApproveProxy.sol";


contract ResourcesHandler is AccessControl, ReentrancyGuard, Pausable {

    bytes32 public constant GAME_CONTROL = keccak256("GAME_CONTROL");
    bytes32 public constant RESOURCE_ITEM_CREATOR = keccak256("RESOURCE_ITEM_CREATOR");

    address private MoDTaxAccount;
    IMoDApproveProxy public MoDApproveProxy;
    IResources public resources; 
    IItems public items;

    mapping(uint=>Crafting_recipe) public craftingRecipes;
    mapping(uint=>ItemRegen_recipe) public itemRegenRecipes;

    struct Crafting_recipe {
        uint[] resourceInputIds;
        uint[] resourceInputAmounts;

        uint[] itemInputPrefixes;

        uint darInputAmount;

        uint[] resourceOutputIds;
        uint[] resourceOutputAmounts;

        uint[] itemOutputPrefixes;
    }

    struct ItemRegen_recipe {
        uint[] RIIds;
        uint[] RIAmounts;
        uint IIPrefix;
        uint DIAmount;
        uint regenAmount;
    }

    event CraftRecipeCreated(uint recipeId);
    event CraftRecipeDeleted(uint recipeId);
    event CraftEvent(address crafter, uint recipeId);
    event ItemRegenRecipeCreated(uint recipeId);
    event ItemRegenRecipeDeleted(uint recipeId);
    event ItemEnergyRegenerate(uint recipeId, uint itemId, uint amount);

    function createResource(string memory _resourceName) public onlyRole(RESOURCE_ITEM_CREATOR){
        resources.createResource(_resourceName);
    }

    function createItem(uint _prefix) public onlyRole(RESOURCE_ITEM_CREATOR){
        items.createItemType(_prefix);
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
         ) public onlyRole(GAME_CONTROL){
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

        emit CraftRecipeCreated(_recipeId);
    }
        
    function removeCraftingRecipe(uint _recipeId) public onlyRole(GAME_CONTROL){
        require(recipeExists(_recipeId, 1));
        delete craftingRecipes[_recipeId];
        emit CraftRecipeDeleted(_recipeId);
    }

    function craft(uint _recipeId, uint[] memory _tokenIds) public nonReentrant() whenNotPaused(){
        require(recipeExists(_recipeId, 1), "Recipe id not exist");

        if (craftingRecipes[_recipeId].darInputAmount > 0 ){
            MoDApproveProxy.DAR_transferFrom(msg.sender, MoDTaxAccount, craftingRecipes[_recipeId].darInputAmount);
        } 
        if (craftingRecipes[_recipeId].resourceInputIds.length > 0){
            MoDApproveProxy.resources_burnBatch(msg.sender, craftingRecipes[_recipeId].resourceInputIds, craftingRecipes[_recipeId].resourceInputAmounts);
        }

        if (craftingRecipes[_recipeId].itemInputPrefixes.length > 0 && craftingRecipes[_recipeId].itemOutputPrefixes.length > 0){
            itemInputCheck(_recipeId, _tokenIds);
            MoDApproveProxy.item_burnAndMint(msg.sender, craftingRecipes[_recipeId].itemOutputPrefixes, _tokenIds);
        }else{
            if (craftingRecipes[_recipeId].itemInputPrefixes.length > 0){
                itemInputCheck(_recipeId, _tokenIds);
                MoDApproveProxy.item_burn(msg.sender, _tokenIds);
            }
            if (craftingRecipes[_recipeId].itemOutputPrefixes.length > 0){
                MoDApproveProxy.item_mint(msg.sender, craftingRecipes[_recipeId].itemOutputPrefixes);
            }
        }
        if (craftingRecipes[_recipeId].resourceOutputIds.length > 0){
            MoDApproveProxy.resources_mintBatch(msg.sender, craftingRecipes[_recipeId].resourceOutputIds, craftingRecipes[_recipeId].resourceOutputAmounts);
        }
        emit CraftEvent(msg.sender, _recipeId);
    }

    function addItemRegenRecipe(
        uint _recipeId, 
        uint[] memory _RIIds,
        uint[] memory _RIAmounts,
        uint _DIAmount,
        uint _IIPrefix,
        uint _regenAmount
         ) public onlyRole(GAME_CONTROL){
        require(!recipeExists(_recipeId, 2), "Recipe ID already exists");
        require((_RIIds.length > 0 || _DIAmount > 0) && _IIPrefix != 0 && _regenAmount > 0, "Input failure");

        ItemRegen_recipe storage recipe  = itemRegenRecipes[_recipeId];

        recipe.RIIds = checkResourceIds(_RIIds);
        recipe.RIAmounts = validAmountArray(_RIAmounts, _RIIds.length);
        checkItemPrefix(_IIPrefix);
        recipe.IIPrefix = _IIPrefix;
        recipe.DIAmount = _DIAmount;
        recipe.regenAmount = _regenAmount;

        itemRegenRecipes[_recipeId] = recipe;

        emit ItemRegenRecipeCreated(_recipeId);
    }
        
    function removeItemRegenRecipe(uint _recipeId) public onlyRole(GAME_CONTROL){
        require(recipeExists(_recipeId, 2), "Recipe ID does not exist");
        delete itemRegenRecipes[_recipeId];
        emit ItemRegenRecipeDeleted(_recipeId);
    }

    function multiRecipeRegen(uint[] memory _recipeIds, uint[] memory _itemIds) external {
        require(_recipeIds.length == _itemIds.length ,"Array length mis-match");
        for (uint256 i = 0; i < _itemIds.length; i++) {
            regenerateItemEnergy(_recipeIds[i], _itemIds[i]);
        }
    }

    function regenerateItemEnergy(uint _recipeId, uint _itemId) public whenNotPaused{
        require(items.ownerOf(_itemId) == msg.sender, "Address not owner of item");
        require(recipeExists(_recipeId, 2), "Regen recipe does not exist");
        require(itemRegenRecipes[_recipeId].IIPrefix == prefixStrip(_itemId), "Token, recipe prefix mismatch");

        if(itemRegenRecipes[_recipeId].RIIds.length != 0){
            MoDApproveProxy.resources_burnBatch(msg.sender, itemRegenRecipes[_recipeId].RIIds, itemRegenRecipes[_recipeId].RIAmounts);
        }
        if(itemRegenRecipes[_recipeId].DIAmount != 0){
            MoDApproveProxy.DAR_transferFrom(msg.sender, MoDTaxAccount, itemRegenRecipes[_recipeId].DIAmount);
        }
        emit ItemEnergyRegenerate(_recipeId, _itemId, itemRegenRecipes[_recipeId].regenAmount);
    }

    function recipeExists(uint _recipeId, uint8 _type) public view returns (bool){
        if(_type == 1){
            if (craftingRecipes[_recipeId].resourceOutputIds.length == 0 && craftingRecipes[_recipeId].itemOutputPrefixes.length == 0) {
                return false;
            } else {
                return true;
            }
        } else {
            if (itemRegenRecipes[_recipeId].regenAmount == 0) {
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
                checkItemPrefix(_iPrefixes[index]);
            }
        }
        return _iPrefixes;
    }

    function checkItemPrefix(uint _iPrefix) internal view {
        require(items.prefixExists(_iPrefix), "Item not exist");
    }

    function prefixStrip(uint _tokenId) internal pure returns (uint) {
        return _tokenId / (10**68);
    }

    function itemInputCheck(uint _recipeId, uint[] memory _tokenIds) internal view {
        require(craftingRecipes[_recipeId].itemInputPrefixes.length == _tokenIds.length, "Recipe - tokenIds arr no match");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(craftingRecipes[_recipeId].itemInputPrefixes[i] == prefixStrip(_tokenIds[i]), "Token, recipe prefix mismatch");
        }
    }

    function updateTaxAccount(address _MoDTaxAccount) public onlyRole(GAME_CONTROL){
        MoDTaxAccount = _MoDTaxAccount;
    }

    function pauseHandler() public onlyRole(GAME_CONTROL){
        _pause();
    }
    function unpauseHandler() public onlyRole(GAME_CONTROL){
        _unpause();
    }

    constructor (
        IResources _resources, 
        IItems _items, 
        IMoDApproveProxy _ModApproveProxy,
        address _MoDTaxAccount,
        address _admin_address
    ) {
        resources = _resources;
        items = _items;
        MoDApproveProxy = _ModApproveProxy;
        MoDTaxAccount = _MoDTaxAccount;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin_address);
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