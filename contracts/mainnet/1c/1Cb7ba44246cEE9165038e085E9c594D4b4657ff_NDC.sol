/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
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

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Middle {
    IERC20 public token;
    IERC20 public usdt;

    constructor (IERC20 _token, IERC20 _usdt) {
        token = _token;
        usdt = _usdt;
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(token), usdtBalance);
        }
        uint256 tokenBalance = token.balanceOf(address(this));
        if (tokenBalance > 0) {
            token.transfer(address(token), tokenBalance);
        }
    }
}

contract LPManager {

    using SafeMath for uint256;

    IUniswapV2Router02 _uniswapV2Router;
    IERC20 public token;
    IERC20 public usdt;
    address public owner;
    uint256 public lastTime;
    uint256 public minTime = 10 minutes;
    uint256 public minAmount = 20 * 10 ** 18;

    modifier onlyOwner() {
        require(msg.sender == owner, 'Ownable: caller is not the owner');
        _;
    }

    constructor (IUniswapV2Router02 _router, IERC20 _token, IERC20 _usdt, address _owner) {
        _uniswapV2Router = _router;
        token = _token;
        usdt = _usdt;
        owner = _owner;
        usdt.approve(address(_uniswapV2Router), ~uint256(0));
    }

    function manageLp() public {
        require(msg.sender == owner || msg.sender == address(token), "permission denied");
        uint256 balanceUsdt = usdt.balanceOf(address(this));
        if (block.timestamp.sub(lastTime) < minTime || balanceUsdt < minAmount) {
            return;
        }
        uint256 initialToken = token.balanceOf(address(this));
        swapUSDTForToken(minAmount.div(2));
        uint256 afterToken = token.balanceOf(address(this));
        uint256 addToken = afterToken.sub(initialToken);
        addLiquidityUsdt(addToken, minAmount.div(2));
        lastTime = block.timestamp;
    }

    function setMin(uint256 _minTime, uint256 _minAmount) public onlyOwner {
        minTime = _minTime;
        minAmount = _minAmount;
    }

    function takeToken(address t, address recipient, uint256 amount) public onlyOwner {
        IERC20(t).transfer(recipient, amount);
    }

    function swapUSDTForToken(uint256 usdtAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(token);

        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _uniswapV2Router.addLiquidity(
            address(token),
            address(usdt),
            tokenAmount,
            usdtAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

}

abstract contract Referral is Ownable {

    mapping(address => address) internal _referrers;
    mapping(address => address[]) internal _recommended;

    event SetReferrer(address account, address referrer);

    function setReferrer(address parentAddress) public {
        require(_referrers[msg.sender] == address(0), "user already have parent");
        require(
            parentAddress == owner() || _referrers[parentAddress] != address(0),
            "Error: parentAddress must be has parent!"
        );
        _referrers[msg.sender] = parentAddress;
        _recommended[parentAddress].push(msg.sender);
        emit SetReferrer(msg.sender, parentAddress);
    }

    function parent(address account) public view returns (address)
    {
        return _referrers[account];
    }

    function referrersSize(address account) public view returns (uint256)
    {
        return _recommended[account].length;
    }

    function recommended(address account, uint256 page, uint256 size) public view returns (uint256, address[] memory) {
        uint256 len = size;
        if (page * size + size > _recommended[account].length) {
            len = _recommended[account].length % size;
        }
        if (page > _recommended[account].length / size) {
            len = 0;
        }
        address[] memory _fans = new address[](len);
        uint256 startIdx = page * size;
        for (uint256 i = 0; i != size; i++) {
            if (startIdx + i >= _recommended[account].length) {
                break;
            }
            _fans[i] = _recommended[account][startIdx + i];
        }
        return (_recommended[account].length, _fans);
    }
}

contract NDC is IERC20, Ownable, Referral {
    using SafeMath for uint256;
    uint256 private constant MAX = ~uint256(0);

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    IERC20 public usdt;
    mapping(address => uint256) public lastSellTime;

    bool public swapAndLiquifyEnabled = true;
    bool public swapEnabled = false; // should be true
    bool public sellLimit = true;
    uint256 public sellInterval = 1 days;

    string private _name = "NDC";
    string private _symbol = "NDC";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 21000000 * 10 ** _decimals;

    uint256 public minTokenNumberToSell = 20 * 10 ** _decimals;

    uint256 public baseRate = 10000;
    uint256[5] public sellAmountRate = [100, 500, 1000, baseRate, baseRate];


    Middle public middle;
    LPManager public lPManager;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;

    constructor(address _router, IERC20 _usdt) {
        usdt = _usdt;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), address(_usdt));

        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(_uniswapV2Router), MAX);
        usdt.approve(address(_uniswapV2Router), MAX);

        middle = new Middle(IERC20(this), usdt);
        lPManager = new LPManager(_uniswapV2Router, IERC20(this), usdt, msg.sender);
        _approve(address(lPManager), address(_uniswapV2Router), MAX);

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(middle)] = true;
        _isExcludedFromFee[address(lPManager)] = true;

        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setFromFees(address[] memory accounts, bool[] memory flags) public onlyOwner {
        require(accounts.length == flags.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = flags[i];
        }
    }

    function setMinToken(uint256 _minTokenNumberToSell) public onlyOwner {
        minTokenNumberToSell = _minTokenNumberToSell;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setSellLimit(bool _sellLimit) public onlyOwner {
        sellLimit = _sellLimit;
    }

    function setLPManager(LPManager _lPManager) public onlyOwner {
        lPManager = _lPManager;
    }

    function setSellAmountRate(uint256[5] memory _sellAmountRate) public onlyOwner {
        sellAmountRate = _sellAmountRate;
    }

    function setSellLimit(uint256 _sellInterval) public onlyOwner {
        sellInterval = _sellInterval;
    }

    function activeSwap() public onlyOwner {
        swapEnabled = true;
    }

    function takeToken(address token, address recipient, uint256 amount) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function takeBNB(address recipient, uint256 amount) public onlyOwner {
        payable(recipient).transfer(amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if ((from == uniswapV2Pair || to == uniswapV2Pair) && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(swapEnabled, "not allowed");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= minTokenNumberToSell;

        if (
            canSwap &&
            swapAndLiquifyEnabled &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            from != address(this)
        ) {
            inSwapAndLiquify = true;
            swapAndLiquify(minTokenNumberToSell);
            inSwapAndLiquify = false;
        }
        bool takeFee = !inSwapAndLiquify;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if (takeFee) {
            if (sellLimit && to == uniswapV2Pair) {
                require(block.timestamp - lastSellTime[from] >= sellInterval, "sell not good");
                uint256 sellRate = getSellAmount();
                if (amount > _tOwned[from] * sellRate / baseRate) {
                    amount = _tOwned[from] * sellRate / baseRate;
                }
                lastSellTime[from] = block.timestamp;
            }
            if (from != uniswapV2Pair && address(lPManager) != address(0x0)) {
                lPManager.manageLp();
            }
            _tokenTransfer(from, to, amount);
        } else {
            _basicTransfer(from, to, amount);
        }
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(amount);
        emit Transfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);

        uint256 burnFee = _takeBurn(sender, amount);

        uint256 lpFee = _takeLp(sender, amount);

        uint256 recipientAmount = amount.sub(burnFee + lpFee);

        _tOwned[recipient] = _tOwned[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
    }

    function _takeBurn(
        address sender,
        uint256 amount
    ) private returns (uint256) {
        uint256 tFee = amount.mul(100).div(baseRate);
        _tOwned[address(0x0)] = _tOwned[address(0x0)].add(tFee);
        emit Transfer(sender, address(0x0), tFee);
        _tTotal = _tTotal.sub(tFee);
        return tFee;
    }

    function _takeLp(
        address sender,
        uint256 amount
    ) private returns (uint256) {
        uint256 tFee = amount.mul(200).div(baseRate);
        _tOwned[address(this)] = _tOwned[address(this)].add(tFee);
        emit Transfer(sender, address(this), tFee);
        return tFee;
    }

    function getSellAmount() public view returns (uint256){
        uint256 price = getCurrentPrice();
        uint256 decimalRate = 10 ** 18;
        if (price > 100 * decimalRate) {
            return sellAmountRate[3];
        } else if (price > 50 * decimalRate) {
            return sellAmountRate[2];
        } else if (price > 20 * decimalRate) {
            return sellAmountRate[1];
        }else {
            return sellAmountRate[0];
        }
    }

    function getCurrentPrice() public view returns (uint256){
        if (_tOwned[uniswapV2Pair] == 0) {
            return 0;
        }
        return IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
    }

    function getUserInfo(address account) public view returns (uint256, uint256, address, uint256, uint256){
        return (getCurrentPrice(), getSellAmount(), _referrers[account], _recommended[account].length, lastSellTime[account]);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half, "sub half");

        uint256 initialUsdt = usdt.balanceOf(address(this));
        swapTokensForUSDT(half);
        uint256 afterUsdt = usdt.balanceOf(address(this));
        uint256 addUsdt = afterUsdt.sub(initialUsdt);

        addLiquidityUSDT(otherHalf, addUsdt);
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(middle),
            block.timestamp
        );
        middle.withdraw();
    }

    function addLiquidityUSDT(uint256 tokenAmount, uint256 uAmount) private {
        // approve token transfer to cover all possible scenarios
        uniswapV2Router.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            uAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

}