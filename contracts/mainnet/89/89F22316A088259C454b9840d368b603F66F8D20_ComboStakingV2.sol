// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IMinterFactory {
    function mintTo(address to, address tokenAddress) external;
}

contract ComboStakingV2 is Ownable {
    using SafeERC20 for IERC20;

    uint256 public minStakingValue = 250000 * 10 ** 18;
    bool public stakingEnabled = true;    
    
    enum StakingLevel {
        SIMPLE,
        UNCOMMON,
        RARE,
        EPIC,
        LEGENDARY
    }

    struct RewardRule {
        uint256 apr;
        uint256 period;
        address nftHero;
    }

    struct Staking {
        uint256 timestamp;
        uint256 amount;
        uint256 rewarded;
        StakingLevel targetLevel;
        StakingLevel rewardedLevel;
        bool isCompleted;
        bool isInitialized;
    }

    struct UserStaking {
        mapping(uint256 => Staking) stakings;
        mapping(uint256 => bool) activeStakings;
        uint256 stakingNumber;
    }

    mapping(address => UserStaking) private stakers;
    mapping(StakingLevel => RewardRule) public rewardRules;

    uint256 public totalStaked;
    IERC20 public taleToken;
    IMinterFactory public minterFactory;

    event Stake(address indexed staker, uint256 amount, StakingLevel targetLevel);
    event TaleReward(address indexed staker, uint256 amount, uint256 reward);
    event NftReward(address indexed staker, address taleHero);
    
    constructor(address _taleToken, address _minterFactory) {
        taleToken = IERC20(_taleToken);
        minterFactory = IMinterFactory(_minterFactory);
        rewardRules[StakingLevel.SIMPLE] = RewardRule(15, 15 days, address(0));
        rewardRules[StakingLevel.UNCOMMON] = RewardRule(30, 30 days, address(0));
        rewardRules[StakingLevel.RARE] = RewardRule(50, 50 days, address(0));
        rewardRules[StakingLevel.EPIC] = RewardRule(75, 75 days, address(0));
        rewardRules[StakingLevel.LEGENDARY] = RewardRule(100, 100 days, address(0));
    }

    /**
    * @notice Starts a new staking.
    *
    * @param amount Amount of tokens to stake.
    * @param targetLevel Type of staking, see StakingLevel enum and rewardRules.
    */
    function stake(uint256 amount, StakingLevel targetLevel) external {
        require(stakingEnabled, "TaleStaking: Staking disabled");
        require(amount >= minStakingValue, "TaleStaking: Amount less then the minimum staking value");
        address staker = _msgSender();

        //check erc20 balance and allowance
        require(taleToken.balanceOf(staker) >= amount, "TaleStaking: Insufficient tokens");
        require(taleToken.allowance(staker, address(this)) >= amount, "TaleStaking: Not enough tokens allowed");

        uint stakingId = stakers[staker].stakingNumber;    
        stakers[staker].stakingNumber = stakingId + 1;
        stakers[staker].stakings[stakingId] = Staking(block.timestamp, amount, 0, targetLevel, StakingLevel.SIMPLE, false, true);
        stakers[staker].activeStakings[stakingId] = true;

        totalStaked += amount;
        taleToken.safeTransferFrom(staker, address(this), amount);  

        emit Stake(staker, amount, targetLevel);
    }

    /**
    * @notice Pays rewards and withdraws the specified amount of tokens from staking. 
    *
    * @param stakingId Id of staking;
    */
    function claim(uint256 stakingId) external {
        address staker = _msgSender();
        Staking storage staking = stakers[staker].stakings[stakingId];        
        require(staking.isInitialized, "TaleStaking: Staking is not exists");
        require(!staking.isCompleted, "TaleStaking: Staking is completed");
        bool nftClaimed = claimNft(staking, staker);
        bool taleClaimed = claimTale(staking, stakingId, staker);
        require(nftClaimed || taleClaimed, "TaleStaking: Nothing to claim");
    }

    function claimTale(Staking storage staking, uint256 stakingId, address staker) private returns(bool cliamed) {
        RewardRule memory rewardRule = rewardRules[staking.targetLevel];
        if (block.timestamp >= staking.timestamp + rewardRule.period) {                    
            staking.isCompleted = true;       
            staking.rewarded = staking.amount * rewardRule.apr * rewardRule.period / 365 days / 100;
            delete stakers[staker].activeStakings[stakingId];
            
            totalStaked -= staking.amount;
            uint256 totalAmount = staking.amount + staking.rewarded;
            uint thisBalance = taleToken.balanceOf(address(this));
            require(thisBalance >= totalAmount, "TaleStaking: Insufficient funds in the pool");
            taleToken.safeTransfer(staker, totalAmount);
            cliamed = true;
            emit TaleReward(staker, staking.amount, staking.rewarded);
        }
    }

    function claimNft(Staking storage staking, address staker) private returns(bool cliamed) {
        uint256 stakingDuration = block.timestamp - staking.timestamp;
        for (uint256 i = uint256(staking.rewardedLevel)  + 1; i <= uint256(staking.targetLevel); ++i) {
            StakingLevel level = StakingLevel(i);
            RewardRule memory rule = rewardRules[level];
            if (stakingDuration >= rule.period) {
                staking.rewardedLevel = level;
                require(rule.nftHero != address(0), "TaleStaking: Hero unset");
                minterFactory.mintTo(staker, rule.nftHero);
                cliamed = true;
                emit NftReward(staker, rule.nftHero);
            } else {
                break;
            }       
        }
    }

    /**
    * @notice Returns the maximum available level for the user and staking
    *
    * @param user User address
    * @param stakingId Id of staking;
    */
    function getAvailableLevel(address user, uint256 stakingId) public view returns (StakingLevel) {
        Staking storage staking = stakers[user].stakings[stakingId];  
        StakingLevel availableLevel;        
        uint256 stakingDuration = block.timestamp - staking.timestamp;
        for (uint256 i = uint256(staking.rewardedLevel)  + 1; i < 5; ++i) {
            StakingLevel level = StakingLevel(i);
            RewardRule memory rule = rewardRules[level];
            if (rule.period <= stakingDuration) {
                availableLevel = level;
            } else {
                break;
            }       
        }

        return availableLevel;
    }

    /**
    * @notice Sets MinterFactory, only available to the owner
    *
    * @param factory Address of minter factory
    */
    function setMinterFactory(address factory) external onlyOwner {
        minterFactory = IMinterFactory(factory);
    }

    /**
    * @notice Sets hero staking rules for different levels
    */
    function setStakingRule(
        StakingLevel level, 
        uint256 apr, 
        uint256 period,
        address nftHero
        ) external onlyOwner {
        require(period >= 3600, "Period must be more then 3600");
        if (level == StakingLevel.SIMPLE) {
            require(nftHero == address(0), "Simple level shouldn't have a hero");
        } else {
            StakingLevel previousLevel = StakingLevel(uint(level) - 1);
            require(rewardRules[previousLevel].period < period, "The rule for a higher level must have a longer period than the previous level");
        }
        rewardRules[level] = RewardRule(apr, period, nftHero);
    }

    function setStakingEnabled(bool isEnabled) external onlyOwner {
        stakingEnabled = isEnabled;
    }

    /**
    * @notice Sets the minimum staking value
    *
    * @param value Minimum value
    */
    function setMinStakingValue(uint256 value) external onlyOwner {
        minStakingValue = value;
    }

    /**
    * @notice Withdraws tokens from the pool. 
    *         Available only to the owner of the contract.
    *
    * @param to Address where tokens will be withdrawn
    * @param amount Amount of tokens to withdraw.
    */
    function withdraw(address to, uint256 amount) external onlyOwner {
        require(getPoolSize() >= amount, "TaleStaking: Owner can't withdraw more than pool size");
        taleToken.safeTransfer(to, amount);
    }

    /**
    * @notice Returns the current number of tokens in the pool
    */
    function getPoolSize() public view returns(uint256) {
        uint256 balance = taleToken.balanceOf(address(this));
        return balance - totalStaked;
    }

    /**
    * @notice Returns active staking indexes for the specified user
    *
    * @param user Address for which indexes will be returned
    */
    function getActiveStakingIndexes(address user) external view returns(uint256[] memory) {
        uint256 activeStakingsCount = getActiveStakingCount(user);
        uint256[] memory result = new uint256[](activeStakingsCount);
        uint256 j = 0;
        for (uint256 i = 0; i < stakers[user].stakingNumber; ++i) {
            if (stakers[user].activeStakings[i]) {
                result[j] = i;
                ++j;
            }
        }
        return result;
    }

    /**
    * @notice Returns staking for the specified user and index
    *
    * @param user Address for which indexes will be returned
    * @param stakingIndex Index of the staking
    */
    function getStaking(address user, uint256 stakingIndex) external view returns(Staking memory) {
        Staking memory staking = stakers[user].stakings[stakingIndex];        
        require(staking.isInitialized, "TaleStaking: Staking is not exists");
        return staking;
    }

   /**
    * @notice Returns the number of all stakings for the user
    *
    * @param user The user whose number of stakings will be returned
    */
    function getAllStakingCount(address user) public view returns(uint256) {
        return stakers[user].stakingNumber;
    }

   /**
    * @notice Returns the number of active stakings for the user
    *
    * @param user The user whose number of stakings will be returned
    */
    function getActiveStakingCount(address user) public view returns(uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < stakers[user].stakingNumber; ++i) {
            if (stakers[user].activeStakings[i]) {
                ++count;
            }
        }
        return count;
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