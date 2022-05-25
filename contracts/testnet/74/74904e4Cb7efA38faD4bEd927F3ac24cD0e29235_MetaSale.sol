// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./IMBotzDesign.sol";

interface IERCContract {
    function transferBetaTest(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IErc721Contract {
    function balanceOf(address owner) external view returns (uint256 balance);

    function mintBotz(uint256 count, address recepient,uint256 crateType)
        external
        returns (bool);
}

contract MetaSale is AccessControl {

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant DESIGNER_ROLE = keccak256("DESIGNER_ROLE");
    bytes32 public constant CLAIMER_ROLE = keccak256("CLAIMER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant TRADER_ROLE = keccak256("TRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address payable public _admin; // Admin address

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DESIGNER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _admin = payable(msg.sender);
    }

    address public _tokenContractAddress;
    address public _designContractAddress;
    address public _nftnContractAddress;

    IMBotzDesign public design;

    uint256 public NORMAL_PRICE_BNB = .020 ether;
    uint256 public NORMAL_NFT_SUPPLY = 1000000 ;

    uint256 public SILVER_PRICE_BNB = .0055 ether;
    uint256 public SILVER_NFT_SUPPLY = 1000000 ;

    uint256 public GOLD_PRICE_BNB = .011 ether;
    uint256 public GOLD_NFT_SUPPLY = 1000000 ;

    uint256 public PLATINUM_PRICE_BNB = .016 ether;
    uint256 public PLATINUM_NFT_SUPPLY = 1000000 ;

    uint256 public PURCHASE_LIMIT = 100;
    uint256 public ACCOUNT_BOT_LIMIT = 100;
    
    bool public isNormalNFTSaleClosed = true;
    bool public isSilverNFTSaleClosed = true;
    bool public isGoldNFTSaleClosed = true;
    bool public isPlatinumNFTSaleClosed = true;

    mapping(address => uint256) public BAL_NFT_BOUGHT;

    //Purchase BNB
    function purchaseNormalBNB(uint256 count) external payable {
        require(count > 0, "No token to mint");
        require(msg.sender != address(0), "Zero address");
        require(isNormalNFTSaleClosed == false, "NFT Sale Closed!");
        require(NORMAL_NFT_SUPPLY > 0, "Out of supply");
        require(msg.value == (NORMAL_PRICE_BNB * count), "Not enough BNB");
        require((BAL_NFT_BOUGHT[msg.sender] + count) <= PURCHASE_LIMIT,"Purchase Limit Exceeded!");

        IErc721Contract nftContract = IErc721Contract(_nftnContractAddress);
        require((nftContract.balanceOf(msg.sender) + count) <= ACCOUNT_BOT_LIMIT, "Account limit exceeded!");

        nftContract.mintBotz(count, msg.sender,0);

        BAL_NFT_BOUGHT[msg.sender] = BAL_NFT_BOUGHT[msg.sender] + count;
        NORMAL_NFT_SUPPLY = NORMAL_NFT_SUPPLY - count;
    }
    
    function purchaseSilverBNB(uint256 count) external payable {
        require(count > 0, "No token to mint");
        require(msg.sender != address(0), "Zero address");
        require(isSilverNFTSaleClosed == false, "NFT Sale Closed!");
        require(SILVER_NFT_SUPPLY > 0, "Out of supply");
        require(msg.value == (SILVER_PRICE_BNB * count), "Not enough BNB");
        require((BAL_NFT_BOUGHT[msg.sender] + count) <= PURCHASE_LIMIT,"Purchase Limit Exceeded!");

        IErc721Contract nftContract = IErc721Contract(_nftnContractAddress);
        require((nftContract.balanceOf(msg.sender) + count) <= ACCOUNT_BOT_LIMIT, "Account limit exceeded!");

        nftContract.mintBotz(count, msg.sender,1);

        BAL_NFT_BOUGHT[msg.sender] = BAL_NFT_BOUGHT[msg.sender] + count;
        SILVER_NFT_SUPPLY = SILVER_NFT_SUPPLY - count;
    }

    function purchaseGoldBNB(uint256 count) external payable {
        require(count > 0, "No token to mint");
        require(msg.sender != address(0), "Zero address");
        require(isGoldNFTSaleClosed == false, "NFT Sale Closed!");
        require(GOLD_NFT_SUPPLY > 0, "Out of supply");
        require(msg.value == (GOLD_PRICE_BNB * count), "Not enough BNB");
        require((BAL_NFT_BOUGHT[msg.sender] + count) <= PURCHASE_LIMIT,"Purchase Limit Exceeded!");

        IErc721Contract nftContract = IErc721Contract(_nftnContractAddress);
        require((nftContract.balanceOf(msg.sender) + count) <= ACCOUNT_BOT_LIMIT, "Account limit exceeded!");

        nftContract.mintBotz(count, msg.sender,2);

        BAL_NFT_BOUGHT[msg.sender] = BAL_NFT_BOUGHT[msg.sender] + count;
        GOLD_NFT_SUPPLY = GOLD_NFT_SUPPLY - count;
    }

    function purchasePlatinumBNB(uint256 count) external payable {
        require(count > 0, "No token to mint");
        require(msg.sender != address(0), "Zero address");
        require(isPlatinumNFTSaleClosed == false, "NFT Sale Closed!");
        require(PLATINUM_NFT_SUPPLY > 0, "Out of supply");
        require(msg.value == (PLATINUM_PRICE_BNB * count), "Not enough BNB");
        require((BAL_NFT_BOUGHT[msg.sender] + count) <= PURCHASE_LIMIT,"Purchase Limit Exceeded!");

        IErc721Contract nftContract = IErc721Contract(_nftnContractAddress);
        require((nftContract.balanceOf(msg.sender) + count) <= ACCOUNT_BOT_LIMIT, "Account limit exceeded!");

        nftContract.mintBotz(count, msg.sender,3);

        BAL_NFT_BOUGHT[msg.sender] = BAL_NFT_BOUGHT[msg.sender] + count;
        PLATINUM_NFT_SUPPLY = PLATINUM_NFT_SUPPLY - count;
    }

    //Setters
    function _setNormalNFTSaleStatus() external onlyRole(DEFAULT_ADMIN_ROLE){
        isNormalNFTSaleClosed = !isNormalNFTSaleClosed;
    }

    function _setSilverNFTSaleStatus() external onlyRole(DEFAULT_ADMIN_ROLE){
        isSilverNFTSaleClosed = !isSilverNFTSaleClosed;
    }

    function _setGoldNFTSaleStatus() external onlyRole(DEFAULT_ADMIN_ROLE){
        isGoldNFTSaleClosed = !isGoldNFTSaleClosed;
    }

    function _setPlatinumNFTSaleStatus() external onlyRole(DEFAULT_ADMIN_ROLE){
        isPlatinumNFTSaleClosed = !isPlatinumNFTSaleClosed;
    }

    function _setPriceNormalBNB(uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE){
        NORMAL_PRICE_BNB = price;
    }

    function _setPriceSilverBNB(uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE){
        SILVER_PRICE_BNB = price;
    }

    function _setPriceGoldBNB(uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE){
        GOLD_PRICE_BNB = price;
    }

    function _setPricePlatinumBNB(uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE){
        PLATINUM_PRICE_BNB = price;
    }

    function _setSupplyNormal(uint256 supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        NORMAL_NFT_SUPPLY = supply;
    }

    function _setSupplySilver(uint256 supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        SILVER_NFT_SUPPLY = supply;
    }

    function _setSupplyPlatinum(uint256 supply) external onlyRole(DEFAULT_ADMIN_ROLE){
        PLATINUM_NFT_SUPPLY = supply;
    }

    function _setPurchaseLimit(uint256 limit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PURCHASE_LIMIT = limit;
    }

    function _setAccountBotLimit(uint256 limit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ACCOUNT_BOT_LIMIT = limit;
    }
  
    function _setTokenContractAddress(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        _tokenContractAddress = contractAddress;
    }

    function _setNftContractAddress(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        _nftnContractAddress = contractAddress;
    }

    function _setDesign(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE){
        _designContractAddress = contractAddress;
        design = IMBotzDesign(contractAddress);
    }

    function withdrawToken() external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERCContract tokenContract = IERCContract(_tokenContractAddress);
        tokenContract.transfer(msg.sender,tokenContract.balanceOf(address(this)));
    }

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
pragma solidity 0.8.2;

interface IMBotzDesign {
    function createRandomRarityBronze(uint256 currentBotId) external view returns (uint256);

    function createRandomRaritySilver(uint256 currentBotId) external view returns (uint256);

    function createRandomRarityGold(uint256 currentBotId) external view returns (uint256);

    function createRandomRarityPlatinum(uint256 currentBotId) external view returns (uint256);

    function createRandomAttributes(uint256 _rarity) external view returns ( uint256, uint256, uint256);

    function getMergingCost(uint256 _rarity, uint256 _level) external view returns (uint256);

    function getAccountBotLimit() external view returns (uint256);

    function getAccountBotLevelLimit() external view returns (uint256);

    function setRandomAttribues(uint256 _level) external view returns (uint256);
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