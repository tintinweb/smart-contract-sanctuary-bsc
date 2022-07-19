// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./BaseEntity.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IUserEntity.sol";

contract ProjectEntity is BaseEntity {
  IEntityFactory public entityFactory;

  function initialize(
    address owner_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address entityFactory_
  ) external initializer {
    require(
      entityFactory_ != address(0),
      "EntityFactory address cannot be zero"
    );
    __BaseEntity_init(swapMile_, mileToken_, sMileToken_, owner_);
    entityFactory = IEntityFactory(entityFactory_);
  }

  /// @dev Override function "swapOwner" of BaseEntity contract by adding additional code.
  /// @param prevOwner address of owner that pointed to the owner to be removed in the linked list;
  /// @param oldOwner address of owner to remove from UserEntity and EntityFactory;
  /// @param newOwner address of new Owner of UserEntity contract.
  function swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) public onlyOwner {
    require(
      entityFactory.getEntityType(newOwner) == 0,
      "Owner of project entity can be only user entity"
    );
    IUserEntity(_getCurrentOwner()).removeChildeEntity();
    _swapOwner(prevOwner, oldOwner, newOwner);
    IUserEntity(newOwner).addChildeEntity();
  }

  function isOwner(address owner) public view override returns (bool) {
    return BaseEntity(_getCurrentOwner()).isOwner(owner);
  }

  function isAdmin(address admin) public view override returns (bool) {
    bool isAdminOfUserEntity = BaseEntity(_getCurrentOwner()).isAdmin(admin);
    return administrators[admin] || isAdminOfUserEntity;
  }

  /// @notice Stake amount of MILE tokens to SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function stake(uint256 amount, TokenSourceType sourceType)
    external
    onlyOwnerOrAdmin
  {
    _managingTokenSupply(mileToken, amount, sourceType);
    _stake(amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function stakeTo(
    uint256 amount,
    address recipient,
    TokenSourceType sourceType
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(mileToken, amount, sourceType);
    _stakeTo(amount, recipient);
  }

  /// @notice Stake amount of ERC20 token to the SwapMILE contract.
  /// @param amount amount of “erc20token “ tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function swapStake(
    uint256 amount,
    address erc20token,
    TokenSourceType sourceType,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(erc20token, amount, sourceType);
    _swapStake(amount, erc20token, validTill, amountOutMin);
  }

  /// @dev The same function like "swapStake" but the BaseEntity contract call
  /// function "swapStakeTo" instead of "swapStake" of SwapMILE contract.
  /// @param amount amount of "erc20token" tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    TokenSourceType sourceType,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(erc20token, amount, sourceType);
    _swapStakeTo(amount, erc20token, recipient, validTill, amountOutMin);
  }

  function _getCurrentOwner() internal view returns (address) {
    address[] memory ownersArray = getOwners();
    return ownersArray[0];
  }

  function _managingTokenSupply(
    address token,
    uint256 amount,
    TokenSourceType sourceType
  ) internal {
    if (sourceType == TokenSourceType.UserWallet) {
      IERC20(token).transferFrom(msg.sender, address(this), amount);
    } else if (sourceType == TokenSourceType.UserEntity) {
      IUserEntity(_getCurrentOwner()).sendTokens(mileToken, amount);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ISwapMILE.sol";
import "./interfaces/IBaseEntity.sol";

contract BaseEntity is IBaseEntity, Initializable {
  address public constant SENTINEL_OWNERS = address(0x1);

  ISwapMILE public swapMile;

  address public mileToken;

  address public sMileToken;

  uint256 public ownerCount;

  mapping(address => address) public owners;

  mapping(address => bool) public administrators;

  modifier onlyOwner() {
    require(isOwner(msg.sender), "Caller must be owner");
    _;
  }
  modifier onlyOwnerOrAdmin() {
    require(
      isOwner(msg.sender) || isAdmin(msg.sender),
      "Caller must be admin or owner"
    );
    _;
  }

  // solhint-disable-next-line
  function __BaseEntity_init(
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address owner_
  ) public initializer {
    require(swapMile_ != address(0), "SwapMILE address cannot be zero");
    require(
      mileToken_ != address(0) && sMileToken_ != address(0),
      "Token addresses cannot be zero"
    );
    require(owner_ != address(0), "Owner can't be zero address");
    swapMile = ISwapMILE(swapMile_);
    mileToken = mileToken_;
    sMileToken = sMileToken_;
    IERC20(sMileToken).approve(swapMile_, type(uint256).max);

    owners[SENTINEL_OWNERS] = owner_;
    owners[owner_] = SENTINEL_OWNERS;
    ownerCount++;
  }

  /// @dev Checks if the address is in the linked list.
  /// @param owner Address of owner.
  /// @return True if passed address is address of owner, else - return false.
  function isOwner(address owner) public view virtual returns (bool) {
    return owner != SENTINEL_OWNERS && owners[owner] != address(0);
  }

  /// @dev Checks if the address has administrator role.
  /// @param admin Address of user.
  /// @return True if passed address is address of administrator, else - return false.
  function isAdmin(address admin) public view virtual returns (bool) {
    return administrators[admin];
  }

  function addAdmin(address newAdministrator) external onlyOwner {
    administrators[newAdministrator] = true;
    emit AddedAdmin(newAdministrator);
  }

  function removeAdmin(address administrator) external onlyOwner {
    administrators[administrator] = false;
    emit RemovedAdmin(administrator);
  }

  /// @dev Returns array of owners.
  /// @return Array of owners.
  function getOwners() public view returns (address[] memory) {
    address[] memory array = new address[](ownerCount);

    // populate return array
    uint256 index = 0;
    address currentOwner = owners[SENTINEL_OWNERS];
    while (currentOwner != SENTINEL_OWNERS) {
      array[index] = currentOwner;
      currentOwner = owners[currentOwner];
      index++;
    }
    return array;
  }

  /// @notice Stake amount of MILE tokens to SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  function _stake(uint256 amount) internal {
    IERC20(mileToken).approve(address(swapMile), amount);
    swapMile.stake(amount);

    emit StakeMile(msg.sender, mileToken, amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  function _stakeTo(uint256 amount, address recipient) internal {
    IERC20(mileToken).approve(address(swapMile), amount);
    swapMile.stakeTo(recipient, amount);

    emit StakeMile(msg.sender, mileToken, amount);
  }

  /// @notice Stake amount of ERC20 token to the SwapMILE contract.
  /// @param amount amount of “erc20token “ tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  function _swapStake(
    uint256 amount,
    address erc20token,
    uint256 validTill,
    uint256 amountOutMin
  ) internal {
    IERC20(erc20token).approve(address(swapMile), amount);
    swapMile.swapStake(amount, erc20token, validTill, amountOutMin);
  }

  /// @dev The same function like "swapStake" but the BaseEntity contract call
  /// function "swapStakeTo" instead of "swapStake" of SwapMILE contract.
  /// @param amount amount of "erc20token" tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  function _swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    uint256 validTill,
    uint256 amountOutMin
  ) internal {
    IERC20(erc20token).approve(address(swapMile), amount);
    swapMile.swapStakeTo(
      amount,
      erc20token,
      recipient,
      validTill,
      amountOutMin
    );
  }

  /// @notice Create withdraw request to SwapMILE contract.
  /// @param amount amount to withdraw.
  /// @return id of the created request.
  function requestWithdraw(uint256 amount)
    external
    onlyOwnerOrAdmin
    returns (uint256)
  {
    uint256 requestId = swapMile.requestWithdraw(amount);
    emit CreatedRequestWithdraw(msg.sender, amount, requestId);

    return requestId;
  }

  /// @notice Cancel request of withdraw from SwapMILE contract.
  /// @param requestId id of withdrawal request.
  function cancelWithdraw(uint256 requestId) external onlyOwnerOrAdmin {
    swapMile.cancelWithdraw(requestId);
  }

  /// @notice Withdraw MILE token from SwapMILE contract to the Entity contract.
  /// @param requestId withdrawal request id.
  function withdrawFromStaking(uint256 requestId) external onlyOwnerOrAdmin {
    swapMile.withdraw(requestId);
  }

  /// @notice Withdraw token from the Entity contract to the recipient address.
  /// @param token address of token to transfer;
  /// @param amount amount of tokens to transfer;
  /// @param recipient recipient of transferred tokens.
  function withdrawFromEntity(
    address token,
    uint256 amount,
    address recipient
  ) external onlyOwner {
    require(
      IERC20(token).balanceOf(address(this)) >= amount,
      "Not enough tokens to withdraw"
    );
    IERC20(token).transfer(recipient, amount);

    emit Withdrawn(recipient, amount);
  }

  /// @dev Allows to add a new owner to the Safe.
  /// @notice Adds the owner `owner` to the Safe.
  /// @param owner New owner address.
  function _addOwner(address owner) internal {
    // Owner address cannot be null, the sentinel or the Safe itself.
    require(
      owner != address(0) && owner != SENTINEL_OWNERS && owner != address(this),
      "Invalid owner address provided"
    );
    // No duplicate owners allowed.
    require(owners[owner] == address(0), "Address is already an owner");
    owners[owner] = owners[SENTINEL_OWNERS];
    owners[SENTINEL_OWNERS] = owner;
    ownerCount++;
    emit AddedOwner(owner);
  }

  /// @dev Allows to remove an owner from the Safe.
  /// @notice Removes the owner `owner` from the Safe.
  /// @param prevOwner Owner that pointed to the owner to be removed in the linked list
  /// @param owner Owner address to be removed.
  function _removeOwner(address prevOwner, address owner) internal {
    // Validate owner address and check that it corresponds to owner index.
    require(
      owner != address(0) && owner != SENTINEL_OWNERS,
      "Invalid owner address provided"
    );
    require(
      owners[prevOwner] == owner,
      "Invalid prevOwner, owner pair provided"
    );
    owners[prevOwner] = owners[owner];
    owners[owner] = address(0);
    ownerCount--;
    emit RemovedOwner(owner);
  }

  /// @dev Allows to swap/replace an owner from the Safe with another address.
  /// @notice Replaces the owner `oldOwner` in the Safe with `newOwner`.
  /// @param prevOwner Owner that pointed to the owner to be replaced in the linked list
  /// @param oldOwner Owner address to be replaced.
  /// @param newOwner New owner address.
  function _swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) internal {
    // Owner address cannot be null, the sentinel or the Safe itself.
    require(
      newOwner != address(0) &&
        newOwner != SENTINEL_OWNERS &&
        newOwner != address(this),
      "Invalid owner address provided"
    );
    // No duplicate owners allowed.
    require(owners[newOwner] == address(0), "Address is already an owner");
    // Validate oldOwner address and check that it corresponds to owner index.
    require(
      oldOwner != address(0) && oldOwner != SENTINEL_OWNERS,
      "Invalid owner address provided"
    );
    require(
      owners[prevOwner] == oldOwner,
      "Invalid prevOwner, owner pair provided"
    );
    owners[newOwner] = owners[oldOwner];
    owners[prevOwner] = newOwner;
    owners[oldOwner] = address(0);
    emit RemovedOwner(oldOwner);
    emit AddedOwner(newOwner);
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[49] private ___gap;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IEntityFactory {
  enum EntityType {
    UserEntity,
    CompanyEntity,
    ProjectEntity
  }
  event UpdatedUpgradeableBeacon(address newBeacon, EntityType entityType);
  event CreatedNewEntity(
    uint256 indexed id,
    address indexed creator,
    address entity,
    EntityType entityType
  );
  event UpdatedWhiteList(address oldWhiteList, address newWhiteList);

  event UpdatedEntityStrategy(address oldStrategy, address newStrategy);

  event AddedOwnerOfEntity(address newOwner);

  event RemovedOwnerOfEntity(address owner);

  function updateUpgradeableBeacon(address newBeacon, EntityType entityType)
    external;

  function updateWhiteList(address newWhiteList) external;

  function updatedStrategy(address newEntityStrategy) external;

  function createUserEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function addUser(address entityOwner) external;

  function removeUser(address entityOwner) external;

  function getEntityType(address entity) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IUserEntity {
  event CreatedEntity(
    uint256 indexed id,
    address newEntity,
    uint256 entityType
  );

  event AddedChildeEntity(address entity, uint256 entityType);

  event RemovedChildeEntity(address entity, uint256 entityType);

  function initialize(
    address owner_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address entityFactory_
  ) external;

  function addOwner(address owner) external;

  function removeOwner(address prevOwner, address owner) external;

  function swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) external;

  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function addChildeEntity() external;

  function removeChildeEntity() external;

  function sendTokens(address token, uint256 amount) external;

  function stake(uint256 amount, bool fromSender) external;

  function stakeTo(
    uint256 amount,
    address recipient,
    bool fromSender
  ) external;

  function swapStake(
    uint256 amount,
    address erc20token,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external;

  function swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external;
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
pragma solidity =0.8.9;

interface ISwapMILE {
  enum RequestWithdrawStatus {
    Active,
    Canceled,
    Expired,
    Done
  }

  struct WithdrawRequest {
    uint256 id;
    uint256 amountOfsMILE;
    uint256 creationTimestamp;
    uint256 coolDownEnd;
    uint256 withdrawEnd;
    RequestWithdrawStatus status;
    uint256 statusUpdateTimestamp;
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
    uint256 indexed withdrawalId,
    address recipient,
    uint256 recipientEntityType,
    uint256 amountOfsMILE,
    uint256 amountOfMILE,
    uint256 fee,
    bool success
  );

  event WithdrawCanceled(
    uint256 indexed withdrawalId,
    uint256 amountOfsMILE,
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
    returns (uint256[] memory, uint256);

  function getRequestsByEntity(
    address entity,
    uint256 offset,
    uint256 limit,
    bool ascOrder
  ) external returns (WithdrawRequest[] memory, uint256);

  function getAvailableSMILEToWithdraw(address entity)
    external
    returns (uint256);

  function getRequestedSMILE(address entity) external returns (uint256);

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

interface IBaseEntity {
  enum TokenSourceType {
    UserWallet,
    UserEntity,
    CurrentContract
  }

  struct WithdrawRequest {
    uint256 id;
    uint256 amountOfMILE;
    uint256 creationTimestamp;
  }

  event FundingRoadmap(
    address roadmap,
    address fundingToken,
    address funder,
    uint256 amount
  );

  event StakeMile(address staker, address token, uint256 amount);

  event CreatedRequestWithdraw(
    address staker,
    uint256 amount,
    uint256 indexed requestId
  );

  event CancelRequestWithdraw(
    address staker,
    uint256 amount,
    uint256 requestId
  );

  event Withdrawn(address recipient, uint256 amount);

  event AddedOwner(address owner);

  event RemovedOwner(address owner);

  event AddedAdmin(address admin);

  event RemovedAdmin(address admin);

  function addAdmin(address newAdministrator) external;

  function removeAdmin(address administrator) external;

  function requestWithdraw(uint256 amount) external returns (uint256);

  function cancelWithdraw(uint256 requestId) external;

  function withdrawFromStaking(uint256 requestId) external;

  function withdrawFromEntity(
    address token,
    uint256 amount,
    address recipient
  ) external;
}