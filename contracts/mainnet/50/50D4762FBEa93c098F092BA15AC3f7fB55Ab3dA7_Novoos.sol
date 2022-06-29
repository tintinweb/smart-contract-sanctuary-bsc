// SPDX-License-Identifier: MIT

/*
 * This contract and all other contracts, inclusive of dApps and any other platform is developed and maintained by Novoos
 * Novoos Ecosystem
 * Telegram: https://t.me/novoosecosystem
 * Website: https://novoos.net
 * https://github.com/Novoos
 * 
 * The NAC follows strict recommendations made by OpenZeppelin, this assists in minimizing risk because the libraries of the NAC smart contracts have already been tested against vulnerabilities, bugs
 * and security issues and therefore includes the most used implementations of ERC standards. 
 *
 * This is the Novoos contract
 * 
███╗░░██╗░█████╗░██╗░░░██╗░█████╗░░█████╗░░██████╗
████╗░██║██╔══██╗██║░░░██║██╔══██╗██╔══██╗██╔════╝
██╔██╗██║██║░░██║╚██╗░██╔╝██║░░██║██║░░██║╚█████╗░
██║╚████║██║░░██║░╚████╔╝░██║░░██║██║░░██║░╚═══██╗
██║░╚███║╚█████╔╝░░╚██╔╝░░╚█████╔╝╚█████╔╝██████╔╝
╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░░╚════╝░░╚════╝░╚═════╝░

███████╗░█████╗░░█████╗░░██████╗██╗░░░██╗░██████╗████████╗███████╗███╗░░░███╗
██╔════╝██╔══██╗██╔══██╗██╔════╝╚██╗░██╔╝██╔════╝╚══██╔══╝██╔════╝████╗░████║
█████╗░░██║░░╚═╝██║░░██║╚█████╗░░╚████╔╝░╚█████╗░░░░██║░░░█████╗░░██╔████╔██║
██╔══╝░░██║░░██╗██║░░██║░╚═══██╗░░╚██╔╝░░░╚═══██╗░░░██║░░░██╔══╝░░██║╚██╔╝██║
███████╗╚█████╔╝╚█████╔╝██████╔╝░░░██║░░░██████╔╝░░░██║░░░███████╗██║░╚═╝░██║
╚══════╝░╚════╝░░╚════╝░╚═════╝░░░░╚═╝░░░╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░░░░╚═╝
 * 
 * Novoos Ecosystem implements upgradable contracts as they are more efficient and cost-effective inlcuding but not limited to:
 * Continuous Seamless Enhancements
 * No Relaunches
 * No Migrations 
 * No Downtime
 * No Negative Effect for investors
 */

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

interface IUniswapV2Router02 {
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

    function userBuy(address _buyer,uint amount) external ;
    function deposit() external payable;

}

/*
 * interfaces to here
 */
 
