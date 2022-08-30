// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

/**
 * @title A farming pool that supports one ERC20 staking token one reward token.
 * Based on the Synthetix StakingRewards contract.
 */
contract FarmingPool {
    using SafeERC20 for IERC20;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardAdded(uint256 reward);
    event RewardStartScheduled(uint256 newStartTime);
    event RewardPaid(address indexed user, uint256 reward);
    event AdminTransferred(address indexed prevAdmin, address indexed newAdmin);

    // State
    address public admin;
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    uint256 public startTime; // time in seconds when reward starts
    uint256 public endTime; // time in seconds when reward ends
    uint256 public lastUpdateTime; // last time reward info was updated
    uint256 public rewardPerTokenStored; // reward per token
    uint256 public immutable rewardRate; // how many reward tokens to give out per second
    mapping(address => uint256) public userRewardPerTokenPaid; // reward per token already paid
    mapping(address => uint256) public rewards; // stored amount of reward token to pay

    /**
     * @notice Farming pool constructor
     * @param _admin The privileged address for certain functions.
     * @param _stakingToken The stake token.
     * @param _rewardToken The reward token.
     * @param _rewardRate The amount of reward released per second.
     */
    constructor(
        address _admin,
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate
    ) {
        admin = _admin;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
    }

    /**
     * @dev Change the admin address.
     * @param _newAdmin The new admin address.
     */
    function transferAdmin(address _newAdmin) external onlyAdmin {
        emit AdminTransferred(admin, _newAdmin);
        admin = _newAdmin;
    }

    /**
     * @notice Returns the number of tokens staked by a user.
     * @param _account The account.
     */
    function balanceOf(address _account) external view returns (uint256) {
        return balances[_account];
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        if (block.timestamp < startTime) {
            return startTime;
        }
        // return smaller time
        return block.timestamp > endTime ? endTime : block.timestamp;
    }

    // Gets the amount of reward per token.
    function rewardPerToken() internal view returns (uint256 rewardPerToken_, uint256 lastTimeRewardApplicable_) {
        lastTimeRewardApplicable_ = lastTimeRewardApplicable();
        if (lastUpdateTime == 0 || totalSupply == 0) {
            rewardPerToken_ = rewardPerTokenStored;
        } else {
            rewardPerToken_ =
                rewardPerTokenStored +
                ((lastTimeRewardApplicable_ - lastUpdateTime) * rewardRate * 1e18) /
                totalSupply;
        }
        return (rewardPerToken_, lastTimeRewardApplicable_);
    }

    /**
     * @notice Returns the amount of reward token a user has earned but has not yet been paid.
     * @param _account The account.
     */
    function earned(address _account) public view returns (uint256) {
        (uint256 rewardPerToken_, ) = rewardPerToken();
        return (balances[_account] * (rewardPerToken_ - userRewardPerTokenPaid[_account])) / 1e18 + rewards[_account];
    }

    /**
     * @notice Returns the total amount of reward issued for the duration.
     */
    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * (endTime - startTime);
    }

    /**
     * @notice Stake tokens with an approval signature.
     * @param _amount The amount.
     * @param _deadline The permit deadline.
     * @param _v The signature V.
     * @param _r The signature R.
     * @param _s The signature S.
     */
    function stakeWithPermit(
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        require(_amount > 0, "Cannot stake 0");

        updateReward(msg.sender);
        IERC20 stakingToken_ = stakingToken;
        totalSupply += _amount;
        balances[msg.sender] += _amount;
        emit Staked(msg.sender, _amount);

        // permit
        IERC20Permit(address(stakingToken_)).permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);

        stakingToken_.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice Stake tokens. Requires that the FarmingPool contract is approved to transfer user's funds.
     * @param _amount The amount.
     */
    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0");

        updateReward(msg.sender);
        totalSupply += _amount;
        balances[msg.sender] += _amount;
        emit Staked(msg.sender, _amount);

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @notice Pays caller the reward tokens that have been earned.
     */
    function claimReward() public {
        uint256 rewardToPay = updateReward(msg.sender);
        if (rewardToPay > 0) {
            rewards[msg.sender] = 0;
            emit RewardPaid(msg.sender, rewardToPay);

            rewardToken.safeTransfer(msg.sender, rewardToPay);
        }
    }

    /**
     * @notice Withdraws a specific amount of staked tokens without paying any rewards.
     * @param _amount The amount.
     */
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Cannot withdraw 0");
        uint256 balance = balances[msg.sender];
        require(_amount <= balance, "Cannot withdraw more than staked");

        updateReward(msg.sender);
        totalSupply -= _amount;
        balances[msg.sender] = balance - _amount;
        emit Withdrawn(msg.sender, _amount);

        stakingToken.safeTransfer(msg.sender, _amount);
    }

    /**
     * @notice Withdraws all staked tokens without paying any rewards.
     */
    function withdrawAll() external {
        withdraw(balances[msg.sender]);
    }

    /**
     * @notice Pays all rewards and withdraws all staked tokens.
     */
    function exit() external {
        claimReward();
        uint256 amount = balances[msg.sender];
        totalSupply -= amount;
        balances[msg.sender] = 0;
        emit Withdrawn(msg.sender, amount);

        stakingToken.safeTransfer(msg.sender, amount);
    }

    function updateReward(address _account) internal returns (uint256 rewardToPay_) {
        (rewardPerTokenStored, lastUpdateTime) = rewardPerToken();
        if (_account != address(0)) {
            rewardToPay_ = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
            rewards[_account] = rewardToPay_;
        }
        return rewardToPay_;
    }

    /**
     * @notice Add more rewards, optionally resetting the startTime if not started or already finished.
     * @param _amount The reward token amount.
     * @param _newStartTime The optional new start time.
     */
    function contribute(uint256 _amount, uint256 _newStartTime) external {
        require(_amount % rewardRate == 0, "Amount not divisible by rate");

        uint256 addedDuration = _amount / rewardRate;
        if (block.timestamp > startTime) {
            if (block.timestamp >= endTime) {
                // (Re) starting new schedule
                require(_newStartTime >= block.timestamp, "Invalid new start time");
                startTime = _newStartTime;
                lastUpdateTime = startTime;
                endTime = startTime;
                emit RewardStartScheduled(_newStartTime);
            } else {
                // Adding to ongoing schedule
                lastUpdateTime = block.timestamp;
            }
        } else {
            // Adding before schedule starts
            lastUpdateTime = startTime;
        }
        endTime += addedDuration;
        emit RewardAdded(_amount);

        rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @dev Rescue non-staking tokens from the pool. Can only rescue reward token
     * after end time.
     * @param _tokenAddress The token address.
     * @param _receiver The receiver.
     */
    function rescueFunds(address _tokenAddress, address _receiver) external onlyAdmin {
        require(_tokenAddress != address(stakingToken), "Cannot rescue staking token");
        if (_tokenAddress == address(rewardToken)) {
            require(block.timestamp > endTime, "Rescue reward before end time");
        }
        IERC20(_tokenAddress).transfer(_receiver, IERC20(_tokenAddress).balanceOf(address(this)));
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
}