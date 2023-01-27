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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

//SPDX-License-Identifier: MIT
/* 
█████████████████████████████████████████████████████████████████████████████████
███████████████████████████████████████░ ▓███████████████████████████████████████
███████████████████░███████████████████   ███████████████████▓███████████████████
███████████████████  █████████████████▓   ██████████████████  ███████████████████
███████████████████  ▒████████████████    ▒████████████████░  ███████████████████
███████████████████   ████████████████     ████████████████   ███████████████████
███████████████████   ░██████████████▒     ███████████████    ███████████████████
███████████████████    ██████████████      ░█████████████▓    ███████████████████
███████████████████     █████████████       █████████████     ███████████████████
███████████████████     ████████████░       ████████████▒     ███████████████████
███████████████████      ███████████        ░███████████      ███████████████████
███████████████████      ▓██████████         ██████████░      ███████████████████
███████████████████       █████████          ▓█████████       ███████████████████
███████████████████       ▒████████           ████████        ███████████████████
███████████████████        ███████▒           ████████        ███████████████████
███████████████████        ░██████            ░██████         ███████████████████
█████████████████████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████████████████████
███    ██████     ███████▓   ▒████████░   ▓███████   ░████████████▒       ░██████
███    ████▒     ████████░    ████████     ░█████▒    ██████████             ████
███    ███     ██████████▒   ░████████       ████▓    █████████      ▒▓▒░   ▓████
███    █▒    ▓███████████▒   ░████████        ███▓    ████████     ██████████████
███         █████████████▒   ░████████    ░    ▒██    ███████▒    ████▒░░░▒░░░███
███         ▒████████████▒   ░████████    ██    ░█    ███████░    ████        ███
███     ▓     ███████████▒   ░████████    ███         ███████▓    ████▒  ░    ███
███    ███     ██████████▒   ░████████    ████░       ████████     ███████    ███
███    ████░    ▓████████░   ░████████    █████▓      █████████               ███
███    █████▓     ███████░    ████████    ▓██████     ██████████▒            ████
███░░░▒███████░░░ ████████░░░█████████▓░░░████████▒░░▓█████████████▒░   ░▒███████
█████████████████████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████████████████████
website: https://kingworld.finance/
telegram: https://t.me/kingannouncements
twitter: https://twitter.com/kingfinance
discord: https://kingworld.finance/discord
 */
