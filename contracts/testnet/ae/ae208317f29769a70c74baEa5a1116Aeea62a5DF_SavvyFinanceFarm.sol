/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;



// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IAccessControl

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

// Part: OpenZeppelin/[email protected]/IERC165

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

// Part: OpenZeppelin/[email protected]/IERC20

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

// Part: OpenZeppelin/[email protected]/Strings

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

// Part: OpenZeppelin/[email protected]/ERC165

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

// Part: OpenZeppelin/[email protected]/Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Part: OpenZeppelin/[email protected]/AccessControl

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

// File: SavvyFinanceFarm.sol

contract SavvyFinanceFarm is Ownable, AccessControl {
    address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    address public developmentWallet;
    uint256 public minimumStakingFee;
    uint256 public maximumStakingFee;
    uint256 public minimumStakingApr;
    uint256 public maximumStakingApr;
    mapping(address => bool) public isExcludedFromFees;
    mapping(uint256 => string) public tokenTypeNumberToName;

    address[] public tokens;
    mapping(address => bool) public tokenIsActive;
    struct TokenDetails {
        string name;
        uint256 _type;
        uint256 balance;
        uint256 price;
        uint256 stakeFee;
        uint256 unstakeFee;
        uint256 stakingApr;
        address rewardToken;
        address admin;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => TokenDetails) public tokensData;

    address[] public stakers;
    mapping(address => bool) public stakerIsActive;
    struct StakerDetails {
        uint256 uniqueTokensStaked;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => StakerDetails) public stakersData;

    struct StakerRewardDetails {
        uint256 id;
        address token;
        address rewardToken;
        uint256 rewardAmount;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    mapping(address => StakerRewardDetails[]) public stakersRewardsData;

    struct StakingDetails {
        uint256 balance;
        address rewardToken;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    // token => staker => StakingDetails
    mapping(address => mapping(address => StakingDetails)) public stakingData;

    struct StakingRewardDetails {
        uint256 balance;
        uint256 timestampAdded;
        uint256 timestampLastUpdated;
    }
    // reward_token => staker => StakingRewardDetails
    mapping(address => mapping(address => StakingRewardDetails))
        public stakingRewardsData;

    event Stake(address indexed staker, address indexed token, uint256 amount);
    event Unstake(
        address indexed staker,
        address indexed token,
        uint256 amount
    );
    event WithdrawStakingReward(
        address indexed staker,
        address indexed reward_token,
        uint256 amount
    );

    // constructor() {
    //     developmentWallet = _msgSender();
    //     minimumStakingFee = 0;
    //     maximumStakingFee = toWei(10);
    //     minimumStakingApr = toWei(50);
    //     maximumStakingApr = toWei(1000);
    //     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    // }

    function initialize() external {
        developmentWallet = _msgSender();
        minimumStakingFee = 0;
        maximumStakingFee = toWei(10);
        minimumStakingApr = toWei(50);
        maximumStakingApr = toWei(1000);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _transferOwnership(_msgSender());
    }

    function toRole(address a) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(a));
    }

    function toWei(uint256 _number) public pure returns (uint256) {
        return _number * (10**18);
    }

    function fromWei(uint256 _number) public pure returns (uint256) {
        return _number / (10**18);
    }

    function secondsToYears(uint256 _seconds) public pure returns (uint256) {
        return fromWei(_seconds * (0.0000000317098 * (10**18)));
    }

    function tokenExists(address _token) public view returns (bool) {
        for (uint256 tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++) {
            if (tokens[tokenIndex] == _token) return true;
        }
        return false;
    }

    function stakerExists(address _staker) public view returns (bool) {
        for (
            uint256 stakerIndex = 0;
            stakerIndex < stakers.length;
            stakerIndex++
        ) {
            if (stakers[stakerIndex] == _staker) return true;
        }
        return false;
    }

    function getTokens() public view returns (address[] memory) {
        return tokens;
    }

    function getTokenValue(address _token) public view returns (uint256) {
        return tokensData[_token].balance * tokensData[_token].price;
    }

    function getStakers() public view returns (address[] memory) {
        return stakers;
    }

    function getStakerRewardsData(address _staker)
        public
        view
        returns (StakerRewardDetails[] memory)
    {
        return stakersRewardsData[_staker];
    }

    function setDevelopmentWallet(address _developmentWallet) public onlyOwner {
        developmentWallet = _developmentWallet;
    }

    function setStakingFeeDetails(
        uint256 _minimumStakingFee,
        uint256 _maximumStakingFee
    ) public onlyOwner {
        minimumStakingFee = _minimumStakingFee;
        maximumStakingFee = _maximumStakingFee;
    }

    function setStakingAprDetails(
        uint256 _minimumStakingApr,
        uint256 _maximumStakingApr
    ) public onlyOwner {
        minimumStakingApr = _minimumStakingApr;
        maximumStakingApr = _maximumStakingApr;
    }

    function excludeFromFees(address _address) public onlyOwner {
        isExcludedFromFees[_address] = true;
    }

    function includeInFees(address _address) public onlyOwner {
        isExcludedFromFees[_address] = false;
    }

    function setTokenTypeNumberToName(uint256 _number, string memory _name)
        public
        onlyOwner
    {
        tokenTypeNumberToName[_number] = _name;
    }

    function addToken(
        address _token,
        string memory _name,
        uint256 _type,
        uint256 _stakeFee,
        uint256 _unstakeFee,
        uint256 _stakingApr,
        address _reward_token,
        address _admin
    ) public onlyOwner {
        require(!tokenExists(_token), "Token already exists.");
        _setupRole(toRole(_token), _msgSender());
        tokens.push(_token);
        tokensData[_token].name = _name;
        tokensData[_token]._type = _type;
        tokensData[_token].timestampAdded = block.timestamp;
        setTokenStakingFees(
            _token,
            _stakeFee == 0 ? toWei(1) : _stakeFee,
            _unstakeFee == 0 ? toWei(1) : _unstakeFee
        );
        setTokenStakingApr(_token, _stakingApr == 0 ? toWei(365) : _stakingApr);
        setTokenRewardToken(
            _token,
            _reward_token == address(0x0) ? _token : _reward_token
        );
        setTokenAdmin(_token, _admin == address(0x0) ? _msgSender() : _admin);
    }

    function activateToken(address _token) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokenIsActive[_token] = true;
    }

    function deactivateToken(address _token) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokenIsActive[_token] = false;
    }

    function setTokenName(address _token, string memory _name)
        public
        onlyOwner
    {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].name = _name;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenPrice(address _token, uint256 _price) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        tokensData[_token].price = _price;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenAdmin(address _token, address _admin) public onlyOwner {
        require(tokenExists(_token), "Token does not exist.");
        if (tokensData[_token].admin != owner())
            revokeRole(toRole(_token), tokensData[_token].admin);
        tokensData[_token].admin = _admin;
        tokensData[_token].timestampLastUpdated = block.timestamp;
        grantRole(toRole(_token), tokensData[_token].admin);
    }

    function setTokenStakingFees(
        address _token,
        uint256 _stakeFee,
        uint256 _unstakeFee
    ) public onlyOwner {
        setTokenStakeFee(_token, _stakeFee);
        setTokenUnstakeFee(_token, _unstakeFee);
    }

    function setTokenStakeFee(address _token, uint256 _stakeFee)
        public
        onlyOwner
    {
        require(tokenExists(_token), "Token does not exist.");
        require(
            _stakeFee >= minimumStakingFee && _stakeFee <= maximumStakingFee,
            string(
                abi.encodePacked(
                    "Stake fee must be between",
                    fromWei(minimumStakingFee),
                    "and",
                    fromWei(maximumStakingFee),
                    "."
                )
            )
        );
        tokensData[_token].stakeFee = _stakeFee;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenUnstakeFee(address _token, uint256 _unstakeFee)
        public
        onlyOwner
    {
        require(tokenExists(_token), "Token does not exist.");
        require(
            _unstakeFee >= minimumStakingFee &&
                _unstakeFee <= maximumStakingFee,
            string(
                abi.encodePacked(
                    "Unstake fee must be between",
                    fromWei(minimumStakingFee),
                    "and",
                    fromWei(maximumStakingFee),
                    "."
                )
            )
        );
        tokensData[_token].unstakeFee = _unstakeFee;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenStakingApr(address _token, uint256 _stakingApr)
        public
        onlyRole(toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(
            _stakingApr >= minimumStakingApr &&
                _stakingApr <= maximumStakingApr,
            string(
                abi.encodePacked(
                    "Staking APR must be between",
                    fromWei(minimumStakingApr),
                    "and",
                    fromWei(maximumStakingApr),
                    "."
                )
            )
        );
        tokensData[_token].stakingApr = _stakingApr;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function setTokenRewardToken(address _token, address _reward_token)
        public
        onlyRole(toRole(_token))
        onlyRole(toRole(_reward_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(tokenExists(_reward_token), "Reward token does not exist.");
        tokensData[_token].rewardToken = _reward_token;
        tokensData[_token].timestampLastUpdated = block.timestamp;
    }

    function depositToken(address _token, uint256 _amount)
        public
        onlyRole(toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            IERC20(_token).balanceOf(_msgSender()) >= _amount,
            "Insufficient token balance."
        );
        IERC20(_token).transferFrom(_msgSender(), address(this), _amount);
        tokensData[_token].balance += _amount;
    }

    function withdrawToken(address _token, uint256 _amount)
        public
        onlyRole(toRole(_token))
    {
        require(tokenExists(_token), "Token does not exist.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            tokensData[_token].balance >= _amount,
            "Amount is greater than token balance."
        );
        tokensData[_token].balance -= _amount;
        IERC20(_token).transfer(_msgSender(), _amount);
    }

    function stakeToken(address _token, uint256 _amount) public {
        require(tokenIsActive[_token], "Token not active.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            IERC20(_token).balanceOf(_msgSender()) >= _amount,
            "Insufficient token balance."
        );

        uint256 stakeFee = (_amount / toWei(100)) * tokensData[_token].stakeFee;
        uint256 stakeAmount;
        if (stakeFee == 0 || isExcludedFromFees[_msgSender()]) {
            stakeAmount = _amount;
        } else {
            IERC20(_token).transferFrom(
                _msgSender(),
                developmentWallet,
                stakeFee
            );
            stakeAmount = _amount - stakeFee;
        }
        IERC20(_token).transferFrom(_msgSender(), address(this), stakeAmount);

        if (stakingData[_token][_msgSender()].balance == 0) {
            if (stakersData[_msgSender()].uniqueTokensStaked == 0) {
                if (!stakerExists(_msgSender())) stakers.push(_msgSender());
                stakerIsActive[_msgSender()] = true;
            }
            stakersData[_msgSender()].uniqueTokensStaked++;
            stakersData[_msgSender()].timestampAdded == 0
                ? stakersData[_msgSender()].timestampAdded = block.timestamp
                : stakersData[_msgSender()].timestampLastUpdated = block
                .timestamp;
            stakingData[_token][_msgSender()].rewardToken = _token;
        } else {
            rewardStaker(_msgSender(), _token);
        }

        stakingData[_token][_msgSender()].balance += stakeAmount;
        stakingData[_token][_msgSender()].timestampAdded == 0
            ? stakingData[_token][_msgSender()].timestampAdded = block.timestamp
            : stakingData[_token][_msgSender()].timestampLastUpdated = block
            .timestamp;
        emit Stake(_msgSender(), _token, stakeAmount);
    }

    function unstakeToken(address _token, uint256 _amount) public {
        // require(tokenIsActive[_token], "Token not active.");
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            stakingData[_token][_msgSender()].balance >= _amount,
            "Amount is greater than token staking balance."
        );

        rewardStaker(_msgSender(), _token);

        if (stakingData[_token][_msgSender()].balance == _amount) {
            if (stakersData[_msgSender()].uniqueTokensStaked == 1) {
                stakerIsActive[_msgSender()] = false;
            }
            stakersData[_msgSender()].uniqueTokensStaked--;
            stakersData[_msgSender()].timestampLastUpdated = block.timestamp;
        }

        stakingData[_token][_msgSender()].balance -= _amount;
        stakingData[_token][_msgSender()].timestampAdded == 0
            ? stakingData[_token][_msgSender()].timestampAdded = block.timestamp
            : stakingData[_token][_msgSender()].timestampLastUpdated = block
            .timestamp;

        uint256 unstakeFee = (_amount / toWei(100)) *
            tokensData[_token].unstakeFee;
        uint256 unstakeAmount;
        if (unstakeFee == 0 || isExcludedFromFees[_msgSender()]) {
            unstakeAmount = _amount;
        } else {
            IERC20(_token).transfer(developmentWallet, unstakeFee);
            unstakeAmount = _amount - unstakeFee;
        }
        IERC20(_token).transfer(_msgSender(), unstakeAmount);
        emit Unstake(_msgSender(), _token, unstakeAmount);
    }

    function withdrawStakingReward(address _reward_token, uint256 _amount)
        public
    {
        require(_amount > 0, "Amount must be greater than zero.");
        require(
            stakingRewardsData[_reward_token][_msgSender()].balance >= _amount,
            "Amount is greater than reward token balance."
        );
        stakingRewardsData[_reward_token][_msgSender()].balance -= _amount;
        IERC20(_reward_token).transfer(_msgSender(), _amount);
        emit WithdrawStakingReward(_msgSender(), _reward_token, _amount);
    }

    function setStakingRewardToken(address _token, address _reward_token)
        public
    {
        setStakerRewardToken(_msgSender(), _token, _reward_token, true);
    }

    function setStakerRewardToken(
        address _staker,
        address _token,
        address _reward_token,
        bool validate
    ) internal returns (address) {
        if (validate) {
            require(
                stakerIsActive[_msgSender()],
                "Staker does not have this token staked."
            );
            require(tokenIsActive[_token], "Token not active.");
            require(tokenIsActive[_reward_token], "Reward token not active.");
        }
        stakingData[_token][_staker].rewardToken = _reward_token;
        return stakingData[_token][_staker].rewardToken;
    }

    function calculateStakerRewardValue(address _staker, address _token)
        internal
        view
        returns (uint256)
    {
        if (!tokenExists(_token)) return 0;
        TokenDetails memory tokenData = tokensData[_token];
        if (!stakerExists(_staker)) return 0;
        StakingDetails memory stakerData = stakingData[_token][_staker];
        if (stakerData.balance <= 0) return 0;

        uint256 stakerValue = fromWei(stakerData.balance * tokenData.price);
        uint256 rate = tokenData.stakingApr / 100;
        uint256 timestampStarted = stakerData.timestampLastUpdated != 0
            ? stakerData.timestampLastUpdated
            : stakerData.timestampAdded;
        uint256 timestampEnded = block.timestamp;
        uint256 timeInSeconds = toWei(timestampEnded - timestampStarted);
        uint256 timeInYears = secondsToYears(timeInSeconds);

        return (stakerValue * rate * timeInYears) / (10**36);
    }

    function rewardStaker(address _staker, address _token) internal {
        if (!tokenIsActive[_token]) return;
        if (!stakerIsActive[_staker]) return;

        TokenDetails memory tokenData = tokensData[_token];
        StakingDetails memory stakingData1 = stakingData[_token][_staker];
        if (stakingData1.balance <= 0) return;

        if (!tokenIsActive[stakingData1.rewardToken]) {
            if (stakingData1.rewardToken == tokenData.rewardToken) return;
            stakingData1.rewardToken = setStakerRewardToken(
                _staker,
                _token,
                tokenData.rewardToken,
                false
            );
            if (!tokenIsActive[stakingData1.rewardToken]) return;
        }

        uint256 stakerRewardValue = calculateStakerRewardValue(_staker, _token);
        uint256 stakerRewardTokenValue = getTokenValue(
            stakingData1.rewardToken
        );

        if (stakerRewardTokenValue < stakerRewardValue) {
            if (stakingData1.rewardToken == tokenData.rewardToken) {
                deactivateToken(_token);
                return;
            }
            stakingData1.rewardToken = setStakerRewardToken(
                _staker,
                _token,
                tokenData.rewardToken,
                false
            );
            stakerRewardTokenValue = getTokenValue(stakingData1.rewardToken);
            if (stakerRewardTokenValue < stakerRewardValue) {
                deactivateToken(_token);
                return;
            }
        }

        uint256 stakerRewardTokenAmount = toWei(
            stakerRewardValue / tokensData[stakingData1.rewardToken].price
        );
        if (stakerRewardTokenAmount <= 0) return;

        tokensData[stakingData1.rewardToken].balance -= stakerRewardTokenAmount;
        tokensData[stakingData1.rewardToken].timestampLastUpdated = block
            .timestamp;
        stakingRewardsData[stakingData1.rewardToken][_staker]
            .balance += stakerRewardTokenAmount;
        stakingRewardsData[stakingData1.rewardToken][_staker]
            .timestampLastUpdated = block.timestamp;

        StakerRewardDetails memory stakerRewardData;
        stakerRewardData.id = stakersRewardsData[_staker].length;
        stakerRewardData.token = _token;
        stakerRewardData.rewardToken = stakingData1.rewardToken;
        stakerRewardData.rewardAmount = stakerRewardTokenAmount;
        stakerRewardData.timestampAdded = block.timestamp;
        stakersRewardsData[_staker].push(stakerRewardData);
    }

    function rewardStakers() public onlyOwner {
        for (uint256 tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++) {
            address token = tokens[tokenIndex];

            for (
                uint256 stakerIndex = 0;
                stakerIndex < stakers.length;
                stakerIndex++
            ) {
                address staker = stakers[stakerIndex];

                rewardStaker(staker, token);
            }
        }
    }

    function transferToken(
        address _token,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }
}