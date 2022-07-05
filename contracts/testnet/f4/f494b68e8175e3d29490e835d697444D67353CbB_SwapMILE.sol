// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ISwapMILE.sol";
import "./interfaces/IERC20MintableBurnable.sol";
import "./interfaces/IEntityFactory.sol";

import "./interfaces/IPancakeRouter02.sol";

contract SwapMILE is
  Initializable,
  ISwapMILE,
  AccessControl,
  ReentrancyGuardUpgradeable
{
  using SafeERC20 for IERC20MintableBurnable;

  /// @notice Stores the admin role key hash that is used for accessing the withdrawal call.
  /// @return Bytes representing admin role key hash.
  bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

  IERC20MintableBurnable public tokenMILE;
  IERC20MintableBurnable public sMILEToken;
  uint256 public totalPool;
  uint256 public sMILEPool;
  uint256 public cooldownPeriod;
  uint256 public withdrawPeriod;
  uint256 private requestsCreated;

  address public entityFactory;
  address public router;

  mapping(address => mapping(uint256 => WithdrawRequest))
    public withdrawalRequests;

  mapping(address => uint256[]) public withdrawalRequestIdsByEntity;

  modifier onlyAdmin() {
    _checkRole(ROLE_ADMIN, msg.sender);
    _;
  }

  modifier onlyEntity(address recipient) {
    require(
      IEntityFactory(entityFactory).getEntityType(recipient) < 3,
      "Recipient isn't entity"
    );
    _;
  }

  function initialize(
    address _admin,
    address _tokenMILE,
    address _sMILEToken,
    address _router,
    address _entityFactory,
    uint256 _cooldownPeriod,
    uint256 _withdrawPeriod
  ) external initializer {
    require(_admin != address(0), "Zero address");
    require(_tokenMILE != address(0), "Zero address");
    require(_sMILEToken != address(0), "Zero address");
    require(_router != address(0), "Zero address");
    require(_entityFactory != address(0), "Zero address");
    require(_cooldownPeriod > 0, "Zero value");
    require(_withdrawPeriod > 0, "Zero value");
    require(
      _withdrawPeriod > _cooldownPeriod,
      "Cooldown period less than withdraw period"
    );
    __ReentrancyGuard_init();

    _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);
    _setupRole(ROLE_ADMIN, _admin);

    tokenMILE = IERC20MintableBurnable(_tokenMILE);
    sMILEToken = IERC20MintableBurnable(_sMILEToken);
    router = _router;
    entityFactory = _entityFactory;
    cooldownPeriod = _cooldownPeriod;
    withdrawPeriod = _withdrawPeriod;
  }

  function setCoolDownPeriod(uint256 newValue) external override onlyAdmin {
    require(newValue > 0, "Zero value");
    require(
      newValue < withdrawPeriod,
      "Cooldown period must be less than withdrawal period"
    );
    uint256 oldPeriod = cooldownPeriod;
    cooldownPeriod = newValue;

    emit UpdatedCoolDownPeriod(oldPeriod, cooldownPeriod);
  }

  function setWithdrawPeriod(uint256 newValue) external override onlyAdmin {
    require(newValue > 0, "Zero value");
    require(
      newValue > cooldownPeriod,
      "Withdrawal period must be greater than cooldown period"
    );
    uint256 oldPeriod = withdrawPeriod;
    withdrawPeriod = newValue;

    emit UpdatedWithdrawPeriod(oldPeriod, withdrawPeriod);
  }

  function setEntityFactoryContract(address _entityFactory)
    external
    override
    onlyAdmin
  {
    require(_entityFactory != address(0), "Zero address");

    address oldAddress = entityFactory;
    entityFactory = _entityFactory;

    emit UpdatedEntityContract(oldAddress, entityFactory);
  }

  function getMILEPrice() external view override returns (uint256) {
    return _convertToSMILE(10**18);
  }

  function getSMILEPrice() external view override returns (uint256) {
    return _convertToMILE(10**18);
  }

  function getLiquidityAmount()
    external
    view
    override
    returns (uint256, uint256)
  {
    return (totalPool, sMILEPool);
  }

  function stake(uint256 amount) external override onlyEntity(msg.sender) {
    require(amount > 0, "Zero amount");

    tokenMILE.safeTransferFrom(msg.sender, address(this), amount);
    _stake(msg.sender, msg.sender, amount);
  }

  function stakeTo(address to, uint256 amount)
    external
    override
    onlyEntity(to)
  {
    require(amount > 0, "Zero amount");

    tokenMILE.safeTransferFrom(msg.sender, address(this), amount);
    _stake(msg.sender, to, amount);
  }

  function swapStake(
    uint256 amount,
    address erc20Token,
    uint256 validTill,
    uint256 amountOutMin
  ) external override onlyEntity(msg.sender) {
    require(amount > 0, "Zero amount");
    require(erc20Token != address(0), "Zero token address");

    IERC20MintableBurnable(erc20Token).safeTransferFrom(
      msg.sender,
      address(this),
      amount
    );

    address[] memory path = new address[](2);
    path[0] = erc20Token;
    path[1] = address(tokenMILE);

    IERC20(path[0]).approve(router, amount);
    uint256[] memory amounts = IPancakeRouter02(router)
      .swapExactTokensForTokens(
        amount,
        amountOutMin,
        path,
        address(this),
        validTill
      );

    _stake(msg.sender, msg.sender, amounts[1]);
  }

  function swapStakeTo(
    uint256 amount,
    address erc20Token,
    address to,
    uint256 validTill,
    uint256 amountOutMin
  ) external override onlyEntity(to) {
    require(amount > 0, "Zero amount");
    require(erc20Token != address(0), "Zero token address");

    IERC20MintableBurnable(erc20Token).safeTransferFrom(
      msg.sender,
      address(this),
      amount
    );

    address[] memory path = new address[](2);
    path[0] = erc20Token;
    path[1] = address(tokenMILE);

    IERC20(path[0]).approve(router, amount);
    uint256[] memory amounts = IPancakeRouter02(router)
      .swapExactTokensForTokens(
        amount,
        amountOutMin,
        path,
        address(this),
        validTill
      );

    _stake(msg.sender, to, amounts[1]);
  }

  function getRequestAmountByEntity(address entity)
    external
    view
    returns (uint256)
  {
    return withdrawalRequestIdsByEntity[entity].length;
  }

  function getRequestIdsByEntity(address entity)
    external
    view
    returns (uint256[] memory)
  {
    uint256[] memory array = withdrawalRequestIdsByEntity[entity];
    return array;
  }

  function getRequestsByEntity(
    address entity,
    uint256 offset,
    uint256 limit
  ) external view returns (WithdrawRequest[] memory) {
    require(
      withdrawalRequestIdsByEntity[entity].length > 0,
      "The Entity doesn't have withdrawal requests"
    );
    require(limit > 0, "Limit can't be equal to zero");
    require(
      withdrawalRequestIdsByEntity[entity].length > offset,
      "Offset out of bounds array"
    );
    uint256 arrayLength = withdrawalRequestIdsByEntity[entity].length;
    uint256 arrayLimit;
    uint256 arraySize;
    if (arrayLength > (offset + limit)) {
      arrayLimit = offset + limit;
      arraySize = limit;
    } else {
      arrayLimit = arrayLength;
      arraySize = arrayLength - offset;
    }

    WithdrawRequest[] memory array = new WithdrawRequest[](arraySize);
    uint256 j;
    for (uint256 i = offset; i < arrayLimit; i++) {
      uint256 id = withdrawalRequestIdsByEntity[entity][i];
      array[j] = withdrawalRequests[entity][id];
      j++;
    }
    return array;
  }

  function requestWithdraw(uint256 amount)
    external
    override
    onlyEntity(msg.sender)
    returns (uint256)
  {
    require(amount > 0, "Zero amount");
    require(totalPool >= amount, "Not enough MILE tokens to transfer");

    require(
      sMILEToken.balanceOf(msg.sender) >= amount,
      "Not enough sMILE to withdraw"
    );

    requestsCreated++;
    uint256 id = requestsCreated;
    // solhint-disable-next-line not-rely-on-time
    uint256 currentTime = block.timestamp;
    withdrawalRequestIdsByEntity[msg.sender].push(id);
    withdrawalRequests[msg.sender][id] = WithdrawRequest({
      id: id,
      amountOfsMILE: amount,
      creationTimestamp: currentTime,
      coolDownEnd: currentTime + cooldownPeriod,
      withdrawEnd: currentTime + withdrawPeriod
    });
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      msg.sender
    );
    emit CreatedWithdrawRequest(
      id,
      msg.sender,
      recipientEntityType,
      amount,
      currentTime
    );

    return id;
  }

  function withdraw(uint256 withdrawalId) external override returns (bool) {
    WithdrawRequest memory request = withdrawalRequests[msg.sender][
      withdrawalId
    ];
    uint256 amountOfSMILE = request.amountOfsMILE;
    require(amountOfSMILE != 0, "Request does not exist");

    uint256 balanceOfSMILE = sMILEToken.balanceOf(msg.sender);
    require(
      balanceOfSMILE >= amountOfSMILE,
      "Not enough sMILE tokens on entity balance"
    );

    uint256 amountOfMILE = _convertToMILE(amountOfSMILE);
    uint256 balanceOfMILE = tokenMILE.balanceOf(address(this));
    require(
      balanceOfMILE >= amountOfMILE,
      "Not enough MILE tokens to transfer"
    );
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      msg.sender
    );
    // solhint-disable-next-line not-rely-on-time
    if (request.withdrawEnd <= block.timestamp) {
      _deleteRequestWithdraw(msg.sender, withdrawalId);
      emit Withdrawn(msg.sender, recipientEntityType, 0, 0, false);
      return false;
    }

    uint256 fee = _calculateWithdrawFee(
      // solhint-disable-next-line not-rely-on-time
      block.timestamp,
      request.creationTimestamp,
      request.coolDownEnd,
      amountOfMILE
    );

    uint256 toTransfer = amountOfMILE - fee;
    //in cases when it is not divided equally
    uint256 feeToBurn = fee - fee / 2;
    totalPool = totalPool - amountOfMILE + fee / 2;
    sMILEPool = sMILEPool - amountOfSMILE;

    tokenMILE.transfer(msg.sender, toTransfer);
    tokenMILE.burn(feeToBurn);
    sMILEToken.burnFrom(msg.sender, amountOfSMILE);

    _deleteRequestWithdraw(msg.sender, withdrawalId);

    emit Withdrawn(msg.sender, recipientEntityType, toTransfer, fee, true);

    return true;
  }

  function cancelWithdraw(uint256 withdrawalId) external override {
    require(
      withdrawalRequests[msg.sender][withdrawalId].amountOfsMILE != 0,
      "Request does not exist"
    );
    _deleteRequestWithdraw(msg.sender, withdrawalId);
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      msg.sender
    );
    emit WithdrawCanceled(withdrawalId, msg.sender, recipientEntityType);
  }

  function addRewards(uint256 amount) external override {
    require(amount > 0, "Zero amount");

    totalPool = totalPool + amount;
    tokenMILE.safeTransferFrom(msg.sender, address(this), amount);
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      msg.sender
    );
    emit AddMILE(msg.sender, recipientEntityType, amount);
  }

  function withdrawUnusedMILE(uint256 amount, address to)
    external
    override
    onlyAdmin
  {
    require(amount > 0, "Zero amount");
    require(to != address(0), "Zero address");

    uint256 balanceOfMILE = tokenMILE.balanceOf(address(this));
    require(amount <= balanceOfMILE - totalPool, "Not enough MILE to withdraw");
    tokenMILE.safeTransfer(to, amount);
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      to
    );
    emit WithdrawnUnusedMILE(amount, to, recipientEntityType);
  }

  function withdrawUnusedSMILE(uint256 amount, address to)
    external
    override
    onlyAdmin
  {
    require(amount > 0, "Zero amount");
    require(to != address(0), "Zero address");

    uint256 sMILEBalance = sMILEToken.balanceOf(address(this));
    require(amount <= sMILEBalance, "Not enough sMILE to withdraw");
    sMILEToken.safeTransfer(to, amount);
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      to
    );
    emit WithdrawnUnusedSMILE(amount, to, recipientEntityType);
  }

  function withdrawUnusedBNB(uint256 amount, address to)
    external
    override
    onlyAdmin
  {
    require(amount > 0, "Zero amount");
    require(to != address(0), "Zero address");

    uint256 balanceBNB = address(this).balance;
    require(amount <= balanceBNB, "Not enough BNB to withdraw");
    payable(to).transfer(amount);
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      to
    );
    emit WithdrawnUnusedBNB(amount, to, recipientEntityType);
  }

  function _deleteRequestWithdraw(address entity, uint256 withdrawalId)
    internal
  {
    delete withdrawalRequests[entity][withdrawalId];
    // uint256 idsLength = withdrawalRequestIdsByEntity[entity].length;
    for (uint256 i; i < withdrawalRequestIdsByEntity[entity].length - 1; i++) {
      if (withdrawalId == withdrawalRequestIdsByEntity[entity][i]) {
        uint256 value = withdrawalRequestIdsByEntity[entity][i];
        withdrawalRequestIdsByEntity[entity][i] = withdrawalRequestIdsByEntity[
          entity
        ][i + 1];
        withdrawalRequestIdsByEntity[entity][i + 1] = value;
      }
    }
    withdrawalRequestIdsByEntity[entity].pop();
  }

  function _stake(
    address _from,
    address _to,
    uint256 _amountMILE
  ) internal {
    uint256 amountSMILE = _convertToSMILE(_amountMILE);

    totalPool = totalPool + _amountMILE;
    sMILEPool = sMILEPool + amountSMILE;

    sMILEToken.mint(_to, amountSMILE);
    uint256 callerEntityType = IEntityFactory(entityFactory).getEntityType(
      _from
    );
    uint256 recipientEntityType = IEntityFactory(entityFactory).getEntityType(
      _to
    );
    emit Staked(
      _from,
      _to,
      _amountMILE,
      amountSMILE,
      callerEntityType,
      recipientEntityType
    );
  }

  function _calculateWithdrawFee(
    uint256 currentTime,
    uint256 creationTimestamp,
    uint256 cooldownEnd,
    uint256 amountOfMILE
  ) internal view returns (uint256 fee) {
    if (currentTime > cooldownEnd) {
      fee = (amountOfMILE * 10) / 100;
    } else {
      uint256 percent = 40 -
        30 *
        ((currentTime - creationTimestamp) / cooldownPeriod);
      fee = (amountOfMILE * percent) / 100;
    }
  }

  function _convertToSMILE(uint256 _amount) internal view returns (uint256) {
    if (totalPool > 0 && sMILEPool > 0) {
      _amount = (sMILEPool * _amount) / totalPool;
    }

    return _amount;
  }

  function _convertToMILE(uint256 _amount) internal view returns (uint256) {
    if (totalPool > 0 && sMILEPool > 0) {
      _amount = (totalPool * _amount) / sMILEPool;
    }

    return _amount;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

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
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
     * bearer except when using {_setupRole}.
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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
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
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
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
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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
     * If the calling account had been granted `role`, emits a {RoleRevoked}
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface ISwapMILE {
  struct WithdrawRequest {
    uint256 id;
    uint256 amountOfsMILE;
    uint256 creationTimestamp;
    uint256 coolDownEnd;
    uint256 withdrawEnd;
  }

  event Staked(
    address indexed caller,
    address indexed recipient,
    uint256 stakedMILE,
    uint256 swappedSMILE,
    uint256 callerEntityType,
    uint256 recipientEntityType
  );

  event CreatedWithdrawRequest(
    uint256 indexed withdrawalId,
    address recipient,
    uint256 recipientEntityType,
    uint256 amountOfsMILE,
    uint256 timestampOfCreation
  );

  event Withdrawn(
    address recipient,
    uint256 recipientEntityType,
    uint256 amountOfMILE,
    uint256 fee,
    bool success
  );

  event WithdrawCanceled(
    uint256 indexed withdrawalId,
    address recipient,
    uint256 recipientEntityType
  );

  event AddMILE(address sender, uint256 callerEntityType, uint256 amount);

  event WithdrawnUnusedMILE(
    uint256 amount,
    address recipient,
    uint256 recipientEntityType
  );

  event WithdrawnUnusedSMILE(
    uint256 amount,
    address recipient,
    uint256 recipientEntityType
  );

  event WithdrawnUnusedBNB(
    uint256 amount,
    address recipient,
    uint256 recipientEntityType
  );

  event UpdatedCoolDownPeriod(uint256 oldPeriod, uint256 newPeriod);

  event UpdatedWithdrawPeriod(uint256 oldPeriod, uint256 newPeriod);

  event UpdatedEntityContract(address oldAddress, address newAddress);

  function setCoolDownPeriod(uint256 newValue) external;

  function setWithdrawPeriod(uint256 newValue) external;

  function setEntityFactoryContract(address entity) external;

  function getMILEPrice() external returns (uint256);

  function getSMILEPrice() external returns (uint256);

  function getLiquidityAmount() external returns (uint256, uint256);

  function stake(uint256 amount) external;

  function stakeTo(address to, uint256 amount) external;

  function swapStake(
    uint256 amount,
    address erc20Token,
    uint256 validTill,
    uint256 amountOutMin
  ) external;

  function swapStakeTo(
    uint256 amount,
    address erc20Token,
    address to,
    uint256 validTill,
    uint256 amountOutMin
  ) external;

  function getRequestAmountByEntity(address entity) external returns (uint256);

  function getRequestIdsByEntity(address entity)
    external
    returns (uint256[] memory);

  function getRequestsByEntity(
    address entity,
    uint256 offset,
    uint256 limit
  ) external returns (WithdrawRequest[] memory);

  function requestWithdraw(uint256 amount) external returns (uint256);

  function withdraw(uint256 withdrawalId) external returns (bool);

  function cancelWithdraw(uint256 withdrawalId) external;

  function addRewards(uint256 amount) external;

  function withdrawUnusedMILE(uint256 amount, address to) external;

  function withdrawUnusedSMILE(uint256 amount, address to) external;

  function withdrawUnusedBNB(uint256 amount, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20MintableBurnable is IERC20 {
  function mint(address account, uint256 amount) external;

  function burn(uint256 amount) external;

  function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IEntityFactory {
  enum EntityType {
    UserEntity,
    CompanyEntity,
    ProjectEntity
  }
  event UpdateUpgradeableBeacon(address newBeacon, EntityType entityType);
  event CreatingNewEntity(
    uint256 indexed id,
    address indexed creator,
    address entity,
    EntityType entityType
  );
  event UpdateWhiteList(address oldWhiteList, address newWhiteList);

  event AddedOwnerOfEntity(address newOwner);

  event RemovedOwnerOfEntity(address owner);

  function updateUpgradeableBeacon(address newBeacon, EntityType entityType)
    external;

  function updateWhiteList(address newWhiteList) external;

  function createUserEntity(uint256 id) external returns (address);

  function createCompanyEntity(uint256 id) external returns (address);

  function createProjectEntity(uint256 id) external returns (address);

  function addUser(address entityOwner) external;

  function removeUser(address entityOwner) external;

  function getEntityType(address entity) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IPancakeRouter01 {
  function factory() external pure returns (address);

  // solhint-disable-next-line func-name-mixedcase
  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}