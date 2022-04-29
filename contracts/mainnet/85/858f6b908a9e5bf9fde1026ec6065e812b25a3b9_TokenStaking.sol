// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin implementations
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

// Sleep token contract interface
import "./ISleepToken.sol";

// Timelock contract interface
import "./ITimelock.sol";

// Auth contract
import "./Auth.sol";

contract TokenStaking is Initializable, Auth, ReentrancyGuardUpgradeable {
    ISleepToken public sleepToken;
    ITimelock public timelock;

    uint256 public stakingDepositFee;
    uint256 public totalLockedFee;

    uint256 public minumumStakingAmount;
    uint256 public maximumStakingAmount;
    uint256 public maxStakingSlotsPerUser;

    uint256 public totalStakes;
    uint256 public totalUniqueStakers;
    mapping(address => bool) private uniqueStakers;

    uint256 public currentTokensStaked;
    uint256 public totalRewardTokensWithdrawn;
    uint256 public historicalTotalTokensStaked;

    struct StakeOption {
        bool isActive;
        uint256 IRMultiplier; // formula: 1/IR
        uint256 maturityPeriod;
        uint256 rewardInterval;
        uint256 postMaturityIRMultiplier; // formula: 1/IR
    }
    mapping(uint256 => StakeOption) public stakeOptions;

    enum StakeType {
        TOKEN,
        REWARD
    }
    struct Stake {
        StakeType stakeType;
        bool isRewardClaimed;
        uint256 maturityPeriod;
        uint256 runningPrincipal;
        uint256 runningStakeTime;
    }
    mapping(address => Stake[]) private stakes;

    event TokensStaked(
        address indexed staker,
        uint256 principal,
        uint256 indexed maturityPeriod
    );
    event TokensUnstaked(
        address indexed staker,
        uint256 principal,
        uint256 indexed maturityPeriod
    );
    event RewardsClaimed(address staker, uint256 claimedRewards);

    function initialize(ISleepToken _sleepToken, ITimelock _timelock)
        public
        initializer
    {
        __Auth_init(msg.sender);
        __ReentrancyGuard_init();

        stakingDepositFee = 0;

        minumumStakingAmount = 500 ether;
        maximumStakingAmount = type(uint256).max;
        maxStakingSlotsPerUser = 50;

        sleepToken = _sleepToken;
        timelock = _timelock;
    }

    function updateStakingDepositFee(uint256 _stakingDepositFee)
        external
        onlyOwner
    {
        stakingDepositFee = _stakingDepositFee;
    }

    function updateMinimumStakingAmount(uint256 _minumumStakingAmount)
        external
        onlyOwner
    {
        minumumStakingAmount = _minumumStakingAmount;
    }

    function updateMaximumStakingAmount(uint256 _maximumStakingAmount)
        external
        onlyOwner
    {
        maximumStakingAmount = _maximumStakingAmount;
    }

    function updateMaxStakingSlotsPerUser(uint256 _maxStakingSlotsPerUser)
        external
        onlyOwner
    {
        maxStakingSlotsPerUser = _maxStakingSlotsPerUser;
    }

    function updateStakingOption(StakeOption memory _stakingOption)
        external
        onlyOwner
    {
        require(
            _stakingOption.IRMultiplier <= 100,
            "Interest rate multiplier provided is invalid"
        );
        require(
            _stakingOption.postMaturityIRMultiplier <= 100,
            "Post maturity interest rate multiplier provided is invalid"
        );

        stakeOptions[_stakingOption.maturityPeriod] = _stakingOption;
    }

    function removeUserStakingSlot(address _user, uint256 _index) internal {
        Stake[] storage userStakes = stakes[_user];

        require(
            _index < userStakes.length,
            "Cannot remove user staking slot beyond index length"
        );

        for (uint256 i = _index; i < userStakes.length - 1; i++) {
            userStakes[i] = userStakes[i + 1];
        }
        userStakes.pop();
    }

    function userRemainingStakingSlots(address _user)
        public
        view
        returns (uint256)
    {
        uint256 usedStakingSlots = stakes[_user].length;

        if (usedStakingSlots >= maxStakingSlotsPerUser) {
            return 0;
        }

        return maxStakingSlotsPerUser - usedStakingSlots;
    }

    function totalUserStakedTokens(address _user)
        external
        view
        returns (uint256)
    {
        uint256 userStakedTokenCount;

        Stake[] memory userStakes = stakes[_user];
        for (uint256 i; i < userStakes.length; i++) {
            if (userStakes[i].stakeType == StakeType.TOKEN) {
                userStakedTokenCount += userStakes[i].runningPrincipal;
            }
        }

        return userStakedTokenCount;
    }

    function hasStakeBeenMature(Stake memory _stake)
        internal
        view
        returns (bool)
    {
        return
            _stake.stakeType == StakeType.TOKEN &&
            (_stake.runningStakeTime + _stake.maturityPeriod <=
                block.timestamp ||
                _stake.isRewardClaimed);
    }

    function totalUnstakableUserTokens(address _user)
        external
        view
        returns (uint256)
    {
        uint256 unstakableTokenCount;

        Stake[] memory userStakes = stakes[_user];
        for (uint256 i; i < userStakes.length; i++) {
            if (
                hasStakeBeenMature(userStakes[i]) ||
                timelock.getNumPendingAndReadyOperations() > 0
            ) {
                unstakableTokenCount += userStakes[i].runningPrincipal;
            }
        }

        return unstakableTokenCount;
    }

    function isMaturityPeriodValid(uint256 _maturityPeriod)
        public
        view
        returns (bool)
    {
        return stakeOptions[_maturityPeriod].maturityPeriod == _maturityPeriod;
    }

    function isStakeOptionActive(uint256 _maturityPeriod)
        public
        view
        returns (bool)
    {
        return stakeOptions[_maturityPeriod].isActive;
    }

    function totalUnstakableUserTokensByMaturityPeriod(
        address _user,
        uint256 _maturityPeriod
    ) public view returns (uint256) {
        require(
            isMaturityPeriodValid(_maturityPeriod),
            "Provided maturity period is invalid"
        );

        uint256 unstakableTokenCount;

        Stake[] memory userStakes = stakes[_user];
        for (uint256 i; i < userStakes.length; i++) {
            if (
                userStakes[i].maturityPeriod == _maturityPeriod &&
                (hasStakeBeenMature(userStakes[i]) ||
                    timelock.getNumPendingAndReadyOperations() > 0)
            ) {
                unstakableTokenCount += userStakes[i].runningPrincipal;
            }
        }

        return unstakableTokenCount;
    }

    function totalClaimableUserRewards(
        address _user,
        bool _considerMaturityPeriod
    ) external view returns (uint256) {
        uint256 claimableUserRewards;

        Stake[] memory userStakes = stakes[_user];
        for (uint256 i; i < userStakes.length; i++) {
            uint256 stakeReward = getStakeRewards(
                userStakes[i],
                _considerMaturityPeriod
            );

            claimableUserRewards += stakeReward;
            if (userStakes[i].stakeType == StakeType.REWARD) {
                claimableUserRewards += userStakes[i].runningPrincipal;
            }
        }

        return claimableUserRewards;
    }

    function totalClaimableUserRewardsByMaturityPeriod(
        address _user,
        uint256 _maturityPeriod,
        bool _considerMaturityPeriod
    ) external view returns (uint256) {
        uint256 claimableUserRewards;

        Stake[] memory userStakes = stakes[_user];
        for (uint256 i; i < userStakes.length; i++) {
            if (userStakes[i].maturityPeriod != _maturityPeriod) {
                continue;
            }

            uint256 stakeReward = getStakeRewards(
                userStakes[i],
                _considerMaturityPeriod
            );

            claimableUserRewards += stakeReward;
            if (userStakes[i].stakeType == StakeType.REWARD) {
                claimableUserRewards += userStakes[i].runningPrincipal;
            }
        }

        return claimableUserRewards;
    }

    function computeCompoundInterest(
        uint256 _principal,
        uint256 _interest,
        uint256 _periods
    ) internal pure returns (uint256) {
        require(_interest <= 100, "Interest rate provided is invalid");

        // Equivalent to 0% IR.
        if (_interest == 0) {
            return _principal;
        }

        uint256 precision = 8;
        if (_periods < 7) {
            precision = _periods + 1;
        }

        uint256 s = 0;
        uint256 N = 1;
        uint256 B = 1;
        for (uint256 i = 0; i < precision; ++i) {
            s += (_principal * N) / B / (_interest**i);
            N = N * (_periods - i);
            B = B * (i + 1);
        }

        return s;
    }

    function getStakeRewards(Stake memory _stake, bool _considerMaturityPeriod)
        public
        view
        returns (uint256)
    {
        require(
            isMaturityPeriodValid(_stake.maturityPeriod),
            "Provided maturity period is invalid"
        );

        if (
            _considerMaturityPeriod &&
            !hasStakeBeenMature(_stake) &&
            timelock.getNumPendingAndReadyOperations() == 0
        ) {
            return 0;
        }

        StakeOption memory stakeOption = stakeOptions[_stake.maturityPeriod];
        uint256 timeStaked = block.timestamp - _stake.runningStakeTime;
        uint256 maturityIntervals = _stake.maturityPeriod /
            stakeOption.rewardInterval;
        uint256 numIntervalsStaked = timeStaked / stakeOption.rewardInterval;

        uint256 completedMatureIntervals = numIntervalsStaked >=
            maturityIntervals
            ? maturityIntervals
            : numIntervalsStaked;
        uint256 completedPostMaturityIntervals = numIntervalsStaked -
            completedMatureIntervals;

        uint256 postMaturityPrincipal = _stake.runningPrincipal;

        if (_stake.stakeType == StakeType.TOKEN && !_stake.isRewardClaimed) {
            uint256 rewardInMaturity = computeCompoundInterest(
                _stake.runningPrincipal,
                stakeOption.IRMultiplier,
                completedMatureIntervals
            );
            postMaturityPrincipal = rewardInMaturity;
        } else {
            completedPostMaturityIntervals += completedMatureIntervals;
        }

        uint256 rewardPostMaturity = computeCompoundInterest(
            postMaturityPrincipal,
            stakeOption.postMaturityIRMultiplier,
            completedPostMaturityIntervals
        );

        uint256 totalReward = rewardPostMaturity - _stake.runningPrincipal;

        return totalReward;
    }

    function withdrawFee(uint256 _amountPercentage) external onlyOwner {
        uint256 amountToWithdraw = (totalLockedFee * _amountPercentage) / 100;
        totalLockedFee -= amountToWithdraw;
        require(
            sleepToken.transfer(msg.sender, amountToWithdraw),
            "transfer failed"
        );
    }

    function stakeTokens(uint256 _principal, uint256 _maturityPeriod)
        external
        nonReentrant
    {
        require(
            _principal >= minumumStakingAmount &&
                _principal <= maximumStakingAmount,
            "Stake amount should be within threshold"
        );

        require(
            userRemainingStakingSlots(msg.sender) > 0,
            "All staking slots have been used up"
        );

        require(
            isMaturityPeriodValid(_maturityPeriod),
            "Provided maturity period is invalid"
        );
        require(
            isStakeOptionActive(_maturityPeriod),
            "Provided stake option is inactive"
        );

        require(
            sleepToken.transferFrom(msg.sender, address(this), _principal),
            "transfer from failed"
        );
        uint256 feeAmount = (stakingDepositFee * _principal) / 100;
        totalLockedFee += feeAmount;
        uint256 feeAdjustedPrincipal = _principal - feeAmount;

        Stake memory newStake;
        newStake.stakeType = StakeType.TOKEN;
        newStake.maturityPeriod = _maturityPeriod;
        newStake.runningPrincipal = feeAdjustedPrincipal;
        newStake.runningStakeTime = block.timestamp;
        stakes[msg.sender].push(newStake);

        totalStakes += 1;
        currentTokensStaked += feeAdjustedPrincipal;
        historicalTotalTokensStaked += feeAdjustedPrincipal;

        if (!uniqueStakers[msg.sender]) {
            uniqueStakers[msg.sender] = true;
            totalUniqueStakers += 1;
        }

        emit TokensStaked(msg.sender, _principal, _maturityPeriod);
    }

    function unstakeTokens(uint256 _principal, uint256 _maturityPeriod)
        external
        nonReentrant
    {
        require(_principal > 0, "Unstaking principal has to be greater than 0");
        require(
            _principal <=
                totalUnstakableUserTokensByMaturityPeriod(
                    msg.sender,
                    _maturityPeriod
                ),
            "You can not unstake more tokens than have matured in a specific maturity period"
        );

        uint256 remainingUnstakedTokens = _principal;

        Stake[] storage userStakes = stakes[msg.sender];

        uint256 pendingStakesLen;
        Stake[] memory pendingStakes = new Stake[](userStakes.length);
        uint256 obsoleteStakesLen;
        uint256[] memory obsoleteStakes = new uint256[](userStakes.length);

        for (uint256 i; i < userStakes.length; i++) {
            if (remainingUnstakedTokens <= 0) {
                break;
            }

            if (
                userStakes[i].maturityPeriod == _maturityPeriod &&
                (hasStakeBeenMature(userStakes[i]) ||
                    timelock.getNumPendingAndReadyOperations() > 0)
            ) {
                uint256 tokensToWithdraw = (userStakes[i].runningPrincipal >=
                    remainingUnstakedTokens)
                    ? remainingUnstakedTokens
                    : userStakes[i].runningPrincipal;

                Stake memory stakeRewardQuery = userStakes[i];
                stakeRewardQuery.runningPrincipal = tokensToWithdraw;
                uint256 newRewardStakePrincipal = getStakeRewards(
                    stakeRewardQuery,
                    true
                );

                Stake memory newRewardStake;
                newRewardStake.stakeType = StakeType.REWARD;
                newRewardStake.runningStakeTime = block.timestamp;
                newRewardStake.runningPrincipal = newRewardStakePrincipal;
                newRewardStake.maturityPeriod = userStakes[i].maturityPeriod;
                pendingStakes[pendingStakesLen] = newRewardStake;
                pendingStakesLen += 1;

                if (tokensToWithdraw == userStakes[i].runningPrincipal) {
                    obsoleteStakes[obsoleteStakesLen] = i;
                    obsoleteStakesLen += 1;
                }
                if (tokensToWithdraw == remainingUnstakedTokens) {
                    userStakes[i].runningPrincipal -= remainingUnstakedTokens;
                }
                remainingUnstakedTokens -= tokensToWithdraw;
            }
        }

        require(
            remainingUnstakedTokens == 0,
            "Not enough unstakable tokens to fulfil request"
        );

        uint256 numRemoved;
        for (uint256 x; x < obsoleteStakesLen; x++) {
            removeUserStakingSlot(msg.sender, (obsoleteStakes[x] - numRemoved));
            numRemoved += 1;
        }

        for (uint256 y; y < pendingStakesLen; y++) {
            stakes[msg.sender].push(pendingStakes[y]);
        }

        currentTokensStaked -= _principal;

        require(sleepToken.transfer(msg.sender, _principal), "transfer failed");

        emit TokensUnstaked(msg.sender, _principal, _maturityPeriod);
    }

    function claimRewardsByMaturityPeriod(uint256 _maturityPeriod)
        external
        nonReentrant
    {
        uint256 userRewardCount;

        Stake[] storage userStakes = stakes[msg.sender];

        uint256 obsoleteStakesLen;
        uint256[] memory obsoleteStakes = new uint256[](userStakes.length);

        for (uint256 i; i < userStakes.length; i++) {
            if (userStakes[i].maturityPeriod != _maturityPeriod) {
                continue;
            }

            uint256 stakeReward = getStakeRewards(userStakes[i], true);

            if (userStakes[i].stakeType == StakeType.REWARD) {
                userRewardCount += stakeReward + userStakes[i].runningPrincipal;
                obsoleteStakes[obsoleteStakesLen] = i;
                obsoleteStakesLen += 1;
            } else {
                if (
                    hasStakeBeenMature(userStakes[i]) ||
                    timelock.getNumPendingAndReadyOperations() > 0
                ) {
                    userStakes[i].isRewardClaimed = true;
                    userStakes[i].runningStakeTime = block.timestamp;
                    userRewardCount += stakeReward;
                }
            }
        }

        uint256 numRemoved;
        for (uint256 x; x < obsoleteStakesLen; x++) {
            removeUserStakingSlot(msg.sender, (obsoleteStakes[x] - numRemoved));
            numRemoved += 1;
        }

        totalRewardTokensWithdrawn += userRewardCount;

        sleepToken.mintRewards(msg.sender, userRewardCount);

        emit RewardsClaimed(msg.sender, userRewardCount);
    }

    function claimRewards() external nonReentrant {
        uint256 userRewardCount;

        Stake[] storage userStakes = stakes[msg.sender];

        uint256 obsoleteStakesLen;
        uint256[] memory obsoleteStakes = new uint256[](userStakes.length);

        for (uint256 i; i < userStakes.length; i++) {
            uint256 stakeReward = getStakeRewards(userStakes[i], true);

            if (userStakes[i].stakeType == StakeType.REWARD) {
                userRewardCount += stakeReward + userStakes[i].runningPrincipal;
                obsoleteStakes[obsoleteStakesLen] = i;
                obsoleteStakesLen += 1;
            } else {
                if (
                    hasStakeBeenMature(userStakes[i]) ||
                    timelock.getNumPendingAndReadyOperations() > 0
                ) {
                    userStakes[i].isRewardClaimed = true;
                    userStakes[i].runningStakeTime = block.timestamp;
                    userRewardCount += stakeReward;
                }
            }
        }

        uint256 numRemoved;
        for (uint256 x; x < obsoleteStakesLen; x++) {
            removeUserStakingSlot(msg.sender, (obsoleteStakes[x] - numRemoved));
            numRemoved += 1;
        }

        totalRewardTokensWithdrawn += userRewardCount;

        sleepToken.mintRewards(msg.sender, userRewardCount);

        emit RewardsClaimed(msg.sender, userRewardCount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITimelock {
    function getNumPendingAndReadyOperations() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISleepToken {
    function mintRewards(address recipient, uint256 rewardAmount) external;

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin implementations
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Auth is Initializable {
    address internal owner;

    mapping(address => bool) internal authorizations;

    event OwnershipTransferred(address owner);

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Auth: Caller is not the owner");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "Auth: Caller is not authorized");
        _;
    }

    function __Auth_init(address _owner) internal onlyInitializing {
        owner = _owner;
        authorizations[_owner] = true;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function authorize(address _account) public onlyOwner {
        authorizations[_account] = true;
    }

    function unauthorize(address _account) public onlyOwner {
        authorizations[_account] = false;
    }

    function isOwner(address _account) public view returns (bool) {
        return _account == owner;
    }

    function isAuthorized(address _account) public view returns (bool) {
        return authorizations[_account];
    }

    function transferOwnership(address payable _account) public onlyOwner {
        owner = _account;
        authorizations[_account] = true;
        emit OwnershipTransferred(_account);
    }
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
     * @dev This empty reserved space is put in place to allow future versions to add new
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