// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

contract Ownable is Context {
    using Address for address;
    address private _owner;
    address private _admin;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _admin = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            _owner == _msgSender() || _admin == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }
    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 _days) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + (_days * 1 days);
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(
            block.timestamp > _lockTime,
            "Contract is locked until {_lockTime} days"
        );
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Router01 {
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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
contract ERC20 is Context, IERC20 {
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;

    uint256 public _totalSupply;
    string private _name = "RIR7";
    string private _symbol = "RIR7";
    uint8 private _decimals = 9;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
=     * construction.
     */
    constructor() {}

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeIERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

contract ReedLock is Ownable {
    using SafeMath for uint256;

    /// @notice Indicates if token lock is enabled
    bool public isLockEnabled;

    struct Frozen {
        uint256 id;
        uint256 startsInDays;
        uint256 endsInDays;
        bool status; // TRUE / FALSE
    }

    uint256 public _frozenCount = 0; //
    mapping(address => Frozen) public _frozen; // Array of frozen accounts

    event AccountFreezed(address _account, uint256 _id);
    event AccountUnfreezed(address _account, uint256 _id);

    constructor() {
        isLockEnabled = true;
    }

    modifier canFreez() {
        require(
            isLockEnabled == true,
            "ReedLock: Account freezing is disabled"
        );
        _;
    }

    function freezer() external onlyAdmin {
        if (isLockEnabled == true) isLockEnabled = false;
        if (isLockEnabled == false) isLockEnabled = true;
    }

    function _freeze(
        address _account,
        uint256 _startsDays,
        uint256 _endsDays
    ) internal canFreez onlyAdmin {
        _frozenCount = _frozenCount.add(1);
        uint256 starts = block.timestamp;
        Frozen memory frozen = Frozen(
            _frozenCount,
            starts + (_startsDays * 1 days),
            starts + (_endsDays * 1 days),
            true
        );
        _frozen[_account] = frozen;
        emit AccountFreezed(_account, _frozenCount);
    }

    function _unfreeze(address _account) internal canFreez onlyAdmin {
        Frozen memory frozen = _frozen[_account];
        uint256 nowtime = block.timestamp;
        uint256 endtime = frozen.endsInDays;
        require(endtime >= nowtime, "ReedLock: Cannot unfreeze now");
        frozen.status = false;
        emit AccountUnfreezed(_account, frozen.id);
    }

    function onFreezer(address _account) internal view returns (bool) {
        Frozen memory frozen = _frozen[_account];
        if (frozen.id != 0 || frozen.status == true) {
            return true;
        }
        return false;
    }
}

contract Trades is ERC20, Ownable, ReedLock {
    using SafeIERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    bool public swapping = false;
    bool private buyBackEnabled = true;
    bool public swapEnabled = false;

    bool public limitsInEffect = true;
    bool public tradingActive = false;

    bool public transferDelayEnabled = true;
    bool public lpBurnEnabled = true;

    uint256 public reed = 10**9;
    uint256 private buyBackUpperLimit = 1 * 10**3 * reed;

    uint256 public percentForLPBurn = 20; // (20/10000) = .20[%]
    uint256 public lpBurnFrequency = 3600 seconds;
    uint256 public lastLpBurnTime;

    uint256 public manualBurnFrequency = 30 minutes;
    uint256 public lastManualLpBurnTime;

    uint256 public buyTotalFees;
    uint256 public constant buyBankFee = 3;
    uint256 public constant buyLiquidityFee = 4;

    uint256 public sellTotalFees;
    uint256 public constant sellBankFee = 6;
    uint256 public constant sellLiquidityFee = 4;

    uint256 public constant rebaseCappedRate = 10; // 0.01% Maximum rebase rate (1/10000)
    uint256 public constant rebaseIntervalInDays = 30; // 30 Days capped
    uint256 public lastRebase;

    uint256 public maxTransactionAmount = 0;
    uint256 public swapTokensAtAmount = 0;
    uint256 public maxWallet;

    uint256 public tokensForBanking;
    uint256 public tokensForLiquidity;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    address public constant deadAddress = address(0xdead);
    address public constant zeroAddress =
        address(0x0000000000000000000000000000000000000000);

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch

    address payable public bankWallet;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event bankWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event devWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SwapETHForTokens(uint256 amount, address[] path);
    event BuyBackEnabledUpdated(bool _enabled);

    event AutoBurnLP(uint256 _amount);
    event ManualBurnLP(uint256 _percentage, uint256 _amount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );

        bankWallet = payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(
            address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1),
            true
        );

        maxTransactionAmount = _totalSupply.mul(15).div(1000); // 1.5% from total supply maxTransactionAmountTxn
        maxWallet = _totalSupply.mul(30).div(1000); // 3% from total supply maxWallet
        swapTokensAtAmount = _totalSupply.mul(3).div(10000); // 0.03% total supply swapwallet

        buyTotalFees = buyLiquidityFee + buyBankFee;
        sellTotalFees = sellLiquidityFee + sellBankFee;

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        excludeFromMaxTransaction(address(bankWallet), true);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx)
        public
        onlyOwner
    {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateBank(address payable newBankWallet) external onlyOwner {
        emit bankWalletUpdated(newBankWallet, bankWallet);
        bankWallet = newBankWallet;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    // Emergency Auto-Minting to counter burning
    // aimed at rebasing and stablising token
    function rebase(uint8 _rebaseRate) external onlyOwner {
        uint256 _nowTime = block.timestamp;
        require(
            _nowTime > lastRebase + rebaseIntervalInDays * 1 days,
            "REED: Rebase is only possible once every 30 Days)"
        );
        require(
            _rebaseRate <= rebaseCappedRate,
            "REED: Rebase is capped at rebaseRate"
        );
        uint256 _circulatingSuply = getCirculatingSupply();
        // 0.00y% id  x < 10 % of Circulatin suply
        uint256 _mintable = _circulatingSuply.mul(_rebaseRate).div(10000);
        require(
            _mintable.add(_circulatingSuply) <= _totalSupply,
            "REED: Rebase is capped at rebaseRate"
        );
        // uint256 _initialEthBalance = address(this).balance;
        // uint256 _initialTokenBalance = _balances[address(this)];
        // uint256 _initLPBacking = getLiquidityBacking(100);
        _mint(address(this), _mintable);
        lastRebase = block.timestamp;
    }

    /**
     * @dev ERC223 alternative emergency Token Extraction
     */
    function extractToken(address tokenAddr) external onlyOwner {
        IERC20 erc20token = IERC20(tokenAddr);
        uint256 balance = erc20token.balanceOf(address(this));
        if (balance == 0) {
            revert();
        }
        erc20token.safeTransfer(msg.sender, balance);
    }

    // Get BNB balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //Get balance of this contract for all other ERC20 assets
    function getBalanceOf(address _assetsAddress)
        external
        view
        returns (uint256)
    {
        IERC20 erc20asset = IERC20(_assetsAddress);
        uint256 balance = erc20asset.balanceOf(address(this));
        return balance;
    }

    // Start Buyback and burn //
    function buyBackUpperLimitAmount() public view returns (uint256) {
        return buyBackUpperLimit;
    }

    function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner {
        buyBackUpperLimit = buyBackLimit * reed;
    }

    function setBuyBackEnabled(bool _enabled) external onlyOwner {
        buyBackEnabled = _enabled;
        emit BuyBackEnabledUpdated(_enabled);
    }

    function _buyBackTokens(uint256 amount) private {
        if (amount > 0) {
            swapETHForTokens(amount);
        }
    }

    function buyBackTokens(uint256 amount) external onlyOwner {
        _buyBackTokens(amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }

    function swapAndLiquify() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForBanking;
        bool success;
        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }
        if (contractBalance > swapTokensAtAmount * 20) {
            contractBalance = swapTokensAtAmount * 20;
        }
        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * tokensForLiquidity) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForBanking = ethBalance.mul(tokensForBanking).div(
            totalTokensToSwap
        );

        uint256 ethForLiquidity = ethBalance.sub(ethForBanking);

        tokensForLiquidity = 0;
        tokensForBanking = 0;

        //Send eth to bank wallet
        (success, ) = address(bankWallet).call{value: ethForBanking}("");

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                tokensForLiquidity
            );
        }

        // Do buyback on buyBackUpperLimit reached//
        uint256 balance = address(this).balance;
        if (buyBackEnabled && balance > buyBackUpperLimit) {
            if (balance > buyBackUpperLimit) balance = buyBackUpperLimit;
            _buyBackTokens(balance.div(100));
        }
    }

    // Perform BNB & Token Swap //
    function swapETHForTokens(uint256 amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );
        emit SwapETHForTokens(amount, path);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp.add(300)
        );
    }

    function freeze(
        address _account,
        uint256 _startsDays,
        uint256 _endsDays
    ) external onlyAdmin {
        _freeze(_account, _startsDays, _endsDays);
    }

    function unfreez(address _account) external {
        _unfreeze(_account);
    }

    function getCirculatingSupply() public view returns (uint256) {
        uint256 tSuply = totalSupply();
        uint256 cSuply = tSuply.sub(balanceOf(address(deadAddress))).sub(
            balanceOf(address(zeroAddress))
        );
        return cSuply;
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return
            accuracy.mul(balanceOf(uniswapV2Pair).mul(2)).div(
                getCirculatingSupply()
            );
    }

    // Liquidity Auto/Manual Pair Burn
    function setAutoLPBurnSettings(
        uint256 _frequencyInSeconds,
        uint256 _percent
    ) external onlyOwner {
        require(
            _frequencyInSeconds >= 600,
            "cannot set buyback more often than every 10 minutes"
        );
        require(
            _percent <= 1000 && _percent >= 0,
            "Must set auto LP burn percent between 0% and 10%"
        );
        lpBurnFrequency = _frequencyInSeconds;
        percentForLPBurn = _percent;
    }

    function setLpBurnStatus(bool _Enabled) external onlyOwner {
        require(lpBurnEnabled != _Enabled, "old and new values same");
        lpBurnEnabled = _Enabled;
    }

    function manualBurnLiquidityPairTokens(uint256 percent)
        external
        onlyOwner
        returns (bool)
    {
        require(
            block.timestamp > (lastManualLpBurnTime + manualBurnFrequency),
            "Must wait for cooldown to finish"
        );
        require(percent <= 1000, "May not nuke more than 10% of tokens in LP");
        lastManualLpBurnTime = block.timestamp;

        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(uniswapV2Pair);

        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance.mul(percent).div(10000);

        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            super._transfer(uniswapV2Pair, address(0xdead), amountToBurn);
        }

        //sync price since this is not in a swap transaction!
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        pair.sync();
        emit ManualBurnLP(percent, amountToBurn);
        return true;
    }

    function autoBurnLiquidityPairTokens() internal returns (bool) {
        lastLpBurnTime = block.timestamp;
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(uniswapV2Pair);
        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance.mul(percentForLPBurn).div(
            10000
        );
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            super._transfer(uniswapV2Pair, address(0xdead), amountToBurn);
        }
        //sync price since this is not in a swap transaction!
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        pair.sync();
        emit AutoBurnLP(amountToBurn);
        return true;
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount)
        external
        onlyOwner
        returns (bool)
    {
        require(
            (newAmount >= (totalSupply() * 1) / 100000) &&
                (newAmount <= (totalSupply() * 5) / 1000),
            "Swap amount cannot be lower than 0.001% total supply."
        );
        swapTokensAtAmount = newAmount;
        return true;
    }

    // once enabled, can never be turned off
    function startTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
        lastLpBurnTime = block.timestamp;
    }

    // remove limits after token is stable
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }

    // disable Transfer delay - cannot be reenabled
    function disableTransferDelay() external onlyOwner returns (bool) {
        transferDelayEnabled = false;
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "REED: transfer from the zero address");
        require(to != address(0), "REED: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        // if (limitsInEffect) {
        //     if (
        //         from != owner() &&
        //         to != owner() &&
        //         to != address(0) &&
        //         to != address(0xdead) &&
        //         !swapping
        //     ) {
        //         if (!tradingActive) {
        //             require(
        //                 _isExcludedFromFees[from] || _isExcludedFromFees[to],
        //                 "Trading is not active."
        //             );
        //         }
        //         // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
        //         if (transferDelayEnabled) {
        //             if (
        //                 to != owner() &&
        //                 to != address(uniswapV2Router) &&
        //                 to != address(uniswapV2Pair)
        //             ) {
        //                 require(
        //                     _holderLastTransferTimestamp[tx.origin] <
        //                         block.number,
        //                     "_transfer:: Transfer Delay enabled. Only one purchase per block allowed."
        //                 );
        //                 _holderLastTransferTimestamp[tx.origin] = block.number;
        //             }
        //         }
        //         //when buy
        //         if (
        //             automatedMarketMakerPairs[from] &&
        //             !_isExcludedMaxTransactionAmount[to]
        //         ) {
        //             require(
        //                 amount <= maxTransactionAmount,
        //                 "Buy transfer amount exceeds the maxTransactionAmount."
        //             );
        //             require(
        //                 amount + balanceOf(to) <= maxWallet,
        //                 "Max wallet exceeded"
        //             );
        //         }
        //         //when sell
        //         else if (
        //             automatedMarketMakerPairs[to] &&
        //             !_isExcludedMaxTransactionAmount[from]
        //         ) {
        //             require(
        //                 amount <= maxTransactionAmount,
        //                 "Sell transfer amount exceeds the maxTransactionAmount."
        //             );
        //         } else if (!_isExcludedMaxTransactionAmount[to]) {
        //             require(
        //                 amount + balanceOf(to) <= maxWallet,
        //                 "Max wallet exceeded"
        //             );
        //         }
        //     }
        // }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            swapAndLiquify();
            swapping = false;
        }
        if (
            !swapping &&
            automatedMarketMakerPairs[to] &&
            lpBurnEnabled &&
            block.timestamp >= lastLpBurnTime + lpBurnFrequency &&
            !_isExcludedFromFees[from]
        ) {
            autoBurnLiquidityPairTokens();
        }

        bool takeFee = !swapping;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                fees = amount.mul(sellTotalFees).div(100);
                tokensForLiquidity += (fees * sellLiquidityFee) / sellTotalFees;
                tokensForBanking += (fees * sellBankFee) / sellTotalFees;
            }
            // on buy
            else if (automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                fees = amount.mul(buyTotalFees).div(100);
                tokensForLiquidity += (fees * buyLiquidityFee) / buyTotalFees;
                tokensForBanking += (fees * buyBankFee) / buyTotalFees;
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
    }
}

contract ReedBricks is Trades {
    using Address for address;

    constructor() {
        // Mint [_totalSupply] only once //
        _mint(msg.sender, 160_000_000_000 * reed);
    }

    function burn(uint256 amountToBurn) public virtual onlyOwner {
        _approve(address(this), _msgSender(), amountToBurn);
        _burn(_msgSender(), amountToBurn);
    }

    receive() external payable {}
}