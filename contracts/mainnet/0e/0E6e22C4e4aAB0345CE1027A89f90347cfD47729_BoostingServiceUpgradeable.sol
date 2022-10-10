// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0 <0.9.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "abdk-libraries-solidity/ABDKMath64x64.sol";

import "./interfaces/IERC20Permit.sol";
import "./interfaces/INmxSupplier.sol";
import "./interfaces/IStakingService.sol";

import "./PausableByOwnerUpgradeable.sol";
import "./RecoverableByOwnerUpgradeable.sol";

contract BoostingServiceUpgradeable is PausableByOwnerUpgradeable, RecoverableByOwnerUpgradeable {
    using ABDKMath64x64 for int128;

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

    address public constant  NULL_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint16  public constant  RATE_DENOMINATOR = 10000; // 2000 - is 20%
    uint16  public constant  MAX_PENALTY_RATE = 2500; // 25%
    uint16  public constant  MAX_PERFORMANCE_FEE = 500; // 5%
    address public immutable NMX;
    address public immutable LAUNCHPOOL;
    uint32  public immutable DURATION;
    /// @dev time adjusting coefficients
    uint72  public immutable K1;
    uint72  public immutable K2; 

    bytes32 public domain_separator;

    address public nmxSupplier;
    uint16  public boostingRate;
    uint16  public penaltyRate;
    uint16  public performanceFee;

    uint128 public totalShares;
    uint128 public totalStakedCompounded;

    uint128 public totalStaked;
    uint128 public totalBoostings;

    uint128 public historicalCompoundRate;
    uint128 public historicalBoostingRate;

    mapping(address => Staker) public stakers;

    BoostingRateCheckpoint[] boostingRateHistory;

    mapping(address => uint256) public nonces;

    string private constant UNSTAKE_TYPE =
        "Unstake(address owner,address spender,uint128 value,uint256 nonce,uint256 deadline)";
    bytes32 public constant UNSTAKE_TYPEHASH = keccak256(abi.encodePacked(UNSTAKE_TYPE));


    string private constant CLAIM_TYPE =
        "Claim(address owner,address spender,uint128 value,uint256 nonce,uint256 deadline)";
    bytes32 public constant CLAIM_TYPEHASH =
        keccak256(abi.encodePacked(CLAIM_TYPE));

    event Staked(address indexed owner, uint128 amount);
    event Unstaked(address indexed from, address indexed to, uint128 amount);
    event BoostingAccrued(address indexed owner, uint128 amount);
    event BoostingBurnt(address indexed owner, uint128 amount);
    event BoostingUnlocked(address indexed owner, uint128 amount);
    event BoostingClaimed(address indexed owner, address indexed spender, uint128 amount);
    event CompoundAccrued(address indexed owner, uint128 amount);
    event CompoundBurnt(address indexed owner, uint128 amount);
    event CompoundUnlocked(address indexed owner, uint128 amount);
    event PenaltyBurnt(address indexed owner, uint128 amount);
    event ParamsChanged(address nmxSupplier, uint16 boostingRate, uint16 penaltyRate, uint16 performanceFee);

    constructor(
        address _nmx, 
        address _launchpool, 
        uint32 _duration,
        uint72 _k1,
        uint72 _k2
    ) {
        NMX = _nmx;
        LAUNCHPOOL = _launchpool;
        DURATION = _duration;
        K1 = _k1;
        K2 = _k2;
    }

    function initialize(
        address _nmxSupplier, 
        uint16 _boostingRate, 
        uint16 _penaltyRate,
        uint16 _performanceFee
    ) public initializer {
        require(_penaltyRate <= MAX_PENALTY_RATE, 'BoostingService: INVALID_PENALTY_RATE');
        require(_performanceFee <= MAX_PERFORMANCE_FEE, 'BoostingService: INVALID_PERFORMANCE_FEE');

        __PausableByOwner_init();

        _changeParams(_nmxSupplier, _boostingRate, _penaltyRate, _performanceFee);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        domain_separator = keccak256(
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

        IERC20(NMX).approve(LAUNCHPOOL, 2**256 - 1);
    }

    function changeParams(
        address _nmxSupplier,
        uint16 _boostingRate,
        uint16 _penaltyRate,
        uint16 _performanceFee
    )
        external 
        onlyOwner
    {
        _changeParams(_nmxSupplier, _boostingRate, _penaltyRate, _performanceFee);
    }

    function _changeParams(
        address _nmxSupplier,
        uint16 _boostingRate,
        uint16 _penaltyRate,
        uint16 _performanceFee
    )
        private
    {
        require(_penaltyRate <= MAX_PENALTY_RATE, 'BoostingService: INVALID_PENALTY_RATE');
        require(_performanceFee <= MAX_PERFORMANCE_FEE, 'BoostingService: INVALID_PERFORMANCE_FEE');

        nmxSupplier = _nmxSupplier;
        boostingRate = _boostingRate;
        penaltyRate = _penaltyRate;
        performanceFee = _performanceFee;
        emit ParamsChanged(_nmxSupplier, _boostingRate, _penaltyRate, _performanceFee);
    }

    function stake(uint128 amount) external {
        _stake(amount, _msgSender(), _msgSender());
    }

    function stakeWithPermit(uint128 amount, address owner, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(NMX).permit(
            owner,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );

        _stake(amount, owner, owner);
    }

    function stakeFor(address owner, uint128 amount) external returns (uint128) {
        return _stake(amount, owner, _msgSender());
    }

    function _stake(uint128 amount, address owner, address sourceOfFunds) private whenNotPaused returns (uint128) {
        bool transferred =
            IERC20(NMX).transferFrom(
                sourceOfFunds,
                address(this),
                uint256(amount)
            );
        require(transferred, "BoostingService: FAILED_TRANSFER");

        Staker storage staker = stakers[owner];
        return _compoundAndRecalculateShares(staker, amount, owner);
    } 

    function getAndUpdateStaker() external returns (Staker memory) {
        Staker storage staker = stakers[_msgSender()];
        _compoundAndRecalculateShares(staker, 0, _msgSender());
        return staker;
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

    function _claimReward(address owner, address spender) private {
        Staker storage staker = stakers[owner];
        _compoundAndRecalculateShares(staker, 0, owner);

        uint128 _stakerBoosting = staker.unlockedBoostingAmount;
        require(_stakerBoosting > 0, "BoostingService: NO BOOSTING REWARDS");

        staker.unlockedBoostingAmount = 0;    
        totalBoostings -= _stakerBoosting;

        bool transferred = IERC20(NMX).transfer(spender, _stakerBoosting);
        require(transferred, "BoostingService: FAILED_TRANSFER");
        emit BoostingClaimed(owner, spender, _stakerBoosting);
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

    function _unstakeShares(address owner, address spender, uint128 shares) private {
        Staker storage staker = stakers[owner];
        _compoundAndRecalculateShares(staker, 0, owner);

        require(shares <= staker.shares, "BoostingService: INVALID_AMOUNT");

        uint64 _stakedAt  = staker.stakedAt;

        // 2 cases - new user or lock is expired
        if (_stakedAt > 0) {
            // unstake with loss
            _unstakeSharesLocked(staker, owner, spender, shares);
        } else {
            // unstake without loss 
            _unstakeSharesUnlocked(staker, owner, spender, shares);
        }
    }

    function _unstakeSharesLocked(Staker storage staker, address owner, address spender, uint128 unstakedShares) private {
        uint128 _stakerShares = staker.shares;
        require(unstakedShares <= _stakerShares, "BoostingService: NOT_ENOUGH_BALANCE");

        uint128 principalDiff  = uint128(uint256(staker.principalAmount) * unstakedShares / _stakerShares);
        uint128 amountDiff     = uint128(uint256(staker.amount) * unstakedShares / _stakerShares);
        uint128 boostingDiff   = uint128(uint256(staker.boostingAmount) * unstakedShares / _stakerShares);

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


        IStakingService(LAUNCHPOOL).unstake(amountDiff);
        _burn(totalBurnedAmount);
        emit PenaltyBurnt(owner, penaltyAmount);
        emit BoostingBurnt(owner, boostingDiff);
        emit CompoundBurnt(owner, amountDiff);
        bool transferred = IERC20(NMX).transfer(spender, withdrawAmount);
        require(transferred, "BoostingService: FAILED_TRANSFER");
        emit Unstaked(owner, spender, principalDiff);
    }

    function _unstakeSharesUnlocked(Staker storage staker, address owner, address spender, uint128 unstakedShares) private {
        uint128 _stakerShares = staker.shares;
        require(unstakedShares <= _stakerShares, "BoostingService: NOT_ENOUGH_BALANCE");

        uint128 unstakeAmount = uint128(uint256(staker.amount) * unstakedShares / _stakerShares);

        staker.amount -= unstakeAmount;
        staker.principalAmount -= unstakeAmount;
        staker.shares -= unstakedShares;

        // TODO: test
        totalStakedCompounded -= unstakeAmount;
        totalStaked -= unstakeAmount;
        totalShares -= unstakedShares;

        uint128 fee = unstakeAmount * performanceFee / RATE_DENOMINATOR;
        uint128 unstakeAmountWithFee = unstakeAmount - fee;
        IStakingService(LAUNCHPOOL).unstake(unstakeAmount);
        IERC20(NMX).transfer(spender, unstakeAmountWithFee);
        _burn(fee);
        emit Unstaked(owner, spender, unstakeAmount);
    }


    function _compoundAndRecalculateShares(
        Staker storage staker, 
        uint128 amount, 
        address owner
    )
        private 
        returns(uint128 adjustedStakedAmount)
    {
        uint128 compoundRewards = _receiveCompound();
        _receiveBoosting(compoundRewards);
        
        adjustedStakedAmount = _materializeShares(staker, owner);
        _stakeShares(staker, amount);

        adjustedStakedAmount += amount;
        if (adjustedStakedAmount > 0) {
            emit Staked(owner, adjustedStakedAmount);
        }

        uint128 compoundAmount = compoundRewards + amount;
        IStakingService(LAUNCHPOOL).stakeFrom(address(this), compoundAmount);
    }

    function _receiveCompound() private returns (uint128 claimedReward) {
        uint128 _totalShares = totalShares;

        claimedReward = uint128(IStakingService(LAUNCHPOOL).claimReward());
        
        if (_totalShares > 0) {
            totalStakedCompounded += claimedReward;
            historicalCompoundRate += (claimedReward << 40) / _totalShares;
        } else {
            _burn(claimedReward);
            claimedReward = 0;
        }
    }

    function _receiveBoosting(uint128 compoundRewards) private {
        uint128 boostingRewards = uint128(INmxSupplier(nmxSupplier).supplyNmx(uint40(block.timestamp)));
        uint128 expectedBoostings = (compoundRewards * boostingRate) / RATE_DENOMINATOR;

        // theoretically we can receive less than expected
        if (boostingRewards > expectedBoostings) {
            // todo: test
            _burn(boostingRewards - expectedBoostings);
            boostingRewards = expectedBoostings;
        }   

        uint128 _totalShares = totalShares;
        if (_totalShares > 0) {
            uint128 _historicalBoostingRate = historicalBoostingRate + ((boostingRewards << 40) / _totalShares);
            historicalBoostingRate = _historicalBoostingRate;
            _recordBoostingRateHistory(_historicalBoostingRate);
            totalBoostings += boostingRewards;
        } else {
            _burn(boostingRewards);
        }
    }

    function _materializeShares(Staker storage staker, address owner) private returns(uint128 principalAmountDiff) {
        uint128 _stakerShares = staker.shares;
        uint128 _stakerInitialBoostingRate = staker.initialBoostingRate;

        uint128 compoundAmount = uint128(((uint168(historicalCompoundRate) - staker.initialCompoundRate) * _stakerShares) >> 40);
        uint128 boostingAmount = uint128(((uint168(historicalBoostingRate) - _stakerInitialBoostingRate) * _stakerShares) >> 40);

        uint64 _stakedAt  = staker.stakedAt;
        uint64 stakingEnd = _stakedAt + DURATION;
        bool unlocked;

        // 2 cases - new user or lock is expired
        if (stakingEnd < block.timestamp) {
            unlocked = true;
            // lock is expired
            if (_stakedAt > 0) {
                // one time action: materialize boostings up to the staking end and burn leftovers
                uint128 boostingRateAtCheckpoint = _findNearestLowestBoostingRate(stakingEnd);
                uint128 boostingAmountAtCheckpoint = uint128(((uint168(boostingRateAtCheckpoint) - _stakerInitialBoostingRate) * _stakerShares) >> 40);
                uint128 leftOvers = boostingAmount - boostingAmountAtCheckpoint;
                boostingAmount = boostingAmountAtCheckpoint;
                // todo: regression test
                totalBoostings -= leftOvers;
                uint128 unlockedAmount = staker.boostingAmount + boostingAmount;
                staker.unlockedBoostingAmount += unlockedAmount;
                staker.boostingAmount = 0;
                emit BoostingAccrued(owner, boostingAmount);
                emit BoostingUnlocked(owner, unlockedAmount);
                staker.stakedAt = 0; // will be overwritten in _stakeShares() if user is staking again
                _burn(leftOvers);        
            } else if (boostingAmount > 0) {
                // if staker.stakedAt == 0 it's either a new user or an unloked user
                // if boostingAmount > 0 then it's a user that was previously unlocked and their's lefover boostings were burned
                // and all their due boostings were materialized, since unlocked users do not receive the boost, we now burn everything
                // todo: regression test
                totalBoostings -= boostingAmount;
                _burn(boostingAmount);
            }
        } else {
            staker.boostingAmount += boostingAmount;
            emit BoostingAccrued(owner, boostingAmount);
        }
      
        staker.amount += compoundAmount;
        emit CompoundAccrued(owner, compoundAmount);

        if (unlocked) {
            uint128 _principal = staker.principalAmount;
            uint128 _amount = staker.amount;
            principalAmountDiff = _amount  - _principal;
            // materialize compounded rewards
            staker.principalAmount = _amount;
            totalStaked += principalAmountDiff;
            emit CompoundUnlocked(owner, principalAmountDiff);
            // emit Staked(owner, diff);
        }

        staker.initialCompoundRate = historicalCompoundRate;
        staker.initialBoostingRate = historicalBoostingRate;
    }


    function _stakeShares(Staker storage staker, uint128 amount) private {
        if (amount == 0) return;

        uint128 currentShares;
        uint128 _totalShares = totalShares;
        if (_totalShares != 0) {
            currentShares = uint128((uint256(amount) * _totalShares) / totalStakedCompounded);
        } else {
            require(amount >= 10**16, 'BoostingService: INVALID_INITIAL_AMOUNT');
            currentShares = amount;
        }

        uint128 prevPrincipalAmount = staker.principalAmount;
        
        staker.principalAmount += amount;
        staker.amount += amount;
        staker.shares += currentShares;

        uint64 time = _recalculateStakingTime(staker.stakedAt, prevPrincipalAmount, amount);
        staker.stakedAt = uint64(block.timestamp) - time;
        // emit Staked(owner, amount);

        totalShares += currentShares;
        totalStakedCompounded += amount;
        totalStaked += amount;
    }

    function _burn(uint128 amount) private {
        bool transferred = IERC20(NMX).transfer(NULL_ADDRESS, amount);
        require(transferred, "BoostingService: BURN_TRANSFER_FAILED");  
    }

    function _recordBoostingRateHistory(uint128 _boostingRate) private {
        BoostingRateCheckpoint storage checkpoint = boostingRateHistory.push();
        checkpoint.time = uint64(block.timestamp);
        checkpoint.value = _boostingRate;        
    }

    function _findNearestLowestBoostingRate(uint64 timestamp) private view returns (uint128) {
        uint256 length = boostingRateHistory.length;
        if (length == 0) {
            return 0;
        }

        // If the requested time is equal to or after the time of the latest registered value, return latest value
        uint256 lastIndex = length - 1;
        if (timestamp >= boostingRateHistory[lastIndex].time) {
            return boostingRateHistory[lastIndex].value;
        }

        // If the requested time is previous to the first registered value, return 0 as if there was no autocompounding 
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

        uint128 value = boostingRateHistory[low].value;
        if (low < length - 1) {
            uint64 time0 = boostingRateHistory[low].time;
            uint64 time1 = boostingRateHistory[low + 1].time;
            uint128 value1 = boostingRateHistory[low + 1].value;
            // value = value0 + (value1 - value0) / (time1 - time0) * (timestamp - time0) = [value0 * (time1 - time0) + (value1 - value0) * (timestamp - time0)] / (time1 - time0)
            value = (value * (time1 - time0) + (value1 - value) * (timestamp - time0)) / (time1 - time0);
        }
        return value;
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
    ) private {
        require(deadline >= block.timestamp, "BoostingService: EXPIRED");
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domain_separator,
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
 
    /**
    @dev recalculates user's actual staking time after re-stake
        the formula is principalAmount * secondsSinceStake / (principalAmount + stakeAmount) / (k1 + secondsSinceStake/durationInSeconds*k2)
    @return Calculated user staking time in seconds 
    */ 
    function _recalculateStakingTime(
        uint64 stakedAt,
        uint128 principalAmount,
        uint128 stakingAmount
    ) 
        internal
        view 
        returns(uint64) 
    {
        // if this service doesn't have time adjusting coefficient or staker is new or staker is unlocked
        if (K1 == 0 || stakedAt == 0) {
            return 0;
        }

        // todo: can be unchecked {}
        uint64 secondsSinceStake = uint64(block.timestamp) - stakedAt;

        uint128 newAmount = principalAmount + stakingAmount;
        uint192 amountsRatio = (uint192(principalAmount) << 64) / newAmount;
        uint256 first = uint256(secondsSinceStake) * amountsRatio;

        uint192 second = ((uint128(secondsSinceStake) * K2) / DURATION) + K1;
        uint256 result = first / second;

        return uint64(result);
    }

    function getRecoverableAmount(address tokenAddress) override internal view returns (uint256) {        
        if (tokenAddress == NMX) {            
            uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
            uint256 reserved = totalStakedCompounded + totalBoostings;
            assert(balance >= reserved);
            return balance - reserved;
        }
        return RecoverableByOwnerUpgradeable.getRecoverableAmount(tokenAddress);
    }

}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0 <0.9.0;

interface IStakingService {
    function unstake(uint128 amount) external;
    function unstakeTo(address to, uint128 amount) external;
    function stakeFrom(address owner, uint128 amount) external;
    function claimReward() external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

/**
 * @dev Interface to got minted Nmx.
 */
interface INmxSupplier {
    /**
      @dev if caller is owner of any mint pool it will be supplied with Nmx based on the schedule and time passed from the moment
      when the method was invoked by the same mint pool owner last time
      @param maxTime the upper limit of the time to make calculations
    */
    function supplyNmx(uint40 maxTime) external returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Permit is IERC20 {
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 @dev The contract is intendent to help recovering arbitrary ERC20 tokens and ETH accidentally transferred to the contract address
 */
abstract contract RecoverableByOwnerUpgradeable is OwnableUpgradeable {

    function __RecoverableByOwner_init() internal onlyInitializing {
        __RecoverableByOwner_init_unchained();
    }

    function __RecoverableByOwner_init_unchained() internal onlyInitializing {
        __Ownable_init();
    }

    function getRecoverableAmount(address tokenAddress)
        internal
        view
        virtual
        returns (uint256)
    {
        if (tokenAddress == address(0)) return address(this).balance;
        else return IERC20(tokenAddress).balanceOf(address(this));
    }

    /**
     @param tokenAddress ERC20 token's address to recover or address(0) to recover ETH
     @param amount to recover from contract's address
     @param to address to receive tokens from the contract
     */
    function recoverFunds(
        address tokenAddress,
        uint256 amount,
        address to
    ) external onlyOwner {
        uint256 recoverableAmount = getRecoverableAmount(tokenAddress);
        require(
            amount <= recoverableAmount,
            "RecoverableByOwner: RECOVERABLE_AMOUNT_NOT_ENOUGH"
        );
        if (tokenAddress == address(0)) recoverEth(amount, to);
        else recoverErc20(tokenAddress, amount, to);
    }

    function recoverEth(uint256 amount, address to) private {
        address payable toPayable = payable(to);
        toPayable.transfer(amount);
    }

    function recoverErc20(
        address tokenAddress,
        uint256 amount,
        address to
    ) private {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = tokenAddress.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'RecoverableByOwner: TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

/**
 * @dev Contract module which is essentially like Pausable but only owner is allowed to change the state.
 */
abstract contract PausableByOwnerUpgradeable is PausableUpgradeable, OwnableUpgradeable {

    function __PausableByOwner_init() internal onlyInitializing {
        __Pausable_init();
        __Ownable_init();
    }

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

// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */
pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
  /*
   * Minimum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  /*
   * Maximum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Convert signed 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromInt (int256 x) internal pure returns (int128) {
    unchecked {
      require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (x << 64);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 64-bit integer number
   * rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64-bit integer number
   */
  function toInt (int128 x) internal pure returns (int64) {
    unchecked {
      return int64 (x >> 64);
    }
  }

  /**
   * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromUInt (uint256 x) internal pure returns (int128) {
    unchecked {
      require (x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (int256 (x << 64));
    }
  }

  /**
   * Convert signed 64.64 fixed point number into unsigned 64-bit integer
   * number rounding down.  Revert on underflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return unsigned 64-bit integer number
   */
  function toUInt (int128 x) internal pure returns (uint64) {
    unchecked {
      require (x >= 0);
      return uint64 (uint128 (x >> 64));
    }
  }

  /**
   * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
   * number rounding down.  Revert on overflow.
   *
   * @param x signed 128.128-bin fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function from128x128 (int256 x) internal pure returns (int128) {
    unchecked {
      int256 result = x >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 128.128 fixed point
   * number.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 128.128 fixed point number
   */
  function to128x128 (int128 x) internal pure returns (int256) {
    unchecked {
      return int256 (x) << 64;
    }
  }

  /**
   * Calculate x + y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function add (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) + y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x - y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sub (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) - y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding down.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function mul (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) * y >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
   * number and y is signed 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y signed 256-bit integer number
   * @return signed 256-bit integer number
   */
  function muli (int128 x, int256 y) internal pure returns (int256) {
    unchecked {
      if (x == MIN_64x64) {
        require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
          y <= 0x1000000000000000000000000000000000000000000000000);
        return -y << 63;
      } else {
        bool negativeResult = false;
        if (x < 0) {
          x = -x;
          negativeResult = true;
        }
        if (y < 0) {
          y = -y; // We rely on overflow behavior here
          negativeResult = !negativeResult;
        }
        uint256 absoluteResult = mulu (x, uint256 (y));
        if (negativeResult) {
          require (absoluteResult <=
            0x8000000000000000000000000000000000000000000000000000000000000000);
          return -int256 (absoluteResult); // We rely on overflow behavior here
        } else {
          require (absoluteResult <=
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
          return int256 (absoluteResult);
        }
      }
    }
  }

  /**
   * Calculate x * y rounding down, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y unsigned 256-bit integer number
   * @return unsigned 256-bit integer number
   */
  function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    unchecked {
      if (y == 0) return 0;

      require (x >= 0);

      uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      uint256 hi = uint256 (int256 (x)) * (y >> 128);

      require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      hi <<= 64;

      require (hi <=
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
      return hi + lo;
    }
  }

  /**
   * Calculate x / y rounding towards zero.  Revert on overflow or when y is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function div (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      int256 result = (int256 (x) << 64) / y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are signed 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divi (int256 x, int256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);

      bool negativeResult = false;
      if (x < 0) {
        x = -x; // We rely on overflow behavior here
        negativeResult = true;
      }
      if (y < 0) {
        y = -y; // We rely on overflow behavior here
        negativeResult = !negativeResult;
      }
      uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
      if (negativeResult) {
        require (absoluteResult <= 0x80000000000000000000000000000000);
        return -int128 (absoluteResult); // We rely on overflow behavior here
      } else {
        require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int128 (absoluteResult); // We rely on overflow behavior here
      }
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divu (uint256 x, uint256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      uint128 result = divuu (x, y);
      require (result <= uint128 (MAX_64x64));
      return int128 (result);
    }
  }

  /**
   * Calculate -x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function neg (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return -x;
    }
  }

  /**
   * Calculate |x|.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function abs (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return x < 0 ? -x : x;
    }
  }

  /**
   * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function inv (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != 0);
      int256 result = int256 (0x100000000000000000000000000000000) / x;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function avg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      return int128 ((int256 (x) + int256 (y)) >> 1);
    }
  }

  /**
   * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
   * Revert on overflow or in case x * y is negative.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function gavg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 m = int256 (x) * int256 (y);
      require (m >= 0);
      require (m <
          0x4000000000000000000000000000000000000000000000000000000000000000);
      return int128 (sqrtu (uint256 (m)));
    }
  }

  /**
   * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y uint256 value
   * @return signed 64.64-bit fixed point number
   */
  function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
      bool negative = x < 0 && y & 1 == 1;

      uint256 absX = uint128 (x < 0 ? -x : x);
      uint256 absResult;
      absResult = 0x100000000000000000000000000000000;

      if (absX <= 0x10000000000000000) {
        absX <<= 63;
        while (y != 0) {
          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x2 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x4 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x8 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          y >>= 4;
        }

        absResult >>= 64;
      } else {
        uint256 absXShift = 63;
        if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
        if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
        if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
        if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
        if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
        if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }

        uint256 resultShift = 0;
        while (y != 0) {
          require (absXShift < 64);

          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
            resultShift += absXShift;
            if (absResult > 0x100000000000000000000000000000000) {
              absResult >>= 1;
              resultShift += 1;
            }
          }
          absX = absX * absX >> 127;
          absXShift <<= 1;
          if (absX >= 0x100000000000000000000000000000000) {
              absX >>= 1;
              absXShift += 1;
          }

          y >>= 1;
        }

        require (resultShift < 64);
        absResult >>= 64 - resultShift;
      }
      int256 result = negative ? -int256 (absResult) : int256 (absResult);
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down.  Revert if x < 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
      require (x >= 0);
      return int128 (sqrtu (uint256 (int256 (x)) << 64));
    }
  }

  /**
   * Calculate binary logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      int256 msb = 0;
      int256 xc = x;
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

      int256 result = msb - 64 << 64;
      uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256 (b);
      }

      return int128 (result);
    }
  }

  /**
   * Calculate natural logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function ln (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      return int128 (int256 (
          uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
    }
  }

  /**
   * Calculate binary exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      uint256 result = 0x80000000000000000000000000000000;

      if (x & 0x8000000000000000 > 0)
        result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (x & 0x4000000000000000 > 0)
        result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (x & 0x2000000000000000 > 0)
        result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (x & 0x1000000000000000 > 0)
        result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (x & 0x800000000000000 > 0)
        result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (x & 0x400000000000000 > 0)
        result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (x & 0x200000000000000 > 0)
        result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (x & 0x100000000000000 > 0)
        result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (x & 0x80000000000000 > 0)
        result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (x & 0x40000000000000 > 0)
        result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (x & 0x20000000000000 > 0)
        result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (x & 0x10000000000000 > 0)
        result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (x & 0x8000000000000 > 0)
        result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (x & 0x4000000000000 > 0)
        result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (x & 0x2000000000000 > 0)
        result = result * 0x1000162E525EE054754457D5995292026 >> 128;
      if (x & 0x1000000000000 > 0)
        result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (x & 0x800000000000 > 0)
        result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (x & 0x400000000000 > 0)
        result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (x & 0x200000000000 > 0)
        result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (x & 0x100000000000 > 0)
        result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (x & 0x80000000000 > 0)
        result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (x & 0x40000000000 > 0)
        result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (x & 0x20000000000 > 0)
        result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (x & 0x10000000000 > 0)
        result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (x & 0x8000000000 > 0)
        result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (x & 0x4000000000 > 0)
        result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (x & 0x2000000000 > 0)
        result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (x & 0x1000000000 > 0)
        result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (x & 0x800000000 > 0)
        result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (x & 0x400000000 > 0)
        result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (x & 0x200000000 > 0)
        result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (x & 0x100000000 > 0)
        result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (x & 0x80000000 > 0)
        result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (x & 0x40000000 > 0)
        result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (x & 0x20000000 > 0)
        result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (x & 0x10000000 > 0)
        result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (x & 0x8000000 > 0)
        result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (x & 0x4000000 > 0)
        result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (x & 0x2000000 > 0)
        result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (x & 0x1000000 > 0)
        result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (x & 0x800000 > 0)
        result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (x & 0x400000 > 0)
        result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (x & 0x200000 > 0)
        result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (x & 0x100000 > 0)
        result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (x & 0x80000 > 0)
        result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (x & 0x40000 > 0)
        result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (x & 0x20000 > 0)
        result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (x & 0x10000 > 0)
        result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (x & 0x8000 > 0)
        result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (x & 0x4000 > 0)
        result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (x & 0x2000 > 0)
        result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (x & 0x1000 > 0)
        result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (x & 0x800 > 0)
        result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (x & 0x400 > 0)
        result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (x & 0x200 > 0)
        result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (x & 0x100 > 0)
        result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (x & 0x80 > 0)
        result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (x & 0x40 > 0)
        result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (x & 0x20 > 0)
        result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (x & 0x10 > 0)
        result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (x & 0x8 > 0)
        result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (x & 0x4 > 0)
        result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (x & 0x2 > 0)
        result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (x & 0x1 > 0)
        result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

      result >>= uint256 (int256 (63 - (x >> 64)));
      require (result <= uint256 (int256 (MAX_64x64)));

      return int128 (int256 (result));
    }
  }

  /**
   * Calculate natural exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      return exp_2 (
          int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return unsigned 64.64-bit fixed point number
   */
  function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    unchecked {
      require (y != 0);

      uint256 result;

      if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        result = (x << 64) / y;
      else {
        uint256 msb = 192;
        uint256 xc = x >> 192;
        if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
        if (xc >= 0x10000) { xc >>= 16; msb += 16; }
        if (xc >= 0x100) { xc >>= 8; msb += 8; }
        if (xc >= 0x10) { xc >>= 4; msb += 4; }
        if (xc >= 0x4) { xc >>= 2; msb += 2; }
        if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

        result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
        require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 hi = result * (y >> 128);
        uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 xh = x >> 192;
        uint256 xl = x << 64;

        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here
        lo = hi << 128;
        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here

        assert (xh == hi >> 128);

        result += xl / y;
      }

      require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return uint128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
   * number.
   *
   * @param x unsigned 256-bit integer number
   * @return unsigned 128-bit integer number
   */
  function sqrtu (uint256 x) private pure returns (uint128) {
    unchecked {
      if (x == 0) return 0;
      else {
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
        if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
        if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
        if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
        if (xx >= 0x100) { xx >>= 8; r <<= 4; }
        if (xx >= 0x10) { xx >>= 4; r <<= 2; }
        if (xx >= 0x8) { r <<= 1; }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return uint128 (r < r1 ? r : r1);
      }
    }
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
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