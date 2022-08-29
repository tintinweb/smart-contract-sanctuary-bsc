/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: lib/Operator.sol


pragma solidity ^0.8.0;


contract Operator is Ownable {
    address private _operator;
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }
    function operator() public view returns (address) {
        return _operator;
    }
    modifier onlyOperator() {
        require(_operator == msg.sender, 'operator: caller is not the operator');
        _;
    }
    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }
    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }
    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), 'operator: zero address given for new operator');
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

// File: lib/IUniswapV2Router01.sol


pragma solidity ^0.8.0;

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
// File: lib/IUniswapV2Router02.sol


pragma solidity ^0.8.0;


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
// File: lib/IUniswapV2Pair.sol


pragma solidity ^0.8.0;

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
// File: lib/IUniswapV2Factory.sol


pragma solidity ^0.8.0;

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
// File: lib/SafeMath.sol


pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: DeerDAO.sol


pragma solidity ^0.8.0;







interface IBoard {
    function allocateWithToken(uint256 amount) external;
    function allocate(uint256 amount) external;
    function stake(address account, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

interface IBind{
    function getReferrer(address account) external view returns(address);
}

contract Fomo5 {
    using SafeMath for uint256;
    address public dead = 0x000000000000000000000000000000000000dEaD;
    uint256 public procRoundIndex = 0;
    DeerDAO token = DeerDAO(msg.sender);
    constructor () {}
    function proc() external {
        require(msg.sender == address(token), "permission denied");
        if (token.roundIndex() != procRoundIndex) {
            uint256 roundLen = token.roundLen(procRoundIndex);
            uint256 tAmount = token.roundFomo5Amounts(procRoundIndex);
            if (roundLen == 0 || tAmount <= 1e17) {
                procRoundIndex++;
                return;
            }
            uint256 procMax = 10;
            if (roundLen < procMax) procMax = roundLen;
            uint256 amount = tAmount.div(procMax);
            uint256 nextProcIndex = roundLen - procMax;
            for (uint256 i = roundLen; i > nextProcIndex; i--) {
                address user = token.roundAddr(procRoundIndex, i - 1);
                token.transfer(user, amount);
            }
            procRoundIndex++;
        }
    }
}

contract Fomo100 {
    using SafeMath for uint256;
    address public dead = 0x000000000000000000000000000000000000dEaD;
    uint256 public procRoundIndex = 0;
    uint256 public procIndex = 0;
    uint256 public stepMax = 50;
    DeerDAO token = DeerDAO(msg.sender);
    constructor () {}
    function proc() external {
        require(msg.sender == address(token), "permission denied");
        if (token.roundIndex() != procRoundIndex) {
            uint256 roundLen = token.roundLen(procRoundIndex);
            uint256 tAmount = token.roundFomo100Amounts(procRoundIndex);
            if (roundLen == 0 || tAmount <= 1e17) {
                procRoundIndex++;
                return;
            }
            uint256 procMax = 100;
            if (roundLen < procMax) procMax = roundLen;
            uint256 amount = tAmount.div(procMax);
            uint256 step = stepMax;
            if (procIndex + step > procMax) step = procMax - procIndex;
            uint256 nextProcIndex = procIndex + step;
            for (uint256 i = procIndex; i < nextProcIndex; i++) {
                address user = token.roundAddr(procRoundIndex, roundLen.sub(i).sub(1));
                token.transfer(user, amount);
            }
            procIndex = nextProcIndex;
            if (procIndex == procMax) {
                procIndex = 0;
                procRoundIndex++;
            }
        }
    }
}

contract Node {
}

contract ReceiveUsdt is Ownable {
    IERC20 public usdt;
    constructor (address usdt_) {
        usdt = IERC20(usdt_);
    }

    function transferOut(address[] memory accounts) public onlyOwner{
        uint256 length = accounts.length;
        uint256 amount = usdt.balanceOf(address(this));
        for(uint i;i<length;i++){
            usdt.transfer(accounts[i], amount);
        }
    }
}

contract DeerDAO is IERC20, Operator {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;

    string private _name = "DeerDAO";
    string private _symbol = "DeerDAO";
    uint8 private _decimals = 18;

    mapping(address => bool) public pairList;
    mapping(address => bool) public isDelivers;
    mapping(address => bool) public isExcludedFromNode;
    mapping(address => bool) public isExcludedFromFomo;

    ReceiveUsdt public _receiveUsdt;
    address[] public receives;
    IERC20 public usdt;
    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;

    //buyFee
    uint256 public nodeFee = 5;
    uint256 public inviteFee = 2;
    uint256 public boxBoard30Fee = 3;
    uint256 public fomo5Fee = 2;
    uint256 public fomo100Fee = 3;
    //sellFee
    uint256 public nodeFeeSell = 3;
    uint256 public ecologyFee = 3;
    uint256 public nftFeeNormal = 6;
    uint256 public nftFeeRare = 3;

    uint256 public swapTime;
    bool public once = false;

    IERC20 public lpPool;
    address public node;
    Fomo5 public fomo5;
    Fomo100 public fomo100;
    IBoard public nftBoardNormal;
    IBoard public nftBoardRare;
    IBoard public boxBoard30;
    IBoard public boxBoard100;
    IBind public bind;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public numTokensSellToAddToLiquidity = 100 * 1e18;
    uint256 public total = 2100 * 1e4 * 1e18;
    address public dead = 0x000000000000000000000000000000000000dEaD;
    uint256 public toPool = 2059 * 1e4 * 1e18;

    //Node param
    uint256 public pairFee;  // /10000
    uint256 public nodeLimit = 700 * 1e18;  //USDT
    mapping(address => bool) public nodeWhiteList;
    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;
    uint256 currentIndex;
    uint256 public nodeHoldLimit = 1400 * 1e18;

    uint256 public distributorTime;
    uint256 public distributorGas = 300000;
    uint256 public minPeriod = 10 minutes;
    uint256 public minAmount = 0.05 * 1e18;
    uint256 public minBalance = 100 * 1e18;
    address private fromAddress;
    address private toAddress;

    uint256 public fomoDuration;
    uint256 public fomoLastTime;
    uint256 public fomoLimit = 200 * 1e18;  //USDT
    uint256 public fomoDiviendPct = 50;  // /100

    uint256 enterCount;
    mapping(uint256 => address[]) public rounds;
    mapping(uint256 => uint256) public roundFomo5Amounts;
    mapping(uint256 => uint256) public roundFomo100Amounts;
    uint256 public fomo5Amount = 0;
    uint256 public fomo100Amount = 0;
    uint256 public fomo5DivAmount = 0;
    uint256 public fomo100DivAmount = 0;
    uint256 public roundIndex = 0;
    uint256 public fomo5Limit = 1000 * 1e18;
    uint256 public fomo100Limit = 1000 * 1e18;

    mapping(address => bool) public isValid;
    mapping(address => uint256) public validNum;

    modifier transferCounter {
        enterCount = enterCount.add(1);
        _;
        enterCount = enterCount.sub(1, "transfer counter");
    }
    constructor (address _usdt, address _router, address[] memory _receives, address _receiveToken, uint256 _fomoDuration, uint256 _pairFee, uint256 _swapTime) {
        usdt = IERC20(_usdt);
        uniswapV2Router = IUniswapV2Router02(_router);
        fomo5 = new Fomo5();
        fomo100 = new Fomo100();
        node = address(new Node());
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), address(usdt));

        _receiveUsdt = new ReceiveUsdt(_usdt);
        receives = _receives;
        _mint(owner(), toPool);
        _mint(_receiveToken, total.sub(toPool));
        fomoDuration = _fomoDuration;
        pairFee = _pairFee;
        swapTime = _swapTime;

        pairList[uniswapV2Pair] = true;
        isDelivers[_receiveToken] = true;
        isDelivers[owner()] = true;
        isDelivers[address(this)] = true;
        isDelivers[address(fomo5)] = true;
        isDelivers[address(fomo100)] = true;
        isExcludedFromNode[dead] = true;
        isExcludedFromNode[address(uniswapV2Pair)] = true;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function changeFomoDuration(uint256 _fomoDuration) public onlyOwner {
        fomoDuration = _fomoDuration;
    }

    function setPool(address _nftBoardNormal, address _nftBoardRare, address _lpPool, address _boxBoard30, address _boxBoard100, address _bind) public onlyOwner {
        //普通NFT质押池(分nftFeeNormal)，稀缺NFT质押池(分nftFeeRare)，LP质押池(含质押爆块，需加余额来分lpFee)，
        //直推30合约(分boxBoard30Fee)，直推100合约(分fomo累计到限额的一半)
        nftBoardNormal = IBoard(_nftBoardNormal);
        nftBoardRare = IBoard(_nftBoardRare);
        lpPool = IERC20(_lpPool);
        isExcludedFromNode[_lpPool] = true;
        boxBoard30 = IBoard(_boxBoard30);
        boxBoard100 = IBoard(_boxBoard100);
        bind = IBind(_bind);
    }

    function changeMin(uint256 _distributorGas, uint256 _minPeriod, uint256 _minAmount, uint256 _minBalance) public onlyOwner {
        distributorGas = _distributorGas;
        minPeriod = _minPeriod;
        minAmount = _minAmount;
        minBalance = _minBalance;
    }

    function changeLimits(uint256 _fomoLimit, uint256 _nodeLimit, uint256 _nodeHoldLimit) public onlyOwner {
        fomoLimit = _fomoLimit;
        nodeLimit = _nodeLimit;
        nodeHoldLimit = _nodeHoldLimit;
    }

    //Token param change
    function setPairList(address[] memory addrs, bool flag) public onlyOwner() {
        for (uint i = 0; i < addrs.length; i++) {
            pairList[addrs[i]] = flag;
        }
    }

    function setDelivers(address[] memory addrs, bool flag) public onlyOwner() {
        for (uint i = 0; i < addrs.length; i++) {
            isDelivers[addrs[i]] = flag;
        }
    }

    function setExcludedFromNode(address[] memory addrs, bool flag) public onlyOwner() {
        for (uint i = 0; i < addrs.length; i++) {
            isExcludedFromNode[addrs[i]] = flag;
        }
    }

    function setExcludedFromFomo(address[] memory addrs, bool flag) public onlyOwner() {
        for (uint i = 0; i < addrs.length; i++) {
            isExcludedFromFomo[addrs[i]] = flag;
        }
    }

    function changeSwapAndLiquifyEnabled(bool _swapAndLiquifyEnabled) public onlyOwner() {
        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
    }

    function changeRouterAddress(address newRouter) public onlyOwner() {
        uniswapV2Router = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(usdt));
        pairList[uniswapV2Pair] = true;
    }

