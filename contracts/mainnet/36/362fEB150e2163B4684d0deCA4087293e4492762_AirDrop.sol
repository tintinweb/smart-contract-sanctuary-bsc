// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/Percent.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract AirDrop is Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct User {
        uint256 airdropped;         // tokens airdropped to the user
        uint256 withdrawn;          // tokens withdrawn by the user
    }

    /**
     * Withdraw phase determines `token` withdrawals by users
     *  NoWithdraw:     default on contract creation, withdrawals are prohibited
     *  Withdraw0:      withdraw 0% of airdropped tokens
     *  Withdraw25:     withdraw up to 25% of airdropped tokens
     *  Withdraw50:     withdraw up to 50% of airdropped tokens
     *  Withdraw75:     withdraw up to 75% of airdropped tokens
     *  Withdraw100:    withdraw up to 100% of airdropped tokens
     * 
     * After Withdraw0 is started, subsequent withdraw phases automatically 
     * begin `WITHDRAW_PHASE_DURATION` after the start of the previous withdraw phase
     */
    enum WithdrawPhase {
        NoWithdraw,
        Withdraw0,
        Withdraw25,
        Withdraw50,
        Withdraw75,
        Withdraw100
    }
    
    /// Token being airdropped, i.e. HelixToken
    address public token;

    /// Current withdraw phase, dictates what percentage of tickets may be withdrawn
    WithdrawPhase public withdrawPhase;

    /// Length of withdrawPhase in seconds, 86400 == 1 day
    uint256 public immutable WITHDRAW_PHASE_DURATION; 

    /// Timestamp after which the current withdrawPhase has ended
    uint256 public withdrawPhaseEndTimestamp;

    /// Owners who can airdrop tokens to users
    address[] public owners;

    /// true if address is an owner and false otherwise
    mapping(address => bool) public isOwner;

    /// Relates user addresses to their struct
    mapping(address => User) public users;
    
    /// Relates a withdrawPhase to the percent of airdropped tokens a user may withdraw during that withdrawPhase
    mapping (uint256 => uint256) public withdrawPhasePercent;

    // Emitted when an owner burns amount of tickets
    event Burn(uint256 amount);

    // Emitted when tickets are withdrawn
    event Withdraw(address indexed user, uint256 amount);

    // Emitted when an existing owner adds a new owner
    event AddOwner(address indexed owner, address indexed newOwner);

    // Emitted when the purchase phase is set
    event SetWithdrawPhase(WithdrawPhase withdrawPhase, uint256 startTimestamp, uint256 endTimestamp);

    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "AirDrop: zero address");
        _;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "AirDrop: not owner");
        _;
    }

    constructor(
        address _token, 
        uint256 _WITHDRAW_PHASE_DURATION
    ) onlyValidAddress(_token) {
        token = _token;

        isOwner[msg.sender] = true;
        owners.push(msg.sender);

        WITHDRAW_PHASE_DURATION = _WITHDRAW_PHASE_DURATION;

        withdrawPhasePercent[2] = 25;       // 25%
        withdrawPhasePercent[3] = 50;       // 50%
        withdrawPhasePercent[4] = 75;       // 75%
        withdrawPhasePercent[5] = 100;      // 100%
    }

    /// Called to withdraw _amount of token to caller's address
    function withdraw(uint256 _amount) external whenNotPaused {
        // Want to be in the latest phase
        updateWithdrawPhase();

        _requireValidWithdraw(msg.sender, _amount);

        users[msg.sender].withdrawn += _amount;
        IERC20(token).safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    /// Called to withdraw tokens
    function emergencyWithdraw() external onlyOwner {
        uint256 amount = getContractTokenBalance();
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    /// Called to destroy _amount of token
    function burn(uint256 _amount) external onlyOwner { 
        IERC20(token).burn(address(this), _amount);
        emit Burn(_amount);
    }

    /// Called externally by owner to manually set the _withdrawPhase
    function setWithdrawPhase(WithdrawPhase _withdrawPhase) external onlyOwner {
        _setWithdrawPhase(_withdrawPhase);
    }

    /// Called externally to airdrop multiple _users tokens
    /// each _users[i] receives amounts[i] many tokens for i in range _users.length
    function airdropAdd(address[] calldata _users, uint256[] calldata _amounts) external onlyOwner {
        uint256 usersLength = _users.length;
        require(usersLength == _amounts.length, "AirDrop: users and amounts must be same length");

        uint256 amountSum;
        for (uint256 i = 0; i < usersLength; i++) {
            uint256 amount = _amounts[i];
            amountSum += amount;
            require(amountSum <= getContractTokenBalance(), "AirDrop: insufficient tokens available");

            users[_users[i]].airdropped += amount;
        }
    }

    /// Called externally to reduce a _user's airdrop balance by _amount
    function airdropRemove(address _user, uint256 _amount) external onlyOwner {
        if (users[_user].withdrawn > _amount) {
            users[_user].withdrawn = users[_user].airdropped;
        } else {
            users[_user].withdrawn += _amount;
        }
    }

    /// Called by the owner to pause the contract
    function pause() external onlyOwner {
        _pause();
    }

    /// Called by the owner to unpause the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    /// Add a new _owner to the contract, only callable by an existing owner
    function addOwner(address _owner) external onlyOwner onlyValidAddress(_owner) {
        require(!isOwner[_owner], "AirDrop: already owner");
        isOwner[_owner] = true;
        owners.push(_owner);
        emit AddOwner(msg.sender, _owner);
    }

    /// Remove an existing _owner from the contract, only callable by an owner
    function removeOwner(address _owner) external onlyOwner onlyValidAddress(_owner) {
        require(isOwner[_owner], "VipPresale: not owner");
        delete isOwner[_owner];

        // array remove by swap
        uint256 length = owners.length;
        for (uint256 i = 0; i < length; i++) {
            if (owners[i] == _owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
            }
        }
    }

    /// Return true if `amount` is removable by address `by`
    function isRemovable(address _by, uint256 _amount) external view returns (bool) {
        _requireValidWithdraw(_by, _amount);
        return true;
    }

    /// Return the address array of registered owners
    function getOwners() external view returns (address[] memory) {
        return owners;
    }
    
    /// Called periodically and, if sufficient time has elapsed, update the withdrawPhase
    function updateWithdrawPhase() public {
        if (block.timestamp >= withdrawPhaseEndTimestamp) {
            if (withdrawPhase == WithdrawPhase.Withdraw0) {
                _setWithdrawPhase(WithdrawPhase.Withdraw25);
            }
            else if (withdrawPhase == WithdrawPhase.Withdraw25) {
                _setWithdrawPhase(WithdrawPhase.Withdraw50);
            }
            else if (withdrawPhase == WithdrawPhase.Withdraw50) {
                _setWithdrawPhase(WithdrawPhase.Withdraw75);
            }
            else if (withdrawPhase == WithdrawPhase.Withdraw75) {
                _setWithdrawPhase(WithdrawPhase.Withdraw100);
            }
        }
    }

    /// Return maxAmount removable by address _by
    function getMaxAmount(address _by) public view returns (uint256 maxAmount) {
        // Use the next withdrawPhase if update hasn't been called
        uint256 _withdrawPhase = uint(withdrawPhase);
        if (block.timestamp >= withdrawPhaseEndTimestamp && withdrawPhase != WithdrawPhase.Withdraw100) {
            _withdrawPhase++;
        }

        // Max number of tokens user can withdraw based on current withdrawPhase, 
        // number of tokens airdropped, and number of tokens already withdrawn
        maxAmount = Percent.getPercentage(users[_by].airdropped, withdrawPhasePercent[_withdrawPhase]);

        // Reduce the maxAmount by the number of tokens already withdrawn
        maxAmount -= users[_by].withdrawn;

        // Max amount will be the lesser of the maxAmount allowed and the remaining balance
        maxAmount = Math.min(maxAmount, getBalance(_by));
    }

    /// Return _user balance
    function getBalance(address _user) public view returns(uint256) {
        if (users[_user].airdropped != 0) {
            return users[_user].airdropped - users[_user].withdrawn;
        } else {
            return 0;
        }
    }

    /// Return this contract's token balance
    function getContractTokenBalance() public view returns(uint256 balance) {
        balance = IERC20(token).balanceOf(address(this));
    }

    // Called privately to set the _withdrawPhase
    function _setWithdrawPhase(WithdrawPhase _withdrawPhase) private {
        withdrawPhase = _withdrawPhase;
        withdrawPhaseEndTimestamp = block.timestamp + WITHDRAW_PHASE_DURATION;
        emit SetWithdrawPhase(_withdrawPhase, block.timestamp, withdrawPhaseEndTimestamp);
    }

    // Require that _amount of tokens are removable by address _by
    function _requireValidWithdraw(address _by, uint256 _amount) private view {
        require(_amount > 0, "AirDrop: zero amount");
        require(_amount <= getContractTokenBalance(), "AirDrop: insufficient contract balance");
        require(_amount <= getMaxAmount(_by), "AirDrop: exceeds max amount");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.8.0;

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

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity >=0.8.0;

import "../interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

library Percent {
    uint256 public constant MAX_PERCENT = 100;

    modifier onlyValidPercent(uint256 _percent, uint256 _decimals) {
        require(_isValidPercent(_percent, _decimals), "Percent: invalid percent");
        _;
    }

    // Return true if the _percent is valid and false otherwise
    function isValidPercent(uint256 _percent)
        internal
        pure
        returns (bool)
    {
        return _isValidPercent(_percent, 0);
    }

    // Return true if the _percent with _decimals many decimals is valid and false otherwise
    function isValidPercent(uint256 _percent, uint256 _decimals)
        internal
        pure
        returns (bool)
    {
        return _isValidPercent(_percent, _decimals);
    }

    // Return true if the _percent with _decimals many decimals is valid and false otherwise
    function _isValidPercent(uint256 _percent, uint256 _decimals)
        private
        pure
        returns (bool)
    {
        return _percent <= MAX_PERCENT * 10 ** _decimals;
    }

    // Return _percent of _amount
    function getPercentage(uint256 _amount, uint256 _percent)
        internal 
        pure
        returns (uint256 percentage) 
    {
        percentage = _getPercentage(_amount, _percent, 0);
    }

    // Return _percent of _amount with _decimals many decimals
    function getPercentage(uint256 _amount, uint256 _percent, uint256 _decimals)
        internal 
        pure
        returns (uint256 percentage)
    {
        percentage =_getPercentage(_amount, _percent, _decimals);
    }

    // Return _percent of _amount with _decimals many decimals
    function _getPercentage(uint256 _amount, uint256 _percent, uint256 _decimals) 
        private
        pure
        onlyValidPercent(_percent, _decimals) 
        returns (uint256 percentage)
    {
        percentage = _amount * _percent / (MAX_PERCENT * 10 ** _decimals);
    }

    // Return _percent of _amount as the percentage and the remainder of _amount - percentage
    function splitByPercent(uint256 _amount, uint256 _percent) 
        internal 
        pure 
        returns (uint256 percentage, uint256 remainder) 
    {
        (percentage, remainder) = _splitByPercent(_amount, _percent, 0);
    }

    // Return _percent of _amount as the percentage and the remainder of _amount - percentage
    // with _decimals many decimals
    function splitByPercent(uint256 _amount, uint256 _percent, uint256 _decimals)
        internal 
        pure
        returns (uint256 percentage, uint256 remainder)
    {
        (percentage, remainder) = _splitByPercent(_amount, _percent, _decimals);
    }

    // Return _percent of _amount as the percentage and the remainder of _amount - percentage
    // with _decimals many decimals
    function _splitByPercent(uint256 _amount, uint256 _percent, uint256 _decimals)
        private
        pure
        onlyValidPercent(_percent, _decimals)
        returns (uint256 percentage, uint256 remainder)
    {
        percentage = _getPercentage(_amount, _percent, _decimals);
        remainder = _amount - percentage;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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