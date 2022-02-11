/**
 *Submitted for verification at BscScan.com on 2022-01-18
 */

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;
import './WhiteList.sol';

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function allowance(address _owner, address spender) external view returns (uint256);
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

library SafeMathInt {
  int256 private constant MIN_INT256 = int256(1) << 255;
  int256 private constant MAX_INT256 = ~(int256(1) << 255);

  function mul(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a * b;

    require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != -1 || a != MIN_INT256);

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a));
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function abs(int256 a) internal pure returns (int256) {
    require(a != MIN_INT256);
    return a < 0 ? -a : a;
  }
}

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;
  event OwnershipTransferred(address owner);

  modifier onlyOwner() {
    require(isOwner(msg.sender), '!OWNER');
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), '!AUTHORIZED');
    _;
  }

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    authorizations[adr] = false;
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }
}

contract PrivateSale is WhiteList, Auth {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  struct InvestorInfo {
    uint256 vestedDate; //in seconds
    uint256 cliff; // in seconds
    uint256 totalReceivableAmount; //total
    uint256 receivableAmount; //left
    uint256 currentAmount; //current  e.g. total = left + current
    uint256 releaseState; // 0: not released, 1: listing-released, 2: first-released, 3: second-released, 4: third-released, 5: last-released
  }

  IBEP20 public MambaContract;
  WhiteList public whiteList;

  address[] public investors;

  uint256 public totalAmountForPrivateSale = 10000000; //10,000,000
  uint256 public rateMAMPperBNB = 100000; //100,000
  uint256 public etherDenominator = 10**18;
  uint256 public mampDenominator = 10**8;
  uint256 public percDenominator = 100;

  uint256 public cliff = 5 minutes;
  uint256 public duration = 3 days;
  uint256 public TGE = 20; //20%
  uint256 public PercPerMonth = 20; //20%
  bool public isListedonPancakeswap = false;

  uint256 public start_time = 1644753600; //13th Feb 2022
  uint256 public end_time = 1645012800; //16th Feb 2022

  uint256 public min_buy_amount_estimate = 0.001 * 10**18; //fix
  uint256 public max_buy_amount_estimate = 2.4 * 10**18;

  uint256 public depositedBNB = 0;
  mapping(address => InvestorInfo) public investorInfos;

  event joinedPool(address indexed from, uint256 amount);
  event withdrawn(address indexed from, uint256 rewardAmount);

  constructor(address _mambapad, address _whitelist) Auth(msg.sender) {
    require(_mambapad != address(0), 'PrivateSale: mambapad is zero address');
    require(_whitelist != address(0), 'PrivateSale: whitelist is zero address');

    MambaContract = IBEP20(_mambapad);
    MambaContract.approve(_mambapad, totalAmountForPrivateSale);
    whiteList = WhiteList(_whitelist);
  }

  function joinPool() public payable returns (uint256) {
    require(block.timestamp > start_time, "PrivateSale:joinPool - Can't join pool yet");
    require(block.timestamp < end_time, "PrivateSale:joinPool - Can't join pool more");
    require(msg.value >= min_buy_amount_estimate, "PrivateSale:joinPool - Can't be under min_buy_amount");
    require(msg.value <= max_buy_amount_estimate, "PrivateSale:joinPool - Can't be over max_buy_amount");
    require(whiteList.isWhitelisted(msg.sender), 'PrivateSale:joinPool - User is not whitelisted');

    uint256 amountToBuy = (msg.value).div(rateMAMPperBNB);
    require(
      MambaContract.balanceOf(address(this)) > amountToBuy,
      'PrivateSale:joinPool - This pool has no enough Mamp than amountToBuy'
    );

    investorInfos[msg.sender] = InvestorInfo(block.timestamp, 0, amountToBuy, amountToBuy, 0, 0);
    investors.push(msg.sender);
    depositedBNB = depositedBNB.add(msg.value);

    uint256 TGEtoPancakeswap = amountToBuy.div(TGE).mul(percDenominator);

    MambaContract.transfer(owner, TGEtoPancakeswap);

    emit joinedPool(msg.sender, msg.value);
    return amountToBuy;
  }

  function withdrawBNB(uint256 _amount, address _to) public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, 'PrivateSale: No BNB to withdraw');

    (bool sent, ) = _to.call{value: _amount}('');
    require(sent, 'PrivateSale: Transfer failed.');
    emit withdrawn(msg.sender, ownerBalance);
  }

  function withdrawMAMP(uint256 _amount, address _to) public onlyOwner {
    uint256 ownerBalance = MambaContract.balanceOf(address(this));
    require(ownerBalance > 0, 'PrivateSale: No MAMP to withdraw');

    MambaContract.transfer(_to, _amount);

    emit withdrawn(msg.sender, ownerBalance);
  }

  function withdrawTGE() public {
    require(isListedonPancakeswap, 'PrivateSale:withdrawTGE - Is not yet listed on PancakeSwap');
    require(investorInfos[msg.sender].releaseState == 0, 'PrivateSale:withdrawTGE - You already received TGE');
    require(whiteList.isWhitelisted(msg.sender), 'PrivateSale:withdrawTGE - User is not whitelisted');

    uint256 receivingAmountAfterListing = investorInfos[msg.sender].receivableAmount.div(TGE).mul(percDenominator);
    _claimMamp(receivingAmountAfterListing);

    // uint256 releasedAmount = MambaContract.balanceOf(msg.sender);

    investorInfos[msg.sender].cliff = block.timestamp.div(cliff); //30 * 24 * 60 * 60
    investorInfos[msg.sender].receivableAmount = investorInfos[msg.sender].receivableAmount.sub(
      receivingAmountAfterListing
    );
    investorInfos[msg.sender].currentAmount = receivingAmountAfterListing;
    investorInfos[msg.sender].releaseState = 1;
    emit withdrawn(address(this), receivingAmountAfterListing);
  }

  function withdrawPerMonth() public {
    require(isListedonPancakeswap, 'PrivateSale:withdrawPerMonth - Is not yet listed on PancakeSwap');
    require(whiteList.isWhitelisted(msg.sender), 'PrivateSale:withdrawPerMonth - User is not whitelisted');
    require(investorInfos[msg.sender].cliff<block.timestamp, "PrivateSale:withdrawPerMonth - is not the time to withdraw monthly");
    require(investorInfos[msg.sender].releaseState>=1, "PrivateSale:withdrawPerMonth - First receive TGE");
    require(investorInfos[msg.sender].releaseState<5, "PrivateSale:withdrawPerMonth - You are all received Amount of Private Sale");

    uint256 amountToReceivePerMonth = investorInfos[msg.sender].totalReceivableAmount.div(PercPerMonth).mul(percDenominator);
    _claimMamp(amountToReceivePerMonth);

    investorInfos[msg.sender].cliff = block.timestamp.div(cliff);
    investorInfos[msg.sender].receivableAmount = investorInfos[msg.sender].receivableAmount.sub(amountToReceivePerMonth);
    investorInfos[msg.sender].currentAmount = investorInfos[msg.sender].currentAmount.add(amountToReceivePerMonth);
    investorInfos[msg.sender].releaseState++;
    emit withdrawn(address(this), amountToReceivePerMonth);
  }

  function addTotalAmountForPrivateSale(uint256 _addingAmount) public onlyOwner {
    totalAmountForPrivateSale = totalAmountForPrivateSale.add(_addingAmount);
  }

  function setListedonPancakeswap() public onlyOwner {
    isListedonPancakeswap = true;
  }

  function setStartTime(uint256 _startTime) public onlyOwner {
    start_time = _startTime;
  }

  function setEndTime(uint256 _endTime) public onlyOwner {
    end_time = _endTime;
  }

  function getInvestorInfo(address _beneficiary) public view onlyOwner returns (InvestorInfo memory) {
    return investorInfos[_beneficiary];
  }

  function getInvestorsCount() public view returns (uint256) {
    return investors.length;
  }

  function getInfo()
    public
    view
    returns (
      uint256 mampAmountofContract,
      uint256 bnbAmountDepositedinContract,
      uint256 startingTime,
      uint256 endingTime
    )
  {
    mampAmountofContract = MambaContract.balanceOf(address(this));
    bnbAmountDepositedinContract = depositedBNB;
    startingTime = start_time;
    endingTime = end_time;
    return (MambaContract.balanceOf(address(this)), depositedBNB, start_time, end_time);
  }

  function getBalanceofContract() public view returns (uint256) {
    return address(this).balance;
  }

  function getContractMampBalance() public view returns (uint256) {
    require(MambaContract.balanceOf(address(this)) > 0, 'PrivateSale: balance is 0');
    return MambaContract.balanceOf(address(this));
  }

  function getDepositedBNB() public view returns (uint256) {
    return depositedBNB;
  }

  function getStartTime() public view returns (uint256) {
    return start_time;
  }

  function getEndTime() public view returns (uint256) {
    return end_time;
  }

  function _claimMamp(uint256 amountToBuy) private {
    if (MambaContract.balanceOf(address(this)) > amountToBuy) {
      MambaContract.transfer(msg.sender, amountToBuy);
    } else MambaContract.transfer(msg.sender, MambaContract.balanceOf(address(this)));
  }
}

