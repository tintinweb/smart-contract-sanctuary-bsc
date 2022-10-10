// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IGymSinglePool.sol";
import "./interfaces/IGymFarming.sol";
import "./interfaces/IGymVault.sol";
import "./interfaces/IGymMLM.sol";

contract GymMLMQualifications is OwnableUpgradeable {
    /**
     * @notice User qualification
     * @param usdAmountVault: User deposit Vault in USD
     * @param usdAmountFarm: User deposit Farrm in USD
     * @param usdAmountPool: User deposit Pool in USD
     * @param directPartners: User direct partners
     * @param partnerLevel: User partner level
     */
    struct UserLevel {
        uint64 usdAmountVault;
        uint64 usdAmountFarm;
        uint64 usdAmountPool;
        uint32 directPartners;
        uint32 partnerLevel;
    }

    /**
     * @notice Rockstar rank qualification
     * @param qualificationLevel: level by normal qualification
     * @param usdAmountVault: User deposit Vault in USD
     * @param usdAmountFarm: User deposit Farrm in USD
     * @param usdAmountPool: User deposit Pool in USD
     */
    struct RockstarLevel {
        uint64 qualificationLevel;
        uint64 usdAmountVault;
        uint64 usdAmountFarm;
        uint64 usdAmountPool;
    }

    mapping(uint32 => UserLevel) public levels;
    mapping(uint32 => RockstarLevel) public rockStarLevels;
    // mapping for store information about user rockstar rank
    mapping(uint32 => mapping(address => bool)) public hasRockstarRank;
    mapping(address => address[]) public directPartners;

    address public mlmAddress;
    address public bankAddress;
    address public farmingAddress;
    address public singlePoolAddress;

    event SetGymMLMAddress(address indexed _address);
    event SetGymVaultsBankAddress(address indexed _address);
    event SetGymFarmingAddress(address indexed _address);
    event SetGymSinglePoolAddress(address indexed _address);

    function initialize(
        address _mlmAddress,
        address _bankAddress,
        address _farmingAddress,
        address _singlePoolAddress
    ) external initializer {
        mlmAddress = _mlmAddress;
        bankAddress = _bankAddress;
        farmingAddress = _farmingAddress;
        singlePoolAddress = _singlePoolAddress;

        levels[0] = UserLevel(25, 0, 0, 0, 0);
        levels[1] = UserLevel(25, 25, 0, 0, 0);
        levels[2] = UserLevel(50, 50, 50, 0, 0);
        levels[3] = UserLevel(100, 100, 100, 1, 1);
        levels[4] = UserLevel(250, 250, 250, 1, 1);
        levels[5] = UserLevel(500, 500, 500, 1, 2);
        levels[6] = UserLevel(1000, 1000, 1000, 1, 2);
        levels[7] = UserLevel(2500, 2500, 2500, 1, 3);
        levels[8] = UserLevel(5000, 5000, 5000, 1, 3);
        levels[9] = UserLevel(5000, 7500, 7500, 2, 4);
        levels[10] = UserLevel(5000, 10000, 10000, 2, 4);
        levels[11] = UserLevel(7500, 10000, 10000, 2, 4);
        levels[12] = UserLevel(7500, 15000, 15000, 2, 4);
        levels[13] = UserLevel(7500, 20000, 20000, 2, 5);
        levels[14] = UserLevel(10000, 20000, 20000, 2, 5);
        levels[15] = UserLevel(10000, 25000, 25000, 2, 5);
        levels[16] = UserLevel(10000, 30000, 30000, 2, 5);
        levels[17] = UserLevel(20000, 30000, 30000, 2, 5);
        levels[18] = UserLevel(25000, 30000, 30000, 2, 5);
        levels[19] = UserLevel(30000, 30000, 30000, 2, 5);
        levels[20] = UserLevel(30000, 35000, 35000, 2, 5);
        levels[21] = UserLevel(35000, 35000, 35000, 2, 5);
        levels[22] = UserLevel(40000, 40000, 40000, 2, 5);
        levels[23] = UserLevel(45000, 45000, 45000, 2, 5);
        levels[24] = UserLevel(50000, 50000, 50000, 2, 5);

        rockStarLevels[0] = RockstarLevel(9, 2500, 2500, 2500);
        rockStarLevels[1] = RockstarLevel(22, 30000, 30000, 30000);
        rockStarLevels[2] = RockstarLevel(23, 30000, 35000, 35000);

        __Ownable_init();
    }

    modifier onlyMLM() {
        require(msg.sender == mlmAddress);
        _;
    }

    modifier onlyBank() {
        require(msg.sender == bankAddress);
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function setMLMAddress(address _address) external onlyOwner {
        mlmAddress = _address;

        emit SetGymMLMAddress(_address);
    }

    function setBankAddress(address _address) external onlyOwner {
        bankAddress = _address;

        emit SetGymVaultsBankAddress(_address);
    }

    function setSinglePoolAddress(address _address) external onlyOwner {
        singlePoolAddress = _address;

        emit SetGymSinglePoolAddress(_address);
    }

    function setFarmingAddress(address _address) external onlyOwner {
        farmingAddress = _address;

        emit SetGymFarmingAddress(_address);
    }

    /**
     * @notice  Function to set user qualification criteria
     * @param _level:  qualification level
     * @param _usdAmountVault:  value of min deposit in Vault in USD
     * @param _usdAmountFarm:  value of min deposit in Farm in USD
     * @param _usdAmountPool:  value of min deposit in Pool in USD
     * @param _directPartnersCount:  direct partners count
     * @param _partnerLevel:  direct partner level
     */
    function setUserQualification(
        uint32 _level,
        uint64 _usdAmountVault,
        uint64 _usdAmountFarm,
        uint64 _usdAmountPool,
        uint32 _directPartnersCount,
        uint32 _partnerLevel
    ) external onlyOwner {
        levels[_level] = UserLevel(
            _usdAmountVault,
            _usdAmountFarm,
            _usdAmountPool,
            _directPartnersCount,
            _partnerLevel
        );
    }

    function setRockstarRank(
        uint32 _rank,
        uint64 _qualificationLevel,
        uint64 _usdAmountVault,
        uint64 _usdAmountFarm,
        uint64 _usdAmountPool
    ) external onlyOwner {
        rockStarLevels[_rank] = RockstarLevel(
            _qualificationLevel,
            _usdAmountVault,
            _usdAmountFarm,
            _usdAmountPool
        );
    }

    /**
     * @notice  Function to update user rockstar rank
     * @param _user:  user address
     * @param _rank:  rank(0-2)
     * @param _value:  boolean flag
     */
    function updateRockstarRank(
        address _user,
        uint8 _rank,
        bool _value
    ) external onlyBank {
        hasRockstarRank[_rank][_user] = _value;
    }

    /**
     * @notice  Function to add direct partner
     * @param _referrer:  referrer address
     * @param _user:  user address
     */
    function addDirectPartner(address _referrer, address _user) external onlyMLM {
        directPartners[_referrer].push(_user);
    }

    /**
     * @notice External view function to get user MLM level
     * @param _user: user address to get the level
     * @return userLevel user MLM level
     */
    function getUserCurrentLevel(address _user) external view returns (uint32 userLevel) {
        return _getUserLevel(_user);
    }

    /**
     * @notice External view function to get rockstar amount for Vault
     * @param _rank: rockstar rank
     * @return RockstarLevel structure
     */
    function getRockstarAmount(uint32 _rank) external view returns (RockstarLevel memory) {
        return rockStarLevels[_rank];
    }

    /**
     * @notice Private view function to get user MLM level
     * @param _userAddress: user address to get the level
     * @return user MLM level
     */
    function _getUserLevel(address _userAddress) private view returns (uint32) {
        uint32 _userLevel;
        address[] memory _directPartners = directPartners[_userAddress];
        uint256 _usdVault = IGymVault(bankAddress).getUserDepositDollarValue(_userAddress);
        uint256 _usdFarm = IGymFarming(farmingAddress).getUserUsdDepositAllPools(_userAddress);
        uint256 _usdPool = IGymSinglePool(singlePoolAddress)
            .getUserInfo(_userAddress)
            .totalDepositDollarValue;
        // remove if after 12 september
        if (
            IGymFarming(0x03ac9DE519e006E0f9e173392B4b8657E57fc683).isSpecialOfferParticipant(
                _userAddress
            ) &&
            _usdFarm >= 7500 &&
            block.timestamp < 1668058613
        ) {
            return 24;
        }
        // remove if after 12 september
        if (IGymMLM(mlmAddress).addressToId(_userAddress) < 25500 && block.timestamp < 1668058613) {
            for (uint32 i = 0; i <= 24; i++) {
                if (_usdVault >= levels[i].usdAmountVault && _usdPool >= levels[i].usdAmountPool) {
                    _userLevel = i;
                } else {
                    break;
                }
            }
        } else {
            for (uint32 i = 0; i <= 24; i++) {
                if (
                    _usdVault >= levels[i].usdAmountVault &&
                    _usdFarm >= levels[i].usdAmountFarm &&
                    _usdPool >= levels[i].usdAmountPool &&
                    _directPartners.length >= levels[i].directPartners &&
                    _checkPartnersLevel(_directPartners, levels[i].partnerLevel)
                ) {
                    _userLevel = i;
                } else {
                    break;
                }
            }
        }

        uint32 _rockstarRank = _getRockstarRank(_userAddress, _usdVault, _usdFarm, _usdFarm);
        return _rockstarRank > _userLevel ? _rockstarRank : _userLevel;
    }

    /**
     * @notice Private view function to check direct partners levels
     * @param _partners: array of addresses for check
     * @param _level: minimum level of partner
     * @return bool flag
     */
    function _checkPartnersLevel(address[] memory _partners, uint32 _level)
        private
        view
        returns (bool)
    {
        if (_level == 0) return true;
        for (uint32 i = 0; i < _partners.length; i++) {
            if (_getUserLevel(_partners[i]) < _level) {
                return false;
            }
        }
        return true;
    }

    /**
     * @notice Private view function to get user rockstar rank
     * @param _user: user address
     * @param _usdVault: dollar deposit in VaultBank
     * @param _usdFarm: dollar deposit in Farming
     * @param _usdPool: dollar deposit in SinglePool
     */
    function _getRockstarRank(
        address _user,
        uint256 _usdVault,
        uint256 _usdFarm,
        uint256 _usdPool
    ) private view returns (uint32 _rockstarRank) {
        for (uint32 i = 0; i < 2; i++) {
            if (
                hasRockstarRank[i][_user] &&
                _usdVault >= rockStarLevels[i].usdAmountVault &&
                _usdFarm >= rockStarLevels[i].usdAmountFarm &&
                _usdPool >= rockStarLevels[i].usdAmountPool
            ) {
                _rockstarRank = uint32(rockStarLevels[i].qualificationLevel);
            }
        }
    }

    function getDirectPartners(address _user) external view returns (address[] memory) {
        return directPartners[_user];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymSinglePool {
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 totalGGYMNET;
        uint256 level;
        uint256 depositId;
        uint256 totalClaimt;
    }

    function getUserInfo(address) external view returns (UserInfo memory);

    function pendingRewardTotal(address) external view returns (uint256);

    function getUserLevelInSinglePool(address) external view returns (uint32);

    function totalGGymnetInPoolLocked() external view returns (uint256);

    function depositFromOtherContract(
        uint256,
        uint8,
        bool,
        address
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymFarming {
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 lpTokensAmount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    function getUserInfo(uint256, address) external view returns (UserInfo memory);

    function getUserUsdDepositAllPools(address) external view returns (uint256);

    function depositFromOtherContract(
        uint256,
        uint256,
        address
    ) external;

    function pendingRewardTotal(address) external view returns (uint256 total);

    function isSpecialOfferParticipant(address _user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymVault {
    /// @dev Return the total ERC20 entitled to the token holders. Be careful of unaccrued interests.
    function totalToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /// @dev Add more ERC20 to the bank. Hope to get some good returns.
    function deposit(uint256 amountToken) external payable;

    /// @dev Withdraw ERC20 from the bank by burning the share tokens.
    function withdraw(uint256 share) external;

    /// @dev Request funds from user through Vault
    function requestFunds(address targetedToken, uint256 amount) external;

    function token() external view returns (address);

    function pendingRewardTotal(address _user) external view returns (uint256);

    function getUserInvestment(address _user) external view returns (bool);

    function getUserDepositDollarValue(address _user) external view returns (uint256);

    function updateTermsOfConditionsTimestamp(address _user) external;

    function termsOfConditionsTimeStamp(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IGymMLM {
    function addGymMLM(address, uint256) external;

    function addGymMLMNFT(address, uint256) external;

    function distributeRewards(
        uint256,
        address,
        address,
        uint32
    ) external;

    function distributeCommissions(
        uint256,
        uint256,
        uint256,
        bool,
        address
    ) external;

    function updateInvestment(address _user, bool _isInvesting) external;

    function getPendingRewards(address, uint32) external view returns (uint256);

    function hasInvestment(address) external view returns (bool);

    function addressToId(address) external view returns (uint256);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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