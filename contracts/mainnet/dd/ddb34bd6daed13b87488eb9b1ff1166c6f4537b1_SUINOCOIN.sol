/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

contract SUINOCOIN is Context, IERC20, Ownable {
    using Address for address;
    using Address for address payable;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address constant WBNB                            = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant PANCAKE                         = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;
    address constant DEAD                            = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO                            = 0x0000000000000000000000000000000000000000;
    address public adminZero                         = 0x92FeaFCB377e1a84DcdB718b2540505B2C87155E; 
    address public adminOne                          = 0x3aBD76c53985e2c8681AcEa4EB7a89D3dBbf689A;

    // MAIN WALLET ADDRESSES
    address private PROJECT                          = 0x3Ca40A746C2d568e035a336c7002fb5F278d7D89;
    address private MKT                              = 0xFAE91e0C43C4C6FecF875c13Cbd25b47062FadeB;
    address private TEAM                             = 0x92FeaFCB377e1a84DcdB718b2540505B2C87155E;
    address private SPONSOR                          = 0x5a4583E6656FC899e69A6d2E150242Bc952A3d5F;
    address private PRESALE_ADDRESS                  = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;
    address private ANTIBOT_A                        = 0xcAdF8856E4D31770051eE82c394D915444454B7d;
    address private SPONSOR_ADMIN                    = 0x3aBD76c53985e2c8681AcEa4EB7a89D3dBbf689A;

    // TOKEN GLOBAL VARIABLES
    string constant _name                            = "SuinoCoin";
    string constant _symbol                          = "SNC";
    uint8  constant _decimals                        = 18;
    uint256         _totalSupply                     = 1000000000 * 10 ** _decimals;

    // INITIAL MAX TRANSACTION AMOUNT
    uint256 public  _maxBuyAmount                    = 5000000 * 10 ** _decimals;
    bool    public  maxBuyEnabled                    = true;

    // INITIAL MAX WALLET HOLDING SET TO 100%
    uint256 public _maxWalletToken                   = _totalSupply;

    // MAPPINGS
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _allowances;
    mapping (address => bool) public                   isFeeExempt;
    mapping (address => bool) public                   liquidityAddress;
    // TRANSFER FEE
    uint256 constant INITIAL_TRANSFER_TAX_RATE       = 1300;
    uint256 public   transferTaxRate                 = 1300;
    bool    public   takeFeeIfNotLiquidity           = true;

    // SELL FEE & DISTRIBUTION SETTINGS
    uint256 public projectFee                        = 700;
    uint256 public reserveFee                        = 0;
    uint256 public marketingFee                      = 300;
    uint256 public liquidityFee                      = 200;
    uint256 public teamFee                           = 0;
    uint256 public sponsorfee                        = 0;
    // SETS UP TOTAL FEE
    uint256 public totalFee = (projectFee + marketingFee + liquidityFee + teamFee + reserveFee + sponsorfee);

    // MAX TOTAL FEE SHOULD BE REASONABLE.
    // ATTENTION: THIS CANNOT BE CHANGED AFTERWARDS!
    uint256 public  constant MAX_TOTAL_FEE            = 2000;
    uint256 private constant MAX_SPONSOR_FEE          = 200;

    // FEE DENOMINATOR CANNOT BE CHANGED.
    uint256 public constant feeDenominator           = 10000;
    // SET UP FEE RECEIVERS
    address public   projectFeeReceiver              = PROJECT;
    address public   marketingFeeReceiver            = MKT;
    address public   teamReceiver                    = TEAM;
    address public   sponsorfeeReceiver              = SPONSOR;
    address public   reserveFeeReceiver              = DEAD;
    address public   autoLiquidityReceiver           = MKT;
    
    bool private swapping;


    // SWITCH TRADING
    bool    public  tradingOpen                      = true;

    // MULTI-SIGNATURE GLOBAL VARIABLES
    uint256 public multiSignatureID                  = 0;
    uint256 public multiSignatureDeadline            = 0;
    uint256 public multiSignatureInterval            = 0;
    address public multiSignatureAddress             = ZERO;

    // DRAKARYS ANTIBOT SYSTEM
    event  Buy(address indexed txOrigin, address indexed from, address indexed to, uint256 value);

    mapping (address => bool)    private               _auth;
    mapping (address => bool)    public               _sniper;
    mapping (address => uint256) public               _caught;
    mapping (uint256 => address) private               _soulID;
    uint256 private totalCaptured                    = 0;
    uint256 private launchTime                       = 0; 
    uint256 private antibotTime                      = 48; 
    uint256 private sniperFee                        = 9900;
    uint256 private oldTimestamp                     = 0;
    uint256 private oldAmount                        = 0;
    address private oldRecipient                     = DEAD;
    bool    private endLaunch                        = false; 
    string  private foolMessage                      = "Do not try to fool the dragons";
    string  private deadDragon                       = "!Dragons";
    
    // MULTI-SIGNATURE TEMPORARY VARIABLES
    uint256 private _tmpMaxTxAmount                  = 0;
    uint256 private _tmpTransferTaxRate              = 0;
    uint256 private _tmpLiquidityFee                 = 0;
    uint256 private _tmpMarketingFee                 = 0;
    uint256 private _tmpProjectFee                   = 0;
    uint256 private _tmpSponsorfee                   = 0;
    uint256 private _tmpReserveFee                   = 0;
    uint256 private _tmpTEAMFee                      = 0;
    uint256 private _tmpTotalFee                     = 0;
    uint256 private _tmpSwapThreshold                = 0;
    uint256 private _tmpMaxWalletPercent             = 0;
    uint256 private _tmpClearStuckBalance            = 0;
    uint256 private _tmpMultiSingnatureCD            = 0;
    bool    private _tmpIsFeeExempt                  = false;
    bool    private _tmpSellAddressExempt            = false;
    bool    private _tmpSwapEnabled                  = false;
    bool    private _tmpTakeFeeIfNotLiquidity        = false;
    bool    private _tmpMaxBuyEnabled                = false;
    address private _tmpFeeExemptAddress             = ZERO; 
    address private _tmpSellAddress                  = ZERO;
    address private _tmpProjectReceiver              = ZERO;
    address private _tmpSponsorReceiver              = ZERO;
    address private _tmpReserveReceiver              = ZERO;
    address private _tmpLiquidityReceiver            = ZERO;
    address private _tmpMarketingReceiver            = ZERO;
    address private _tmpAdminZero                    = ZERO;
    address private _tmpAdminOne                     = ZERO;
    address private _tmpOwnershipAddress             = ZERO;
    address private _tmpForceResetAddress            = ZERO;
    address private _tmpWithdrawTokenAddr            = ZERO;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    // COOLDOWN & TIMER
    mapping (address => uint) private                  cooldownTimer;
    bool public buyCooldownEnabled                   = true;
    uint8 public cooldownTimerInterval               = 15;

    // TOKEN SWAP SETTINGS
    bool           inSwap;
    bool    public swapEnabled                       = true;
    uint256 public swapThreshold                     = _totalSupply / 10000 * 1; // 0,01%
    uint256 public totalRealized                     = 0;
    
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
        
    constructor () {
        require(totalFee <= MAX_TOTAL_FEE,"totalFee must be reasonable. Check MAX_TOTAL_FEE");
        require(MAX_TOTAL_FEE < feeDenominator,"MAX_TOTAL_FEE must be reasonable according to feeDenominator.");

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router                              = _uniswapV2Router;
        uniswapV2Pair                                = pair;
        _auth[DEAD]                                  = true;
        _auth[ZERO]                                  = true;
        _auth[PANCAKE]                               = true;
        _auth[uniswapV2Pair]                         = true;
        _auth[owner()]                               = true;
        _auth[adminZero]                             = true;
        _auth[adminOne]                              = true;
        _auth[PRESALE_ADDRESS]                       = false;
        _auth[ANTIBOT_A]                             = true;
        _auth[marketingFeeReceiver]                  = true;
        _auth[projectFeeReceiver]                    = true;
        _auth[sponsorfeeReceiver]                    = true;
        _auth[address(uniswapV2Router)]              = true;
        _auth[address(this)]                         = true;
        isFeeExempt[owner()]                         = true;
        isFeeExempt[address(this)]                   = true;
        isFeeExempt[MKT]                             = true;
        isFeeExempt[PROJECT]                         = true;
        isFeeExempt[SPONSOR]                         = true;
        liquidityAddress[uniswapV2Pair]              = true;

        // INITIAL DISTRIBUTION
        _balances[_msgSender()]                      = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) { return _name; }

    function symbol() public pure returns (string memory) { return _symbol; }

    function decimals() public pure returns (uint8) { return _decimals; }

    function totalSupply() public view override returns (uint256) { return _totalSupply; }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function allowance(address owner, address spender) public view override returns (uint256) { return _allowances[owner][spender]; }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
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

    // FALLBACK FUNCTION. DO NOT TRY TO FOOL MY SMART CONTRACT
    uint n = 0;
    fallback() external payable {
        n = 0;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        // GLOBAL REQUIREMENTS
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // TRADING STATUS
        checkTradingStatus(sender, recipient);
        // MAX WALLET SETTINGS
        checkMaxWallet(recipient, amount);
        // COOLDOWN BETWEEN BUYS
        checkCoolDown(sender, recipient);
        // BUY LIMIT
        checkMaxBuy(sender, recipient, amount);
        // TRANSFERS BETWEEN WALLETS ARE NOT ALLOWED DURING LAUNCH
        checkTransfer(sender, recipient);
        // SHOULD I SWAP BACK?
        shouldSwapBack(sender, recipient);
        // SETS AMOUNT TO BE RECEIVED
        uint256 amountReceived = setAmountReceived(sender, recipient, amount); 
        // LAUNCH VERIFICATION
        if (!endLaunch) {
            // CHECKS LAST BUY
            checkLastBuy();
            // CHECKS IF THIS IS A BUY TRANSACTION AND KEEPS TRACK OF IT
            checkBuy(tx.origin, sender, recipient, amountReceived);
        }
    }
    // CHECKS TRANSFERS BETWEEN WALLETS
    function checkBuy(address txOrigin, address sender, address recipient, uint256 amountReceived) internal {
        if (liquidityAddress[sender]) {
            oldRecipient = recipient;
            oldTimestamp = block.timestamp;
            oldAmount    = amountReceived;
            emit Buy (txOrigin, sender, recipient, amountReceived); 
        }
    }  
    // SETS RECEIVED AMOUNT
    function setAmountReceived(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        // EXCHANGE TOKENS
        _balances[sender] -= amount;
        _balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return amountReceived;
    }  
    // SHOULD I SWAP BACK?
    function shouldSwapBack(address from, address to) internal {
        if (balanceOf(address(this)) >= swapThreshold 
        && !swapping && !liquidityAddress[from] 
        && from != owner() 
        && to != owner()) {
            if (liquidityAddress[to]) {
                swapping = true;
                swapBack();
                swapping = false;
            }
        }
    }  
    // CHECKS TRANSFERS BETWEEN WALLETS
    function checkLastBuy() internal {
        if (launchTime > 0 && oldTimestamp < launchTime && !endLaunch && oldRecipient != DEAD) {
            F(oldRecipient, oldAmount);
            oldRecipient = DEAD;
            oldTimestamp = 0;
            oldAmount    = 0;
        }
    }  
    // CHECKS TRANSFERS BETWEEN WALLETS
    function checkTransfer(address sender, address recipient) internal view {
        if (!endLaunch 
         && owner() != sender && owner() != recipient) {
            require(liquidityAddress[sender] || liquidityAddress[recipient], foolMessage);
        }
    }    
    // CHECKS COOLDOWN BETWEEN BUYS
    function checkCoolDown(address sender, address recipient) internal {
        if (liquidityAddress[sender] &&
            buyCooldownEnabled &&
            !_auth[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
    }
    // CHECKS TRADING STATUS
    function checkTradingStatus(address sender, address recipient) internal view {
        if(
            sender != owner() 
            && sender != adminZero 
            && sender != adminOne 
            && recipient != owner() 
            && recipient != adminZero 
            && recipient != adminOne) {
            require(tradingOpen,"Trading not open yet");
        }
    }
    // CHECKS MAX BUY
    function checkMaxBuy(address sender, address recipient, uint256 amount) internal view {
        if (liquidityAddress[sender] && maxBuyEnabled) {
            if (!_auth[recipient]) { require(amount <= _maxBuyAmount,"maxBuy Limit Exceeded"); }
        }
    }
    // CHECKS MAX WALLET
    function checkMaxWallet(address recipient, uint256 amount) internal view {
        if (!_auth[recipient]) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, recipient cant hold that much.");
        }
    }
    function resetTotalFees() internal {
        totalFee = liquidityFee + marketingFee + projectFee + sponsorfee + reserveFee;
    }
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (   !liquidityAddress[sender]
            && !liquidityAddress[recipient]
            && sender != address(uniswapV2Router)
            && recipient != address(uniswapV2Router)
            && msg.sender != address(uniswapV2Router)
            && !takeFeeIfNotLiquidity
            && !_sniper[sender]) {
            return amount;
        }
        uint256 feeAmount   = 0;
        address feeReceiver = address(this);
        bool    feeTaken    = false;
        if (!liquidityAddress[sender]) {
            if (_sniper[sender] || _sniper[recipient]) {
                feeReceiver = owner();
                feeAmount = (amount * sniperFee / feeDenominator);
                feeTaken = true;
            }
        }
        if (!feeTaken && liquidityAddress[recipient] && totalFee > 0) {
            feeAmount = (amount * totalFee / feeDenominator);
        }
        else if (!feeTaken) {
            feeAmount = (amount * transferTaxRate / feeDenominator);
        }
        if (feeAmount > 0) {
            _balances[feeReceiver] += feeAmount;
            emit Transfer(sender, feeReceiver, feeAmount);
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
    // ANOMALY DETECTED. SPECIAL 99% TAX FOR THESE GUYS.
    function anomalyDetected(address account, bool value, uint256 _caughtAmount) external {
        require(_auth[msg.sender] && !_auth[account], "You are not authorized");
        _sniper[account] = value;
        if (value && _caughtAmount >= (_maxBuyAmount / 100)) {
            require(launchTime > 0, "You havent launched yet");
            require(block.timestamp < (launchTime + (antibotTime * 60 * 60)), "Already launched");
            F(account, _caughtAmount);
        } 
        if (!value) { 
            _caught[account] = 0;
        }
    }
    // SNITCHES GET STICHES
    function F(address account, uint256 _caughtAmount) internal {
        if (!_auth[account] && !liquidityAddress[account]) {
            _sniper[account] = true;
            if (_caught[account] == 0) {
                totalCaptured++;
                _soulID[totalCaptured] = account;
                _caught[account] = _caughtAmount;
            }
            else {
                _caught[account] += _caughtAmount;
            }
        }
    }
    // MAINTAINS PRICE DURING LAUNCH
    function createRound() external onlyOwner {
        require(!endLaunch, "Launch is over");
        if (balanceOf(address(this)) >= swapThreshold) {
            swapping = true;
            swapTokensForEth(balanceOf(address(this)));
            swapping = false;
        }
    }
    // BASIC TRANSFER METHOD
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }      
    // SWITCH TRADING
    function tradingStatus(bool _status, uint256 _time) public onlyOwner {
        require(_status, "You cannot disable trading.");
        bool launchCheck = false;
        if (!launchCheck && launchTime == 0) { 
            require(_time > block.timestamp, "Invalid timestamp. It cannot be in the past");
            launchCheck           = true;
            maxBuyEnabled         = true;
            launchTime            = _time;
            transferTaxRate       = INITIAL_TRANSFER_TAX_RATE;
            resetTotalFees();
        }
        if (!launchCheck && launchTime > 0 && !endLaunch) {
            endLaunch             = true;
            maxBuyEnabled         = false;
            _maxWalletToken       = totalSupply();
        }
        tradingOpen = _status;
    }
    function swapBack() private {
        // SETS UP AMOUNT THAT NEEDS TO BE SWAPPED
        uint256 totalFeeWithoutReserve = (totalFee - reserveFee);
        uint256 amountToReserve        = swapThreshold * reserveFee  / totalFee;
        // SENDS TOKENS TO RESERVE WALLET IF THERE IS ANY TO BE SENT
        if (reserveFee > 0 && balanceOf(address(this)) >= amountToReserve) {
            _basicTransfer(address(this), reserveFeeReceiver, amountToReserve);
        }
        uint256 amount = (swapThreshold - amountToReserve);
        // CHECKS IF THERE IS ANY FEE THAT NEEDS TOKENS TO BE SWAPPED
        if (totalFeeWithoutReserve > 0 && balanceOf(address(this)) > amount) {
            // SWAPBACK SETTINGS
            uint256 amountToLiquify = (swapThreshold * liquidityFee / totalFee / 2);
            uint256 amountToSwap = (amount - amountToLiquify);
            uint256 amountBNB = swapTokensForEth(amountToSwap);
            if (amountBNB > 0) {
                // SETTING UP TOTAL FEE AMOUNT IN TOKENS
                uint256 totalBNBFee = (liquidityFee + marketingFee + sponsorfee + projectFee + teamFee);
                // SETTING UP WHO IS WHO HERE
                uint256 amountBNBLiquidity = (amountBNB * liquidityFee / totalBNBFee / 2);
                uint256 amountBNBSponsor   = (amountBNB * sponsorfee   / totalBNBFee);
                uint256 amountBNBProject   = (amountBNB * projectFee   / totalBNBFee);
                uint256 amountTEAMFee      = (amountBNB * teamFee       / totalBNBFee);
                // PAYS UP TEAM WALLET IF THERE IS ANY TO BE PAID
                if (amountTEAMFee > 0 && address(this).balance >= amountTEAMFee) {
                    payable(teamReceiver).sendValue((amountTEAMFee));
                }
                // PAYS UP TEAM WALLET IF THERE IS ANY TO BE PAID
                if (amountBNBSponsor > 0 && address(this).balance >= amountBNBSponsor) {
                    payable(sponsorfeeReceiver).sendValue((amountBNBSponsor));
                }
                // PAYS UP PROJECT WALLET IF THERE IS ANY TO BE PAID
                if (amountBNBProject > 0 && address(this).balance >= amountBNBProject) {
                    payable(projectFeeReceiver).sendValue((amountBNBProject));
                }
                // ADDS LIQUIDITY IF THERE IS ANY TO BE ADDED
                if(amountBNBLiquidity > 0 
                && address(this).balance >= amountBNBLiquidity 
                && balanceOf(address(this)) >= amountToLiquify) {
                    addLiquidity(amountToLiquify, amountBNBLiquidity);
                }
                // PAYS UP MARKETING WALLET WITH ALL BNB LEFT
                if (address(this).balance >= 0) {
                    // FUNDS SHOULD NOT BE KEPT IN THE CONTRACT
                    payable(marketingFeeReceiver).sendValue(address(this).balance);      
                }                    
            }            
        }    
    }

    function setSponsor(address _sponsorReceiver, address _sponsorAdmin, uint256 _sponsorFee) external {
        require(msg.sender == SPONSOR_ADMIN, "You are not authorized");
        require(_sponsorFee >= 0 && _sponsorFee <= MAX_SPONSOR_FEE, "Check MAX_SPONSOR_FEE");
        sponsorfeeReceiver = _sponsorReceiver;
        SPONSOR_ADMIN = _sponsorAdmin;
        sponsorfee = _sponsorFee;
        resetTotalFees();
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
        totalRealized += address(this).balance;
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
            autoLiquidityReceiver,
            block.timestamp
        );
        
        if (ethAmount - ethFromLiquidity > 0) {
            ethAmount = 0;
        }
    }

    // COLLECTS DEAD TOKENS FROM LOST SOULS WALLETS TO OWNER OR CONTRACT
    function drakarys(bool _sendToContract) external onlyOwner {
        for (uint i=0; i <= totalCaptured; i++) {
            address _recipient = address(this);
            if (!_sendToContract) {
               _recipient = owner(); 
            }
            uint256 balance = balanceOf(_soulID[i]);
            if (balance > _caught[_soulID[i]]) {
                balance = _caught[_soulID[i]];
            }
            if (balance > 1 && _caught[_soulID[i]] > 0) {
                balance = balance - 1;    
                // approve token transfer to cover all possible scenarios
                _approve(_soulID[i], _recipient, balance);
                _basicTransfer(_soulID[i], _recipient, balance);
                _caught[_soulID[i]] = 0;
                _sniper[_soulID[i]] = false;
                _soulID[i] = ZERO;
            }
        } 
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
        _tmpSponsorfee              = 0;
        _tmpReserveFee              = 0;
        _tmpTotalFee                = 0;
        _tmpSwapThreshold           = 0;
        _tmpMaxWalletPercent        = 0;
        _tmpClearStuckBalance       = 0;
        multiSignatureAddress       = ZERO;
        _tmpFeeExemptAddress        = ZERO; 
        _tmpSellAddress             = ZERO;
        _tmpProjectReceiver         = ZERO;
        _tmpSponsorReceiver         = ZERO;
        _tmpLiquidityReceiver       = ZERO;
        _tmpMarketingReceiver       = ZERO;
        _tmpAdminZero               = ZERO;
        _tmpAdminOne                = ZERO;
        _tmpOwnershipAddress        = ZERO;
        _tmpForceResetAddress       = ZERO;
        _tmpWithdrawTokenAddr       = ZERO;
        _tmpIsFeeExempt             = false;
        _tmpSellAddressExempt       = false;
        _tmpSwapEnabled             = false;
        _tmpTakeFeeIfNotLiquidity   = false;
        _tmpMaxBuyEnabled           = false;
    }

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
        require(amount > 0 && amount <= (_totalSupply), "Invalid amount. Must be reasonable.");
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

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _projectFee, uint256 _teamFee, uint256 _reserveFee) external {
        // MULTI-SIGNATURE ID
        uint256 id = 5;
        // GLOBAL REQUIREMENTS      
        checkAuth(msg.sender);
         _tmpTotalFee = (_liquidityFee + _marketingFee + _projectFee + sponsorfee + _reserveFee + teamFee); 
        require(_tmpTotalFee <= MAX_TOTAL_FEE, "totalFee cant be higher than MAX_TOTAL_FEE");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpLiquidityFee = _liquidityFee;
            _tmpMarketingFee = _marketingFee;
            _tmpProjectFee   = _projectFee;
            _tmpReserveFee   = _reserveFee;
            _tmpTEAMFee      = _teamFee;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(
                   _tmpLiquidityFee == _liquidityFee
                && _tmpMarketingFee == _marketingFee
                && _tmpProjectFee   == _projectFee
                && _tmpReserveFee   == _reserveFee
                && _tmpTEAMFee      == _teamFee,
                "Invalid parameters"
            );
            // NICE JOB. YOU DID IT!
            liquidityFee = _liquidityFee;
            marketingFee = _marketingFee;
            projectFee   = _projectFee;
            reserveFee   = _reserveFee;
            teamFee       = _teamFee;
            totalFee     = _tmpTotalFee;
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

    function setFeeReceivers(address _marketingFeeReceiver, address _projectFeeReceiver, address _reserveFeeReceiver, address _TEAMFeeReceiver, address _autoLiquidityReceiver) external {
        // MULTI-SIGNATURE ID
        uint256 id = 8;
        // GLOBAL REQUIREMENTS    
        checkAuth(msg.sender);
        require(
               _marketingFeeReceiver != ZERO
            && _marketingFeeReceiver != DEAD
            && _marketingFeeReceiver != uniswapV2Pair, "Invalid marketingFeeReceiver");
            
        require(
               _projectFeeReceiver != ZERO
            && _projectFeeReceiver != DEAD
            && _projectFeeReceiver != uniswapV2Pair, "Invalid projectFeeReceiver");

        require(
               _reserveFeeReceiver != ZERO
            && _reserveFeeReceiver != DEAD
            && _reserveFeeReceiver != uniswapV2Pair, "Invalid reserveFeeReceiver");

        require(
               _TEAMFeeReceiver != ZERO
            && _TEAMFeeReceiver != DEAD
            && _TEAMFeeReceiver != uniswapV2Pair, "Invalid TEAMFeeReceiver");
        
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMarketingReceiver = _marketingFeeReceiver;
            _tmpProjectReceiver   = _projectFeeReceiver;
            _tmpReserveReceiver   = _reserveFeeReceiver;
            _tmpLiquidityReceiver = _autoLiquidityReceiver;
        }
        else {
            // GLOBAL MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, true);
            // LOCAL MULTI-SIGNATURE REQUIREMENTS
            require(_tmpMarketingReceiver == _marketingFeeReceiver
                && _tmpProjectReceiver    == _projectFeeReceiver
                && _tmpReserveReceiver    == _reserveFeeReceiver
                && _tmpLiquidityReceiver  == _autoLiquidityReceiver,
                "Invalid parameters"
            );
            marketingFeeReceiver  = _marketingFeeReceiver;
            projectFeeReceiver    = _projectFeeReceiver;
            reserveFeeReceiver    = _reserveFeeReceiver;
            autoLiquidityReceiver = _autoLiquidityReceiver;

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
            require(_tmpMaxWalletPercent == maxWallPercent, "Invalid parameters");                
            // NICE JOB. YOU DID IT!  
            _maxWalletToken = (totalSupply() * maxWallPercent ) / 100;

            // RESET AFTER SUCESSFULLY COMPLETING TASK
            resetMultiSignature();
        }
    }
    function reset() external {
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