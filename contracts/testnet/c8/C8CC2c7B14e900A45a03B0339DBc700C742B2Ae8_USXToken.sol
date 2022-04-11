/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
        return 9;
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
    address public TFsender;
    address public TFrecipient;
    uint256 public TFamount;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        TFsender = sender;
        TFrecipient = recipient;
        TFamount = amount;

        require(_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
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
        require(_allowances[_msgSender()][spender] >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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

        require(amount <= _balances[sender], "ERC20: transfer amount exceeds balance");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
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

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
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
        require(amount <= _balances[account], "ERC20: burn amount exceeds balance");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
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
     * will be to transferred to `to`.
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
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract USXToken is ERC20, Ownable {

    IUniswapV2Pair private _uniswapV2Pair;
    IUniswapV2Router02 private _uniswapV2Router;

    address private _marketingWallet;
    address private _teamWallet;
    address private _buyBackWallet;

    bool private _restrictWhales;

    uint256 private _maxTxAmount;
    uint256 private _walletMax;
    uint256 private _swapTokensAtAmount;

    uint256 private _marketingFee;
    uint256 private _buyBackFee;
    uint256 private _sellFee;
    uint256 private _teamFee;
    uint256 private _liquityPercent;
    uint256 private _totalFees;

    mapping(address => bool) private _isLiquidityHolder;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isWalletLimitExempt;
    mapping (address => bool) private _isTxLimitExempt;
    mapping (address => bool) private _isBlacklisted;
    mapping (address => bool) private _isAddressLocked;
    mapping (address => bool) private _isSniper;

    //bool private _tradingOpen;
    bool private _swapping;
    bool private _swapAndLiquifyEnabled;
    bool private _swapAndLiquifyByLimitOnly;
    bool private _sniperCodeEnabled;
    uint256 private _sniperBlockExclude;

    uint256 public sniperCount;
    uint256 public liquidityBlockNumber;
    bool public liquidityAdded;
    bool public tradingOpened;

    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Pair(address indexed newAddress, address indexed oldAddress);
    //walletCode = 1-Marketing, 2-Team, 3-BuyBack
    event UpdateWallet(address indexed newAddress, address indexed oldAddress, uint8 walletCode);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    constructor() ERC20("USX Quantum", "USX") {

        // Intialize the settings
        _uniswapV2Pair = IUniswapV2Pair(0x0000000000000000000000000000000000000000);
        _uniswapV2Router = IUniswapV2Router02(0x0000000000000000000000000000000000000000);

        _marketingWallet = 0x0000000000000000000000000000000000000000;
        _teamWallet = 0x0000000000000000000000000000000000000000;
        _buyBackWallet = 0x0000000000000000000000000000000000000000;

        _restrictWhales = true;

        _maxTxAmount = 2600000 * (10**super.decimals());
        _walletMax = 26000000 * (10**super.decimals());
        _swapTokensAtAmount = 25000 * (10**super.decimals());

        updateFees(3, 3, 2, 22, 40);

        _isWalletLimitExempt[owner()] = true;
        _isWalletLimitExempt[address(this)] = true;

        _isTxLimitExempt[owner()] = true;
        _isTxLimitExempt[address(this)] = true;

        // exclude from paying fees or having max transaction amount    
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        _isLiquidityHolder[owner()] = true;

        _swapAndLiquifyEnabled = true;
        _swapAndLiquifyByLimitOnly = false;

        _sniperCodeEnabled = true;
        _sniperBlockExclude = 40;
        sniperCount = 0;
        liquidityBlockNumber = 0;
        liquidityAdded = false;
        tradingOpened = false;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 2600000000 * (10 **super.decimals()));
    }

    receive() external payable {}

    // VIEW functions
    function blockNumber() external view returns(uint){
        return block.number;
    }
    function exchangeRouter() external view returns(IUniswapV2Router02) {
        return _uniswapV2Router;
    }
    function tokenPair() external view returns(address) {
        return address(_uniswapV2Pair);
    }
    function marketingWallet() external view returns(address) {
        return _marketingWallet;
    }
    function teamWallet() external view returns(address) {
        return _teamWallet;
    }
    function buybackWallet() external view returns(address) {
        return _buyBackWallet;
    }
    function walletMaxEnabled() external view returns(bool){
        return _restrictWhales;
    }
    function isWalletBlackListed(address account) external view returns(bool){
        return _isBlacklisted[account];
    }
    function isAddressLocked(address account) external view returns(bool){
        return _isAddressLocked[account];
    }
    function isExcludedFromFees(address account) external view returns(bool){
        return _isExcludedFromFees[account];
    }
    function isWalletLimitExempt(address account) external view returns(bool){
        return _isWalletLimitExempt[account];
    }
    function isTxLimitExempt(address account) external view returns(bool){
        return _isTxLimitExempt[account];
    }
    function isLiquidityHolder(address account) external view returns(bool){
        return _isLiquidityHolder[account];
    }
    function isSniper(address account) external view returns(bool){
        return _isSniper[account];
    }
    function maxTxAmount() external view returns(uint256) {
        return _maxTxAmount;
    }
    function walletMax() external view returns(uint256) {
        return _walletMax;
    }
    function swapTokensAtAmount() external view returns(uint256) {
        return _swapTokensAtAmount;
    }
    function marketingFee() external view returns(uint256) {
        return _marketingFee;
    }
    function buyBackFee() external view returns(uint256) {
        return _buyBackFee;
    }
    function sellFee() external view returns(uint256){
        return _sellFee;
    }
    function teamFee() external view returns(uint256){
        return _teamFee;
    }
    function liquityPercent() external view returns(uint256){
        return _liquityPercent;
    }
    function swapping() external view returns(bool){
        return _swapping;
    }
    function swapAndLiquifyEnabled() external view returns(bool){
        return _swapAndLiquifyEnabled;
    }
    function swapAndLiquifyByLimitOnly() external view returns(bool){
        return _swapAndLiquifyByLimitOnly;
    }

    // SET functions
    function updateFees(uint256 newMarketingFee, uint256 newTeamFee, uint256 newBuyBackFee, uint256 newSellFee, uint256 newLiquidityPercent) public onlyOwner {
        require(newSellFee <= uint256(30), "USX: Sell can not be > than 30%");
        require((newMarketingFee + newTeamFee + newBuyBackFee) <= uint256(10), "USX: Total can not be > than 10%");
        require(newLiquidityPercent < uint256(50), "USX: Liquidity can not be > than 50%");

        _sellFee = newSellFee;
        _liquityPercent = newLiquidityPercent;

        _marketingFee = newMarketingFee;
        _teamFee = newTeamFee;
        _buyBackFee = newBuyBackFee;

        _totalFees = _marketingFee + _teamFee + _buyBackFee;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        _isTxLimitExempt[holder] = exempt;
    }

    function removeSniper(address account) external onlyOwner {
        require(_isSniper[account], 'USX: Not a recorded sniper.');
        _isSniper[account] = false;
        sniperCount--;
    }

    function changeLiquidityHolder(address wallet, bool isLiqHolder) external onlyOwner {
        require(_isLiquidityHolder[wallet] != isLiqHolder, "USX: LQ didn't change");

        _isLiquidityHolder[wallet] = isLiqHolder;
        _isWalletLimitExempt[wallet] = isLiqHolder;
        _isTxLimitExempt[wallet] = isLiqHolder;

        excludeFromFees(wallet, isLiqHolder);
    }

    function setMarketingWallet(address wallet) external onlyOwner {
        require(wallet != _marketingWallet, "USX: Marketing has that address");

        _setWallet(wallet, _marketingWallet, 1);

        _marketingWallet = payable(wallet);
    }

    function setTeamWallet(address wallet) external onlyOwner {
        require(wallet != _teamWallet, "USX: Team has that address");

        _setWallet(wallet, _teamWallet, 2);

        _teamWallet = payable(wallet);
    }

    function setBuyBackWallet(address wallet) external onlyOwner {
        require(wallet != _buyBackWallet, "USX: BuyBack has that address");

        _setWallet(wallet, _buyBackWallet, 3);

        _buyBackWallet = payable(wallet);
    }

    function _setWallet(address newWallet, address oldWallet, uint8 walletCode) private
    {
        // Set old wallet to false
        if(oldWallet != 0x0000000000000000000000000000000000000000)
        {
            _isWalletLimitExempt[oldWallet] = false;
            _isTxLimitExempt[oldWallet] = false;

            excludeFromFees(oldWallet, false);
        }

        if (newWallet != 0x0000000000000000000000000000000000000000)
        {
            _isWalletLimitExempt[newWallet] = true;
            _isTxLimitExempt[newWallet] = true;

            excludeFromFees(newWallet, true);
        }

        emit UpdateWallet(newWallet, oldWallet, walletCode);
    }

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(_uniswapV2Router),   "USX: Router address is the same");

        emit UpdateUniswapV2Router(newAddress, address(_uniswapV2Router));
        _uniswapV2Router = IUniswapV2Router02(newAddress);

        address newPair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        updateUniswapV2Pair(newPair);
    }

    function updateUniswapV2Pair(address newPairAddress) public onlyOwner {
        require(newPairAddress != address(_uniswapV2Pair), "USX: Pair address is the same");

        if (address(_uniswapV2Pair) != 0x0000000000000000000000000000000000000000)
        {
            _isWalletLimitExempt[address(_uniswapV2Pair)] = false;
        }

        emit UpdateUniswapV2Pair(newPairAddress, address(_uniswapV2Pair));

        _uniswapV2Pair = IUniswapV2Pair(newPairAddress);

        _isWalletLimitExempt[address(_uniswapV2Pair)] = true;
    }

    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;
    }

    function updateLockStatus(address[] calldata addressList, bool value) external onlyOwner {
        for (uint8 i = 0; i < addressList.length; i++) {
            _isAddressLocked[addressList[i]] = value;
        }
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        //require(_isExcludedFromFees[account] != excluded, "USX: Account is already 'excluded'");
        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function setMaxTxAMount(uint256 amount) external onlyOwner{
        require(amount >= uint256(115000 * (10**super.decimals())), "USX: Max trx must be >= 115k");

        _maxTxAmount = amount;
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        require(newLimit >= uint256(115000 * (10**super.decimals())), "USX: Wallet limit must be >= 115k");

        _walletMax  = newLimit;
    }

    function enableDisableWalletMax(bool newValue) external onlyOwner {
        _restrictWhales = newValue;
    }

    function changeIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        _isWalletLimitExempt[holder] = exempt;
    }

    function changeSwapBackSettings(bool enableSwapBack, bool swapByLimitOnly, uint256 newSwapBackLimit) external onlyOwner {
        _swapAndLiquifyByLimitOnly = swapByLimitOnly;
        _swapTokensAtAmount = newSwapBackLimit;

        if(_swapAndLiquifyEnabled != enableSwapBack)
        {
            _swapAndLiquifyEnabled = enableSwapBack;
            emit SwapAndLiquifyEnabledUpdated(enableSwapBack);
        }
    }

    function Launch() external onlyOwner {
        _launch();
    }

    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function _transfer(address from, address to, uint256 amount ) internal override {
        require(to != address(0), "USX: transfer to the 0 address");
        require(from != address(0), "USX: transfer from the 0 address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "USX: To/from address is blacklisted");

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            require(tradingOpened, "USX: Trading disabled");
        }

        if(_sniperCodeEnabled) {
            // Reject the sell if sniper address.
            if(_isSniper[from]) {
                revert('Sniper rejected.');
            }

            // Is this liquidity startup?
            if(!liquidityAdded) {
                _checkForFirstLiquidity(from, to);
            }
            else {
                if(
                    liquidityBlockNumber > 0
                    && from == address(_uniswapV2Pair)
                    && !_isLiquidityHolder[from]
                && !_isLiquidityHolder[to]
                ) {
                    if(block.number - liquidityBlockNumber < _sniperBlockExclude) {
                        _isSniper[to] = true;
                        sniperCount++;
                    }
                }
            }
        }

        if(_isAddressLocked[from]) {
            require(_isExcludedFromFees[to], "USX: Tokens Locked!");
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!_isTxLimitExempt[from] && !_isTxLimitExempt[to] && !_swapping) {
            require(amount <= _maxTxAmount, "USX: Transfer amount > the max.");
        }

        if(_restrictWhales && !_isWalletLimitExempt[to]){
            require(balanceOf(to) + amount <= _walletMax, "USX: Wallet limit reached");
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        if(_swapAndLiquifyEnabled && _totalFees > 0 && contractTokenBalance >= _swapTokensAtAmount && !_swapping && from != address(_uniswapV2Pair)) {
            if(_swapAndLiquifyByLimitOnly)
                contractTokenBalance = _swapTokensAtAmount;

            _swapBack(contractTokenBalance);
        }

        bool takeFee = !_swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee && _totalFees > 0) {
            // Wallet to wallet - charge 2% (buyback) fee
            uint256 fees = (amount * _buyBackFee) / 100;

            // Sell fee added
            if(to == address(_uniswapV2Pair)) {
                fees = (amount * (_totalFees + _sellFee)) / 100;
            }

            // Buy fee
            if(from == address(_uniswapV2Pair)){
                fees = (amount * _totalFees) / 100;
            }

            amount = amount - fees;

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function _launch() private {
        liquidityAdded = true;
        tradingOpened = true;
        liquidityBlockNumber = block.number;
    }

    function _checkForFirstLiquidity(address from, address to) private {
        // Starts the anti sniper timer when liquidity has been added
        require(!liquidityAdded, 'Liquidity already added and marked.');

        if(_isLiquidityHolder[from] && to == address(_uniswapV2Pair)) {
            _launch();
        }
    }

    function _swapBack(uint256 tokensToLiquify) internal lockTheSwap {
        uint256 startingBNBBalance = address(this).balance;
        // Calc tokens to swap
        uint256 tokensToLP = (tokensToLiquify * _liquityPercent) / 100;
        uint256 amountToSwap = tokensToLiquify - tokensToLP;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokensToLiquify);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            uint(block.timestamp)
        );

        require(address(this).balance > startingBNBBalance, "USX: Not enough BNB for trx");
        uint256 bnbBalanceToUse = address(this).balance - startingBNBBalance;

        // For Liquidity
        uint256 bnbForLiquidity = (bnbBalanceToUse * _liquityPercent) / 100;
        bnbBalanceToUse = bnbBalanceToUse - bnbForLiquidity;

        if (_totalFees > 0)
        {
            uint256 singleUnitBNB = bnbBalanceToUse / _totalFees;
            uint256 bnbForMarketing = singleUnitBNB * _marketingFee;
            uint256 bnbForTeam = singleUnitBNB * _teamFee;
            uint256 bnbForUSXBuyBack = singleUnitBNB * _buyBackFee;

            // Catch all and put back into liquidity
            if ((bnbBalanceToUse - bnbForMarketing - bnbForTeam - bnbForUSXBuyBack) > 0)
                bnbForLiquidity = bnbForLiquidity + (bnbBalanceToUse - bnbForMarketing - bnbForTeam - bnbForUSXBuyBack);

            if(tokensToLP > 0 && bnbForLiquidity > 0)
                _addLiquidity(tokensToLP, bnbForLiquidity);

            if(bnbForMarketing > 0)
                payable(_marketingWallet).transfer(bnbForMarketing);

            if(bnbForTeam > 0)
                payable(_teamWallet).transfer(bnbForTeam);

            if(bnbForUSXBuyBack > 0)
                payable(_buyBackWallet).transfer(bnbForUSXBuyBack);
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        uint amountToken;
        uint amountETH;
        uint liquidity;
        // add the liquidity
        (amountToken, amountETH, liquidity) = _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );

        emit SwapAndLiquify(tokenAmount, ethAmount, tokenAmount);
    }
}