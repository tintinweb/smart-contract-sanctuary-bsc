// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Amatik is ERC20,  Ownable{
    address public bankReserve;
    constructor(address owner_, address bankReserve_) ERC20("Amatik", "AMT") {
        require(owner_ != address(0), "Owner address can't be address zero");
        require(bankReserve_ != address(0), "BankReserve address can't be address zero");
        _mint(owner_, 2e8 * 1e18);
        transferOwnership(owner_);
        bankReserve = bankReserve_;
    }

    function burn() external onlyOwner{
        _burn(bankReserve, balanceOf(bankReserve));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Team is Ownable {
    using SafeERC20 for IERC20;
    // TODO fix for mainnet
    uint256 public constant BLOCKS_PER_MONTH = 20;
    uint256 public lockedPeriod = 36 * BLOCKS_PER_MONTH;
    uint256 public lockedAmount = 18000000 ether;
    uint256 public claimedAmount;
    uint256 public startBlock;
    uint256 public unlockedPerMonth = 1000000 ether;
    IERC20 public token;

    constructor(IERC20 token_) {
        require(address(token_) != address(0), "Team: Token address can't be address zero");
        token = token_;
        startBlock = block.number;
    }

    function claim(uint256 amount_) external onlyOwner {
        require(block.number >= startBlock + 37 * BLOCKS_PER_MONTH, "Team: Locked period didn't passed");
        uint256 unlockedAmount = getUnlockedTokenAmount();
        require(amount_ <= unlockedAmount, "Team: Insufficiant unlocked tokens");
        claimedAmount += amount_;
        // lockedAmount -= amount_;
        token.safeTransfer(msg.sender, amount_);
    }

    function getUnlockedTokenAmount() public view returns (uint256 amount) {
        if(block.number < startBlock + 37 * BLOCKS_PER_MONTH){
            return 0;
        }
        amount = unlockedPerMonth * ((block.number - (startBlock + 36 * BLOCKS_PER_MONTH)) / BLOCKS_PER_MONTH);
        if(amount >= lockedAmount){
            amount = lockedAmount;
        }
        amount-= claimedAmount;
        return amount;
    }
}

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;
// Imported OZ helper contracts
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// Inherited allowing for ownership of contract
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
import "ApeSwap-AMM-Periphery/contracts/interfaces/IApePair.sol";


// Allows for time manipulation. Set to 0x address on test/mainnet deploy

contract LotteryMock is Ownable {
    // Libraries
    using SafeMath for uint256;
    // Safe ERC20
    using SafeERC20 for IERC20;
    // Address functionality
    using Address for address;

    // State variables
    // Instance of Cake token (collateral currency for lotto)
    IERC20 public token;
    // Storing of the NFT
    // Request ID for random number
    bytes32 internal requestId_;
    // Counter for lottery IDs
    uint256 private lotteryIdCounter_;
    AggregatorInterface public priceFeed;
    IApePair public pair;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(uint256 => uint16) public currentTicket;
    mapping(address => mapping(uint256 => uint16[])) public usersTickets;
    mapping(address => mapping(uint256 => bool)) public alreadyClaimed;

    // Represents the status of the lottery
    enum Status {
        NotStarted, // The lottery has not started yet
        Open, // The lottery is open for ticket purchases
        Closed, // The lottery is no longer open for ticket purchases
        Completed // The lottery has been closed and the numbers drawn
    }
    // All the needed info around a lottery
    struct LottoInfo {
        uint256 lotteryID; // ID for lotto
        Status lotteryStatus; // Status for lotto
        uint16[] prizeDistributionPercents; // The distribution percents for prize money
        uint256 startBlock; // Block number for start of lotto
        uint256 ticketPrice;
        uint16 ticketsCount;
        uint16 ticketsSold;
        uint16[] winningNumbers; // The winning numbers
    }
    // Lottery ID's to info
    mapping(uint256 => LottoInfo) internal allLotteries_;
    // LotteryId to rendomNumber
    mapping(uint256 => uint256) public rendomNumbers;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event RequestNumbers(uint256 lotteryId, bytes32 requestId);

    event UpdatedSizeOfLottery(address admin, uint16 newLotterySize);

    event UpdatedMaxRange(address admin, uint16 newMaxRange);

    event LotteryOpen(uint256 lotteryId, uint256 ticketSupply);

    event LotteryClose(uint256 lotteryId, uint256 ticketSupply);

    //-------------------------------------------------------------------------
    // MODIFIERS
    //-------------------------------------------------------------------------

    modifier notContract() {
        require(!address(msg.sender).isContract(), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    constructor(
        IERC20 token_,
        address priceFeed_,
        IApePair pair_
    ) {
        token = token_;
        priceFeed = AggregatorInterface(priceFeed_);
        pair = pair_;
    }

    function getBasicLottoInfo(uint256 lotteryId_) public view returns (LottoInfo memory) {
        return (allLotteries_[lotteryId_]);
    }

    function drawWinningNumbers(uint256 lotteryId_) external onlyOwner {
        // Checks that the all tickets are sold
        require(
            allLotteries_[lotteryId_].ticketsSold == allLotteries_[lotteryId_].ticketsCount,
            "Lottery: Cannot set winning numbers during lottery"
        );
        // Checks lottery numbers have not already been drawn
        require(
            allLotteries_[lotteryId_].lotteryStatus == Status.Open ||
                allLotteries_[lotteryId_].lotteryStatus == Status.NotStarted,
            "Lottery: State incorrect for draw"
        );
        allLotteries_[lotteryId_].winningNumbers = [1, 5, 7];
        allLotteries_[lotteryId_].lotteryStatus = Status.Completed;
    }

    /**
     * @param   startBlock_ The block number for the beginning of the
     *          lottery.
     */
    function createNewLotto(
        uint16[] calldata prizeDistributionPercents_,
        uint256 startBlock_,
        uint256 ticketPrice_,
        uint16 ticketsCount_
    ) external onlyOwner returns (uint256 lotteryId) {
        require(ticketPrice_ > 0, "Lottery: Ticket price can't be zero");
        require(ticketsCount_ > 0, "Lottery: Tickets count can't be zero");
        require(startBlock_ >= block.number, "Lottery: Too late");
        uint256 sumOfPrizePercents;
        for (uint8 i; i <= 2; i++) {
            sumOfPrizePercents += prizeDistributionPercents_[i];
        }
        require(sumOfPrizePercents == 5000, "Lottery: Incorrect percents for prize distribution");
        // Incrementing lottery ID
        lotteryIdCounter_++;
        lotteryId = lotteryIdCounter_;
        uint16[] memory winningNumbers;
        Status lotteryStatus;
        if (startBlock_ == block.number) {
            lotteryStatus = Status.Open;
        } else {
            lotteryStatus = Status.NotStarted;
        }
        // Saving data in struct
        LottoInfo memory newLottery = LottoInfo(
            lotteryId,
            lotteryStatus,
            prizeDistributionPercents_,
            startBlock_,
            ticketPrice_,
            ticketsCount_,
            0,
            winningNumbers
        );
        allLotteries_[lotteryId] = newLottery;
        currentTicket[lotteryId] = 1;
        // TODO fix
        // emit LotteryOpen(
        //     lotteryId,
        //     nft_.getTotalSupply()
        // );
    }

    function claimReward(uint256 lotteryId_) external notContract {
        // Checks the lottery winning numbers are available
        require(allLotteries_[lotteryId_].lotteryStatus == Status.Completed, "Lottery: Winning Numbers not chosen yet");
        require(getWonAmount(msg.sender, lotteryId_) > 0, "Lottery: Nothing to claim");
        require(!alreadyClaimed[msg.sender][lotteryId_], "Lottery: User have already claimed his rewards");
        alreadyClaimed[msg.sender][lotteryId_] = true;
        // Transfering the user their winnings
        token.safeTransfer(address(msg.sender), getWonAmount(msg.sender, lotteryId_));
    }

    function getWonAmount(address user_, uint256 lotteryId_) public view returns (uint256 amount) {
        uint16[] memory matchingNumbers = new uint16[](3);
        uint16[] memory winningNumbers = new uint16[](3);
        winningNumbers = getBasicLottoInfo(lotteryId_).winningNumbers;
        matchingNumbers = getNumberOfMatching(usersTickets[user_][lotteryId_], winningNumbers);
        if (matchingNumbers[0] == 0) {
            return 0;
        }
        for (uint256 i; i <= 2; i++) {
            if (matchingNumbers[i] > 0) {
                for (uint256 j; j <= 2; j++) {
                    if ((allLotteries_[lotteryId_].winningNumbers)[j] == matchingNumbers[i]) {
                        amount +=
                            (allLotteries_[lotteryId_].prizeDistributionPercents[j] *
                                getTokenAmountForCurrentPrice(allLotteries_[lotteryId_].ticketPrice) *
                                1e18 *
                                allLotteries_[lotteryId_].ticketsCount) /
                            10000;
                    }
                }
            }
        }
        return amount;
    }

    function getNumberOfMatching(uint16[] memory usersNumbers_, uint16[] memory winningNumbers_)
        public
        pure
        returns (uint16[] memory wonNumbers)
    {
        wonNumbers = new uint16[](3);
        // Loops through all wimming numbers
        for (uint256 i = 0; i < winningNumbers_.length; i++) {
            // If the winning numbers and user numbers match
            for (uint256 j; j < usersNumbers_.length; j++) {
                if (usersNumbers_[j] == winningNumbers_[i]) {
                    // The number of matching numbers incrases
                    for (uint256 k; k < 3; k++) {
                        if (wonNumbers[k] == 0) {
                            wonNumbers[k] = usersNumbers_[j];
                            break;
                        }
                    }
                }
            }
        }
    }

    function _split(uint256 lotteryId_) public returns (uint16[] memory) {
        uint16[] memory winningNumbers = new uint16[](3);
        uint256 i;
        // count of unique numbers we have already got
        uint256 numbersCount;
        while (numbersCount < 3) {
            // Encodes the random number with its position in loop
            bytes32 hashOfRandom = keccak256(abi.encodePacked(rendomNumbers[lotteryId_], i));
            // Casts random number hash into uint256
            uint256 numberRepresentation = uint256(hashOfRandom);

            if (uint16(numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount)) > 0) {
                uint256 duplicates;
                if (winningNumbers[0] == 0) {
                    winningNumbers[0] = uint16(numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount));
                    numbersCount++;
                }
                for (uint8 j; j < winningNumbers.length; j++) {
                    if (uint16(numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount)) == winningNumbers[j]) {
                        duplicates++;
                    }
                }
                if (duplicates == 0) {
                    winningNumbers[numbersCount] = uint16(
                        numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount)
                    );
                    numbersCount++;
                }
            }
            i++;
        }
        allLotteries_[lotteryId_].winningNumbers = winningNumbers;
        return winningNumbers;
    }

    function buyTicket(uint256 lotteryId_) external {
        require(allLotteries_[lotteryId_].startBlock <= block.number, "Lottery: Not started yet");
        require(
            allLotteries_[lotteryId_].ticketsSold < allLotteries_[lotteryId_].ticketsCount,
            "Lottery: No available tickets"
        );
        usersTickets[msg.sender][lotteryId_].push(currentTicket[lotteryId_]);
        currentTicket[lotteryId_]++;
        allLotteries_[lotteryId_].ticketsSold++;
        token.safeTransferFrom(
            msg.sender,
            address(this),
            getTokenAmountForCurrentPrice(allLotteries_[lotteryId_].ticketPrice) * 1e18
        );
    }

    function getTokenAmountForCurrentPrice(uint256 price_) public view returns (uint256) {
        uint256 bnbPrice = uint256(priceFeed.latestAnswer());
        uint256 tokenBalance = token.balanceOf(address(pair));
        uint256 bnbBalance = IERC20(WBNB).balanceOf(address(pair));
        uint256 tokenPrice = bnbPrice / (tokenBalance / bnbBalance);
        return (price_ * 1e8) / tokenPrice;
    }

    function getUsersTickets(address user_, uint256 lotteryId_) public view returns (uint16[] memory) {
        return usersTickets[user_][lotteryId_];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

pragma solidity >=0.6.6;

interface IApePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
import "ApeSwap-AMM-Periphery/contracts/interfaces/IApePair.sol";
import "ApeSwap-AMM-Periphery/contracts/interfaces/IApeRouter02.sol";


pragma solidity ^0.8.12;

contract Payment is Ownable {
    address public burnReserve;
    address public treasury;
    address public liquidityReserve;
    struct Lessons {
        uint256 price;
        uint16 tutorPercent;
        uint16 profitPercent;
        bool available;
        address tutor;
    }
    // lessonId -> Lessons struct
    mapping(uint256 => Lessons) public lesson;
    // user ->  subscribtionEndBlock
    mapping(address => uint256) public subscribtionInfo;
    // user address -> lessonId -> availability
    mapping(address => mapping(uint256 => bool)) public lessonAvailability;
    uint256 public lessonsId;
    // TODO fix
    uint256 public constant BLOCKS_PER_MONTH = 560;
    // Count of hours for free trial
    uint256 public freeTrialDuration;
    IERC20 public token;
    AggregatorInterface public priceFeed;
    IApePair public pair;
    IApeRouter02 public router;
    // Fix for network
    address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    mapping(uint256 => uint256) public subscribtionPrice;
    event NewLessonAdded(uint256 lessonId, uint256 price, bool availability);
    event LessonAvailabilityChanged(uint256 lessonId, bool availability);
    event LessonPriceChanged(uint256 lessonId, uint256 price);
    event FreeTrialDurationChanged(uint256 newDuration);
    event NewsSubscribtionPlanAded(uint256 months, uint256 price);
    event PaidForLesson(uint256 lessonId, address user, uint256 price, uint256 tokenAmount);
    event SubscibtionComplited(
        uint256 months,
        address user,
        uint256 subscribtionEndBlock,
        uint256 price,
        uint256 tokenAmount
    );

    constructor(
        address burnReserve_,
        address priceFeed_,
        IApePair pair_,
        IApeRouter02 router_,
        IERC20 token_,
        uint256 freeTrialDuration_,
        address treasury_,
        address liquidityReserve_
    ) {
        require(burnReserve_ != address(0), "Payment: BurnReserve can't be address zero");
        require(priceFeed_ != address(0), "Payment: PriceFeed can't be address zero");
        require(address(pair_) != address(0), "Payment: Pair can't be address zero");
        require(address(router_) != address(0), "Payment: Router can't be address zero");
        require(address(token_) != address(0), "Payment: Pair can't be address zero");
        require(treasury_ != address(0), "Payment: Treasury can't be address zero");
        require(liquidityReserve_ != address(0), "Payment: LiquidityReserve can't be address zero");
        burnReserve = burnReserve_;
        priceFeed = AggregatorInterface(priceFeed_);
        pair = pair_;
        router = router_;
        token = token_;
        freeTrialDuration = freeTrialDuration_;
        treasury = treasury_;
        liquidityReserve = liquidityReserve_;
    }

    // Admin functions
    function addLesson(
        uint256 price_,
        uint16 tutorPercent_,
        uint16 profitPercent_,
        bool available_,
        address tutor_
    ) external onlyOwner {
        require(price_ != 0, "Paymant: Price can't be zero");
        require(tutor_ != address(0), "Payment: Tutor address can't be zero");
        require(tutorPercent_ + profitPercent_ == 3000, "Payment: Invalid percents");
        lesson[lessonsId].price = price_;
        lesson[lessonsId].tutorPercent = tutorPercent_;
        lesson[lessonsId].profitPercent = profitPercent_;
        lesson[lessonsId].available = available_;
        lesson[lessonsId].tutor = tutor_;
        emit NewLessonAdded(lessonsId, price_, available_);
        lessonsId++;
    }

    function changeLessonAvailability(uint256 lessonId_, bool availability_) external onlyOwner {
        require(lesson[lessonId_].price != 0, "Payment: Lesson with this id doesn't exist");
        require(lesson[lessonId_].available != availability_, "Payment: Nothing to change");
        lesson[lessonId_].available = availability_;
        emit LessonAvailabilityChanged(lessonId_, availability_);
    }

    function changeLessonPrice(uint256 lessonId_, uint256 newPrice_) external onlyOwner {
        require(lesson[lessonId_].price != 0, "Payment: Lesson with this id doesn't exist");
        require(lesson[lessonId_].price != newPrice_, "Payment: Nothing to change");
        require(newPrice_ != 0, "Paymant: Price can't be zero");
        lesson[lessonId_].price = newPrice_;
        emit LessonPriceChanged(lessonId_, newPrice_);
    }

    function changeFreeTrialDurtion(uint256 newDuration_) external onlyOwner {
        require(freeTrialDuration != newDuration_, "Payment: Nothing to change");
        freeTrialDuration = newDuration_;
        emit FreeTrialDurationChanged(newDuration_);
    }

    function addNewsSubscibtionPlan(uint256 months_, uint256 price_) external onlyOwner {
        subscribtionPrice[months_] = price_;
        emit NewsSubscribtionPlanAded(months_, price_);
    }

    // User functions
    function payForLesson(uint256 lessonId_) external {
        require(lesson[lessonId_].price != 0, "Payment: Lesson with this id doesn't exist");
        require(lesson[lessonId_].available, "Payment: Lesson is now unavailable");
        require(!lessonAvailability[msg.sender][lessonId_], "Payment: Lessen already paid");
        uint256 tokenAmount = getTokenAmountForCurrentPrice(lesson[lessonId_].price);
        token.transferFrom(msg.sender, address(burnReserve), (tokenAmount * 1e18 * 7000) / 10000);
        token.transferFrom(
            msg.sender,
            lesson[lessonId_].tutor,
            (tokenAmount * 1e18 * lesson[lessonId_].tutorPercent) / 10000
        );
        token.transferFrom(msg.sender, treasury, (tokenAmount * 1e18 * lesson[lessonId_].profitPercent) / 10000);
        // Add tokens to pool
        swap(tokenAmount);
        lessonAvailability[msg.sender][lessonId_] = true;
        emit PaidForLesson(lessonId_, msg.sender, lesson[lessonId_].price, tokenAmount);
    }

    function payForLessonWithBNB(
        uint256 lessonId_,
        uint256 amountOutMin,
        uint256 deadline
    ) external payable {
        require(lesson[lessonId_].price != 0, "Payment: Lesson with this id doesn't exist");
        require(lesson[lessonId_].available, "Payment: Lesson is now unavailable");
        require(!lessonAvailability[msg.sender][lessonId_], "Payment: Lessen already paid");
        address[] memory path;
        path[0] = WBNB;
        path[1] = address(token);
        uint256[] memory tokenAmount = router.swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            deadline
        );
        require(
            tokenAmount[1] >= getTokenAmountForCurrentPrice(lesson[lessonId_].price - 5),
            "Payment: Insufficient tokens"
        );
        if (tokenAmount[1] > getTokenAmountForCurrentPrice(lesson[lessonId_].price) * 1e18) {
            uint256 amount = getTokenAmountForCurrentPrice(lesson[lessonId_].price) * 1e18;
            lessonAvailability[msg.sender][lessonId_] = true;
            emit PaidForLesson(lessonId_, msg.sender, lesson[lessonId_].price, amount);
            token.transfer(address(burnReserve), (amount * 7000) / 10000);
            token.transfer(lesson[lessonId_].tutor, (amount * lesson[lessonId_].tutorPercent) / 10000);
            token.transfer(treasury, (amount * lesson[lessonId_].profitPercent) / 10000);
            token.transfer(msg.sender, tokenAmount[1] - amount);
            // Add tokens to pool
            // swap(amount);
        } else {
            lessonAvailability[msg.sender][lessonId_] = true;
            emit PaidForLesson(lessonId_, msg.sender, lesson[lessonId_].price, tokenAmount[1]);
            token.transfer(address(burnReserve), (tokenAmount[1] * 7000) / 10000);
            token.transfer(lesson[lessonId_].tutor, (tokenAmount[1] * lesson[lessonId_].tutorPercent) / 10000);
            token.transfer(treasury, (tokenAmount[1] * lesson[lessonId_].profitPercent) / 10000);
            // Add tokens to pool
            // swap(tokenAmount[1]);
        }
    }

    function subscribeForNews(uint256 months_) external {
        require(subscribtionPrice[months_] != 0, "Payment: Invalid subscription plan");
        if (subscribtionInfo[msg.sender] > block.number) {
            subscribtionInfo[msg.sender] += months_ * BLOCKS_PER_MONTH;
        }
        if (subscribtionInfo[msg.sender] < block.number) {
            subscribtionInfo[msg.sender] = block.number + months_ * BLOCKS_PER_MONTH;
        }
        token.transferFrom(
            msg.sender,
            address(burnReserve),
            getTokenAmountForCurrentPrice(subscribtionPrice[months_]) * 1e18
        );
        emit SubscibtionComplited(
            months_,
            msg.sender,
            subscribtionInfo[msg.sender],
            subscribtionPrice[months_],
            getTokenAmountForCurrentPrice(subscribtionPrice[months_])
        );
    }

    function freeTrialActivation() external {
        require(subscribtionInfo[msg.sender] == 0, "Payment: You can't activate free trial");
        subscribtionInfo[msg.sender] = block.number + freeTrialDuration;
    }

    // View functions

    function newsAvailability(address user_) public view returns (bool) {
        if (subscribtionInfo[user_] > block.number) {
            return true;
        }
        return false;
    }

    function getTokenAmountForCurrentPrice(uint256 price_) public view returns (uint256) {
        uint256 bnbPrice = uint256(priceFeed.latestAnswer());
        uint256 tokenBalance = token.balanceOf(address(pair));
        uint256 bnbBalance = IERC20(WBNB).balanceOf(address(pair));
        uint256 tokenPrice = bnbPrice / (tokenBalance / bnbBalance);
        return (price_ * 1e8) / tokenPrice;
    }

    function swap(uint256 amount) public {
        uint256 amountForLiquidity = (amount * 1e18 * 6000) / 10000;
        address[] memory path = new address[](2);

        path[0] = router.WETH();
        path[1] = address(token);
        if (token.balanceOf(liquidityReserve) >= amountForLiquidity) {
            token.transferFrom(liquidityReserve, address(this), amountForLiquidity);
            token.approve(address(router), amountForLiquidity);
            router.swapExactTokensForETH(amountForLiquidity, 0, path, treasury, block.timestamp + 1000);
        }
    }
}

