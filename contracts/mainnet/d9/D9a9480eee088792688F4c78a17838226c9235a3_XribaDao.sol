// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.11;

import "./access/AccessControl.sol";
import "./access/Ownable.sol";

abstract contract vaultInterface {
 function balanceOf(address _owner) public virtual view returns (uint256);
}

contract XribaDao is  AccessControl, Ownable {
  vaultInterface public vaultDao;

  bytes32 public constant DEV_ROLE = keccak256("DEV");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");


  uint32 public sprintPeriod;
  uint32 public proposalPeriod;
  uint32 public effortPeriod;
  uint32 public votingPeriod;
  uint256 public lastProposalId;
  uint256 public maxEffort;
  uint256 public currentSprintNumber;
  uint256 public currentSprintStartTime;
  uint256 public minimumTokens;

  constructor (uint32 _sprintPeriod, uint32 _proposalPeriod, uint32 _effortPeriod, uint32 _votingPeriod, uint256 _startTime) {
    sprintPeriod = _sprintPeriod;
    proposalPeriod = _proposalPeriod;
    effortPeriod = _effortPeriod;
    votingPeriod = _votingPeriod;
    maxEffort = 10;
    minimumTokens = 1000e18;
    currentSprintStartTime = _startTime;
    currentSprintNumber = 1;
  }

  struct Proposal {
    uint256 id;
    uint256 timestamp;
    address proposer;
    string title;
    string description;
    uint256 votesUp;
    uint256 votesDown;
    uint256 rank;
    uint256 effortFor;
  }

  struct Sprint {
    uint256 id;
    uint256 start;
    uint256 end;
    Proposal[] winningProposals;
  }

  mapping(uint256 => Proposal[]) public sprintProposal;
  mapping(address => mapping(uint256 => mapping(uint256 => bool))) public proposalAddressVoted;
  mapping(uint256 => Sprint) public sprints;

  function setVaultAddress(address _tkn) public onlyOwner {
    vaultDao = vaultInterface(_tkn);
  }

  event NewProposal(address indexed proposer, string title, string description);
  event NewEffort(uint256 proposalId, uint256 supportEffort);

  modifier onlyDev() {
    require(hasRole(DEV_ROLE, msg.sender), "Only dev are allowed to effort");
    _;
  }
  modifier onlyAdmin() {
    require(hasRole(ADMIN_ROLE, msg.sender), "Only admin is allowed");
    _;
  }
  modifier onlyQualifiedTokenHolders() {
    require(vaultDao.balanceOf(msg.sender) >= minimumTokens, "The user does not have the minimum required tokens");
    _;
  }

  function makeDev(address account) external onlyAdmin {    
    _setupRole(DEV_ROLE, account);
  }
  function revokeDev(address account) external onlyAdmin {    
    _revokeRole(DEV_ROLE, account);
  }
  function isDev(address account) public view returns (bool) {
    return hasRole(DEV_ROLE, account);
  }

  function makeAdmin(address account) external onlyOwner {
    _setupRole(ADMIN_ROLE, account);
  }
  function revokeAdmin(address account) external onlyOwner { 
    _revokeRole(ADMIN_ROLE, account);
  }
  function isAdmin(address account) public view returns (bool) {
    return hasRole(ADMIN_ROLE, account);
  }

  function setSprintPhases (uint32 _sprintPeriod, uint32 _proposalPeriod, uint32 _effortPeriod, uint32 _votingPeriod, uint256 _maxEffort, uint256 _minimumTokens) public onlyAdmin {
    if( _sprintPeriod != 0 ) sprintPeriod = _sprintPeriod;
    if( _proposalPeriod != 0 ) proposalPeriod = _proposalPeriod;
    if( _effortPeriod != 0 ) effortPeriod = _effortPeriod;
    if( _votingPeriod != 0 ) votingPeriod =_votingPeriod;
    if( _maxEffort != 0 ) maxEffort = _maxEffort;
    if( _minimumTokens != 0 ) minimumTokens = _minimumTokens;
  }

  function isProposalPeriod () public view returns (bool) {
    return block.timestamp >= currentSprintStartTime && block.timestamp < currentSprintStartTime + proposalPeriod;
  }
  function isEffortPeriod () public view returns (bool) {
    return block.timestamp >= currentSprintStartTime && block.timestamp < currentSprintStartTime + proposalPeriod + effortPeriod;
    //return block.timestamp >= currentSprintStartTime + proposalPeriod && block.timestamp < currentSprintStartTime + proposalPeriod + effortPeriod;
  }
  function isVotingPeriod () public view returns (bool) {
    return block.timestamp >= currentSprintStartTime + proposalPeriod + effortPeriod && block.timestamp < currentSprintStartTime + proposalPeriod + effortPeriod + votingPeriod;
  }
  function isClosed() public view returns (bool) {
    return block.timestamp >= currentSprintStartTime && !isProposalPeriod() && !isEffortPeriod() && !isVotingPeriod();
  }

  // function initProject (uint256 startTime) external onlyAdmin {
  //   require(currentSprintNumber == 0, "This function can only be called once!");
  //   currentSprintStartTime = startTime;
  //   currentSprintNumber++;
  // }

  function closeSprint () public {
    require(isClosed(), "The sprint must be closed!");

    Sprint storage sprint = sprints[currentSprintNumber];
    sprint.id = currentSprintNumber;
    sprint.start = currentSprintStartTime;
    sprint.end = currentSprintStartTime + sprintPeriod;
    if (sprintProposal[currentSprintNumber].length > 0) {
      Proposal[] memory sortedProposals = sort(sprintProposal[currentSprintNumber]);
      setWinProposals(sortedProposals, sprint.winningProposals);
    }
    currentSprintStartTime = currentSprintStartTime + sprintPeriod;
    currentSprintNumber++;
    lastProposalId = 0;
  }

  function quickSort(Proposal[] memory arr, uint left, uint right, bool byRank) private {
    uint i = left;
    uint j = right;
    if (i == j) return;
    
    uint pivot = byRank ? arr[uint(left + (right - left) / 2)].rank : arr[uint(left + (right - left) / 2)].votesUp;
    while (i <= j) {
      while ((byRank ? arr[uint(i)].rank : arr[uint(i)].votesUp) > pivot) i++;
      while (pivot > (byRank ? arr[uint(j)].rank : arr[uint(j)].votesUp)) j--;
      if (i <= j) {
        (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
        i++;
        if (j != 0) {
          j--;
        }
      }
    }
    if (left < j)
      quickSort(arr, left, j, byRank);
    if (i < right)
      quickSort(arr, i, right, byRank);
  }

  function sort(Proposal[] memory data) public returns (Proposal[] memory) {
    quickSort(data, uint(0), uint(data.length - 1), true);
  
    uint left = 0;
    uint right = 0;

    for (uint i = 1; i < uint(data.length); i++) {
      if (data[i].rank != data[i - 1].rank) {
        if (left != right) {
          quickSort(data, left, right, false);
        }
        left = i;
        right = i;
      } else {
        right++;
      }
    }
    if (left != right) {
      quickSort(data, left, right, false);
    }
    return data;
  }
  
  function setWinProposals(Proposal[] memory sortedProposals, Proposal[] storage winProposals) private {
    uint256 _usedEfforts = 0;
    for (uint i = 0; i < uint(sortedProposals.length); i++) {
      if(sortedProposals[i].effortFor > 0){
        if (sortedProposals[i].effortFor + _usedEfforts <= maxEffort) {
          winProposals.push(sortedProposals[i]);
          _usedEfforts += sortedProposals[i].effortFor;
        } else {
          break;
        }
      }
    }
  }

  function getWinProposals(uint256 _num) public view returns (Proposal[] memory) { 
    return sprints[_num].winningProposals;
  }
  
  function createProposal(string calldata _title, string calldata _description) onlyQualifiedTokenHolders external {
    require(isProposalPeriod(), "Not a proposal period");
    uint256 _proposalId = ++lastProposalId;
    Proposal memory newProposal = Proposal(_proposalId, block.timestamp, msg.sender, _title, _description, 0, 0, 1e27, 0);
    sprintProposal[currentSprintNumber].push(newProposal);
    emit NewProposal(msg.sender, _title, _description);
  }
  
  function getProposals() public view returns (Proposal[] memory) {   
    return sprintProposal[currentSprintNumber];
  }
  function getProposalById(uint256 _numberSprint, uint256 _proposalId) public view returns (Proposal memory) {
    return sprintProposal[_numberSprint][_proposalId];
  }

  function setEffort(uint256 _proposalId, uint256 _developmentEffort) external onlyDev {
    require(isEffortPeriod(), "Not an effort period");
    require(_developmentEffort <= maxEffort, "Exceeds max effort");
    Proposal storage proposal = sprintProposal[currentSprintNumber][_proposalId-1];
    proposal.effortFor = _developmentEffort;
    emit NewEffort(_proposalId, _developmentEffort);
  }

  function vote (uint256 _proposalId, bool _voteUp) onlyQualifiedTokenHolders() external {
    require(isVotingPeriod(), "Not a voting period");
    require(!proposalAddressVoted[msg.sender][currentSprintNumber][_proposalId], "This user already voted on this proposal");
    Proposal storage proposal = sprintProposal[currentSprintNumber][_proposalId-1];
    if (_voteUp) {
      proposal.votesUp += vaultDao.balanceOf(msg.sender);
    } else {
      proposal.votesDown += vaultDao.balanceOf(msg.sender);
    }   
    proposalAddressVoted[msg.sender][currentSprintNumber][_proposalId] = true;
  }
  
  function voted (address _user) public view returns (bool) {
    Proposal[] memory proposals = getProposals();
    for (uint256 i = 0; i < proposals.length; i++) { 
      if (proposalAddressVoted[_user][currentSprintNumber][proposals[i].id]) {
        return true;
      }
    }
    return false;
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
    function renounceOwnership(string calldata check) public virtual onlyOwner {
        require(keccak256(abi.encodePacked(check)) == keccak256(abi.encodePacked("renounceOwnership")), "security check");
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(address(0) != newOwner, "ownership cannot be transferred to address 0");
        _newOwner = newOwner;
    }

    function acceptOwnership() public {
        require(_newOwner != address(0), "no new owner has been set up");
        require(msg.sender == _newOwner, "only the new owner can accept ownership");
        _setOwner(_newOwner);
        _newOwner = address(0);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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