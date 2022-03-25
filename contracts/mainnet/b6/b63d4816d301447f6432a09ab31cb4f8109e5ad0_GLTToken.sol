/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: MIT
// File @openzeppelin/contracts/token/ERC20/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]



pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity ^0.8.0;



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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}


// File @openzeppelin/contracts/access/[email protected]



pragma solidity ^0.8.0;

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/security/[email protected]



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
     * by making the `nonReentrant` function external, and make it call a
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


// File contracts/GLD/GLT.sol


pragma solidity ^0.8.0;




interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract GLTToken is ERC20Capped, Ownable, ReentrancyGuard {
    string public constant __NAME__ = "GLT Token";
    string public constant __SYMBOL__ = "GLT";
    uint256 public constant __CAP__ = 21 * (10 ** 10) * (10 ** 18);
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant LP_WBNB_USDT = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;

    uint256 private constant MaxSellFeePct = 16;
    uint256 private sellFeePct;
    IUniswapV2Router public uniswapV2Router;  // router02 of PancakeSwap
    address public uniswapV2Pair;   //  GLT-BNB lp address

    address payable[] private treasuryList;
    uint256[] private treasuryRates;

    // excluded list from Treasury Fee
    mapping(address => bool) private _isExcludedFromSenderFees;
    mapping(address => bool) private _isExcludedFromRecipientFees;

    // included list from treasury fees
    mapping(address => bool) private _isIncludedInSenderFees;
    mapping(address => bool) private _isIncludedInRecipientFees;

    mapping(address => bool) internal blacklist;

    // tools
    uint256 public constant FeePctScale = 100;
    uint256 public constant SlippageScale = 100;
    uint256 public slippage;
    uint256 public timeoutLimit;

    /* statistic */
    uint256 public holdersNumber;

    // deploy
    constructor () public
    ERC20Capped(__CAP__)
    ERC20(__NAME__, __SYMBOL__)
    {
        sellFeePct = MaxSellFeePct;

        // pancake routerV2 address
        uniswapV2Router = IUniswapV2Router(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // create GLT-BNB lp address
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        // for addLP
        timeoutLimit = 10 minutes;
        slippage = 10;

        includeIntoRecipientFees(uniswapV2Pair, true);

        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }

    receive() external payable {}

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "GLTToken: only EOA account");
        _;
    }

    function initMintAll(address[] memory _init_accounts, uint256[] memory _init_percents) external onlyOwner {
        require(_init_accounts.length == _init_percents.length, "init length mismatch");
        uint256 totalPercent = 0;
        uint256 totalCap = 0;
        for (uint256 i = 0; i < _init_accounts.length; i++) {
            uint256 mintAmount = __CAP__ * _init_percents[i] / 100;
            totalPercent = totalPercent + _init_percents[i];
            totalCap = totalCap + mintAmount;
            _mint(_init_accounts[i], mintAmount);

            excludeFromSenderFees(_init_accounts[i], true);
        }
        require(totalPercent == 100, "invalid _init_percents");
        require(totalCap == __CAP__, "invalid _init_cap");
    }

    function changeTreasuryList(address payable[] memory _treasuryList, uint256[] memory _rates) external onlyOwner {
        require(_treasuryList.length > 0, "empty _treasuryList");
        require(_treasuryList.length == _rates.length, "_treasuryList length mismatch");

        for (uint256 i = 0; i < _treasuryList.length; i++) {
            require(_treasuryList[i] != address(0), "treasury address is the zero address");
        }

        uint256 totalRates = 0;
        for (uint256 i = 0; i < _rates.length; i++) {
            totalRates = totalRates + _rates[i];
        }
        require(totalRates == 100, "totalRates of treasuryList fee is not 100");

        treasuryList = _treasuryList;
        treasuryRates = _rates;

        for (uint256 i = 0; i < _treasuryList.length; i++) {
            excludeFromSenderFees(_treasuryList[i], true);
            excludeFromRecipientFees(_treasuryList[i], true);
        }
    }

    function setSellFeeRate(uint256 newSellFeeRate) external onlyOwner {
        require(newSellFeeRate <= MaxSellFeePct, "invalid newSellFeeRate");
        sellFeePct = newSellFeeRate;
    }

    function includeIntoSenderFees(address account, bool flag) public onlyOwner {
        _isIncludedInSenderFees[account] = flag;
    }

    function includeIntoRecipientFees(address account, bool flag) public onlyOwner {
        _isIncludedInRecipientFees[account] = flag;
    }

    function excludeFromSenderFees(address account, bool flag) public onlyOwner {
        _isExcludedFromSenderFees[account] = flag;
    }

    function excludeFromRecipientFees(address account, bool flag) public onlyOwner {
        _isExcludedFromRecipientFees[account] = flag;
    }

    function setBatchIncludeSenderFeeList(address[] memory users, bool flag) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            _isIncludedInSenderFees[users[i]] = flag;
        }
    }

    function setBatchIncludeRecipientFeeList(address[] memory users, bool flag) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            _isIncludedInRecipientFees[users[i]] = flag;
        }
    }

    function setBatchExcludeFeeList(address[] memory users, bool flag) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            _isExcludedFromSenderFees[users[i]] = flag;
            _isExcludedFromRecipientFees[users[i]] = flag;
        }
    }

    function setBatchBlacklists(address[] memory users, bool[] memory flags) external onlyOwner {
        require(users.length == flags.length, "length mismatch");

        for (uint256 i = 0; i < users.length; i++) {
            blacklist[users[i]] = flags[i];
        }
    }

    // transfer back mis-transferred token to users
    
    function transferBack(address tokenAddress, address payable to, uint256 amount) external onlyOwner {
        // transfer BNB
        if (tokenAddress == address(0)) {
            _safeTransferETH(to, amount);
        } else {
            IERC20(tokenAddress).transfer(to, amount);
        }
    }

    function setAddLpConfig(uint256 _slippage, uint256 _timeoutLimit) external onlyOwner {
        require(_slippage <= SlippageScale, "invalid slippage");
        slippage = _slippage;
        timeoutLimit = _timeoutLimit;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        require(!blacklist[sender], "GLT: in blacklist");

        uint256 remainingAmount = amount;

        // statistic
        uint256 recipientBeforeBalance = balanceOf(recipient);

        if (
            amount > 0 &&
            sellFeePct > 0 &&
            sender != address(this) &&
            recipient != address(this) &&
            !_isExcludedFromSenderFees[sender] &&
            !_isExcludedFromRecipientFees[recipient] &&
            (_isIncludedInSenderFees[sender] || _isIncludedInRecipientFees[recipient])
        ) {
            uint256 _GLTTokenFee = amount * sellFeePct / FeePctScale;

            super._transfer(sender, address(this), _GLTTokenFee);

            _swapAndTransferToTreasury(_GLTTokenFee);

            remainingAmount = amount - _GLTTokenFee;
        }

        super._transfer(sender, recipient, remainingAmount);

        // statistic
        if (remainingAmount > 0) {
            if (recipientBeforeBalance == 0) {
                holdersNumber++;
            }

            if (balanceOf(sender) == 0) {
                holdersNumber--;
            }
        }
    }

    function _swapAndTransferToTreasury(uint256 _GLTFee) private nonReentrant {
        uint256 initBalance = address(this).balance;

        _swapTokensForEth(_GLTFee);

        uint256 addedBalance = address(this).balance - initBalance;

        _distributeFee(addedBalance);
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function _distributeFee(uint256 _fee) private {
        require(treasuryList.length > 0, "treasuryList is none");

        uint256 distributedFee = 0;
        uint256 treasuryFee;
        for (uint256 i = 0; i < treasuryList.length; i++) {
            if (i < treasuryList.length - 1) {
                treasuryFee = _fee * treasuryRates[i] / 100;
                distributedFee = distributedFee + treasuryFee;
                _safeTransferETH(treasuryList[i], treasuryFee);
            } else {
                treasuryFee = _fee - distributedFee;
                _safeTransferETH(treasuryList[i], treasuryFee);
            }
        }
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{gas : 2300, value : value}("");
        require(success, "transfer eth failed");
    }

    function batchTransferAmount(address[] calldata receivers, uint256 amount) external onlyEOA nonReentrant {
        for (uint256 i = 0; i < receivers.length; i++) {
            _transfer(msg.sender, receivers[i], amount);
        }
    }

    function batchTransfer(address[] calldata receivers, uint256[] calldata amounts) external onlyEOA nonReentrant {
        require(receivers.length == amounts.length, "length mismatch");
        for (uint256 i = 0; i < receivers.length; i++) {
            _transfer(msg.sender, receivers[i], amounts[i]);
        }
    }

    function addLP(uint amountTokenDesired)
    external
    payable
    onlyEOA
    nonReentrant
    {
        _transfer(msg.sender, address(this), amountTokenDesired);
        IUniswapV2Router(uniswapV2Router).addLiquidityETH{
            value: msg.value
        }(
            address(this),
            amountTokenDesired,
            amountTokenDesired - amountTokenDesired * slippage / SlippageScale,
            msg.value - msg.value * slippage / SlippageScale,
            msg.sender,
            block.timestamp + timeoutLimit
        );
    }

    function isIncludedInSenderFees(address account) public view returns (bool) {
        return _isIncludedInSenderFees[account];
    }

    function isIncludedInRecipientFees(address account) public view returns (bool) {
        return _isIncludedInRecipientFees[account];
    }

    function isExcludedFromSenderFees(address account) public view returns (bool) {
        return _isExcludedFromSenderFees[account];
    }

    function isExcludedFromRecipientFees(address account) public view returns (bool) {
        return _isExcludedFromRecipientFees[account];
    }

    function getTokenPrices()
    public
    view
    returns(uint256 priceUSDT, uint256 priceWBNB) {

        uint256 WBNBBalanceAtGLTPair = IERC20(uniswapV2Router.WETH()).balanceOf(uniswapV2Pair);
        uint256 GLTBalanceAtGLTPair = IERC20(address(this)).balanceOf(uniswapV2Pair);
        priceWBNB =  WBNBBalanceAtGLTPair * 1e18 / GLTBalanceAtGLTPair;

        uint256 USDTBalanceAtPair = IERC20(USDT).balanceOf(LP_WBNB_USDT);
        uint256 WBNBBalanceAtPair = IERC20(uniswapV2Router.WETH()).balanceOf(LP_WBNB_USDT);

        priceUSDT = priceWBNB * USDTBalanceAtPair / WBNBBalanceAtPair;
    }
}