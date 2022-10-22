/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// File: contracts/Stakable.sol



pragma solidity ^0.8.4;



/**

* @notice Claimable is a contract who is ment to be inherited by other contract that wants claiming capabilities

*/

contract Claimable {



    



    /**

    * @notice Constructor,since this contract is not ment to be used without inheritance

    * push once to claimers for it to work proplerly

     */

    constructor() {

        claims.push();

    }



    /**

     * @notice

     * A claim struct is used to represent the way we store claims, 

     * A claim will contain the claimer address & the amount

     */

    struct Claim{

        address claimer;

        uint256 amount;

    }



    function _addClaimer(address claimerAddr, uint256 claimAmount) internal returns (uint256){

        // Push a empty item to the Array to make space for our new claimer

        claims.push();

        // Calculate the index of the last item in the array by Len-1

        uint256 claimIndex = claims.length - 1;

        claimers[claimerAddr] = claimIndex;

        claims[claimIndex] = Claim(claimerAddr, claimAmount);

        return claimIndex; 

    }



    function _addClaim(address claimerAddr, uint256 claimAmount) internal{

        require(claimAmount > 0, "TOKO: Invalid amount");

        uint256 claimIndex;

        // Add claimer if needed, add amount

        if(claimers[claimerAddr] == 0)

        {

            claimIndex = _addClaimer(claimerAddr, claimAmount);

        }

        else 

        {

            claimIndex = claimers[claimerAddr];

            claims[claimIndex].amount += claimAmount;

        }

        emit ClaimAdded(claimerAddr, claimAmount, claimIndex, block.timestamp);

    }



    function _removeClaim(address claimerAddr) internal{

        require(claimers[claimerAddr] > 0, "TOKO: Invalid claimer address");

        uint256 claimIndex = claimers[claimerAddr];

        emit ClaimRemoved(claimerAddr, claims[claimIndex].amount, claimIndex, block.timestamp);

        delete claims[claimIndex];

        claimers[claimerAddr] = 0;

    }



    function _viewClaimable(address claimerAddr) internal view returns(uint256){

        if(claimers[claimerAddr] > 0)

        {

            return  claims[claimers[claimerAddr]].amount;

        }

        else return 0;

    }



    function _viewMyClaimable() public view returns(uint256){

        return _viewClaimable(msg.sender);

    }

 

    /**

    * @notice 

    *   This is a array where we store all Claims that are performed on the Contract

    *   The rightful claim for each address is stored at a certain index, the index can be found using the claimer mapping

    */

    Claim[] internal claims;

    /**

    * @notice 

    * Claimers is used to keep track of the INDEX for the claims in the claims array

     */

    mapping(address => uint256) internal claimers;



    event ClaimAdded(address indexed claimer, uint256 amount, uint256 index, uint256 timestamp);

    event ClaimRemoved(address indexed claimer, uint256 amount, uint256 index, uint256 timestamp);

    event Claimed(address indexed claimer, address receiver, uint256 amount, uint256 index, uint256 timestamp);



}
// File: contracts/Claimable.sol



pragma solidity ^0.8.4;



/**

* @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities

*/

