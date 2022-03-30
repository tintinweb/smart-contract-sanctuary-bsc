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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IERC20.sol";
import "./libraries/SafeERC20.sol";
import "./interfaces/IAdmin.sol";
import "./interfaces/IIDO.sol";
import {IDO} from "./IDO.sol";

/**
 * @title Admin.
 * @dev tur461 working on this contract!
 * @dev contract creates IDOs.
 *
 */

contract Admin is AccessControl, IAdmin {
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    address public _oracle;
    address public _wallet;
    address public _airdrop;
    address public _stakingContract;

    mapping(address => bool) public _IDO;
    mapping(address => address) public _IDOByOwner;

    constructor(
        address wallet_,
        address airdrop_,
        address oracle_,
        address stakingContract_
    ) {
        // caller is depoyer
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(OPERATOR, DEFAULT_ADMIN_ROLE);

        _oracle = oracle_;
        _wallet = wallet_;
        _airdrop = airdrop_;
        _stakingContract = stakingContract_;
    }

    // ----------------------------------------------------------------------------
    // ------------------------- Mutable Functions --------------------------------
    // ----------------------------------------------------------------------------

    // dev: creates new pool.
    // dev: initializes tokesale contracts, other things related to this contract, etc.
    // param: address_
    // param: timing_
    // param: limit_
    // param: pubSaleEnabled_
    // param: whitelistingNeeded_
    function deployNewIDO(
        IIDO.Address memory address_,
        IIDO.Timing memory timing_,
        IIDO.Limit memory limit_,
        bool pubSaleEnabled_,
        bool whitelistingNeeded_
    ) external override onlyRole(OPERATOR) {
        // pass parameters
        // neccessary checks are already setup in the IDO contract!
        // caller is anyone who is an operator
        address idoAddress = address(new IDO(msg.sender));

        bytes memory initCallData = abi.encodeWithSignature(
            "init((address,address,address,address,address),(uint256,uint256,uint256,uint256),(uint256,uint256,uint256,uint256,uint256,uint256,uint16),bool,bool)",
            address_,
            timing_,
            limit_,
            pubSaleEnabled_,
            whitelistingNeeded_
        );
        (bool passed, bytes memory data) = idoAddress.call(initCallData);
        require(passed, "error calling init on IDO!");

        _IDO[idoAddress] = true;
        _IDOByOwner[address_.owner] = idoAddress;

        // transfer All sale tokens to IDO contract
        // this  contract must be allowed to do that!
        IERC20(address_.saleToken).safeTransferFrom(
            address_.owner,
            idoAddress,
            limit_.totalSupply
        );

        emit NewIdoDeployed(idoAddress);
    }

    function changeWallet(address newWallet_)
        external
        override
        onlyAdmin
        nonZero(newWallet_)
        notSame(_wallet, newWallet_)
    {
        emit WalletChanged(_wallet, newWallet_);
        _wallet = newWallet_;
    }

    function addOperator(address operator_)
        external
        override
        nonZero(operator_)
        onlyAdmin
    {
        grantRole(OPERATOR, operator_);
    }

    function removeOperator(address operator_)
        external
        override
        nonZero(operator_)
        onlyAdmin
    {
        revokeRole(OPERATOR, operator_);
    }

    function changeAirdropAddress(address newAirdrop_)
        external
        override
        onlyRole(OPERATOR)
        nonZero(newAirdrop_)
        notSame(_airdrop, newAirdrop_)
    {
        _airdrop = newAirdrop_;
        emit AirdropChanged(_airdrop, newAirdrop_);
    }

    // dev: set address for staking logic contract.
    function setStakingContract(address newStaking_)
        external
        override
        nonZero(newStaking_)
        notSame(_stakingContract, newStaking_)
        onlyRole(OPERATOR)
    {
        _stakingContract = newStaking_;
    }

    // dev: changes oracle contract address
    function changeOracleContract(address newOracle_)
        external
        override
        nonZero(newOracle_)
        onlyRole(OPERATOR)
    {
        _oracle = newOracle_;
    }

    function containsRole(bytes32 role_, address acc_)
        external
        view
        override
        returns (bool)
    {
        return hasRole(role_, acc_);
    }

    function getIdoByOwner(address owner_) external view override returns(address) {
        return _IDOByOwner[owner_];
    }

    function isAnIDO(address caller_) external view override returns (bool) {
        return _IDO[caller_];
    }

    modifier nonZero(address givenAddress_) {
        require(givenAddress_ != address(0), "invalid address!");
        _;
    }

    modifier notSame(address old_, address new_) {
        require(old_ != new_, "provide different value!");
        _;
    }

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Sender is not an admin"
        );
        _;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "./interfaces/IIDO.sol";