    function changeNumToAddToLiquidity(uint256 num) public onlyOwner() {
        numTokensSellToAddToLiquidity = num;
    }

    //Node param change
    function setNodeWhiteList(address[] memory addrs, bool flag) public onlyOwner() {
        for (uint i = 0; i < addrs.length; i++) {
            nodeWhiteList[addrs[i]] = flag;
        }
    }

    function roundLen(uint256 rIndex) public view returns (uint256) {
        return rounds[rIndex].length;
    }

    function roundAddr(uint256 rIndex, uint256 index) public view returns (address) {
        return rounds[rIndex][index];
    }

    function lpBalanceOf(address shareholder) public view returns (uint256){
        if (address(lpPool) != address(0)) {
            return IERC20(uniswapV2Pair).balanceOf(shareholder).add(lpPool.balanceOf(shareholder));
        } else {
            return IERC20(uniswapV2Pair).balanceOf(shareholder);
        }
    }

    function process(uint256 gas) private {
        address pool = node;
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;
        uint256 nowbanance = balanceOf(pool);
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            address shareholder = shareholders[currentIndex];
            uint256 amount = lpBalanceOf(shareholder).mul(nowbanance).div(IERC20(uniswapV2Pair).totalSupply());
            if (amount < minAmount) {
                currentIndex++;
                iterations++;
                continue;
            }
            if (balanceOf(pool) < amount) return;
            _basicTransfer(pool, shareholders[currentIndex], amount);

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setShare(address shareholder) private {
        bool shouldRemove = lpBalanceOf(shareholder).mul(getLPPrice()).div(1e18) < nodeHoldLimit || !nodeWhiteList[shareholder];
        if (_updated[shareholder]) {
            if (shouldRemove) {
                shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
                shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
                shareholders.pop();
                _updated[shareholder] = false;
            }
            return;
        }
        if (shouldRemove) return;
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
        _updated[shareholder] = true;
    }

    function getShareholdersLength() public view returns (uint256){
        return shareholders.length;
    }

    function getList(uint256 start, uint256 length) public view returns (address[] memory addrs, uint256[] memory bals){
        address[] memory list = shareholders;
        uint256 end = (start + length) < list.length ? (start + length) : list.length;
        (, length) = end.trySub(start);
        addrs = new address[](length);
        bals = new uint256[](length);
        IERC20 pair = IERC20(uniswapV2Pair);
        for (uint i = start; i < end; i++) {
            addrs[i - start] = list[i];
            bals[i - start] = pair.balanceOf(list[i]);
        }
    }

    function getLPPrice() public view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        uint256 totalLP = pair.totalSupply();
        if (totalLP == 0) return 0;
        if (address(usdt) == pair.token0()) {
            return reserve0.mul(2e18).div(totalLP);
        } else {
            return reserve1.mul(2e18).div(totalLP);
        }
    }