contract Stakeable {





    /**

    * @notice Constructor since this contract is not ment to be used without inheritance

    * push once to stakeholders for it to work proplerly

    */

    constructor() {

        // This push is needed so we avoid index 0 causing bug of index-1

        stakeholders.push();

        uint256 minStakeFlex = 20 * 10 ** 18;

        uint256 minStakeFixed = 500 * 10 ** 18;

        stakeOptions[7 days] = StakeOption(minStakeFlex,21,0);

        stakeOptions[30 days] = StakeOption(minStakeFixed,100,100);

        stakeOptions[91 days] = StakeOption(minStakeFixed,350,350);

        stakeOptions[182 days] = StakeOption(minStakeFixed,800,800);

        stakeOptions[365 days] = StakeOption(minStakeFixed,1800,1800);

    }

    /**

     * @notice

     * A stake struct is used to represent the way we store stake option, 

     * A Stake will the min amount for staking, reward and penalty rate

     */

    struct StakeOption{

        uint256 minStake;

        uint256 rewardRate;

        uint256 penaltyRate;

    }

    /**

     * @notice

     * A stake struct is used to represent the way we store stakes, 

     * A Stake will contain the users address, the amount staked and a timestamp, 

     * Since which is when the stake was made along with state option applied

     */

    struct Stake{

        address user;

        uint256 amount;

        uint256 since;

        uint256 duration;

        uint256 rewardRate;

        uint256 penaltyRate;

    }

    /**

    * @notice Stakeholder is a staker that has active stakes

    */

    struct Stakeholder{

        address user;

        Stake[] address_stakes;

        

    }



     /**

    * @notice 

    * stakes is used to keep track of the INDEX for the stakeOptions in the stakes array

    */

    mapping(uint256 => StakeOption) internal stakeOptions;

    /**

    * @notice 

    *   This is a array where we store all Stakes that are performed on the Contract

    *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping

    */

    Stakeholder[] internal stakeholders;

    /**

    * @notice 

    * stakes is used to keep track of the INDEX for the stakers in the stakes array

    */

    mapping(address => uint256) internal stakes;

    /**

    * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable

    */

    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);



    /**

    * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array

    */

    function _addStakeholder(address staker) internal returns (uint256){

        // Push a empty item to the Array to make space for our new stakeholder

        stakeholders.push();

        // Calculate the index of the last item in the array by Len-1

        uint256 userIndex = stakeholders.length - 1;

        // Assign the address to the new index

        stakeholders[userIndex].user = staker;

        // Add index to the stakeHolders

        stakes[staker] = userIndex;

        return userIndex; 

    }



    /**

    * @notice

    * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container

    * StakeID 

    */

    function _stake(uint256 _amount, uint256 _duration) internal returns(uint256){

        // Simple check so that user does not stake 0 

        require(_amount > 0, "TOKO: Cannot stake nothing");

        require(stakeOptions[_duration].rewardRate > 0, "TOKO: Invalid stake duration");

        require(_amount >= stakeOptions[_duration].minStake, "TOKO: Invalid stake amount");

        

        // Mappings in solidity creates all values, but empty, so we can just check the address

        uint256 index = stakes[msg.sender];

        // block.timestamp = timestamp of the current block in seconds since the epoch

        uint256 timestamp = block.timestamp;

        // See if the staker already has a staked index or if its the first time

        if(index == 0){

            // This stakeholder stakes for the first time

            // We need to add him to the stakeHolders and also map it into the Index of the stakes

            // The index returned will be the index of the stakeholder in the stakeholders array

            index = _addStakeholder(msg.sender);

        }



        // Use the index to push a new Stake

        // push a newly created Stake with the current block timestamp.

        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp, _duration, stakeOptions[_duration].rewardRate, stakeOptions[_duration].penaltyRate));

        // Emit an event that the stake has occured

        emit Staked(msg.sender, _amount, index,timestamp);

        return stakeholders[index].address_stakes.length - 1;

    }



    function _calcReward(address stakerAddr, uint256 stakeID) internal view returns(uint256) {

        require(stakes[stakerAddr] > 0, "TOKO: Stakeholder not found");

        require(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].rewardRate > 0, "TOKO: Stake not found");

        if(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].since + stakeholders[stakes[stakerAddr]].address_stakes[stakeID].duration <= block.timestamp){

            uint256 rewardVal = stakeholders[stakes[stakerAddr]].address_stakes[stakeID].amount * stakeholders[stakes[stakerAddr]].address_stakes[stakeID].rewardRate / 10000;

            if(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].penaltyRate == 0)

            {

                uint256 multiPar = (block.timestamp - stakeholders[stakes[stakerAddr]].address_stakes[stakeID].since) / stakeholders[stakes[stakerAddr]].address_stakes[stakeID].duration;

                rewardVal *= multiPar;

            }

            return rewardVal;

        }

        else return 0;

    }



    function _calcPenalty(address stakerAddr, uint256 stakeID) internal view returns(uint256) {

        require(stakes[stakerAddr] > 0, "TOKO: Stakeholder not found");

        require(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].rewardRate > 0, "TOKO: Stake not found");

        if(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].penaltyRate == 0 || stakeholders[stakes[stakerAddr]].address_stakes[stakeID].since + stakeholders[stakes[stakerAddr]].address_stakes[stakeID].duration <= block.timestamp){

            return 0;

        }

        else return stakeholders[stakes[stakerAddr]].address_stakes[stakeID].amount * stakeholders[stakes[stakerAddr]].address_stakes[stakeID].penaltyRate / 10000;

    }



    function calcMyReward(uint256 stakeID) public view returns(uint256) {

        return _calcReward(msg.sender, stakeID);

    }



    function calcMyPenalty(uint256 stakeID) public view returns(uint256) {

        return _calcPenalty(msg.sender, stakeID);

    }



    function _viewStake(address stakerAddr, uint256 stakeID) internal view returns(address,uint256,uint256,uint256,uint256,uint256) {

        require(stakes[stakerAddr] > 0, "TOKO: Stakeholder not found");

        require(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].rewardRate > 0, "TOKO: Stake not found");

        return (stakerAddr,stakeholders[stakes[stakerAddr]].address_stakes[stakeID].since,stakeholders[stakes[stakerAddr]].address_stakes[stakeID].amount,stakeholders[stakes[stakerAddr]].address_stakes[stakeID].duration,stakeholders[stakes[stakerAddr]].address_stakes[stakeID].rewardRate,stakeholders[stakes[stakerAddr]].address_stakes[stakeID].penaltyRate);

    }



    function viewMyStake(uint256 stakeID) public view returns(address,uint256,uint256,uint256,uint256,uint256) {

        return _viewStake(msg.sender, stakeID);    

    }



}
// File: @openzeppelin/[email protected]/utils/introspection/IERC165.sol


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

