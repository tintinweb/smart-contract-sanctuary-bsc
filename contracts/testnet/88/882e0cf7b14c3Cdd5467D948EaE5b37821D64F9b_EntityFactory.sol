// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./UserEntity.sol";
import "./CompanyEntity.sol";
import "./ProjectEntity.sol";
import "./interfaces/IWhiteList.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IEntityStrategy.sol";

/// @title A factory for entity deployment.
/// @dev Contains upgradable beacon proxies of other contracts for a Dapp.
contract EntityFactory is IEntityFactory, OwnableUpgradeable {
  /// @notice Stores the address of an upgradable beacon proxy for a user entity contract.
  /// @return Address of an upgradable beacon proxy for a user entity contract.
  UpgradeableBeacon public userEntityBeacon;
  /// @notice Stores the address of an upgradable beacon proxy for a company entity contract.
  /// @return Address of an upgradable beacon proxy for a company entity contract.
  UpgradeableBeacon public companyEntityBeacon;
  /// @notice Stores the address of an upgradable beacon proxy for a project entity contract.
  /// @return Address of an upgradable beacon proxy for a project entity contract.
  UpgradeableBeacon public projectEntityBeacon;
  /// @notice Stores a entity strategy used to check entity validity.
  /// @return Address of a entity strategy used to check entity validity.
  IEntityStrategy public entityStrategy;

  address public swapMile;

  address public mileToken;

  address public sMileToken;

  IWhiteList public whiteList;

  /// @notice Stores if a particular address is a entity created by this factory.
  /// @return Boolean value which is true if provided address is a entity created by this factory.
  mapping(address => bool) public isEntityByAddress;
  /// @notice Stores if a particular address is a user entity created by this factory.
  /// @return Boolean value which is true if provided address is a user entity.
  mapping(address => bool) public usersEntities;
  /// @notice Stores if a particular address is a company entity created by this factory.
  /// @return Boolean value which is true if provided address is a company entity.
  mapping(address => bool) public companiesEntities;
  /// @notice Stores if a particular address is a project entity created by this factory.
  /// @return Boolean value which is true if provided address is a project entity.
  mapping(address => bool) public projectsEntities;
  /// @notice Stores if a particular address is the owner of user entity.
  /// @return Boolean value which is true if provided address is the owner of user entity.
  mapping(address => bool) public ownersOfUserEntity;

  modifier onlyUserEntity() {
    require(
      usersEntities[_msgSender()],
      "EntityFactory: caller is not the userEntity"
    );
    _;
  }

  modifier onlyValidSignature(
    address owner,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) {
    require(
      entityStrategy.isValid(
        IEntityStrategy.Entity({
          owner: owner,
          swapMile: swapMile,
          mileToken: mileToken,
          sMileToken: sMileToken,
          entityFactory: address(this)
        }),
        deadline,
        argumentsU256,
        argumentsB32
      ),
      "Invalid signature"
    );
    _;
  }

  /// @param userEntityBeacon_ user entity upgradable beacon proxy address;
  /// @param companyEntityBeacon_ company entity upgradable beacon proxy address;
  /// @param projectEntityBeacon_ project entity upgradable beacon proxy address;
  /// @param entityStrategy_ address of entity voting strategy;
  /// @param swapMile_ address of SwapMILE contract;
  /// @param mileToken_ address of MILE token;
  /// @param sMileToken_ address of sMILE token;
  /// @param whiteList_ address of white list contract.
  function initialize(
    UpgradeableBeacon userEntityBeacon_,
    UpgradeableBeacon companyEntityBeacon_,
    UpgradeableBeacon projectEntityBeacon_,
    IEntityStrategy entityStrategy_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address whiteList_
  ) external initializer {
    __Ownable_init();
    require(
      address(userEntityBeacon_) != address(0) &&
        address(companyEntityBeacon_) != address(0) &&
        address(projectEntityBeacon_) != address(0),
      "Entity's Upgradeable Beacon address cannot be zero"
    );
    require(
      address(entityStrategy_) != address(0),
      "EntityStrategy address cannot be zero"
    );
    require(swapMile_ != address(0), "SwapMILE address cannot be zero");
    require(
      mileToken_ != address(0) && sMileToken_ != address(0),
      "Token addresses cannot be zero"
    );
    require(whiteList_ != address(0), "WhiteList address cannot be zero");

    userEntityBeacon = userEntityBeacon_;
    companyEntityBeacon = companyEntityBeacon_;
    projectEntityBeacon = projectEntityBeacon_;
    entityStrategy = entityStrategy_;
    swapMile = swapMile_;
    mileToken = mileToken_;
    sMileToken = sMileToken_;
    whiteList = IWhiteList(whiteList_);
  }

  /// @dev Owner set new address of Entity’s Upgradeable Beacon contract.
  /// @param newBeacon address of new Upgradeable Beacon contract;
  /// @param entityType the type of contract that needs to be changed.
  function updateUpgradeableBeacon(address newBeacon, EntityType entityType)
    external
    onlyOwner
  {
    require(
      newBeacon != address(0),
      "Entity's Upgradeable Beacon address cannot be zero"
    );
    if (entityType == EntityType.UserEntity) {
      userEntityBeacon = UpgradeableBeacon(newBeacon);
    } else if (entityType == EntityType.CompanyEntity) {
      companyEntityBeacon = UpgradeableBeacon(newBeacon);
    } else if (entityType == EntityType.ProjectEntity) {
      projectEntityBeacon = UpgradeableBeacon(newBeacon);
    }
    emit UpdatedUpgradeableBeacon(newBeacon, entityType);
  }

  /// @dev Owner set new address of WhiteList contract.
  /// @param newWhiteList new address of WhiteList contract.
  function updateWhiteList(address newWhiteList) external onlyOwner {
    require(newWhiteList != address(0), "WhiteList address cannot be zero");
    address oldWhiteList = address(whiteList);
    whiteList = IWhiteList(newWhiteList);

    emit UpdatedWhiteList(oldWhiteList, newWhiteList);
  }

  function updatedStrategy(address newEntityStrategy) external onlyOwner {
    require(newEntityStrategy != address(0), "Strategy address cannot be zero");
    address oldEntityStrategy = address(entityStrategy);
    entityStrategy = IEntityStrategy(newEntityStrategy);
    emit UpdatedEntityStrategy(oldEntityStrategy, newEntityStrategy);
  }

  /// @notice Creates a user entity.
  /// @param id Id of entity sended from BE;
  /// @param deadline Signature deadline;
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information;
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information;
  /// @return the address of the created proxy.
  function createUserEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  )
    external
    onlyValidSignature(msg.sender, deadline, argumentsU256, argumentsB32)
    returns (address)
  {
    require(
      !ownersOfUserEntity[msg.sender],
      "The caller has already created a UserEntity"
    );
    require(
      !companiesEntities[msg.sender] && !projectsEntities[msg.sender],
      "The caller cannot be other entities"
    );

    BeaconProxy entity = new BeaconProxy(address(userEntityBeacon), "");

    UserEntity(address(entity)).initialize(
      msg.sender,
      swapMile,
      mileToken,
      sMileToken,
      address(this)
    );
    ownersOfUserEntity[msg.sender] = true;
    whiteList.addNewAddress(address(entity));
    isEntityByAddress[address(entity)] = true;
    usersEntities[address(entity)] = true;
    ownersOfUserEntity[msg.sender] = true;
    emit CreatedNewEntity(
      id,
      msg.sender,
      address(entity),
      EntityType.UserEntity
    );

    return address(entity);
  }

  /// @notice Creates a company entity.
  /// @param id Id of entity sended from BE;
  /// @param deadline Signature deadline;
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information;
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information;
  /// @return the address of the created proxy.
  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  )
    external
    onlyUserEntity
    onlyValidSignature(msg.sender, deadline, argumentsU256, argumentsB32)
    returns (address)
  {
    require(
      !companiesEntities[msg.sender] && !projectsEntities[msg.sender],
      "The caller cannot be other entities"
    );
    BeaconProxy entity = new BeaconProxy(address(companyEntityBeacon), "");

    CompanyEntity(address(entity)).initialize(
      msg.sender,
      swapMile,
      mileToken,
      sMileToken,
      address(this)
    );

    whiteList.addNewAddress(address(entity));
    isEntityByAddress[address(entity)] = true;
    companiesEntities[address(entity)] = true;
    emit CreatedNewEntity(
      id,
      msg.sender,
      address(entity),
      EntityType.CompanyEntity
    );

    return address(entity);
  }

  /// @notice Creates a project entity.
  /// @param id Id of entity sended from BE;
  /// @param deadline Signature deadline;
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information;
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information;
  /// @return the address of the created proxy.
  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  )
    external
    onlyUserEntity
    onlyValidSignature(msg.sender, deadline, argumentsU256, argumentsB32)
    returns (address)
  {
    require(
      !companiesEntities[msg.sender] && !projectsEntities[msg.sender],
      "The caller cannot be other entities"
    );
    BeaconProxy entity = new BeaconProxy(address(projectEntityBeacon), "");

    ProjectEntity(address(entity)).initialize(
      msg.sender,
      swapMile,
      mileToken,
      sMileToken,
      address(this)
    );

    whiteList.addNewAddress(address(entity));
    isEntityByAddress[address(entity)] = true;
    projectsEntities[address(entity)] = true;
    emit CreatedNewEntity(
      id,
      msg.sender,
      address(entity),
      EntityType.ProjectEntity
    );

    return address(entity);
  }

  /// @notice Add new address of entity owner for validating creating userEntities.
  /// @param entityOwner address of entityContract owner to add
  function addUser(address entityOwner) external onlyUserEntity {
    require(entityOwner != address(0), "User address cannot be zero");
    ownersOfUserEntity[entityOwner] = true;
    emit AddedOwnerOfEntity(entityOwner);
  }

  /// @notice Remove address of entity owner for validating creating userEntities.
  /// @param entityOwner address of entityContract owner to remove
  function removeUser(address entityOwner) external onlyUserEntity {
    require(entityOwner != address(0), "User address cannot be zero");
    ownersOfUserEntity[entityOwner] = false;
    emit RemovedOwnerOfEntity(entityOwner);
  }

  function getEntityType(address entity) external view returns (uint256) {
    if (usersEntities[entity]) {
      return uint256(EntityType.UserEntity);
    } else if (companiesEntities[entity]) {
      return uint256(EntityType.CompanyEntity);
    } else if (projectsEntities[entity]) {
      return uint256(EntityType.ProjectEntity);
    } else {
      return 3;
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

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../../access/Ownable.sol";
import "../../utils/Address.sol";

/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
     * beacon.
     */
    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newImplementation` must be a contract.
     */
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
pragma solidity =0.8.9;

import "./BaseEntity.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IUserEntity.sol";

contract UserEntity is BaseEntity, IUserEntity {
  IEntityFactory public entityFactory;

  mapping(address => bool) public childeEntities;

  modifier onlyChildEntity() {
    require(childeEntities[msg.sender], "Caller must be childe entity");
    _;
  }

  /// @param swapMile_ address of SwapMILE contract;
  /// @param mileToken_ address of MILE token;
  /// @param sMileToken_ address of sMILE token;
  /// @param entityFactory_ address of EntityFactory contract.
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

  /// @dev Override function "addOwner" of BaseEntity contract by adding additional code.
  /// @param owner address of new Owner of UserEntity contract.
  function addOwner(address owner) external onlyOwner {
    _addOwner(owner);
    entityFactory.addUser(owner);
  }

  /// @dev Override function "removeOwner" of BaseEntity contract by adding additional code.
  /// @param prevOwner address of owner that pointed to the owner to be removed in the linked list;
  /// @param owner address of owner to remove from UserEntity and EntityFactory.
  function removeOwner(address prevOwner, address owner) external onlyOwner {
    _removeOwner(prevOwner, owner);
    entityFactory.removeUser(owner);
  }

  /// @dev Override function "swapOwner" of BaseEntity contract by adding additional code.
  /// @param prevOwner address of owner that pointed to the owner to be removed in the linked list;
  /// @param oldOwner address of owner to remove from UserEntity and EntityFactory;
  /// @param newOwner address of new Owner of UserEntity contract.
  function swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) external onlyOwner {
    _swapOwner(prevOwner, oldOwner, newOwner);
    entityFactory.removeUser(oldOwner);
    entityFactory.addUser(newOwner);
  }

  /// @dev This function calls function "createCompanyEntity()" EntityFactory contract.
  /// @return the address of the created CompanyEntity proxy.
  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external onlyOwner returns (address) {
    address newEntity = entityFactory.createCompanyEntity(
      id,
      deadline,
      argumentsU256,
      argumentsB32
    );
    childeEntities[newEntity] = true;
    emit CreatedEntity(id, newEntity, 1);
    return newEntity;
  }

  /// @dev This function calls function "createProjectEntity()" EntityFactory contract.
  /// @return the address of the created ProjectEntity proxy.
  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external onlyOwner returns (address) {
    address newEntity = entityFactory.createProjectEntity(
      id,
      deadline,
      argumentsU256,
      argumentsB32
    );
    childeEntities[newEntity] = true;
    emit CreatedEntity(id, newEntity, 2);
    return newEntity;
  }

  function addChildeEntity() external {
    uint256 entityType = entityFactory.getEntityType(msg.sender);
    require(
      0 < entityType && entityType < 3,
      "Caller must be company or project entity"
    );
    childeEntities[msg.sender] = true;
    emit AddedChildeEntity(msg.sender, entityType);
  }

  function removeChildeEntity() external onlyChildEntity {
    uint256 entityType = entityFactory.getEntityType(msg.sender);
    childeEntities[msg.sender] = false;
    emit RemovedChildeEntity(msg.sender, entityType);
  }

  function sendTokens(address token, uint256 amount) external onlyChildEntity {
    require(
      IERC20(token).balanceOf(address(this)) >= amount,
      "Not enougth balance on the user entity contract"
    );
    IERC20(token).transfer(msg.sender, amount);
  }

  /// @notice Stake amount of MILE tokens to SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function stake(uint256 amount, bool fromSender) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(mileToken).transferFrom(msg.sender, address(this), amount);
    }
    _stake(amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function stakeTo(
    uint256 amount,
    address recipient,
    bool fromSender
  ) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(mileToken).transferFrom(msg.sender, address(this), amount);
    }

    _stakeTo(amount, recipient);
  }

  /// @notice Stake amount of ERC20 token to the SwapMILE contract.
  /// @param amount amount of “erc20token “ tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function swapStake(
    uint256 amount,
    address erc20token,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(erc20token).transferFrom(msg.sender, address(this), amount);
    }

    _swapStake(amount, erc20token, validTill, amountOutMin);
  }

  /// @dev The same function like "swapStake" but the BaseEntity contract call
  /// function "swapStakeTo" instead of "swapStake" of SwapMILE contract.
  /// @param amount amount of "erc20token" tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(erc20token).transferFrom(msg.sender, address(this), amount);
    }

    _swapStakeTo(amount, erc20token, recipient, validTill, amountOutMin);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./BaseEntity.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IUserEntity.sol";

contract CompanyEntity is BaseEntity {
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
      "Owner of company entity can be only user entity"
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

interface IWhiteList {
  /// @notice Emits when MilestoneBased contract or owner adds new address to the contract.
  /// @param newAddress address of new contract to add.
  event AddedNewAddress(address newAddress);
  /// @notice Emits when owner remove address from the contract.
  /// @param invalidAddress address of contract for removing.
  event RemovedAddress(address invalidAddress);

  function addNewAddress(address newAddress) external;

  function addNewAddressesBatch(address[] memory newAddresses) external;

  function removeAddress(address invalidAddress) external;

  function removeAddressesBatch(address[] memory invalidAddresses) external;

  function getAllAddresses() external view returns (address[] memory);

  function isValidAddress(address accountAddress) external view returns (bool);
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

/// @title Interface for a generic voting strategy contract
interface IEntityStrategy {
  struct Entity {
    address owner;
    address swapMile;
    address mileToken;
    address sMileToken;
    address entityFactory;
  }

  function isValid(
    Entity calldata entity,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (bool);

  function getNonce(address owner) external returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
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

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
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