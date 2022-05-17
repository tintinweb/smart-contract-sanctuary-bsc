// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/ICRules.sol";
import "./interfaces/IParticipationManager.sol";

contract ParticipationManager {
    /* ========== STATE VARIABLES ========== */

    mapping(address => IParticipationManager.Copier) private copiers;

    ICRules public rulesContract;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rulesContract) {
        rulesContract = ICRules(_rulesContract);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function findPool(address _poolAddress, address[] memory _pools)
        private
        pure
        returns (bool ret)
    {
        for (uint256 index = 0; index < _pools.length; index++) {
            ret = _poolAddress == _pools[index];
            if (ret) break;
        }
    }

    function calcAveragePriceIn(
        uint256 _averagePriceIn,
        uint256 _currentParticipations,
        uint256 _newParticipations,
        uint256 _participationPrice
    ) private pure returns (uint256) {
        uint256 t1 = _averagePriceIn == 0 || _currentParticipations == 0
            ? 0
            : _averagePriceIn * _currentParticipations;

        uint256 t2 = _newParticipations * _participationPrice;

        return (t1 + t2) / (_newParticipations + _currentParticipations);
    }

    function computeSuscribe(
        address _poolAddress,
        address _copierAddress,
        uint256 _amount,
        uint256 _newParticipations,
        uint256 _participationPrice
    ) external onlyPoolInWhiteList(_poolAddress) {
        IParticipationManager.Copier storage copier = copiers[_copierAddress];

        copier.allocation += _amount;
        if (!findPool(_poolAddress, copier.pools)) {
            copier.pools.push(_poolAddress);
        }

        copier.averagePriceIn = calcAveragePriceIn(
            copier.averagePriceIn,
            copier.participations,
            _newParticipations,
            _participationPrice
        );
    }

    function computeUnsuscribe(
        address _poolAddress,
        address _copierAddress,
        uint256 _amount,
        uint256 _participations
    ) external onlyPoolInWhiteList(_poolAddress) {
        IParticipationManager.Copier storage copier = copiers[_copierAddress];

        copier.allocation -= _amount;
        copier.participations -= _participations;
    }

    function getMaxInvestmentAvailable(address _copier, uint256 _stakedTokens)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable)
    {
        (uint256 maxAllocations, uint256 maxPools) = rulesContract
            .getMaxAllocationPerStaking(_stakedTokens);

        maxAllocationAvailable = maxAllocations - copiers[_copier].allocation;
        maxPoolsAvailable = maxPools - copiers[_copier].pools.length;
    }

    /* ========== VIEWS ========== */

    function getCopierInfo(address _copierAddress)
        external
        view
        returns (
            uint256 allocation,
            uint256 participations,
            uint256 pools,
            uint256 averagePriceIn
        )
    {
        IParticipationManager.Copier memory copier = copiers[_copierAddress];

        allocation = copier.allocation;
        participations = copier.participations;
        pools = copier.pools.length;
        averagePriceIn = copier.averagePriceIn;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyPoolInWhiteList(address _poolAddress) {
        require(
            rulesContract.isPoolInWhiteList(_poolAddress),
            "Only a CPool may perform this action"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../CRules.sol";

interface ICRules {
    /* ========== ENUMS ========== */
    enum Tier {
        FREEMIUM,
        BRONZE,
        SILVER,
        GOLD,
        DIAMOND
    }

    /* ========== STRUCTS ========== */
    struct MaxPerTier {
        uint256 maxAllocations;
        uint256 maxPools;
    }

    function getMaxPerformanceFee() external pure returns (uint256);

    function getMaxAllocationPerStaking(uint256 _stakedTokens)
        external
        view
        returns (uint256, uint256);

    function isTokenInWhiteList(address _tokenAddress)
        external
        view
        returns (bool);

    function isTraderInWhiteList(address _traderAddress)
        external
        view
        returns (bool);

    function isPoolInWhiteList(address _poolAddress)
        external
        view
        returns (bool);

    function addPoolToWhiteList(address _poolAddress) external;

    function getTier(uint256 _stakedTokens) external pure returns (Tier);

    function maxPerTier(Tier _tier)
        external
        returns (uint256 maxAllocations, uint256 maxPools);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IParticipationManager {
    /* ========== STRUCTS ========== */

    struct Copier {
        uint256 allocation;
        uint256 participations;
        address[] pools;
        uint256 averagePriceIn;
    }

    function getCopierInfo(address _copierAddress)
        external
        view
        returns (
            uint256 allocation,
            uint256 participations,
            uint256 pools,
            uint256 averagePriceIn
        );

    function computeSuscribe(
        address _poolAddress,
        address _copierAddress,
        uint256 _amount,
        uint256 _newParticipations,
        uint256 _participationPrice
    ) external;

    function getMaxInvestmentAvailable(address _copier, uint256 _stakedTokens)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IParticipationManager.sol";
import "./interfaces/ICRules.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CRules is Ownable {
    /* ========== STATE VARIABLES ========== */

    mapping(ICRules.Tier => ICRules.MaxPerTier) public maxPerTier;
    mapping(address => bool) public tradersWhiteList;
    mapping(address => bool) public tokenWhiteList;
    mapping(address => bool) public poolWhiteList;

    uint256 public constant PROJECT_FEE = 150;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 private constant MAX_PERFORMANCE_FEE = 200;

    /* ========== CONSTRUCTOR ========== */

    constructor() {
        _loadTiers();
    }

    function _loadTiers() private {
        maxPerTier[ICRules.Tier.FREEMIUM] = ICRules.MaxPerTier(
            500 * (10**18),
            1
        );
        maxPerTier[ICRules.Tier.BRONZE] = ICRules.MaxPerTier(
            3000 * (10**18),
            3
        );
        maxPerTier[ICRules.Tier.SILVER] = ICRules.MaxPerTier(
            7000 * (10**18),
            7
        );
        maxPerTier[ICRules.Tier.GOLD] = ICRules.MaxPerTier(
            15000 * (10**18),
            15
        );
        maxPerTier[ICRules.Tier.DIAMOND] = ICRules.MaxPerTier(
            1000000 * (10**18),
            1000
        );
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function modifyMaxPerTier(
        uint8 _tier,
        uint256 _maxAllocations,
        uint256 _maxPools
    ) external onlyOwner {
        require(_tier <= uint8(ICRules.Tier.DIAMOND), "Tier not found.");

        ICRules.MaxPerTier storage maxs = maxPerTier[ICRules.Tier(_tier)];

        maxs.maxAllocations = _maxAllocations;
        maxs.maxPools = _maxPools;
    }

    function addPoolToWhiteList(address _poolAddress) external {
        poolWhiteList[_poolAddress] = true;
    }

    function removePoolFromWhiteList(address _poolAddress) external {
        if (poolWhiteList[_poolAddress]) delete poolWhiteList[_poolAddress];
    }

    function addTraderToWhiteList(address _traderAddress) external onlyOwner {
        tradersWhiteList[_traderAddress] = true;
    }

    function removeTraderFromWhiteList(address _traderAddress)
        external
        onlyOwner
    {
        if (tradersWhiteList[_traderAddress])
            delete tradersWhiteList[_traderAddress];
    }

    function addTokenToWhiteList(address _tokenAddress) external onlyOwner {
        tokenWhiteList[_tokenAddress] = true;
    }

    function removeTokenFromWhiteList(address _tokenAddress)
        external
        onlyOwner
    {
        if (tokenWhiteList[_tokenAddress]) delete tokenWhiteList[_tokenAddress];
    }

    /* ========== VIEWS ========== */
    function getMaxPerformanceFee() external pure returns (uint256) {
        return MAX_PERFORMANCE_FEE;
    }

    function isPoolInWhiteList(address _poolAddress)
        external
        view
        returns (bool)
    {
        return poolWhiteList[_poolAddress];
    }

    function isTraderInWhiteList(address _traderAddress)
        external
        view
        returns (bool)
    {
        return tradersWhiteList[_traderAddress];
    }

    function isTokenInWhiteList(address _tokenAddress)
        external
        view
        returns (bool)
    {
        return tokenWhiteList[_tokenAddress];
    }

    function getMaxAllocationPerStaking(uint256 _stakedTokens)
        public
        view
        returns (ICRules.MaxPerTier memory)
    {
        return maxPerTier[getTier(_stakedTokens)];
    }

    function getTier(uint256 _stakedTokens) public pure returns (ICRules.Tier) {
        if (_stakedTokens >= 200000 * (10**18)) return ICRules.Tier.DIAMOND;
        else if (_stakedTokens >= 70000 * (10**18)) return ICRules.Tier.GOLD;
        else if (_stakedTokens >= 40000 * (10**18)) return ICRules.Tier.SILVER;
        else if (_stakedTokens >= 20000 * (10**18)) return ICRules.Tier.BRONZE;
        return ICRules.Tier.FREEMIUM;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    constructor() {
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