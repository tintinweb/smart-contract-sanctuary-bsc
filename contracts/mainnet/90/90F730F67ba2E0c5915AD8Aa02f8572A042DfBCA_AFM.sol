/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
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

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
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

    function setOwner(address _newOwner) internal {
        _owner = _newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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

  
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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

contract AFM is Context, IERC20, Ownable {
    using Address for address;
    using Address for address payable;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping (address => bool) private _isExcludedFromFee;

    address constant WBNB                            = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD                            = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO                            = 0x0000000000000000000000000000000000000000;
    address public adminZero                         = 0x33cF975497C4E4b095B6912539c657edcCE9956d; 
    address public adminOne                          = 0x9d9D23864c5601dc328d23281A38662c9d9D7422;

    // MAIN WALLET ADDRESSES
    address private MKT                              = 0x9d9D23864c5601dc328d23281A38662c9d9D7422;
    address private TEAM                             = 0x95B913C8F715F1451D4D47F19bd66CC9C9e1c52B;
    address private PROJECT_A                        = 0x806d1eE6479a2C36Ac9d03E457BeBf8d655E2f29;
    address private PROJECT_B                        = 0xA6B996b526d94908673afd323aEdf18e7A9fe4eD;
    address private PROJECT_C                        = 0x8811665Fa46a4d776D283F73e1De39AB2B4e6E8a;
    address private PRESALE_ADDRESS                  = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;

    // TOKEN GLOBAL VARIABLES
    string constant _name                            = "Apple Fan Metaverse";
    string constant _symbol                          = "AFM";
    uint8  constant _decimals                        = 18;
    uint256 _totalSupply                             = 165000000 * 10 ** _decimals;

    // INITIAL MAX TRANSACTION AMOUNT SET TO 1.5M
    uint256 public  _maxBuyAmount                    = 1500000 * 10 ** _decimals;
    bool    public  maxBuyEnabled                    = false;

    // INITIAL MAX WALLET HOLDING SET TO 100%
    uint256 public _maxWalletToken                   = _totalSupply;

    // MAPPINGS
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _allowances;
    mapping (address => bool) public                   isFeeExempt;
    mapping (address => bool) public                   isTxLimitExempt;
    mapping (address => bool) public                   isTimelockExempt;
    mapping (address => bool) public                   liquidityAddress;
    mapping (address => bool) private                  _auth;
    // TRANSFER FEE
    uint256 constant INITIAL_TRANSFER_TAX_RATE       = 600;
    uint256 public   transferTaxRate                 = 600;
    bool    public   takeFeeIfNotLiquidity           = true;

    // SELL FEE & DISTRIBUTION SETTINGS
    uint256 public liquidityFee                       = 300;
    uint256 public marketingFee                       = 700;
    uint256 public projectFee                         = 200;
    uint256 public burnFee                            = 0;
    uint256 public teamFee                            = 0;
    // SETS UP TOTAL FEE
    uint256 public totalFee = (liquidityFee + marketingFee + projectFee + teamFee + burnFee);

    // MAX TOTAL FEE SHOULD BE REASONABLE.
    // ATTENTION: THIS CANNOT BE CHANGED AFTERWARDS!
    uint256 public constant MAX_TOTAL_FEE             = 2500;

    // FEE DENOMINATOR CANNOT BE CHANGED.
    uint256 public constant feeDenominator            = 10000;
    // SET UP FEE RECEIVERS
    address public burnFeeReceiver                    = DEAD;
    address public projectFeeReceiverA                = PROJECT_A;
    address public projectFeeReceiverB                = PROJECT_B;
    address public projectFeeReceiverC                = PROJECT_C;
    address public teamFeeReceiver                    = TEAM;
    address public autoLiquidityReceiver              = MKT;
    address public marketingFeeReceiver               = MKT;
    
    bool private swapping;
    address public lastSell                           = ZERO;


    // SWITCH TRADING
    bool    public  tradingOpen                       = false;
    uint256 private launchedAt                        = 0;

    // MULTI-SIGNATURE GLOBAL VARIABLES
    uint256 public multiSignatureID                   = 0;
    uint256 public multiSignatureDeadline             = 0;
    uint256 public multiSignatureInterval             = 0;
    address public multiSignatureAddress              = ZERO;
    
    // MULTI-SIGNATURE TEMPORARY VARIABLES
    uint256 private _tmpMaxTxAmount                   = 0;
    uint256 private _tmpTransferTaxRate               = 0;
    uint256 private _tmpLiquidityFee                  = 0;
    uint256 private _tmpMarketingFee                  = 0;
    uint256 private _tmpProjectFee                    = 0;
    uint256 private _tmpBurnFee                       = 0;
    uint256 private _tmpTotalFee                      = 0;
    uint256 private _tmpSwapThreshold                 = 0;
    uint256 private _tmpMaxWalletPercent              = 0;
    uint256 private _tmpClearStuckBalance             = 0;
    uint256 private _tmpMultiSingnatureCD             = 0;
    bool    private _tmpIsFeeExempt                   = false;
    bool    private _tmpIsTxLimitExempt               = false;
    bool    private _tmpIsTimeLockExempt              = false;
    bool    private _tmpSellAddressExempt             = false;
    bool    private _tmpSwapEnabled                   = false;
    bool    private _tmpTakeFeeIfNotLiquidity         = false;
    bool    private _tmpMaxBuyEnabled                 = false;
    address private _tmpFeeExemptAddress              = ZERO; 
    address private _tmpTimeLockAddress               = ZERO;
    address private _tmpTxLimitAddress                = ZERO;
    address private _tmpSellAddress                   = ZERO;
    address private _tmpProjectReceiverA              = ZERO;
    address private _tmpProjectReceiverB              = ZERO;
    address private _tmpProjectReceiverC              = ZERO;
    address private _tmpTeamReceiver                  = ZERO;
    address private _tmpLiquidityReceiver             = ZERO;
    address private _tmpMarketingReceiver             = ZERO;
    address private _tmpBurnReceiver                  = ZERO;
    address private _tmpAdminZero                     = ZERO;
    address private _tmpAdminOne                      = ZERO;
    address private _tmpOwnershipAddress              = ZERO;
    address private _tmpForceResetAddress             = ZERO;
    address private _tmpWithdrawTokenAddr             = ZERO;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    // COOLDOWN & TIMER
    mapping (address => uint) private                   cooldownTimer;
    bool public buyCooldownEnabled                    = true;
    uint8 public cooldownTimerInterval                = 30;

    // TOKEN SWAP SETTINGS
    bool           inSwap;
    bool    public swapEnabled                        = true;
    uint256 public swapThreshold                      = _totalSupply / 10000; // 0,01%
    
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
        
    constructor () {
        require(totalFee <= MAX_TOTAL_FEE,"totalFee must be reasonable. Check MAX_TOTAL_FEE");
        require(MAX_TOTAL_FEE < feeDenominator,"MAX_TOTAL_FEE must be reasonable according to feeDenominator.");

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router                               = _uniswapV2Router;
        uniswapV2Pair                                 = pair;
        _auth[DEAD]                                   = true;
        _auth[ZERO]                                   = true;
        _auth[uniswapV2Pair]                          = true;
        _auth[owner()]                                = true;
        _auth[adminZero]                              = true;
        _auth[adminOne]                               = true;
        _auth[PRESALE_ADDRESS]                        = true;
        _auth[marketingFeeReceiver]                   = true;
        _auth[projectFeeReceiverA]                    = true;
        _auth[projectFeeReceiverB]                    = true;
        _auth[projectFeeReceiverC]                    = true;
        _auth[teamFeeReceiver]                        = true;
        _auth[address(uniswapV2Router)]               = true;
        _auth[address(this)]                          = true;
        isFeeExempt[owner()]                          = true;
        isFeeExempt[address(this)]                    = true;
        isFeeExempt[MKT]                              = true;
        isTxLimitExempt[msg.sender]                   = true;
        isTxLimitExempt[DEAD]                         = true;
        isTxLimitExempt[uniswapV2Pair]                = true;
        liquidityAddress[uniswapV2Pair]               = true;
        isTimelockExempt[msg.sender]                  = true;
        isTimelockExempt[DEAD]                        = true;
        isTimelockExempt[address(this)]               = true;

        // INITIAL DISTRIBUTION
        _balances[_msgSender()]                       = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function totalSupply() public view override returns (uint256) {
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
    
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    
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
        // TRADING STATUS
        checkTradingStatus(from, to);
        // MAX WALLET SETTINGS
        checkMaxWallet(to, amount);
        // COOLDOWN BETWEEN BUYS
        checkCoolDown(from, to);
        // BUY LIMIT
        checkMaxBuy(from, to, amount);
        // SWAP BACK?        
        if (balanceOf(address(this)) >= swapThreshold && !swapping && from != uniswapV2Pair && from != owner() && to != owner()) {
            swapping = true;
            swapBack(from);
            lastSell = from;
            swapping = false;
        }

        uint256 amountReceived = shouldTakeFee(from, to) ? takeFee(from, to, amount) : amount;

        // EXCHANGE TOKENS
        _balances[from] -= amount;
        _balances[to] += amountReceived;
        emit Transfer(from, to, amountReceived);
    }   
    // CHECKS COOLDOWN BETWEEN BUYS
    function checkCoolDown(address sender, address recipient) internal {
        if (liquidityAddress[sender] &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
    }
    // CHECKS TRADING STATUS
    function checkTradingStatus(address sender, address recipient) internal view {
        if(
               sender    != owner() 
            && recipient != owner() 
            && sender    != PRESALE_ADDRESS) {
            require(tradingOpen,"Trading not open yet");
        }
    }
    function tradingStatus(bool _status) public onlyOwner {
        require(_status, "You cannot disable trading.");
        tradingOpen = _status;
    }
    // CHECKS MAX BUY
    function checkMaxBuy(address sender, address recipient, uint256 amount) internal view {
        if (liquidityAddress[sender] && maxBuyEnabled) {
            if (!isTxLimitExempt[recipient]) { require(amount <= _maxBuyAmount,"maxBuy Limit Exceeded"); }
        }
    }
    // CHECKS MAX WALLET
    function checkMaxWallet(address recipient, uint256 amount) internal view {
        if (   recipient != owner()
            && recipient != adminZero
            && recipient != adminOne 
            && recipient != address(this) 
            && recipient != DEAD
            && recipient != uniswapV2Pair 
            && recipient != burnFeeReceiver
            && recipient != marketingFeeReceiver 
            && recipient != autoLiquidityReceiver) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, recipient cant hold that much.");
        }
    }
    function resetTotalFees() internal {
        totalFee = liquidityFee + marketingFee + projectFee + burnFee;
    }
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (   !liquidityAddress[sender]
            && !liquidityAddress[recipient]
            && sender != address(uniswapV2Router)
            && recipient != address(uniswapV2Router)
            && msg.sender != address(uniswapV2Router)
            && !takeFeeIfNotLiquidity) {
            return amount;
        }
        uint256 feeAmount = 0;
        if (liquidityAddress[recipient] && totalFee > 0) {
            feeAmount = (amount * totalFee / feeDenominator);
        }        
        else {
            feeAmount = (amount * transferTaxRate / feeDenominator);
        }
        if (feeAmount > 0) {
            _balances[address(this)] += feeAmount;
            emit Transfer(sender, address(this), feeAmount);
            return (amount - feeAmount);
        } else {
            return amount;
        }
    }
    // SHOULD WE TAKE ANY TRANSACTION FEE ON THIS?
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
         if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
             return true;
         }
         else { return false; }
    }    

    // BASIC TRANSFER METHOD
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }      
    // SWAP BACK FUNCTION
    function swapBack(address sender) private {
        if (lastSell != sender) {
            // SETS UP AMOUNT THAT NEEDS TO BE SWAPPED
            uint256 totalFeeWithoutBurn = totalFee - burnFee;
            uint256 amountToBurn        = swapThreshold * burnFee / totalFee;
            // BURNS TOKENS IF THERE IS ANY TO BE BURNED
            if (burnFee > 0 && balanceOf(address(this)) >= amountToBurn) {
                _basicTransfer(address(this), burnFeeReceiver, amountToBurn);
            }

            // CHECKS IF THERE IS ANY FEE THAT NEEDS TOKENS TO BE SWAPPED
            if (totalFeeWithoutBurn > 0 && balanceOf(address(this)) > (swapThreshold - amountToBurn)) {
                // SWAPBACK SETTINGS
                uint256 amount = (swapThreshold - amountToBurn);
                uint256 amountToLiquify = (amount * liquidityFee / totalFee / 2);
                uint256 amountToSwap = (amount - amountToLiquify);
                uint256 amountBNB = swapTokensForEth(amountToSwap);
                if (amountBNB > 0) {
                    // SETTING UP TOTAL FEE AMOUNT IN TOKENS
                    uint256 totalBNBFee = (liquidityFee + marketingFee + projectFee);
                    // SETTING UP WHO IS WHO HERE
                    uint256 amountBNBLiquidity = (amountBNB * liquidityFee / totalBNBFee / 2);
                    uint256 amountBNBProject   = (amountBNB * projectFee / totalBNBFee);
                    uint256 amountBNBTeam      = (amountBNB * teamFee / totalBNBFee);
                    // PAYS UP PROJECT WALLET IF THERE IS ANY TO BE PAID
                    if (amountBNBProject > 0 && address(this).balance >= amountBNBProject) {
                        payable(projectFeeReceiverA).sendValue((amountBNBProject / 3));
                        payable(projectFeeReceiverB).sendValue((amountBNBProject / 3));
                        payable(projectFeeReceiverC).sendValue((amountBNBProject / 3));
                    }
                    // PAYS UP TEAM WALLET IF THERE IS ANY TO BE PAID
                    if (amountBNBTeam > 0 && address(this).balance >= amountBNBTeam) {
                        payable(teamFeeReceiver).sendValue((amountBNBTeam));
                    }
                    // ADDS LIQUIDITY IF THERE IS ANY TO BE ADDED
                    if(amountBNBLiquidity > 0 
                    && address(this).balance >= amountBNBLiquidity 
                    && balanceOf(address(this)) >= amountToLiquify) {
                        addLiquidity(amountToLiquify, amountBNBLiquidity);
                    }
                    // PAYS UP MARKETING WALLET WITH ALL BNB LEFT
                    /*
                    Up untill now all fees and swaps are done and every receiver has been paid.
                    The rest of it should be mathematically marketingFee, but there could be a minor difference.
                    For the transaction not to revert, what we do is send all BNB funds left to marketingFeeReceiver.
                    */
                    if (address(this).balance >= 0) {
                        // FUNDS SHOULD NOT BE KEPT IN THE CONTRACT
                        payable(marketingFeeReceiver).sendValue(address(this).balance);      
                    }                    
                }            
            }            
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private returns (uint256) {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return (address(this).balance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        (,uint256 ethFromLiquidity,) = uniswapV2Router.addLiquidityETH {value: ethAmount} (
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );
        
        if (ethAmount - ethFromLiquidity > 0)
            payable(marketingFeeReceiver).sendValue(ethAmount - ethFromLiquidity);
    }
    
    ////    MULTI-SIGNATURE FUNCTIONS START
    function resetMultiSignature() internal {
        multiSignatureID            = 0;
        multiSignatureDeadline      = 0;
        _tmpMaxTxAmount             = 0;
        _tmpTransferTaxRate         = 0;
        _tmpLiquidityFee            = 0;
        _tmpMarketingFee            = 0;
        _tmpProjectFee              = 0;
        _tmpBurnFee                 = 0;
        _tmpTotalFee                = 0;
        _tmpSwapThreshold           = 0;
        _tmpMaxWalletPercent        = 0;
        _tmpClearStuckBalance       = 0;
        multiSignatureAddress       = ZERO;
        _tmpFeeExemptAddress        = ZERO; 
        _tmpTimeLockAddress         = ZERO;
        _tmpTxLimitAddress          = ZERO;
        _tmpSellAddress             = ZERO;
        _tmpProjectReceiverA        = ZERO;
        _tmpProjectReceiverB        = ZERO;
        _tmpProjectReceiverC        = ZERO;
        _tmpTeamReceiver            = ZERO;
        _tmpLiquidityReceiver       = ZERO;
        _tmpMarketingReceiver       = ZERO;
        _tmpBurnReceiver            = ZERO;
        _tmpAdminZero               = ZERO;
        _tmpAdminOne                = ZERO;
        _tmpOwnershipAddress        = ZERO;
        _tmpForceResetAddress       = ZERO;
        _tmpWithdrawTokenAddr       = ZERO;
        _tmpIsFeeExempt             = false;
        _tmpIsTxLimitExempt         = false;
        _tmpIsTimeLockExempt        = false;
        _tmpSellAddressExempt       = false;
        _tmpSwapEnabled             = false;
        _tmpTakeFeeIfNotLiquidity   = false;
        _tmpMaxBuyEnabled           = false;
    }
    // [dev]: Mister Whitestake https://t.me/mrwhitestake

    function checkAuth(address _msgSender) internal view {
        require(_msgSender == adminZero || _msgSender == adminOne || _msgSender == owner(), "You are not authorized");
    }

    function multiSignatureRequirements(uint256 _id, address _address, bool _checkID) internal view {
        if (_checkID) { 
            require(multiSignatureID == _id, "Invalid multiSignatureID"); 
            require((multiSignatureDeadline - 15) < block.timestamp, "MultiSignatureDeadline hasnt been reached");
        }
        require(multiSignatureAddress != _address, "You need authorization from the other admins");
    }

    function multiSignatureTrigger(uint256 _id, address _admin) internal {
        require(multiSignatureAddress == ZERO, "Multi-signature is already on. You can try force resetting.");
        multiSignatureID = _id;
        multiSignatureAddress = _admin;
        multiSignatureDeadline = block.timestamp + multiSignatureInterval;
    }

    function setMaxBuy(uint256 amount, bool _enabled) external {
        // MULTI-SIGNATURE ID
        uint256 id = 1;
        // GLOBAL REQUIREMENTS
        require(amount > (_totalSupply / 10000) && amount < (_totalSupply / 100 * 2), "Invalid amount. Must be reasonable.");
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMaxTxAmount = amount;
            _tmpMaxBuyEnabled = _enabled;
        } else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                if (msg.sender != multiSignatureAddress) {
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpMaxTxAmount == amount && _tmpMaxBuyEnabled == _enabled, "Invalid parameters");
                // NICE JOB. YOU DID IT!
                _maxBuyAmount = amount;
                maxBuyEnabled = _enabled;
                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();            
            }
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external {
        // MULTI-SIGNATURE ID
        uint256 id = 2;
        // GLOBAL REQUIREMENTS
        checkAuth(msg.sender);
        require(isFeeExempt[holder] != exempt, "Address is already set in that condition");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpIsFeeExempt = exempt;
            _tmpFeeExemptAddress = holder;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpFeeExemptAddress == holder && _tmpIsFeeExempt == exempt, "Invalid parameters");
            //NICE JOB. YOU DID IT!
            isFeeExempt[holder] = exempt;
            // RESET AFTER SUCCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }

    function setIsTxLimitExempt(address holder, bool exempt) external {
        // MULTI-SIGNATURE ID
        uint256 id = 3;
        // GLOBAL REQUIREMENTS
        checkAuth(msg.sender);
        require(isTxLimitExempt[holder] != exempt, "Address is already set in that condition");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpIsTxLimitExempt = exempt;
            _tmpTxLimitAddress = holder;
        }   else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpTxLimitAddress == holder && _tmpIsTxLimitExempt == exempt, "Invalid parameters");
            // NICE JOB. YOU DID IT!
            isTxLimitExempt[holder] = exempt;
            // RESET AFTER SUCCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }

    function setIsTimelockExempt(address holder, bool exempt) external {
        // MULTI-SIGNATURE ID
        uint256 id = 4;
        // GLOBAL REQUIREMENTS       
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpIsTimeLockExempt = exempt;
            _tmpTimeLockAddress = holder;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpIsTimeLockExempt == exempt && _tmpFeeExemptAddress == holder, "Invalid parameters");

            // NICE JOB. YOU DID IT!
            isTimelockExempt[holder] = exempt;

            // RESET AFTER SUCCESSFULLY COMPLETING TASK
            resetMultiSignature();  
        }
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _projectFee, uint256 _burnFee) external {
        // MULTI-SIGNATURE ID
        uint256 id = 5;
        // GLOBAL REQUIREMENTS      
        checkAuth(msg.sender);
         _tmpTotalFee = (_liquidityFee + _marketingFee + _projectFee + _burnFee); 
        require(_tmpTotalFee <= MAX_TOTAL_FEE, "totalFee cant be higher than MAX_TOTAL_FEE");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpLiquidityFee = _liquidityFee;
            _tmpMarketingFee = _marketingFee;
            _tmpProjectFee = _projectFee;
            _tmpBurnFee = _burnFee;    
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(
                _tmpLiquidityFee == _liquidityFee
                && _tmpMarketingFee == _marketingFee
                && _tmpProjectFee == _projectFee
                && _tmpBurnFee == _burnFee,
                "Invalid parameters"
            );
            // NICE JOB. YOU DID IT!
            liquidityFee = _liquidityFee;
            marketingFee = _marketingFee;
            projectFee = _projectFee;
            burnFee = _burnFee;
            totalFee = _tmpTotalFee;
            // RESET AFTER SUCCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }

    function setTransferTaxRate(uint256 _transferTaxRate, bool _takeFeeIfNotLiquidityAddress) external {   
        // MULTI-SIGNATURE ID
        uint256 id = 6;
        // GLOBAL REQUIREMENTS
        checkAuth(msg.sender); 
        require(_transferTaxRate <= MAX_TOTAL_FEE, "must not be higher than MAX_TOTAL_FEE");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpTransferTaxRate = _transferTaxRate;
            _tmpTakeFeeIfNotLiquidity = _takeFeeIfNotLiquidityAddress;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpTransferTaxRate == _transferTaxRate
                    && _tmpTakeFeeIfNotLiquidity == _takeFeeIfNotLiquidityAddress, "Invalid parameters");
            
            // NICE JOB. YOU DID IT!
            transferTaxRate = _transferTaxRate;
            takeFeeIfNotLiquidity = _takeFeeIfNotLiquidityAddress;
            // RESET AFTER SUCCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }

    function setSellingFeeAddress(address _liquidityAddress, bool _enabled) external {
        // MULTI-SIGNATURE ID
        uint256 id = 7;
        // GLOBAL REQUIREMENTS      
        checkAuth(msg.sender);
        require(liquidityAddress[_liquidityAddress] != _enabled, "User is already set in that condition");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpSellAddress = _liquidityAddress;
            _tmpSellAddressExempt = _enabled;
        }
           else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpSellAddress == _liquidityAddress && _tmpSellAddressExempt == _enabled, "Invalid parameters");

            // NICE JOB. YOU DID IT!
            liquidityAddress[_liquidityAddress] = _enabled;
            // RESET AFTER SUCCESFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _projectFeeReceiverA, address _projectFeeReceiverB,  address _projectFeeReceiverC, address _teamFeeReceiver, address _burnFeeReceiver) external {
        // MULTI-SIGNATURE ID
        uint256 id = 8;
        // GLOBAL REQUIREMENTS    
        checkAuth(msg.sender);
         require(
               _autoLiquidityReceiver != ZERO
            && _autoLiquidityReceiver != uniswapV2Pair, "Invalid autoLiquidityReceiver");
        require(
               _marketingFeeReceiver != ZERO
            && _marketingFeeReceiver != DEAD
            && _marketingFeeReceiver != uniswapV2Pair, "Invalid marketingFeeReceiver");
        require(
               _projectFeeReceiverA != ZERO
            && _projectFeeReceiverA != DEAD
            && _projectFeeReceiverA != uniswapV2Pair, "Invalid projectFeeReceiverA");
        require(
               _projectFeeReceiverB != ZERO
            && _projectFeeReceiverB != DEAD
            && _projectFeeReceiverB != uniswapV2Pair, "Invalid projectFeeReceiverB");
        require(
               _projectFeeReceiverC != ZERO
            && _projectFeeReceiverC != DEAD
            && _projectFeeReceiverC != uniswapV2Pair, "Invalid projectFeeReceiverC");
        require(
               _teamFeeReceiver != ZERO
            && _teamFeeReceiver != DEAD
            && _teamFeeReceiver != uniswapV2Pair, "Invalid projectFeeReceiverB");
        
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpLiquidityReceiver = _autoLiquidityReceiver;
            _tmpMarketingReceiver = _marketingFeeReceiver;
            _tmpProjectReceiverA  = _projectFeeReceiverA;
            _tmpProjectReceiverB  = _projectFeeReceiverB;
            _tmpProjectReceiverC  = _projectFeeReceiverC;
            _tmpTeamReceiver      = _teamFeeReceiver;
            _tmpBurnReceiver      = _burnFeeReceiver;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(
                _tmpLiquidityReceiver    == _autoLiquidityReceiver
                && _tmpMarketingReceiver == _marketingFeeReceiver
                && _tmpProjectReceiverA  == _projectFeeReceiverA
                && _tmpProjectReceiverB  == _projectFeeReceiverB
                && _tmpProjectReceiverC  == _projectFeeReceiverC
                && _tmpTeamReceiver      == _teamFeeReceiver,
                "Invalid parameters"
            );

            // NICE JOB. YOU DID IT
            autoLiquidityReceiver = _autoLiquidityReceiver;
            marketingFeeReceiver  = _marketingFeeReceiver;
            projectFeeReceiverA   = _projectFeeReceiverA;
            projectFeeReceiverB   = _projectFeeReceiverB;
            projectFeeReceiverC   = _projectFeeReceiverC;
            teamFeeReceiver       = _teamFeeReceiver;
            burnFeeReceiver       = _burnFeeReceiver;

            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external {
        // MULTI-SIGNATURE ID
        uint256 id = 9;
        // GLOBAL REQUIREMENTS   
        checkAuth(msg.sender);
        require(_amount <= (totalSupply() / 1000 * 5), "MAX_SWAPBACK amount cannot be higher than half percent");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpSwapEnabled = _enabled;
            _tmpSwapThreshold = _amount;
        }   else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpSwapEnabled == _enabled && _tmpSwapThreshold == _amount, "Invalid parameters");

            // NICE JOB. YOU DID IT
            swapEnabled = _enabled;
            swapThreshold = _amount;

            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }
    
    function setAdmins(address _adminZero, address _adminOne) external {
        // MULTI-SIGNATURE ID
        uint256 id = 10;
        // GLOBAL REQUIREMENTS       
        checkAuth(msg.sender);
        require(
            _adminZero != ZERO 
            && _adminZero != DEAD 
            && _adminZero != address(this)
            && _adminOne != ZERO 
            && _adminOne != DEAD 
            && _adminOne != address(this), "Invalid address"
        );
        require(_adminZero != _adminOne,"Duplicated addresses");

        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpAdminZero = _adminZero;
            _tmpAdminOne = _adminOne;
        }   else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpAdminZero == _adminZero && _tmpAdminOne == _adminOne, "Invalid parameters");

            // NICE JOB. YOU DID IT!
            adminZero = _adminZero;
            adminOne = _adminOne;

            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }

    function renounceContract() external {
        // MULTI-SIGNATURE ID
        uint256 id = 11;
        // GLOBAL REQUIREMENTS     
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpOwnershipAddress = DEAD;
            _tmpAdminZero = DEAD;
            _tmpAdminOne = DEAD;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(
                _tmpOwnershipAddress == DEAD 
                && _tmpAdminZero == DEAD 
                && _tmpAdminOne == DEAD, "Invalid parameters");
            // NICE JOB. YOU DID IT!
            adminZero = DEAD;
            adminOne = DEAD;
            setOwner(DEAD);
            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
        
    }
    /**
     * Transfer ownership to new address
     */
    function transferOwnership(address adr) external {
        // MULTI-SIGNATURE ID
        uint256 id = 12;
        // GLOBAL REQUIREMENTS      
        checkAuth(msg.sender);
        require(
            adr != ZERO 
            && adr != DEAD 
            && adr != address(this)
            && adr != adminZero
            && adr != adminOne, "Invalid address");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpOwnershipAddress = adr;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpOwnershipAddress == adr, "Invalid parameters");
            // NICE JOB. YOU DID IT!
            address _previousOwner = owner();
            setOwner(adr);
            emit OwnershipTransferred(_previousOwner, adr);
            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
        
    }
    function setMaxWalletPercent(uint256 maxWallPercent) external {
        // MULTI-SIGNATURE ID
        uint256 id = 13;
        // GLOBAL REQUIREMENTS       
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMaxWalletPercent = maxWallPercent;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(maxWallPercent > 0 && maxWallPercent <= 100, "Invalid maxWallPercent");
            require(_tmpMaxTxAmount == maxWallPercent, "Invalid parameters");                
            // NICE JOB. YOU DID IT!  
            _maxWalletToken = (totalSupply() * maxWallPercent ) / 100;

            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }
    function forceMultiSignatureReset() external {
        // MULTI-SIGNATURE ID
        uint256 id = 14;
        // GLOBAL REQUIREMENTS  
        checkAuth(msg.sender);
        require(ZERO != multiSignatureAddress, "!RESET");
        // MULTI-SIGNATURE REQUIREMENTS
        multiSignatureRequirements(id, msg.sender, false);
        // NICE JOB. YOU DID IT!
        resetMultiSignature();
    }
    function clearStuckBalance(uint256 amountPercentage) external {
        require(amountPercentage <= 100 && amountPercentage > 0, "You can only select a number from 1 to 100");
        // MULTI-SIGNATURE ID
        uint256 id = 15;
        // GLOBAL REQUIREMENTS  
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpClearStuckBalance = amountPercentage;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(amountPercentage == _tmpClearStuckBalance, "Invalid parameters"); 
            // NICE JOB. YOU DID IT!  
            uint256 amountBNB = address(this).balance;
            uint256 weiAmount = amountBNB * amountPercentage / 100;
            payable(multiSignatureAddress).sendValue(weiAmount);
            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();         
        }
    }

    function withdrawTokens(address _tokenAddress) external {
        // MULTI-SIGNATURE ID
        uint256 id = 16;
        // GLOBAL REQUIREMENTS      
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpWithdrawTokenAddr = _tokenAddress;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tokenAddress == _tmpWithdrawTokenAddr, "Invalid parameters"); 
            // NICE JOB. YOU DID IT!
            IERC20 ERC20token = IERC20(_tokenAddress);
            uint256 balance = ERC20token.balanceOf(address(this));
            ERC20token.transfer(multiSignatureAddress, balance);
            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();         
        }
    }
    
    function multiSignatureCooldown(uint256 _time) external {   
        // MULTI-SIGNATURE ID
        uint256 id = 17;
        // GLOBAL REQUIREMENTS   
        checkAuth(msg.sender); 
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMultiSingnatureCD = _time;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_time == _tmpMultiSingnatureCD, "Invalid parameters");
            // NICE JOB. YOU DID IT!
            multiSignatureInterval = _time;

            // RESET AFTER SUCCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////

    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply() - balanceOf(DEAD) - balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}