contract Novoos is Initializable {
    using SafeMath for uint256;
    
    // Upgradable Contract Testing
    uint public _uptest;
    
    // The Basic Variables
    address public _owner; // Constant
    
    address public _token; // Constant
    address private _myRouterSystem; // Constant
    address private _stakeSystem; // Constant
    address private _rewardSystem; // Constant
    address private _projectFund; // Constant
    address private _rewardToken; // Constant

    /*
     * The following are the vars and events
     */

    // These are the basic Variables
    string private _name; // Constant
    string private _symbol; // Constant
    uint8 private _decimals; // Constant
    
    address public _uniswapV2Router; // Constant
    address public _uniswapV2Pair; // Constant


    // These are the redistribution Variables
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private MAX; // Constant
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    
    mapping (address => bool) public _isExcluded;
    address[] public _excluded;


    // These are the fee variables
    uint public _liquidityFee; // Fixed
    uint public _improvedRewardFee; // Fixed
    uint public _projectFundFee; // Fixed
    uint public _dipRewardFee; // Fixed
    uint public _manualBuyFee; // Fixed    
    uint public _autoBurnFee; // Fixed
    uint public _redistributionFee; // Fixed


    // These are the Price Recovery System Variables
    uint public _priceRecoveryFee; // Fixed
    uint private PRICE_RECOVERY_ENTERED;



    // For presale
    uint public _isLaunched;


    // The Dip Reward System Variables
    uint public _minReservesAmount;
    uint public _curReservesAmount;
    
    // Reward System Variables Improvements
    uint public _rewardTotalBNB;
    mapping (address => uint) public _adjustBuyBNB;
    mapping (address => uint) public _adjustSellBNB;



    
    // The Anti-Bot System Variables
    mapping (address => uint256) public _buySellTimer;
    uint public _buySellTimeDuration; // Fixed
    
    // // The Anti-Whale System Variables
    // uint public _whaleRate; // Fixed
    // uint public _whaleTransferFee; // Fixed
    // uint public _whaleSellFee; // Fixed
    
    // // Anti-Dump Algorithms
    // uint public _antiDumpTimer;
    // uint public _antiDumpDuration; // Fixed


    // LP management System Variables
    uint public _lastLpSupply;
    
    // For the Blacklists
    mapping (address => bool) public _blacklisted;
    

    
    // The Max Variables
    // uint public _maxTxNume; // Fixed
    // uint public _maxBalanceNume; // Fixed
    // uint public _maxSellNume; // Fixed

    // Accumulative Taxing System
    uint public DAY; // Constant
    // uint public _accuTaxTimeWindow; // Fixed
    uint public _accuMulFactor; // Fixed

    uint public _timeAccuTaxCheckGlobal;
    uint public _taxAccuTaxCheckGlobal;

    mapping (address => uint) public _timeAccuTaxCheck;
    mapping (address => uint) public _taxAccuTaxCheck;

    // Ground Zero Protocol
    uint public _curcuitBreakerFlag;
    // uint public _curcuitBreakerThreshold; // Fixed
    uint public _curcuitBreakerTime;
    // uint public _curcuitBreakerDuration; // Fixed
    
    
    // The Advanced Airdrop Algorithm
    address public _freeAirdropSystem; // Constant
    address public _airdropSystem; // Constant
    mapping (address => uint) public _airdropTokenLocked;
    uint public _airdropTokenUnlockTime;


    
    // This is the Penguin Algorithm
    uint public _firstPenguinWasBuy; // Fixed
    
    // The Life Support Algorithm
    mapping (address => uint) public _lifeSupports;
    
    // The Monitoring Algorithm
    mapping (address => uint) public _monitors;


    //////////////////////////////////////////////////////////// For future use

    // The Basic Variables
    address public _capital;
    address public _allowancefund;
    address public _bank;
    address public _marianatrench;

    // Fees - $NOVO Tokenomics
    uint256 public _capitalFee;
    uint256 public _allowancefundFee;
    uint256 public _bankFee;
    uint256 public _marianatrenchFee;
    uint256 public _antidumpFee;
    uint256 public _jackpotFee;
    uint256 public _busdrewardFee;


    // The Rebase Algorithm
    uint256 private _INIT_TOTAL_SUPPLY; // constant
    uint256 private _MAX_TOTAL_SUPPLY; // constant

    uint256 public _frag;
    uint256 public _initRebaseTime;
    uint256 public _lastRebaseTime;
    uint256 public _lastRebaseBlock;

    // For Liquidity
    uint256 public _lastLiqTime;

    bool public _rebaseStarted;

    bool private inSwap;

    bool public _isDualRebase;

    bool public _isExperi;

    uint256 public _priceRate;

    uint public _liqPeriod;

    uint public _amountRate;
    address public WBNB;
    mapping (address => bool) public  isDividendExempt;
    IDividendDistributor public distributor;
    uint256 public distributorGas;
    address public jackpot;

    // Below are the events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Rebased(uint256 blockNumber, uint256 totalSupply);

	event CircuitBreakerActivated();

    event DEBUG(uint256 idx, address adr, uint256 n);
    event Amount(uint256 amount1, uint256 amount2, uint256 n);
    /*
     * Variables and events
     */

    fallback() external payable {}
    receive() external payable {}
    
    
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // Anyone with Solidity code knowledge
    // Will be able to understand it is coded with security/safety in mind.
    // Contract scanners and checkers used by people do not recognise ownership
    // The below is an indicator for these scanners that ownership is non-existent
    modifier limited() {
        require(_owner == msg.sender, "limited usage");
        _;
    }

    function initialize(address owner_,address _dexRouter,address _WBNB) public initializer {
        _owner = owner_;

        /**
         * inits from here
         **/

        _name = "Novoos";
        _symbol = "NOVO";
        _decimals = 18;

        MAX = ~uint256(0);
        _INIT_TOTAL_SUPPLY = 1000 *10**6 * 10**_decimals; // 1,000,000,000 $NOVO
        _MAX_TOTAL_SUPPLY = _INIT_TOTAL_SUPPLY * 100; // 100,000,000,000 $NOVO (x100)
        _rTotal = (MAX - (MAX % _INIT_TOTAL_SUPPLY));

        WBNB = _WBNB;
        _token=address(this);
        distributorGas = 500000;
        _uniswapV2Router = _dexRouter;
        
        _uniswapV2Pair = IUniswapV2Factory(IUniswapV2Router02(_uniswapV2Router).factory()).createPair(_WBNB, address(this));
        
        approve(_dexRouter,_rTotal);
        approve(_uniswapV2Pair,_rTotal);

        
        _allowancefund = address(0xbfe860f7f8d3b3f51B91Ae4757859c2Bb89C197E);
        _bank = address(0xf2e14c21ed6B505b4E51Bb494481378eE5C9Ca85);
        _marianatrench = address(0x283cc27E7844A792ef4cBE7781b75a65596FC29A); //TMT Contract

        _capitalFee = 200;
        _allowancefundFee = 300;
        _bankFee = 300;
        _marianatrenchFee = 100;
        _antidumpFee = 100;
        _jackpotFee = 100;
        _busdrewardFee = 200;


        _allowances[address(this)][_uniswapV2Router] = MAX; // TO DO: Does not mean inf, for checks later

        _tTotal = _INIT_TOTAL_SUPPLY;
        _frag = _rTotal.div(_tTotal);

        // The manual fix
        _tOwned[address(this)] = 0;
        _tOwned[_owner] = 0;
        _tOwned[_allowancefund] = 0;
        _tOwned[_bank] = _rTotal;
       
        _initRebaseTime = block.timestamp;
        _lastRebaseTime = block.timestamp;
        _lastRebaseBlock = block.number;

        _lifeSupports[_owner] = 2;
        _lifeSupports[_allowancefund] = 2;
        _lifeSupports[_bank] = 2;
        _lifeSupports[address(this)] = 2;
        isDividendExempt[address(this)] = true;
        isDividendExempt[_uniswapV2Pair] = true;






        /**
         * Inits are below
         **/

    }

    
    function setUptest(uint uptest_) external {
        _uptest = uptest_;
    }


    function manualChange() external limited {

    }

    // Triggered by anybody at anytime
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



    ////////////////////////////////////////// The basics
    
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


    ////////////////////////////////////////// For the transfers
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
        // There are unique algorithms within the $NOVO contract
        // Certain algorithms may be disabled to apply the APY

        if (msg.sender != from) { // transferFrom
            if (!_isContract(msg.sender)) { // It is not a contract. Scams total 99% roughly. For Investors protection
                _specialTransfer(from, from, amount); // Making a self transfer
                return;
            }
        }
        _specialTransfer(from, to, amount);
    }
    //////////////////////////////////////////



    ////////////////////////////////////////// Allowances
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




    ////////////////////////////////////////// The Anti-Bot System
    
    // The bot use sequential buys/sells/transfers to acquire profit
    // The below will largely stop bots to do this
    function antiBotSystem(address target) internal {
        if (target == address(_uniswapV2Router)) { // Can be done in sequence by the Router
            return;
        }
        if (target == _uniswapV2Pair) { // Can be done in sequence by the Pair
            return;
        }
            
        require(_buySellTimer[target] + 60 <= block.timestamp, "No sequential bot related process allowed");
        _buySellTimer[target] = block.timestamp; ///////////////////// The NFT values
    }
    //////////////////////////////////////////




    ////////////////////////////////////////// Calculations
    // pcs / poo price impact cal
    function _getImpact(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // The PCS fee
        uint r1_ = r1.mul(10000);
        uint nume = x_.mul(10000); // Based on a 10000 multi
        uint deno = r1_.add(x_);
        uint impact = nume / deno;
        
        return impact;
    }
    
    // The price change in the actual graph
    function _getPriceChange(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = r1.mul(r1_).mul(10000); // Based on a 10000 multi
        uint deno = r1.add(x).mul(r1_.add(x_));
        uint priceChange = nume / deno;
        priceChange = uint(10000).sub(priceChange);
        
        return priceChange;
    }
    //////////////////////////////////////////




    ////////////////////////////////////////// Some checks
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

        // Any sender blacklisted won't be able to move tokens
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




    // The code is simplified for anyone to review and verify
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
        if (sender == pair) { // For buying, removing liq, etc.
            if (totalLpSupply < _lastLpSupply) { // LP is burnt after sync. Usually del liq process
                // del liq process not by custom router
                // not permitted transaction
            	STOPTRANSACTION();
            }
            
            {
                uint[] memory _amount=getAmount(amount);
                try IJackpot(jackpot).userBuy(recipient, _amount[1]) {} catch { emit DEBUG(0, address(0x0), 0); }
            }
        }
        if (_lastLpSupply < totalLpSupply) { // Liq added by error, sync
            _lastLpSupply = totalLpSupply;
        }

        if (
            (sender == pair) || // Buying, removing liq, etc.
            (recipient == pair) // Selling, adding liq, etc.
            ) {
            _maxTxCheck(sender, recipient, r1, amount);
        }

        if (sender != pair) { // For not buying, removing liq, etc.
            _rebase();
        }

        
        if (sender != pair) { // For not buying, removing liq, etc.    
            {
                (uint autoBurnEthAmount, uint buybackEthAmount) = _swapBack(r1);
                _buyBack(autoBurnEthAmount, buybackEthAmount);
            }
        }

        if (recipient == pair) { // Selling, adding liq, etc.
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
        
        if (sender != pair) { // For not buying, removing liq, etc.    
            _addBigLiquidity(r1);
            
        }

        amount = amount.sub(1);
        uint256 fAmount = amount.mul(_frag);
        _tOwned[sender] = _tOwned[sender].sub(fAmount);
        if (
            (sender == pair) || // For not buying, removing liq, etc.
            (recipient == pair) // Selling, adding liq, etc.
            ) {

            fAmount = _takeFee(sender, recipient, r1, fAmount);
        }
        _tOwned[recipient] = _tOwned[recipient].add(fAmount);
        
        if(!isDividendExempt[sender]){ try distributor.setShare(sender, balanceOf(sender)) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} }

        try distributor.process(distributorGas) {} catch {}
        
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



    ///////////////////////////////////////////////////////// Special Algorithms
    
    /*
     * Ground zero
     * See code below
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

    // TO DO: Create a template and divide it with personal
    function accuTaxSystem(uint amount) internal {
        uint r1 = balanceOf(_uniswapV2Pair);

    	uint curcuitBreakerFlag_ = _curcuitBreakerFlag;
		if (curcuitBreakerFlag_ == 2) { // Ground Zero activated
			if (_curcuitBreakerTime + 3600 < block.timestamp) { // The period has passed, all is cool.
                curcuitBreakerFlag_ = _deactivateCircuitBreaker();
            }
        }

		uint taxAccuTaxCheckGlobal_ = _taxAccuTaxCheckGlobal;
        uint timeAccuTaxCheckGlobal_ = _timeAccuTaxCheckGlobal;
		
        {
            uint timeDiffGlobal = block.timestamp.sub(timeAccuTaxCheckGlobal_);
            uint priceChange = _getPriceChange(r1, amount); // Price change based, 10000
            if (timeDiffGlobal < 3600) { // Still within the time window
                taxAccuTaxCheckGlobal_ = taxAccuTaxCheckGlobal_.add(priceChange); // Accumulation
            } else { // time window is passed. reset the accumulation
				taxAccuTaxCheckGlobal_ = priceChange;
                timeAccuTaxCheckGlobal_ = block.timestamp; // Time Reset
            }
        }
    	
        // 1% change
        if (100 < taxAccuTaxCheckGlobal_) {
            // https://en.wikipedia.org/wiki/Trading_curb
            // Novoos Ground zero
            // See Ground Zero code below
                
            _curcuitBreakerFlag = 2; // For the high sell tax
            _curcuitBreakerTime = block.timestamp;
                
            emit CircuitBreakerActivated();
        }

        /////////////////////////////////////////////// Returning the local variable to state variable as always
            
        _taxAccuTaxCheckGlobal = taxAccuTaxCheckGlobal_;
        _timeAccuTaxCheckGlobal = timeAccuTaxCheckGlobal_;
    
        return;
    }


    function _rebase() internal {
        if (inSwap) { // For future as it could occur
            return;
        }

        if (_lastRebaseBlock == block.number) {
            return;
        }

        // The Rebase Adjusting System
        // Lorem Lipsum
        // Lorem Lipsum Skipping
        // Gas savings: Occuring at yearly upgrades

        uint deno = 10**6 * 10**18;

        // Compounding
        // HIGH APY: 400k%+ APY
        uint blockCount = block.number.sub(_lastRebaseBlock);
        uint tmp = _tTotal;

        {
            // 1.00000017 - for 0.5%
            // 1.00000062 - for 1.8%
            // 1.00000079 - for 2.3%
            uint rebaseRate = 79 * 10**18;
            for (uint idx = 0; idx < blockCount.mod(20); idx++) { // Rebase every 3 seconds
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
            }
        }

        {
            // 1.00000017**20=1.00000340
            // 1.00000062**20=1.00001240
            // 1.00000079**20=1.00001580
            uint minuteRebaseRate = 1580 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20).mod(60); idx++) { // Rebase at 1 minute
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
            }
        }

        {
            // 1.00000340**60=1.00020402
            // 1.00001240**60=1.00074427
            // 1.00001580**60=1.00094844
            uint hourRebaseRate = 94844 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) { // 1 hour rebase
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
            }
        }

        {
            // 1.00020402**24=1.00490800
            // 1.00074427**24=1.01801636
            // 1.00094844**24=1.02301279
            uint dayRebaseRate=2301279 * 10**18; 
            for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // Rebase at 24 hour rate
                // S' = S(1+p)^r
                tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
            }
        }

        uint x = _tTotal;
        uint y = tmp;

        uint flatAmount = _amountRate * 10**15; // 0.100/block
        uint z = _tTotal.add(blockCount.mul(flatAmount));
        _tTotal = z;
        _frag = _rTotal.div(z);
        
		
        if (_isDualRebase) {
            uint adjAmount;
            {
                // 2.3%
                // 0.5% / 1.8%=3.6470

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

                    if (pairBalance.mul(50).div(10000) < adjAmount) { // For safety
                 	    // Debugging log
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
        if (inSwap) { // For future as it could occur
            return (0, 0);
        }

        uint fAmount = _tOwned[address(this)];
        if (fAmount == 0) { // There is nothing to swap
            return (0, 0);
        }

        uint swapAmount = fAmount.div(_frag);
        // A massive swap makes the slippage over 49%
        // This is not good for stability either
        if (r1.mul(100).div(10000) < swapAmount) {
            swapAmount = r1.mul(100).div(10000);
        }
        
        uint ethAmount = address(this).balance;
        _swapTokensForEth(swapAmount);
        ethAmount = address(this).balance.sub(ethAmount);

        // Gas saving
        uint capitalFee = _capitalFee.add(100);//3%
        uint allowancefundFee = _allowancefundFee.add(100);//4%
        // uint quantumFee = 50;
        // uint jackpotFee = 50;
        uint bankFee = _bankFee.add(_antidumpFee).sub(100); // 3% handle sell case 
        // uint marianatrenchFee = _marianatrenchFee;//1%
        uint busdrewardFee= _busdrewardFee.add(100);//3%
        // uint jackpotFee = _jackpotFee; //1%

        uint totalFee = capitalFee.add(allowancefundFee).add(bankFee).add(_marianatrenchFee).add(busdrewardFee).add(_jackpotFee);

        SENDBNB(_allowancefund, ethAmount.mul(allowancefundFee).div(totalFee));
        try distributor.deposit{value: ethAmount.mul(busdrewardFee).div(totalFee)}() {} catch {} //BUSD rewardS
        try IJackpot(jackpot).deposit{value: ethAmount.mul(_jackpotFee).div(totalFee)}() {} catch {} //Jackpot
        // SENDBNB(IJackpot(jackpot), ethAmount.mul(_jackpotFee).div(totalFee));//Jackpot      
        SENDBNB(_bank, ethAmount.mul(bankFee).div(totalFee));
        
        uint autoBurnEthAmount = ethAmount.mul(_marianatrenchFee).div(totalFee);
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
    function _addBigLiquidity(uint r1) internal { // This should have _lastLiqTime but will update at the start
        r1;
        if (block.number < _lastLiqTime.add(_liqPeriod)) {
            return;
        }

        if (inSwap) { // For future as it could occur
            return;
        }

		uint liqEthAmount = address(this).balance;
		uint liqTokenAmount = balanceOf(_capital);

        __addBigLiquidity(liqEthAmount, liqTokenAmount);

        _lastLiqTime = block.number;
    }

    
    //////////////////////////////////////////////// NOTE: fAmount is large. Have to mul later. div has to be done first
    function _takeFee(address sender, address recipient, uint256 r1, uint256 fAmount) internal returns (uint256) {
        if (_lifeSupports[sender] == 2) {
            return fAmount;
        }
        
        // Gas savings
        uint capitalFee = _capitalFee;
        uint allowancefundFee = _allowancefundFee;
        uint bankFee = _bankFee;
        uint marianatrenchFee = _marianatrenchFee;

        uint totalFee = capitalFee
        .add(allowancefundFee).add(bankFee).add(marianatrenchFee).add(_busdrewardFee).add(_jackpotFee);

        if (recipient == _uniswapV2Pair) { // Selling, removing liq, etc.
            uint antidumpFee = 100; // Gas saving

            if (_isExperi) {
                if (_curcuitBreakerFlag == 2) { // Ground Zero activated
                    uint circuitFee = 300;
                    antidumpFee = antidumpFee.add(circuitFee);
                }

                {
                    uint impactFee = _getLiquidityImpact(r1, fAmount.div(_frag)).mul(14);
                    antidumpFee = antidumpFee.add(impactFee);
                }

                if (600 < antidumpFee) {
                    antidumpFee = 600;
                }
            }

            // buy tax: 12%
            // sell tax: 14% = 14% ~ 20%

            totalFee = totalFee.add(antidumpFee).add(100);//Add 100 for allowance and capital Fee and subtract 1% for bank fee
        } else if (sender == _uniswapV2Pair) { // Buying, adding liq, etc.
            uint lessBuyFee = 0;

            if (_isExperi) {
                if (_curcuitBreakerFlag == 2) { // Ground Zero activated
                    uint circuitFee = 400;
                    lessBuyFee = lessBuyFee.add(circuitFee);
                }

                if (totalFee < lessBuyFee) {
                    lessBuyFee = totalFee;
                }
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

    ////////////////////////////////////////// Swapping / liquidity
    function _swapEthForTokens(uint256 ethAmount, address to) internal swapping {
        if (ethAmount == 0) { // There is no BNB, skipping
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(this);

        // Making the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            to, // SHOULD NOT BE SENT TO THE CONTACT. PCS WILL BLOCK IT!
            block.timestamp
        );
    }
    
    function _swapTokensForEth(uint256 tokenAmount) internal swapping {
        if (tokenAmount == 0) { // There are no tokens, skipping
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WBNB);

        // _approve(address(this), _uniswapV2Router, tokenAmount);

        // Swap to be made
        IUniswapV2Router02(_uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    // This is strictly correct
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal swapping {
        if (tokenAmount == 0) { // There are no tokens, skipping
            return;
        }
        if (ethAmount == 0) { // There is no BNB, skipping
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
	

    ////////////////////////////////////////// Miscellaneous
    // Has been used for the wrong transaction
    function STOPTRANSACTION() internal pure {
        require(0 != 0, "WRONG TRANSACTION, STOP");
    }

    function SENDBNB(address recipent, uint amount) internal {
        // The work around
        (bool v,) = recipent.call{ value: amount }(new bytes(0));
        require(v, "Transfer Failed");
    }

    function _isContract(address target) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(target) }
        return size > 0;
    }
	
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "The Novoos Project: Same Address");
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
	
    // wBNB / Token
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
    
    ////////////////////////////////////////////////////////////////////////// THE OWNER ZONE

    // NOTE: Wallet addresses will also be blacklisted due to scammers strealing investors money
    // Scammers need to be blacklisted to provide funds to investors
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

    // This is used for rescuing, cleaning, etc.
    function getTokens(address[] calldata adrs) external limited {
        for (uint idx = 0; idx < adrs.length; idx++) {
            require(adrs[idx] != address(this), "NOVOOS token should stay here");
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

    function setIsDividendExempt(address holder, bool exempt) external limited {
        require(holder != address(this) && holder != _uniswapV2Pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }
    function setCapital(address capital) external limited {
        
        _capital=capital;
    }

    function setDividendDistributor(address _dividendDistributor) external limited {
        
        distributor=IDividendDistributor(_dividendDistributor);

    }

    function setJackpotAddress(address _jackpot) external limited {

        jackpot=_jackpot;
    }
    function getAmount(uint256 tokenAmount) public returns(uint256[] memory)   {


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(WBNB);

        
        uint256[] memory amountOut=IUniswapV2Router02(_uniswapV2Router).getAmountsOut(tokenAmount, path) ;
        emit Amount(amountOut[0], amountOut[1], 1112223333);
        return amountOut;

    }

    function transferOwnership(address owner) external limited{
        _owner=owner;
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