//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./interfaces/IBiswapNFT.sol";
import "./interfaces/ISquidPlayerNFT.sol";
import "./interfaces/ISquidBusNFT.sol";
import "./interfaces/IAutoBSW.sol";
import "./interfaces/IBiswapCollectiblesNFT.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract CollectiblesChanger is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    struct LevelRequirements {
        uint128 rb;
        uint128 se;
        uint8 busCap;
        uint8 quantityAvailable;
        uint8 quantitySold;
    }

    struct CollectiblesLevel {
        uint128 totalBurnedRB;
        uint128 totalBurnedSE;
        uint128 totalBurnedBusCap;
        LevelRequirements[5] prices; //initiate with sort min to max
    }

    IAutoBsw public holderPool;
    ISquidPlayerNFT public squidPlayerNFT;
    ISquidBusNFT public squidBusNFT;
    IBiswapNFT public biswapNFT;
    IBiswapCollectiblesNFT public biswapCollectibles;

    uint public minRequirementsHolderPool;

    CollectiblesLevel[] public collectiblesLevel; //levels start from zero

    //Initialize function ---------------------------------------------------------------------------------------------

    function initialize(
        uint _minRequirementsHolderPool,
        LevelRequirements[5][] calldata _levelRequirements,
        IAutoBsw _holderPool,
        ISquidPlayerNFT _squidPlayerNFT,
        ISquidBusNFT _squidBusNFT,
        IBiswapNFT _robiNFT,
        IBiswapCollectiblesNFT _biswapCollectibles
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        holderPool = _holderPool;
        squidPlayerNFT = _squidPlayerNFT;
        squidBusNFT = _squidBusNFT;
        biswapNFT = _robiNFT;
        biswapCollectibles = _biswapCollectibles;
        minRequirementsHolderPool = _minRequirementsHolderPool;
        for (uint i = 0; i < _levelRequirements.length; i++) {
            collectiblesLevel.push();
            for (uint j = 0; j < _levelRequirements[i].length; j++) {
                collectiblesLevel[collectiblesLevel.length - 1].prices[j] = _levelRequirements[i][j];
            }
        }
    }

    //Modifiers -------------------------------------------------------------------------------------------------------

    modifier notContract() {
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        require(msg.sender.code.length == 0, "Contract not allowed");
        _;
    }

    modifier holderPoolCheck() {
        uint autoBswBalance = (holderPool.balanceOf() * holderPool.userInfo(msg.sender).shares) /
            holderPool.totalShares();
        require(autoBswBalance >= minRequirementsHolderPool, "Need more stake in holder pool");
        _;
    }

    //External functions ----------------------------------------------------------------------------------------------

    function setAddresses(IAutoBsw _holderPool,
        ISquidPlayerNFT _squidPlayerNFT,
        ISquidBusNFT _squidBusNFT,
        IBiswapNFT _biswapNFT,
        IBiswapCollectiblesNFT _biswapCollectibles
    ) external onlyOwner {
        holderPool = _holderPool;
        squidPlayerNFT = _squidPlayerNFT;
        squidBusNFT = _squidBusNFT;
        biswapNFT = _biswapNFT;
        biswapCollectibles = _biswapCollectibles;
    }

    function changeToCollectiblesRB(uint[] calldata tokenId, uint8 level)
        external
        whenNotPaused
        nonReentrant
        notContract
        holderPoolCheck
    {
        require(level <= collectiblesLevel.length, "Wrong level");
        (LevelRequirements memory currentLevelRequirement, uint priceIndex) = getCurrentLevelRequirement(level);
        require(currentLevelRequirement.rb > 0, "Level sold");
        uint128 totalRBForBurn = uint128(biswapNFT.burnForCollectibles(msg.sender, tokenId));
        require(totalRBForBurn >= currentLevelRequirement.rb, "not enough RB");
        CollectiblesLevel storage currentCollectLevel = collectiblesLevel[level - 1];
        currentCollectLevel.totalBurnedRB += totalRBForBurn;
        currentCollectLevel.prices[priceIndex].quantitySold += 1;
        biswapCollectibles.mint(msg.sender, level);
    }

    function changeToCollectiblesSE(
        uint[] calldata playersTokenId,
        uint[] calldata bussesTokenId,
        uint8 level
    ) external whenNotPaused nonReentrant notContract holderPoolCheck {
        require(level <= collectiblesLevel.length, "Wrong level");
        (LevelRequirements memory currentLevelRequirement, uint priceIndex) = getCurrentLevelRequirement(level);
        require(currentLevelRequirement.se > 0, "Level sold");
        uint128 totalSEForBurn = uint128(squidPlayerNFT.burnForCollectibles(msg.sender, playersTokenId));
        uint128 totalBusCapForBurn = uint128(squidBusNFT.burnForCollectibles(msg.sender, bussesTokenId));
        require(
            totalSEForBurn >= currentLevelRequirement.se && totalBusCapForBurn >= currentLevelRequirement.busCap,
            "not enough RB"
        );
        CollectiblesLevel storage currentCollectLevel = collectiblesLevel[level - 1];
        currentCollectLevel.totalBurnedSE += totalSEForBurn;
        currentCollectLevel.totalBurnedBusCap += totalBusCapForBurn;
        currentCollectLevel.prices[priceIndex].quantitySold += 1;
        biswapCollectibles.mint(msg.sender, level);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function getPlayerTokens(address user) external view returns (ISquidPlayerNFT.TokensViewFront[] memory nfts) {
        nfts = user == address(0) ? nfts : squidPlayerNFT.arrayUserPlayers(user);
    }

    function getBusTokens(address user) external view returns (ISquidBusNFT.BusToken[] memory nfts) {
        if (user != address(0)) {
            uint count = squidBusNFT.balanceOf(user);
            nfts = new ISquidBusNFT.BusToken[](count);
            if (count > 0) {
                for (uint i = 0; i < count; i++) {
                    (uint tokenId, , uint8 level, uint32 createTimestamp, string memory uri) = squidBusNFT.getToken(
                        squidBusNFT.tokenOfOwnerByIndex(user, i)
                    );
                    nfts[i].tokenId = tokenId;
                    nfts[i].level = level;
                    nfts[i].createTimestamp = createTimestamp;
                    nfts[i].uri = uri;
                }
            }
        }
        return (nfts);
    }

    function getRobiTokens(address user) external view returns (IBiswapNFT.TokenView[] memory nfts) {
        if (user != address(0)) {
            uint count = biswapNFT.balanceOf(user);
            nfts = new IBiswapNFT.TokenView[](count);
            for (uint i = 0; i < count; i++) {
                (
                    uint tokenId,
                    ,
                    uint level,
                    uint robiBoost,
                    bool stakeFreeze,
                    uint createTimestamp,
                    ,
                    string memory uri
                ) = biswapNFT.getToken(biswapNFT.tokenOfOwnerByIndex(user, i));
                nfts[i].tokenId = tokenId;
                nfts[i].level = level;
                nfts[i].robiBoost = robiBoost;
                nfts[i].stakeFreeze = stakeFreeze;
                nfts[i].createTimestamp = createTimestamp;
                nfts[i].uri = uri;
            }
        }
        return nfts;
    }

    function getCollectiblesTokens(address user)
        external
        view
        returns (IBiswapCollectiblesNFT.TokenView[] memory nfts)
    {
        nfts = biswapCollectibles.getUserTokens(user);
    }

    //Public functions ----------------------------------------------------------------------------------------------

    function getUserInfo(address user)
        public
        view
        returns (
            LevelRequirements[] memory currentLevelRequirements,
            uint robiNFTBalance,
            uint playersBalance,
            uint busBalance,
            uint totalRbinNFTs,
            uint AvailableRB
        )
    {
        currentLevelRequirements = new LevelRequirements[](collectiblesLevel.length);
        for (uint8 i = 0; i < collectiblesLevel.length; i++) {
            (currentLevelRequirements[i], ) = getCurrentLevelRequirement(i+1);
        }
        robiNFTBalance = biswapNFT.balanceOf(user);
        playersBalance = squidPlayerNFT.balanceOf(user);
        busBalance = squidBusNFT.balanceOf(user);
        AvailableRB = biswapNFT.getRbBalance(user);
        totalRbinNFTs = 0;
        for(uint i = 0; i < robiNFTBalance; i++){
            totalRbinNFTs += biswapNFT.getRB(biswapNFT.tokenOfOwnerByIndex(user, i));
        }
    }

    //Internal functions --------------------------------------------------------------------------------------------
    function getCurrentLevelRequirement(uint8 level)
        internal
        view
        returns (LevelRequirements memory currentLevelRequirement, uint priceIndex)
    {
        CollectiblesLevel memory currentLevel = collectiblesLevel[level - 1];
        for (uint i = 0; i < currentLevel.prices.length; i++) {
            if (currentLevel.prices[i].quantityAvailable > currentLevel.prices[i].quantitySold) {
                return (currentLevel.prices[i], i);
            }
        }
        return (currentLevelRequirement, priceIndex);
    }

    //Private functions ---------------------------------------------------------------------------------------------
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBiswapNFT {
    struct Token {
        uint robiBoost;
        uint level;
        bool stakeFreeze;
        uint createTimestamp;
    }

    struct TokenView {
        uint tokenId;
        uint robiBoost;
        uint level;
        bool stakeFreeze;
        uint createTimestamp;
        string uri;
    }

    function getLevel(uint tokenId) external view returns (uint);

    function getRB(uint tokenId) external view returns (uint);

    function getInfoForStaking(uint tokenId)
        external
        view
        returns (
            address tokenOwner,
            bool stakeFreeze,
            uint robiBoost
        );

    function getToken(uint _tokenId)
        external
        view
        returns (
            uint tokenId,
            address tokenOwner,
            uint level,
            uint rb,
            bool stakeFreeze,
            uint createTimestamp,
            uint remainToNextLevel,
            string memory uri
        );

    function accrueRB(address user, uint amount) external;

    function tokenFreeze(uint tokenId) external;

    function tokenUnfreeze(uint tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function getRbBalance(address user) external view returns (uint);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function burnForCollectibles(address user, uint[] calldata tokenId) external returns (uint); //todo add in contract returns RB amount
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface ISquidPlayerNFT{
    struct TokensViewFront {
        uint tokenId;
        uint8 rarity;
        address tokenOwner;
        uint128 squidEnergy;
        uint128 maxSquidEnergy;
        uint32 contractEndTimestamp;
        uint32 contractV2EndTimestamp;
        uint32 busyTo; //Timestamp until which the player is busy
        uint32 createTimestamp;
        bool stakeFreeze;
        string uri;
        bool contractBought;
    }

    function getToken(uint _tokenId) external view returns (TokensViewFront memory);

    function arrayUserPlayers(address _user) external view returns (TokensViewFront[] memory);

    function balanceOf(address owner) external view returns (uint balance);

    function burnForCollectibles(address user, uint[] calldata tokenId) external returns(uint); //todo add in contract returns SE amount
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface ISquidBusNFT {

    struct BusToken {
        uint tokenId;
        uint8 level;
        uint32 createTimestamp;
        string uri;
    }

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Initialize(string baseURI);
    event Initialized(uint8 version);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event TokenMint(address indexed to, uint256 indexed tokenId, uint8 level);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function TOKEN_MINTER_ROLE() external view returns (bytes32);

    function allowedBusBalance(address _user) external view returns (uint256);

    function allowedUserToMintBus(address _user) external view returns (bool);

    function allowedUserToPlayGame(address _user) external view returns (bool);

    function approve(address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 _tokenId) external;

    function busAdditionPeriod() external view returns (uint256);

    function firstBusTimestamp(address) external view returns (uint256);

    function getApproved(uint256 tokenId) external view returns (address);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getToken(uint256 _tokenId)
        external
        view
        returns (
            uint256 tokenId,
            address tokenOwner,
            uint8 level,
            uint32 createTimestamp,
            string memory uri
        );

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function initialize(
        string memory baseURI,
        uint8 _maxBusLevel,
        uint256 _minBusBalance,
        uint256 _maxBusBalance,
        uint256 _busAdditionPeriod
    ) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function maxBusBalance() external view returns (uint256);

    function minBusBalance() external view returns (uint256);

    function mint(address _to, uint8 _busLevel) external;

    function name() external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address);

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;

    function seatsInBuses(address _user) external view returns (uint256);

    function secToNextBus(address _user) external view returns (uint256);

    function setApprovalForAll(address operator, bool approved) external;

    function setBaseURI(string memory newBaseUri) external;

    function setBusParameters(
        uint8 _maxBusLevel,
        uint256 _minBusBalance,
        uint256 _maxBusBalance,
        uint256 _busAdditionPeriod
    ) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function burnForCollectibles(address user, uint[] calldata tokenId) external returns(uint); //todo add in contract returns bus capacities
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface IAutoBsw {
    function balanceOf() external view returns (uint);

    function totalShares() external view returns (uint);

    struct UserInfo {
        uint shares; // number of shares for a user
        uint lastDepositedTime; // keeps track of deposited time for potential penalty
        uint BswAtLastUserAction; // keeps track of Bsw deposited at the last user action
        uint lastUserActionTime; // keeps track of the last user action time
    }

    function userInfo(address user) external view returns (UserInfo memory);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBiswapCollectiblesNFT {
  struct Token{
    uint8 level;
    uint32 createTimestamp;
  }

  struct TokenView{
    uint tokenId;
    uint8 level;
    uint32 createTimestamp;
    address tokenOwner;
    string uri;
    bool isSelected;
  }

  function DEFAULT_ADMIN_ROLE (  ) external view returns ( bytes32 );
  function TOKEN_MINTER_ROLE (  ) external view returns ( bytes32 );
  function MAX_LEVEL() external view returns (uint);
  function approve ( address to, uint256 tokenId ) external;
  function balanceOf ( address owner ) external view returns ( uint256 );
  function burn ( uint256 _tokenId ) external;
  function getApproved ( uint256 tokenId ) external view returns ( address );
  function getRoleAdmin ( bytes32 role ) external view returns ( bytes32 );
  function getToken ( uint256 tokenId ) external view returns ( TokenView calldata);
  function getUserTokens ( address user ) external view returns ( TokenView[] calldata);
  function getUserSelectedToken(address user) external view returns (TokenView memory token);
  function getUserSelectedTokenId(address user) external view returns (uint tokenId, uint8 level);
  function grantRole ( bytes32 role, address account ) external;
  function hasRole ( bytes32 role, address account ) external view returns ( bool );
  function initialize ( string calldata baseURI, string calldata name_, string calldata symbol_ ) external;
  function isApprovedForAll ( address owner, address operator ) external view returns ( bool );
  function mint ( address to, uint8 level ) external;
  function name (  ) external view returns ( string calldata);
  function ownerOf ( uint256 tokenId ) external view returns ( address );
  function renounceRole ( bytes32 role, address account ) external;
  function revokeRole ( bytes32 role, address account ) external;
  function safeTransferFrom ( address from, address to, uint256 tokenId ) external;
  function safeTransferFrom ( address from, address to, uint256 tokenId, bytes calldata data ) external;
  function setApprovalForAll ( address operator, bool approved ) external;
  function setBaseURI ( string calldata newBaseUri ) external;
  function supportsInterface ( bytes4 interfaceId ) external view returns ( bool );
  function symbol (  ) external view returns ( string calldata );
  function tokenByIndex ( uint256 index ) external view returns ( uint256 );
  function tokenOfOwnerByIndex ( address owner, uint256 index ) external view returns ( uint256 );
  function tokenURI ( uint256 tokenId ) external view returns ( string calldata );
  function totalSupply (  ) external view returns ( uint256 );
  function transferFrom ( address from, address to, uint256 tokenId ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}