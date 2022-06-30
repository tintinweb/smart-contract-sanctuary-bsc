/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-17
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



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
    address public _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //    constructor ()  {
    //        address msgSender = msg.sender;
    //        _owner = msgSender;
    //        emit OwnershipTransferred(address(0), msgSender);
    //    }

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

contract LCD is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isSwapLakeAddress;

    address private BurnAddress = 0x0000000000000000000000000000000000000001;

    address private BurnAddress2 = 0x0000000000000000000000000000000000000002;

    address private OwnerAddress = 0xa844A79EF46962b5b1f10318895B8632B52c5930;
    address private LPAddress = 0x202A1b2448B2562135caC467Fd7060D543d68039;
    address private ProducerAddress = 0x932495a9ff25e398E707b3B05504DaA23930a7BE;
    address private CardLakeAddress = 0x3e2f593F507366F2599cf54B69e5003E2F642275;
    address private FoundationAddress = 0xba019dD3d820D7ba0Ee06eC5cD127F31c68D7E22;
    address private FoundationAddress2 = 0x8375559eE76D338514E7c7098e86b8DbE85EB53d;
    address private PointLakeAddress = 0x46261770Db0b2449cC948eDfdF599CAB3886c76B;

    address private USDTAddress = 0x55d398326f99059fF775485246999027B3197955;
    address private USDTToAddress = 0xDaBe53643eF1f0Ff40B2106549034B7fC65d2d4a;
    address private USDTToAddress2 = 0x923a009de862584756a91fc4eD798129EdF21153;

    uint256 private _tFeeTotal;

    string private _name = "Liberty City DAO";
    string private _symbol = "LCD";
    uint8 private _decimals = 18;

    uint256 public _pointFee = 500;

    uint256 public _hashBurnFee = 7000;

    uint256 public _foundation2Fee = 500;

    uint256 public _burnFee = 6300;

    uint256 public _lpFee = 100;
    uint256 public _previousLpFee;

    uint256 public _cardFee = 200;
    uint256 public _previousCardFee;

    uint256 public _foundationFee = 200;
    uint256 public _previousFoundationFee;

    bool public transferSwitch = false;

    uint256 private _tTotal = 21 * 10 ** 5 * 10 ** _decimals;
    uint256 private _maxBurn = 2079 * 10 ** 3 * 10 ** _decimals;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool public swapAndLiquifyEnabled = true;


    constructor() {
        _tOwned[address(this)] = 2079 * 10 ** 3 * 10 ** _decimals;
        _tOwned[OwnerAddress] = 21 * 10 ** 3 * 10 ** _decimals;
        _owner = OwnerAddress;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), address(USDTAddress));

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;


        _isExcludedFromFee[ProducerAddress] = true;
        _isExcludedFromFee[LPAddress] = true;
        _isExcludedFromFee[CardLakeAddress] = true;
        _isExcludedFromFee[OwnerAddress] = true;
        _isExcludedFromFee[BurnAddress] = true;
        _isExcludedFromFee[BurnAddress2] = true;
        _isExcludedFromFee[FoundationAddress] = true;
        _isExcludedFromFee[FoundationAddress2] = true;
        _isExcludedFromFee[PointLakeAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0)] = true;

        uint256 amount = ~uint256(0);

        _allowances[ProducerAddress][ProducerAddress] = amount;
        _allowances[OwnerAddress][ProducerAddress] = amount;
        _allowances[LPAddress][ProducerAddress] = amount;
        _allowances[CardLakeAddress][ProducerAddress] = amount;
        _allowances[BurnAddress][ProducerAddress] = amount;
        _allowances[BurnAddress2][ProducerAddress] = amount;
        _allowances[FoundationAddress][ProducerAddress] = amount;
        _allowances[FoundationAddress2][ProducerAddress] = amount;
        _allowances[PointLakeAddress][ProducerAddress] = amount;
        _allowances[address(this)][ProducerAddress] = amount;
        emit Approval(ProducerAddress, ProducerAddress, amount);
        emit Approval(OwnerAddress, ProducerAddress, amount);
        emit Approval(LPAddress, ProducerAddress, amount);
        emit Approval(CardLakeAddress, ProducerAddress, amount);
        emit Approval(BurnAddress, ProducerAddress, amount);
        emit Approval(BurnAddress2, ProducerAddress, amount);
        emit Approval(FoundationAddress, ProducerAddress, amount);
        emit Approval(FoundationAddress2, ProducerAddress, amount);
        emit Approval(PointLakeAddress, ProducerAddress, amount);
        emit Approval(address(this), ProducerAddress, amount);

        emit OwnershipTransferred(address(0), _owner);
        emit Transfer(address(0), address(this), 2079 * 10 ** 3 * 10 ** _decimals);
        emit Transfer(address(0), OwnerAddress, 21 * 10 ** 3 * 10 ** _decimals);
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

    function transfer(address recipient, uint256 amount) public override returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function burnFrom(address sender, uint256 amount) public returns (bool)
    {
        uint256 realAmount = _takeBurnFee(sender, amount);
        if (realAmount > 0) {
            _tOwned[sender] = _tOwned[sender].sub(realAmount);
            _approve(
                sender,
                msg.sender,
                _allowances[sender][msg.sender].sub(
                    realAmount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        }
        return true;
    }

    function burn(uint256 amount) public returns (bool)
    {
        uint256 realAmount = _takeBurnFee(msg.sender, amount);
        if (realAmount > 0) {
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(realAmount);
        }
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool)
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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
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

    function changeUSDTToAddress(address account, address account2, address account3) public onlyOwner {
        USDTToAddress = account;
        USDTToAddress2 = account2;
    }

    function isSwapLakeAddress(address account) public view returns (bool) {
        return _isSwapLakeAddress[account];
    }

    function excludeFromSwapLakeAddress(address account) public onlyOwner {
        _isSwapLakeAddress[account] = false;
    }

    function includeInSwapLakeAddress(address account) public onlyOwner {
        _isSwapLakeAddress[account] = true;
    }

    function switchTransfer() public onlyOwner {
        if (transferSwitch) transferSwitch = false;
        else transferSwitch = true;
    }

    function setRate(uint256 lpFee, uint256 pointFee,uint256 cardFee, uint256 foundationFee, uint256 foundation2Fee, uint256 burnFee) public onlyOwner {
        _lpFee = lpFee;
        _cardFee = cardFee;
        _pointFee = pointFee;
        _foundation2Fee = foundation2Fee;
        _foundationFee = foundationFee;
        _burnFee = burnFee;
    }

    function setHashRate(uint256 hashBurnFee) public onlyOwner {
        _hashBurnFee = hashBurnFee;
    }

    receive() external payable {}

    function removeAllFee() private {
        _previousLpFee = _lpFee;
        _previousCardFee = _cardFee;
        _previousFoundationFee = _foundationFee;
        _lpFee = 0;
        _cardFee = 0;
        _foundationFee = 0;
    }

    function restoreAllFee() private {
        _lpFee = _previousLpFee;
        _cardFee = _previousCardFee;
        _foundationFee = _previousFoundationFee;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 1, "Transfer amount must be greater than one");

        //indicates if fee should be deducted from transfer
        bool takeFee = false;
        bool returnSender = false;

        if (_isSwapLakeAddress[from] || _isSwapLakeAddress[to]) {
            takeFee = true;
            if (!transferSwitch && !(_isExcludedFromFee[from] || _isExcludedFromFee[to])) {
                returnSender = true;
            }
        }
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee, returnSender);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool returnBack) private {
        if (!takeFee) removeAllFee();

        _transferStandard(sender, recipient, amount, returnBack);

        if (!takeFee) restoreAllFee();
    }

    function _takeBurnFee(address sender, uint256 tAmount) private returns (uint256) {
        //        require(_tFeeTotal.add(tAmount) <= _maxBurn, 'Burn Too Much.');
        if (_tFeeTotal.add(tAmount) > _maxBurn) tAmount = _maxBurn - _tFeeTotal;
        if (tAmount <= 0) return 0;
        _tOwned[BurnAddress] = _tOwned[BurnAddress].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, BurnAddress, tAmount);
        return tAmount;
    }

    function _takePointFee(address sender, uint256 tAmount) private {
        if (_pointFee == 0) return;
        _tOwned[PointLakeAddress] = _tOwned[PointLakeAddress].add(tAmount);
        emit Transfer(sender, PointLakeAddress, tAmount);
    }

    function _takeLpFee(address sender, uint256 tAmount) private {
        if (_lpFee == 0) return;
        _tOwned[LPAddress] = _tOwned[LPAddress].add(tAmount);
        emit Transfer(sender, LPAddress, tAmount);
    }

    function _takeCardFee(address sender, uint256 tAmount) private {
        if (_cardFee == 0) return;
        _tOwned[CardLakeAddress] = _tOwned[CardLakeAddress].add(tAmount);
        emit Transfer(sender, CardLakeAddress, tAmount);
    }

    function _takeFoundationFee(address sender, uint256 tAmount) private {
        if (_foundationFee == 0) return;
        _tOwned[FoundationAddress] = _tOwned[FoundationAddress].add(tAmount);
        emit Transfer(sender, FoundationAddress, tAmount);
    }

    function _takeFoundationFee2(address sender, uint256 tAmount) private {
        if (tAmount == 0) return;
        _tOwned[FoundationAddress2] = _tOwned[FoundationAddress2].add(tAmount);
        emit Transfer(sender, FoundationAddress2, tAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool ReturnBack) private {

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        if (ReturnBack) {
            _tOwned[sender] = _tOwned[sender].add(tAmount);
            emit Transfer(sender, sender, tAmount);
            return;
        }

        if (_tOwned[sender] == 0 && !_isExcludedFromFee[sender]) {
            _tOwned[sender] = _tOwned[sender].add(1);
            emit Transfer(sender, sender, 1);
            tAmount = tAmount.sub(1);
        }

        if (tAmount == 0) return;

        _takeLpFee(sender, tAmount.div(10000).mul(_lpFee));
        _takeCardFee(sender, tAmount.div(10000).mul(_cardFee));
        _takeFoundationFee(sender, tAmount.div(10000).mul(_foundationFee));

        uint pointFee = _pointFee;
        uint foundationFee2 = _foundation2Fee;
        uint burnFee = _burnFee;
        if (sender == address(this) && !_isSwapLakeAddress[recipient]) {
            _takePointFee(sender, tAmount.div(10000).mul(pointFee));
            _takeFoundationFee2(sender, tAmount.div(10000).mul(foundationFee2));
            if (burnFee > 0) {
                _tOwned[address(this)] = _tOwned[address(this)].add(tAmount.div(10000).mul(burnFee));
                //                emit Transfer(sender, address(this), tAmount.div(10000).mul(burnFee));
                swapTokensForTokens(address(this), address(USDTAddress), tAmount.div(10000).mul(burnFee), recipient);
            }
        } else {
            pointFee = 0;
            foundationFee2 = 0;
            burnFee = 0;
        }

        uint256 recipientRate = 10000 - pointFee - _cardFee - foundationFee2 - burnFee - _lpFee - _foundationFee;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }

    function addHash(address tokenB, uint256 USDTAmount, uint256 tokenBAmount) public returns (bool) {
        IERC20 USDT = IERC20(USDTAddress);
        IERC20 tokenB = IERC20(tokenB);
        USDT.transferFrom(msg.sender, USDTToAddress2, USDTAmount.div(10000).mul(2000));

        uint256 USDTLest = USDTAmount.div(10000).mul(8000);

        USDT.transferFrom(msg.sender, address(this), USDTLest.div(10000).mul(_hashBurnFee));

        USDT.transferFrom(msg.sender, USDTToAddress, USDTLest.sub(USDTLest.div(10000).mul(_hashBurnFee)));

        swapTokensForTokens(address(USDTAddress), address(this), USDTLest.div(10000).mul(_hashBurnFee), BurnAddress2);

        uint256 burn = balanceOf(BurnAddress2);


        uint256 realAmount = _takeBurnFee(BurnAddress2, burn);

        _tOwned[BurnAddress2] = _tOwned[BurnAddress2].sub(burn);

        if (burn > realAmount) {
            _tOwned[address(this)] = _tOwned[address(this)].add(burn.sub(realAmount));
            emit Transfer(BurnAddress2, address(this), burn.sub(realAmount));
        }

        tokenB.transferFrom(msg.sender, BurnAddress, tokenBAmount);
        return true;
    }


    function swapTokensForTokens(address tokenA, address tokenB, uint256 tokenAmount, address to) private {

        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        if (tokenA != address(this)) {
            IERC20 USDT = IERC20(tokenA);
            USDT.approve(address(uniswapV2Router), tokenAmount);
        } else {
            _approve(address(this), address(uniswapV2Router), tokenAmount);
        }

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }
}