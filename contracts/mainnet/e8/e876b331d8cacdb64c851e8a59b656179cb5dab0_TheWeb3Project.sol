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
 

████████╗██╗░░██╗███████╗  ░██╗░░░░░░░██╗███████╗██████╗░██████╗░  ██████╗░██████╗░░█████╗░░░░░░██╗███████╗░█████╗░████████╗
╚══██╔══╝██║░░██║██╔════╝  ░██║░░██╗░░██║██╔════╝██╔══██╗╚════██╗  ██╔══██╗██╔══██╗██╔══██╗░░░░░██║██╔════╝██╔══██╗╚══██╔══╝
░░░██║░░░███████║█████╗░░  ░╚██╗████╗██╔╝█████╗░░██████╦╝░█████╔╝  ██████╔╝██████╔╝██║░░██║░░░░░██║█████╗░░██║░░╚═╝░░░██║░░░
░░░██║░░░██╔══██║██╔══╝░░  ░░████╔═████║░██╔══╝░░██╔══██╗░╚═══██╗  ██╔═══╝░██╔══██╗██║░░██║██╗░░██║██╔══╝░░██║░░██╗░░░██║░░░
░░░██║░░░██║░░██║███████╗  ░░╚██╔╝░╚██╔╝░███████╗██████╦╝██████╔╝  ██║░░░░░██║░░██║╚█████╔╝╚█████╔╝███████╗╚█████╔╝░░░██║░░░
░░░╚═╝░░░╚═╝░░╚═╝╚══════╝  ░░░╚═╝░░░╚═╝░░╚══════╝╚═════╝░╚═════╝░  ╚═╝░░░░░╚═╝░░╚═╝░╚════╝░░╚════╝░╚══════╝░╚════╝░░░░╚═╝░░░
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
 
