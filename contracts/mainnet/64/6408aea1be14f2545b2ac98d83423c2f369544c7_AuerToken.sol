/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

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

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{ value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{ value : weiValue}(data);
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

contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
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

interface ITokenVesting {
    function createVestingSchedule(address,uint256,uint256,uint256,uint256,bool,uint256) external;
}

contract AuerToken is Context, IERC20, Ownable, Initializable {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => bool) controllers;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public TokenVestingContract;

    uint256 constant MAXIMUMSUPPLY=1000000000 * 10 ** 18;
    uint256 private MONTHLY = 2592000;
    uint256 private ONE_YEAR = 31104000;
    uint256 private TWO_YEAR = 62208000;
    uint256 private THREE_YEAR = 93312000;
    uint256 private FOUR_YEAR = 124416000;
    uint256 private FIVE_YEAR = 155520000;
    uint256 private SIX_YEAR = 186624000;

    address public SwapFeesOneWallet = 0xEd14824D28ee157c4F8FCdD1c19E3F38771918D4;
    address public SwapFeesTwoWallet = 0xE3513abf78717001dc432Bc233dF420D070a9e44;

    address private PrivateCapitalWallet = 0x5D5B1C5d93277E7C72f94D254B098f90cb9d64Ce;
    address private CoreTeamWallet = 0xC28Af089968a21b1FA49bD1bDb33D248537F5aF2;
    address private MarketingWallet = 0x8496ccC12e83Dd4A1040D9cb0AaA80a8852656C8;
    address private SystemEnhancementWallet = 0x1efAcdA5F5460aB18a055Aedb8DBBDc078086055;
    address private LegalFeesWallet = 0xB79751347b7B6A603B7F850a776F7400f80d23E8; 
    address private BugRewardsWallet = 0xF46495b01f9Bfa933C9F890285946c615a44ced4;
    address private TreasuryWallet = 0x9f6c74770FdF0eE4299f2A56B70F3163d127e03C;
    address private ExchangeLiquidityWallet = 0x6288f594633EC77bF7AdE25d09bd44AEE322873b; 
    address private EcoSystemMakerWallet = 0xddFa62887a69f8aE3fB1BF35aA37625eF8b9306d; 
    address private ReserveFundWallet = 0xc935A8cf3A71095935032f3540f4f98353Ef50D0;
    address private VCWallet = 0x7e475275F0F98fE985182C9e31B88eF42dA5F96e; 
    address private SuperNodeWallet = 0x713442044587521695A966E0862B67Dae0418350; 
    address private StakingDividendWallet = 0xBFb7e7f7b2658491dC8FD070959b647E32390C57; 
    address private AffiliateRewardsWallet = 0xe95DEd287A1855Da0937aDAf31609b27e59F9bdD; 
    address private CommunityPoolWallet = 0x47D51417999Bdd98905f04a82057C69f31bb6DE5; 
    address private NFTDividendWallet = 0x8e1086B20eb2fD9788d6E570B32eA8Dc94A3ca09; 
    address private DAOIncentiveWallet = 0xC3128D4b130F0CAaddb0976A84D98255bc874867; 
    address private GameFiBountyWallet = 0xd10B6A5F830358A23D40C778ebE2c7ddAAAfe42E; 
    address private AdvisoryWallet = 0xb3fA2e6ccd268b00Fa56155bC7b5A959631a980E;

    uint256 private PrivateCapitalAllocation = 70000000 * 10 ** 18;
    uint256 private CoreTeamAllocation = 70000000 * 10 ** 18;
    uint256 private MarketingAllocation = 50000000 * 10 ** 18;
    uint256 private SystemEnhancementAllocation = 20000000 * 10 ** 18;
    uint256 private LegalFeesAllocation = 5000000 * 10 ** 18;
    uint256 private BugRewardsAllocation = 500000 * 10 ** 18;
    uint256 private TreasuryAllocation = 9500000 * 10 ** 18;
    uint256 private ExchangeLiquidityAllocation = 50000000 * 10 ** 18;
    uint256 private EcoSystemMakerAllocation = 100000000 * 10 ** 18;
    uint256 private ReserveFundAllocation = 20000000 * 10 ** 18;
    uint256 private VCAllocation = 20000000 * 10 ** 18;
    uint256 private SuperNodeAllocation = 50000000 * 10 ** 18;
    uint256 private StakingDividendAllocation = 40000000 * 10 ** 18;
    uint256 private AffiliateRewardsAllocation = 25000000 * 10 ** 18;
    uint256 private CommunityPoolAllocation = 30000000 * 10 ** 18;
    uint256 private NFTDividendAllocation = 40000000 * 10 ** 18;
    uint256 private DAOIncentiveAllocation = 15000000 * 10 ** 18;
    uint256 private GameFiBountyAllocation = 5000000 * 10 ** 18;
    uint256 private AdvisoryAllocation = 30000000 * 10 ** 18;

    uint256 public LegalFeesMinted;
    uint256 public BugRewardsMinted;
    uint256 public ExchangeLiquidityMinted;
    uint256 public EcoSystemMakerMinted;
    uint256 public VCMinted;
    uint256 public SuperNodeMinted;
    uint256 public StakingDividendMinted;
    uint256 public AffiliateRewardsMinted;
    uint256 public CommunityPoolMinted;
    uint256 public NFTDividendMinted;
    uint256 public DAOIncentiveMinted;
    uint256 public GameFiBountyMinted;
    

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;

    uint256 public _buyLiquidityFee = 0;
    uint256 public _buyMarketingFee = 0;
    uint256 public _buyTeamFee = 0;
    uint256 public _buyDestroyFee = 0;

    uint256 public _sellLiquidityFee = 0;
    uint256 public _sellMarketingFee = 4;
    uint256 public _sellTeamFee = 1;
    uint256 public _sellDestroyFee = 0;

    uint256 public _liquidityShare = 0;
    uint256 public _marketingShare = 4;
    uint256 public _teamShare = 1;
    uint256 public _totalDistributionShares = 5;

    uint256 public _totalTaxIfBuying = 0;
    uint256 public _totalTaxIfSelling = 5;

    uint256 public _tFeeTotal;
    uint256 public _maxDestroyAmount;
    uint256 private _totalSupply;
    uint256 public _maxTxAmount;
    uint256 public _walletMax;
    uint256 private _minimumTokensBeforeSwap = 0;


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );

    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    constructor (
        address router,
        address owner
    ) payable {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _name = "Auer Token";
        _symbol = "AUER";
        _decimals = 18;
        _owner = owner;
        _maxTxAmount = MAXIMUMSUPPLY;
        _walletMax = MAXIMUMSUPPLY;
        _maxDestroyAmount = MAXIMUMSUPPLY;
        _minimumTokensBeforeSwap = 1 * 10**_decimals;
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = MAXIMUMSUPPLY;
        isExcludedFromFee[owner] = true;
        isExcludedFromFee[address(this)] = true;

        isWalletLimitExempt[owner] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[deadAddress] = true;

        isTxLimitExempt[owner] = true;
        isTxLimitExempt[deadAddress] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;

        _balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function initialize(address _contract, uint256 _start) public initializer {

      TokenVestingContract = _contract;
      
      //Reserve Fund
      _mint(_contract, ReserveFundAllocation);
      ITokenVesting(_contract).createVestingSchedule(ReserveFundWallet,_start,TWO_YEAR,TWO_YEAR,TWO_YEAR,false,ReserveFundAllocation);

      //Treasury
      _mint(_contract, TreasuryAllocation);
      ITokenVesting(_contract).createVestingSchedule(TreasuryWallet,_start,ONE_YEAR,THREE_YEAR,MONTHLY,false,TreasuryAllocation);

      //System Enhancement
      _mint(_contract, SystemEnhancementAllocation);
      ITokenVesting(_contract).createVestingSchedule(SystemEnhancementWallet,_start,ONE_YEAR,THREE_YEAR,MONTHLY,false,SystemEnhancementAllocation);

      //Marketing & Events
      _mint(_contract, MarketingAllocation);
      ITokenVesting(_contract).createVestingSchedule(MarketingWallet,_start,ONE_YEAR,SIX_YEAR,MONTHLY,false,MarketingAllocation);

      //Advisory Team
      _mint(_contract, AdvisoryAllocation);
      ITokenVesting(_contract).createVestingSchedule(AdvisoryWallet,_start,ONE_YEAR,THREE_YEAR,MONTHLY,false,AdvisoryAllocation);

      //Team
      _mint(_contract, CoreTeamAllocation);
      ITokenVesting(_contract).createVestingSchedule(CoreTeamWallet,_start,ONE_YEAR,THREE_YEAR,MONTHLY,false,CoreTeamAllocation);

      //Private Capital
      _mint(_contract, PrivateCapitalAllocation);
      ITokenVesting(_contract).createVestingSchedule(PrivateCapitalWallet,_start,TWO_YEAR,FOUR_YEAR,MONTHLY,false,PrivateCapitalAllocation);

      _totalSupply = ReserveFundAllocation+TreasuryAllocation+SystemEnhancementAllocation+MarketingAllocation+AdvisoryAllocation+CoreTeamAllocation+PrivateCapitalAllocation;
  }

    function mint(address to, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        _mint(to, amount);
    }

    function mintLegalFees(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((LegalFeesMinted+amount)<=LegalFeesAllocation,"Maximum allocation has been reached");
        _mint(LegalFeesWallet, amount);
        LegalFeesMinted += amount;
    }

    function mintBugRewards(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((BugRewardsMinted+amount)<=BugRewardsAllocation,"Maximum allocation has been reached");
        _mint(BugRewardsWallet, amount);
        BugRewardsMinted += amount;
    }

    function mintExchangeLiquidity(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((ExchangeLiquidityMinted+amount)<=ExchangeLiquidityAllocation,"Maximum allocation has been reached");
        _mint(ExchangeLiquidityWallet, amount);
        ExchangeLiquidityMinted += amount;
    }

    function mintEcoSystemMaker(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((EcoSystemMakerMinted+amount)<=EcoSystemMakerAllocation,"Maximum allocation has been reached");
        _mint(EcoSystemMakerWallet, amount);
        EcoSystemMakerMinted += amount;
    }

    function mintVC(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((VCMinted+amount)<=VCAllocation,"Maximum allocation has been reached");
        _mint(VCWallet, amount);
        VCMinted += amount;
    }

    function mintStakingDividend(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((StakingDividendMinted+amount)<=StakingDividendAllocation,"Maximum allocation has been reached");
        _mint(StakingDividendWallet, amount);
        StakingDividendMinted += amount;
    }

    function mintAffiliateRewards(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((AffiliateRewardsMinted+amount)<=AffiliateRewardsAllocation,"Maximum allocation has been reached");
        _mint(AffiliateRewardsWallet, amount);
        AffiliateRewardsMinted += amount;
    }

    function mintCommunityPool(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((CommunityPoolMinted+amount)<=CommunityPoolAllocation,"Maximum allocation has been reached");
        _mint(CommunityPoolWallet, amount);
        CommunityPoolMinted += amount;
    }

    function mintNFTDividend(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((NFTDividendMinted+amount)<=NFTDividendAllocation,"Maximum allocation has been reached");
        _mint(NFTDividendWallet, amount);
        NFTDividendMinted += amount;
    }

    function mintDAOIncentive(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((DAOIncentiveMinted+amount)<=DAOIncentiveAllocation,"Maximum allocation has been reached");
        _mint(DAOIncentiveWallet, amount);
        DAOIncentiveMinted += amount;
    }

    function mintGameFiBounty(uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((GameFiBountyMinted+amount)<=GameFiBountyAllocation,"Maximum allocation has been reached");
        _mint(GameFiBountyWallet, amount);
        GameFiBountyMinted += amount;
    }

    function mintSuperNode(address to, uint256 amount, uint256 start, uint256 cliff, uint256 duration, uint256 slicePeriodSeconds) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        require((SuperNodeMinted+amount)<=SuperNodeAllocation,"Maximum allocation has been reached");
        _mint(TokenVestingContract, amount);
        ITokenVesting(TokenVestingContract).createVestingSchedule(to,start,cliff,duration,slicePeriodSeconds,false,amount);
        SuperNodeMinted += amount;
    }

    function mintWithVesting(address to, uint256 amount, uint256 start, uint256 cliff, uint256 duration, uint256 slicePeriodSeconds) external {
        require(controllers[msg.sender], "Only controllers can mint");
        require((_totalSupply+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
        _mint(TokenVestingContract, amount);
        ITokenVesting(TokenVestingContract).createVestingSchedule(to,start,cliff,duration,slicePeriodSeconds,false,amount);
    }

    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return _minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress);

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress; //Set new pair address
        uniswapV2Router = _uniswapV2Router; //Set new router address

        isWalletLimitExempt[address(uniswapPair)] = true;
        isMarketPair[address(uniswapPair)] = true;
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(inSwapAndLiquify)
        {
            return _basicTransfer(sender, recipient, amount);
        }
        else
        {
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= _minimumTokensBeforeSwap;

            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled)
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = _minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ?
                                         amount : takeFee(sender, recipient, amount);

            if(checkWalletLimit && !isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {

        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));

        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
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
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
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

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = 0;
        uint256 destAmount = 0;

        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying.sub(_buyDestroyFee)).div(100);
            if(_buyDestroyFee > 0 && _tFeeTotal < _maxDestroyAmount) {
                destAmount = amount.mul(_buyDestroyFee).div(100);
                destroyFee(sender,destAmount);
            }
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling.sub(_sellDestroyFee)).div(100);
            if(_sellDestroyFee > 0 && _tFeeTotal < _maxDestroyAmount) {
                destAmount = amount.mul(_sellDestroyFee).div(100);
                destroyFee(sender,destAmount);
            }
        }

        if(feeAmount > 0) {

            uint256 amountTeam = feeAmount.mul(_teamShare).div(_totalDistributionShares);
            uint256 amountMarketing = feeAmount.sub(amountTeam);

            if(amountMarketing > 0)
                _balances[SwapFeesOneWallet] = _balances[SwapFeesOneWallet].add(amountMarketing);

            if(amountTeam > 0)
                _balances[SwapFeesTwoWallet] = _balances[SwapFeesTwoWallet].add(amountTeam);

            emit Transfer(sender, SwapFeesOneWallet, amountMarketing);
            emit Transfer(sender, SwapFeesTwoWallet, amountTeam);
        }

        return amount.sub(feeAmount.add(destAmount));
    }

    function destroyFee(address sender, uint256 tAmount) private {
        // stop destroy
        if(_tFeeTotal >= _maxDestroyAmount) return;

        _balances[deadAddress] = _balances[deadAddress].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, deadAddress, tAmount);
    }

}