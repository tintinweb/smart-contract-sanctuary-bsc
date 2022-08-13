/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


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

// File: contracts/UP_Token.sol

/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/


pragma solidity ^0.8.7;



interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
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

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakePair {
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

interface EthWarp {
    function withdraw(address erc20) external returns(bool);
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public _marketAddress; // 营销钱包
    address public _valueAddress; // 市值钱包
    address public _subTokenAddress; // 子币底池预留

    address private warp;

    //（100% = 10000）
    // 1.5%LP分红（买分本币，卖分U）
    uint256 public _lpFee;

    // 0.5%LP令牌分营销钱包
    uint256 public _marketLpFee; 

    // 1%营销钱包（买分本币，卖分U）
    uint256 public _marketFee; 

    // 1.25%市值钱包（买分本币，卖分U）
    uint256 public _valueFee;

    // 0.75%子币底池预留（买分本币，卖分U）
    uint256 public _subTokenFee;


    uint256 public _startTradeBlock;
    
    uint256 public _maxBalanceAmount; // 最大持币余额10

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    // 全局买卖开关, 打开后不能买卖
    bool private globalFlag = false;


    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList; // 黑名单就是指定地址不能交易
    mapping(address => bool) private _swapPairList;
    uint256 private constant MAX = ~uint256(0);
    address private _mainPair;
    address private _usdt;
    address private _routerAddress;

    constructor (
        string memory tokenName, 
        string memory tokenSymbol, 
        uint8 tokenDecimals, 
        uint256 tokenSupply, 
        address routerAddress, 
        address usdtAddress, 
        address marketAddress,
        address valueAddress, 
        address subTokenAddress){

        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;

        _lpFee = 150;       // 1.5%LP分红（买分本币，卖分U）
        _marketLpFee = 50;  // 0.5%LP令牌分营销钱包（没有LP令牌，买分本币，卖分U）
        _valueFee = 125;    // 1.25%市值钱包（买分本币，卖分U）
        _subTokenFee = 75;  // 0.75%子币底池预留（买分本币，卖分U）
        _marketFee = 100;  // 0.75%子币底池预留（买分本币，卖分U）

        _routerAddress = routerAddress;
        ISwapRouter swapRouter = ISwapRouter(routerAddress);
        address usdt = usdtAddress;

        _usdt = usdt;
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(usdtAddress).approve(address(swapRouter), MAX);

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;

        _mainPair = usdtPair;

        uint256 total = tokenSupply * 10 ** tokenDecimals;
        _totalSupply = total;
        _maxBalanceAmount = total;
        _balances[owner()] = total;
        emit Transfer(address(0), owner(), total);

        _subTokenAddress = subTokenAddress;
        _valueAddress = valueAddress;
        _marketAddress = marketAddress;

        _feeWhiteList[_marketAddress] = true;
        _feeWhiteList[valueAddress] = true;
        _feeWhiteList[subTokenAddress] = true;
        _feeWhiteList[owner()] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function setFlag(bool flag) external onlyOwner {
        globalFlag = flag;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UP: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UP: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        // 黑名单只能转账到创始人钱包
        if (_blackList[from] == true) {
            require(to==owner(), "ERC20: if block list address just transfer to contract owner");
        }
        require(_blackList[to]==false, "ERC20: from or to in not allowed list");

        // 全局买卖开关
        require(globalFlag==false, "ERC20: global flag is disable translate");

        // 往池子转入时检查, 最大10枚, 白名单除外
        if(!_swapPairList[to]){
            require(_maxBalanceAmount >= (balanceOf(to) + amount), "exceed maxBalanceAmount");
        }

        // 4小时之内，卖燃烧9999/10000进燃烧钱包
        if (block.number < _startTradeBlock + 4800 && _swapPairList[to] && !_feeWhiteList[to] && !_feeWhiteList[from]) {
            _tokenTransfer(from, _marketAddress, amount*9999/10000, 0);
            _tokenTransfer(from, to, amount*1/10000, 0);
            return;
        }
        if (amount >= balanceOf(from)) { // 全转出
            uint256 remainAmount = 10 ** (_decimals - 4); // 0.00001
            if (amount < remainAmount) {
                require(amount>=remainAmount, "shuld leave 0.00001 in your address"); // 一点都不让转出了
            } else {
                amount -= remainAmount;
            }
        }
        if (_feeWhiteList[from] || _feeWhiteList[to]){
            // from和to有一个是白名单用户就不扣手续费，正常转账
            _tokenTransfer(from, to, amount, 0);
        }else{

            if (_swapPairList[from]) { // 买币

                _tokenTransfer(from, _mainPair,         amount*_lpFee/10000, 0); //        1.5 % LP池子分红

                _tokenTransfer(from, _marketAddress,    amount*_marketLpFee/10000, 0);//   0.5 % LP令牌分营销钱包

                _tokenTransfer(from, _valueAddress,     amount*_valueFee/10000, 0); //      1.25% 市值钱包

                _tokenTransfer(from, _subTokenAddress,  amount*_subTokenFee/10000, 0); //      0.75% 子币低池预留

                _tokenTransfer(from, _marketAddress,    amount*_marketFee/10000, 0);//   1.0 % 分营销钱包  

                _tokenTransfer(from, to, amount*(10000-_lpFee-_marketLpFee-_valueFee-_subTokenFee-_marketFee)/10000, 0); // 实际到帐

            } else if (_swapPairList[to]) { //卖币, 分U

                _tokenTransfer(from, _mainPair,         amount*_lpFee/10000, 0); //        1.5 % LP池子分红

                _tokenTransfer(from, address(this),    amount*_marketLpFee/10000, 0);//   0.5 % LP令牌分营销钱包
                swapTokensForOther(balanceOf(address(this)), _marketAddress);

                _tokenTransfer(from, address(this),     amount*_valueFee/10000, 0); //      1.25% 市值钱包
                swapTokensForOther(amount*_valueFee/10000, _valueAddress);

                _tokenTransfer(from, address(this),  amount*_subTokenFee/10000, 0); //      0.75% 子币低池预留
                swapTokensForOther(amount*_subTokenFee/10000, _subTokenAddress);

                _tokenTransfer(from, address(this),    amount*_marketFee/10000, 0);//   1.0 % 分营销钱包 
                swapTokensForOther(amount*_marketFee/10000, _marketAddress); 

                _tokenTransfer(from, to, amount*(10000-_lpFee-_marketLpFee-_valueFee-_subTokenFee-_marketFee)/10000, 0); // 实际到帐
            
            } else{
                // 普通转账
                _tokenTransfer(from, to, amount, 0);
            }
        }

    }

    function swapTokensForOther(uint256 tokenAmount, address to) private {
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_usdt);
        ISwapRouter(_routerAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }
    
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (fee > 0) {
            feeAmount = tAmount * fee / 100;
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    //////////// address api
    function setMarketAddress(address addr) external onlyOwner {
        _marketAddress = addr;       
        _feeWhiteList[addr] = true;
    }
    function setSubTokenAddress(address addr) external onlyOwner {
        _subTokenAddress = addr;
        _feeWhiteList[addr] = true;
    }
    function setValueAddress(address addr) external onlyOwner {
        _valueAddress = addr;
        _feeWhiteList[addr] = true;
    }

    ///////// fee api
    function setLpFee(uint256 fee) external onlyOwner {
        require(fee < 10000, "fee should less than 10000");
        _lpFee = fee;      
    }
    function setMarketLpFee(uint256 fee) external onlyOwner {
        require(fee < 10000, "fee should less than 10000");
        _marketLpFee = fee;      
    }
    function setMarketFee(uint256 fee) external onlyOwner {
        require(fee < 10000, "fee should less than 10000");
        _marketFee = fee;      
    }
    function setValueFee(uint256 fee) external onlyOwner {
        require(fee < 10000, "fee should less than 10000");
        _valueFee = fee;
    }
    function setSubTokenFee(uint256 fee) external onlyOwner {
        require(fee < 10000, "fee should less than 10000");
        _subTokenFee = fee;
    }

    function setMaxBalanceAmount(uint256 amount) external onlyOwner {
        _maxBalanceAmount = amount;
    }
    // 白名单地址免手续费
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }  
	
	function changeSwapWarp(address _warp) external onlyOwner {
        warp = _warp;
    }

    function warpWithdraw(address _token) external onlyOwner {
        EthWarp(warp).withdraw(_token);
    } 
    
    // 设置黑名单，不能交易
    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }   
    
    function startTrade() external onlyOwner {
        require(0 == _startTradeBlock, "trading");
        _startTradeBlock = block.number;
    }
    function closeTrade() external onlyOwner {
        _startTradeBlock = 0;
    }

    receive() external payable {}
}

contract UP is AbsToken {
    constructor() AbsToken(
        "UP",
        "UP",
        9,
        2500, // 2500
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // PancakeSwap: Router v2
        address(0x55d398326f99059fF775485246999027B3197955), // USDT
        address(0xa01D6DdFa62503A83a1bE9e962751ed815ad3a10), // 市场
        address(0x18D7c787096F62079771806194eED52bdBE426Af), // 市值
        address(0xa276ec83F9b248Fa02119EBf9B21C82E857C563f) // sub token  
    ){

    }
}