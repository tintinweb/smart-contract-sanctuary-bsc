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
    onlyOwnerOrAdministrator
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
  ) external onlyOwnerOrAdministrator {
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
  ) external onlyOwnerOrAdministrator {
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
  ) external onlyOwnerOrAdministrator {
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
import "./WhiteList.sol";

contract BaseEntity is IBaseEntity, Initializable {
  address internal constant SENTINEL_OWNERS = address(0x1);

  ISwapMILE public swapMile;

  address public mileToken;

  address public sMileToken;

  uint256 internal ownerCount;

  mapping(address => address) internal owners;

  mapping(address => bool) internal administrators;

  modifier onlyOwner() {
    require(isOwner(msg.sender), "Caller must be owner");
    _;
  }
  modifier onlyOwnerOrAdministrator() {
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
    address currentOwner = SENTINEL_OWNERS;
    owners[currentOwner] = owner_;
    currentOwner = owner_;
    owners[currentOwner] = SENTINEL_OWNERS;
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
  function _stake(uint256 amount) internal onlyOwnerOrAdministrator {
    IERC20(mileToken).approve(address(swapMile), amount);
    swapMile.stake(amount);

    emit StakeMile(msg.sender, mileToken, amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  function _stakeTo(uint256 amount, address recipient)
    internal
    onlyOwnerOrAdministrator
  {
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
  ) internal onlyOwnerOrAdministrator {
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
    onlyOwnerOrAdministrator
    returns (uint256)
  {
    uint256 requestId = swapMile.requestWithdraw(amount);
    emit CreateRequestWithdraw(msg.sender, amount, requestId);

    return requestId;
  }

  /// @notice Cancel request of withdraw from SwapMILE contract.
  /// @param requestId id of withdrawal request.
  function cancelWithdraw(uint256 requestId) external onlyOwnerOrAdministrator {
    swapMile.cancelWithdraw(requestId);
  }

  /// @notice Withdraw MILE token from SwapMILE contract to the Entity contract.
  /// @param requestId withdrawal request id.
  function withdrawFromStaking(uint256 requestId)
    external
    onlyOwnerOrAdministrator
  {
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
    IERC20(token).transferFrom(address(this), recipient, amount);

    emit Withdraw(recipient, amount);
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

  function createCompanyEntity(uint256 id) external returns (address);

  function createProjectEntity(uint256 id) external returns (address);

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

  event CreateRequestWithdraw(
    address staker,
    uint256 amount,
    uint256 indexed requestId
  );

  event CancelRequestWithdraw(
    address staker,
    uint256 amount,
    uint256 requestId
  );

  event Withdraw(address recipient, uint256 amount);

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

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title The contract keep addresses of all contracts which are using on MilestoneBased platform.
/// @dev It is used by sMILE token for transactions restriction.
contract WhiteList is AccessControl {
  using EnumerableSet for EnumerableSet.AddressSet;
  /// @notice Stores the factory role key hash.
  /// @return Bytes representing fectory role key hash.
  bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

  /// @notice Stores a set of all contracts which are using on MilestoneBased platform.
  EnumerableSet.AddressSet private _whiteList;

  /// @notice Emits when MilestoneBased contract or owner adds new address to the contract.
  /// @param newAddress address of new contract to add.
  event AddNewAddress(address newAddress);
  /// @notice Emits when owner remove address from the contract.
  /// @param invalidAddress address of contract for removing.
  event RemoveAddress(address invalidAddress);

  modifier onlyAdminOrFactory() {
    require(
      hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
        hasRole(FACTORY_ROLE, msg.sender),
      "The caller must be admin or factory contract"
    );
    _;
  }

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  /// @notice Add new address to the contract.
  /// @param newAddress address to add.
  function addNewAddress(address newAddress) public onlyAdminOrFactory {
    _whiteList.add(newAddress);
    emit AddNewAddress(newAddress);
  }

  /// @notice Add new addresses to the contract.
  /// @param newAddresses array of new addresses.
  function addNewAddressesBatch(address[] memory newAddresses)
    public
    onlyAdminOrFactory
  {
    for (uint256 i = 0; i < newAddresses.length; i++) {
      _whiteList.add(newAddresses[i]);
      emit AddNewAddress(newAddresses[i]);
    }
  }

  /// @notice Remove passed address from the contract.
  /// @param invalidAddress address for removing.
  function removeAddress(address invalidAddress) public onlyAdminOrFactory {
    _whiteList.remove(invalidAddress);
    emit RemoveAddress(invalidAddress);
  }

  /// @notice Remove passed addresses from the contract.
  /// @param invalidAddresses array of addresses to remove.
  function removeAddressesBatch(address[] memory invalidAddresses)
    public
    onlyAdminOrFactory
  {
    for (uint256 i = 0; i < invalidAddresses.length; i++) {
      _whiteList.remove(invalidAddresses[i]);
      emit RemoveAddress(invalidAddresses[i]);
    }
  }

  /// @notice Return all addresses of MB platform.
  /// @return White list addresses array.
  function getAllAddresses() external view returns (address[] memory) {
    address[] memory addresses = new address[](_whiteList.length());
    for (uint256 i = 0; i < _whiteList.length(); i++) {
      addresses[i] = _whiteList.at(i);
    }
    return addresses;
  }

  /// @notice Return true if contract has such address, and false if doesn’t.
  /// @param accountAddress address to check.
  /// @return The presence of the address in the list.
  function isValidAddress(address accountAddress) external view returns (bool) {
    return _whiteList.contains(accountAddress);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
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