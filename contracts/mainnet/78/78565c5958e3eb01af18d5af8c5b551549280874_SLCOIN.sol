/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
        //console.log("  final: %s => %s : %d; balance: %d ", sender, recipient, amount);
        _beforeTokenTransfer(sender, recipient, amount);
        //console.log("_beforeTokenTransfer done");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        //console.log("sub done");
        _balances[recipient] = _balances[recipient].add(amount);
        //console.log("add done");
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

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
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

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
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

interface IWrapperSwap{
    function swapAndDistribute(address to,uint256 amount) external;
}
contract LpWrapperSwap is IWrapperSwap{

    receive() external payable {}

    function swapAndDistribute(address to, uint256 amount) override external {
        //console.log("swapAndDistribute %d ", address(this).balance);
        payable(to).transfer(amount);
        //console.log("swapAndDistribute %d  successfully ", address(this).balance);
    }
}
contract SLCOIN is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapPair;

    bool private swapping = false;


    uint256 public buyLiquidityFee = 2;
    uint256 public sellLiquidityFee = 2;

    uint256 public buyMarketingFee1 = 2;
    uint256 public buyMarketingFee2 = 1;
    uint256 public sellMarketingFee1 = 2;
    uint256 public sellMarketingFee2 = 1;

    uint256 public buyDeadFee = 1;
    uint256 public sellDeadFee = 1;

    uint256 public rewardLPFee = 2;

    uint256 public rewardLevel1 = 5;
    uint256 public rewardLevel2 = 2;

    // uint256 public AmountLiquidityFee;
    // uint256 public AmountMarketingFee;
    // uint256 public amountLPRewardFee;

    uint256 public feeAmount;
    uint256 public minDistributeAmount = 10 * (10 ** 18);


    uint256 public minSupply;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    // dev
    // address public fistAddress= 0xcEeECf9d1E188C83B1e472df05Ad05b921164d9D;
    // address public routerAddress = 0xc71FE35aa0d27aD77D4e4Fc5534a787B31b9D444;
    // address public marketingWalletAddress1 = 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199;
    // address public marketingWalletAddress2 = 0xdD2FD4581271e230360230F9337D5c0430Bf44C0;


    // pro    test  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3  pro  0x10ED43C718714eb63d5aA57B78B54704E256024E
    // address public fistAddress= 0x55d398326f99059fF775485246999027B3197955;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public marketingWalletAddress1 = 0x839780132B820828561420280148e6632F5f5888;
    address public marketingWalletAddress2 = 0x3a23cfc360d1Ed5CFfCD6a85823861390F997A27;

    mapping (address => uint256) public lpholders;
    mapping (address => address) public invitorMap;
    address[] public holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    mapping(address => bool) public _isBlacklisted;


     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
    IWrapperSwap public swapUtil;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    constructor() ERC20("SL TOKEN", "SL")  {
    

        uint256 totalSupply = 1000000 * (10**18);
        minSupply = 10000 * 10 ** 18;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(_uniswapV2Router.WETH(), address(this));

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //     .createPair(address(this), _uniswapV2Router.WETH());
        // fistAddress = _uniswapV2Router.WETH();

        uniswapV2Router = _uniswapV2Router;
        uniswapPair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        swapUtil = new LpWrapperSwap();

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress1, true);
        excludeFromFees(marketingWalletAddress2, true);
        excludeFromFees(address(this), true);
        excludeHolder[address(0)] = true;
        excludeHolder[address(deadWallet)] = true;

        _mint(owner(), totalSupply);

    }

    receive() external payable {}



    function multipleBotlistAddress(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = excluded;
        }
    }


    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair( uniswapV2Router.WETH(), address(this));
        uniswapPair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(uniswapPair, true);
        
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }


    function setMarketingWallet(address payable wallet1, address payable wallet2) external onlyOwner{
        marketingWalletAddress1 = wallet1;
        marketingWalletAddress2 = wallet2;
        excludeFromFees(marketingWalletAddress1, true);
        excludeFromFees(marketingWalletAddress2, true);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapPair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setDeadWallet(address addr) public onlyOwner {
        deadWallet = addr;
    }

    function setMinDistributeAmount(uint256 _minDistributeAmount) external onlyOwner {
        minDistributeAmount = _minDistributeAmount;
    }
    
    function setBuyTaxes(uint256 liquidity, uint256 marketingFee1,  uint256 marketingFee2, uint256 deadFee) external onlyOwner {
        buyLiquidityFee = liquidity;
        buyMarketingFee1 = marketingFee1;
        buyMarketingFee2 = marketingFee2;
        buyDeadFee = deadFee;
    }

    function setSelTaxes(uint256 liquidity, uint256 marketingFee1,  uint256 marketingFee2, uint256 deadFee) external onlyOwner {
        sellLiquidityFee = liquidity;
        sellMarketingFee1 = marketingFee1;
        sellMarketingFee2 = marketingFee2;
        sellDeadFee = deadFee;
    }

    uint public addPriceTokenAmount = 1e3;

    function _isLiquidity(address from,address to)internal view returns(bool isAdd,bool isDel){

        address token0 = IUniswapV2Pair(address(uniswapPair)).token0(); 
        address token1 = IUniswapV2Pair(address(uniswapPair)).token1();
        //console.log("_isLiquidity ? token0 : %s - token1 : %s", token0, token1);
        (uint r0,uint r1,) = IUniswapV2Pair(address(uniswapPair)).getReserves();
        uint bal1 = IERC20(token1).balanceOf(address(uniswapPair));
        uint bal0 = IERC20(token0).balanceOf(address(uniswapPair));
        if( automatedMarketMakerPairs[to] ){
           
            if( token0 == address(this) ){
                
                if( bal1 > r1){
                    uint change1 = bal1 - r1;
                    isAdd = change1 > addPriceTokenAmount;
                }
            }else{
                if( bal0 > r0){
                    uint change0 = bal0 - r0;
                    isAdd = change0 > addPriceTokenAmount;
                }
            }
        }

        if( automatedMarketMakerPairs[from] ){
            if( token0 == address(this) ){
                if( bal1 < r1 && r1 > 0){
                    uint change1 = r1 - bal1;
                    isDel = change1 > 0;
                }
            }else{
                if( bal0 < r0 && r0 > 0){
                    uint change0 = r0 - bal0;
                    isDel = change0 > 0;
                }
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        //console.log("start _transfer from %s to %s, amount is %d", from, to, amount);

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && !isContract(from) && !isContract(to)){
            // transfer 
            // mark the invite tree
            if (invitorMap[to] == address(0)) {
                invitorMap[to] = from;
                //console.log("Bind invite address %s => and %s ", from, to);
            }
        }

        bool takeFee = true;
        
        // swap MFee to BNB    && automatedMarketMakerPairs[to] 
        if (!swapping
            && !automatedMarketMakerPairs[from]
            && from != address(routerAddress)
            && from != owner() 
            && to != owner()) {
            
            swapping = true;
            if (feeAmount >= minDistributeAmount) {
                swapAndDistribute(feeAmount);

                // if (address(swapUtil).balance >= 1 * (10 ** 18)) {
                    processLPReward();
                // }
            }        
            swapping = false;
        }

        takeFee = !swapping;


        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);

        if (isAddLiquidity) {
            //console.log("Add liquidity transaction !!!");
            takeFee = false;
        }
        if(automatedMarketMakerPairs[to] && !isContract(from)){
            addHolder(from);
        }



        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        if (from == address(uniswapPair) && to == address(routerAddress)) {
            takeFee = false;
            //console.log(" bridge transfer fee is zero ");
        }
        if (from == address(routerAddress) &&  !isContract(to)) {
            if(_isExcludedFromFees[to]) {
                takeFee = false;
            }
            //console.log(" bridge transfer fee part 2  takeFee %s ", takeFee);
        }

        
        
        //console.log("takeFee: ", takeFee);
        if(takeFee) {

            uint256 fees;
            uint256 DFee; // Dead
            uint256 MFee; // MFee
            if(automatedMarketMakerPairs[from] || from == address(routerAddress)){
                // buy 
                MFee =  amount.mul(buyLiquidityFee.add(buyMarketingFee1).add(buyMarketingFee2).add(rewardLPFee)).div(100);
                DFee = amount.mul(buyDeadFee).div(100);
                fees = MFee.add(DFee);
            }
            if(automatedMarketMakerPairs[to]){
                // sell
                MFee =  amount.mul(sellLiquidityFee.add(sellMarketingFee1).add(sellMarketingFee2).add(rewardLPFee)).div(100);
                DFee = amount.mul(sellDeadFee).div(100);
                fees = MFee.add(DFee);
            }
            if(!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && !isContract(from) && !isContract(to)){
                // transfer 
                MFee = 0;
                DFee = 0;
                fees = 0;
            }

            amount = swap2invite(from, to, amount);

            if (fees > 0) {
                amount = amount.sub(fees);
            }

            //console.log("left amount : %d ", amount);
            if (MFee > 0) {
                feeAmount = MFee.add(feeAmount);
                super._transfer(from, address(this), MFee);
                //console.log("MFee: %d => %s ", MFee, address(this));
            }
            uint256 circulate = totalSupply() - balanceOf(deadWallet);
            if (DFee > 0 && circulate > minSupply) {
                //console.log(" can burn ! ");
                if ((circulate - DFee) > minSupply) {
                    super._transfer(from, deadWallet, DFee);
                    //console.log("burn %d ", DFee);
                } else {
                    //console.log(" can burn part ! ");
                    super._transfer(from, deadWallet,  circulate - minSupply);
                     //console.log("burn %d ", circulate - minSupply);
                    amount += (DFee + minSupply - circulate);
                    if (sellDeadFee != 0 || buyDeadFee != 0) {
                        sellDeadFee = 0;
                        buyDeadFee = 0;
                    }
                }
            } else {
                if (DFee > 0) {
                    amount = amount.add(DFee);
                }
                
                if (circulate <= minSupply && (sellDeadFee != 0 || buyDeadFee != 0)) {
                    sellDeadFee = 0;
                    buyDeadFee = 0;
                }
            }

        } else {
            if(automatedMarketMakerPairs[to] && from != address(this)){
                addHolder(from);
            }
        }
        //console.log("now transfer %s => %s : the %d ", from, to, amount);
        //console.log("now transfer balance %d ", balanceOf(from));
        super._transfer(from, to, amount);
        //console.log("now transfers successfully  "); 
        
    }


    function swap2invite(address from, address to, uint256 amount) private returns(uint256) {

        uint256 rewardL1Fee;
        uint256 rewardL2Fee;
        uint256 fees;
        // to level1
        address l1;
        address l2;
        if(automatedMarketMakerPairs[from] || from == address(routerAddress)){
            // buy 
            rewardL1Fee = amount.mul(rewardLevel1).div(100);
            rewardL2Fee = amount.mul(rewardLevel2).div(100);
            fees = rewardL1Fee.add(rewardL2Fee);
            l1 = invitorMap[to];
            if (l1 == address(0)) {
                l1 = marketingWalletAddress1;
            } 
        }
    
        if(automatedMarketMakerPairs[to]){
            // sell
            rewardL1Fee = amount.mul(rewardLevel1).div(100);
            rewardL2Fee = amount.mul(rewardLevel2).div(100);
            fees = rewardL1Fee.add(rewardL2Fee);
             l1 = invitorMap[from];
            if (l1 == address(0)) {
                l1 = marketingWalletAddress1;
            }
        }
        if (fees > 0) {
            amount = amount.sub(fees);
        }
        
        if (rewardL1Fee > 0 && l1 != address(0)) {
            super._transfer(from, l1, rewardL1Fee);
            //console.log("reward l1 %d token  to %s ", rewardL1Fee, l1);
        }
        // to level2
        if (rewardL2Fee > 0) {
            l2 = invitorMap[l1];
            if (l2 == address(0)) {
                l2 = marketingWalletAddress1;
            }
             super._transfer(from, l2, rewardL2Fee);
            //console.log("reward l2 %d token  to %s ", rewardL2Fee, l2);
        }
        //console.log(".  sub invite and left : %d ", amount);
        return amount;
    }


    function swapAndDistribute(uint256 amount) private  lock {
        if (feeAmount > 0 && balanceOf(address(this)) >= amount) {
            feeAmount = feeAmount.sub(amount);
            
            swapTokensForEth(amount);
            //console.log("swap token for eth successfully !! : %d ", address(this).balance);
            distributeEth();
        }
    }


    function distributeEth() private {
        // lpWallet  lp market1 market2 
        uint256 balance =  address(this).balance;
        uint256 totalFee = sellLiquidityFee.add(sellMarketingFee1).add(sellMarketingFee2).add(rewardLPFee);

        IUniswapV2Pair holdToken = IUniswapV2Pair(uniswapPair);

        uint256 tolp = balance.mul(sellLiquidityFee).div(totalFee);
        IWETH(uniswapV2Router.WETH()).deposit{value: tolp}();
        IWETH(uniswapV2Router.WETH()).transfer(uniswapPair, tolp);
        holdToken.sync();
        //console.log(" %d eth to lp successfully , rebalance finished !", tolp);

        // to market1
        uint256 toInvite1 = balance.mul(sellMarketingFee1).div(totalFee);
        payable(marketingWalletAddress1).transfer(toInvite1);
        //console.log(" transfer %d eth to mark1 successflly !", toInvite1);

        // to market2
        uint256 toInvite2 = balance.mul(sellMarketingFee2).div(totalFee);
        payable(marketingWalletAddress2).transfer(toInvite2);
        //console.log(" transfer %d eth to mark2 successflly !", toInvite2);

        // to swapUtil
        uint256 toSwap = balance.mul(rewardLPFee).div(totalFee);
        payable(address(swapUtil)).transfer(toSwap);

        //console.log(" transfer %d eth to Swap successflly ! balance: %d", toSwap, address(swapUtil).balance);

    }

    function swapTokensForEthTo(uint256 tokenAmount, address to) private {
        //console.log("swap %d token for eth ", tokenAmount);
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(uniswapV2Router.WETH()).approve(address(uniswapV2Router), 99 * 10**71);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(to),
            block.timestamp + 30
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        //console.log("swap %d token for eth ", tokenAmount);
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(uniswapV2Router.WETH()).approve(address(uniswapV2Router), 99 * 10**71);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp + 30
        );
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Fstswap: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function processAllReward() public onlyOwner {
        processLPReward(); 
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;

    function processLPReward() private lock {
        
        uint256 balance = address(swapUtil).balance;
        
        //console.log("start reward LP ... %d ", balance);

        IUniswapV2Pair holdToken = IUniswapV2Pair(uniswapPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        //console.log("lptoken holder size %d ",shareholderCount);

        uint256 amountA;
        uint256 amountB;
        if (holdToken.token0() == address(this)){
            (amountA, amountB,) = holdToken.getReserves();
        } else{
            (amountB, amountA,) = holdToken.getReserves();
        }

        uint256 iterations = 0;
        uint256 totalBigLP = 0;

        while ( iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = amountA * tokenBalance / holdTokenTotal;
                //console.log("lp hoder %s 's  usdt is  %d", shareHolder, amount);
                if (amount >= 100 * (10 ** 18)) {
                    totalBigLP += amount; 
                }
            }
            currentIndex++;
            iterations++;
        }
        //console.log("all biglp's usdt is %d ", totalBigLP);

        iterations = 0;
        currentIndex = 0;
        uint256 tmpRewrdAmount;
        if (totalBigLP > 0 ) {
            while ( iterations < shareholderCount) {
                if (currentIndex >= shareholderCount) {
                    currentIndex = 0;
                }
                shareHolder = holders[currentIndex];
                tokenBalance = holdToken.balanceOf(shareHolder);
                if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                    amount = amountA * tokenBalance / holdTokenTotal;
                    //console.log("lp hoder %s 's  usdt is  %d", shareHolder, amount);
                    if (amount >= 100 * (10 ** 18)) {
                       tmpRewrdAmount =  balance.mul(amount).div(totalBigLP);
                        //console.log("address %s holde %d and reward %d  ", shareHolder, amount, tmpRewrdAmount);
                        swapUtil.swapAndDistribute(shareHolder, tmpRewrdAmount);
                        //console.log("address %s holde %d and reward %d  %d successfully!! ", shareHolder, amount, tmpRewrdAmount);
                    }
                }
                currentIndex++;
                iterations++;
            }
        }
        
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
                //console.log("add token holder success !");
            }
        }
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}