    function swapTokensForToken(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_receiveUsdt),
            block.timestamp
        );
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public view returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(pairFee);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountInToToken(uint amountOut) public view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        if (address(usdt) == pair.token0()) {
            return getAmountIn(amountOut, reserve0, reserve1);
        } else {
            return getAmountIn(amountOut, reserve1, reserve0);
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function updateFomo(address account) public onlyOperator {
        _updateFomo(account);
    }

    function _updateFomo(address account) internal {
        if (fomoLastTime != 0 && fomoLastTime.add(fomoDuration) < block.timestamp) {
            roundFomo5Amounts[roundIndex] = fomo5Amount.sub(fomo5DivAmount).div(2);
            roundFomo100Amounts[roundIndex] = fomo100Amount.sub(fomo100DivAmount).div(2);
            fomo5DivAmount = fomo5DivAmount.add(roundFomo5Amounts[roundIndex]);
            fomo100DivAmount = fomo100DivAmount.add(roundFomo100Amounts[roundIndex]);
            roundIndex++;
        }
        fomoLastTime = block.timestamp;
        rounds[roundIndex].push(account);
    }

    function _halfFomo() internal {
        uint256 fomo5Reward = fomo5Amount.sub(fomo5DivAmount);
        if (fomo5Reward > fomo5Limit) {
            uint256 toBoxBoard100 = fomo5Reward.div(2);
            fomo5DivAmount = fomo5DivAmount.add(toBoxBoard100);
            _basicTransfer(address(fomo5), address(boxBoard100), toBoxBoard100);
            try boxBoard100.allocate(toBoxBoard100) {} catch {}
        }
        uint256 fomo100Reward = fomo100Amount.sub(fomo100DivAmount);
        if (fomo100Reward > fomo100Limit) {
            uint256 toBoxBoard100 = fomo100Reward.div(2);
            fomo100DivAmount = fomo100DivAmount.add(toBoxBoard100);
            _basicTransfer(address(fomo100), address(boxBoard100), toBoxBoard100);
            try boxBoard100.allocate(toBoxBoard100) {} catch {}
        }
    }

    function _buyTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        uint256 toNode = amount.mul(nodeFee).div(100);
        uint256 toInviter = amount.mul(inviteFee).div(100);
        uint256 toBoxBoard30 = amount.mul(boxBoard30Fee).div(100);
        uint256 toFomo5 = amount.mul(fomo5Fee).div(100);
        uint256 toFomo100 = amount.mul(fomo100Fee).div(100);

        _balances[address(node)] = _balances[address(node)].add(toNode);
        emit Transfer(sender, address(node), toNode);

        address referrer = bind.getReferrer(recipient);
        _balances[referrer] = _balances[referrer].add(toInviter);
        emit Transfer(sender, referrer, toInviter);

        _balances[address(boxBoard30)] = _balances[address(boxBoard30)].add(toBoxBoard30);
        emit Transfer(sender, address(boxBoard30), toBoxBoard30);
        try boxBoard30.allocate(toBoxBoard30) {} catch {}

        _balances[address(fomo5)] = _balances[address(fomo5)].add(toFomo5);
        emit Transfer(sender, address(fomo5), toFomo5);
        fomo5Amount = fomo5Amount.add(toFomo5);

        _balances[address(fomo100)] = _balances[address(fomo100)].add(toFomo100);
        emit Transfer(sender, address(fomo100), toFomo100);
        fomo100Amount = fomo100Amount.add(toFomo100);

        amount = amount.sub(toNode).sub(toInviter).sub(toBoxBoard30);
        amount = amount.sub(toFomo5).sub(toFomo100);

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _sellTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        uint256 toNode = amount.mul(nodeFeeSell).div(100);
        uint256 toEcology = amount.mul(ecologyFee).div(100);
        uint256 toNftBoardNormal = amount.mul(nftFeeNormal).div(100);
        uint256 toNftBoardRare = amount.mul(nftFeeRare).div(100);

        _balances[node] = _balances[node].add(toNode);
        emit Transfer(sender, node, toNode);

        _balances[address(this)] = _balances[address(this)].add(toEcology);
        emit Transfer(sender, address(this), toEcology);

        _balances[address(nftBoardNormal)] = _balances[address(nftBoardNormal)].add(toNftBoardNormal);
        emit Transfer(sender, address(nftBoardNormal), toNftBoardNormal);
        try nftBoardNormal.allocate(toNftBoardNormal) {} catch {}

        _balances[address(nftBoardRare)] = _balances[address(nftBoardRare)].add(toNftBoardRare);
        emit Transfer(sender, address(nftBoardRare), toNftBoardRare);
        try nftBoardRare.allocate(toNftBoardRare) {} catch {}

        amount = amount.sub(toNode).sub(toEcology).sub(toNftBoardNormal).sub(toNftBoardRare);

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual transferCounter {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (inSwapAndLiquify) {
            _basicTransfer(sender, recipient, amount);
            return;
        }

        if (pairList[sender]){
            if (getAmountInToToken(amount) >= nodeLimit.mul(99).div(100) && !nodeWhiteList[recipient]) {
                nodeWhiteList[recipient] = true;
                setShare(recipient);
            }
            if (getAmountInToToken(amount) >= fomoLimit.mul(99).div(100) && !isExcludedFromFomo[recipient]) {
                _updateFomo(recipient);
            }
            address _referrer = bind.getReferrer(recipient);
            if(!isValid[recipient]){
                isValid[recipient] = true;
                validNum[_referrer]++;
                _updateBoxBoardBalance(_referrer);
            }
        }

        _halfFomo();

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            recipient != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = balanceOf(uniswapV2Pair).div(10).min(numTokensSellToAddToLiquidity);
            swapTokensForToken(contractTokenBalance);
            _receiveUsdt.transferOut(receives);
        }

        _beforeTokenTransfer(sender, recipient, amount);
        if (isDelivers[sender] || isDelivers[recipient]) {
            _basicTransfer(sender, recipient, amount);
        } else if (pairList[sender]) {
            require(block.timestamp >= swapTime, 'Can\'t swap!');
            _buyTransfer(sender, recipient, amount);
        } else if (pairList[recipient]) {
            require(block.timestamp >= swapTime, 'Can\'t swap!');
            _sellTransfer(sender, recipient, amount);
        } else {
            _basicTransfer(sender, recipient, amount);
        }

        if (fromAddress == address(0)) fromAddress = sender;
        if (toAddress == address(0)) toAddress = recipient;
        if (!isExcludedFromNode[fromAddress]) {
            setShare(fromAddress);
        }
        if (!isExcludedFromNode[toAddress]) {
            setShare(toAddress);
        }
        fromAddress = sender;
        toAddress = recipient;

        if (balanceOf(node) >= minBalance && sender != address(this) && distributorTime.add(minPeriod) <= block.timestamp) {
            process(distributorGas);
            distributorTime = block.timestamp;
        }

        if (enterCount == 1) {
            fomo5.proc();
            fomo100.proc();
        }
    }

    function _updateBoxBoardBalance(address referrer) internal{
        uint256 _validNum = validNum[referrer];
        if(_validNum<30) return;
        uint256 bal30 = boxBoard30.balanceOf(referrer);
        if(_validNum>bal30) boxBoard30.stake(referrer, _validNum.sub(bal30));

        if(_validNum<100) return;
        uint256 bal100 = boxBoard100.balanceOf(referrer);
        if(_validNum>bal100) boxBoard100.stake(referrer, _validNum.sub(bal100));
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}