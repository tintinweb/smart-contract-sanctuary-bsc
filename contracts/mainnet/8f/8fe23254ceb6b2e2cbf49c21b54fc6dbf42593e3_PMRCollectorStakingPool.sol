// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../../collector-staking/TokenCollectorStakingPool.sol";

contract PMRCollectorStakingPool is TokenCollectorStakingPool {}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title The Polychain Monsters "Collect To Earn" contract for token rewards
/// @dev This contract holds a fixed amount of rewards and distributes them periodically, depending on a given score
/// @dev This contract needs an appropriate backend to be used
abstract contract TokenCollectorStakingPool is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 private constant _DIV_PRECISION = 1e18;

    /** 
        @dev an array of this is sent back to the frontend and looks like this there
        [ [1, 100], [2, 150], [intervalId, rewardForInterval] ]
        The frontend will then sum up the total amount of rewards for the user
    */
    struct PendingRewardResult {
        uint256 intervalId;
        uint256 reward;
    }

    /** 
        @dev points is the score that the user has achieved via collect to earn within this
        interval totalPoints is amount of points that all users together have achieved based
        on this information we calculate the proportionally reward for the given intervalId
    */
    struct PendingRewardRequest {
        uint256 intervalId;
        uint256 points;
        uint256 totalPoints;
    }

    struct UserData {
        uint256 lastHarvestedInterval;
    }

    struct Interval {
        uint256 rewardAmount;
        uint256 claimedRewardAmount;
    }

    /// @dev The token in which the rewards are payed out
    IERC20Upgradeable public rewardToken;

    /// @dev the number of intervals that can be passed before the reward for this interval gets revoked
    uint256 public expireAfter;

    uint256 public intervalLengthInSec;

    /// @dev the fixed total amount of rewards that will be released, will be claimable
    uint256 public totalRewards;

    /// @dev the amount of rewards that are theoretically can be harvested so far
    uint256 public totalAvailableRewards;

    /// @dev the amount of rewards that are available in each interval
    uint256 public rewardAmountPerInterval;

    /// @dev the address of the wallet that is used by the backend to sign messages
    address private _trustedSigner;

    /// @dev amount of rewards that have not been claimed withing the expireAfter time
    uint256 private _unclaimedRewards;

    /// @dev holds the timestamp at which the current interval will end
    uint256 public nextIntervalTimestamp;

    /// @dev holds the number of the current interval - starting number can be defined on init
    uint256 public intervalIdCounter;

    /// @dev holds id of the last interval
    /// @dev is set during init, taking into account the given first interval id
    uint256 public lastIntervalId;

    /// @dev the last interval has reached an all rewards have been claimed
    bool public distributionEnded;

    /**
        @dev stores the interval id and the info about how much reward is 
        available in this interval and how much has been claimed
    */
    mapping(uint256 => Interval) private _idToInterval;

    /// @dev stores the userId and the appropriate value of "last harvested interval"
    mapping(uint256 => UserData) private _userIdToUserData;

    /// @dev is emitted when the end of an interval is reached and the information for a the interval is set
    event IntervalClosed(uint256 newInterval);

    /// @dev is emitted when the last interval is reached
    event DistributionEnded(uint256 lastIntervalId);

    /// @dev is emitted when the expireAfter period has passed and unclaimed rewards amount increases
    event RevokeUnclaimedRewards(uint256 unclaimedRewards);

    /// @param __rewardToken              the token the rewards are payed
    /// @param __totalRewards             amount of rewards to be harvested in total
    /// @param __expireAfter              number of intervals a user can harvest in the past (not harvested rewards will be withdrawn by the contract owner)
    /// @param __intervalLengthInSec      interval length in sec - 604800 for one week
    /// @param __numberOfIntervals        number of intervals to be excuted (max intervalIdCounter)
    /// @param __endOfFirstInterval       initially sets the value for "next Interval timestamp"
    /// @param __trustedSigner            the address of the wallet that is used for backend signing
    /// @param __firstIntervalId          start Id for intervalCounter - most likeyl this will be 1
    function initialize(
        IERC20Upgradeable __rewardToken,
        uint256 __totalRewards,
        uint256 __expireAfter,
        uint256 __intervalLengthInSec,
        uint256 __numberOfIntervals,
        uint256 __endOfFirstInterval,
        address __trustedSigner,
        uint256 __firstIntervalId
    ) public initializer {
        intervalIdCounter = __firstIntervalId;
        rewardToken = __rewardToken;
        expireAfter = __expireAfter;
        intervalLengthInSec = __intervalLengthInSec;
        lastIntervalId = __numberOfIntervals + __firstIntervalId - 1;
        nextIntervalTimestamp = __endOfFirstInterval;
        _trustedSigner = __trustedSigner;
        totalRewards = __totalRewards;
        rewardAmountPerInterval = (__totalRewards * _DIV_PRECISION) / __numberOfIntervals / _DIV_PRECISION;
        _idToInterval[intervalIdCounter].rewardAmount = rewardAmountPerInterval;
        OwnableUpgradeable.__Ownable_init();
    }

    /// @dev the amount of intervals in within rewards can be harvested can be changed
    function setExpireAfter(uint256 newExpireAfter) external onlyOwner {
        if (_isNextIntervalReached()) {
            // cleanup the current state first if necessary
            _closeCurrentInterval();
        }
        if (newExpireAfter < expireAfter && intervalIdCounter > newExpireAfter) {
            // cleanup expired intervals
            uint256 iStart = 1;
            if (intervalIdCounter > expireAfter) {
                iStart = intervalIdCounter - expireAfter;
            }
            for (uint256 i = iStart; i < intervalIdCounter - newExpireAfter; i++) {
                _revokeUnclaimedRewards(i);
            }
        }
        expireAfter = newExpireAfter;
    }

    /// @dev the owner can change the address of the wallet that is used by the backend
    function setTrustedSigner(address trustedSigner) external onlyOwner {
        _trustedSigner = trustedSigner;
    }

    /**
        @dev the next interval is reached when the current timestamp 
        is bigger than the currently set 'next interval timestamp
    */
    function _isNextIntervalReached() private view returns (bool) {
        return block.timestamp >= nextIntervalTimestamp;
    }

    /// @dev returns the amount of the unclaimed (expired) rewards
    function getUnclaimedRewards() external view onlyOwner returns (uint256) {
        return _unclaimedRewards;
    }

    /// @dev transfers the amount of tokens that have not been claimed within the expire period to the owners wallet
    function withdrawUnclaimedRewards() external onlyOwner {
        uint256 unclaimed = _unclaimedRewards;
        _unclaimedRewards = 0;
        rewardToken.safeTransfer(msg.sender, unclaimed);
    }

    /// @dev actually harvest/withdraw the claimable rewards
    /**
        @dev o make it easier to verify the signature, harvestRequests contains an intervalId in each even index and the
        reward for the interval in the next odd index.
        also see structs PendingRewardResult and PendingRewardRequest 
     */
    function harvest(
        uint256 userId,
        address[] memory userWallets,
        uint256[] memory harvestRequests,
        bytes memory signature
    ) external {
        bool senderAssociatedWithTheUser = false;
        for (uint256 i = 0; i < userWallets.length && !senderAssociatedWithTheUser; i++) {
            senderAssociatedWithTheUser = msg.sender == userWallets[i];
        }
        require(senderAssociatedWithTheUser, "Sender is not associated with the user");
        require(_signatureVerification(userId, userWallets, harvestRequests, signature), "Invalid signer or signature");
        if (_isNextIntervalReached()) {
            _closeCurrentInterval();
        }

        uint256 harvestableReward;
        for (uint256 i = 0; i < harvestRequests.length; i += 2) {
            uint256 intervalId = harvestRequests[i];
            // all of the latest harvest intervals have to be older than the current. Prevent double harvest.
            require(_userIdToUserData[userId].lastHarvestedInterval < intervalId, "Tried to harvest already harvested interval");
            // all of the latest harvest intervals have to be older than the current. Prevent double harvest.
            require(intervalIdCounter > intervalId, "Tried to harvest not yet closed or started interval");
            // Prevent harvest of expired interval.
            require(intervalIdCounter < intervalId + expireAfter, "Tried to harvest expired interval");
            uint256 reward = harvestRequests[i + 1];
            // update latest harvest interval
            _userIdToUserData[userId].lastHarvestedInterval = intervalId;
            // update the claimed rewards for this interval
            _idToInterval[intervalId].claimedRewardAmount += reward;
            // sum total rewards
            harvestableReward += reward;
        }
        // transfer reward to the user
        rewardToken.safeTransfer(msg.sender, harvestableReward);
    }

    /// @dev
    function _isExpiredButNotProcessed(uint256 intervalId) private view returns (bool) {
        return _isNextIntervalReached() && intervalIdCounter + 1 > expireAfter && intervalIdCounter - expireAfter == intervalId;
    }

    /// @dev returns an array that contains an array holding the intervalId and the appropriate amount of reward
    /** 
        @dev the reward is calculated for each interval based on the users points and the totalpoints for the given interval
        these value are passed to the function for each interval
    */
    /// @return PendingRewardResult[]   e.g. [ [1, 10], [2, 20], [3, 30] ], where the first number is the intervalId and the second one the reward
    /// @param userId                   the Id of the user the rewards are requested for
    /// @param pendingRewardRequests    array of PendingRewardRequest: {intervalId, points, totalPoints}
    function pendingRewards(uint256 userId, PendingRewardRequest[] memory pendingRewardRequests)
        external
        view
        returns (PendingRewardResult[] memory)
    {
        uint256 lastHarvestedInterval = _userIdToUserData[userId].lastHarvestedInterval;
        PendingRewardResult[] memory rewards = new PendingRewardResult[](pendingRewardRequests.length);
        /// calculate rewards for each interval
        for (uint256 i = 0; i < pendingRewardRequests.length; i++) {
            PendingRewardRequest memory request = pendingRewardRequests[i];
            /// only calculate rewards for valid interval ID's
            if (
                /// distribution has ended or will already been ended in the requested interval
                request.intervalId <= lastIntervalId &&
                /// interval is not already harvested
                lastHarvestedInterval < request.intervalId &&
                /// interval is closed
                (request.intervalId < intervalIdCounter || (request.intervalId == intervalIdCounter && _isNextIntervalReached())) &&
                !_isExpiredButNotProcessed(request.intervalId)
            ) {
                rewards[i] = PendingRewardResult(
                    request.intervalId,
                    _calculateReward(_idToInterval[request.intervalId].rewardAmount, request.totalPoints, request.points)
                );
            } else {
                rewards[i] = PendingRewardResult(request.intervalId, 0);
            }
        }
        return rewards;
    }

    function _calculateReward(
        uint256 intervalRewardAmount,
        uint256 totalPointsForTheInterval,
        uint256 points
    ) private pure returns (uint256) {
        return (((intervalRewardAmount * _DIV_PRECISION) / totalPointsForTheInterval) * points) / _DIV_PRECISION;
    }

    function getLastHarvestedInterval(uint256 userId) external view returns (uint256) {
        return _userIdToUserData[userId].lastHarvestedInterval;
    }

    /// @dev triggers the closing of the current interval
    /** 
        @dev this is only done because we need to be able to trigger it from the outside, but only with the owner
        but the call of closeCurrentInterval needs to be done by any other use as well as part of the harvest function
    */
    function triggerCloseCurrentInterval() external onlyOwner {
        if (_isNextIntervalReached()) {
            _closeCurrentInterval();
        }
    }

    /**
        @dev closing the current interval happens more or less everytime when a state-changing operation is done
        on this contract like "setExpireAfter" or "harvest". It also can be triggered manually by the owner
        Closing an interval means that the interval counter increases and the amount of rewards for the new interval
        is set. If the expireAfter value is greater than the new intervalId the unclaimed rewards are made unavailable
    */
    function _closeCurrentInterval() private {
        ++intervalIdCounter;
        if (intervalIdCounter > lastIntervalId) {
            distributionEnded = true;
            _idToInterval[intervalIdCounter].rewardAmount = 0;
            emit DistributionEnded(intervalIdCounter - 1);
        } else {
            _idToInterval[intervalIdCounter].rewardAmount = rewardAmountPerInterval;
        }
        nextIntervalTimestamp += intervalLengthInSec;
        // cleanup expired interval
        if (intervalIdCounter > expireAfter) {
            _revokeUnclaimedRewards(intervalIdCounter - expireAfter);
        }
        emit IntervalClosed(intervalIdCounter - 1);
    }

    /**
        @dev rewards that have not been claimed within the expire after time will be not available any more
        the owner of the contract will be able to withdraw them
    */
    function _revokeUnclaimedRewards(uint256 intervalId) private {
        Interval memory oldInterval = _idToInterval[intervalId];
        if (oldInterval.rewardAmount > 0) {
            uint256 unclaimed = oldInterval.rewardAmount - oldInterval.claimedRewardAmount;
            if (unclaimed > 0) {
                _unclaimedRewards += unclaimed;
                emit RevokeUnclaimedRewards(_unclaimedRewards);
            }
            delete _idToInterval[intervalId];
        }
    }

    /// @dev if there are tokens sent to this contract by accident we still can withdraw them
    function recoverToken(address _token, uint256 amount) external onlyOwner {
        IERC20Upgradeable(_token).safeTransfer(_msgSender(), amount);
    }

    /// @dev we are signing messages from the backend and need to check if they are valid
    function _splitSignature(bytes memory signature)
        private
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sigR := mload(add(signature, 32))
            sigS := mload(add(signature, 64))
            sigV := byte(0, mload(add(signature, 96)))
        }
        return (sigV, sigR, sigS);
    }

    /// @dev we are signing messages from the backend and need to check if they are valid
    function _signatureVerification(
        uint256 userId,
        address[] memory userWallets,
        uint256[] memory harvestRequests,
        bytes memory signature
    ) private view returns (bool) {
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        (sigV, sigR, sigS) = _splitSignature(signature);
        bytes32 message = keccak256(abi.encodePacked(userId, userWallets, harvestRequests));
        return _trustedSigner == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message)), sigV, sigR, sigS);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/*
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}