// Written by Krakovia | KKTeam with 💓 o/
pragma solidity 0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
//interfaces
interface IPancakeV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IPancakeV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface IKingPass {
    function checkIfPassActive(address who) external view returns(bool);
}
contract King is ERC20, Ownable {
    //custom
    IPancakeV2Router02 public pancakeV2Router;
    //bool
    bool public swapAndLiquifyEnabled = true;
    bool public sendToMarketing = true;
    bool public sendToDev = true;
    bool public sendToBuyback = true;
    bool public limitSells = true;
    bool public limitBuys = true;
    bool public feeStatus = true;
    bool public buyFeeStatus = true;
    bool public sellFeeStatus = true;
    bool public vestingActive = true;
    bool public blockMultiBuys = true;
    bool public kingPassActive;
    bool public marketActive;
    bool public KKLaunched;
    bool private isInternalTransaction;
    //address
    address public marketingAddress = 0x2EEcdB4631c3D2F49D56b4CbfEdE4C7B23151337;
    address public devAddress = 0x0af6fef0248d666f0Bfd73e65485186526411337;
    address public buybackAddress = 0x0af6fef0248d666f0Bfd73e65485186526411337;
    address public pancakeV2Pair;
    address public kingPassContract;
    //uint
    uint public buyMarketingFee = 40;
    uint public sellMarketingFee = 60;
    uint public buyDevFee = 50;
    uint public sellDevFee = 70;
    uint public buyBuybackFee = 10;
    uint public sellBuybackFee = 20;
    uint public kingPassFeeDiscount = 600;
    uint public totalBuyFee = buyMarketingFee + buyDevFee + buyBuybackFee;
    uint public totalSellFee = sellMarketingFee + sellDevFee + sellBuybackFee;
    uint public minimumTokensBeforeSwap = 5500 * 10 ** decimals();
    uint public tokensToSwap = 5500 * 10 ** decimals();
    uint public intervalSecondsForSwap = 30;
    uint public minimumWeiForTokenomics = 1 * 10**17; // 0.1 BNB
    uint public maxBuyTxAmount;
    uint public maxSellTxAmount;
    uint private startTimeForSwap;
    uint private marketActiveAt;
    //struct
    struct userData {uint lastBuyTime;}
    //mapping
    mapping (address => bool) public premarketUser;
    mapping (address => bool) public VestedUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint) public kingPassLockedTokens;
    mapping (address => userData) public userLastTradeData;
    //events
    event DevelopmentFeeCollected(uint amount);
    event MarketingFeeCollected(uint amount);
    event BuybackFeeCollected(uint amount);
    event PancakeRouterUpdated(address indexed newAddress, address indexed newPair);
    event PancakePairUpdated(address indexed newAddress, address indexed newPair);
    event TokenRemovedFromContract(address indexed tokenAddress, uint256 amount);
    event BnbRemovedFromContract(uint256 amount);
    event MarketStatusChanged(bool status, uint256 date);
    event LimitSellChanged(bool status);
    event LimitBuyChanged(bool status);
    event VestingDisabled(uint256 date);
    event FeesSendToWalletStatusChanged(bool marketing, bool buyback, bool dev);
    event MinimumWeiChanged(uint256 amount);
    event MaxSellChanged(uint256 amount);
    event MaxBuyChanged(uint256 amount);
    event FeesChanged(uint256 buyDevFee, uint256 buyMarketingFee, uint256 buyBuybackFee,
                      uint256 sellDevFee, uint256 sellMarketingFee, uint256 sellBuybackFee);
    event FeesAddressesChanged(address indexed marketing, address indexed buyback, address indexed dev);
    event FeesStatusChanged(bool feesActive, bool buy, bool sell);
    event SwapSystemChanged(bool status, uint256 intervalSecondsToWait, uint256 minimumToSwap, uint256 tokensToSwap);
    event PremarketUserChanged(bool status, address indexed user);
    event ExcludeFromFeesChanged(bool status, address indexed user);
    event MessengerChanged(bool status, address indexed user);
    event AutomatedMarketMakerPairsChanged(bool status, address indexed target);
    event VestedUsersChanged(bool status, address[] indexed users);
    event ContractSwap(uint256 date, uint256 amount);
    event BlockMultiBuysChange(bool status);
    event KingPassAddressChanged(address kingpass);
    event KingPassState(bool enabled);
    event KingPassLockedTokens(address indexed user, uint amount);
    event SetKingPassFeeDiscount(uint discountAmount);
    // constructor
    constructor() ERC20("King", "KING") {
        uint total_supply = 100_000_000 * 10 ** decimals();
        IPancakeV2Router02 _pancakeV2Router = IPancakeV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeV2Router = _pancakeV2Router;
        maxSellTxAmount = total_supply / 100; // 1% supply
        maxBuyTxAmount = total_supply / 100; // 1% supply
        //spawn pair
        pancakeV2Pair = IPancakeV2Factory(_pancakeV2Router.factory())
        .createPair(address(this), _pancakeV2Router.WETH());
        // mappings
        excludedFromFees[address(this)] = true;
        excludedFromFees[owner()] = true;
        excludedFromFees[devAddress] = true;
        excludedFromFees[buybackAddress] = true;
        excludedFromFees[marketingAddress] = true;
        premarketUser[owner()] = true;
        automatedMarketMakerPairs[pancakeV2Pair] = true;
        // mint is used only here
        _mint(owner(), total_supply);
        // burn the old dead supply
        burn(23164530898000000);
        // used only here to avoid some bots
        KKPunishOn();
    }
    // KingPass check
    modifier onlyKingPass {
        require(msg.sender == kingPassContract,"only KingPass contract can do that");
        _;
    }
    // accept bnb for autoswap
    receive() external payable {}
    
    function decimals() public pure override returns(uint8) {
        return 9;
    }

    // burn function
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    // called at deploy and never used anymore
    function KKPunishOn() internal {
        buyMarketingFee = 330;
        sellMarketingFee = 330;
        buyDevFee = 330;
        sellDevFee = 330;
        buyBuybackFee = 330;
        sellBuybackFee = 330;
        totalBuyFee = buyMarketingFee + buyDevFee + buyBuybackFee;
        totalSellFee = sellMarketingFee + sellDevFee + sellBuybackFee;
    }
    // change router if needed
    function updatePancakeV2Router(address newAddress, bool _createPair, address _pair) external onlyOwner {
        pancakeV2Router = IPancakeV2Router02(newAddress);
        if(_createPair) {
            address _pancakeV2Pair = IPancakeV2Factory(pancakeV2Router.factory())
                .createPair(address(this), pancakeV2Router.WETH());
            pancakeV2Pair = _pancakeV2Pair;
            emit PancakePairUpdated(newAddress,pancakeV2Pair);
        } else {
            pancakeV2Pair = _pair;
        }
        emit PancakeRouterUpdated(newAddress,pancakeV2Pair);
    }
    // to take leftover(tokens) from contract
    function transferToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        } 
        _sent = IERC20(_token).transfer(_to, _value);
        emit TokenRemovedFromContract(_token, _value);
    }
    // to take leftover(bnb) from contract
    function transferBNB() external onlyOwner {
        uint balance = address(this).balance;
        (bool success,) = owner().call{value: balance}("");
        if(success) {
            emit BnbRemovedFromContract(balance);
        }
    }
    // market status
    function switchMarketActive(bool _state) external onlyOwner {
        marketActive = _state;
        if(_state) {
            marketActiveAt = block.timestamp;
        }
        emit MarketStatusChanged(_state, block.timestamp);
    }
    // limit sells
    function switchLimitSells(bool _state) external onlyOwner {
        limitSells = _state;
        emit LimitSellChanged(_state);
    }
    // limit buys
    function switchLimitBuys(bool _state) external onlyOwner {
        limitBuys = _state;
        emit LimitBuyChanged(_state);
    }
    // vesting status
    function disableVesting() external onlyOwner {
        // there is no coming back after disabling vesting.
        vestingActive = false;
        emit VestingDisabled(block.timestamp);
    }
    //set functions
    // launch fee
    function setLaunchFee() external onlyOwner {
        buyMarketingFee = 40;
        sellMarketingFee = 60;
        buyDevFee = 50;
        sellDevFee = 70;
        buyBuybackFee = 10;
        sellBuybackFee = 20;
        KKLaunched = true;
        totalBuyFee = buyMarketingFee + buyDevFee + buyBuybackFee;
        totalSellFee = sellMarketingFee + sellDevFee + sellBuybackFee;
        emit FeesChanged(buyDevFee,buyMarketingFee,buyBuybackFee,
                         sellDevFee, sellMarketingFee, sellBuybackFee);
    }
    // multi buy
    function setBlockMultiBuys(bool _status) external onlyOwner {
        blockMultiBuys = _status;
        emit BlockMultiBuysChange(_status);
    }
    // redistribution status (enable/disable)
    function setsendFeeStatus(bool marketing, bool dev, bool buyback) external onlyOwner {
        sendToMarketing = marketing;
        sendToBuyback = buyback;
        sendToDev = dev;
        emit FeesSendToWalletStatusChanged(marketing,buyback,dev);
    }
    // min BNB to activate redistribution
    function setminimumWeiForTokenomics(uint _value) external onlyOwner {
        minimumWeiForTokenomics = _value;
        emit MinimumWeiChanged(_value);
    }
    // fee wallets
    function setFeesAddress(address marketing, address dev, address buyback) external onlyOwner {
        marketingAddress = marketing;
        devAddress = dev;
        buybackAddress = buyback;
        emit FeesAddressesChanged(marketing,dev,buyback);
    }
    // maxTx - sell
    function setMaxSellTxAmount(uint _value) external onlyOwner {
        maxSellTxAmount = _value*10**decimals();
        require(maxSellTxAmount >= totalSupply() / 1000,"maxSellTxAmount should be at least 0.1% of total supply.");
        emit MaxSellChanged(_value);
    }
    // maxTx - buy
    function setMaxBuyTxAmount(uint _value) external onlyOwner {
        maxBuyTxAmount = _value*10**decimals();
        require(maxBuyTxAmount >= totalSupply() / 1000,"maxBuyTxAmount should be at least 0.1% of total supply.");
        emit MaxBuyChanged(maxBuyTxAmount);
    }
    // KingPass status
    function setKingPassState(bool state) external onlyOwner {
        kingPassActive = state;
        emit KingPassState(state);
    }
    // KingPass address
    function setKingPassAddress(address _target) external onlyOwner {
        kingPassContract = _target;
        require(kingPassContract.code.length > 0,"KingPass must be a contract.");
        emit KingPassAddressChanged(_target);
    }
    // Lock tokens to activate KingPass
    function setKingPassLockedTokens(address user, uint amount) external onlyKingPass {
        kingPassLockedTokens[user] = amount;
        emit KingPassLockedTokens(user,amount);
    }
    // KingPass fee discount amount
    function setKingPassFeeDiscount(uint discountAmount) external onlyOwner {
        kingPassFeeDiscount = discountAmount;
        require(kingPassFeeDiscount <= 1000,"KingPass fee discount cannot be over 100%");
        emit SetKingPassFeeDiscount(discountAmount);
    }
    // set fee numbers
    function setFee(bool is_buy, uint marketing, uint dev, uint buyback) external onlyOwner {
        if(is_buy) {
            buyDevFee = dev;
            buyMarketingFee = marketing;
            buyBuybackFee = buyback;
            totalBuyFee = buyMarketingFee + buyDevFee + buyBuybackFee;
        } else {
            sellDevFee = dev;
            sellMarketingFee = marketing;
            sellBuybackFee = buyback;
            totalSellFee = sellMarketingFee + sellDevFee + sellBuybackFee;
        }
        require(totalBuyFee + totalSellFee <= 250,"Total fees cannot be over 25%");
        emit FeesChanged(buyDevFee,buyMarketingFee,buyBuybackFee,
             sellDevFee,sellMarketingFee,sellBuybackFee);
    }
    // fee status (enable/disable)
    function setFeeStatus(bool buy, bool sell, bool _state) external onlyOwner {
        feeStatus = _state;
        buyFeeStatus = buy;
        sellFeeStatus = sell;
        emit FeesStatusChanged(_state,buy,sell);
    }
    // swap system settings
    function setSwapAndLiquify(bool _state, uint _intervalSecondsForSwap, uint _minimumTokensBeforeSwap, uint _tokensToSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        intervalSecondsForSwap = _intervalSecondsForSwap;
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap*10**decimals();
        tokensToSwap = _tokensToSwap*10**decimals();
        require(tokensToSwap <= minimumTokensBeforeSwap,"You cannot swap more then the minimum amount");
        require(tokensToSwap <= totalSupply() / 1000,"token to swap limited to 0.1% supply");
        emit SwapSystemChanged(_state,_intervalSecondsForSwap,_minimumTokensBeforeSwap,_tokensToSwap);
    }
    // mappings functions
    // premarket users
    function editPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
        emit PremarketUserChanged(_status,_target);
    }
    // excluded from fees
    function editExcludedFromFees(address _target, bool _status) external onlyOwner {
        excludedFromFees[_target] = _status;
        emit ExcludeFromFeesChanged(_status,_target);
    }
    // liquidity pools
    function editAutomatedMarketMakerPairs(address _target, bool _status) external onlyOwner {
        automatedMarketMakerPairs[_target] = _status;
        emit AutomatedMarketMakerPairsChanged(_status,_target);
    }
    // account vesting for special events
    function VestingMultipleAccounts(address[] calldata accounts, bool _state) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            VestedUser[accounts[i]] = _state;
        }
        emit VestedUsersChanged(_state,accounts);
    }
    // migration function
    function KKMigration(address[] memory _address, uint256[] memory _amount) external onlyOwner {
        for(uint i=0; i< _amount.length; i++){
            address adr = _address[i];
            uint amnt = _amount[i];
            super._transfer(owner(), adr, amnt);
        }
        // events from ERC20
    }
    // swap token > bnb
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();
        _approve(address(this), address(pancakeV2Router), tokenAmount);
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        emit ContractSwap(block.timestamp, tokenAmount);
    }
    // swap token > bnb
    function swapTokens(uint256 contractTokenBalance) private {
        isInternalTransaction = true;
        swapTokensForEth(contractTokenBalance);
        isInternalTransaction = false;
    }
    // check if KingPass is active
    function isKingPassActive(address user) private view returns(bool status) {
        // try-catch to avoid breaking the tx on the external call
        try IKingPass(kingPassContract).checkIfPassActive(user) {
            if (IKingPass(kingPassContract).checkIfPassActive(user)) status = true;
        } catch {}
        return status;
    }
    // transfer
    function _transfer(address from, address to, uint256 amount) internal override {
        // trade type, default = transfer
        uint trade_type = 0;
        // normal transaction
        if(!isInternalTransaction) {
            // market status flag
            if(!marketActive) {
                require(premarketUser[from],"cannot trade before the market opening");
            }
            // KingPass check - lock token in-place to use KingPass
            if(kingPassActive && kingPassLockedTokens[from] != 0) {
                require(balanceOf(from) - amount >= kingPassLockedTokens[from],"Cannot trade KingPass tokens");
            }
            // vesting, used to lock vested users, no tranfer, no sell, buy allowed.
            // can be disabled and cannot be enabled again
            if(vestingActive) {
                if(trade_type == 0 || trade_type == 2) {
                    require(!VestedUser[from],"your account is locked.");
                }
            }
            //buy
            if(automatedMarketMakerPairs[from]) {
                trade_type = 1;
                // if not excluded from fees
                if(!excludedFromFees[to]) {
                    // tx limit
                    if(limitBuys) {
                        require(amount <= maxBuyTxAmount, "maxBuyTxAmount Limit Exceeded");
                        // multi-buy limit
                        if(blockMultiBuys) {
                            require(marketActiveAt + 7 < block.timestamp,"You cannot buy at launch.");
                            require(userLastTradeData[tx.origin].lastBuyTime + 3 <= block.timestamp,"You cannot do multi-buy orders.");
                            userLastTradeData[tx.origin].lastBuyTime = block.timestamp;
                        }
                    }
                }
            }
            //sell
            else if(automatedMarketMakerPairs[to]) {
                trade_type = 2;
                bool overMinimumTokenBalance = balanceOf(address(this)) >= minimumTokensBeforeSwap;
                // marketing auto-bnb
                if (swapAndLiquifyEnabled && balanceOf(pancakeV2Pair) > 0) {
                    // if contract has X tokens, not sold since Y time, sell Z tokens
                    if (overMinimumTokenBalance && startTimeForSwap + intervalSecondsForSwap <= block.timestamp) {
                        startTimeForSwap = block.timestamp;
                        // sell to bnb
                        swapTokens(tokensToSwap);
                    }
                }
                // if not excluded from fees
                if(!excludedFromFees[from]) {
                    // tx limit
                    if(limitSells) {
                    require(amount <= maxSellTxAmount, "maxSellTxAmount Limit Exceeded");
                    }
                }
            }
            // fees redistribution
            if(address(this).balance > minimumWeiForTokenomics) {
                //marketing
                uint256 caBalance = address(this).balance;
                if(sendToMarketing) {
                    uint256 marketingTokens = caBalance * sellMarketingFee / totalSellFee;
                    (bool success,) = address(marketingAddress).call{value: marketingTokens}("");
                    if(success) {
                        emit MarketingFeeCollected(marketingTokens);
                    }
                }
                //development
                if(sendToDev) {
                    uint256 devTokens = caBalance * sellDevFee / totalSellFee;
                    (bool success,) = address(devAddress).call{value: devTokens}("");
                    if(success) {
                        emit DevelopmentFeeCollected(devTokens);
                    }
                }
                //buyback
                if(sendToBuyback) {
                    uint256 buybackTokens = caBalance * sellBuybackFee / totalSellFee;
                    (bool success,) = address(buybackAddress).call{value: buybackTokens}("");
                    if(success) {
                        emit BuybackFeeCollected(buybackTokens);
                    }
                }
            }
            // fees management
            if(feeStatus) {
                // buy
                uint txFees;
                if(trade_type == 1 && buyFeeStatus && !excludedFromFees[to]) {
                    if(kingPassActive && isKingPassActive(to)) {
                        txFees = amount * (totalBuyFee * kingPassFeeDiscount / 1000) / 1000;
                    } else {
                	    txFees = amount * totalBuyFee / 1000;
                    }
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
                //sell
                else if(trade_type == 2 && sellFeeStatus && !excludedFromFees[from]) {
                    if(kingPassActive && isKingPassActive(from)) {
                        txFees = amount * (totalSellFee * kingPassFeeDiscount / 1000) / 1000;
                    } else {
                	    txFees = amount * totalSellFee / 1000;
                    }
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
                // no wallet to wallet tax
            }
        }
        // transfer tokens
        super._transfer(from, to, amount);
    }
    //heheboi.gif
}