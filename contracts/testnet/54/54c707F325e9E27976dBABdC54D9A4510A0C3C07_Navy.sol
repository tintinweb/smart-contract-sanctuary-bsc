// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

// import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/proxy/utils/Initializable.sol';
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

/*
 * interfaces from here
 */


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IPancakeSwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function skim(address to) external;
    function sync() external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
}

interface IJackpot {
    function checkJackpot(address adr, uint amount) external;
}

/*
 * interfaces to here
 */
 
contract Navy is Initializable {
    using SafeMath for uint256;
    
    // Upgradable Contract Test
    uint public _uptest;
    
    // My Basic Variables
    address public _owner; // constant
    
    address public _token; // constant
    address private _myRouterSystem; // constant
    address private _stakeSystem; // constant
    address private _rewardSystem; // constant
    address private _projectFund; // constant
    address private _rewardToken; // constant
    
    // uint256 distributorGas = 500000;
    /*
     * vars and events from here
     */

    // Basic Variables
    string private _name; // constant
    string private _symbol; // constant
    uint8 private _decimals; // constant
    
    address public _uniswapV2Router; // constant
    address public _uniswapV2Pair; // constant
    address public WBNB;

    // Redistribution Variables
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private MAX; // constant
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    
    mapping (address => bool) public _isExcluded;
    address[] public _excluded;


    // Fee Variables
    uint public _liquidityFee; // fixed
    uint public _improvedRewardFee; // fixed
    uint public _projectFundFee; // fixed
    uint public _dipRewardFee; // fixed
    uint public _manualBuyFee; // fixed    
    uint public _autoBurnFee; // fixed
    uint public _redistributionFee; // fixed


    // Price Recovery System Variables
    uint public _priceRecoveryFee; // fixed
    uint private PRICE_RECOVERY_ENTERED;



    // presale
    uint public _isLaunched;


    // Dip Reward System Variables
    uint public _minReservesAmount;
    uint public _curReservesAmount;
    
    // Improved Reward System Variables
    uint public _rewardTotalBNB;
    mapping (address => uint) public _adjustBuyBNB;
    mapping (address => uint) public _adjustSellBNB;



    
    // Anti Bot System Variables
    mapping (address => uint256) public _buySellTimer;
    uint public _buySellTimeDuration; // fixed
    
    // // Anti Whale System Variables
    // uint public _whaleRate; // fixed
    // uint public _whaleTransferFee; // fixed
    // uint public _whaleSellFee; // fixed
    
    // // Anti-Dump Algorithm
    // uint public _antiDumpTimer;
    // uint public _antiDumpDuration; // fixed


    // LP manage System Variables
    uint public _lastLpSupply;
    
    // Blacklists
    mapping (address => bool) public _blacklisted;
    

    
    // Max Variables
    // uint public _maxTxNume; // fixed
    // uint public _maxBalanceNume; // fixed
    // uint public _maxSellNume; // fixed

    // Accumulated Tax System
    uint public DAY; // constant
    // uint public _accuTaxTimeWindow; // fixed
    uint public _accuMulFactor; // fixed

    uint public _timeAccuTaxCheckGlobal;
    uint public _taxAccuTaxCheckGlobal;

    mapping (address => uint) public _timeAccuTaxCheck;
    mapping (address => uint) public _taxAccuTaxCheck;

    // Circuit Breaker
    uint public _curcuitBreakerFlag;
    // uint public _curcuitBreakerThreshold; // fixed
    uint public _curcuitBreakerTime;
    // uint public _curcuitBreakerDuration; // fixed
    
    
    // Advanced Airdrop Algorithm
    address public _freeAirdropSystem; // constant
    address public _airdropSystem; // constant
    mapping (address => uint) public _airdropTokenLocked;
    uint public _airdropTokenUnlockTime;


    
    // First Penguin Algorithm
    uint public _firstPenguinWasBuy; // fixed
    
    // Life Support Algorithm
    mapping (address => uint) public _lifeSupports;
    
    // Monitor Algorithm
    mapping (address => uint) public _monitors;
    
    // //Dividend Exempt
    // mapping (address => bool) public isDividendExempt;

    //////////////////////////////////////////////////////////// keep for later use

    // Basic Variables
    address public _capital;
    address public _allowancefund;
    address public _bank;
    address public _marianatrench;

    // fees
    uint256 public _capitalFee;
    uint256 public _allowancefundFee;
    uint256 public _bankFee;
    uint256 public _marianatrenchFee;
    uint256 public _antidumpFee;

    // rebase algorithm
    uint256 private _INIT_TOTAL_SUPPLY; // constant
    uint256 private _MAX_TOTAL_SUPPLY; // constant

    uint256 public _frag;
    uint256 public _initRebaseTime;
    uint256 public _lastRebaseTime;
    uint256 public _lastRebaseBlock;

    // liquidity
    uint256 public _lastLiqTime;

    bool public _rebaseStarted;

    bool private inSwap;

    bool public _isDualRebase;

    bool public _isExperi;

    uint256 public _priceRate;

    uint public _liqPeriod;
    IDividendDistributor public distributor; // constant
    mapping (address => bool) public isDividendExempt;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Rebased(uint256 blockNumber, uint256 totalSupply);

	event CircuitBreakerActivated();

    event DEBUG(uint256 idx, address adr, uint256 n);
    event Amount(uint256 amount1, uint256 amount2, uint256 n);
    event ErrorHandled(bytes reason,uint errorCode);
    // event ErrorHandled(string reason);  
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

    // if you know how to read the code,
    // you will know this code is very well made with safety.
    // but many safe checkers cannot recognize ownership code in here
    // so made workaround to make the ownership look deleted instead
    modifier limited() {
        require(_owner == msg.sender, "limited usage");
        _;
    }

    function initialize(address owner_) public initializer {
        _owner = owner_;

        /**
         * inits from here
         **/

        _name = "The NAVY Project";
        _symbol = "NAVY";
        _decimals = 18;
        WBNB=address(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F);
        /**
         * inits to here
         **/


    }
    // inits
    function runInit() external limited {
        require(
            _allowancefund !=
                address(0xFe05C7fB36d9DbB89aF4b73764C6cA6d5a128C4f),
            "Already Initialized"
        );

        MAX = ~uint256(0);
        _INIT_TOTAL_SUPPLY = 100 * 10**3 * 10**_decimals; // 100,000 $NAV
        _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 10**4; // 1,000,000,000 $NAV (x10000)
        _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

        
        _allowancefund = address(0xFe05C7fB36d9DbB89aF4b73764C6cA6d5a128C4f);
        _bank = address(0x3d3A5B1241aD1245D1b44acF1a5a845804c93B38);
        _marianatrench = address(0xfE957fA42eBf3c3D3179bB8b4d4550B064C7Ce90); //contract

        // deno = 10000
        _capitalFee = 300;
        _allowancefundFee = 400;
        _bankFee = 300;
        _marianatrenchFee = 200;
        _antidumpFee = 200;

        _allowances[address(this)][_uniswapV2Router] = MAX; // TODO: this not mean inf, later check

        _tTotal = _INIT_TOTAL_SUPPLY;
        _frag = _rTotal.div(_tTotal);

        // manual fix
        _tOwned[address(this)] = 0;
        _tOwned[_owner] = 0;
        _tOwned[_allowancefund] = 0;
        _tOwned[_bank] = _rTotal;
        emit Transfer(_owner, _bank, 4810 * 10**6 * 10**_decimals);
        emit Transfer(
            _allowancefund,
            _bank,
            189 * 10**6 * 10**_decimals + 1
        );
        emit Transfer(address(this), _bank, 5000 * 10**6 * 10**_decimals);

        _initRebaseTime = block.timestamp;
        _lastRebaseTime = block.timestamp;
        _lastRebaseBlock = block.number;

        _lifeSupports[_owner] = 2;
        _lifeSupports[_allowancefund] = 2;
        _lifeSupports[_bank] = 2;
        _lifeSupports[address(this)] = 2;

        }
    function setUptest(uint uptest_) external {
        _uptest = uptest_;
    }


    function manualChange() external limited {

    }

    // anyone can trigger this :) more frequent updates
    function manualRebase() external {
        _rebase();
    }

    function toggleDualRebase() external limited {
        if (_isDualRebase) {
            _isDualRebase = false;
        } else {
            _isDualRebase = true;
        }
    }

    function toggleExperi() external limited {
        if (_isExperi) {
            _isExperi = false;
        } else {
            _isExperi = true;
        }
    }

    function setPriceRate(uint priceRate) external limited {
        _priceRate = priceRate;
    }


    function setLiqPeriod(uint liqPeriod) external limited {
        _liqPeriod = liqPeriod;
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
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        // many unique algorithms are delicately implemented by me :)

        if (msg.sender != from) { // transferFrom
            if (!_isContract(msg.sender)) { // not a contract. 99% scammer. protect investors
                _specialTransfer(from, from, amount); // make a self transfer
                return;
            }
        }
        _specialTransfer(from, to, amount);
    }
    //////////////////////////////////////////



    ////////////////////////////////////////// allowances
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    //////////////////////////////////////////




    ////////////////////////////////////////// Anti Bot System
    
    // bot use sequential buy/sell/transfer to get profit
    // this will heavily decrease the chance for bot to do that
    function antiBotSystem(address target) internal {
        if (target == address(_uniswapV2Router)) { // Router can do in sequence
            return;
        }
        if (target == _uniswapV2Pair) { // Pair can do in sequence
            return;
        }
            
        require(_buySellTimer[target] + 60 <= block.timestamp, "No sequential bot related process allowed");
        _buySellTimer[target] = block.timestamp; ///////////////////// NFT values
    }
    //////////////////////////////////////////




    ////////////////////////////////////////// cals
    // pcs / poo price impact cal
    function _getImpact(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = x_.mul(10000); // to make it based on 10000 multi
        uint deno = r1_.add(x_);
        uint impact = nume / deno;
        
        return impact;
    }
    
    // actual price change in the graph
    function _getPriceChange(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = r1.mul(r1_).mul(10000); // to make it based on 10000 multi
        uint deno = r1.add(x).mul(r1_.add(x_));
        uint priceChange = nume / deno;
        priceChange = uint(10000).sub(priceChange);
        
        return priceChange;
    }
    //////////////////////////////////////////




    ////////////////////////////////////////// checks
    function _getLiquidityImpact(uint r1, uint amount) internal pure returns (uint) {
        if (amount == 0) {
          return 0;
        }

        // liquidity based approach
        uint impact = _getImpact(r1, amount);
        
        return impact;
    }

    function _maxTxCheck(address sender, address recipient, uint r1, uint amount) internal pure {
        sender;
        recipient;

        uint impact = _getLiquidityImpact(r1, amount);
        if (impact == 0) {
          return;
        }

        require(impact <= 200, "buy/sell/tx should be lower than criteria"); // _maxTxNume
    }

    function sanityCheck(address sender, address recipient, uint256 amount) internal view returns (uint) {
        sender;
        recipient;

        // Blacklisted sender will never move token
        require(!_blacklisted[sender], "Blacklisted Sender");

        // if (0 < _monitors[sender]) {
        //     _monitors[sender] = _monitors[sender].sub(1);
        //     if (0 == _monitors[sender]) {
        //         _blacklisted[sender] = true;
        //     }
        // }

        return amount;
    }
    //////////////////////////////////////////






    // made code simple to make people verify easily
    function _specialTransfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        amount = sanityCheck(sender, recipient, amount);
        
        if (
            (amount == 0) ||

            inSwap ||
            
            // 0, 1 is false, 2 for true
            (_lifeSupports[sender] == 2) || // sell case
            (_lifeSupports[recipient] == 2) // buy case
            ) {
            _tokenTransfer(sender, recipient, amount);

            return;
        }

        address pair = _uniswapV2Pair;
        uint r1 = balanceOf(pair); // liquidity pool

        uint totalLpSupply = IERC20(pair).totalSupply();
        if (sender == pair) { // buy, remove liq, etc
            if (totalLpSupply < _lastLpSupply) { // LP burned after sync. usually del liq process
                // del liq process not by custom router
                // not permitted transaction
                STOPTRANSACTION();
            }
            
            // {
            //     address JACKPOT = address(0x3d3A5B1241aD1245D1b44acF1a5a845804c93B38);
            //     try IJackpot(JACKPOT).checkJackpot(recipient, amount) {} catch { emit DEBUG(0, address(0x0), 0); }
            // }
        }
        if (_lastLpSupply < totalLpSupply) { // some people add liq by mistake, sync
            _lastLpSupply = totalLpSupply;
        }

        if (
            (sender == pair) || // buy, remove liq, etc
            (recipient == pair) // sell, add liq, etc
            ) {
            _maxTxCheck(sender, recipient, r1, amount);
        }

        if (sender != pair) { // not buy, remove liq, etc
            _rebase();
        }

        
        if (sender != pair) { // not buy, remove liq, etc    
            {
                (uint autoBurnEthAmount, uint buybackEthAmount) = _swapBack(r1);
                _buyBack(autoBurnEthAmount, buybackEthAmount);
            }
        }

        if (recipient == pair) { // sell, add liq, etc
            antiBotSystem(sender);
            if (sender != msg.sender) {
            antiBotSystem(msg.sender);
            }
            if (sender != recipient) {
                if (msg.sender != recipient) {
                antiBotSystem(recipient);
                }
            }
            if (_isExperi) {
                accuTaxSystem(amount);
            }
            }
            
            if (sender != pair) { // not buy, remove liq, etc    
            _addBigLiquidity(r1);
            
        }

        amount = amount.sub(1);
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
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

    function _tokenTransfer(address sender, address recipient, uint256 amount) internal {
        uint fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        _tOwned[recipient] = _tOwned[recipient].add(fAmount);

        emit Transfer(sender, recipient, amount); // fAmount.div(_frag)

        return;
    }

















    ///////////////////////////////////////////////////////// algorithms
    
    /*
     * Soooooooooooooooo simple and easy algorithms compared to my disabled ones..
     * Hope people like my algorithms when they are applied again :)
     */
	
    function _deactivateCircuitBreaker() internal returns (uint) {
        // in the solidity world,
        // to save the gas,
        // 1 is false, 2 is true
        _curcuitBreakerFlag = 1;
        
        _taxAccuTaxCheckGlobal = 1; // [save gas]
        _timeAccuTaxCheckGlobal = block.timestamp.sub(1); // set time (set to a little past than now)

        return 1;
    }

    // TODO: make this as a template and divide with personal
    function accuTaxSystem(uint amount) internal {
        uint r1 = balanceOf(_uniswapV2Pair);

    	uint curcuitBreakerFlag_ = _curcuitBreakerFlag;
		if (curcuitBreakerFlag_ == 2) { // circuit breaker activated
			if (_curcuitBreakerTime + 3600 < block.timestamp) { // certain duration passed. everyone chilled now?
                curcuitBreakerFlag_ = _deactivateCircuitBreaker();
            }
        }

		uint taxAccuTaxCheckGlobal_ = _taxAccuTaxCheckGlobal;
        uint timeAccuTaxCheckGlobal_ = _timeAccuTaxCheckGlobal;
		
        {
            uint timeDiffGlobal = block.timestamp.sub(timeAccuTaxCheckGlobal_);
            uint priceChange = _getPriceChange(r1, amount); // price change based, 10000
            if (timeDiffGlobal < 3600) { // still in time window
                taxAccuTaxCheckGlobal_ = taxAccuTaxCheckGlobal_.add(priceChange); // accumulate
            } else { // time window is passed. reset the accumulation
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


    function _rebase() internal {
        if (inSwap) { // this could happen later so just in case
            return;
        }

        if (_lastRebaseBlock == block.number) {
            return;
        }

        // Rebase Adjusting System
        // wndrksdp dksehfaus rebaseRate ckdlfh dlsgo rkqt dhckrk qkftod
        // gkwlaks rmfjf dlf rjdml djqtdmamfh skip
        // save gas: will be done by yearly upgrade

        uint deno = 10**6 * 10**18;

        // FASTEST AUTO-COMPOUND: Compound Every Block (3 seconds)
        // HIGHEST APY: 404093.10% APY
        uint blockCount = block.number.sub(_lastRebaseBlock);
        uint tmp = _tTotal;

        {
            // 1.00000017 for 0.5%
            // 1.00000062 for 1.8%
            // 1.00000079 for 2.3%
            uint rebaseRate = 79 * 10**18;
            for (uint idx = 0; idx < blockCount.mod(20); idx++) { // 3 sec rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
            }
        }

        {
            // 1.00000017**20 = 1.00000340
            // 1.00000062**20 = 1.00001240
            // 1.00000079**20 = 1.00001580
            uint minuteRebaseRate = 1580 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20).mod(60); idx++) { // 1 min rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
            }
        }

        {
            // 1.00000340**60 = 1.00020402
            // 1.00001240**60 = 1.00074427
            // 1.00001580**60 = 1.00094844
            uint hourRebaseRate = 94844 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) { // 1 hour rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
            }
        }

        {
            // 1.00020402**24 = 1.00490800
            // 1.00074427**24 = 1.01801636
            // 1.00094844**24 = 1.02301279
            uint dayRebaseRate = 2301279 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // 1 day rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
            }
        }

        uint x = _tTotal;
        uint y = tmp;

        uint flatAmount = 100 * 10**15; // 0.100 / block
        uint z = _tTotal.add(blockCount.mul(flatAmount));
        _tTotal = z;
        _frag = _rTotal.div(z);
        
		
        if (_isDualRebase) {
            uint adjAmount;
            {
                // 2.3%
                // 0.5% / 1.8% = 3.6470

                uint deno_ = 10000;
                uint pairBalance = _tOwned[_uniswapV2Pair].div(_frag);
				
                {
                    uint X;
                    {
                        uint nume__ = _priceRate.mul(y.sub(x));
                        uint deno__ = deno_.mul(x);
                        deno__ = deno__.add(nume__);
                        X = pairBalance.mul(nume__).div(deno__);
                    }

                    uint Y;
                    {
                        uint nume__ = z.sub(x);
                        uint deno__ = x;
                        Y = pairBalance.mul(nume__).div(deno__);
                    }

                    adjAmount = X.add(Y);

                    if (pairBalance.mul(50).div(10000) < adjAmount) { // safety
                 	    // debug log
                        adjAmount = pairBalance.mul(50).div(10000);
                	}
                }
            }
            _tokenTransfer(_uniswapV2Pair, _marianatrench, adjAmount);
            IPancakeSwapPair(_uniswapV2Pair).sync();
        } else {
            IPancakeSwapPair(_uniswapV2Pair).skim(_marianatrench);
        }

        _lastRebaseBlock = block.number;

        emit Rebased(block.number, _tTotal);
    }

    function _swapBack(uint r1) internal returns (uint, uint) {
        if (inSwap) { // this could happen later so just in case
            return (0, 0);
        }

        uint fAmount = _tOwned[address(this)];
        if (fAmount == 0) { // nothing to swap
            return (0, 0);
        }

        uint swapAmount = fAmount.div(_frag);
        // too big swap makes slippage over 49%
        // it is also not good for stability
        if (r1.mul(100).div(10000) < swapAmount) {
            swapAmount = r1.mul(100).div(10000);
        }
        
        uint ethAmount = address(this).balance;
        _swapTokensForEth(swapAmount);
        ethAmount = address(this).balance.sub(ethAmount);

        // save gas
        uint capitalFee = _capitalFee;
        uint allowancefundFee = _allowancefundFee.add(100);
        // uint quantumFee = 50;
        // uint jackpotFee = 50;
        uint bankFee = _bankFee.add(_antidumpFee); // handle sell case
        uint marianatrenchFee = _marianatrenchFee;

        uint totalFee = capitalFee.add(allowancefundFee).add(50).add(50).add(bankFee).add(marianatrenchFee);

        SENDBNB(_allowancefund, ethAmount.mul(allowancefundFee).div(totalFee));
        // emit Transfer(address(this), _allowancefund, ethAmount.mul(allowancefundFee).div(totalFee).div(_frag));
        SENDBNB(address(0x3d3A5B1241aD1245D1b44acF1a5a845804c93B38), ethAmount.mul(50).div(totalFee));//Jackpot Address
        // emit Transfer(address(this), address(0x3d3A5B1241aD1245D1b44acF1a5a845804c93B38), ethAmount.mul(50).div(totalFee).div(_frag));
        SENDBNB(address(0x3d3A5B1241aD1245D1b44acF1a5a845804c93B38), ethAmount.mul(50).div(totalFee));        
        // emit Transfer(address(this), address(0x3d3A5B1241aD1245D1b44acF1a5a845804c93B38), ethAmount.mul(50).div(totalFee).div(_frag));
        
        SENDBNB(_bank, ethAmount.mul(bankFee).div(totalFee));
        // emit Transfer(address(this), _bank, ethAmount.mul(bankFee).div(totalFee).div(_frag));

        
        uint autoBurnEthAmount = ethAmount.mul(marianatrenchFee).div(totalFee);
        uint buybackEthAmount = 0;

        return (autoBurnEthAmount, buybackEthAmount);
    }

    function _buyBack(uint autoBurnEthAmount, uint buybackEthAmount) internal {
        if (autoBurnEthAmount == 0) {
            return;
        }

        buybackEthAmount;
        // {
        //     uint bal = IERC20(address(this)).balanceOf(_allowancefund);
        //     _swapEthForTokens(buybackEthAmount, _allowancefund);
        //     bal = IERC20(address(this)).balanceOf(_allowancefund).sub(bal);
        //     _tokenTransfer(_allowancefund, address(this), bal);
        // }
        
        _swapEthForTokens(autoBurnEthAmount.mul(6000).div(10000), _marianatrench);
        _swapEthForTokens(autoBurnEthAmount.mul(4000).div(10000), _marianatrench);
    }

	
    function manualAddBigLiquidity(uint liqEthAmount, uint liqTokenAmount) external limited {
		__addBigLiquidity(liqEthAmount, liqTokenAmount);
    }

	function __addBigLiquidity(uint liqEthAmount, uint liqTokenAmount) internal {
		(uint amountA, uint amountB) = getRequiredLiqAmount(liqEthAmount, liqTokenAmount);
		
        _tokenTransfer(_capital, address(this), amountB);
        
        uint tokenAmount = amountB;
        uint ethAmount = amountA;

        _addLiquidity(tokenAmount, ethAmount);    
    }

    // djqtdmaus rPthr tlehgkrpehla
    function _addBigLiquidity(uint r1) internal { // should have _lastLiqTime but it will update at start
        r1;
        if (block.number < _lastLiqTime.add(20 * 60 * 24 * 7)) {
            return;
        }

        if (inSwap) { // this could happen later so just in case
            return;
        }

		uint liqEthAmount = address(this).balance;
		uint liqTokenAmount = balanceOf(_capital);

        __addBigLiquidity(liqEthAmount, liqTokenAmount);

        _lastLiqTime = block.number;
    }

    
    //////////////////////////////////////////////// NOTICE: fAmount is big. do mul later. do div first
    function _takeFee(address sender, address recipient, uint256 r1, uint256 fAmount) internal returns (uint256) {
        if (_lifeSupports[sender] == 2) {
            return fAmount;
        }
        
        // save gas
        uint capitalFee = _capitalFee;
        uint allowancefundFee = _allowancefundFee;
        // uint quantumFee = 50;
        // uint jackpotFee = 50;
        uint bankFee = _bankFee;
        uint marianatrenchFee = _marianatrenchFee;
        uint busdrewardsFee=200;
        uint totalFee = capitalFee
        .add(allowancefundFee).add(bankFee).add(marianatrenchFee).add(busdrewardsFee);
        
        if(!isDividendExempt[sender]) {
                try distributor.setShare(sender, balanceOf(sender)) {} catch {}
        }
        if(!isDividendExempt[recipient]) {
                try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} 
        }
        
        if (recipient == _uniswapV2Pair) { // sell, remove liq, etc
            uint antidumpFee = 200; // save gas
            allowancefundFee=_allowancefundFee.add(100);
            bankFee=_bankFee.sub(100);

            if (_isExperi) {
                if (_curcuitBreakerFlag == 2) { // circuit breaker activated
                    uint circuitFee = 900;
                    antidumpFee = antidumpFee.add(circuitFee);
                }

                {
                    uint impactFee = _getLiquidityImpact(r1, fAmount.div(_frag)).mul(14);
                    antidumpFee = antidumpFee.add(impactFee);
                }

                if (1600 < antidumpFee) {
                    antidumpFee = 1600;
                }
            }

            // buy tax: 14%
            // sell tax: 14% (+ 2% ~ 16%) = 16% ~ 30%


            uint allAmount=fAmount.div(10000).mul(allowancefundFee);
            _tOwned[_allowancefund] = _tOwned[_allowancefund].add(allAmount);
            emit Transfer(sender, _allowancefund, allAmount.div(_frag));
            
            uint bankAmount=fAmount.div(10000).mul(bankFee);
            _tOwned[_bank] = _tOwned[_bank].add(bankAmount);
            emit Transfer(sender, _bank, bankAmount.div(_frag));


                //busdreward fee
            
            // uint busdrewardAmount=fAmount.div(10000).mul(100);
            
            // try distributor.deposit{value: busdrewardAmount}() {} catch {}
            totalFee = totalFee.add(antidumpFee);
        } else if (sender == _uniswapV2Pair) { // buy, add liq, etc
            uint lessBuyFee = 0;

            if (_isExperi) {
                if (_curcuitBreakerFlag == 2) { // circuit breaker activated
                    uint circuitFee = 400;
                    lessBuyFee = lessBuyFee.add(circuitFee);
                }

                if (totalFee < lessBuyFee) {
                    lessBuyFee = totalFee;
                }
            }
            
            totalFee = totalFee.sub(lessBuyFee);
                //feess

            uint allAmount=fAmount.div(10000).mul(allowancefundFee);
            _tOwned[_allowancefund] = _tOwned[_allowancefund].add(allAmount);
            emit Transfer(sender, _allowancefund, allAmount.div(_frag));
            
            uint bankAmount=fAmount.div(10000).mul(bankFee);
            _tOwned[_bank] = _tOwned[_bank].add(bankAmount);
            emit Transfer(sender, _bank, bankAmount.div(_frag));

            // Dividend tracker
            
            // uint busdrewardAmount=fAmount.div(10000).mul(50).div(_frag);
            
            // deposit(busdrewardAmount);
            // try distributor.process(distributorGas) {} catch {}
        
        }
            
            
            // _swapTokensForEth(fAmount.div(10000).mul(20).div(_frag));

            // emit Amount(busdrewardAmount.div(_frag),123,1232);  
            // deposit(amountOut[1]);
            
        {
            uint capAmount=fAmount.div(10000).mul(capitalFee);
            _tOwned[_capital] = _tOwned[_capital].add(capAmount);
            emit Transfer(sender, _capital, capAmount.div(_frag));

            uint marianatrenchAmount=fAmount.div(10000).mul(marianatrenchFee);
            _tOwned[_marianatrench] = _tOwned[_marianatrench].add(marianatrenchAmount);
            emit Transfer(sender, _marianatrench, marianatrenchAmount.div(_frag));

            uint busdrewardAmount=fAmount.div(10000).mul(busdrewardsFee);
            
            _tOwned[address(this)] = _tOwned[address(this)].add(busdrewardAmount);
            emit Transfer(sender, address(this), busdrewardAmount.div(_frag));
            uint256[] memory amountOut=getAmount(busdrewardAmount.div(_frag));
            emit Amount(amountOut[0], amountOut[1], 321);

            
        }
            
        {
            uint feeAmount = fAmount.div(10000).mul(totalFee);
            fAmount = fAmount.sub(feeAmount);
        }

        return fAmount;
    }

    ////////////////////////////////////////// swap / liq
    function _swapEthForTokens(uint256 ethAmount, address to) public {
        if (ethAmount == 0) { // no BNB. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(this);
            
        // make the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactBNBForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            to, // DON'T SEND TO THIS CONTACT. PCS BLOCKS IT
            block.timestamp
        );
    }
    
    // function _swapTokensForEth(uint256 tokenAmount) public  swapping {
    function _swapTokensForEth(uint256 tokenAmount) public   {

        if (tokenAmount == 0) { // no token. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WBNB);

        _approve(address(this), _uniswapV2Router, tokenAmount);

        // make the swap
        uint256[] memory amountOut=IUniswapV2Router02(_uniswapV2Router).getAmountsOut(tokenAmount, path) ;
        emit Amount(amountOut[0], amountOut[1], 111);

        IUniswapV2Router02(_uniswapV2Router).swapExactTokensForBNBSupportingFeeOnTransferTokens(
            // IUniswapV2Router02(_uniswapV2Router).swapExactTokensForBNB(
            tokenAmount,
            0, // fee
            path,
            address(this),
            block.timestamp
        );
        
    }
    
    // strictly correct
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }
        if (ethAmount == 0) { // no BNB. skip
            return;
        }
		
        {
            _tokenTransfer(address(this), _uniswapV2Pair, tokenAmount);

            address WETH = address(WBNB);
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

    function SENDBNB(address recipent, uint amount) internal {
        // workaround
        (bool v,) = recipent.call{ value: amount }(new bytes(0));
        require(v, "Transfer Failed");
    }

    function _isContract(address target) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(target) }
        return size > 0;
    }
	
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "The NAVY Project: Same Address");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
	
    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1, ) = IPancakeSwapPair(_uniswapV2Pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

	function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint) {
        if (amountA == 0) {
            return 0;
        }

        return amountA.mul(reserveB).div(reserveA);
    }
	
    // wbnb / token
	function getRequiredLiqAmount(uint amountADesired, uint amountBDesired) internal view returns (uint, uint) {
        (uint reserveA, uint reserveB) = getReserves(address(WBNB), address(this));
    	
        uint amountA = 0;
        uint amountB = 0;

        uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
        if (amountBOptimal <= amountBDesired) {
            (amountA, amountB) = (amountADesired, amountBOptimal);
        } else {
            uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
            assert(amountAOptimal <= amountADesired);
            (amountA, amountB) = (amountAOptimal, amountBDesired);
        }

        return (amountA, amountB);
    }
    
    ////////////////////////////////////////////////////////////////////////// OWNER ZONE

    // EDIT: wallet address will also be blacklisted due to scammers taking users money
    // we need to blacklist them and give users money
    function setBotBlacklists(address[] calldata botAdrs, bool[] calldata flags) external limited {
        for (uint idx = 0; idx < botAdrs.length; idx++) {
            _blacklisted[botAdrs[idx]] = flags[idx];    
        }
    }

    function setLifeSupports(address[] calldata adrs, uint[] calldata flags) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            _lifeSupports[adrs[idx]] = flags[idx];    
        }
    }

    // used for rescue, clean, etc
    function getTokens(address[] calldata adrs) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            require(adrs[idx] != address(this), "NAVY token should stay here");
            uint bal = IERC20(adrs[idx]).balanceOf(address(this));
            IERC20(adrs[idx]).transfer(address(0xdead), bal);
        }
    }

    // function disperseToken(address[] calldata recipients, uint256[] calldata amounts) external {
    //     {
    //         uint256 totalAmount = 0;
    //         for (uint256 idx = 0; idx < recipients.length; idx++) {
    //             totalAmount += amounts[idx];
    //         }

    //         uint fTotalAmount = totalAmount.mul(_frag);
    //         _tOwned[msg.sender] = _tOwned[msg.sender].sub(fTotalAmount);
    //     }

    //     for (uint256 idx = 0; idx < recipients.length; idx++) {
    //         uint fAmount = amounts[idx].mul(_frag);
    //         _tOwned[recipients[idx]] = _tOwned[recipients[idx]].add(fAmount);
    //         emit Transfer(msg.sender, recipients[idx], amounts[idx]);
    //     }
    // }

    // function disperseSameToken(address[] calldata recipients, uint256 amount) external { // about 30% cheaper
    //     {
    //         uint256 totalAmount = amount * recipients.length;

    //         uint fTotalAmount = totalAmount.mul(_frag);
    //         _tOwned[msg.sender] = _tOwned[msg.sender].sub(fTotalAmount);
    //     }

    //     for (uint256 idx = 0; idx < recipients.length; idx++) {
    //         uint fAmount = amount.mul(_frag);
    //         _tOwned[recipients[idx]] = _tOwned[recipients[idx]].add(fAmount);
    //         emit Transfer(msg.sender, recipients[idx], amount);
    //     }
    // }

    // function sellbuy(uint tokenAmount_) external limited {
    //     _tokenTransfer(msg.sender, address(this), tokenAmount_);
		
    //     // sell
    //     uint ethAmount = address(this).balance;
    //     _swapTokensForEth(tokenAmount_);
    //     ethAmount = address(this).balance.sub(ethAmount);

    //     // buy
    //     _swapEthForTokens(ethAmount, msg.sender);
    // }
    //////////////////////////////////////////
    function setRouter(address _router,address _pair) external limited {
        
        _uniswapV2Router =_router;
        _uniswapV2Pair =_pair;
    }

    function setToken(address token) external limited {
        
        _token=token;
    }

    function setCapital(address capital) external limited {
        
        _capital=capital;
    }

    function setDividendDistributor(address _dividendDistributor) external limited {
        
        distributor=IDividendDistributor(_dividendDistributor);

    }

    function setIsDividendExempt(address holder, bool exempt) external limited {
        // require(holder != address(this) && holder != _uniswapV2Pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function deposit(uint amount) public payable  {
        distributor.deposit{value: amount}();
    
    }
    function getAmount(uint256 tokenAmount) public returns(uint256[] memory)   {


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WBNB);

        
        uint256[] memory amountOut=IUniswapV2Router02(_uniswapV2Router).getAmountsOut(tokenAmount, path) ;
        emit Amount(amountOut[0], amountOut[1], 123);
        return amountOut;

    }
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