import "./interfaces/IStaking.sol";
import "./libraries/SafeERC20.sol";

/*
 * Most of the functions are to be called by the deployer of the IDO only!
 * init function will be called by admin contract only and that too will happen only once!
 * Max allocation is set by IDO creator as pubN and/or pvtN, 
   meaning for each CFLU purchaser can get N # of sale token/s only
 * In public sale (when enabled) no need to stake CFLU token/s to purchase sale token/s!
 * In this IDO LP, we dont have Tiers but a continous curve formula (1:N), 
   the allocation per participant is proportional 
   to 1/N (pvtN or pubN) CFLUs (set by owner of IDO project) 
   ie for each CFLU staked one will get N xyz Sale Token/s allocations
 * notes:
     functionality not written for handling leftover tokens
 */

// A token sale contract that accepts only desired USD stable coins as a payment. Blocks any direct ETH deposits.
contract IDO is IIDO {
    string private constant ZERO_ERR = "zero address";

    using SafeERC20 for IERC20;

    address public _deployer;
    address payable public _adminContract;
    bool public _fundsWithdrawn;

    Timing public _timing;
    Limit public _limit;

    Address public _address;
    IdoProject public _idoProject;

    // constructor
    constructor(address deployer_) {
        _deployer = deployer_;
        // caller is deployer and which is admin contract
        _adminContract = payable(msg.sender);
    }

    // ------------------------- Impure Functions --------------------------------

    // creates a token sale contract that accepts only BUSD stable coin
    function init(
        Address memory address_,
        Timing memory timing_,
        Limit memory limit_,
        bool pubSaleEnabled_,
        bool whitelistingNeeded_
    )
        external
        notInitialized
        onlyAdminContract
        paramsAreValid(address_, timing_, limit_, pubSaleEnabled_)
    {      
        _idoProject.initialized = true;

        // set addresses
        _address = address_;
        // set timings
        _timing = timing_;
        // set limits
        _limit = limit_;

        // rest
        _idoProject.pvtTokenPrice =
            (_limit.hardcap * 10**_decimals()) /
            _limit.totalSupply;
        _idoProject.liveSaleType = LiveSaleType.NIL;
        _idoProject.pubSaleEnabled = pubSaleEnabled_;
        _idoProject.whitelistingNeeded = whitelistingNeeded_;
        _idoProject.pubTokenPrice = _idoProject.pvtTokenPrice;

        emit Initialized(_deployer);
    }

    // noted: as no fractions allowed so, use 100 for 1%
    function changeProfitPercentageTo(uint16 newPercentage_)
        external
        initialized
        onlyDeployer 
    {
        require(
            _limit.profitPercentage != newPercentage_,
            "already same value!"
        );
        // 10 -> 0.1% and 10000 -> 100%
        require(
            newPercentage_ > 10 && newPercentage_ < 10000,
            "Invalid percentage value!"
        );
        _limit.profitPercentage = newPercentage_;
    }

    function setPublicSaleAbility(bool abled_)
        external
        initialized
        onlyDeployer
    {
        require(_idoProject.pubSaleEnabled != abled_, "already set!");
        _idoProject.pubSaleEnabled = abled_;
        emit PublicSaleEnabled(abled_);
    }

    function setWhitelistingAbility(bool abled_)
        external
        initialized
        onlyDeployer
    {
        require(_idoProject.whitelistingNeeded != abled_, "already set!");
        _idoProject.whitelistingNeeded = abled_;
        emit NeedOfWhitelistingChanged(abled_);
    }

    function setNewBeneficiary(address newBeneficiary_)
        external
        initialized
        onlyDeployer
    {
        require(newBeneficiary_ != address(0), ZERO_ERR);
        require(newBeneficiary_ != _address.beneficiary, "already set!");
        _address.beneficiary = newBeneficiary_;
        emit BeneficiaryChanged(newBeneficiary_);
    }

    function setNewAllocationAmount(uint256 alloc_, bool isPrivate)
        external
        onlyDeployer
    {
        require(alloc_ > 0, "must be non-zero");
        require(
            !isPrivate && _idoProject.pubSaleEnabled,
            "pub sale not enabled!"
        );
        if (isPrivate) {
            require(_limit.pvtN != alloc_, "provide diff value!");
            _limit.pvtN = alloc_;
        } else {
            require(_limit.pubN != alloc_, "provide diff value!");
            _limit.pvtN = alloc_;
        }
        emit AllocationAmountChanged(alloc_, isPrivate);
    }

    function setGiftAllocation(address participant_, uint256 amount_) 
        external 
        onlyDeployer 
        nonZero(participant_) 
    {
        _idoProject.giftAllocForParticipant[participant_] = amount_;
    }     

    function addToWhitelist(address participant_)
        external
        initialized
        onlyDeployer
    {
        require(participant_ != address(0), ZERO_ERR);
        require(!_idoProject.whitelistingNeeded, "whitelisting not needed!");
        require(_idoProject.whitelisted[participant_], "already whitelisted!");
        _idoProject.whitelisted[participant_] = true;
        emit WhitelistedSingle(participant_);
    }

    function addManyToWhitelist(address[] memory participants_)
        external
        onlyDeployer
    {
        require(!_idoProject.whitelistingNeeded, "whitelisting not needed!");
        uint256 count = participants_.length;
        for (uint256 i; i < count; i++) {
            if (!_idoProject.whitelisted[participants_[i]]) {
                _idoProject.whitelisted[participants_[i]] = true;
            }
        }
        emit WhitelistedMany(count, participants_);
    }

    function addManyToWhitelistWithGiftAllocations(address[] memory participants_, uint256[] memory giftedAllocations_)
        external
        onlyDeployer
    {
        require(!_idoProject.whitelistingNeeded, "whitelisting not needed!");
        uint256 count = participants_.length;
        require(giftedAllocations_.length == count, "gifted alloc count must be eq to participant count");
        for (uint256 i; i < count; i++) {
            if (!_idoProject.whitelisted[participants_[i]]) {
                _idoProject.whitelisted[participants_[i]] = true;
                _idoProject.giftAllocForParticipant[participants_[i]] = giftedAllocations_[i];
            }
        }
        emit WhitelistedManyWithGiftAllocation(count, participants_, giftedAllocations_);
    }

    function startPrivateSale()
        external
        initialized
        onlyDeployer
        noSaleIsGoingOn
    {
        _idoProject.liveSaleType = LiveSaleType.PVT;
        emit PrivateSaleStarted(_adminContract);
    }

    function endPrivateSale()
        external
        onlyDeployer
        capLimitReached
        saleIsOngoing
    {
        _idoProject.liveSaleType = LiveSaleType.NIL;
        emit PrivateSaleEnded(_adminContract);
    }

    function startPublicSale()
        external
        initialized
        onlyDeployer
        noSaleIsGoingOn
        hardcapNotReached
        pubSaleEnabled
    {
        _idoProject.liveSaleType = LiveSaleType.PUB;
        emit PublicSaleStarted(_adminContract);
    }

    function endPublicSale()
        external
        onlyDeployer
        capLimitReached
        pubSaleEnabled
        saleIsOngoing
    {
        _idoProject.liveSaleType = LiveSaleType.NIL;
        emit PublicSaleEnded(_adminContract);
    }

    // we will change this logic in future, ie, we wont burn but sell! 
    function burnLeftoverTokens()
        external
        saleHasEnded
        onlyDeployer
    {
        require(
            _idoProject.collected == _limit.hardcap,
            "Hardcap not reached!"
        );
        uint256 tokensLeft = IERC20(_address.saleToken).safeBalanceOf(
            address(this)
        );
        require(tokensLeft > 0, "no leftover tokens to burn!");
        IERC20(_address.saleToken).safeBurn(tokensLeft);
    }

    // any1 can call this function, provided, conditions are met!
    // ip: amount of BUSD tokens
    function purchaseTokens(uint256 amount_)
        external
        saleIsOngoing
        onlyWhitelisted
    {
        require(amount_ > 0, "Amount is 0");
        uint256 normalizedAmntWithDec = this.getNormalizedAmount(amount_);
        amount_ = normalizedAmntWithDec / _decimals();
        bool hcapXceeds = this.willHardcapExceedWith(amount_);
        if (hcapXceeds) {
            amount_ = this.getRemainingAmount();
            normalizedAmntWithDec = amount_ * _decimals();
        }
        uint256 saleTokenAmount = _getEqvAmountOfSaleTokens(
            normalizedAmntWithDec
        );
        require(saleTokenAmount > 0, "no tokens possible for you!");
        require(
            IERC20(_address.stableCoin).allowance(msg.sender, address(this)) >=
                normalizedAmntWithDec,
            "BUSD allowance low"
        );
        _idoProject.balances[msg.sender] += amount_;
        _idoProject.collected += amount_;
        // transfer busd from sender to this contract
        // so approval is must
        IERC20(_address.stableCoin).safeTransferFrom(
            msg.sender,
            normalizedAmntWithDec
        );
        // transfer sale tokens to the sender
        IERC20(_address.saleToken).safeTransferFrom(
            address(this),
            msg.sender,
            saleTokenAmount * IERC20(_address.saleToken).safeDecimals()
        );
        if (hcapXceeds) {
            if (
                _idoProject.pubSaleEnabled &&
                _idoProject.liveSaleType == LiveSaleType.PUB
            ) {
                this.endPublicSale();
            } else {
                this.endPrivateSale();
            }
        }
        if (!_idoProject.participants[msg.sender]) {
            _idoProject.participants[msg.sender] = true;
            _idoProject.participantCount += 1;
        }

        emit Purchased(msg.sender, amount_);
    }

    function withdrawFunds() external onlyDeployer saleHasEnded {
        uint256 amount = IERC20(_address.stableCoin).balanceOf(address(this));
        require(amount > 0, "no funds!");
        _fundsWithdrawn = true;
        uint256 adminzProfitAmount = (amount * _limit.profitPercentage) / 10000;
        amount = amount - adminzProfitAmount;
        // transfer final amount to beneficiary
        IERC20(_address.stableCoin).safeTransfer(_address.beneficiary, amount);
        // transfer the profit part to admin contract
        IERC20(_address.stableCoin).safeTransfer(
            _adminContract,
            adminzProfitAmount
        );

        emit FundsWithdrawn(
            _address.beneficiary,
            amount,
            _adminContract,
            adminzProfitAmount
        );
    }

    function destroyTokenSaleContract(address payable to_)
        external
        saleHasEnded
        onlyDeployer
    {
        require(_fundsWithdrawn, "Please first withdraw the funds!");
        if (to_ == address(0)) {
            to_ = _adminContract;
        }
        // transfer remaining funds (if any?)
        // to to_ address and destroy this contract!
        selfdestruct(to_);
    }

    // ------------------------- Pure Functions ------------------------------

    // returns: max_allocation per per participant
    function getNormalizedAmount(uint256 busdAmount_)
        external
        view
        returns (uint256)
    {
        busdAmount_ *= _decimals();
        uint256 tokenPrice = this.getTokenPrice();
        uint256 maxAlloc = this.getMaxAllocationPerParticipant();
        // uint256 busdAmountEqvTokens = (busdAmount_ * _decimals()) / tokenPrice;
        uint256 prvPurchase = _idoProject.balances[msg.sender] * _decimals();
        uint256 totalTokensForStakedCFLU = _getTokensForStakedCFLU(msg.sender);
        // if totalTokensForStakedCFLU is zero, everything below will result into 0!
        uint256 stakedEqvBusd = tokenPrice * totalTokensForStakedCFLU;
        // first cap stakedEqv busd, if needed!
        if (stakedEqvBusd > maxAlloc) {
            stakedEqvBusd -= (stakedEqvBusd - maxAlloc);
        }
        // now cap given busd amount, if already purchased some!
        if (prvPurchase + busdAmount_ > stakedEqvBusd) {
            busdAmount_ -= ((prvPurchase + busdAmount_) - stakedEqvBusd);
        }

        // uint256 busdPriceInTotal = totalTokensForStakedCFLU * tokenPrice;

        return busdAmount_; // with decimals!
    }

    // returns: max_allocation per per participant in busd
    function getMaxAllocationPerParticipant()
        external
        view
        
        returns (uint256)
    {
        return _limit.maxAllocationShare * _decimals();
    }

    // returns: token_price for current sale in busd
    function getTokenPrice() external view  returns (uint256) {
        if (
            _idoProject.pubSaleEnabled &&
            _idoProject.liveSaleType == LiveSaleType.PUB
        ) {
            return _idoProject.pubTokenPrice;
        }
        return _idoProject.pvtTokenPrice;
    }

    // returns: the end time of the pvt sale
    function pvtEndTime() external view  returns (uint256) {
        return _timing.pvtStart + _timing.pvtDuration;
    }

    // returns: the end time of the pub sale
    function pubEndTime() external view  returns (uint256) {
        return _timing.pubStart + _timing.pubDuration;
    }

    // returns: the balance of the participant in BUSD
    function balanceOf(address participant_)
        external
        view
        
        returns (uint256)
    {
        return _idoProject.balances[participant_];
    }

    // returns: fb if participant is whitelisted
    function isWhitelisted(address participant_)
        external
        view
        
        returns (bool)
    {
        return
            _idoProject.whitelistingNeeded
                ? _idoProject.whitelisted[participant_]
                : true;
    }

    // returns: info if any of sales is still ongoing
    function isLive() external view  returns (bool islive) {
        uint256 nw = _now();
        if (_idoProject.pubSaleEnabled) {
            islive =
                _idoProject.liveSaleType == LiveSaleType.PUB ||
                (nw > _timing.pubStart && nw < this.pubEndTime());
        } else {
            islive =
                _idoProject.liveSaleType == LiveSaleType.PVT ||
                (nw > _timing.pvtStart && nw < this.pvtEndTime());
        }
    }

    function getParticipantCount() external view  returns (uint256) {
        return _idoProject.participantCount;
    }

    // returns: willIt of participant
    function willHardcapExceedWith(uint256 amount_)
        external
        view
        
        returns (bool willIt)
    {
        willIt = amount_ + _idoProject.collected > _limit.hardcap;
    }

    // returns: remaining sale tokens
    function getRemainingAmount()
        external
        view
        
        returns (uint256 remaining)
    {
        remaining = _limit.hardcap - _idoProject.collected;
    }

    function getGiftAllocationFor(address participant_) external view  returns(uint256 amount) {
        amount = _idoProject.giftAllocForParticipant[participant_];
    }

    // ------------------- Internal Pure Functions ----------------------

    // returns: decimals of stable coin (here busd)
    function _decimals() internal view returns (uint256) {
        return IERC20(_address.stableCoin).safeDecimals();
    }

    // returns: time_now
    function _now() internal view returns (uint256) {
        return block.timestamp;
    }

    // returns: allocation of participant in terms of sale tokens
    function _getTokensForStakedCFLU(address participant_)
        internal
        view
        returns (uint256 alloc)
    {
        uint256 n = _idoProject.liveSaleType == LiveSaleType.PUB
            ? _limit.pubN
            : _limit.pvtN;
        // get cflu staked, if any?
        alloc = IStaking(_address.stakingContract).amountStakedBy(participant_);
        if(alloc == 0) {
            // get gifted allocation, if any, for the participant
            alloc = _idoProject.giftAllocForParticipant[participant_];
        } 
        // now convert to total sale tokens as per 1:N ratio
        alloc *= n;
    }

    // param: busdAmount_ with decimals
    // returns: max_allocation per per participant
    function _getEqvAmountOfSaleTokens(uint256 busdAmount_)
        internal
        view
        returns (uint256)
    {
        return busdAmount_ / this.getTokenPrice();
    }

    // ----------------------------- Modifiers -------------------------------

    modifier onlyBeneficiary() {
        require(
            msg.sender == _address.beneficiary,
            "Caller is not the beneficiary"
        );
        _;
    }

    modifier onlyWhitelisted() {
        require(
            !_idoProject.whitelistingNeeded ||
                _idoProject.whitelisted[msg.sender],
            "participant is not whitelisted"
        );
        _;
    }

    modifier saleIsOngoing() {
        require(this.isLive(), "Sale is not active!");
        _;
    }

    modifier hardcapNotReached() {
        require(
            _idoProject.collected < _limit.hardcap,
            "hardcap already reached!"
        );
        _;
    }

    modifier noSaleIsGoingOn() {
        require(!this.isLive(), "Sale is active already!");
        _;
    }

    // notice: PLZ _review this modifier once again
    modifier saleHasEnded() {
        require(_idoProject.liveSaleType != LiveSaleType.NIL, "sale not ended");
        uint256 nw = _now();
        if (_idoProject.pubSaleEnabled) {
            require(
                nw > _timing.pubStart + _timing.pubDuration,
                "sale not ended"
            );
        } else {
            require(
                nw > _timing.pvtStart + _timing.pvtDuration,
                "sale not ended"
            );
        }
        _;
    }

    modifier capLimitReached() {
        require(
            _idoProject.collected >= _limit.hardcap,
            "Cap limit not reached"
        );
        _;
    }

    modifier pubSaleEnabled() {
        require(_idoProject.pubSaleEnabled, "public sale not enabled!");
        _;
    }

    modifier initialized() {
        require(_idoProject.initialized, "tokensale not initialized!");
        _;
    }

    modifier notInitialized() {
        require(!_idoProject.initialized, "tokensale initialized already!");
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == _deployer, "must be deployer of the IDO");
        _;
    }

    modifier onlyAdminContract {
        require(msg.sender == _adminContract, "Forbidden: Only admin contract allowed!");
        _;
    }

    modifier nonZero(address a_) {
        require(a_ != address(a_), "address must be non zero");
        _;
    }

    modifier paramsAreValid(
        Address memory address_,
        Timing memory timing_,
        Limit memory limit_,
        bool pubSaleEnabled_
    ) {
        uint256 _now = _now();

        require(address_.owner != address(0), ZERO_ERR);
        require(address_.saleToken != address(0), ZERO_ERR);
        require(address_.stableCoin != address(0), ZERO_ERR);
        require(address_.beneficiary != address(0), ZERO_ERR);
        require(address_.stakingContract != address(0), ZERO_ERR);

        require(limit_.hardcap > 0, "hardcap cant be 0");
        require(limit_.totalSupply > 0, "total supply cant be 0");
        require(
            limit_.maxAllocationShare > 0,
            "max allocation per user cant be 0!"
        );

        require(
            limit_.pvtN > 0 && limit_.pvtN <= limit_.totalSupply,
            "invalid pvt sale Factor!"
        );

        require(timing_.pvtDuration > 0, "Pvt Duration is 0");
        require(
            timing_.pvtStart + timing_.pvtDuration > _now,
            "Pvt Final time is before current time"
        );

        if (pubSaleEnabled_) {
            require(
                limit_.pubN != 0 && limit_.pubN <= limit_.totalSupply,
                "invalid pub sale Factor!"
            );

            require(timing_.pubDuration != 0, "Pub Duration is 0");
            require(
                timing_.pubStart + timing_.pubDuration > _now,
                "Pub end time is before current time"
            );
            require(
                timing_.pubStart > timing_.pvtStart + timing_.pvtDuration,
                "Pub start time is before pvt end time"
            );
        }

        // 10 -> 0.1% and 10000 -> 100%
        require(
            limit_.profitPercentage > 10 && limit_.profitPercentage < 10000,
            "Invalid percentage value!"
        );

        _;
    }

    // -------------------------- Events ------------------------------------------

    event PublicSaleEnabled(bool);
    event Initialized(address indexed);
    event NeedOfWhitelistingChanged(bool);
    event PublicSaleEnded(address indexed);
    event PrivateSaleEnded(address indexed);
    event PublicSaleStarted(address indexed);
    event WhitelistedSingle(address indexed);
    event Purchased(address indexed, uint256);
    event BeneficiaryChanged(address indexed);
    event PrivateSaleStarted(address indexed);
    event AllocationAmountChanged(uint256, bool);
    event WhitelistedMany(uint256, address[] indexed);
    event FundsWithdrawn(address indexed, uint256, address indexed, uint256);
    event WhitelistedManyWithGiftAllocation(uint256, address[] indexed, uint256[]);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IACL {
    function addOperator(address) external;
    function removeOperator(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IIDO.sol";
import "./IACL.sol";

interface IAdmin is IACL {
    event NewIdoDeployed(address indexed ido_);
    event AirdropChanged(address indexed, address indexed);
    event WalletChanged(address indexed, address indexed);

    function deployNewIDO(
        IIDO.Address memory,
        IIDO.Timing memory,
        IIDO.Limit memory,
        bool,
        bool
    ) external;

    function changeWallet(address) external;

    function changeAirdropAddress(address) external;

    function setStakingContract(address) external;

    function changeOracleContract(address) external;

    function isAnIDO(address) external view returns (bool);

    function getIdoByOwner(address) external view returns(address); 
    
    function containsRole(bytes32, address) external view returns (bool);
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function burn(uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    // EIP 2612
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IIDO {
    enum LiveSaleType {
        PVT,
        PUB,
        NIL
    }

    struct Address {
        address owner;
        address saleToken;
        address stableCoin;
        address beneficiary;
        address stakingContract;
    }

    struct Timing {
        uint256 pubStart;
        uint256 pvtStart;
        uint256 pubDuration;
        uint256 pvtDuration;
    }

    // IDO limits
    struct Limit {
        uint256 pvtN; // # of sale tokens per CFLU in pvt sale
        uint256 pubN; // # of sale tokens per CFLU in pub sale
        uint256 hardcap; // amount of BUSD to to be raised at the most
        uint256 softcap; // amount of BUSD to be raised at the least (if say we couldn't sell all the tokens----means low demand for the tokens!), in order to say IDO is success and the project needs this much at least!
        uint256 totalSupply; // total sale tokens available for sale
        uint256 maxAllocationShare; // to prevent single sided loading i.e single participant shouldn't get most of the tokens!
        uint16 profitPercentage; // part of IDO funds raised which goto admin contract. use 2000 for 20% eg
    }

    struct IdoProject {
        bool initialized; // initialized?
        bool pubSaleEnabled; // is pub sale enabled?
        bool whitelistingNeeded; // is whitelisting needed for participants?
        uint256 collected; // total BUSD collected
        uint256 pubTokenPrice; // will be calc when pvt sale ends and if there are any tokens left
        uint256 pvtTokenPrice; // hardcap / totalSupply
        uint256 participantCount; // keep track of # of participants
        LiveSaleType liveSaleType; // current sale type
        mapping(address => bool) whitelisted;
        mapping(address => uint256) balances; // account balance in BUSD
        mapping(address => bool) participants; // participants in the ido project (subset of stakers)
        mapping(address => uint256) giftAllocForParticipant; // allocation for non-staking participants --- controlled by admin 
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IStaking {
    function unstake(uint256) external;

    function stake(uint256) external;

    function setIdoEndTime(address, uint32) external;

    function amountStakedBy(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

library SafeERC20 {
    function safeBalanceOf(IERC20 token, address of_)
        internal
        view
        returns (uint256)
    {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x70a08231, of_)
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeSymbol(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x95d89b41)
        );
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x06fdde03)
        );
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) internal view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSelector(0x313ce567)
        );
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeBurn(IERC20 token, uint256 amount_) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x42966c68, amount_)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: Transfer failed"
        );
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0xa9059cbb, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: Transfer failed"
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        uint256 amount
    ) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x23b872dd, from, address(this), amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: TransferFrom failed"
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(0x23b872dd, from, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeERC20: TransferFrom failed"
        );
    }
}