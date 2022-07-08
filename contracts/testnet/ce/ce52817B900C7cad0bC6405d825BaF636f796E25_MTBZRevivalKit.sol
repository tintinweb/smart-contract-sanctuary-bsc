// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IERCContract {

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract MTBZRevivalKit is AccessControl {

    using Counters for Counters.Counter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address payable public _admin; // Admin address

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _admin = payable(msg.sender);
    }

    address public _tokenContractAddress; 

    uint256 public capsulePurchaseLimit = 5;

    bool public isSaleCommonOpen = true;
    bool public isSaleRareOpen = true;
    bool public isSaleEpicOpen = true;
    bool public isSaleLegendaryOpen = true;
    bool public isSaleDivineOpen = true;
    bool public isSaleImmortalOpen = true;

    uint256 public supply_common = 1500;
    uint256 public supply_rare = 300;
    uint256 public supply_epic = 300;
    uint256 public supply_legendary = 300;
    uint256 public supply_divine = 300;
    uint256 public supply_immortal = 300;

    uint256 public price_common = 0.022938342 ether;
    uint256 public price_rare = 0.045876684 ether;
    uint256 public price_epic = 0.06422735759999999 ether;
    uint256 public price_legendary = 0.091753368 ether;
    uint256 public price_divine = 0.137630052 ether;
    uint256 public price_immortal = 0.183506736 ether;

    mapping(address => uint256) public KIT_COUNT; 
    mapping(address => uint256) public COMMON_KITS; 
    mapping(address => uint256) public RARE_KITS;
    mapping(address => uint256) public EPIC_KITS;
    mapping(address => uint256) public LEGENDARY_KITS; 
    mapping(address => uint256) public DIVINE_KITZ;
    mapping(address => uint256) public IMMORTAL_KITZ;   

    Counters.Counter public capsuleCounter;
    Counters.Counter public capsuleCounterCommon;
    Counters.Counter public capsuleCounterRare;
    Counters.Counter public capsuleCounterEpic;
    Counters.Counter public capsuleCounterLegendary;
    Counters.Counter public capsuleCounterDivine;
    Counters.Counter public capsuleCounterImmortal;

    //Purchase Common via BNB
    function purchaseKitCommon(uint256 count) external payable {
        require(isSaleCommonOpen, "Capsule Sale Closed!");
        require(supply_common - count >= 0, "Insufficient supply!");
        require(msg.sender != address(0), "Zero address");
        require(msg.value == (price_common*count), "Not enough BNB");
        require((KIT_COUNT[msg.sender]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

        COMMON_KITS[msg.sender] = COMMON_KITS[msg.sender] + count;
        KIT_COUNT[msg.sender] = KIT_COUNT[msg.sender] + count;
        supply_common = supply_common+count;
        capsuleCounterCommon.increment();
    }
    //Purchase Rare via BNB
    function purchaseKitRare(uint256 count) external payable {
        require(isSaleRareOpen, "Capsule Sale Closed!");
        require(supply_rare - count >= 0, "Insufficient supply!");
        require(msg.sender != address(0), "Zero address");
        require(msg.value == (price_rare*count), "Not enough BNB");
        require((KIT_COUNT[msg.sender]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

        RARE_KITS[msg.sender] = RARE_KITS[msg.sender] + count;
        KIT_COUNT[msg.sender] = KIT_COUNT[msg.sender] + count;    
        supply_rare = supply_rare-count;
        capsuleCounterRare.increment();
    }

    //Purchase Epic via BNB
    function purchaseKitEpic(uint256 count) external payable {
        require(isSaleEpicOpen, "Capsule Sale Closed!");
        require(supply_epic - count >= 0, "Insufficient supply!");
        require(msg.sender != address(0), "Zero address");
        require(msg.value == (price_epic*count), "Not enough BNB");
        require((KIT_COUNT[msg.sender]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

        EPIC_KITS[msg.sender] = EPIC_KITS[msg.sender] + count;
        KIT_COUNT[msg.sender] = KIT_COUNT[msg.sender] + count; 
        supply_epic = supply_epic-count;   
        capsuleCounterEpic.increment();
    }

    //Purchase Legendary via BNB
    function purchaseKitLegendary(uint256 count) external payable {
        require(isSaleLegendaryOpen, "Capsule Sale Closed!");
        require(supply_legendary - count >= 0, "Insufficient supply!");
        require(msg.sender != address(0), "Zero address");
        require(msg.value == (price_legendary*count), "Not enough BNB");
        require((KIT_COUNT[msg.sender]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

        LEGENDARY_KITS[msg.sender] = LEGENDARY_KITS[msg.sender] + count;
        KIT_COUNT[msg.sender] = KIT_COUNT[msg.sender] + count;    
        supply_legendary = supply_legendary-count;  
        capsuleCounterLegendary.increment();
    }

    //Purchase Divine via BNB
    function purchaseKitDivine(uint256 count) external payable {
        require(isSaleDivineOpen, "Capsule Sale Closed!");
        require(supply_divine - count >= 0, "Insufficient supply!");
        require(msg.sender != address(0), "Zero address");
        require(msg.value == (price_divine*count), "Not enough BNB");
        require((KIT_COUNT[msg.sender]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

        DIVINE_KITZ[msg.sender] = DIVINE_KITZ[msg.sender] + count;
        KIT_COUNT[msg.sender] = KIT_COUNT[msg.sender] + count;
        supply_divine = supply_divine-count;     
        capsuleCounterDivine.increment();
    }

    //Purchase Immortal via BNB
    function purchaseKitImmortal(uint256 count) external payable {
        require(isSaleImmortalOpen, "Capsule Sale Closed!");
        require(supply_immortal - count >= 0, "Insufficient supply!");
        require(msg.sender != address(0), "Zero address");
        require(msg.value == (price_immortal*count), "Not enough BNB");
        require((KIT_COUNT[msg.sender]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

        IMMORTAL_KITZ[msg.sender] = IMMORTAL_KITZ[msg.sender] + count;
        KIT_COUNT[msg.sender] = KIT_COUNT[msg.sender] + count;    
        supply_immortal = supply_immortal-count;   
        capsuleCounterImmortal.increment();
    }

    //Purchase via Credits
    function _purchaseKitCredits(address walletAddress, uint256 count, uint256 capsuleType) external onlyRole(MINTER_ROLE) {
        if(capsuleType == 1){
            require(isSaleCommonOpen, "Capsule Sale Closed!");
            require(supply_common - count >= 0, "Insufficient supply!");
            require((KIT_COUNT[walletAddress]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

            COMMON_KITS[walletAddress] = COMMON_KITS[walletAddress] + count;
            KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] + count;  
            supply_common = supply_common-count;     
            capsuleCounterCommon.increment();
        }else if(capsuleType == 2){
            require(isSaleRareOpen, "Capsule Sale Closed!");
            require(supply_rare - count >= 0, "Insufficient supply!");
            require((KIT_COUNT[walletAddress]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

            RARE_KITS[walletAddress] = RARE_KITS[walletAddress] + count;
            KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] + count;    
            supply_rare = supply_rare-count; 
            capsuleCounterRare.increment();
        }else if(capsuleType == 3){
            require(isSaleEpicOpen, "Capsule Sale Closed!");
            require(supply_epic - count >= 0, "Insufficient supply!");
            require((KIT_COUNT[walletAddress]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

            EPIC_KITS[walletAddress] = EPIC_KITS[walletAddress] + count;
            KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] + count;
            supply_epic = supply_epic-count; 
            capsuleCounterEpic.increment();
        }else if(capsuleType == 4){
            require(isSaleLegendaryOpen, "Capsule Sale Closed!");
            require(supply_legendary - count >= 0, "Insufficient supply!");
            require((KIT_COUNT[walletAddress]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

            LEGENDARY_KITS[walletAddress] = LEGENDARY_KITS[walletAddress] + count;
            KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] + count;
            supply_legendary = supply_legendary-count;     
            capsuleCounterLegendary.increment();
        }else if(capsuleType == 5){
            require(isSaleDivineOpen, "Capsule Sale Closed!");
            require(supply_divine - count >= 0, "Insufficient supply!");
            require((KIT_COUNT[walletAddress]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

            DIVINE_KITZ[walletAddress] = DIVINE_KITZ[walletAddress] + count;
            KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] + count;
            supply_divine = supply_divine-count;   
            capsuleCounterDivine.increment();
        }else if(capsuleType == 6){
            require(isSaleImmortalOpen, "Capsule Sale Closed!");
            require(supply_immortal - count >= 0, "Insufficient supply!");
            require((KIT_COUNT[walletAddress]+count)<= capsulePurchaseLimit, "Limit Exceeded!");

            IMMORTAL_KITZ[walletAddress] = IMMORTAL_KITZ[walletAddress] + count;
            KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] + count;  
            supply_immortal = supply_immortal-count;  
            capsuleCounterImmortal.increment();
        }else{}
    }

    //Capsule Expire Common
    function _kitExpireCommon(address walletAddress, uint256 count) external onlyRole(MINTER_ROLE) {
      require((KIT_COUNT[walletAddress]-count)>= 0, "Limit Exceeded!");

      COMMON_KITS[walletAddress] = COMMON_KITS[walletAddress] - count;
      KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] - count;    
      supply_common = supply_common + count; 
    }

    //Capsule Expire Rare
    function _kitExpireRare(address walletAddress, uint256 count) external onlyRole(MINTER_ROLE) {
      require((KIT_COUNT[walletAddress]-count)>= 0, "Limit Exceeded!");

      RARE_KITS[walletAddress] = RARE_KITS[walletAddress] - count;
      KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] - count;    
      supply_rare = supply_rare + count;
    }

    //Capsule Expire Epic
    function _kitExpireEpic(address walletAddress, uint256 count) external onlyRole(MINTER_ROLE) {
      require((KIT_COUNT[walletAddress]-count)>= 0, "Limit Exceeded!");

      EPIC_KITS[walletAddress] = EPIC_KITS[walletAddress] - count;
      KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] - count;    
      supply_epic = supply_epic + count;
    }

    //Capsule Expire Legendary
    function _kitExpireLegendary(address walletAddress, uint256 count) external onlyRole(MINTER_ROLE) {
      require((KIT_COUNT[walletAddress]-count)>= 0, "Limit Exceeded!");

      LEGENDARY_KITS[walletAddress] = LEGENDARY_KITS[walletAddress] - count;
      KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] - count;    
      supply_legendary = supply_legendary + count;
    }

    //Capsule Expire Divine
    function _kitExpireDivine(address walletAddress, uint256 count) external onlyRole(MINTER_ROLE) {
      require((KIT_COUNT[walletAddress]-count)>= 0, "Limit Exceeded!");

      DIVINE_KITZ[walletAddress] = DIVINE_KITZ[walletAddress] - count;
      KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] - count;    
      supply_divine = supply_divine + count;
    }

    //Capsule Expire Immortal
    function _kitExpireImmortal(address walletAddress, uint256 count) external onlyRole(MINTER_ROLE) {
      require((KIT_COUNT[walletAddress]-count)>= 0, "Limit Exceeded!");

      IMMORTAL_KITZ[walletAddress] = IMMORTAL_KITZ[walletAddress] - count;
      KIT_COUNT[walletAddress] = KIT_COUNT[walletAddress] - count;    
      supply_immortal = supply_immortal + count;
    }

    //Setters
    function _setSaleStatusCommon() external onlyRole(DEFAULT_ADMIN_ROLE){
        isSaleCommonOpen = !isSaleCommonOpen;
    }
    function _setSaleStatusRare() external onlyRole(DEFAULT_ADMIN_ROLE){
        isSaleRareOpen = !isSaleRareOpen;
    }
    function _setSaleStatusEpic() external onlyRole(DEFAULT_ADMIN_ROLE){
        isSaleEpicOpen = !isSaleEpicOpen;
    }
    function _setSaleStatusLegendary() external onlyRole(DEFAULT_ADMIN_ROLE){
        isSaleLegendaryOpen = !isSaleLegendaryOpen;
    }   
    function _setSaleStatusDivine() external onlyRole(DEFAULT_ADMIN_ROLE){
        isSaleDivineOpen = !isSaleDivineOpen;
    }
    function _setSaleStatusImmortal() external onlyRole(DEFAULT_ADMIN_ROLE){
        isSaleImmortalOpen = !isSaleImmortalOpen;
    }   

    function _setSupplyCommon(uint256 _supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        supply_common= _supply;
    }
    function _setSupplyRare(uint256 _supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        supply_rare= _supply;
    }
    function _setSupplyEpic(uint256 _supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        supply_epic= _supply;
    }
    function _setSupplyLegendary(uint256 _supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        supply_legendary= _supply;
    }
    function _setSupplyDivine(uint256 _supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        supply_divine= _supply;
    }

    function _setPriceCommon(uint256 _price) external onlyRole(DEFAULT_ADMIN_ROLE){
        price_common = _price;
    }
    function _setPriceRare(uint256 _price) external onlyRole(DEFAULT_ADMIN_ROLE){
        price_rare = _price;
    }
    function _setPriceEpic(uint256 _price) external onlyRole(DEFAULT_ADMIN_ROLE){
        price_epic = _price;
    }
    function _setPriceLegendary(uint256 _price) external onlyRole(DEFAULT_ADMIN_ROLE){
        price_legendary = _price;
    }
    function _setPriceDivine(uint256 _price) external onlyRole(DEFAULT_ADMIN_ROLE){
        price_divine = _price;
    }
    function _setPriceImmortal(uint256 _price) external onlyRole(DEFAULT_ADMIN_ROLE){
        price_immortal = _price;
    }

    function _setCapsuleLimit(uint256 _limit) external onlyRole(DEFAULT_ADMIN_ROLE){
       capsulePurchaseLimit = _limit;
    }

    function _setTokenContractAddress(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        _tokenContractAddress = contractAddress;
    }

    //Withdraw Token Balance
    function withdrawToken() external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERCContract tokenContract = IERCContract(_tokenContractAddress);
        tokenContract.transfer(msg.sender,tokenContract.balanceOf(address(this)));
    }
    //Withdraw BNB Balance
    function withdrawBNB() external onlyRole(DEFAULT_ADMIN_ROLE){
        _admin.transfer(address(this).balance);
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