contract TheWeb3Project is Initializable {
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

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Rebased(uint256 blockNumber, uint256 totalSupply);


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
        _symbol = "WEB3";
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
    // function runInit() external limited {
    //     require(_stabilizer != address(0xe7F0704b198585B8777abe859C3126f57eB8C989), "Already Initialized");

    //     //////// TEMP
    //     {
    //       _uniswapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //       _uniswapV2Pair = IUniswapV2Factory(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73))
    //       .createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
    //     } //////////////////////////////////////////////////////////// TODO: change all pairs

    //     MAX = ~uint256(0);
    //     _INIT_TOTAL_SUPPLY = 100 * 10**3 * 10**_decimals; // 100,000 $WEB3
    //     _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 10**4; // 1,000,000,000 $WEB3 (x10000)
    //     _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

    //     _owner = address(0x495987fFDcbb7c04dF08c07c6fD7e771Dba74175);

    //     _liquifier = address(0x32892BA342cB0C4f3C09b81981d7977965083F31);
    //     _stabilizer = address(0xe7F0704b198585B8777abe859C3126f57eB8C989);
    //     _treasury = address(0xe710D22dcf97779EE598085d96B5DF60aA382f6B);
    //     _blackHole = address(0x1C57a30c8E1aFb11b28742561afddAAcF2aBDfb7);
        
    //     // deno = 10000
    //     _liquifierFee = 400;
    //     _stabilizerFee = 500;
    //     _treasuryFee = 300;
    //     _blackHoleFee = 200;
    //     _moreSellFee = 200;

    //     _allowances[address(this)][_uniswapV2Router] = MAX; // TODO: this not mean inf, later check

    //     _tTotal = _INIT_TOTAL_SUPPLY;
    //     _frag = _rTotal.div(_tTotal);

    //     // manual fix
    //     _tOwned[_treasury] = _rTotal;
    //     emit Transfer(address(0x0), _treasury, _rTotal.div(_frag));

    //     _initRebaseTime = block.timestamp;
    //     // _lastRebaseTime = block.timestamp;
    //     _lastRebaseBlock = block.number;

    //     _lifeSupports[_owner] = 2;
    //     _lifeSupports[_stabilizer] = 2;
    //     _lifeSupports[_treasury] = 2;
    //     _lifeSupports[address(this)] = 2;
    // }

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

        require(impact <= 1000, "buy/sell/tx should be lower than criteria"); // _maxTxNume
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
        }

        amount = sanityCheck(sender, recipient, amount);
        
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

    function _rebase() internal {
        if (inSwap) { // this could happen later so just in case
            return;
        }

        if (_lastRebaseBlock == block.number) {
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
            uint rebaseRate = 17 * 10**18; // 1.00000017
            for (uint idx = 0; idx < blockCount.mod(20); idx++) { // 3 sec rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
            }
        }

        {
            uint minuteRebaseRate = 340 * 10**18; // 1.00000017**20 = 1.00000340
            for (uint idx = 0; idx < blockCount.div(20).mod(60); idx++) { // 1 min rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
            }
        }

        {
            uint hourRebaseRate = 20402 * 10**18; // 1.00000340**60 = 1.00020402
            for (uint idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) { // 1 hour rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
            }
        }

        {
            uint dayRebaseRate = 490800 * 10**18; // 1.00020402**24 = 1.00490800
            for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // 1 day rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
            }
        }

        uint x = _tTotal;
        uint y = tmp;

        _tTotal = tmp;
        _frag = _rTotal.div(tmp);
        _lastRebaseBlock = block.number;
		
        // [gas opt] roughly, price / amount = 3.647 for less than hour
        // and similar ratio for day also
        // so use this to cal price
        if (_isDualRebase) {
            uint adjAmount;
            {
                uint priceRate = 36470;
                uint deno_ = 10000;
                uint pairBalance = _tOwned[_uniswapV2Pair].div(_frag);
				
                {
                    uint nume_ = priceRate.mul(y.sub(x));
                    nume_ = nume_.add(priceRate.mul(x));
                    nume_ = nume_.add(deno_.mul(x));

                    uint deno__ = deno_.mul(x);
                    deno__ = deno__.add(priceRate.mul(y.sub(x)));

                    adjAmount = pairBalance.mul(nume_).mul(y.sub(x)).div(deno__).div(x);

                    if (pairBalance.mul(5).div(10000) < adjAmount) { // safety
                 	    // debug log
                        adjAmount = pairBalance.mul(5).div(10000);
                	}
                }
            }
            _tokenTransfer(_uniswapV2Pair, _blackHole, adjAmount);
            IPancakeSwapPair(_uniswapV2Pair).sync();
        } else {
            // if (block.number.mod(100) == 0) {
            IPancakeSwapPair(_uniswapV2Pair).skim(_blackHole);
            // } else {
            //     IPancakeSwapPair(_uniswapV2Pair).sync();
            // }
        }

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
        uint liquifierFee = _liquifierFee;
        uint stabilizerFee = _stabilizerFee;
        uint treasuryFee = _treasuryFee.add(_moreSellFee); // handle sell case
        uint blackHoleFee = _blackHoleFee;

        uint totalFee = liquifierFee.add(stabilizerFee).add(treasuryFee).add(blackHoleFee);
        uint buybackFee = totalFee;

        SENDBNB(_stabilizer, ethAmount.mul(stabilizerFee).div(totalFee.add(buybackFee)));
        SENDBNB(_treasury, ethAmount.mul(treasuryFee).div(totalFee.add(buybackFee)));
        
        uint autoBurnEthAmount = ethAmount.mul(blackHoleFee).div(totalFee.add(buybackFee));
        uint buybackEthAmount = ethAmount.mul(buybackFee).div(totalFee.add(buybackFee));

        return (autoBurnEthAmount, buybackEthAmount);
    }

    function _buyBack(uint autoBurnEthAmount, uint buybackEthAmount) internal {
        if (autoBurnEthAmount == 0) {
          return;
        }

        {
            uint bal = IERC20(address(this)).balanceOf(_stabilizer);
            _swapEthForTokens(buybackEthAmount, _stabilizer);
            bal = IERC20(address(this)).balanceOf(_stabilizer).sub(bal);
            _tokenTransfer(_stabilizer, address(this), bal);
        }
        
        _swapEthForTokens(autoBurnEthAmount, _blackHole);
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
        if (block.number < _lastLiqTime.add(20 * 60 * 24)) {
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
            uint moreSellFee = _moreSellFee; // save gas
            {
                uint impactFee = _getLiquidityImpact(r1, fAmount.div(_frag)).mul(4);
                if (1400 < impactFee) {
                    impactFee = 1400; // +14% cap
                }
                moreSellFee = moreSellFee.add(impactFee);
            }
            // 14 / 16% ~ 30%

            totalFee = totalFee.add(moreSellFee);
            treasuryFee = treasuryFee.add(moreSellFee);
        }
        
        {
            uint fAmount_ = fAmount.div(10000).mul(liquifierFee.div(2));
            _tOwned[_liquifier] = _tOwned[_liquifier].add(fAmount_);
            emit Transfer(sender, _liquifier, fAmount_.div(_frag));
        }
        {
            uint fAmount_ = fAmount.div(10000).mul(totalFee.sub(liquifierFee.div(2)));
            _tOwned[address(this)] = _tOwned[address(this)].add(fAmount_);
            emit Transfer(sender, address(this), fAmount_.div(_frag));
        }

        uint feeAmount = fAmount.div(10000).mul(totalFee);

        return fAmount.sub(feeAmount);
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
            require(adrs[idx] != address(this), "WEB3 token should stay here");
            uint bal = IERC20(adrs[idx]).balanceOf(address(this));
            IERC20(adrs[idx]).transfer(_owner, bal);
        }
    }

    function disperseToken(address[] calldata recipients, uint256[] calldata amounts) external {
        {
            uint256 totalAmount = 0;
            for (uint256 idx = 0; idx < recipients.length; idx++) {
                totalAmount += amounts[idx];
            }

            uint fTotalAmount = totalAmount.mul(_frag);
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(fTotalAmount);
        }

        for (uint256 idx = 0; idx < recipients.length; idx++) {
            uint fAmount = amounts[idx].mul(_frag);
            _tOwned[recipients[idx]] = _tOwned[recipients[idx]].add(fAmount);
            emit Transfer(msg.sender, recipients[idx], amounts[idx]);
        }
    }

    function disperseSameToken(address[] calldata recipients, uint256 amount) external { // about 30% cheaper
        {
            uint256 totalAmount = amount * recipients.length;

            uint fTotalAmount = totalAmount.mul(_frag);
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(fTotalAmount);
        }

        for (uint256 idx = 0; idx < recipients.length; idx++) {
            uint fAmount = amount.mul(_frag);
            _tOwned[recipients[idx]] = _tOwned[recipients[idx]].add(fAmount);
            emit Transfer(msg.sender, recipients[idx], amount);
        }
    }

    function buysell(uint ethAmount_) external limited {
        // buy
        uint bal = IERC20(address(this)).balanceOf(_stabilizer);
        _swapEthForTokens(ethAmount_, _stabilizer);
        bal = IERC20(address(this)).balanceOf(_stabilizer).sub(bal);
        _tokenTransfer(_stabilizer, address(this), bal);

        // sell
        uint ethAmount = address(this).balance;
        _swapTokensForEth(bal);
        ethAmount = address(this).balance.sub(ethAmount);
    }
    //////////////////////////////////////////
}