/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

// SP1
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
interface IGame {
    function placeBet(address _bettor, uint256 _toBet) external;

    function creditPrice() external view returns (uint256);

    function isGameActive() external view returns (bool);

    function removeBet(address _bettor) external returns (uint256);

    function setCreditPrice(uint256 _amount) external;
}

contract SP1 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    
    mapping (address => bool) private _isBlackListedBot;
    address[] private _blackListedBots;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "SP1";
    string private constant _symbol = "SP1";
    uint8 private constant _decimals = 18;
    
    struct AddressFee {
        bool enable;
        uint256 _taxFee;
        uint256 _liquidityFee;
        uint256 _buyTaxFee;
        uint256 _buyLiquidityFee;
        uint256 _sellTaxFee;
        uint256 _sellLiquidityFee;
    }

    struct AddressTaxSplit {
        bool enable;
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
    
    // keeping track of the sell date/time and amount
    struct SellData {
        uint256 timeStamp;
        uint256 bnbAmount;
    }

    // sell data max allowance
    mapping(address => SellData[]) private _sellData;
    uint256 public maxSellAllowanceTime = 86400; // 24 hours
    uint256 public maxSellAllowanceBeforeExtra = 1 * 10**18; // 1 BNB
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
	uint256 public marketingTax = 5454;
    uint256 private _previousMarketingTax = marketingTax;
    uint256 public buyMarketingTax = 0;
    uint256 public sellMarketingTax = 5454;
    uint256 public sellExtraMarketingTax = 7500;
	address payable public marketingWallet = payable(0x42979Ab546B5fF75E5DCEbb17363878D2F72b0F2);
	// dev
    uint256 public devTax = 1819;
    uint256 private _previousDevTax = devTax;
    uint256 public buyDevTax = 0;
    uint256 public sellDevTax = 1819;
    uint256 public sellExtraDevTax = 0;
	address payable public devWallet = payable(0x7245AA3377401C1a0482219053edC8545D65920f);
    // jackpots
    //uint256 public buyJackpotTax = 10000;
    //uint256 public sellJackpotTax = 2727;
    //uint256 public sellExtraJackpotTax = 2500;
    mapping (address => JackpotFee) public jackpotWallets;
    //address payable private jackpotWallet = payable(0xfA336A240D934c942C0c746b1EC8840D0797311e);
    address[] private _jackpotWallets;
	
	// false = only enabled can trade or owner (add LP)
	// true = all can trade
	bool tradingEnabled = false;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    // Fee per address
    mapping (address => AddressFee) public addressFees;

    // Tax Split per address
    mapping (address => AddressTaxSplit) public addressTaxSplit;
    
    uint256 public _maxTxAmount = 1000000000 * 10**18;
    uint256 private numTokensSellToAddToLiquidity = 500000 * 10**6 * 10**8;
    
    uint256 public liquidityActiveBlock = 0; // 0 means liquidity is not active yet

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    
    event FromRewardsExcluded(address account);
    event InRewardsIncluded(address account);
    event FromFeesExcluded(address account);
    event InFeesIncluded(address account);
    
    event TaxFeePercentChanged(uint256 fee);
    event LiquidityFeePercentChanged(uint256 fee);
    event MaxTxPercentChanged(uint256 percent);
    
    event BuyFeesChanged(uint256 buyTaxFee, uint256 buyLiquidityFee);
    event SellFeesChanged(uint256 buyTaxFee, uint256 buyLiquidityFee);
    
    event AddressFeesChanged(address account, bool enabled, uint256 buyTaxFee, uint256 buyLiquidityFee);
    event AddressTaxSplitChanged(address account, bool enabled, uint256 marketingTax, uint256 devTax);
    event AddressBuyFeesChanged(address account, bool enabled, uint256 buyTaxFee, uint256 buyLiquidityFee);
    event AddressBuyTaxSplitChanged(address account, bool enabled, uint256 marketingTax, uint256 devTax);
    event AddressSellFeesChanged(address account, bool enabled, uint256 buyTaxFee, uint256 buyLiquidityFee);
    event AddressSellTaxSplitChanged(address account, bool enabled, uint256 marketingTax, uint256 devTax);

    event JackpotWalletChanged(address account, bool enabled, uint256 multiplicator, address game);
    event JackpotWalletDeleted(address account);

    event MarketingWalletChanged(address wallet);
    event DevWalletChanged(address wallet);
    
    event TradingEnabled(bool enabled);

    event MaxSellAllowanceChanged(uint256 maxAllowance);
    event MaxSellAllowanceTimeChanged(uint256 maxAllowanceTime);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        // BLACKLIST
        _isBlackListedBot[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
        _blackListedBots.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));

        _isBlackListedBot[address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345)] = true;
        _blackListedBots.push(address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345));

        _isBlackListedBot[address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b)] = true;
        _blackListedBots.push(address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b));

        _isBlackListedBot[address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95)] = true;
        _blackListedBots.push(address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95));

        _isBlackListedBot[address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964)] = true;
        _blackListedBots.push(address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964));

        _isBlackListedBot[address(0xDC81a3450817A58D00f45C86d0368290088db848)] = true;
        _blackListedBots.push(address(0xDC81a3450817A58D00f45C86d0368290088db848));

        _isBlackListedBot[address(0x45fD07C63e5c316540F14b2002B085aEE78E3881)] = true;
        _blackListedBots.push(address(0x45fD07C63e5c316540F14b2002B085aEE78E3881));

        _isBlackListedBot[address(0x27F9Adb26D532a41D97e00206114e429ad58c679)] = true;
        _blackListedBots.push(address(0x27F9Adb26D532a41D97e00206114e429ad58c679));
        
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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
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
        
        emit FromRewardsExcluded(account);
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
        
        emit InRewardsIncluded(account);
    }
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _sendTax(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        
        emit FromFeesExcluded(account);
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        
        emit InFeesIncluded(account);
    }
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        require(taxFee<15, "Tax higher 15 leads to several issues and is not allowed");
        _taxFee = taxFee;
        
        emit TaxFeePercentChanged(taxFee);
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        require(liquidityFee<15, "Liquidity fee higher 15 leads to several issues and is not allowed");
        _liquidityFee = liquidityFee;
        
        emit LiquidityFeePercentChanged(liquidityFee);
    }

    function setMaxSellAllowanceBeforeExtra(uint256 maxAllowance) external onlyOwner(){
        maxSellAllowanceBeforeExtra = maxAllowance;

        emit MaxSellAllowanceChanged(maxAllowance);
    }
    function setMaxSellAllowanceTimeBeforeExtra(uint256 maxAllowanceTime) external onlyOwner(){
        maxSellAllowanceTime = maxAllowanceTime;

        emit MaxSellAllowanceTimeChanged(maxAllowanceTime);
    }
   
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
        
        emit MaxTxPercentChanged(maxTxPercent);
    }

    function addBotToBlackList(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
        require(!_isBlackListedBot[account], "Account is already blacklisted");
        require(!tradingEnabled, "Trading is enabled which disableds blacklisting");
        _isBlackListedBot[account] = true;
        _blackListedBots.push(account);
    }

    function removeBotFromBlackList(address account) external onlyOwner() {
        require(_isBlackListedBot[account], "Account is not blacklisted");
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
    
    function setBuyFee(uint256 buyTaxFee, uint256 buyLiquidityFee) external onlyOwner {
        require(buyLiquidityFee+buyTaxFee<25, "Taxes/fees higher 25 in total lead to several issues and is not allowed");
        _buyTaxFee = buyTaxFee;
        _buyLiquidityFee = buyLiquidityFee;
        
        emit BuyFeesChanged(buyTaxFee, buyLiquidityFee);
    }
   
    function setSellFee(uint256 sellTaxFee, uint256 sellLiquidityFee) external onlyOwner {
        require(sellLiquidityFee+sellTaxFee<25, "Taxes/fees higher 25 in total lead to several issues and is not allowed");
        _sellTaxFee = sellTaxFee;
        _sellLiquidityFee = sellLiquidityFee;
        
        emit SellFeesChanged(sellTaxFee, sellLiquidityFee);
    }
    
    function setAddressFee(address _address, bool _enable, uint256 _addressTaxFee, uint256 _addressLiquidityFee) external onlyOwner {
        addressFees[_address].enable = _enable;
        addressFees[_address]._taxFee = _addressTaxFee;
        addressFees[_address]._liquidityFee = _addressLiquidityFee;
        
        emit AddressFeesChanged(_address, _enable, _addressTaxFee, _addressLiquidityFee);
    }
    
    function setBuyAddressFee(address _address, bool _enable, uint256 _addressTaxFee, uint256 _addressLiquidityFee) external onlyOwner {
        addressFees[_address].enable = _enable;
        addressFees[_address]._buyTaxFee = _addressTaxFee;
        addressFees[_address]._buyLiquidityFee = _addressLiquidityFee;
        
        emit AddressBuyFeesChanged(_address, _enable, _addressTaxFee, _addressLiquidityFee);
    }
    
    function setSellAddressFee(address _address, bool _enable, uint256 _addressTaxFee, uint256 _addressLiquidityFee) external onlyOwner {
        addressFees[_address].enable = _enable;
        addressFees[_address]._sellTaxFee = _addressTaxFee;
        addressFees[_address]._sellLiquidityFee = _addressLiquidityFee;
        
        emit AddressSellFeesChanged(_address, _enable, _addressTaxFee, _addressLiquidityFee);
    }

    function setAddressTaxSplit(address _address, bool _enable, uint256 _addressMarketingTax, uint256 _addressDevTax) external onlyOwner {
        addressTaxSplit[_address].enable = _enable;
        addressTaxSplit[_address]._marketingTax = _addressMarketingTax;
        addressTaxSplit[_address]._devTax = _addressDevTax;
        
        emit AddressTaxSplitChanged(_address, _enable, _addressMarketingTax, _addressDevTax);
    }
    
    function setBuyAddressTaxSplit(address _address, bool _enable, uint256 _addressMarketingTax, uint256 _addressDevTax) external onlyOwner {
        addressTaxSplit[_address].enable = _enable;
        addressTaxSplit[_address]._buyMarketingTax = _addressMarketingTax;
        addressTaxSplit[_address]._buyDevTax = _addressDevTax;
        
        emit AddressBuyTaxSplitChanged(_address, _enable, _addressMarketingTax, _addressDevTax);
    }
    
    function setSellAddressTaxSplit(address _address, bool _enable, uint256 _addressMarketingTax, uint256 _addressDevTax) external onlyOwner {
        addressTaxSplit[_address].enable = _enable;
        addressTaxSplit[_address]._sellMarketingTax = _addressMarketingTax;
        addressTaxSplit[_address]._sellDevTax = _addressDevTax;
        
        emit AddressSellTaxSplitChanged(_address, _enable, _addressMarketingTax, _addressDevTax);
    }
  
    function setMarketingWallet(address marketingAddress) external onlyOwner {
        require(marketingAddress != address(0), "Marketing Address cannot be 0!");
        marketingWallet = payable(marketingAddress);
        
        emit MarketingWalletChanged(marketingAddress);
    }
    
    function setDevWallet(address devAddress) external onlyOwner {
        require(devAddress != address(0), "Dev Address cannot be 0!");
        devWallet = payable(devAddress);
        
        emit DevWalletChanged(devAddress);
    }
        
    function setMarketingTax(uint256 tax, uint256 buyTax, uint256 sellTax) external onlyOwner{
        require(tax<=100 && tax >=0, "only between 0 and 100.00% is allowed");
        marketingTax = tax;
        buyMarketingTax = buyTax;
        sellMarketingTax = sellTax;
    }
    function setDevTax(uint256 tax, uint256 buyTax, uint256 sellTax) external onlyOwner{
        require(tax<=10000 && tax >=0, "only between 0 and 100.00% is allowed");
        devTax = tax;
        buyDevTax = buyTax;
        sellDevTax = sellTax;
    }
    
    function enableTrading() external onlyOwner{
        tradingEnabled = true;
        
        emit TradingEnabled(true);
    }    

    //--------------------- game related functions begin ---------------------//
    function setJackpotGame(address _address, bool _enable, uint256 _multiplicator, address _game) external onlyOwner() {
        jackpotWallets[_address].enable = _enable;
        jackpotWallets[_address].multiplicator =  _multiplicator;
        jackpotWallets[_address].game = IGame(_game);
        _jackpotWallets.push(_address);

        _isExcludedFromFee[_game] = true;

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
    function setCreditPrice(address _address, uint256 _amount) external onlyOwner(){
        jackpotWallets[_address].game.setCreditPrice(_amount);
    }
    function getCreditPrice(address _address) external view returns (uint256){
        return jackpotWallets[_address].game.creditPrice();
    }
    function gameIsActive(address _address) external view returns (bool){
        return jackpotWallets[_address].game.isGameActive();
    }
    //--------------------- game related functions end ---------------------//
     //to receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    function _sendTax(uint256 rFee, uint256 tFee) private{
        //default parameters
        uint256 cPercentageTotal = 10000; //100.00% with 2 digits => value changes depending on reflected/redistributed tokens
        uint256 initialBalance; // default variable to calculate the initial balance of BNB on contract for BNB swaps
        bool sent; // for bnb transfer
        bytes memory data; // default value for bnb transfer (not used => delete?) 
        //marketing T and R value
        uint256 tMarketingTax = 0;
        uint256 rMarketingTax = 0;
        //dev T and R value
        uint256 tDevTax = 0;
        uint256 rDevTax = 0;
        //jackpot tax values
        uint256 tSingleJackpotTax = 0;
        uint256 rSingleJackpotTax = 0;

        //Tax calculation
        //marketing
        tMarketingTax = tFee.mul(marketingTax).div(cPercentageTotal);
        rMarketingTax = rFee.mul(marketingTax).div(cPercentageTotal);

        // remove tFees/rFees and recalc max
        tFee = tFee.sub(tMarketingTax);
        rFee = rFee.sub(rMarketingTax);
        cPercentageTotal = cPercentageTotal.sub(marketingTax);
        //dev
        tDevTax = tFee.mul(devTax).div(cPercentageTotal);     
        rDevTax = rFee.mul(devTax).div(cPercentageTotal);

        // remove tFees/rFees and recalc max
        tFee = tFee.sub(tDevTax);
        rFee = rFee.sub(rDevTax);

        if(tMarketingTax > 0){
            // instead of paying in tokens it will be directly sent as BNB to the wallet
            // capture the contract's current ETH balance.
            // this is so that we can capture exactly the amount of ETH that the
            // swap creates, and not make the liquidity event include any ETH that
            // has been manually sent to the contract
            initialBalance = address(this).balance;
            // swap tokens for BNB
            swapTokensForEth(tMarketingTax); 
            // calculate the bnb
            uint256 marketingTaxinBNB = address(this).balance.sub(initialBalance);
            // transfer using calsl
            if(marketingTaxinBNB > 0){
                (sent, data) = address(marketingWallet).call{value: marketingTaxinBNB}("");
                if(sent){
                    initialBalance = 0;
                }
            }
        }

        if(tDevTax > 0){
            // instead of paying in tokens it will be directly sent as BNB to the wallet
            // capture the contract's current ETH balance.
            // this is so that we can capture exactly the amount of ETH that the
            // swap creates, and not make the liquidity event include any ETH that
            // has been manually sent to the contract
            initialBalance = address(this).balance;
            // swap tokens for BNB
            swapTokensForEth(tDevTax); 
            // calculate the bnb
            uint256 devTaxinBNB = address(this).balance.sub(initialBalance);
            // transfer using call
            if(devTaxinBNB > 0){
                (sent, data) = address(devWallet).call{value: devTaxinBNB}("");
                if(sent){
                    initialBalance = 0;
                }
            }
        }

        if(tFee > 0){
           //max multiplicator
            uint256 _maxMultiplicator = 0;
            // calculate the max multiplicators
            for (uint i=0; i<_jackpotWallets.length; i++) {
                if(jackpotWallets[_jackpotWallets[i]].enable == true){
                    _maxMultiplicator = _maxMultiplicator.add(jackpotWallets[_jackpotWallets[i]].multiplicator);
                }
            }
            for (uint i=0; i<_jackpotWallets.length; i++) {
                if(jackpotWallets[_jackpotWallets[i]].enable == true){
                    // calculate the fees going to each jackpot
                    tSingleJackpotTax = tFee.mul(jackpotWallets[_jackpotWallets[i]].multiplicator);
                    tSingleJackpotTax = tSingleJackpotTax.div(_maxMultiplicator);
                    rSingleJackpotTax = rFee.mul(jackpotWallets[_jackpotWallets[i]].multiplicator);
                    rSingleJackpotTax = rSingleJackpotTax.div(_maxMultiplicator); 
                    _tOwned[_jackpotWallets[i]] = _tOwned[_jackpotWallets[i]].add(tSingleJackpotTax);
                    _rOwned[_jackpotWallets[i]] = _rOwned[_jackpotWallets[i]].add(rSingleJackpotTax);
                    //remove tokens from fees to avoid a minting of new tokens
                    tFee = tFee.sub(tSingleJackpotTax);
                    rFee = rFee.sub(rSingleJackpotTax);
                    _maxMultiplicator = _maxMultiplicator - jackpotWallets[_jackpotWallets[i]].multiplicator;
                }
            }
        }
    }
    // reflection ----------------------------------------------------- //
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
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
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
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
        _previousMarketingTax = marketingTax;
        _previousDevTax = devTax;
        marketingTax = 0;
        devTax = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
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
        require(!_isBlackListedBot[from], "Account is blacklisted and can't trade");
        require(!_isBlackListedBot[to], "Account is blacklisted and can't trade");
        require(!_isBlackListedBot[tx.origin], "Origin xAccount is blacklisted");
        require(tradingEnabled || from == owner() || to == owner() || tx.origin == owner(), "Trading is not enabled");
        
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        if (
            !tradingEnabled &&
            block.number < liquidityActiveBlock + 3 && // 3 blocks against the snipers/bots
            from != owner() &&
            from != address(uniswapV2Router)
        ) {
            _tokenTransfer(from, marketingWallet, amount, false);
            return;
        }

        if (!tradingEnabled) {
            require(
                from == owner() || from == address(uniswapV2Router),
                "Trading is not active."
            );
            if (liquidityActiveBlock == 0 && to == uniswapV2Pair) {
                liquidityActiveBlock = block.number;
            }
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
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }else{
            // Buy
            if(from == uniswapV2Pair){
                removeAllFee();
                _taxFee = _buyTaxFee;
                _liquidityFee = _buyLiquidityFee;

                // marketing/dev/jackpot
                marketingTax = buyMarketingTax;
                devTax = buyDevTax;
            }
            // Sell
            if(to == uniswapV2Pair){
                calculateSellTax(from, amount);
            }
            
            // If send account has a special fee 
            if(addressFees[from].enable){
                removeAllFee();
                _taxFee = addressFees[from]._taxFee;
                _liquidityFee = addressFees[from]._liquidityFee;

                if(addressTaxSplit[from].enable){
                    marketingTax = addressTaxSplit[from]._marketingTax;
                    devTax = addressTaxSplit[from]._devTax;
                }
                
                // Sell
                if(to == uniswapV2Pair){
                    removeAllFee();
                    _taxFee = addressFees[from]._sellTaxFee;
                    _liquidityFee = addressFees[from]._sellLiquidityFee;

                    if(addressTaxSplit[from].enable){
                        marketingTax = addressTaxSplit[from]._sellMarketingTax;
                        devTax = addressTaxSplit[from]._sellDevTax;
                    }
                }
            }
            else{
                // If buy account has a special fee
                if(addressFees[to].enable){
                    //buy
                    removeAllFee();
                    if(from == uniswapV2Pair){
                        _taxFee = addressFees[to]._buyTaxFee;
                        _liquidityFee = addressFees[to]._buyLiquidityFee;

                        if(addressTaxSplit[to].enable){
                            marketingTax = addressTaxSplit[from]._buyMarketingTax;
                            devTax = addressTaxSplit[from]._buyDevTax;
                        }
                    }
                }
            }
        }
        
        // check the game
        if(from == uniswapV2Pair &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead)){
                uint256 amountsBNB = getAmountBNBOut(amount);
                for (uint i=0; i<_jackpotWallets.length; i++) {
                    require(
                        jackpotWallets[_jackpotWallets[i]].game.isGameActive(),
                         "One Jackpot is not active"
                    );
                }
                for (uint i=0; i<_jackpotWallets.length; i++) {
                    jackpotWallets[_jackpotWallets[i]].game.placeBet(to, amountsBNB);
                }
        }
        // Remove bets of token seller (depending on the jackpot this function can differ)
        if (
            from != owner() &&
            from != uniswapV2Pair &&
            from != address(uniswapV2Router)
        ) {
            // Remove bets only if game is active
            for (uint i=0; i<_jackpotWallets.length; i++) {
                jackpotWallets[_jackpotWallets[i]].game.removeBet(from);
            }
        }
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
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
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _sendTax(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _sendTax(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _sendTax(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // bnb calculation
    function getAmountBNBIn(uint256 _amountTokens)
        private
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
        private
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
    function calculateSellTax(address seller, uint256 amount) private {
        uint256 bnbAmount = getAmountBNBIn(amount);

        uint256 length = _sellData[seller].length;
        uint256 totalBNB;

        uint256 regularAmount = 0;
        uint256 extraAmount = 0;

        if (length > 0) totalBNB = _sellData[seller][length - 1].bnbAmount;

        if (length > 1) {
            for (uint256 i = length - 2; i >= 0; i--) {
                totalBNB += _sellData[seller][i].bnbAmount;

                if (
                    (_sellData[seller][length - 1].timeStamp -
                        _sellData[seller][i].timeStamp) >= maxSellAllowanceTime
                ) {
                    break;
                }

                if (i == 0) break;
            }
        }

        if (totalBNB >= maxSellAllowanceBeforeExtra) {
            // Sell 100% with extra tax
            extraAmount = bnbAmount;
        } else {
            uint256 forLimit = maxSellAllowanceBeforeExtra - totalBNB;

            if (bnbAmount <= forLimit) {
                regularAmount = bnbAmount;
            } else {
                regularAmount = forLimit;
                extraAmount = bnbAmount - forLimit;
            }
        }

        _sellData[seller].push(SellData(block.timestamp, bnbAmount));

        // total tax = ((regular tax fees * regular tax) + (extra tax fees * extra tax)) / bnbAmount
        _liquidityFee = (
            (regularAmount.mul(_sellLiquidityFee).div(100)).add(
                extraAmount.mul(_sellExtraLiquidityFee).div(100)
            )
        ).div(bnbAmount);
        _taxFee = (
            (regularAmount.mul(_sellTaxFee).div(100)).add(
                extraAmount.mul(_sellExtraTaxFee).div(100)
            )
        ).div(bnbAmount);
        marketingTax = (
            (regularAmount.mul(sellMarketingTax).div(100)).add(
                extraAmount.mul(sellExtraMarketingTax).div(100)
            )
        ).div(bnbAmount);
        devTax = (
            (regularAmount.mul(sellDevTax).div(100)).add(
                extraAmount.mul(sellExtraDevTax).div(100)
            )
        ).div(bnbAmount);

    }

    function withdrawBNB(uint256 _amount) external onlyOwner {
        withdrawToken(uniswapV2Router.WETH(), _amount);
    }
    function withdrawToken(address _tokenContract, uint256 _amount) public onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(msg.sender, _amount);
    }

}