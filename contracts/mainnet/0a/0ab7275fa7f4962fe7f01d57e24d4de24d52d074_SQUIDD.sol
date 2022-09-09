/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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

contract SQUIDD is Context, IERC20, Ownable {
    using SafeMath for uint256;
    // Multisig Protocol Wallets
    address payable public marketingAddress =
        payable(0xD06dbCeD79568C6C0B0706484B848411C065add1);
    address payable public vaultRewardAddress =
        payable(0x0a3d6238a74778a278F5c71d770e8ef9Bb80017a);
    address payable public developmentAddress =
        payable(0xF36AaC0bC463375cAe389684575491254e8C7cE0);

    address payable public liquidityWallet = payable(address(this));
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromWalletHoldingLimit;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "SQUIDD";
    string private constant _symbol = "SQUIDD";
    uint8 private constant _decimals = 9;

    // Protocol Fees
    uint256 private _vaultFee = 0;
    uint256 private _tempTaxFee = 0;
    uint256 private _tempVaultFee = 0;
    uint256 private _tempLiquidityFee = 0;
    uint256 private _buyVaultFee = 0;
    uint256 private _sellVaultFee = 0;

    uint256 public _buyTaxFee = 2;
    uint256 public _buyRewardFee = 1;
    uint256 public _buyMarketingFee = 3;
    uint256 public _buyDevelopmentFee = 1;
    uint256 public _buyLiqFee = 2;
    uint256 public _buyBurnFee = 1;
    uint256 private _buyLiquidityFee = 8;

    uint256 public _taxFee = 0;
    uint256 public _rewardFee = 0;
    uint256 public _marketingFee = 0;
    uint256 public _developmentFee = 0;
    uint256 public _liqFee = 0;
    uint256 public _burnFee = 0;
    uint256 private _liquidityFee = 0;

    uint256 public _sellTaxFee = 2;
    uint256 public _sellRewardFee = 1;
    uint256 public _sellMarketingFee = 3;
    uint256 public _sellDevelopmentFee = 1;
    uint256 public _sellLiqFee = 2;
    uint256 public _sellBurnFee = 1;
    uint256 private _sellLiquidityFee = 8;

    bool public transferFee = false;
    bool public tradingOpen = true;

    address public tradingSetter;

    // Protocol Limits
    uint256 public _bMaxTxAmount = 5 * 10**12 * 10**9;
    uint256 public _sMaxTxAmount = 5 * 10**12 * 10**9;
    uint256 public minimumTokensBeforeSwap = 5 * 10**6 * 10**9;
    uint256 public _maxWalletHoldingLimit = 30 * 10**12 * 10**9;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquifyTokens(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event MaxWalletHoldingAmountUpdated(uint256 updatedMaxWalletHoldingAmount);
    event BuyTaxFeeUpdated(uint256 feeUpdated);
    event SellTaxFeeUpdated(uint256 feeUpdated);
    event InternalTaxFeeUpdated(uint256 feeUpdated);
    event MaxSellTxAmountUpdated(uint256 updatedMaxTxAmount);
    event MaxBuyTxAmountUpdated(uint256 updatedMaxTxAmount);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);

    event SwapTokensForBNB(uint256 amountIn, address[] path);

    event SwapBNBForTokensDead(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;

        // Testnet : 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // Mainnet : 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // testnetpswapkiemtieonline: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        tradingSetter = owner();

        // Protocol Multisig Wallets
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[liquidityWallet] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[vaultRewardAddress] = true;
        _isExcludedFromFee[developmentAddress] = true;
        _isExcludedFromFee[deadAddress] = true;

        _isExcludedFromWalletHoldingLimit[owner()] = true;
        _isExcludedFromWalletHoldingLimit[liquidityWallet] = true;
        _isExcludedFromWalletHoldingLimit[marketingAddress] = true;
        _isExcludedFromWalletHoldingLimit[vaultRewardAddress] = true;
        _isExcludedFromWalletHoldingLimit[developmentAddress] = true;
        _isExcludedFromWalletHoldingLimit[deadAddress] = true;
        _isExcludedFromWalletHoldingLimit[uniswapV2Pair] = true;

        excludeFromReward(uniswapV2Pair);
        excludeFromReward(deadAddress);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    /* PUBLIC FUNCTION STARTS */

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
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
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
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
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromWalletLimit(address WalletAddress)
        external
        view
        returns (bool)
    {
        return _isExcludedFromWalletHoldingLimit[WalletAddress];
    }

    /* PUBLIC FUNCTION ENDS */

    /* PRIVATE FUNCTION STARTS */

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
        if (tradingOpen == false) {
            require(
                _isExcludedFromFee[to] || _isExcludedFromFee[from],
                "Trading Not Yet Started."
            );
        }

        if (!_isExcludedFromWalletHoldingLimit[to] && from != owner()) {
            require(
                balanceOf(to).add(amount) <= _maxWalletHoldingLimit,
                "Wallet Holding limit exceeding"
            );
        }

        if (
            from != owner() &&
            to != owner() &&
            !_isExcludedFromFee[to] &&
            !_isExcludedFromFee[from]
        ) {
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(
                    amount <= _bMaxTxAmount,
                    "Transfer amount exceeds max buy amount."
                );
            }
            if (to == uniswapV2Pair && !_isExcludedFromFee[from]) {
                require(
                    amount <= _sMaxTxAmount,
                    "Transfer amount exceeds the max sell amount."
                );
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;

        // Sell tokens for BNB
        if (
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            balanceOf(uniswapV2Pair) > 0
        ) {
            if (to == uniswapV2Pair) {
                if (overMinimumTokenBalance) {
                    contractTokenBalance = minimumTokensBeforeSwap;

                    uint256 remainingLiquidityToken = contractTokenBalance
                        .mul(
                            _sellRewardFee +
                                _sellMarketingFee +
                                _sellDevelopmentFee +
                                _sellBurnFee
                        )
                        .div(_sellLiquidityFee);
                    uint256 liquidityToken = contractTokenBalance.sub(
                        remainingLiquidityToken
                    );

                    // Swap Tokens and Send to Different Address
                    swapTokens(remainingLiquidityToken);

                    // Remove Hate Swap and Liquidity by breaking Token in proportion
                    addLiquidityToToken(liquidityToken);
                }
            }
        }

        _tempTaxFee = 0;
        _tempVaultFee = 0;
        _tempLiquidityFee = 0;
        // If any account belongs to _isExcludedFromFee account then remove the fee
        if (!_isExcludedFromFee[from] || !_isExcludedFromFee[to]) {
            // defaults transfer fees:
            if (transferFee) {
                _tempTaxFee = _taxFee;
                _tempVaultFee = _vaultFee;
                _tempLiquidityFee = _liquidityFee;
            }

            // Buy
            if (from == uniswapV2Pair) {
                _tempTaxFee = _buyTaxFee;
                _tempVaultFee = _buyVaultFee;
                _tempLiquidityFee = _buyLiquidityFee;
            }
            // Sell
            if (to == uniswapV2Pair) {
                _tempTaxFee = _sellTaxFee;
                _tempVaultFee = _sellVaultFee;
                _tempLiquidityFee = _sellLiquidityFee;
            }
        }

        _tokenTransfer(from, to, amount);
    }

    function swapTokens(uint256 _contractTokenBalance) private lockTheSwap {
        // Prize Reward Wakket Transfer
        uint256 rewardToken = _contractTokenBalance.mul(_sellRewardFee).div(
            _sellLiquidityFee
        );
        require(
            IERC20(address(this)).transfer(vaultRewardAddress, rewardToken)
        );

        uint256 newTokenBal = _contractTokenBalance.sub(rewardToken);

        uint256 initialBalance = address(this).balance;
        swapTokensForBnb(newTokenBal);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);

        // Token Burning
        uint256 burnToken = transferredBalance.mul(_sellBurnFee).div(
            _sellLiquidityFee.sub(_sellRewardFee)
        );
        buyBackTokensAndBurn(burnToken);

        // Marketing and Team Wallet
        uint256 marketingToken = transferredBalance.mul(_sellMarketingFee).div(
            _sellLiquidityFee.sub(_sellRewardFee)
        );
        uint256 developmentToken = transferredBalance.sub(
            marketingToken + burnToken
        );

        //Send to All address
        transferToAddressBNB(marketingAddress, marketingToken);
        transferToAddressBNB(developmentAddress, developmentToken);
    }

    function buyBackTokensAndBurn(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapBNBForTokensDead(amount);
        }
    }

    function transferToAddressBNB(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // Generate the uniswap pair path of token -> WBNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            10000,
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForBNB(tokenAmount, path);
    }

    function swapBNBForTokensDead(uint256 amount) private {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );

        emit SwapBNBForTokensDead(amount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // Add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            address(this), //Contract Address
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tVault
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeVault(tVault);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tVault
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeVault(tVault);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tVault
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeVault(tVault);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tVault
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeVault(tVault);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tVault
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tVault,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity,
            tVault
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tVault = calculateVaultFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tVault);
        return (tTransferAmount, tFee, tLiquidity, tVault);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tVault,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rVault = tVault.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rVault);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[liquidityWallet] = _rOwned[liquidityWallet].add(rLiquidity);
        if (_isExcluded[liquidityWallet])
            _tOwned[liquidityWallet] = _tOwned[liquidityWallet].add(tLiquidity);
    }

    function _takeVault(uint256 tVault) private {
        uint256 rVault = tVault.mul(_getRate());
        _rOwned[vaultRewardAddress] = _rOwned[vaultRewardAddress].add(rVault);
        if (_isExcluded[vaultRewardAddress])
            _tOwned[vaultRewardAddress] = _tOwned[vaultRewardAddress].add(
                tVault
            );
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_tempTaxFee).div(10**2);
    }

    function calculateVaultFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_tempVaultFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_tempLiquidityFee).div(10**2);
    }

    // To receive BNB from uniswapV2Router when swapping
    receive() external payable {}

    function addLiquidityToToken(uint256 tokenLiquifyAmount)
        private
        lockTheSwap
    {
        // split the contract balance into halves
        uint256 half = tokenLiquifyAmount.div(2); //staking tokens to be swaped
        uint256 otherHalf = tokenLiquifyAmount.sub(half); //staking tokens not swapped

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBnb(half); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquifyTokens(half, newBalance, otherHalf);
    }

    /* PRIVATE FUNCTION ENDS */

    /* OWNER FUNCTION STARTS */

    //Use when new router is released and pair HAS been created already.
    function setRouterAddress(address newRouter) external onlyOwner {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Router = _newPancakeRouter;
    }

    //Use when new router is released and pair HAS been created already.
    function setPairAddress(address newPair) external onlyOwner {
        uniswapV2Pair = newPair;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function excludeFromMaxHolding(address account) external onlyOwner {
        _isExcludedFromWalletHoldingLimit[account] = true;
    }

    function includeInMaxHolding(address account) external onlyOwner {
        _isExcludedFromWalletHoldingLimit[account] = false;
    }

    function setBuyMaxTxAmount(uint256 bMaxTxAmount) external onlyOwner {
        require(
            bMaxTxAmount >= (_tTotal / 1000),
            "Amount Should be greater than 0.1% of the total Supply"
        );
        _bMaxTxAmount = bMaxTxAmount;
        emit MaxBuyTxAmountUpdated(_bMaxTxAmount);
    }

    function setSellMaxTxAmount(uint256 sMaxTxAmount) external onlyOwner {
        require(
            sMaxTxAmount >= (_tTotal / 1000),
            "Amount Should be greater than 0.1% of the total Supply"
        );
        _sMaxTxAmount = sMaxTxAmount;
        emit MaxSellTxAmountUpdated(_sMaxTxAmount);
    }

    function setMinTokensToInitiateSwap(uint256 _minimumTokensBeforeSwap)
        external
        onlyOwner
    {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        emit MinTokensBeforeSwapUpdated(minimumTokensBeforeSwap);
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        marketingAddress = payable(_marketingAddress);
        _isExcludedFromFee[marketingAddress] = true;
    }

    function setDevelopmentAddress(address _developmentAddress)
        external
        onlyOwner
    {
        developmentAddress = payable(_developmentAddress);
        _isExcludedFromFee[developmentAddress] = true;
    }

    function setRewardAddress(address _vaultAddress) external onlyOwner {
        vaultRewardAddress = payable(_vaultAddress);
        _isExcludedFromFee[vaultRewardAddress] = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function enableTransferFee(bool _enabled) external onlyOwner {
        transferFee = _enabled;
    }

    function changeRouterVersion(address _router)
        external
        onlyOwner
        returns (address _pair)
    {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);

        _pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        if (_pair == address(0)) {
            // Pair doesn't exist
            _pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
                address(this),
                _uniswapV2Router.WETH()
            );
        }
        uniswapV2Pair = _pair;

        // Set the router of the contract variables
        uniswapV2Router = _uniswapV2Router;
    }

    // for stuck tokens of other types
    function transferForeignToken(address _token, address _to)
        external
        onlyOwner
        returns (bool _sent)
    {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    //Create additional liquidity using  tokens in contract
    function manualSwapAndLiquifyTokens(uint256 tokenLiquifyAmount)
        external
        lockTheSwap
        onlyOwner
    {
        addLiquidityToToken(tokenLiquifyAmount);
    }

    function setBuyFee(
        uint256 _buyHolderPercent,
        uint256 _buyRewardsPercent,
        uint256 _buyMarketingPercent,
        uint256 _buyDevelopmentPercent,
        uint256 _buyLiquidityPercent
    ) external onlyOwner {
        require(
            (_buyHolderPercent +
                _buyLiquidityPercent +
                _buyRewardsPercent +
                _buyMarketingPercent +
                _buyDevelopmentPercent) <= 10,
            "Total Buy Percent Should be less than 10%"
        );

        _buyTaxFee = _buyHolderPercent;
        _buyRewardFee = _buyRewardsPercent;
        _buyMarketingFee = _buyMarketingPercent;
        _buyDevelopmentFee = _buyDevelopmentPercent;
        _buyLiqFee = _buyLiquidityPercent;

        _buyLiquidityFee =
            _buyLiquidityPercent +
            _buyRewardsPercent +
            _buyMarketingPercent +
            _buyDevelopmentPercent;
        emit BuyTaxFeeUpdated(_buyLiquidityFee);
    }

    function setSellFee(
        uint256 _sellHolderPercent,
        uint256 _sellRewardsPercent,
        uint256 _sellMarketingPercent,
        uint256 _sellDevelopmentPercent,
        uint256 _sellLiquidityPercent
    ) external onlyOwner {
        require(
            (_sellHolderPercent +
                _sellLiquidityPercent +
                _sellMarketingPercent +
                _sellRewardsPercent +
                _sellDevelopmentPercent) <= 20,
            "Total Sell Percent Should be less than 20%"
        );
        _sellTaxFee = _sellHolderPercent;
        _sellRewardFee = _sellRewardsPercent;
        _sellMarketingFee = _sellMarketingPercent;
        _sellDevelopmentFee = _sellDevelopmentPercent;
        _sellLiqFee = _sellLiquidityPercent;

        _sellLiquidityFee =
            _sellLiquidityPercent +
            _sellMarketingPercent +
            _sellRewardsPercent +
            _sellDevelopmentPercent;
        emit SellTaxFeeUpdated(_sellLiquidityFee);
    }

    function setTransferFee(
        uint256 _holderPercent,
        uint256 _rewardPercent,
        uint256 _marketingPercent,
        uint256 _devPercent,
        uint256 _liquidityPercent
    ) external onlyOwner {
        require(
            (_holderPercent +
                _liquidityPercent +
                _rewardPercent +
                _marketingPercent +
                _devPercent) <= 10,
            "Total Tax Percent Should be less than 10%"
        );
        _taxFee = _holderPercent;
        _sellRewardFee = _rewardPercent;
        _sellMarketingFee = _marketingPercent;
        _sellDevelopmentFee = _devPercent;
        _liqFee = _liquidityPercent;

        _liquidityFee =
            _liquidityPercent +
            _rewardPercent +
            _marketingPercent +
            _devPercent;
        emit InternalTaxFeeUpdated(_liquidityFee);
    }

    /* Turn on or Off the Trading Option */
    function setTradingOpen(bool _status) external onlyOwner {
        require(
            tradingSetter == msg.sender,
            "Ownership of Trade Setter Renounced"
        );
        tradingOpen = _status;
    }

    /* Renounce Trading Setter Address */
    /* Note : Once Renounced trading cant be closed */
    function renounceTradingOwner() external onlyOwner {
        require(
            tradingOpen == true,
            "Trading Must be turned on before Renouncing Ownership"
        );
        tradingSetter = address(0);
    }

    // Recommended : For stuck tokens (as a result of slight miscalculations/rounding errors)
    function SweepStuck(uint256 _amount) external onlyOwner {
        payable(owner()).transfer(_amount);
    }

    function UpdateMaxWalletHoldingPercentage(uint256 maxWalletPercentage)
        external
        onlyOwner
    {
        require(
            maxWalletPercentage >= 1,
            "Percentage should be greater or equal to 1%"
        );
        _maxWalletHoldingLimit = _tTotal.mul(maxWalletPercentage).div(10**2);
        emit MaxWalletHoldingAmountUpdated(_maxWalletHoldingLimit);
    }

    /* OWNER FUNCTION ENDS */
}