// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './ReferralProgram.sol';

/**
 * @title Fixed staking contract
 */
contract FixedStaking is Ownable {
	// address of the treasury (where fees go)
    address public treasuryAddress;

	// address of the ref contract
	address public referralProgramAddress;

	// pool info
	struct Pool {
		address tokenAddress; // stake/reward token address
		uint256 roiDaily; // daily ROI, 100% = 1000000
		uint256 lockupPeriod; // time with increased unstake fee
		bool isPaused; // whether pool is paused
		uint256 userMinStakeSum; // min sum per user stake
		uint256 userMaxStakeSum; // max sum per user stake
		uint256 maxStakeSum; // max sum of all stakes, if 0 then there is no limit
		uint256 harvestFee; // harvest fee, 100% = 1000000
		uint256 earlyUnstakeFee; // unstake fee before lockup period, 100% = 1000000
		uint256 unstakeFee; // unstake fee, 100% = 1000000
		uint256 depositFee; // deposit fee, 100% = 1000000
	}

	// user stake info
	struct Stake {
		uint256 amount; // amount of staked tokens
		uint256 lastHarvestedAt; // when stake was last harvested
		uint256 createdAt; // when stake was created
		Pool pool; // pool's info at the moment of staking
	}

	// available pools
	mapping (uint => Pool) public pools;
	uint256 public poolsCount;

	// available user stakes
	mapping (address => mapping(uint256 => Stake)) public userPoolStake;

	// % denominator
	uint256 constant DENOMINATOR = 1000000;

	/**
	 * @notice Checks that pool exists
	 * @param _poolIndex pool index
	 */
	modifier poolExists(uint256 _poolIndex) {
		require(_poolIndex < poolsCount, 'POOL_DOES_NOT_EXIST');
		_;
	}

	/**
	 * @notice Contract constructor
	 * @param _treasuryAddress address of the treasury (where fees go)
	 * @param _referralProgramAddress address of the referral program contract
	 */
	constructor(
		address _treasuryAddress,
		address _referralProgramAddress
	) {
		treasuryAddress = _treasuryAddress;
		referralProgramAddress = _referralProgramAddress;
	}

	//=================
	// Public methods
	//=================

	/**
	 * @notice Returns number of days in stake which can be harvested
	 * @param _poolIndex pool index
	 * @return daysAmount number of days which can be harvested in a pool
	 */
	function getDaysAmountToPay(
		uint256 _poolIndex
	) public view poolExists(_poolIndex) returns (uint256) {
		// get user stake info
		Stake memory userStake = userPoolStake[msg.sender][_poolIndex];
		// if last harvest timestamp is greater than pool finish timestamp then
		// set last harvest timestamp to pool's finish time so that "daysUnpaid"
		// were not negative
		uint256 lastHarvestedAt = userStake.lastHarvestedAt;
		if (lastHarvestedAt > userStake.createdAt + userStake.pool.lockupPeriod) {
			lastHarvestedAt = userStake.createdAt + userStake.pool.lockupPeriod;
		}
		// get number of unpaid days
		uint256 daysUnpaid = (userStake.createdAt + userStake.pool.lockupPeriod - lastHarvestedAt) / 1 days;
		// get number of days since the latest harvest
		uint256 daysPassed = (block.timestamp - userStake.lastHarvestedAt) / 1 days;
		// if passed days is greater then unpaid days then return unpaid days
		// ex:
		// - user stakes in 30 days pool
		// - 45 days passes
		// - daysUnpaid: 30, daysPassed: 45
		// - harvest only for 30 days period
		if (daysPassed > daysUnpaid) daysPassed = daysUnpaid;
		return daysPassed;
	}

	/**
	 * @notice Harvests pool
	 * @param _poolIndex pool index
	 * @param _parentRefAddress parent referrer address (can be zero)
	 */
	function harvest(
		uint256 _poolIndex,
		address _parentRefAddress
	) public poolExists(_poolIndex) {
		// validation
		Stake memory userStake = userPoolStake[msg.sender][_poolIndex];
		uint256 daysToPay = getDaysAmountToPay(_poolIndex);
		require(userStake.amount > 0, 'STAKE_EMPTY');
		require(daysToPay > 0, 'NOTHING_TO_HARVEST');
		// update user's stake last harvest timestamp
		userPoolStake[msg.sender][_poolIndex].lastHarvestedAt = block.timestamp;
		// calculate reward amount with harvest fee
		uint256 rewardAmountWithFee = userStake.amount / DENOMINATOR * userStake.pool.roiDaily * daysToPay;
		// calculate harvest fee
		uint256 harvestFee = rewardAmountWithFee / DENOMINATOR * userStake.pool.harvestFee;
		// calculate reward amount without harvest fee
		uint256 rewardAmountWithoutFee = rewardAmountWithFee - harvestFee;
		// transfer harvest fee to treasury
		IERC20(userStake.pool.tokenAddress).transfer(treasuryAddress, harvestFee);
		// transfer reward to user
		IERC20(userStake.pool.tokenAddress).transfer(msg.sender, rewardAmountWithoutFee);
		// accrue referral interest
		ReferralProgram(referralProgramAddress).accrue(ReferralProgram.SourceRefContract.FixedStaking, harvestFee, _parentRefAddress, msg.sender);
	}

	/**
	 * @notice Stakes tokens
	 * @param _poolIndex pool index
	 * @param _tokenAmount token amount
	 * @param _parentRefAddress parent referrer address (can be zero)
	 */
	function stake(
		uint256 _poolIndex,
		uint256 _tokenAmount,
		address _parentRefAddress
	) public poolExists(_poolIndex) {
		// validation
		Pool memory pool = pools[_poolIndex];
		IERC20 token = IERC20(pool.tokenAddress);
		uint256 userStakeSum = userPoolStake[msg.sender][_poolIndex].amount + _tokenAmount;
		require(token.balanceOf(msg.sender) >= _tokenAmount, 'NOT_ENOUGH_TOKENS');
		require(!pool.isPaused, 'PAUSED');
		require(userStakeSum >= pool.userMinStakeSum, 'MIN_USER_SUM_NOT_REACHED');
		require(userStakeSum <= pool.userMaxStakeSum, 'MAX_USER_SUM_REACHED');
		// if max sum in all stakes is enabled
		if (pool.maxStakeSum > 0) {
			uint256 newTotalBalance = token.balanceOf(address(this)) + _tokenAmount;
			require(newTotalBalance <= pool.maxStakeSum, 'MAX_SUM_REACHED');
		}
		// if there is something to harvest then force harvest
		uint256 daysToPay = getDaysAmountToPay(_poolIndex);
		if (daysToPay > 0) {
			harvest(_poolIndex, _parentRefAddress);
		}
		// calculate deposit fee
		uint256 depositFeeAmount = _tokenAmount / DENOMINATOR * pool.depositFee;
		// calculate stake amount
		uint256 stakeAmount = _tokenAmount - depositFeeAmount; 
		// update user's stake
		userPoolStake[msg.sender][_poolIndex].amount += stakeAmount;
		userPoolStake[msg.sender][_poolIndex].lastHarvestedAt = block.timestamp;
		userPoolStake[msg.sender][_poolIndex].createdAt = block.timestamp;
		userPoolStake[msg.sender][_poolIndex].pool = pool;
		// transfer deposit fee to treasury
		IERC20(pool.tokenAddress).transferFrom(msg.sender, treasuryAddress, depositFeeAmount);
		// transfer stake tokens to contract
		IERC20(pool.tokenAddress).transferFrom(msg.sender, address(this), stakeAmount);
	}

	/**
	 * @notice Withdraws user's stake
	 * @param _poolIndex pool index
	 */
	function withdraw(
		uint256 _poolIndex
	) public poolExists(_poolIndex) {
		// validation
		Stake memory userStake = userPoolStake[msg.sender][_poolIndex];
		require(userStake.amount > 0, 'NOTHING_TO_WITHDRAW');
		// check if this is an early unstake
		bool isEarlyUnstake = block.timestamp < userStake.createdAt + userStake.pool.lockupPeriod;
		// get unstake fee
		uint256 unstakeFee = isEarlyUnstake ? userStake.pool.earlyUnstakeFee : userStake.pool.unstakeFee;
		// get unstake fee amount
		uint256 unstakeFeeAmount = userStake.amount / DENOMINATOR * unstakeFee;
		// get harvested sum
		uint256 lockupPeriodDays = userStake.pool.lockupPeriod / 1 days;
		uint256 harvestedDays = (userStake.lastHarvestedAt - userStake.createdAt) / 1 days;
		if (harvestedDays > lockupPeriodDays) harvestedDays = lockupPeriodDays;
		uint256 harvestedSum = isEarlyUnstake ? userStake.amount / DENOMINATOR * userStake.pool.roiDaily * harvestedDays : 0;
		// get withdraw sum
		uint256 withdrawSum = 0;
		if (unstakeFeeAmount + harvestedSum < userStake.amount) {
			withdrawSum = userStake.amount - unstakeFeeAmount - harvestedSum;
		}
		// set user's stake amount to 0
		userPoolStake[msg.sender][_poolIndex].amount = 0;
		// transfer withdraw fee to treasury
		IERC20(userStake.pool.tokenAddress).transfer(treasuryAddress, unstakeFeeAmount);
		// withdaw funds to user
		IERC20(userStake.pool.tokenAddress).transfer(msg.sender, withdrawSum);
	}

	//=================
	// Owner methods
	//=================

	/**
	 * @notice Creates a new pool by owner
	 * @param _pool pool data
	 */
	function createPool(Pool memory _pool) public onlyOwner {
		// check that pool does not exist
		for (uint256 i = 0; i < poolsCount; i++) {
			require(pools[i].tokenAddress != _pool.tokenAddress && pools[i].lockupPeriod != _pool.lockupPeriod, 'POOL_EXISTS');
		}
		// create a new pool
		pools[poolsCount] = _pool;
		// increase pools count
		poolsCount++;
	}

	/**
	 * @notice Updates a pool by owner
	 * @param _poolIndex pool index
	 * @param _pool pool data
	 */
	function updatePool(uint256 _poolIndex, Pool memory _pool) public onlyOwner poolExists(_poolIndex) {
		pools[_poolIndex] = _pool;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './EvxToken.sol';

/**
 * @title Referral program for:
 * - staking
 * - fixed staking
 * - swaps
 * - yield farming
 */
contract ReferralProgram is Ownable {
    // contract where user came from
    enum SourceRefContract {
        Swap,
        Staking,
        FixedStaking,
        YieldFarming
    }

    // fee amount for each referrer level
    // 100% = 1000000
    struct FeeLevel {
        uint level0;
        uint level1;
        uint level2;
        uint level3;
        uint level4;
    }

    // referrer level
    struct RefLevel {
        uint minLiquidityAmount; // min amount of liquidity that user should provide to open level
        uint refLevels; // number of levels from which user gets rewards
        mapping(SourceRefContract => FeeLevel) feeLevels; // fee level for all source ref contract types
    }

    // all available ref levels
    mapping (uint => RefLevel) public refLevels;

    // addresses which can accrue rewards (staking, fixed staking, swap, yield farming)
    mapping (address => bool) public whitelist;

    // child => parent ref hierarchy
    mapping (address => address) public childParentRefs;

    // reward token address
    address public rewardTokenAddress;

    // liquidity contract address
    address public liquidityAddress;

    // treasury address
    address public treasuryAddress;

    // address where tokens are sent for burning
    address public burnAddress;

    // % of reward sent to treasury address when ref level is closed, 100% = 1000000
    // NOTICE: feeRateTreasury + feeRateBurn = 100%
    uint public feeRateTreasury;

    // % of reward sent to burn address when ref level is closed, 100% = 1000000
    // NOTICE: feeRateTreasury + feeRateBurn = 100%
    uint public feeRateBurn;

    // % denominator
	uint constant DENOMINATOR = 1000000;

    // how to deep to search for refs
    uint constant REF_MAX_SEARCH_LEVEL = 5;

    // max number of ref levels
    uint constant REF_MAX_LEVEL_COUNT = 6;

    //===================
	// Public methods
	//===================

    /**
     * @notice Returns fee rate from ref level
     * @param _refLevelIndex ref level index
     * @param _sourceRefContract where call to accrue interest was originated
     * @param _feeLevel fee level to search for
     * @return feeRate fee rate for ref level
     */
    function getFeeRateFromRefLevel(
        uint _refLevelIndex,
        SourceRefContract _sourceRefContract,
        uint _feeLevel
    ) 
        public 
        view
        returns(uint) 
    {
        // validation
        require(_refLevelIndex < REF_MAX_LEVEL_COUNT, 'INVALID_REF_LEVEL');
        require(_feeLevel >= 0 && _feeLevel < REF_MAX_SEARCH_LEVEL, 'INFALID_FEE_LEVEL');
        // return fee rate
        uint feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level0;
        if (_feeLevel == 1) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level1;
        if (_feeLevel == 2) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level2;
        if (_feeLevel == 3) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level3;
        if (_feeLevel == 4) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level4;
        return feeRate;
    }

    /**
     * @notice Returns ref level index for target address
     * @param _targetAddress target address
     * @return refLevelIndex target address ref level index
     */
    function getRefLevelIndex(address _targetAddress) public view returns(uint) {
        // get amount of liquidity tokens
        uint balance = IERC20(liquidityAddress).balanceOf(_targetAddress);
        // by default set ref level 0
        uint refLevelIndex = 0;
        // find ref level
        for (uint i = REF_MAX_SEARCH_LEVEL; i > 0; i--) {
            if (balance >= refLevels[i].minLiquidityAmount) {
                refLevelIndex = i;
                break;
            }
        }
        // return result
        return refLevelIndex;
    }

    //=====================
	// Whitelist methods
	//=====================

    /**
     * @notice Accrues interest in reward tokens
     * @param _sourceRefContract where call was originated from
     * @param _amount amount for which to accrue interest
     * @param _parentRefAddress referrer address
     * @param _childRefAddress referral address
     */
    function accrue(
        SourceRefContract _sourceRefContract,
        uint _amount,
        address _parentRefAddress,
        address _childRefAddress
    )
        public
    {
        // validation
        require(whitelist[msg.sender], 'NOT_ALLOWED');
        // if there is no referrer then do not accrue interest
        if (_parentRefAddress == address(0)) return;
        // if amount is less than demoninator then user will get 0 tokens, skip
        if (_amount < DENOMINATOR) return;

        // set parent referrer for child
        childParentRefs[_childRefAddress] = _parentRefAddress;

        // accrue interest for all parents of the child
        address childAddress = _childRefAddress;
        for (uint feeLevel = 0; feeLevel < REF_MAX_SEARCH_LEVEL; feeLevel++) {
            // get parent address
            address parentAddress = childParentRefs[childAddress];
            // if parent address is empty then stop accrueing
            if (parentAddress == address(0)) break;

            // get parent ref level
            uint parentRefLevelIndex = getRefLevelIndex(parentAddress);
            // get fee rate
            uint feeRate = getFeeRateFromRefLevel(parentRefLevelIndex, _sourceRefContract, feeLevel);
            // if fee rate = 0 then there is nothing to accrue, continue
            if (feeRate == 0) continue;
            // get reward amount
            uint rewardAmount = _amount / DENOMINATOR * feeRate;
            // if ref level is opened
            if (refLevels[parentRefLevelIndex].refLevels >= feeLevel + 1) {
                // accrue interest to parent referrer
                EvxToken(rewardTokenAddress).distributeByReferralProgram(parentAddress, rewardAmount);
            } else {
                // accrue interest to treasury and burn addresses
                uint treasuryAmount = rewardAmount / DENOMINATOR * feeRateTreasury;
                uint burnAmount = rewardAmount / DENOMINATOR * feeRateBurn;
                EvxToken(rewardTokenAddress).distributeByReferralProgram(treasuryAddress, treasuryAmount);
                EvxToken(rewardTokenAddress).distributeByReferralProgram(burnAddress, burnAmount);
            }

            // set the next parent in the tree
            childAddress = parentAddress;
        }
    }

    //=================
	// Owner methods
	//=================

    /**
     * @notice Sets contract params
     * @param _rewardTokenAddress address of the reward token
     * @param _liquidityAddress address of the liquidity contract where user should send liquidity to open ref levels
     * @param _treasuryAddress treasury address where reward is sent when ref level is closed
     * @param _burnAddress burn address where reward is sent when ref level is closed
     * @param _feeRateTreasury % of reward sent to treasury address when ref level is closed, 100% = 1000000
     * @param _feeRateBurn % of reward sent to burn address when ref level is closed, 100% = 1000000
     */
    function setParams(
        address _rewardTokenAddress,
        address _liquidityAddress,
        address _treasuryAddress,
        address _burnAddress,
        uint _feeRateTreasury,
        uint _feeRateBurn
    ) 
        public
        onlyOwner
    {
        // validation
        require(_rewardTokenAddress != address(0), 'ZERO_ADDRESS');
        require(_liquidityAddress != address(0), 'ZERO_ADDRESS');
        require(_feeRateTreasury + _feeRateBurn == DENOMINATOR * 2, 'INVALID_FEE_RATES_SUM');
        // set variables
        liquidityAddress = _liquidityAddress;
        treasuryAddress = _treasuryAddress;
        burnAddress = _burnAddress;
        feeRateTreasury = _feeRateTreasury;
        feeRateBurn = _feeRateBurn;
    }

    /**
     * @notice Sets ref level
     * @param _refLevelIndex ref level index
     * @param _minLiquidityAmount min amount of liqudity needed to open a level
     * @param _refLevels number of levels from which user will get rewards
     * @param _swapFeeLevel swap fee levels
     * @param _stakingFeeLevel staking fee levels
     * @param _fixedStakingFeeLevel fixed staking fee levels
     * @param _yieldFarmingFeeLevel yield farming fee levels
     */
    function setRefLevel(
        uint _refLevelIndex,
        uint _minLiquidityAmount,
        uint _refLevels,
        FeeLevel memory _swapFeeLevel,
        FeeLevel memory _stakingFeeLevel,
        FeeLevel memory _fixedStakingFeeLevel,
        FeeLevel memory _yieldFarmingFeeLevel
    ) 
        public 
        onlyOwner 
    {
        // validation
        require(_refLevelIndex < REF_MAX_LEVEL_COUNT, 'LEVEL_NOT_EXIST');
        require(_refLevels >= 1 && _refLevels <= REF_MAX_SEARCH_LEVEL, 'INVALID_REF_LEVEL');
        // set ref level
        refLevels[_refLevelIndex].minLiquidityAmount = _minLiquidityAmount;
        refLevels[_refLevelIndex].refLevels = _refLevels;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.Swap] = _swapFeeLevel;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.Staking] = _stakingFeeLevel;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.FixedStaking] = _fixedStakingFeeLevel;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.YieldFarming] = _yieldFarmingFeeLevel;
    }

    /**
     * @notice Sets whitelist address which can accrue interest
     * @param _targetAddress address to whitelist
     * @param _isWhitelisted whether address is allowed to accrue interest
     */
    function setWhitelistAddress(
        address _targetAddress, 
        bool _isWhitelisted
    )
        public
        onlyOwner
    {
        whitelist[_targetAddress] = _isWhitelisted;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title Basic token for Evex DEX
 */
contract EvxToken is ERC20, Ownable {
    // address which stores tokens that should be burned
    address public burnAddress;

    // address of the treasury (used for staking rewards)
    address public treasuryAddress;

    // address of the YieldFarming contract which can mint EVX tokens for LP staking
    address public yieldFarmingAddress;

    // address of the Staking contract where users can stake DEX tokens
    address public stakingAddress;

    // address of the ReferralProgram contract
    address public referralProgramAddress;

    // initial token supply
    uint256 public initialSupply;

    // how many tokens were distributed for each token distribution target
    mapping (TokenDistributionTarget => uint256) public tokenDistributionTargetAmount;

    // capacity in % for each distribution target, ex: 100 = 1%
    mapping (TokenDistributionTarget => uint256) public tokenDistributionTargetCap;

    // whether token distribution target is set, can be set only once
    mapping (TokenDistributionTarget => bool) public tokenDistributionTargetIsSet;

    // Where tokens can be distributed (transfered)
    enum TokenDistributionTarget {
        IDO, // initial decentralized offering
        P2E, // play to earn
        TEAM, // team
        REFERRAL, // referral program
        LOCKED, // locked in the smart contract
        YIELD_FARMING, // yield farming
        STAKING, // staking
        MARKETING, // marketing and community
        SAFE_FUND // safe fund
    }

    /**
     * Contract constructor
     * @param _initialSupply initial token supply in wei
     * @param _tokenFullName token full name
     * @param _tokenTicker token ticker name
     * @param _burnAddress address where tokens to be burned should be stored
     * @param _yieldFarmingAddress address of the yield farming contract
     * @param _treasuryAddress address of treasury
     * @param _stakingAddress address of the staking contract
     * @param _referralProgramAddress address of the referral program contract
     */
    constructor(
        uint256 _initialSupply,
        string memory _tokenFullName,
        string memory _tokenTicker,
        address _burnAddress,
        address _yieldFarmingAddress,
        address _treasuryAddress,
        address _stakingAddress,
        address _referralProgramAddress
    ) ERC20(_tokenFullName, _tokenTicker) {
        // validation
        require(_initialSupply > 0, 'EvxToken.constructor: initial supply can not be 0');
        // assign constructor variables
        initialSupply = _initialSupply * 10**decimals();
        burnAddress = _burnAddress;
        yieldFarmingAddress = _yieldFarmingAddress;
        treasuryAddress = _treasuryAddress;
        stakingAddress = _stakingAddress;
        referralProgramAddress = _referralProgramAddress;
        // mint initial supply to current contract address
        _mint(address(this), initialSupply);
    }

    //=================
    // Public methods
    //=================

    /**
     * @notice Checks whether owner can distribute tokens for the specified distribution target
     * Owner can distribute tokens for the following distribution targets:
     * - team
     * - locked amount of tokens
     * - marketing and community
     * - safe fund
     * @param _tokenDistributionTarget token distribution target
     * @return whether owner can distribute tokens for the specified target
     */
    function canBeDistributedByOwner(TokenDistributionTarget _tokenDistributionTarget) public pure returns (bool) {
        bool result = false;
        if (_tokenDistributionTarget == TokenDistributionTarget.TEAM ||
            _tokenDistributionTarget == TokenDistributionTarget.LOCKED ||
            _tokenDistributionTarget == TokenDistributionTarget.MARKETING ||
            _tokenDistributionTarget == TokenDistributionTarget.SAFE_FUND
        ) {
            result = true;
        }
        return result;
    }

    /**
     * @notice Returns max token amount for a specified distribution target which owner can spend
     * @param _tokenDistributionTarget for what purpose tokens are distributed
     * @return max token amount for distribution target which owner can spend
     */
    function getTokenDistributionTargetCapacityLimit(TokenDistributionTarget _tokenDistributionTarget) public view returns(uint256) {
        return (initialSupply / 10_000) * tokenDistributionTargetCap[_tokenDistributionTarget];
    }

    /**
     * @notice Returns current total supply of EVX token
     * @return Current total supply
     */
    function totalSupply () public view override returns (uint256) {
        return balanceOf(address(this));
    }

    //=================
    // Owner methods
    //=================

    /**
     * Send tokens from the burn address
     * @param _to address where tokens should be sent
     * @param _amount amount of tokens to send
     */
    function burnByOwner(address _to, uint256 _amount) public onlyOwner {
        // validation
        require(_amount <= balanceOf(burnAddress), 'EvxToken.burnByOwner: not enough tokens to burn');
        // allow owner to burn tokens
        _approve(burnAddress, owner(), balanceOf(burnAddress));
        // burn tokens
        transferFrom(burnAddress, _to, _amount);
    }

    /**
     * @notice Distributes tokens by owner
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     * @param _tokenDistributionTarget for what purpose tokens are distributed
     */
    function distributeByOwner(address _to, uint256 _amount, TokenDistributionTarget _tokenDistributionTarget) public onlyOwner {
        // validation
        require(canBeDistributedByOwner(_tokenDistributionTarget), 'EvxToken.distributeByOwner(): owner can not distribute tokens for this target');
        // distribute tokens
        _distribute(_to, _amount, _tokenDistributionTarget);
    }

    /**
     * @notice Updates burn address
     * @param _newBurnAddress updated burn address
     */
    function updateBurnAddressByOwner(address _newBurnAddress) public onlyOwner {
        burnAddress = _newBurnAddress;
    }

    /**
     * @notice Sets token distribution target capacity. Can be set only once.
     * Ex: 100 = 1%
     * @param _tokenDistributionTarget token distribution target
     * @param _cap token capacity rate, 100 = 1%
     */
    function setTokenDistributionTargetCapacityByOwner(TokenDistributionTarget _tokenDistributionTarget, uint256 _cap) public onlyOwner {
        // validation
        require(!tokenDistributionTargetIsSet[_tokenDistributionTarget], 'EvxToken.setTokenDistributionTargetCapacityByOwner(): capacity already set for this target');
        require(
            tokenDistributionTargetCap[TokenDistributionTarget.IDO] + 
            tokenDistributionTargetCap[TokenDistributionTarget.P2E] + 
            tokenDistributionTargetCap[TokenDistributionTarget.TEAM] + 
            tokenDistributionTargetCap[TokenDistributionTarget.REFERRAL] + 
            tokenDistributionTargetCap[TokenDistributionTarget.LOCKED] +
            tokenDistributionTargetCap[TokenDistributionTarget.YIELD_FARMING] + 
            tokenDistributionTargetCap[TokenDistributionTarget.STAKING] +
            tokenDistributionTargetCap[TokenDistributionTarget.MARKETING] +
            tokenDistributionTargetCap[TokenDistributionTarget.SAFE_FUND] +
            _cap <= 10_000,
            'EvxToken.setTokenDistributionTargetCapacityByOwner(): total capacity should be <= 10000 (100%)'   
        );

        // set capacity
        tokenDistributionTargetCap[_tokenDistributionTarget] = _cap;
        tokenDistributionTargetIsSet[_tokenDistributionTarget] = true;

        // if owner is allowed to distribute tokens for the specified target
        if (canBeDistributedByOwner(_tokenDistributionTarget)) {
            // Add allowance from contract to owner.
            // Each new distribution target (where owner can spend tokends) adds a new allowance sum.
            uint256 newAllowance = allowance(address(this), owner()) + getTokenDistributionTargetCapacityLimit(_tokenDistributionTarget);
            _approve(address(this), owner(), newAllowance);
        }
    }

    //==================================
    // Yield farming contract methods
    //==================================

    /**
     * @notice Distributes tokens by yield farming contract
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     */
    function distributeByYieldFarming(address _to, uint256 _amount) public {
        // validation
        require(msg.sender == yieldFarmingAddress, 'EvxToken.distributeByYieldFarming(): only yield farming contract can distribute tokens');
        // approve yield farming contract to distribute tokens
        _approve(address(this), yieldFarmingAddress, _amount);
        // distribute tokens
        _distribute(_to, _amount, TokenDistributionTarget.YIELD_FARMING);
    }

    //==================================
    // Staking contract methods
    //==================================

    /**
     * @notice Distributes tokens by staking contract
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     */
    function distributeByStaking(address _to, uint256 _amount) public {
        // validation
        require(msg.sender == stakingAddress, 'EvxToken.distributeByStaking(): only staking contract can distribute tokens');
        // approve staking contract to distribute tokens
        _approve(address(this), stakingAddress, _amount);
        // distribute tokens
        _distribute(_to, _amount, TokenDistributionTarget.STAKING);
    }

    //==================================
    // Referral program contract methods
    //==================================

    /**
     * @notice Distributes tokens by referral program contract
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     */
    function distributeByReferralProgram(address _to, uint256 _amount) public {
        // validation
        require(msg.sender == referralProgramAddress, 'EvxToken.distributeByReferralProgram(): only referral program contract can distribute tokens');
        // approve referral program contract to distribute tokens
        _approve(address(this), referralProgramAddress, _amount);
        // if referral capacity limit is not reached then distribute tokens
        uint tokenDistributionTargetCapacityLimit = getTokenDistributionTargetCapacityLimit(TokenDistributionTarget.REFERRAL);
        bool isCapacityReached = tokenDistributionTargetAmount[TokenDistributionTarget.REFERRAL] + _amount > tokenDistributionTargetCapacityLimit;
        if (!isCapacityReached) {
            _distribute(_to, _amount, TokenDistributionTarget.REFERRAL);
        }
    }

    //===================
    // Internal methods
    //===================

    /**
     * @notice Distributes tokens to address for a specified distribution target
     * @param _to address where tokens should be transfered
     * @param _amount amount of tokens to be tranfered
     * @param _tokenDistributionTarget token distribution target
     */
    function _distribute(address _to, uint256 _amount, TokenDistributionTarget _tokenDistributionTarget) internal {
        // validation
        require(_to != address(0), 'EvxToken._distribute(): _to can not be the zero address');
        require(_amount > 0, 'EvxToken._distribute(): _amount can not be 0');
        require(_amount <= balanceOf(address(this)), 'EvxToken._distribute(): contract does not have enough EVX tokens');
        uint tokenDistributionTargetCapacityLimit = getTokenDistributionTargetCapacityLimit(_tokenDistributionTarget);
        require(tokenDistributionTargetAmount[_tokenDistributionTarget] + _amount <= tokenDistributionTargetCapacityLimit, 'EvxToken._distribute(): capacity limit reached');
        // update distributed amount
        tokenDistributionTargetAmount[_tokenDistributionTarget] += _amount;
        // transfer tokens
        transferFrom(address(this), _to, _amount);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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