// SPDX-License-Identifier: MIT
/**
 * @title Whitelist
 * @dev this contract enables whitelisting of users.
 */

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract WhiteList is AccessControl {
    mapping(address => bool) private _isWhitelisted; // white listed flag
    uint256 public totalWhiteListed; // white listed users number
    address[] public holdersIndex; // iterable index of holders
    // Create a new role identifier for the controller role
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");

    event AdddWhitelisted(address indexed user);
    event RemovedWhitelisted(address indexed user);
    modifier isController() {
        require(
            hasRole(CONTROLLER_ROLE, msg.sender),
            "Whitelist::isController - Caller is not a controller"
        );

        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Add an account to the whitelist,
     * @param user The address of the investor
     */
    function addWhitelisted(address user) external isController {
        _addWhitelisted(user);
    }

    /**
     * @notice This function allows to whitelist investors in batch
     * with control of number of iterations
     * @param users The accounts to be whitelisted in batch
     */
    function addWhitelistedMultiple(address[] calldata users)
        external
        isController
    {
        uint256 length = users.length;
        require(
            length <= 256,
            "Whitelist-addWhitelistedMultiple: List too long"
        );
        for (uint256 i = 0; i < length; i++) {
            _addWhitelisted(users[i]);
        }
    }

    /**
     * @notice Remove an account from the whitelist, calling the corresponding internal
     * function
     * @param user The address of the investor that needs to be removed
     */
    function removeWhitelisted(address user) external isController {
        _removeWhitelisted(user);
    }

    /**
     * @notice This function allows to whitelist investors in batch
     * with control of number of iterations
     * @param users The accounts to be whitelisted in batch
     */
    function removeWhitelistedMultiple(address[] calldata users)
        external
        isController
    {
        uint256 length = users.length;
        require(
            length <= 256,
            "Whitelist-removeWhitelistedMultiple: List too long"
        );
        for (uint256 i = 0; i < length; i++) {
            _removeWhitelisted(users[i]);
        }
    }

    /**
     * @notice Check if an account is whitelisted or not
     * @param user The account to be checked
     * @return true if the account is whitelisted. Otherwise, false.
     */
    function isWhitelisted(address user) external view returns (bool) {
        return _isWhitelisted[user];
    }

    /**
     * @notice Add an investor to the whitelist
     * @param user The address of the investor that has successfully passed KYC
     */
    function _addWhitelisted(address user) internal {
        require(
            user != address(0),
            "WhiteList:_addWhiteList - Not a valid address"
        );
        require(
            _isWhitelisted[user] == false,
            "Whitelist-_addWhitelisted: account already whitelisted"
        );
        _isWhitelisted[user] = true;
        totalWhiteListed++;
        holdersIndex.push(user);
        emit AdddWhitelisted(user);
    }

    /**
     * @notice Remove an investor from the whitelist
     * @param user The address of the investor that needs to be removed
     */
    function _removeWhitelisted(address user) internal {
        require(
            user != address(0),
            "WhiteList:_removeWhitelisted - Not a valid address"
        );
        require(
            _isWhitelisted[user] == true,
            "Whitelist-_removeWhitelisted: account was not whitelisted"
        );
        _isWhitelisted[user] = false;
        totalWhiteListed--;
        emit RemovedWhitelisted(user);
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