/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

/**
 * @title TokenStakingFLR
 */
contract TokenStakingFLR is Ownable, ReentrancyGuard {
    struct StakingSchedule {
        bool initialized;
        address beneficiary;
        uint256 start;
        uint256 tier;
        uint256 amountTotal;
        uint256 lastClaim;
    }

    uint8 private _tokenDecimals = 18;

    uint256 public tier1LockPeriod = 0;
    uint256 public tier2LockPeriod = 5259486; // 2 months
    uint256 public tier3LockPeriod = 10518972; // 4 months
    uint256 public tier4LockPeriod = 15778458; // 6 months
    uint256 public tier1APY = 60;
    uint256 public tier2APY = 100;
    uint256 public tier3APY = 120;
    uint256 public tier4APY = 145;
    uint256 public tier1AdditionalTokensPercentage = 0;
    uint256 public tier2AdditionalTokensPercentage = 2;
    uint256 public tier3AdditionalTokensPercentage = 4;
    uint256 public tier4AdditionalTokensPercentage = 6;
    uint256 public tier1MinAmount = (1000 * 10**_tokenDecimals);
    uint256 public tier1MaxAmount = (200000000 * 10**_tokenDecimals);
    uint256 public tier2MinAmount = (200000000 * 10**_tokenDecimals);
    uint256 public tier2MaxAmount = (400000000 * 10**_tokenDecimals);
    uint256 public tier3MinAmount = (400000000 * 10**_tokenDecimals);
    uint256 public tier3MaxAmount = (600000000 * 10**_tokenDecimals);
    uint256 public tier4MinAmount = (600000000 * 10**_tokenDecimals);
    uint256 public tier4MaxAmount = (999999999 * 10**_tokenDecimals);


    IERC20 public immutable tokenAddress;

    mapping(address => uint256) private _balances;
    mapping(bytes32 => StakingSchedule) private _stakingSchedules;
    mapping(address => uint256) private _holdersStakingCount;
    bytes32[] private _stakingSchedulesIds;
    uint256 private _stakingSchedulesTotalAmount;
    uint256 private _dailyTime = 86400;


    event RewardsClaimed(address beneficiary, uint256 amount);
    event StakingScheduleCreated(address from, uint256 tier, uint256 amount);
    event StakedFLR(address from, uint256 amount);
    event UnstakedFLR(address from, uint256 amount);

    modifier onlyIfStakingScheduleExists(bytes32 stakingScheduleId) {
        require(
            _stakingSchedules[stakingScheduleId].initialized == true,
            "TokenStakingFLR: INVALID Staking Schedule ID! no staking schedule exists for that ID"
        );
        _;
    }

    modifier onlyIfBeneficiaryExists(address beneficiary) {
        require(
            _holdersStakingCount[beneficiary] > 0,
            "TokenStakingFLR: INVALID Beneficiary Address! no staking schedule exists for that beneficiary"
        );
        _;
    }

    constructor(address token_) {
        require(token_ != address(0x0));
        tokenAddress = IERC20(token_);
    }

    function getTier1MinMax() public view returns (uint256, uint256){
        return (tier1MinAmount, tier1MaxAmount);
    }

    function changeAllTiersLockPeriod(
        uint256 _tier1LockPeriod,
        uint256 _tier2LockPeriod,
        uint256 _tier3LockPeriod,
        uint256 _tier4LockPeriod
    ) external returns (bool) {
        tier1LockPeriod = _tier1LockPeriod;
        tier2LockPeriod = _tier2LockPeriod;
        tier3LockPeriod = _tier3LockPeriod;
        tier4LockPeriod = _tier4LockPeriod;

        return true;
    }

    function changeAllTiersAPY(
        uint256 _tier1APY,
        uint256 _tier2APY,
        uint256 _tier3APY,
        uint256 _tier4APY
    ) external returns (bool) {
        tier1APY = _tier1APY;
        tier2APY = _tier2APY;
        tier3APY = _tier3APY;
        tier4APY = _tier4APY;

        return true;
    }

    function changeAllTiersAdditionalTokensPercentage(
        uint256 _tier1AdditionalTokensPercentage,
        uint256 _tier2AdditionalTokensPercentage,
        uint256 _tier3AdditionalTokensPercentage,
        uint256 _tier4AdditionalTokensPercentage
    ) external returns (bool) {
        tier1AdditionalTokensPercentage = _tier1AdditionalTokensPercentage;
        tier2AdditionalTokensPercentage = _tier2AdditionalTokensPercentage;
        tier3AdditionalTokensPercentage = _tier3AdditionalTokensPercentage;
        tier4AdditionalTokensPercentage = _tier4AdditionalTokensPercentage;

        return true;
    }

    function changeTier1MinMaxAmount(
        uint256 _tier1MinAmount,
        uint256 _tier1MaxAmount
    ) external returns (bool) {
        tier1MinAmount = _tier1MinAmount;
        tier1MaxAmount = _tier1MaxAmount;
        
        return true;
    }

    function changeTier2MinMaxAmount(
        uint256 _tier2MinAmount,
        uint256 _tier2MaxAmount
    ) external returns (bool) {
        tier2MinAmount = _tier2MinAmount;
        tier2MaxAmount = _tier2MaxAmount;
        
        return true;
    }

    function changeTier3MinMaxAmount(
        uint256 _tier3MinAmount,
        uint256 _tier3MaxAmount
    ) external returns (bool) {
        tier3MinAmount = _tier3MinAmount;
        tier3MaxAmount = _tier3MaxAmount;
        
        return true;
    }

    function changeTier4MinMaxAmount(
        uint256 _tier4MinAmount,
        uint256 _tier4MaxAmount
    ) external returns (bool) {
        tier4MinAmount = _tier4MinAmount;
        tier4MaxAmount = _tier4MaxAmount;
        
        return true;
    }

    function getAdditionalPercentageOfAccount(address beneficiary)
        external
        view
        returns (uint256)
    {
        uint256 stakingSchedulesCountByBeneficiary = getStakingSchedulesCountByBeneficiary(beneficiary);

        StakingSchedule storage stakingSchedule;
        uint256 biggestStakingTier = 0;
        uint256 i = 1;
        do {
            stakingSchedule = _stakingSchedules[computeStakingScheduleIdForAddressAndIndex(beneficiary, i)];

            if (stakingSchedule.tier > biggestStakingTier) {
                biggestStakingTier = stakingSchedule.tier;
            }

            i++;
        } while (i < stakingSchedulesCountByBeneficiary);

        if (biggestStakingTier == 1) {
            return tier1AdditionalTokensPercentage;
        }
        if (biggestStakingTier == 2) {
            return tier2AdditionalTokensPercentage;
        }
        if (biggestStakingTier == 3) {
            return tier3AdditionalTokensPercentage;
        }
        if (biggestStakingTier == 4) {
            return tier4AdditionalTokensPercentage;
        }

        return 0;
    }

    function getStakingSchedulesCountByBeneficiary(address _beneficiary) // temp
        private // public
        view
        returns (uint256)
    {
        return _holdersStakingCount[_beneficiary];
    }

    function getStakingIdAtIndex(uint256 index) // temp
        private // external
        view
        returns (bytes32)
    {
        require(
            index < getStakingSchedulesCount(),
            "TokenStakingFLR: index out of bounds"
        );
        return _stakingSchedulesIds[index];
    }

    function getStakingScheduleByBeneficiaryAndIndex(
        address beneficiary,
        uint256 index
    ) 
    private // external 
    view returns (StakingSchedule memory) {
        require(
            _holdersStakingCount[beneficiary] > 0,
            "TokenStakingFLR: INVALID Beneficiary Address! no staking schedule exists for that beneficiary"
        );
        require(
            index < _holdersStakingCount[beneficiary],
            "TokenStakingFLR: INVALID Staking Schedule Index! no staking schedule exists at this index for that beneficiary"
        );
        return
            getStakingSchedule(
                computeStakingScheduleIdForAddressAndIndex(beneficiary, index)
            );
    }

    function computeStakingScheduleIdForAddressAndIndex(
        address holder,
        uint256 index
    ) private
    // public 
    pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function getStakingSchedule(bytes32 stakingScheduleId)
        private // public
        view
        returns (StakingSchedule memory)
    {
        StakingSchedule storage stakingSchedule = _stakingSchedules[
            stakingScheduleId
        ];
        require(
            stakingSchedule.initialized == true,
            "TokenStakingFLR: INVALID Staking Schedule ID! no staking schedule exists for that id"
        );
        return stakingSchedule;
    }

    function getStakingSchedulesTotalAmount() external view returns (uint256) {
        return _stakingSchedulesTotalAmount;
    }

    function stakeTokens(uint256 amount, uint256 tierNumber) external {
        address from = _msgSender();
        _stakeTokens(from, amount, tierNumber);

        emit StakedFLR(from, amount);
    }

    function _stakeTokens(
        address from,
        uint256 amount,
        uint256 tier
    ) private {
        require((tier >= 1) && (tier <= 4),
            "TokenStakingFLR: invalid tier, choose 1-4");

        if (tier == 1) {
            require((amount >= tier1MinAmount && amount < tier1MaxAmount),
                "TokenStakingFLR: Tier 1 only allows staking >= tier1MinAmount and < tier1MaxAmount FLR tokens");
        }
        if (tier == 2) {
            require((amount >= tier2MinAmount && amount < tier2MaxAmount),
                "TokenStakingFLR: Tier 2 only allows staking >= tier2MinAmount and < tier2MaxAmount FLR tokens");
        }
        if (tier == 3) {
            require((amount >= tier3MinAmount && amount < tier3MaxAmount),
                "TokenStakingFLR: Tier 3 only allows staking >= tier3MinAmount and < tier3MaxAmount FLR tokens");
        }
        if (tier == 4) {
            require((amount >= tier4MinAmount && amount < tier4MaxAmount),
                "TokenStakingFLR: Tier 3 only allows staking >= tier4MinAmount and < tier4MaxAmount FLR tokens");
        }

        tokenAddress.transferFrom(from, address(this), amount);
        _createStakingSchedule(from, tier, amount);

        emit StakingScheduleCreated(from, tier, amount);
    }

    function _createStakingSchedule(
        address _beneficiary,
        uint256 _tier,
        uint256 _amount
    ) private {
        bytes32 stakingScheduleId = computeNextStakingScheduleIdForHolder(_beneficiary);

        _stakingSchedules[stakingScheduleId] = StakingSchedule(
            true,
            _beneficiary,
            block.timestamp,
            _tier,
            _amount,
            block.timestamp
        );
        _balances[_beneficiary] += _amount;
        _stakingSchedulesTotalAmount += _amount;
        _stakingSchedulesIds.push(stakingScheduleId);
        uint256 currentStakingCount = _holdersStakingCount[_beneficiary];
        _holdersStakingCount[_beneficiary] = currentStakingCount + 1;
    }

    function getRewardReservesBalance() public view returns (uint256) {
        return tokenAddress.balanceOf(address(this)) - _stakingSchedulesTotalAmount;
    }

    function computeNextStakingScheduleIdForHolder(address holder)
        private
        view
        returns (bytes32)
    {
        return computeStakingScheduleIdForAddressAndIndex(holder, _holdersStakingCount[holder]);
    }

    function _computeReleasableRewardAmount(StakingSchedule memory stakingSchedule)
        private
        view
        returns (uint256)
    {
        uint256 currentTime = getCurrentTime();
        uint256 timeDifference = currentTime - stakingSchedule.lastClaim;

        uint256 daysToRelease = timeDifference / _dailyTime;

        uint256 amount = stakingSchedule.amountTotal;
        uint256 tier = stakingSchedule.tier;
        uint256 dailyReleaseable;
        if (tier == 1) {
            dailyReleaseable = ((amount * tier1APY) / 1000) / 365;
        }
        if (tier == 2) {
            dailyReleaseable = ((amount * tier2APY) / 1000) / 365;
        }
        if (tier == 3) {
            dailyReleaseable = ((amount * tier3APY) / 1000) / 365;
        }
        if (tier == 4) {
            dailyReleaseable = ((amount * tier4APY) / 1000) / 365;
        }

        return (dailyReleaseable * daysToRelease);
    }

    function releaseRewardsFromAllStakings(address beneficiary)
        external
        onlyOwner
        nonReentrant
        onlyIfBeneficiaryExists(beneficiary)
    {
        uint256 stakingSchedulesCountByBeneficiary = getStakingSchedulesCountByBeneficiary(beneficiary);

        StakingSchedule storage stakingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            stakingSchedule = _stakingSchedules[computeStakingScheduleIdForAddressAndIndex(beneficiary, i)];
            uint256 releaseableAmount = _computeReleasableRewardAmount(stakingSchedule);
            stakingSchedule.lastClaim = block.timestamp;

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < stakingSchedulesCountByBeneficiary);

        require(this.getRewardReservesBalance() >= totalReleaseableAmount,
            "TokenStakingFLR: not enough reward funds available");
        tokenAddress.transfer(beneficiary, totalReleaseableAmount);

        emit RewardsClaimed(beneficiary, totalReleaseableAmount);
    }

    function claimRewardsFromAllStakings()
        external
        nonReentrant
        onlyIfBeneficiaryExists(msg.sender)
    {
        address beneficiary = _msgSender();
        uint256 stakingSchedulesCountByBeneficiary = getStakingSchedulesCountByBeneficiary(beneficiary);

        StakingSchedule storage stakingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            stakingSchedule = _stakingSchedules[computeStakingScheduleIdForAddressAndIndex(beneficiary, i)];
            uint256 releaseableAmount = _computeReleasableRewardAmount(stakingSchedule);
            stakingSchedule.lastClaim = block.timestamp;

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < stakingSchedulesCountByBeneficiary);

        require(this.getRewardReservesBalance() >= totalReleaseableAmount,
            "TokenStakingFLR: not enough reward funds available");
        tokenAddress.transfer(beneficiary, totalReleaseableAmount);

        emit RewardsClaimed(beneficiary, totalReleaseableAmount);
    }

    function computeReleasableRewardAmount(bytes32 stakingScheduleId)
        public
        view
        onlyIfStakingScheduleExists(stakingScheduleId)
        returns (uint256)
    {
        StakingSchedule storage stakingSchedule = _stakingSchedules[stakingScheduleId];

        return _computeReleasableRewardAmount(stakingSchedule);
    }

    function unstakeTokens() external {
        address from = _msgSender();
        uint256 amount = _unstakeTokens(from);

        emit UnstakedFLR(from, amount);
    }

    function _unstakeTokens(address beneficiary) private returns (uint256) {
        uint256 stakingSchedulesCountByBeneficiary = getStakingSchedulesCountByBeneficiary(beneficiary);

        StakingSchedule storage stakingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            stakingSchedule = _stakingSchedules[computeStakingScheduleIdForAddressAndIndex(beneficiary, i)];

            uint256 tier = stakingSchedule.tier;
            uint256 currentTime = block.timestamp;
            bool initialized = stakingSchedule.initialized;

            if(!initialized) {continue;}
            if (tier == 1 && (currentTime < tier1LockPeriod)) {continue;}
            if (tier == 2 && (currentTime < tier2LockPeriod)) {continue;}
            if (tier == 3 && (currentTime < tier3LockPeriod)) {continue;}
            if (tier == 4 && (currentTime < tier4LockPeriod)) {continue;}

            uint256 releaseableAmount = stakingSchedule.amountTotal;

            stakingSchedule.lastClaim = block.timestamp;
            stakingSchedule.amountTotal = 0;
            stakingSchedule.initialized = false;
            stakingSchedule.tier = 0;

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < stakingSchedulesCountByBeneficiary);

        _balances[beneficiary] -= totalReleaseableAmount;
        _stakingSchedulesTotalAmount -= totalReleaseableAmount;
        tokenAddress.transfer(beneficiary, totalReleaseableAmount);

        emit UnstakedFLR(beneficiary, totalReleaseableAmount);
        
        return totalReleaseableAmount;
    }

    function getLastStakingScheduleForBeneficiary(address beneficiary)
        private // external
        view
        returns (StakingSchedule memory)
    {
        require(_holdersStakingCount[beneficiary] > 0,
            "TokenStakingFLR: INVALID Beneficiary Address! no staking schedule exists for that beneficiary");
        return _stakingSchedules[computeStakingScheduleIdForAddressAndIndex(beneficiary,_holdersStakingCount[beneficiary] - 1)];
    }

    function getCurrentTime() public view virtual returns (uint256) {
        return block.timestamp;
    }

    function symbol() external pure returns (string memory) {
        return "StakedFLR";
    } 

    function withdrawFromRewardReserves(uint256 amount)
        external
        nonReentrant
        onlyOwner
    {
        require(this.getRewardReservesBalance() >= amount,
            "TokenStakingFLR: not enough withdrawable funds in reward reserves");
        tokenAddress.transfer(owner(), amount);
    }

    function getStakingSchedulesCount() private
    // public 
    view returns (uint256) {
        return _stakingSchedulesIds.length;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() external view returns (uint256) {
        return _stakingSchedulesTotalAmount;
    }
}