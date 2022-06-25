// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IParticipationManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ICRules.sol";
import "./ParticipationManager.sol";

contract CopyStaking {
    /* ========== STATE VARIABLES ========== */

    IERC20 public stakingToken;
    ICRules public rulesContract;
    IParticipationManager public participationManagerContract;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _stakingToken,
        address _rulesContract,
        address _participationManagerContract
    ) {
        stakingToken = IERC20(_stakingToken);
        rulesContract = ICRules(_rulesContract);
        participationManagerContract = IParticipationManager(
            _participationManagerContract
        );
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 _amount) external {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _amount) public validateDowngradeTier(_amount) {
        require(_amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply - _amount;
        _balances[msg.sender] = _balances[msg.sender] - _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function withdrawAll() public {
        withdraw(_balances[msg.sender]);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /* ========== MODIFIERS ========== */

    /**
        @dev Current position must be less than max's of new tier.
     */
    modifier validateDowngradeTier(uint256 _amount) {
        uint256 balance = _balances[msg.sender];

        ICRules.Tier currentTier = rulesContract.getTier(balance);
        ICRules.Tier newTier = rulesContract.getTier(balance - _amount);

        if (currentTier != newTier) {
            (
                uint256 copierAllocation,
                uint256 copierPools,

            ) = participationManagerContract.getCopierInfo(msg.sender);

            ICRules.MaxPerTier memory maxPerTier = rulesContract.maxPerTier(
                newTier
            );

            require(
                copierPools <= maxPerTier.maxPools,
                "Tier downgrade: you must reduce your pools."
            );
            require(
                copierAllocation <= maxPerTier.maxAllocations,
                "Tier downgrade: you must reduce your allocation."
            );
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/ICRules.sol";
import "./interfaces/IParticipationManager.sol";
import "./interfaces/ICPool.sol";

contract ParticipationManager {
    /* ========== STATE VARIABLES ========== */

    mapping(address => IParticipationManager.Copier) public copiers;

    ICRules public rulesContract;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rulesContract) {
        rulesContract = ICRules(_rulesContract);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function computeSuscribe(
        address _copierAddress,
        uint256 _newShares,
        uint256 _oldShares,
        uint256 _newAverageCostPerShare,
        uint256 _oldAverAgeCostPerShare
    ) external onlyPoolInWhiteList {
        IParticipationManager.Copier storage copier = copiers[_copierAddress];

        uint256 oldCapitalInvestedInPool = (_oldShares *
            _oldAverAgeCostPerShare) / 10**18;
        uint256 newCapitalInvestedInPool = ((_oldShares + _newShares) *
            _newAverageCostPerShare) / 10**18;

        copier.capitalInvested += (newCapitalInvestedInPool -
            oldCapitalInvestedInPool);

        if (!copier.pools[msg.sender]) {
            copier.pools[msg.sender] = true;
            copier.poolsLength++;
        }

        copier.penaltyDeadLine = block.timestamp + rulesContract.penaltyRange();
    }

    function computeUnsuscribe(
        address _copierAddress,
        uint256 _shares,
        uint256 _oldShares,
        uint256 _averageCostPerShare
    ) external onlyPoolInWhiteList {
        IParticipationManager.Copier storage copier = copiers[_copierAddress];

        uint256 oldCapitalInvestedInPool = (_oldShares * _averageCostPerShare) /
            10**18;
        uint256 newCapitalInvestedInPool = ((_oldShares - _shares) *
            _averageCostPerShare) / 10**18;

        copier.capitalInvested -= (oldCapitalInvestedInPool -
            newCapitalInvestedInPool);

        if (copier.capitalInvested == 0) {
            delete copier.pools[msg.sender];
            copier.poolsLength--;
        }
    }

    function getMaxInvestmentAvailable(address _copier, uint256 _stakedTokens)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable)
    {
        (uint256 maxAllocations, uint256 maxPools) = rulesContract
            .getMaxAllocationPerStaking(_stakedTokens);

        maxAllocationAvailable =
            maxAllocations -
            copiers[_copier].capitalInvested;
        maxPoolsAvailable = maxPools - copiers[_copier].poolsLength;
    }

    /* ========== VIEWS ========== */

    function isCopierSuscribed(address _copierAddress, address pool)
        external
        view
        returns (bool)
    {
        IParticipationManager.Copier storage copier = copiers[_copierAddress];

        return copier.pools[pool];
    }

    function getCopierInfo(address _copierAddress)
        external
        view
        returns (
            uint256 allocation,
            uint256 pools,
            uint256 penaltyDeadline
        )
    {
        IParticipationManager.Copier storage copier = copiers[_copierAddress];

        allocation = copier.allocation;
        pools = copier.poolsLength;
        penaltyDeadline = copier.penaltyDeadLine;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyPoolInWhiteList() {
        require(
            rulesContract.isPoolInWhiteList(msg.sender),
            "Only a CPool may perform this action"
        );
        _;
    }
}

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

interface ICPool {
    struct Invest {
        uint256 shares;
        uint256 averageCostPerShare;
    }

    function capitalInvestedOf(address _copierAddress)
        external
        view
        returns (uint256);

    function investmentsOf(address _copierAddress)
        external
        view
        returns (uint256);
}