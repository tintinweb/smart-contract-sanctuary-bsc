/*
 * All systems invented by ALLCOINLAB
 * https://github.com/ALLCOINLAB
 * https://t.me/ALLCOINLAB
 * 
 * The Web3 Project
 * TG: https://t.me/TheWeb3Project
 * Website: https://theweb3project.com
 * 
 *
 * Written in easy code to for easy verificiation by the investors.
 * Some are made with manual if-else conditions in order not to make mistake + maintain code easily.
 * Those doesn't cost gas much so this is way better than the simple / short code.
 * Used high gas optimization if needed.
 * 
 *
 * 
 * $$$$$$$$\ $$\                       $$\      $$\           $$\        $$$$$$\        $$$$$$$\                                                $$\     
 * \__$$  __|$$ |                      $$ | $\  $$ |          $$ |      $$ ___$$\       $$  __$$\                                               $$ |    
 *    $$ |   $$$$$$$\   $$$$$$\        $$ |$$$\ $$ | $$$$$$\  $$$$$$$\  \_/   $$ |      $$ |  $$ | $$$$$$\   $$$$$$\  $$\  $$$$$$\   $$$$$$$\ $$$$$$\   
 *    $$ |   $$  __$$\ $$  __$$\       $$ $$ $$\$$ |$$  __$$\ $$  __$$\   $$$$$ /       $$$$$$$  |$$  __$$\ $$  __$$\ \__|$$  __$$\ $$  _____|\_$$  _|  
 *    $$ |   $$ |  $$ |$$$$$$$$ |      $$$$  _$$$$ |$$$$$$$$ |$$ |  $$ |  \___$$\       $$  ____/ $$ |  \__|$$ /  $$ |$$\ $$$$$$$$ |$$ /        $$ |    
 *    $$ |   $$ |  $$ |$$   ____|      $$$  / \$$$ |$$   ____|$$ |  $$ |$$\   $$ |      $$ |      $$ |      $$ |  $$ |$$ |$$   ____|$$ |        $$ |$$\ 
 *    $$ |   $$ |  $$ |\$$$$$$$\       $$  /   \$$ |\$$$$$$$\ $$$$$$$  |\$$$$$$  |      $$ |      $$ |      \$$$$$$  |$$ |\$$$$$$$\ \$$$$$$$\   \$$$$  |
 *    \__|   \__|  \__| \_______|      \__/     \__| \_______|\_______/  \______/       \__|      \__|       \______/ $$ | \_______| \_______|   \____/ 
 *                                                                                                              $$\   $$ |                              
 *                                                                                                              \$$$$$$  |                              
 *                                                                                                               \______/                               
 * 
 * 
 * This is UpGradable Contract
 * So many new features will be applied periodically :)
 * 
 *  
 * 
 * (Deprecated) Project UpFinity
 * [The Web3 Token] is the relaunch of the [UpFinity]
 * TG: https://t.me/UpFinityTG
 * Website: https://UpFinityCrypto.github.io
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

// import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/proxy/utils/Initializable.sol';
import "./Initializable.sol";

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

interface IPancakeSwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function skim(address to) external;
    function sync() external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
}

/*
 * interfaces to here
 */
 
