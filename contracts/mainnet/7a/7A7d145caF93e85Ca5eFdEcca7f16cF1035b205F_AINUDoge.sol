/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

pragma solidity >=0.5.0;

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

pragma solidity >=0.6.2;

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

pragma solidity >=0.6.2;

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

contract AINUDoge is Context, IERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private _uniswapV2Router;

    mapping (address => uint) private _cooldown;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedMaxTransactionAmount;
    mapping (address => bool) private _isBlacklisted;

    bool public tradingOpen;
    bool private _swapping;
    bool public swapEnabled = false;
    bool public cooldownEnabled = false;
    bool public feesEnabled = true;

    string private constant _name = "AINUDoge";
    string private constant _symbol = "AINU";

    uint8 private constant _decimals = 18;

    uint256 private constant _totalSupply = 1_000_000_000_000 * (10**_decimals);

    uint256 public maxBuyAmount = _totalSupply;
    uint256 public maxSellAmount = _totalSupply;
    uint256 public maxWalletAmount = _totalSupply;

    uint256 public tradingOpenBlock = 0;
    uint256 private _blocksToBlacklist = 0;
    uint256 private _cooldownBlocks = 1;

    uint256 public constant FEE_DIVISOR = 1000;
    uint256 public buyMarketingFee = 40;
    uint256 private _previousBuyMarketingFee = buyMarketingFee;
    uint256 public buyGrowthFee = 15;
    uint256 private _previousBuyGrowthFee = buyGrowthFee;
    uint256 public buyLiquidityFee = 10;
    uint256 private _previousBuyLiquidityFee = buyLiquidityFee;
    uint256 public buyecosystemFee = 15;
    uint256 private _previousBuyecosystemFee = buyecosystemFee;
    
    uint256 public sellMarketingFee = 50;
    uint256 private _previousSellMarketingFee = sellMarketingFee;
    uint256 public sellGrowthFee = 20;
    uint256 private _previousSellGrowthFee = sellGrowthFee;
    uint256 public sellLiquidityFee = 10;
    uint256 private _previousSellLiquidityFee = sellLiquidityFee;
    uint256 public sellecosystemFee = 20;
    uint256 private _previousSellecosystemFee = sellecosystemFee;

    uint256 private _tokensForMarketing;
    uint256 private _tokensForGrowth;
    uint256 private _tokensForLiquidity;
    uint256 private _tokensForecosystem;
    uint256 private _swapTokensAtAmount = 0;

    address payable private _marketingWallet = payable(0x00eC55A11e61826622fd8c9fda51d3A61B0Cb21C);
    address payable private _growthWallet = payable(0x7068C898eb5Ad86C3b5A2A4408EEE7900264adE6);
    address payable private _ecosystemWallet = payable(0x3a9802F498F2D797F4C536Aa7Ee7F4C3680CFaeE);
    address payable private _liquidityWallet = payable(0x392F3fB6216d34e792DE07B5A5142c84e22fB18D);
    address private _uniswapV2Pair;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;
    
    constructor () {
        _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _approve(address(this), address(_uniswapV2Router), _totalSupply);
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        IERC20(_uniswapV2Pair).approve(address(_uniswapV2Router), type(uint).max);

        _balances[_msgSender()] = _totalSupply;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[_marketingWallet] = true;
        _isExcludedFromFees[_growthWallet] = true;
        _isExcludedFromFees[_ecosystemWallet] = true;
        _isExcludedFromFees[_liquidityWallet] = true;

        _isExcludedMaxTransactionAmount[owner()] = true;
        _isExcludedMaxTransactionAmount[address(this)] = true;
        _isExcludedMaxTransactionAmount[DEAD] = true;
        _isExcludedMaxTransactionAmount[_marketingWallet] = true;
        _isExcludedMaxTransactionAmount[_growthWallet] = true;
        _isExcludedMaxTransactionAmount[_ecosystemWallet] = true;
        _isExcludedMaxTransactionAmount[_liquidityWallet] = true;

        emit Transfer(ZERO, _msgSender(), _totalSupply);
    }

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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function setCooldownEnabled(bool onoff) public onlyOwner {
        cooldownEnabled = onoff;
    }

    function setSwapEnabled(bool onoff) public onlyOwner {
        swapEnabled = onoff;
    }

    function setFeesEnabled(bool onoff) public onlyOwner {
        feesEnabled = onoff;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != ZERO, "ERC20: approve from the zero address");
        require(spender != ZERO, "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != ZERO, "ERC20: transfer from the zero address");
        require(to != ZERO, "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = false;
        bool shouldSwap = false;
        if (from != owner() && to != owner() && to != ZERO && to != DEAD && !_swapping) {
            require(!_isBlacklisted[from] && !_isBlacklisted[to]);

            if(!tradingOpen) require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not allowed yet.");

            if (cooldownEnabled) {
                if (to != address(_uniswapV2Router) && to != address(_uniswapV2Pair)) {
                    require(_cooldown[tx.origin] < block.number - _cooldownBlocks && _cooldown[to] < block.number - _cooldownBlocks, "Transfer delay enabled. Try again later.");
                    _cooldown[tx.origin] = block.number;
                    _cooldown[to] = block.number;
                }
            }

            if (from == _uniswapV2Pair && to != address(_uniswapV2Router) && !_isExcludedMaxTransactionAmount[to]) {
                require(amount <= maxBuyAmount, "Transfer amount exceeds the maxBuyAmount.");
                require(balanceOf(to) + amount <= maxWalletAmount, "Exceeds maximum wallet token amount.");
            }
            
            if (to == _uniswapV2Pair && from != address(_uniswapV2Router) && !_isExcludedMaxTransactionAmount[from]) {
                require(amount <= maxSellAmount, "Transfer amount exceeds the maxSellAmount.");
                shouldSwap = true;
            }
        }

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || !feesEnabled) takeFee = false;

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = (contractTokenBalance > _swapTokensAtAmount) && shouldSwap;

        if (canSwap && swapEnabled && !_swapping && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            _swapping = true;
            swapBack();
            _swapping = false;
        }

        _tokenTransfer(from, to, amount, takeFee, shouldSwap);
    }

    function swapBack() private {
        bool success;
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap =  _tokensForMarketing.add(_tokensForGrowth).add(_tokensForLiquidity).add(_tokensForecosystem);
        
        if (contractBalance == 0 || totalTokensToSwap == 0) return;

        if (contractBalance > _swapTokensAtAmount.mul(5)) contractBalance = _swapTokensAtAmount.mul(5);

        uint256 liquidityTokens = contractBalance.mul(_tokensForLiquidity).div(totalTokensToSwap).div(2);
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForETH(amountToSwapForETH);
        
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForMarketing = ethBalance.mul(_tokensForMarketing).div(totalTokensToSwap);
        uint256 ethForGrowth = ethBalance.mul(_tokensForGrowth).div(totalTokensToSwap);
        uint256 ethForecosystem = ethBalance.mul(_tokensForecosystem).div(totalTokensToSwap);
        uint256 ethForLiquidity = ethBalance.sub(ethForMarketing).sub(ethForGrowth).sub(ethForecosystem);
        
        _tokensForMarketing = 0;
        _tokensForGrowth = 0;
        _tokensForLiquidity = 0;
        _tokensForecosystem = 0;

        if(liquidityTokens > 0 && ethForLiquidity > 0) _addLiquidity(liquidityTokens, ethForLiquidity);

        (success,) = address(_growthWallet).call{value: ethForGrowth}("");
        (success,) = address(_ecosystemWallet).call{value: ethForecosystem}("");
        (success,) = address(_marketingWallet).call{value: address(this).balance}("");
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _liquidityWallet,
            block.timestamp
        );
    }
        
    function sendETHToFee(uint256 amount) private {
        _marketingWallet.transfer(amount.div(2));
        _growthWallet.transfer(amount.div(2));
    }

    function isBlacklisted(address wallet) external view returns (bool) {
        return _isBlacklisted[wallet];
    }

    function openTrading(uint256 blocks) public onlyOwner() {
        require(!tradingOpen, "Trading is already open");
        swapEnabled = true;
        cooldownEnabled = true;
        maxSellAmount = _totalSupply.mul(25).div(10000);
        maxBuyAmount = _totalSupply.mul(25).div(10000);
        maxWalletAmount = _totalSupply.mul(50).div(10000);
        _swapTokensAtAmount = _totalSupply.mul(1).div(10000);
        tradingOpen = true;
        tradingOpenBlock = block.number;
        _blocksToBlacklist = blocks;
    }

    function setMaxBuyAmount(uint256 maxBuy) public onlyOwner {
        require(maxBuy >= (totalSupply().mul(1).div(10000)), "Max buy amount cannot be lower than 0.01% total supply.");
        maxBuyAmount = maxBuy;
    }

    function setMaxSellAmount(uint256 maxSell) public onlyOwner {
        require(maxSell >= (totalSupply().mul(1).div(10000)), "Max sell amount cannot be lower than 0.01% total supply.");
        maxSellAmount = maxSell;
    }
    
    function setMaxWalletAmount(uint256 maxToken) public onlyOwner {
        require(maxToken >= (totalSupply().mul(1).div(1000)), "Max wallet amount cannot be lower than 0.1% total supply.");
        maxWalletAmount = maxToken;
    }
    
    function setSwapTokensAtAmount(uint256 swapAmount) public onlyOwner {
        require(swapAmount >= (totalSupply().mul(1).div(100000)), "Swap amount cannot be lower than 0.001% total supply.");
        require(swapAmount <= (totalSupply().mul(5).div(1000)), "Swap amount cannot be higher than 0.5% total supply.");
        _swapTokensAtAmount = swapAmount;
    }

    function setMarketingWallet(address _marketingWalletAddy) public onlyOwner {
        require(_marketingWalletAddy != ZERO, "_marketingWallet address cannot be 0");
        _isExcludedFromFees[_marketingWallet] = false;
        _isExcludedMaxTransactionAmount[_marketingWallet] = false;
        _marketingWallet = payable(_marketingWalletAddy);
        _isExcludedFromFees[_marketingWallet] = true;
        _isExcludedMaxTransactionAmount[_marketingWallet] = true;
    }

    function setgrowthWallet(address _growthWalletAddy) public onlyOwner {
        require(_growthWalletAddy != ZERO, "_growthWallet address cannot be 0");
        _isExcludedFromFees[_growthWallet] = false;
        _isExcludedMaxTransactionAmount[_growthWallet] = false;
        _growthWallet = payable(_growthWalletAddy);
        _isExcludedFromFees[_growthWallet] = true;
        _isExcludedMaxTransactionAmount[_growthWallet] = true;
    }

    function setecosystemWallet(address _ecosystemWalletAddy) public onlyOwner {
        require(_ecosystemWalletAddy != ZERO, "_ecosystemWalletAddy address cannot be 0");
        _isExcludedFromFees[_ecosystemWallet] = false;
        _isExcludedMaxTransactionAmount[_ecosystemWallet] = false;
        _ecosystemWallet = payable(_ecosystemWalletAddy);
        _isExcludedFromFees[_ecosystemWallet] = true;
        _isExcludedMaxTransactionAmount[_ecosystemWallet] = true;
    }

    function setLiquidityWallet(address _liquidityWalletAddy) public onlyOwner {
        require(_liquidityWalletAddy != ZERO, "_liquidityWalletAddy address cannot be 0");
        _isExcludedFromFees[_liquidityWallet] = false;
        _isExcludedMaxTransactionAmount[_liquidityWallet] = false;
        _liquidityWallet = payable(_liquidityWalletAddy);
        _isExcludedFromFees[_liquidityWallet] = true;
        _isExcludedMaxTransactionAmount[_liquidityWallet] = true;
    }

    function setExcludedFromFees(address[] memory accounts, bool isEx) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) _isExcludedFromFees[accounts[i]] = isEx;
    }
    
    function setExcludeFromMaxTransaction(address[] memory accounts, bool isEx) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) _isExcludedMaxTransactionAmount[accounts[i]] = isEx;
    }
    
    function setBlacklisted(address[] memory accounts, bool exempt) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            if(accounts[i] != _uniswapV2Pair) _isBlacklisted[accounts[i]] = exempt;
        }
    }

    function setBuyFee(uint256 newBuyMarketingFee, uint256 newBuyGrowthFee, uint256 newBuyLiquidityFee, uint256 newBuyecosystemFee) public onlyOwner {
        require(newBuyMarketingFee.add(newBuyGrowthFee).add(newBuyLiquidityFee).add(newBuyecosystemFee) <= 200, "Must keep buy taxes below 30%");
        buyMarketingFee = newBuyMarketingFee;
        buyGrowthFee = newBuyGrowthFee;
        buyLiquidityFee = newBuyLiquidityFee;
        buyecosystemFee = newBuyecosystemFee;
    }

    function setSellFee(uint256 newSellMarketingFee, uint256 newSellGrowthFee, uint256 newSellLiquidityFee, uint256 newSellecosystemFee) public onlyOwner {
        require(newSellMarketingFee.add(newSellGrowthFee).add(newSellLiquidityFee).add(newSellecosystemFee) <= 200, "Must keep sell taxes below 30%");
        sellMarketingFee = newSellMarketingFee;
        sellGrowthFee = newSellGrowthFee;
        sellLiquidityFee = newSellLiquidityFee;
        sellecosystemFee = newSellecosystemFee;
    }

    function setCooldownBlocks(uint256 blocks) public onlyOwner {
        require(blocks >= 0 && blocks <= 10, "Invalid blocks count.");
        _cooldownBlocks = blocks;
    }

    function removeAllFee() private {
        if (buyMarketingFee == 0 && buyGrowthFee == 0 && buyLiquidityFee == 0 && buyecosystemFee == 0 && sellMarketingFee == 0 && sellGrowthFee == 0 && sellLiquidityFee == 0 && sellecosystemFee == 0) return;

        _previousBuyMarketingFee = buyMarketingFee;
        _previousBuyGrowthFee = buyGrowthFee;
        _previousBuyLiquidityFee = buyLiquidityFee;
        _previousBuyecosystemFee = buyecosystemFee;
        _previousSellMarketingFee = sellMarketingFee;
        _previousSellGrowthFee = sellGrowthFee;
        _previousSellLiquidityFee = sellLiquidityFee;
        _previousSellecosystemFee = sellecosystemFee;
        
        buyMarketingFee = 0;
        buyGrowthFee = 0;
        buyLiquidityFee = 0;
        buyecosystemFee = 0;
        sellMarketingFee = 0;
        sellGrowthFee = 0;
        sellLiquidityFee = 0;
        sellecosystemFee = 0;
    }
    
    function restoreAllFee() private {
        buyMarketingFee = _previousBuyMarketingFee;
        buyGrowthFee = _previousBuyGrowthFee;
        buyLiquidityFee = _previousBuyLiquidityFee;
        buyecosystemFee = _previousBuyecosystemFee;
        sellMarketingFee = _previousSellMarketingFee;
        sellGrowthFee = _previousSellGrowthFee;
        sellLiquidityFee = _previousSellLiquidityFee;
        sellecosystemFee = _previousSellecosystemFee;
    }
        
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool isSell) private {
        if (!takeFee) removeAllFee();
        else amount = _takeFees(sender, amount, isSell);

        _transferStandard(sender, recipient, amount);
        
        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _takeFees(address sender, uint256 amount, bool isSell) private returns (uint256) {
        uint256 _totalFees;
        uint marketing;
        uint Growth;
        uint liq;
        uint ecosystem;
        if(tradingOpenBlock + _blocksToBlacklist >= block.number) {
            _totalFees = _getBotFees();
            marketing = _getBotMarketingFees();
            Growth = _getBotGrowthFees();
            liq = _getBotLiquidityFees();
            ecosystem = _getBotecosystemFees();
        } else {
            _totalFees = _getTotalFees(isSell);
            if (isSell) {
                marketing = sellMarketingFee;
                Growth = sellGrowthFee;
                liq = sellLiquidityFee;
                ecosystem = sellecosystemFee;
            } else {
                marketing = buyMarketingFee;
                Growth = buyGrowthFee;
                liq = buyLiquidityFee;
                ecosystem = buyecosystemFee;
            }
        }
        
        uint256 fees;
        if (_totalFees > 0) {
            fees = amount.mul(_totalFees).div(FEE_DIVISOR);
            _tokensForMarketing += fees * marketing / _totalFees;
            _tokensForGrowth += fees * Growth / _totalFees;
            _tokensForLiquidity += fees * liq / _totalFees;
            _tokensForecosystem += fees * ecosystem / _totalFees;
        }

        if (fees > 0) _transferStandard(sender, address(this), fees);

        return amount -= fees;
    }

    function _getTotalFees(bool isSell) private view returns(uint256) {
        if (isSell) return sellMarketingFee.add(sellGrowthFee).add(sellLiquidityFee).add(sellecosystemFee);
        return buyMarketingFee.add(buyGrowthFee).add(buyLiquidityFee).add(buyecosystemFee);
    }

    function _getBotFees() private pure returns(uint256) {
        return 888;
    }

    function _getBotMarketingFees() private pure returns(uint256) {
        return 222;
    }

    function _getBotGrowthFees() private pure returns(uint256) {
        return 222;
    }

    function _getBotLiquidityFees() private pure returns(uint256) {
        return 222;
    }

    function _getBotecosystemFees() private pure returns(uint256) {
        return 222;
    }

    receive() external payable {}
    fallback() external payable {}
    
    function unclog() public onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForETH(contractBalance);
    }
    
    function distributeFees() public onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function withdrawStuckETH() public onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function withdrawStuckTokens(address tkn) public onlyOwner {
        require(tkn != address(this), "Cannot withdraw this token");
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
    }

    function removeLimits() public onlyOwner {
        maxBuyAmount = _totalSupply;
        maxSellAmount = _totalSupply;
        maxWalletAmount = _totalSupply;
        cooldownEnabled = false;
    }

}