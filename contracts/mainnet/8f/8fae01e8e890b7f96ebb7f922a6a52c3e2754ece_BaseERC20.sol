// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// solhint-disable not-rely-on-time
contract BaseClaim is Ownable {
    using SafeERC20 for ERC20;

    struct UserInfo {
        uint256 reward;
        uint256 withdrawn;
    }
    mapping(address => UserInfo) public userInfo;

    uint256 public claimTime; // Time at which claiming can start

    ERC20 public immutable rewardToken; // Token that is distributed

    event RewardClaimed(
        address indexed user,
        uint256 indexed withdrawAmount,
        uint256 totalWithdrawn
    );
    event ClaimsPaused();
    event ClaimsUnpaused();

    uint256 public totalRewards;
    uint256 public totalWithdrawn;

    bool public areClaimsPaused;

    constructor(address _rewardToken) {
        require(
            address(_rewardToken) != address(0),
            "Reward token must be set"
        );

        rewardToken = ERC20(_rewardToken);

        claimTime = block.timestamp;
    }

    ////
    // Modifiers
    ////
    modifier onlyWithRewards(address addr) {
        require(userInfo[addr].reward > 0, "Address has no rewards");
        _;
    }

    ////
    // Functions
    ////

    function pauseClaims() external onlyOwner {
        areClaimsPaused = true;

        emit ClaimsPaused();
    }

    function unPauseClaims() external onlyOwner {
        areClaimsPaused = false;

        emit ClaimsUnpaused();
    }

    function addUserReward(address _user, uint256 _amount) internal {
        UserInfo storage user = userInfo[_user];
        uint256 newReward = user.reward + _amount;

        totalRewards = totalRewards + _amount;
        user.reward = newReward;
    }

    function setUserReward(address _user, uint256 _amount) internal {
        UserInfo storage user = userInfo[_user];

        totalRewards = (totalRewards + _amount) - (user.reward);
        user.reward = _amount;

        require(user.reward >= user.withdrawn, "Invalid reward amount");
    }

    function freezeUserReward(address _user) internal {
        UserInfo storage user = userInfo[_user];

        uint256 change = user.reward - user.withdrawn;

        user.reward = user.withdrawn;
        totalRewards = totalRewards - change;
    }

    function claim() external onlyWithRewards(msg.sender) {
        require(!areClaimsPaused, "Claims are paused");

        UserInfo storage user = userInfo[msg.sender];

        uint256 withdrawAmount = getWithdrawableAmount(msg.sender);

        user.withdrawn = user.withdrawn + withdrawAmount;
        totalWithdrawn = totalWithdrawn + withdrawAmount;

        assert(user.withdrawn <= user.reward);

        rewardToken.safeTransfer(msg.sender, withdrawAmount);

        emit RewardClaimed(msg.sender, withdrawAmount, user.withdrawn);
    }

    function getWithdrawableAmount(address _user)
        public
        view
        returns (uint256)
    {
        UserInfo memory user = userInfo[_user];

        uint256 unlockedAmount = calculateUnlockedAmount(
            user.reward,
            block.timestamp
        );

        return unlockedAmount - user.withdrawn;
    }

    // This is a timed vesting contract
    //
    // Claimants can claim 100% of ther claim upon claimTime.
    //
    // Can be overriden in contracts that inherit from this one.
    function calculateUnlockedAmount(uint256 _totalAmount, uint256 _timestamp)
        internal
        view
        virtual
        returns (uint256)
    {
        return _timestamp > claimTime ? _totalAmount : 0;
    }

    function totalAvailableAfter() public view virtual returns (uint256) {
        return claimTime;
    }

    function withdrawRewardAmount() external onlyOwner {
        rewardToken.safeTransfer(
            msg.sender,
            rewardToken.balanceOf(address(this)) - totalRewards
        );
    }

    function emergencyWithdrawToken(ERC20 tokenAddress) external onlyOwner {
        tokenAddress.safeTransfer(
            msg.sender,
            tokenAddress.balanceOf(address(this))
        );
    }
}
// solhint-enable not-rely-on-time

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
pragma solidity 0.8.9;

import "../claim/BaseClaim.sol";