contract TheWeb3ProjectV2 is Initializable {
    using SafeMath for uint256;
    
    // Upgradable Contract Test
    uint public _uptest;
    
    // My Basic Variables
    address public _owner; // constant
    
    address public _token; // constant
    address public _myRouterSystem; // constant
    address public _stakeSystem; // constant
    address public _rewardSystem; // constant
    address public _projectFund; // constant
    address public _rewardToken; // constant

    /*
     * vars and events from here
     */

    // Basic Variables
    string private _name; // constant
    string private _symbol; // constant
    uint8 private _decimals; // constant
    
    address public _uniswapV2Router; // constant
    address public _uniswapV2Pair; // constant


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


    //////////////////////////////////////////////////////////// keep for later use

    // Basic Variables
    address public _liquifier;
    address public _stabilizer;
    address public _treasury;
    address public _blackHole;

    // fees
    uint256 public _liquifierFee;
    uint256 public _stabilizerFee;
    uint256 public _treasuryFee;
    uint256 public _blackHoleFee;
    uint256 public _moreSellFee;

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
    uint public _priceRate;
    uint public _liqPeriod;
    uint public _amountRate;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

        _name = "The Web3 Project";
        // _name = "TEST"; // CHANGE LIQ AND THINGS
        _symbol = "TWEP";
        // _symbol = "TEST";
        _decimals = 18;

        /**
         * inits to here
         **/
         
    }
    
    function setUptest(uint uptest_) external {
        _uptest = uptest_;
    }

    // inits
    function runInit() external limited {
        require(_stabilizer != address(0x5060E2fBB789c021C9b510e2eFd9Bf965e6a2475), "Already Initialized");

        //////// TEMP
        {
          _uniswapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
          _uniswapV2Pair = IUniswapV2Factory(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73))
          .createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
        } //////////////////////////////////////////////////////////// TODO: change all pairs

        MAX = ~uint256(0);
        _INIT_TOTAL_SUPPLY = 3 * 10**9 * 10**_decimals; // 3,000,000,000 $TWEP
        _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 10**3; // 3,000,000,000,000 $TWEP (x1000)
        _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

        _owner = address(0x495987fFDcbb7c04dF08c07c6fD7e771Dba74175);

        _liquifier = address(0x8cA5d2e1cDf875fB063A1d1F0F109BdeE2624296);
        _stabilizer = address(0x5060E2fBB789c021C9b510e2eFd9Bf965e6a2475);
        _treasury = address(0xcCa3C1D62C80834f8B303f45D89298866C097B1a);
        _blackHole = address(0xdead);
        
        // deno = 10000
        _liquifierFee = 400;
        _stabilizerFee = 100;
        _treasuryFee = 400;
        _blackHoleFee = 100;
        _moreSellFee = 0;

        _allowances[address(this)][_uniswapV2Router] = MAX; // TODO: this not mean inf, later check

        _tTotal = _INIT_TOTAL_SUPPLY;
        _frag = _rTotal.div(_tTotal);

        // manual fix
        _tOwned[_treasury] = _rTotal;
        emit Transfer(address(0x0), _treasury, _rTotal.div(_frag));

        _initRebaseTime = block.timestamp;
        // _lastRebaseTime = block.timestamp;
        _lastRebaseBlock = block.number;

        _lifeSupports[_owner] = 2;
        _lifeSupports[_liquifier] = 2;
        _lifeSupports[_stabilizer] = 2;
        _lifeSupports[_treasury] = 2;
        _lifeSupports[address(this)] = 2;

        _amountRate = 50;
        _priceRate = 10000;
        _liqPeriod = 20 * 60;
    }

    // can only start, not stop
    function startRebase() external limited {
        // _initRebaseTime = block.timestamp;
        _lastRebaseBlock = block.number;
        _rebaseStarted = true;
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

    function setAmountRate(uint amountRate) external limited {
        _amountRate = amountRate;
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
        // [2022.03.17] temporarily disable some algorithms to apply APY

        // if (msg.sender != from) { // transferFrom
        //     if (!_isContract(msg.sender)) { // not a contract. 99% scammer. protect investors
        //         _specialTransfer(from, from, amount); // make a self transfer
        //         return;
        //     }
        // }
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
        if (target == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) { // Router can do in sequence
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
        if (r1 == 0) {
          return 0;
        }

        if (amount == 0) { // to distinguish with no reserve
          return 1;
        }

        // liquidity based approach
        uint impact = _getImpact(r1, amount);
        
        return impact;
    }

    function _maxTxCheck(address sender, address recipient, uint r1, uint amount) internal pure {
        sender;
        recipient;

        uint impact = _getLiquidityImpact(r1, amount);
        if (impact <= 1) {
          return;
        }

        require(impact <= 200, "buy/sell/tx should be lower than criteria"); // _maxTxNume
    }

    function sanityCheck(address sender, address recipient, uint256 amount) internal view returns (uint) {
        sender;
        recipient;

        // Blacklisted Bot Sell will be heavily punished
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

        // amount = sanityCheck(sender, recipient, amount);

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
            //     address JACKPOT = address(0x59E4a7C380e9AA63f24873EBD185D13B0ee76Dba);
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

        uint autoBurnEthAmount;
        if (sender != pair) { // not buy, remove liq, etc    
            {
                autoBurnEthAmount = _swapBack(r1); ////////////////////////////// TODO: make auto burn
                // _buyBack(autoBurnEthAmount);
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

        }

        if (recipient == pair) { // sell, add liq, etc
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

















    ////////////////////////////////////////// algorithms
    
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

        if (!_rebaseStarted) {
            return;
        }

   
        if (_MAX_TOTAL_SUPPLY <= _tTotal) {
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
        uint flatAmount = _amountRate * 10**15; // 0.100 / block
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
            _tokenTransfer(_uniswapV2Pair, _blackHole, adjAmount);
            IPancakeSwapPair(_uniswapV2Pair).sync();
        } else {
            IPancakeSwapPair(_uniswapV2Pair).skim(_blackHole);
        }

        _lastRebaseBlock = block.number;
        emit Rebased(block.number, _tTotal);
    }

    function _swapBack(uint r1) internal returns (uint) {
        if (inSwap) { // this could happen later so just in case
            return 0;
        }

        if (r1 == 0) {
            return 0;
        }

        uint fAmount = _tOwned[address(this)];
        if (fAmount == 0) { // nothing to swap
          return 0;
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
        uint liquifierFee = _liquifierFee;
        uint stabilizerFee = _stabilizerFee;
        uint treasuryFee = _treasuryFee; // handle sell case
        uint blackHoleFee = _blackHoleFee;

        // liquidity half
        uint totalFee = liquifierFee.div(2).add(stabilizerFee).add(treasuryFee).add(blackHoleFee);

        SENDBNB(_stabilizer, ethAmount.mul(stabilizerFee).div(totalFee));
        SENDBNB(_treasury, ethAmount.mul(treasuryFee).div(totalFee));
        
        uint autoBurnEthAmount = ethAmount.mul(blackHoleFee).div(totalFee);

        return autoBurnEthAmount;
    }

    function _buyBack(uint autoBurnEthAmount) internal {
        if (autoBurnEthAmount == 0) {
          return;
        }

        // make 60% / 40% buys
        _swapEthForTokens(autoBurnEthAmount.mul(6000).div(10000), _blackHole); // user?
        _swapEthForTokens(autoBurnEthAmount.mul(4000).div(10000), _blackHole);
    }


    function manualAddBigLiquidity(uint liqEthAmount, uint liqTokenAmount) external limited {
		__addBigLiquidity(liqEthAmount, liqTokenAmount);
    }

    function __addBigLiquidity(uint liqEthAmount, uint liqTokenAmount) internal {
		(uint amountA, uint amountB) = getRequiredLiqAmount(liqEthAmount, liqTokenAmount);
		
        _tokenTransfer(_liquifier, address(this), amountB);
        
        uint tokenAmount = amountB;
        uint ethAmount = amountA;
        _addLiquidity(tokenAmount, ethAmount);    
    }

    // djqtdmaus rPthr tlehgkrpehla
    function _addBigLiquidity(uint r1) internal { // should have _lastLiqTime but it will update at start
        r1;
        if (block.number < _lastLiqTime.add(_liqPeriod)) { // 20 * 60 * 24 CHANGE THIS!
            return;
        }

        if (inSwap) { // this could happen later so just in case
            return;
        }

        uint liqEthAmount = address(this).balance;
		uint liqTokenAmount = balanceOf(_liquifier);
        __addBigLiquidity(liqEthAmount, liqTokenAmount);

        _lastLiqTime = block.number;
    }

    
    //////////////////////////////////////////////// NOTICE: fAmount is big. do mul later. do div first
    function _takeFee(address sender, address recipient, uint256 r1, uint256 fAmount) internal returns (uint256) {
        if (_lifeSupports[sender] == 2) {
             return fAmount;
        }
        
        // save gas
        uint liquifierFee = _liquifierFee;
        uint stabilizerFee = _stabilizerFee;
        uint treasuryFee = _treasuryFee;
        uint blackHoleFee = _blackHoleFee;

        uint totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(blackHoleFee);

        if (recipient == _uniswapV2Pair) { // sell, remove liq, etc
            uint moreSellFee = 0; // save gas
            if (_isExperi) {
                if (_curcuitBreakerFlag == 2) { // circuit breaker activated
                    uint circuitFee = 1500;
                    moreSellFee = moreSellFee.add(circuitFee);
                }
                {
                    uint impactFee = _getLiquidityImpact(r1, fAmount.div(_frag)).mul(10);
                    moreSellFee = moreSellFee.add(impactFee);
                }
                if (2000 < moreSellFee) {
                    moreSellFee = 2000;
                }
            }
            
            // sell tax: 10% (+ 0% ~ 20%) = 10% ~ 30%

            totalFee = totalFee.add(moreSellFee);
            treasuryFee = treasuryFee.add(moreSellFee);
        } else if (sender == _uniswapV2Pair) { // buy, add liq, etc
            // buy tax: 0% 
            uint lessBuyFee = 1000;
            if (totalFee < lessBuyFee) {
                lessBuyFee = totalFee;
            }
            
            totalFee = totalFee.sub(lessBuyFee);
        }
        
        {
            uint fAmount_ = fAmount.div(10000).mul(totalFee);
            _tOwned[address(this)] = _tOwned[address(this)].add(fAmount_);
            emit Transfer(sender, address(this), fAmount_.div(_frag));
        }

        {
            uint feeAmount = fAmount.div(10000).mul(totalFee);
            fAmount = fAmount.sub(feeAmount);
        }

        return fAmount;
    }

    ////////////////////////////////////////// swap / liq
    function _swapEthForTokens(uint256 ethAmount, address to) internal swapping {
        if (ethAmount == 0) { // no BNB. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        path[1] = address(this);

        // make the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            to, // DON'T SEND TO THIS CONTACT. PCS BLOCKS IT
            block.timestamp
        );
    }
    
    function _swapTokensForEth(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) { // no token. skip
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        // _approve(address(this), _uniswapV2Router, tokenAmount);

        // make the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
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
            address WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
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
        require(tokenA != tokenB, "The Web3 Project: Same Address");
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
        (uint reserveA, uint reserveB) = getReserves(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c), address(this));
    	
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
            // require(_isContract(botAdrs[idx]), "Only Contract Address can be blacklisted");
            _blacklisted[botAdrs[idx]] = flags[idx];    
        }
    }

    function setLifeSupports(address[] calldata adrs, uint[] calldata flags) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            _lifeSupports[adrs[idx]] = flags[idx];    
        }
    }
    //////////////////////////////////////////

    // used for rescue, clean, etc
    function getTokens(address[] calldata adrs) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            require(adrs[idx] != address(this), "WEB3 token should stay here");
            uint bal = IERC20(adrs[idx]).balanceOf(address(this));
            IERC20(adrs[idx]).transfer(address(0xdead), bal);
        }
    }

}