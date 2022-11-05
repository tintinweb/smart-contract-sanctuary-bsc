/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "./console.sol";
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
    function swap(uint256 amount) external;
}
contract WrapperSwap is IWrapperSwap{

    address public usdtAddress;
    address public tokenAddress;

    constructor(address _usdtAddress, address _tokenAddress) {
        usdtAddress = _usdtAddress;
        tokenAddress = _tokenAddress;
    }

    function swap(uint256 amount) external override {
     //   //console.log("swap amount: %d fist !", amount);
        IERC20(usdtAddress).transfer(tokenAddress, amount);
     //   //console.log("swap %d to token success !", amount);
    }
}

contract HUAGE is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapPair;
  
    bool private swapping = false;



    IWrapperSwap public wrapRouter;
    // to market wallet 
    uint256 public buyMarketingFee1 = 1;
    uint256 public sellMarketingFee1 = 1;
    // to lp holder
    uint256 public buyRewardLpFee = 1;
    uint256 public sellRewardLpFee = 1;


    uint256 public feeAmount;
    uint256 public minDistributeAmount = 1 * (10 ** 18);

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    // dev
    // address public usdtAddress= 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9;
    // address public routerAddress = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
    // address public marketingWalletAddress1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;


    // pro
    address public usdtAddress= 0x55d398326f99059fF775485246999027B3197955;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public marketingWalletAddress1 = 0x4eB80B7e58302Dbc4A0c288A987CD1ED931e80E3;
   

    mapping(address => bool) excludeHolder;


     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromDistribute;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event ExcludeMultipleAccountsFromDis(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    constructor() ERC20("MDINA", "MDN")  {
    

        uint256 totalSupply = 5200000000 * (10**18);


        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this),usdtAddress);


        uniswapV2Router = _uniswapV2Router;
        uniswapPair = _uniswapV2Pair;

        wrapRouter = new WrapperSwap(usdtAddress, address(this));

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress1, true);

        excludeFromFees(address(this), true);
        excludeHolder[address(0)] = true;
        excludeHolder[address(deadWallet)] = true;

        _mint(owner(), totalSupply);

    }

    receive() external payable {}


    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this),usdtAddress);
        uniswapPair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(uniswapPair, true);
        
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if(_isExcludedFromFees[account] != excluded){
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }
    

    function excludeMultipleAccountsFromDis(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromDistribute[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromDis(accounts, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }


    function setMarketingWallet(address payable wallet1) external onlyOwner{
        marketingWalletAddress1 = wallet1;
        excludeFromFees(marketingWalletAddress1, true);
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
    
    function setBuyTaxes(uint256 marketingFee1, uint256 rewardLpFee) external onlyOwner {
        buyMarketingFee1 = marketingFee1;
        buyRewardLpFee = rewardLpFee;
    }

    function setSelTaxes(uint256 marketingFee1, uint256 rewardLpFee) external onlyOwner {
        sellMarketingFee1 = marketingFee1;
        sellRewardLpFee = rewardLpFee;
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

    uint256 public openTime;
    uint256 public maxSellForNow = 30000 * 10 ** 18;
    uint256 public sellLimit = 10;
    uint256 public maxSellLimitTime = 30;

    function setMaxSellForNow(uint256 _maxSellForNow) external onlyOwner {
        maxSellForNow = _maxSellForNow;
    }

    function setMaxSellLimitTime(uint256 _maxSellLimitTime) external onlyOwner {
        maxSellLimitTime = _maxSellLimitTime;
    }

    function setSellLimit(uint256 _sellLimit) external onlyOwner {
        sellLimit = _sellLimit;
    }

    mapping(address => uint256) public userTransTime; 

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        //console.log("start _transfer from %s to %s, amount is %d", from, to, amount);

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = true;

        bool isAddLiquidity;
        bool isDelLiquidity;
        ( isAddLiquidity, isDelLiquidity) = _isLiquidity(from,to);
        if (isAddLiquidity) {
            //console.log("Add liquidity transaction !!!");
            if (openTime == 0) {
                openTime = block.timestamp;
            }
            addHolder(from);
        }
        // swap MFee to BNB    && automatedMarketMakerPairs[to] 

        if (feeAmount >= minDistributeAmount) {
            swapAndDistribute();
        }   

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        if (from == address(uniswapPair) && to == address(routerAddress)) {
            takeFee = false;
            //console.log(" bridge transfer fee is zero ");
        }
        
        //console.log("takeFee: ", takeFee);
        if(takeFee) {
            uint256 fees;

            uint256 MFee; // MFee
            uint256 RLFee; // reward fee

            if(automatedMarketMakerPairs[from]){

                // buy 
                MFee =  amount.mul(buyMarketingFee1).div(100);
                RLFee = amount.mul(buyRewardLpFee).div(100);
                fees = MFee.add(RLFee);
                userTransTime[to] = block.timestamp;
                //console.log("update buy time %s:%d", to, block.timestamp);
            }
            if(automatedMarketMakerPairs[to]){
                // sell
                if (!isAddLiquidity) {
                    // Trade limit 
                    if (block.timestamp < (openTime.add(maxSellLimitTime * 60))) {
                        require(amount < maxSellForNow, "Trade amount limited");
                    }
                    require(block.timestamp - userTransTime[from] > sellLimit, "Trade time limited");
                }
                MFee =  amount.mul(sellMarketingFee1).div(100);
                RLFee = amount.mul(sellRewardLpFee).div(100);
                fees = MFee.add(RLFee);
                addHolder(from);
            }
            if(!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && !isContract(from) && !isContract(to)){
                // transfer 
                require(block.timestamp - userTransTime[from] > sellLimit, "Trade time limited");
                MFee =  amount.mul(buyMarketingFee1).div(100);
                RLFee = amount.mul(buyRewardLpFee).div(100);
                fees = MFee.add(RLFee);
            }

            if (fees > 0) {
                amount = amount.sub(fees);
            }
            if (MFee > 0) {
                super._transfer(from, marketingWalletAddress1, MFee );
            }
            if (RLFee > 0 ) {
                feeAmount = feeAmount.add(RLFee);
                super._transfer(from, address(this),  RLFee);
            }
        } 
        super._transfer(from, to, amount);
        
    }



    function swapAndDistribute() private  lock {
        processLPReward();
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;
    address[] public holders;
    mapping(address => uint256) holderIndex;

    uint256 public minLpRewardUsdt = 99 * 10 ** 18;

    function setMinLpRewardUsdt(uint256 _minLpRewardUsdt) external onlyOwner {
        minLpRewardUsdt = _minLpRewardUsdt;
    }

    function processLPReward() private {
       uint256 tokenAmt = feeAmount;
        if (tokenAmt <= 0.00000001 * 10 ** 18 ) {
            return;
        }
        tokenAmt = tokenAmt.sub(0.00000001 * 10 ** 18);

        //console.log("start reward LP ... %d ", tokenAmt);

        IUniswapV2Pair holdToken = IUniswapV2Pair(uniswapPair);
        uint256 holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        // uint256 shareholderCount = holders.length;

        //console.log("lptoken holder size %d ", holders.length);

        uint256 amountA;
        uint256 amountB;
        if (holdToken.token0() == address(this)){
            (amountA, amountB,) = holdToken.getReserves();
        } else{
            (amountB, amountA,) = holdToken.getReserves();
        }

        uint256 iterations = 0;
        uint256 totalBigLP = 0;


        while ( iterations < holders.length) {
            if (currentIndex >= holders.length) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = amountA * tokenBalance / holdTokenTotal;
                //console.log("lp hoder %s 's  usdt is  %d", shareHolder, amount);
                if (amount.mul(amountB).div(amountA) >= minLpRewardUsdt) {
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
            while ( iterations < holders.length) {
                if (currentIndex >= holders.length) {
                    currentIndex = 0;
                }
                shareHolder = holders[currentIndex];
                tokenBalance = holdToken.balanceOf(shareHolder);
                if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                    amount = amountA * tokenBalance / holdTokenTotal;
                    //console.log("lp hoder %s 's  usdt is  %d", shareHolder, amount);
                    if (amount.mul(amountB).div(amountA) >= minLpRewardUsdt) {
                       tmpRewrdAmount =  tokenAmt.mul(amount).div(totalBigLP);
                        //console.log("address %s holde %d and reward %d", shareHolder, amount, tmpRewrdAmount);
                        feeAmount = feeAmount.sub(tmpRewrdAmount);
                        IERC20(address(this)).transfer(shareHolder, tmpRewrdAmount);
                        //console.log("address %s holde %d and reward %d.  successfully!! ", shareHolder, amount, tmpRewrdAmount);
                    }
                }
                currentIndex++;
                iterations++;
            }
        }
        
    }

    function addHolder(address adr) private {
        if (!isContract(adr)) {
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

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
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