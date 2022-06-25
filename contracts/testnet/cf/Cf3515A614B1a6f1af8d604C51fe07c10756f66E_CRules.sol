// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IParticipationManager.sol";
import "./interfaces/ICRules.sol";

contract CRules {
    /* ========== STATE VARIABLES ========== */

    mapping(ICRules.Tier => ICRules.MaxPerTier) public maxPerTier;
    mapping(address => bool) public tradersWhiteList;
    mapping(address => bool) public tokenWhiteList;
    mapping(address => bool) public poolWhiteList;
    mapping(address => bool) public ownerList;

    uint256 public minAmountToCreatePool;
    uint256 public platformFee;
    uint256 public platformFeeWithPenalty;
    uint256 public penaltyRange;
    address public stableToken;
    address public platformAddress;

    uint256 private constant PERCENTS_DIVIDER = 100;
    uint256 private constant MAX_PERFORMANCE_FEE = 20;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        uint256 _minAmountToCreatePool,
        uint256 _platformFee,
        uint256 _platformFeeWithPenalty,
        uint256 _penaltyRange,
        address _stableToken,
        address[] memory _owners
    ) {
        minAmountToCreatePool = _minAmountToCreatePool;
        platformFee = _platformFee;
        platformFeeWithPenalty = _platformFeeWithPenalty;
        penaltyRange = _penaltyRange;
        stableToken = _stableToken;
        _loadTiers();
        _loadOwners(_owners);
    }

    function _loadOwners(address[] memory _owners) private {
        ownerList[msg.sender] = true;
        for (uint256 i; i < _owners.length; i++) {
            ownerList[_owners[i]] = true;
        }
    }

    function _loadTiers() private {
        maxPerTier[ICRules.Tier.FREEMIUM] = ICRules.MaxPerTier(
            500 * (10**18),
            1,
            1000 * (10**18)
        );
        maxPerTier[ICRules.Tier.BRONZE] = ICRules.MaxPerTier(
            3000 * (10**18),
            3,
            20000 * (10**18)
        );
        maxPerTier[ICRules.Tier.SILVER] = ICRules.MaxPerTier(
            7000 * (10**18),
            7,
            40000 * (10**18)
        );
        maxPerTier[ICRules.Tier.GOLD] = ICRules.MaxPerTier(
            15000 * (10**18),
            15,
            70000 * (10**18)
        );
        maxPerTier[ICRules.Tier.DIAMOND] = ICRules.MaxPerTier(
            1000000 * (10**18),
            1000,
            200000 * (10**18)
        );
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function modifyMaxPerTier(
        uint8 _tier,
        uint256 _maxAllocations,
        uint256 _maxPools
    ) external onlyOwners {
        require(_tier <= uint8(ICRules.Tier.DIAMOND), "Tier not found.");

        ICRules.MaxPerTier storage maxs = maxPerTier[ICRules.Tier(_tier)];

        maxs.maxAllocations = _maxAllocations;
        maxs.maxPools = _maxPools;
    }

    function setPlatformAddress(address _platformAddress) external onlyOwners {
        platformAddress = _platformAddress;
    }

    function setPenaltyDeadline(uint256 _penaltyRange) external onlyOwners {
        penaltyRange = _penaltyRange;
    }

    function setMinAmountToCreatePool(uint256 _minAmountToCreatePool)
        external
        onlyOwners
    {
        minAmountToCreatePool = _minAmountToCreatePool;
    }

    function setPlatformFee(uint256 _platformFee) external onlyOwners {
        platformFee = _platformFee;
    }

    function setPlatformFeeWithPenalty(uint256 _platformFeeWithPenalty)
        external
        onlyOwners
    {
        platformFeeWithPenalty = _platformFeeWithPenalty;
    }

    function addPoolToWhiteList(address _poolAddress) external onlyOwners {
        poolWhiteList[_poolAddress] = true;
    }

    function removePoolFromWhiteList(address _poolAddress) external onlyOwners {
        if (poolWhiteList[_poolAddress]) delete poolWhiteList[_poolAddress];
    }

    function addTraderToWhiteList(address _traderAddress) external onlyOwners {
        tradersWhiteList[_traderAddress] = true;
    }

    function removeTraderFromWhiteList(address _traderAddress)
        external
        onlyOwners
    {
        if (tradersWhiteList[_traderAddress])
            delete tradersWhiteList[_traderAddress];
    }

    function addTokenToWhiteList(address _tokenAddress) external onlyOwners {
        tokenWhiteList[_tokenAddress] = true;
    }

    function removeTokenFromWhiteList(address _tokenAddress)
        external
        onlyOwners
    {
        if (tokenWhiteList[_tokenAddress]) delete tokenWhiteList[_tokenAddress];
    }

    function addOwner(address _ownerAddress) external onlyOwners {
        ownerList[_ownerAddress] = true;
    }

    function removeOwner(address _ownerAddress) external onlyOwners {
        if (ownerList[_ownerAddress]) delete ownerList[_ownerAddress];
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

    function getTier(uint256 _stakedTokens) public view returns (ICRules.Tier) {
        if (
            _stakedTokens >=
            maxPerTier[ICRules.Tier.DIAMOND].requiredTokenStaked
        ) return ICRules.Tier.DIAMOND;
        else if (
            _stakedTokens >= maxPerTier[ICRules.Tier.GOLD].requiredTokenStaked
        ) return ICRules.Tier.GOLD;
        else if (
            _stakedTokens >= maxPerTier[ICRules.Tier.SILVER].requiredTokenStaked
        ) return ICRules.Tier.SILVER;
        else if (
            _stakedTokens >= maxPerTier[ICRules.Tier.BRONZE].requiredTokenStaked
        ) return ICRules.Tier.BRONZE;
        return ICRules.Tier.FREEMIUM;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyOwners() {
        require(
            ownerList[msg.sender],
            "Ownable: caller is not one of the owners."
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IParticipationManager {
    /* ========== STRUCTS ========== */

    struct Copier {
        mapping(address => bool) pools;
        uint256 penaltyDeadLine;
        uint256 capitalInvested;
        uint256 allocation;
        uint8 poolsLength;
    }

    function getCopierInfo(address _copierAddress)
        external
        view
        returns (
            uint256 allocation,
            uint256 pools,
            uint256 penaltyDeadline
        );

    function computeSuscribe(
        address _copierAddress,
        uint256 _newShares,
        uint256 _oldShares,
        uint256 _oldAverageCostPerShare,
        uint256 _newAverageCostPerShare
    ) external;

    function computeUnsuscribe(
        address _copierAddress,
        uint256 _shares,
        uint256 _oldShares,
        uint256 _averageCostPerShare
    ) external;

    function getMaxInvestmentAvailable(address _copier, uint256 _stakedTokens)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable);

    function isCopierSuscribed(address pool) external view returns (bool);
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
        uint256 requiredTokenStaked;
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

    function maxPerTier(Tier _tier) external returns (MaxPerTier memory);

    function minAmountToCreatePool() external returns (uint256);

    function stableToken() external returns (address);

    function platformFee() external view returns (uint256);

    function platformFeeWithPenalty() external returns (uint256);

    function penaltyRange() external returns (uint256);

    function platformAddress() external returns (address);
}