/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// Speakeasy $SPEEZY
//  _____                  _                        
// /  ___|                | |                       
// \ `--. _ __   ___  __ _| | _____  __ _ ___ _   _ 
//  `--. \ '_ \ / _ \/ _` | |/ / _ \/ _` / __| | | |
// /\__/ / |_) |  __/ (_| |   <  __/ (_| \__ \ |_| |
// \____/| .__/ \___|\__,_|_|\_\___|\__,_|___/\__, |
//       | |                                   __/ |
//       |_|                                  |___/ 
//
// The best kept secret on BSC.
//
// Anti-Dump Tokenomics
// Automatic Jackpot Entries
// BNB Swap Thresholds
// Max Tax: 23%
// Anti-Sniper Bot Blacklist ONLY (No Manual Blacklist)
// web: speakeasy.finance
// telegram: t.me/speakeasytoken
// twitter: twitter.com/speakeasytoken
// jackpot dapp: spinbsc.com
// betting dapp: spinbsc.com/bets
// written by: @cyber_draco

pragma solidity 0.8.11;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

library Address {
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
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
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
// Interface for our Jackpot games
interface IGameBase {
    function isGameActive() external view returns (bool);
    function getCreditPrice() external view returns(uint256);
}
interface IGame is IGameBase {
    function placeBet(address _bettor, uint256 _toBet) external;

    function addtokenAmount(uint256 _tokens) external;

    function removeBet(address _bettor) external returns (uint256);

    function setCreditPrice(uint256 _amount) external;
}

contract Speakeasy is Context, IERC20, Ownable{
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public _marketingTaxToRedistr = 0;
    uint256 public _devTaxToRedistr = 0;
    uint256 public swapTokensAtBNBAmountforLP;
    uint256 public swapTokensAtBNBAmountforMarketing;
    uint256 public swapTokensAtBNBAmountforDev;
    uint256 public maxSwapTokensAtBNBAmountforLP;
    uint256 public maxSwapTokensAtBNBAmountforMarketing;
    uint256 public maxSwapTokensAtBNBAmountforDev;

    // presale values
    address private _presaleAddress;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    
    mapping (address => bool) public _isBlackListedBot;
    address[] private _blackListedBots;
   
    mapping (address => bool) public _isExcludedFromCredits;
    mapping (address => bool) public _isExcludedFromCreditRemoval;
    mapping (address => bool) public _isExcludedToCreditRemoval;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    string private constant _name = "Speakeasy";
    string private constant _symbol = "SPEEZY";
    uint8 private constant _decimals = 18;
    
    struct AddressFee {
        bool enable;
        uint256 _taxFee;
        uint256 _liquidityFee;
        uint256 _buyTaxFee;
        uint256 _buyLiquidityFee;
        uint256 _sellTaxFee;
        uint256 _sellLiquidityFee;
        uint256 _marketingTax;
        uint256 _devTax;
        uint256 _buyMarketingTax;
        uint256 _buyDevTax;
        uint256 _sellMarketingTax;
        uint256 _sellDevTax;
    }

    // flexible defining all the jackpots
    struct JackpotFee {
        string name;
        bool enable;
        uint256 multiplicator;
        IGame game;
    }
    
    //ISpeakeasyOverSellStorage public _overSellStore;
    address public _overSell;

    // sell data max allowance
    bool private _isSelling = false;
    ////mapping(address => SellDataHeader) private _sellDataHeader;
    //SellDataItem[] private _sellDataItem;
    uint256 private maxSellAllowanceTime = 86400; // 24 hours
    uint256 private maxSellAllowanceBeforeExtra = 1 * 10**18; // 1 BNB
    uint256 public _sellExtraTaxFee = 8;
    uint256 public _sellExtraLiquidityFee = 2;

    uint256 public _taxFee = 11;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;
    
    uint256 public _buyTaxFee = 3;
    uint256 public _buyLiquidityFee = 0;
    
    uint256 public _sellTaxFee = 11;
    uint256 public _sellLiquidityFee = 2;

    // tax split
	// marketing
	uint256 public _marketingTax = 6;
    uint256 private _previousMarketingTax = _marketingTax;
    uint256 public _buyMarketingTax = 0;
    uint256 public _sellMarketingTax = 6;
    uint256 public _sellExtraMarketingTax = 5;
	address payable public marketingWallet = payable(0x42979Ab546B5fF75E5DCEbb17363878D2F72b0F2);
	// dev
    uint256 public _devTax = 2; 
    uint256 private _previousDevTax = _devTax;
    uint256 public _buyDevTax = 0;
    uint256 public _sellDevTax = 2;
    uint256 public _sellExtraDevTax = 0;
	address payable public devWallet = payable(0x6176d1913d4577a70adf93144dA355874355713D);
    // jackpots
    mapping (address => JackpotFee) public jackpotWallets;
    address[] private _jackpotWallets;
	
	// false = only enabled can trade or owner (add LP)
	// true = all can trade
	bool tradingEnabled = false;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool private swapAndLiquifyEnabled = true;
    
    // Fee per address
    mapping (address => AddressFee) public addressFees;

    uint256 public _maxTxAmount = 1000000000 * 10**18;
    
    uint256 private liquidityActiveBlock = 0; // 0 means liquidity is not active yet

    bool public _autoSendLP = true;
    bool public _autoSendTax = true;

    enum AddressFeeType{ TRANSF, BUY, SELL }

    // Events
    //event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    
    event ExclusionOfRewardsChanged(address account, bool excluded);
    event ExclusionOfFeesChanged(address account, bool excluded);

    //event TaxFeePercentChanged(uint256 fee);
    //event LiquidityFeePercentChanged(uint256 fee);
    event MaxTxPercentChanged(uint256 percent);
    
    event FeesChanged(uint256 taxFee, uint256 liquidityFee, uint256 marketingTax, uint256 devTax);
    event BuyFeesChanged(uint256 buyTaxFee, uint256 buyLiquidityFee, uint256 buyMarketingTax, uint256 buyDevTax);
    event SellFeesChanged(uint256 sellTaxFee, uint256 sellExtraTaxFee, uint256 sellLiquidityFee, uint256 sellExtraLiquidityFee, uint256 sellMarketingTax, uint256 sellExtraMarketingTax, uint256 sellDevTax, uint256 sellExtraDevTax);
    event SellExtraFeesChanged(uint256 sellExtraTaxFee, uint256 sellExtraLiquidityFee);
    
    event AddressFeesChanged(address account, bool enabled, AddressFeeType feeType, uint256 taxFee, uint256 liquidityFee, uint256 marketingTax, uint256 devTax);
    event AddressBuyFeesChanged(address account, bool enabled, uint256 buyTaxFee, uint256 buyLiquidityFee, uint256 buyMarketingTax, uint256 buyDevTax);
    event AddressSellFeesChanged(address account, bool enabled, uint256 sellTaxFee, uint256 sellLiquidityFee, uint256 sellMarketingTax, uint256 sellDevTax);

    event JackpotWalletChanged(address account, bool enabled, uint256 multiplicator, address game);
    event JackpotWalletDeleted(address account);

    event taxWalletsChanged(address marketing, address dev);
    
    event TradingEnabled(bool enabled);

    event MaxSellAllowanceChanged(uint256 maxAllowance, uint256 maxAllowanceTime);

    event UpdateUniswapV2Router( address indexed newAddress, address indexed oldAddress );

    event ExclusionOfCreditsChanged(address account, bool excluded);
    event ExclusionFromCreditsRemovalChanged(address account, bool excluded); 
    event ExclusionToCreditsRemovalChanged(address account, bool excluded); 

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // mainnet
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // testnet
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        // Swap tokens(for reward, liquidity, other fees) when contract balance is 'swapTokensAtBNBAmountforLP' worth
        //setSwapTokensBNBLimit(0.1 ether, 0.1 ether, 0.1 ether, 1 ether, 1 ether, 1 ether);
        swapTokensAtBNBAmountforLP = 0.1 ether;
        swapTokensAtBNBAmountforMarketing = 0.1 ether;
        swapTokensAtBNBAmountforDev = 0.1 ether;//0.1 ether;
        maxSwapTokensAtBNBAmountforLP = 1 ether;
        maxSwapTokensAtBNBAmountforMarketing = 1 ether;
        maxSwapTokensAtBNBAmountforDev = 1 ether;//0.1 ether;

        // default exclusion from credit removal
        _isExcludedFromCredits[address(0)] = true;
        _isExcludedFromCredits[address(0xdead)] = true;
        _isExcludedFromCredits[owner()] = true;

        // default exclusion from credit removal
        _isExcludedFromCreditRemoval[uniswapV2Pair] = true;
        _isExcludedFromCreditRemoval[owner()] = true;
        _isExcludedFromCreditRemoval[address(uniswapV2Router)] = true;
        _isExcludedFromCreditRemoval[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string  memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
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

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _isBlackListedBot[account];
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        //require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function setExclusionFromRewards(address account, bool enabled) external onlyOwner(){
        if(enabled){
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _isExcluded[account] = true;
            _excluded.push(account);
        }else{
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
        emit ExclusionOfRewardsChanged(account, enabled);
    }
    function setExclusionFromFees(address account, bool enable) external onlyOwner(){
        _isExcludedFromFee[account] = enable;
        emit ExclusionOfFeesChanged(account, enable);
    }
    // Update the BNB limit to swap the tokens for rewards
    function setSwapTokensBNBLimit(uint256 _limitLP, uint256 _limitMarketing, uint256 _limitDev, uint256 _maxLimitLP, uint256 _maxLimitMarketing, uint256 _maxLimitDev) external onlyOwner {
        require(_limitLP >= 0.1 ether && _limitMarketing >= 0.1 ether && _limitDev >= 0.1 ether  && _maxLimitLP >= 0.1 ether && _maxLimitMarketing >= 0.1 ether && _maxLimitLP >= 0.1 ether &&
            _limitLP <= _maxLimitLP && _limitMarketing <= _maxLimitMarketing && _limitDev <= _maxLimitDev, "Invalid swap tokens limit! for gas fee purposes it needs to be more 0.1 BNB! and limit cant be higher max limit");
        swapTokensAtBNBAmountforLP = _limitLP;
        swapTokensAtBNBAmountforMarketing = _limitMarketing;
        swapTokensAtBNBAmountforDev = _limitDev;    
        maxSwapTokensAtBNBAmountforLP = _maxLimitLP;
        maxSwapTokensAtBNBAmountforMarketing = _maxLimitMarketing;
        maxSwapTokensAtBNBAmountforDev = _maxLimitDev;
    }

    function setMaxSellAllowanceBeforeExtra(uint256 maxAllowance, uint256 maxAllowanceTime) external onlyOwner(){
        maxSellAllowanceBeforeExtra = maxAllowance;
        maxSellAllowanceTime = maxAllowanceTime;

        emit MaxSellAllowanceChanged(maxAllowance, maxAllowanceTime);
    }
    function getMaxSellAllowanceBeforeExtra() external view returns (uint256, uint256){
        return( maxSellAllowanceBeforeExtra, maxSellAllowanceTime );
    }
   
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        require(maxTxPercent >  1, "Max transaction percentage has to be higher 1%");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
        
        emit MaxTxPercentChanged(maxTxPercent);
    }

    function removeBlacklist(address account) external onlyOwner() {
        for (uint256 i = 0; i < _blackListedBots.length; i++) {
            if (_blackListedBots[i] == account) {
                _blackListedBots[i] = _blackListedBots[_blackListedBots.length - 1];
                _isBlackListedBot[account] = false;
                _blackListedBots.pop();
                break;
            }
        }

    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    // if feeType = 0 = Transfer
    // if feeType = 1 = Buy
    // if feeType = 2 = Sell
    function setFees(AddressFeeType feeType, uint256 taxFee, uint256 liquidityFee, uint256 marketingTax, uint256 devTax, uint256 sellExtraTaxFee, uint256 sellExtraLiquidityFee, uint256 sellExtraMarketingTax, uint256 sellExtraDevTax) external onlyOwner {
        if(feeType == AddressFeeType.TRANSF){
            require(liquidityFee+taxFee<25 && marketingTax+devTax<= taxFee, "Taxes/fees higher 25 is not allowed && internal taxes can't be higher global tax value");
            _taxFee = taxFee;
            _liquidityFee = liquidityFee;
            _marketingTax = marketingTax;
            _devTax = devTax;

            emit FeesChanged(taxFee, liquidityFee, marketingTax, devTax);
        }else if(feeType == AddressFeeType.BUY){
            require(liquidityFee+taxFee<25 && marketingTax+devTax<= taxFee, "Taxes/fees higher 25 is not allowed && internal taxes can't be higher global tax value");
            _buyTaxFee = taxFee;
            _buyLiquidityFee = liquidityFee;
            _buyMarketingTax = marketingTax;
            _buyDevTax = devTax;

            emit BuyFeesChanged(taxFee, liquidityFee, marketingTax, devTax);
        }else if(feeType == AddressFeeType.SELL){ // if type SELL it uses the sellExtra* Parameters otherwise not
            require((sellExtraLiquidityFee+sellExtraTaxFee)+(liquidityFee+taxFee)<25 && marketingTax+devTax<= taxFee && sellExtraMarketingTax+sellExtraDevTax<= sellExtraTaxFee, "Taxes/fees + extra sell taxes higher 25 is not allowed && internal taxes can't be higher global tax value");
            _sellTaxFee = taxFee;
            _sellExtraTaxFee = sellExtraTaxFee;
            _sellLiquidityFee = liquidityFee;
            _sellExtraLiquidityFee = sellExtraLiquidityFee;
            _sellMarketingTax = marketingTax;
            _sellExtraMarketingTax = sellExtraMarketingTax;
            _sellDevTax = devTax;
            _sellExtraDevTax = sellExtraDevTax;
        
            emit SellFeesChanged(taxFee, sellExtraTaxFee, liquidityFee, sellExtraLiquidityFee, marketingTax, sellExtraMarketingTax, devTax, sellExtraDevTax);
        }
    }
    // if feeType = 0 = Transfer
    // if feeType = 1 = Buy
    // if feeType = 2 = Sell
    function setAddressFee(address _address, bool _enable, AddressFeeType feeType, uint256 _addressTaxFee, uint256 _addressLiquidityFee, uint256 _addressMarketingTax, uint256 _addressDevTax) external onlyOwner {
        addressFees[_address].enable = _enable;
        if(feeType == AddressFeeType.TRANSF){
            addressFees[_address]._taxFee = _addressTaxFee;
            addressFees[_address]._liquidityFee = _addressLiquidityFee;
            addressFees[_address]._marketingTax = _addressMarketingTax;
            addressFees[_address]._devTax = _addressDevTax;
        }else if(feeType == AddressFeeType.BUY){
            addressFees[_address]._buyTaxFee = _addressTaxFee;
            addressFees[_address]._buyLiquidityFee = _addressLiquidityFee;
            addressFees[_address]._buyMarketingTax = _addressMarketingTax;
            addressFees[_address]._buyDevTax = _addressDevTax;
        }else if(feeType == AddressFeeType.SELL){
            addressFees[_address]._sellTaxFee = _addressTaxFee;
            addressFees[_address]._sellLiquidityFee = _addressLiquidityFee;
            addressFees[_address]._sellMarketingTax = _addressMarketingTax;
            addressFees[_address]._sellDevTax = _addressDevTax;
        }
        
        emit AddressFeesChanged(_address, _enable, feeType, _addressTaxFee, _addressLiquidityFee, _addressMarketingTax, _addressDevTax);
    }
    
    function setTaxWallets(address marketingAddress, address devAddress) external onlyOwner {
        marketingWallet = payable(marketingAddress);
        devWallet = payable(devAddress);
        
        emit taxWalletsChanged(marketingAddress, devAddress);
    }
    
    function enableTrading() external onlyOwner{
        tradingEnabled = true;
        liquidityActiveBlock = block.number; // when trading enabled for bot protection
        
        emit TradingEnabled(true);
    }    

    //--------------------- game related functions begin ---------------------//
    function setJackpotGame(address _address, bool _enable, uint256 _multiplicator, address _game) external onlyOwner() {
        jackpotWallets[_address].enable = _enable;
        jackpotWallets[_address].multiplicator =  _multiplicator;
        jackpotWallets[_address].game = IGame(_game);
        _jackpotWallets.push(_address);

        _isExcludedFromFee[_game] = true;
        _isExcludedFromCredits[_game] = true;
        _isExcludedFromCreditRemoval[_game] = true;

        emit JackpotWalletChanged(_address, _enable, _multiplicator, _game);
    }
    function removeJackpotGame(address _address) external onlyOwner() {
        delete jackpotWallets[_address];
        for (uint256 i = 0; i < _jackpotWallets.length; i++) {
            if (_jackpotWallets[i] == _address) {
                _jackpotWallets[i] = _jackpotWallets[_jackpotWallets.length - 1];
                _jackpotWallets.pop();
                break;
            }
        }
        emit JackpotWalletDeleted(_address);
    }

    function setExclusionToAddrFromCredits(address account, bool enabled) external onlyOwner {
        _isExcludedFromCredits[account] = enabled;
        
        emit ExclusionOfCreditsChanged(account, enabled);
    }

    function setExclusionFromAddrFromCredits(address account, bool enabled) external onlyOwner {
        _isExcludedFromCreditRemoval[account] = enabled;
        
        emit ExclusionFromCreditsRemovalChanged(account, enabled);
    }

    function setExclusionToAddrFromCreditRemoval(address account, bool enabled) external onlyOwner{
        _isExcludedToCreditRemoval[account] = enabled;
        
        emit ExclusionToCreditsRemovalChanged(account, enabled);
    }
    
    function setCreditPrice(address _address, uint256 _amount) external onlyOwner(){
        jackpotWallets[_address].game.setCreditPrice(_amount);
    }
    function getCreditPrice(address _address) external view returns (uint256){
        return jackpotWallets[_address].game.getCreditPrice();
    }
    function gameIsActive(address _address) external view returns (bool){
        return jackpotWallets[_address].game.isGameActive();
    }
    //--------------------- game related functions end ---------------------//
     //to receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    function _sendTax(uint256 rFee, uint256 tFee, uint256 rOverSellFee, uint256 tOverSellFee) private{
        
        // no tax no needs
        if(rFee == 0 && tFee == 0 && rOverSellFee == 0 && tOverSellFee == 0)
            return;

        uint256 currentRate = _getRate();
        bool noJackpotGames = true;
        if(_jackpotWallets.length > 0){
            for (uint i=0; i<_jackpotWallets.length; i++) {
                if(_jackpotWallets[i] != address(0)){
                    noJackpotGames = false;
                    break;
                }
            }
        }

        uint256 tDevTax = 0;
        if(noJackpotGames == true){
            tDevTax = (tFee.mul(_devTax).div(_taxFee)).add(tOverSellFee.mul(_sellExtraDevTax).div(_sellExtraTaxFee)); 
            _rOwned[address(this)] = _rOwned[address(this)].add(rFee).add(rOverSellFee);
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tFee).add(tOverSellFee);
            _marketingTaxToRedistr = _marketingTaxToRedistr.add(tFee.add(tOverSellFee).sub(tDevTax));
            _devTaxToRedistr = _devTaxToRedistr.add(tDevTax);
            return;
        }else{
            uint256 tMarketingTax = (tFee.mul(_marketingTax).div(_taxFee)).add(tOverSellFee.mul(_sellExtraMarketingTax).div(_sellExtraTaxFee));
            tDevTax = (tFee.mul(_devTax).div(_taxFee)).add(tOverSellFee.mul(_sellExtraDevTax).div(_sellExtraTaxFee)); 
            uint256 tFeesExclGames = tMarketingTax.add(tDevTax);
            uint256 rFeesExclGames = tFeesExclGames.mul(currentRate);//(rFee.mul(_marketingTax).div(_taxFee)).add(rOverSellFee.mul(_sellExtraMarketingTax).div(_sellExtraTaxFee)).add(rFee.mul(_devTax).div(_taxFee)).add(rOverSellFee.mul(_sellExtraDevTax).div(_sellExtraTaxFee));
            _rOwned[address(this)] = _rOwned[address(this)].add(rFeesExclGames);
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tFeesExclGames);
            _marketingTaxToRedistr = _marketingTaxToRedistr.add(tMarketingTax);
            _devTaxToRedistr = _devTaxToRedistr.add(tDevTax);

            tFee = (tFee.add(tOverSellFee)).sub(tFeesExclGames);
        }
        if(tFee > 0 && noJackpotGames == false){
           //max multiplicator
            uint256 _maxMultiplicator = 0;
            // calculate the max multiplicators
            for (uint i=0; i<_jackpotWallets.length; i++) {
                if(_jackpotWallets[i] != address(0) && jackpotWallets[_jackpotWallets[i]].enable == true){
                    _maxMultiplicator = _maxMultiplicator.add(jackpotWallets[_jackpotWallets[i]].multiplicator);
                }
            }

            for (uint i=0; i<_jackpotWallets.length; i++) {
                if(jackpotWallets[_jackpotWallets[i]].enable == true){
                    // calculate the fees going to each jackpot
                    _sendJackpotTax(i, jackpotWallets[_jackpotWallets[i]].multiplicator, _maxMultiplicator, tFee);
                    _maxMultiplicator = _maxMultiplicator.sub(jackpotWallets[_jackpotWallets[i]].multiplicator);
                }
           }
        }
    }
    function _sendJackpotTax(uint256 walletIndex, uint256 _multiplicator, uint256 _maxMultiplicator, uint256 tFee) 
        private{
        
        uint256 currentRate = _getRate();
        uint256 tSingleJackpotTax = 0;
        uint256 rSingleJackpotTax = 0;
        tSingleJackpotTax = tFee.mul(_multiplicator).div(_maxMultiplicator);
        rSingleJackpotTax = tSingleJackpotTax.mul(currentRate);
        _rOwned[_jackpotWallets[walletIndex]] = _rOwned[_jackpotWallets[walletIndex]].add(rSingleJackpotTax);
        _tOwned[_jackpotWallets[walletIndex]] = _tOwned[_jackpotWallets[walletIndex]].add(tSingleJackpotTax);

        // assign token amount to the correct game
        jackpotWallets[_jackpotWallets[walletIndex]].game.addtokenAmount(tSingleJackpotTax);
    }
    // reflection ----------------------------------------------------- //
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getOverSellTValues(uint256 tTransferAmount, uint256 tAmount ) private view returns (uint256, uint256, uint256) {
        uint256 tOverSellFee = calculateOverSellTaxFee(tAmount);
        uint256 tOverSellLiquidity = calculateOverSellLiquidityFee(tAmount);
        tTransferAmount = tTransferAmount.sub(tOverSellFee).sub(tOverSellLiquidity);
        return (tTransferAmount,  tOverSellFee, tOverSellLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity) private view returns (uint256, uint256, uint256) {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getOverSellRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tOverSellFee, uint256 tOverSellLiquidity) private view returns (uint256, uint256) {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rOverSellFee = tOverSellFee.mul(currentRate);
        uint256 rOverSellLiquidity = tOverSellLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rOverSellFee).sub(rOverSellLiquidity);
        return (rTransferAmount, rOverSellFee);
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
    
    function _takeLiquidity(uint256 tLiquidity, uint256 tOverSellLiquidity) private {
        uint256 currentRate =  _getRate();
        tLiquidity = tLiquidity.add(tOverSellLiquidity);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateOverSellTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_sellExtraTaxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }

    function calculateOverSellLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_sellExtraLiquidityFee).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _taxFee = 0;
        _liquidityFee = 0;

        // same for marketing/dev/jackpot split
        _previousMarketingTax = _marketingTax;
        _previousDevTax = _devTax;
        _marketingTax = 0;
        _devTax = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _marketingTax = _previousMarketingTax;
        _devTax = _previousDevTax;
    }
    
    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        //require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0) && owner != address(0), "ERC20: approve from/to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0) && to != address(0) && amount > 0, "ERC20: transfer from/to the zero address && transfer amount must be greater than zero");
        require(( tradingEnabled &&  ( !_isBlackListedBot[from] && !_isBlackListedBot[to] && !_isBlackListedBot[tx.origin] )) || from == owner() || to == owner() || tx.origin == owner() || from == _presaleAddress || to == _presaleAddress || tx.origin == _presaleAddress, "Trading is not enabled or account is blacklisted");
        
        if(from != owner() && to != owner() && from != _presaleAddress && to != _presaleAddress)
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        if (
            tradingEnabled &&
            block.number < liquidityActiveBlock + 3 && // 3 blocks against the snipers/bots
            from ==uniswapV2Pair
        ) {
            _isBlackListedBot[to] = true;
        }

        if (!tradingEnabled) {
            require(
                from == owner() || from == address(uniswapV2Router) || from == _presaleAddress,
                "Trading is not active."
            );
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        if (
            tradingEnabled &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled && 
            ( _autoSendLP || 
            _autoSendTax ) 
        ) {
            //redistribute tax first
            if(_autoSendTax)
                contractTokenBalance = redistributeBNBTax(contractTokenBalance);
            //reload Contract Balance
            if(_autoSendLP){
                //add liquidity
                contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance >= _maxTxAmount)
                {
                    contractTokenBalance = _maxTxAmount;
                }
                uint256 maxTokensforLP = getAmountTokensOut(maxSwapTokensAtBNBAmountforLP);
                uint256 minTokensforLP = getAmountTokensOut(swapTokensAtBNBAmountforLP);
                uint256 LPToRedistr = (contractTokenBalance.sub(_marketingTaxToRedistr)).sub(_devTaxToRedistr);
                bool overMinTokenforLPBalanceforLP = LPToRedistr > minTokensforLP;
                bool overMaxTokenforLPBalanceforLP = LPToRedistr > maxTokensforLP;
                            
                if (overMinTokenforLPBalanceforLP){
                    if(overMaxTokenforLPBalanceforLP)
                        LPToRedistr = maxTokensforLP;
                    swapAndLiquify(LPToRedistr);
                }
                    
            }
        }
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        _isSelling = false;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }else{
            // Buy
            if(from == uniswapV2Pair){
                removeAllFee();
                _taxFee = _buyTaxFee;
                _liquidityFee = _buyLiquidityFee;
                _marketingTax = _buyMarketingTax;
                _devTax = _buyDevTax;
            }
            // Sell
            if(to == uniswapV2Pair){
                removeAllFee();
                _isSelling = true;
                _taxFee = _sellTaxFee;
                _liquidityFee = _sellLiquidityFee;
                _marketingTax = _sellMarketingTax;
                _devTax = _sellDevTax;
            }
            
            // If send account has a special fee 
            if(addressFees[from].enable){
                removeAllFee();
                _taxFee = addressFees[from]._taxFee;
                _liquidityFee = addressFees[from]._liquidityFee;
                _marketingTax = addressFees[from]._marketingTax;
                _devTax = addressFees[from]._devTax;
                
                // Sell
                if(to == uniswapV2Pair){
                    removeAllFee();
                    _taxFee = addressFees[from]._sellTaxFee;
                    _liquidityFee = addressFees[from]._sellLiquidityFee;
                    _marketingTax = addressFees[from]._sellMarketingTax;
                    _devTax = addressFees[from]._sellDevTax;
                }
            }else{
                // If buy account has a special fee
                if(addressFees[to].enable){
                    //buy
                    removeAllFee();
                    if(from == uniswapV2Pair){
                        _taxFee = addressFees[to]._buyTaxFee;
                        _liquidityFee = addressFees[to]._buyLiquidityFee;
                    }
                }
            }
        }
        
        // check the game
        if( from == uniswapV2Pair &&
            _isExcludedFromCredits[to] == false){

                for (uint i=0; i<_jackpotWallets.length; i++) {
                    require(
                        jackpotWallets[_jackpotWallets[i]].game.isGameActive(),
                        "One Jackpot is not active"
                    );
                }
                for (uint i=0; i<_jackpotWallets.length; i++) {
                    uint256 amountsBNB = getAmountBNBIn(amount);
                    jackpotWallets[_jackpotWallets[i]].game.placeBet(to, amountsBNB);
                }
        }
        // Remove bets of token seller (depending on the jackpot this function can differ)
        if ( _isExcludedFromCreditRemoval[from] == false &&
            _isExcludedToCreditRemoval[to] == false 
        ) {
            bytes memory removeBetsData;
            for (uint i=0; i<_jackpotWallets.length; i++) {
                if(_jackpotWallets[i] != address(0))
                    removeBetsData = abi.encodeWithSelector(bytes4(keccak256("removeBet(address)")), from);
                    (bool success,) = _jackpotWallets[i].call(removeBetsData);
            }
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function redistributeBNBTax(uint256 contractTokenBalance) private lockTheSwap returns (uint256){

        // variables
        uint256 initialBalance;
        uint256 newBalance;
        uint256 marketingTaxToRedistr = _marketingTaxToRedistr;
        uint256 devTaxToRedistr = _devTaxToRedistr;

        // max and min token values
        uint256 maxTokensforMarketing = getAmountTokensOut(maxSwapTokensAtBNBAmountforMarketing);
        uint256 minTokensforMarketing = getAmountTokensOut(swapTokensAtBNBAmountforMarketing);
        bool overMinTokenforMarketing = _marketingTaxToRedistr > minTokensforMarketing;
        bool overMaxTokensforMarketing = _marketingTaxToRedistr > maxTokensforMarketing;

        contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        if(overMinTokenforMarketing && marketingTaxToRedistr < contractTokenBalance){
            if(overMaxTokensforMarketing)
                marketingTaxToRedistr = maxTokensforMarketing;
            // initial BNB balance
            initialBalance = address(this).balance;    
            // swap marketing-tax    
            swapTokensForEth(marketingTaxToRedistr);
            // check the BNB amount
            // how much ETH did we just swap into?
            newBalance = address(this).balance.sub(initialBalance);
            // redistribution marketing tax
            payable(marketingWallet).transfer(newBalance);
            //remove from token balance
            contractTokenBalance = contractTokenBalance.sub(marketingTaxToRedistr);
            // reset marketing tax
            _marketingTaxToRedistr = _marketingTaxToRedistr.sub(marketingTaxToRedistr);
        }
        //dev tax
        uint256 maxTokensforDev = getAmountTokensOut(maxSwapTokensAtBNBAmountforDev);
        uint256 minTokensforDev = getAmountTokensOut(swapTokensAtBNBAmountforDev);
        bool overMinTokensforDev = _devTaxToRedistr >= minTokensforDev;
        bool overMaxTokensforDev = _devTaxToRedistr >= maxTokensforDev;

        contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        if(overMinTokensforDev && devTaxToRedistr < contractTokenBalance){
            if(overMaxTokensforDev)
                devTaxToRedistr = maxTokensforDev;
            initialBalance = address(this).balance; 
            // swap marketing-tax    
            swapTokensForEth(devTaxToRedistr);
            // check the BNB amount
            // how much ETH did we just swap into?
            newBalance = address(this).balance.sub(initialBalance);
            // redistribution dev tax
            payable(devWallet).transfer(newBalance);
            //remove from token balance
            contractTokenBalance = contractTokenBalance.sub(devTaxToRedistr);
            // reset dev tax
            _devTaxToRedistr = _devTaxToRedistr.sub(devTaxToRedistr);
        }

        return contractTokenBalance;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // initial BNB balance
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
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
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        uint256 rOverSellFee = 0;
        uint256 tOverSellFee = 0;
        uint256 tOverSellLiquidity = 0;

        if(_isSelling && _overSell != address(0)){
            bytes memory data = abi.encodeWithSignature("calculateOverSellBNB(address,uint256)",sender,tAmount);
            (bool success, bytes memory returnedData) = address(_overSell).call(data);
            uint256 overSellPrice;
            if(success)
                overSellPrice = abi.decode(returnedData, (uint256));
            else
                overSellPrice = 0;

            (tTransferAmount, tOverSellFee, tOverSellLiquidity) = _getOverSellTValues(tTransferAmount, overSellPrice);
            (rTransferAmount, rOverSellFee) = _getOverSellRValues(tAmount, tOverSellFee, tOverSellLiquidity, tFee, tLiquidity);
        }
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity, tOverSellLiquidity);
        _sendTax(rFee, tFee, rOverSellFee, tOverSellFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        uint256 rOverSellFee = 0;
        uint256 tOverSellFee = 0;
        uint256 tOverSellLiquidity = 0;

        if(_isSelling && _overSell != address(0)){
            bytes memory data = abi.encodeWithSignature("calculateOverSellBNB(address,uint256)",sender,tAmount);
            (bool success, bytes memory returnedData) = address(_overSell).call(data);
            uint256 overSellPrice;
            if(success)
                overSellPrice = abi.decode(returnedData, (uint256));
            else
                overSellPrice = 0;

            (tTransferAmount, tOverSellFee, tOverSellLiquidity) = _getOverSellTValues(tTransferAmount, overSellPrice);
            (rTransferAmount, rOverSellFee) = _getOverSellRValues(tAmount, tOverSellFee, tOverSellLiquidity, tFee, tLiquidity);
        }
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity, tOverSellLiquidity);
        _sendTax(rFee, tFee, rOverSellFee, tOverSellFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        uint256 rOverSellFee = 0;
        uint256 tOverSellFee = 0;
        uint256 tOverSellLiquidity = 0;

        if(_isSelling && _overSell != address(0)){
            bytes memory data = abi.encodeWithSignature("calculateOverSellBNB(address,uint256)",sender,tAmount);
            (bool success, bytes memory returnedData) = address(_overSell).call(data);
            uint256 overSellPrice;
            if(success)
                overSellPrice = abi.decode(returnedData, (uint256));
            else
                overSellPrice = 0;

            (tTransferAmount, tOverSellFee, tOverSellLiquidity) = _getOverSellTValues(tTransferAmount, overSellPrice);
            (rTransferAmount, rOverSellFee) = _getOverSellRValues(tAmount, tOverSellFee, tOverSellLiquidity, tFee, tLiquidity);
        }
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity, tOverSellLiquidity);
        _sendTax(rFee, tFee, rOverSellFee, tOverSellFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        uint256 rOverSellFee = 0;
        uint256 tOverSellFee = 0;
        uint256 tOverSellLiquidity = 0;

        if(_isSelling && _overSell != address(0)){
            bytes memory data = abi.encodeWithSignature("calculateOverSellBNB(address,uint256)",sender,tAmount);
            (bool success, bytes memory returnedData) = address(_overSell).call(data);
            uint256 overSellPrice;
            if(success)
                overSellPrice = abi.decode(returnedData, (uint256));
            else
                overSellPrice = 0;
            
            (tTransferAmount, tOverSellFee, tOverSellLiquidity) = _getOverSellTValues(tTransferAmount, overSellPrice);
            (rTransferAmount, rOverSellFee) = _getOverSellRValues(tAmount, tOverSellFee, tOverSellLiquidity, tFee, tLiquidity);
        }
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity, tOverSellLiquidity);
        _sendTax(rFee, tFee, rOverSellFee, tOverSellFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // tokens to bnb calc
    function getAmountTokensOut(uint256 _amountBNB)
        public
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        try uniswapV2Router.getAmountsOut(_amountBNB, path) returns (
            uint256[] memory amountsOut
        ) {
            return amountsOut[1];
        } catch {
            return 0;
        }
    }

    // bnb calculations (in and out / pancake)
    function getAmountBNBIn(uint256 _amountTokens)
        public
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        try uniswapV2Router.getAmountsIn(_amountTokens, path) returns (
            uint256[] memory amountsIn
        ) {
            return amountsIn[0];
        } catch {
            return 0;
        }
    }
    function getAmountBNBOut(uint256 _amountTokens)
        external
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        try uniswapV2Router.getAmountsOut(_amountTokens, path) returns (
            uint256[] memory amountsOut
        ) {
            return amountsOut[1];
        } catch {
            return 0;
        }
    }

    function setAutoSend(bool lp_, bool tax_) external onlyOwner {
        _autoSendLP = lp_;
        _autoSendTax = tax_;
    }

    function withdrawBNB(uint256 _amount) external onlyOwner {
        (bool success,) = address(msg.sender).call{
            value: _amount
        }("");
        
    }
    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require( newAddress != address(uniswapV2Router), "The router already has that address" );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);

         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
    } //exclude has to be made manually from credits etc

    function setOverSellAddress(address overSell_) external onlyOwner{
        _overSell = overSell_;
    }

    function setTaxesToRedistribute(uint256 marketingTaxAmount, uint256 devTaxAmount) external onlyOwner{
        _marketingTaxToRedistr = marketingTaxAmount;
        _devTaxToRedistr = devTaxAmount;
    }

    function setPresaleAddress(address account) external onlyOwner{
        //set new values
        _presaleAddress = account;
        _isExcludedFromFee[_presaleAddress] = true;
        _isExcludedFromCredits[_presaleAddress] = true;
        _isExcludedFromCreditRemoval[_presaleAddress] = true;
    }
}