// File: @openzeppelin/[email protected]/utils/introspection/ERC165.sol


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

// File: @openzeppelin/[email protected]/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/[email protected]/access/IAccessControl.sol


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

// File: @openzeppelin/[email protected]/utils/Context.sol


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

// File: @openzeppelin/[email protected]/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: @openzeppelin/[email protected]/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// File: @openzeppelin/[email protected]/token/ERC20/IERC20.sol


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

// File: @openzeppelin/[email protected]/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/[email protected]/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/[email protected]/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: contracts/OnlearnyToken.sol


pragma solidity ^0.8.4;








/// @custom:security-contact [email protected]
contract OnLearnyToken is ERC20, ERC20Burnable, Pausable, AccessControl, Claimable, Stakeable{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PLATFORM_ROLE = keccak256("PLATFORM_ROLE");

    uint256 public constant INITIAL_SUPPLY_LIMIT = 1000000000 * 10 ** 18;
    uint256 public constant RELEASE_TIME = 1668125460;
    
    uint256 public NEXT_LIMP_AVAILABLE = RELEASE_TIME + 90 days;
    uint256 public LIMP_DEADLINE = 0;
    uint256 public LIMP_RAISE_POW = 0;
    uint256 public LIMP_KEEP_POW = 0;

    uint256 public UNCLAIMED_AMOUNT = 850000000 * 10 ** 18;

    event LIMPStarted(uint256 beginTime, uint256 endTime);
    event LIMPEnded(uint256 atTime, uint256 raisePow, uint256 keepPow);
    event LIMPVoted(uint256 atTime, uint256 voteOption, uint256 votePow, uint256 voteCost);

    constructor() ERC20("OnLearny Token Test 1", "TOK1"){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PLATFORM_ROLE, msg.sender);

        //mint to owner
        _mint(msg.sender, 90000000 * 10 ** 18);
        _mint(msg.sender, 30000000 * 10 ** 18);
        _mint(msg.sender, 30000000 * 10 ** 18);
        
        _pause();
        
    }

    function openLIMP() public onlyRole(PLATFORM_ROLE) whenNotPaused{
        require(block.timestamp >= NEXT_LIMP_AVAILABLE, "TOKO: The time to start a new poll should be later");
        require(LIMP_DEADLINE == 0, "TOKO: Cannot start a new poll when the previous one still in effect");
        LIMP_DEADLINE = block.timestamp + 15 days;
        NEXT_LIMP_AVAILABLE = block.timestamp + 75 days;
        LIMP_RAISE_POW = 0;
        LIMP_KEEP_POW = 0;
        emit LIMPStarted(block.timestamp,LIMP_DEADLINE);
    }

    function closeLIMP() public onlyRole(PLATFORM_ROLE) whenNotPaused{
        require(LIMP_DEADLINE > 0, "TOKO: Poll is not started yet");
        require(block.timestamp >= LIMP_DEADLINE, "TOKO: Time for this poll is not over yet");
        LIMP_DEADLINE = 0;
        if(LIMP_RAISE_POW > LIMP_KEEP_POW)
        {
            UNCLAIMED_AMOUNT += LIMP_RAISE_POW - LIMP_KEEP_POW;
        }
        emit LIMPEnded(block.timestamp,LIMP_RAISE_POW,LIMP_KEEP_POW);
    }

    function voteLIMP_raise(uint256 votePower) public whenNotPaused{
        require(LIMP_DEADLINE > 0, "TOKO: Poll is not started yet");
        require(block.timestamp <= LIMP_DEADLINE, "TOKO: Time for this poll is over");
        require(balanceOf(msg.sender) >= votePower, "TOKO: Not enough token to vote at this power level");
        uint256 costRate = 40 + block.timestamp % 60;
        uint256 voteCost = votePower * costRate / 100;
        _burn(msg.sender,voteCost);
        LIMP_RAISE_POW += votePower;
        emit LIMPVoted(block.timestamp, 1, votePower, voteCost);
    }

     function voteLIMP_keep(uint256 votePower) public whenNotPaused{
        require(LIMP_DEADLINE > 0, "TOKO: Poll is not started yet");
        require(block.timestamp <= LIMP_DEADLINE, "TOKO: Time for this poll is over");
        require(balanceOf(msg.sender) >= votePower, "TOKO: Not enough token to vote at this power level");
        uint256 costRate = 20 + block.timestamp % 80;
        uint256 voteCost = votePower * costRate / 100;
        _burn(msg.sender,voteCost);
        LIMP_KEEP_POW += votePower;
        emit LIMPVoted(block.timestamp, 0, votePower, voteCost);
    }

    function addClaim(address forAddr, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(amount > 0, "TOKO: Invalid amount");
        require(amount <= UNCLAIMED_AMOUNT, "TOKO: Not enough supply");
        _addClaim(forAddr, amount);
        UNCLAIMED_AMOUNT -= amount;
    }

    function removeClaim(address forAddr) public onlyRole(DEFAULT_ADMIN_ROLE){
        UNCLAIMED_AMOUNT += _viewClaimable(forAddr);
        _removeClaim(forAddr);
    }

    function viewClaimable(address forAddr) public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256){
        return _viewClaimable(forAddr);
    }

    function claimMyTOKO(address toAddr, uint256 amount) public{
        require(amount > 0, "TOKO: Invalid claimable amount");
        require(amount <= _viewClaimable(msg.sender), "TOKO: Invalid claimable amount");
        _mint(toAddr, amount);
        emit Claimed(msg.sender, toAddr, amount, claimers[msg.sender], block.timestamp);
        if(claims[claimers[msg.sender]].amount > amount)
        {
            claims[claimers[msg.sender]].amount -= amount;
        }
        else _removeClaim(msg.sender);
    }

    function emergencyIncLimit() public onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256){
        uint256 limA = totalSupply() / 20;
        uint256 limB = INITIAL_SUPPLY_LIMIT / 10 * 10 ** decimals();
        uint256 available_supply = balanceOf(msg.sender) + UNCLAIMED_AMOUNT;
        if((available_supply < limA) || (available_supply < limB))
        {
            uint256 amount = limA >= limB ? limA:limB;
            UNCLAIMED_AMOUNT += amount;
            return amount;
        }
        else
        {
            return 0;
        }
    }

        function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(UNCLAIMED_AMOUNT >= amount, "TOKO: Not enough supply");
        UNCLAIMED_AMOUNT -= amount;
        _mint(to, amount);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        require(block.timestamp > RELEASE_TIME, "TOKO: Please wait until release time");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20)
    {
        super._burn(account, amount);
    }

    function stake(uint256 amount, uint256 duration) public returns(uint256){
        require(amount <= balanceOf(msg.sender),"TOKO: Not enough token");
        uint256 stakeID = _stake(amount, duration);
        _burn(msg.sender,amount);
        return stakeID;
    }

    function _safeWithdrawStake(address stakerAddr, uint256 stakeID) internal{
        require(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].since + stakeholders[stakes[stakerAddr]].address_stakes[stakeID].duration < block.timestamp, "TOKO: Not enough staking time");
        uint256 wdAmount = stakeholders[stakes[stakerAddr]].address_stakes[stakeID].amount + _calcReward(stakerAddr, stakeID);
        _mint(stakerAddr, wdAmount);
        delete stakeholders[stakes[stakerAddr]].address_stakes[stakeID];
    }

    function _forcewithdrawStake(address stakerAddr, uint256 stakeID) internal{
        if(stakeholders[stakes[stakerAddr]].address_stakes[stakeID].since + stakeholders[stakes[stakerAddr]].address_stakes[stakeID].duration < block.timestamp)
        {
            _safeWithdrawStake(stakerAddr, stakeID);
        }
        else
        {
            uint256 wdAmount = stakeholders[stakes[stakerAddr]].address_stakes[stakeID].amount - _calcPenalty(stakerAddr, stakeID);
            _mint(stakerAddr, wdAmount);
            delete stakeholders[stakes[stakerAddr]].address_stakes[stakeID];
        }
    }


}