// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '../utils/PirateWarAccessControl.sol';
import '../nft/IPirateWarCharacter.sol';
import '../nft/IPirateWarGear.sol';

contract PreMint is Pausable {
  uint256[17] public _premintAmounts;
  uint256[4] public _gearPremintAmounts;

  uint256[17] public _mintLimits;
  uint256[4] public _gearMintLimits;

  uint256 public _totalSold = 0;
  uint256 public _totalGearSold = 0;

  address public _nftContract;
  address public _gearNftContract;
  address public _tokenContract;
  PirateWarAccessControl public _accessControl;

  // Duration of premint
  uint256 public _startTime;
  uint256 public _endTime;

  constructor(
    address nftContract,
    address gearNftContract,
    address tokenContract,
    address accessControl
  ) {
    _nftContract = nftContract;
    _tokenContract = tokenContract;
    _gearNftContract = gearNftContract;
    _accessControl = PirateWarAccessControl(accessControl);

    // character premint price per class
    // captains 150 BUSD / 200 Limit
    _premintAmounts[0] = 150 ether; // captain 1
    _premintAmounts[1] = 150 ether; // captain 2
    _mintLimits[0] = 200; // captain 1
    _mintLimits[1] = 200; // captain 2

    // quartermasters 100 BUSD / 300 Limit
    _premintAmounts[2] = 100 ether; // quartermaster 1
    _premintAmounts[3] = 100 ether; // quartermaster 2
    _premintAmounts[4] = 100 ether; // quartermaster 3
    _mintLimits[2] = 300; // quartermaster 1
    _mintLimits[3] = 300; // quartermaster 2
    _mintLimits[4] = 300; // quartermaster 3

    // gunners 75 BUSD / 500 Limit
    _premintAmounts[5] = 75 ether; // gunner 1
    _premintAmounts[6] = 75 ether; // gunner 2
    _premintAmounts[7] = 75 ether; // gunner 3
    _mintLimits[5] = 500; // gunner 1
    _mintLimits[6] = 500; // gunner 2
    _mintLimits[7] = 500; // gunner 3

    // cabin crew 75 BUSD / 500 Limit
    _premintAmounts[8] = 75 ether; // cabin crew 1
    _premintAmounts[9] = 75 ether; // cabin crew 2
    _premintAmounts[10] = 75 ether; // cabin crew 3
    _premintAmounts[11] = 75 ether; // cabin crew 4
    _mintLimits[8] = 500; // cabin crew 1
    _mintLimits[9] = 500; // cabin crew 2
    _mintLimits[10] = 500; // cabin crew 3

    // supports 50 BUSD / 700 Limit
    _premintAmounts[12] = 50 ether; // support 1
    _premintAmounts[13] = 50 ether; // support 2
    _premintAmounts[14] = 50 ether; // support 3
    _premintAmounts[15] = 50 ether; // support 4
    _premintAmounts[16] = 50 ether; // support 5
    _mintLimits[12] = 700; // support 1
    _mintLimits[13] = 700; // support 2
    _mintLimits[14] = 700; // support 3
    _mintLimits[15] = 700; // support 4
    _mintLimits[16] = 700; // support 5

    // Gears
    // 40 BUSD / 1000 Limit
    _gearPremintAmounts[0] = 40 ether; // gear 1
    _gearPremintAmounts[1] = 40 ether; // gear 2
    _gearPremintAmounts[2] = 40 ether; // gear 3
    _gearPremintAmounts[3] = 40 ether; // gear 4
    _gearMintLimits[0] = 1000; // gear 1
    _gearMintLimits[1] = 1000; // gear 2
    _gearMintLimits[2] = 1000; // gear 3
    _gearMintLimits[3] = 1000; // gear 4
  }

  modifier onlyAdmin() {
    require(_accessControl.hasAdminRole(msg.sender));
    _;
  }

  // ------ Public functions ------

  /**
   * @dev get the price of a character base on its class
   */
  function getMintPrice(uint256 _index) public view returns (uint256) {
    require(_index < _premintAmounts.length);

    return _premintAmounts[_index];
  }

  /**
   * @dev get the available amount of a character base on its class
   */
  function getMintLimit(uint256 _index) public view returns (uint256) {
    require(_index < _mintLimits.length);

    return _mintLimits[_index];
  }

  /**
   * @dev get the price of a gear base on its class
   */
  function getGearMintPrice(uint256 _index) public view returns (uint256) {
    require(_index < _gearPremintAmounts.length);

    return _gearPremintAmounts[_index];
  }

  /**
   * @dev get the available amount of a gear base on its class
   */
  function getGearMintLimits(uint256 _index) public view returns (uint256) {
    require(_index < _gearMintLimits.length);

    return _gearMintLimits[_index];
  }

  /**
   * @dev mint new character
   */
  function mintNewCharacters(uint256 qty, uint256 classType) public whenNotPaused {
    // Check busd balance
    uint256 tokenBalance = IERC20(_tokenContract).balanceOf(msg.sender);
    uint256 premintPrice = getMintPrice(classType);
    uint256 tokenAmountToPay = qty * premintPrice;
    uint256 mintLimit = getMintLimit(classType);

    require(mintLimit > 0, 'Mint limit is 0');
    require(tokenBalance >= tokenAmountToPay, 'Not enough tokens');
    require(block.timestamp > _startTime, 'Premint not started yet');
    require(block.timestamp < _endTime, 'Premint ended');

    // reduce mint stock
    _mintLimits[classType] -= qty;
    _totalSold += qty;

    // Collect payment
    IERC20(_tokenContract).transferFrom(msg.sender, address(this), tokenAmountToPay);

    // Create new characters
    IPirateWarCharacter(_nftContract).summonNewPirates(msg.sender, qty, classType);
  }

  /**
   * @dev mint new gears
   */
  function mintNewGears(uint256 qty, uint256 gearType) public whenNotPaused {
    // Check busd balance
    uint256 tokenBalance = IERC20(_tokenContract).balanceOf(msg.sender);
    uint256 premintPrice = getGearMintPrice(gearType);
    uint256 tokenAmountToPay = qty * premintPrice;
    uint256 mintLimit = getGearMintLimits(gearType);

    require(mintLimit > 0, 'Mint limit is 0');
    require(tokenBalance >= tokenAmountToPay, 'Not enough tokens');
    require(block.timestamp > _startTime, 'Premint not started yet');
    require(block.timestamp < _endTime, 'Premint ended');

    _gearMintLimits[gearType] -= qty;
    _totalGearSold += qty;

    // Collect payment
    IERC20(_tokenContract).transferFrom(msg.sender, address(this), tokenAmountToPay);

    // Create new gears
    IPirateWarGear(_gearNftContract).mintNewGears(msg.sender, qty, gearType);
  }

  // ------ Admin functions ------

  function pause() public whenPaused {
    require(_accessControl.hasPauserRole(msg.sender), 'Only pauser can pause');

    _pause();
  }

  function unpause() public whenPaused {
    require(_accessControl.hasPauserRole(msg.sender), 'Only pauser can pause');

    _unpause();
  }

  /**
   * @dev Set the premint amount base on index
   */
  function setPremintAmount(uint256 index, uint256 amount) public onlyAdmin {
    require(index < _premintAmounts.length, 'Index out of range');
    require(amount > 0, 'Amount must be greater than 0');

    _premintAmounts[index] = amount;
  }

  /**
   * @dev Set the premint amount base on index
   */
  function setGearPremintAmount(uint256 index, uint256 amount) public onlyAdmin {
    require(index < _gearPremintAmounts.length, 'Index out of range');
    require(amount > 0, 'Amount must be greater than 0');

    _gearPremintAmounts[index] = amount;
  }

  /**
   * @dev Set the premint limit base on index
   */
  function setPremintLimits(uint256 index, uint256 limit) public onlyAdmin {
    require(index < _mintLimits.length, 'Index out of range');
    require(limit > 0, 'Limit must be greater than 0');

    _mintLimits[index] = limit;
  }

  /**
   * @dev Set the premint limit base on index
   */
  function setGearPremintLimits(uint256 index, uint256 limit) public onlyAdmin {
    require(index < _gearMintLimits.length, 'Index out of range');
    require(limit > 0, 'Limit must be greater than 0');

    _gearMintLimits[index] = limit;
  }

  /**
   * @dev Set the NFT contract address
   */
  function setNFTContract(address nftContract) public onlyAdmin {
    require(nftContract != address(0), 'NFT contract address cannot be 0');

    _nftContract = nftContract;
  }

  /**
   * @dev Set the NFT contract address for gear
   */
  function setGearNFTContract(address gearNftContract) public onlyAdmin {
    require(gearNftContract != address(0), 'Gear NFT contract address cannot be 0');

    _gearNftContract = gearNftContract;
  }

  /**
   * @dev Set the preminting start time and end time
   */
  function setPremintingTime(uint256 startTime, uint256 endTime) public onlyAdmin {
    require(startTime < endTime, 'Start time must be before end time');

    _startTime = startTime;
    _endTime = endTime;
  }

  /**
   * @dev Collect the sales
   */
  function collectSales() public onlyAdmin {
    uint256 tokenBalance = IERC20(_tokenContract).balanceOf(address(this));
    require(tokenBalance > 0, 'No funds to collect');
    // approve the token to the contract
    IERC20(_tokenContract).approve(address(this), tokenBalance);

    // Transfer token balance to collector
    IERC20(_tokenContract).transferFrom(address(this), msg.sender, tokenBalance);
  }

  // ------ Private functions ------
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
pragma solidity ^0.8.2;

import '@openzeppelin/contracts/access/AccessControl.sol';

contract PirateWarAccessControl is AccessControl {
  bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
  bytes32 public constant CEO_ROLE = keccak256('CEO_ROLE');
  bytes32 public constant CTO_ROLE = keccak256('CTO_ROLE');
  bytes32 public constant CONTRACT_ROLE = keccak256('CONTRACT_ROLE');
  bytes32 public constant OPERATOR_ROLE = keccak256('OPERATOR_ROLE');

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(PAUSER_ROLE, msg.sender);
  }

  function hasPauserRole(address _account) public view returns (bool) {
    return hasRole(PAUSER_ROLE, _account);
  }

  function hasAdminRole(address _account) public view returns (bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, _account);
  }

  function hasOperatorRole(address _account) public view returns (bool) {
    return hasRole(OPERATOR_ROLE, _account);
  }

  function hasContractRole(address _account) public view returns (bool) {
    return hasRole(CONTRACT_ROLE, _account);
  }

  function hasMinterRole(address _account) public view returns (bool) {
    return hasRole(MINTER_ROLE, _account);
  }

  function hasCTORole(address _account) public view returns (bool) {
    return hasRole(CTO_ROLE, _account);
  }

  function hasCEORole(address _account) public view returns (bool) {
    return hasRole(CEO_ROLE, _account);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IPirateWarCharacter {
  function getUserPirates() external view returns (uint256[] memory);

  function summonNewPirate(address to, uint256 classType) external;

  function summonNewPirates(
    address to,
    uint256 count,
    uint256 classType
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IPirateWarGear {
  function getUserGears() external view returns (uint256[] memory);

  function mintNewGear(address to, uint256 gearType) external;

  function mintNewGears(
    address to,
    uint256 count,
    uint256 gearType
  ) external;
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