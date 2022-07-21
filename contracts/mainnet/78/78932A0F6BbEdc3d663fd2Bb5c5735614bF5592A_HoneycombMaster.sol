/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at snowtrace.io on 2021-11-03
*/

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.6;
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface MintableToken is IERC20 {
    function mint(address dest, uint256 amount) external;
    function transferOwnership(address _minterAddress) external;
}

//owned by the HoneycombMaster contract
interface IHoneycombStrategy {
    // Deposit amount of tokens for 'caller' to address 'to'
    function deposit(address caller, address to, uint256 tokenAmount, uint256 shareAmount) external;
    // Transfer tokens from strategy for 'caller' to address 'to'
    function withdraw(address caller, address to, uint256 tokenAmount, uint256 shareAmount) external;
    function inCaseTokensGetStuck(IERC20 token, address to, uint256 amount) external;
    function setAllowances() external;
    function revokeAllowance(address token, address spender) external;
    function migrate(address newStrategy) external;
    function onMigration() external;
    function pendingTokens(uint256 pid, address user, uint256 amount) external view returns (address[] memory, uint256[] memory);
    function transferOwnership(address newOwner) external;
    function setPerformanceFeeBips(uint256 newPerformanceFeeBips) external;
}

interface IStakingRewards {
    function userInfo(uint256, address) external view returns (uint256, uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function lastTimeRewardApplicable() external view returns (uint256);
    function rewardPerToken() external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function getRewardForDuration() external view returns (uint256);
    function deposit(uint256 pid, uint256 amount) external;
    function withdraw(uint256 pid, uint256 amount) external;
    function stakeWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function withdraw(uint256 amount) external;
    function getReward() external;
    function pendingCake(uint256 pid, address user) external view returns (uint256);
    function exit() external;
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
        assembly {
            size := extcodesize(account)
        }
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IEarningsReferral {
    function recordReferral(address _user, address _referrer) external;
    function recordReferralCommission(address _referrer, uint256 _commission) external;
    function getReferrer(address _user) external view returns (address);
    function updateOperator(address _operator, bool _status) external;
    function drainBEP20Token(IERC20 _token, uint256 _amount, address _to) external;
}

contract HoneycombStrategyBase is IHoneycombStrategy, Ownable {
    using SafeERC20 for IERC20;

    HoneycombMaster public immutable honeycombMaster;
    IERC20 public immutable depositToken;
    uint256 public performanceFeeBips;
    uint256 internal constant MAX_UINT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint256 internal constant ACC_EARNING_PRECISION = 1e18;
    uint256 internal constant MAX_BIPS = 10000;

    constructor(
        HoneycombMaster _honeycombMaster,
        IERC20 _depositToken
        ){
        honeycombMaster = _honeycombMaster;
        depositToken = _depositToken;
        transferOwnership(address(_honeycombMaster));
    }

    //returns zero address and zero tokens since base strategy does not distribute rewards
    function pendingTokens(uint256, address, uint256) external view virtual override
        returns (address[] memory, uint256[] memory) {
        address[] memory _rewardTokens = new address[](1);
        _rewardTokens[0] = address(0);
        uint256[] memory _pendingAmounts = new uint256[](1);
        _pendingAmounts[0] = 0;
        return(_rewardTokens, _pendingAmounts);
    }

    function deposit(address, address, uint256, uint256) external virtual override onlyOwner {
    }

    function withdraw(address, address to, uint256 tokenAmount, uint256) external virtual override onlyOwner {
        if (tokenAmount > 0) {
            depositToken.safeTransfer(to, tokenAmount);
        }
    }

    function inCaseTokensGetStuck(IERC20 token, address to, uint256 amount) external virtual override onlyOwner {
        require(amount > 0, "cannot recover 0 tokens");
        require(address(token) != address(depositToken), "cannot recover deposit token");
        token.safeTransfer(to, amount);
    }

    function setAllowances() external virtual override onlyOwner {
    }

    /**
     * @notice Revoke token allowance
     * @param token address
     * @param spender address
     */
    function revokeAllowance(address token, address spender) external virtual override onlyOwner {
        IERC20(token).safeApprove(spender, 0);
    }

    function migrate(address newStrategy) external virtual override onlyOwner {
        uint256 toTransfer = depositToken.balanceOf(address(this));
        depositToken.safeTransfer(newStrategy, toTransfer);
    }

    function onMigration() external virtual override onlyOwner {
    }

    function transferOwnership(address newOwner) public virtual override(Ownable, IHoneycombStrategy) onlyOwner {
        Ownable.transferOwnership(newOwner);
    }

    function setPerformanceFeeBips(uint256 newPerformanceFeeBips) external virtual override onlyOwner {
        require(newPerformanceFeeBips <= MAX_BIPS, "input too high");
        performanceFeeBips = newPerformanceFeeBips;
    }
}

//owned by an HoneycombStrategy contract
contract HoneycombStrategyStorage is Ownable {
    //scaled up by ACC_EARNING_PRECISION
    uint256 public rewardTokensPerShare;
    uint256 internal constant ACC_EARNING_PRECISION = 1e18;

    //pending reward = (user.amount * rewardTokensPerShare) / ACC_EARNING_PRECISION - user.rewardDebt
    mapping(address => uint256) public rewardDebt;

    function increaseRewardDebt(address user, uint256 shareAmount) external onlyOwner {
        rewardDebt[user] += (rewardTokensPerShare * shareAmount) / ACC_EARNING_PRECISION;
    }

    function decreaseRewardDebt(address user, uint256 shareAmount) external onlyOwner {
        rewardDebt[user] -= (rewardTokensPerShare * shareAmount) / ACC_EARNING_PRECISION;
    }

    function setRewardDebt(address user, uint256 userShares) external onlyOwner {
        rewardDebt[user] = (rewardTokensPerShare * userShares) / ACC_EARNING_PRECISION;
    }

    function increaseRewardTokensPerShare(uint256 amount) external onlyOwner {
        rewardTokensPerShare += amount;
    }
}

contract HoneycombStrategyForPancake is HoneycombStrategyBase {
    using SafeERC20 for IERC20;

    IERC20 public constant rewardToken = IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82); //CAKE token
    IStakingRewards public immutable stakingContract;
    HoneycombStrategyStorage public immutable honeycombStrategyStorage;
    uint256 public immutable pid;
    uint256 public immutable pidHoneycomb;
    //total harvested by the contract all time
    uint256 public totalHarvested;

    //total amount harvested by each user
    mapping(address => uint256) public harvested;

    event Harvest(address indexed caller, address indexed to, uint256 harvestedAmount);

    constructor(
        HoneycombMaster _honeycombMaster,
        IERC20 _depositToken,
        uint256 _pid,
        uint256 _pidHoneycomb,
        IStakingRewards _stakingContract
        )
        HoneycombStrategyBase(_honeycombMaster, _depositToken)
    {
        pid = _pid;
        pidHoneycomb = _pidHoneycomb;
        stakingContract = _stakingContract;
        honeycombStrategyStorage = new HoneycombStrategyStorage();
        _depositToken.safeApprove(address(_stakingContract), MAX_UINT);
    }

    //PUBLIC FUNCTIONS
    /**
    * @notice Reward token balance that can be claimed
    * @dev Staking rewards accrue to contract on each deposit/withdrawal
    * @return Unclaimed rewards
    */
    function checkReward() public view returns (uint256) {
        return stakingContract.pendingCake(pid, address(this));
    }

    function pendingRewards(address user) public view returns (uint256) {
        uint256 userShares = honeycombMaster.userShares(pidHoneycomb, user);
        uint256 unclaimedRewards = checkReward();
        uint256 rewardTokensPerShare = honeycombStrategyStorage.rewardTokensPerShare();
        uint256 totalShares = honeycombMaster.totalShares(pidHoneycomb);
        uint256 userRewardDebt = honeycombStrategyStorage.rewardDebt(user);
        uint256 multiplier =  rewardTokensPerShare;
        if(totalShares > 0) {
            multiplier = multiplier + ((unclaimedRewards * ACC_EARNING_PRECISION) / totalShares);
        }
        uint256 totalRewards = (userShares * multiplier) / ACC_EARNING_PRECISION;
        uint256 userPendingRewards = (totalRewards >= userRewardDebt) ?  (totalRewards - userRewardDebt) : 0;
        return userPendingRewards;
    }

    function rewardTokens() external view virtual returns(address[] memory) {
        address[] memory _rewardTokens = new address[](1);
        _rewardTokens[0] = address(rewardToken);
        return(_rewardTokens);
    }

    function pendingTokens(uint256, address user, uint256) external view override
        returns (address[] memory, uint256[] memory) {
        address[] memory _rewardTokens = new address[](1);
        _rewardTokens[0] = address(rewardToken);
        uint256[] memory _pendingAmounts = new uint256[](1);
        _pendingAmounts[0] = pendingRewards(user);
        return(_rewardTokens, _pendingAmounts);
    }

    //EXTERNAL FUNCTIONS
    function harvest() external {
        _claimRewards();
        _harvest(msg.sender, msg.sender);
    }

    //OWNER-ONlY FUNCTIONS
    function deposit(address caller, address to, uint256 tokenAmount, uint256 shareAmount) external override onlyOwner {
        _claimRewards();
        _harvest(caller, to);
        if (tokenAmount > 0) {
            stakingContract.deposit(pid, tokenAmount);
        }
        if (shareAmount > 0) {
            honeycombStrategyStorage.increaseRewardDebt(to, shareAmount);
        }
    }

    function withdraw(address caller, address to, uint256 tokenAmount, uint256 shareAmount) external override onlyOwner {
        _claimRewards();
        _harvest(caller, to);
        if (tokenAmount > 0) {
            stakingContract.withdraw(pid, tokenAmount);
            depositToken.safeTransfer(to, tokenAmount);
        }
        if (shareAmount > 0) {
            honeycombStrategyStorage.decreaseRewardDebt(to, shareAmount);
        }
    }

    function migrate(address newStrategy) external override onlyOwner {
        _claimRewards();
        (uint256 toWithdraw, ) = stakingContract.userInfo(pid, address(this));
        if (toWithdraw > 0) {
            stakingContract.withdraw(pid, toWithdraw);
            depositToken.safeTransfer(newStrategy, toWithdraw);
        }
        uint256 rewardsToTransfer = rewardToken.balanceOf(address(this));
        if (rewardsToTransfer > 0) {
            rewardToken.safeTransfer(newStrategy, rewardsToTransfer);
        }
        honeycombStrategyStorage.transferOwnership(newStrategy);
    }

    function onMigration() external override onlyOwner {
        uint256 toStake = depositToken.balanceOf(address(this));
        stakingContract.deposit(pid, toStake);
    }

    function setAllowances() external override onlyOwner {
        depositToken.safeApprove(address(stakingContract), 0);
        depositToken.safeApprove(address(stakingContract), MAX_UINT);
    }

    //INTERNAL FUNCTIONS
    //claim any as-of-yet unclaimed rewards
    function _claimRewards() internal {
        uint256 unclaimedRewards = checkReward();
        uint256 totalShares = honeycombMaster.totalShares(pidHoneycomb);
        if (unclaimedRewards > 0 && totalShares > 0) {
            stakingContract.deposit(pid, 0);
            honeycombStrategyStorage.increaseRewardTokensPerShare((unclaimedRewards * ACC_EARNING_PRECISION) / totalShares);
        }
    }

    function _harvest(address caller, address to) internal {
        uint256 userShares = honeycombMaster.userShares(pidHoneycomb, caller);
        uint256 totalRewards = (userShares * honeycombStrategyStorage.rewardTokensPerShare()) / ACC_EARNING_PRECISION;
        uint256 userRewardDebt = honeycombStrategyStorage.rewardDebt(caller);
        uint256 userPendingRewards = (totalRewards >= userRewardDebt) ?  (totalRewards - userRewardDebt) : 0;
        honeycombStrategyStorage.setRewardDebt(caller, userShares);
        if (userPendingRewards > 0) {
            totalHarvested += userPendingRewards;
            if (performanceFeeBips > 0) {
                uint256 performanceFee = (userPendingRewards * performanceFeeBips) / MAX_BIPS;
                _safeRewardTokenTransfer(honeycombMaster.performanceFeeAddress(), performanceFee);
                userPendingRewards = userPendingRewards - performanceFee;
            }
            harvested[to] += userPendingRewards;
            emit Harvest(caller, to, userPendingRewards);
            _safeRewardTokenTransfer(to, userPendingRewards);
        }
    }

    //internal wrapper function to avoid reverts due to rounding
    function _safeRewardTokenTransfer(address user, uint256 amount) internal {
        uint256 rewardTokenBal = rewardToken.balanceOf(address(this));
        if (amount > rewardTokenBal) {
            rewardToken.safeTransfer(user, rewardTokenBal);
        } else {
            rewardToken.safeTransfer(user, amount);
        }
    }
}

// The HoneycombMaster is the master of rewards. He can make reward and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once reward is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract HoneycombMaster is Ownable {
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many shares the user currently has
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 lastDepositTimestamp; // Timestamp of the last deposit.
        
