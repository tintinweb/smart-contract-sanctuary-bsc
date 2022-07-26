/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed
interface IBEP20 {

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
interface IPancakeFactory {
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

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract T34 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public _isBlackList;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public _isLPHolderExist;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000 * (1e9);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "T34";
    string private _symbol = "T34";
    uint8 private _decimals = 9;

    uint256 public buyLpDividendFee = 0;
    uint256 private previousBuyLpDividendFee = buyLpDividendFee;
    uint256 public buyHoldersDividendFee = 3;
    uint256 private previousBuyHoldersDividendFee = buyHoldersDividendFee;
    uint256 public buyMarketingFee = 0;
    uint256 private previousBuyMarketingFee = buyMarketingFee;
    uint256 public buyLiquidityFee = 0;
    uint256 private previousBuyLiquidityFee = buyLiquidityFee;

    uint256 public sellLpDividendFee = 0;
    uint256 private previousSellLpDividendFee = sellLpDividendFee;
    uint256 public sellHoldersDividendFee = 0;
    uint256 private previousSellHoldersDividendFee = sellHoldersDividendFee;
    uint256 public sellMarketingFee = 1;
    uint256 private previousSellMarketingFee = sellMarketingFee;
    uint256 public sellLiquidityFee = 4;
    uint256 private previousSellLiquidityFee = sellLiquidityFee;

    uint256 public transferFee = 0;
    uint256 private previousTransferFee = transferFee;

    uint256 private numTokensSellToAddToLiquidity = 10000*(1e9);
    uint256 public maxTxAmount = _tTotal;
    uint256 public numTokensSellToDividend = 0; 

    uint256 public timeOfLiquidityAdded;
    uint256 public lastProcessedIndex;
    bool private isLiquidityAdded;

    address public marketingAddrA = 0xcDBb310A1D3E35A9a2966b3138AC5e822187B3FE;
    address public marketingAddrB = 0x7029367Ea4F52E6f272D7C15b9e5f2e97988A94D;

   
    address public immutable pair;
    address private lastPotentialLPHolder;
    address[] public lpHolders;
    address[] private _excluded;

