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
    IERC20 public tokenAddress;

    uint256 private _tier1LockPeriod = 0;
    uint256 private _tier2LockPeriod = 5259486; // 2 months
    uint256 private _tier3LockPeriod = 10518972; // 4 months
    uint256 private _tier4LockPeriod = 15778458; // 6 months
    uint256 private _tier1APY = 60;
    uint256 private _tier2APY = 100;
    uint256 private _tier3APY = 120;
    uint256 private _tier4APY = 145;
    uint256 private _tier1AdditionalTokensPercentage = 0;
    uint256 private _tier2AdditionalTokensPercentage = 20;
    uint256 private _tier3AdditionalTokensPercentage = 40;
    uint256 private _tier4AdditionalTokensPercentage = 60;
    uint256 private _tier1MinAmount = (1000 * 10**_tokenDecimals);
    uint256 private _tier1MaxAmount = (200000000 * 10**_tokenDecimals);
    uint256 private _tier2MinAmount = (200000000 * 10**_tokenDecimals);
    uint256 private _tier2MaxAmount = (400000000 * 10**_tokenDecimals);
    uint256 private _tier3MinAmount = (400000000 * 10**_tokenDecimals);
    uint256 private _tier3MaxAmount = (600000000 * 10**_tokenDecimals);
    uint256 private _tier4MinAmount = (600000000 * 10**_tokenDecimals);
    uint256 private _tier4MaxAmount = (500000000000 * 10**_tokenDecimals);

    mapping(address => uint256) private _balances;
    mapping(bytes32 => StakingSchedule) private _stakingSchedules;
    mapping(address => uint256) private _holdersStakingCount;
    bytes32[] private _stakingSchedulesIds;
    uint256 private _stakingSchedulesTotalAmount;
    uint256 private _rewardFrequencyTime = 86400;
    uint256 private _yearTime = 31556926;

    event StakedFLR(address from, uint256 amount, uint256 tierNumber);
    event RewardsClaimed(address beneficiary, uint256 amount);
    event UnstakedFLR(address from, uint256 amount);

    modifier onlyIfBeneficiaryExists(address beneficiary) {
        require(
            _holdersStakingCount[beneficiary] > 0,
            "TokenStakingFLR: INVALID Beneficiary Address! no staking schedule exists for that beneficiary"
        );
        _;
    }

    constructor() {
        tokenAddress = IERC20(address(0));
    }

    function setAllTiersLockPeriod(
        uint256 tier1LockPeriod,
        uint256 tier2LockPeriod,
        uint256 tier3LockPeriod,
        uint256 tier4LockPeriod
    ) external onlyOwner returns (bool) {
        _tier1LockPeriod = tier1LockPeriod;
        _tier2LockPeriod = tier2LockPeriod;
        _tier3LockPeriod = tier3LockPeriod;
        _tier4LockPeriod = tier4LockPeriod;

        return true;
    }

    function getAllTiersLockPeriod()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _tier1LockPeriod,
            _tier2LockPeriod,
            _tier3LockPeriod,
            _tier4LockPeriod
        );
    }

    function setAllTiersAPY(
        uint256 tier1APY,
        uint256 tier2APY,
        uint256 tier3APY,
        uint256 tier4APY
    ) external onlyOwner returns (bool) {
        _tier1APY = tier1APY;
        _tier2APY = tier2APY;
        _tier3APY = tier3APY;
        _tier4APY = tier4APY;

        return true;
    }

    function getAllTiersAPY()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (_tier1APY, _tier2APY, _tier3APY, _tier4APY);
    }

    function setAllTiersAdditionalTokensPercentage(
        uint256 tier1AdditionalTokensPercentage,
        uint256 tier2AdditionalTokensPercentage,
        uint256 tier3AdditionalTokensPercentage,
        uint256 tier4AdditionalTokensPercentage
    ) external onlyOwner returns (bool) {
        _tier1AdditionalTokensPercentage = tier1AdditionalTokensPercentage;
        _tier2AdditionalTokensPercentage = tier2AdditionalTokensPercentage;
        _tier3AdditionalTokensPercentage = tier3AdditionalTokensPercentage;
        _tier4AdditionalTokensPercentage = tier4AdditionalTokensPercentage;

        return true;
    }

    function getAllTiersAdditionalTokensPercentage()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _tier1AdditionalTokensPercentage,
            _tier2AdditionalTokensPercentage,
            _tier3AdditionalTokensPercentage,
            _tier4AdditionalTokensPercentage
        );
    }

    function setAllTiersMinMax(
        uint256 tier1MinAmount,
        uint256 tier1MaxAmount,
        uint256 tier2MinAmount,
        uint256 tier2MaxAmount,
        uint256 tier3MinAmount,
        uint256 tier3MaxAmount,
        uint256 tier4MinAmount,
        uint256 tier4MaxAmount
    ) external onlyOwner returns (bool) {
        _tier1MinAmount = tier1MinAmount;
        _tier1MaxAmount = tier1MaxAmount;
        _tier2MinAmount = tier2MinAmount;
        _tier2MaxAmount = tier2MaxAmount;
        _tier3MinAmount = tier3MinAmount;
        _tier3MaxAmount = tier3MaxAmount;
        _tier4MinAmount = tier4MinAmount;
        _tier4MaxAmount = tier4MaxAmount;

        return true;
    }

    function getAllTiersMinMax()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _tier1MinAmount,
            _tier1MaxAmount,
            _tier2MinAmount,
            _tier2MaxAmount,
            _tier3MinAmount,
            _tier3MaxAmount,
            _tier4MinAmount,
            _tier4MaxAmount
        );
    }

    function setRewardFrequencyTime(uint256 rewardFrequencyTime)
        external
        onlyOwner
        returns (bool)
    {
        _rewardFrequencyTime = rewardFrequencyTime;

        return true;
    }

    function getRewardFrequencyTime() external view returns (uint256) {
        return _rewardFrequencyTime;
    }

    function getAdditionalPercentageOfAccount(address beneficiary)
        external
        view
        returns (uint256)
    {
        uint256 stakingSchedulesCountByBeneficiary = getStakingSchedulesCountByBeneficiary(
                beneficiary
            );

        StakingSchedule storage stakingSchedule;
        uint256 biggestStakingTier = 0;
        uint256 i = 1;
        do {
            stakingSchedule = _stakingSchedules[
                computeStakingScheduleIdForAddressAndIndex(beneficiary, i)
            ];

            if (stakingSchedule.tier > biggestStakingTier) {
                biggestStakingTier = stakingSchedule.tier;
            }

            i++;
        } while (i < stakingSchedulesCountByBeneficiary);

        if (biggestStakingTier == 1) {
            return _tier1AdditionalTokensPercentage;
        }
        if (biggestStakingTier == 2) {
            return _tier2AdditionalTokensPercentage;
        }
        if (biggestStakingTier == 3) {
            return _tier3AdditionalTokensPercentage;
        }
        if (biggestStakingTier == 4) {
            return _tier4AdditionalTokensPercentage;
        }

        return 0;
    }

    function getStakingSchedulesCountByBeneficiary(address _beneficiary)
        private
        view
        returns (uint256)
    {
        return _holdersStakingCount[_beneficiary];
    }

    function getStakingIdAtIndex(uint256 index) private view returns (bytes32) {
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
        external
        view
        onlyIfBeneficiaryExists(beneficiary)
        returns (StakingSchedule memory)
    {
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
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function stakeTokens(uint256 amount, uint256 tierNumber) external {
        address from = _msgSender();
        _stakeTokens(from, amount, tierNumber);

        emit StakedFLR(from, amount, tierNumber);
    }

    function _stakeTokens(
        address from,
        uint256 amount,
        uint256 tier
    ) private {
        require(
            (tier >= 1) && (tier <= 4),
            "TokenStakingFLR: invalid tier, choose 1-4"
        );

        if (tier == 1) {
            require(
                (amount >= _tier1MinAmount && amount < _tier1MaxAmount),
                "TokenStakingFLR: Tier 1 only allows staking >=_tier1MinAmount and <_tier1MaxAmount FLR tokens"
            );
        }
        if (tier == 2) {
            require(
                (amount >= _tier2MinAmount && amount < _tier2MaxAmount),
                "TokenStakingFLR: Tier 2 only allows staking >=_tier2MinAmount and <_tier2MaxAmount FLR tokens"
            );
        }
        if (tier == 3) {
            require(
                (amount >= _tier3MinAmount && amount < _tier3MaxAmount),
                "TokenStakingFLR: Tier 3 only allows staking >=_tier3MinAmount and <_tier3MaxAmount FLR tokens"
            );
        }
        if (tier == 4) {
            require(
                (amount >= _tier4MinAmount && amount < _tier4MaxAmount),
                "TokenStakingFLR: Tier 3 only allows staking >=_tier4MinAmount and <_tier4MaxAmount FLR tokens"
            );
        }

        tokenAddress.transferFrom(from, address(this), amount);
        _createStakingSchedule(from, tier, amount);
    }

    function _createStakingSchedule(
        address _beneficiary,
        uint256 _tier,
        uint256 _amount
    ) private {
        bytes32 stakingScheduleId = computeNextStakingScheduleIdForHolder(
            _beneficiary
        );

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
        uint256 currentStakingCount = getStakingSchedulesCountByBeneficiary(
            _beneficiary
        );
        _holdersStakingCount[_beneficiary] = currentStakingCount + 1;
    }

    function getRewardReservesBalance() external view returns (uint256) {
        return _getRewardReservesBalance();
    }

    function _getRewardReservesBalance() private view returns (uint256) {
        return
            tokenAddress.balanceOf(address(this)) -
            _stakingSchedulesTotalAmount;
    }

    function computeNextStakingScheduleIdForHolder(address holder)
        private
        view
        returns (bytes32)
    {
        return
            computeStakingScheduleIdForAddressAndIndex(
                holder,
                _holdersStakingCount[holder]
            );
    }

    function _computeReleasableRewardAmount(
        StakingSchedule memory stakingSchedule
    ) private view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 timeDifference = currentTime - stakingSchedule.lastClaim;

        uint256 cyclesToRelease = timeDifference / _rewardFrequencyTime;

        uint256 frequencyInYear = _yearTime / _rewardFrequencyTime;

        uint256 amount = stakingSchedule.amountTotal;
        uint256 tier = stakingSchedule.tier;
        uint256 cycleReleaseableAmount;
        if (tier == 1) {
            cycleReleaseableAmount =
                ((amount * _tier1APY) / 1000) /
                frequencyInYear;
        }
        if (tier == 2) {
            cycleReleaseableAmount =
                ((amount * _tier2APY) / 1000) /
                frequencyInYear;
        }
        if (tier == 3) {
            cycleReleaseableAmount =
                ((amount * _tier3APY) / 1000) /
                frequencyInYear;
        }
        if (tier == 4) {
            cycleReleaseableAmount =
                ((amount * _tier4APY) / 1000) /
                frequencyInYear;
        }

        return (cycleReleaseableAmount * cyclesToRelease);
    }

    function claimRewardsFromAllMyStakings()
        external
        nonReentrant
        onlyIfBeneficiaryExists(msg.sender)
    {
        address beneficiary = _msgSender();
        require(
            balanceOf(beneficiary) > 0,
            "TokenStakingFLR: all tokens already unstaked"
        );
        uint256 stakingSchedulesCountByBeneficiary = getStakingSchedulesCountByBeneficiary(
                beneficiary
            );

        StakingSchedule storage stakingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            stakingSchedule = _stakingSchedules[
                computeStakingScheduleIdForAddressAndIndex(beneficiary, i)
            ];
            uint256 releaseableAmount = _computeReleasableRewardAmount(
                stakingSchedule
            );
            stakingSchedule.lastClaim = block.timestamp;
            totalReleaseableAmount += releaseableAmount;

            i++;
        } while (i < stakingSchedulesCountByBeneficiary);

        require(
            totalReleaseableAmount > 0,
            "TokenStakingFLR: no new claimable rewards, check back tomorrow"
        );
        require(
            totalReleaseableAmount <= _getRewardReservesBalance(),
            "TokenStakingFLR: not enough reward funds available"
        );
        tokenAddress.transfer(beneficiary, totalReleaseableAmount);

        emit RewardsClaimed(beneficiary, totalReleaseableAmount);
    }

    function unstakeTokens()
        external
        nonReentrant
        onlyIfBeneficiaryExists(msg.sender)
    {
        address from = _msgSender();
        uint256 amount = _unstakeTokens(from);

        emit UnstakedFLR(from, amount);
    }

    function _unstakeTokens(address beneficiary) private returns (uint256) {
        require(
            balanceOf(beneficiary) > 0,
            "TokenStakingFLR: all tokens already unstaked"
        );
        uint256 stakingSchedulesCountByBeneficiary = getStakingSchedulesCountByBeneficiary(
                beneficiary
            );

        StakingSchedule storage stakingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            stakingSchedule = _stakingSchedules[
                computeStakingScheduleIdForAddressAndIndex(beneficiary, i)
            ];

            bool initialized = stakingSchedule.initialized;
            uint256 tier = stakingSchedule.tier;
            uint256 stakingStart = stakingSchedule.start;
            uint256 currentTime = block.timestamp;

            if (!initialized) {
                i++;
                continue;
            }
            if (
                tier == 1 && (currentTime < (stakingStart + _tier1LockPeriod))
            ) {
                i++;
                continue;
            }
            if (
                tier == 2 && (currentTime < (stakingStart + _tier2LockPeriod))
            ) {
                i++;
                continue;
            }
            if (
                tier == 3 && (currentTime < (stakingStart + _tier3LockPeriod))
            ) {
                i++;
                continue;
            }
            if (
                tier == 4 && (currentTime < (stakingStart + _tier4LockPeriod))
            ) {
                i++;
                continue;
            }

            uint256 releaseableAmount = stakingSchedule.amountTotal;

            stakingSchedule.lastClaim = block.timestamp;
            stakingSchedule.amountTotal = 0;
            stakingSchedule.initialized = false;
            stakingSchedule.tier = 0;
            totalReleaseableAmount += releaseableAmount;

            i++;
        } while (i < stakingSchedulesCountByBeneficiary);

        require(
            totalReleaseableAmount > 0,
            "TokenStakingFLR: tokens are locked, wait till the staking period end"
        );
        _balances[beneficiary] -= totalReleaseableAmount;
        _stakingSchedulesTotalAmount -= totalReleaseableAmount;
        tokenAddress.transfer(beneficiary, totalReleaseableAmount);

        return totalReleaseableAmount;
    }

    function getLastStakingScheduleForBeneficiary(address beneficiary)
        private
        view
        returns (StakingSchedule memory)
    {
        require(
            _holdersStakingCount[beneficiary] > 0,
            "TokenStakingFLR: INVALID Beneficiary Address! no staking schedule exists for that beneficiary"
        );

        return
            _stakingSchedules[
                computeStakingScheduleIdForAddressAndIndex(
                    beneficiary,
                    _holdersStakingCount[beneficiary] - 1
                )
            ];
    }

    function symbol() external pure returns (string memory) {
        return "StakedFLR";
    }

    function withdrawFromRewardReserves(uint256 amount)
        external
        nonReentrant
        onlyOwner
    {
        require(
            _getRewardReservesBalance() >= amount,
            "TokenStakingFLR: not enough withdrawable funds in reward reserves"
        );
        tokenAddress.transfer(owner(), amount);
    }

    function getStakingSchedulesCount() private view returns (uint256) {
        return _stakingSchedulesIds.length;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function getStakingSchedule(bytes32 stakingScheduleId)
        private
        view
        returns (StakingSchedule memory)
    {
        StakingSchedule storage stakingSchedule = _stakingSchedules[
            stakingScheduleId
        ];

        return stakingSchedule;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() external view returns (uint256) {
        return _stakingSchedulesTotalAmount;
    }

    function changeTokenContractAddress(address newContractAddress)
        external
        onlyOwner
        returns (bool)
    {
        require(newContractAddress != address(0x0));
        tokenAddress = IERC20(newContractAddress);

        return true;
    }
}