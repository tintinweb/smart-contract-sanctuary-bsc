// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0 <0.9.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./NmxSupplier.sol";
import "./PausableByOwner.sol";


interface IERC20Permit is IERC20 {
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

interface StakingService {
    function unstake(uint128 amount) external;
    function unstakeTo(address to, uint128 amount) external;
    function stakeFrom(address owner, uint128 amount) external;
    function claimReward() external returns (uint256);
}


contract BoostingService is PausableByOwner {

    struct Staker {
        uint128 initialCompoundRate;
        uint128 initialBoostingRate;

        uint128 principalAmount;    
        uint128 boostingAmount;

        uint128 unlockedBoostingAmount;
        uint128 amount;

        uint128 shares;
        uint64 stakedAt;
    }

    struct BoostingRateCheckpoint {
        uint64  time;
        uint128 value;
    }

    address public constant NULL_ADDRESS = 0x21e0ac86EbfB57b107E4c00D142792469c7Dbe96;
    uint128 public constant RATE_DENOMINATOR = 10000; // 2000 - is 20%

    address public immutable nmx;

    address public launchpool;

    address public nmxSupplier;
    uint16 public boostingRate;
    uint16 public penaltyRate;
    uint16 public performanceFee;
    uint32 public duration;

    uint128 public totalShares;
    uint128 public totalStakedCompounded;

    uint128 public totalStaked;
    uint128 public totalBoostings;

    uint128 public historicalCompoundRate;
    uint128 public historicalBoostingRate;

    mapping(address => Staker) public stakers;
    BoostingRateCheckpoint[] boostingRateHistory;

    mapping(address => uint256) public nonces;
    bytes32 immutable public DOMAIN_SEPARATOR;

    string private constant UNSTAKE_TYPE =
        "Unstake(address owner,address spender,uint128 value,uint256 nonce,uint256 deadline)";
    bytes32 public constant UNSTAKE_TYPEHASH = keccak256(abi.encodePacked(UNSTAKE_TYPE));


    string private constant CLAIM_TYPE =
        "Claim(address owner,address spender,uint128 value,uint256 nonce,uint256 deadline)";
    bytes32 public constant CLAIM_TYPEHASH =
        keccak256(abi.encodePacked(CLAIM_TYPE));

    event Staked(address indexed owner, uint128 amount);
    event Unstaked(address indexed from, address indexed to, uint128 amount);

    constructor(
        address _nmx, 
        address _launchpool, 
        address _nmxSupplier, 
        uint16 _boostingRate, 
        uint16 _penaltyRate, 
        uint16 _performanceFee, 
        uint32 _duration
    ) {
        nmx = _nmx;
        launchpool = _launchpool;
        nmxSupplier = _nmxSupplier;
        boostingRate = _boostingRate;
        penaltyRate = _penaltyRate;
        performanceFee = _performanceFee;
        duration = _duration;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("BoostingService")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        IERC20(nmx).approve(launchpool, 2**256 - 1);
    }

    function changeParams(
        address _launchpool,
        address _nmxSupplier,
        uint16 _boostingRate,
        uint16 _penaltyRate, 
        uint32 _duration
    )
        external 
        onlyOwner
    {
        launchpool = _launchpool;
        nmxSupplier = _nmxSupplier;
        boostingRate = _boostingRate;
        penaltyRate = _penaltyRate;
        duration = _duration;

        IERC20(nmx).approve(launchpool, 2**256 - 1);
    }

    function stake(uint128 amount) external {
        _stake(amount, _msgSender());
    }

    function stakeWithPermit(uint128 amount, address owner, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(nmx).permit(
            owner,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );

        _stake(amount, owner);
    }

    function _stake(uint128 amount, address owner) internal whenNotPaused {
        bool transferred =
            IERC20(nmx).transferFrom(
                owner,
                address(this),
                uint256(amount)
            );
        require(transferred, "BoostingService: FAILED_TRANSFER");

        Staker storage staker = stakers[owner];
        _compoundAndRecalculateShares(staker, amount);
    } 

    function getAndUpdateStaker() external returns (Staker memory) {
        Staker storage staker = stakers[_msgSender()];
        _compoundAndRecalculateShares(staker, 0);     
        return staker;
    }

    function compound() external {
        Staker storage staker = stakers[_msgSender()];
        _compoundAndRecalculateShares(staker, 0);
    }

    function claimBoostingRewards() external {
        address owner = _msgSender();
        _claimReward(owner, owner);
    }

    function claimBoostingRewardsWithAuthorization(
        address owner,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        _verifySignature(
            CLAIM_TYPEHASH,
            owner,
            _msgSender(),
            0,
            deadline,
            v,
            r,
            s
        );

        _claimReward(owner, _msgSender());
    }

    function _claimReward(address owner, address spender) internal {
        Staker storage staker = stakers[owner];
        _compoundAndRecalculateShares(staker, 0);

        uint128 _stakerBoosting = staker.unlockedBoostingAmount;
        require(_stakerBoosting > 0, "BoostingService: NO BOOSTING REWARDS");

        staker.unlockedBoostingAmount = 0;    
        totalBoostings -= _stakerBoosting;

        bool transferred = IERC20(nmx).transfer(spender, _stakerBoosting);
        require(transferred, "BoostingService: FAILED_TRANSFER");
    }

    function unstake(uint128 amount) external {
        _unstake(_msgSender(), _msgSender(), amount);
    }

    function unstakeWithAuthorization(
        address owner,
        uint128 amount,
        uint128 signedAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(amount <= signedAmount, "BoostingService: INVALID_AMOUNT");

        address spender = _msgSender();

        _verifySignature(
            UNSTAKE_TYPEHASH,
            owner,
            spender,
            signedAmount,
            deadline,
            v,
            r,
            s
        );

        _unstake(owner, spender, amount);
    }

    function unstakeSharesWithAuthorization(
        address owner,
        uint128 shares,
        uint128 signedShares,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(shares <= signedShares, "BoostingService: INVALID_AMOUNT");

        address spender = _msgSender();

        _verifySignature(
            UNSTAKE_TYPEHASH,
            owner,
            spender,
            0,
            deadline,
            v,
            r,
            s
        );

        _unstakeShares(owner, spender, shares);
    }

    function unstakeShares(uint128 shares) external {
        _unstakeShares(_msgSender(), _msgSender(), shares);
    }

    function _unstakeShares(address owner, address spender, uint128 shares) internal {
        Staker storage staker = stakers[owner];
        _compoundAndRecalculateShares(staker, 0);

        require(shares <= staker.shares, "BoostingService: INVALID_AMOUNT");

        uint64 _stakedAt  = staker.stakedAt;
        uint64 stakingEnd = _stakedAt + duration;

        // 2 cases - new user or lock is expired
        if (_stakedAt > 0 && stakingEnd > block.timestamp) {   
            // unstake with loss
            _unstakeSharesLocked(staker, owner, spender, shares);
        } else {
            // unstake without loss 
            _unstakeSharesUnlocked(staker, owner, spender, shares);
        }
    }

    function _unstakeSharesLocked(Staker storage staker, address owner, address spender, uint128 unstakedShares) internal {
        uint128 _stakerShares = staker.shares;
        uint128 _stakerPrincipalAmount = staker.principalAmount;

        require(unstakedShares <= _stakerShares, "BoostingService: NOT_ENOUGH_BALANCE");
        require(_stakerPrincipalAmount > 0, "BoostingService: NOT_ENOUGH_BALANCE");

        uint128 _stakerAmount = staker.amount;        

        uint192 ratio  = (uint192(_stakerShares) << 64) / unstakedShares;
        uint128 principalDiff  = uint128((uint192(_stakerPrincipalAmount) << 64) / ratio);
        uint128 amountDiff     = uint128((uint192(_stakerAmount) << 64) / ratio);
        uint128 boostingDiff   = uint128((uint192(staker.boostingAmount) << 64) / ratio);


        staker.principalAmount -= principalDiff;
        staker.amount -= amountDiff;
        staker.boostingAmount -= boostingDiff;
        staker.shares -= unstakedShares;

        if (unstakedShares == _stakerShares) {
            staker.stakedAt = 0;
        }

        totalBoostings -= boostingDiff;
        totalStakedCompounded -= amountDiff;
        totalStaked -= principalDiff;
        totalShares -= unstakedShares;


        uint128 penaltyAmount = (principalDiff * penaltyRate) / RATE_DENOMINATOR;
        uint128 withdrawAmount = principalDiff - penaltyAmount;
        // amountDiff already includes unstakeAmount so no need to count penaltyAmount
        uint128 totalBurnedAmount = (amountDiff - withdrawAmount) + boostingDiff;


        StakingService(launchpool).unstake(amountDiff);
        _burn(totalBurnedAmount);
        bool transferred = IERC20(nmx).transfer(spender, withdrawAmount);
        require(transferred, "BoostingService: FAILED_TRANSFER");

        emit Unstaked(owner, spender, principalDiff);
    }

    function _unstakeSharesUnlocked(Staker storage staker, address owner, address spender, uint128 unstakedShares) internal {
        require(unstakedShares <= staker.shares, "BoostingService: NOT_ENOUGH_BALANCE");

        uint128 unstakeAmount = uint128((uint256(totalStakedCompounded) * unstakedShares) / totalShares);
        uint128 fee = unstakeAmount * performanceFee / RATE_DENOMINATOR;

        staker.amount -= unstakeAmount;
        staker.principalAmount -= unstakeAmount;
        staker.shares -= unstakedShares;

        // TODO: test
        totalStakedCompounded -= unstakeAmount;
        totalStaked -= unstakeAmount;
        totalShares -= unstakedShares;

        uint128 unstakeAmountWithFee = unstakeAmount - fee;
        StakingService(launchpool).unstakeTo(spender, unstakeAmountWithFee);
        StakingService(launchpool).unstakeTo(NULL_ADDRESS, fee);
        emit Unstaked(owner, spender, unstakeAmount);
    }

    function _unstake(address owner, address spender, uint128 amount) internal {
        Staker storage staker = stakers[owner];
        _compoundAndRecalculateShares(staker, 0);

        uint64 _stakedAt  = staker.stakedAt;
        uint64 stakingEnd = _stakedAt + duration;

        // 2 cases - new user or lock is expired
        if (_stakedAt > 0 && stakingEnd > block.timestamp) {   
            // unstake with loss
            _unstakeLocked(staker, owner, spender, amount);
        } else {
            // unstake without loss 
            _unstakeUnlocked(staker, owner, spender, amount);
        }
    }


    function _unstakeLocked(Staker storage staker, address owner, address spender, uint128 unstakeAmount) internal {
        uint128 _stakerPrincipalAmount = staker.principalAmount;
        require(unstakeAmount <= _stakerPrincipalAmount, "BoostingService: NOT_ENOUGH_BALANCE");
        require(_stakerPrincipalAmount > 0, "BoostingService: NOT_ENOUGH_BALANCE");

        uint128 _stakerAmount = staker.amount;        

        uint128 amountDiff; 
        uint128 boostingDiff;
        uint128 sharesToRemove;
        
        // dust protection
        if (unstakeAmount == _stakerPrincipalAmount) {
            amountDiff     = _stakerAmount;
            boostingDiff   = staker.boostingAmount; 
            sharesToRemove = staker.shares;
            staker.stakedAt = 0;
        } else {
            uint192 ratio  = (uint192(_stakerPrincipalAmount) << 64) / unstakeAmount;
            amountDiff     = uint128((uint192(_stakerAmount) << 64) / ratio);
            boostingDiff   = uint128((uint192(staker.boostingAmount) << 64) / ratio);
            sharesToRemove = uint128((uint256(amountDiff) * totalShares) / totalStakedCompounded);
        }

        staker.principalAmount -= unstakeAmount;
        staker.amount -= amountDiff;
        staker.boostingAmount -= boostingDiff;
        staker.shares -= sharesToRemove;

        totalBoostings -= boostingDiff;
        totalStakedCompounded -= amountDiff;
        totalStaked -= unstakeAmount;
        totalShares -= sharesToRemove;


        uint128 penaltyAmount = (unstakeAmount * penaltyRate) / RATE_DENOMINATOR;
        uint128 withdrawAmount = unstakeAmount - penaltyAmount;
        // amountDiff already includes unstakeAmount so no need to count penaltyAmount
        uint128 totalBurnedAmount = (amountDiff - withdrawAmount) + boostingDiff;


        StakingService(launchpool).unstake(amountDiff);
        _burn(totalBurnedAmount);
        bool transferred = IERC20(nmx).transfer(spender, withdrawAmount);
        require(transferred, "BoostingService: FAILED_TRANSFER");

        emit Unstaked(owner, spender, unstakeAmount);
    }

    function _unstakeUnlocked(Staker storage staker, address owner, address spender, uint128 unstakeAmount) internal {
        uint128 _stakerAmount = staker.amount;
        require(unstakeAmount <= _stakerAmount, "BoostingService: NOT_ENOUGH_BALANCE");

        uint128 sharesToRemove;

        // because each share will represent multiple WEIs, when the user will unstake (even entire stake amount)
        // some shares dust is always going to left. So in the case if user wants to unstake everything
        // we just zeroing their shares
        if (unstakeAmount == _stakerAmount) {
            sharesToRemove = staker.shares;
        } else {
            sharesToRemove = uint128((uint256(unstakeAmount) * totalShares) / totalStakedCompounded);
        }
                 
        // if user is unlocked consider his entire amount as principal - he can withdraw any fraction of it
        // staker.principalAmount = _stakerAmount;

        uint128 fee = unstakeAmount * performanceFee / RATE_DENOMINATOR;

        staker.amount -= unstakeAmount;
        staker.principalAmount -= unstakeAmount;
        staker.shares -= sharesToRemove;

        // TODO: test
        totalStakedCompounded -= unstakeAmount;
        totalStaked -= unstakeAmount;
        totalShares -= sharesToRemove;

        uint128 unstakeAmountWithFee = unstakeAmount - fee;
        StakingService(launchpool).unstakeTo(spender, unstakeAmountWithFee);
        StakingService(launchpool).unstakeTo(NULL_ADDRESS, fee);
        emit Unstaked(owner, spender, unstakeAmount);
    }
    

    function _compoundAndRecalculateShares(Staker storage staker, uint128 amount) internal {
        uint128 compoundRewards = _receiveCompound();
        _receiveBoosting(compoundRewards);
        
        totalStakedCompounded += compoundRewards;
        
        _materializeShares(staker);

        _stakeShares(staker, amount);

        uint128 compoundAmount = compoundRewards + amount;
        StakingService(launchpool).stakeFrom(address(this), compoundAmount);
    }


    function _receiveCompound() internal returns (uint128 claimedReward) {
        uint128 _totalShares = totalShares;
        address _launchpool = launchpool;

        claimedReward = uint128(StakingService(_launchpool).claimReward());
        
        if (_totalShares > 0) {
            historicalCompoundRate += (claimedReward << 40) / totalShares;
        } else {
            _burn(claimedReward);
            claimedReward = 0;
        }
    }

    function _receiveBoosting(uint128 compoundRewards) internal returns (uint128 boostingRewards) {
        uint128 _totalShares = totalShares;

        boostingRewards = uint128(NmxSupplier(nmxSupplier).supplyNmx(uint40(block.timestamp)));
        uint128 expectedBoostings = (compoundRewards * boostingRate) / RATE_DENOMINATOR;

        // theoretically we can receive less than expected
        if (boostingRewards > expectedBoostings) {
            // todo: test
            _burn(boostingRewards - expectedBoostings);
            boostingRewards = expectedBoostings;
        }   

        if (_totalShares > 0) { 
            historicalBoostingRate += (boostingRewards << 40) / totalShares;
            _recordBoostingRateHistory(historicalBoostingRate);
            totalBoostings += boostingRewards;
        } else {
            _burn(boostingRewards);
        }
    }


    function _materializeShares(Staker storage staker) internal returns(uint128 compoundAmount, uint128 boostingAmount) {
        uint128 _stakerShares = staker.shares;
        uint128 _stakerInitialBoostingRate = staker.initialBoostingRate;

        compoundAmount = ((historicalCompoundRate - staker.initialCompoundRate) * _stakerShares) >> 40;
        boostingAmount = ((historicalBoostingRate - _stakerInitialBoostingRate) * _stakerShares) >> 40;

        uint64 _stakedAt  = staker.stakedAt;
        uint64 stakingEnd = _stakedAt + duration;
        bool unlocked;

        // 2 cases - new user or lock is expired
        if (stakingEnd < block.timestamp) {
            // lock is expired
            if (_stakedAt > 0) {
                // one time action: materialize boostings up to the staking end and burn leftovers
                uint128 boostingRateAtCheckpoint = _findNearestLowestBoostingRate(stakingEnd);
                uint128 boostingAmountAtCheckpoint = ((boostingRateAtCheckpoint - _stakerInitialBoostingRate) * _stakerShares) >> 40;
                uint128 leftOvers = boostingAmount - boostingAmountAtCheckpoint;
                boostingAmount = boostingAmountAtCheckpoint;
                _burn(leftOvers);
                unlocked = true;
                staker.unlockedBoostingAmount += (staker.boostingAmount + boostingAmount);
                staker.boostingAmount = 0;
                staker.stakedAt = 0; // will be overwritten in _stakeShares() if user is staking again             
            } else if (boostingAmount > 0) {
                // if staker.stakedAt == 0 it's either a new user or an unloked user
                // if boostingAmount > 0 then it's a user that was previously unlocked and their's lefover boostings were burned
                // and all their due boostings were materialized, since unlocked users do not receive the boost, we now burn everything
                _burn(boostingAmount);
            }
        } else {
            staker.boostingAmount += boostingAmount;
        }
      
        staker.amount += compoundAmount;

        if (unlocked) {
            uint128 _principal = staker.principalAmount;
            uint128 _amount = staker.amount;
            uint128 diff = _amount  - _principal;
            // materialize compounded rewards
            staker.principalAmount = _amount;
            totalStaked += diff;
            emit Staked(_msgSender(), diff);
        }

        staker.initialCompoundRate = historicalCompoundRate;
        staker.initialBoostingRate = historicalBoostingRate;
    }

    function _stakeShares(Staker storage staker, uint128 amount) internal {
        uint128 currentShares;

        uint128 stakerAddedAmount = amount;

        if (totalShares != 0) {
            currentShares = uint128((uint256(stakerAddedAmount) * totalShares) / totalStakedCompounded);
        } else {
            currentShares = amount;
        }
        
        staker.principalAmount += amount;
        staker.amount += amount;
        staker.shares += currentShares;
        if (amount > 0) {
            staker.stakedAt = uint64(block.timestamp);
            emit Staked(_msgSender(), amount);
        } 

        totalShares += currentShares;
        totalStakedCompounded += amount;
        totalStaked += amount;

    }

    function _burn(uint128 amount) internal {
        bool transferred = IERC20(nmx).transfer(NULL_ADDRESS, amount);
        require(transferred, "BoostingService: BURN_TRANSFER_FAILED");  
    }

    function _recordBoostingRateHistory(uint128 _boostingRate) internal {
        BoostingRateCheckpoint storage checkpoint = boostingRateHistory.push();
        checkpoint.time = uint64(block.timestamp);
        checkpoint.value = _boostingRate;        
    }

    function _findNearestLowestBoostingRate(uint64 timestamp) internal view returns (uint128) {
        uint256 length = boostingRateHistory.length;
        if (length == 0) {
            return 0;
        }

        // If the requested time is equal to or after the time of the latest registered value, return latest value
        uint256 lastIndex = length - 1;
        if (timestamp >= boostingRateHistory[lastIndex].time) {
            return boostingRateHistory[lastIndex].value;
        }

        // If the requested time is previous to the first registered value, return ONE as if there was no autocompounding 
        if (timestamp < boostingRateHistory[0].time) {
            return 0;
        }

        // Execute a binary search between the checkpointed times of the history
        uint256 low = 0;
        uint256 high = lastIndex;

        while (high > low) {
            // for this to overflow array size should be ~2^255
            uint256 mid = (high + low + 1) / 2;
            BoostingRateCheckpoint storage checkpoint = boostingRateHistory[mid];
            uint64 midTime = checkpoint.time;

            if (timestamp > midTime) {
                low = mid;
            } else if (timestamp < midTime) {
                // no overflow: high > low >= 0 => high >= 1 => mid >= 1
                high = mid - 1;
            } else {
                return checkpoint.value;
            }
        }

        return boostingRateHistory[low].value;
    }

    function _verifySignature(
        bytes32 typehash,
        address owner,
        address spender,
        uint128 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        require(deadline >= block.timestamp, "BoostingService: EXPIRED");
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            typehash,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "BoostingService: INVALID_SIGNATURE"
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @dev Contract module which is essentially like Pausable but only owner is allowed to change the state.
 */
abstract contract PausableByOwner is Pausable, Ownable {
    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external virtual onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external virtual onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

/**
 * @dev Interface to got minted Nmx.
 */
interface NmxSupplier {
    /**
      @dev if caller is owner of any mint pool it will be supplied with Nmx based on the schedule and time passed from the moment
      when the method was invoked by the same mint pool owner last time
      @param maxTime the upper limit of the time to make calculations
    */
    function supplyNmx(uint40 maxTime) external returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
}