contract BaseClaimTest is BaseClaim {
    constructor(address _rewardToken) BaseClaim(_rewardToken) {} // solhint-disable-line no-empty-blocks

    function buy(uint256 _amount) external {
        addUserReward(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./BaseClaim.sol";

contract RunnerClaim is BaseClaim {
    constructor(address _rewardToken) BaseClaim(_rewardToken) {} // solhint-disable-line no-empty-blocks

    // For the private round: 10% released on TGE,
    // followed by a 3 months cliff, then 3.913% on a monthly basis (from month 4 onwards) for
    // a total of 23 unlocks on top of TGE release.
    function calculateUnlockedAmount(uint256 _totalAmount, uint256 _timestamp)
        internal
        view
        override
        returns (uint256)
    {
        if (_timestamp < claimTime) {
            return 0;
        }

        uint256 timeSinceClaim = _timestamp - claimTime;
        uint256 unlockedAmount = 0;

        if (timeSinceClaim <= 90 days) {
            unlockedAmount = (_totalAmount * 10) / 100;
        } else if (timeSinceClaim > 780 days) {
            // 90 + 23 months
            unlockedAmount = _totalAmount;
        } else {
            uint256 unlockedOnClaim = (_totalAmount * 10) / 100;
            uint256 vestable = _totalAmount - unlockedOnClaim;
            uint256 monthsSince = (timeSinceClaim - 90 days) / 30 days;

            unlockedAmount = ((vestable * monthsSince) / 23) + unlockedOnClaim;
        }

        return unlockedAmount;
    }

    function totalAvailableAfter() public view override returns (uint256) {
        return claimTime + 780 days;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../claim/RunnerClaim.sol";

contract RunnerClaimTest is RunnerClaim {
    constructor(uint256 _claimTime, address _rewardToken)
        RunnerClaim(_rewardToken)
    {
        claimTime = _claimTime;
    }

    function buy(uint256 _amount) external {
        addUserReward(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../claim/RunnerClaim.sol";

interface IStakeSum {
    function minTimeToStake() external view returns (uint256);

    function balanceOf(address user) external view returns (uint256);
}

// solhint-disable not-rely-on-time
contract RunnerIdo is RunnerClaim {
    using SafeERC20 for ERC20;

    uint256 public immutable tokenPrice;

    ERC20 public immutable USDTAddress; // solhint-disable-line var-name-mixedcase
    ERC20 public immutable USDCAddress; // solhint-disable-line var-name-mixedcase

    uint256 public immutable startTime; // Only for test purposes not marked as immutable. We accept the increased gas cost
    uint256 public immutable endTime; // Only for test purposes not marked as immutable. We accept the increased gas cost
    uint256 public immutable maxReward;
    uint256 public immutable maxDistribution;
    uint256 public currentDistributed;

    address public immutable treasury;

    address[2] public stakingContracts = [
        0x2768f5d352f7aC67218027A1A7EAA8977c40d006,
        0xD05198fEFD618030d1E2325D4f01Eb5908A4be20
    ];

    event Bought(
        address indexed holder,
        uint256 depositedAmount,
        uint256 rewardAmount
    );

    constructor(
        uint256 _tokenPrice,
        address _rewardToken, // Provided by VestedClaim
        ERC20 _USDTAddress, // solhint-disable-line var-name-mixedcase
        ERC20 _USDCAddress, // solhint-disable-line var-name-mixedcase
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimTime,
        uint256 _maxReward,
        uint256 _maxDistribution,
        address _treasury
    ) RunnerClaim(_rewardToken) {
        require(_startTime < _endTime, "Invalid start timestamp");
        require(_endTime > block.timestamp, "Ivvalid finish timestamp");

        tokenPrice = _tokenPrice;
        USDTAddress = ERC20(_USDTAddress);
        USDCAddress = ERC20(_USDCAddress);
        startTime = _startTime;
        endTime = _endTime;
        maxReward = _maxReward;
        maxDistribution = _maxDistribution;
        treasury = _treasury;

        // Provided by VestedClaim
        claimTime = _claimTime;
    }

    modifier checkTimespan() {
        require(block.timestamp >= startTime, "Not started");
        require(block.timestamp < endTime, "Ended");
        _;
    }

    modifier checkPaymentTokenAddress(ERC20 addr) {
        require(addr == USDTAddress || addr == USDCAddress, "Unexpected token");
        _;
    }

    modifier onlyWhitelisted(address _address) {
        require(whitelisted(_address), "Not whitelisted");
        _;
    }

    function whitelisted(address _address) public view returns (bool) {
        uint256 staked;

        for (uint256 i = 0; i < stakingContracts.length; i++) {
            staked += IStakeSum(stakingContracts[i]).balanceOf(_address);
        }

        return staked >= 1000 * 1e18;
    }

    // We want to leave ourselves the option change claim time
    function updateClaimTimestamp(uint256 _claimTime) external onlyOwner {
        claimTime = _claimTime;
    }

    function buy(ERC20 paymentToken, uint256 depositedAmount)
        external
        checkTimespan
        onlyWhitelisted(msg.sender)
    {
        uint256 rewardTokenAmount = getTokenAmount(
            paymentToken,
            depositedAmount
        );

        currentDistributed = currentDistributed + rewardTokenAmount;
        require(currentDistributed <= maxDistribution, "Overfilled");

        paymentToken.safeTransferFrom(msg.sender, treasury, depositedAmount);

        UserInfo storage user = userInfo[msg.sender];
        uint256 totalReward = user.reward + rewardTokenAmount;
        require(totalReward <= maxReward, "More then max amount");
        addUserReward(msg.sender, rewardTokenAmount);

        emit Bought(msg.sender, depositedAmount, rewardTokenAmount);
    }

    function getTokenAmount(ERC20 paymentToken, uint256 depositedAmount)
        public
        view
        checkPaymentTokenAddress(paymentToken)
        returns (uint256)
    {
        // Reward token has 18 decimals
        return (depositedAmount * 1e18) / tokenPrice;
    }

    function withdrawUnallocatedToken() external onlyOwner {
        require(block.timestamp > endTime, "Sale not ended");
        uint256 amount = maxDistribution - currentDistributed;

        rewardToken.safeTransfer(msg.sender, amount);
    }
}
// solhint-enable not-rely-on-time

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Util is ERC20 {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _mint(msg.sender, 1000**18);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC721 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC721Pausable is ERC721, Pausable {
    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC721Bros is Ownable, ERC721Enumerable, ERC721Pausable {
    string public contractURI;
    string public baseURI;

    mapping(uint256 => string) public _tokenURI;

    constructor(string memory _contractURI, string memory _baseURI)
        ERC721("Brokoli BROs", "BRO")
    {
        contractURI = _contractURI;
        baseURI = _baseURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            bytes(_tokenURI[_tokenId]).length == 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        Strings.toString(_tokenId),
                        ".json"
                    )
                )
                : _tokenURI[_tokenId];
    }

    function mint(address to, uint256 id) external onlyOwner {
        _mint(to, id);
    }

    function mintMultiple(address to, uint256[] calldata ids)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < ids.length; i++) {
            _mint(to, ids[i]);
        }
    }

    function pause() external virtual onlyOwner {
        _pause();
    }

    function setContractURI(string calldata uri_) external onlyOwner {
        contractURI = uri_;
    }

    function setTokenURI(uint256 _tokenId, string calldata uri_)
        external
        onlyOwner
    {
        _tokenURI[_tokenId] = uri_;
    }

    function setURI(string calldata uri_) external onlyOwner {
        baseURI = uri_;
    }

    function removeTokenURI(uint256 _tokenId) external onlyOwner {
        delete _tokenURI[_tokenId];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract ERC1155Sale is AccessControlEnumerable, IERC1155Receiver {
    using SafeERC20 for ERC20Burnable;

    address public immutable nftAddress;
    address public immutable paymentToken;

    // ROLES
    bytes32 public constant LISTER = keccak256("LISTER");
    bytes32 public constant WITHDRAWER = keccak256("WITHDRAWER");
    bytes32 public constant PAUSER = keccak256("PAUSER");

    bool public paused;
    event PausedStateChanged(bool paused, address by);

    struct Listing {
        uint256 nftId;
        uint256 price;
        uint256 amount;
    }
    Listing[] public listings;
    event ListingCreated(uint256 indexed listingId, Listing listing);
    event ListingChanged(uint256 indexed listingId, Listing listing);
    event ListingRemoved(uint256 indexed listingId, Listing listing);
    event ListingClaimed(
        address indexed claimedBy,
        uint256 indexed nftId,
        uint256 amount,
        uint256 paid
    );

    event WithdrawnNft(
        address indexed nftAddress,
        uint256 indexed nftId,
        uint256 amount,
        address by
    );
    event WithdrawnToken(address token, address by);
    event WithdrawnNative(address by);

    constructor(address _nftAddress, address _paymentToken) {
        nftAddress = _nftAddress;
        paymentToken = _paymentToken;

        _setupRole(LISTER, msg.sender);
        _setupRole(WITHDRAWER, msg.sender);
        _setupRole(PAUSER, msg.sender);
    }

    // Warning: Might fail with large amounts of listings
    function getAllListings() public view returns (Listing[] memory) {
        return listings;
    }

    function getListings(uint256 cursor, uint256 amount)
        public
        view
        returns (Listing[] memory values, uint256 newCursor)
    {
        uint256 length = amount;
        if (length > listings.length - cursor) {
            length = listings.length - cursor;
        }

        values = new Listing[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = listings[cursor + i];
        }

        newCursor = cursor + length;
    }

    function getListingsLength() public view returns (uint256) {
        return listings.length;
    }

    function createListing(
        uint256 nftId,
        uint256 price,
        uint256 amount
    ) public onlyRole(LISTER) {
        require(nftId > 0, "NFT id must be greater than 0");
        require(amount > 0, "Amount must be greater than 0");

        Listing memory listing = Listing(nftId, price, amount);
        listings.push(listing);
        emit ListingCreated(listings.length - 1, listing);
    }

    function editListing(
        uint256 listingId,
        uint256 price,
        uint256 amount
    ) public onlyRole(LISTER) {
        require(listingId < listings.length, "Listing index out of bounds");

        Listing storage listing = listings[listingId];
        listing.price = price;
        listing.amount = amount;
        emit ListingChanged(listingId, listing);
    }

    function removeListing(uint256 listingId) public onlyRole(LISTER) {
        require(listingId < listings.length, "Listing index out of bounds");

        emit ListingRemoved(listingId, listings[listingId]);

        listings[listingId] = listings[listings.length - 1];
        listings.pop();
    }

    function pause(bool _paused) public onlyRole(PAUSER) {
        if (paused != _paused) {
            paused = _paused;
            emit PausedStateChanged(paused, msg.sender);
        }
    }

    function claim(uint256 listingId, uint256 claimAmount) public {
        require(!paused, "Contract is paused");
        require(listingId < listings.length, "Listing index out of bounds");

        Listing storage listing = listings[listingId];
        require(listing.amount > 0, "No amount left");
        require(listing.amount >= claimAmount, "Not enough tokens to claim");

        uint256 payment = claimAmount * listing.price;

        _collectPayment(msg.sender, payment);

        IERC1155 nft = IERC1155(nftAddress);
        nft.safeTransferFrom(
            address(this),
            msg.sender,
            listing.nftId,
            claimAmount,
            bytes("")
        );
        listing.amount -= claimAmount;

        emit ListingClaimed(msg.sender, listing.nftId, claimAmount, payment);
    }

    function _collectPayment(address _from, uint256 _amount) internal virtual {
        ERC20Burnable token = ERC20Burnable(paymentToken);
        token.burnFrom(_from, _amount);
    }

    //
    // Emergency withdraw functions
    //
    function withdrawNft(
        address _nftAddress,
        uint256 nftId,
        uint256 amount
    ) public onlyRole(WITHDRAWER) {
        IERC1155 nft = IERC1155(_nftAddress);
        nft.safeTransferFrom(
            address(this),
            msg.sender,
            nftId,
            amount,
            bytes("")
        );
        emit WithdrawnNft(_nftAddress, nftId, amount, msg.sender);
    }

    function withdrawToken(address _token) public onlyRole(WITHDRAWER) {
        ERC20Burnable token = ERC20Burnable(_token);

        token.safeTransfer(msg.sender, token.balanceOf(address(this)));

        emit WithdrawnToken(_token, msg.sender);
    }

    function withdrawNative() external onlyRole(WITHDRAWER) {
        (bool sent, ) = msg.sender.call{value: address(this).balance}(""); // solhint-disable-line avoid-low-level-calls
        require(sent, "Failed to send Ether");
        emit WithdrawnNative(msg.sender);
    }

    function onERC1155Received(
        address, /* operator */
        address, /* from */
        uint256, /* id */
        uint256, /* value */
        bytes calldata /* data */
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, /* operator */
        address, /* from */
        uint256[] calldata, /* ids */
        uint256[] calldata, /* values */
        bytes calldata /* data */
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ERC20Seed.sol";
import "./ISeeder.sol";

/**
 * @title Seeder
 * @notice The Seeder contract is used to issue SEEDs (an ERC20 token) in exchange for fees.
 */
contract Seeder is ISeeder, AccessControlEnumerable {
    using SafeERC20 for IERC20;

    bytes32 public constant FEE_SETTER = keccak256("FEE_SETTER");
    bytes32 public constant WHITELIST_SETTER = keccak256("WHITELIST_SETTER");

    address private constant NATIVE_TOKEN =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public immutable seedAddress;
    address public collectionAddress;

    mapping(address => bool) public whitelisted;

    mapping(address => uint256) public feePerSeed;

    bool public restrictToWhitelisted;

    event RestrictToWhitelistedChanged(bool restrict, address sender);
    event Whitelisted(address indexed account, bool isWhitelisted);
    event FeePerSeedChanged(address indexed token, uint256 feePerSeed);
    event SeedsIssued(
        address indexed sender,
        address indexed feeToken,
        address indexed recipient,
        uint256 feeAmount,
        uint256 seedAmount
    );

    constructor(address _seed, address _collection) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FEE_SETTER, _msgSender());

        seedAddress = _seed;
        collectionAddress = _collection;

        restrictToWhitelisted = true;
    }

    modifier onlyWhitelisted() {
        require(
            !restrictToWhitelisted || whitelisted[msg.sender],
            "Address has not been whitelisted"
        );

        _;
    }

    function toggleRestrictToWhitelisted()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        restrictToWhitelisted = !restrictToWhitelisted;

        emit RestrictToWhitelistedChanged(restrictToWhitelisted, msg.sender);
    }

    /**
     * @notice set whitelisted addresse
     * @param _address array of addresses
     * @param _whitelisted bool `true` if the address is whitelisted and
     * `false` otherwise
     */
    function setWhitelisted(address _address, bool _whitelisted) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(WHITELIST_SETTER, msg.sender),
            "Not authorized"
        );
        whitelisted[_address] = _whitelisted;

        emit Whitelisted(_address, _whitelisted);
    }

    /**
     * @notice set whitelisted addresses
     * @param _addresses array of addresses
     * @param _whitelisted array of booleans, `true` if the address is whitelisted and
     * `false` otherwise
     */
    function setWhitelistedMultiple(
        address[] calldata _addresses,
        bool[] calldata _whitelisted
    ) external {
        require(_addresses.length == _whitelisted.length, "Length mismatch");

        unchecked {
            for (uint256 i = 0; i < _addresses.length; ++i) {
                setWhitelisted(_addresses[i], _whitelisted[i]);
            }
        }
    }

    /**
     * @notice Issues SEEDs in exchange for fee collected through ERC20 tokens.
     *
     * @param recipient The recipient of SEEDs.
     * @param feeToken The ERC20 token address that is being exchanged.
     * @param feeAmount The amount of 'feeToken' for which to issue SEEDs.
     *
     * @dev This function only transfers tokens if there are SEEDs to be issued.
     */
    function issueSeedsForErc20(
        address recipient,
        address feeToken,
        uint256 feeAmount
    ) external onlyWhitelisted {
        uint256 seeds = getSeedAmount(feeToken, feeAmount);

        if (seeds > 0) {
            IERC20(feeToken).safeTransferFrom(
                msg.sender,
                collectionAddress,
                feeAmount
            );

            ERC20Seed(seedAddress).mint(recipient, seeds);

            emit SeedsIssued(msg.sender, feeToken, recipient, feeAmount, seeds);
        }
    }

    /**
     * @notice Issues SEEDs in exchange for fee collected through ERC20 tokens.
     *
     * @param recipients The recipients of SEEDs.
     * @param feeToken The ERC20 token address that is being exchanged.
     * @param feeAmounts The amounts of 'feeToken' for which to issue SEEDs (in order of 'recipients').
     *
     * @dev This function only transfers tokens if there are SEEDs to be issued. It returns the potential leftovers.
     */
    function issueSeedsForErc20Multiple(
        address[] calldata recipients,
        address feeToken,
        uint256[] calldata feeAmounts
    ) external onlyWhitelisted {
        require(recipients.length == feeAmounts.length, "Length mismatch");

        if (!tokenIssuable(feeToken)) {
            return;
        }

        uint256 feeAmountTotal = 0;

        // Mint amounts
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 feeAmount = feeAmounts[i];
            uint256 seeds = getSeedAmount(feeToken, feeAmount);

            if (seeds > 0) {
                ERC20Seed(seedAddress).mint(recipients[i], seeds);
                feeAmountTotal += feeAmount;

                emit SeedsIssued(
                    msg.sender,
                    feeToken,
                    recipients[i],
                    feeAmount,
                    seeds
                );
            }
        }

        // Take only what was minted
        IERC20(feeToken).safeTransferFrom(
            msg.sender,
            collectionAddress,
            feeAmountTotal
        );
    }

    /**
     * @notice Issues SEEDs in exchange for ETH.
     *
     * @param recipient The recipient of SEEDs.
     *
     * @dev This function only transfers ETH if there are SEEDs to be issued.
     */
    function issueSeedsForNative(address recipient)
        external
        payable
        onlyWhitelisted
    {
        uint256 seeds = getSeedAmount(NATIVE_TOKEN, msg.value);

        if (seeds > 0) {
            sendNative(collectionAddress, msg.value);
            ERC20Seed(seedAddress).mint(recipient, seeds);

            emit SeedsIssued(
                msg.sender,
                NATIVE_TOKEN,
                recipient,
                msg.value,
                seeds
            );
        } else {
            sendNative(msg.sender, msg.value); // return to sender
        }
    }

    /**
     * @notice Issues SEEDs in exchange for ETH for multiple users.
     *
     * @param recipients The recipients of SEEDs.
     * @param feeAmounts The amounts of ETH.
     *
     * @dev This function only transfers ETH if there are SEEDs to be issued. It returns the potential leftovers.
     */
    function issueSeedsForNativeMultiple(
        address[] calldata recipients,
        uint256[] calldata feeAmounts
    ) external payable onlyWhitelisted {
        require(recipients.length == feeAmounts.length, "Length mismatch");

        if (!tokenIssuable(NATIVE_TOKEN)) {
            return;
        }

        uint256 feeAmountTotal = 0;

        // Mint amounts
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 feeAmount = feeAmounts[i];
            uint256 seeds = getSeedAmount(NATIVE_TOKEN, feeAmount);

            if (seeds > 0) {
                ERC20Seed(seedAddress).mint(recipients[i], seeds);
                feeAmountTotal += feeAmount;

                emit SeedsIssued(
                    msg.sender,
                    NATIVE_TOKEN,
                    recipients[i],
                    feeAmount,
                    seeds
                );
            }
        }

        sendNative(collectionAddress, feeAmountTotal);

        // Return leftovers to sender
        if (msg.value > feeAmountTotal) {
            sendNative(msg.sender, msg.value - feeAmountTotal);
        }
    }

    /**
     * @notice Returns the number of SEEDs that would be issued for a given token amount.
     *
     * @param token The ERC20 token address (use 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE for ETH).
     * @param amount The amount of 'token' for which to issue SEEDs.
     */
    function getSeedAmount(address token, uint256 amount)
        public
        view
        returns (uint256)
    {
        uint256 price = feePerSeed[token];

        if (price > 0) {
            return (amount * 1e18) / price;
        }

        return 0;
    }

    /**
     * Gets the role needed for setting fee for specified token.
     * @param token The ERC20 token address.
     */
    function tokenFeeSetterRole(address token) public pure returns (bytes32) {
        return bytes32(abi.encodePacked("FEE_SETTER", token));
    }

    /**
     * @notice Sets the fee for a given token. Use case: price oracles per specific token.
     *
     * @param token The ERC20 token address.
     * @param feeSetter The address of the account authorised to set fees for this token.
     */
    function setTokenFeeSetterRole(address token, address feeSetter)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(token != address(0), "token address cannot be 0");
        require(feeSetter != address(0), "fee setter address cannot be 0");
        require(
            tokenFeeSetterRole(token) != DEFAULT_ADMIN_ROLE &&
                tokenFeeSetterRole(token) != FEE_SETTER,
            "invalid fee setter role"
        );

        _setupRole(tokenFeeSetterRole(token), feeSetter);
    }

    function removeTokenFeeSetterRole(address token, address feeSetter)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(token != address(0), "token address cannot be 0");
        require(feeSetter != address(0), "fee setter address cannot be 0");

        _revokeRole(tokenFeeSetterRole(token), feeSetter);
    }

    /**
     * @notice Sets the amount of a given token that you must supply for 1 SEED.
     *
     * @param token The ERC20 token address.
     * @param price The fee in the token's base unit that would produce 1 SEED.
     *
     * @dev You need permission to set this fee for a token.
     */
    function setFeePerSeed(address token, uint256 price) public {
        require(
            hasRole(tokenFeeSetterRole(token), _msgSender()) ||
                hasRole(FEE_SETTER, _msgSender()),
            "Needs role for setting fee"
        );

        emit FeePerSeedChanged(token, price);
        feePerSeed[token] = price;
    }

    function setFeePerSeedMultiple(
        address[] calldata tokens,
        uint256[] calldata prices
    ) external {
        require(tokens.length == prices.length, "Length mismatch");

        for (uint256 i = 0; i < tokens.length; i++) {
            setFeePerSeed(tokens[i], prices[i]);
        }
    }

    function setCollectionAddress(address _address)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        collectionAddress = _address;
    }

    function tokenIssuable(address token) public view returns (bool) {
        return feePerSeed[token] > 0;
    }

    function sendNative(address _to, uint256 _amount) private {
        (bool sent, ) = payable(_to).call{value: _amount}(""); // solhint-disable-line avoid-low-level-calls
        require(sent, "Failed to send Ether");
    }

    // Utility functions to be able to recover any funds sent directly to the contract
    function emptyTokens(IERC20 _tokenAddress, address _to)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_to != address(0), "recipient cannot be 0");
        _tokenAddress.safeTransfer(_to, _tokenAddress.balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract ERC20Seed is ERC20PresetMinterPauser {
    event TransfersPaused();
    event TransfersUnpaused();
    event Whitelisted(address indexed account, bool isWhitelisted);
    event Blacklisted(address indexed account, bool isBlacklisted);

    /**
     * Addresses that are prevented from receiving, or sending tokens
     * event when enabled.
     * Can still be minted to.
     */
    mapping(address => bool) public blacklisted;

    /**
     * Addresses that are whitelisted to receive token transfers even when (only) transfers paused
     * Needed for potential bridging, exchanges, etc.
     */
    mapping(address => bool) public whitelisted;

    /**
     * Separate transferPaused flag that prevents only transfers (except to whitelistedTo addresses)
     * since we want to allow minting & burning when paused.
     *
     * There is still a global default 'pause' that halts all transfers and minting entirely.
     */
    bool public areTransfersPaused;

    constructor(string memory name, string memory symbol)
        ERC20PresetMinterPauser(name, symbol)
    {
        areTransfersPaused = true;
    }

    // Only pauses transfers (allows minting & burning)
    function pauseTransfers() external onlyRole(DEFAULT_ADMIN_ROLE) {
        areTransfersPaused = true;

        emit TransfersPaused();
    }

    // Only un-pauses transfers (allows minting & burning)
    // The global pause is still in effect
    function unPauseTransfers() external onlyRole(DEFAULT_ADMIN_ROLE) {
        areTransfersPaused = false;

        emit TransfersUnpaused();
    }

    function setWhitelisted(address _address, bool _whitelisted)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        whitelisted[_address] = _whitelisted;

        emit Whitelisted(_address, _whitelisted);
    }

    function setBlacklisted(address _address, bool _blacklisted)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        blacklisted[_address] = _blacklisted;

        emit Blacklisted(_address, _blacklisted);
    }

    /**
     * Transfers are disabled by default (only minting and burning is allowed).
     *
     * While transfers are paused, transfers are still allowed for whitelisted addresses. This
     * is useful for bridging, exchanges, etc.
     *
     * Blacklisted addresses are always prevented from receiving and sending tokens.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(
            !areTransfersPaused ||
                whitelisted[recipient] ||
                whitelisted[sender],
            "Transfers are paused"
        );

        require(
            !blacklisted[sender] && !blacklisted[recipient],
            "Blacklisted sender or recipient"
        );

        super._transfer(sender, recipient, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ISeeder {
    function feePerSeed(address feeToken) external view returns (uint256);

    function getSeedAmount(address token, uint256 amount)
        external
        view
        returns (uint256);

    function tokenIssuable(address token) external view returns (bool);

    function issueSeedsForErc20(
        address recipient,
        address feeToken,
        uint256 feeAmount
    ) external;

    function issueSeedsForErc20Multiple(
        address[] calldata recipients,
        address feeToken,
        uint256[] calldata feeAmounts
    ) external;

    function issueSeedsForNative(address recipient) external payable;

    function issueSeedsForNativeMultiple(
        address[] calldata recipients,
        uint256[] calldata feeAmounts
    ) external payable;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/presets/ERC20PresetMinterPauser.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../extensions/ERC20Burnable.sol";
import "../extensions/ERC20Pausable.sol";
import "../../../access/AccessControlEnumerable.sol";
import "../../../utils/Context.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract ERC20PresetMinterPauser is Context, AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../seed/ISeeder.sol";
import "../withdrawable/Withdrawable.sol";
import "./IDexProxyV2.sol";
import "./IPuppet.sol";

contract DexProxyV2 is IDexProxyV2, Withdrawable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public seeder;
    address private constant NATIVE_TOKEN =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // native coin address with checksum

    address public callTarget;
    address public puppet;

    mapping(address => bool) public isAllowanceTarget;

    event Swap(
        address indexed swapper,
        address sellToken,
        address buyToken,
        uint256 sellAmount,
        uint256 buyAmount,
        uint256 climateFee
    );
    event SeederChanged(address indexed seeder);
    event PuppetChanged(address indexed puppet);
    event CallTargetChanged(address indexed callTarget);
    event AllowanceTargetAdded(address indexed allowanceTarget);
    event AllowanceTargetRemoved(address indexed allowanceTarget);

    constructor(
        address _seeder,
        address _target,
        address _puppet
    ) {
        seeder = _seeder;
        callTarget = _target;
        puppet = _puppet;
    }

    function setSeeder(address _seeder) external onlyOwner {
        seeder = _seeder;

        emit SeederChanged(_seeder);
    }

    function setPuppet(address _puppet) external onlyOwner {
        puppet = _puppet;

        emit PuppetChanged(_puppet);
    }

    function setCallTarget(address _target) external onlyOwner {
        callTarget = _target;

        emit CallTargetChanged(_target);
    }

    function setAllowanceTargets(address[] calldata _targets)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _targets.length; i++) {
            isAllowanceTarget[_targets[i]] = true;

            emit AllowanceTargetAdded(_targets[i]);
        }
    }

    function removeAllowanceTargets(address[] calldata _targets)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _targets.length; i++) {
            isAllowanceTarget[_targets[i]] = false;

            emit AllowanceTargetRemoved(_targets[i]);
        }
    }

    /**
     * @notice Swaps exact amount of sell token for buy token, send the slippage to a treasury, and
     * issue seeds based on the slippage amount.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param allowanceTarget The target contract address for which the user needs to have an allowance.
     * @param sellToken The ERC20 token address of the token that is sent.
     * @param buyToken The ERC20 token address of the token that is received.
     * @param buyAmountMin The minimum amount of buyToken you agree to receive.
     * @param sellAmount The exact amount of sellToken you want to sell.
     *
     * @dev User should set the allowance for the allowanceTarget address to sellAmount in order to
     * be able to complete the swap.
     * after the swap is completed, if the buy token is issuable, the slippage is calculated.
     * if the slippage is greater than 0, the corresponding seeds amount is calculated.
     * if the seeds amount is greater than 0, the seeds are issued to the user and
     * the slippage is sent to the treasury. otherwise, the slippage is sent back to the user.
     */
    function exactSell(
        bytes calldata data,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external nonReentrant {
        require(tx.origin == msg.sender, "invalid sender"); // solhint-disable-line avoid-tx-origin
        require(isAllowanceTarget[allowanceTarget], "Invalid allowance target");

        uint256 initialBalance = IERC20(buyToken).balanceOf(address(this));

        IPuppet(puppet).withdrawToken(address(sellToken), sellAmount);
        sellToken.safeIncreaseAllowance(allowanceTarget, sellAmount);

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 buyAmount = updatedBalance - initialBalance;

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(buyToken));
        uint256 climateFee = tokenIssuable ? buyAmount - buyAmountMin : 0;

        if (getSeedAmount(address(buyToken), climateFee) > 0) {
            buyToken.safeTransfer(msg.sender, buyAmountMin);
            issueSeedsForErc20(buyToken, climateFee);
        } else {
            buyToken.safeTransfer(msg.sender, buyAmount);
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            address(buyToken),
            sellAmount,
            buyAmount - climateFee,
            climateFee
        );
    }

    /**
     * @notice Swaps exact amount of native token for buy token, send the slippage to a treasury,
     * and issue seeds based on the slippage amount.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param buyToken The ERC20 token address of the token that is received.
     * @param buyAmountMin the minimum amount of buyToken you agree to receive.
     *
     * @dev User should send the sell amount of native token along with the transaction.
     * after the swap is completed, if the buy token is issuable, the slippage is calculated.
     * if the slippage is greater than 0, the corresponding seeds amount is calculated.
     * if the seeds amount is greater than 0, the seeds are issued to the user and
     * the slippage is sent to the treasury. otherwise, the slippage is sent back to the user.
     */
    function exactSellWithSellNative(
        bytes calldata data,
        IERC20 buyToken,
        uint256 buyAmountMin
    ) external payable nonReentrant {
        uint256 initialBalance = IERC20(buyToken).balanceOf(address(this));

        (bool success, ) = callTarget.call{value: msg.value}(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 buyAmount = updatedBalance - initialBalance;

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(buyToken));
        uint256 climateFee = tokenIssuable ? buyAmount - buyAmountMin : 0;

        if (getSeedAmount(address(buyToken), climateFee) > 0) {
            buyToken.safeTransfer(msg.sender, buyAmountMin);
            issueSeedsForErc20(buyToken, climateFee);
        } else {
            buyToken.safeTransfer(msg.sender, buyAmount);
        }

        emit Swap(
            msg.sender,
            NATIVE_TOKEN,
            address(buyToken),
            msg.value,
            buyAmount - climateFee,
            climateFee
        );
    }

    /**
     * @notice Swaps exact amount of sell token for native token, send the slippage to a treasury, and
     * issue seeds based on the slippage amount.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param allowanceTarget The target contract address for which the user needs to have an allowance.
     * @param sellToken The ERC20 token address of the token that is sent.
     * @param buyAmountMin the minimum amount of native token you agree to receive.
     * @param sellAmount the exact amount of sellToken you want to sell.
     *
     * @dev User should set the allowance for the allowanceTarget address to sellAmount in order to
     * be able to complete the swap.
     * after the swap is completed, if the native token is issuable, the slippage is calculated.
     * if the slippage is greater than 0, the corresponding seeds amount is calculated.
     * if the seeds amount is greater than 0, the seeds are issued to the user and
     * the slippage is sent to the treasury.
     * otherwise, the slippage is sent back to the user.
     * if the caller is a contract, it should contain a payable fallback function.
     */
    function exactSellWithBuyNative(
        bytes calldata data,
        address allowanceTarget,
        IERC20 sellToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external nonReentrant {
        require(tx.origin == msg.sender, "invalid sender"); // solhint-disable-line avoid-tx-origin
        require(isAllowanceTarget[allowanceTarget], "Invalid allowance target");

        uint256 initialBalance = address(this).balance;

        IPuppet(puppet).withdrawToken(address(sellToken), sellAmount);
        sellToken.safeIncreaseAllowance(allowanceTarget, sellAmount);

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        // uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 updatedBalance = address(this).balance;
        uint256 buyAmount = updatedBalance - initialBalance;

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(NATIVE_TOKEN);
        uint256 climateFee = tokenIssuable ? buyAmount - buyAmountMin : 0;

        if (getSeedAmount(address(NATIVE_TOKEN), climateFee) > 0) {
            (bool successTransfer, ) = msg.sender.call{value: buyAmountMin}( // solhint-disable-line avoid-low-level-calls
                new bytes(0)
            );
            require(successTransfer, "Native Token transfer failed");

            issueSeedsForNative(climateFee);
        } else {
            (bool successTransfer, ) = msg.sender.call{value: buyAmount}( // solhint-disable-line avoid-low-level-calls
                new bytes(0)
            );
            require(successTransfer, "Native Token transfer failed");
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            NATIVE_TOKEN,
            sellAmount,
            buyAmount - climateFee,
            climateFee
        );
    }

    function issueSeedsForErc20(IERC20 token, uint256 climateFee) private {
        if (climateFee > 0) {
            token.safeIncreaseAllowance(seeder, climateFee);

            ISeeder(seeder).issueSeedsForErc20(
                msg.sender,
                address(token),
                climateFee
            );
        }
    }

    function issueSeedsForNative(uint256 climateFee) private {
        if (climateFee > 0) {
            ISeeder(seeder).issueSeedsForNative{value: climateFee}(msg.sender);
        }
    }

    function getSeedAmount(address feeToken, uint256 feeAmount)
        public
        view
        returns (uint256)
    {
        return
            feeAmount > 0
                ? ISeeder(seeder).getSeedAmount(feeToken, feeAmount)
                : 0;
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
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Withdrawable is Ownable {
    using SafeERC20 for IERC20;

    function sendTokens(IERC20 _tokenAddress, address _to) external onlyOwner {
        require(_to != address(0), "recipient cannot be 0");
        _tokenAddress.safeTransfer(_to, _tokenAddress.balanceOf(address(this)));
    }

    function sendNative(address payable _to) external onlyOwner {
        require(_to != address(0), "recipient cannot be 0");

        (bool sent, ) = _to.call{value: address(this).balance}(""); // solhint-disable-line avoid-low-level-calls
        require(sent, "Failed to send Ether");
    }

    receive() external payable virtual {} // solhint-disable-line no-empty-blocks
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDexProxyV2 {
    function seeder() external view returns (address);

    function setSeeder(address _seeder) external;

    function exactSell(
        bytes calldata data,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external;

    function exactSellWithSellNative(
        bytes calldata data,
        IERC20 buyToken,
        uint256 buyAmountMin
    ) external payable;

    function exactSellWithBuyNative(
        bytes calldata data,
        address allowanceTarget,
        IERC20 sellToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external;

    function getSeedAmount(address feeToken, uint256 feeAmount)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IPuppet {
    function withdrawToken(address _token, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDexProxy {
    function seeder() external view returns (address);

    function setSeeder(address _seeder) external;

    function exactBuy(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmountMax,
        uint256 buyAmount
    ) external;

    function exactBuyWithSellFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmountMax,
        uint256 buyAmount,
        uint256 feeAmount
    ) external;

    function exactBuyWithBuyFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmountMax,
        uint256 buyAmount,
        uint256 feePercentage
    ) external;

    function exactSell(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external;

    function exactSellWithSellNative(
        bytes calldata data,
        address callTarget,
        IERC20 buyToken,
        uint256 buyAmountMin
    ) external payable;

    function exactSellWithBuyNative(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external;

    function exactSellWithSellFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmount,
        uint256 feeAmount
    ) external;

    function exactSellWithBuyFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmount,
        uint256 feePercentage
    ) external;

    function getSeedAmount(address feeToken, uint256 feeAmount)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../seed/ISeeder.sol";
import "../withdrawable/Withdrawable.sol";
import "./IDexProxy.sol";

contract DexProxy is IDexProxy, Withdrawable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public seeder;
    uint256 public immutable divisor = 10000;
    address private constant NATIVE_TOKEN =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // native coin address with checksum

    event Swap(
        address indexed swapper,
        address sellToken,
        address buyToken,
        uint256 sellAmount,
        uint256 buyAmount,
        uint256 climateFee
    );

    constructor(address _seeder) {
        seeder = _seeder;
    }

    function setSeeder(address _seeder) external onlyOwner {
        seeder = _seeder;
    }

    function exactBuy(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmountMax,
        uint256 buyAmount
    ) external nonReentrant {
        uint256 initialBalance = IERC20(sellToken).balanceOf(address(this));

        sellToken.safeTransferFrom(msg.sender, address(this), sellAmountMax);
        sellToken.safeIncreaseAllowance(allowanceTarget, sellAmountMax);

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        buyToken.safeTransfer(msg.sender, buyAmount);

        uint256 updatedBalance = IERC20(sellToken).balanceOf(address(this));

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(sellToken));

        uint256 slippage = updatedBalance - initialBalance;
        uint256 climateFee = tokenIssuable ? slippage : 0;

        if (getSeedAmount(address(sellToken), climateFee) > 0) {
            issueSeedsForErc20(sellToken, climateFee);
        } else {
            sellToken.safeTransfer(msg.sender, slippage);
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            address(buyToken),
            sellAmountMax - slippage,
            buyAmount,
            climateFee
        );
    }

    function exactBuyWithSellFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmountMax,
        uint256 buyAmount,
        uint256 feeAmount
    ) external nonReentrant {
        uint256 initialBalance = IERC20(sellToken).balanceOf(address(this));

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(sellToken));
        uint256 climateFee = tokenIssuable ? feeAmount : 0;

        if (getSeedAmount(address(sellToken), climateFee) > 0) {
            uint256 greenSellAmount = sellAmountMax + feeAmount;

            sellToken.safeTransferFrom(
                msg.sender,
                address(this),
                greenSellAmount
            );
            sellToken.safeIncreaseAllowance(allowanceTarget, sellAmountMax);

            issueSeedsForErc20(sellToken, climateFee);
        } else {
            sellToken.safeTransferFrom(
                msg.sender,
                address(this),
                sellAmountMax
            );
            sellToken.safeIncreaseAllowance(allowanceTarget, sellAmountMax);
        }

        {
            (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
            require(success, "call not successful");
        }

        buyToken.safeTransfer(msg.sender, buyAmount);

        uint256 updatedBalance = IERC20(sellToken).balanceOf(address(this));
        uint256 slippage = updatedBalance - initialBalance;

        if (slippage > 0) {
            sellToken.safeTransfer(msg.sender, slippage);
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            address(buyToken),
            sellAmountMax - slippage,
            buyAmount,
            climateFee
        );
    }

    function exactBuyWithBuyFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmountMax,
        uint256 buyAmount,
        uint256 feePercentage
    ) external nonReentrant {
        uint256 initialBalance = IERC20(sellToken).balanceOf(address(this));

        sellToken.safeTransferFrom(msg.sender, address(this), sellAmountMax);
        sellToken.safeIncreaseAllowance(allowanceTarget, sellAmountMax);

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        uint256 updatedBalance = IERC20(sellToken).balanceOf(address(this));
        uint256 slippage = updatedBalance - initialBalance;

        if (slippage > 0) {
            sellToken.safeTransfer(msg.sender, slippage);
        }

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(buyToken));
        uint256 climateFee = tokenIssuable
            ? (buyAmount * feePercentage) / divisor
            : 0;

        if (getSeedAmount(address(buyToken), climateFee) > 0) {
            uint256 greenBuyAmount = buyAmount - climateFee;
            issueSeedsForErc20(buyToken, climateFee);

            buyToken.safeTransfer(msg.sender, greenBuyAmount);
        } else {
            buyToken.safeTransfer(msg.sender, buyAmount);
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            address(buyToken),
            sellAmountMax - slippage,
            buyAmount - climateFee,
            climateFee
        );
    }

    /**
     * @notice Swaps exact amount of sell token for buy token, send the slippage to a treasury, and
     * issue seeds based on the slippage amount.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param callTarget The address of the contract to send call data to.
     * @param allowanceTarget The target contract address for which the user needs to have an allowance.
     * @param sellToken The ERC20 token address of the token that is sent.
     * @param buyToken The ERC20 token address of the token that is received.
     * @param buyAmountMin The minimum amount of buyToken you agree to receive.
     * @param sellAmount The exact amount of sellToken you want to sell.
     *
     * @dev User should set the allowance for the allowanceTarget address to sellAmount in order to
     * be able to complete the swap.
     * after the swap is completed, if the buy token is issuable, the slippage is calculated.
     * if the slippage is greater than 0, the corresponding seeds amount is calculated.
     * if the seeds amount is greater than 0, the seeds are issued to the user and
     * the slippage is sent to the treasury. otherwise, the slippage is sent back to the user.
     */
    function exactSell(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external nonReentrant {
        uint256 initialBalance = IERC20(buyToken).balanceOf(address(this));

        sellToken.safeTransferFrom(msg.sender, address(this), sellAmount);
        sellToken.safeIncreaseAllowance(allowanceTarget, sellAmount);

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 buyAmount = updatedBalance - initialBalance;

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(buyToken));
        uint256 climateFee = tokenIssuable ? buyAmount - buyAmountMin : 0;

        if (getSeedAmount(address(buyToken), climateFee) > 0) {
            buyToken.safeTransfer(msg.sender, buyAmountMin);
            issueSeedsForErc20(buyToken, climateFee);
        } else {
            buyToken.safeTransfer(msg.sender, buyAmount);
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            address(buyToken),
            sellAmount,
            buyAmount - climateFee,
            climateFee
        );
    }

    /**
     * @notice Swaps exact amount of native token for buy token, send the slippage to a treasury,
     * and issue seeds based on the slippage amount.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param callTarget The address of the contract to send call data to.
     * @param buyToken The ERC20 token address of the token that is received.
     * @param buyAmountMin the minimum amount of buyToken you agree to receive.
     *
     * @dev User should send the sell amount of native token along with the transaction.
     * after the swap is completed, if the buy token is issuable, the slippage is calculated.
     * if the slippage is greater than 0, the corresponding seeds amount is calculated.
     * if the seeds amount is greater than 0, the seeds are issued to the user and
     * the slippage is sent to the treasury. otherwise, the slippage is sent back to the user.
     */
    function exactSellWithSellNative(
        bytes calldata data,
        address callTarget,
        IERC20 buyToken,
        uint256 buyAmountMin
    ) external payable nonReentrant {
        uint256 initialBalance = IERC20(buyToken).balanceOf(address(this));

        (bool success, ) = callTarget.call{value: msg.value}(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 buyAmount = updatedBalance - initialBalance;

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(buyToken));
        uint256 climateFee = tokenIssuable ? buyAmount - buyAmountMin : 0;

        if (getSeedAmount(address(buyToken), climateFee) > 0) {
            buyToken.safeTransfer(msg.sender, buyAmountMin);
            issueSeedsForErc20(buyToken, climateFee);
        } else {
            buyToken.safeTransfer(msg.sender, buyAmount);
        }

        emit Swap(
            msg.sender,
            NATIVE_TOKEN,
            address(buyToken),
            msg.value,
            buyAmount - climateFee,
            climateFee
        );
    }

    /**
     * @notice Swaps exact amount of sell token for native token, send the slippage to a treasury, and
     * issue seeds based on the slippage amount.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param callTarget The address of the contract to send call data to.
     * @param allowanceTarget The target contract address for which the user needs to have an allowance.
     * @param sellToken The ERC20 token address of the token that is sent.
     * @param buyAmountMin the minimum amount of native token you agree to receive.
     * @param sellAmount the exact amount of sellToken you want to sell.
     *
     * @dev User should set the allowance for the allowanceTarget address to sellAmount in order to
     * be able to complete the swap.
     * after the swap is completed, if the native token is issuable, the slippage is calculated.
     * if the slippage is greater than 0, the corresponding seeds amount is calculated.
     * if the seeds amount is greater than 0, the seeds are issued to the user and
     * the slippage is sent to the treasury.
     * otherwise, the slippage is sent back to the user.
     * if the caller is a contract, it should contain a payable fallback function.
     */
    function exactSellWithBuyNative(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        uint256 buyAmountMin,
        uint256 sellAmount
    ) external nonReentrant {
        // uint256 initialBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 initialBalance = address(this).balance;

        sellToken.safeTransferFrom(msg.sender, address(this), sellAmount);
        sellToken.safeIncreaseAllowance(allowanceTarget, sellAmount);

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        // uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 updatedBalance = address(this).balance;
        uint256 buyAmount = updatedBalance - initialBalance;

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(NATIVE_TOKEN);
        uint256 climateFee = tokenIssuable ? buyAmount - buyAmountMin : 0;

        if (getSeedAmount(address(NATIVE_TOKEN), climateFee) > 0) {
            (bool successTransfer, ) = msg.sender.call{value: buyAmountMin}( // solhint-disable-line avoid-low-level-calls
                new bytes(0)
            );
            require(successTransfer, "Native Token transfer failed");

            issueSeedsForNative(climateFee);
        } else {
            (bool successTransfer, ) = msg.sender.call{value: buyAmount}( // solhint-disable-line avoid-low-level-calls
                new bytes(0)
            );
            require(successTransfer, "Native Token transfer failed");
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            NATIVE_TOKEN,
            sellAmount,
            buyAmount - climateFee,
            climateFee
        );
    }

    /**
     * @notice Swaps exact amount of sell token for buy token, send the feeAmount to a treasury, and
     * issue seeds based on the feeAmount amount.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param callTarget The address of the contract to send call data to.
     * @param allowanceTarget The target contract address for which the user needs to have an allowance.
     * @param sellToken The ERC20 token address of the token that is sent.
     * @param buyToken The ERC20 token address of the token that is received.
     * @param sellAmount The exact amount of sellToken you want to sell.
     * @param feeAmount Exact amount of sell token paid by the caller as a fee.
     *
     * @dev User should set the allowance for the allowanceTarget address to sellAmount in order to
     * be able to complete the swap.
     * after the swap is completed, if the sell token is issuable, the corresponding seeds amount is
     * calculated base on feeAmount.
     * if the seeds amount is greater than 0, the seeds are issued to the user and the feeAmount is
     * sent to the treasury.
     * otherwise, the feeAmount is sent back to the user.
     */
    function exactSellWithSellFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmount,
        uint256 feeAmount
    ) external nonReentrant {
        uint256 initialBalance = IERC20(buyToken).balanceOf(address(this));

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(sellToken));

        uint256 climateFee = tokenIssuable ? feeAmount : 0;

        if (getSeedAmount(address(sellToken), climateFee) > 0) {
            uint256 greenSellAmount = sellAmount + feeAmount;

            sellToken.safeTransferFrom(
                msg.sender,
                address(this),
                greenSellAmount
            );
            sellToken.safeIncreaseAllowance(allowanceTarget, sellAmount);

            issueSeedsForErc20(sellToken, climateFee);
        } else {
            sellToken.safeTransferFrom(msg.sender, address(this), sellAmount);
            sellToken.safeIncreaseAllowance(allowanceTarget, sellAmount);
        }

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 buyAmount = updatedBalance - initialBalance;

        buyToken.safeTransfer(msg.sender, buyAmount);

        emit Swap(
            msg.sender,
            address(sellToken),
            address(buyToken),
            sellAmount - climateFee,
            buyAmount,
            climateFee
        );
    }

    /**
     * @notice Swaps exact amount of sell token for buy token, send the feePercentage to a treasury, and
     * issue seeds based on the feePercentage.
     *
     * @param data The call data required to be sent to the to callTarget address.
     * @param callTarget The address of the contract to send call data to.
     * @param allowanceTarget The target contract address for which the user needs to have an allowance.
     * @param sellToken The ERC20 token address of the token that is sent.
     * @param buyToken The ERC20 token address of the token that is received.
     * @param sellAmount The exact amount of sellToken you want to sell.
     * @param feePercentage The percentage of buy token paid by the caller as a climate fee.(up to 2 decimals)
     *
     * @dev User should set the allowance for the allowanceTarget address to sellAmount in order to
     * be able to complete the swap.
     * after the swap is completed, if the buy token is issuable, the corresponding seeds amount is
     * calculated base on feePercentage.
     * if the seeds amount is greater than 0, the seeds are issued to the user and
     * the feePercentage is sent to the treasury.
     * otherwise, the feePercentage is sent back to the user.
     */
    function exactSellWithBuyFee(
        bytes calldata data,
        address callTarget,
        address allowanceTarget,
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmount,
        uint256 feePercentage
    ) external nonReentrant {
        uint256 initialBalance = IERC20(buyToken).balanceOf(address(this));

        sellToken.safeTransferFrom(msg.sender, address(this), sellAmount);
        sellToken.safeIncreaseAllowance(allowanceTarget, sellAmount);

        (bool success, ) = callTarget.call(data); // solhint-disable-line avoid-low-level-calls
        require(success, "call not successful");

        uint256 updatedBalance = IERC20(buyToken).balanceOf(address(this));
        uint256 buyAmount = updatedBalance - initialBalance;

        bool tokenIssuable = ISeeder(seeder).tokenIssuable(address(buyToken));
        uint256 climateFee = tokenIssuable
            ? (buyAmount * feePercentage) / divisor
            : 0;

        if (getSeedAmount(address(buyToken), climateFee) > 0) {
            uint256 greenBuyAmount = buyAmount - climateFee;

            buyToken.safeTransfer(msg.sender, greenBuyAmount);

            issueSeedsForErc20(buyToken, climateFee);
        } else {
            buyToken.safeTransfer(msg.sender, buyAmount);
        }

        emit Swap(
            msg.sender,
            address(sellToken),
            address(buyToken),
            sellAmount,
            buyAmount - climateFee,
            climateFee
        );
    }

    function issueSeedsForErc20(IERC20 token, uint256 climateFee) private {
        if (climateFee > 0) {
            token.safeIncreaseAllowance(seeder, climateFee);

            ISeeder(seeder).issueSeedsForErc20(
                msg.sender,
                address(token),
                climateFee
            );
        }
    }

    function issueSeedsForNative(uint256 climateFee) private {
        if (climateFee > 0) {
            ISeeder(seeder).issueSeedsForNative{value: climateFee}(msg.sender);
        }
    }

    function getSeedAmount(address feeToken, uint256 feeAmount)
        public
        view
        returns (uint256)
    {
        return
            feeAmount > 0
                ? ISeeder(seeder).getSeedAmount(feeToken, feeAmount)
                : 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./ITokensFarm.sol";
import "../IStakeBalance.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * This contract is a wrapper for TokensFarm staking contracts that we use
 * for staking tokens on BSC.
 *
 * We use this to easily calculate voting power for the DAO.
 */
contract TokensFarmBalance is Ownable, IStakeBalance {
    ITokensFarm public stakeContract;
    uint256 public stakeAmountPercentage;

    constructor(address _stakeContract, uint256 _stakeAmountPercentage) {
        stakeContract = ITokensFarm(_stakeContract);
        stakeAmountPercentage = _stakeAmountPercentage;
    }

    function balanceOf(address _address) public view returns (uint256) {
        uint256 staked;
        (uint256[] memory deposits, , ) = stakeContract
            .getUserStakesAndPendingAmounts(_address);

        for (uint256 i = 0; i < deposits.length; i++) {
            staked += deposits[i];
        }

        return (staked * stakeAmountPercentage) / 100;
    }

    function setStakeContract(address _address) public onlyOwner {
        stakeContract = ITokensFarm(_address);
    }

    function setStakeAmountPercentage(uint256 _stakeAmountPercentage)
        public
        onlyOwner
    {
        stakeAmountPercentage = _stakeAmountPercentage;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ITokensFarm {
    function minTimeToStake() external view returns (uint256);

    function getUserStakesAndPendingAmounts(address user)
        external
        view
        returns (
            uint256[] memory deposits,
            uint256[] memory pendingAmounts,
            uint256[] memory depositTimes
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IStakeBalance {
    function balanceOf(address _address) external view returns (uint256);

    function setStakeContract(address _address) external;

    function setStakeAmountPercentage(uint256 _stakeAmountPercentage) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IStakeBalance.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * This contract is a wrapper for NFTrade staking contracts that we use
 * for staking tokens on BSC.
 *
 * We use this to easily calculate voting power for the DAO.
 */
contract StakePower is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public stakeAmountPercentage;

    EnumerableSet.AddressSet private balanceContractSet;

    constructor(uint256 _stakeAmountPercentage) {
        stakeAmountPercentage = _stakeAmountPercentage;
    }

    function balanceOf(address _address) public view returns (uint256) {
        uint256 balance;

        for (uint256 i = 0; i < balanceContractSet.length(); i++) {
            balance += IStakeBalance(balanceContractSet.at(i)).balanceOf(
                _address
            );
        }

        return (balance * stakeAmountPercentage) / 100;
    }

    function setStakeAmountPercentage(uint256 _stakeAmountPercentage)
        public
        onlyOwner
    {
        stakeAmountPercentage = _stakeAmountPercentage;
    }

    function addBalanceContract(address _contract) public onlyOwner {
        balanceContractSet.add(_contract);
    }

    function addBalanceContracts(address[] calldata _contracts)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _contracts.length; i++) {
            addBalanceContract(_contracts[i]);
        }
    }

    function removeBalanceContract(address _contract) public onlyOwner {
        balanceContractSet.remove(_contract);
    }

    function removeBalanceContracts(address[] calldata _contracts)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _contracts.length; i++) {
            removeBalanceContract(_contracts[i]);
        }
    }

    function getBalanceContracts() public view returns (address[] memory) {
        return balanceContractSet.values();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./INFTrade.sol";
import "../IStakeBalance.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * This contract is a wrapper for NFTrade staking contracts that we use
 * for staking tokens on BSC.
 *
 * We use this to easily calculate voting power for the DAO.
 */
contract NFTradeBalance is Ownable, IStakeBalance {
    INFTrade public stakeContract;
    uint256 public stakeAmountPercentage;

    address public tokenAddress;

    constructor(
        address _stakeContract,
        uint256 _stakeAmountPercentage,
        address _tokenAddress
    ) {
        stakeContract = INFTrade(_stakeContract);
        stakeAmountPercentage = _stakeAmountPercentage;
        tokenAddress = _tokenAddress;
    }

    function balanceOf(address _address) public view returns (uint256) {
        uint256 staked = stakeContract.getBalanceOf(tokenAddress, _address);

        return (staked * stakeAmountPercentage) / 100;
    }

    function setStakeContract(address _address) public onlyOwner {
        stakeContract = INFTrade(_address);
    }

    function setStakeAmountPercentage(uint256 _stakeAmountPercentage)
        public
        onlyOwner
    {
        stakeAmountPercentage = _stakeAmountPercentage;
    }

    function setTokenAddress(address _address) public onlyOwner {
        tokenAddress = _address;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface INFTrade {
    function getBalanceOf(address stakingToken, address userAddress)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC721Base is Ownable, ERC721Enumerable, ERC721Pausable {
    string public contractURI;
    string public baseURI;

    mapping(uint256 => string) public _tokenURI;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        contractURI = _contractURI;
        baseURI = _baseURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            bytes(_tokenURI[_tokenId]).length == 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        Strings.toString(_tokenId),
                        ".json"
                    )
                )
                : _tokenURI[_tokenId];
    }

    function mint(address to, uint256 id) external onlyOwner {
        _mint(to, id);
    }

    function mintMultiple(address[] calldata to, uint256[] calldata ids)
        external
        onlyOwner
    {
        require(to.length == ids.length, "Length mismatch");
        for (uint256 i = 0; i < ids.length; i++) {
            _mint(to[i], ids[i]);
        }
    }

    function pause() external virtual onlyOwner {
        _pause();
    }

    function setContractURI(string calldata uri_) external onlyOwner {
        contractURI = uri_;
    }

    function setTokenURI(uint256 _tokenId, string calldata uri_)
        external
        onlyOwner
    {
        _tokenURI[_tokenId] = uri_;
    }

    function setURI(string calldata uri_) external onlyOwner {
        baseURI = uri_;
    }

    function removeTokenURI(uint256 _tokenId) external onlyOwner {
        delete _tokenURI[_tokenId];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../ERC721Base.sol";

interface ILaunchpadNFT {
    // return max supply config for launchpad, if no reserved will be collection's max supply
    function getMaxLaunchpadSupply() external view returns (uint256);

    // return current launchpad supply
    function getLaunchpadSupply() external view returns (uint256);

    // this function need to restrict mint permission to launchpad contract
    function mintTo(address to, uint256 size) external;
}

contract GallerLaunchpadNft is ERC721Base, ILaunchpadNFT {
    address public launchpad;
    uint256 public launchpadMaxSupply; // max launch supply
    uint256 public launchpadSupply; // current launch supply

    uint256 public constant LAUNCHPAD_ID_START = 10000;

    event LaunchpadUpdated(address launchpadAddresss);
    event MaxSupplyUpdated(uint256 launchpadMaxSupply);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        address _launchpad,
        uint256 _launchMaxSupply
    ) ERC721Base(_name, _symbol, _contractURI, _baseURI) {
        launchpad = _launchpad;
        launchpadMaxSupply = _launchMaxSupply;
    }

    //
    // Launchpad - start
    //
    modifier onlyLaunchpad() {
        require(launchpad != address(0), "launchpad address must be set");
        require(msg.sender == launchpad, "must be called by the launchpad");
        _;
    }

    // This enables the Galler Launchpad to mint NFTs
    function mintTo(address to, uint256 size) external onlyLaunchpad {
        require(to != address(0), "can't mint to empty address");
        require(size > 0, "size must be greater than zero");
        require(
            launchpadSupply + size <= launchpadMaxSupply,
            "max supply reached"
        );

        uint256 mintId = LAUNCHPAD_ID_START + launchpadSupply;
        for (uint256 i = 1; i <= size; i++) {
            _mint(to, mintId + i);
            launchpadSupply++;
        }
    }

    function getMaxLaunchpadSupply() public view returns (uint256) {
        return launchpadMaxSupply;
    }

    function getLaunchpadSupply() public view returns (uint256) {
        return launchpadSupply;
    }

    //
    // Launchpad - end
    //

    function setLaunchpadAddress(address _address) external onlyOwner {
        require(_address != address(0), "Invalid launchpad address");
        launchpad = _address;

        emit LaunchpadUpdated(_address);
    }

    function setLaunchpadMaxSupply(uint256 _supply) external onlyOwner {
        require(_supply > launchpadSupply, "Low max supply");
        launchpadMaxSupply = _supply;

        emit MaxSupplyUpdated(_supply);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            bytes(_tokenURI[_tokenId]).length == 0
                ? baseURI
                : _tokenURI[_tokenId];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./ERC721Base.sol";

// This contract implies that different NFT tiers are represented by IDs multiplier
contract ERC721Tiers is ERC721Base {
    uint256 public constant TIER_DELIMITER = 10000;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI
    ) ERC721Base(_name, _symbol, _contractURI, _baseURI) {} // solhint-disable-line no-empty-blocks

    // Example: TIER_DELIMITER = 10000
    //
    // ID 0-9999 -> Tier 0
    // ID 10000-19999 -> Tier 1
    // ...
    function tier(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Nonexistent token");
        return tokenId / TIER_DELIMITER;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC1155Badge is Ownable, ERC1155Burnable {
    string public contractURI;

    mapping(uint256 => string) public tokenURI;

    constructor(string memory _tokenURI, string memory _contractURI)
        ERC1155(_tokenURI)
    {
        contractURI = _contractURI;
    }

    function uri(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            bytes(tokenURI[_tokenId]).length == 0
                ? string(
                    abi.encodePacked(
                        ERC1155.uri(_tokenId),
                        Strings.toString(_tokenId),
                        ".json"
                    )
                )
                : tokenURI[_tokenId];
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        _mint(to, id, amount, data);
    }

    function mintMultiple(address[] calldata to, uint256 id)
        external
        onlyOwner
    {
        for (uint256 _to = 0; _to < to.length; _to++) {
            _mint(to[_to], id, 1, "");
        }
    }

    function setContractURI(string calldata uri_) external onlyOwner {
        contractURI = uri_;
    }

    function setTokenURI(uint256 _tokenId, string calldata uri_)
        external
        onlyOwner
    {
        tokenURI[_tokenId] = uri_;
    }

    function setURI(string calldata uri_) external onlyOwner {
        _setURI(uri_);
    }

    function removeTokenURI(uint256 _tokenId) external onlyOwner {
        delete tokenURI[_tokenId];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC1155Ticket is AccessControl, ERC1155Burnable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public contractURI;

    bool public paused;

    mapping(uint256 => string) public tokenURI;

    constructor(string memory _tokenURI, string memory _contractURI)
        ERC1155(_tokenURI)
    {
        contractURI = _contractURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());

        pause();
    }

    function uri(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            bytes(tokenURI[_tokenId]).length == 0
                ? string(
                    abi.encodePacked(
                        ERC1155.uri(_tokenId),
                        Strings.toString(_tokenId),
                        ".json"
                    )
                )
                : tokenURI[_tokenId];
    }

    /**
     * Modifier
     */
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Must have default admin role"
        );
        _;
    }

    /**
     * Mint
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role");

        _mint(to, id, amount, data);
    }

    function mintMultiple(address[] calldata to, uint256 id) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role");

        for (uint256 _to = 0; _to < to.length; _to++) {
            _mint(to[_to], id, 1, "");
        }
    }

    /**
     * Pause
     */
    function pause() public virtual onlyOwner {
        paused = true;
    }

    function unpause() public virtual onlyOwner {
        paused = false;
    }

    /**
     * Set URIs
     */
    function setContractURI(string calldata uri_) external onlyOwner {
        contractURI = uri_;
    }

    function setTokenURI(uint256 _tokenId, string calldata uri_)
        external
        onlyOwner
    {
        tokenURI[_tokenId] = uri_;
    }

    function setURI(string calldata uri_) external onlyOwner {
        _setURI(uri_);
    }

    function removeTokenURI(uint256 _tokenId) external onlyOwner {
        delete tokenURI[_tokenId];
    }

    /**
     * Overrides
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(!paused, "Contract is paused");
        return super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(!paused, "Contract is paused");
        return super.safeTransferFrom(from, to, id, amount, data);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../nfts/ERC1155Ticket.sol";

contract RedeemTicket {
    event TicketClaim(
        address indexed sender,
        uint256 indexed id,
        uint256 amount
    );

    ERC1155Ticket public ticket;

    mapping(uint256 => address[]) public rewards;

    constructor(address _ticketContract) {
        require(_ticketContract != address(0), "zero address provided");
        ticket = ERC1155Ticket(_ticketContract);
    }

    function claim(uint256 id, uint256 amount) external {
        require(id <= 5, "the ticket id is invalid");
        require(amount > 0, "the amount has to be over 0");

        ticket.burn(msg.sender, id, amount);

        for (uint256 i = 0; i < amount; i++) {
            rewards[id].push(msg.sender);
        }

        emit TicketClaim(msg.sender, id, amount);
    }

    function getRewards(uint256 id) external view returns (address[] memory) {
        return rewards[id];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title BaseERC20
 *
 * @notice The BaseERC20 is a simple token template based on OpenZeppelin implementation
 * with total token supply initially minted to a single treasury.
 */
contract BaseERC20 is ERC20Burnable {
    constructor(
        string memory name,
        string memory symbol,
        address initialOwner,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(initialOwner, initialSupply);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./BaseERC20.sol";

contract BaseERC20Factory {
    event TokenCreated(
        address indexed token,
        string name,
        string symbol,
        address initialOwner,
        uint256 initialSupply
    );

    function create(
        string calldata name,
        string calldata symbol,
        uint256 initialSupply,
        address initialOwner
    ) external returns (address) {
        require(bytes(name).length > 0, "Name is empty");
        require(bytes(symbol).length > 0, "Symbol is empty");

        require(initialSupply > 0, "Low supply");
        require(initialOwner != address(0), "Invalid owner");

        ERC20 baseERC20 = new BaseERC20(
            name,
            symbol,
            initialOwner,
            initialSupply
        );

        emit TokenCreated(
            address(baseERC20),
            name,
            symbol,
            initialOwner,
            initialSupply
        );

        return address(baseERC20);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ERC20Test is ERC20Burnable {
    uint8 private _decimals;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 decimals_
    ) ERC20(_name, _symbol) {
        _decimals = decimals_;
        _mint(msg.sender, 1000000000 * 10**_decimals);
    }

    function mint(address tokenOwner, uint256 tokens) public {
        _mint(tokenOwner, tokens);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    receive() external payable {
        mint(msg.sender, 100 * decimals());
        if (msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

import "./TokenLock.sol";

interface IMintable {
    function mint(address _to, uint256 _amount) external;
}

// solhint-disable not-rely-on-time
contract XPFarm is AccessControlEnumerable {
    using SafeERC20 for IERC20;

    uint256 public constant MAX_STAKE_DAYS = 365;

    IMintable public immutable rewardToken;
    TokenLock public immutable tokenLock;

    struct StakeToken {
        uint256 totalStaked;
        uint256 rewardMultiplier; // In %. 100 = 1x, 200 = 2x, etc.
    }
    mapping(address => StakeToken) public stakeTokens;

    event TokenMultiplierSet(address indexed _token, uint256 _multiplier);

    event TokensStaked(
        address indexed _user,
        address indexed _token,
        uint256 _amount,
        uint256 _days,
        uint256 _rewardAmount
    );

    constructor(address _rewardToken, address _tokenLock) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        rewardToken = IMintable(_rewardToken);
        tokenLock = TokenLock(_tokenLock);
    }

    /**
     * @notice Stake (lock) the tokens and receive rewards.
     *
     * @param _token address of the token you want to stake
     * @param _amount amount of tokens you want to stake
     * @param _days amount of days you want to stake for
     */
    function stake(
        address _token,
        uint256 _amount,
        uint256 _days
    ) external {
        require(_days >= 1, "Stake period less than 1 day");
        require(_days <= MAX_STAKE_DAYS, "Stake period exceeds max");
        require(_amount > 0, "Cannot stake 0 tokens");
        require(stakeTokens[_token].rewardMultiplier > 0, "Token not accepted");

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        IERC20(_token).approve(address(tokenLock), _amount);
        tokenLock.lock(
            _token,
            _amount,
            msg.sender,
            block.timestamp + _days * 86400
        );

        uint256 reward = getRewardAmount(_token, _amount, _days);

        rewardToken.mint(msg.sender, reward);

        emit TokensStaked(msg.sender, _token, _amount, _days, reward);
    }

    /**
     * @notice Get the rewards you will receive for staking tokens.
     *
     * @param _token address of the token you want to stake
     * @param _amount amount of tokens you want to stake
     * @param _days amount of days you want to stake for
     */
    function getRewardAmount(
        address _token,
        uint256 _amount,
        uint256 _days
    ) public view returns (uint256) {
        uint256 multiplier = stakeTokens[_token].rewardMultiplier;
        uint256 amount;

        if (_days < 30) {
            amount = (_amount * _days * (_days * 14 + 986)) / 1000;
        } else if (_days <= 365) {
            amount = (_amount * _days * (_days * 18 + 13462)) / 10000;
        }

        return (amount * multiplier) / 100;
    }

    /**
     * @notice Set the reward multiplier for staking a token.
     *
     * @param _token address of the token
     * @param _multiplier multiplier of the token in % (100 = 1x, 200 = 2x, etc.)
     */
    function setTokenMultiplier(address _token, uint256 _multiplier)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        stakeTokens[_token].rewardMultiplier = _multiplier;
        emit TokenMultiplierSet(_token, _multiplier);
    }

    /**
     * @notice Set the reward multipliers for staking a tokens.
     *
     * @param _tokens addresses of the tokens
     * @param _multipliers multipliers of the tokens in % (100 = 1x, 200 = 2x, etc.)
     */
    function setTokenMultipliers(
        address[] calldata _tokens,
        uint256[] calldata _multipliers
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_tokens.length == _multipliers.length, "Length mismatch");

        for (uint256 i = 0; i < _tokens.length; i++) {
            setTokenMultiplier(_tokens[i], _multipliers[i]);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// solhint-disable not-rely-on-time
contract TokenLock is AccessControlEnumerable {
    using SafeERC20 for ERC20Burnable;

    address public constant DEAD_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    bytes32 public constant LOCKER = keccak256("LOCKER");
    bytes32 public constant EXTRA_TOKEN_WITHDRAWER =
        keccak256("EXTRA_TOKEN_WITHDRAWER");

    address public treasury;

    struct LockPosition {
        address _token;
        uint256 _amount;
        uint256 _unlockTime;
        uint256 _index;
    }
    mapping(address => LockPosition[]) public lockPositions;
    mapping(address => uint256) public totalLockAmount;

    struct PenaltyFee {
        uint256 burn;
        uint256 treasury;
        bool manualBurn;
    }
    mapping(address => PenaltyFee) public tokenPenaltyFees;

    event TokensLocked(
        address indexed _beneficiary,
        address indexed _token,
        uint256 _amount,
        uint256 _unlockTime
    );

    event TokensUnlocked(
        address indexed _beneficiary,
        address indexed _token,
        uint256 _amount
    );

    event TokensUnlockedWithPenalty(
        address indexed _beneficiary,
        address indexed _token,
        uint256 _amount,
        uint256 _penalty
    );

    event PenaltyFeesUpdated(
        address indexed _token,
        uint256 _burnFee,
        uint256 _treasuryFee,
        bool _manualBurn
    );

    event TreasuryChanged(address _treasury);

    constructor(address _treasury) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(LOCKER, msg.sender);
        _setupRole(EXTRA_TOKEN_WITHDRAWER, msg.sender);

        treasury = _treasury;
    }

    /**
     * @notice Update the treasury address
     * @param _treasury address of treasury
     * @dev only the admin can update the treasury address
     */
    function setTreasury(address _treasury)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        treasury = _treasury;
        emit TreasuryChanged(_treasury);
    }

    //
    // LockPosition getters
    //

    /**
     * @notice Get all lock posotion for a user
     * @param _address address of user
     * @return array of lock positions
     */
    function getAllLockPositions(address _address)
        public
        view
        returns (LockPosition[] memory)
    {
        return lockPositions[_address];
    }

    /**
     * @notice Get the length of lock positions for a user
     * @param _address address of user
     * @return length of lock positions
     */
    function getLockPositionsLength(address _address)
        public
        view
        returns (uint256)
    {
        return lockPositions[_address].length;
    }

    /**
     * @notice Get paginated lock posotion for a user
     * @param _address address of user
     * @param cursor pagination cursor
     * @param amount amount of lock positions to return
     * @return values array of lock positions
     * @return newCursor new cursor
     */
    function getLockPositions(
        address _address,
        uint256 cursor,
        uint256 amount
    ) public view returns (LockPosition[] memory values, uint256 newCursor) {
        uint256 length = amount;
        LockPosition[] memory positions = lockPositions[_address];

        if (length > positions.length - cursor) {
            length = positions.length - cursor;
        }

        values = new LockPosition[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = positions[cursor + i];
        }

        newCursor = cursor + length;
    }

    //
    // Penalty data
    //

    /**
     * @notice Update the penalty fees
     * @param _token Token address for which penalty fees are set
     * @param _burnFee percentage of penalty fees (100% => 10000)
     * @param _treasuryFee percentage of penalty fees (100% => 10000)
     * @dev only the admin can update the penalty fees
     */
    function updateTokenPenaltyFees(
        address _token,
        uint256 _burnFee,
        uint256 _treasuryFee,
        bool _manualBurn
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_burnFee + _treasuryFee < 10000, "Invalid fee");

        tokenPenaltyFees[_token] = PenaltyFee(
            _burnFee,
            _treasuryFee,
            _manualBurn
        );

        emit PenaltyFeesUpdated(_token, _burnFee, _treasuryFee, _manualBurn);
    }

    //
    // Locking & Unlocking
    //

    /**
     * @notice Lock tokens
     * @param _token address of token to lock
     * @param _amount amount of tokens to lock
     * @param _beneficiary address of beneficiary
     * @param _unlockTime time in seconds until the tokens are unlocked
     * @dev only the locker call this function. _beneficiary send token
     * to locker and locker approves TokenLock.
     */
    function lock(
        address _token,
        uint256 _amount,
        address _beneficiary,
        uint256 _unlockTime
    ) external onlyRole(LOCKER) {
        require(_amount > 0, "Cannot lock 0 tokens");
        require(_beneficiary != address(0), "Invalid address");
        require(_unlockTime > block.timestamp, "Invalid unlock time");

        ERC20Burnable(_token).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        lockPositions[_beneficiary].push(
            LockPosition(
                _token,
                _amount,
                _unlockTime,
                lockPositions[_beneficiary].length
            )
        );

        totalLockAmount[_token] += _amount;

        emit TokensLocked(_beneficiary, _token, _amount, _unlockTime);
    }

    /**
     * @notice Unlock token
     * @param _positionIndex the index of the lock position
     * @dev the function should be called after unlock time for
     * the specific lock position
     */
    function unlock(uint256 _positionIndex) external {
        require(
            _positionIndex < lockPositions[msg.sender].length,
            "Invalid index"
        );
        LockPosition memory lockPosition = lockPositions[msg.sender][
            _positionIndex
        ];
        require(
            block.timestamp >= lockPosition._unlockTime,
            "Tokens still locked"
        );

        _returnAllTokens(lockPosition);
    }

    /**
     * @notice Unlock token with penalty
     * @param _positionIndex the index of the lock position
     * @dev the function can be called before unlock time but
     * _beneficiary should pay penalty fee
     */
    function unlockWithPenalty(uint256 _positionIndex) external {
        require(
            _positionIndex < lockPositions[msg.sender].length,
            "Invalid index"
        );

        LockPosition memory lockPosition = lockPositions[msg.sender][
            _positionIndex
        ];

        if (block.timestamp < lockPosition._unlockTime) {
            // Deduct penalty
            _returnWithPenalty(lockPosition);
        } else {
            // Return all tokens
            _returnAllTokens(lockPosition);
        }
    }

    /**
     * @notice Send token to beneficiary
     * @param lockPosition lock position
     */
    function _returnAllTokens(LockPosition memory lockPosition) private {
        ERC20Burnable(lockPosition._token).safeTransfer(
            msg.sender,
            lockPosition._amount
        );
        emit TokensUnlocked(
            msg.sender,
            lockPosition._token,
            lockPosition._amount
        );
        _removePosition(msg.sender, lockPosition._index);
        totalLockAmount[lockPosition._token] -= lockPosition._amount;
    }

    /**
     * @notice Send token to beneficiary with penalty
     * and send penalty to treasury
     * @param lockPosition lock position
     */
    function _returnWithPenalty(LockPosition memory lockPosition) private {
        PenaltyFee memory tokenPenalty = tokenPenaltyFees[lockPosition._token];
        uint256 burnFee = (lockPosition._amount * tokenPenalty.burn) / 10000;

        uint256 treasuryFee = (lockPosition._amount * tokenPenalty.treasury) /
            10000;

        uint256 claimableAmount = lockPosition._amount - burnFee - treasuryFee;

        // Transfer to treasury
        ERC20Burnable(lockPosition._token).safeTransfer(treasury, treasuryFee);

        // Burn
        if (tokenPenalty.manualBurn) {
            ERC20Burnable(lockPosition._token).safeTransfer(
                DEAD_ADDRESS,
                burnFee
            );
        } else {
            ERC20Burnable(lockPosition._token).burn(burnFee);
        }

        // Transfer the rest to claimant
        ERC20Burnable(lockPosition._token).safeTransfer(
            msg.sender,
            claimableAmount
        );

        emit TokensUnlockedWithPenalty(
            msg.sender,
            lockPosition._token,
            claimableAmount,
            burnFee + treasuryFee
        );
        _removePosition(msg.sender, lockPosition._index);
        totalLockAmount[lockPosition._token] -= lockPosition._amount;
    }

    /**
     * @notice Remove position from the array
     * @param _beneficiary the address of the beneficiary
     * @param _positionIndex the index of the lock position
     */
    function _removePosition(address _beneficiary, uint256 _positionIndex)
        private
    {
        uint256 positionsLength = lockPositions[_beneficiary].length;
        LockPosition memory lastLockPosition = lockPositions[_beneficiary][
            positionsLength - 1
        ];
        lastLockPosition._index = _positionIndex;
        lockPositions[_beneficiary][_positionIndex] = lastLockPosition;
        lockPositions[_beneficiary].pop();
    }

    //
    // Extra utility functions
    //

    /**
     * @notice Withdraw extra tokens
     * @param _token the address of the token
     * @param _to the recipient address
     */
    function withdrawExtraTokens(address _token, address _to)
        external
        onlyRole(EXTRA_TOKEN_WITHDRAWER)
    {
        require(
            ERC20Burnable(_token).balanceOf(address(this)) > 0,
            "No tokens"
        );

        ERC20Burnable(_token).safeTransfer(
            _to,
            ERC20Burnable(_token).balanceOf(address(this)) -
                totalLockAmount[_token]
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Core0x {
    using SafeERC20 for IERC20;

    uint256 public excessSlippage;

    constructor(uint256 _excessSlippage) {
        excessSlippage = _excessSlippage;
    }

    function exactSell(
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 sellAmount,
        uint256 buyAmountMin
    ) external {
        sellToken.safeTransferFrom(msg.sender, address(this), sellAmount);

        uint256 buyAmount = buyAmountMin + excessSlippage;

        buyToken.safeTransfer(msg.sender, buyAmount);
    }

    function exactSellWithSellNative(IERC20 buyToken, uint256 buyAmountMin)
        external
        payable
    {
        require(msg.value > 0, "value is 0");

        uint256 buyAmount = buyAmountMin + excessSlippage;

        buyToken.safeTransfer(msg.sender, buyAmount);
    }

    function exactSellWithBuyNative(
        IERC20 sellToken,
        uint256 sellAmount,
        uint256 buyAmountMin
    ) external {
        sellToken.safeTransferFrom(msg.sender, address(this), sellAmount);

        uint256 buyAmount = buyAmountMin + excessSlippage;

        (bool success, ) = msg.sender.call{value: buyAmount}(""); // solhint-disable-line avoid-low-level-calls

        require(success, "call failed");
    }

    function exactBuy(
        IERC20 sellToken,
        IERC20 buyToken,
        uint256 buyAmount,
        uint256 sellAmountMax
    ) external {
        uint256 amountIn = sellAmountMax - excessSlippage;

        sellToken.safeTransferFrom(msg.sender, address(this), amountIn);

        buyToken.safeTransfer(msg.sender, buyAmount);
    }

    receive() external payable virtual {} // solhint-disable-line no-empty-blocks
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../claim/Claim.sol";

interface IWhitelistRegistry {
    function isWhitelisted(address _addr) external view returns (bool);
}

interface IERC20Burnable is IERC20 {
    function burnFrom(address _from, uint256 _amount) external;
}

// solhint-disable not-rely-on-time
contract PoolWithTiers is Claim {
    using SafeERC20 for IERC20Burnable;

    uint256 public startTime;
    uint256 public endTime;

    uint256 public immutable maxAllocationPerUser; // Maximum allocation per user in USD
    uint256 public immutable maxAllocationTotal; // Maximum allocation per pool in USD (raise amount)

    uint256 public totalAllocated;
    mapping(address => uint256) public userAllocated;

    address public immutable payToken; // USD - token that is paid
    address public immutable burnToken; // XP - token that is burned
    uint256 public immutable payTokenPerReward; // Amount of USD token for 1 reward token

    address public immutable whitelistRegistry;
    address public treasury;

    struct AllocationBundle {
        uint256 payTokenAmount;
        uint256 burnTokenAmount;
    }
    AllocationBundle[4] public allocationBundles;

    event Bought(
        address indexed user,
        uint256 rewardAmount,
        uint256 paidAmount,
        uint256 burnedAmount,
        uint256 bundleId,
        uint256 bundleAmount
    );

    constructor(
        uint256[3] memory _times, // [startTime, endTime, claimTime]
        uint256 _maxAllocation,
        uint256 _maxAllocationPerUser,
        address[3] memory _tokens, // [rewardtoken, payToken, burnToken]
        uint256 _payTokenPerReward,
        address _whitelistRegistry,
        address _treasury,
        uint256[4] memory _bundlePayTokenAmount,
        uint256[4] memory _bundleburnTokenAmount
    ) Claim(_times[2], _tokens[0]) {
        require(
            _whitelistRegistry != address(0),
            "Invalid whitelist registry address"
        );
        require(_treasury != address(0), "Invalid treasury address");

        startTime = _times[0];
        endTime = _times[1];

        maxAllocationTotal = _maxAllocation;
        maxAllocationPerUser = _maxAllocationPerUser;

        payToken = _tokens[1];
        burnToken = _tokens[2];
        payTokenPerReward = _payTokenPerReward;
        whitelistRegistry = _whitelistRegistry;
        treasury = _treasury;

        for (uint256 i = 0; i < 4; i++) {
            allocationBundles[i].payTokenAmount = _bundlePayTokenAmount[i];
            allocationBundles[i].burnTokenAmount = _bundleburnTokenAmount[i];
        }
    }

    /**
     * @notice get the bundles array
     */
    function getBundles()
        external
        view
        virtual
        returns (AllocationBundle[4] memory)
    {
        return allocationBundles;
    }

    /**
     * @notice It buys some one or more bundles and increases the allocations
     * @param _bundleId the index of bundle to buy
     * @param _bundleAmount the amount of bundles to buy
     * @dev caller should approve this contract before calling this function.
     * payTokens will be transferred from caller to the treasury
     * and burnTokens will be burned.
     */
    function buyBundles(uint256 _bundleId, uint256 _bundleAmount) external {
        // Check parameter bounds
        require(_bundleId >= 0 && _bundleId < 4, "Invalid bundle");
        require(_bundleAmount > 0, "Must be higher than 0");

        // Check times
        require(block.timestamp >= startTime, "Pool not started");
        require(block.timestamp < endTime, "Pool ended");

        // Check whitelist
        require(
            IWhitelistRegistry(whitelistRegistry).isWhitelisted(msg.sender),
            "Not whitelisted"
        );

        (uint256 burnAmount, uint256 payAmount) = getBundlePriceForAmount(
            _bundleId,
            _bundleAmount
        );

        // Check allocation limits
        userAllocated[msg.sender] += payAmount;
        require(
            payAmount + totalAllocated <= maxAllocationTotal,
            "Over total limit"
        );
        require(
            userAllocated[msg.sender] <= maxAllocationPerUser,
            "Over user limit"
        );

        // Transfer & Burn
        IERC20Burnable(burnToken).burnFrom(msg.sender, burnAmount);
        IERC20(payToken).transferFrom(msg.sender, treasury, payAmount);

        uint256 reward = _getReward(payAmount);
        addUserReward(msg.sender, reward);

        emit Bought(
            msg.sender,
            reward,
            payAmount,
            burnAmount,
            _bundleId,
            _bundleAmount
        );
    }

    /**
     * @notice It calculates and returns the burn and pay amount
     * for a bundle based on the amount of bundles
     * @param _bundleId the index of bundle
     * @param _numberOf the amount of bundles
     */
    function getBundlePriceForAmount(uint256 _bundleId, uint256 _numberOf)
        public
        view
        virtual
        returns (uint256 burnAmount, uint256 payAmount)
    {
        (uint256 _burnAmount, uint256 _payAmount) = _getBundlePrice(_bundleId);

        return (_burnAmount * _numberOf, _payAmount * _numberOf);
    }

    /**
     * @notice It calculates and returns the burn and pay amount
     * for one bundle
     * @param _bundleId the index of bundle
     */
    function _getBundlePrice(uint256 _bundleId)
        internal
        view
        virtual
        returns (uint256 burnAmount, uint256 payAmount)
    {
        AllocationBundle memory bundle = allocationBundles[_bundleId];

        return (bundle.burnTokenAmount, bundle.payTokenAmount);
    }

    /**
     * @notice It calculates and returns the rewards based on the
     * amount of pay tokens
     * @param _payAmount the amount of pay tokens
     */
    function _getReward(uint256 _payAmount) private view returns (uint256) {
        return _payAmount / payTokenPerReward;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./VestedClaim.sol";

contract Claim is VestedClaim {
    event ClaimantsAdded(
        address[] indexed claimants,
        uint256[] indexed amounts
    );

    event RewardsFrozen(address[] indexed claimants);

    constructor(uint256 _claimTime, address _token) VestedClaim(_token) {
        claimTime = _claimTime;
    }

    function updateClaimTimestamp(uint256 _claimTime) external onlyOwner {
        claimTime = _claimTime;
    }

    function addClaimants(
        address[] calldata _claimants,
        uint256[] calldata _claimAmounts
    ) external onlyOwner {
        require(
            _claimants.length == _claimAmounts.length,
            "Arrays do not have equal length"
        );

        for (uint256 i = 0; i < _claimants.length; i++) {
            setUserReward(_claimants[i], _claimAmounts[i]);
        }

        emit ClaimantsAdded(_claimants, _claimAmounts);
    }

    function freezeRewards(address[] memory _claimants) external onlyOwner {
        for (uint256 i = 0; i < _claimants.length; i++) {
            freezeUserReward(_claimants[i]);
        }

        emit RewardsFrozen(_claimants);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./BaseClaim.sol";

contract VestedClaim is BaseClaim {
    uint256 public constant BASE_POINTS = 10000;
    uint256 public initialUnlock; // percentage unlocked at claimTime (100% = 10000)
    uint256 public cliff; // delay before gradual unlock
    uint256 public vesting; // total time of gradual unlock
    uint256 public vestingInterval; // interval of unlock

    constructor(address _rewardToken) BaseClaim(_rewardToken) {
        require(initialUnlock <= BASE_POINTS, "initialUnlock too high");

        initialUnlock = 2000; // = 20%
        cliff = 90 days;
        vesting = 455 days;
        vestingInterval = 1 days;
    } // solhint-disable-line no-empty-blocks

    // This is a timed vesting contract
    //
    // Claimants can claim 20% of ther claim upon claimTime.
    // After 90 days, there is a cliff that starts a gradual unlock. For ~15 months (455 days),
    // a relative amount of the remaining 80% is unlocked.
    //
    // At claimTime: 20%
    // At claimTime + 90, until claimTime + 455 days: daily unlock
    // After claimTime + 90 + 455: 100%
    function calculateUnlockedAmount(uint256 _totalAmount, uint256 _timestamp)
        internal
        view
        override
        returns (uint256)
    {
        if (_timestamp < claimTime) {
            return 0;
        }

        uint256 timeSinceClaim = _timestamp - claimTime;
        uint256 unlockedAmount = 0;

        if (timeSinceClaim <= cliff) {
            unlockedAmount = (_totalAmount * initialUnlock) / BASE_POINTS;
        } else if (timeSinceClaim > cliff + vesting) {
            unlockedAmount = _totalAmount;
        } else {
            uint256 unlockedOnClaim = (_totalAmount * initialUnlock) / BASE_POINTS;
            uint256 vestable = _totalAmount - unlockedOnClaim;
            uint256 intervalsSince = (timeSinceClaim - cliff) / vestingInterval;
            uint256 totalVestingIntervals = vesting / vestingInterval;

            unlockedAmount =
                ((vestable * intervalsSince) / totalVestingIntervals) +
                unlockedOnClaim;
        }

        return unlockedAmount;
    }

    function totalAvailableAfter() public view override returns (uint256) {
        return claimTime + cliff + vesting;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../claim/Claim.sol";
import "../whitelisted/Whitelisted.sol";

// solhint-disable not-rely-on-time
contract IDO is Claim, Whitelisted {
    using SafeERC20 for ERC20;

    uint256 public immutable tokenPrice;

    ERC20 public immutable USDTAddress; // solhint-disable-line var-name-mixedcase
    ERC20 public immutable USDCAddress; // solhint-disable-line var-name-mixedcase

    uint256 public startTime;
    uint256 public endTime;
    uint256 public immutable _maxReward;
    uint256 public immutable maxDistribution;
    uint256 public currentDistributed;

    address public immutable treasury;

    event Bought(
        address indexed holder,
        uint256 depositedAmount,
        uint256 rewardAmount
    );

    constructor(
        uint256 _tokenPrice,
        address _rewardToken, // Provided by VestedClaim
        address _USDTAddress, // solhint-disable-line var-name-mixedcase
        address _USDCAddress, // solhint-disable-line var-name-mixedcase
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimTime,
        uint256 maxReward_,
        uint256 _maxDistribution,
        address _treasury
    ) Claim(_claimTime, _rewardToken) {
        require( // solhint-disable-line reason-string
            _startTime < _endTime,
            "Start timestamp must be less than finish timestamp"
        );
        require( // solhint-disable-line reason-string
            _endTime > block.timestamp,
            "Finish timestamp must be more than current block time"
        );

        tokenPrice = _tokenPrice;
        USDTAddress = ERC20(_USDTAddress);
        USDCAddress = ERC20(_USDCAddress);
        startTime = _startTime;
        endTime = _endTime;
        _maxReward = maxReward_;
        maxDistribution = _maxDistribution;
        treasury = _treasury;

        // Provided by VestedClaim
        claimTime = _claimTime;
    }

    modifier checkTimespan() {
        require(block.timestamp >= startTime, "Not started");
        require(block.timestamp < endTime, "Ended");
        _;
    }

    modifier checkPaymentTokenAddress(ERC20 addr) {
        require(addr == USDTAddress || addr == USDCAddress, "Unexpected token");
        _;
    }

    function getMaxReward(address) public view virtual returns (uint256) {
        return _maxReward;
    }

    function buy(ERC20 paymentToken, uint256 depositedAmount)
        external
        checkTimespan
        onlyWhitelisted(msg.sender)
    {
        uint256 rewardTokenAmount = getTokenAmount(
            paymentToken,
            depositedAmount
        );

        currentDistributed = currentDistributed + rewardTokenAmount;
        require(currentDistributed <= maxDistribution, "Overfilled");

        paymentToken.safeTransferFrom(msg.sender, treasury, depositedAmount);

        UserInfo storage user = userInfo[msg.sender];
        uint256 totalReward = user.reward + rewardTokenAmount;
        require(totalReward <= getMaxReward(msg.sender), "More then max amount");
        addUserReward(msg.sender, rewardTokenAmount);

        emit Bought(msg.sender, depositedAmount, rewardTokenAmount);
    }

    function getTokenAmount(ERC20 paymentToken, uint256 depositedAmount)
        public
        view
        checkPaymentTokenAddress(paymentToken)
        returns (uint256)
    {
        // Reward token has 18 decimals
        return (depositedAmount * 1e18) / tokenPrice;
    }

    function withdrawUnallocatedToken() external onlyOwner {
        require(block.timestamp > endTime, "Sale not ended");
        uint256 amount = maxDistribution - currentDistributed;

        rewardToken.safeTransfer(msg.sender, amount);
    }
}
// solhint-enable not-rely-on-time

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelisted is Ownable {
    mapping(address => bool) internal _whitelisted;

    event AddressesWhitelisted(address[] indexed accounts);

    modifier onlyWhitelisted(address addr) virtual {
        require(whitelisted(addr), "Address has not been whitelisted");
        _;
    }

    function whitelisted(address _address) public view virtual returns (bool) {
        return _whitelisted[_address];
    }

    function addWhitelisted(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _whitelisted[addresses[i]] = true;
        }

        emit AddressesWhitelisted(addresses);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IDO.sol";

// Ido with configurable vesting
contract IdoConfigurable is IDO {
    constructor(
        uint256 _tokenPrice,
        address _rewardToken, // Provided by VestedClaim
        address _USDTAddress, // solhint-disable-line var-name-mixedcase
        address _USDCAddress, // solhint-disable-line var-name-mixedcase
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimTime,
        uint256 _maxReward,
        uint256 _maxDistribution,
        address _treasury,
        uint256[4] memory vestingData
    )
        IDO(
            _tokenPrice,
            _rewardToken,
            _USDTAddress,
            _USDCAddress,
            _startTime,
            _endTime,
            _claimTime,
            _maxReward,
            _maxDistribution,
            _treasury
        )
    {
        require(vestingData[0] <= BASE_POINTS, "initialUnlock too high");

        initialUnlock = vestingData[0];
        cliff = vestingData[1];
        vesting = vestingData[2];
        vestingInterval = vestingData[3];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IdoConfigurable.sol";

// This IDO enables setting different max reward per address (as opposed to the same max reward for all addresses)
// With configurable vesting
// solhint-disable not-rely-on-time
contract DynamicIdoConfigurable is IdoConfigurable {
    mapping(address => uint256) public maxReward;

    event MaxRewardAdded(address indexed holder, uint256 rewardAmount);

    constructor(
        uint256 _tokenPrice,
        address _rewardToken, // Provided by VestedClaim
        address _USDTAddress, // solhint-disable-line var-name-mixedcase
        address _USDCAddress, // solhint-disable-line var-name-mixedcase
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimTime,
        uint256 _maxReward,
        uint256 _maxDistribution,
        address _treasury,
        uint256[4] memory vestingData
    )
        IdoConfigurable(
            _tokenPrice,
            _rewardToken,
            _USDTAddress,
            _USDCAddress,
            _startTime,
            _endTime,
            _claimTime,
            _maxReward,
            _maxDistribution,
            _treasury,
            vestingData
        )
    {} // solhint-disable-line no-empty-blocks

    // Override the existing whitelisted modifier
    function whitelisted(address _address) public view override returns (bool) {
        return maxReward[_address] > 0;
    }

    function getMaxReward(address holder) public view override returns (uint256) {
        return maxReward[holder];
    }

    function setMaxReward(address _holder, uint256 _maxReward) internal {
        maxReward[_holder] = _maxReward;

        emit MaxRewardAdded(_holder, _maxReward);
    }

    function setMaxRewardMultiple(
        address[] calldata _holders,
        uint256[] calldata _maxRewards
    ) external onlyOwner {
        require(
            _holders.length == _maxRewards.length,
            "Arrays must have the same length"
        );

        for (uint256 i = 0; i < _holders.length; ) {
            setMaxReward(_holders[i], _maxRewards[i]);
            unchecked {
                ++i;
            }
        }
    }
}
// solhint-enable not-rely-on-time

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IDO.sol";

// This IDO enables setting different max reward per address (as opposed to the same max reward for all addresses)

// solhint-disable not-rely-on-time
contract DynamicIdo is IDO {
    mapping(address => uint256) public maxReward;

    event MaxRewardAdded(address indexed holder, uint256 rewardAmount);

    constructor(
        uint256 _tokenPrice,
        address _rewardToken, // Provided by VestedClaim
        address _USDTAddress, // solhint-disable-line var-name-mixedcase
        address _USDCAddress, // solhint-disable-line var-name-mixedcase
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimTime,
        uint256 _maxReward,
        uint256 _maxDistribution,
        address _treasury
    )
        IDO(
            _tokenPrice,
            _rewardToken,
            _USDTAddress,
            _USDCAddress,
            _startTime,
            _endTime,
            _claimTime,
            _maxReward,
            _maxDistribution,
            _treasury
        )
    {} // solhint-disable-line no-empty-blocks

    // Override the existing whitelisted modifier
    function whitelisted(address _address) public view override returns (bool) {
        return maxReward[_address] > 0;
    }

    function getMaxReward(address holder) public view override returns (uint256) {
        return maxReward[holder];
    }

    function setMaxReward(address _holder, uint256 _maxReward) internal {
        maxReward[_holder] = _maxReward;

        emit MaxRewardAdded(_holder, _maxReward);
    }

    function setMaxRewardMultiple(
        address[] calldata _holders,
        uint256[] calldata _maxRewards
    ) external onlyOwner {
        require(
            _holders.length == _maxRewards.length,
            "Arrays must have the same length"
        );

        for (uint256 i = 0; i < _holders.length; ) {
            setMaxReward(_holders[i], _maxRewards[i]);
            unchecked {
                ++i;
            }
        }
    }
}
// solhint-enable not-rely-on-time

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../ido/DynamicIdo.sol";

// solhint-disable not-rely-on-time
contract IDOTest is DynamicIdo {
    constructor(
        uint256 _tokenPrice,
        address _rewardToken,
        address _USDTAddress, // solhint-disable-line var-name-mixedcase
        address _USDCAddress, // solhint-disable-line var-name-mixedcase
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimTime,
        uint256 _maxReward,
        uint256 _maxDistribution,
        address _treasury
    )
        DynamicIdo(
            _tokenPrice,
            _rewardToken,
            _USDTAddress,
            _USDCAddress,
            _startTime,
            _endTime,
            _claimTime,
            _maxReward,
            _maxDistribution,
            _treasury
        )
    {} // solhint-disable-line no-empty-blocks

    function testResetUser(address _user) external {
        UserInfo storage user = userInfo[_user];

        user.reward = 0;
        user.withdrawn = 0;
    }

    function testSetContractDistribution(uint256 _distribution) external {
        currentDistributed = _distribution;
    }

    function testBeforeStart() external {
        startTime = block.timestamp + 900;
        endTime = block.timestamp + 1800;
        claimTime = block.timestamp + 2100;
    }

    function testInProgress() external {
        startTime = block.timestamp - 300;
        endTime = block.timestamp + 900;
        claimTime = block.timestamp + 2100;
    }

    function testEndedNotClaimable() external {
        startTime = block.timestamp - 600;
        endTime = block.timestamp - 300;
        claimTime = block.timestamp + 900;
    }

    function testSetTimestamps(
        uint256 start,
        uint256 end,
        uint256 claim
    ) external {
        startTime = start;
        endTime = end;
        claimTime = claim;
    }

    function testClaimable() external {
        startTime = block.timestamp - 600;
        endTime = block.timestamp - 300;
        claimTime = block.timestamp;
    }

    function testFinishVesting() external {
        startTime = block.timestamp - 602 days;
        endTime = block.timestamp - 601 days;
        claimTime = block.timestamp - 600 days;
    }

    function testResetContract() external {
        currentDistributed = 0;
    }

    function testAddWhitelisted(address user) external {
        _whitelisted[user] = true;
    }

    function testRemoveWhitelisted(address user) external {
        _whitelisted[user] = false;
    }

    function testSetUserReward(address _user) external {
        UserInfo storage user = userInfo[_user];

        user.reward = 10000;
        user.withdrawn = 0;
    }

    function testSetMaxRewardMultiple(
        address[] calldata _holders,
        uint256[] calldata _maxRewards
    ) external {
        require(
            _holders.length == _maxRewards.length,
            "Arrays must have the same length"
        );

        for (uint256 i = 0; i < _holders.length; ) {
            setMaxReward(_holders[i], _maxRewards[i]);
            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Claim.sol";

contract ClaimConfigurable is Claim {
    constructor(uint256 _claimTime, address _token, uint256[4] memory vestingData) Claim(_claimTime, _token) {
        require(vestingData[0] <= BASE_POINTS, "initialUnlock too high");

        initialUnlock = vestingData[0];
        cliff = vestingData[1];
        vesting = vestingData[2];
        vestingInterval = vestingData[3];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../claim/VestedClaim.sol";

contract VestedClaimTest is VestedClaim {
    constructor(uint256 _claimTime, address _rewardToken)
        VestedClaim(_rewardToken)
    {
        claimTime = _claimTime;
    }

    function buy(uint256 _amount) external {
        addUserReward(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./VestedClaim.sol";

contract VestedClaimWithoutCliff is VestedClaim {
    constructor(address _rewardToken) VestedClaim(_rewardToken) {
        initialUnlock = 0; // = 0%
        cliff = 0 days;
        vesting = 455 days;
        vestingInterval = 1 days;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../claim/VestedClaimWithoutCliff.sol";

contract VestedClaimWithoutCliffTest is VestedClaimWithoutCliff {
    constructor(uint256 _claimTime, address _rewardToken)
        VestedClaimWithoutCliff(_rewardToken)
    {
        claimTime = _claimTime;
    }

    function buy(uint256 _amount) external {
        addUserReward(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "./PoolWithTiers.sol";

interface IERC721Tiers {
    function tier(uint256 tokenId) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);
}

contract PoolNftBoosted is PoolWithTiers {
    IERC721Tiers public immutable nft;

    // Five tiers of NFT boosts
    // 0 -> 0% added
    // 100 -> 1% added to bundle
    // 10000 -> 100% added to bundle
    uint256[5] public nftBoost;

    mapping(uint256 => bool) public nftUsed;
    mapping(address => bool) public isBoosted;

    struct UserNft {
        uint256 nftId;
        uint256 nftTier;
    }
    mapping(address => UserNft) public userNft;

    event PoolBoosted(address indexed user, uint256 nftId, uint256 nftTier);

    constructor(
        uint256[3] memory _times, // [startTime, endTime, claimTime]
        uint256 _maxAllocation,
        uint256 _maxAllocationPerUser,
        address[3] memory _tokens, // [rewardtoken, payToken, burnToken]
        uint256 _payTokenPerReward,
        address _whitelistRegistry,
        address _treasury,
        uint256[4] memory _bundlePayTokenAmount,
        uint256[4] memory _bundleBurnTokenAmount,
        address _nft,
        uint256[5] memory _nftBoostPerTier
    )
        PoolWithTiers(
            _times,
            _maxAllocation,
            _maxAllocationPerUser,
            _tokens,
            _payTokenPerReward,
            _whitelistRegistry,
            _treasury,
            _bundlePayTokenAmount,
            _bundleBurnTokenAmount
        )
    {
        nft = IERC721Tiers(_nft);
        nftBoost = _nftBoostPerTier;
    }

    /**
     * @dev It lets whitelisted user to boos the pool with their NFT
     * @param _nftId The user to add.
     */
    function boostPool(uint256 _nftId) external {
        // Check whitelist
        require(
            IWhitelistRegistry(whitelistRegistry).isWhitelisted(msg.sender),
            "Not whitelisted"
        );

        // Check owner of NFT
        require(nft.ownerOf(_nftId) == msg.sender, "Not owner of NFT");

        // Check that NFT not already used
        require(!nftUsed[_nftId], "NFT already used");

        // Check if user already boosted
        require(!isBoosted[msg.sender], "User already boosted");

        nftUsed[_nftId] = true;
        isBoosted[msg.sender] = true;
        userNft[msg.sender] = UserNft(_nftId, nft.tier(_nftId));

        emit PoolBoosted(msg.sender, _nftId, nft.tier(_nftId));
    }

    /**
     * @notice It calculates and returns the array of
     * AllocationBundle(payAmount, burnAmount) for the given tier.
     * @param _tier the index of tier
     */
    function getBundlesForTier(uint256 _tier)
        external
        view
        virtual
        returns (AllocationBundle[4] memory)
    {
        AllocationBundle[4] memory bundles = allocationBundles;

        for (uint256 i = 0; i < 4; i++) {
            (uint256 _burnAmount, uint256 _payAmount) = _getBundlePriceForTier(
                i,
                _tier
            );
            bundles[i].payTokenAmount = _payAmount;
            bundles[i].burnTokenAmount = _burnAmount;
        }

        return bundles;
    }

    /**
     * @notice It calculates and returns the burn and pay amount
     * for a bundle based on the amount of bundles
     * @param _bundleId the index of bundle
     * @param _numberOf the amount of bundles
     */
    function getBundlePriceForAmount(uint256 _bundleId, uint256 _numberOf)
        public
        view
        override
        returns (uint256 burnAmount, uint256 payAmount)
    {
        (uint256 _burnAmount, uint256 _payAmount) = _getBundlePriceForTier(
            _bundleId,
            nftBoost[userNft[msg.sender].nftTier]
        );

        return (_burnAmount * _numberOf, _payAmount * _numberOf);
    }

    /**
     * @notice It calculates and returns the burn and pay amount
     * for a bundle based on tier
     * @param _bundleId the index of bundle
     * @param _tier the index of tier
     */
    function _getBundlePriceForTier(uint256 _bundleId, uint256 _tier)
        internal
        view
        returns (uint256 burnAmount, uint256 payAmount)
    {
        AllocationBundle memory bundle = allocationBundles[_bundleId];

        uint256 boostedPayAmount = (bundle.payTokenAmount *
            (10000 + nftBoost[_tier])) / 10000;

        return (bundle.burnTokenAmount, boostedPayAmount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "./Lottery.sol";
import "./PoolNftBoosted.sol";

contract PoolWithLottery is Lottery, PoolNftBoosted {
    struct LotteryBundle {
        uint256 amount;
        uint256 burnTokenAmount;
    }
    LotteryBundle[3] public lotteryBurnBundles; // 1 ticket, 2 tickets, 3 tickets

    uint256 public ticketAllocation;
    uint256 public ticketReward;
    uint256 public totalAllocationBought;

    bool public lotteryInitialized = false;

    // track if user has claimed non-winning tickets
    mapping(address => bool) userLotteryWithdrawn;

    event TicketsBought(
        address indexed user,
        uint256 amount,
        uint256 paidAmount,
        uint256 burnedAmount
    );

    event LotteryDrawn();
    event LotteryClaimed(address indexed user, uint256 tickets);
    event LotteryInitialized(uint256 ticketReward, uint256 maxWinningTickets);

    constructor(
        uint256[3] memory _times, // [startTime, endTime, claimTime]
        uint256 _maxAllocation,
        uint256 _maxAllocationPerUser,
        address[3] memory _tokens, // [rewardtoken, payToken, burnToken]
        uint256 _payTokenPerReward,
        address _whitelistRegistry,
        address _treasury,
        uint256[4] memory _bundlePayTokenAmount,
        uint256[4] memory _bundleburnTokenAmount,
        address _nft,
        uint256[5] memory _nftBoostPerTier
    )
        PoolNftBoosted(
            _times,
            _maxAllocation,
            _maxAllocationPerUser,
            _tokens,
            _payTokenPerReward,
            _whitelistRegistry,
            _treasury,
            _bundlePayTokenAmount,
            _bundleburnTokenAmount,
            _nft,
            _nftBoostPerTier
        )
    {}

    /**
     * @notice It initializes the lottery. should be called only
     * once after deploying.
     * @param _ticketAllocation the amount of allocation per ticket
     * @param _winningTickets the maximum number of tickets that can be won
     * @param _lotteryBundleTicketAmount the amount of tickets which exist in
     * each bundle
     * @param _lotteryBundleBurnAmount the amount of tokens which should
     * be burned for buying each bundle
     */
    function initLottery(
        uint256 _ticketAllocation,
        uint256 _winningTickets,
        uint256[3] calldata _lotteryBundleTicketAmount,
        uint256[3] calldata _lotteryBundleBurnAmount
    ) external onlyOwner {
        require(!lotteryInitialized, "Lottery already initialized");
        require(_ticketAllocation > 0, "Invalid ticket allocation");
        require(_winningTickets > 0, "Invalid winning tickets");

        for (uint256 i = 0; i < 3; i++) {
            lotteryBurnBundles[i].amount = _lotteryBundleTicketAmount[i];
            lotteryBurnBundles[i].burnTokenAmount = _lotteryBundleBurnAmount[i];
        }

        ticketAllocation = _ticketAllocation;
        ticketReward = ticketAllocation / payTokenPerReward;
        maxWinningTickets = _winningTickets;

        lotteryInitialized = true;

        emit LotteryInitialized(ticketReward, maxWinningTickets);
    }

    /**
     * @notice It returns the bundles array
     */
    function getLotteryBurnBundles()
        external
        view
        returns (LotteryBundle[3] memory)
    {
        return lotteryBurnBundles;
    }

    function getLotteryAllocation() public view returns (uint256) {
        return maxWinningTickets * ticketAllocation;
    }

    /**
     * @notice It buys some one or more bundles and increases the allocations
     * @param _bundleId the index of bundle to buy
     * @param _bundleAmount the amount of bundles to buy
     * @dev caller should approve this contract before calling this function.
     * payTokens will be transferred from caller to this contract or treasury
     * and burnTokens will be burned.
     */
    function buyLotteryBundles(uint256 _bundleId, uint256 _bundleAmount)
        external
    {
        require(lotteryInitialized, "Lottery not initialized");

        // Check parameter bounds
        require(_bundleId >= 0 && _bundleId < 3, "Invalid bundle");
        require(_bundleAmount > 0, "Amount must be higher than 0");

        // Check times
        require(block.timestamp >= startTime, "Pool not started");
        require(block.timestamp < endTime, "Pool ended");

        // Check whitelist
        require(
            IWhitelistRegistry(whitelistRegistry).isWhitelisted(msg.sender),
            "Not whitelisted"
        );

        (
            uint256 burnAmount,
            uint256 payAmount
        ) = getLotteryBundlePriceForAmount(_bundleId, _bundleAmount);

        // Burn
        IERC20Burnable(burnToken).burnFrom(msg.sender, burnAmount);

        // Transfer
        if (totalAllocationBought < getLotteryAllocation()) {
            // Within guaranteed winnings (non-claimable)
            uint256 potentialTotal = totalAllocationBought + payAmount;

            if (potentialTotal < getLotteryAllocation()) {
                // Send all to treasury
                IERC20(payToken).transferFrom(msg.sender, treasury, payAmount);
            } else {
                // Send remaining guaranteed to treasury
                IERC20(payToken).transferFrom(
                    msg.sender,
                    treasury,
                    getLotteryAllocation() - totalAllocationBought
                );

                // Hold the rest on the pool for claiming back losing tickets
                IERC20(payToken).transferFrom(
                    msg.sender,
                    address(this),
                    potentialTotal - getLotteryAllocation()
                );
            }
        } else {
            // All additional funds are claimable upon lottery
            IERC20(payToken).transferFrom(msg.sender, address(this), payAmount);
        }
        totalAllocationBought += payAmount;

        _enterTickets(
            msg.sender,
            uint128(lotteryBurnBundles[_bundleId].amount * _bundleAmount)
        );

        emit TicketsBought(
            msg.sender,
            lotteryBurnBundles[_bundleId].amount * _bundleAmount,
            payAmount,
            burnAmount
        );
    }

    /**
     * @notice Non winner users can calim back only their payTokens
     * @dev should be called only after lottery is drawn
     * it calculates the amounts based on the non-winning tickets
     * and _ticketAllocation (nonWinningTickets * ticketAllocation)
     */
    function claimNonWinningTickets() external {
        require(lotteryDrawn, "Lottery not drawn");
        require(!userLotteryWithdrawn[msg.sender], "Already withdrawn");

        uint256 nonWinningTickets = userTickets[msg.sender].total -
            userTickets[msg.sender].winning;

        userLotteryWithdrawn[msg.sender] = true;

        if (nonWinningTickets > 0) {
            IERC20(payToken).transfer(
                msg.sender,
                nonWinningTickets * ticketAllocation
            );
        }

        emit LotteryClaimed(msg.sender, nonWinningTickets);
    }

    /**
     * @notice It draws the lottery
     * @dev should be called only by admin
     */
    function drawLottery(uint256 _seed) external onlyOwner {
        _drawLottery(_seed);
        emit LotteryDrawn();
    }

    /**
     * @notice It assigns the winning tickets to the winners
     * and increases the reward of user
     * @dev should be called only by admin
     */
    function _assignWinner(address _winner) internal override {
        super._assignWinner(_winner);
        addUserReward(_winner, ticketReward);
    }

    /**
     * @notice It calculates and returns the burn and pay amount
     * for a bundle
     * @param _bundleId the index of bundle
     * @param _numberOf the amount of bundles
     */
    function getLotteryBundlePriceForAmount(
        uint256 _bundleId,
        uint256 _numberOf
    ) public view virtual returns (uint256 burnAmount, uint256 payAmount) {
        burnAmount = lotteryBurnBundles[_bundleId].burnTokenAmount * _numberOf;
        payAmount =
            ticketAllocation *
            _numberOf *
            lotteryBurnBundles[_bundleId].amount;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

contract Lottery {
    address[] public tickets;
    uint256 public maxWinningTickets;

    bool public lotteryDrawn = false;

    struct UserTickets {
        uint128 total;
        uint128 winning;
    }
    mapping(address => UserTickets) public userTickets;

    /**
     * @notice It draws a lottery and assigns tickets to users.
     * @param _seed random value to make lottery unpredictable
     * @dev it generates a random number as a startIndex of shuffled tickets
     */
    function _drawLottery(uint256 _seed) internal virtual {
        require(!lotteryDrawn, "Lottery already drawn");
        require(tickets.length > 0, "No tickets available");

        uint256 startIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, _seed))
        ) % tickets.length;

        uint256 lastIndex = tickets.length - 1;

        if (startIndex + maxWinningTickets <= tickets.length) {
            // Continuous interval
            _assignWinners(startIndex, startIndex + maxWinningTickets - 1);
        } else {
            // Non-Continuous interval
            _assignWinners(startIndex, lastIndex);
            _assignWinners(0, maxWinningTickets + startIndex - lastIndex - 2);
        }

        lotteryDrawn = true;
    }

    /**
     * @notice It selects the winning tickets from array of tickets
     * @param _start index of first winning ticket
     * @param _end index of last winning ticket
     */
    function _assignWinners(uint256 _start, uint256 _end) private {
        for (uint256 i = _start; i <= _end; ) {
            _assignWinner(tickets[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice It increases the amount of winning tickets of _winner
     * @param _winner the winner address which is also the ticket id
     */
    function _assignWinner(address _winner) internal virtual {
        userTickets[_winner].winning++;
    }

    /**
     * @notice It adds one or more amount of tickets to lottery
     * @param _address address of the user which will used
     * as a ticket id. it can be repetitious.
     * @param _amount the amount of tickets to add
     * @dev since it uses the user address as a ticket id,
     * then after selecting the winning tickets, contract can
     * assign winner by increasing userTickets[_address].winning
     * where _address is equal to winning ticket id which has been
     * randomly selected by contract.
     */
    function _enterTickets(address _address, uint128 _amount) internal virtual {
        for (uint128 i = 0; i < _amount; ) {
            _enterTicket(_address);
            unchecked {
                ++i;
            }
        }

        userTickets[_address].total += _amount;
    }

    /**
     * @notice It adds one ticket to lottery
     * @param _address address of the user which will used
     * as a ticket id. it can be repetitious.
     * @dev it shufles the tickets array and adds the ticket
     */
    function _enterTicket(address _address) private {
        if (tickets.length == 0) {
            tickets.push(_address);
            return;
        }

        // pseudo-random
        uint256 _index = uint256(
            keccak256(abi.encodePacked(block.timestamp, tickets.length))
        ) % tickets.length;

        tickets.push(tickets[_index]);
        tickets[_index] = _address;
    }

    // Unsafe - could break on large numbers
    function getTickets() public view returns (address[] memory) {
        return tickets;
    }

    function getTicketsLength() public view returns (uint256) {
        return tickets.length;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Puppet is AccessControlEnumerable {
    using SafeERC20 for IERC20;

    bytes32 public constant WITHDRAWER_SETTER = keccak256("WITHDRAWER_SETTER");
    bytes32 public constant WITHDRAWER_REMOVER =
        keccak256("WITHDRAWER_REMOVER");

    mapping(address => bool) public isWithdrawer;
    address[] public withdrawers;

    event WithdrawerAdded(address indexed withdrawer);
    event WithdrawerRemoved(address indexed withdrawer);
    event WithdrawersDeleted();

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(WITHDRAWER_SETTER, _msgSender());
        _setupRole(WITHDRAWER_REMOVER, _msgSender());
    }

    modifier onlyWithdrawer() {
        require(isWithdrawer[msg.sender], "Not approved");
        _;
    }

    function setWithdrawer(address _withdrawer)
        external
        onlyRole(WITHDRAWER_SETTER)
    {
        if (isWithdrawer[_withdrawer]) {
            return;
        }
        isWithdrawer[_withdrawer] = true;
        withdrawers.push(_withdrawer);
        emit WithdrawerAdded(_withdrawer);
    }

    function getWithdrawers() external view returns (address[] memory) {
        return withdrawers;
    }

    function removeWithdrawerAt(uint256 _index)
        external
        onlyRole(WITHDRAWER_REMOVER)
    {
        require(_index < withdrawers.length, "Index out of bounds");
        address _withdrawer = withdrawers[_index];

        isWithdrawer[_withdrawer] = false;

        if (_index != withdrawers.length - 1) {
            withdrawers[_index] = withdrawers[withdrawers.length - 1];
        }

        withdrawers.pop();

        emit WithdrawerRemoved(_withdrawer);
    }

    function removeWithdrawer(address _withdrawer)
        external
        onlyRole(WITHDRAWER_REMOVER)
    {
        isWithdrawer[_withdrawer] = false;

        uint256 length = withdrawers.length;

        for (uint256 i = 0; i < length; i++) {
            if (withdrawers[i] == _withdrawer) {
                withdrawers[i] = withdrawers[withdrawers.length - 1];
                withdrawers.pop();
                break;
            }
        }
        emit WithdrawerRemoved(_withdrawer);
    }

    function removeWithdrawers() external onlyRole(WITHDRAWER_REMOVER) {
        for (uint256 i = 0; i < withdrawers.length; i++) {
            isWithdrawer[withdrawers[i]] = false;
        }
        delete withdrawers;
        emit WithdrawersDeleted();
    }

    function withdrawToken(address _token, uint256 _amount)
        external
        onlyWithdrawer
    {
        IERC20(_token).safeTransferFrom(tx.origin, msg.sender, _amount); // solhint-disable-line avoid-tx-origin
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../seed/ERC20Seed.sol";

contract XPToken is ERC20Seed {
    constructor(string memory name, string memory symbol)
        ERC20Seed(name, symbol)
    {} // solhint-disable-line no-empty-blocks
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract ERC1155Base is AccessControlEnumerable, ERC1155Burnable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public contractURI;

    mapping(uint256 => string) public tokenURI;

    constructor(string memory _tokenURI, string memory _contractURI)
        ERC1155(_tokenURI)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());

        contractURI = _contractURI;
    }

    function uri(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            bytes(tokenURI[_tokenId]).length == 0
                ? string(
                    abi.encodePacked(
                        ERC1155.uri(_tokenId),
                        Strings.toString(_tokenId),
                        ".json"
                    )
                )
                : tokenURI[_tokenId];
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, id, amount, data);
    }

    function mintMultiple(
        address[] calldata to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < to.length; ) {
            _mint(to[i], ids[i], amounts[i], "");
            unchecked {
                ++i;
            }
        }
    }

    function mintMultipleWithData(
        address[] calldata to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes[] calldata data
    ) external onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < to.length; ) {
            _mint(to[i], ids[i], amounts[i], data[i]);
            unchecked {
                ++i;
            }
        }
    }

    function setContractURI(string calldata uri_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        contractURI = uri_;
    }

    function setTokenURI(uint256 _tokenId, string calldata uri_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        tokenURI[_tokenId] = uri_;
    }

    function setURI(string calldata uri_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setURI(uri_);
    }

    function removeTokenURI(uint256 _tokenId)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        delete tokenURI[_tokenId];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Distributor is Ownable {
    IERC721 public nft;

    constructor(address _nftAddress) {
        require(_nftAddress != address(0), "nft address is zero address");

        nft = IERC721(_nftAddress);
    }

    function setNftAddress(address _nftAddress) external onlyOwner {
        require(_nftAddress != address(0), "nft address is zero address");

        nft = IERC721(_nftAddress);
    }

    function sendMultiple(address[] calldata addresses, uint256[] calldata ids)
        external
        onlyOwner
    {
        require(addresses.length == ids.length, "mismatch arrays length");

        for (uint256 i = 0; i < addresses.length; i++) {
            nft.safeTransferFrom(address(this), addresses[i], ids[i]);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../withdrawable/Withdrawable.sol";

contract Collector is Withdrawable {
    event Received(address indexed sender, uint256 amount);

    receive() external payable override {
        emit Received(msg.sender, msg.value);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract WhitelistRegistry is AccessControlEnumerable {
    bytes32 public constant WHITELIST_SETTER = keccak256("WHITELIST_SETTER");
    bytes32 public constant WHITELIST_REMOVER = keccak256("WHITELIST_REMOVER");

    /**
     * @notice enabling/disabling check for whitelisted addresses
     */
    bool public restrictToWhitelisted;

    /**
     * @notice Array whitelisted addresses
     */
    address[] public whitelistedAddresses;
    uint256 public whitelistedAddressesCount;
    mapping(address => uint256) public whitelistedPosition; // position 0 means not whitelisted

    // Events
    event WhitelistedAdded(address indexed account, uint256 position);
    event WhitelistedRemoved(address indexed account, uint256 position);
    event RestrictToWhitelistedChanged(bool restrict, address sender);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(WHITELIST_SETTER, msg.sender);
        _setupRole(WHITELIST_REMOVER, msg.sender);

        restrictToWhitelisted = true;
    }

    modifier onlyWhitelisted(address _address) {
        require(
            !restrictToWhitelisted || isWhitelisted(_address),
            "Not whitelisted"
        );
        _;
    }

    /**
     * @notice return true if the address is whitelisted, otherwise false
     */
    function isWhitelisted(address _account) public view returns (bool) {
        if (whitelistedPosition[_account] > 0) return true;
        return false;
    }

    /**
     * @notice toggle restrictToWhitelisted
     */
    function toggleRestrictToWhitelisted()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        restrictToWhitelisted = !restrictToWhitelisted;

        emit RestrictToWhitelistedChanged(restrictToWhitelisted, msg.sender);
    }

    /**
     * @notice get the full array of whitelisted addresses
     */
    function getAllWhitelisted() external view returns (address[] memory) {
        return whitelistedAddresses;
    }

    /**
     * @notice get the paginated array of whitelisted addresses
     * @param _cursor the pointer which indicates the start of the paginated array
     * @param _amount the amount of addresses to return
     * @return addresses the paginated array of whitelisted addresses
     * @return newCursor new pointer to the next page
     */
    function getWhitelisted(uint256 _cursor, uint256 _amount)
        public
        view
        returns (address[] memory addresses, uint256 newCursor)
    {
        uint256 length = _amount;
        if (length > whitelistedAddressesCount - _cursor) {
            length = whitelistedAddressesCount - _cursor;
        }

        addresses = new address[](length);
        for (uint256 i = 0; i < length; ) {
            unchecked {
                addresses[i] = whitelistedAddresses[_cursor + i];
                ++i;
            }
        }

        newCursor = _cursor + length;
    }

    /**
     * @notice Add a new address to the whitelisted array
     * @param _whitelistedAddress the address to be added
     * @dev only the whitelisted setter can add a new address to the whitelisted array
     */
    function addWhitelisted(address _whitelistedAddress) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(WHITELIST_SETTER, msg.sender),
            "Not authorized"
        );

        whitelistedAddresses.push(_whitelistedAddress);
        whitelistedAddressesCount++;
        whitelistedPosition[_whitelistedAddress] = whitelistedAddressesCount;

        emit WhitelistedAdded(_whitelistedAddress, whitelistedAddressesCount);
    }

    /**
     * @notice Add multiple addresses to the whitelisted array
     * @param _whitelistedAddresses array of addresses to be added
     * @dev only the whitelisted setter can add a new address to the whitelisted array
     */
    function addWhitelistedMultiple(address[] calldata _whitelistedAddresses)
        external
    {
        for (uint256 i = 0; i < _whitelistedAddresses.length; ) {
            addWhitelisted(_whitelistedAddresses[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Remove an address from the whitelisted array
     * @param _addressToRemove the address to be removed
     * @dev only the whitelisted remover can remove an address from the whitelisted array
     */
    function removeWhitelisted(address _addressToRemove) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
                hasRole(WHITELIST_REMOVER, msg.sender),
            "Not authorized"
        );

        require(isWhitelisted(_addressToRemove), "Whitelisted not found");

        uint256 positionToBeRemoved = whitelistedPosition[_addressToRemove];

        if (positionToBeRemoved != whitelistedAddressesCount) {
            uint256 lastAddressIndex = whitelistedAddressesCount - 1;

            // copy the last address to the position of the removed address
            whitelistedAddresses[
                positionToBeRemoved - 1
            ] = whitelistedAddresses[lastAddressIndex];

            // update the position number of the last address
            whitelistedPosition[
                whitelistedAddresses[lastAddressIndex]
            ] = positionToBeRemoved;
        }

        whitelistedAddresses.pop();
        whitelistedPosition[_addressToRemove] = 0; // 0 means not whitelisted
        whitelistedAddressesCount--;

        emit WhitelistedRemoved(_addressToRemove, positionToBeRemoved);
    }

    /**
     * @notice Remove multiple addresses from the whitelisted array
     * @param _whitelistedAddresses array of addresses to be removed
     * @dev only the whitelisted remover can remove an address from the whitelisted array
     */
    function removeWhitelistedMultiple(address[] calldata _whitelistedAddresses)
        external
    {
        for (uint256 i = 0; i < _whitelistedAddresses.length; ) {
            removeWhitelisted(_whitelistedAddresses[i]);

            unchecked {
                ++i;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IIDO {
    /// @notice Emitted when user buy token
    /// @param holder the address of user who want to participate in ido
    /// @param depositedAmount the amount that has been sent by the user to get some reward token
    /// @param rewardAmount the amount that has been sent to user address
    event TokensDebt(
        address indexed holder,
        uint256 depositedAmount,
        uint256 rewardAmount
    );

    /// @notice Emitted when user withdraw his/her reward token
    /// @param holder the address of user who has participated in ido
    /// @param amount the withdrawal amount
    event TokensWithdrawn(address indexed holder, uint256 amount);

    /// @notice gets the count of token holders
    function getUserCount() external;

    /// @notice pays ether to get reward token
    function payWithEther() external payable;

    /// @notice pays erc20 token to get reward token
    /// @param depositedAmount the amount of erc20 token
    function payWithToken(uint256 depositedAmount) external;

    /// @notice calculates the amount of reward token that will be sent to user
    /// @param depositedAmount the amount of erc20 token or ether that is deposited
    /// @return the amount of reward token
    function getTokenAmount(uint256 depositedAmount)
        external
        view
        returns (uint256);

    /// @notice allows to claim tokens for the specific user.
    /// @param _user token receiver.
    function claimFor(address _user) external;

    /// @notice allows to claim tokens for themselves.
    function claim() external;

    /// @notice allows owner to withdraw ethers from contract.
    /// @param amount amount of ethers.
    function withdrawETH(uint256 amount) external;

    /// @notice allows owner to withdraw erc20 token(payment token) from contract.
    /// @param amount amount of ethers.
    function withdrawPaymentToken(uint256 amount) external;

    /// @notice allows admin to withdraw non solden reward token.
    function withdrawNotSoldTokens() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract BalanceContract {
    mapping(address => uint256) public balances;

    function setBalance(address _address, uint256 _balance) external {
        balances[_address] += _balance;
    }

    function balanceOf(address _address) external view returns (uint256) {
        return balances[_address];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Forwarder {
    function forward(address payable _to) external payable {
        (bool sent, ) = _to.call{value: msg.value}(""); // solhint-disable-line avoid-low-level-calls
        require(sent, "Failed to send Ether");
    }
}