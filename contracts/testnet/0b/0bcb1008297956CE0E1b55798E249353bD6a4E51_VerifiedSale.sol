/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
// File @openzeppelin/contracts/access/[email protected]
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


// File @openzeppelin/contracts/utils/[email protected]

 
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


// File @openzeppelin/contracts/utils/[email protected]

 
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


// File @openzeppelin/contracts/utils/introspection/[email protected]

 
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


// File @openzeppelin/contracts/utils/introspection/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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

 
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

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


// File @openzeppelin/contracts/security/[email protected]

 
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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


// File contracts/10_ObservationNFTs/VerifiedSale.sol

 
pragma solidity ^0.8.0;


interface IObservationNFT {
    function mintObservation(address _to, address _originalExplorer, uint256 _observationId) external;
    function tokenNonce() external returns (uint256);
}


contract VerifiedSale is AccessControl, Pausable  { 


    // Public address of the address which created the signature.
    address public signatory;

    // beneficiary fee 
    uint256 public beneficiaryPercent = 6000; 

    // Address of the nft contract
    address public nftAddress;

    // The fee that the people will pay on purchasing an nft. 
    uint256 public feeAmount;

    // purchase limit for the users. 
    uint256 public purchaseLimit = 10; 

    // This is a purchase limit switch if it is enabled or not.  
    bool public purchaseLimitEnabled = false;
    
    // amount of purchases an account has made.
    mapping(address => uint256) public amountPurchased;

    bool public whitelistEnabled = false;
    
    /// @notice A mapping to store if someone is on the whitelist. 
    mapping (address => bool) public whitelist;

    event VerifiedPurchaseSuccessful(
        uint256 indexed _tokenId,
        uint256 indexed _observationId,
        address _purchaser,
        address _originalOwner,
        uint256 _timestamp
    );

    constructor (
        address _signatory, 
        address _nftAddress, 
        uint256 _feeAmount) {

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        signatory = _signatory;
        nftAddress = _nftAddress;
        feeAmount = _feeAmount;
    }

    modifier isWhiteListed(address user) {
        require(whitelistEnabled ? whitelist[msg.sender] : true,"Not on the whitelist");
        _;
    }

    modifier isUnderLimit(address user) {
        require(purchaseLimitEnabled ? amountPurchased[msg.sender] < purchaseLimit : true,"You have reached the purchase limit");  
        _;
    }

    /**
    * @notice This is a setter for the signatory
    * @param _signatory This is the public address of the address that signed the signatures.
    */
    function setSignerPub(address _signatory) external onlyRole(DEFAULT_ADMIN_ROLE) {
        signatory = _signatory;
    }

    /**
    * @notice This is the setter for the fee amount
    * @param _feeAmount is the amount a user pays to mint.
    */
    function setFeeAmount(uint256 _feeAmount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeAmount = _feeAmount;
    }

    /**
    * @notice This is the setter for the purchase limit
    * @param _limit is the amount a user pays to mint.
    */
    function setPurchaseLimit(uint256 _limit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        purchaseLimit = _limit;
    }

    /**
    * @notice This function allows the admin to enable the white list or not.
    * @param _switch to switch if the whitelist is enabled or disabled. 
    */
    function whitelistSwitch(bool _switch) external onlyRole(DEFAULT_ADMIN_ROLE) {
        whitelistEnabled = _switch;
    }

    /**
    * @notice This function allows the admin to enable the purchase limit or not.
    * @param _switch to switch if the purchase limit is enabled or disabled. 
    */
    function purchaseLimitSwitch(bool _switch) external onlyRole(DEFAULT_ADMIN_ROLE) {
        purchaseLimitEnabled = _switch;
    }

    /**
    * @notice This function allows an admin to add users to the whitelist
    * @param toAdd An array of addresses to add to the whitelist
    */
    function addToWhitelist(address[] memory toAdd) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint256 i = 0; i < toAdd.length; i++) {
            whitelist[toAdd[i]] = true;
        }
    }

    /**
     * @notice This function allows the admin to change the percent that goes to the beneficiary
     * @param percent is the percent you would like to use as the beneficiary percentage 0 - 10000.
     */
    function setBeneficiaryPercent(uint256 percent) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(percent <= 10000,"percentage too high");
        beneficiaryPercent = percent;
    }

    /**
     * @notice This function pauses the purchases on the smart contract
     * @param _switch if the purchases should be paused or not.
     */
    function pausePurchasesSwitch(bool _switch) external onlyRole(DEFAULT_ADMIN_ROLE){
        _switch ? _pause() : _unpause();
    }

    /**
     * @notice This function recovers the signatory of the message to validate the signature.
     * @param message This is the message that the signatory signed.
     * @param sig This is the signature from the signatory.
     */
    function recoverSigner(bytes32 message, bytes memory sig)
        public
        pure
        returns (address)
        {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    /**
     * @notice This function splits the signature up into its constituent parts.
     * @param sig The signature signed by the signatory.
     */
    function splitSignature(bytes memory sig)
        public
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    /**
    * @notice This function allows verification of a personal purchase.
    * @param _observationId observation to be minted.
    * @param sig This is the signature the private key creates with this information to verify against. 
    */
    function isValidPersonalPurchase(
                uint256 _observationId, 
                bytes memory sig) 
                public view returns(bool) {
        bytes32 message = keccak256(abi.encodePacked(msg.sender, _observationId));
        return (recoverSigner(message, sig) == signatory);
    }

    /**
    * @notice This function allows a verification of a secondary purchase.
    * @param _originalUserAddress The address of the person who sighted it. 
    * @param _observationId The observation to be minted.
    * @param sig This is the signature the private key creates with this information to verify against. 
    */
    function isValidSecondaryPurchase(
            uint256 _observationId, 
            address _originalUserAddress,
            bytes memory sig) 
            public view returns(bool) {
        bytes32 message = keccak256(abi.encodePacked(msg.sender,_originalUserAddress, _observationId));
        return (recoverSigner(message, sig) == signatory);
    }


    /**
    * @notice This function allows a personal purchase of an observation nft.
    * @param observationId this is the id of the observation they would like to mint.
    * @param sig This is the signature that the signatory has signed previously.
    */
    function purchasePersonalObservationNFT(
            uint256 observationId,
            bytes memory sig) 
            external payable whenNotPaused isUnderLimit(msg.sender) isWhiteListed(msg.sender) {
        
        require(msg.value >= feeAmount,"Insufficient minting fee");
        
        require(isValidPersonalPurchase(observationId,sig),"Not a valid purchase");

        IObservationNFT(nftAddress).mintObservation(msg.sender,msg.sender,observationId);

        if(purchaseLimitEnabled) {
            amountPurchased[msg.sender]++;
        }

        emit VerifiedPurchaseSuccessful(
                IObservationNFT(nftAddress).tokenNonce(),
                observationId,
                msg.sender,
                msg.sender,
                block.timestamp);

    }

    /**
    * @notice This function allows a personal purchase of an observation nft.
    * @param observationId this is the id of the observation they would like to mint.
    * @param originalUserAddress this is the address of the 
    * @param sig This is the signature that the signatory has signed previously.
    */
    function purchaseSecondaryObservationNFT(
            uint256 observationId,
            address originalUserAddress,
            bytes memory sig) 
            external payable whenNotPaused isUnderLimit(msg.sender) isWhiteListed(msg.sender) {
        
        require(msg.value >= feeAmount,"Insufficient minting fee");

        require(isValidSecondaryPurchase(observationId,originalUserAddress,sig),"Not a valid purchase");

        IObservationNFT(nftAddress).mintObservation(msg.sender,originalUserAddress,observationId);

        payable(originalUserAddress).transfer(msg.value * beneficiaryPercent / 10000);

        if(purchaseLimitEnabled) {
            amountPurchased[msg.sender]++;
        }

        emit VerifiedPurchaseSuccessful(
                IObservationNFT(nftAddress).tokenNonce(),
                observationId,
                msg.sender,
                originalUserAddress,
                block.timestamp);

    }


    /**
    * @notice withdraws the balance of the smart contract to the given admin address
    * @param admin admin address to send funds
    */
    function withdraw(address admin) external onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(admin).transfer(address(this).balance);
    }


}