    IPancakeRouter02 public immutable router;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IPancakeRouter02 _router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        pair = IPancakeFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        // set the rest of the contract variables
        router = _router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingAddrA] = true;
        _isExcludedFromFee[marketingAddrB] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
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

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tLPDividend;
        uint256 tMarketing;
        if(sender == pair) {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, true);
        } else {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, false);
        }
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tLPDividend, tMarketing, _getRate());
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
       if(tLiquidity > 0) {
            _takeLiquidity(tLiquidity);
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tMarketing > 0) {
            _takeMarketing(tMarketing);
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLPDividend > 0) {
            _takeLPDividend(tLPDividend);
            emit Transfer(sender, address(this), tLPDividend);
        }
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setNumTokensSellToDividend(uint256 _numTokensSellToDividend) external onlyOwner() {
        numTokensSellToDividend = _numTokensSellToDividend;
    }

    function setBuyLpDividendFee(uint256 _buyLpDividendFee) external onlyOwner() {
        buyLpDividendFee = _buyLpDividendFee;
    }

    function setBuyHoldersDividendFee(uint256 _buyHoldersDividendFee) external onlyOwner() {
        buyHoldersDividendFee = _buyHoldersDividendFee;
    }
    
    function setBuyMarketingFee(uint256 _buyMarketingFee) external onlyOwner() {
        buyMarketingFee = _buyMarketingFee;
    }

    function setBuyLiquidityFee(uint256 _buyLiquidityFee) external onlyOwner() {
        buyLiquidityFee = _buyLiquidityFee;
    }

    function setSellLpDividendFee(uint256 _sellLpDividendFee) external onlyOwner() {
        sellLpDividendFee = _sellLpDividendFee;
    }

    function setSellHoldersDividendFee(uint256 _sellHoldersDividendFee) external onlyOwner() {
        sellHoldersDividendFee = _sellHoldersDividendFee;
    }
    
    function setSellMarketingFee(uint256 _sellMarketingFee) external onlyOwner() {
        sellMarketingFee = _sellMarketingFee;
    }

    function setSellLiquidityFee(uint256 _sellLiquidityFee) external onlyOwner() {
        sellLiquidityFee = _sellLiquidityFee;
    }

    function setTransferFee(uint256 _transferFee) external onlyOwner() {
        transferFee = _transferFee;
    }

    function addBlackList(address account, bool flag) external onlyOwner() {
        _isBlackList[account] = flag;
    }

    function setMaxTxAmount(uint256 _maxTxAmount) external onlyOwner() {
        maxTxAmount = _maxTxAmount;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getTValues(uint256 tAmount,bool flag) private view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount,flag);
        uint256 tLiquidity = calculateLiquidityFee(tAmount,flag);
        uint256 tLPDividend = calculateLpDividendFee(tAmount,flag);
        uint256 tMarketing = calculateMarketingFee(tAmount,flag);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        tTransferAmount = tTransferAmount.sub(tLPDividend).sub(tMarketing);
        return (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tLPDividend, uint256 tMarketing, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rLPDividend = tLPDividend.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rLPDividend).sub(rMarketing);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(rMarketing);
    }
    function _takeLPDividend(uint256 tLPDividend) private {
        uint256 currentRate =  _getRate();
        uint256 rLPDividend = tLPDividend.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLPDividend);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(rLPDividend);
    }
    
    function calculateTaxFee(uint256 _amount, bool flag) private view returns (uint256) {
        if(flag) {
            return _amount.mul(buyHoldersDividendFee).div(10**2);
        } else{
           return _amount.mul(sellHoldersDividendFee).div(10**2); 
        }
        
    }

    function calculateLiquidityFee(uint256 _amount, bool flag) private view returns (uint256) {
        if(flag) {
            return _amount.mul(buyLiquidityFee).div(10**2);
        } else {
            return _amount.mul(sellLiquidityFee).div(10**2);
        }
    }

    function calculateLpDividendFee(uint256 _amount, bool flag) private view returns (uint256) {
        if(flag) {
            return _amount.mul(buyLpDividendFee).div(10**2);
        } else {
            return _amount.mul(sellLpDividendFee).div(10**2);
        }
    }

    function calculateMarketingFee(uint256 _amount, bool flag) private view returns (uint256) {
        if(flag) {
            return _amount.mul(buyMarketingFee).div(10**2);
        } else {
            return _amount.mul(sellMarketingFee).div(10**2);
        }  
    }

    function removeAllFee() private {
        previousBuyLpDividendFee = buyLpDividendFee;
        previousBuyHoldersDividendFee = buyHoldersDividendFee;
        previousBuyMarketingFee = buyMarketingFee;
        previousBuyLiquidityFee = buyLiquidityFee;

        previousSellLpDividendFee = sellLpDividendFee;
        previousSellHoldersDividendFee = sellHoldersDividendFee;
        previousSellMarketingFee = sellMarketingFee;
        previousSellLiquidityFee = sellLiquidityFee;
        
        buyLpDividendFee = 0;
        buyHoldersDividendFee = 0;
        buyMarketingFee = 0;
        buyLiquidityFee = 0;

        sellLpDividendFee = 0;
        sellHoldersDividendFee = 0;
        sellMarketingFee = 0;
        sellLiquidityFee = 0;
    }
    
    function restoreAllFee() private {
        buyLpDividendFee = previousBuyLpDividendFee;
        buyHoldersDividendFee = previousBuyHoldersDividendFee;
        buyMarketingFee = previousBuyMarketingFee;
        buyLiquidityFee = previousBuyLiquidityFee;

        sellLpDividendFee = previousSellLpDividendFee;
        sellHoldersDividendFee = previousSellHoldersDividendFee;
        sellMarketingFee = previousSellMarketingFee;
        sellLiquidityFee = previousSellLiquidityFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
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
        require(!_isBlackList[from], "blc list");

        if(!isLiquidityAdded && to == pair) {
            timeOfLiquidityAdded = block.timestamp;
            isLiquidityAdded = true;
            lpHolders.push(from);
            _isLPHolderExist[from] = true;
        }
        
        if (from == pair){
            if (block.timestamp <= timeOfLiquidityAdded + 30){
                _isBlackList[to] = true;
            }
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwap &&
            from != pair
        ) {
            //swap , dividend to marketing ,LP holders ,add liquidity
            processSwap(contractTokenBalance);
        }

        if(lastPotentialLPHolder != address(0) && !_isLPHolderExist[lastPotentialLPHolder]) {
            uint256 lpAmount = IBEP20(pair).balanceOf(lastPotentialLPHolder);
            if(lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if(to == pair && from != address(this)) {
            lastPotentialLPHolder = from;
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        if(takeFee) {
            require(amount < maxTxAmount, "max tx amount limit");
        }
        if(from != pair && to != pair ) {
            _normalTokenTransfer(from,to,amount);
        } else {
            //transfer amount, it will take tax, liquidity fee
            _tokenTransfer(from,to,amount,takeFee);
        }  
    }

    function processSwap(uint256 contractTokenBalance) private lockTheSwap {
        uint256 lpDividendFee = buyLpDividendFee.add(sellLpDividendFee);
        uint256 marketingFee = buyMarketingFee.add(sellMarketingFee);
        uint256 liquidityFee = buyLiquidityFee.add(sellLiquidityFee);

        uint256 totalShare = lpDividendFee.add(marketingFee).add(liquidityFee);
        uint256 halfTokensForLiquidity = contractTokenBalance.mul(liquidityFee).div(totalShare).div(2);
       
        // split the contract balance into halves
        // uint256 half = contractTokenBalance.div(2);
        // uint256 otherHalf = contractTokenBalance.sub(half);

        // // capture the contract's current ETH balance.
        // // this is so that we can capture exactly the amount of ETH that the
        // // swap creates, and not make the liquidity event include any ETH that
        // // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(contractTokenBalance.sub(halfTokensForLiquidity)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 balanceForLiquidity = newBalance.mul(halfTokensForLiquidity).div(contractTokenBalance.sub(halfTokensForLiquidity));

        // add liquidity to uniswap
        addLiquidity(halfTokensForLiquidity, balanceForLiquidity);

        uint256 tokensForLPHodersSwaped = contractTokenBalance.mul(lpDividendFee).div(totalShare);
        uint256 balanceForLPHolders = newBalance.mul(tokensForLPHodersSwaped).div(contractTokenBalance.sub(halfTokensForLiquidity));
        dividendToLpHolders(balanceForLPHolders);

        uint256 halfForMarketing = (address(this).balance).div(2);
        (bool successA, ) = marketingAddrA.call{value: halfForMarketing}("");
        require(successA, 'BNB transfer failed');
        (bool successB, ) = marketingAddrB.call{value: halfForMarketing}("");
        require(successB, 'BNB transfer failed');
    }

    function dividendToLpHolders(uint256 rewards) private {
        if(rewards == 0) return;
        IBEP20 pairContract = IBEP20(pair);
        uint256 numberOfTokenHolders = lpHolders.length;	
        if(numberOfTokenHolders == 0) return;
        uint256 gas = 300000;
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 totalLPAmount = pairContract.totalSupply() - 1e3;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if(_lastProcessedIndex >= numberOfTokenHolders) {
                _lastProcessedIndex = 0;
            }

            address account = lpHolders[_lastProcessedIndex];
            uint256 LPAmount = pairContract.balanceOf(account); 
            if(LPAmount > 0) {
                uint256 reward = rewards.mul(LPAmount).div(totalLPAmount);
                if(reward == 0) { continue; }
                (bool success, ) = account.call{value: reward}("");
                require(success, 'BNB transfer failed');
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _normalTokenTransfer(address sender, address recipient, uint256 tAmount) private {
        uint256 currentRate =  _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 tTransferFeeAmount = 0;
        uint256 rTransferFeeAmount = 0;
        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient] && transferFee != 0) {
            tTransferFeeAmount = tAmount.mul(transferFee).div(100);
            rTransferFeeAmount = tTransferFeeAmount.mul(currentRate);
        } 

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rAmount.sub(rTransferFeeAmount));

            if(tTransferFeeAmount > 0) {
                _rOwned[address(this)] = _rOwned[address(this)].add(rTransferFeeAmount);
                if(_isExcluded[address(this)])
                    _tOwned[address(this)] = _tOwned[address(this)].add(tTransferFeeAmount);
                emit Transfer(sender, address(this), tTransferFeeAmount);
            }
            emit Transfer(sender, recipient, tAmount.sub(tTransferFeeAmount));
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tAmount.sub(tTransferFeeAmount));
            _rOwned[recipient] = _rOwned[recipient].add(rAmount.sub(rTransferFeeAmount)); 

            if(tTransferFeeAmount > 0) {
                _rOwned[address(this)] = _rOwned[address(this)].add(rTransferFeeAmount);
                if(_isExcluded[address(this)])
                    _tOwned[address(this)] = _tOwned[address(this)].add(tTransferFeeAmount);
                emit Transfer(sender, address(this), tTransferFeeAmount);
            }
            emit Transfer(sender, recipient, tAmount.sub(tTransferFeeAmount));
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rAmount.sub(rTransferFeeAmount));

            if(tTransferFeeAmount > 0) {
                _rOwned[address(this)] = _rOwned[address(this)].add(rTransferFeeAmount);
                if(_isExcluded[address(this)])
                    _tOwned[address(this)] = _tOwned[address(this)].add(tTransferFeeAmount);
                emit Transfer(sender, address(this), tTransferFeeAmount);
            }
            emit Transfer(sender, recipient, tAmount.sub(tTransferFeeAmount));
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tAmount.sub(tTransferFeeAmount));
            _rOwned[recipient] = _rOwned[recipient].add(rAmount.sub(rTransferFeeAmount));

            if(tTransferFeeAmount > 0) {
                _rOwned[address(this)] = _rOwned[address(this)].add(rTransferFeeAmount);
                if(_isExcluded[address(this)])
                    _tOwned[address(this)] = _tOwned[address(this)].add(tTransferFeeAmount);
                emit Transfer(sender, address(this), tTransferFeeAmount);
            }
            emit Transfer(sender, recipient, tAmount.sub(tTransferFeeAmount));
        } else {
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rAmount.sub(rTransferFeeAmount));

            if(tTransferFeeAmount > 0) {
                _rOwned[address(this)] = _rOwned[address(this)].add(rTransferFeeAmount);
                if(_isExcluded[address(this)])
                    _tOwned[address(this)] = _tOwned[address(this)].add(tTransferFeeAmount);
                emit Transfer(sender, address(this), tTransferFeeAmount);
            }
            emit Transfer(sender, recipient, tAmount.sub(tTransferFeeAmount));
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tLPDividend;
        uint256 tMarketing;
        if(sender == pair) {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, true);
        } else {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, false);
        }
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tLPDividend, tMarketing, _getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if(tLiquidity > 0) {
            _takeLiquidity(tLiquidity);
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tMarketing > 0) {
            _takeMarketing(tMarketing);
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLPDividend > 0) {
            _takeLPDividend(tLPDividend);
            emit Transfer(sender, address(this), tLPDividend);
        }
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tLPDividend;
        uint256 tMarketing;
        if(sender == pair) {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, true);
        } else {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, false);
        }
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tLPDividend, tMarketing, _getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        if(tLiquidity > 0) {
            _takeLiquidity(tLiquidity);
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tMarketing > 0) {
            _takeMarketing(tMarketing);
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLPDividend > 0) {
            _takeLPDividend(tLPDividend);
            emit Transfer(sender, address(this), tLPDividend);
        }
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tLPDividend;
        uint256 tMarketing;
        if(sender == pair) {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, true);
        } else {
            (tTransferAmount, tFee, tLiquidity, tLPDividend, tMarketing) = _getTValues(tAmount, false);
        }
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tLPDividend, tMarketing, _getRate());
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        if(tLiquidity > 0) {
            _takeLiquidity(tLiquidity);
            emit Transfer(sender, address(this), tLiquidity);
        }
        if(tMarketing > 0) {
            _takeMarketing(tMarketing);
            emit Transfer(sender, address(this), tMarketing);
        }
        if(tLPDividend > 0) {
            _takeLPDividend(tLPDividend);
            emit Transfer(sender, address(this), tLPDividend);
        }
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}