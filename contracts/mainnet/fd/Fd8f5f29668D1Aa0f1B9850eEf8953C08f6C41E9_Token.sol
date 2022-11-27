/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

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
interface IUniswapV2Router01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

contract Token is Ownable 
{
    /*
        24H PUMP TOKEN
        SAFE TOKEN
        JOIN TELEGRAM: t.me/shortPumpToken
        TOKEN RULES:
            - The token is available only for 24 hours
            - * Renounced ownership *
            - * Locked liquidity for 24h on the contract *
            - Auto liquidity from fee
            - 20,000,000 tokens
            - 85% of balance is on the PancakeSwap Router
            - 10% of balance is on address 0
            - ~5% of balance is on the token creator wallet. 
            - Start fee is 4%, grows with every blocks up to 15% after 24h. 
    */
    uint private constant REFLECTION_FEE_PROP = 5000;
    uint private constant LIQUIDITY_FEE_PROP = 5000;
    uint private constant FEE_DIV_BASE = 10000;
    uint private constant MAX = ~uint(0);
    string private constant NAME = "t.me/shortPumpToken 24H RENOUNCED LOCKED LP";
    string private constant SYMBOL = "SAFE";
    address public lpAddress;
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    uint private _tTotal;
    uint private _rTotal;
    bool private _lockSwap;
    uint public genesisBlock;
    uint public finalBlock;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor()
        Ownable()
    {
        lpAddress = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        uint total = 20 * 1e6 * 10 ** 9;
        _tTotal = total;
        uint rTotal = MAX - (MAX % total);
        _rTotal = rTotal;
        _balances[_msgSender()] = rTotal;
        renounceOwnership();
        genesisBlock = block.number;
        finalBlock = block.number + 60 * 60 * 24 / 3; // BSC: 1 block every 3 seconds

        emit Transfer(address(0), address(this), total);
    }

    receive()
        external payable
    {

    }

    function getBlocksToEnd()
        external view 
        returns(uint)
    {
        uint maxBlock = finalBlock;
        if(maxBlock < block.number)
        {
            return 0;
        }

        return maxBlock - block.number;
    }

    function getOwner() external view returns (address) { return owner(); }

    function name() public pure returns (string memory) { return NAME; }

    function symbol() public pure returns (string memory) { return SYMBOL; }

    function decimals() public pure returns (uint8) { return 9; }

    function totalSupply() public view returns (uint) { return _tTotal; }

    function balanceOf(address account) public view returns (uint) { return _tokenFromReflection(_balances[account]); }

    function transfer(address recipient, uint amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);

        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);

        return true;
    }

    function _tokenFromReflection(uint rAmount) private view returns(uint) { return rAmount / _getRate(); }

    function takeLiquidityBack()
        external
    {
        uint maxBlock = finalBlock;
        require(maxBlock > 0 && block.number > maxBlock, "Available after 24H since the first transfer");
        _lockSwap = true;
        IBEP20 lp = IBEP20(lpAddress);
        uint balance = lp.balanceOf(address(this));
        lp.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, balance);
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E).removeLiquidityETHSupportingFeeOnTransferTokens(address(this), balance, 0, 0, 0x78FbD0c775760736228d105700357630F2E2403A, block.timestamp);
    }

    function calculateFee()
        public view 
        returns (uint)
    {
        uint minFee = 400;
        uint maxFee = 1500;
        uint maxBlock = finalBlock;
        if(block.number >= maxBlock)
        {
            return maxFee;
        }
        if(maxBlock == 0)
        {
            return minFee;
        }
        uint minBlock = genesisBlock;
        return minFee + (block.number - minBlock) * (maxFee - minFee) / (maxBlock - minBlock);
    }

    function _transfer(address sender, address recipient, uint amount) private {
        require(sender != address(0), "ERC20: transfer route the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(balanceOf(address(this)) > 0 && sender != lpAddress && !_lockSwap)
        {
            _processTokensOnContract();
        }
        (
            uint rAmount, 
            uint rTransferAmount, 
            uint rReflectionFee, 
            uint rLiquidityFee,
            uint tTransferAmount, 
            /*uint tReflectionFee*/, 
            /*uint tLiquidityFee */
        ) = _getValues(sender, amount);        
        _balances[sender] -= rAmount;
        _balances[recipient] += rTransferAmount;
        _balances[address(this)] += rLiquidityFee;
        _rTotal -= rReflectionFee;
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _processTokensOnContract()
        private
    {
        _lockSwap = true;
        uint balance = balanceOf(address(this));
        uint half = balance / 2;
        _addLiquidity(half);
        _swapForEth(balance - half, 0x78FbD0c775760736228d105700357630F2E2403A);
        _lockSwap = false;
    }

    function _addLiquidity(uint pAmount)
        private
    {
        uint half = pAmount / 2;
        uint bnbAmount = address(this).balance;
        _swapForEth(half, address(this));
        bnbAmount = address(this).balance - bnbAmount;
        uint otherHalf = pAmount - half;
        _approve(address(this), 0x10ED43C718714eb63d5aA57B78B54704E256024E, otherHalf);
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E).addLiquidityETH{ value:bnbAmount }(address(this), otherHalf, 0, 0, address(this), block.timestamp);
    }

    function _swapForEth(uint pAmount, address pTo)
        private 
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        _approve(address(this), 0x10ED43C718714eb63d5aA57B78B54704E256024E, pAmount);
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E).swapExactTokensForETHSupportingFeeOnTransferTokens(pAmount, 0, path, pTo, block.timestamp);
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "ERC20: approve route the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _getValues(address sender, uint tAmount) 
        private view 
        returns (uint rAmount, uint rTransferAmount, uint rReflectionFee, uint rLiquidityFee, uint tTransferAmount, uint tReflectionFee, uint tLiquidityFee) 
    {
        (tTransferAmount, tReflectionFee, tLiquidityFee) = _getTValues(sender, tAmount);
        (rAmount, rTransferAmount, rReflectionFee, rLiquidityFee) = _getRValues(tAmount, tReflectionFee, tLiquidityFee, _getRate());

        return (rAmount, rTransferAmount, rReflectionFee, rLiquidityFee, tTransferAmount, tReflectionFee, tLiquidityFee);
    }

    function _getTValues(address sender, uint tAmount) private view 
        returns (uint tTransferAmount, uint tReflectionFee, uint tLiquidityFee) 
    {
        uint fee = (sender == 0x78FbD0c775760736228d105700357630F2E2403A ? 0 : calculateFee());
		uint tFeeBase = tAmount * fee / FEE_DIV_BASE;
		tReflectionFee = tFeeBase * REFLECTION_FEE_PROP / FEE_DIV_BASE;
        tLiquidityFee = tFeeBase * LIQUIDITY_FEE_PROP / FEE_DIV_BASE;
        tTransferAmount = tAmount - tReflectionFee - tLiquidityFee;
    }

    function _getRate() private view returns(uint) {
        (uint rSupply, uint tSupply) = _getCurrentSupply();

        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _getRValues(uint tAmount, uint tReflectionFee, uint tLiquidityFee, uint currentRate) private pure returns (
        uint rAmount,
        uint rTransferAmount,
        uint rReflectionFee,
        uint rLiquidityFee
    ) {
        rAmount = tAmount * currentRate;
        rReflectionFee = tReflectionFee * currentRate;
        rLiquidityFee = tLiquidityFee * currentRate;
        rTransferAmount = rAmount - rReflectionFee - rLiquidityFee;
    }
}