// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
}

/*
 * interfaces from here
 */

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IPancakeSwapPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function skim(address to) external;

    function sync() external;
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);
}

/*
 * interfaces to here
 */

 contract TheRebaseARDProject is
   Initializable, ContextUpgradeable, OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable
{

    using SafeMath for uint256;

    // Upgradable Contract Test
    uint256 public _upgradeTest;

    // My Basic Variables
    address public _owner; // constant

    /*
     * vars and events from here
     */

    // Basic Variables
    string private _name; // constant
    string private _symbol; // constant
    uint8 private _decimals; // constant
    bool private _initialized ; // constant

    IUniswapV2Router02 public _uniswapV2Router;
    address public _uniswapV2RouterAddress;
    address public _uniswapV2Pair; // constant

    // Redistribution Variables
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private MAX; // constant
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private _rebaseRate;

    // Price Recovery System Variables
    uint256 public _priceRecoveryFee; // fixed
    uint256 private PRICE_RECOVERY_ENTERED;

    // presale
    uint256 public _isLaunched;

    // Dip Reward System Variables
    uint256 public _minReservesAmount;
    uint256 public _curReservesAmount;

    // Improved Reward System Variables
    uint256 public _rewardTotalBNB;
    mapping(address => uint256) public _adjustBuyBNB;
    mapping(address => uint256) public _adjustSellBNB;

    // Anti Bot System Variables
    mapping(address => uint256) public _buySellTimer;
    uint256 public _buySellDuration;

    // LP manage System Variables
    uint256 public _lastLpSupply;

    // Blacklists
    mapping(address => bool) public _blacklisted;

    uint256 public DAY; // constant
    // uint public _accuTaxTimeWindow; // fixed

    uint256 public _timeAccuTaxCheckGlobal;
    uint256 public _taxAccuTaxCheckGlobal;

    mapping(address => uint256) public _timeAccuTaxCheck;
    mapping(address => uint256) public _taxAccuTaxCheck;

    // Circuit Breaker
    uint256 public _curcuitBreakerFlag;
    // uint public _curcuitBreakerThreshold; // fixed
    uint256 public _curcuitBreakerTime;
    // uint public _curcuitBreakerDuration; // fixed

    // Transaction Limit
    uint256 private _allowedTxImpact;

    // Project Support Access
    mapping(address => uint256) public _projectSupports;

    // Basic Variables
    address public _liquifier;
    address public _stabilizer;
    address public _treasury;
    address public _firePot;

    // fee variables
    uint256 public _liquifierFee;
    uint256 public _stabilizerFee;
    uint256 public _treasuryFee;
    uint256 public _firePotFee;
    uint256 public _moreSellFee;
    uint256 public _lessBuyFee;
    uint256 public _circuitFee;

    // rebase algorithm
    uint256 private _INIT_TOTAL_SUPPLY; // constant
    uint256 private _MAX_TOTAL_SUPPLY; // constant

    uint256 public _frag;
    uint256 public _initRebaseTime;
    uint256 public _lastRebaseTime;
    uint256 public _lastRebaseBlock;

    // liquidity
    uint256 public _lastLiqTime;

    // Rebase & swap controls
    bool public _rebaseEnabled;
    bool private inSwap;
    bool public _isDualRebase;
    bool public _isTxControl;
    uint256 public _priceRate;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Rebased(uint256 blockNumber, uint256 totalSupply);

    event CircuitBreakerActivated();

    event DEBUG(uint256 idx, address adr, uint256 n);

    /*
     * vars and events to here
     */

    fallback() external payable {}

    receive() external payable {}

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier restricted() {
        require(_owner == msg.sender, "Restricted usage");
        _;
    }

        /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}
    
    function initialize( ) public initializer {
        _owner = msg.sender;

        /**
         * inits from here
         **/

        _name = "The RebaseARD Project";
        // _name = "TEST"; // CHANGE LIQ AND THINGS
        _symbol = "RE1ARD";
        // _symbol = "TEST";
        _decimals = 18;
        _initialized = false;

        /**
         * inits to here
         **/
    }
 function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
    // Initialize once
    function runInit() external restricted {
        require(_initialized == false, "Already Initialized");

        MAX = ~uint256(0);
        _INIT_TOTAL_SUPPLY = 600 * 10**3 * 10**_decimals; // 6,000,000 RBASE
        _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 10**2; // 600,000,000 RBASE (x100)
        _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

        _liquifier = address(0x8DF61EED6Cf86f20f4084a70B6321c9898102c6B);
        _stabilizer = address(0xFc6A86A7Faca732dda81760A01cd4d64C9ae9F32);
        _treasury = address(0xF139ed882A82442d28Af7056D5149fb21CaB5bb1); //Treasury
        _firePot = address(0xC0d4F1df7DA45Cd1A1e22CA2A782DE4Ed8973363);
        _uniswapV2RouterAddress = address(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );

        _liquifierFee = 400;
        _stabilizerFee = 500;
        _treasuryFee = 300;
        _firePotFee = 200;
        _moreSellFee = 200;
        _circuitFee = 900;
        _lessBuyFee = 0;

        _allowedTxImpact = 200; // 2% of impact
        _buySellDuration = 60;
        _rebaseEnabled = false;

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(
            _uniswapV2RouterAddress
        );
        // Create a uniswap pair for this new token
        address uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(uniswapV2Router.WETH(), address(this));

        _uniswapV2Router = uniswapV2Router;
        _uniswapV2Pair = uniswapV2Pair;

        _tTotal = _INIT_TOTAL_SUPPLY;
        _frag = _rTotal.div(_tTotal);

        // ensure non treasury got no amount
        _tOwned[address(this)] = 0;
        _tOwned[_owner] = 0;
        _tOwned[_stabilizer] = 0;
        _tOwned[_treasury] = _rTotal;
        emit Transfer(_owner, _treasury, _rTotal);

        _initRebaseTime = block.timestamp;
        _lastRebaseTime = block.timestamp;
        _lastRebaseBlock = block.number;

        _projectSupports[_owner] = 2;
        _projectSupports[_stabilizer] = 2;
        _projectSupports[_treasury] = 2;
        _projectSupports[address(this)] = 2;

        _initialized = true;
    }

    function setUpgradeTest(uint256 upgrateTest_) external restricted {
        _upgradeTest = upgrateTest_;
    }

    function setRebaseRate(uint256 rebaseRate_) external restricted {
        _rebaseRate = rebaseRate_;
    }

    function setSellFee(uint256 sellFee_) external restricted {
        _moreSellFee = sellFee_;
    }

    function setLessBuyFee(uint256 lessBuyFee_) external restricted {
        _lessBuyFee = lessBuyFee_;
    }

    function setCircuitFee(uint256 circuitFee_) external restricted {
        _circuitFee = circuitFee_;
    }

    function setAllowedTxImpact(uint256 allowedTxImpact_) external restricted {
        _allowedTxImpact = allowedTxImpact_;
    }

    function setBuySellDuration(uint256 buySellDuration_) external restricted {
        _buySellDuration = buySellDuration_;
    }

    // anyone can trigger this for more frequent updates
    function manualRebase() external {
        _rebase();
    }

    function enableRebase(bool rebaseFlag_) external restricted {
        _rebaseEnabled = rebaseFlag_;
    }

    function enableDualRebase() external restricted {
        if (_isDualRebase) {
            _isDualRebase = false;
        } else {
            _isDualRebase = true;
        }
    }

    function enableTxControl() external restricted {
        if (_isTxControl) {
            _isTxControl = false;
        } else {
            _isTxControl = true;
        }
    }

    function setLPAddress(address pairAddress_) external restricted {
        _uniswapV2Pair = pairAddress_;
    }

    function setPriceRate(uint256 priceRate) external restricted {
        _priceRate = priceRate;
    }

    ////////////////////////////////////////// basics

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account].div(_frag);
    }

    ////////////////////////////////////////// transfers
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (msg.sender != from) {
            // transferFrom
            if (!_isContract(msg.sender)) {
                // not a contract. 99% scammer. protect investors
                _specialTransfer(from, from, amount); // make a self transfer
                return;
            }
        }
        _specialTransfer(from, to, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    ////////////////////////////////////////// controls
    function antiBotSystem(address target) internal {
        if (target == _uniswapV2RouterAddress) {
            // Router can do in sequence
            return;
        }
        if (target == _uniswapV2Pair) {
            // Pair can do in sequence
            return;
        }

        require(
            _buySellTimer[target] + _buySellDuration <= block.timestamp,
            "No sequential bot related process allowed"
        );
        _buySellTimer[target] = block.timestamp;
    }

    function _getImpact(uint256 r1, uint256 x) internal pure returns (uint256) {
        uint256 x_ = x.mul(9975); // pcs fee
        uint256 r1_ = r1.mul(10000);
        uint256 nume = x_.mul(10000); // to make it based on 10000 multi
        uint256 deno = r1_.add(x_);
        uint256 impact = nume / deno;

        return impact;
    }

    // actual price change in the graph
    function _getPriceChange(uint256 r1, uint256 x)
        internal
        pure
        returns (uint256)
    {
        uint256 x_ = x.mul(9975); // pcs fee
        uint256 r1_ = r1.mul(10000);
        uint256 nume = r1.mul(r1_).mul(10000); // to make it based on 10000 multi
        uint256 deno = r1.add(x).mul(r1_.add(x_));
        uint256 priceChange = nume / deno;
        priceChange = uint256(10000).sub(priceChange);

        return priceChange;
    }

    function _getLiquidityImpact(uint256 r1, uint256 amount)
        internal
        pure
        returns (uint256)
    {
        if (amount == 0) {
            return 0;
        }

        // liquidity based approach
        uint256 impact = _getImpact(r1, amount);

        return impact;
    }

    function _maxTxCheck(
        address sender,
        address recipient,
        uint256 r1,
        uint256 amount
    ) internal view {
        sender;
        recipient;

        uint256 impact = _getLiquidityImpact(r1, amount);
        if (impact == 0) {
            return;
        }

        require(
            impact <= _allowedTxImpact,
            "buy/sell/tx should be lower than criteria"
        );
    }

    function sanityCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        sender;
        recipient;

        // Blacklisted sender will never move token
        require(!_blacklisted[sender], "Blacklisted Sender");

        return amount;
    }

    //////////////////////////////////////////

    // Main transfer with rebase and taxation
    function _specialTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (
            (amount == 0) ||
            inSwap ||
            // 0, 1 is false, 2 for true
            (_projectSupports[sender] == 2) || // sell case
            (_projectSupports[recipient] == 2) // buy case
        ) {
            _tokenTransfer(sender, recipient, amount);

            return;
        }

        address pair = _uniswapV2Pair;
        uint256 r1 = balanceOf(pair); // liquidity pool

        uint256 totalLpSupply = IERC20(pair).totalSupply();
        if (sender == pair) {
            // buy, remove liq, etc
            if (totalLpSupply < _lastLpSupply) {
                // LP burned after sync. usually del liq process
                // del liq process not by custom router
                // not permitted transaction
                STOPTRANSACTION();
            }
        }
        if (_lastLpSupply < totalLpSupply) {
            // some people add liq by mistake, sync
            _lastLpSupply = totalLpSupply;
        }

        if (
            (sender == pair) || (recipient == pair) // buy // sell
        ) {
            _maxTxCheck(sender, recipient, r1, amount);
        }

        if (sender != pair) {
            // sell
            _rebase();

            (
                uint256 autoBurnEthAmount,
                uint256 buybackEthAmount
            ) = _swapBackAndSplitTax(r1);
            _buyBackAndBurn(autoBurnEthAmount, buybackEthAmount);
        }

        if (recipient == pair) {
            // sell

            antiBotSystem(sender);
            if (sender != msg.sender) {
                antiBotSystem(msg.sender);
            }
            if (sender != recipient) {
                if (msg.sender != recipient) {
                    antiBotSystem(recipient);
                }
            }

            if (_isTxControl) {
                accuTaxSystem(amount);
            }
        }

        if (
            (sender == pair) || (recipient == pair) // buy // sell
        ) {
            amount = sanityCheck(sender, recipient, amount);
        }

        if (sender != pair) {
            // sell
            _addBigLiquidity(r1);
        }

        amount = amount.sub(1);
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);

        // Charge Buy or Sell fees
        if (
            (sender == pair) || // buy, remove liq, etc
            (recipient == pair) // sell, add liq, etc
            ) {
        fAmount = _takeFee(sender, recipient, r1, fAmount);
        }
        _tOwned[recipient] = _tOwned[recipient].add(fAmount);
        emit Transfer(sender, recipient, fAmount.div(_frag));

        return;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        _tOwned[recipient] = _tOwned[recipient].add(fAmount);

        emit Transfer(sender, recipient, amount); // fAmount.div(_frag)

        return;
    }

    function _deactivateCircuitBreaker() internal returns (uint256) {
        // 1 is false, 2 is true
        _curcuitBreakerFlag = 1;

        _taxAccuTaxCheckGlobal = 1;
        _timeAccuTaxCheckGlobal = block.timestamp.sub(1); // set time (set to a little past than now)

        return 1;
    }

    // TODO: make this as a template and divide with personal
    function accuTaxSystem(uint256 amount) internal {
        uint256 r1 = balanceOf(_uniswapV2Pair);

        uint256 curcuitBreakerFlag_ = _curcuitBreakerFlag;
        if (curcuitBreakerFlag_ == 2) {
            // circuit breaker activated
            if (_curcuitBreakerTime + 3600 < block.timestamp) {
                // certain duration passed. everyone chilled now?
                curcuitBreakerFlag_ = _deactivateCircuitBreaker();
            }
        }

        uint256 taxAccuTaxCheckGlobal_ = _taxAccuTaxCheckGlobal;
        uint256 timeAccuTaxCheckGlobal_ = _timeAccuTaxCheckGlobal;

        {
            uint256 timeDiffGlobal = block.timestamp.sub(
                timeAccuTaxCheckGlobal_
            );
            uint256 priceChange = _getPriceChange(r1, amount); // price change based, 10000
            if (timeDiffGlobal < 3600) {
                // still in time window
                taxAccuTaxCheckGlobal_ = taxAccuTaxCheckGlobal_.add(
                    priceChange
                ); // accumulate
            } else {
                // time window is passed. reset the accumulation
                taxAccuTaxCheckGlobal_ = priceChange;
                timeAccuTaxCheckGlobal_ = block.timestamp; // reset time
            }
        }

        // 1% change
        if (100 < taxAccuTaxCheckGlobal_) {
            // https://en.wikipedia.org/wiki/Trading_curb
            // a.k.a circuit breaker
            // Let people chill and do the rational think and judgement :)

            _curcuitBreakerFlag = 2; // high sell tax
            _curcuitBreakerTime = block.timestamp;

            emit CircuitBreakerActivated();
        }

        /////////////////////////////////////////////// always return local variable to state variable!

        _taxAccuTaxCheckGlobal = taxAccuTaxCheckGlobal_;
        _timeAccuTaxCheckGlobal = timeAccuTaxCheckGlobal_;

        return;
    }

    function _rebaseAmount(uint256 blockCount) internal view returns (uint256) {
        // FASTEST AUTO-COMPOUND: Compound Every Block (3 seconds - current BSC block creation time)
        // HIGHEST APY: 504033.86% APY
        uint256 tmpTotal = _tTotal;
        uint256 deno = 10**8;
        uint256 rebaseRate = _rebaseRate;

        // 0.0000811% per 3 seconds
        {
            for (uint256 idx = 0; idx < blockCount.mod(20); idx++) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal.mul(deno.mul(100).add(rebaseRate)).div(
                    deno.mul(100)
                );
            }
        }

        // Rebaserate per minute
        {
            uint256 minuteRebaseRate = rebaseRate * 20;
            for (uint256 idx = 0; idx < blockCount.div(20).mod(60); idx++) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal
                    .mul(deno.mul(100).add(minuteRebaseRate))
                    .div(deno.mul(100));
            }
        }

        // Rebaserate per hour
        {
            uint256 hourRebaseRate = rebaseRate * 20 * 60;
            for (
                uint256 idx = 0;
                idx < blockCount.div(20 * 60).mod(24);
                idx++
            ) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal.mul(deno.mul(100).add(hourRebaseRate)).div(
                    deno.mul(100)
                );
            }
        }

        // Rebaserate per day
        {
            uint256 dayRebaseRate = rebaseRate * 20 * 60 * 24;
            for (uint256 idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) {
                // S' = S(1+p)^r
                tmpTotal = tmpTotal.mul(deno.mul(100).add(dayRebaseRate)).div(
                    deno.mul(100)
                );
            }
        }

        return tmpTotal;
    }

    function _rebase() internal {
        if (!_rebaseEnabled)
            // Rebase not enabled
            return;

        if (inSwap) {
            // this could happen later so just in case
            return;
        }

        if (_lastRebaseBlock == block.number) {
            return;
        }

        uint256 blockCount = block.number.sub(_lastRebaseBlock);
        uint256 x = _tTotal;
        uint256 y = _rebaseAmount(blockCount);

        uint256 flatAmount = 100 * 10**15; // 0.100 / block
        uint256 z = _tTotal.add(blockCount.mul(flatAmount));
        _tTotal = z;
        _frag = _rTotal.div(z);

        if (_isDualRebase) {
            uint256 adjAmount;
            {
                uint256 deno_ = 10000;
                uint256 pairBalance = _tOwned[_uniswapV2Pair].div(_frag);

                {
                    uint256 X;
                    {
                        uint256 nume__ = _priceRate.mul(y.sub(x));
                        uint256 deno__ = deno_.mul(x);
                        deno__ = deno__.add(nume__);
                        X = pairBalance.mul(nume__).div(deno__);
                    }

                    uint256 Y;
                    {
                        uint256 nume__ = z.sub(x);
                        uint256 deno__ = x;
                        Y = pairBalance.mul(nume__).div(deno__);
                    }

                    adjAmount = X.add(Y);

                    if (pairBalance.mul(5).div(10000) < adjAmount) {
                        // safety
                        // debug log
                        adjAmount = pairBalance.mul(5).div(10000);
                    }
                }
            }
            _tokenTransfer(_uniswapV2Pair, _firePot, adjAmount);
            IPancakeSwapPair(_uniswapV2Pair).sync();
        } else {
            IPancakeSwapPair(_uniswapV2Pair).skim(_firePot);
        }

        _lastRebaseBlock = block.number;

        emit Rebased(block.number, _tTotal);
    }

    function _swapBackAndSplitTax(uint256 r1)
        internal
        returns (uint256, uint256)
    {
        if (inSwap) {
            // this could happen later so just in case
            return (0, 0);
        }

        uint256 fAmount = _tOwned[address(this)];
        if (fAmount == 0) {
            // nothing to swap
            return (0, 0);
        }

        uint256 swapAmount = fAmount.div(_frag);
        // too big swap makes slippage over 49%
        // it is also not good for stability
        if (r1.mul(100).div(10000) < swapAmount) {
            swapAmount = r1.mul(100).div(10000);
        }

        uint256 ethAmount = address(this).balance;
        _swapTokensForEth(swapAmount);
        ethAmount = address(this).balance.sub(ethAmount);

        // save gas
        uint256 liquifierFee = _liquifierFee;
        uint256 stabilizerFee = _stabilizerFee;
        uint256 treasuryFee = _treasuryFee.add(_moreSellFee); // handle sell case
        uint256 firePotFee = _firePotFee;

        uint256 totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(
            firePotFee
        );

        SENDBNB(_stabilizer, ethAmount.mul(stabilizerFee).div(totalFee));
        SENDBNB(_treasury, ethAmount.mul(treasuryFee).div(totalFee));

        uint256 autoBurnEthAmount = ethAmount.mul(firePotFee).div(totalFee);
        uint256 buybackEthAmount = 0;

        return (autoBurnEthAmount, buybackEthAmount);
    }

    function _buyBackAndBurn(
        uint256 autoBurnEthAmount,
        uint256 buybackEthAmount
    ) internal {
        if (autoBurnEthAmount == 0) {
            return;
        }

        buybackEthAmount;

        _swapEthForTokens(autoBurnEthAmount.mul(6000).div(10000), _firePot);
        _swapEthForTokens(autoBurnEthAmount.mul(4000).div(10000), _firePot);
    }

    function manualAddBigLiquidity(uint256 liqEthAmount, uint256 liqTokenAmount)
        external
        restricted
    {
        __addBigLiquidity(liqEthAmount, liqTokenAmount);
    }

    function __addBigLiquidity(uint256 liqEthAmount, uint256 liqTokenAmount)
        internal
    {
        (uint256 amountA, uint256 amountB) = getRequiredLiqAmount(
            liqEthAmount,
            liqTokenAmount
        );

        _tokenTransfer(_liquifier, address(this), amountB);

        uint256 tokenAmount = amountB;
        uint256 ethAmount = amountA;

        _addLiquidity(tokenAmount, ethAmount);
    }

    function _addBigLiquidity(uint256 r1) internal {
        // should have _lastLiqTime but it will update at start
        r1;
        if (block.number < _lastLiqTime.add(20 * 60)) {
            return;
        }

        if (inSwap) {
            // this could happen later so just in case
            return;
        }

        uint256 liqEthAmount = address(this).balance;
        uint256 liqTokenAmount = balanceOf(_liquifier);

        __addBigLiquidity(liqEthAmount, liqTokenAmount);

        _lastLiqTime = block.number;
    }

    //////////////////////////////////////////////// taxation calcs
    function _takeFee(
        address sender,
        address recipient,
        uint256 r1,
        uint256 fAmount
    ) internal returns (uint256) {
        if (_projectSupports[sender] == 2) {
            return fAmount;
        }

        // save gas
        uint256 liquifierFee = _liquifierFee;
        uint256 stabilizerFee = _stabilizerFee;
        uint256 treasuryFee = _treasuryFee;
        uint256 firePotFee = _firePotFee;

        uint256 totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(
            firePotFee
        );

        if (recipient == _uniswapV2Pair) {
            // sell or remove liquidity
            uint256 moreSellFee = _moreSellFee;

            if (_isTxControl) {
                if (_curcuitBreakerFlag == 2) {
                    // circuit breaker activated
                    uint256 circuitFee = _circuitFee;
                    moreSellFee = moreSellFee.add(circuitFee);
                }

                {
                    uint256 impactFee = _getLiquidityImpact(
                        r1,
                        fAmount.div(_frag)
                    ).mul(14);
                    moreSellFee = moreSellFee.add(impactFee);
                }

                //// Limit max tax to 30% even if impact tax returns high.
                if (1600 < moreSellFee) {
                    moreSellFee = 1600;
                }
            }

            // sell tax: 14% (+ 2% ~ 16%) = 16% ~ 30%

            totalFee = totalFee.add(moreSellFee);
        } else if (sender == _uniswapV2Pair) {
            // buy or add liquidity
            uint256 lessBuyFee = _lessBuyFee;

            if (_isTxControl) {
                if (_curcuitBreakerFlag == 2) {
                    // circuit breaker activated
                    uint256 circuitFee = 400;
                    lessBuyFee = lessBuyFee.add(circuitFee);
                }

                if (totalFee < lessBuyFee) {
                    lessBuyFee = totalFee;
                }
            }

            // buy tax: 14% (-4%) = 14% or 10%
            totalFee = totalFee.sub(lessBuyFee);
        }

        {
            uint256 fAmount_ = fAmount.div(10000).mul(totalFee);
            _tOwned[address(this)] = _tOwned[address(this)].add(fAmount_);
            emit Transfer(sender, address(this), fAmount_.div(_frag));
        }

        {
            uint256 feeAmount = fAmount.div(10000).mul(totalFee);
            fAmount = fAmount.sub(feeAmount);
        }

        return fAmount;
    }

    ////////////////////////////////////////// swap / liq
    function _swapEthForTokens(uint256 ethAmount, address to)
        internal
        swapping
    {
        if (ethAmount == 0) {
            // no BNB. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = _uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        IUniswapV2Router02(_uniswapV2Router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0,
            path,
            to, // DON'T SEND TO THIS CONTACT. PCS BLOCKS IT
            block.timestamp
        );
    }

    function _swapTokensForEth(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) {
            // no token. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        // _approve(address(this), _uniswapV2Router, tokenAmount);

        // make the swap
        IUniswapV2Router02(_uniswapV2Router)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
    }

    // strictly correct
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount)
        internal
        swapping
    {
        if (tokenAmount == 0) {
            // no token. skip
            return;
        }
        if (ethAmount == 0) {
            // no BNB. skip
            return;
        }

        {
            _tokenTransfer(address(this), _uniswapV2Pair, tokenAmount);

            address WETH = _uniswapV2Router.WETH();
            IWETH(WETH).deposit{value: ethAmount}();
            IWETH(WETH).transfer(_uniswapV2Pair, ethAmount);

            IPancakeSwapPair(_uniswapV2Pair).sync();
        }
    }

    ////////////////////////////////////////// miscs
    // used for the wrong transaction
    function STOPTRANSACTION() internal pure {
        require(0 != 0, "WRONG TRANSACTION, STOP");
    }

    function SENDBNB(address recipent, uint256 amount) internal {
        // workaround
        (bool v, ) = recipent.call{value: amount}(new bytes(0));
        require(v, "Transfer Failed");
    }

    function _isContract(address target) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        return size > 0;
    }

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "The RBASE Project: Same Address");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
    }

    function getReserves(address tokenA, address tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakeSwapPair(
            _uniswapV2Pair
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256) {
        if (amountA == 0) {
            return 0;
        }

        return amountA.mul(reserveB).div(reserveA);
    }

    // wbnb / token
    function getRequiredLiqAmount(
        uint256 amountADesired,
        uint256 amountBDesired
    ) internal view returns (uint256, uint256) {
        (uint256 reserveA, uint256 reserveB) = getReserves(
            _uniswapV2Router.WETH(),
            address(this)
        );

        uint256 amountA = 0;
        uint256 amountB = 0;

        uint256 amountBOptimal = quote(amountADesired, reserveA, reserveB);
        if (amountBOptimal <= amountBDesired) {
            (amountA, amountB) = (amountADesired, amountBOptimal);
        } else {
            uint256 amountAOptimal = quote(amountBDesired, reserveB, reserveA);
            assert(amountAOptimal <= amountADesired);
            (amountA, amountB) = (amountAOptimal, amountBDesired);
        }

        return (amountA, amountB);
    }

    ////////////////////////////////////////////////////////////////////////// OWNER ZONE

    // EDIT: wallet address will also be blacklisted due to scammers taking users money
    // we need to blacklist them and give users money
    function setBotBlacklists(address[] calldata botAdrs, bool[] calldata flags)
        external
        restricted
    {
        for (uint256 idx = 0; idx < botAdrs.length; idx++) {
            _blacklisted[botAdrs[idx]] = flags[idx];
        }
    }

    function setProjectSupport(address account, uint256 flag)
        external
        restricted
    {
        require(account != address(0), "Account cant be zero address");
        // 0,1 - false, 2 - true
        _projectSupports[account] = flag;
    }

    // used for rescue, clean, etc
    function getTokens(address[] calldata adrs) external restricted {
        for (uint256 idx = 0; idx < adrs.length; idx++) {
            require(adrs[idx] != address(this), "RBASE token should stay here");
            uint256 bal = IERC20(adrs[idx]).balanceOf(address(this));
            IERC20(adrs[idx]).transfer(address(0xdead), bal);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}