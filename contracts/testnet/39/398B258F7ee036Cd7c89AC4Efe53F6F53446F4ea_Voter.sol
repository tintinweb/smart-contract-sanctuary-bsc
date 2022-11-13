// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../interfaces/IBribe.sol';

interface IGauge {
    function notifyRewardAmount(IERC20 token, uint256 amount) external;
}

interface IVe {
    function vote(address user, int256 voteDelta) external;
}

/// Voter can handle gauge voting. WOM rewards are distributed to different gauges (MasterWombat->LpToken pair)
/// according to the base allocation & voting weights.
///
/// veWOM holders can participate in gauge voting to determine `voteAllocation()` of the WOM emission. They can
///  allocate their vote (1 veWOM = 1 vote) to one or more gauges. WOM emission to a gauge is proportional
/// to the amount of vote it receives.
///
/// Real-time WOM accumulation and epoch-based WOM distribution:
/// Voting gauges accumulates WOM seconds by seconds according to the voting weight. When a user applies new
/// allocation for their votes, accumulation rate of WOM of the gauge updates immediately. Only whitelisted
/// gauges are able to accumulage WOM.
/// However, accumulated WOM is distributed to LP in the next epoch at an even rate. 1 epoch last for 7 days.
///
/// Base Allocation:
/// `baseAllocation` of WOM emissions is distributed to gauges according to the allocation by `owner`.
/// Other WOM emissions are deteremined by `votes` of veWOM holders.
///
/// Flow to distribute reward:
/// 1. At the beginning of MasterWombat.updateFactor/deposit/withdraw, Voter.distribute(lpToken) is called
/// 2. WOM index (`baseIndex` and `voteIndex`) is updated and corresponding WOM accumulated over this period (`GaugeInfo.claimable`)
///    is updated.
/// 3. At the beginning of each epoch, `GaugeInfo.claimable` amount of WOM is sent to respective gauge
///    via MasterWombat.notifyRewardAmount(IERC20 _lpToken, uint256 _amount)
/// 4. MasterWombat will update the corresponding `pool.rewardRate` and `pool.periodFinish`
///
/// Bribe
/// Bribe is natively supported by `Voter`. Third Party protocols can bribe to attract more votes from veWOM holders
/// to increase WOM emissions to their tokens.
///
/// Flow of bribe:
/// 1. When users vote/unvote, `bribe.onVote` is called. The bribe contract works similar to `MultiRewarderPerSec`.
///
/// Note: This should also works with boosted pool. But it doesn't work with interest rate model
/// Note 2: Please refer to the comment of MasterWombatV3.notifyRewardAmount for front-running risk
contract Voter is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    struct GaugeInfo {
        uint104 supplyBaseIndex; // 19.12 fixed point. distributed reward per alloc point
        uint104 supplyVoteIndex; // 19.12 fixed point. distributed reward per vote weight
        uint40 nextEpochStartTime;
        uint128 claimable; // 20.18 fixed point. Rewards pending distribution in the next epoch
        bool whitelist;
        IGauge gaugeManager;
        IBribe bribe; // address of bribe
    }

    struct GaugeWeight {
        uint128 allocPoint;
        uint128 voteWeight; // total amount of votes for an LP-token
    }

    uint256 internal constant ACC_TOKEN_PRECISION = 1e12;
    uint256 internal constant EPOCH_DURATION = 7 days;

    IERC20 public wom;
    IVe public veWom;
    IERC20[] public lpTokens; // all LP tokens

    // emission related storage
    uint40 public lastRewardTimestamp; // last timestamp to count
    uint104 public baseIndex; // 19.12 fixed point. Accumulated reward per alloc point
    uint104 public voteIndex; // 19.12 fixed point. Accumulated reward per vote weight

    uint128 public totalWeight;
    uint128 public totalAllocPoint;

    uint40 public firstEpochStartTime;
    uint88 public womPerSec; // 8.18 fixed point
    uint16 public baseAllocation; // (e.g. 300 for 30%)

    mapping(IERC20 => GaugeWeight) public weights; // lpToken => gauge weight
    mapping(address => mapping(IERC20 => uint256)) public votes; // user address => lpToken => votes
    mapping(IERC20 => GaugeInfo) public infos; // lpToken => GaugeInfo

    event UpdateEmissionPartition(uint256 baseAllocation, uint256 votePartition);
    event UpdateVote(address user, IERC20 lpToken, uint256 amount);
    event DistributeReward(IERC20 lpToken, uint256 amount);

    function initialize(
        IERC20 _wom,
        IVe _veWom,
        uint88 _womPerSec,
        uint40 _startTimestamp,
        uint40 _firstEpochStartTime,
        uint16 _baseAllocation
    ) external initializer {
        require(_firstEpochStartTime >= block.timestamp, 'invalid _firstEpochStartTime');
        require(address(_wom) != address(0), 'wom address cannot be zero');
        require(address(_veWom) != address(0), 'veWom address cannot be zero');
        require(_baseAllocation <= 1000);

        __Ownable_init();
        __ReentrancyGuard_init_unchained();

        wom = _wom;
        veWom = _veWom;
        womPerSec = _womPerSec;
        lastRewardTimestamp = _startTimestamp;
        firstEpochStartTime = _firstEpochStartTime;
        baseAllocation = _baseAllocation;
    }

    /// @dev this check save more gas than a modifier
    function _checkGaugeExist(IERC20 _lpToken) internal view {
        require(address(infos[_lpToken].gaugeManager) != address(0), 'Voter: gaugeManager not exist');
    }

    /// @notice returns LP tokens length
    function lpTokenLength() external view returns (uint256) {
        return lpTokens.length;
    }

    /// @notice getter function to return vote of a LP token for a user
    function getUserVotes(address _user, IERC20 _lpToken) external view returns (uint256) {
        return votes[_user][_lpToken];
    }

    /// @notice Vote and unvote WOM emission for LP tokens.
    /// User can vote/unvote a un-whitelisted pool. But no WOM will be emitted.
    /// Bribes are also distributed by the Bribe contract.
    /// Amount of vote should be checked by veWom.vote().
    /// This can also used to distribute bribes when _deltas are set to 0
    /// @param _lpVote address to LP tokens to vote
    /// @param _deltas change of vote for each LP tokens
    function vote(IERC20[] calldata _lpVote, int256[] calldata _deltas)
        external
        nonReentrant
        returns (uint256[][] memory bribeRewards)
    {
        // 1. call _updateFor() to update WOM emission
        // 2. update related lpToken weight and total lpToken weight
        // 3. update used voting power and ensure there's enough voting power
        // 4. call IBribe.onVote() to update bribes
        require(_lpVote.length == _deltas.length, 'voter: array length not equal');

        // update voteIndex
        _distributeWom();

        uint256 voteCnt = _lpVote.length;
        int256 voteDelta;

        bribeRewards = new uint256[][](voteCnt);

        for (uint256 i; i < voteCnt; ++i) {
            IERC20 lpToken = _lpVote[i];
            _checkGaugeExist(lpToken);

            int256 delta = _deltas[i];
            uint256 originalWeight = weights[lpToken].voteWeight;
            if (delta != 0) {
                _updateFor(lpToken);

                // update vote and weight
                if (delta > 0) {
                    // vote
                    votes[msg.sender][lpToken] += uint256(delta);
                    weights[lpToken].voteWeight = to128(originalWeight + uint256(delta));
                    totalWeight += to128(uint256(delta));
                } else {
                    // unvote
                    require(votes[msg.sender][lpToken] >= uint256(-delta), 'voter: vote underflow');
                    votes[msg.sender][lpToken] -= uint256(-delta);
                    weights[lpToken].voteWeight = to128(originalWeight - uint256(-delta));
                    totalWeight -= to128(uint256(-delta));
                }

                voteDelta += delta;
                emit UpdateVote(msg.sender, lpToken, votes[msg.sender][lpToken]);
            }

            // update bribe
            if (address(infos[lpToken].bribe) != address(0)) {
                bribeRewards[i] = infos[lpToken].bribe.onVote(msg.sender, votes[msg.sender][lpToken], originalWeight);
            }
        }

        // notice veWom for the new vote, it reverts if vote is invalid
        veWom.vote(msg.sender, voteDelta);
    }

    /// @notice Claim bribes for LP tokens
    /// @dev This function looks safe from re-entrancy attack
    function claimBribes(IERC20[] calldata _lpTokens) external returns (uint256[][] memory bribeRewards) {
        bribeRewards = new uint256[][](_lpTokens.length);
        for (uint256 i; i < _lpTokens.length; ++i) {
            IERC20 lpToken = _lpTokens[i];
            _checkGaugeExist(lpToken);
            if (address(infos[lpToken].bribe) != address(0)) {
                bribeRewards[i] = infos[lpToken].bribe.onVote(
                    msg.sender,
                    votes[msg.sender][lpToken],
                    weights[lpToken].voteWeight
                );
            }
        }
    }

    /// @dev This function looks safe from re-entrancy attack
    function distribute(IERC20 _lpToken) external {
        _checkGaugeExist(_lpToken);
        _distributeWom();
        _updateFor(_lpToken);

        uint256 _claimable = infos[_lpToken].claimable;
        // 1. distribute WOM once in each epoch
        // 2. In case WOM is not fueled, it should not create DoS
        if (
            _claimable > 0 &&
            block.timestamp >= infos[_lpToken].nextEpochStartTime &&
            wom.balanceOf(address(this)) > _claimable
        ) {
            infos[_lpToken].claimable = 0;
            infos[_lpToken].nextEpochStartTime = _getNextEpochStartTime();
            emit DistributeReward(_lpToken, _claimable);

            wom.transfer(address(infos[_lpToken].gaugeManager), _claimable);
            infos[_lpToken].gaugeManager.notifyRewardAmount(_lpToken, _claimable);
        }
    }

    /// @notice Update index for accrued WOM
    function _distributeWom() internal {
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }

        baseIndex = to104(_getBaseIndex());
        voteIndex = to104(_getVoteIndex());
        lastRewardTimestamp = uint40(block.timestamp);
    }

    /// @notice Update `supplyBaseIndex` and `supplyVoteIndex` for the gauge
    /// @dev Assumption: gaugeManager exists and is not paused, the caller should verify it
    /// @param _lpToken address of the LP token
    function _updateFor(IERC20 _lpToken) internal {
        // calculate claimable amount before update supplyVoteIndex
        infos[_lpToken].claimable = to128(_getClaimable(_lpToken, baseIndex, voteIndex));
        infos[_lpToken].supplyBaseIndex = baseIndex;
        infos[_lpToken].supplyVoteIndex = voteIndex;
    }

    /**
     * Permisioneed functions
     */

    /// @notice update the base and vote partition
    function setBaseAllocation(uint16 _baseAllocation) external onlyOwner {
        require(_baseAllocation <= 1000);
        _distributeWom();

        emit UpdateEmissionPartition(_baseAllocation, 1000 - _baseAllocation);
        baseAllocation = _baseAllocation;
    }

    function setAllocPoint(IERC20 _lpToken, uint128 _allocPoint) external onlyOwner {
        _distributeWom();
        _updateFor(_lpToken);
        totalAllocPoint = totalAllocPoint - weights[_lpToken].allocPoint + _allocPoint;
        weights[_lpToken].allocPoint = _allocPoint;
    }

    /// @notice Add LP token into the Voter
    function add(
        IGauge _gaugeManager,
        IERC20 _lpToken,
        IBribe _bribe
    ) external onlyOwner {
        require(infos[_lpToken].whitelist == false, 'voter: already added');
        require(address(_gaugeManager) != address(0));
        require(address(_lpToken) != address(0));
        require(address(infos[_lpToken].gaugeManager) == address(0), 'Voter: gaugeManager is already exist');

        infos[_lpToken].whitelist = true;
        infos[_lpToken].gaugeManager = _gaugeManager;
        infos[_lpToken].bribe = _bribe; // 0 address is allowed
        infos[_lpToken].nextEpochStartTime = _getNextEpochStartTime();
        lpTokens.push(_lpToken);
    }

    function setWomPerSec(uint88 _womPerSec) external onlyOwner {
        require(_womPerSec <= 10000e18, 'reward rate too high'); // in case `voteIndex` overflow
        _distributeWom();
        womPerSec = _womPerSec;
    }

    /// @notice Pause vote emission of WOM tokens for the gauge. Un-distributed rewards are forfeited
    /// Users can still vote/unvote and receive bribes.
    function pauseVoteEmission(IERC20 _lpToken) external onlyOwner {
        require(infos[_lpToken].whitelist, 'voter: not whitelisted');
        _checkGaugeExist(_lpToken);

        infos[_lpToken].whitelist = false;
    }

    /// @notice Resume vote emission of WOM tokens for the gauge.
    function resumeVoteEmission(IERC20 _lpToken) external onlyOwner {
        require(infos[_lpToken].whitelist == false, 'voter: not paused');
        _checkGaugeExist(_lpToken);

        // catch up supplyVoteIndex
        _distributeWom();
        infos[_lpToken].supplyBaseIndex = baseIndex;
        infos[_lpToken].supplyVoteIndex = voteIndex;
        infos[_lpToken].whitelist = true;
    }

    /// @notice Pause emission of WOM tokens for all assets. Un-distributed rewards are forfeited
    /// Users can still vote/unvote and receive bribes.
    function pauseAll() external onlyOwner {
        _pause();
    }

    /// @notice Resume emission of WOM tokens for all assets
    function resumeAll() external onlyOwner {
        _unpause();
    }

    /// @notice get gaugeManager address for LP token
    function setGauge(IERC20 _lpToken, IGauge _gaugeManager) external onlyOwner {
        require(address(_gaugeManager) != address(0));
        _checkGaugeExist(_lpToken);

        infos[_lpToken].gaugeManager = _gaugeManager;
    }

    /// @notice get bribe address for LP token
    function setBribe(IERC20 _lpToken, IBribe _bribe) external onlyOwner {
        _checkGaugeExist(_lpToken);

        infos[_lpToken].bribe = _bribe; // 0 address is allowed
    }

    /// @notice In case we need to manually migrate WOM funds from Voter
    /// Sends all remaining wom from the contract to the owner
    function emergencyWomWithdraw() external onlyOwner {
        // SafeERC20 is not needed as WOM will revert if transfer fails
        wom.transfer(address(msg.sender), wom.balanceOf(address(this)));
    }

    /**
     * Read-only functions
     */

    function voteAllocation() external view returns (uint256) {
        return 1000 - baseAllocation;
    }

    /// @notice Get pending bribes for LP tokens
    function pendingBribes(IERC20[] calldata _lpTokens, address _user)
        external
        view
        returns (uint256[][] memory bribeRewards)
    {
        bribeRewards = new uint256[][](_lpTokens.length);
        for (uint256 i; i < _lpTokens.length; ++i) {
            IERC20 lpToken = _lpTokens[i];
            if (address(infos[lpToken].bribe) != address(0)) {
                bribeRewards[i] = infos[lpToken].bribe.pendingTokens(_user);
            }
        }
    }

    /// @notice Amount of pending WOM for the LP token
    function pendingWom(IERC20 _lpToken) external view returns (uint256) {
        return _getClaimable(_lpToken, _getBaseIndex(), _getVoteIndex());
    }

    function _getBaseIndex() internal view returns (uint256) {
        if (block.timestamp <= lastRewardTimestamp || totalAllocPoint == 0) {
            return baseIndex;
        }

        uint256 secondsElapsed = block.timestamp - lastRewardTimestamp;
        // use `max(totalAllocPoint, 1e18)` in case the value overflows uint104
        return
            baseIndex +
            (secondsElapsed * womPerSec * baseAllocation * ACC_TOKEN_PRECISION) /
            max(totalAllocPoint, 1e18) /
            1000;
    }

    /// @notice Calculate the new `voteIndex`
    function _getVoteIndex() internal view returns (uint256) {
        if (block.timestamp <= lastRewardTimestamp || totalWeight == 0) {
            return voteIndex;
        }

        uint256 secondsElapsed = block.timestamp - lastRewardTimestamp;
        // use `max(totalWeight, 1e18)` in case the value overflows uint104
        return
            voteIndex +
            (secondsElapsed * womPerSec * (1000 - baseAllocation) * ACC_TOKEN_PRECISION) /
            max(totalWeight, 1e18) /
            1000;
    }

    /// @notice Calculate the new `claimable` for an gauge
    function _getClaimable(
        IERC20 _lpToken,
        uint256 _baseIndex,
        uint256 _voteIndex
    ) internal view returns (uint256) {
        if (paused()) {
            // WOM emission for un-whitelisted lpTokens are blackholed.
            // Also, don't distribute WOM if the contract is paused
            return infos[_lpToken].claimable;
        }

        uint256 baseIndexDelta = _baseIndex - infos[_lpToken].supplyBaseIndex;
        uint256 _baseShare = (weights[_lpToken].allocPoint * baseIndexDelta) / ACC_TOKEN_PRECISION;

        if (!infos[_lpToken].whitelist) {
            return infos[_lpToken].claimable + _baseShare;
        }

        uint256 voteIndexDelta = _voteIndex - infos[_lpToken].supplyVoteIndex;
        uint256 _voteShare = (weights[_lpToken].voteWeight * voteIndexDelta) / ACC_TOKEN_PRECISION;

        return infos[_lpToken].claimable + _baseShare + _voteShare;
    }

    /// @notice Get the start timestamp of the next epoch
    function _getNextEpochStartTime() internal view returns (uint40) {
        if (block.timestamp < firstEpochStartTime) {
            return firstEpochStartTime;
        }

        uint256 epochCount = (block.timestamp - firstEpochStartTime) / EPOCH_DURATION;
        return uint40(firstEpochStartTime + (epochCount + 1) * EPOCH_DURATION);
    }

    function to128(uint256 val) internal pure returns (uint128) {
        require(val <= type(uint128).max, 'uint128 overflow');
        return uint128(val);
    }

    function to104(uint256 val) internal pure returns (uint104) {
        if (val > type(uint104).max) revert('uint104 overflow');
        return uint104(val);
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
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
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
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
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IBribe {
    function onVote(
        address user,
        uint256 newVote,
        uint256 originalTotalVotes
    ) external returns (uint256[] memory rewards);

    function pendingTokens(address _user) external view returns (uint256[] memory rewards);

    function rewardTokens() external view returns (IERC20[] memory tokens);

    function rewardLength() external view returns (uint256);
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
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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