pragma solidity >=0.6.2;

import './IApeRouter01.sol';

interface IApeRouter02 is IApeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IApeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;
// Imported OZ helper contracts
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// Inherited allowing for ownership of contract
import "@openzeppelin/contracts/access/Ownable.sol";
// Allows for intergration with ChainLink VRF
import "./interfaces/IRandomNumberGenerator.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
import "ApeSwap-AMM-Periphery/contracts/interfaces/IApePair.sol";
import "ApeSwap-AMM-Periphery/contracts/interfaces/IApeRouter02.sol";


// Allows for time manipulation. Set to 0x address on test/mainnet deploy

contract Lottery is Ownable {
    // Libraries
    using SafeMath for uint256;
    // Safe ERC20
    using SafeERC20 for IERC20;
    // Address functionality
    using Address for address;

    // State variables
    // Instance of Cake token (collateral currency for lotto)
    IERC20 public token;
    // Storing of the randomness generator
    IRandomNumberGenerator internal randomGenerator_;
    // Request ID for random number
    bytes32 internal requestId_;
    // Counter for lottery IDs
    uint256 private lotteryIdCounter_;
    AggregatorInterface public priceFeed;
    IApePair public pair;
    IApeRouter02 public router;
    // TODO check
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public burnReserve;
    address public liquidityReserve;
    address public treasury;

    mapping(uint256 => uint16) public currentTicket;
    mapping(address => mapping(uint256 => uint16[])) public usersTickets;
    mapping(address => mapping(uint256 => bool)) public alreadyClaimed;

    // Represents the status of the lottery
    enum Status {
        NotStarted, // The lottery has not started yet
        Open, // The lottery is open for ticket purchases
        Closed, // The lottery is no longer open for ticket purchases
        Completed // The lottery has been closed and the numbers drawn
    }
    // All the needed info around a lottery
    struct LottoInfo {
        uint256 lotteryID; // ID for lotto
        Status lotteryStatus; // Status for lotto
        uint16[] prizeDistributionPercents; // The distribution percents for prize money
        uint256 startBlock; // Block number for start of lotto
        uint256 ticketPrice;
        uint16 ticketsCount;
        uint16 ticketsSold;
        uint16[] winningNumbers; // The winning numbers
    }
    // Lottery ID's to info
    mapping(uint256 => LottoInfo) internal allLotteries_;
    // LotteryId to rendomNumber
    mapping(uint256 => uint256) public rendomNumbers;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event RequestNumbers(uint256 lotteryId, bytes32 requestId);

    event UpdatedSizeOfLottery(address admin, uint16 newLotterySize);

    event UpdatedMaxRange(address admin, uint16 newMaxRange);

    event LotteryOpen(uint256 lotteryId, uint256 ticketSupply);

    event LotteryClose(uint256 lotteryId, uint256 ticketSupply);

    //-------------------------------------------------------------------------
    // MODIFIERS
    //-------------------------------------------------------------------------

    modifier onlyRandomGenerator() {
        require(msg.sender == address(randomGenerator_), "Only random generator");
        _;
    }

    modifier notContract() {
        require(!address(msg.sender).isContract(), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    constructor(
        IERC20 token_,
        address priceFeed_,
        IApePair pair_,
        address burnReserve_,
        address liquidityReserve_,
        address treasury_
    ) {
        token = token_;
        priceFeed = AggregatorInterface(priceFeed_);
        pair = pair_;
        burnReserve = burnReserve_;
        liquidityReserve = liquidityReserve_;
        treasury = treasury_;
    }

    function getBasicLottoInfo(uint256 lotteryId_) public view returns (LottoInfo memory) {
        return (allLotteries_[lotteryId_]);
    }

    function setRendomGenerator(address randomNumberGenerator_) external onlyOwner {
        require(randomNumberGenerator_ != address(0), "Contracts cannot be 0 address");
        randomGenerator_ = IRandomNumberGenerator(randomNumberGenerator_);
    }

    function drawWinningNumbers(uint256 lotteryId_) external onlyOwner {
        // Checks that the all tickets are sold
        // require(
        //     allLotteries_[lotteryId_].ticketsSold == allLotteries_[lotteryId_].ticketsCount,
        //     "Lottery: Cannot set winning numbers during lottery"
        // );
        // // Checks lottery numbers have not already been drawn
        // require(
        //     allLotteries_[lotteryId_].lotteryStatus == Status.Open ||
        //         allLotteries_[lotteryId_].lotteryStatus == Status.NotStarted,
        //     "Lottery: State incorrect for draw"
        // );
        // Sets lottery status to closed
        allLotteries_[lotteryId_].lotteryStatus = Status.Closed;
        // Requests a random number from the generator
        requestId_ = randomGenerator_.getRandomNumber(lotteryId_);
        uint256 amount = (getTokenAmountForCurrentPrice(allLotteries_[lotteryId_].ticketPrice) *
            1e18 *
            allLotteries_[lotteryId_].ticketsCount) / 2;
        token.transfer(burnReserve, amount);
        swap(amount);
        // Emits that random number has been requested
        emit RequestNumbers(lotteryId_, requestId_);
    }

    function numbersDrawn(
        uint256 lotteryId_,
        bytes32 _requestId,
        uint256 _randomNumber
    ) external onlyRandomGenerator {
        require(allLotteries_[lotteryId_].lotteryStatus == Status.Closed, "Lottery: Draw numbers first");
        if (requestId_ == _requestId) {
            allLotteries_[lotteryId_].lotteryStatus = Status.Completed;
            allLotteries_[lotteryId_].winningNumbers = _split(lotteryId_);
        }
        rendomNumbers[lotteryId_] = _randomNumber;
        // TODO fix
        // emit LotteryClose( lotteryId_, nft_.getTotalSupply());
    }

    /**
     * @param   startBlock_ The block number for the beginning of the
     *          lottery.
     */
    function createNewLotto(
        uint16[] calldata prizeDistributionPercents_,
        uint256 startBlock_,
        uint256 ticketPrice_,
        uint16 ticketsCount_
    ) external onlyOwner returns (uint256 lotteryId) {
        require(ticketPrice_ > 0, "Lottery: Ticket price can't be zero");
        require(ticketsCount_ > 0, "Lottery: Tickets count can't be zero");
        require(startBlock_ >= block.number, "Lottery: Too late");
        uint256 sumOfPrizePercents;
        for (uint8 i; i <= 2; i++) {
            sumOfPrizePercents += prizeDistributionPercents_[i];
        }
        require(sumOfPrizePercents == 5000, "Lottery: Incorrect percents for prize distribution");
        // Incrementing lottery ID
        lotteryIdCounter_++;
        lotteryId = lotteryIdCounter_;
        uint16[] memory winningNumbers;
        Status lotteryStatus;
        if (startBlock_ == block.number) {
            lotteryStatus = Status.Open;
        } else {
            lotteryStatus = Status.NotStarted;
        }
        // Saving data in struct
        LottoInfo memory newLottery = LottoInfo(
            lotteryId,
            lotteryStatus,
            prizeDistributionPercents_,
            startBlock_,
            ticketPrice_,
            ticketsCount_,
            0,
            winningNumbers
        );
        allLotteries_[lotteryId] = newLottery;
        currentTicket[lotteryId] = 1;
        // TODO fix
        // emit LotteryOpen(
        //     lotteryId,
        //     nft_.getTotalSupply()
        // );
    }

    function claimReward(uint256 lotteryId_) external notContract {
        // Checks the lottery winning numbers are available
        require(allLotteries_[lotteryId_].lotteryStatus == Status.Completed, "Lottery: Winning Numbers not chosen yet");
        require(getWonAmount(msg.sender, lotteryId_) > 0, "Lottery: Nothing to claim");
        require(!alreadyClaimed[msg.sender][lotteryId_], "Lottery: User have already claimed his rewards");
        alreadyClaimed[msg.sender][lotteryId_] = true;
        // Transfering the user their winnings
        uint256 amount = getWonAmount(msg.sender, lotteryId_);
        if(getWonAmount(msg.sender, lotteryId_) > token.balanceOf(address(this))){
            amount = token.balanceOf(address(this));
        }
        token.safeTransfer(msg.sender, amount);
    }

    function getWonAmount(address user_, uint256 lotteryId_) public view returns (uint256 amount) {
        uint16[] memory matchingNumbers = new uint16[](3);
        uint16[] memory winningNumbers = new uint16[](3);
        winningNumbers = getBasicLottoInfo(lotteryId_).winningNumbers;
        matchingNumbers = getNumberOfMatching(usersTickets[user_][lotteryId_], winningNumbers);
        if (matchingNumbers[0] == 0) {
            return 0;
        }
        for (uint256 i; i <= 2; i++) {
            if (matchingNumbers[i] > 0) {
                for (uint256 j; j <= 2; j++) {
                    if ((allLotteries_[lotteryId_].winningNumbers)[j] == matchingNumbers[i]) {
                        amount +=
                            (allLotteries_[lotteryId_].prizeDistributionPercents[j] *
                                getTokenAmountForCurrentPrice(allLotteries_[lotteryId_].ticketPrice) *
                                1e18 *
                                allLotteries_[lotteryId_].ticketsCount) /
                            10000;
                    }
                }
            }
        }
        return amount;
    }

    function getNumberOfMatching(uint16[] memory usersNumbers_, uint16[] memory winningNumbers_)
        public
        pure
        returns (uint16[] memory wonNumbers)
    {
        wonNumbers = new uint16[](3);
        // Loops through all wimming numbers
        for (uint256 i = 0; i < winningNumbers_.length; i++) {
            // If the winning numbers and user numbers match
            for (uint256 j; j < usersNumbers_.length; j++) {
                if (usersNumbers_[j] == winningNumbers_[i]) {
                    // The number of matching numbers incrases
                    for (uint256 k; k < 3; k++) {
                        if (wonNumbers[k] == 0) {
                            wonNumbers[k] = usersNumbers_[j];
                            break;
                        }
                    }
                }
            }
        }
    }

    function _split(uint256 lotteryId_) public returns (uint16[] memory) {
        uint16[] memory winningNumbers = new uint16[](3);
        uint256 i;
        // count of unique numbers we have already got
        uint256 numbersCount;
        while (numbersCount < 3) {
            // Encodes the random number with its position in loop
            bytes32 hashOfRandom = keccak256(abi.encodePacked(rendomNumbers[lotteryId_], i));
            // Casts random number hash into uint256
            uint256 numberRepresentation = uint256(hashOfRandom);

            if (uint16(numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount)) > 0) {
                uint256 duplicates;
                if (winningNumbers[0] == 0) {
                    winningNumbers[0] = uint16(numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount));
                    numbersCount++;
                }
                for (uint8 j; j < winningNumbers.length; j++) {
                    if (uint16(numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount)) == winningNumbers[j]) {
                        duplicates++;
                    }
                }
                if (duplicates == 0) {
                    winningNumbers[numbersCount] = uint16(
                        numberRepresentation.mod(allLotteries_[lotteryId_].ticketsCount)
                    );
                    numbersCount++;
                }
            }
            i++;
        }
        allLotteries_[lotteryId_].winningNumbers = winningNumbers;
        return winningNumbers;
    }

    function buyTicket(uint256 lotteryId_) external {
        require(allLotteries_[lotteryId_].startBlock <= block.number, "Lottery: Not started yet");
        require(
            allLotteries_[lotteryId_].ticketsSold < allLotteries_[lotteryId_].ticketsCount,
            "Lottery: No available tickets"
        );
        usersTickets[msg.sender][lotteryId_].push(currentTicket[lotteryId_]);
        currentTicket[lotteryId_]++;
        allLotteries_[lotteryId_].ticketsSold++;
        token.safeTransferFrom(
            msg.sender,
            address(this),
            getTokenAmountForCurrentPrice(allLotteries_[lotteryId_].ticketPrice) * 1e18
        );
    }

    function getTokenAmountForCurrentPrice(uint256 price_) public view returns (uint256) {
        uint256 bnbPrice = uint256(priceFeed.latestAnswer());
        uint256 tokenBalance = token.balanceOf(address(pair));
        uint256 bnbBalance = IERC20(WBNB).balanceOf(address(pair));
        uint256 tokenPrice = bnbPrice / (tokenBalance / bnbBalance);
        return (price_ * 1e8) / tokenPrice;
    }

    function getUsersTickets(address user_, uint256 lotteryId_) public view returns (uint16[] memory) {
        return usersTickets[user_][lotteryId_];
    }

    function swap(uint256 amount) internal {
        uint256 amountForLiquidity = (amount * 1e18 * 6000) / 10000;
        if (token.balanceOf(liquidityReserve) >= amountForLiquidity) {
            token.transferFrom(liquidityReserve, address(this), amountForLiquidity);
            address[] memory path;
            path[0] = address(token);
            path[1] = WBNB;
            router.swapExactTokensForETH(amountForLiquidity, 0, path, treasury, block.timestamp + 1000);
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRandomNumberGenerator {
    /**
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 lotteryId) external returns (bytes32 requestId);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    IERC20 public token;
    struct UserInfo {
        uint256 amount;
        uint256 startBlock;
    }
    uint256 public availablePrizeFund;
    uint256 public constant BLOCKS_PER_YEAR = 50;
    mapping(address => UserInfo[]) public userInfo;

    constructor(IERC20 token_) {
        require(address(token_) != address(0), "Token address can't be address zero");
        token = token_;
    }

    function addPrizeFund(uint256 amount) external onlyOwner {
        availablePrizeFund += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function stake(uint256 amount_) external {
        require(availablePrizeFund > (amount_ * 1200) / 10000, "Staking: Insufficient Prize fund");
        userInfo[msg.sender].push(UserInfo({amount: amount_, startBlock: block.number}));
        availablePrizeFund -= (amount_ * 1200) / 10000;
    }

    function unstake(uint256 stakeIndex_) external {
        require(userInfo[msg.sender][stakeIndex_].amount > 0, "Staking: Nothing to unstake");
        require(
            userInfo[msg.sender][stakeIndex_].startBlock + BLOCKS_PER_YEAR * 3 <= block.number,
            "Staking: Locked period didn't passed"
        );
        uint256 amount = userInfo[msg.sender][stakeIndex_].amount;
        delete userInfo[msg.sender][stakeIndex_];
        token.transfer(msg.sender, amount + (amount * 1200) / 10000);
    }

    function withdraw() external onlyOwner {
        uint256 amount = availablePrizeFund;
        availablePrizeFund = 0;
        token.transfer(msg.sender, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Marketing is Ownable {
    using SafeERC20 for IERC20;
    // TODO fix for mainnet
    uint256 public constant BLOCKS_PER_MONTH = 20;
    uint256 public lockedPeriod = 6 * BLOCKS_PER_MONTH;
    uint256 public lockedAmount = 8000000 ether;
    uint256 public claimedAmount;
    uint256 public startBlock;
    uint256 public unlockedPerMonth = 200000 ether;
    IERC20 public token;

    constructor(IERC20 token_) {
        require(address(token_) != address(0), "Marketing: Token address can't be address zero");
        token = token_;
        startBlock = block.number;
    }

    function claim(uint256 amount_) external onlyOwner {
        require(block.number >= startBlock + 7 * BLOCKS_PER_MONTH, "Marketing: Locked period didn't passed");
        uint256 unlockedAmount = getUnlockedTokenAmount();
        require(amount_ <= unlockedAmount, "Marketing: Insufficiant unlocked tokens");
        require(lockedAmount >= claimedAmount + amount_, "Marketing: Insufficient locked tokens");
        claimedAmount += amount_;
        // lockedAmount -= amount_;
        token.safeTransfer(msg.sender, amount_);
    }

    function getUnlockedTokenAmount() public view returns (uint256 amount) {
        if (block.number < startBlock + 7 * BLOCKS_PER_MONTH) {
            return 0;
        }
        amount = unlockedPerMonth * ((block.number - (startBlock + 6 * BLOCKS_PER_MONTH)) / BLOCKS_PER_MONTH);
        if (amount >= lockedAmount) {
            amount = lockedAmount;
        }
        amount -= claimedAmount;
        return amount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityReserve is Ownable {
    IERC20 public token;

    constructor(IERC20 token_) {
        require(address(token_) != address(0), "Token address can't be address zero");
        token = token_;
    }

    function approveForAddingLiquidity(address contractAddress) external onlyOwner {
        IERC20(token).approve(contractAddress, type(uint256).max);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Charity is Ownable {
    using SafeERC20 for IERC20;
    // TODO fix for mainnet
    uint256 public constant BLOCKS_PER_MONTH = 20;
    uint256 public lockedPeriod = 16 * BLOCKS_PER_MONTH;
    uint256 public lockedAmount = 2000000 ether;
    uint256 public claimedAmount;
    uint256 public startBlock;
    uint256 public unlockedPerMonth = 80000 ether;
    IERC20 public token;

    constructor(IERC20 token_) {
        require(address(token_) != address(0), "Charity: Token address can't be address zero");
        token = token_;
        startBlock = block.number;
    }

    function claim(uint256 amount_) external onlyOwner {
        require(block.number >= startBlock + 17 * BLOCKS_PER_MONTH, "Charity: Locked period didn't passed");
        uint256 unlockedAmount = getUnlockedTokenAmount();
        require(amount_ <= unlockedAmount, "Charity: Insufficiant unlocked tokens");
        require(lockedAmount >= claimedAmount + amount_, "Charity: Insufficient locked tokens");
        claimedAmount += amount_;
        // lockedAmount -= amount_;
        token.safeTransfer(msg.sender, amount_);
    }

    function getUnlockedTokenAmount() public view returns (uint256 amount) {
        if (block.number < startBlock + 17 * BLOCKS_PER_MONTH) {
            return 0;
        }
        amount = unlockedPerMonth * ((block.number - (startBlock + 16 * BLOCKS_PER_MONTH)) / BLOCKS_PER_MONTH);
        if (amount >= lockedAmount) {
            amount = lockedAmount;
        }
        amount -= claimedAmount;
        return amount;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.0.0;
import 'ApeSwap-AMM-Periphery/contracts/interfaces/IApeRouter02.sol';