        //
        // We do some fancy math here. Basically, any point in time, the amount of Rewards
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accEarningPerShare) / ACC_EARNING_PRECISION - user.rewardDebt
        //
        // Whenever a user harvest from a pool, here's what happens:
        //   1. The pool's `accEarningPerShare` gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 want; // Address of LP token contract.
        IHoneycombStrategy strategy; // Address of strategy for pool
        uint256 allocPoint; // How many allocation points assigned to this pool. earnings to distribute per block.
        uint256 lastRewardTime; // Last block number that earnings distribution occurs.
        uint256 accEarningPerShare; // Accumulated earnings per share, times ACC_EARNING_PRECISION. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint256 totalShares; //total number of shares in the pool
        uint256 lpPerShare; //number of LP tokens per share, times ACC_EARNING_PRECISION
        bool isWithdrawFee;      // if the pool has withdraw fee
    }

    // The main reward token!
    MintableToken public immutable earningToken;
    // The block when mining starts.
    uint256 public startTime;
    //development endowment
    address public dev;
    //performance fee address -- receives performance fees from strategies
    address public performanceFeeAddress;
    // amount of reward emitted per second
    uint256 public earningsPerSecond;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    //allocations to dev and nest addresses, expressed in BIPS
    uint256 public devMintBips = 1000;
    //whether the onlyApprovedContractOrEOA is turned on or off
    bool public onlyApprovedContractOrEOAStatus;

    uint256 internal constant ACC_EARNING_PRECISION = 1e18;
    uint256 internal constant MAX_BIPS = 10000;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    //mappping for tracking contracts approved to build on top of this one
    mapping(address => bool) public approvedContracts;
    //tracks historic deposits of each address. deposits[pid][user] is the total deposits for that user to that honeycomb
    mapping(uint256 => mapping(address => uint256)) public deposits;
    //tracks historic withdrawals of each address. withdrawals[pid][user] is the total withdrawals for that user from that honeycomb
    mapping(uint256 => mapping(address => uint256)) public withdrawals;

    uint256[] public withdrawalFeeIntervals = [1];
    uint16[] public withdrawalFeeBP = [0, 0];
    uint16 public constant MAX_WITHDRAWAL_FEE_BP = 300;
    uint16 public constant MAX_DEPOSIT_FEE_BP = 400;
    
    // Earnings referral contract address.
    IEarningsReferral public earningReferral;
    // Referral commission rate in basis points.
    uint16 public referralCommissionRate = 300;
    // Max referral commission rate: 20%.
    uint16 public constant MAXIMUM_REFERRAL_COMMISSION_RATE = 2000;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event DevSet(address indexed oldAddress, address indexed newAddress);
    event PerformanceFeeAddressSet(address indexed oldAddress, address indexed newAddress);
    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);

    /**
     * @notice Throws if called by smart contract
     */
    modifier onlyApprovedContractOrEOA() {
        if (onlyApprovedContractOrEOAStatus) {
            require(tx.origin == msg.sender || approvedContracts[msg.sender], "HoneycombMaster::onlyApprovedContractOrEOA");
        }
        _;
    }

    constructor(
        MintableToken _earningToken,
        uint256 _startTime,
        address _dev,
        address _performanceFeeAddress,
        uint256 _earningsPerSecond
    ) {
        require(_startTime > block.timestamp, "must start in future");
        earningToken = _earningToken;
        startTime = _startTime;
        dev = _dev;
        performanceFeeAddress = _performanceFeeAddress;
        earningsPerSecond = _earningsPerSecond;
        emit DevSet(address(0), _dev);
        emit PerformanceFeeAddressSet(address(0), _performanceFeeAddress);
    }

    //VIEW FUNCTIONS
    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    // View function to see total pending reward in = on frontend.
    function pendingEarnings(uint256 pid, address userAddr) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][userAddr];
        uint256 accEarningPerShare = pool.accEarningPerShare;
        uint256 poolShares = pool.totalShares;
        if (block.timestamp > pool.lastRewardTime && poolShares != 0) {
            uint256 earningsReward = (reward(pool.lastRewardTime, block.timestamp) * pool.allocPoint) / totalAllocPoint;
            accEarningPerShare = accEarningPerShare + (
                (earningsReward * ACC_EARNING_PRECISION) / poolShares
            );
        }
        return ((user.amount * accEarningPerShare) / ACC_EARNING_PRECISION) - user.rewardDebt;
    }

    // view function to get all pending rewards, from HoneycombMaster, Strategy, and Rewarder
    function pendingTokens(uint256 pid, address user) external view
        returns (address[] memory, uint256[] memory) {
        uint256 earningAmount = pendingEarnings(pid, user);
        (address[] memory strategyTokens, uint256[] memory strategyRewards) =
            poolInfo[pid].strategy.pendingTokens(pid, user, earningAmount);

        uint256 rewardsLength = 1;
        for (uint256 j = 0; j < strategyTokens.length; j++) {
            if (strategyTokens[j] != address(0)) {
                rewardsLength += 1;
            }
        }
        address[] memory _rewardTokens = new address[](rewardsLength);
        uint256[] memory _pendingAmounts = new uint256[](rewardsLength);
        _rewardTokens[0] = address(earningToken);
        _pendingAmounts[0] = pendingEarnings(pid, user);
        for (uint256 m = 0; m < strategyTokens.length; m++) {
            if (strategyTokens[m] != address(0)) {
                _rewardTokens[m + 1] = strategyTokens[m];
                _pendingAmounts[m + 1] = strategyRewards[m];
            }
        }
        return(_rewardTokens, _pendingAmounts);
    }

    // Return reward over the period _from to _to.
    function reward(uint256 _lastRewardTime, uint256 _currentTime) public view returns (uint256) {
        return ((_currentTime - _lastRewardTime) * earningsPerSecond);
    }

    //convenience function to get the yearly emission of reward at the current emission rate
    function earningPerYear() public view returns(uint256) {
        //31536000 = seconds per year = 365 * 24 * 60 * 60
        return (earningsPerSecond * 31536000);
    }

    //convenience function to get the yearly emission of reward at the current emission rate, to a given honeycomb
    function earningPerYearToHoneycomb(uint256 pid) public view returns(uint256) {
        return ((earningPerYear() * poolInfo[pid].allocPoint) / totalAllocPoint);
    }

    //convenience function to get the total number of shares in an honeycomb
    function totalShares(uint256 pid) public view returns(uint256) {
        return poolInfo[pid].totalShares;
    }

    //convenience function to get the total amount of LP tokens in an honeycomb
    function totalLP(uint256 pid) public view returns(uint256) {
        return (poolInfo[pid].lpPerShare * totalShares(pid) / ACC_EARNING_PRECISION);
    }

    //convenience function to get the shares of a single user in an honeycomb
    function userShares(uint256 pid, address user) public view returns(uint256) {
        return userInfo[pid][user].amount;
    }

    //WRITE FUNCTIONS
    /// @notice Update reward variables of the given pool.
    /// @param pid The index of the pool. See `poolInfo`.
    function updatePool(uint256 pid) public {
        PoolInfo storage pool = poolInfo[pid];
        if (block.timestamp > pool.lastRewardTime) {
            uint256 poolShares = pool.totalShares;
            if (poolShares == 0 || pool.allocPoint == 0) {
                pool.lastRewardTime = block.timestamp;
                return;
            }
            uint256 earningReward = (reward(pool.lastRewardTime, block.timestamp) * pool.allocPoint) / totalAllocPoint;
            pool.lastRewardTime = block.timestamp;
            if (earningReward > 0) {
                uint256 toDev = (earningReward * devMintBips) / MAX_BIPS;
                pool.accEarningPerShare = pool.accEarningPerShare + (
                    (earningReward * ACC_EARNING_PRECISION) / poolShares
                );
                earningToken.mint(dev, toDev);
                earningToken.mint(address(this), earningReward);
            }
        }
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /// @notice Deposit LP tokens to HoneycombMaster for reward allocation.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amount LP token amount to deposit.
    /// @param to The receiver of `amount` deposit benefit.
    function deposit(uint256 pid, uint256 amount, address to, address _referrer) external onlyApprovedContractOrEOA {
        uint256 totalAmount = amount;
        updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];
        if (amount > 0) {
            UserInfo storage user = userInfo[pid][to];
            
            if (address(earningReferral) != address(0) && _referrer != address(0) && _referrer != msg.sender) {
                earningReferral.recordReferral(msg.sender, _referrer);
            }
            
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = amount * pool.depositFeeBP / 10000;
                pool.want.safeTransfer(performanceFeeAddress, depositFee);
                amount = amount - depositFee;
            }

            //find number of new shares from amount
            uint256 newShares = (amount * ACC_EARNING_PRECISION) / pool.lpPerShare;

            //transfer tokens directly to strategy
            pool.want.safeTransferFrom(
                address(msg.sender),
                address(pool.strategy),
                amount
            );
            //tell strategy to deposit newly transferred tokens and process update
            pool.strategy.deposit(msg.sender, to, amount, newShares);

            //track new shares
            pool.totalShares = pool.totalShares + newShares;
            user.amount = user.amount + newShares;
            user.rewardDebt = user.rewardDebt + ((newShares * pool.accEarningPerShare) / ACC_EARNING_PRECISION);
            user.lastDepositTimestamp = block.timestamp;
            //track deposit for profit tracking
            deposits[pid][to] += totalAmount;

            emit Deposit(msg.sender, pid, totalAmount, to);
        }
    }

    /// @notice Withdraw LP tokens from HoneycombMaster.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amountShares amount of shares to withdraw.
    /// @param to Receiver of the LP tokens.
    function withdraw(uint256 pid, uint256 amountShares, address to) external onlyApprovedContractOrEOA {
        updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount >= amountShares, "withdraw: not good");

        if (amountShares > 0) {
            //find amount of LP tokens from shares
            uint256 lpFromShares = (amountShares * pool.lpPerShare) / ACC_EARNING_PRECISION;

            if (pool.isWithdrawFee) {
                uint16 withdrawFeeBP = getWithdrawFee(pid, msg.sender);
                if (withdrawFeeBP > 0) {
                    uint256 withdrawFee = lpFromShares * withdrawFeeBP / 10000;
                    uint256 withdrawFeeShare = amountShares * withdrawFeeBP / 10000;
                    pool.strategy.withdraw(msg.sender, performanceFeeAddress, withdrawFee, withdrawFeeShare);
                    lpFromShares = lpFromShares - withdrawFee;
                    amountShares = amountShares - withdrawFeeShare;
                }
            }

            if (pool.totalShares > amountShares) {
                uint256 lpToSend = lpFromShares;
                //track withdrawal for profit tracking
                withdrawals[pid][to] += lpToSend;
                //tell strategy to withdraw lpTokens, send to 'to', and process update
                pool.strategy.withdraw(msg.sender, to, lpToSend, amountShares);
                //increase price per share based on redistributed LP amount
                pool.lpPerShare = pool.lpPerShare + (ACC_EARNING_PRECISION / (pool.totalShares - amountShares));
            } else {
                //track withdrawal for profit tracking
                withdrawals[pid][to] += lpFromShares;
                //tell strategy to withdraw lpTokens, send to 'to', and process update
                pool.strategy.withdraw(msg.sender, to, lpFromShares, amountShares);
            }

            //track removed shares
            user.amount = user.amount - amountShares;
            uint256 rewardDebtOfShares = ((amountShares * pool.accEarningPerShare) / ACC_EARNING_PRECISION);
            uint256 userRewardDebt = user.rewardDebt;
            user.rewardDebt = (userRewardDebt >= rewardDebtOfShares) ?
                (userRewardDebt - rewardDebtOfShares) : 0;
            pool.totalShares = pool.totalShares - amountShares;

            emit Withdraw(msg.sender, pid, amountShares, to);
        }
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param to Receiver of rewards.
    function harvest(uint256 pid, address to) external onlyApprovedContractOrEOA {
        updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        //find all time rewards for all of user's shares
        uint256 accumulatedEarnings = (user.amount * pool.accEarningPerShare) / ACC_EARNING_PRECISION;
        //subtract out the rewards they have already been entitled to
        uint256 pendings = accumulatedEarnings - user.rewardDebt;
        //update user reward debt
        user.rewardDebt = accumulatedEarnings;

        //send remainder as reward
        if (pendings > 0) {
            safeEarningsTransfer(to, pendings);
            payReferralCommission(msg.sender, pendings);
        }

        //call strategy to update
        pool.strategy.withdraw(msg.sender, to, 0, 0);

        emit Harvest(msg.sender, pid, pendings);
    }

    /// @notice Withdraw LP tokens from HoneycombMaster.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amountShares amount of shares to withdraw.
    /// @param to Receiver of the LP tokens.
    function withdrawAndHarvest(uint256 pid, uint256 amountShares, address to) external onlyApprovedContractOrEOA {
        updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount >= amountShares, "withdraw: not good");

        //find all time rewards for all of user's shares
        uint256 accumulatedEarnings = (user.amount * pool.accEarningPerShare) / ACC_EARNING_PRECISION;
        //subtract out the rewards they have already been entitled to
        uint256 pendings = accumulatedEarnings - user.rewardDebt;
        //find amount of LP tokens from shares
        uint256 lpToSend = (amountShares * pool.lpPerShare) / ACC_EARNING_PRECISION;

        if (pool.isWithdrawFee) {
            uint16 withdrawFeeBP = getWithdrawFee(pid, msg.sender);
            if (withdrawFeeBP > 0) {
                uint256 withdrawFee = lpToSend * withdrawFeeBP / 10000;
                uint256 withdrawFeeShare = amountShares * withdrawFeeBP / 10000;
                pool.strategy.withdraw(msg.sender, performanceFeeAddress, withdrawFee, withdrawFeeShare);
                lpToSend = lpToSend - withdrawFee;
                amountShares = amountShares - withdrawFeeShare;
            }
        }

        if (pool.totalShares > amountShares) {
            //track withdrawal for profit tracking
            withdrawals[pid][to] += lpToSend;
            //tell strategy to withdraw lpTokens, send to 'to', and process update
            pool.strategy.withdraw(msg.sender, to, lpToSend, amountShares);
            //increase price per share based on redistributed LP amount
            pool.lpPerShare = pool.lpPerShare + (ACC_EARNING_PRECISION / (pool.totalShares - amountShares));
        } else {
            //track withdrawal for profit tracking
            withdrawals[pid][to] += lpToSend;
            //tell strategy to withdraw lpTokens, send to 'to', and process update
            pool.strategy.withdraw(msg.sender, to, lpToSend, amountShares);
        }

        //track removed shares
        user.amount = user.amount - amountShares;
        uint256 rewardDebtOfShares = ((amountShares * pool.accEarningPerShare) / ACC_EARNING_PRECISION);
        user.rewardDebt = accumulatedEarnings - rewardDebtOfShares;
        pool.totalShares = pool.totalShares - amountShares;

        //handle rewards
        if (pendings > 0) {
            safeEarningsTransfer(to, pendings);
            payReferralCommission(msg.sender, pendings);
        }

        emit Withdraw(msg.sender, pid, amountShares, to);
        emit Harvest(msg.sender, pid, pendings);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(uint256 pid, address to) external onlyApprovedContractOrEOA {
        //skip pool update
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 amountShares = user.amount;
        //find amount of LP tokens from shares
        uint256 lpFromShares = (amountShares * pool.lpPerShare) / ACC_EARNING_PRECISION;

        if (pool.isWithdrawFee) {
            uint16 withdrawFeeBP = getWithdrawFee(pid, msg.sender);
            if (withdrawFeeBP > 0) {
                uint256 withdrawFee = lpFromShares * withdrawFeeBP / 10000;
                uint256 withdrawFeeShare = amountShares * withdrawFeeBP / 10000;
                pool.strategy.withdraw(msg.sender, performanceFeeAddress, withdrawFee, withdrawFeeShare);
                lpFromShares = lpFromShares - withdrawFee;
                amountShares = amountShares - withdrawFeeShare;
            }
        }

        if (pool.totalShares > amountShares) {
            uint256 lpToSend = lpFromShares;
            //track withdrawal for profit tracking
            withdrawals[pid][to] += lpToSend;
            //tell strategy to withdraw lpTokens, send to 'to', and process update
            pool.strategy.withdraw(msg.sender, to, lpToSend, amountShares);
            //increase price per share based on redistributed LP amount
            pool.lpPerShare = pool.lpPerShare + (ACC_EARNING_PRECISION / (pool.totalShares - amountShares));
        } else {
            //track withdrawal for profit tracking
            withdrawals[pid][to] += lpFromShares;
            //tell strategy to withdraw lpTokens, send to 'to', and process update
            pool.strategy.withdraw(msg.sender, to, lpFromShares, amountShares);
        }

        //track removed shares
        user.amount = 0;
        user.rewardDebt = 0;
        pool.totalShares = pool.totalShares - amountShares;

        emit EmergencyWithdraw(msg.sender, pid, amountShares, to);
    }

    //OWNER-ONLY FUNCTIONS
    /// @notice Add a new LP to the pool. Can only be called by the owner.
    /// @param _allocPoint AP of the new pool.
    /// @param _want Address of the LP ERC-20 token.
    /// @param _withUpdate True if massUpdatePools should be called prior to pool updates.
    function add(uint256 _allocPoint, uint16 _depositFeeBP, IERC20 _want, bool _withUpdate,
        bool _isWithdrawFee, IHoneycombStrategy _strategy)
        external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTime =
            block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                want: _want,
                strategy: _strategy,
                allocPoint: _allocPoint,
                lastRewardTime: lastRewardTime,
                accEarningPerShare: 0,
                depositFeeBP: _depositFeeBP,
                isWithdrawFee: _isWithdrawFee,
                totalShares: 0,
                lpPerShare: ACC_EARNING_PRECISION
            })
        );
    }

    /// @notice Update the given pool's reward allocation point, withdrawal fee, and `IRewarder` contract. Can only be called by the owner.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _allocPoint New AP of the pool.
    /// @param _withUpdate True if massUpdatePools should be called prior to pool updates.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        bool _withUpdate,
        bool _isWithdrawFee
    ) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = (totalAllocPoint - poolInfo[_pid].allocPoint) + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].isWithdrawFee = _isWithdrawFee;
    }

    //used to migrate an honeycomb from using one strategy to another
    function migrateStrategy(uint256 pid, IHoneycombStrategy newStrategy) external onlyOwner {
        PoolInfo storage pool = poolInfo[pid];
        //migrate funds from old strategy to new one
        pool.strategy.migrate(address(newStrategy));
        //update strategy in storage
        pool.strategy = newStrategy;
        newStrategy.onMigration();
    }

    //used in emergencies, or if setup of an honeycomb fails
    function setStrategy(uint256 pid, IHoneycombStrategy newStrategy, bool transferOwnership, address newOwner)
        external onlyOwner {
        PoolInfo storage pool = poolInfo[pid];
        if (transferOwnership) {
            pool.strategy.transferOwnership(newOwner);
        }
        pool.strategy = newStrategy;
    }

    function manualMint(address dest, uint256 amount) external onlyOwner {
        earningToken.mint(dest, amount);
    }

    function transferMinter(address newMinter) external onlyOwner {
        require(newMinter != address(0));
        earningToken.transferOwnership(newMinter);
    }

    function setDev(address _dev) external onlyOwner {
        require(_dev != address(0));
        emit DevSet(dev, _dev);
        dev = _dev;
    }

    function setPerfomanceFeeAddress(address _performanceFeeAddress) external onlyOwner {
        require(_performanceFeeAddress != address(0));
        emit PerformanceFeeAddressSet(performanceFeeAddress, _performanceFeeAddress);
        performanceFeeAddress = _performanceFeeAddress;
    }

    function setDevMintBips(uint256 _devMintBips) external onlyOwner {
        require(_devMintBips <= MAX_BIPS, "combined dev & nest splits too high");
        devMintBips = _devMintBips;
    }

    function setEarningsEmission(uint256 newEarningsPerSecond, bool withUpdate) external onlyOwner {
        if (withUpdate) {
            massUpdatePools();
        }
        earningsPerSecond = newEarningsPerSecond;
    }

    //ACCESS CONTROL FUNCTIONS
    function modifyApprovedContracts(address[] calldata contracts, bool[] calldata statuses) external onlyOwner {
        require(contracts.length == statuses.length, "input length mismatch");
        for (uint256 i = 0; i < contracts.length; i++) {
            approvedContracts[contracts[i]] = statuses[i];
        }
    }

    function setOnlyApprovedContractOrEOAStatus(bool newStatus) external onlyOwner {
        onlyApprovedContractOrEOAStatus = newStatus;
    }

    //STRATEGY MANAGEMENT FUNCTIONS
    function inCaseTokensGetStuck(uint256 pid, IERC20 token, address to, uint256 amount) external onlyOwner {
        IHoneycombStrategy strat = poolInfo[pid].strategy;
        strat.inCaseTokensGetStuck(token, to, amount);
    }

    function setAllowances(uint256 pid) external onlyOwner {
        IHoneycombStrategy strat = poolInfo[pid].strategy;
        strat.setAllowances();
    }

    function revokeAllowance(uint256 pid, address token, address spender) external onlyOwner {
        IHoneycombStrategy strat = poolInfo[pid].strategy;
        strat.revokeAllowance(token, spender);
    }

    function setPerformanceFeeBips(uint256 pid, uint256 newPerformanceFeeBips) external onlyOwner {
        IHoneycombStrategy strat = poolInfo[pid].strategy;
        strat.setPerformanceFeeBips(newPerformanceFeeBips);
    }

    //STRATEGY-ONLY FUNCTIONS
    //an autocompounding strategy calls this function to account for new LP tokens that it earns
    function accountAddedLP(uint256 pid, uint256 amount) external {
        PoolInfo storage pool = poolInfo[pid];
        require(msg.sender == address(pool.strategy), "only callable by strategy contract");
        pool.lpPerShare = pool.lpPerShare + ((amount * ACC_EARNING_PRECISION) / pool.totalShares);
    }

    //INTERNAL FUNCTIONS
    // Safe reward transfer function, just in case if rounding error causes pool to not have enough earnings.
    function safeEarningsTransfer(address _to, uint256 _amount) internal {
        uint256 earningsBal = earningToken.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > earningsBal) {
            earningToken.mint(address(this), _amount - earningsBal);
        }
        transferSuccess = earningToken.transfer(_to, _amount);
        require(transferSuccess, "safeEarningsTransfer: transfer failed");
    }
    
    function getWithdrawFee(uint256 _pid, address _user) public view returns (uint16) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        if (!pool.isWithdrawFee)
            return 0;
        uint256 elapsed = block.timestamp - user.lastDepositTimestamp;
        uint i = 0;
        for (; i < withdrawalFeeIntervals.length; i++) {
            if (elapsed < withdrawalFeeIntervals[i])
                break;
        }
        return withdrawalFeeBP[i];
    }
    
    function setWithdrawFee(uint256[] memory _withdrawalFeeIntervals, uint16[] memory _withdrawalFeeBP) public onlyOwner {
        require (_withdrawalFeeIntervals.length + 1 == _withdrawalFeeBP.length, 'setWithdrawFee: _withdrawalFeeBP length is one more than _withdrawalFeeIntervals length');
        require (_withdrawalFeeBP.length > 0, 'setWithdrawFee: _withdrawalFeeBP length is one more than 0');
        for (uint i = 0; i < _withdrawalFeeIntervals.length - 1; i++) {
            require (_withdrawalFeeIntervals[i] < _withdrawalFeeIntervals[i + 1], 'setWithdrawFee: The interval must be ascending');
        }
        for (uint i = 0; i < _withdrawalFeeBP.length; i++) {
            require (_withdrawalFeeBP[i] <= MAX_WITHDRAWAL_FEE_BP, 'setWithdrawFee: invalid withdrawal fee basis points');
        }
        withdrawalFeeIntervals = _withdrawalFeeIntervals;
        withdrawalFeeBP = _withdrawalFeeBP;
    }
    
    // Update the earning referral contract address by the owner
    function setEarningsReferral(IEarningsReferral _earningReferral) public onlyOwner {
        earningReferral = _earningReferral;
    }

    // Update referral commission rate by the owner
    function setReferralCommissionRate(uint16 _referralCommissionRate) public onlyOwner {
        require(_referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE, "setReferralCommissionRate: invalid referral commission rate basis points");
        referralCommissionRate = _referralCommissionRate;
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _user, uint256 _pending) internal {
        if (address(earningReferral) != address(0) && referralCommissionRate > 0) {
            address referrer = earningReferral.getReferrer(_user);
            uint256 commissionAmount = _pending * referralCommissionRate / 10000;

            if (referrer != address(0) && commissionAmount > 0) {
                earningToken.mint(referrer, commissionAmount);
                earningReferral.recordReferralCommission(referrer, commissionAmount);
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }
}