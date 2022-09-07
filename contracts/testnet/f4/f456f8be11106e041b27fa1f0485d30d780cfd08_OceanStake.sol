/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// File: contracts/oceanstake_v1.sol


pragma solidity 0.8.16;

/*
https://oceanstake.net
10% deposit fee
Min deposit 0.001 * etherMultipliedBy. Max deposit 10 * etherMultipliedBy
Max 200% rewards payout
5% daily rewards max (%1 base + %2 hold bonus + %2 balance bonus)
Hold bonus increases +0.1% every day (max 2% for 20 days) (not retroactive)
Withdrawals and compounds reset hold bonus
Balance bonus +0.01% for every 10 * etherMultipliedBy in the contract. Max +2% (retroactive)
Compound anytime with 10% compound bonus (no fee)
Withdraw anytime (no fee)
4 level referrals 8% (1st level 4%, 2nd level 2%, 3rd level 1%, 4th level 1%)
Must invest at least 0.05 * etherMultipliedBy to be able to withdraw ref rewards
*/



contract OceanStake is ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant PERC_DIVIDER = 10000;
    uint256 public constant DAY_SECONDS = 86400;

    uint256 public constant DEPOSIT_FEE = 1000; //10%
    uint256 public constant MAX_REWARD = 20000; //200% max reward including compounds
    uint256 public constant DAILY_DIV = 100; //1%
    uint256 public constant REINVEST_BONUS = 1000; //10%
    uint256[] public REF_PERCENTS = [400, 200, 100, 100];

    uint256 public constant HOLD_PERCENT_STEP = 10; //+0.1% per day (2% max)
    uint256 public constant HOLD_MAX_DAYS = 20; //max number of days for hold bonus
    uint256 public constant HOLD_BONUS_MAX = HOLD_MAX_DAYS * HOLD_PERCENT_STEP; //200 (2%)

    //multiplier for ether parameters when using a token or a different coin than eth (eth 1x,bnb 10x,avax 100x,busd 2000x ..)
    uint256 public etherMultipliedBy; //set in constructor. (multiplies MIN_REF MIN_INVEST MAX_INVEST BALANCE_STEP)

    uint256 public MIN_REF = 0.05 ether; //min amount of stake needed to withdraw ref rewards
    uint256 public MIN_INVEST = 0.001 ether;
    uint256 public MAX_INVEST = 10 ether;
    uint256 public BALANCE_STEP = 10 ether;

    uint256 public constant BALANCE_PERCENT_STEP = 1; //+0.01% bonus per balance step (2% max)
    uint256 public constant BALANCE_BONUS_MAX = 200; //%2

    address public tokenAddress;
    address public owner;
    address payable private dev;
    address payable private mrk;

    uint256 private invested;
    uint256 private reinvested;
    uint256 private withdrawn;
    uint256 private totalRefRewards;
    uint256 private userCount;

    uint256 public launchTime;
    bool public launched = false;

    struct DWStruct {
        uint256 amount;
        uint256 timestamp;
    }

    struct User {
        uint256 invested;
        uint256 reinvested;
        uint256 withdrawable;
        uint256 withdrawn;
        uint256 lastWithdrawnAt; //info
        uint256 claimedTotal;
        uint256 checkpoint;
        uint256 refWithdrawable;
        uint256 refWithdrawn;
        uint256 refTotal;
        address upline;
        uint256 firstInvestTime; //info
        uint256 holdBonusStart;
        uint256 lastRefWithdrawnAt; //info
        uint32[4] refCounts; //info
    }

    mapping(address => User) internal users;
    mapping(address => DWStruct[]) internal deposits; //info
    mapping(address => DWStruct[]) internal withdrawals; //info

    event Invested(address indexed addr, uint256 amount, uint256 time);
    event Withdrawn(address indexed addr, uint256 amount, uint256 time);
    event Reinvested(address indexed addr, uint256 amount, uint256 time);
    event WithdrawnRef(address indexed addr, uint256 amount, uint256 time);

    constructor(
        address payable _dev,
        address payable _mrk,
        address _tokenAddress,
        uint256 _multiplyEtherBy
    ) {
        require(!Address.isContract(_dev));

        owner = msg.sender;
        dev = _dev;
        mrk = _mrk;
        tokenAddress = _tokenAddress;

        etherMultipliedBy = _multiplyEtherBy;
        MIN_REF *= etherMultipliedBy;
        MIN_INVEST *= etherMultipliedBy;
        MAX_INVEST *= etherMultipliedBy;
        BALANCE_STEP *= etherMultipliedBy;
    }

    function launch() external {
        require(msg.sender == owner && !launched);
        launched = true;
        launchTime = block.timestamp;
        owner = address(0);
    }

    function invest(address ref, uint256 _amount)
        external
        payable
        nonReentrant
    {
        require(launched, "Not launched");

        address addr = msg.sender;
        uint256 amount = msg.value;

        if (tokenAddress != address(0)) {
            require(amount == 0); //contract is using token. prevent payments of network's native payable coin
            amount = _amount;
            IERC20(tokenAddress).safeTransferFrom(addr, address(this), amount);
        }
        require(amount >= MIN_INVEST && amount <= MAX_INVEST);

        User storage user = users[addr];
        uint8 refInc = 0;
        if (user.invested == 0) {
            ++refInc;
            ++userCount;
            user.firstInvestTime = block.timestamp; //info
            user.holdBonusStart = user.firstInvestTime;
            user.upline = ref != addr && ref != address(0) ? ref : dev;
        }

        address up = user.upline;
        for (uint8 i = 0; i < REF_PERCENTS.length && up != address(0); i++) {
            users[up].refCounts[i] += refInc;

            uint256 rew = (amount * REF_PERCENTS[i]) / PERC_DIVIDER;
            users[up].refWithdrawable += rew;
            users[up].refTotal += rew;
            totalRefRewards += rew;
            up = users[up].upline;
        }

        _claimReward(addr);
        _invest(addr, amount);

        uint256 halfFee = (amount * DEPOSIT_FEE) / (PERC_DIVIDER * 2);
        _transferTo(dev, halfFee);
        _transferTo(mrk, halfFee);
        emit Invested(addr, amount, block.timestamp);
    }

    function withdrawRef(uint256 amount) external nonReentrant {
        address addr = msg.sender;
        User storage user = users[addr];
        require(user.invested >= MIN_REF, "More investment required");

        if (amount == 0 || amount > user.refWithdrawable) {
            amount = user.refWithdrawable;
        }
        require(amount > 0, "Amount is 0");

        user.refWithdrawable -= amount;
        user.refWithdrawn += amount;
        user.lastRefWithdrawnAt = block.timestamp;
        withdrawn += amount;

        _transferTo(addr, amount);
        emit WithdrawnRef(addr, amount, block.timestamp);
    }

    function withdraw() external nonReentrant {
        address addr = msg.sender;

        _claimReward(addr);
        uint256 amount = _withdraw(addr);
        require(amount > 0, "Amount is 0");

        _transferTo(addr, amount);
        emit Withdrawn(addr, amount, block.timestamp);
    }

    function reinvest() external nonReentrant {
        address addr = msg.sender;

        _claimReward(addr);
        uint256 amount = _withdraw(addr);
        require(amount > 0, "Amount is 0");

        amount += (amount * REINVEST_BONUS) / PERC_DIVIDER;
        _invest(addr, amount);

        users[addr].reinvested += amount;
        reinvested += amount;
        emit Reinvested(addr, amount, block.timestamp);
    }

    function _transferTo(address addr, uint256 amount) private {
        if (tokenAddress != address(0)) {
            IERC20(tokenAddress).safeTransfer(addr, amount);
        } else {
            payable(addr).transfer(amount);
        }
    }

    //claim and set checkpoint
    function _claimReward(address addr) private {
        uint256 rew = _calcReward(addr);
        //calc is done since the checkpoint
        users[addr].checkpoint = block.timestamp;

        users[addr].withdrawable += rew;
        users[addr].claimedTotal += rew;
    }

    function _invest(address addr, uint256 amount) private {
        users[addr].invested += amount;
        invested += amount;
        deposits[addr].push(
            DWStruct({amount: amount, timestamp: block.timestamp})
        );
    }

    function _withdraw(address addr) private returns (uint256) {
        uint256 balance = getBalance();
        User storage user = users[addr];

        uint256 amount = user.withdrawable < balance
            ? user.withdrawable
            : balance;

        if (amount == 0) return 0;

        user.withdrawable -= amount;
        user.withdrawn += amount;
        withdrawn += amount;

        uint256 tsNow = block.timestamp;
        user.lastWithdrawnAt = tsNow;
        users[addr].holdBonusStart = tsNow;

        withdrawals[addr].push(DWStruct({amount: amount, timestamp: tsNow}));
        return amount;
    }

    function _calcReward(address addr) private view returns (uint256) {
        uint256 maxReward = getMaxReward(addr);
        User memory user = users[addr];
        if (user.invested == 0 || maxReward <= user.claimedTotal) return 0;
        uint256 tsNow = block.timestamp;
        uint256 perc = _getBasePerc() + _getBalanceBonusPerc(); //balance bonus retroactive


user.holdBonusStart = tsNow - 30*DAY_SECONDS;
user.checkpoint = tsNow - 30*DAY_SECONDS;

uint256 rew = 0;
uint256 start;
uint256 diff;
uint256 end;
uint256 holdBonus;
uint256 i;

for (uint256 j=0; j<10; j++) {

        start = user.checkpoint;
        rew = perc * (tsNow - start);

        diff = (start - user.holdBonusStart) % DAY_SECONDS;
        end = start + DAY_SECONDS - diff;

        //holdBonus = _getHoldBonusPercAt(addr, start);
        i = (start - user.holdBonusStart) / DAY_SECONDS;
        holdBonus = HOLD_PERCENT_STEP * (i < HOLD_MAX_DAYS ? i : HOLD_MAX_DAYS);

        while (true) {
            if (end > tsNow || holdBonus >= HOLD_BONUS_MAX) {
                end = tsNow; //calculate from start to now as the last step
            }
            rew += holdBonus * (end - start);
            if (end >= tsNow) break;

            start = end;
            end += DAY_SECONDS;
            holdBonus += HOLD_PERCENT_STEP; //hold bonus not retroactive
        }


        rew = (rew * user.invested) / (DAY_SECONDS * PERC_DIVIDER);
}

        return
            maxReward > rew + user.claimedTotal
                ? rew
                : maxReward - user.claimedTotal;
    }

    function _getHoldBonusPercAt(address addr, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        if (users[addr].invested == 0) return 0;

        uint256 i = (timestamp - users[addr].holdBonusStart) / DAY_SECONDS;
        return HOLD_PERCENT_STEP * (i < HOLD_MAX_DAYS ? i : HOLD_MAX_DAYS);
    }

    function _getBasePerc() private pure returns (uint256) {
        return DAILY_DIV;
    }

    function _getHoldBonusPerc(address addr) private view returns (uint256) {
        return _getHoldBonusPercAt(addr, block.timestamp);
    }

    function _getCurrentPerc(address addr) private view returns (uint256) {
        return
            _getBasePerc() + _getHoldBonusPerc(addr) + _getBalanceBonusPerc();
    }

    function _getBalanceBonusPerc() private view returns (uint256) {
        uint256 i = BALANCE_PERCENT_STEP * (getBalance() / BALANCE_STEP);
        return i < BALANCE_BONUS_MAX ? i : BALANCE_BONUS_MAX;
    }

    function getMaxReward(address addr) public view returns (uint256) {
        return (users[addr].invested * MAX_REWARD) / PERC_DIVIDER;
    }

    function getBalance() public view returns (uint256) {
        return
            tokenAddress != address(0)
                ? IERC20(tokenAddress).balanceOf(address(this))
                : address(this).balance;
    }

    function getWithdrawable(address addr) public view returns (uint256) {
        return users[addr].withdrawable + _calcReward(addr);
    }

    function getUserDeposits(address addr)
        external
        view
        returns (DWStruct[] memory)
    {
        return deposits[addr];
    }

    function getUserWithdrawals(address addr)
        external
        view
        returns (DWStruct[] memory)
    {
        return withdrawals[addr];
    }

    function getContractInfo()
        external
        view
        returns (
            uint256 _invested,
            uint256 _reinvested,
            uint256 _withdrawn,
            uint256 _totalRefRewards,
            uint256 _userCount
        )
    {
        return (invested, reinvested, withdrawn, totalRefRewards, userCount);
    }

    function getCurrentUserPercentages(address addr)
        external
        view
        returns (
            uint256 percentTotal,
            uint256 basePercent,
            uint256 holdBonusPercent,
            uint256 balanceBonusPercent
        )
    {
        basePercent = _getBasePerc();
        holdBonusPercent = _getHoldBonusPerc(addr);
        balanceBonusPercent = _getBalanceBonusPerc();
        percentTotal = basePercent + holdBonusPercent + balanceBonusPercent;
    }

    function getUserInfo(address addr)
        external
        view
        returns (User memory user)
    {
        user = users[addr];
        user.withdrawable = getWithdrawable(addr);
    }
}