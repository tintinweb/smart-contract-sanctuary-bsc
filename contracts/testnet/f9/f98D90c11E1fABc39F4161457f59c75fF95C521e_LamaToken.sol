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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `from` to `to`.
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

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
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
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
/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

interface IEmergencyGuard {
    /**
     * Emitted on BNB withdrawal
     *
     * @param receiver address - Receiver of BNB
     * @param amount uint256 - BNB amount
     */
    event EmergencyWithdraw(address receiver, uint256 amount);

    /**
     * Emitted on token withdrawal
     *
     * @param receiver address - Receiver of token
     * @param token address - Token address
     * @param amount uint256 - token amount
     */
    event EmergencyWithdrawToken(
        address receiver,
        address token,
        uint256 amount
    );

    /**
     * Withdraws BNB stores at the contract
     *
     * @param amount uint256 - Amount of BNB to withdraw
     */
    function emergencyWithdraw(uint256 amount) external;

    /**
     * Withdraws token stores at the contract
     *
     * @param token address - Token to withdraw
     * @param amount uint256 - Amount of token to withdraw
     */
    function emergencyWithdrawToken(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

// SPDX-License-Identifier: MIT

/**
 * Developed By Snake M
 */

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./interfaces/Uniswap.sol";
import "./utils/EmergencyGuard.sol";

/**
 * @title LAMA Token
 * @dev Token contract for the LAMA ecosystem currency
 */
contract LamaToken is ERC20, ERC20Burnable, Ownable, Pausable, EmergencyGuard {

    // Fee percentage limit (Fees cannot exceed 20%)
    uint256 internal constant FEE_PERCENTAGE_LIMIT = 20;

    // Mapping to allow only whitelisted addresses to buy in the first minute of launch
    mapping(address => bool) public whitelistedAtLaunch;

    // Launch Lock Time before it goes public
    uint256 public launchLockTime = 0;

    // Mapping to exclude some contracts from fees. Transfers are excluded from fees if address in this mapping is recipient or sender.
    mapping(address => bool) public excludedFromFees;

    // Blacklist mapping to prevent addresses from trading if necessary (i.e. flagged for malicious activity).
    mapping(address => bool) public blacklistedAddresses;

    // Mapping to determine which addresses are pair addresses.
    mapping(address => bool) public pairAddresses;

    // Address of the contract for burning Lama Tokens and also for future exchanges listing.
    address private burnAndFutureExchangesListingWalletAddress;

    // Address of the contract for airdrop that will be used in the first year to rewards long term investors.
    address private airdropWalletAddress;

    // Team wallet address used for funding the team.
    address private teamWalletAddress;

    // Marketing wallet address used for funding the marketing.
    address private marketingWalletAddress;

    // Private sale Investors wallet address.
    // After these tokens are provided to the holders, this address will no longer be used.
    address private privateSaleWalletAddress;

    // Liquidity wallet address used to hold Lama Tokens for the liquidity pool.
    // After these tokens are moved to the DEX, this address will no longer be used.
    address private liquidityWalletAddress;

    // Fee wallet address used for the tax generated
    address public feeWalletAddress;

    // The DEX router address for swapping Lama Tokens for BNB.
    address public uniswapV2RouterAddress;

    // Buy transaction fee - deployed at 10%
    uint256 public buyFeePercent = 10;

    // Sell transaction fee - deployed at 10%
    uint256 public sellFeePercent = 10;

    // Lama Contract Address
    address private contractAddress;

    // DEX router interface.
    IUniswapV2Router02 private uniswapV2Router;

    // Address of the BNB to Lama Token pair on the DEX.
    address public uniswapV2Pair;

    // Determines how many Lama Tokens this contract needs before it swaps for BNB to pay fee wallets.
    uint256 public contractTokenDivisor = 1000;

    // Buy and sell transaction fee enabled
    bool public feesEnabled = true;

    // Swap Fees to BNB enabled
    bool public swapEnabled = false;

    bool inSwap;

    // Events to emit when the transaction fees are updated or transaction fee tokens are sold and dispersed
    event buyTransactionFeeUpdated(uint256 indexed transactionFeeAmount);
    event sellTransactionFeeUpdated(uint256 indexed transactionFeeAmount);
    event transactionFeesSwappedForBnb(uint256 indexed lamaTokenAmount, uint256 indexed bnbAmount);
    event transactionFeeBnbDispersed(uint256 indexed fee);
    event FeesEnabledUpdated(bool enabled);
    event SwapEnabledUpdated(bool enabled);


    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // Initial token distribution
    constructor(
        uint256 initialSupply,
        address _liquidityWalletAddress,
        address _burnAndFutureExchangesListingWalletAddress,
        address _airdropWalletAddress,
        address _teamWalletAddress,
        address _marketingWalletAddress,
        address _privateSaleWalletAddress,
        address payable _feeWalletAddress,
        address _uniswapV2RouterAddress) ERC20("LAMA", "LAMA") {

        liquidityWalletAddress = _liquidityWalletAddress;
        burnAndFutureExchangesListingWalletAddress = _burnAndFutureExchangesListingWalletAddress;
        airdropWalletAddress = _airdropWalletAddress;
        teamWalletAddress = _teamWalletAddress;
        marketingWalletAddress = _marketingWalletAddress;
        privateSaleWalletAddress = _privateSaleWalletAddress;
        feeWalletAddress = _feeWalletAddress;
        contractAddress = address(this);

        excludedFromFees[owner()] = true;
        excludedFromFees[contractAddress] = true;
        excludedFromFees[liquidityWalletAddress] = true;
        excludedFromFees[burnAndFutureExchangesListingWalletAddress] = true;
        excludedFromFees[airdropWalletAddress] = true;
        excludedFromFees[teamWalletAddress] = true;
        excludedFromFees[marketingWalletAddress] = true;
        excludedFromFees[privateSaleWalletAddress] = true;
        excludedFromFees[feeWalletAddress] = true;

        _mint(liquidityWalletAddress, initialSupply / 10);
        _mint(burnAndFutureExchangesListingWalletAddress, ((initialSupply) * 35 / 100));
        _mint(airdropWalletAddress, initialSupply / 10);
        _mint(teamWalletAddress, initialSupply / 10);
        _mint(marketingWalletAddress, ((initialSupply) * 5 / 100));
        _mint(privateSaleWalletAddress, ((initialSupply) * 30 / 100));

        setRouter(_uniswapV2RouterAddress);

        _pause();
    }

    /**
     * @dev Returns the contract address
     * @return contract address
     */
    function getContractAddress() external view returns (address){
        return contractAddress;
    }

    /**
    * @dev Adds a user to be excluded from fees.
    * @param user address of the user to be excluded from fees.
     */
    function excludeUserFromFees(address user) external onlyOwner {
        excludedFromFees[user] = true;
    }

    /**
    * @dev Gets the current timestamp, used for testing + verification
    * @return the the timestamp of the current block
     */
    function getCurrentTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
    * @dev Removes a user from the fee exclusion.
    * @param user address of the user than will now have to pay transaction fees.
     */
    function includeUsersInFees(address user) external onlyOwner {
        excludedFromFees[user] = false;
    }

    /**
     * @dev Overrides the BEP20 transfer function to include transaction fees.
     * @param recipient the recipient of the transfer
     * @param amount the amount to be transfered
     * @return bool representing if the transfer was successful
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Ensure the sender isn't blacklisted.
        require(!blacklistedAddresses[_msgSender()], "You have been blacklisted from trading the LAMA Token. If you think this is an error, please contact the LAMA team.");
        // Ensure the recipient isn't blacklisted.
        require(!blacklistedAddresses[recipient], "The address you are trying to send LAMA Tokens to has been blacklisted from trading the LAMA Token. If you think this is an error, please contact the LAMA team.");

        // If the sender or recipient is excluded from fees, perform the default transfer.
        if (!feesEnabled || excludedFromFees[_msgSender()] || excludedFromFees[recipient]) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        require(!paused(), "Trading is paused.");

        validateLaunchFirstBlocks(_msgSender(), recipient, amount);

        collectFees(_msgSender(), recipient, amount);

        if (swapEnabled && !pairAddresses[_msgSender()]) {
            uint256 contractLamaTokenBalance = balanceOf(contractAddress);

            if (contractLamaTokenBalance > balanceOf(uniswapV2Pair) / contractTokenDivisor) {
                swapLamaTokensForBnb(contractLamaTokenBalance);
            }
        }

        return true;
    }

    /**
     * @dev Overrides the BEP20 transferFrom function to include transaction fees.
     * @param from the address from where the tokens are coming from
     * @param to the recipient of the transfer
     * @param amount the amount to be transfered
     * @return bool representing if the transfer was successful
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        // Ensure the sender isn't blacklisted.
        require(!blacklistedAddresses[_msgSender()], "You have been blacklisted from trading the Lama Token. If you think this is an error, please contact the Lama House team.");
        // Ensure the address where the tokens are coming from isn't blacklisted.
        require(!blacklistedAddresses[from], "The address you're trying to spend the Lama Tokens from has been blacklisted from trading the Lama Token. If you think this is an error, please contact the Lama House team.");
        // Ensure the recipient isn't blacklisted.
        require(!blacklistedAddresses[to], "The address you are trying to send Lama Tokens to has been blacklisted from trading the Lama Token. If you think this is an error, please contact the Lama House team.");

        // If the from address or to address is excluded from fees, perform the default transferFrom.
        if (!feesEnabled || excludedFromFees[from] || excludedFromFees[to] || excludedFromFees[_msgSender()]) {
            _spendAllowance(from, _msgSender(), amount);
            _transfer(from, to, amount);
            return true;
        }

        require(!paused(), "Trading is paused.");

        validateLaunchFirstBlocks(from, to, amount);

        collectFees(from, to, amount);

        if (swapEnabled && !pairAddresses[from]) {
            uint256 contractLamaTokenBalance = balanceOf(contractAddress);

            if (contractLamaTokenBalance > balanceOf(uniswapV2Pair) / contractTokenDivisor) {
                swapLamaTokensForBnb(contractLamaTokenBalance);
            }
        }

        return true;
    }

    function validateLaunchFirstBlocks(address from, address to, uint256 amount) internal view {
        //if lock is active AND recipient is not whitelisted, recipient cannot buy
        if (block.timestamp < launchLockTime && !whitelistedAtLaunch[to]) {
            require(!pairAddresses[_msgSender()], "You are not whitelisted at launch. Wait for the launch to be open to public");
        }
        //if lock is active AND recipient IS whitelisted, recipient can buy up to 2000 Tokens
//        if (block.timestamp < launchLockTime && whitelistedAtLaunch[to]) {
//            if (pairAddresses[from] && !excludedFromFees[from] && !excludedFromFees[to]) {
//                require((balanceOf(to) + amount) < 2000000000000000000000, "You can't buy more than 2000 Lama Tokens at launch.");
//            }
//        }
    }

    function collectFees(address from, address to, uint256 amount) internal {
        uint256 contractFee = 0;

        if (pairAddresses[from] == true) {
            // Buy transaction fee.
            contractFee = (amount * buyFeePercent) / 100;
        } else {
            // Sell Fees
            contractFee = (amount * sellFeePercent) / 100;
        }

        if(contractFee > 0) {
            // Sends the transaction fees to the contract address
            _spendAllowance(from, _msgSender(), amount);
            _transfer(from, contractAddress, contractFee);

            // Sends [initial amount] - [fees] to the recipient
            uint256 valueAfterFees = amount - contractFee;
            _transfer(from, to, valueAfterFees);
        } else {
            _transfer(from, to, amount);
        }
    }

    function swapLamaTokensForBnb(uint256 amount) internal swapping {
        // only swap if more than 1e-5 tokens are in contract to avoid "UniswapV2: K" error
        if (amount > 10 ** 13) {
            // Generate the uniswap pair path of LAMA -> WBNB
            address[] memory path = new address[](2);
            path[0] = contractAddress;
            path[1] = uniswapV2Router.WETH();

            _approve(contractAddress, address(uniswapV2Router), amount);

            // make the swap
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0, // accept any amount of BNB
                path,
                contractAddress,
                block.timestamp
            );

            emit transactionFeesSwappedForBnb(amount, contractAddress.balance);

            sendFeeToWallet();
        }
    }

    /**
     * @dev Sends Bnb to transaction fees wallet after Lama Token swaps.
     */
    function sendFeeToWallet() private {
        uint256 amount = contractAddress.balance;
        if (amount > 0) {
            (bool success,) = feeWalletAddress.call{value : amount}("");
            require(success, "Failed to send BNB to Fee Wallet address");
            emit transactionFeeBnbDispersed(amount);
        }
    }


    /**
     * @dev Sends BNB to transaction fee wallets manually as opposed to happening automatically after a certain level of volume
     */
    function disperseFeesManually() external onlyOwner {
        sendFeeToWallet();
    }

    /**
     * @dev Swaps all Lama Tokens in the contract for BNB and then disperses those funds to the fees wallet.
     * @param amount the amount of LAMA Tokens in the contract to swap for BNB
     * @param useAmount boolean to determine if the amount sent in is swapped for BNB or if the entire contract balance is swapped
     */
    function swapLamaTokensForBnbManually(uint256 amount, bool useAmount) external onlyOwner {
        if (useAmount) {
            swapLamaTokensForBnb(amount);
        }
        else {
            uint256 contractLamaTokenBalance = balanceOf(contractAddress);
            swapLamaTokensForBnb(contractLamaTokenBalance);
        }
    }

    /**
     * @dev Sets the value that determines how many Lama Tokens need to be in the contract before it's swapped for BNB.
     * @param newDivisor the new divisor value to determine the swap threshold
     */
    function setContractTokenDivisor(uint256 newDivisor) external onlyOwner {
        contractTokenDivisor = newDivisor;
    }

    /**
    * @dev Updates the blacklist mapping for a given address
    * @param user the address that is being added or removed from the blacklist
    * @param blacklisted a boolean that determines if the given address is being added or removed from the blacklist
    */
    function updateBlackListAddresses(address user, bool blacklisted) external onlyOwner {
        blacklistedAddresses[user] = blacklisted;
    }

    /**
    * @dev Function to update the buy transaction fee - can't be more than 20 percent
    * @param newBuyTransactionFee the new buy transaction fee
    */
    function updateBuyTransactionFee(uint256 newBuyTransactionFee) external onlyOwner {
        require(newBuyTransactionFee <= FEE_PERCENTAGE_LIMIT, "The buy transaction fee can't be more than 20%.");
        buyFeePercent = newBuyTransactionFee;
        emit buyTransactionFeeUpdated(newBuyTransactionFee);
    }

    /**
    * @dev Function to update the marketing transaction fee - can't be more than 20 percent
    * @param newSellTransactionFee the new sell transaction fee
    */
    function updateSellTransactionFee(uint256 newSellTransactionFee) external onlyOwner {
        require(newSellTransactionFee <= FEE_PERCENTAGE_LIMIT, "The sell transaction fee can't be more than 20%.");
        sellFeePercent = newSellTransactionFee;
        emit sellTransactionFeeUpdated(newSellTransactionFee);
    }



    /**
    * @dev Function to update the fees wallet
    * @param newFeeWalletAddress the address that will be used to receive fees in BNB
    */
    function updateFeesWallet(address newFeeWalletAddress) external onlyOwner {
        require(
            newFeeWalletAddress != address(0),
            "Lama: Cannot set Fee Wallet to zero address"
        );

        feeWalletAddress = newFeeWalletAddress;
    }

    /**
    * @dev Function to set the router
    * @param router the address of the new router
    */
    function setRouter(address router) internal {
        require(
            router != address(0),
            "Lama: Cannot set Router to zero address"
        );

        uniswapV2RouterAddress = router;
        uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
        _approve(contractAddress, address(uniswapV2Router), type(uint256).max);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(contractAddress, uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint256).max);

        pairAddresses[uniswapV2Pair] = true;
    }

    /**
    * @dev Only owner function to add/remove an address as a pair address.
    * @param pairAddr the pair address to either add or remove as a pair
    * @param isPairAddress boolean to determine if the address is now a pair or no longer a pair
    */
    function addOrRemovePairAddress(address pairAddr, bool isPairAddress) external onlyOwner {
        pairAddresses[pairAddr] = isPairAddress;
    }

    function isWhitelistedAtLaunch(address wAddress) external view returns (bool)
    {
        return whitelistedAtLaunch[wAddress];
    }

    function addMultiWhitelistedAtLaunch(address[] calldata wAddresses) public onlyOwner returns (bool success)
    {
        for (uint256 i = 0; i < wAddresses.length; i++) {
            if (addWhitelistedAtLaunch(wAddresses[i])) {
                success = true;
            }
        }
    }

    function addWhitelistedAtLaunch(address _address) public onlyOwner returns (bool)
    {
        whitelistedAtLaunch[_address] = true;
        return true;
    }

    function removeFromWhitelistedAtLaunch(address _address) external onlyOwner
    {
        whitelistedAtLaunch[_address] = false;
    }

    function emergencyWithdraw(uint256 amount) external override onlyOwner
    {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(address token, uint256 amount) external override onlyOwner
    {
        super._emergencyWithdrawToken(token, amount);
    }

    function pause() external onlyOwner
    {
        super._pause();
    }

    function unpause() external onlyOwner
    {
        super._unpause();
    }

    /**
    * @notice sets whether account collects fees on token transfer
     * @param enabled bool whether fees are enabled
     */
    function setFeesEnabled(bool enabled) external onlyOwner {
        emit FeesEnabledUpdated(enabled);
        feesEnabled = enabled;
    }

    /**
     * @notice sets whether collected fees are autoswapped
     * @param enabled bool whether swap is enabled
     */
    function setSwapEnabled(bool enabled) external onlyOwner {
        emit SwapEnabledUpdated(enabled);
        swapEnabled = enabled;
    }

    function manualPairSync() external onlyOwner {
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    /**
     * @dev Start Trading, This function can be executed just one time
     */
    function startTrading() external onlyOwner {
        if (launchLockTime == 0) {
            _unpause();
            launchLockTime = block.timestamp + 300 seconds;
        }
    }

    // To receive ETH from uniswapV2Router when swapping
    receive() external payable {}
}

// SPDX-License-Identifier: MIT

/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./../interfaces/IEmergencyGuard.sol";

abstract contract EmergencyGuard is IEmergencyGuard {
    function _emergencyWithdraw(uint256 amount) internal virtual {
        address payable sender = payable(msg.sender);
        (bool sent,) = sender.call{value : amount}("");
        require(sent, "Lama: Failed to send BNB");

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function _emergencyWithdrawToken(address token, uint256 amount)
    internal
    virtual
    {
        IERC20(token).transfer(msg.sender, amount);
        emit EmergencyWithdrawToken(msg.sender, token, amount);
    }
}